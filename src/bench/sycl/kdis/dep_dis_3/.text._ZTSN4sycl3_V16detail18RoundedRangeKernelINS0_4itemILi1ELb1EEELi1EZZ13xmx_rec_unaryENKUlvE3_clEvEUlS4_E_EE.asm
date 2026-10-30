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
(W)     mov (8|M0)               r2.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r2.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r115.0<1>:ud  r4.3<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r127.0<1>:d   r1.0<1;1,0>:uw                   {$2.src}
(W)     mov (1|M0)               r114.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r31.0<1>:ud   r114.0<0;1,0>:ud  r127.0<1;1,0>:ud {AccWrEn,Compacted,I@1}
        add (8|M0)               r30.0<1>:ud   acc0.0<1;1,0>:ud  r115.0<0;1,0>:ud
        addc (8|M0)              r9.0<1>:ud    r31.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r9.0<1;1,0>:ud    r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud  r30.0<1;1,0>:ud  {$1.dst}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r3.0<1;1,0>:d     r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:ud    r3.0<1;1,0>:ud    r4.7<0;1,0>:ud  
(~f1.1) goto (8|M0)                          L44072                  L44072                
L456:
(W)     and (1|M0)               r6.0<1>:d     r6.6<0;1,0>:d     -2:w               {Compacted,$2.dst}
(W)     cmp (8|M0)    (eq)f0.1   null<1>:d     r5.0<0;1,0>:d     0:w              
(W)     cmp (8|M0)    (eq)f0.0   null<1>:d     r5.3<0;1,0>:d     0:w              
(W)     cmp (8|M0)    (eq)f1.1   null<1>:d     r6.0<0;1,0>:d     2:w               {I@3}
(W)     and (1|M0)               r6.0<1>:d     r6.6<0;1,0>:d     -3:w               {Compacted}
(W)     mov (1|M0)               r5.9<1>:uw    f0.1<0;1,0>:uw                  
(W)     mov (1|M0)               r5.14<1>:uw   f0.0<0;1,0>:uw                   {Compacted}
(W)     cmp (8|M0)    (eq)f1.0   null<1>:d     r6.0<0;1,0>:d     1:w               {I@3}
(W)     cmp (8|M0)    (eq)f0.1   null<1>:d     r6.6<0;1,0>:d     4:w              
(W)     mov (1|M0)               r5.15<1>:uw   f1.1<0;1,0>:uw                  
(W)     cmp (8|M0)    (eq)f0.0   null<1>:w     r6.28<0;1,0>:b    0:w              
(W)     cmp (8|M0)    (eq)f1.1   null<1>:w     r5.16<0;1,0>:b    0:w              
(W)     mov (2|M0)               r5.5<1>:d     r6.4<1;1,0>:d                   
(W)     mov (2|M0)               r6.1<1>:d     r7.4<1;1,0>:d                   
        mov (8|M0)               r11.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r10.0<1>:f    r3.0<1;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r6.6<1>:f     -0.0:f                               {Compacted,I@6}
(W)     mov (1|M0)               r6.0<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (1|M0)               r6.1<1>:uw    f0.1<0;1,0>:uw                   {Compacted}
(W)     mov (1|M0)               r6.5<1>:f     inf:f                               {Compacted,I@4}
(W)     mov (1|M0)               r6.4<1>:d     -1:w                              
(W)     mov (1|M0)               r6.6<1>:uw    f0.0<0;1,0>:uw                   {Compacted}
(W)     mov (1|M0)               r6.7<1>:uw    f1.1<0;1,0>:uw                  
L744:
(W)     mov (1|M0)               f1.0<1>:uw    r5.9<0;1,0>:uw                  
(~f1.0) goto (8|M0)                          L808                  L808                
L776:
        mov (8|M0)               r73.0<1>:d    -1:w                              
        goto (8|M0)                          L808                  L1160                
L808:
        join (8|M0)                          L1160                                
L824:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r8.3<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
        mov (8|M0)               r122.0<1>:f   r11.0<1;1,0>:ud                  {Compacted,F@5}
(W)     mov (1|M0)               r6.7<1>:ud    r8.3<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r8.4<1>:f     r8.3<0;1,0>:f                    {$6}
(W)     add (1|M0)               r8.5<1>:d     r5.0<0;1,0>:d     -r6.7<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.7<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r56.0<1>:ud   r122.0<1;1,0>:f                  {F@2}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r6.7<1>:f     r8.4<0;0>:f       r6.7<0;0>:f       r8.4<0>:f        {F@1}
        add (8|M0)               r56.0<1>:d    r11.0<1;1,0>:d    -r56.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               r35.0<1>:f    r122.0<1;1,0>:f   r6.7<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r8.4<1>:f     r8.5<0;1,0>:ud                  
        mov (8|M0)               r49.0<1>:ud   r35.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r54.0<1>:f    r56.0<1;1,0>:ud                  {Compacted,I@2}
        mov (8|M0)               r20.0<1>:f    r49.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r122.0<1;0>:f     r20.0<1;0>:f      -r8.3<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r54.0<1;0>:f      r20.0<1;0>:f      -r8.4<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r106.0<1>:f   r6.7<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r106.0<1>:ud  r106.0<1;1,0>:f                  {A@1}
        add (8|M0)               r69.0<1>:d    r106.0<1;1,0>:d   r49.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r69.0<1>:d    r69.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (8|M0)               r69.0<1>:d    r11.0<1;1,0>:d    -r69.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f1.0   r124.0<1>:ud  r69.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (8|M0)              r73.0<1>:d    r106.0<1;0>:d     r49.0<1;0>:d      -r124.0<1>:d     {I@1}
L1160:
        join (8|M0)                          L44072                                
L1176:
(W)     mov (1|M0)               f0.1<1>:uw    r5.14<0;1,0>:uw                 
(~f0.1) goto (8|M0)                          L1240                  L1240                
L1208:
        mov (8|M0)               r76.0<1>:d    -1:w                               {$3.src}
        goto (8|M0)                          L1240                  L1608                
L1240:
        join (8|M0)                          L1608                                
L1256:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r8.3<1>:f     r5.3<0;1,0>:ud                   {Compacted,A@1}
        mov (8|M0)               r24.0<1>:f    r73.0<1;1,0>:ud                  {Compacted,I@7}
(W)     mov (1|M0)               r6.7<1>:ud    r8.3<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r8.4<1>:f     r8.3<0;1,0>:f                    {$7}
(W)     add (1|M0)               r8.5<1>:d     r5.3<0;1,0>:d     -r6.7<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.7<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r74.0<1>:ud   r24.0<1;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$7.dst}
(W)     mad (1|M0)               r6.7<1>:f     r8.4<0;0>:f       r6.7<0;0>:f       r8.4<0>:f        {F@1}
        add (8|M0)               r74.0<1>:d    r73.0<1;1,0>:d    -r74.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               r44.0<1>:f    r24.0<1;1,0>:f    r6.7<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r8.4<1>:f     r8.5<0;1,0>:ud                  
        mov (8|M0)               r52.0<1>:ud   r44.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r64.0<1>:f    r74.0<1;1,0>:ud                  {Compacted,I@2}
        mov (8|M0)               r30.0<1>:f    r52.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r24.0<1;0>:f      r30.0<1;0>:f      -r8.3<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r64.0<1;0>:f      r30.0<1;0>:f      -r8.4<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r107.0<1>:f   r6.7<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r109.0<1>:ud  r107.0<1;1,0>:f                  {A@1}
        sync.nop                             null                             {Compacted,$5.src}
        add (8|M0)               r71.0<1>:d    r109.0<1;1,0>:d   r52.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r71.0<1;1,0>:d    r5.6<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r71.0<1>:d    r71.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
        add (8|M0)               r71.0<1>:d    r73.0<1;1,0>:d    -r71.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f0.1   r121.0<1>:ud  r71.0<1;1,0>:ud   r5.3<0;1,0>:ud   {I@1}
        sync.nop                             null                             {Compacted,$3.src}
        add3 (8|M0)              r76.0<1>:d    r109.0<1;0>:d     r52.0<1;0>:d      -r121.0<1>:d     {I@1}
L1608:
        join (8|M0)                          L44072                                
L1624:
(W)     mul (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:d    r5.6<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r120.0<1>:d   r76.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
        add (8|M0)               r123.0<1>:d   r73.0<1;1,0>:d    -r120.0<1;1,0>:d {Compacted,I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r123.0<1;1,0>:ud  r5.2<0;1,0>:ud   {I@1}
(f0.1)  cmp (8|M0)    (lt)f0.1   null<1>:ud    r76.0<1;1,0>:ud   r5.1<0;1,0>:ud  
(f0.1)  goto (8|M0)                          L1720                  L1720                
L1696:
        mov (8|M0)               r12.0<1>:f    0.0:f                               {Compacted,$5.dst}
        goto (8|M0)                          L1720                  L2352                
L1720:
        join (8|M0)                          L2352                                
L1736:
(W)     mul (8|M0)               acc0.0<1>:d   r73.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted}
        mach (8|M0)              r119.0<1>:d   r73.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r76.0<1;1,0>:ud   r5.4<0;1,0>:uw  
        mach (8|M0)              r111.0<1>:ud  r76.0<1;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (1|M0)               f0.0<1>:uw    r6.7<0;1,0>:uw                  
        mov (8|M0)               r110.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r84.0<1>:d    r11.0<1;1,0>:d    -r119.0<1;1,0>:d {Compacted,I@5}
        addc (8|M0)              r108.0<1>:ud  r110.0<1;1,0>:ud  r123.0<1;1,0>:ud {AccWrEn,Compacted,I@2}
        add (8|M0)               r117.0<1>:ud  acc0.0<1;1,0>:ud  r111.0<1;1,0>:ud
        mul (8|M0)               acc0.0<1>:ud  r108.0<1;1,0>:ud  r5.0<0;1,0>:uw   {I@2}
        mach (8|M0)              r113.0<1>:ud  r108.0<1;1,0>:ud  r5.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r112.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:ud    r117.0<2;1,0>:uw {I@4}
        mach (8|M0)              r118.0<1>:d   r5.0<0;1,0>:ud    r117.0<1;1,0>:d 
        mov (8|M0)               r64.0<1>:f    r112.0<1;1,0>:f                  {Compacted,I@3}
        add (8|M0)               r41.0<1>:d    r113.0<1;1,0>:d   r118.0<1;1,0>:d  {Compacted,I@1}
(f0.0)  goto (8|M0)                          L2152                  L2152                
L1928:
        shl (8|M0)               r34.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (8|M0)               r13.0<1>:ud   r64.0<1;1,0>:ud   31:w              
        shl (8|M0)               r21.0<1>:d    r41.0<1;1,0>:d    1:w               {Compacted,I@4}
        shl (8|M0)               r12.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted,$5.dst}
        addc (8|M0)              r33.0<1>:ud   r34.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        or (8|M0)                r21.0<1>:d    r21.0<1;1,0>:d    r13.0<1;1,0>:d   {Compacted,I@3}
        shr (8|M0)               r32.0<1>:ud   r84.0<1;1,0>:ud   31:w              
        add3 (8|M0)              r43.0<1>:ud   acc0.0<1;0>:ud    r21.0<1;0>:ud     r5.6<0>:ud       {I@2}
        addc (8|M0)              r42.0<1>:ud   r33.0<1;1,0>:ud   r12.0<1;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        add3 (8|M0)              r35.0<1>:ud   acc0.0<1;0>:ud    r43.0<1;0>:ud     r32.0<1>:ud      {I@3}
        mov (8|M0)               r90.1<2>:ud   r35.0<1;1,0>:ud                  {I@1}
        mov (8|M0)               r90.0<2>:d    r42.0<1;1,0>:d                  
        send.ugm (8|M0)          r116     r90     null:0  0x0            0x04180B80           {A@1,$8} // wr:2+0, rd:1; load.ugm.d16u32.a64.ca.ca
        mov (8|M0)               r7.0<1>:uw    r116.0<2;1,0>:uw                 {$8.dst}
        mov (8|M0)               r12.0<1>:f    r7.0<1;1,0>:hf                   {I@1}
        goto (8|M0)                          L2152                  L2352                
L2152:
        join (8|M0)                          L2352                                
L2168:
        shl (8|M0)               r31.0<1>:d    r64.0<1;1,0>:d    2:w               {Compacted,$3.src}
        shr (8|M0)               r7.0<1>:ud    r64.0<1;1,0>:ud   30:w               {F@1}
        shl (8|M0)               r20.0<1>:d    r41.0<1;1,0>:d    2:w               {Compacted}
        shl (8|M0)               r127.0<1>:d   r84.0<1;1,0>:d    2:w               {Compacted}
        addc (8|M0)              r30.0<1>:ud   r31.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        or (8|M0)                r20.0<1>:d    r20.0<1;1,0>:d    r7.0<1;1,0>:d    {Compacted,I@3}
        shr (8|M0)               r29.0<1>:ud   r84.0<1;1,0>:ud   30:w              
        add3 (8|M0)              r41.0<1>:ud   acc0.0<1;0>:ud    r20.0<1;0>:ud     r5.6<0>:ud       {I@2}
        addc (8|M0)              r40.0<1>:ud   r30.0<1;1,0>:ud   r127.0<1;1,0>:ud {AccWrEn,Compacted}
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        add3 (8|M0)              r34.0<1>:ud   acc0.0<1;0>:ud    r41.0<1;0>:ud     r29.0<1>:ud      {I@3}
        sync.nop                             null                             {Compacted,$5.src}
        mov (8|M0)               r70.1<2>:ud   r34.0<1;1,0>:ud                  {I@1}
        mov (8|M0)               r70.0<2>:d    r40.0<1;1,0>:d                  
        send.ugm (8|M0)          r12      r70     null:0  0x0            0x04180580           {A@1,$5} // wr:2+0, rd:1; load.ugm.d32.a64.ca.ca
L2352:
        join (8|M0)                          L44072                                
L2368:
(W)     mov (1|M0)               f1.1<1>:uw    r5.15<0;1,0>:uw                 
(~f1.1) goto (8|M0)                          L30656                  L30656                
L2400:
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {$5.dst}
        mov (8|M0)               r13.0<1>:f    r7.0<1;1,0>:hf                   {F@1}
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   r13.0<1;1,0>:f    -4.0:f               {Compacted,F@1}
        sel (8|M0)    (lt)f0.0   r17.0<1>:f    acc0.0<1;1,0>:f   4.0:f               {Compacted}
        and (8|M0)    (ne)f0.0   r14.0<1>:d    r17.0<1;1,0>:d    8388607:d               {F@1}
        shr (8|M0)               r16.0<1>:ud   r17.0<1;1,0>:ud   23:w              
        and (8|M0)               r15.0<1>:d    r16.0<1;1,0>:d    255:w               {Compacted,I@1}
        cmp (8|M0)    (ne)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r15.0<1;1,0>:d    255:w               {I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r15.0<1;1,0>:d    255:w              
(~f1.1) goto (8|M0)                          L2576                  L2576                
L2552:
        mov (8|M0)               r20.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L2576                  L8384                
L2576:
        join (8|M0)                          L8384                                
L2592:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r15.0<1;1,0>:d    255:w              
(~f1.0) goto (8|M0)                          L2664                  L2664                
L2640:
        mov (8|M0)               r20.0<1>:f    -inf:f                               {Compacted}
        goto (8|M0)                          L2664                  L8384                
L2664:
        join (8|M0)                          L8384                                
L2680:
        or (8|M0)     (eq)f1.0   null<1>:d     r15.0<1;1,0>:d    r14.0<1;1,0>:d  
(~f1.0) goto (8|M0)                          L2736                  L2736                
L2712:
        mov (8|M0)               r20.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L2736                  L8384                
L2736:
        join (8|M0)                          L8384                                
L2752:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r15.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.14<1>:hf   0.0:hf                             
        add (8|M0)               r107.0<1>:d   r15.0<1;1,0>:d    -132:w               {Compacted}
(W)     mov (1|M0)               r7.7<1>:d     0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    8388608:d               {F@1}
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r20.0<1>:d    acc0.0<1;1,0>:d   r14.0<1;1,0>:d  
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        mul (8|M0)               acc0.0<1>:ud  r20.0<1;1,0>:ud   0x0:uw              {I@2}
        mach (8|M0)              r123.0<1>:ud  r20.0<1;1,0>:ud   0xE50000:ud              {AccWrEn}
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        sync.nop                             null                             {Compacted,$3.src}
        mov (8|M0)               r31.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r27.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L2936:
(W)     shl (1|M0)               r8.4<1>:d     r7.6<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r8.3<1>:ud    r7.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r7.7<1>:d     r8.3<0;1,0>:d     r8.4<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r54.0<1>:ud   r27.0<1;0>:ud     r8.3<0;0>:ud      r8.4<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    r7.7<0;1,0>:d    {I@3}
        and (8|M0)               r53.0<1>:d    r31.0<1;1,0>:d    r6.7<0;1,0>:d    {Compacted,A@1}
(W)     addc (1|M0)              r21.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r53.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r8.6<1>:hf    0x1:hf                             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  sel (8|M0)               r19.0<1>:uw   r8.6<0;1,0>:uw    0x0:uw              {F@1}
(W)     add (1|M0)               r8.5<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@2}
(f1.0)  sel (8|M0)               r7.0<1>:uw    r8.6<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r12.0<1>:d    r7.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r19.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r18.0<1>:d    r7.5<0;1,0>:d                   
        mov (8|M0)               r42.0<1>:f    r21.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r96.0<1>:d    r8.5<0;1,0>:d                   
(f0.1)  goto (8|M0)                          L3344                  L3344                
L3280:
(W)     mov (1|M0)               r7.6<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r21.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:f     r8.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L2936                                
L3344:
        join (8|M0)                          L8384                                
L3360:
(W)     mov (1|M0)               r6.7<1>:f     8.68805e-44:f                               {I@4}
(~f1.1) sel (8|M0)               r81.0<1>:d    r107.0<1;1,0>:d   -131:w              
        subb (8|M0)              r50.0<1>:ud   r6.7<0;1,0>:ud    r12.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        add3 (8|M0)              r99.0<1>:d    r81.0<1;0>:d      r50.0<1;0>:d      -46:w               {I@1}
        add (8|M0)               r78.0<1>:d    r81.0<1;1,0>:d    r50.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r99.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r105.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r18.0<1>:ud     {F@1}
(~f0.1) goto (8|M0)                          L3512                  L3512                
L3488:
        mov (8|M0)               r20.0<1>:f    -inf:f                               {Compacted}
        goto (8|M0)                          L3512                  L8384                
L3512:
        join (8|M0)                          L8384                                
L3528:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r99.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L6016                  L6016                
L3560:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r99.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L5592                  L5592                
L3592:
(W)     mov (1|M0)               r6.7<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r80.0<1>:d    r81.0<1;0>:d      r50.0<1;0>:d      104:w              
        subb (8|M0)              r109.0<1>:ud  r6.7<0;1,0>:ud    r12.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r109.0<1;1,0>:ud  r80.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r45.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r18.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r45.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L3792                  L3792                
L3728:
        add3 (8|M0)              acc0.0<1>:d   r78.0<1;0>:d      -r109.0<1;0>:d    104:w              
        mov (8|M0)               r51.0<1>:d    0:w                               {$4.src}
        shl (8|M0)               r52.0<1>:d    r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L3792                  L5544                
L3792:
        join (8|M0)                          L5544                                
L3808:
        add3 (8|M0)              r114.0<1>:d   r109.0<1;0>:d     -r78.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r114.0<1;1,0>:d   2:w               {I@1}
(f0.1)  goto (8|M0)                          L3960                  L3960                
L3856:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   2:w              
(~f1.1) goto (8|M0)                          L3960                  L4008                
L3888:
        shr (8|M0)               r18.0<1>:ud   r27.0<1;1,0>:ud   1:w              
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:d    0:w                              
        mov (8|M0)               r64.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L3960                  L4968                
L3960:
        join (8|M0)                          L4008                                
L3976:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   1:w              
(f1.0)  goto (8|M0)                          L4008                  L4912                
L4008:
        join (8|M0)                          L4912                                
L4024:
        add3 (8|M0)              acc0.0<1>:d   r109.0<1;0>:d     -r80.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r63.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L4104                  L4104                
L4072:
        mov (8|M0)               r87.0<1>:d    r27.0<1;1,0>:d                   {$4.src}
        goto (8|M0)                          L4104                  L4248                
L4104:
        join (8|M0)                          L4248                                
L4120:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r63.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r63.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r63.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r110.0<1>:ud  r27.0<1;1,0>:ud   r63.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r23.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r18.0<1>:ud   r31.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r18.0<1>:d    r110.0<1;1,0>:d   r23.0<1;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r87.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@1}
L4248:
        join (8|M0)                          L4912                                
L4264:
        add3 (8|M0)              r67.0<1>:d    r109.0<1;0>:d     -r80.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r62.0<1>:d    r67.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L4344                  L4344                
L4312:
        mov (8|M0)               r18.0<1>:d    r27.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L4344                  L4472                
L4344:
        join (8|M0)                          L4472                                
L4360:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r62.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r62.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r62.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r108.0<1>:ud  r27.0<1;1,0>:ud   r62.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r22.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r18.0<1>:ud   r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r18.0<1>:d    r108.0<1;1,0>:d   r22.0<1;1,0>:d   {I@2}
L4472:
        join (8|M0)                          L4912                                
L4488:
        and (8|M0)    (ne)f1.1   r21.0<1>:d    r67.0<1;1,0>:d    63:w              
        and (8|M0)               r93.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L4576                  L4576                
L4528:
        mov (8|M0)               r34.0<1>:d    -1:w                              
        mov (8|M0)               r41.0<1>:d    -1:w                              
        goto (8|M0)                          L4576                  L4760                
L4576:
        join (8|M0)                          L4760                                
L4592:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r21.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L4696                  L4696                
L4624:
        add (8|M0)               acc0.0<1>:d   r21.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r34.0<1>:d    0:w                              
        shl (8|M0)               r41.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L4696                  L4760                
L4696:
        join (8|M0)                          L4760                                
L4712:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r41.0<1>:d    -1:w                              
        shl (8|M0)               r34.0<1>:d    r6.14<0;1,0>:w    r21.0<1;1,0>:d   {F@1}
L4760:
        join (8|M0)                          L4912                                
L4776:
        bfn.0x28 (8|M0)          r107.0<1>:ud  r27.0<1;0>:ud     r34.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r106.0<1>:ud  r31.0<1;0>:ud     r41.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r107.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r64.0<1>:f    r87.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r106.0<1;1,0>:d   0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@2}
        mov (8|M0)               r74.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L4912                  L4968                
L4912:
        join (8|M0)                          L4968                                
L4928:
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:d    0:w                              
        mov (8|M0)               r64.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
L4968:
        join (8|M0)                          L5544                                
L4984:
        and (8|M0)    (ne)f0.1   r61.0<1>:d    r114.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L5048                  L5048                
L5016:
        mov (8|M0)               r18.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L5048                  L5176                
L5048:
        join (8|M0)                          L5176                                
L5064:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r61.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r61.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r61.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r103.0<1>:ud  r27.0<1;1,0>:ud   r61.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r20.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r18.0<1>:ud   r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r18.0<1>:d    r103.0<1;1,0>:d   r20.0<1;1,0>:d   {I@2}
L5176:
        join (8|M0)                          L5544                                
L5192:
        shl (8|M0)               r95.0<1>:d    r64.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r102.0<1>:d   r93.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r95.0<1>:d    r95.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r38.0<1>:ud   r95.0<1;0>:ud     r102.0<1;0>:ud    r74.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L5296                  L5296                
L5264:
        mov (8|M0)               r55.0<1>:d    0:w                              
        goto (8|M0)                          L5296                  L5456                
L5296:
        join (8|M0)                          L5456                                
L5312:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r38.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L5376                  L5376                
L5344:
        mov (8|M0)               r55.0<1>:d    1:w                              
        goto (8|M0)                          L5376                  L5456                
L5376:
        join (8|M0)                          L5456                                
L5392:
        and (8|M0)    (ne)f1.1   null<1>:d     r18.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r38.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r55.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L5456:
        join (8|M0)                          L5544                                
L5472:
        add (8|M0)               r116.0<1>:d   r55.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.7<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r116.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r52.0<1>:d    r116.0<1;1,0>:d   0:w              
        sync.nop                             null                             {Compacted,$4.src}
(f0.1)  sel (8|M0)               r51.0<1>:d    r6.7<0;1,0>:d     0:w               {F@1}
L5544:
        join (8|M0)                          L5592                                
L5560:
        bfn.0xFE (8|M0)          r20.0<1>:ud   r51.0<1;0>:ud     r52.0<1;0>:ud     r6.6<0>:ud       {I@2} // s0|s1|s2
        goto (8|M0)                          L5592                  L8384                
L5592:
        join (8|M0)                          L6016                                
L5608:
        and (8|M0)    (ne)f1.1   r109.0<1>:d   r50.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L5688                  L5688                
L5640:
        mov (8|M0)               r121.0<1>:d   -1:w                              
        mov (8|M0)               r19.0<1>:d    -1:w                              
        goto (8|M0)                          L5688                  L5872                
L5688:
        join (8|M0)                          L5872                                
L5704:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r109.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L5808                  L5808                
L5736:
        add (8|M0)               acc0.0<1>:d   r109.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r121.0<1>:d   0:w                              
        shl (8|M0)               r19.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L5808                  L5872                
L5808:
        join (8|M0)                          L5872                                
L5824:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r19.0<1>:d    -1:w                              
        shl (8|M0)               r121.0<1>:d   r6.14<0;1,0>:w    r109.0<1;1,0>:d  {F@1}
L5872:
        join (8|M0)                          L6016                                
L5888:
        bfn.0x28 (8|M0)          r101.0<1>:ud  r27.0<1;0>:ud     r121.0<1;0>:ud    r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r100.0<1>:ud  r31.0<1;0>:ud     r19.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r101.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.7<1>:f     -1.4013e-45:f                              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r100.0<1;1,0>:d   0:w               {I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r99.0<1;1,0>:d    -150:w              
(f0.1)  sel (8|M0)               r20.0<1>:f    r6.7<0;1,0>:f     -0.0:f               {F@1}
        goto (8|M0)                          L6016                  L8384                
L6016:
        join (8|M0)                          L8384                                
L6032:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r50.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r103.0<1>:d   r81.0<1;0>:d      r50.0<1;0>:d      81:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r105.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L8096                  L8096                
L6096:
        shl (8|M0)               r97.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r95.0<1>:ud   r42.0<1;1,0>:ud   31:w              
        shl (8|M0)               r73.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r97.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r73.0<1>:d    r73.0<1;1,0>:d    r95.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r73.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r73.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L6328                  L6328                
L6200:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r42.0<1;1,0>:d    39:w               {F@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    0:w              
(~f0.1) goto (8|M0)                          L6328                  L6392                
L6248:
        shr (8|M0)               r18.0<1>:ud   r27.0<1;1,0>:ud   1:w              
        mov (8|M0)               r85.0<1>:d    0:w                              
        mov (8|M0)               r96.0<1>:d    0:w                              
        mov (8|M0)               r80.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r18.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L6328                  L7600                
L6328:
        join (8|M0)                          L6392                                
L6344:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r42.0<1;1,0>:d    38:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    0:w               {I@4}
(f1.1)  goto (8|M0)                          L6392                  L7512                
L6392:
        join (8|M0)                          L7512                                
L6408:
        add (8|M0)               acc0.0<1>:d   -r42.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r112.0<1>:d   -r42.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r69.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L6488                  L6488                
L6456:
        mov (8|M0)               r97.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L6488                  L6624                
L6488:
        join (8|M0)                          L6624                                
L6504:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r69.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r69.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r69.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r97.0<1>:ud   r27.0<1;1,0>:ud   r69.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r40.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r18.0<1>:ud   r31.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r18.0<1>:d    r97.0<1;1,0>:d    r40.0<1;1,0>:d   {I@2}
        mov (8|M0)               r97.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@1}
L6624:
        join (8|M0)                          L7512                                
L6640:
        add (8|M0)               r76.0<1>:d    -r42.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r72.0<1>:d    r76.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L6712                  L6712                
L6680:
        mov (8|M0)               r18.0<1>:d    r27.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L6712                  L6840                
L6712:
        join (8|M0)                          L6840                                
L6728:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r72.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r72.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r72.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r95.0<1>:ud   r27.0<1;1,0>:ud   r72.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r48.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r18.0<1>:ud   r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r18.0<1>:d    r95.0<1;1,0>:d    r48.0<1;1,0>:d   {I@2}
L6840:
        join (8|M0)                          L7512                                
L6856:
        and (8|M0)    (ne)f1.1   r47.0<1>:d    r76.0<1;1,0>:d    63:w              
        and (8|M0)               r96.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L6944                  L6944                
L6896:
        mov (8|M0)               r51.0<1>:d    -1:w                               {$4.src}
        mov (8|M0)               r56.0<1>:d    -1:w                              
        goto (8|M0)                          L6944                  L7136                
L6944:
        join (8|M0)                          L7136                                
L6960:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r47.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L7064                  L7064                
L6992:
        add (8|M0)               acc0.0<1>:d   r47.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r51.0<1>:d    0:w                               {$4.src}
        shl (8|M0)               r56.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L7064                  L7136                
L7064:
        join (8|M0)                          L7136                                
L7080:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r56.0<1>:d    -1:w                              
        sync.nop                             null                             {Compacted,$4.src}
        shl (8|M0)               r51.0<1>:d    r6.14<0;1,0>:w    r47.0<1;1,0>:d   {F@1}
L7136:
        join (8|M0)                          L7512                                
L7152:
        bfn.0x28 (8|M0)          r94.0<1>:ud   r27.0<1;0>:ud     r51.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r93.0<1>:ud   r31.0<1;0>:ud     r56.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r94.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.1   r71.0<1>:d    r112.0<1;1,0>:d   63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r93.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
        mov (8|M0)               r85.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L7328                  L7328                
L7296:
        mov (8|M0)               r18.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L7328                  L7456                
L7328:
        join (8|M0)                          L7456                                
L7344:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r71.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r71.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r71.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r90.0<1>:ud   r27.0<1;1,0>:ud   r71.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r46.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r18.0<1>:ud   r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r18.0<1>:d    r90.0<1;1,0>:d    r46.0<1;1,0>:d   {I@2}
L7456:
        join (8|M0)                          L7512                                
L7472:
        mov (8|M0)               r80.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r18.0<1>:d    r97.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L7512                  L7600                
L7512:
        join (8|M0)                          L7600                                
L7528:
        shr (8|M0)               r18.0<1>:ud   r27.0<1;1,0>:ud   2:w              
        mov (8|M0)               r85.0<1>:d    0:w                              
        mov (8|M0)               r96.0<1>:d    0:w                              
        mov (8|M0)               r80.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r18.0<1>:ud   r27.0<1;1,0>:ud   1:w               {F@1}
L7600:
        join (8|M0)                          L8096                                
L7616:
        shl (8|M0)               r33.0<1>:d    r18.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r89.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r33.0<1>:d    r33.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r99.0<1>:d    r80.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r108.0<1>:ud  r33.0<1;0>:ud     r89.0<1;0>:ud     r85.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (8|M0)                          L7736                  L7736                
L7704:
        mov (8|M0)               r107.0<1>:d   0:w                              
        goto (8|M0)                          L7736                  L7896                
L7736:
        join (8|M0)                          L7896                                
L7752:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r108.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (8|M0)                          L7816                  L7816                
L7784:
        mov (8|M0)               r107.0<1>:d   1:w                              
        goto (8|M0)                          L7816                  L7896                
L7816:
        join (8|M0)                          L7896                                
L7832:
        and (8|M0)    (ne)f0.1   null<1>:d     r80.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r108.0<1;1,0>:d   4:w              
(f0.1)  sel (8|M0)               r107.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
L7896:
        join (8|M0)                          L8096                                
L7912:
        add (8|M0)               r44.0<1>:d    r99.0<1;1,0>:d    r107.0<1;1,0>:d  {Compacted,I@2}
        add3 (8|M0)              r51.0<1>:d    r81.0<1;0>:d      r50.0<1;0>:d      82:w               {$4.src}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r44.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r19.0<1>:d    r51.0<1;1,0>:d    r103.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r19.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L8024                  L8024                
L8000:
        mov (8|M0)               r20.0<1>:f    -inf:f                               {Compacted}
        goto (8|M0)                          L8024                  L8384                
L8024:
        join (8|M0)                          L8096                                
L8040:
(~f0.1) sel (8|M0)               r50.0<1>:d    r44.0<1;1,0>:d    0:w              
        shl (8|M0)               r88.0<1>:d    r19.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r20.0<1>:ud   r88.0<1;0>:ud     r50.0<1;0>:ud     r6.6<0>:ud       {A@1} // s0|s1|s2
        goto (8|M0)                          L8096                  L8384                
L8096:
        join (8|M0)                          L8384                                
L8112:
        and (8|M0)    (ne)f1.0   r40.0<1>:d    r50.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L8176                  L8176                
L8144:
        mov (8|M0)               r94.0<1>:d    -1:w                              
        goto (8|M0)                          L8176                  L8304                
L8176:
        join (8|M0)                          L8304                                
L8192:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r40.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L8256                  L8256                
L8224:
        mov (8|M0)               r94.0<1>:d    0:w                              
        goto (8|M0)                          L8256                  L8304                
L8256:
        join (8|M0)                          L8304                                
L8272:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        shl (8|M0)               r94.0<1>:d    r6.14<0;1,0>:w    r40.0<1;1,0>:d   {F@1}
L8304:
        join (8|M0)                          L8384                                
L8320:
        bfn.0x28 (8|M0)          r93.0<1>:ud   r27.0<1;0>:ud     r94.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r50.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r86.0<1>:d    r103.0<1;1,0>:d   23:w               {Compacted,$4.src}
        shl (8|M0)               r93.0<1>:d    r93.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@3}
        bfn.0xFE (8|M0)          r20.0<1>:ud   r86.0<1;0>:ud     r93.0<1;0>:ud     r6.6<0>:ud       {I@1} // s0|s1|s2
L8384:
        join (8|M0)                          L30656                                
L8400:
        shr (8|M0)               r90.0<1>:ud   r20.0<1;1,0>:ud   23:w               {I@2}
        and (8|M0)    (ne)f1.1   r27.0<1>:d    r20.0<1;1,0>:d    8388607:d              
        and (8|M0)               r22.0<1>:d    r90.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L8496                  L8496                
L8472:
        mov (8|M0)               r20.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L8496                  L12920                
L8496:
        join (8|M0)                          L12920                                
L8512:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r27.0<1;1,0>:d    0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    255:w              
(f1.0)  goto (8|M0)                          L12920                  L12920                
L8560:
        or (8|M0)     (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    r27.0<1;1,0>:d  
(~f1.1) goto (8|M0)                          L8624                  L8624                
L8592:
        mov (8|M0)               r20.0<1>:f    0x3EE50000:f                              
        goto (8|M0)                          L8624                  L12920                
L8624:
        join (8|M0)                          L12920                                
L8640:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r20.0<1;1,0>:d    -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r22.0<1;1,0>:ud   0x7D:uw             
(f1.0)  goto (8|M0)                          L8912                  L8912                
L8688:
(f1.1)  goto (8|M0)                          L8800                  L8800                
L8704:
        mov (8|M0)               r82.0<1>:f    0x3EE50000:f                              
        mov (8|M0)               r119.0<1>:f   r20.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r8.4          L44176                                 {A@1}
L8776:
        mov (8|M0)               r20.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@5}
        goto (8|M0)                          L8800                  L12920                
L8800:
        join (8|M0)                          L8912                                
L8816:
        mov (8|M0)               r82.0<1>:f    r20.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r119.0<1>:f   0x3EE50000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r8.4          L44176                                 {A@1}
L8888:
        mov (8|M0)               r20.0<1>:f    r110.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L8912                  L12920                
L8912:
        join (8|M0)                          L12920                                
L8928:
(f1.1)  goto (8|M0)                          L11048                  L11048                
L8944:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w              
        add (8|M0)               r63.0<1>:d    -r22.0<1;1,0>:d   125:w               {Compacted}
(f1.0)  sel (8|M0)               r35.0<1>:d    r63.0<1;1,0>:d    124:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r35.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L10136                  L10136                
L9016:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r35.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L9720                  L9720                
L9048:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r35.0<1;1,0>:ud   0x18:uw             
(f0.1)  goto (8|M0)                          L9480                  L9480                
L9080:
        cmp (8|M0)    (ne)f0.1   r39.0<1>:d    r22.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r35.0<1;1,0>:d    25:w              
        mov (8|M0)               r32.0<1>:d    -r39.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L9288                  L9288                
L9144:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r35.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f1.1   r62.0<1>:d    r27.0<1;1,0>:d    0:w              
        cmp (8|M0)    (ne)f1.0   r85.0<1>:d    r20.0<1;1,0>:d    0:w               {F@1}
(f0.1)  sel (8|M0)               r32.0<1>:d    -r39.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               acc0.0<1>:d   -r62.0<1;1,0>:d   -r85.0<1;1,0>:d  {I@2}
        mov (8|M0)               r58.0<1>:f    r32.0<1;1,0>:f                   {Compacted,I@2}
        shl (8|M0)               r37.0<1>:d    acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r32.0<1>:d    0:w                               {F@1}
        asr (8|M0)               r18.0<1>:d    r37.0<1;1,0>:d    31:w               {Compacted,I@2}
        goto (8|M0)                          L9288                  L9360                
L9288:
        join (8|M0)                          L9360                                
L9304:
        shr (8|M0)               r84.0<1>:ud   r20.0<1;1,0>:ud   22:w              
        and (8|M0)               r83.0<1>:d    r20.0<1;1,0>:d    4194303:d              
        and (8|M0)               r58.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r18.0<1>:d    r83.0<1;1,0>:d    0:w               {I@2}
L9360:
        join (8|M0)                          L9480                                
L9376:
        cmp (8|M0)    (ne)f1.0   r82.0<1>:d    r18.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.28<2>:b    125:w                              
        mov (8|M0)               r29.0<1>:f    9.275385e-39:f                              
        mov (8|M0)               r108.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@1}
        mov (8|M0)               r72.0<1>:d    -r82.0<1;1,0>:d                 
        goto (8|M0)                          L9480                  L10632                
L9480:
        join (8|M0)                          L9720                                
L9496:
        add (8|M0)               acc0.0<1>:d   r35.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r35.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r91.0<1>:d    -r35.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r81.0<1>:ud   r27.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r68.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r88.0<1>:ud   r27.0<1;1,0>:ud   r35.0<1;1,0>:d  
        shr (8|M0)               r72.0<1>:ud   r27.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r93.0<1>:ud   r68.0<1;0>:ud     r6.4<0;0>:ud      r27.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r91.0<1>:d    r6.14<0;1,0>:w    r91.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r91.0<1>:d    0:w                              
        and (8|M0)               r73.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r32.0<1>:d    r72.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r38.0<1>:d    r93.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r70.0<1>:d    r88.0<1;1,0>:d    r91.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L9720                  L9808                
L9720:
        join (8|M0)                          L9808                                
L9736:
        and (8|M0)               r32.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r70.0<1>:ud   r27.0<1;1,0>:ud   1:w              
(f1.0)  goto (8|M0)                          L9808                  L10024                
L9776:
        mov (8|M0)               r73.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:d    0:w                              
L9808:
        join (8|M0)                          L10024                                
L9824:
        cmp (8|M0)    (ne)f1.1   r57.0<1>:d    r38.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r70.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r29.0<1>:d    r70.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r72.0<1>:d    -r57.0<1;1,0>:d                  {I@3}
(f1.0)  goto (8|M0)                          L9960                  L9960                
L9904:
(W)     mov (1|M0)               r6.28<2>:b    125:w                              
        mov (8|M0)               r108.0<1>:f   r73.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@1}
        goto (8|M0)                          L9960                  L10632                
L9960:
        join (8|M0)                          L10024                                
L9976:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r73.0<1;1,0>:d    1:w              
(~f0.1) sel (8|M0)               r72.0<1>:d    -r57.0<1;1,0>:d   1:w              
        goto (8|M0)                          L10024                  L10072                
L10024:
        join (8|M0)                          L10072                                
L10040:
        add (8|M0)               r29.0<1>:d    r70.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r72.0<1>:d    0:w                              
L10072:
        join (8|M0)                          L10136                                
L10088:
        shr (8|M0)               r80.0<1>:ud   r29.0<1;1,0>:ud   1:w               {I@3}
        and (8|M0)               r56.0<1>:d    r80.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L10136                  L10544                
L10136:
        join (8|M0)                          L10544                                
L10152:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r27.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r29.0<1>:d    r27.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L10432                  L10432                
L10200:
(f1.0)  goto (8|M0)                          L10312                  L10312                
L10216:
(W)     mov (1|M0)               r6.28<2>:b    125:w                              
        mov (8|M0)               r32.0<1>:d    0:w                              
        mov (8|M0)               r108.0<1>:d   0:w                               {F@1}
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@4}
        goto (8|M0)                          L10312                  L10632                
L10312:
        join (8|M0)                          L10432                                
L10328:
(W)     mov (1|M0)               r6.28<2>:b    126:w                              
        and (8|M0)               r32.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r29.0<1>:ud   r29.0<1;1,0>:ud   1:w              
        mov (8|M0)               r108.0<1>:d   0:w                              
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@5}
        goto (8|M0)                          L10432                  L10632                
L10432:
        join (8|M0)                          L10544                                
L10448:
        shr (8|M0)               r40.0<1>:ud   r29.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r72.0<1>:d    0:w                              
        and (8|M0)               r61.0<1>:d    r40.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r40.0<1>:d    r40.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r32.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r56.0<1>:d    r40.0<1;1,0>:d    r61.0<1;1,0>:d   {I@2}
L10544:
        join (8|M0)                          L10632                                
L10560:
        and (8|M0)               acc0.0<1>:d   r29.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r6.28<2>:b    126:w                              
        mov (8|M0)               r108.0<1>:f   r32.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r29.0<1>:f    r56.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r32.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@2}
L10632:
        join (8|M0)                          L11048                                
L10648:
        shl (8|M0)               r73.0<1>:d    r32.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r79.0<1>:d    r108.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r54.0<1>:ud   r73.0<1;0>:ud     r79.0<1;0>:ud     r72.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L10744                  L10744                
L10712:
        mov (8|M0)               r71.0<1>:d    0:w                              
        goto (8|M0)                          L10744                  L10904                
L10744:
        join (8|M0)                          L10904                                
L10760:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r54.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L10824                  L10824                
L10792:
        mov (8|M0)               r71.0<1>:d    1:w                              
        goto (8|M0)                          L10824                  L10904                
L10824:
        join (8|M0)                          L10904                                
L10840:
        and (8|M0)    (ne)f0.1   null<1>:d     r29.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r71.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L10904:
        join (8|M0)                          L11048                                
L10920:
        add (8|M0)               r88.0<1>:d    r29.0<1;1,0>:d    r71.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r87.0<1>:d    r7.0<1;1,0>:ub                   {$4.src}
        cmp (8|M0)    (eq)f0.1   r60.0<1>:d    r88.0<1;1,0>:d    8388608:d               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r87.0<1;0>:d      -r60.0<1;0>:d     0:w               {I@2}
(f1.0)  mov (8|M0)               r88.0<1>:d    0:w                              
        shl (8|M0)               r87.0<1>:d    acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r20.0<1>:d    r87.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted,I@1}
        goto (8|M0)                          L11048                  L12920                
L11048:
        join (8|M0)                          L12920                                
L11064:
        mov (8|M0)               r7.0<1>:b     r90.0<4;1,0>:b                  
        cmp (8|M0)    (lt)f1.0   null<1>:w     r7.0<1;1,0>:b     126:w               {I@1}
(f1.0)  goto (8|M0)                          L11224                  L11224                
L11112:
        cmp (8|M0)    (eq)f0.1   null<1>:w     r7.0<1;1,0>:b     126:w              
(~f0.1) goto (8|M0)                          L11224                  L11272                
L11144:
        mov (8|M0)               r38.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r101.0<1>:d   0:w                              
        mov (8|M0)               r107.0<1>:f   0x728000:f                              
        goto (8|M0)                          L11224                  L11936                
L11224:
        join (8|M0)                          L11272                                
L11240:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     125:w              
(f1.1)  goto (8|M0)                          L11272                  L12152                
L11272:
        join (8|M0)                          L11936                                
L11288:
        add (8|M0)               r71.0<1>:d    r22.0<1;1,0>:d    -125:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r71.0<1;1,0>:ud   0x18:uw              {I@1}
(f1.0)  goto (8|M0)                          L11712                  L11712                
L11328:
        cmp (8|M0)    (lt)f0.1   null<1>:w     r7.0<1;1,0>:b     -106:w              
(f0.1)  goto (8|M0)                          L11472                  L11472                
L11360:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     -106:w              
(~f1.1) goto (8|M0)                          L11472                  L11520                
L11392:
        mov (8|M0)               r38.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    1:w                              
        mov (8|M0)               r101.0<1>:d   -1:w                              
        mov (8|M0)               r107.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L11472                  L11936                
L11472:
        join (8|M0)                          L11520                                
L11488:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r7.0<1;1,0>:b     -107:w              
(f1.0)  goto (8|M0)                          L11520                  L11616                
L11520:
        join (8|M0)                          L11616                                
L11536:
        mov (8|M0)               r38.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r101.0<1>:d   -1:w                              
        mov (8|M0)               r107.0<1>:d   0:w                              
        goto (8|M0)                          L11616                  L11936                
L11616:
        join (8|M0)                          L11712                                
L11632:
        mov (8|M0)               r38.0<1>:d    1:w                              
        mov (8|M0)               r82.0<1>:d    1:w                              
        mov (8|M0)               r101.0<1>:d   -1:w                              
        mov (8|M0)               r107.0<1>:d   0:w                              
        goto (8|M0)                          L11712                  L11936                
L11712:
        join (8|M0)                          L11936                                
L11728:
(W)     mov (1|M0)               r8.3<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r22.0<1;1,0>:d    -127:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r22.0<1;1,0>:d    -126:w               {Compacted}
        add (8|M0)               r32.0<1>:d    -r22.0<1;1,0>:d   148:w               {Compacted}
        shr (8|M0)               r78.0<1>:ud   r8.3<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r80.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r91.0<1>:ud   r8.3<0;1,0>:ud    r71.0<1;1,0>:d  
        shr (8|M0)               r106.0<1>:ud  r8.3<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r80.0<1>:d    r80.0<1;1,0>:d    6619136:d              
        shl (8|M0)               r32.0<1>:d    r6.14<0;1,0>:w    r32.0<1;1,0>:d   {F@1}
        and (8|M0)               r82.0<1>:d    r78.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r38.0<1>:d    r106.0<1;1,0>:d   1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f1.0   r101.0<1>:d   r80.0<1;1,0>:d    6619136:d               {I@4}
        or (8|M0)                r107.0<1>:d   r91.0<1;1,0>:d    r32.0<1;1,0>:d   {Compacted,I@4}
L11936:
        join (8|M0)                          L12152                                
L11952:
        add (8|M0)               r33.0<1>:d    r27.0<1;1,0>:d    r107.0<1;1,0>:d  {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r60.0<1>:d    r101.0<1;1,0>:d   0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r33.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        mov (8|M0)               r79.0<1>:d    -r60.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L12056                  L12056                
L12024:
        mov (8|M0)               r18.0<1>:d    r82.0<1;1,0>:d                  
        goto (8|M0)                          L12056                  L12448                
L12056:
        join (8|M0)                          L12152                                
L12072:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    1:w              
        shr (8|M0)               r77.0<1>:ud   r33.0<1;1,0>:ud   1:w               {$3.src}
        and (8|M0)               r50.0<1>:d    r77.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r79.0<1>:d    -r60.0<1;1,0>:d   1:w              
        goto (8|M0)                          L12152                  L12384                
L12152:
        join (8|M0)                          L12384                                
L12168:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r27.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r33.0<1>:d    r27.0<1;1,0>:d    6619136:d              
(f1.0)  goto (8|M0)                          L12296                  L12296                
L12216:
        and (8|M0)               r38.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r33.0<1>:ud   r33.0<1;1,0>:ud   1:w               {I@3}
        add (8|M0)               r22.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r18.0<1>:d    0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        goto (8|M0)                          L12296                  L12448                
L12296:
        join (8|M0)                          L12384                                
L12312:
        sync.nop                             null                             {Compacted,$3.src}
        shr (8|M0)               r76.0<1>:ud   r33.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r79.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:d    0:w                              
        or (8|M0)                r50.0<1>:d    r76.0<1;1,0>:d    4194304:d               {I@3}
L12384:
        join (8|M0)                          L12448                                
L12400:
        and (8|M0)               acc0.0<1>:d   r33.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r22.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r18.0<1>:f    r38.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r33.0<1>:f    r50.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r38.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L12448:
        join (8|M0)                          L12920                                
L12464:
        shl (8|M0)               r80.0<1>:d    r38.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r75.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r70.0<1>:ud   r80.0<1;0>:ud     r75.0<1;0>:ud     r79.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L12560                  L12560                
L12528:
        mov (8|M0)               r92.0<1>:d    0:w                              
        goto (8|M0)                          L12560                  L12720                
L12560:
        join (8|M0)                          L12720                                
L12576:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r70.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L12640                  L12640                
L12608:
        mov (8|M0)               r92.0<1>:d    1:w                              
        goto (8|M0)                          L12640                  L12720                
L12640:
        join (8|M0)                          L12720                                
L12656:
        and (8|M0)    (ne)f1.1   null<1>:d     r33.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r92.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L12720:
        join (8|M0)                          L12920                                
L12736:
        add (8|M0)               r91.0<1>:d    r33.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f1.1   r74.0<1>:d    r91.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r91.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r37.0<1>:d    r22.0<1;0>:d      -r74.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r37.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L12848                  L12848                
L12824:
        mov (8|M0)               r20.0<1>:f    inf:f                               {Compacted}
        goto (8|M0)                          L12848                  L12920                
L12848:
        join (8|M0)                          L12920                                
L12864:
(~f0.1) sel (8|M0)               r67.0<1>:d    r91.0<1;1,0>:d    0:w              
        and (8|M0)               r59.0<1>:d    r20.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (8|M0)               r73.0<1>:d    r37.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r20.0<1>:ud   r59.0<1;0>:ud     r73.0<1;0>:ud     r67.0<1>:ud      {I@1} // s0|s1|s2
L12920:
        join (8|M0)                          L30656                                
L12936:
        mov (8|M0)               r7.0<1>:hf    r20.0<1;1,0>:f                   {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
        mov (8|M0)               r120.0<1>:f   r7.0<1;1,0>:hf                   {F@2}
(f0.0)  sel (8|M0)               r7.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw              {A@1}
        shr (8|M0)               r77.0<1>:ud   r120.0<1;1,0>:ud  23:w               {$3.src}
        and (8|M0)    (ne)f1.0   r79.0<1>:d    r120.0<1;1,0>:d   8388607:d              
        and (8|M0)               r105.0<1>:d   r77.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r105.0<1;1,0>:d   255:w               {I@1}
(f1.0)  sel (8|M0)               r18.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        or (8|M0)     (ne)f0.1   null<1>:uw    r18.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@1}
(~f0.1) goto (8|M0)                          L13128                  L13128                
L13104:
        mov (8|M0)               r33.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L13128                  L19528                
L13128:
        join (8|M0)                          L19528                                
L13144:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r79.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
        xor (8|M0)               r18.0<1>:d    r120.0<1;1,0>:d   r17.0<1;1,0>:d   {Compacted}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r105.0<1;1,0>:d   255:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r15.0<1;1,0>:d    255:w              
(f1.0)  sel (8|M0)               r17.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(f0.1)  sel (8|M0)               r7.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw             
        or (8|M0)     (ne)f1.1   null<1>:uw    r17.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@1}
(f1.1)  goto (8|M0)                          L19496                  L19496                
L13296:
        or (8|M0)     (eq)f0.1   null<1>:d     r15.0<1;1,0>:d    r14.0<1;1,0>:d  
        or (8|M0)                r72.0<1>:d    r105.0<1;1,0>:d   r79.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r72.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L13376                  L13376                
L13352:
        mov (8|M0)               r33.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L13376                  L19528                
L13376:
        join (8|M0)                          L19496                                
L13392:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r105.0<1;1,0>:d   0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r15.0<1;1,0>:d    0:w              
        add (8|M0)               r122.0<1>:d   r105.0<1;1,0>:d   -127:w               {Compacted}
        add (8|M0)               r120.0<1>:d   r15.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r122.0<1>:d   -126:w                              
(f1.1)  mov (8|M0)               r120.0<1>:d   -126:w                              
        add (8|M0)               r103.0<1>:d   r122.0<1;1,0>:d   r120.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r103.0<1;1,0>:d   127:w               {I@1}
(f1.0)  goto (8|M0)                          L19424                  L19424                
L13512:
        or (8|M0)     (eq)f1.0   null<4>:b     r77.0<1;1,0>:d    r16.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L19352                  L19352                
L13544:
(W)     mov (1|M0)               r6.14<1>:hf   0.0:hf                             
(W)     mov (1|M0)               r7.7<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    8388608:d               {F@1}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r6.14<0;1,0>:w    8388608:d              
        or (8|M0)                r45.0<1>:d    acc0.0<1;1,0>:d   r79.0<1;1,0>:d  
        or (8|M0)                r39.0<1>:d    acc2.0<1;1,0>:d   r14.0<1;1,0>:d  
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r45.0<1;1,0>:ud   r39.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r117.0<1>:ud  r45.0<1;1,0>:ud   r39.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r29.0<1>:f    r117.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r25.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L13720:
(W)     shl (1|M0)               r8.4<1>:d     r7.6<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r8.3<1>:ud    r7.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.0   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r7.7<1>:d     r8.3<0;1,0>:d     r8.4<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r48.0<1>:ud   r25.0<1;0>:ud     r8.3<0;0>:ud      r8.4<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f1.0) cmp (8|M0)   (eq)f1.0   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    r7.7<0;1,0>:d    {I@3}
        and (8|M0)               r47.0<1>:d    r29.0<1;1,0>:d    r6.7<0;1,0>:d    {Compacted,A@1}
(W)     addc (1|M0)              r15.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.0) cmp (8|M0)  (gt)f1.0   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r47.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r8.6<1>:hf    0x1:hf                             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f1.0)  sel (8|M0)               r14.0<1>:uw   r8.6<0;1,0>:uw    0x0:uw              {F@1}
(W)     add (1|M0)               r8.5<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@2}
(f0.1)  sel (8|M0)               r7.0<1>:uw    r8.6<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r121.0<1>:d   r7.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.1   null<1>:uw    r14.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r127.0<1>:d   r7.5<0;1,0>:d                   
        mov (8|M0)               r40.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r94.0<1>:d    r8.5<0;1,0>:d                   
(f1.1)  goto (8|M0)                          L14128                  L14128                
L14064:
(W)     mov (1|M0)               r7.6<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:f     r8.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L13720                                
L14128:
        join (8|M0)                          L19352                                
L14144:
(W)     mov (1|M0)               r6.7<1>:f     8.68805e-44:f                               {I@4}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r57.0<1>:ud   r6.7<0;1,0>:ud    r121.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        sync.nop                             null                             {Compacted,$4.src}
        add3 (8|M0)              r87.0<1>:d    r103.0<1;0>:d     r57.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r104.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r127.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r87.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r74.0<1>:d    r122.0<1;0>:d     r120.0<1;0>:d     r57.0<1>:d      
(f1.0)  goto (8|M0)                          L19280                  L19280                
L14272:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r87.0<1;1,0>:d    -127:w              
(f0.1)  goto (8|M0)                          L16848                  L16848                
L14304:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r87.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L16328                  L16328                
L14336:
(W)     mov (1|M0)               r6.7<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r67.0<1>:d    r103.0<1;0>:d     r57.0<1;0>:d      104:w              
        subb (8|M0)              r104.0<1>:ud  r6.7<0;1,0>:ud    r121.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r104.0<1;1,0>:ud  r67.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r16.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r127.0<1>:ud    {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r16.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L14536                  L14536                
L14472:
        add3 (8|M0)              acc0.0<1>:d   r74.0<1;0>:d      -r104.0<1;0>:d    104:w              
        mov (8|M0)               r35.0<1>:d    0:w                              
        shl (8|M0)               r36.0<1>:d    r25.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L14536                  L16264                
L14536:
        join (8|M0)                          L16264                                
L14552:
        add3 (8|M0)              r102.0<1>:d   r104.0<1;0>:d     -r74.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r102.0<1;1,0>:d   2:w               {I@1}
(f1.0)  goto (8|M0)                          L14696                  L14696                
L14600:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r102.0<1;1,0>:d   2:w              
(~f0.1) goto (8|M0)                          L14696                  L14744                
L14632:
        shr (8|M0)               r12.0<1>:ud   r25.0<1;1,0>:ud   1:w              
        and (8|M0)               r84.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r63.0<1>:d    0:w                              
        mov (8|M0)               r45.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L14696                  L15696                
L14696:
        join (8|M0)                          L14744                                
L14712:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   1:w              
(f1.1)  goto (8|M0)                          L14744                  L15640                
L14744:
        join (8|M0)                          L15640                                
L14760:
        add3 (8|M0)              acc0.0<1>:d   r104.0<1;0>:d     -r67.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.0   r38.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L14840                  L14840                
L14808:
        mov (8|M0)               r80.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L14840                  L14976                
L14840:
        join (8|M0)                          L14976                                
L14856:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r38.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r38.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r38.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r68.0<1>:ud   r25.0<1;1,0>:ud   r38.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r90.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r12.0<1>:ud   r29.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r12.0<1>:d    r68.0<1;1,0>:d    r90.0<1;1,0>:d   {I@2}
        mov (8|M0)               r80.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
L14976:
        join (8|M0)                          L15640                                
L14992:
        add3 (8|M0)              r55.0<1>:d    r104.0<1;0>:d     -r67.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.1   r37.0<1>:d    r55.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L15072                  L15072                
L15040:
        mov (8|M0)               r12.0<1>:d    r25.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L15072                  L15200                
L15072:
        join (8|M0)                          L15200                                
L15088:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r37.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r37.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r37.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r66.0<1>:ud   r25.0<1;1,0>:ud   r37.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r89.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r12.0<1>:ud   r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r12.0<1>:d    r66.0<1;1,0>:d    r89.0<1;1,0>:d   {I@2}
L15200:
        join (8|M0)                          L15640                                
L15216:
        and (8|M0)    (ne)f0.1   r88.0<1>:d    r55.0<1;1,0>:d    63:w              
        and (8|M0)               r84.0<1>:d    r12.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L15304                  L15304                
L15256:
        mov (8|M0)               r105.0<1>:d   -1:w                              
        mov (8|M0)               r119.0<1>:d   -1:w                              
        goto (8|M0)                          L15304                  L15488                
L15304:
        join (8|M0)                          L15488                                
L15320:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r88.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L15424                  L15424                
L15352:
        add (8|M0)               acc0.0<1>:d   r88.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r105.0<1>:d   0:w                              
        shl (8|M0)               r119.0<1>:d   r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L15424                  L15488                
L15424:
        join (8|M0)                          L15488                                
L15440:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r119.0<1>:d   -1:w                              
        shl (8|M0)               r105.0<1>:d   r6.14<0;1,0>:w    r88.0<1;1,0>:d   {F@1}
L15488:
        join (8|M0)                          L15640                                
L15504:
        bfn.0x28 (8|M0)          r65.0<1>:ud   r25.0<1;0>:ud     r105.0<1;0>:ud    r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r64.0<1>:ud   r29.0<1;0>:ud     r119.0<1;0>:ud    r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r65.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r45.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r64.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@2}
        mov (8|M0)               r63.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L15640                  L15696                
L15640:
        join (8|M0)                          L15696                                
L15656:
        mov (8|M0)               r63.0<1>:d    0:w                              
        mov (8|M0)               r84.0<1>:d    0:w                              
        mov (8|M0)               r45.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
L15696:
        join (8|M0)                          L16264                                
L15712:
        and (8|M0)    (ne)f1.0   r36.0<1>:d    r102.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L15776                  L15776                
L15744:
        mov (8|M0)               r12.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L15776                  L15904                
L15776:
        join (8|M0)                          L15904                                
L15792:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r36.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r36.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r36.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r61.0<1>:ud   r25.0<1;1,0>:ud   r36.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r87.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r12.0<1>:ud   r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r12.0<1>:d    r61.0<1;1,0>:d    r87.0<1;1,0>:d   {I@2}
L15904:
        join (8|M0)                          L16264                                
L15920:
        shl (8|M0)               r36.0<1>:d    r45.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r60.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r36.0<1>:d    r36.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r36.0<1;0>:ud     r60.0<1;0>:ud     r63.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r7.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (8|M0)                          L16024                  L16024                
L15992:
        mov (8|M0)               r19.0<1>:d    0:w                              
        goto (8|M0)                          L16024                  L16184                
L16024:
        join (8|M0)                          L16184                                
L16040:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r7.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (8|M0)                          L16104                  L16104                
L16072:
        mov (8|M0)               r19.0<1>:d    1:w                              
        goto (8|M0)                          L16104                  L16184                
L16104:
        join (8|M0)                          L16184                                
L16120:
        and (8|M0)    (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r7.0<1;1,0>:d     4:w              
(f1.0)  sel (8|M0)               r19.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L16184:
        join (8|M0)                          L16264                                
L16200:
        add (8|M0)               r103.0<1>:d   r19.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.7<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r103.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r36.0<1>:d    r103.0<1;1,0>:d   0:w              
(f1.1)  sel (8|M0)               r35.0<1>:d    r6.7<0;1,0>:d     0:w               {F@1}
L16264:
        join (8|M0)                          L16328                                
L16280:
        and (8|M0)               r59.0<1>:d    r18.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r33.0<1>:ud   r59.0<1;0>:ud     r35.0<1;0>:ud     r36.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L16328                  L19528                
L16328:
        join (8|M0)                          L16848                                
L16344:
        and (8|M0)    (ne)f0.1   r53.0<1>:d    r57.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L16424                  L16424                
L16376:
        mov (8|M0)               r69.0<1>:d    -1:w                              
        mov (8|M0)               r86.0<1>:d    -1:w                              
        goto (8|M0)                          L16424                  L16608                
L16424:
        join (8|M0)                          L16608                                
L16440:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r53.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L16544                  L16544                
L16472:
        add (8|M0)               acc0.0<1>:d   r53.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r69.0<1>:d    0:w                              
        shl (8|M0)               r86.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L16544                  L16608                
L16544:
        join (8|M0)                          L16608                                
L16560:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r86.0<1>:d    -1:w                              
        shl (8|M0)               r69.0<1>:d    r6.14<0;1,0>:w    r53.0<1;1,0>:d   {F@1}
L16608:
        join (8|M0)                          L16848                                
L16624:
        bfn.0x28 (8|M0)          r58.0<1>:ud   r25.0<1;0>:ud     r69.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r57.0<1>:ud   r29.0<1;0>:ud     r86.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r58.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -1:w              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r57.0<1;1,0>:d    0:w               {I@3}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r87.0<1;1,0>:d    -150:w              
(f1.0)  goto (8|M0)                          L16784                  L16784                
L16736:
(W)     mov (1|M0)               r6.7<1>:ud    0x80000001:ud                             
(f1.1)  sel (8|M0)               r33.0<1>:f    r6.7<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L16784                  L19528                
L16784:
        join (8|M0)                          L16848                                
L16800:
(W)     mov (1|M0)               r6.7<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (8|M0)               r33.0<1>:f    r6.7<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L16848                  L19528                
L16848:
        join (8|M0)                          L19280                                
L16864:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r57.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r100.0<1>:d   r103.0<1;0>:d     r57.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L18960                  L18960                
L16928:
        shl (8|M0)               r79.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r78.0<1>:ud   r40.0<1;1,0>:ud   31:w              
        shl (8|M0)               r60.0<1>:d    r94.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r79.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r60.0<1>:d    r60.0<1;1,0>:d    r78.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r60.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r60.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L17160                  L17160                
L17032:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r40.0<1;1,0>:d    39:w               {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L17160                  L17224                
L17080:
        shr (8|M0)               r12.0<1>:ud   r25.0<1;1,0>:ud   1:w              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r94.0<1>:d    0:w                              
        mov (8|M0)               r77.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L17160                  L18416                
L17160:
        join (8|M0)                          L17224                                
L17176:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r40.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r94.0<1;1,0>:d    0:w               {I@4}
(f1.0)  goto (8|M0)                          L17224                  L18336                
L17224:
        join (8|M0)                          L18336                                
L17240:
        add (8|M0)               acc0.0<1>:d   -r40.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r110.0<1>:d   -r40.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r52.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L17320                  L17320                
L17288:
        mov (8|M0)               r89.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L17320                  L17456                
L17320:
        join (8|M0)                          L17456                                
L17336:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r52.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r52.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r52.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r54.0<1>:ud   r25.0<1;1,0>:ud   r52.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r118.0<1>:d   r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r12.0<1>:ud   r29.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r12.0<1>:d    r54.0<1;1,0>:d    r118.0<1;1,0>:d  {I@2}
        mov (8|M0)               r89.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
L17456:
        join (8|M0)                          L18336                                
L17472:
        add (8|M0)               r66.0<1>:d    -r40.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r59.0<1>:d    r66.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L17544                  L17544                
L17512:
        mov (8|M0)               r12.0<1>:d    r25.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L17544                  L17672                
L17544:
        join (8|M0)                          L17672                                
L17560:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r59.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r59.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r59.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r52.0<1>:ud   r25.0<1;1,0>:ud   r59.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r16.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r12.0<1>:ud   r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r12.0<1>:d    r52.0<1;1,0>:d    r16.0<1;1,0>:d   {I@2}
L17672:
        join (8|M0)                          L18336                                
L17688:
        and (8|M0)    (ne)f1.1   r15.0<1>:d    r66.0<1;1,0>:d    63:w              
        and (8|M0)               r94.0<1>:d    r12.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L17776                  L17776                
L17728:
        mov (8|M0)               r31.0<1>:d    -1:w                              
        mov (8|M0)               r39.0<1>:d    -1:w                              
        goto (8|M0)                          L17776                  L17960                
L17776:
        join (8|M0)                          L17960                                
L17792:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r15.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L17896                  L17896                
L17824:
        add (8|M0)               acc0.0<1>:d   r15.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r31.0<1>:d    0:w                              
        shl (8|M0)               r39.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L17896                  L17960                
L17896:
        join (8|M0)                          L17960                                
L17912:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r39.0<1>:d    -1:w                              
        shl (8|M0)               r31.0<1>:d    r6.14<0;1,0>:w    r15.0<1;1,0>:d   {F@1}
L17960:
        join (8|M0)                          L18336                                
L17976:
        bfn.0x28 (8|M0)          r51.0<1>:ud   r25.0<1;0>:ud     r31.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r50.0<1>:ud   r29.0<1;0>:ud     r39.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r51.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r50.0<1;1,0>:d    0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
        and (8|M0)    (ne)f0.1   r58.0<1>:d    r110.0<1;1,0>:d   63:w              
        mov (8|M0)               r78.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L18152                  L18152                
L18120:
        mov (8|M0)               r12.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L18152                  L18280                
L18152:
        join (8|M0)                          L18280                                
L18168:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r58.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r58.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r58.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r47.0<1>:ud   r25.0<1;1,0>:ud   r58.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r14.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r12.0<1>:ud   r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r12.0<1>:d    r47.0<1;1,0>:d    r14.0<1;1,0>:d   {I@2}
L18280:
        join (8|M0)                          L18336                                
L18296:
        mov (8|M0)               r77.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r12.0<1>:d    r89.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L18336                  L18416                
L18336:
        join (8|M0)                          L18416                                
L18352:
        shr (8|M0)               r12.0<1>:ud   r25.0<1;1,0>:ud   2:w              
        and (8|M0)               r94.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r77.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r12.0<1>:ud   r25.0<1;1,0>:ud   1:w               {F@1}
L18416:
        join (8|M0)                          L18960                                
L18432:
        shl (8|M0)               r104.0<1>:d   r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r46.0<1>:d    r94.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r104.0<1>:d   r104.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r92.0<1>:d    r77.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r52.0<1>:ud   r104.0<1;0>:ud    r46.0<1;0>:ud     r78.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L18552                  L18552                
L18520:
        mov (8|M0)               r51.0<1>:d    0:w                              
        goto (8|M0)                          L18552                  L18712                
L18552:
        join (8|M0)                          L18712                                
L18568:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r52.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L18632                  L18632                
L18600:
        mov (8|M0)               r51.0<1>:d    1:w                              
        goto (8|M0)                          L18632                  L18712                
L18632:
        join (8|M0)                          L18712                                
L18648:
        and (8|M0)    (ne)f1.1   null<1>:d     r77.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r51.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L18712:
        join (8|M0)                          L18960                                
L18728:
        add (8|M0)               r15.0<1>:d    r92.0<1;1,0>:d    r51.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r126.0<1>:d   r103.0<1;0>:d     r57.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r15.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r115.0<1>:d   r126.0<1;1,0>:d   r100.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r115.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (8|M0)                          L18888                  L18888                
L18816:
(~f0.1) sel (8|M0)               r28.0<1>:d    r15.0<1;1,0>:d    0:w              
        and (8|M0)               r125.0<1>:d   r18.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r45.0<1>:d    r115.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r33.0<1>:ud   r125.0<1;0>:ud    r45.0<1;0>:ud     r28.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L18888                  L19528                
L18888:
        join (8|M0)                          L18960                                
L18904:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r33.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L18960                  L19528                
L18960:
        join (8|M0)                          L19280                                
L18976:
        and (8|M0)    (ne)f1.0   r122.0<1>:d   r57.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L19040                  L19040                
L19008:
        mov (8|M0)               r35.0<1>:d    -1:w                              
        goto (8|M0)                          L19040                  L19168                
L19040:
        join (8|M0)                          L19168                                
L19056:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r122.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L19120                  L19120                
L19088:
        mov (8|M0)               r35.0<1>:d    0:w                              
        goto (8|M0)                          L19120                  L19168                
L19120:
        join (8|M0)                          L19168                                
L19136:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        shl (8|M0)               r35.0<1>:d    r6.14<0;1,0>:w    r122.0<1;1,0>:d  {F@1}
L19168:
        join (8|M0)                          L19280                                
L19184:
        bfn.0x28 (8|M0)          r50.0<1>:ud   r25.0<1;0>:ud     r35.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r57.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r124.0<1>:d   r18.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r43.0<1>:d    r100.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r50.0<1>:d    r50.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r33.0<1>:ud   r124.0<1;0>:ud    r43.0<1;0>:ud     r50.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L19280                  L19528                
L19280:
        join (8|M0)                          L19352                                
L19296:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r33.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L19352                  L19528                
L19352:
        join (8|M0)                          L19424                                
L19368:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r18.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (8|M0)               r33.0<1>:f    r6.7<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L19424                  L19528                
L19424:
        join (8|M0)                          L19496                                
L19440:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r33.0<1>:f    r6.7<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L19496                  L19528                
L19496:
        join (8|M0)                          L19528                                
L19512:
        bfn.0xF8 (8|M0)          r33.0<1>:ud   r18.0<1;0>:ud     r6.6<0;0>:ud      r6.5<0>:ud       {F@1} // s0&s1|s2
L19528:
        join (8|M0)                          L30656                                
L19544:
        sync.nop                             null                             {Compacted,$4.src}
        shr (8|M0)               r86.0<1>:ud   r33.0<1;1,0>:ud   23:w               {I@2}
        and (8|M0)    (ne)f1.0   r25.0<1>:d    r33.0<1;1,0>:d    8388607:d              
        and (8|M0)               r21.0<1>:d    r86.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r21.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L19648                  L19648                
L19624:
        mov (8|M0)               r33.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L19648                  L23984                
L19648:
        join (8|M0)                          L23984                                
L19664:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r25.0<1;1,0>:d    0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r21.0<1;1,0>:d    255:w              
(f0.1)  goto (8|M0)                          L23984                  L23984                
L19712:
        or (8|M0)     (eq)f1.1   null<1>:d     r21.0<1;1,0>:d    r25.0<1;1,0>:d  
(~f1.1) goto (8|M0)                          L19776                  L19776                
L19744:
        mov (8|M0)               r33.0<1>:f    0x3F650000:f                              
        goto (8|M0)                          L19776                  L23984                
L19776:
        join (8|M0)                          L23984                                
L19792:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r33.0<1;1,0>:d    -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r21.0<1;1,0>:ud   0x7E:uw             
(f1.0)  goto (8|M0)                          L20064                  L20064                
L19840:
(f1.1)  goto (8|M0)                          L19952                  L19952                
L19856:
        mov (8|M0)               r82.0<1>:f    0x3F650000:f                              
        mov (8|M0)               r119.0<1>:f   r33.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r8.4          L44176                                 {A@1}
L19928:
        mov (8|M0)               r33.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@5}
        goto (8|M0)                          L19952                  L23984                
L19952:
        join (8|M0)                          L20064                                
L19968:
        mov (8|M0)               r82.0<1>:f    r33.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r119.0<1>:f   0x3F650000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r8.4          L44176                                 {A@1}
L20040:
        mov (8|M0)               r33.0<1>:f    r110.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L20064                  L23984                
L20064:
        join (8|M0)                          L23984                                
L20080:
(f1.1)  goto (8|M0)                          L22184                  L22184                
L20096:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r21.0<1;1,0>:d    0:w              
        add (8|M0)               r123.0<1>:d   -r21.0<1;1,0>:d   126:w               {Compacted}
(f1.0)  sel (8|M0)               r34.0<1>:d    r123.0<1;1,0>:d   125:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r34.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L21272                  L21272                
L20168:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  goto (8|M0)                          L20864                  L20864                
L20192:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r34.0<1;1,0>:ud   0x18:uw             
(f1.1)  goto (8|M0)                          L20624                  L20624                
L20224:
        cmp (8|M0)    (ne)f0.0   r114.0<1>:d   r21.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r34.0<1;1,0>:d    25:w              
        mov (8|M0)               r31.0<1>:d    -r114.0<1;1,0>:d                 {I@2}
(f1.0)  goto (8|M0)                          L20432                  L20432                
L20288:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r34.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f1.1   r122.0<1>:d   r25.0<1;1,0>:d    0:w              
        cmp (8|M0)    (ne)f1.0   r42.0<1>:d    r33.0<1;1,0>:d    0:w               {F@1}
(f0.1)  sel (8|M0)               r31.0<1>:d    -r114.0<1;1,0>:d  0:w              
(f0.1)  sel (8|M0)               acc0.0<1>:d   -r122.0<1;1,0>:d  -r42.0<1;1,0>:d  {I@2}
        mov (8|M0)               r29.0<1>:f    r31.0<1;1,0>:f                   {Compacted,I@2}
        shl (8|M0)               r124.0<1>:d   acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r31.0<1>:d    0:w                               {F@1}
        asr (8|M0)               r105.0<1>:d   r124.0<1;1,0>:d   31:w               {Compacted,I@2}
        goto (8|M0)                          L20432                  L20504                
L20432:
        join (8|M0)                          L20504                                
L20448:
        shr (8|M0)               r41.0<1>:ud   r33.0<1;1,0>:ud   22:w              
        and (8|M0)               r40.0<1>:d    r33.0<1;1,0>:d    4194303:d              
        and (8|M0)               r29.0<1>:d    r41.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r105.0<1>:d   r40.0<1;1,0>:d    0:w               {I@2}
L20504:
        join (8|M0)                          L20624                                
L20520:
        cmp (8|M0)    (ne)f1.0   r39.0<1>:d    r105.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.28<2>:b    126:w                              
        mov (8|M0)               r28.0<1>:f    9.275385e-39:f                              
        mov (8|M0)               r99.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@1}
        mov (8|M0)               r70.0<1>:d    -r39.0<1;1,0>:d                 
        goto (8|M0)                          L20624                  L21768                
L20624:
        join (8|M0)                          L20864                                
L20640:
        add (8|M0)               acc0.0<1>:d   r34.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r34.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r86.0<1>:d    -r34.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r38.0<1>:ud   r25.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r35.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r57.0<1>:ud   r25.0<1;1,0>:ud   r34.0<1;1,0>:d  
        shr (8|M0)               r17.0<1>:ud   r25.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r72.0<1>:ud   r35.0<1;0>:ud     r6.4<0;0>:ud      r25.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r86.0<1>:d    r6.14<0;1,0>:w    r86.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r86.0<1>:d    0:w                              
        and (8|M0)               r55.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r31.0<1>:d    r17.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r113.0<1>:d   r72.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r51.0<1>:d    r57.0<1;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L20864                  L20952                
L20864:
        join (8|M0)                          L20952                                
L20880:
        and (8|M0)               r31.0<1>:d    r33.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r51.0<1>:ud   r25.0<1;1,0>:ud   1:w              
(f1.0)  goto (8|M0)                          L20952                  L21160                
L20920:
        mov (8|M0)               r55.0<1>:d    0:w                              
        mov (8|M0)               r113.0<1>:d   0:w                              
L20952:
        join (8|M0)                          L21160                                
L20968:
        cmp (8|M0)    (ne)f0.0   r27.0<1>:d    r113.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r51.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r28.0<1>:d    r51.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r70.0<1>:d    -r27.0<1;1,0>:d                  {I@3}
(f0.1)  goto (8|M0)                          L21104                  L21104                
L21048:
(W)     mov (1|M0)               r6.28<2>:b    126:w                              
        mov (8|M0)               r99.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@1}
        goto (8|M0)                          L21104                  L21768                
L21104:
        join (8|M0)                          L21160                                
L21120:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r55.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) sel (8|M0)               r70.0<1>:d    -r27.0<1;1,0>:d   1:w              
        goto (8|M0)                          L21160                  L21208                
L21160:
        join (8|M0)                          L21208                                
L21176:
        add (8|M0)               r28.0<1>:d    r51.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r70.0<1>:d    0:w                              
L21208:
        join (8|M0)                          L21272                                
L21224:
        shr (8|M0)               r37.0<1>:ud   r28.0<1;1,0>:ud   1:w               {I@3}
        and (8|M0)               r26.0<1>:d    r37.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L21272                  L21680                
L21272:
        join (8|M0)                          L21680                                
L21288:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r25.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r28.0<1>:d    r25.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L21568                  L21568                
L21336:
(f1.0)  goto (8|M0)                          L21448                  L21448                
L21352:
(W)     mov (1|M0)               r6.28<2>:b    126:w                              
        mov (8|M0)               r31.0<1>:d    0:w                              
        mov (8|M0)               r99.0<1>:d    0:w                               {F@1}
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@4}
        goto (8|M0)                          L21448                  L21768                
L21448:
        join (8|M0)                          L21568                                
L21464:
(W)     mov (1|M0)               r6.28<2>:b    127:w                              
        and (8|M0)               r31.0<1>:d    r33.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r28.0<1>:ud   r28.0<1;1,0>:ud   1:w              
        mov (8|M0)               r99.0<1>:d    0:w                              
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@5}
        goto (8|M0)                          L21568                  L21768                
L21568:
        join (8|M0)                          L21680                                
L21584:
        shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r70.0<1>:d    0:w                              
        and (8|M0)               r121.0<1>:d   r19.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r19.0<1>:d    r19.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r31.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r26.0<1>:d    r19.0<1;1,0>:d    r121.0<1;1,0>:d  {I@2}
L21680:
        join (8|M0)                          L21768                                
L21696:
        and (8|M0)               acc0.0<1>:d   r28.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r6.28<2>:b    127:w                              
        mov (8|M0)               r99.0<1>:f    r31.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r28.0<1>:f    r26.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r31.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@2}
L21768:
        join (8|M0)                          L22184                                
L21784:
        shl (8|M0)               r38.0<1>:d    r31.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r36.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r127.0<1>:ud  r38.0<1;0>:ud     r36.0<1;0>:ud     r70.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r127.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L21880                  L21880                
L21848:
        mov (8|M0)               r16.0<1>:d    0:w                              
        goto (8|M0)                          L21880                  L22040                
L21880:
        join (8|M0)                          L22040                                
L21896:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r127.0<1;1,0>:ud  0x4:uw             
(~f0.0) goto (8|M0)                          L21960                  L21960                
L21928:
        mov (8|M0)               r16.0<1>:d    1:w                              
        goto (8|M0)                          L21960                  L22040                
L21960:
        join (8|M0)                          L22040                                
L21976:
        and (8|M0)    (ne)f0.0   null<1>:d     r28.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r127.0<1;1,0>:d   4:w              
(f0.0)  sel (8|M0)               r16.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L22040:
        join (8|M0)                          L22184                                
L22056:
        add (8|M0)               r84.0<1>:d    r28.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r83.0<1>:d    r7.0<1;1,0>:ub                  
        cmp (8|M0)    (eq)f0.1   r120.0<1>:d   r84.0<1;1,0>:d    8388608:d               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r83.0<1;0>:d      -r120.0<1;0>:d    0:w               {I@2}
(f1.0)  mov (8|M0)               r84.0<1>:d    0:w                              
        shl (8|M0)               r83.0<1>:d    acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r33.0<1>:d    r83.0<1;1,0>:d    r84.0<1;1,0>:d   {Compacted,I@1}
        goto (8|M0)                          L22184                  L23984                
L22184:
        join (8|M0)                          L23984                                
L22200:
        mov (8|M0)               r7.0<1>:b     r86.0<4;1,0>:b                  
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     127:w               {I@1}
(~f1.1) goto (8|M0)                          L22328                  L22328                
L22248:
        mov (8|M0)               r36.0<1>:d    0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        mov (8|M0)               r98.0<1>:f    0x728000:f                              
        goto (8|M0)                          L22328                  L23024                
L22328:
        join (8|M0)                          L23024                                
L22344:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r7.0<1;1,0>:b     126:w              
(f1.0)  goto (8|M0)                          L23024                  L23232                
L22376:
        add (8|M0)               r54.0<1>:d    r21.0<1;1,0>:d    -126:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r54.0<1;1,0>:ud   0x18:uw              {I@1}
(f0.1)  goto (8|M0)                          L22800                  L22800                
L22416:
        cmp (8|M0)    (lt)f0.0   null<1>:w     r7.0<1;1,0>:b     -105:w              
(f0.0)  goto (8|M0)                          L22560                  L22560                
L22448:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     -105:w              
(~f1.1) goto (8|M0)                          L22560                  L22608                
L22480:
        mov (8|M0)               r36.0<1>:d    0:w                              
        mov (8|M0)               r79.0<1>:d    1:w                              
        mov (8|M0)               r90.0<1>:d    -1:w                              
        mov (8|M0)               r98.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L22560                  L23024                
L22560:
        join (8|M0)                          L22608                                
L22576:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r7.0<1;1,0>:b     -106:w              
(f1.0)  goto (8|M0)                          L22608                  L22704                
L22608:
        join (8|M0)                          L22704                                
L22624:
        mov (8|M0)               r36.0<1>:d    0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    -1:w                              
        mov (8|M0)               r98.0<1>:d    0:w                              
        goto (8|M0)                          L22704                  L23024                
L22704:
        join (8|M0)                          L22800                                
L22720:
        mov (8|M0)               r36.0<1>:d    1:w                              
        mov (8|M0)               r79.0<1>:d    1:w                              
        mov (8|M0)               r90.0<1>:d    -1:w                              
        mov (8|M0)               r98.0<1>:d    0:w                              
        goto (8|M0)                          L22800                  L23024                
L22800:
        join (8|M0)                          L23024                                
L22816:
(W)     mov (1|M0)               r8.3<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r21.0<1;1,0>:d    -128:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r21.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r85.0<1>:d    -r21.0<1;1,0>:d   149:w               {Compacted}
        shr (8|M0)               r35.0<1>:ud   r8.3<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r78.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r66.0<1>:ud   r8.3<0;1,0>:ud    r54.0<1;1,0>:d  
        shr (8|M0)               r34.0<1>:ud   r8.3<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r78.0<1>:d    r78.0<1;1,0>:d    6619136:d              
        shl (8|M0)               r85.0<1>:d    r6.14<0;1,0>:w    r85.0<1;1,0>:d   {F@1}
        and (8|M0)               r79.0<1>:d    r35.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r36.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f1.1   r90.0<1>:d    r78.0<1;1,0>:d    6619136:d               {I@4}
        or (8|M0)                r98.0<1>:d    r66.0<1;1,0>:d    r85.0<1;1,0>:d   {Compacted,I@4}
L23024:
        join (8|M0)                          L23232                                
L23040:
        add (8|M0)               r30.0<1>:d    r25.0<1;1,0>:d    r98.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.0   r34.0<1>:d    r90.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r30.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        mov (8|M0)               r74.0<1>:d    -r34.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L23144                  L23144                
L23112:
        mov (8|M0)               r68.0<1>:d    r79.0<1;1,0>:d                  
        goto (8|M0)                          L23144                  L23520                
L23144:
        join (8|M0)                          L23232                                
L23160:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r79.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) sel (8|M0)               r74.0<1>:d    -r34.0<1;1,0>:d   1:w              
        shr (8|M0)               r34.0<1>:ud   r30.0<1;1,0>:ud   1:w              
        and (8|M0)               r14.0<1>:d    r34.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L23232                  L23456                
L23232:
        join (8|M0)                          L23456                                
L23248:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r25.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r30.0<1>:d    r25.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L23376                  L23376                
L23296:
        and (8|M0)               r36.0<1>:d    r33.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r30.0<1>:ud   r30.0<1;1,0>:ud   1:w               {I@3}
        add (8|M0)               r21.0<1>:d    r21.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r68.0<1>:d    0:w                              
        mov (8|M0)               r74.0<1>:d    0:w                              
        goto (8|M0)                          L23376                  L23520                
L23376:
        join (8|M0)                          L23456                                
L23392:
        shr (8|M0)               r32.0<1>:ud   r30.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r36.0<1>:d    0:w                              
        or (8|M0)                r14.0<1>:d    r32.0<1;1,0>:d    4194304:d               {I@3}
L23456:
        join (8|M0)                          L23520                                
L23472:
        and (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r21.0<1>:d    r21.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r68.0<1>:f    r36.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r30.0<1>:f    r14.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r36.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L23520:
        join (8|M0)                          L23984                                
L23536:
        shl (8|M0)               r48.0<1>:d    r36.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r31.0<1>:d    r68.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r48.0<1;0>:ud     r31.0<1;0>:ud     r74.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r15.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L23632                  L23632                
L23600:
        mov (8|M0)               r28.0<1>:d    0:w                              
        goto (8|M0)                          L23632                  L23792                
L23632:
        join (8|M0)                          L23792                                
L23648:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r15.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L23712                  L23712                
L23680:
        mov (8|M0)               r28.0<1>:d    1:w                              
        goto (8|M0)                          L23712                  L23792                
L23712:
        join (8|M0)                          L23792                                
L23728:
        and (8|M0)    (ne)f1.1   null<1>:d     r30.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r15.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r28.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L23792:
        join (8|M0)                          L23984                                
L23808:
        add (8|M0)               r27.0<1>:d    r30.0<1;1,0>:d    r28.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.0   r30.0<1>:d    r27.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r27.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r112.0<1>:d   r21.0<1;0>:d      -r30.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r112.0<1;1,0>:d   255:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L23912                  L23912                
L23888:
        mov (8|M0)               r33.0<1>:f    inf:f                               {Compacted}
        goto (8|M0)                          L23912                  L23984                
L23912:
        join (8|M0)                          L23984                                
L23928:
(~f0.1) sel (8|M0)               r27.0<1>:d    r27.0<1;1,0>:d    0:w              
        and (8|M0)               r119.0<1>:d   r33.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (8|M0)               r29.0<1>:d    r112.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r33.0<1>:ud   r119.0<1;0>:ud    r29.0<1;0>:ud     r27.0<1>:ud      {I@1} // s0|s1|s2
L23984:
        join (8|M0)                          L30656                                
L24000:
        shr (8|M0)               r73.0<1>:ud   r13.0<1;1,0>:ud   23:w              
        and (8|M0)    (ne)f1.0   r69.0<1>:d    r13.0<1;1,0>:d    8388607:d              
        and (8|M0)               r100.0<1>:d   r73.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (8|M0)                          L24096                  L24096                
L24072:
        mov (8|M0)               r24.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L24096                  L30608                
L24096:
        join (8|M0)                          L30608                                
L24112:
        mov (8|M0)               r7.0<1>:hf    r33.0<1;1,0>:f                  
        mov (8|M0)               r49.0<1>:f    r7.0<1;1,0>:hf                   {F@1}
        shr (8|M0)               r65.0<1>:ud   r49.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.1   r59.0<1>:d    r49.0<1;1,0>:d    8388607:d              
        and (8|M0)               r97.0<1>:d    r65.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r97.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L24240                  L24240                
L24216:
        mov (8|M0)               r24.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L24240                  L30608                
L24240:
        join (8|M0)                          L30608                                
L24256:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r69.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r59.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
        xor (8|M0)               r20.0<1>:d    r13.0<1;1,0>:d    r49.0<1;1,0>:d   {Compacted}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   255:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    255:w              
(f1.1)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r7.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw             
        or (8|M0)     (ne)f1.1   null<1>:uw    r13.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@1}
(f1.1)  goto (8|M0)                          L30576                  L30576                
L24408:
        or (8|M0)     (eq)f0.0   null<1>:d     r97.0<1;1,0>:d    r59.0<1;1,0>:d  
        or (8|M0)                r28.0<1>:d    r100.0<1;1,0>:d   r69.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r28.0<1;1,0>:d    0:w               {I@1}
(~f0.0) goto (8|M0)                          L24488                  L24488                
L24464:
        mov (8|M0)               r24.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L24488                  L30608                
L24488:
        join (8|M0)                          L30576                                
L24504:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r100.0<1;1,0>:d   0:w               {Compacted}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r97.0<1;1,0>:d    0:w              
        add (8|M0)               r119.0<1>:d   r100.0<1;1,0>:d   -127:w               {Compacted}
        add (8|M0)               r117.0<1>:d   r97.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (8|M0)               r119.0<1>:d   -126:w                              
(f1.1)  mov (8|M0)               r117.0<1>:d   -126:w                              
        add (8|M0)               r101.0<1>:d   r119.0<1;1,0>:d   r117.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r101.0<1;1,0>:d   127:w               {I@1}
(f1.0)  goto (8|M0)                          L30504                  L30504                
L24616:
        or (8|M0)     (eq)f0.1   null<4>:b     r73.0<1;1,0>:d    r65.0<1;1,0>:d  
(f0.1)  goto (8|M0)                          L30432                  L30432                
L24648:
(W)     mov (1|M0)               r6.14<1>:hf   0.0:hf                             
(W)     mov (1|M0)               r7.7<1>:d     0:w                              
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    8388608:d               {F@1}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r6.14<0;1,0>:w    8388608:d              
        or (8|M0)                r33.0<1>:d    acc0.0<1;1,0>:d   r69.0<1;1,0>:d  
        or (8|M0)                r27.0<1>:d    acc2.0<1;1,0>:d   r59.0<1;1,0>:d  
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r33.0<1;1,0>:ud   r27.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r115.0<1>:ud  r33.0<1;1,0>:ud   r27.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r32.0<1>:f    r115.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L24824:
(W)     shl (1|M0)               r8.4<1>:d     r7.6<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r8.3<1>:ud    r7.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r7.7<1>:d     r8.3<0;1,0>:d     r8.4<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r44.0<1>:ud   r24.0<1;0>:ud     r8.3<0;0>:ud      r8.4<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r44.0<1;1,0>:d    r7.7<0;1,0>:d    {I@3}
        and (8|M0)               r43.0<1>:d    r32.0<1;1,0>:d    r6.7<0;1,0>:d    {Compacted,A@1}
(W)     addc (1|M0)              r14.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r43.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r8.6<1>:hf    0x1:hf                             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  sel (8|M0)               r13.0<1>:uw   r8.6<0;1,0>:uw    0x0:uw              {F@1}
(W)     add (1|M0)               r8.5<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@2}
(f0.0)  sel (8|M0)               r7.0<1>:uw    r8.6<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r118.0<1>:d   r7.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.0   null<1>:uw    r13.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r125.0<1>:d   r7.5<0;1,0>:d                   
        mov (8|M0)               r37.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r92.0<1>:d    r8.5<0;1,0>:d                   
(f1.0)  goto (8|M0)                          L25232                  L25232                
L25168:
(W)     mov (1|M0)               r7.6<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:f     r8.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L24824                                
L25232:
        join (8|M0)                          L30432                                
L25248:
(W)     mov (1|M0)               r6.7<1>:f     8.68805e-44:f                               {I@4}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r49.0<1>:ud   r6.7<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r83.0<1>:d    r101.0<1;0>:d     r49.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r100.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r125.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r83.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r70.0<1>:d    r119.0<1;0>:d     r117.0<1;0>:d     r49.0<1>:d      
(f0.0)  goto (8|M0)                          L30360                  L30360                
L25368:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r83.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L27936                  L27936                
L25400:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r83.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L27416                  L27416                
L25432:
(W)     mov (1|M0)               r6.7<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r58.0<1>:d    r101.0<1;0>:d     r49.0<1;0>:d      104:w              
        subb (8|M0)              r102.0<1>:ud  r6.7<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r102.0<1;1,0>:ud  r58.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r121.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r125.0<1>:ud    {F@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r121.0<1;1,0>:d   0:w               {I@1}
(~f0.0) cmp (8|M0)    (gt)f0.0   null<1>:ud    r121.0<1;1,0>:ud  0x0:uw             
(f0.0)  goto (8|M0)                          L25632                  L25632                
L25568:
        add3 (8|M0)              acc0.0<1>:d   r70.0<1;0>:d      -r102.0<1;0>:d    104:w              
        shl (8|M0)               r25.0<1>:d    r24.0<1;1,0>:d    acc0.0<1;1,0>:d 
        mov (8|M0)               r24.0<1>:d    0:w                              
        goto (8|M0)                          L25632                  L27352                
L25632:
        join (8|M0)                          L27352                                
L25648:
        add3 (8|M0)              r98.0<1>:d    r102.0<1;0>:d     -r70.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r98.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (8|M0)                          L25784                  L25784                
L25696:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r98.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (8|M0)                          L25784                  L25832                
L25720:
        shr (8|M0)               r7.0<1>:ud    r24.0<1;1,0>:ud   1:w              
        and (8|M0)               r83.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@3}
        goto (8|M0)                          L25784                  L26784                
L25784:
        join (8|M0)                          L25832                                
L25800:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L25832                  L26728                
L25832:
        join (8|M0)                          L26728                                
L25848:
        add3 (8|M0)              acc0.0<1>:d   r102.0<1;0>:d     -r58.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.0   r26.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L25928                  L25928                
L25896:
        mov (8|M0)               r79.0<1>:d    r24.0<1;1,0>:d                  
        goto (8|M0)                          L25928                  L26064                
L25928:
        join (8|M0)                          L26064                                
L25944:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r26.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r26.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r26.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r23.0<1>:ud   r24.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r67.0<1>:d    r32.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r7.0<1>:ud    r32.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r7.0<1>:d     r23.0<1;1,0>:d    r67.0<1;1,0>:d   {I@2}
        mov (8|M0)               r79.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@1}
L26064:
        join (8|M0)                          L26728                                
L26080:
        add3 (8|M0)              r49.0<1>:d    r102.0<1;0>:d     -r58.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.0   r25.0<1>:d    r49.0<1;1,0>:d    63:w               {I@1}
(f0.0)  goto (8|M0)                          L26160                  L26160                
L26128:
        mov (8|M0)               r7.0<1>:d     r24.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L26160                  L26288                
L26160:
        join (8|M0)                          L26288                                
L26176:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r25.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r25.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r25.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r21.0<1>:ud   r24.0<1;1,0>:ud   r25.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r66.0<1>:d    r32.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r7.0<1>:ud    r32.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r7.0<1>:d     r21.0<1;1,0>:d    r66.0<1;1,0>:d   {I@2}
L26288:
        join (8|M0)                          L26728                                
L26304:
        and (8|M0)    (ne)f1.0   r65.0<1>:d    r49.0<1;1,0>:d    63:w              
        and (8|M0)               r83.0<1>:d    r7.0<1;1,0>:d     1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L26392                  L26392                
L26344:
        mov (8|M0)               r84.0<1>:d    -1:w                              
        mov (8|M0)               r103.0<1>:d   -1:w                              
        goto (8|M0)                          L26392                  L26576                
L26392:
        join (8|M0)                          L26576                                
L26408:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r65.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L26512                  L26512                
L26440:
        add (8|M0)               acc0.0<1>:d   r65.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r84.0<1>:d    0:w                              
        shl (8|M0)               r103.0<1>:d   r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L26512                  L26576                
L26512:
        join (8|M0)                          L26576                                
L26528:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r103.0<1>:d   -1:w                              
        shl (8|M0)               r84.0<1>:d    r6.14<0;1,0>:w    r65.0<1;1,0>:d   {F@1}
L26576:
        join (8|M0)                          L26728                                
L26592:
        bfn.0x28 (8|M0)          r19.0<1>:ud   r24.0<1;0>:ud     r84.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r18.0<1>:ud   r32.0<1;0>:ud     r103.0<1;0>:ud    r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r19.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r38.0<1>:f    r79.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r18.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@2}
        mov (8|M0)               r54.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L26728                  L26784                
L26728:
        join (8|M0)                          L26784                                
L26744:
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
L26784:
        join (8|M0)                          L27352                                
L26800:
        and (8|M0)    (ne)f0.0   r23.0<1>:d    r98.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L26864                  L26864                
L26832:
        mov (8|M0)               r7.0<1>:d     r24.0<1;1,0>:d                  
        goto (8|M0)                          L26864                  L26992                
L26864:
        join (8|M0)                          L26992                                
L26880:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r23.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r23.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r23.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r15.0<1>:ud   r24.0<1;1,0>:ud   r23.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r64.0<1>:d    r32.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r7.0<1>:ud    r32.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r7.0<1>:d     r15.0<1;1,0>:d    r64.0<1;1,0>:d   {I@2}
L26992:
        join (8|M0)                          L27352                                
L27008:
        shl (8|M0)               r26.0<1>:d    r38.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r14.0<1>:d    r83.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r26.0<1>:d    r26.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r123.0<1>:ud  r26.0<1;0>:ud     r14.0<1;0>:ud     r54.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r123.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (8|M0)                          L27112                  L27112                
L27080:
        mov (8|M0)               r126.0<1>:d   0:w                              
        goto (8|M0)                          L27112                  L27272                
L27112:
        join (8|M0)                          L27272                                
L27128:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r123.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (8|M0)                          L27192                  L27192                
L27160:
        mov (8|M0)               r126.0<1>:d   1:w                              
        goto (8|M0)                          L27192                  L27272                
L27192:
        join (8|M0)                          L27272                                
L27208:
        and (8|M0)    (ne)f1.0   null<1>:d     r7.0<1;1,0>:d     1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r123.0<1;1,0>:d   4:w              
(f1.0)  sel (8|M0)               r126.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
L27272:
        join (8|M0)                          L27352                                
L27288:
        add (8|M0)               r101.0<1>:d   r126.0<1;1,0>:d   r7.0<1;1,0>:d    {Compacted,I@2}
(W)     mov (1|M0)               r6.7<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r101.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r25.0<1>:d    r101.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               r24.0<1>:d    r6.7<0;1,0>:d     0:w               {F@1}
L27352:
        join (8|M0)                          L27416                                
L27368:
        and (8|M0)               r13.0<1>:d    r20.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r24.0<1>:ud   r13.0<1;0>:ud     r24.0<1;0>:ud     r25.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L27416                  L30608                
L27416:
        join (8|M0)                          L27936                                
L27432:
        and (8|M0)    (ne)f0.0   r33.0<1>:d    r49.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L27512                  L27512                
L27464:
        mov (8|M0)               r48.0<1>:d    -1:w                              
        mov (8|M0)               r63.0<1>:d    -1:w                              
        goto (8|M0)                          L27512                  L27696                
L27512:
        join (8|M0)                          L27696                                
L27528:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r33.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L27632                  L27632                
L27560:
        add (8|M0)               acc0.0<1>:d   r33.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r48.0<1>:d    0:w                              
        shl (8|M0)               r63.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L27632                  L27696                
L27632:
        join (8|M0)                          L27696                                
L27648:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r63.0<1>:d    -1:w                              
        shl (8|M0)               r48.0<1>:d    r6.14<0;1,0>:w    r33.0<1;1,0>:d   {F@1}
L27696:
        join (8|M0)                          L27936                                
L27712:
        bfn.0x28 (8|M0)          r12.0<1>:ud   r24.0<1;0>:ud     r48.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r7.0<1>:ud    r32.0<1;0>:ud     r63.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r20.0<1;1,0>:d    -1:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r7.0<1;1,0>:d     0:w               {I@3}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r83.0<1;1,0>:d    -150:w              
(f1.0)  goto (8|M0)                          L27872                  L27872                
L27824:
(W)     mov (1|M0)               r6.7<1>:ud    0x80000001:ud                             
(f0.1)  sel (8|M0)               r24.0<1>:f    r6.7<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L27872                  L30608                
L27872:
        join (8|M0)                          L27936                                
L27888:
(W)     mov (1|M0)               r6.7<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (8|M0)               r24.0<1>:f    r6.7<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L27936                  L30608                
L27936:
        join (8|M0)                          L30360                                
L27952:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r49.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r99.0<1>:d    r101.0<1;0>:d     r49.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L30040                  L30040                
L28016:
        shl (8|M0)               r71.0<1>:d    r37.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r70.0<1>:ud   r37.0<1;1,0>:ud   31:w              
        shl (8|M0)               r50.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r71.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r50.0<1>:d    r50.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r50.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r50.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L28240                  L28240                
L28120:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r37.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r92.0<1;1,0>:d    0:w              
(~f0.0) goto (8|M0)                          L28240                  L28304                
L28160:
        shr (8|M0)               r7.0<1>:ud    r24.0<1;1,0>:ud   1:w              
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r92.0<1>:d    0:w                              
        mov (8|M0)               r76.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@3}
        mov (8|M0)               r7.0<1>:f     r24.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L28240                  L29496                
L28240:
        join (8|M0)                          L28304                                
L28256:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r37.0<1;1,0>:d    38:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r92.0<1;1,0>:d    0:w               {I@4}
(f1.1)  goto (8|M0)                          L28304                  L29416                
L28304:
        join (8|M0)                          L29416                                
L28320:
        add (8|M0)               acc0.0<1>:d   -r37.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r108.0<1>:d   -r37.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r44.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L28400                  L28400                
L28368:
        mov (8|M0)               r88.0<1>:d    r24.0<1;1,0>:d                  
        goto (8|M0)                          L28400                  L28536                
L28400:
        join (8|M0)                          L28536                                
L28416:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r44.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r44.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r44.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r125.0<1>:ud  r24.0<1;1,0>:ud   r44.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r102.0<1>:d   r32.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r7.0<1>:ud    r32.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.0)  or (8|M0)                r7.0<1>:d     r125.0<1;1,0>:d   r102.0<1;1,0>:d  {I@2}
        mov (8|M0)               r88.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@1}
L28536:
        join (8|M0)                          L29416                                
L28552:
        add (8|M0)               r61.0<1>:d    -r37.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.1   r48.0<1>:d    r61.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L28624                  L28624                
L28592:
        mov (8|M0)               r7.0<1>:d     r24.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L28624                  L28752                
L28624:
        join (8|M0)                          L28752                                
L28640:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r48.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r48.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r48.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r123.0<1>:ud  r24.0<1;1,0>:ud   r48.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r117.0<1>:d   r32.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r7.0<1>:ud    r32.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r7.0<1>:d     r123.0<1;1,0>:d   r117.0<1;1,0>:d  {I@2}
L28752:
        join (8|M0)                          L29416                                
L28768:
        and (8|M0)    (ne)f0.1   r116.0<1>:d   r61.0<1;1,0>:d    63:w              
        and (8|M0)               r92.0<1>:d    r7.0<1;1,0>:d     1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L28856                  L28856                
L28808:
        mov (8|M0)               r12.0<1>:d    -1:w                              
        mov (8|M0)               r30.0<1>:d    -1:w                              
        goto (8|M0)                          L28856                  L29040                
L28856:
        join (8|M0)                          L29040                                
L28872:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r116.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.0)  goto (8|M0)                          L28976                  L28976                
L28904:
        add (8|M0)               acc0.0<1>:d   r116.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r12.0<1>:d    0:w                              
        shl (8|M0)               r30.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L28976                  L29040                
L28976:
        join (8|M0)                          L29040                                
L28992:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r30.0<1>:d    -1:w                              
        shl (8|M0)               r12.0<1>:d    r6.14<0;1,0>:w    r116.0<1;1,0>:d  {F@1}
L29040:
        join (8|M0)                          L29416                                
L29056:
        bfn.0x28 (8|M0)          r122.0<1>:ud  r24.0<1;0>:ud     r12.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r121.0<1>:ud  r32.0<1;0>:ud     r30.0<1;0>:ud     r6.4<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.1   r47.0<1>:d    r108.0<1;1,0>:d   63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r121.0<1;1,0>:d   0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
        mov (8|M0)               r72.0<1>:d    -acc0.0<1;1,0>:d                
(f1.1)  goto (8|M0)                          L29232                  L29232                
L29200:
        mov (8|M0)               r7.0<1>:d     r24.0<1;1,0>:d                  
        goto (8|M0)                          L29232                  L29360                
L29232:
        join (8|M0)                          L29360                                
L29248:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r47.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r47.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r47.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r118.0<1>:ud  r24.0<1;1,0>:ud   r47.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r115.0<1>:d   r32.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r7.0<1>:ud    r32.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r7.0<1>:d     r118.0<1;1,0>:d   r115.0<1;1,0>:d  {I@2}
L29360:
        join (8|M0)                          L29416                                
L29376:
        mov (8|M0)               r76.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@2}
        mov (8|M0)               r7.0<1>:d     r88.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L29416                  L29496                
L29416:
        join (8|M0)                          L29496                                
L29432:
        shr (8|M0)               r7.0<1>:ud    r24.0<1;1,0>:ud   2:w              
        and (8|M0)               r92.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r76.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@3}
        shr (8|M0)               r7.0<1>:ud    r24.0<1;1,0>:ud   1:w               {F@1}
L29496:
        join (8|M0)                          L30040                                
L29512:
        shl (8|M0)               r83.0<1>:d    r7.0<1;1,0>:d     2:w               {Compacted,I@2}
        shl (8|M0)               r117.0<1>:d   r92.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r83.0<1>:d    r83.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r90.0<1>:d    r76.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r32.0<1>:ud   r83.0<1;0>:ud     r117.0<1;0>:ud    r72.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r32.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L29632                  L29632                
L29600:
        mov (8|M0)               r31.0<1>:d    0:w                              
        goto (8|M0)                          L29632                  L29792                
L29632:
        join (8|M0)                          L29792                                
L29648:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r32.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (8|M0)                          L29712                  L29712                
L29680:
        mov (8|M0)               r31.0<1>:d    1:w                              
        goto (8|M0)                          L29712                  L29792                
L29712:
        join (8|M0)                          L29792                                
L29728:
        and (8|M0)    (ne)f0.1   null<1>:d     r76.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r32.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r31.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L29792:
        join (8|M0)                          L30040                                
L29808:
        add (8|M0)               r120.0<1>:d   r90.0<1;1,0>:d    r31.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r114.0<1>:d   r101.0<1;0>:d     r49.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r120.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r107.0<1>:d   r114.0<1;1,0>:d   r99.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r107.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (8|M0)                          L29968                  L29968                
L29896:
(~f1.0) sel (8|M0)               r118.0<1>:d   r120.0<1;1,0>:d   0:w              
        and (8|M0)               r113.0<1>:d   r20.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r116.0<1>:d   r107.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r24.0<1>:ud   r113.0<1;0>:ud    r116.0<1;0>:ud    r118.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L29968                  L30608                
L29968:
        join (8|M0)                          L30040                                
L29984:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r20.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r24.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L30040                  L30608                
L30040:
        join (8|M0)                          L30360                                
L30056:
        and (8|M0)    (ne)f1.0   r111.0<1>:d   r49.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L30120                  L30120                
L30088:
        mov (8|M0)               r25.0<1>:d    -1:w                              
        goto (8|M0)                          L30120                  L30248                
L30120:
        join (8|M0)                          L30248                                
L30136:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r111.0<1;1,0>:ud  0x20:uw              {A@1}
(f0.1)  goto (8|M0)                          L30200                  L30200                
L30168:
        mov (8|M0)               r25.0<1>:d    0:w                              
        goto (8|M0)                          L30200                  L30248                
L30200:
        join (8|M0)                          L30248                                
L30216:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        shl (8|M0)               r25.0<1>:d    r6.14<0;1,0>:w    r111.0<1;1,0>:d  {F@1}
L30248:
        join (8|M0)                          L30360                                
L30264:
        bfn.0x28 (8|M0)          r30.0<1>:ud   r24.0<1;0>:ud     r25.0<1;0>:ud     r6.4<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r49.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r112.0<1>:d   r20.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r114.0<1>:d   r99.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r30.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r24.0<1>:ud   r112.0<1;0>:ud    r114.0<1;0>:ud    r30.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L30360                  L30608                
L30360:
        join (8|M0)                          L30432                                
L30376:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r20.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r24.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L30432                  L30608                
L30432:
        join (8|M0)                          L30504                                
L30448:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r24.0<1>:f    r6.7<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L30504                  L30608                
L30504:
        join (8|M0)                          L30576                                
L30520:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r20.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r24.0<1>:f    r6.7<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L30576                  L30608                
L30576:
        join (8|M0)                          L30608                                
L30592:
        bfn.0xF8 (8|M0)          r24.0<1>:ud   r20.0<1;0>:ud     r6.6<0;0>:ud      r6.5<0>:ud       {F@1} // s0&s1|s2
L30608:
        join (8|M0)                          L30656                                
L30624:
        mov (8|M0)               r7.0<1>:hf    r24.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r12.0<1>:f    r7.0<1;1,0>:hf                   {F@1}
L30656:
        join (8|M0)                          L44072                                
L30672:
(W)     mov (1|M0)               f1.0<1>:uw    r6.0<0;1,0>:uw                  
(f1.0)  goto (8|M0)                          L30792                  L30792                
L30704:
        sync.nop                             null                             {Compacted,$5.dst}
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r6.1<0;1,0>:uw                  
        mov (8|M0)               acc0.0<1>:f   r7.0<1;1,0>:hf                   {F@1}
(f0.1)  sel (8|M0)               r31.0<1>:f    acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {$3.src}
        goto (8|M0)                          L30792                  L43584                
L30792:
        join (8|M0)                          L43584                                
L30808:
        and (8|M0)               r113.0<1>:d   r12.0<1;1,0>:d    2147483647:d               {$5.dst}
        sel (8|M0)    (lt)f0.0   r47.0<1>:f    r113.0<1;1,0>:f   448.0:f               {Compacted,I@1}
        shr (8|M0)               r48.0<1>:ud   r47.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.0   r7.0<1>:d     r47.0<1;1,0>:d    8388607:d              
        and (8|M0)               r75.0<1>:d    r48.0<1;1,0>:d    255:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r112.0<1>:ud  r75.0<1;1,0>:ud   0x79:uw              {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r75.0<1;1,0>:d    255:w              
        shl (8|M0)               r19.0<1>:d    r112.0<1;1,0>:d   23:w               {Compacted,I@2}
(~f0.0) goto (8|M0)                          L30952                  L30952                
L30928:
        mov (8|M0)               r26.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L30952                  L37152                
L30952:
        join (8|M0)                          L37152                                
L30968:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r7.0<1;1,0>:d     0:w              
        add (8|M0)               r13.0<1>:d    -r19.0<1;1,0>:d   -2139095040:d               {I@5}
        xor (8|M0)               r22.0<1>:d    r13.0<1;1,0>:d    r47.0<1;1,0>:d   {Compacted,I@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r75.0<1;1,0>:d    255:w              
(f1.1)  goto (8|M0)                          L37120                  L37120                
L31040:
        or (8|M0)     (eq)f0.0   null<1>:d     r75.0<1;1,0>:d    r7.0<1;1,0>:d   
(~f0.0) goto (8|M0)                          L31096                  L31096                
L31072:
        mov (8|M0)               r26.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L31096                  L37152                
L31096:
        join (8|M0)                          L37120                                
L31112:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r75.0<1;1,0>:d    0:w               {Compacted}
        shr (8|M0)               r98.0<1>:ud   r13.0<1;1,0>:ud   23:w              
        add (8|M0)               r113.0<1>:d   r75.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (8|M0)               r113.0<1>:d   -126:w                              
        add (8|M0)               r97.0<1>:d    r98.0<1;1,0>:d    r113.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r97.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (8|M0)                          L37048                  L37048                
L31200:
        or (8|M0)     (eq)f1.0   null<4>:b     r48.0<1;1,0>:d    r98.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L36976                  L36976                
L31232:
(W)     mov (1|M0)               r6.14<1>:hf   0.0:hf                             
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    8388608:d               {F@1}
        or (8|M0)                r32.0<1>:d    acc0.0<1;1,0>:d   r7.0<1;1,0>:d   
(W)     mov (1|M0)               r7.7<1>:d     0:w                              
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted,I@2}
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        shl (8|M0)               r26.0<1>:d    r32.0<1;1,0>:d    23:w               {Compacted}
        shr (8|M0)               r30.0<1>:ud   r32.0<1;1,0>:ud   9:w              
L31344:
(W)     shl (1|M0)               r8.4<1>:d     r7.6<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r8.3<1>:ud    r7.7<0;1,0>:ud    1:w               {I@5}
(W)     cmp (8|M0)    (gt)f0.0   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r7.7<1>:d     r8.3<0;1,0>:d     r8.4<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r52.0<1>:ud   r8.3<0;0>:ud      r8.4<0;0>:ud      r26.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.7<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f0.0) cmp (8|M0)   (eq)f0.0   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    r7.7<0;1,0>:d    {I@3}
        sync.nop                             null                             {Compacted,$4.src}
        and (8|M0)               r51.0<1>:d    r6.7<0;1,0>:d     r30.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r15.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.0) cmp (8|M0)  (gt)f0.0   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r8.6<1>:hf    0x1:hf                             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.0)  sel (8|M0)               r14.0<1>:uw   r8.6<0;1,0>:uw    0x0:uw              {F@1}
(W)     add (1|M0)               r8.5<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@2}
(f1.1)  sel (8|M0)               r7.0<1>:uw    r8.6<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r124.0<1>:d   r7.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r14.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r13.0<1>:d    r7.5<0;1,0>:d                   
        mov (8|M0)               r41.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r95.0<1>:d    r8.5<0;1,0>:d                   
(f0.1)  goto (8|M0)                          L31760                  L31760                
L31696:
(W)     mov (1|M0)               r7.6<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:f     r8.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L31344                                
L31760:
        join (8|M0)                          L36976                                
L31776:
(W)     mov (1|M0)               r6.7<1>:f     8.68805e-44:f                               {I@4}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r68.0<1>:ud   r6.7<0;1,0>:ud    r124.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r88.0<1>:d    r97.0<1;0>:d      r68.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r106.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r13.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r88.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r75.0<1>:d    r98.0<1;0>:d      r113.0<1;0>:d     r68.0<1>:d      
(f0.1)  goto (8|M0)                          L36904                  L36904                
L31896:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r88.0<1;1,0>:d    -127:w              
(f0.0)  goto (8|M0)                          L34472                  L34472                
L31928:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r88.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L33952                  L33952                
L31960:
(W)     mov (1|M0)               r6.7<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r68.0<1>:d    r97.0<1;0>:d      r68.0<1;0>:d      -23:w              
        subb (8|M0)              r106.0<1>:ud  r6.7<0;1,0>:ud    r124.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r106.0<1;1,0>:ud  r68.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r23.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r13.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r23.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r23.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L32160                  L32160                
L32096:
        add3 (8|M0)              acc0.0<1>:d   r75.0<1;0>:d      -r106.0<1;0>:d    -23:w              
        mov (8|M0)               r42.0<1>:d    0:w                              
        shl (8|M0)               r43.0<1>:d    r26.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L32160                  L33888                
L32160:
        join (8|M0)                          L33888                                
L32176:
        add3 (8|M0)              r111.0<1>:d   r106.0<1;0>:d     -r75.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r111.0<1;1,0>:d   2:w               {I@1}
(f1.0)  goto (8|M0)                          L32328                  L32328                
L32224:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r111.0<1;1,0>:d   2:w              
(~f0.1) goto (8|M0)                          L32328                  L32368                
L32256:
        shr (8|M0)               r13.0<1>:ud   r26.0<1;1,0>:ud   1:w              
        mov (8|M0)               r66.0<1>:d    0:w                              
        mov (8|M0)               r88.0<1>:d    0:w                              
        mov (8|M0)               r50.0<1>:f    r13.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L32328                  L33320                
L32328:
        join (8|M0)                          L32368                                
L32344:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r111.0<1;1,0>:d   1:w               {Compacted}
(f0.0)  goto (8|M0)                          L32368                  L33264                
L32368:
        join (8|M0)                          L33264                                
L32384:
        add3 (8|M0)              acc0.0<1>:d   r106.0<1;0>:d     -r68.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.1   r43.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L32464                  L32464                
L32432:
        mov (8|M0)               r84.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L32464                  L32600                
L32464:
        join (8|M0)                          L32600                                
L32480:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r43.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r43.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r43.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r108.0<1>:ud  r26.0<1;1,0>:ud   r43.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r101.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r13.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r13.0<1>:d    r108.0<1;1,0>:d   r101.0<1;1,0>:d  {I@2}
        mov (8|M0)               r84.0<1>:f    r13.0<1;1,0>:f                   {Compacted,I@1}
L32600:
        join (8|M0)                          L33264                                
L32616:
        add3 (8|M0)              r59.0<1>:d    r106.0<1;0>:d     -r68.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.1   r42.0<1>:d    r59.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (8|M0)                          L32696                  L32696                
L32664:
        mov (8|M0)               r13.0<1>:d    r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L32696                  L32824                
L32696:
        join (8|M0)                          L32824                                
L32712:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r42.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r42.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r42.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r106.0<1>:ud  r26.0<1;1,0>:ud   r42.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r100.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r13.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r13.0<1>:d    r106.0<1;1,0>:d   r100.0<1;1,0>:d  {I@2}
L32824:
        join (8|M0)                          L33264                                
L32840:
        and (8|M0)    (ne)f1.1   r99.0<1>:d    r59.0<1;1,0>:d    63:w              
        and (8|M0)               r88.0<1>:d    r13.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L32928                  L32928                
L32880:
        mov (8|M0)               r114.0<1>:d   -1:w                              
        mov (8|M0)               r127.0<1>:d   -1:w                              
        goto (8|M0)                          L32928                  L33112                
L32928:
        join (8|M0)                          L33112                                
L32944:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r99.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L33048                  L33048                
L32976:
        add (8|M0)               acc0.0<1>:d   r99.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r114.0<1>:d   0:w                              
        shl (8|M0)               r127.0<1>:d   r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L33048                  L33112                
L33048:
        join (8|M0)                          L33112                                
L33064:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r127.0<1>:d   -1:w                              
        shl (8|M0)               r114.0<1>:d   r6.14<0;1,0>:w    r99.0<1;1,0>:d   {F@1}
L33112:
        join (8|M0)                          L33264                                
L33128:
        bfn.0x60 (8|M0)          r105.0<1>:ud  r114.0<1;0>:ud    r6.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r104.0<1>:ud  r127.0<1;0>:ud    r6.4<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r105.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r50.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r104.0<1;1,0>:d   0:w               {I@2}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@2}
        mov (8|M0)               r66.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L33264                  L33320                
L33264:
        join (8|M0)                          L33320                                
L33280:
        mov (8|M0)               r66.0<1>:d    0:w                              
        mov (8|M0)               r88.0<1>:d    0:w                              
        mov (8|M0)               r50.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
L33320:
        join (8|M0)                          L33888                                
L33336:
        and (8|M0)    (ne)f0.1   r41.0<1>:d    r111.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L33400                  L33400                
L33368:
        mov (8|M0)               r13.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L33400                  L33528                
L33400:
        join (8|M0)                          L33528                                
L33416:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r41.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r41.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r41.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r101.0<1>:ud  r26.0<1;1,0>:ud   r41.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r98.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r13.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r13.0<1>:d    r101.0<1;1,0>:d   r98.0<1;1,0>:d   {I@2}
L33528:
        join (8|M0)                          L33888                                
L33544:
        shl (8|M0)               r46.0<1>:d    r50.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r100.0<1>:d   r88.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r46.0<1>:d    r46.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r14.0<1>:ud   r46.0<1;0>:ud     r100.0<1;0>:ud    r66.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L33648                  L33648                
L33616:
        mov (8|M0)               r23.0<1>:d    0:w                              
        goto (8|M0)                          L33648                  L33808                
L33648:
        join (8|M0)                          L33808                                
L33664:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r14.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L33728                  L33728                
L33696:
        mov (8|M0)               r23.0<1>:d    1:w                              
        goto (8|M0)                          L33728                  L33808                
L33728:
        join (8|M0)                          L33808                                
L33744:
        and (8|M0)    (ne)f0.1   null<1>:d     r13.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r14.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r23.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L33808:
        join (8|M0)                          L33888                                
L33824:
        add (8|M0)               r104.0<1>:d   r23.0<1;1,0>:d    r13.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.7<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r104.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f0.0) sel (8|M0)               r43.0<1>:d    r104.0<1;1,0>:d   0:w              
(f0.0)  sel (8|M0)               r42.0<1>:d    r6.7<0;1,0>:d     0:w               {F@1}
L33888:
        join (8|M0)                          L33952                                
L33904:
        and (8|M0)               r99.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r26.0<1>:ud   r99.0<1;0>:ud     r42.0<1;0>:ud     r43.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L33952                  L37152                
L33952:
        join (8|M0)                          L34472                                
L33968:
        and (8|M0)    (ne)f0.1   r62.0<1>:d    r68.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L34048                  L34048                
L34000:
        mov (8|M0)               r82.0<1>:d    -1:w                              
        mov (8|M0)               r97.0<1>:d    -1:w                              
        goto (8|M0)                          L34048                  L34232                
L34048:
        join (8|M0)                          L34232                                
L34064:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r62.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L34168                  L34168                
L34096:
        add (8|M0)               acc0.0<1>:d   r62.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r82.0<1>:d    0:w                              
        shl (8|M0)               r97.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L34168                  L34232                
L34168:
        join (8|M0)                          L34232                                
L34184:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r97.0<1>:d    -1:w                              
        shl (8|M0)               r82.0<1>:d    r6.14<0;1,0>:w    r62.0<1;1,0>:d   {F@1}
L34232:
        join (8|M0)                          L34472                                
L34248:
        bfn.0x60 (8|M0)          r98.0<1>:ud   r82.0<1;0>:ud     r6.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r97.0<1>:ud   r97.0<1;0>:ud     r6.4<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r98.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r22.0<1;1,0>:d    -1:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r97.0<1;1,0>:d    0:w               {I@3}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r88.0<1;1,0>:d    -150:w              
(f1.1)  goto (8|M0)                          L34408                  L34408                
L34360:
(W)     mov (1|M0)               r6.7<1>:ud    0x80000001:ud                             
(f0.0)  sel (8|M0)               r26.0<1>:f    r6.7<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L34408                  L37152                
L34408:
        join (8|M0)                          L34472                                
L34424:
(W)     mov (1|M0)               r6.7<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (8|M0)               r26.0<1>:f    r6.7<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L34472                  L37152                
L34472:
        join (8|M0)                          L36904                                
L34488:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r68.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r102.0<1>:d   r97.0<1;0>:d      r68.0<1;0>:d      -46:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r106.0<1;1,0>:d   0:w              
(f0.0)  goto (8|M0)                          L36584                  L36584                
L34552:
        shl (8|M0)               r86.0<1>:d    r41.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r85.0<1>:ud   r41.0<1;1,0>:ud   31:w              
        shl (8|M0)               r67.0<1>:d    r95.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r86.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r67.0<1>:d    r67.0<1;1,0>:d    r85.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r67.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r67.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L34784                  L34784                
L34656:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r41.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L34784                  L34848                
L34704:
        shr (8|M0)               r13.0<1>:ud   r26.0<1;1,0>:ud   1:w              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r95.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:f    r13.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r13.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L34784                  L36048                
L34784:
        join (8|M0)                          L34848                                
L34800:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r41.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    0:w               {I@4}
(f1.0)  goto (8|M0)                          L34848                  L35960                
L34848:
        join (8|M0)                          L35960                                
L34864:
        add (8|M0)               acc0.0<1>:d   -r41.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r111.0<1>:d   -r41.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r56.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L34944                  L34944                
L34912:
        mov (8|M0)               r94.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L34944                  L35080                
L34944:
        join (8|M0)                          L35080                                
L34960:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r56.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r56.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r56.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r94.0<1>:ud   r26.0<1;1,0>:ud   r56.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r126.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r13.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r13.0<1>:d    r94.0<1;1,0>:d    r126.0<1;1,0>:d  {I@2}
        mov (8|M0)               r94.0<1>:f    r13.0<1;1,0>:f                   {Compacted,I@1}
L35080:
        join (8|M0)                          L35960                                
L35096:
        add (8|M0)               r69.0<1>:d    -r41.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.0   r66.0<1>:d    r69.0<1;1,0>:d    63:w               {I@1}
(f0.0)  goto (8|M0)                          L35168                  L35168                
L35136:
        mov (8|M0)               r13.0<1>:d    r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L35168                  L35296                
L35168:
        join (8|M0)                          L35296                                
L35184:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r66.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r66.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r66.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r92.0<1>:ud   r26.0<1;1,0>:ud   r66.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r29.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r13.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r13.0<1>:d    r92.0<1;1,0>:d    r29.0<1;1,0>:d   {I@2}
L35296:
        join (8|M0)                          L35960                                
L35312:
        and (8|M0)    (ne)f1.0   r28.0<1>:d    r69.0<1;1,0>:d    63:w              
        and (8|M0)               r95.0<1>:d    r13.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L35400                  L35400                
L35352:
        mov (8|M0)               r37.0<1>:d    -1:w                              
        mov (8|M0)               r44.0<1>:d    -1:w                              
        goto (8|M0)                          L35400                  L35584                
L35400:
        join (8|M0)                          L35584                                
L35416:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r28.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L35520                  L35520                
L35448:
        add (8|M0)               acc0.0<1>:d   r28.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r37.0<1>:d    0:w                              
        shl (8|M0)               r44.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L35520                  L35584                
L35520:
        join (8|M0)                          L35584                                
L35536:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r44.0<1>:d    -1:w                              
        shl (8|M0)               r37.0<1>:d    r6.14<0;1,0>:w    r28.0<1;1,0>:d   {F@1}
L35584:
        join (8|M0)                          L35960                                
L35600:
        bfn.0x60 (8|M0)          r91.0<1>:ud   r37.0<1;0>:ud     r6.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r90.0<1>:ud   r44.0<1;0>:ud     r6.4<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r91.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.0   r65.0<1>:d    r111.0<1;1,0>:d   63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r90.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
        mov (8|M0)               r82.0<1>:d    -acc0.0<1;1,0>:d                
(f0.0)  goto (8|M0)                          L35776                  L35776                
L35744:
        mov (8|M0)               r13.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L35776                  L35904                
L35776:
        join (8|M0)                          L35904                                
L35792:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r65.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r65.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r65.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r87.0<1>:ud   r26.0<1;1,0>:ud   r65.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r27.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r13.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r13.0<1>:d    r87.0<1;1,0>:d    r27.0<1;1,0>:d   {I@2}
L35904:
        join (8|M0)                          L35960                                
L35920:
        mov (8|M0)               r78.0<1>:f    r13.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r13.0<1>:d    r94.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L35960                  L36048                
L35960:
        join (8|M0)                          L36048                                
L35976:
        shr (8|M0)               r13.0<1>:ud   r26.0<1;1,0>:ud   2:w              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r95.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:f    r13.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r13.0<1>:ud   r26.0<1;1,0>:ud   1:w               {F@1}
L36048:
        join (8|M0)                          L36584                                
L36064:
        shl (8|M0)               r113.0<1>:d   r13.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r86.0<1>:d    r95.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r113.0<1>:d   r113.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r98.0<1>:d    r78.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r61.0<1>:ud   r113.0<1;0>:ud    r86.0<1;0>:ud     r82.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r61.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L36184                  L36184                
L36152:
        mov (8|M0)               r60.0<1>:d    0:w                              
        goto (8|M0)                          L36184                  L36344                
L36184:
        join (8|M0)                          L36344                                
L36200:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r61.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L36264                  L36264                
L36232:
        mov (8|M0)               r60.0<1>:d    1:w                              
        goto (8|M0)                          L36264                  L36344                
L36264:
        join (8|M0)                          L36344                                
L36280:
        and (8|M0)    (ne)f0.0   null<1>:d     r78.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r61.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r60.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L36344:
        join (8|M0)                          L36584                                
L36360:
        add (8|M0)               r21.0<1>:d    r98.0<1;1,0>:d    r60.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r25.0<1>:d    r97.0<1;0>:d      r68.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r21.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r119.0<1>:d   r25.0<1;1,0>:d    r102.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r119.0<1;1,0>:d   255:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L36512                  L36512                
L36440:
(~f0.1) sel (8|M0)               r37.0<1>:d    r21.0<1;1,0>:d    0:w              
        and (8|M0)               r24.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r85.0<1>:d    r119.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r26.0<1>:ud   r24.0<1;0>:ud     r85.0<1;0>:ud     r37.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L36512                  L37152                
L36512:
        join (8|M0)                          L36584                                
L36528:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r22.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r26.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36584                  L37152                
L36584:
        join (8|M0)                          L36904                                
L36600:
        and (8|M0)    (ne)f1.1   r127.0<1>:d   r68.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L36664                  L36664                
L36632:
        mov (8|M0)               r45.0<1>:d    -1:w                              
        goto (8|M0)                          L36664                  L36792                
L36664:
        join (8|M0)                          L36792                                
L36680:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r127.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  goto (8|M0)                          L36744                  L36744                
L36712:
        mov (8|M0)               r45.0<1>:d    0:w                              
        goto (8|M0)                          L36744                  L36792                
L36744:
        join (8|M0)                          L36792                                
L36760:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        shl (8|M0)               r45.0<1>:d    r6.14<0;1,0>:w    r127.0<1;1,0>:d  {F@1}
L36792:
        join (8|M0)                          L36904                                
L36808:
        bfn.0x60 (8|M0)          r59.0<1>:ud   r45.0<1;0>:ud     r6.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r68.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r23.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r83.0<1>:d    r102.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r59.0<1>:d    r59.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r26.0<1>:ud   r23.0<1;0>:ud     r83.0<1;0>:ud     r59.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L36904                  L37152                
L36904:
        join (8|M0)                          L36976                                
L36920:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r26.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36976                  L37152                
L36976:
        join (8|M0)                          L37048                                
L36992:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r22.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r26.0<1>:f    r6.7<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L37048                  L37152                
L37048:
        join (8|M0)                          L37120                                
L37064:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r26.0<1>:f    r6.7<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L37120                  L37152                
L37120:
        join (8|M0)                          L37152                                
L37136:
        bfn.0xF8 (8|M0)          r26.0<1>:ud   r22.0<1;0>:ud     r6.6<0;0>:ud      r6.5<0>:ud       {F@1} // s0&s1|s2
L37152:
        join (8|M0)                          L43584                                
L37168:
        rnde (8|M0)              r58.0<1>:f    r26.0<1;1,0>:f                   {Compacted,I@2}
        shr (8|M0)               r53.0<1>:ud   r58.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.1   r36.0<1>:d    r58.0<1;1,0>:d    8388607:d              
        and (8|M0)               r89.0<1>:d    r53.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L37272                  L37272                
L37248:
        mov (8|M0)               r23.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L37272                  L43528                
L37272:
        join (8|M0)                          L43528                                
L37288:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    0:w               {Compacted}
        add (8|M0)               r126.0<1>:d   r19.0<1;1,0>:d    -25165824:d              
        shr (8|M0)               r47.0<1>:ud   r126.0<1;1,0>:ud  23:w               {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r89.0<1;1,0>:d    255:w              
        and (8|M0)               r116.0<1>:d   r47.0<1;1,0>:d    255:w               {Compacted,I@2}
        xor (8|M0)               r21.0<1>:d    r126.0<1;1,0>:d   r58.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r116.0<1;1,0>:d   255:w               {I@2}
(f0.0)  goto (8|M0)                          L43496                  L43496                
L37392:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r116.0<1;1,0>:d   0:w              
        or (8|M0)                r82.0<1>:d    r89.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L37472                  L37472                
L37448:
        mov (8|M0)               r23.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L37472                  L43528                
L37472:
        join (8|M0)                          L43496                                
L37488:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    0:w              
        add (8|M0)               r112.0<1>:d   r89.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (8|M0)               r112.0<1>:d   -126:w                              
        add (8|M0)               r100.0<1>:d   r116.0<1;1,0>:d   r112.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r100.0<1;1,0>:d   254:w               {I@1}
(f0.1)  goto (8|M0)                          L43424                  L43424                
L37568:
        or (8|M0)     (eq)f0.0   null<4>:b     r53.0<1;1,0>:d    r47.0<1;1,0>:d  
(f0.0)  goto (8|M0)                          L43352                  L43352                
L37600:
(W)     mov (1|M0)               r6.14<1>:hf   0.0:hf                             
(W)     mov (1|M0)               r7.7<1>:d     0:w                              
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    8388608:d               {F@1}
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r22.0<1>:d    acc0.0<1;1,0>:d   r36.0<1;1,0>:d  
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        shl (8|M0)               r23.0<1>:d    r22.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r28.0<1>:ud   r22.0<1;1,0>:ud   9:w              
L37712:
(W)     shl (1|M0)               r8.4<1>:d     r7.6<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r8.3<1>:ud    r7.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.1   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r7.7<1>:d     r8.3<0;1,0>:d     r8.4<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r46.0<1>:ud   r8.3<0;0>:ud      r8.4<0;0>:ud      r23.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.7<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f1.1) cmp (8|M0)   (eq)f1.1   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    r7.7<0;1,0>:d    {I@3}
        and (8|M0)               r45.0<1>:d    r6.7<0;1,0>:d     r28.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r14.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.1) cmp (8|M0)  (gt)f1.1   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r8.6<1>:hf    0x1:hf                             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f1.1)  sel (8|M0)               r13.0<1>:uw   r8.6<0;1,0>:uw    0x0:uw              {F@1}
(W)     add (1|M0)               r8.5<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@2}
(f1.0)  sel (8|M0)               r7.0<1>:uw    r8.6<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r120.0<1>:d   r7.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.0   null<1>:uw    r13.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r126.0<1>:d   r7.5<0;1,0>:d                   
        mov (8|M0)               r39.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r93.0<1>:d    r8.5<0;1,0>:d                   
(f0.0)  goto (8|M0)                          L38120                  L38120                
L38056:
(W)     mov (1|M0)               r7.6<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:f     r8.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L37712                                
L38120:
        join (8|M0)                          L43352                                
L38136:
(W)     mov (1|M0)               r6.7<1>:f     8.68805e-44:f                               {I@4}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r67.0<1>:ud   r6.7<0;1,0>:ud    r120.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        sync.nop                             null                             {Compacted,$4.src}
        add3 (8|M0)              r86.0<1>:d    r100.0<1;0>:d     r67.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r102.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r126.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r86.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r72.0<1>:d    r116.0<1;0>:d     r112.0<1;0>:d     r67.0<1>:d      
(f1.1)  goto (8|M0)                          L43280                  L43280                
L38264:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r86.0<1;1,0>:d    -127:w              
(f1.0)  goto (8|M0)                          L40848                  L40848                
L38296:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r86.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (8|M0)                          L40320                  L40320                
L38328:
(W)     mov (1|M0)               r6.7<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r65.0<1>:d    r100.0<1;0>:d     r67.0<1;0>:d      -23:w              
        subb (8|M0)              r103.0<1>:ud  r6.7<0;1,0>:ud    r120.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r103.0<1;1,0>:ud  r65.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r125.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r126.0<1>:ud    {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@1}
(~f1.1) cmp (8|M0)    (gt)f1.1   null<1>:ud    r125.0<1;1,0>:ud  0x0:uw             
(f1.1)  goto (8|M0)                          L38528                  L38528                
L38464:
        add3 (8|M0)              acc0.0<1>:d   r72.0<1;0>:d      -r103.0<1;0>:d    -23:w              
        mov (8|M0)               r32.0<1>:d    0:w                              
        shl (8|M0)               r33.0<1>:d    r23.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L38528                  L40256                
L38528:
        join (8|M0)                          L40256                                
L38544:
        add3 (8|M0)              r104.0<1>:d   r103.0<1;0>:d     -r72.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f0.0   null<1>:d     r104.0<1;1,0>:d   2:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L38688                  L38688                
L38584:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   2:w              
(~f1.1) goto (8|M0)                          L38688                  L38736                
L38616:
        shr (8|M0)               r19.0<1>:ud   r23.0<1;1,0>:ud   1:w              
        mov (8|M0)               r57.0<1>:d    0:w                              
        mov (8|M0)               r53.0<1>:d    0:w                              
        mov (8|M0)               r43.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L38688                  L39696                
L38688:
        join (8|M0)                          L38736                                
L38704:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r104.0<1;1,0>:d   1:w              
(f1.0)  goto (8|M0)                          L38736                  L39640                
L38736:
        join (8|M0)                          L39640                                
L38752:
        add3 (8|M0)              acc0.0<1>:d   r103.0<1;0>:d     -r65.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r31.0<1>:d    acc0.0<1;1,0>:d   63:w               {$3.src}
(f0.1)  goto (8|M0)                          L38832                  L38832                
L38800:
        mov (8|M0)               r83.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L38832                  L38968                
L38832:
        join (8|M0)                          L38968                                
L38848:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r31.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r31.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r31.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r78.0<1>:ud   r23.0<1;1,0>:ud   r31.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r81.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.0)  or (8|M0)                r19.0<1>:d    r78.0<1;1,0>:d    r81.0<1;1,0>:d   {I@2}
        mov (8|M0)               r83.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@1}
L38968:
        join (8|M0)                          L39640                                
L38984:
        add3 (8|M0)              r46.0<1>:d    r103.0<1;0>:d     -r65.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.1   r30.0<1>:d    r46.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L39064                  L39064                
L39032:
        mov (8|M0)               r19.0<1>:d    r23.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L39064                  L39192                
L39064:
        join (8|M0)                          L39192                                
L39080:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r30.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r30.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r30.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r76.0<1>:ud   r23.0<1;1,0>:ud   r30.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r80.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r19.0<1>:d    r76.0<1;1,0>:d    r80.0<1;1,0>:d   {I@2}
L39192:
        join (8|M0)                          L39640                                
L39208:
        and (8|M0)    (ne)f0.1   r79.0<1>:d    r46.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L39288                  L39288                
L39240:
        mov (8|M0)               r96.0<1>:d    -1:w                              
        mov (8|M0)               r112.0<1>:d   -1:w                              
        goto (8|M0)                          L39288                  L39472                
L39288:
        join (8|M0)                          L39472                                
L39304:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r79.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L39408                  L39408                
L39336:
        add (8|M0)               acc0.0<1>:d   r79.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r96.0<1>:d    0:w                              
        shl (8|M0)               r112.0<1>:d   r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L39408                  L39472                
L39408:
        join (8|M0)                          L39472                                
L39424:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r112.0<1>:d   -1:w                              
        shl (8|M0)               r96.0<1>:d    r6.14<0;1,0>:w    r79.0<1;1,0>:d   {F@1}
L39472:
        join (8|M0)                          L39640                                
L39488:
        bfn.0x60 (8|M0)          r75.0<1>:ud   r96.0<1;0>:ud     r6.4<0;0>:ud      r23.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r74.0<1>:ud   r112.0<1;0>:ud    r6.4<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r75.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        shl (8|M0)               r72.0<1>:d    r19.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r43.0<1>:f    r83.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r74.0<1;1,0>:d    0:w               {I@3}
        and (8|M0)               r53.0<1>:d    r72.0<1;1,0>:d    2:w               {Compacted,I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@2}
        mov (8|M0)               r57.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L39640                  L39696                
L39640:
        join (8|M0)                          L39696                                
L39656:
        mov (8|M0)               r57.0<1>:d    0:w                              
        mov (8|M0)               r53.0<1>:d    0:w                              
        mov (8|M0)               r43.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
L39696:
        join (8|M0)                          L40256                                
L39712:
        and (8|M0)    (ne)f1.1   r29.0<1>:d    r104.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L39776                  L39776                
L39744:
        mov (8|M0)               r19.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L39776                  L39904                
L39776:
        join (8|M0)                          L39904                                
L39792:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r29.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r29.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r29.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r70.0<1>:ud   r23.0<1;1,0>:ud   r29.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r78.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r19.0<1>:d    r70.0<1;1,0>:d    r78.0<1;1,0>:d   {I@2}
L39904:
        join (8|M0)                          L40256                                
L39920:
        shl (8|M0)               r22.0<1>:d    r43.0<1;1,0>:d    2:w               {Compacted,F@1}
        and (8|M0)               r22.0<1>:d    r22.0<1;1,0>:d    4:w               {Compacted,I@1}
        bfn.0xFE (8|M0)          r125.0<1>:ud  r22.0<1;0>:ud     r53.0<1;0>:ud     r57.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L40016                  L40016                
L39984:
        mov (8|M0)               r13.0<1>:d    0:w                              
        goto (8|M0)                          L40016                  L40176                
L40016:
        join (8|M0)                          L40176                                
L40032:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r125.0<1;1,0>:ud  0x4:uw             
(~f0.0) goto (8|M0)                          L40096                  L40096                
L40064:
        mov (8|M0)               r13.0<1>:d    1:w                              
        goto (8|M0)                          L40096                  L40176                
L40096:
        join (8|M0)                          L40176                                
L40112:
        and (8|M0)    (ne)f0.0   null<1>:d     r19.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r125.0<1;1,0>:d   4:w              
(f0.0)  sel (8|M0)               r13.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L40176:
        join (8|M0)                          L40256                                
L40192:
        add (8|M0)               r102.0<1>:d   r13.0<1;1,0>:d    r19.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.7<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r102.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r33.0<1>:d    r102.0<1;1,0>:d   0:w              
(f1.1)  sel (8|M0)               r32.0<1>:d    r6.7<0;1,0>:d     0:w               {F@1}
L40256:
        join (8|M0)                          L40320                                
L40272:
        and (8|M0)               r69.0<1>:d    r21.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r23.0<1>:ud   r69.0<1;0>:ud     r32.0<1;0>:ud     r33.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L40320                  L43528                
L40320:
        join (8|M0)                          L40848                                
L40336:
        and (8|M0)    (ne)f1.1   r44.0<1>:d    r67.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L40416                  L40416                
L40368:
        mov (8|M0)               r57.0<1>:d    -1:w                              
        mov (8|M0)               r77.0<1>:d    -1:w                               {$3.src}
        goto (8|M0)                          L40416                  L40608                
L40416:
        join (8|M0)                          L40608                                
L40432:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r44.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L40544                  L40544                
L40464:
        add (8|M0)               acc0.0<1>:d   r44.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r57.0<1>:d    0:w                              
        sync.nop                             null                             {Compacted,$3.src}
        shl (8|M0)               r77.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L40544                  L40608                
L40544:
        join (8|M0)                          L40608                                
L40560:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r77.0<1>:d    -1:w                               {$3.src}
        shl (8|M0)               r57.0<1>:d    r6.14<0;1,0>:w    r44.0<1;1,0>:d   {F@1}
L40608:
        join (8|M0)                          L40848                                
L40624:
        bfn.0x60 (8|M0)          r68.0<1>:ud   r57.0<1;0>:ud     r6.4<0;0>:ud      r23.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r67.0<1>:ud   r77.0<1;0>:ud     r6.4<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r68.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r21.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r67.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    -150:w              
(f0.1)  goto (8|M0)                          L40784                  L40784                
L40736:
(W)     mov (1|M0)               r6.7<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r23.0<1>:f    r6.7<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L40784                  L43528                
L40784:
        join (8|M0)                          L40848                                
L40800:
(W)     mov (1|M0)               r6.7<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r23.0<1>:f    r6.7<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L40848                  L43528                
L40848:
        join (8|M0)                          L43280                                
L40864:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r67.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r101.0<1>:d   r100.0<1;0>:d     r67.0<1;0>:d      -46:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L42960                  L42960                
L40928:
        shl (8|M0)               r76.0<1>:d    r39.0<1;1,0>:d    1:w               {Compacted,$3.src}
        shr (8|M0)               r75.0<1>:ud   r39.0<1;1,0>:ud   31:w              
        shl (8|M0)               r55.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r76.0<1;1,0>:ud   0x4E:uw              {A@1}
        or (8|M0)                r55.0<1>:d    r55.0<1;1,0>:d    r75.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r55.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r55.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L41160                  L41160                
L41032:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r39.0<1;1,0>:d    39:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r93.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L41160                  L41224                
L41080:
        shr (8|M0)               r19.0<1>:ud   r23.0<1;1,0>:ud   1:w              
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r19.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L41160                  L42432                
L41160:
        join (8|M0)                          L41224                                
L41176:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r39.0<1;1,0>:d    38:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r93.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L41224                  L42344                
L41224:
        join (8|M0)                          L42344                                
L41240:
        add (8|M0)               acc0.0<1>:d   -r39.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r109.0<1>:d   -r39.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.0   r46.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L41320                  L41320                
L41288:
        mov (8|M0)               r95.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L41320                  L41456                
L41320:
        join (8|M0)                          L41456                                
L41336:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r46.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r46.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r46.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r64.0<1>:ud   r23.0<1;1,0>:ud   r46.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r111.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r19.0<1>:d    r64.0<1;1,0>:d    r111.0<1;1,0>:d  {I@2}
        mov (8|M0)               r95.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@1}
L41456:
        join (8|M0)                          L42344                                
L41472:
        add (8|M0)               r64.0<1>:d    -r39.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r54.0<1>:d    r64.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L41544                  L41544                
L41512:
        mov (8|M0)               r82.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L41544                  L41680                
L41544:
        join (8|M0)                          L41680                                
L41560:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r54.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r54.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r54.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r62.0<1>:ud   r23.0<1;1,0>:ud   r54.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r125.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r19.0<1>:d    r62.0<1;1,0>:d    r125.0<1;1,0>:d  {I@2}
        mov (8|M0)               r82.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@1}
L41680:
        join (8|M0)                          L42344                                
L41696:
        and (8|M0)    (ne)f0.0   r124.0<1>:d   r64.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L41776                  L41776                
L41728:
        mov (8|M0)               r25.0<1>:d    -1:w                              
        mov (8|M0)               r35.0<1>:d    -1:w                              
        goto (8|M0)                          L41776                  L41960                
L41776:
        join (8|M0)                          L41960                                
L41792:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r124.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L41896                  L41896                
L41824:
        add (8|M0)               acc0.0<1>:d   r124.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        mov (8|M0)               r25.0<1>:d    0:w                              
        shl (8|M0)               r35.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L41896                  L41960                
L41896:
        join (8|M0)                          L41960                                
L41912:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r35.0<1>:d    -1:w                              
        shl (8|M0)               r25.0<1>:d    r6.14<0;1,0>:w    r124.0<1;1,0>:d  {F@1}
L41960:
        join (8|M0)                          L42344                                
L41976:
        bfn.0x60 (8|M0)          r61.0<1>:ud   r25.0<1;0>:ud     r6.4<0;0>:ud      r23.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r60.0<1>:ud   r35.0<1;0>:ud     r6.4<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r61.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.0   r53.0<1>:d    r109.0<1;1,0>:d   63:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r60.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
        mov (8|M0)               r81.0<1>:d    -acc0.0<1;1,0>:d                
(f1.0)  goto (8|M0)                          L42152                  L42152                
L42120:
        mov (8|M0)               r19.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L42152                  L42280                
L42152:
        join (8|M0)                          L42280                                
L42168:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r53.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r53.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r53.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r57.0<1>:ud   r23.0<1;1,0>:ud   r53.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r123.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r19.0<1>:ud   r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r19.0<1>:d    r57.0<1;1,0>:d    r123.0<1;1,0>:d  {I@2}
L42280:
        join (8|M0)                          L42344                                
L42296:
        shl (8|M0)               r56.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r75.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@3}
        and (8|M0)               r42.0<1>:d    r56.0<1;1,0>:d    2:w               {Compacted,I@1}
        mov (8|M0)               r19.0<1>:f    r95.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L42344                  L42432                
L42344:
        join (8|M0)                          L42432                                
L42360:
        shr (8|M0)               r19.0<1>:ud   r23.0<1;1,0>:ud   2:w               {F@1}
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:f    r19.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r19.0<1>:ud   r23.0<1;1,0>:ud   1:w               {F@1}
L42432:
        join (8|M0)                          L42960                                
L42448:
        shl (8|M0)               r76.0<1>:d    r19.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (8|M0)               r89.0<1>:d    r75.0<1;1,0>:d    8388607:d              
        and (8|M0)               r76.0<1>:d    r76.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r43.0<1>:ud   r76.0<1;0>:ud     r42.0<1;0>:ud     r81.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r43.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L42552                  L42552                
L42520:
        mov (8|M0)               r42.0<1>:d    0:w                              
        goto (8|M0)                          L42552                  L42712                
L42552:
        join (8|M0)                          L42712                                
L42568:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r43.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L42632                  L42632                
L42600:
        mov (8|M0)               r42.0<1>:d    1:w                              
        goto (8|M0)                          L42632                  L42712                
L42632:
        join (8|M0)                          L42712                                
L42648:
        and (8|M0)    (ne)f1.1   null<1>:d     r75.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r42.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L42712:
        join (8|M0)                          L42960                                
L42728:
        add (8|M0)               r124.0<1>:d   r89.0<1;1,0>:d    r42.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r117.0<1>:d   r100.0<1;0>:d     r67.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r124.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f1.1)  sel (8|M0)               r110.0<1>:d   r117.0<1;1,0>:d   r101.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (8|M0)                          L42888                  L42888                
L42816:
(~f1.1) sel (8|M0)               r22.0<1>:d    r124.0<1;1,0>:d   0:w              
        and (8|M0)               r116.0<1>:d   r21.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r55.0<1>:d    r110.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r23.0<1>:ud   r116.0<1;0>:ud    r55.0<1;0>:ud     r22.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L42888                  L43528                
L42888:
        join (8|M0)                          L42960                                
L42904:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r21.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r23.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L42960                  L43528                
L42960:
        join (8|M0)                          L43280                                
L42976:
        and (8|M0)    (ne)f0.1   r118.0<1>:d   r67.0<1;1,0>:d    63:w               {F@1}
(f0.1)  goto (8|M0)                          L43040                  L43040                
L43008:
        mov (8|M0)               r29.0<1>:d    -1:w                              
        goto (8|M0)                          L43040                  L43168                
L43040:
        join (8|M0)                          L43168                                
L43056:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r118.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  goto (8|M0)                          L43120                  L43120                
L43088:
        mov (8|M0)               r29.0<1>:d    0:w                              
        goto (8|M0)                          L43120                  L43168                
L43120:
        join (8|M0)                          L43168                                
L43136:
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        shl (8|M0)               r29.0<1>:d    r6.14<0;1,0>:w    r118.0<1;1,0>:d  {F@1}
L43168:
        join (8|M0)                          L43280                                
L43184:
        bfn.0x60 (8|M0)          r41.0<1>:ud   r29.0<1;0>:ud     r6.4<0;0>:ud      r23.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r67.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r115.0<1>:d   r21.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r53.0<1>:d    r101.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r41.0<1>:d    r41.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r23.0<1>:ud   r115.0<1;0>:ud    r53.0<1;0>:ud     r41.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L43280                  L43528                
L43280:
        join (8|M0)                          L43352                                
L43296:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r21.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r23.0<1>:f    r6.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L43352                  L43528                
L43352:
        join (8|M0)                          L43424                                
L43368:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r21.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r23.0<1>:f    r6.7<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L43424                  L43528                
L43424:
        join (8|M0)                          L43496                                
L43440:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r21.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.7<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r23.0<1>:f    r6.7<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L43496                  L43528                
L43496:
        join (8|M0)                          L43528                                
L43512:
        bfn.0xF8 (8|M0)          r23.0<1>:ud   r21.0<1;0>:ud     r6.6<0;0>:ud      r6.5<0>:ud       {F@1} // s0&s1|s2
L43528:
        join (8|M0)                          L43584                                
L43544:
        cmp (8|M0)    (lt)f1.1   null<1>:f     r12.0<1;1,0>:f    0.0:f               {I@7}
        sync.nop                             null                             {Compacted,$3.src}
(f1.1)  sel (8|M0)               r31.0<1>:f    -r23.0<1;1,0>:f   r23.0<1;1,0>:f   {I@2}
L43584:
        join (8|M0)                          L44072                                
L43600:
(W)     mov (1|M0)               f0.0<1>:uw    r6.6<0;1,0>:uw                  
(f0.0)  goto (8|M0)                          L43792                  L43792                
L43632:
        shl (8|M0)               r111.0<1>:d   r11.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r110.0<1>:ud  r11.0<1;1,0>:ud   31:w              
        shl (8|M0)               r40.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r20.0<1>:ud   r111.0<1;1,0>:ud  r6.1<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        mov (8|M0)               r7.0<1>:hf    r31.0<1;1,0>:f                   {F@1}
        or (8|M0)                r40.0<1>:d    r40.0<1;1,0>:d    r110.0<1;1,0>:d  {Compacted,I@2}
        mov (8|M0)               r52.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r51.0<1>:ud   r7.0<1;1,0>:uw                   {F@1}
        add3 (8|M0)              r86.1<2>:ud   r52.0<1;0>:ud     r40.0<1;0>:ud     r6.2<0>:ud       {I@2}
        mov (8|M0)               r86.0<2>:d    r20.0<1;1,0>:d                  
        send.ugm (8|M0)          null     r86     r51:1   0x0            0x040E0B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64.wb.wb
        goto (8|M0)                          L43792                  L43920                
L43792:
        join (8|M0)                          L43920                                
L43808:
        shl (8|M0)               r109.0<1>:d   r11.0<1;1,0>:d    2:w               {Compacted}
        shr (8|M0)               r108.0<1>:ud  r11.0<1;1,0>:ud   30:w              
        shl (8|M0)               r39.0<1>:d    r10.0<1;1,0>:d    2:w               {Compacted}
        addc (8|M0)              r19.0<1>:ud   r109.0<1;1,0>:ud  r6.1<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (8|M0)                r39.0<1>:d    r39.0<1;1,0>:d    r108.0<1;1,0>:d  {Compacted,I@2}
        mov (8|M0)               r50.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        add3 (8|M0)              r76.1<2>:ud   r50.0<1;0>:ud     r39.0<1;0>:ud     r6.2<0>:ud       {I@1}
        mov (8|M0)               r76.0<2>:d    r19.0<1;1,0>:d                  
        send.ugm (8|M0)          null     r76     r31:1   0x0            0x040E0584           {A@1,$3} // wr:2+1, rd:0; store.ugm.d32.a64.wb.wb
L43920:
        join (8|M0)                          L44072                                
L43936:
        addc (8|M0)              r99.0<1>:ud   r11.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r99.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r115.0<1>:ud  acc0.0<1;1,0>:ud  r10.0<1;1,0>:ud 
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r115.0<1;1,0>:d   r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:ud    r115.0<1;1,0>:ud  r4.7<0;1,0>:ud  
(~f1.1) goto (8|M0)                          L44072                  L44072                
L44024:
(f1.1)  sel (8|M0)               r11.0<1>:d    r99.0<1;1,0>:d    r9.0<1;1,0>:d   
(f1.1)  sel (8|M0)               r10.0<1>:d    r115.0<1;1,0>:d   r3.0<1;1,0>:d   
(W)     jmpi                                 L744                                
L44072:
        join (8|M0)                          L44088                                
L44088:
(W)     mov (8|M0)               r112.0<1>:f   r2.0<1;1,0>:f                    {Compacted}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L44112:
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x50:ud                             
L44176:
        shr (8|M0)               r48.0<1>:ud   r119.0<1;1,0>:ud  23:w              
        shr (8|M0)               r49.0<1>:ud   r82.0<1;1,0>:ud   23:w              
        and (8|M0)    (eq)f0.1   r113.0<1>:d   r48.0<1;1,0>:d    255:w               {I@2}
        and (8|M0)               r18.0<1>:d    r82.0<1;1,0>:d    8388607:d              
        and (8|M0)               r100.0<1>:d   r119.0<1;1,0>:d   8388607:d              
        shr (8|M0)               r23.0<1>:ud   r82.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w               {I@4}
        shr (8|M0)               r29.0<1>:ud   r119.0<1;1,0>:ud  31:w              
        and (8|M0)               r98.0<1>:d    r49.0<1;1,0>:d    255:w               {Compacted}
(f1.0)  goto (8|M0)                          L44384                  L44384                
L44328:
(W)     mov (1|M0)               r6.28<2>:b    1:w                              
        add (8|M0)               r85.0<1>:d    r98.0<1;1,0>:d    -r113.0<1;1,0>:d {Compacted,I@3}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@2}
        goto (8|M0)                          L44384                  L44472                
L44384:
        join (8|M0)                          L44472                                
L44400:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L44472                  L50944                
L44432:
(W)     mov (1|M0)               r6.28<2>:b    0:w                              
        add (8|M0)               r85.0<1>:d    r98.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.28<0;1,0>:b                   {I@2}
L44472:
        join (8|M0)                          L50944                                
L44488:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r85.0<1;1,0>:d    0:w               {I@3}
(f1.0)  goto (8|M0)                          L48432                  L48432                
L44520:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r85.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L44680                  L44680                
L44552:
        shr (8|M0)               r28.0<1>:ud   r100.0<1;1,0>:ud  1:w              
        cmp (8|M0)    (eq)f1.1   r47.0<1>:d    r113.0<1;1,0>:d   0:w              
        and (8|M0)               r104.0<1>:d   r119.0<1;1,0>:d   1:w               {Compacted}
        or (8|M0)                r39.0<1>:d    r28.0<1;1,0>:d    4194304:d               {I@3}
        mov (8|M0)               r117.0<1>:d   0:w                              
        mov (8|M0)               r119.0<1>:f   r104.0<1;1,0>:f                  {Compacted,I@3}
        bfn.0xD8 (8|M0)          r118.0<1>:ud  r47.0<1;0>:ud     r28.0<1;0>:ud     r39.0<1>:ud      {I@2} // s0&s1|~s0&s2
        mov (8|M0)               r104.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L44680                  L45376                
L44680:
        join (8|M0)                          L45376                                
L44696:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r85.0<1;1,0>:ud   0x18:uw             
(f1.0)  goto (8|M0)                          L45112                  L45112                
L44728:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r85.0<1;1,0>:d    25:w              
        mov (8|M0)               r104.0<1>:d   r7.0<1;1,0>:ub                  
(f1.1)  goto (8|M0)                          L44872                  L44872                
L44776:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r85.0<1;1,0>:d    25:w              
(~f1.0) goto (8|M0)                          L44872                  L45016                
L44808:
        cmp (8|M0)    (ne)f1.0   r117.0<1>:d   r100.0<1;1,0>:d   0:w              
        mov (8|M0)               r119.0<1>:d   0:w                              
        mov (8|M0)               r118.0<1>:d   0:w                              
        goto (8|M0)                          L44872                  L45376                
L44872:
        join (8|M0)                          L45016                                
L44888:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r85.0<1;1,0>:d    24:w              
(~f1.1) goto (8|M0)                          L45016                  L45016                
L44920:
        shr (8|M0)               r38.0<1>:ud   r119.0<1;1,0>:ud  22:w               {I@6}
        and (8|M0)               r46.0<1>:d    r119.0<1;1,0>:d   4194303:d              
        mov (8|M0)               r118.0<1>:d   0:w                              
        mov (8|M0)               r119.0<1>:f   r104.0<1;1,0>:f                  {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r117.0<1>:d   r46.0<1;1,0>:d    0:w              
        and (8|M0)               r104.0<1>:d   r38.0<1;1,0>:d    1:w               {Compacted,F@1}
        goto (8|M0)                          L45016                  L45376                
L45016:
        join (8|M0)                          L45112                                
L45032:
        cmp (8|M0)    (ne)f1.0   r117.0<1>:d   r119.0<1;1,0>:d   0:w              
        mov (8|M0)               r104.0<1>:d   0:w                              
        mov (8|M0)               r118.0<1>:d   0:w                              
        mov (8|M0)               r119.0<1>:d   0:w                              
        goto (8|M0)                          L45112                  L45376                
L45112:
        join (8|M0)                          L45376                                
L45128:
        add (8|M0)               acc0.0<1>:d   r85.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r85.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w              
        shr (8|M0)               r42.0<1>:ud   r100.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r121.0<1>:d   r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.7<1>:d     -1:w                              
        add (8|M0)               acc0.0<1>:d   -r85.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r12.0<1>:ud   r100.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r41.0<1>:ud   r121.0<1;0>:ud    r6.7<0;0>:ud      r100.0<1>:ud     {I@3} // (s0^s1)&s2
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r40.0<1>:ud   r100.0<1;1,0>:ud  r85.0<1;1,0>:d  
        and (8|M0)               r104.0<1>:d   r12.0<1;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r116.0<1>:d   r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(f1.0)  mov (8|M0)               r116.0<1>:d   0:w                              
        cmp (8|M0)    (ne)f1.1   r117.0<1>:d   r41.0<1;1,0>:d    0:w              
        mov (8|M0)               r119.0<1>:f   r104.0<1;1,0>:f                  {Compacted,I@4}
        or (8|M0)                r118.0<1>:d   r40.0<1;1,0>:d    r116.0<1;1,0>:d  {Compacted,I@2}
        and (8|M0)               r104.0<1>:d   r42.0<1;1,0>:d    1:w               {Compacted,F@1}
L45376:
        join (8|M0)                          L48432                                
L45392:
        cmp (8|M0)    (ne)f1.0   r22.0<1>:d    r117.0<1;1,0>:d   0:w               {I@4}
        shl (8|M0)               r19.0<1>:d    r118.0<1;1,0>:d   3:w               {Compacted,I@4}
        shl (8|M0)               r45.0<1>:d    r119.0<1;1,0>:d   2:w               {Compacted}
        shl (8|M0)               r44.0<1>:d    r104.0<1;1,0>:d   1:w               {Compacted,I@5}
        mov (8|M0)               r22.0<1>:d    -r22.0<1;1,0>:d                  {I@4}
        or (8|M0)                r19.0<1>:d    r19.0<1;1,0>:d    r45.0<1;1,0>:d   {Compacted,I@3}
        shl (8|M0)               r21.0<1>:d    r18.0<1;1,0>:d    3:w               {Compacted}
        bfn.0xFE (8|M0)          r127.0<1>:ud  r19.0<1;0>:ud     r44.0<1;0>:ud     r22.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r21.0<1;1,0>:ud   r127.0<1;1,0>:ud {I@1}
(f1.1)  goto (8|M0)                          L45560                  L45560                
L45512:
        add (8|M0)               r24.0<1>:d    r21.0<1;1,0>:d    -r127.0<1;1,0>:d {Compacted}
        and (8|M0)               r120.0<1>:d   r24.0<1;1,0>:d    7:w               {Compacted,I@1}
        shr (8|M0)               r20.0<1>:ud   r24.0<1;1,0>:ud   3:w              
        goto (8|M0)                          L45560                  L48040                
L45560:
        join (8|M0)                          L48040                                
L45576:
        or (8|M0)                acc0.0<1>:d   r21.0<1;1,0>:d    67108864:d              
        add (8|M0)               r74.0<1>:d    acc0.0<1;1,0>:d   -r127.0<1;1,0>:d
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    33554432:d               {I@1}
(~f1.0) goto (8|M0)                          L47624                  L47624                
L45640:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    16777216:d              
(~f1.1) goto (8|M0)                          L47576                  L47576                
L45672:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    8388608:d              
(~f1.0) goto (8|M0)                          L47528                  L47528                
L45704:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L47480                  L47480                
L45736:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L47432                  L47432                
L45768:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    1048576:d              
(~f1.1) goto (8|M0)                          L47384                  L47384                
L45800:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    524288:d              
(~f1.0) goto (8|M0)                          L47336                  L47336                
L45832:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    262144:d              
(~f1.1) goto (8|M0)                          L47288                  L47288                
L45864:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    131072:d              
(~f1.0) goto (8|M0)                          L47240                  L47240                
L45896:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L47192                  L47192                
L45928:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L47144                  L47144                
L45960:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    16384:w              
(~f1.1) goto (8|M0)                          L47096                  L47096                
L45992:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    8192:w              
(~f1.0) goto (8|M0)                          L47048                  L47048                
L46024:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    4096:w              
(~f1.1) goto (8|M0)                          L47000                  L47000                
L46056:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    2048:w              
(~f1.0) goto (8|M0)                          L46952                  L46952                
L46088:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L46904                  L46904                
L46120:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L46856                  L46856                
L46152:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    256:w              
(~f1.1) goto (8|M0)                          L46808                  L46808                
L46184:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    128:w              
(~f1.0) goto (8|M0)                          L46760                  L46760                
L46216:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    64:w              
(~f1.1) goto (8|M0)                          L46712                  L46712                
L46248:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    32:w              
(~f1.0) goto (8|M0)                          L46664                  L46664                
L46280:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L46616                  L46616                
L46312:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L46568                  L46568                
L46344:
        and (8|M0)    (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    4:w              
(~f1.1) goto (8|M0)                          L46520                  L46520                
L46376:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L46472                  L46472                
L46408:
        and (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
(f1.0)  sel (8|M0)               r77.0<1>:d    r6.14<0;1,0>:w    25:w               {F@1}
        goto (8|M0)                          L46472                  L47656                
L46472:
        join (8|M0)                          L46520                                
L46488:
        mov (8|M0)               r77.0<1>:d    24:w                              
        goto (8|M0)                          L46520                  L47656                
L46520:
        join (8|M0)                          L46568                                
L46536:
        mov (8|M0)               r77.0<1>:d    23:w                              
        goto (8|M0)                          L46568                  L47656                
L46568:
        join (8|M0)                          L46616                                
L46584:
        mov (8|M0)               r77.0<1>:d    22:w                              
        goto (8|M0)                          L46616                  L47656                
L46616:
        join (8|M0)                          L46664                                
L46632:
        mov (8|M0)               r77.0<1>:d    21:w                              
        goto (8|M0)                          L46664                  L47656                
L46664:
        join (8|M0)                          L46712                                
L46680:
        mov (8|M0)               r77.0<1>:d    20:w                              
        goto (8|M0)                          L46712                  L47656                
L46712:
        join (8|M0)                          L46760                                
L46728:
        mov (8|M0)               r77.0<1>:d    19:w                              
        goto (8|M0)                          L46760                  L47656                
L46760:
        join (8|M0)                          L46808                                
L46776:
        mov (8|M0)               r77.0<1>:d    18:w                              
        goto (8|M0)                          L46808                  L47656                
L46808:
        join (8|M0)                          L46856                                
L46824:
        mov (8|M0)               r77.0<1>:d    17:w                              
        goto (8|M0)                          L46856                  L47656                
L46856:
        join (8|M0)                          L46904                                
L46872:
        mov (8|M0)               r77.0<1>:d    16:w                              
        goto (8|M0)                          L46904                  L47656                
L46904:
        join (8|M0)                          L46952                                
L46920:
        mov (8|M0)               r77.0<1>:d    15:w                              
        goto (8|M0)                          L46952                  L47656                
L46952:
        join (8|M0)                          L47000                                
L46968:
        mov (8|M0)               r77.0<1>:d    14:w                              
        goto (8|M0)                          L47000                  L47656                
L47000:
        join (8|M0)                          L47048                                
L47016:
        mov (8|M0)               r77.0<1>:d    13:w                              
        goto (8|M0)                          L47048                  L47656                
L47048:
        join (8|M0)                          L47096                                
L47064:
        mov (8|M0)               r77.0<1>:d    12:w                              
        goto (8|M0)                          L47096                  L47656                
L47096:
        join (8|M0)                          L47144                                
L47112:
        mov (8|M0)               r77.0<1>:d    11:w                              
        goto (8|M0)                          L47144                  L47656                
L47144:
        join (8|M0)                          L47192                                
L47160:
        mov (8|M0)               r77.0<1>:d    10:w                              
        goto (8|M0)                          L47192                  L47656                
L47192:
        join (8|M0)                          L47240                                
L47208:
        mov (8|M0)               r77.0<1>:d    9:w                              
        goto (8|M0)                          L47240                  L47656                
L47240:
        join (8|M0)                          L47288                                
L47256:
        mov (8|M0)               r77.0<1>:d    8:w                              
        goto (8|M0)                          L47288                  L47656                
L47288:
        join (8|M0)                          L47336                                
L47304:
        mov (8|M0)               r77.0<1>:d    7:w                              
        goto (8|M0)                          L47336                  L47656                
L47336:
        join (8|M0)                          L47384                                
L47352:
        mov (8|M0)               r77.0<1>:d    6:w                              
        goto (8|M0)                          L47384                  L47656                
L47384:
        join (8|M0)                          L47432                                
L47400:
        mov (8|M0)               r77.0<1>:d    5:w                              
        goto (8|M0)                          L47432                  L47656                
L47432:
        join (8|M0)                          L47480                                
L47448:
        mov (8|M0)               r77.0<1>:d    4:w                              
        goto (8|M0)                          L47480                  L47656                
L47480:
        join (8|M0)                          L47528                                
L47496:
        mov (8|M0)               r77.0<1>:d    3:w                              
        goto (8|M0)                          L47528                  L47656                
L47528:
        join (8|M0)                          L47576                                
L47544:
        mov (8|M0)               r77.0<1>:d    2:w                              
        goto (8|M0)                          L47576                  L47656                
L47576:
        join (8|M0)                          L47624                                
L47592:
        mov (8|M0)               r77.0<1>:d    1:w                              
        goto (8|M0)                          L47624                  L47656                
L47624:
        join (8|M0)                          L47656                                
L47640:
        mov (8|M0)               r77.0<1>:d    0:w                              
L47656:
        join (8|M0)                          L48040                                
L47672:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r85.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  sel (8|M0)               r7.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r19.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        or (8|M0)     (ne)f1.0   null<1>:uw    r19.0<1;1,0>:uw   r7.0<1;1,0>:uw   {I@1}
(f1.0)  goto (8|M0)                          L47968                  L47968                
L47768:
        add (8|M0)               r85.0<1>:d    r77.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r98.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r98.0<1;1,0>:ud   r85.0<1;1,0>:ud  {I@2}
        not (8|M0)               acc2.0<1>:d   r77.0<1;1,0>:d                  
        and (8|M0)               r34.0<1>:d    r82.0<1;1,0>:d    -2147483648:d              
        add (8|M0)               acc2.0<1>:d   r98.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f1.0) mov (8|M0)               r85.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r83.0<1>:d    acc2.0<1;1,0>:d   23:w              
        shl (8|M0)               r85.0<1>:d    r74.0<1;1,0>:d    r85.0<1;1,0>:d   {Compacted,I@2}
(~f1.0) mov (8|M0)               r83.0<1>:d    0:w                              
        shr (8|M0)               r85.0<1>:ud   r85.0<1;1,0>:ud   3:w               {I@2}
        and (8|M0)               r85.0<1>:d    r85.0<1;1,0>:d    8388607:d               {I@1}
        bfn.0xFE (8|M0)          r85.0<1>:ud   r34.0<1;0>:ud     r83.0<1;0>:ud     r85.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L47968                  L51056                
L47968:
        join (8|M0)                          L48040                                
L47984:
        shr (8|M0)               r42.0<1>:ud   r74.0<1;1,0>:ud   2:w              
        shl (8|M0)               r41.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r98.0<1>:d    r98.0<1;1,0>:d    -1:w               {Compacted}
        and (8|M0)               r20.0<1>:d    r42.0<1;1,0>:d    8388607:d               {I@3}
        and (8|M0)               r120.0<1>:d   r41.0<1;1,0>:d    6:w               {Compacted,I@3}
L48040:
        join (8|M0)                          L48432                                
L48056:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   0:w               {I@2}
(f0.1)  goto (8|M0)                          L48248                  L48248                
L48088:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r120.0<1;1,0>:ud  0x4:uw             
(f1.1)  goto (8|M0)                          L48200                  L48200                
L48120:
        and (8|M0)    (ne)f1.1   null<1>:d     r20.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r125.0<1>:d   r6.14<0;1,0>:w    0:w               {F@1}
        goto (8|M0)                          L48200                  L48280                
L48200:
        join (8|M0)                          L48248                                
L48216:
        mov (8|M0)               r125.0<1>:d   1:w                              
        goto (8|M0)                          L48248                  L48280                
L48248:
        join (8|M0)                          L48280                                
L48264:
        mov (8|M0)               r125.0<1>:d   0:w                              
L48280:
        join (8|M0)                          L48432                                
L48296:
        add (8|M0)               r124.0<1>:d   r20.0<1;1,0>:d    r125.0<1;1,0>:d  {Compacted,I@2}
        and (8|M0)               r33.0<1>:d    r82.0<1;1,0>:d    -2147483648:d              
        cmp (8|M0)    (gt)f1.1   r40.0<1>:ud   r124.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r124.0<1;1,0>:ud  0x7FFFFF:ud             
        add3 (8|M0)              acc0.0<1>:d   r98.0<1;0>:d      -r40.0<1;0>:d     0:w               {I@2}
(~f1.0) sel (8|M0)               r37.0<1>:d    r124.0<1;1,0>:d   0:w              
        shl (8|M0)               r123.0<1>:d   acc0.0<1;1,0>:d   23:w              
        bfn.0xFE (8|M0)          r85.0<1>:ud   r33.0<1;0>:ud     r123.0<1;0>:ud    r37.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L48432                  L51056                
L48432:
        join (8|M0)                          L50944                                
L48448:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    r100.0<1;1,0>:d 
(W)     mov (1|M0)               r8.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r8.3<1>:d     8388608:d                              
(f0.1)  goto (8|M0)                          L50864                  L50864                
L48504:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r18.0<1;1,0>:ud   r100.0<1;1,0>:ud
(f0.1)  goto (8|M0)                          L48680                  L48680                
L48536:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r113.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L48600                  L48600                
L48568:
        add (8|M0)               r81.0<1>:d    r100.0<1;1,0>:d   -r18.0<1;1,0>:d  {Compacted}
        mov (8|M0)               r23.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L48600                  L48784                
L48600:
        join (8|M0)                          L48680                                
L48616:
        or (8|M0)                acc0.0<1>:d   r18.0<1;1,0>:d    8388608:d              
        add (8|M0)               r126.0<1>:d   acc0.0<1;1,0>:d   -r100.0<1;1,0>:d
        bfn.0xF8 (8|M0)          r85.0<1>:ud   r82.0<1;0>:ud     r8.6<0;0>:ud      r126.0<1>:ud     {A@1} // s0&s1|s2
        goto (8|M0)                          L48680                  L51056                
L48680:
        join (8|M0)                          L48784                                
L48696:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w              
        add (8|M0)               r81.0<1>:d    r18.0<1;1,0>:d    -r100.0<1;1,0>:d {Compacted}
(~f1.0) goto (8|M0)                          L48784                  L48784                
L48736:
        and (8|M0)               r39.0<1>:d    r82.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r85.0<1>:ud   r39.0<1;0>:ud     r81.0<1;0>:ud     r8.3<0>:ud       {I@1} // s0|s1|s2
        goto (8|M0)                          L48784                  L51056                
L48784:
        join (8|M0)                          L50864                                
L48800:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    4194304:d              
(~f0.1) goto (8|M0)                          L50576                  L50576                
L48832:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    2097152:d              
(~f1.1) goto (8|M0)                          L50528                  L50528                
L48864:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    1048576:d              
(~f1.0) goto (8|M0)                          L50480                  L50480                
L48896:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    524288:d              
(~f0.1) goto (8|M0)                          L50432                  L50432                
L48928:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    262144:d              
(~f1.1) goto (8|M0)                          L50384                  L50384                
L48960:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    131072:d              
(~f1.0) goto (8|M0)                          L50336                  L50336                
L48992:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    65536:d              
(~f0.1) goto (8|M0)                          L50288                  L50288                
L49024:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    0x8000:uw             
(~f1.1) goto (8|M0)                          L50240                  L50240                
L49056:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    16384:w              
(~f1.0) goto (8|M0)                          L50192                  L50192                
L49088:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    8192:w              
(~f0.1) goto (8|M0)                          L50144                  L50144                
L49120:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    4096:w              
(~f1.1) goto (8|M0)                          L50096                  L50096                
L49152:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    2048:w              
(~f1.0) goto (8|M0)                          L50048                  L50048                
L49184:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    1024:w              
(~f0.1) goto (8|M0)                          L50000                  L50000                
L49216:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    512:w              
(~f1.1) goto (8|M0)                          L49952                  L49952                
L49248:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    256:w              
(~f1.0) goto (8|M0)                          L49904                  L49904                
L49280:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    128:w              
(~f0.1) goto (8|M0)                          L49856                  L49856                
L49312:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    64:w              
(~f1.1) goto (8|M0)                          L49808                  L49808                
L49344:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    32:w              
(~f1.0) goto (8|M0)                          L49760                  L49760                
L49376:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    16:w              
(~f0.1) goto (8|M0)                          L49712                  L49712                
L49408:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    8:w              
(~f1.1) goto (8|M0)                          L49664                  L49664                
L49440:
        and (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    4:w              
(~f1.0) goto (8|M0)                          L49616                  L49616                
L49472:
        and (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L49568                  L49568                
L49504:
        and (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
(f1.1)  sel (8|M0)               r85.0<1>:d    r6.14<0;1,0>:w    22:w               {F@1}
        goto (8|M0)                          L49568                  L50608                
L49568:
        join (8|M0)                          L49616                                
L49584:
        mov (8|M0)               r85.0<1>:d    21:w                              
        goto (8|M0)                          L49616                  L50608                
L49616:
        join (8|M0)                          L49664                                
L49632:
        mov (8|M0)               r85.0<1>:d    20:w                              
        goto (8|M0)                          L49664                  L50608                
L49664:
        join (8|M0)                          L49712                                
L49680:
        mov (8|M0)               r85.0<1>:d    19:w                              
        goto (8|M0)                          L49712                  L50608                
L49712:
        join (8|M0)                          L49760                                
L49728:
        mov (8|M0)               r85.0<1>:d    18:w                              
        goto (8|M0)                          L49760                  L50608                
L49760:
        join (8|M0)                          L49808                                
L49776:
        mov (8|M0)               r85.0<1>:d    17:w                              
        goto (8|M0)                          L49808                  L50608                
L49808:
        join (8|M0)                          L49856                                
L49824:
        mov (8|M0)               r85.0<1>:d    16:w                              
        goto (8|M0)                          L49856                  L50608                
L49856:
        join (8|M0)                          L49904                                
L49872:
        mov (8|M0)               r85.0<1>:d    15:w                              
        goto (8|M0)                          L49904                  L50608                
L49904:
        join (8|M0)                          L49952                                
L49920:
        mov (8|M0)               r85.0<1>:d    14:w                              
        goto (8|M0)                          L49952                  L50608                
L49952:
        join (8|M0)                          L50000                                
L49968:
        mov (8|M0)               r85.0<1>:d    13:w                              
        goto (8|M0)                          L50000                  L50608                
L50000:
        join (8|M0)                          L50048                                
L50016:
        mov (8|M0)               r85.0<1>:d    12:w                              
        goto (8|M0)                          L50048                  L50608                
L50048:
        join (8|M0)                          L50096                                
L50064:
        mov (8|M0)               r85.0<1>:d    11:w                              
        goto (8|M0)                          L50096                  L50608                
L50096:
        join (8|M0)                          L50144                                
L50112:
        mov (8|M0)               r85.0<1>:d    10:w                              
        goto (8|M0)                          L50144                  L50608                
L50144:
        join (8|M0)                          L50192                                
L50160:
        mov (8|M0)               r85.0<1>:d    9:w                              
        goto (8|M0)                          L50192                  L50608                
L50192:
        join (8|M0)                          L50240                                
L50208:
        mov (8|M0)               r85.0<1>:d    8:w                              
        goto (8|M0)                          L50240                  L50608                
L50240:
        join (8|M0)                          L50288                                
L50256:
        mov (8|M0)               r85.0<1>:d    7:w                              
        goto (8|M0)                          L50288                  L50608                
L50288:
        join (8|M0)                          L50336                                
L50304:
        mov (8|M0)               r85.0<1>:d    6:w                              
        goto (8|M0)                          L50336                  L50608                
L50336:
        join (8|M0)                          L50384                                
L50352:
        mov (8|M0)               r85.0<1>:d    5:w                              
        goto (8|M0)                          L50384                  L50608                
L50384:
        join (8|M0)                          L50432                                
L50400:
        mov (8|M0)               r85.0<1>:d    4:w                              
        goto (8|M0)                          L50432                  L50608                
L50432:
        join (8|M0)                          L50480                                
L50448:
        mov (8|M0)               r85.0<1>:d    3:w                              
        goto (8|M0)                          L50480                  L50608                
L50480:
        join (8|M0)                          L50528                                
L50496:
        mov (8|M0)               r85.0<1>:d    2:w                              
        goto (8|M0)                          L50528                  L50608                
L50528:
        join (8|M0)                          L50576                                
L50544:
        mov (8|M0)               r85.0<1>:d    1:w                              
        goto (8|M0)                          L50576                  L50608                
L50576:
        join (8|M0)                          L50608                                
L50592:
        mov (8|M0)               r85.0<1>:d    0:w                              
L50608:
        join (8|M0)                          L50864                                
L50624:
        add (8|M0)               r27.0<1>:d    r85.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r98.0<1;1,0>:ud   r27.0<1;1,0>:ud  {I@1}
(f1.1)  goto (8|M0)                          L50720                  L50720                
L50664:
        add (8|M0)               acc0.0<1>:d   r98.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r25.0<1>:d    0:w                              
        shl (8|M0)               r26.0<1>:d    r81.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L50720                  L50808                
L50720:
        join (8|M0)                          L50808                                
L50736:
        not (8|M0)               acc0.0<1>:d   r85.0<1;1,0>:d                  
        shl (8|M0)               r37.0<1>:d    r81.0<1;1,0>:d    r27.0<1;1,0>:d   {Compacted}
        add (8|M0)               acc0.0<1>:d   r98.0<1;1,0>:d    acc0.0<1;1,0>:d 
        and (8|M0)               r26.0<1>:d    r37.0<1;1,0>:d    8388607:d               {I@2}
        shl (8|M0)               r25.0<1>:d    acc0.0<1;1,0>:d   23:w              
L50808:
        join (8|M0)                          L50864                                
L50824:
        shl (8|M0)               r36.0<1>:d    r23.0<1;1,0>:d    31:w               {Compacted}
        bfn.0xFE (8|M0)          r85.0<1>:ud   r36.0<1;0>:ud     r25.0<1;0>:ud     r26.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L50864                  L51056                
L50864:
        join (8|M0)                          L50944                                
L50880:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w              
        bfn.0xF8 (8|M0)          r32.0<1>:ud   r82.0<1;0>:ud     r8.6<0;0>:ud      r8.3<0>:ud       // s0&s1|s2
(f1.0)  sel (8|M0)               r85.0<1>:f    r32.0<1;1,0>:f    0.0:f               {I@1}
        goto (8|M0)                          L50944                  L51056                
L50944:
        join (8|M0)                          L51056                                
L50960:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r18.0<1;1,0>:ud   r100.0<1;1,0>:ud
        add (8|M0)               acc0.0<1>:d   r100.0<1;1,0>:d   -r18.0<1;1,0>:d 
        add (8|M0)               r7.0<1>:d     r18.0<1;1,0>:d    -r100.0<1;1,0>:d {Compacted}
(f0.1)  sel (8|M0)               acc2.0<1>:d   r23.0<1;1,0>:d    r29.0<1;1,0>:d  
(~f0.1) mov (8|M0)               r7.0<1>:d     acc0.0<1;1,0>:d                 
        shl (8|M0)               r122.0<1>:d   acc2.0<1;1,0>:d   31:w              
        or (8|M0)                r85.0<1>:d    r122.0<1;1,0>:d   r7.0<1;1,0>:d    {Compacted,A@1}
L51056:
        join (8|M0)                          L51072                                
L51072:
        mov (8|M0)               r110.0<1>:f   r85.0<1;1,0>:f                   {Compacted,I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r8.4                             {A@1}
L51128:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
