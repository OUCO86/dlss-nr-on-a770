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
(W)     mov (8|M0)               r2.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r2.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r99.0<1>:ud   r4.3<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r121.0<1>:d   r1.0<1;1,0>:uw                  
(W)     mov (1|M0)               r98.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        addc (8|M0)              r127.0<1>:ud  r98.0<0;1,0>:ud   r121.0<1;1,0>:ud {AccWrEn,Compacted,I@1}
        add (8|M0)               r126.0<1>:ud  acc0.0<1;1,0>:ud  r99.0<0;1,0>:ud 
        addc (8|M0)              r8.0<1>:ud    r127.0<1;1,0>:ud  r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r8.0<1;1,0>:ud    r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud  r126.0<1;1,0>:ud {$1.dst}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r3.0<1;1,0>:d     r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:ud    r3.0<1;1,0>:ud    r4.7<0;1,0>:ud  
(~f1.1) goto (8|M0)                          L43648                  L43648                
L496:
(W)     cmp (8|M0)    (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     0:w               {$2.dst}
(W)     cmp (8|M0)    (eq)f1.0   null<1>:d     r5.1<0;1,0>:d     0:w              
(W)     and (1|M0)               r7.3<1>:d     r5.3<0;1,0>:d     -2:w               {Compacted,$3.dst}
(W)     and (1|M0)               r7.6<1>:d     r5.3<0;1,0>:d     -3:w              
(W)     mov (1|M0)               r5.14<1>:uw   f1.1<0;1,0>:uw                   {Compacted}
(W)     cmp (8|M0)    (eq)f0.1   null<1>:d     r7.3<0;1,0>:d     2:w               {I@3}
(W)     mov (1|M0)               r5.15<1>:uw   f1.0<0;1,0>:uw                  
(W)     cmp (8|M0)    (eq)f0.0   null<1>:d     r7.6<0;1,0>:d     1:w               {I@4}
(W)     cmp (8|M0)    (eq)f1.1   null<1>:d     r5.3<0;1,0>:d     4:w              
(W)     cmp (8|M0)    (eq)f1.0   null<1>:d     r5.6<0;1,0>:d     0:w              
(W)     mov (2|M0)               r7.4<1>:f     r6.4<1;1,0>:f                   
(W)     mov (1|M0)               r6.1<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r7.7<1>:d     -1:w                              
        mov (8|M0)               r10.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r9.0<1>:f     r3.0<1;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r7.6<1>:uw    f0.1<0;1,0>:uw                  
(W)     mov (1|M0)               r7.7<1>:uw    f0.0<0;1,0>:uw                  
(W)     mov (1|M0)               r7.12<1>:uw   f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r7.13<1>:uw   f1.0<0;1,0>:uw                  
L768:
(W)     mov (1|M0)               f0.1<1>:uw    r5.14<0;1,0>:uw                  {I@7}
(~f0.1) goto (8|M0)                          L832                  L832                
L800:
        mov (8|M0)               r70.0<1>:d    -1:w                              
        goto (8|M0)                          L832                  L1192                
L832:
        join (8|M0)                          L1192                                
L848:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r6.3<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
        mov (8|M0)               r114.0<1>:f   r10.0<1;1,0>:ud                  {Compacted,F@3}
(W)     mov (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r6.4<1>:f     r6.3<0;1,0>:f                    {$7}
(W)     add (1|M0)               r6.5<1>:d     r5.0<0;1,0>:d     -r6.2<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.2<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r49.0<1>:ud   r114.0<1;1,0>:f                  {F@2}
        sync.nop                             null                             {Compacted,$7.dst}
(W)     mad (1|M0)               r6.2<1>:f     r6.4<0;0>:f       r6.2<0;0>:f       r6.4<0>:f        {F@1}
        add (8|M0)               r49.0<1>:d    r10.0<1;1,0>:d    -r49.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               r22.0<1>:f    r114.0<1;1,0>:f   r6.2<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r6.4<1>:f     r6.5<0;1,0>:ud                  
        mov (8|M0)               r44.0<1>:ud   r22.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r37.0<1>:f    r49.0<1;1,0>:ud                  {Compacted,I@2}
        mov (8|M0)               r19.0<1>:f    r44.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r114.0<1;0>:f     r19.0<1;0>:f      -r6.3<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r37.0<1;0>:f      r19.0<1;0>:f      -r6.4<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r103.0<1>:ud  r104.0<1;1,0>:f                  {A@1}
        sync.nop                             null                             {Compacted,$5.src}
        add (8|M0)               r66.0<1>:d    r103.0<1;1,0>:d   r44.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r66.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r66.0<1>:d    r66.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (8|M0)               r66.0<1>:d    r10.0<1;1,0>:d    -r66.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f1.0   r118.0<1>:ud  r66.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (8|M0)              r70.0<1>:d    r103.0<1;0>:d     r44.0<1;0>:d      -r118.0<1>:d     {I@1}
L1192:
        join (8|M0)                          L43648                                
L1208:
(W)     mov (1|M0)               f0.0<1>:uw    r5.15<0;1,0>:uw                 
(W)     mul (8|M0)               acc0.0<1>:d   r70.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@3}
        mach (8|M0)              r117.0<1>:d   r70.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (8|M0)               r95.0<1>:d    r10.0<1;1,0>:d    -r117.0<1;1,0>:d {Compacted,I@1}
(~f0.0) goto (8|M0)                          L1296                  L1296                
L1264:
        mov (8|M0)               r89.0<1>:d    -1:w                              
        goto (8|M0)                          L1296                  L1664                
L1296:
        join (8|M0)                          L1664                                
L1312:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r6.3<1>:f     r5.1<0;1,0>:ud                   {A@1}
        mov (8|M0)               r29.0<1>:f    r70.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r6.4<1>:f     r6.3<0;1,0>:f                    {$8}
(W)     add (1|M0)               r6.5<1>:d     r5.1<0;1,0>:d     -r6.2<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.2<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r87.0<1>:ud   r29.0<1;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$8.dst}
(W)     mad (1|M0)               r6.2<1>:f     r6.4<0;0>:f       r6.2<0;0>:f       r6.4<0>:f        {F@1}
        add (8|M0)               r87.0<1>:d    r70.0<1;1,0>:d    -r87.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               r36.0<1>:f    r29.0<1;1,0>:f    r6.2<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r6.4<1>:f     r6.5<0;1,0>:ud                  
        mov (8|M0)               r53.0<1>:ud   r36.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r52.0<1>:f    r87.0<1;1,0>:ud                  {Compacted,I@2}
        mov (8|M0)               r38.0<1>:f    r53.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r29.0<1;0>:f      r38.0<1;0>:f      -r6.3<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r52.0<1;0>:f      r38.0<1;0>:f      -r6.4<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r113.0<1>:f   r6.2<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r115.0<1>:ud  r113.0<1;1,0>:f                  {A@1}
        sync.nop                             null                             {Compacted,$6.src}
        add (8|M0)               r68.0<1>:d    r115.0<1;1,0>:d   r53.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r68.0<1;1,0>:d    r5.2<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r68.0<1>:d    r68.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
        add (8|M0)               r68.0<1>:d    r70.0<1;1,0>:d    -r68.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f0.1   r114.0<1>:ud  r68.0<1;1,0>:ud   r5.1<0;1,0>:ud   {I@1}
        add3 (8|M0)              r89.0<1>:d    r115.0<1;0>:d     r53.0<1;0>:d      -r114.0<1>:d     {I@1}
L1664:
        join (8|M0)                          L43648                                
L1680:
(W)     mul (8|M0)               acc0.0<1>:d   r89.0<1;1,0>:d    r5.2<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r113.0<1>:d   r89.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r89.0<1;1,0>:ud   r5.4<0;1,0>:uw  
        mach (8|M0)              r110.0<1>:ud  r89.0<1;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,Compacted}
        shr (8|M0)               r112.0<1>:ud  r95.0<1;1,0>:ud   5:w              
        mov (8|M0)               r109.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        add (8|M0)               r67.0<1>:d    r70.0<1;1,0>:d    -r113.0<1;1,0>:d {Compacted,I@5}
        addc (8|M0)              r113.0<1>:ud  r109.0<1;1,0>:ud  r112.0<1;1,0>:ud {AccWrEn,Compacted,I@2}
(W)     mov (1|M0)               f1.1<1>:uw    r7.6<0;1,0>:uw                  
        add (8|M0)               r112.0<1>:ud  acc0.0<1;1,0>:ud  r110.0<1;1,0>:ud
        mul (8|M0)               acc0.0<1>:ud  r113.0<1;1,0>:ud  r5.2<0;1,0>:uw   {I@3}
        mach (8|M0)              r114.0<1>:ud  r113.0<1;1,0>:ud  r5.1<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r113.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r5.1<0;1,0>:ud    r112.0<2;1,0>:uw {I@4}
        mach (8|M0)              r111.0<1>:d   r5.1<0;1,0>:ud    r112.0<1;1,0>:d 
        addc (8|M0)              r126.0<1>:ud  r113.0<1;1,0>:ud  r67.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        add (8|M0)               r21.0<1>:d    r114.0<1;1,0>:d   r111.0<1;1,0>:d  {Compacted,I@2}
        shl (8|M0)               r112.0<1>:d   r126.0<1;1,0>:d   7:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$4.src}
        add (8|M0)               r81.0<1>:ud   acc0.0<1;1,0>:ud  r21.0<1;1,0>:ud  {I@2}
        shr (8|M0)               r126.0<1>:ud  r126.0<1;1,0>:ud  25:w              
        addc (8|M0)              r127.0<1>:ud  r112.0<1;1,0>:ud  r5.4<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        shl (8|M0)               r81.0<1>:d    r81.0<1;1,0>:d    7:w               {Compacted,I@3}
        shl (8|M0)               r112.0<1>:d   r95.0<1;1,0>:d    2:w               {Compacted}
        or (8|M0)                r81.0<1>:d    r81.0<1;1,0>:d    r126.0<1;1,0>:d  {Compacted,I@2}
        and (8|M0)               r112.0<1>:d   r112.0<1;1,0>:d   124:w               {Compacted,I@2}
        add3 (8|M0)              r35.0<1>:ud   acc0.0<1;0>:ud    r81.0<1;0>:ud     r5.5<0>:ud       {I@2}
        addc (8|M0)              r126.0<1>:ud  r127.0<1;1,0>:ud  r112.0<1;1,0>:ud {AccWrEn,Compacted,I@2}
        mov (8|M0)               r110.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        add (8|M0)               r68.1<2>:ud   r110.0<1;1,0>:ud  r35.0<1;1,0>:ud  {Compacted,I@1}
        mov (8|M0)               r68.0<2>:d    r126.0<1;1,0>:d                 
        send.ugm (8|M0)          r11      r68     null:0  0x0            0x04180580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64.ca.ca
(~f1.1) goto (8|M0)                          L30264                  L30264                
L2064:
        mov (8|M0)               r12.0<1>:hf   r11.0<1;1,0>:f                   {$6.dst}
        mov (8|M0)               r12.0<1>:f    r12.0<1;1,0>:hf                  {F@1}
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   r12.0<1;1,0>:f    -4.0:f               {Compacted,F@1}
        sel (8|M0)    (lt)f0.0   r16.0<1>:f    acc0.0<1;1,0>:f   4.0:f               {Compacted}
        and (8|M0)    (ne)f0.0   r13.0<1>:d    r16.0<1;1,0>:d    8388607:d               {F@1}
        shr (8|M0)               r15.0<1>:ud   r16.0<1;1,0>:ud   23:w              
        and (8|M0)               r14.0<1>:d    r15.0<1;1,0>:d    255:w               {Compacted,I@1}
        cmp (8|M0)    (ne)f1.0   null<1>:d     r13.0<1;1,0>:d    0:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    255:w               {I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    255:w              
(~f1.0) goto (8|M0)                          L2240                  L2240                
L2216:
        mov (8|M0)               r127.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L2240                  L8016                
L2240:
        join (8|M0)                          L8016                                
L2256:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r13.0<1;1,0>:d    0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r14.0<1;1,0>:d    255:w              
(~f0.1) goto (8|M0)                          L2328                  L2328                
L2304:
        mov (8|M0)               r127.0<1>:f   -inf:f                               {Compacted}
        goto (8|M0)                          L2328                  L8016                
L2328:
        join (8|M0)                          L8016                                
L2344:
        or (8|M0)     (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    r13.0<1;1,0>:d  
(~f1.0) goto (8|M0)                          L2400                  L2400                
L2376:
        mov (8|M0)               r127.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L2400                  L8016                
L2400:
        join (8|M0)                          L8016                                
L2416:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
        add (8|M0)               r91.0<1>:d    r14.0<1;1,0>:d    -132:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r22.0<1>:d    acc0.0<1;1,0>:d   r13.0<1;1,0>:d  
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        mul (8|M0)               acc0.0<1>:ud  r22.0<1;1,0>:ud   0x0:uw              {I@2}
        mach (8|M0)              r120.0<1>:ud  r22.0<1;1,0>:ud   0xE50000:ud              {AccWrEn}
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r29.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L2592:
(W)     shl (1|M0)               r17.1<1>:d    r6.3<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r17.1<0;1,0>:d   {I@2}
        bfn.0xA8 (8|M0)          r49.0<1>:ud   r26.0<1;0>:ud     r6.7<0;0>:ud      r17.1<0>:ud      // s0&(s1|s2)
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r49.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r48.0<1>:d    r29.0<1;1,0>:d    r6.2<0;1,0>:d    {Compacted,A@1}
(W)     addc (1|M0)              r20.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  sel (8|M0)               r19.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r17.4<1>:ud   r17.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f1.0)  sel (8|M0)               r17.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r18.0<1>:d    r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r19.0<1;1,0>:uw   r17.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r21.0<1>:d    r6.5<0;1,0>:d                   
        mov (8|M0)               r39.0<1>:f    r20.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r94.0<1>:d    r17.4<0;1,0>:d                  
(f0.1)  goto (8|M0)                          L3000                  L3000                
L2936:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r20.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r17.4<0;1,0>:d                  
(W)     jmpi                                 L2592                                
L3000:
        join (8|M0)                          L8016                                
L3016:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(~f1.1) sel (8|M0)               r77.0<1>:d    r91.0<1;1,0>:d    -131:w              
        subb (8|M0)              r51.0<1>:ud   r6.2<0;1,0>:ud    r18.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r17.0<1>:hf   0.0:hf                             
        add3 (8|M0)              r85.0<1>:d    r77.0<1;0>:d      r51.0<1;0>:d      -46:w               {I@1}
        add (8|M0)               r75.0<1>:d    r77.0<1;1,0>:d    r51.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r85.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r89.0<1>:ud   -acc0.0<1;0>:ud   r17.0<0;0>:uw     -r21.0<1>:ud     {F@1}
(~f0.1) goto (8|M0)                          L3168                  L3168                
L3144:
        mov (8|M0)               r127.0<1>:f   -inf:f                               {Compacted}
        goto (8|M0)                          L3168                  L8016                
L3168:
        join (8|M0)                          L8016                                
L3184:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r85.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L5656                  L5656                
L3216:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r85.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L5232                  L5232                
L3248:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r76.0<1>:d    r77.0<1;0>:d      r51.0<1;0>:d      104:w              
        subb (8|M0)              r108.0<1>:ud  r6.2<0;1,0>:ud    r18.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r17.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r108.0<1;1,0>:ud  r76.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r42.0<1>:ud   -acc0.0<1;0>:ud   r17.0<0;0>:uw     -r21.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r42.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r42.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L3448                  L3448                
L3384:
        add3 (8|M0)              acc0.0<1>:d   r75.0<1;0>:d      -r108.0<1;0>:d    104:w              
        mov (8|M0)               r49.0<1>:d    0:w                              
        shl (8|M0)               r50.0<1>:d    r26.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L3448                  L5184                
L3448:
        join (8|M0)                          L5184                                
L3464:
        add3 (8|M0)              r109.0<1>:d   r108.0<1;0>:d     -r75.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r109.0<1;1,0>:d   2:w               {I@1}
(f0.1)  goto (8|M0)                          L3616                  L3616                
L3512:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r109.0<1;1,0>:d   2:w              
(~f1.1) goto (8|M0)                          L3616                  L3664                
L3544:
        shr (8|M0)               r125.0<1>:ud  r26.0<1;1,0>:ud   1:w              
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        mov (8|M0)               r59.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L3616                  L4616                
L3616:
        join (8|M0)                          L3664                                
L3632:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r109.0<1;1,0>:d   1:w              
(f1.0)  goto (8|M0)                          L3664                  L4560                
L3664:
        join (8|M0)                          L4560                                
L3680:
        add3 (8|M0)              acc0.0<1>:d   r108.0<1;0>:d     -r76.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r60.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L3760                  L3760                
L3728:
        mov (8|M0)               r83.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L3760                  L3896                
L3760:
        join (8|M0)                          L3896                                
L3776:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r60.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r60.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r60.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r105.0<1>:ud  r26.0<1;1,0>:ud   r60.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r18.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r125.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r125.0<1>:d   r105.0<1;1,0>:d   r18.0<1;1,0>:d   {I@2}
        mov (8|M0)               r83.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@1}
L3896:
        join (8|M0)                          L4560                                
L3912:
        add3 (8|M0)              r64.0<1>:d    r108.0<1;0>:d     -r76.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r59.0<1>:d    r64.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L3992                  L3992                
L3960:
        mov (8|M0)               r125.0<1>:d   r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L3992                  L4120                
L3992:
        join (8|M0)                          L4120                                
L4008:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r59.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r59.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r59.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r103.0<1>:ud  r26.0<1;1,0>:ud   r59.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r17.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r125.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r125.0<1>:d   r103.0<1;1,0>:d   r17.0<1;1,0>:d   {I@2}
L4120:
        join (8|M0)                          L4560                                
L4136:
        and (8|M0)    (ne)f1.1   r11.0<1>:d    r64.0<1;1,0>:d    63:w              
        and (8|M0)               r90.0<1>:d    r125.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L4224                  L4224                
L4176:
        mov (8|M0)               r28.0<1>:d    -1:w                              
        mov (8|M0)               r36.0<1>:d    -1:w                              
        goto (8|M0)                          L4224                  L4408                
L4224:
        join (8|M0)                          L4408                                
L4240:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r11.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L4344                  L4344                
L4272:
        add (8|M0)               acc0.0<1>:d   r11.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r28.0<1>:d    0:w                              
        shl (8|M0)               r36.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L4344                  L4408                
L4344:
        join (8|M0)                          L4408                                
L4360:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r36.0<1>:d    -1:w                              
        shl (8|M0)               r28.0<1>:d    r6.4<0;1,0>:w     r11.0<1;1,0>:d   {F@1}
L4408:
        join (8|M0)                          L4560                                
L4424:
        bfn.0x28 (8|M0)          r102.0<1>:ud  r26.0<1;0>:ud     r28.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r101.0<1>:ud  r29.0<1;0>:ud     r36.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r102.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r59.0<1>:f    r83.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r101.0<1;1,0>:d   0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r72.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L4560                  L4616                
L4560:
        join (8|M0)                          L4616                                
L4576:
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        mov (8|M0)               r59.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
L4616:
        join (8|M0)                          L5184                                
L4632:
        and (8|M0)    (ne)f0.1   r58.0<1>:d    r109.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L4696                  L4696                
L4664:
        mov (8|M0)               r125.0<1>:d   r26.0<1;1,0>:d                  
        goto (8|M0)                          L4696                  L4824                
L4696:
        join (8|M0)                          L4824                                
L4712:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r58.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r58.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r58.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r98.0<1>:ud   r26.0<1;1,0>:ud   r58.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r127.0<1>:d   r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r125.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r125.0<1>:d   r98.0<1;1,0>:d    r127.0<1;1,0>:d  {I@2}
L4824:
        join (8|M0)                          L5184                                
L4840:
        shl (8|M0)               r86.0<1>:d    r59.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r97.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r86.0<1>:d    r86.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r31.0<1>:ud   r86.0<1;0>:ud     r97.0<1;0>:ud     r72.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r31.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L4944                  L4944                
L4912:
        mov (8|M0)               r48.0<1>:d    0:w                              
        goto (8|M0)                          L4944                  L5104                
L4944:
        join (8|M0)                          L5104                                
L4960:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r31.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L5024                  L5024                
L4992:
        mov (8|M0)               r48.0<1>:d    1:w                              
        goto (8|M0)                          L5024                  L5104                
L5024:
        join (8|M0)                          L5104                                
L5040:
        and (8|M0)    (ne)f1.0   null<1>:d     r125.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r31.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r48.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L5104:
        join (8|M0)                          L5184                                
L5120:
        add (8|M0)               r111.0<1>:d   r48.0<1;1,0>:d    r125.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r111.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r50.0<1>:d    r111.0<1;1,0>:d   0:w              
(f1.0)  sel (8|M0)               r49.0<1>:d    r6.2<0;1,0>:d     0:w               {F@1}
L5184:
        join (8|M0)                          L5232                                
L5200:
        bfn.0xFE (8|M0)          r127.0<1>:ud  r49.0<1;0>:ud     r50.0<1;0>:ud     r6.1<0>:ud       {I@2} // s0|s1|s2
        goto (8|M0)                          L5232                  L8016                
L5232:
        join (8|M0)                          L5656                                
L5248:
        and (8|M0)    (ne)f1.1   r101.0<1>:d   r51.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L5328                  L5328                
L5280:
        mov (8|M0)               r113.0<1>:d   -1:w                              
        mov (8|M0)               r126.0<1>:d   -1:w                              
        goto (8|M0)                          L5328                  L5512                
L5328:
        join (8|M0)                          L5512                                
L5344:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r101.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L5448                  L5448                
L5376:
        add (8|M0)               acc0.0<1>:d   r101.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r113.0<1>:d   0:w                              
        shl (8|M0)               r126.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L5448                  L5512                
L5448:
        join (8|M0)                          L5512                                
L5464:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r126.0<1>:d   -1:w                              
        shl (8|M0)               r113.0<1>:d   r6.4<0;1,0>:w     r101.0<1;1,0>:d  {F@1}
L5512:
        join (8|M0)                          L5656                                
L5528:
        bfn.0x28 (8|M0)          r96.0<1>:ud   r26.0<1;0>:ud     r113.0<1;0>:ud    r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r95.0<1>:ud   r29.0<1;0>:ud     r126.0<1;0>:ud    r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r96.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.2<1>:f     -1.4013e-45:f                              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r95.0<1;1,0>:d    0:w               {I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r85.0<1;1,0>:d    -150:w              
(f0.1)  sel (8|M0)               r127.0<1>:f   r6.2<0;1,0>:f     -0.0:f               {F@1}
        goto (8|M0)                          L5656                  L8016                
L5656:
        join (8|M0)                          L8016                                
L5672:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r51.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r102.0<1>:d   r77.0<1;0>:d      r51.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r89.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L7728                  L7728                
L5736:
        shl (8|M0)               r82.0<1>:d    r39.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r81.0<1>:ud   r39.0<1;1,0>:ud   31:w              
        shl (8|M0)               r69.0<1>:d    r94.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r82.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r69.0<1>:d    r69.0<1;1,0>:d    r81.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r69.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r69.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L5968                  L5968                
L5840:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r39.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L5968                  L6032                
L5888:
        shr (8|M0)               r125.0<1>:ud  r26.0<1;1,0>:ud   1:w              
        mov (8|M0)               r87.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:d    0:w                              
        mov (8|M0)               r76.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r125.0<1>:f   r26.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L5968                  L7232                
L5968:
        join (8|M0)                          L6032                                
L5984:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r39.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r94.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L6032                  L7144                
L6032:
        join (8|M0)                          L7144                                
L6048:
        add (8|M0)               acc0.0<1>:d   -r39.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r96.0<1>:d    -r39.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r65.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L6128                  L6128                
L6096:
        mov (8|M0)               r94.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L6128                  L6264                
L6128:
        join (8|M0)                          L6264                                
L6144:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r65.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r65.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r65.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r92.0<1>:ud   r26.0<1;1,0>:ud   r65.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r35.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r125.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r125.0<1>:d   r92.0<1;1,0>:d    r35.0<1;1,0>:d   {I@2}
        mov (8|M0)               r94.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@1}
L6264:
        join (8|M0)                          L7144                                
L6280:
        add (8|M0)               r73.0<1>:d    -r39.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r68.0<1>:d    r73.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L6352                  L6352                
L6320:
        mov (8|M0)               r125.0<1>:d   r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L6352                  L6480                
L6352:
        join (8|M0)                          L6480                                
L6368:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r68.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r68.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r68.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r90.0<1>:ud   r26.0<1;1,0>:ud   r68.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r43.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r125.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r125.0<1>:d   r90.0<1;1,0>:d    r43.0<1;1,0>:d   {I@2}
L6480:
        join (8|M0)                          L7144                                
L6496:
        and (8|M0)    (ne)f1.1   r42.0<1>:d    r73.0<1;1,0>:d    63:w              
        and (8|M0)               r93.0<1>:d    r125.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L6584                  L6584                
L6536:
        mov (8|M0)               r46.0<1>:d    -1:w                              
        mov (8|M0)               r52.0<1>:d    -1:w                              
        goto (8|M0)                          L6584                  L6768                
L6584:
        join (8|M0)                          L6768                                
L6600:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r42.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L6704                  L6704                
L6632:
        add (8|M0)               acc0.0<1>:d   r42.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r46.0<1>:d    0:w                              
        shl (8|M0)               r52.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L6704                  L6768                
L6704:
        join (8|M0)                          L6768                                
L6720:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r52.0<1>:d    -1:w                              
        shl (8|M0)               r46.0<1>:d    r6.4<0;1,0>:w     r42.0<1;1,0>:d   {F@1}
L6768:
        join (8|M0)                          L7144                                
L6784:
        bfn.0x28 (8|M0)          r89.0<1>:ud   r26.0<1;0>:ud     r46.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r88.0<1>:ud   r29.0<1;0>:ud     r52.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r89.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r88.0<1;1,0>:d    0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        and (8|M0)    (ne)f0.1   r67.0<1>:d    r96.0<1;1,0>:d    63:w              
        mov (8|M0)               r87.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L6960                  L6960                
L6928:
        mov (8|M0)               r125.0<1>:d   r26.0<1;1,0>:d                  
        goto (8|M0)                          L6960                  L7088                
L6960:
        join (8|M0)                          L7088                                
L6976:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r67.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r67.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r67.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r85.0<1>:ud   r26.0<1;1,0>:ud   r67.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r41.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r125.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r125.0<1>:d   r85.0<1;1,0>:d    r41.0<1;1,0>:d   {I@2}
L7088:
        join (8|M0)                          L7144                                
L7104:
        mov (8|M0)               r76.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r125.0<1>:d   r94.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L7144                  L7232                
L7144:
        join (8|M0)                          L7232                                
L7160:
        shr (8|M0)               r125.0<1>:ud  r26.0<1;1,0>:ud   2:w              
        mov (8|M0)               r87.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:d    0:w                              
        mov (8|M0)               r76.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r125.0<1>:ud  r26.0<1;1,0>:ud   1:w               {F@1}
L7232:
        join (8|M0)                          L7728                                
L7248:
        shl (8|M0)               r27.0<1>:d    r125.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r84.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r27.0<1>:d    r27.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r85.0<1>:d    r76.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r100.0<1>:ud  r27.0<1;0>:ud     r84.0<1;0>:ud     r87.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (8|M0)                          L7368                  L7368                
L7336:
        mov (8|M0)               r99.0<1>:d    0:w                              
        goto (8|M0)                          L7368                  L7528                
L7368:
        join (8|M0)                          L7528                                
L7384:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r100.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (8|M0)                          L7448                  L7448                
L7416:
        mov (8|M0)               r99.0<1>:d    1:w                              
        goto (8|M0)                          L7448                  L7528                
L7448:
        join (8|M0)                          L7528                                
L7464:
        and (8|M0)    (ne)f1.1   null<1>:d     r76.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r99.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L7528:
        join (8|M0)                          L7728                                
L7544:
        add (8|M0)               r41.0<1>:d    r85.0<1;1,0>:d    r99.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r34.0<1>:d    r77.0<1;0>:d      r51.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r41.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r18.0<1>:d    r34.0<1;1,0>:d    r102.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r18.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L7656                  L7656                
L7632:
        mov (8|M0)               r127.0<1>:f   -inf:f                               {Compacted}
        goto (8|M0)                          L7656                  L8016                
L7656:
        join (8|M0)                          L7728                                
L7672:
(~f0.1) sel (8|M0)               r33.0<1>:d    r41.0<1;1,0>:d    0:w              
        shl (8|M0)               r83.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r127.0<1>:ud  r83.0<1;0>:ud     r33.0<1;0>:ud     r6.1<0>:ud       {A@1} // s0|s1|s2
        goto (8|M0)                          L7728                  L8016                
L7728:
        join (8|M0)                          L8016                                
L7744:
        and (8|M0)    (ne)f1.0   r37.0<1>:d    r51.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L7808                  L7808                
L7776:
        mov (8|M0)               r85.0<1>:d    -1:w                              
        goto (8|M0)                          L7808                  L7936                
L7808:
        join (8|M0)                          L7936                                
L7824:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r37.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L7888                  L7888                
L7856:
        mov (8|M0)               r85.0<1>:d    0:w                              
        goto (8|M0)                          L7888                  L7936                
L7888:
        join (8|M0)                          L7936                                
L7904:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r85.0<1>:d    r6.4<0;1,0>:w     r37.0<1;1,0>:d   {F@1}
L7936:
        join (8|M0)                          L8016                                
L7952:
        bfn.0x28 (8|M0)          r84.0<1>:ud   r26.0<1;0>:ud     r85.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r51.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r81.0<1>:d    r102.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r84.0<1>:d    r84.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@3}
        bfn.0xFE (8|M0)          r127.0<1>:ud  r81.0<1;0>:ud     r84.0<1;0>:ud     r6.1<0>:ud       {I@1} // s0|s1|s2
L8016:
        join (8|M0)                          L30264                                
L8032:
        shr (8|M0)               r86.0<1>:ud   r127.0<1;1,0>:ud  23:w               {I@2}
        and (8|M0)    (ne)f1.0   r23.0<1>:d    r127.0<1;1,0>:d   8388607:d              
        and (8|M0)               r18.0<1>:d    r86.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L8128                  L8128                
L8104:
        mov (8|M0)               r127.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L8128                  L12544                
L8128:
        join (8|M0)                          L12544                                
L8144:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r23.0<1;1,0>:d    0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    255:w              
(f0.1)  goto (8|M0)                          L12544                  L12544                
L8192:
        or (8|M0)     (eq)f1.1   null<1>:d     r18.0<1;1,0>:d    r23.0<1;1,0>:d  
(~f1.1) goto (8|M0)                          L8256                  L8256                
L8224:
        mov (8|M0)               r127.0<1>:f   0x3EE50000:f                              
        goto (8|M0)                          L8256                  L12544                
L8256:
        join (8|M0)                          L12544                                
L8272:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r127.0<1;1,0>:d   -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r18.0<1;1,0>:ud   0x7D:uw             
(f1.0)  goto (8|M0)                          L8544                  L8544                
L8320:
(f1.1)  goto (8|M0)                          L8432                  L8432                
L8336:
        mov (8|M0)               r78.0<1>:f    0x3EE50000:f                              
        mov (8|M0)               r117.0<1>:f   r127.0<1;1,0>:f                  {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L43752                                 {A@1}
L8408:
        mov (8|M0)               r127.0<1>:f   r102.0<1;1,0>:f                  {Compacted,I@5}
        goto (8|M0)                          L8432                  L12544                
L8432:
        join (8|M0)                          L8544                                
L8448:
        mov (8|M0)               r78.0<1>:f    r127.0<1;1,0>:f                  {Compacted,F@1}
        mov (8|M0)               r117.0<1>:f   0x3EE50000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L43752                                 {A@1}
L8520:
        mov (8|M0)               r127.0<1>:f   r102.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L8544                  L12544                
L8544:
        join (8|M0)                          L12544                                
L8560:
(f1.1)  goto (8|M0)                          L10680                  L10680                
L8576:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        add (8|M0)               r46.0<1>:d    -r18.0<1;1,0>:d   125:w               {Compacted}
(f1.0)  sel (8|M0)               r31.0<1>:d    r46.0<1;1,0>:d    124:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r31.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L9768                  L9768                
L8648:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r31.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L9352                  L9352                
L8680:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r31.0<1;1,0>:ud   0x18:uw             
(f0.1)  goto (8|M0)                          L9112                  L9112                
L8712:
        cmp (8|M0)    (ne)f0.1   r36.0<1>:d    r18.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r31.0<1;1,0>:d    25:w              
        mov (8|M0)               r28.0<1>:d    -r36.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L8920                  L8920                
L8776:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r31.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f1.1   r45.0<1>:d    r23.0<1;1,0>:d    0:w              
        cmp (8|M0)    (ne)f1.0   r80.0<1>:d    r127.0<1;1,0>:d   0:w               {F@1}
(f0.1)  sel (8|M0)               r28.0<1>:d    -r36.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               acc0.0<1>:d   -r45.0<1;1,0>:d   -r80.0<1;1,0>:d  {I@2}
        mov (8|M0)               r57.0<1>:f    r28.0<1;1,0>:f                   {Compacted,I@2}
        shl (8|M0)               r30.0<1>:d    acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r28.0<1>:d    0:w                               {F@1}
        asr (8|M0)               r17.0<1>:d    r30.0<1;1,0>:d    31:w               {Compacted,I@2}
        goto (8|M0)                          L8920                  L8992                
L8920:
        join (8|M0)                          L8992                                
L8936:
        shr (8|M0)               r79.0<1>:ud   r127.0<1;1,0>:ud  22:w              
        and (8|M0)               r78.0<1>:d    r127.0<1;1,0>:d   4194303:d              
        and (8|M0)               r57.0<1>:d    r79.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r17.0<1>:d    r78.0<1;1,0>:d    0:w               {I@2}
L8992:
        join (8|M0)                          L9112                                
L9008:
        cmp (8|M0)    (ne)f1.0   r77.0<1>:d    r17.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.8<2>:b     125:w                              
        mov (8|M0)               r25.0<1>:f    9.275385e-39:f                              
        mov (8|M0)               r106.0<1>:f   r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r17.0<1>:b    r6.8<0;1,0>:b                    {I@1}
        mov (8|M0)               r69.0<1>:d    -r77.0<1;1,0>:d                 
        goto (8|M0)                          L9112                  L10264                
L9112:
        join (8|M0)                          L9352                                
L9128:
        add (8|M0)               acc0.0<1>:d   r31.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r31.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r88.0<1>:d    -r31.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r76.0<1>:ud   r23.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r64.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r73.0<1>:ud   r23.0<1;1,0>:ud   r31.0<1;1,0>:d  
        shr (8|M0)               r65.0<1>:ud   r23.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r79.0<1>:ud   r64.0<1;0>:ud     r7.7<0;0>:ud      r23.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r88.0<1>:d    r6.4<0;1,0>:w     r88.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r88.0<1>:d    0:w                              
        and (8|M0)               r71.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r28.0<1>:d    r65.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r35.0<1>:d    r79.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r66.0<1>:d    r73.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L9352                  L9440                
L9352:
        join (8|M0)                          L9440                                
L9368:
        and (8|M0)               r28.0<1>:d    r127.0<1;1,0>:d   1:w               {Compacted}
        shr (8|M0)               r66.0<1>:ud   r23.0<1;1,0>:ud   1:w              
(f1.0)  goto (8|M0)                          L9440                  L9656                
L9408:
        mov (8|M0)               r71.0<1>:d    0:w                              
        mov (8|M0)               r35.0<1>:d    0:w                              
L9440:
        join (8|M0)                          L9656                                
L9456:
        cmp (8|M0)    (ne)f1.1   r56.0<1>:d    r35.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r66.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r25.0<1>:d    r66.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r69.0<1>:d    -r56.0<1;1,0>:d                  {I@3}
(f1.0)  goto (8|M0)                          L9592                  L9592                
L9536:
(W)     mov (1|M0)               r6.8<2>:b     125:w                              
        mov (8|M0)               r106.0<1>:f   r71.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r17.0<1>:b    r6.8<0;1,0>:b                    {I@1}
        goto (8|M0)                          L9592                  L10264                
L9592:
        join (8|M0)                          L9656                                
L9608:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r71.0<1;1,0>:d    1:w              
(~f0.1) sel (8|M0)               r69.0<1>:d    -r56.0<1;1,0>:d   1:w              
        goto (8|M0)                          L9656                  L9704                
L9656:
        join (8|M0)                          L9704                                
L9672:
        add (8|M0)               r25.0<1>:d    r66.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r69.0<1>:d    0:w                              
L9704:
        join (8|M0)                          L9768                                
L9720:
        shr (8|M0)               r75.0<1>:ud   r25.0<1;1,0>:ud   1:w               {I@3}
        and (8|M0)               r55.0<1>:d    r75.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L9768                  L10176                
L9768:
        join (8|M0)                          L10176                                
L9784:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r23.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r25.0<1>:d    r23.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L10064                  L10064                
L9832:
(f1.0)  goto (8|M0)                          L9944                  L9944                
L9848:
(W)     mov (1|M0)               r6.8<2>:b     125:w                              
        mov (8|M0)               r28.0<1>:d    0:w                              
        mov (8|M0)               r106.0<1>:d   0:w                               {F@1}
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r17.0<1>:b    r6.8<0;1,0>:b                    {I@4}
        goto (8|M0)                          L9944                  L10264                
L9944:
        join (8|M0)                          L10064                                
L9960:
(W)     mov (1|M0)               r6.8<2>:b     126:w                              
        and (8|M0)               r28.0<1>:d    r127.0<1;1,0>:d   1:w               {Compacted}
        shr (8|M0)               r25.0<1>:ud   r25.0<1;1,0>:ud   1:w              
        mov (8|M0)               r106.0<1>:d   0:w                              
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r17.0<1>:b    r6.8<0;1,0>:b                    {I@5}
        goto (8|M0)                          L10064                  L10264                
L10064:
        join (8|M0)                          L10176                                
L10080:
        shr (8|M0)               r39.0<1>:ud   r25.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r69.0<1>:d    0:w                              
        and (8|M0)               r44.0<1>:d    r39.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r39.0<1>:d    r39.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r28.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r55.0<1>:d    r39.0<1;1,0>:d    r44.0<1;1,0>:d   {I@2}
L10176:
        join (8|M0)                          L10264                                
L10192:
        and (8|M0)               acc0.0<1>:d   r25.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r6.8<2>:b     126:w                              
        mov (8|M0)               r106.0<1>:f   r28.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r25.0<1>:f    r55.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r28.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r17.0<1>:b    r6.8<0;1,0>:b                    {I@2}
L10264:
        join (8|M0)                          L10680                                
L10280:
        shl (8|M0)               r57.0<1>:d    r28.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r74.0<1>:d    r106.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r47.0<1>:ud   r57.0<1;0>:ud     r74.0<1;0>:ud     r69.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r47.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L10376                  L10376                
L10344:
        mov (8|M0)               r64.0<1>:d    0:w                              
        goto (8|M0)                          L10376                  L10536                
L10376:
        join (8|M0)                          L10536                                
L10392:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r47.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L10456                  L10456                
L10424:
        mov (8|M0)               r64.0<1>:d    1:w                              
        goto (8|M0)                          L10456                  L10536                
L10456:
        join (8|M0)                          L10536                                
L10472:
        and (8|M0)    (ne)f1.1   null<1>:d     r25.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r47.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r64.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L10536:
        join (8|M0)                          L10680                                
L10552:
        add (8|M0)               r85.0<1>:d    r25.0<1;1,0>:d    r64.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r84.0<1>:d    r17.0<1;1,0>:ub                 
        cmp (8|M0)    (eq)f0.1   r43.0<1>:d    r85.0<1;1,0>:d    8388608:d               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r85.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r84.0<1;0>:d      -r43.0<1;0>:d     0:w               {I@2}
(f1.0)  mov (8|M0)               r85.0<1>:d    0:w                              
        shl (8|M0)               r84.0<1>:d    acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r127.0<1>:d   r84.0<1;1,0>:d    r85.0<1;1,0>:d   {Compacted,I@1}
        goto (8|M0)                          L10680                  L12544                
L10680:
        join (8|M0)                          L12544                                
L10696:
        mov (8|M0)               r17.0<1>:b    r86.0<4;1,0>:b                  
        cmp (8|M0)    (lt)f1.0   null<1>:w     r17.0<1;1,0>:b    126:w               {I@1}
(f1.0)  goto (8|M0)                          L10856                  L10856                
L10744:
        cmp (8|M0)    (eq)f0.1   null<1>:w     r17.0<1;1,0>:b    126:w              
(~f0.1) goto (8|M0)                          L10856                  L10904                
L10776:
        mov (8|M0)               r34.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r99.0<1>:d    0:w                              
        mov (8|M0)               r105.0<1>:f   0x728000:f                              
        goto (8|M0)                          L10856                  L11568                
L10856:
        join (8|M0)                          L10904                                
L10872:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r17.0<1;1,0>:b    125:w              
(f1.1)  goto (8|M0)                          L10904                  L11784                
L10904:
        join (8|M0)                          L11568                                
L10920:
        add (8|M0)               r68.0<1>:d    r18.0<1;1,0>:d    -125:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r68.0<1;1,0>:ud   0x18:uw              {I@1}
(f1.0)  goto (8|M0)                          L11344                  L11344                
L10960:
        cmp (8|M0)    (lt)f0.1   null<1>:w     r17.0<1;1,0>:b    -106:w              
(f0.1)  goto (8|M0)                          L11104                  L11104                
L10992:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r17.0<1;1,0>:b    -106:w              
(~f1.1) goto (8|M0)                          L11104                  L11152                
L11024:
        mov (8|M0)               r34.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:d    1:w                              
        mov (8|M0)               r99.0<1>:d    -1:w                              
        mov (8|M0)               r105.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L11104                  L11568                
L11104:
        join (8|M0)                          L11152                                
L11120:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r17.0<1;1,0>:b    -107:w              
(f1.0)  goto (8|M0)                          L11152                  L11248                
L11152:
        join (8|M0)                          L11248                                
L11168:
        mov (8|M0)               r34.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r99.0<1>:d    -1:w                              
        mov (8|M0)               r105.0<1>:d   0:w                              
        goto (8|M0)                          L11248                  L11568                
L11248:
        join (8|M0)                          L11344                                
L11264:
        mov (8|M0)               r34.0<1>:d    1:w                              
        mov (8|M0)               r78.0<1>:d    1:w                              
        mov (8|M0)               r99.0<1>:d    -1:w                              
        mov (8|M0)               r105.0<1>:d   0:w                              
        goto (8|M0)                          L11344                  L11568                
L11344:
        join (8|M0)                          L11568                                
L11360:
(W)     mov (1|M0)               r6.3<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r18.0<1;1,0>:d    -127:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r18.0<1;1,0>:d    -126:w               {Compacted}
        add (8|M0)               r26.0<1>:d    -r18.0<1;1,0>:d   148:w               {Compacted}
        shr (8|M0)               r73.0<1>:ud   r6.3<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r76.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r77.0<1>:ud   r6.3<0;1,0>:ud    r68.0<1;1,0>:d  
        shr (8|M0)               r98.0<1>:ud   r6.3<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r76.0<1>:d    r76.0<1;1,0>:d    6619136:d              
        shl (8|M0)               r26.0<1>:d    r6.4<0;1,0>:w     r26.0<1;1,0>:d   {F@1}
        and (8|M0)               r78.0<1>:d    r73.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r34.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f1.0   r99.0<1>:d    r76.0<1;1,0>:d    6619136:d               {I@4}
        or (8|M0)                r105.0<1>:d   r77.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@4}
L11568:
        join (8|M0)                          L11784                                
L11584:
        add (8|M0)               r29.0<1>:d    r23.0<1;1,0>:d    r105.0<1;1,0>:d  {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r59.0<1>:d    r99.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r29.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        mov (8|M0)               r75.0<1>:d    -r59.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L11688                  L11688                
L11656:
        mov (8|M0)               r125.0<1>:d   r78.0<1;1,0>:d                  
        goto (8|M0)                          L11688                  L12072                
L11688:
        join (8|M0)                          L11784                                
L11704:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    1:w              
        shr (8|M0)               r72.0<1>:ud   r29.0<1;1,0>:ud   1:w              
        and (8|M0)               r48.0<1>:d    r72.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r75.0<1>:d    -r59.0<1;1,0>:d   1:w              
        goto (8|M0)                          L11784                  L12008                
L11784:
        join (8|M0)                          L12008                                
L11800:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r23.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r29.0<1>:d    r23.0<1;1,0>:d    6619136:d              
(f1.0)  goto (8|M0)                          L11928                  L11928                
L11848:
        and (8|M0)               r34.0<1>:d    r127.0<1;1,0>:d   1:w               {Compacted}
        shr (8|M0)               r29.0<1>:ud   r29.0<1;1,0>:ud   1:w               {I@3}
        add (8|M0)               r18.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r75.0<1>:d    0:w                              
        goto (8|M0)                          L11928                  L12072                
L11928:
        join (8|M0)                          L12008                                
L11944:
        shr (8|M0)               r71.0<1>:ud   r29.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r75.0<1>:d    0:w                              
        mov (8|M0)               r34.0<1>:d    0:w                              
        or (8|M0)                r48.0<1>:d    r71.0<1;1,0>:d    4194304:d               {I@3}
L12008:
        join (8|M0)                          L12072                                
L12024:
        and (8|M0)               acc0.0<1>:d   r29.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r18.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r125.0<1>:f   r34.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r29.0<1>:f    r48.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r34.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L12072:
        join (8|M0)                          L12544                                
L12088:
        shl (8|M0)               r64.0<1>:d    r34.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r70.0<1>:d    r125.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r63.0<1>:ud   r64.0<1;0>:ud     r70.0<1;0>:ud     r75.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r63.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L12184                  L12184                
L12152:
        mov (8|M0)               r83.0<1>:d    0:w                              
        goto (8|M0)                          L12184                  L12344                
L12184:
        join (8|M0)                          L12344                                
L12200:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r63.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L12264                  L12264                
L12232:
        mov (8|M0)               r83.0<1>:d    1:w                              
        goto (8|M0)                          L12264                  L12344                
L12264:
        join (8|M0)                          L12344                                
L12280:
        and (8|M0)    (ne)f1.0   null<1>:d     r29.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r63.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r83.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L12344:
        join (8|M0)                          L12544                                
L12360:
        add (8|M0)               r82.0<1>:d    r29.0<1;1,0>:d    r83.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f1.1   r69.0<1>:d    r82.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r34.0<1>:d    r18.0<1;0>:d      -r69.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L12472                  L12472                
L12448:
        mov (8|M0)               r127.0<1>:f   inf:f                               {Compacted}
        goto (8|M0)                          L12472                  L12544                
L12472:
        join (8|M0)                          L12544                                
L12488:
(~f0.1) sel (8|M0)               r50.0<1>:d    r82.0<1;1,0>:d    0:w              
        and (8|M0)               r42.0<1>:d    r127.0<1;1,0>:d   -2147483648:d               {F@1}
        shl (8|M0)               r68.0<1>:d    r34.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r127.0<1>:ud  r42.0<1;0>:ud     r68.0<1;0>:ud     r50.0<1>:ud      {I@1} // s0|s1|s2
L12544:
        join (8|M0)                          L30264                                
L12560:
        mov (8|M0)               r17.0<1>:hf   r127.0<1;1,0>:f                  {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        mov (8|M0)               r112.0<1>:f   r17.0<1;1,0>:hf                  {F@2}
(f0.0)  sel (8|M0)               r17.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw              {A@1}
        shr (8|M0)               r74.0<1>:ud   r112.0<1;1,0>:ud  23:w              
        and (8|M0)    (ne)f0.1   r75.0<1>:d    r112.0<1;1,0>:d   8388607:d              
        and (8|M0)               r103.0<1>:d   r74.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   255:w               {I@1}
(f0.1)  sel (8|M0)               r18.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f0.1   null<1>:uw    r18.0<1;1,0>:uw   r17.0<1;1,0>:uw  {I@1}
(~f0.1) goto (8|M0)                          L12752                  L12752                
L12728:
        mov (8|M0)               r32.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L12752                  L19144                
L12752:
        join (8|M0)                          L19144                                
L12768:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r75.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r13.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        xor (8|M0)               r18.0<1>:d    r112.0<1;1,0>:d   r16.0<1;1,0>:d   {Compacted}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   255:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    255:w              
(f0.1)  sel (8|M0)               r17.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r16.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.1   null<1>:uw    r17.0<1;1,0>:uw   r16.0<1;1,0>:uw  {I@1}
(f1.1)  goto (8|M0)                          L19112                  L19112                
L12920:
        or (8|M0)     (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    r13.0<1;1,0>:d  
        or (8|M0)                r67.0<1>:d    r103.0<1;1,0>:d   r75.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (8|M0)    (eq)f1.1   null<1>:d     r67.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L13000                  L13000                
L12976:
        mov (8|M0)               r32.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L13000                  L19144                
L13000:
        join (8|M0)                          L19112                                
L13016:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
        add (8|M0)               r118.0<1>:d   r103.0<1;1,0>:d   -127:w               {Compacted}
        add (8|M0)               r117.0<1>:d   r14.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r118.0<1>:d   -126:w                              
(f1.1)  mov (8|M0)               r117.0<1>:d   -126:w                              
        add (8|M0)               r101.0<1>:d   r118.0<1;1,0>:d   r117.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r101.0<1;1,0>:d   127:w               {I@1}
(f1.0)  goto (8|M0)                          L19040                  L19040                
L13136:
        or (8|M0)     (eq)f1.0   null<4>:b     r74.0<1;1,0>:d    r15.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L18968                  L18968                
L13168:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r6.4<0;1,0>:w     8388608:d              
        or (8|M0)                r44.0<1>:d    acc0.0<1;1,0>:d   r75.0<1;1,0>:d  
        or (8|M0)                r38.0<1>:d    acc2.0<1;1,0>:d   r13.0<1;1,0>:d  
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r44.0<1;1,0>:ud   r38.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r116.0<1>:ud  r44.0<1;1,0>:ud   r38.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r30.0<1>:f    r116.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L13344:
(W)     shl (1|M0)               r13.1<1>:d    r6.3<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.0   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r13.1<0;1,0>:d   {I@2}
        bfn.0xA8 (8|M0)          r45.0<1>:ud   r23.0<1;0>:ud     r6.7<0;0>:ud      r13.1<0>:ud      // s0&(s1|s2)
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f1.0) cmp (8|M0)   (eq)f1.0   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r45.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r44.0<1>:d    r30.0<1;1,0>:d    r6.2<0;1,0>:d    {Compacted,A@1}
(W)     addc (1|M0)              r15.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.0) cmp (8|M0)  (gt)f1.0   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r44.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f1.0)  sel (8|M0)               r14.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r13.4<1>:ud   r13.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f0.1)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r122.0<1>:d   r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.1   null<1>:uw    r14.0<1;1,0>:uw   r13.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r11.0<1>:d    r6.5<0;1,0>:d                   
        mov (8|M0)               r37.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r92.0<1>:d    r13.4<0;1,0>:d                  
(f1.1)  goto (8|M0)                          L13752                  L13752                
L13688:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r13.4<0;1,0>:d                  
(W)     jmpi                                 L13344                                
L13752:
        join (8|M0)                          L18968                                
L13768:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r13.0<1>:hf   0.0:hf                             
        subb (8|M0)              r52.0<1>:ud   r6.2<0;1,0>:ud    r122.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r82.0<1>:d    r101.0<1;0>:d     r52.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r88.0<1>:ud   -acc0.0<1;0>:ud   r13.0<0;0>:uw     -r11.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r82.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r71.0<1>:d    r118.0<1;0>:d     r117.0<1;0>:d     r52.0<1>:d      
(f1.0)  goto (8|M0)                          L18896                  L18896                
L13888:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r82.0<1;1,0>:d    -127:w              
(f0.1)  goto (8|M0)                          L16464                  L16464                
L13920:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r82.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L15944                  L15944                
L13952:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r62.0<1>:d    r101.0<1;0>:d     r52.0<1;0>:d      104:w              
        subb (8|M0)              r102.0<1>:ud  r6.2<0;1,0>:ud    r122.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r13.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r102.0<1;1,0>:ud  r62.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r11.0<1>:ud   -acc0.0<1;0>:ud   r13.0<0;0>:uw     -r11.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r11.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r11.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L14152                  L14152                
L14088:
        add3 (8|M0)              acc0.0<1>:d   r71.0<1;0>:d      -r102.0<1;0>:d    104:w              
        mov (8|M0)               r32.0<1>:d    0:w                              
        shl (8|M0)               r33.0<1>:d    r23.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L14152                  L15880                
L14152:
        join (8|M0)                          L15880                                
L14168:
        add3 (8|M0)              r95.0<1>:d    r102.0<1;0>:d     -r71.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r95.0<1;1,0>:d    2:w               {I@1}
(f1.0)  goto (8|M0)                          L14312                  L14312                
L14216:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L14312                  L14360                
L14248:
        shr (8|M0)               r123.0<1>:ud  r23.0<1;1,0>:ud   1:w              
        and (8|M0)               r83.0<1>:d    r23.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r58.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L14312                  L15312                
L14312:
        join (8|M0)                          L14360                                
L14328:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L14360                  L15256                
L14360:
        join (8|M0)                          L15256                                
L14376:
        add3 (8|M0)              acc0.0<1>:d   r102.0<1;0>:d     -r62.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.0   r37.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L14456                  L14456                
L14424:
        mov (8|M0)               r77.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L14456                  L14592                
L14456:
        join (8|M0)                          L14592                                
L14472:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r37.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r37.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r37.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r63.0<1>:ud   r23.0<1;1,0>:ud   r37.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r81.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r123.0<1>:ud  r30.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r123.0<1>:d   r63.0<1;1,0>:d    r81.0<1;1,0>:d   {I@2}
        mov (8|M0)               r77.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@1}
L14592:
        join (8|M0)                          L15256                                
L14608:
        add3 (8|M0)              r54.0<1>:d    r102.0<1;0>:d     -r62.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.1   r36.0<1>:d    r54.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L14688                  L14688                
L14656:
        mov (8|M0)               r123.0<1>:d   r23.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L14688                  L14816                
L14688:
        join (8|M0)                          L14816                                
L14704:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r36.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r36.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r36.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r61.0<1>:ud   r23.0<1;1,0>:ud   r36.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r80.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r123.0<1>:ud  r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r123.0<1>:d   r61.0<1;1,0>:d    r80.0<1;1,0>:d   {I@2}
L14816:
        join (8|M0)                          L15256                                
L14832:
        and (8|M0)    (ne)f0.1   r79.0<1>:d    r54.0<1;1,0>:d    63:w              
        and (8|M0)               r83.0<1>:d    r123.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L14920                  L14920                
L14872:
        mov (8|M0)               r97.0<1>:d    -1:w                              
        mov (8|M0)               r111.0<1>:d   -1:w                              
        goto (8|M0)                          L14920                  L15104                
L14920:
        join (8|M0)                          L15104                                
L14936:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r79.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L15040                  L15040                
L14968:
        add (8|M0)               acc0.0<1>:d   r79.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r97.0<1>:d    0:w                              
        shl (8|M0)               r111.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L15040                  L15104                
L15040:
        join (8|M0)                          L15104                                
L15056:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r111.0<1>:d   -1:w                              
        shl (8|M0)               r97.0<1>:d    r6.4<0;1,0>:w     r79.0<1;1,0>:d   {F@1}
L15104:
        join (8|M0)                          L15256                                
L15120:
        bfn.0x28 (8|M0)          r60.0<1>:ud   r23.0<1;0>:ud     r97.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r59.0<1>:ud   r30.0<1;0>:ud     r111.0<1;0>:ud    r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r60.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r40.0<1>:f    r77.0<1;1,0>:f                   {Compacted}
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r59.0<1;1,0>:d    0:w               {I@2}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r58.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L15256                  L15312                
L15256:
        join (8|M0)                          L15312                                
L15272:
        mov (8|M0)               r58.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
L15312:
        join (8|M0)                          L15880                                
L15328:
        and (8|M0)    (ne)f1.0   r35.0<1>:d    r95.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L15392                  L15392                
L15360:
        mov (8|M0)               r123.0<1>:d   r23.0<1;1,0>:d                  
        goto (8|M0)                          L15392                  L15520                
L15392:
        join (8|M0)                          L15520                                
L15408:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r35.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r35.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r35.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r56.0<1>:ud   r23.0<1;1,0>:ud   r35.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r78.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r123.0<1>:ud  r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r123.0<1>:d   r56.0<1;1,0>:d    r78.0<1;1,0>:d   {I@2}
L15520:
        join (8|M0)                          L15880                                
L15536:
        shl (8|M0)               r29.0<1>:d    r40.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r55.0<1>:d    r83.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r29.0<1>:d    r29.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r122.0<1>:ud  r29.0<1;0>:ud     r55.0<1;0>:ud     r58.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (8|M0)                          L15640                  L15640                
L15608:
        mov (8|M0)               r13.0<1>:d    0:w                              
        goto (8|M0)                          L15640                  L15800                
L15640:
        join (8|M0)                          L15800                                
L15656:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r122.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (8|M0)                          L15720                  L15720                
L15688:
        mov (8|M0)               r13.0<1>:d    1:w                              
        goto (8|M0)                          L15720                  L15800                
L15720:
        join (8|M0)                          L15800                                
L15736:
        and (8|M0)    (ne)f0.1   null<1>:d     r123.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r122.0<1;1,0>:d   4:w              
(f0.1)  sel (8|M0)               r13.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L15800:
        join (8|M0)                          L15880                                
L15816:
        add (8|M0)               r100.0<1>:d   r13.0<1;1,0>:d    r123.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r100.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r33.0<1>:d    r100.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               r32.0<1>:d    r6.2<0;1,0>:d     0:w               {F@1}
L15880:
        join (8|M0)                          L15944                                
L15896:
        and (8|M0)               r54.0<1>:d    r18.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r32.0<1>:ud   r54.0<1;0>:ud     r32.0<1;0>:ud     r33.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L15944                  L19144                
L15944:
        join (8|M0)                          L16464                                
L15960:
        and (8|M0)    (ne)f0.1   r46.0<1>:d    r52.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L16040                  L16040                
L15992:
        mov (8|M0)               r62.0<1>:d    -1:w                              
        mov (8|M0)               r77.0<1>:d    -1:w                              
        goto (8|M0)                          L16040                  L16224                
L16040:
        join (8|M0)                          L16224                                
L16056:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r46.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L16160                  L16160                
L16088:
        add (8|M0)               acc0.0<1>:d   r46.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r62.0<1>:d    0:w                              
        shl (8|M0)               r77.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L16160                  L16224                
L16160:
        join (8|M0)                          L16224                                
L16176:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r77.0<1>:d    -1:w                              
        shl (8|M0)               r62.0<1>:d    r6.4<0;1,0>:w     r46.0<1;1,0>:d   {F@1}
L16224:
        join (8|M0)                          L16464                                
L16240:
        bfn.0x28 (8|M0)          r53.0<1>:ud   r23.0<1;0>:ud     r62.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r52.0<1>:ud   r30.0<1;0>:ud     r77.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r53.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -1:w              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r52.0<1;1,0>:d    0:w               {I@3}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    -150:w              
(f1.0)  goto (8|M0)                          L16400                  L16400                
L16352:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f1.1)  sel (8|M0)               r32.0<1>:f    r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L16400                  L19144                
L16400:
        join (8|M0)                          L16464                                
L16416:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (8|M0)               r32.0<1>:f    r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L16464                  L19144                
L16464:
        join (8|M0)                          L18896                                
L16480:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r52.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r98.0<1>:d    r101.0<1;0>:d     r52.0<1;0>:d      81:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L18576                  L18576                
L16544:
        shl (8|M0)               r63.0<1>:d    r37.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r62.0<1>:ud   r37.0<1;1,0>:ud   31:w              
        shl (8|M0)               r57.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r63.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r57.0<1>:d    r57.0<1;1,0>:d    r62.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r57.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r57.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L16776                  L16776                
L16648:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r37.0<1;1,0>:d    39:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r92.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L16776                  L16840                
L16696:
        shr (8|M0)               r123.0<1>:ud  r23.0<1;1,0>:ud   1:w              
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r91.0<1>:d    0:w                              
        mov (8|M0)               r73.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r123.0<1>:f   r23.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L16776                  L18032                
L16776:
        join (8|M0)                          L16840                                
L16792:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r37.0<1;1,0>:d    38:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L16840                  L17952                
L16840:
        join (8|M0)                          L17952                                
L16856:
        add (8|M0)               acc0.0<1>:d   -r37.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r94.0<1>:d    -r37.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r50.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L16936                  L16936                
L16904:
        mov (8|M0)               r85.0<1>:d    r23.0<1;1,0>:d                  
        goto (8|M0)                          L16936                  L17072                
L16936:
        join (8|M0)                          L17072                                
L16952:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r50.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (8|M0)               acc0.0<1>:d   r50.0<1;1,0>:d    -32:w              
(f1.1)  add (8|M0)               acc2.0<1>:d   -r50.0<1;1,0>:d   32:w              
(f1.1)  shr (8|M0)               r49.0<1>:ud   r23.0<1;1,0>:ud   r50.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r110.0<1>:d   r30.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r123.0<1>:ud  r30.0<1;1,0>:ud   acc0.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r123.0<1>:d   r49.0<1;1,0>:d    r110.0<1;1,0>:d  {I@2}
        mov (8|M0)               r85.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@1}
L17072:
        join (8|M0)                          L17952                                
L17088:
        add (8|M0)               r63.0<1>:d    -r37.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r56.0<1>:d    r63.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L17160                  L17160                
L17128:
        mov (8|M0)               r123.0<1>:d   r23.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L17160                  L17288                
L17160:
        join (8|M0)                          L17288                                
L17176:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r56.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r56.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r56.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r47.0<1>:ud   r23.0<1;1,0>:ud   r56.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r124.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r123.0<1>:ud  r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r123.0<1>:d   r47.0<1;1,0>:d    r124.0<1;1,0>:d  {I@2}
L17288:
        join (8|M0)                          L17952                                
L17304:
        and (8|M0)               r91.0<1>:d    r123.0<1;1,0>:d   1:w               {Compacted,I@2}
        and (8|M0)    (ne)f1.1   r123.0<1>:d   r63.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L17392                  L17392                
L17344:
        mov (8|M0)               r25.0<1>:d    -1:w                              
        mov (8|M0)               r34.0<1>:d    -1:w                              
        goto (8|M0)                          L17392                  L17576                
L17392:
        join (8|M0)                          L17576                                
L17408:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r123.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L17512                  L17512                
L17440:
        add (8|M0)               acc0.0<1>:d   r123.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r25.0<1>:d    0:w                              
        shl (8|M0)               r34.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L17512                  L17576                
L17512:
        join (8|M0)                          L17576                                
L17528:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r34.0<1>:d    -1:w                              
        shl (8|M0)               r25.0<1>:d    r6.4<0;1,0>:w     r123.0<1;1,0>:d  {F@1}
L17576:
        join (8|M0)                          L17952                                
L17592:
        bfn.0x28 (8|M0)          r46.0<1>:ud   r23.0<1;0>:ud     r25.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r45.0<1>:ud   r30.0<1;0>:ud     r34.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r46.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.1   r55.0<1>:d    r94.0<1;1,0>:d    63:w              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r45.0<1;1,0>:d    0:w               {I@3}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r74.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L17768                  L17768                
L17736:
        mov (8|M0)               r123.0<1>:d   r23.0<1;1,0>:d                  
        goto (8|M0)                          L17768                  L17896                
L17768:
        join (8|M0)                          L17896                                
L17784:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r55.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r55.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r55.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r42.0<1>:ud   r23.0<1;1,0>:ud   r55.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r122.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r123.0<1>:ud  r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r123.0<1>:d   r42.0<1;1,0>:d    r122.0<1;1,0>:d  {I@2}
L17896:
        join (8|M0)                          L17952                                
L17912:
        mov (8|M0)               r73.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r123.0<1>:d   r85.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L17952                  L18032                
L17952:
        join (8|M0)                          L18032                                
L17968:
        shr (8|M0)               r123.0<1>:ud  r23.0<1;1,0>:ud   2:w              
        and (8|M0)               r91.0<1>:d    r23.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r73.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r123.0<1>:ud  r23.0<1;1,0>:ud   1:w               {F@1}
L18032:
        join (8|M0)                          L18576                                
L18048:
        shl (8|M0)               r96.0<1>:d    r123.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r41.0<1>:d    r91.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r96.0<1>:d    r96.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r78.0<1>:d    r73.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r45.0<1>:ud   r96.0<1;0>:ud     r41.0<1;0>:ud     r74.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L18168                  L18168                
L18136:
        mov (8|M0)               r44.0<1>:d    0:w                              
        goto (8|M0)                          L18168                  L18328                
L18168:
        join (8|M0)                          L18328                                
L18184:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r45.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L18248                  L18248                
L18216:
        mov (8|M0)               r44.0<1>:d    1:w                              
        goto (8|M0)                          L18248                  L18328                
L18248:
        join (8|M0)                          L18328                                
L18264:
        and (8|M0)    (ne)f1.0   null<1>:d     r73.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r44.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L18328:
        join (8|M0)                          L18576                                
L18344:
        add (8|M0)               r127.0<1>:d   r78.0<1;1,0>:d    r44.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r125.0<1>:d   r101.0<1;0>:d     r52.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r127.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r110.0<1>:d   r125.0<1;1,0>:d   r98.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r110.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (8|M0)                          L18504                  L18504                
L18432:
(~f0.1) sel (8|M0)               r20.0<1>:d    r127.0<1;1,0>:d   0:w              
        and (8|M0)               r124.0<1>:d   r18.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r40.0<1>:d    r110.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r32.0<1>:ud   r124.0<1;0>:ud    r40.0<1;0>:ud     r20.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L18504                  L19144                
L18504:
        join (8|M0)                          L18576                                
L18520:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r32.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L18576                  L19144                
L18576:
        join (8|M0)                          L18896                                
L18592:
        and (8|M0)    (ne)f1.0   r120.0<1>:d   r52.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L18656                  L18656                
L18624:
        mov (8|M0)               r28.0<1>:d    -1:w                              
        goto (8|M0)                          L18656                  L18784                
L18656:
        join (8|M0)                          L18784                                
L18672:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r120.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L18736                  L18736                
L18704:
        mov (8|M0)               r28.0<1>:d    0:w                              
        goto (8|M0)                          L18736                  L18784                
L18736:
        join (8|M0)                          L18784                                
L18752:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r28.0<1>:d    r6.4<0;1,0>:w     r120.0<1;1,0>:d  {F@1}
L18784:
        join (8|M0)                          L18896                                
L18800:
        bfn.0x28 (8|M0)          r43.0<1>:ud   r23.0<1;0>:ud     r28.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r52.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r123.0<1>:d   r18.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r38.0<1>:d    r98.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r43.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r32.0<1>:ud   r123.0<1;0>:ud    r38.0<1;0>:ud     r43.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L18896                  L19144                
L18896:
        join (8|M0)                          L18968                                
L18912:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r32.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L18968                  L19144                
L18968:
        join (8|M0)                          L19040                                
L18984:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r18.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (8|M0)               r32.0<1>:f    r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L19040                  L19144                
L19040:
        join (8|M0)                          L19112                                
L19056:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r32.0<1>:f    r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L19112                  L19144                
L19112:
        join (8|M0)                          L19144                                
L19128:
        bfn.0xF8 (8|M0)          r32.0<1>:ud   r18.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L19144:
        join (8|M0)                          L30264                                
L19160:
        shr (8|M0)               r82.0<1>:ud   r32.0<1;1,0>:ud   23:w               {I@2}
        and (8|M0)    (ne)f0.1   r21.0<1>:d    r32.0<1;1,0>:d    8388607:d              
        and (8|M0)               r11.0<1>:d    r82.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r11.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L19256                  L19256                
L19232:
        mov (8|M0)               r32.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L19256                  L23592                
L19256:
        join (8|M0)                          L23592                                
L19272:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r21.0<1;1,0>:d    0:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r11.0<1;1,0>:d    255:w              
(f1.1)  goto (8|M0)                          L23592                  L23592                
L19320:
        or (8|M0)     (eq)f1.1   null<1>:d     r11.0<1;1,0>:d    r21.0<1;1,0>:d  
(~f1.1) goto (8|M0)                          L19384                  L19384                
L19352:
        mov (8|M0)               r32.0<1>:f    0x3F650000:f                              
        goto (8|M0)                          L19384                  L23592                
L19384:
        join (8|M0)                          L23592                                
L19400:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r32.0<1;1,0>:d    -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r11.0<1;1,0>:ud   0x7E:uw             
(f1.0)  goto (8|M0)                          L19672                  L19672                
L19448:
(f1.1)  goto (8|M0)                          L19560                  L19560                
L19464:
        mov (8|M0)               r78.0<1>:f    0x3F650000:f                              
        mov (8|M0)               r117.0<1>:f   r32.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L43752                                 {A@1}
L19536:
        mov (8|M0)               r32.0<1>:f    r102.0<1;1,0>:f                  {Compacted,I@5}
        goto (8|M0)                          L19560                  L23592                
L19560:
        join (8|M0)                          L19672                                
L19576:
        mov (8|M0)               r78.0<1>:f    r32.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r117.0<1>:f   0x3F650000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L43752                                 {A@1}
L19648:
        mov (8|M0)               r32.0<1>:f    r102.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L19672                  L23592                
L19672:
        join (8|M0)                          L23592                                
L19688:
(f1.1)  goto (8|M0)                          L21792                  L21792                
L19704:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r11.0<1;1,0>:d    0:w              
        add (8|M0)               r122.0<1>:d   -r11.0<1;1,0>:d   126:w               {Compacted}
(f1.0)  sel (8|M0)               r30.0<1>:d    r122.0<1;1,0>:d   125:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r30.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L20880                  L20880                
L19776:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  goto (8|M0)                          L20472                  L20472                
L19800:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r30.0<1;1,0>:ud   0x18:uw             
(f1.1)  goto (8|M0)                          L20232                  L20232                
L19832:
        cmp (8|M0)    (ne)f0.0   r109.0<1>:d   r11.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r30.0<1;1,0>:d    25:w              
        mov (8|M0)               r27.0<1>:d    -r109.0<1;1,0>:d                 {I@2}
(f1.0)  goto (8|M0)                          L20040                  L20040                
L19896:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r30.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f1.1   r121.0<1>:d   r21.0<1;1,0>:d    0:w              
        cmp (8|M0)    (ne)f1.0   r37.0<1>:d    r32.0<1;1,0>:d    0:w               {F@1}
(f0.1)  sel (8|M0)               r27.0<1>:d    -r109.0<1;1,0>:d  0:w              
(f0.1)  sel (8|M0)               acc0.0<1>:d   -r121.0<1;1,0>:d  -r37.0<1;1,0>:d  {I@2}
        mov (8|M0)               r28.0<1>:f    r27.0<1;1,0>:f                   {Compacted,I@2}
        shl (8|M0)               r111.0<1>:d   acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r27.0<1>:d    0:w                               {F@1}
        asr (8|M0)               r102.0<1>:d   r111.0<1;1,0>:d   31:w               {Compacted,I@2}
        goto (8|M0)                          L20040                  L20112                
L20040:
        join (8|M0)                          L20112                                
L20056:
        shr (8|M0)               r36.0<1>:ud   r32.0<1;1,0>:ud   22:w              
        and (8|M0)               r35.0<1>:d    r32.0<1;1,0>:d    4194303:d              
        and (8|M0)               r28.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r102.0<1>:d   r35.0<1;1,0>:d    0:w               {I@2}
L20112:
        join (8|M0)                          L20232                                
L20128:
        cmp (8|M0)    (ne)f1.0   r34.0<1>:d    r102.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.8<2>:b     126:w                              
        mov (8|M0)               r24.0<1>:f    9.275385e-39:f                              
        mov (8|M0)               r97.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r13.0<1>:b    r6.8<0;1,0>:b                    {I@1}
        mov (8|M0)               r67.0<1>:d    -r34.0<1;1,0>:d                 
        goto (8|M0)                          L20232                  L21376                
L20232:
        join (8|M0)                          L20472                                
L20248:
        add (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r30.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r83.0<1>:d    -r30.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r33.0<1>:ud   r21.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r34.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r40.0<1>:ud   r21.0<1;1,0>:ud   r30.0<1;1,0>:d  
        shr (8|M0)               r11.0<1>:ud   r21.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r56.0<1>:ud   r34.0<1;0>:ud     r7.7<0;0>:ud      r21.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r83.0<1>:d    r6.4<0;1,0>:w     r83.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r83.0<1>:d    0:w                              
        and (8|M0)               r50.0<1>:d    r33.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r27.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r108.0<1>:d   r56.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r49.0<1>:d    r40.0<1;1,0>:d    r83.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L20472                  L20560                
L20472:
        join (8|M0)                          L20560                                
L20488:
        and (8|M0)               r27.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r49.0<1>:ud   r21.0<1;1,0>:ud   1:w              
(f1.0)  goto (8|M0)                          L20560                  L20768                
L20528:
        mov (8|M0)               r50.0<1>:d    0:w                              
        mov (8|M0)               r108.0<1>:d   0:w                              
L20560:
        join (8|M0)                          L20768                                
L20576:
        cmp (8|M0)    (ne)f0.0   r26.0<1>:d    r108.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r49.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r24.0<1>:d    r49.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r67.0<1>:d    -r26.0<1;1,0>:d                  {I@3}
(f0.1)  goto (8|M0)                          L20712                  L20712                
L20656:
(W)     mov (1|M0)               r6.8<2>:b     126:w                              
        mov (8|M0)               r97.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r13.0<1>:b    r6.8<0;1,0>:b                    {I@1}
        goto (8|M0)                          L20712                  L21376                
L20712:
        join (8|M0)                          L20768                                
L20728:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r50.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) sel (8|M0)               r67.0<1>:d    -r26.0<1;1,0>:d   1:w              
        goto (8|M0)                          L20768                  L20816                
L20768:
        join (8|M0)                          L20816                                
L20784:
        add (8|M0)               r24.0<1>:d    r49.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r67.0<1>:d    0:w                              
L20816:
        join (8|M0)                          L20880                                
L20832:
        shr (8|M0)               r32.0<1>:ud   r24.0<1;1,0>:ud   1:w               {I@3}
        and (8|M0)               r25.0<1>:d    r32.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L20880                  L21288                
L20880:
        join (8|M0)                          L21288                                
L20896:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r21.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r24.0<1>:d    r21.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L21176                  L21176                
L20944:
(f1.0)  goto (8|M0)                          L21056                  L21056                
L20960:
(W)     mov (1|M0)               r6.8<2>:b     126:w                              
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r97.0<1>:d    0:w                               {F@1}
        mov (8|M0)               r67.0<1>:d    0:w                              
        mov (8|M0)               r13.0<1>:b    r6.8<0;1,0>:b                    {I@4}
        goto (8|M0)                          L21056                  L21376                
L21056:
        join (8|M0)                          L21176                                
L21072:
(W)     mov (1|M0)               r6.8<2>:b     127:w                              
        and (8|M0)               r27.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r24.0<1>:ud   r24.0<1;1,0>:ud   1:w              
        mov (8|M0)               r97.0<1>:d    0:w                              
        mov (8|M0)               r67.0<1>:d    0:w                              
        mov (8|M0)               r13.0<1>:b    r6.8<0;1,0>:b                    {I@5}
        goto (8|M0)                          L21176                  L21376                
L21176:
        join (8|M0)                          L21288                                
L21192:
        shr (8|M0)               r125.0<1>:ud  r24.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r67.0<1>:d    0:w                              
        and (8|M0)               r120.0<1>:d   r125.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r125.0<1>:d   r125.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r27.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r25.0<1>:d    r125.0<1;1,0>:d   r120.0<1;1,0>:d  {I@2}
L21288:
        join (8|M0)                          L21376                                
L21304:
        and (8|M0)               acc0.0<1>:d   r24.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r6.8<2>:b     127:w                              
        mov (8|M0)               r97.0<1>:f    r27.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r24.0<1>:f    r25.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r27.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r13.0<1>:b    r6.8<0;1,0>:b                    {I@2}
L21376:
        join (8|M0)                          L21792                                
L21392:
        shl (8|M0)               r26.0<1>:d    r27.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r31.0<1>:d    r97.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r121.0<1>:ud  r26.0<1;0>:ud     r31.0<1;0>:ud     r67.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r121.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L21488                  L21488                
L21456:
        mov (8|M0)               r127.0<1>:d   0:w                              
        goto (8|M0)                          L21488                  L21648                
L21488:
        join (8|M0)                          L21648                                
L21504:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r121.0<1;1,0>:ud  0x4:uw             
(~f0.0) goto (8|M0)                          L21568                  L21568                
L21536:
        mov (8|M0)               r127.0<1>:d   1:w                              
        goto (8|M0)                          L21568                  L21648                
L21568:
        join (8|M0)                          L21648                                
L21584:
        and (8|M0)    (ne)f0.0   null<1>:d     r24.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r121.0<1;1,0>:d   4:w              
(f0.0)  sel (8|M0)               r127.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L21648:
        join (8|M0)                          L21792                                
L21664:
        add (8|M0)               r80.0<1>:d    r24.0<1;1,0>:d    r127.0<1;1,0>:d  {Compacted,I@2}
        mov (8|M0)               r79.0<1>:d    r13.0<1;1,0>:ub                 
        cmp (8|M0)    (eq)f0.1   r119.0<1>:d   r80.0<1;1,0>:d    8388608:d               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r79.0<1;0>:d      -r119.0<1;0>:d    0:w               {I@2}
(f1.0)  mov (8|M0)               r80.0<1>:d    0:w                              
        shl (8|M0)               r79.0<1>:d    acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r32.0<1>:d    r79.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@1}
        goto (8|M0)                          L21792                  L23592                
L21792:
        join (8|M0)                          L23592                                
L21808:
        mov (8|M0)               r13.0<1>:b    r82.0<4;1,0>:b                  
        cmp (8|M0)    (eq)f1.1   null<1>:w     r13.0<1;1,0>:b    127:w               {I@1}
(~f1.1) goto (8|M0)                          L21936                  L21936                
L21856:
        mov (8|M0)               r33.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:d    0:w                              
        mov (8|M0)               r87.0<1>:d    0:w                              
        mov (8|M0)               r96.0<1>:f    0x728000:f                              
        goto (8|M0)                          L21936                  L22632                
L21936:
        join (8|M0)                          L22632                                
L21952:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r13.0<1;1,0>:b    126:w              
(f1.0)  goto (8|M0)                          L22632                  L22840                
L21984:
        add (8|M0)               r53.0<1>:d    r11.0<1;1,0>:d    -126:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r53.0<1;1,0>:ud   0x18:uw              {I@1}
(f0.1)  goto (8|M0)                          L22408                  L22408                
L22024:
        cmp (8|M0)    (lt)f0.0   null<1>:w     r13.0<1;1,0>:b    -105:w              
(f0.0)  goto (8|M0)                          L22168                  L22168                
L22056:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r13.0<1;1,0>:b    -105:w              
(~f1.1) goto (8|M0)                          L22168                  L22216                
L22088:
        mov (8|M0)               r33.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:d    1:w                              
        mov (8|M0)               r87.0<1>:d    -1:w                              
        mov (8|M0)               r96.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L22168                  L22632                
L22168:
        join (8|M0)                          L22216                                
L22184:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r13.0<1;1,0>:b    -106:w              
(f1.0)  goto (8|M0)                          L22216                  L22312                
L22216:
        join (8|M0)                          L22312                                
L22232:
        mov (8|M0)               r33.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:d    0:w                              
        mov (8|M0)               r87.0<1>:d    -1:w                              
        mov (8|M0)               r96.0<1>:d    0:w                              
        goto (8|M0)                          L22312                  L22632                
L22312:
        join (8|M0)                          L22408                                
L22328:
        mov (8|M0)               r33.0<1>:d    1:w                              
        mov (8|M0)               r75.0<1>:d    1:w                              
        mov (8|M0)               r87.0<1>:d    -1:w                              
        mov (8|M0)               r96.0<1>:d    0:w                              
        goto (8|M0)                          L22408                  L22632                
L22408:
        join (8|M0)                          L22632                                
L22424:
(W)     mov (1|M0)               r6.3<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r11.0<1;1,0>:d    -128:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r11.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r76.0<1>:d    -r11.0<1;1,0>:d   149:w               {Compacted}
        shr (8|M0)               r30.0<1>:ud   r6.3<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r74.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r49.0<1>:ud   r6.3<0;1,0>:ud    r53.0<1;1,0>:d  
        shr (8|M0)               r27.0<1>:ud   r6.3<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r74.0<1>:d    r74.0<1;1,0>:d    6619136:d              
        shl (8|M0)               r76.0<1>:d    r6.4<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
        and (8|M0)               r75.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r33.0<1>:d    r27.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f1.1   r87.0<1>:d    r74.0<1;1,0>:d    6619136:d               {I@4}
        or (8|M0)                r96.0<1>:d    r49.0<1;1,0>:d    r76.0<1;1,0>:d   {Compacted,I@4}
L22632:
        join (8|M0)                          L22840                                
L22648:
        add (8|M0)               r26.0<1>:d    r21.0<1;1,0>:d    r96.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.0   r31.0<1>:d    r87.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r26.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        mov (8|M0)               r70.0<1>:d    -r31.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L22752                  L22752                
L22720:
        mov (8|M0)               r61.0<1>:d    r75.0<1;1,0>:d                  
        goto (8|M0)                          L22752                  L23128                
L22752:
        join (8|M0)                          L22840                                
L22768:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r75.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r29.0<1>:ud   r26.0<1;1,0>:ud   1:w              
        and (8|M0)               r126.0<1>:d   r29.0<1;1,0>:d    4194303:d               {I@1}
(~f0.0) sel (8|M0)               r70.0<1>:d    -r31.0<1;1,0>:d   1:w              
        goto (8|M0)                          L22840                  L23064                
L22840:
        join (8|M0)                          L23064                                
L22856:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r21.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r26.0<1>:d    r21.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L22984                  L22984                
L22904:
        and (8|M0)               r33.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r26.0<1>:ud   r26.0<1;1,0>:ud   1:w               {I@3}
        add (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r61.0<1>:d    0:w                              
        mov (8|M0)               r70.0<1>:d    0:w                              
        goto (8|M0)                          L22984                  L23128                
L22984:
        join (8|M0)                          L23064                                
L23000:
        shr (8|M0)               r28.0<1>:ud   r26.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r33.0<1>:d    0:w                              
        or (8|M0)                r126.0<1>:d   r28.0<1;1,0>:d    4194304:d               {I@3}
L23064:
        join (8|M0)                          L23128                                
L23080:
        and (8|M0)               acc0.0<1>:d   r26.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r61.0<1>:f    r33.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r26.0<1>:f    r126.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r33.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L23128:
        join (8|M0)                          L23592                                
L23144:
        shl (8|M0)               r31.0<1>:d    r33.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r27.0<1>:d    r61.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r126.0<1>:ud  r31.0<1;0>:ud     r27.0<1;0>:ud     r70.0<1>:ud      {A@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (8|M0)                          L23240                  L23240                
L23208:
        mov (8|M0)               r20.0<1>:d    0:w                              
        goto (8|M0)                          L23240                  L23400                
L23240:
        join (8|M0)                          L23400                                
L23256:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r126.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (8|M0)                          L23320                  L23320                
L23288:
        mov (8|M0)               r20.0<1>:d    1:w                              
        goto (8|M0)                          L23320                  L23400                
L23320:
        join (8|M0)                          L23400                                
L23336:
        and (8|M0)    (ne)f1.1   null<1>:d     r26.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r20.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L23400:
        join (8|M0)                          L23592                                
L23416:
        add (8|M0)               r19.0<1>:d    r26.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.0   r26.0<1>:d    r19.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r19.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r107.0<1>:d   r11.0<1;0>:d      -r26.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r107.0<1;1,0>:d   255:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L23520                  L23520                
L23496:
        mov (8|M0)               r32.0<1>:f    inf:f                               {Compacted}
        goto (8|M0)                          L23520                  L23592                
L23520:
        join (8|M0)                          L23592                                
L23536:
(~f0.1) sel (8|M0)               r19.0<1>:d    r19.0<1;1,0>:d    0:w              
        and (8|M0)               r118.0<1>:d   r32.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (8|M0)               r25.0<1>:d    r107.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r32.0<1>:ud   r118.0<1;0>:ud    r25.0<1;0>:ud     r19.0<1>:ud      {I@1} // s0|s1|s2
L23592:
        join (8|M0)                          L30264                                
L23608:
        shr (8|M0)               r70.0<1>:ud   r12.0<1;1,0>:ud   23:w              
        and (8|M0)    (ne)f1.0   r64.0<1>:d    r12.0<1;1,0>:d    8388607:d              
        and (8|M0)               r98.0<1>:d    r70.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L23704                  L23704                
L23680:
        mov (8|M0)               r20.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L23704                  L30216                
L23704:
        join (8|M0)                          L30216                                
L23720:
        mov (8|M0)               r13.0<1>:hf   r32.0<1;1,0>:f                  
        mov (8|M0)               r42.0<1>:f    r13.0<1;1,0>:hf                  {F@1}
        shr (8|M0)               r62.0<1>:ud   r42.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.1   r56.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (8|M0)               r95.0<1>:d    r62.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L23848                  L23848                
L23824:
        mov (8|M0)               r20.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L23848                  L30216                
L23848:
        join (8|M0)                          L30216                                
L23864:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        xor (8|M0)               r17.0<1>:d    r12.0<1;1,0>:d    r42.0<1;1,0>:d   {Compacted}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    255:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    255:w              
(f1.0)  sel (8|M0)               r13.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (8|M0)               r12.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.1   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@1}
(f1.1)  goto (8|M0)                          L30184                  L30184                
L24016:
        or (8|M0)     (eq)f0.0   null<1>:d     r95.0<1;1,0>:d    r56.0<1;1,0>:d  
        or (8|M0)                r24.0<1>:d    r98.0<1;1,0>:d    r64.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    0:w               {I@1}
(~f0.0) goto (8|M0)                          L24096                  L24096                
L24072:
        mov (8|M0)               r20.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L24096                  L30216                
L24096:
        join (8|M0)                          L30184                                
L24112:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r98.0<1;1,0>:d    0:w               {Compacted}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    0:w              
        add (8|M0)               r115.0<1>:d   r98.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r114.0<1>:d   r95.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (8|M0)               r115.0<1>:d   -126:w                              
(f1.1)  mov (8|M0)               r114.0<1>:d   -126:w                              
        add (8|M0)               r100.0<1>:d   r115.0<1;1,0>:d   r114.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r100.0<1;1,0>:d   127:w               {I@1}
(f1.0)  goto (8|M0)                          L30112                  L30112                
L24224:
        or (8|M0)     (eq)f0.1   null<4>:b     r70.0<1;1,0>:d    r62.0<1;1,0>:d  
(f0.1)  goto (8|M0)                          L30040                  L30040                
L24256:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r6.4<0;1,0>:w     8388608:d              
        or (8|M0)                r33.0<1>:d    acc0.0<1;1,0>:d   r64.0<1;1,0>:d  
        or (8|M0)                r28.0<1>:d    acc2.0<1;1,0>:d   r56.0<1;1,0>:d  
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r33.0<1;1,0>:ud   r28.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r112.0<1>:ud  r33.0<1;1,0>:ud   r28.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r31.0<1>:f    r112.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r25.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L24432:
(W)     shl (1|M0)               r12.1<1>:d    r6.3<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r12.1<0;1,0>:d   {I@2}
        bfn.0xA8 (8|M0)          r41.0<1>:ud   r25.0<1;0>:ud     r6.7<0;0>:ud      r12.1<0>:ud      // s0&(s1|s2)
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r41.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r40.0<1>:d    r31.0<1;1,0>:d    r6.2<0;1,0>:d    {Compacted,A@1}
(W)     addc (1|M0)              r14.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r40.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r12.4<1>:ud   r12.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f0.0)  sel (8|M0)               r12.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r118.0<1>:d   r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.0   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r124.0<1>:d   r6.5<0;1,0>:d                   
        mov (8|M0)               r35.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r90.0<1>:d    r12.4<0;1,0>:d                  
(f1.0)  goto (8|M0)                          L24840                  L24840                
L24776:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r12.4<0;1,0>:d                  
(W)     jmpi                                 L24432                                
L24840:
        join (8|M0)                          L30040                                
L24856:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r12.0<1>:hf   0.0:hf                             
        subb (8|M0)              r50.0<1>:ud   r6.2<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r80.0<1>:d    r100.0<1;0>:d     r50.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r86.0<1>:ud   -acc0.0<1;0>:ud   r12.0<0;0>:uw     -r124.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r80.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r67.0<1>:d    r115.0<1;0>:d     r114.0<1;0>:d     r50.0<1>:d      
(f0.0)  goto (8|M0)                          L29968                  L29968                
L24976:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r80.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L27544                  L27544                
L25008:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r80.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L27024                  L27024                
L25040:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r55.0<1>:d    r100.0<1;0>:d     r50.0<1;0>:d      104:w              
        subb (8|M0)              r100.0<1>:ud  r6.2<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r12.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r100.0<1;1,0>:ud  r55.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r119.0<1>:ud  -acc0.0<1;0>:ud   r12.0<0;0>:uw     -r124.0<1>:ud    {F@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r119.0<1;1,0>:d   0:w               {I@1}
(~f0.0) cmp (8|M0)    (gt)f0.0   null<1>:ud    r119.0<1;1,0>:ud  0x0:uw             
(f0.0)  goto (8|M0)                          L25240                  L25240                
L25176:
        add3 (8|M0)              acc0.0<1>:d   r67.0<1;0>:d      -r100.0<1;0>:d    104:w              
        shl (8|M0)               r24.0<1>:d    r25.0<1;1,0>:d    acc0.0<1;1,0>:d 
        mov (8|M0)               r23.0<1>:d    0:w                              
        goto (8|M0)                          L25240                  L26960                
L25240:
        join (8|M0)                          L26960                                
L25256:
        add3 (8|M0)              r84.0<1>:d    r100.0<1;0>:d     -r67.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r84.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (8|M0)                          L25392                  L25392                
L25304:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r84.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (8|M0)                          L25392                  L25440                
L25328:
        shr (8|M0)               r122.0<1>:ud  r25.0<1;1,0>:ud   1:w              
        and (8|M0)               r82.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r48.0<1>:d    0:w                              
        mov (8|M0)               r33.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L25392                  L26392                
L25392:
        join (8|M0)                          L25440                                
L25408:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L25440                  L26336                
L25440:
        join (8|M0)                          L26336                                
L25456:
        add3 (8|M0)              acc0.0<1>:d   r100.0<1;0>:d     -r55.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.0   r27.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L25536                  L25536                
L25504:
        mov (8|M0)               r76.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L25536                  L25672                
L25536:
        join (8|M0)                          L25672                                
L25552:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r27.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r27.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r27.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r20.0<1>:ud   r25.0<1;1,0>:ud   r27.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r60.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r122.0<1>:ud  r31.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r122.0<1>:d   r20.0<1;1,0>:d    r60.0<1;1,0>:d   {I@2}
        mov (8|M0)               r76.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@1}
L25672:
        join (8|M0)                          L26336                                
L25688:
        add3 (8|M0)              r47.0<1>:d    r100.0<1;0>:d     -r55.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.0   r26.0<1>:d    r47.0<1;1,0>:d    63:w               {I@1}
(f0.0)  goto (8|M0)                          L25768                  L25768                
L25736:
        mov (8|M0)               r122.0<1>:d   r25.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L25768                  L25896                
L25768:
        join (8|M0)                          L25896                                
L25784:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r26.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r26.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r26.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r18.0<1>:ud   r25.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r59.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r122.0<1>:ud  r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r122.0<1>:d   r18.0<1;1,0>:d    r59.0<1;1,0>:d   {I@2}
L25896:
        join (8|M0)                          L26336                                
L25912:
        and (8|M0)    (ne)f1.0   r58.0<1>:d    r47.0<1;1,0>:d    63:w              
        and (8|M0)               r82.0<1>:d    r122.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L26000                  L26000                
L25952:
        mov (8|M0)               r74.0<1>:d    -1:w                              
        mov (8|M0)               r95.0<1>:d    -1:w                              
        goto (8|M0)                          L26000                  L26184                
L26000:
        join (8|M0)                          L26184                                
L26016:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r58.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L26120                  L26120                
L26048:
        add (8|M0)               acc0.0<1>:d   r58.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r74.0<1>:d    0:w                              
        shl (8|M0)               r95.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L26120                  L26184                
L26120:
        join (8|M0)                          L26184                                
L26136:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r95.0<1>:d    -1:w                              
        shl (8|M0)               r74.0<1>:d    r6.4<0;1,0>:w     r58.0<1;1,0>:d   {F@1}
L26184:
        join (8|M0)                          L26336                                
L26200:
        bfn.0x28 (8|M0)          r16.0<1>:ud   r25.0<1;0>:ud     r74.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r15.0<1>:ud   r31.0<1;0>:ud     r95.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r33.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r15.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r48.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L26336                  L26392                
L26336:
        join (8|M0)                          L26392                                
L26352:
        mov (8|M0)               r48.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r33.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
L26392:
        join (8|M0)                          L26960                                
L26408:
        and (8|M0)    (ne)f0.0   r24.0<1>:d    r84.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L26472                  L26472                
L26440:
        mov (8|M0)               r122.0<1>:d   r25.0<1;1,0>:d                  
        goto (8|M0)                          L26472                  L26600                
L26472:
        join (8|M0)                          L26600                                
L26488:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r24.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r24.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r24.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r12.0<1>:ud   r25.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r57.0<1>:d    r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r122.0<1>:ud  r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r122.0<1>:d   r12.0<1;1,0>:d    r57.0<1;1,0>:d   {I@2}
L26600:
        join (8|M0)                          L26960                                
L26616:
        shl (8|M0)               r18.0<1>:d    r33.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r11.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r18.0<1>:d    r18.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r110.0<1>:ud  r18.0<1;0>:ud     r11.0<1;0>:ud     r48.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (8|M0)                          L26720                  L26720                
L26688:
        mov (8|M0)               r120.0<1>:d   0:w                              
        goto (8|M0)                          L26720                  L26880                
L26720:
        join (8|M0)                          L26880                                
L26736:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r110.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (8|M0)                          L26800                  L26800                
L26768:
        mov (8|M0)               r120.0<1>:d   1:w                              
        goto (8|M0)                          L26800                  L26880                
L26800:
        join (8|M0)                          L26880                                
L26816:
        and (8|M0)    (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   4:w              
(f1.0)  sel (8|M0)               r120.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L26880:
        join (8|M0)                          L26960                                
L26896:
        add (8|M0)               r97.0<1>:d    r120.0<1;1,0>:d   r122.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r97.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.0) sel (8|M0)               r24.0<1>:d    r97.0<1;1,0>:d    0:w              
(f0.0)  sel (8|M0)               r23.0<1>:d    r6.2<0;1,0>:d     0:w               {F@1}
L26960:
        join (8|M0)                          L27024                                
L26976:
        and (8|M0)               r127.0<1>:d   r17.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r20.0<1>:ud   r127.0<1;0>:ud    r23.0<1;0>:ud     r24.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L27024                  L30216                
L27024:
        join (8|M0)                          L27544                                
L27040:
        and (8|M0)    (ne)f0.0   r26.0<1>:d    r50.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L27120                  L27120                
L27072:
        mov (8|M0)               r41.0<1>:d    -1:w                              
        mov (8|M0)               r56.0<1>:d    -1:w                              
        goto (8|M0)                          L27120                  L27304                
L27120:
        join (8|M0)                          L27304                                
L27136:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r26.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L27240                  L27240                
L27168:
        add (8|M0)               acc0.0<1>:d   r26.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r41.0<1>:d    0:w                              
        shl (8|M0)               r56.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L27240                  L27304                
L27240:
        join (8|M0)                          L27304                                
L27256:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r56.0<1>:d    -1:w                              
        shl (8|M0)               r41.0<1>:d    r6.4<0;1,0>:w     r26.0<1;1,0>:d   {F@1}
L27304:
        join (8|M0)                          L27544                                
L27320:
        bfn.0x28 (8|M0)          r126.0<1>:ud  r25.0<1;0>:ud     r41.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r125.0<1>:ud  r31.0<1;0>:ud     r56.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r126.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r17.0<1;1,0>:d    -1:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@3}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r80.0<1;1,0>:d    -150:w              
(f1.0)  goto (8|M0)                          L27480                  L27480                
L27432:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f0.1)  sel (8|M0)               r20.0<1>:f    r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L27480                  L30216                
L27480:
        join (8|M0)                          L27544                                
L27496:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (8|M0)               r20.0<1>:f    r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L27544                  L30216                
L27544:
        join (8|M0)                          L29968                                
L27560:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r50.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r97.0<1>:d    r100.0<1;0>:d     r50.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L29648                  L29648                
L27624:
        shl (8|M0)               r55.0<1>:d    r35.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r54.0<1>:ud   r35.0<1;1,0>:ud   31:w              
        shl (8|M0)               r48.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r55.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r48.0<1>:d    r48.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r48.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r48.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L27848                  L27848                
L27728:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r35.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r90.0<1;1,0>:d    0:w              
(~f0.0) goto (8|M0)                          L27848                  L27912                
L27768:
        shr (8|M0)               r122.0<1>:ud  r25.0<1;1,0>:ud   1:w              
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r89.0<1>:d    0:w                              
        mov (8|M0)               r72.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r122.0<1>:f   r25.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L27848                  L29104                
L27848:
        join (8|M0)                          L27912                                
L27864:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r35.0<1;1,0>:d    38:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L27912                  L29024                
L27912:
        join (8|M0)                          L29024                                
L27928:
        add (8|M0)               acc0.0<1>:d   -r35.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r92.0<1>:d    -r35.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r43.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L28008                  L28008                
L27976:
        mov (8|M0)               r84.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L28008                  L28144                
L28008:
        join (8|M0)                          L28144                                
L28024:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r43.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (8|M0)               acc0.0<1>:d   r43.0<1;1,0>:d    -32:w              
(f0.0)  add (8|M0)               acc2.0<1>:d   -r43.0<1;1,0>:d   32:w              
(~f0.0) shr (8|M0)               r122.0<1>:ud  r31.0<1;1,0>:ud   acc0.0<1;1,0>:d  {F@1}
(f0.0)  shl (8|M0)               r94.0<1>:d    r31.0<1;1,0>:d    acc2.0<1;1,0>:d 
(f0.0)  shr (8|M0)               r122.0<1>:ud  r25.0<1;1,0>:ud   r43.0<1;1,0>:d  
(f0.0)  or (8|M0)                r122.0<1>:d   r122.0<1;1,0>:d   r94.0<1;1,0>:d   {I@1}
        mov (8|M0)               r84.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@1}
L28144:
        join (8|M0)                          L29024                                
L28160:
        add (8|M0)               r60.0<1>:d    -r35.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.1   r47.0<1>:d    r60.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L28232                  L28232                
L28200:
        mov (8|M0)               r122.0<1>:d   r25.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L28232                  L28360                
L28232:
        join (8|M0)                          L28360                                
L28248:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r47.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r47.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r47.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r120.0<1>:ud  r25.0<1;1,0>:ud   r47.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r109.0<1>:d   r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r122.0<1>:ud  r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r122.0<1>:d   r120.0<1;1,0>:d   r109.0<1;1,0>:d  {I@2}
L28360:
        join (8|M0)                          L29024                                
L28376:
        and (8|M0)    (ne)f0.1   r108.0<1>:d   r60.0<1;1,0>:d    63:w              
        and (8|M0)               r89.0<1>:d    r122.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L28464                  L28464                
L28416:
        mov (8|M0)               r121.0<1>:d   -1:w                              
        mov (8|M0)               r24.0<1>:d    -1:w                              
        goto (8|M0)                          L28464                  L28648                
L28464:
        join (8|M0)                          L28648                                
L28480:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r108.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.0)  goto (8|M0)                          L28584                  L28584                
L28512:
        add (8|M0)               acc0.0<1>:d   r108.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r121.0<1>:d   0:w                              
        shl (8|M0)               r24.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L28584                  L28648                
L28584:
        join (8|M0)                          L28648                                
L28600:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r24.0<1>:d    -1:w                              
        shl (8|M0)               r121.0<1>:d   r6.4<0;1,0>:w     r108.0<1;1,0>:d  {F@1}
L28648:
        join (8|M0)                          L29024                                
L28664:
        bfn.0x28 (8|M0)          r119.0<1>:ud  r25.0<1;0>:ud     r121.0<1;0>:ud    r7.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r118.0<1>:ud  r31.0<1;0>:ud     r24.0<1;0>:ud     r7.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r119.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.1   r46.0<1>:d    r92.0<1;1,0>:d    63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r118.0<1;1,0>:d   0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r70.0<1>:d    -acc0.0<1;1,0>:d                
(f1.1)  goto (8|M0)                          L28840                  L28840                
L28808:
        mov (8|M0)               r122.0<1>:d   r25.0<1;1,0>:d                  
        goto (8|M0)                          L28840                  L28968                
L28840:
        join (8|M0)                          L28968                                
L28856:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r46.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r46.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r46.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r115.0<1>:ud  r25.0<1;1,0>:ud   r46.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r107.0<1>:d   r31.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r122.0<1>:ud  r31.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r122.0<1>:d   r115.0<1;1,0>:d   r107.0<1;1,0>:d  {I@2}
L28968:
        join (8|M0)                          L29024                                
L28984:
        mov (8|M0)               r72.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r122.0<1>:d   r84.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L29024                  L29104                
L29024:
        join (8|M0)                          L29104                                
L29040:
        shr (8|M0)               r122.0<1>:ud  r25.0<1;1,0>:ud   2:w              
        and (8|M0)               r89.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r72.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r122.0<1>:ud  r25.0<1;1,0>:ud   1:w               {F@1}
L29104:
        join (8|M0)                          L29648                                
L29120:
        shl (8|M0)               r73.0<1>:d    r122.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r114.0<1>:d   r89.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r73.0<1>:d    r73.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r75.0<1>:d    r72.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r24.0<1>:ud   r73.0<1;0>:ud     r114.0<1;0>:ud    r70.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r24.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L29240                  L29240                
L29208:
        mov (8|M0)               r23.0<1>:d    0:w                              
        goto (8|M0)                          L29240                  L29400                
L29240:
        join (8|M0)                          L29400                                
L29256:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r24.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (8|M0)                          L29320                  L29320                
L29288:
        mov (8|M0)               r23.0<1>:d    1:w                              
        goto (8|M0)                          L29320                  L29400                
L29320:
        join (8|M0)                          L29400                                
L29336:
        and (8|M0)    (ne)f0.1   null<1>:d     r72.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r24.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r23.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L29400:
        join (8|M0)                          L29648                                
L29416:
        add (8|M0)               r118.0<1>:d   r75.0<1;1,0>:d    r23.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r111.0<1>:d   r100.0<1;0>:d     r50.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r118.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f0.0)  sel (8|M0)               r104.0<1>:d   r111.0<1;1,0>:d   r97.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (8|M0)                          L29576                  L29576                
L29504:
(~f0.0) sel (8|M0)               r117.0<1>:d   r118.0<1;1,0>:d   0:w              
        and (8|M0)               r110.0<1>:d   r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r113.0<1>:d   r104.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r20.0<1>:ud   r110.0<1;0>:ud    r113.0<1;0>:ud    r117.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L29576                  L30216                
L29576:
        join (8|M0)                          L29648                                
L29592:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r20.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L29648                  L30216                
L29648:
        join (8|M0)                          L29968                                
L29664:
        and (8|M0)    (ne)f1.0   r106.0<1>:d   r50.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L29728                  L29728                
L29696:
        mov (8|M0)               r16.0<1>:d    -1:w                              
        goto (8|M0)                          L29728                  L29856                
L29728:
        join (8|M0)                          L29856                                
L29744:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r106.0<1;1,0>:ud  0x20:uw              {A@1}
(f0.1)  goto (8|M0)                          L29808                  L29808                
L29776:
        mov (8|M0)               r16.0<1>:d    0:w                              
        goto (8|M0)                          L29808                  L29856                
L29808:
        join (8|M0)                          L29856                                
L29824:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r16.0<1>:d    r6.4<0;1,0>:w     r106.0<1;1,0>:d  {F@1}
L29856:
        join (8|M0)                          L29968                                
L29872:
        bfn.0x28 (8|M0)          r22.0<1>:ud   r25.0<1;0>:ud     r16.0<1;0>:ud     r7.7<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r50.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r109.0<1>:d   r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r111.0<1>:d   r97.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r22.0<1>:d    r22.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r20.0<1>:ud   r109.0<1;0>:ud    r111.0<1;0>:ud    r22.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L29968                  L30216                
L29968:
        join (8|M0)                          L30040                                
L29984:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r20.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L30040                  L30216                
L30040:
        join (8|M0)                          L30112                                
L30056:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r17.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r20.0<1>:f    r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L30112                  L30216                
L30112:
        join (8|M0)                          L30184                                
L30128:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r20.0<1>:f    r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L30184                  L30216                
L30184:
        join (8|M0)                          L30216                                
L30200:
        bfn.0xF8 (8|M0)          r20.0<1>:ud   r17.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L30216:
        join (8|M0)                          L30264                                
L30232:
        mov (8|M0)               r12.0<1>:hf   r20.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r11.0<1>:f    r12.0<1;1,0>:hf                  {F@1}
L30264:
        join (8|M0)                          L43648                                
L30280:
(W)     mov (1|M0)               f1.0<1>:uw    r7.7<0;1,0>:uw                  
(f1.0)  goto (8|M0)                          L30400                  L30400                
L30312:
        sync.nop                             null                             {Compacted,$6.dst}
        mov (8|M0)               r12.0<1>:hf   r11.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r7.12<0;1,0>:uw                 
        mov (8|M0)               acc0.0<1>:f   r12.0<1;1,0>:hf                  {F@1}
(f0.1)  sel (8|M0)               r43.0<1>:f    acc0.0<1;1,0>:f   r11.0<1;1,0>:f  
        goto (8|M0)                          L30400                  L43160                
L30400:
        join (8|M0)                          L43160                                
L30416:
        and (8|M0)               r110.0<1>:d   r11.0<1;1,0>:d    2147483647:d               {$6.dst}
        sel (8|M0)    (lt)f0.0   r40.0<1>:f    r110.0<1;1,0>:f   448.0:f               {Compacted,I@1}
        shr (8|M0)               r46.0<1>:ud   r40.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.0   r120.0<1>:d   r40.0<1;1,0>:d    8388607:d              
        and (8|M0)               r72.0<1>:d    r46.0<1;1,0>:d    255:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r109.0<1>:ud  r72.0<1;1,0>:ud   0x79:uw              {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r72.0<1;1,0>:d    255:w              
        shl (8|M0)               r19.0<1>:d    r109.0<1;1,0>:d   23:w               {Compacted,I@2}
(~f0.0) goto (8|M0)                          L30560                  L30560                
L30536:
        mov (8|M0)               r22.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L30560                  L36752                
L30560:
        join (8|M0)                          L36752                                
L30576:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   0:w              
        add (8|M0)               r125.0<1>:d   -r19.0<1;1,0>:d   -2139095040:d               {I@5}
        xor (8|M0)               r21.0<1>:d    r125.0<1;1,0>:d   r40.0<1;1,0>:d   {Compacted,I@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r72.0<1;1,0>:d    255:w              
(f1.1)  goto (8|M0)                          L36720                  L36720                
L30648:
        or (8|M0)     (eq)f0.0   null<1>:d     r72.0<1;1,0>:d    r120.0<1;1,0>:d 
(~f0.0) goto (8|M0)                          L30704                  L30704                
L30680:
        mov (8|M0)               r22.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L30704                  L36752                
L30704:
        join (8|M0)                          L36720                                
L30720:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r72.0<1;1,0>:d    0:w               {Compacted}
        shr (8|M0)               r95.0<1>:ud   r125.0<1;1,0>:ud  23:w              
        add (8|M0)               r103.0<1>:d   r72.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (8|M0)               r103.0<1>:d   -126:w                              
        add (8|M0)               r94.0<1>:d    r95.0<1;1,0>:d    r103.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r94.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (8|M0)                          L36648                  L36648                
L30808:
        or (8|M0)     (eq)f1.0   null<4>:b     r46.0<1;1,0>:d    r95.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L36576                  L36576                
L30840:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r32.0<1>:d    acc0.0<1;1,0>:d   r120.0<1;1,0>:d 
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        shl (8|M0)               r24.0<1>:d    r32.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r28.0<1>:ud   r32.0<1;1,0>:ud   9:w              
L30952:
(W)     shl (1|M0)               r12.1<1>:d    r6.3<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.0   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r12.1<0;1,0>:d   {I@2}
        bfn.0xE0 (8|M0)          r47.0<1>:ud   r6.7<0;0>:ud      r12.1<0;0>:ud     r24.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f0.0) cmp (8|M0)   (eq)f0.0   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r47.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r46.0<1>:d    r6.2<0;1,0>:d     r28.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r14.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.0) cmp (8|M0)  (gt)f0.0   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f0.0)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r12.4<1>:ud   r12.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f1.1)  sel (8|M0)               r12.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r123.0<1>:d   r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r20.0<1>:d    r6.5<0;1,0>:d                   
        mov (8|M0)               r38.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r93.0<1>:d    r12.4<0;1,0>:d                  
(f0.1)  goto (8|M0)                          L31360                  L31360                
L31296:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r12.4<0;1,0>:d                  
(W)     jmpi                                 L30952                                
L31360:
        join (8|M0)                          L36576                                
L31376:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r12.0<1>:hf   0.0:hf                             
        subb (8|M0)              r65.0<1>:ud   r6.2<0;1,0>:ud    r123.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r83.0<1>:d    r94.0<1;0>:d      r65.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r90.0<1>:ud   -acc0.0<1;0>:ud   r12.0<0;0>:uw     -r20.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r83.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r72.0<1>:d    r95.0<1;0>:d      r103.0<1;0>:d     r65.0<1>:d      
(f0.1)  goto (8|M0)                          L36504                  L36504                
L31496:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r83.0<1;1,0>:d    -127:w              
(f0.0)  goto (8|M0)                          L34072                  L34072                
L31528:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r83.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L33552                  L33552                
L31560:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r63.0<1>:d    r94.0<1;0>:d      r65.0<1;0>:d      -23:w              
        subb (8|M0)              r104.0<1>:ud  r6.2<0;1,0>:ud    r123.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r12.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r104.0<1;1,0>:ud  r63.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r22.0<1>:ud   -acc0.0<1;0>:ud   r12.0<0;0>:uw     -r20.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r22.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L31760                  L31760                
L31696:
        add3 (8|M0)              acc0.0<1>:d   r72.0<1;0>:d      -r104.0<1;0>:d    -23:w              
        mov (8|M0)               r39.0<1>:d    0:w                              
        shl (8|M0)               r40.0<1>:d    r24.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L31760                  L33488                
L31760:
        join (8|M0)                          L33488                                
L31776:
        add3 (8|M0)              r99.0<1>:d    r104.0<1;0>:d     -r72.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r99.0<1;1,0>:d    2:w               {I@1}
(f1.0)  goto (8|M0)                          L31928                  L31928                
L31824:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r99.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L31928                  L31968                
L31856:
        shr (8|M0)               r124.0<1>:ud  r24.0<1;1,0>:ud   1:w              
        mov (8|M0)               r61.0<1>:d    0:w                              
        mov (8|M0)               r88.0<1>:d    0:w                              
        mov (8|M0)               r45.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L31928                  L32920                
L31928:
        join (8|M0)                          L31968                                
L31944:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r99.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  goto (8|M0)                          L31968                  L32864                
L31968:
        join (8|M0)                          L32864                                
L31984:
        add3 (8|M0)              acc0.0<1>:d   r104.0<1;0>:d     -r63.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.1   r42.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L32064                  L32064                
L32032:
        mov (8|M0)               r80.0<1>:d    r24.0<1;1,0>:d                  
        goto (8|M0)                          L32064                  L32200                
L32064:
        join (8|M0)                          L32200                                
L32080:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r42.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r42.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r42.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r105.0<1>:ud  r24.0<1;1,0>:ud   r42.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r93.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r124.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r124.0<1>:d   r105.0<1;1,0>:d   r93.0<1;1,0>:d   {I@2}
        mov (8|M0)               r80.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@1}
L32200:
        join (8|M0)                          L32864                                
L32216:
        add3 (8|M0)              r58.0<1>:d    r104.0<1;0>:d     -r63.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.1   r41.0<1>:d    r58.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (8|M0)                          L32296                  L32296                
L32264:
        mov (8|M0)               r124.0<1>:d   r24.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L32296                  L32424                
L32296:
        join (8|M0)                          L32424                                
L32312:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r41.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r41.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r41.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r103.0<1>:ud  r24.0<1;1,0>:ud   r41.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r92.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r124.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r124.0<1>:d   r103.0<1;1,0>:d   r92.0<1;1,0>:d   {I@2}
L32424:
        join (8|M0)                          L32864                                
L32440:
        and (8|M0)    (ne)f1.1   r91.0<1>:d    r58.0<1;1,0>:d    63:w              
        and (8|M0)               r88.0<1>:d    r124.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L32528                  L32528                
L32480:
        mov (8|M0)               r106.0<1>:d   -1:w                              
        mov (8|M0)               r119.0<1>:d   -1:w                              
        goto (8|M0)                          L32528                  L32712                
L32528:
        join (8|M0)                          L32712                                
L32544:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r91.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L32648                  L32648                
L32576:
        add (8|M0)               acc0.0<1>:d   r91.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r106.0<1>:d   0:w                              
        shl (8|M0)               r119.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L32648                  L32712                
L32648:
        join (8|M0)                          L32712                                
L32664:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r119.0<1>:d   -1:w                              
        shl (8|M0)               r106.0<1>:d   r6.4<0;1,0>:w     r91.0<1;1,0>:d   {F@1}
L32712:
        join (8|M0)                          L32864                                
L32728:
        bfn.0x60 (8|M0)          r102.0<1>:ud  r106.0<1;0>:ud    r7.7<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r101.0<1>:ud  r119.0<1;0>:ud    r7.7<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r102.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r45.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r101.0<1;1,0>:d   0:w               {I@2}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r61.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L32864                  L32920                
L32864:
        join (8|M0)                          L32920                                
L32880:
        mov (8|M0)               r61.0<1>:d    0:w                              
        mov (8|M0)               r88.0<1>:d    0:w                              
        mov (8|M0)               r45.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
L32920:
        join (8|M0)                          L33488                                
L32936:
        and (8|M0)    (ne)f0.1   r40.0<1>:d    r99.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L33000                  L33000                
L32968:
        mov (8|M0)               r124.0<1>:d   r24.0<1;1,0>:d                  
        goto (8|M0)                          L33000                  L33128                
L33000:
        join (8|M0)                          L33128                                
L33016:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r40.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r40.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r40.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r98.0<1>:ud   r24.0<1;1,0>:ud   r40.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r90.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r124.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r124.0<1>:d   r98.0<1;1,0>:d    r90.0<1;1,0>:d   {I@2}
L33128:
        join (8|M0)                          L33488                                
L33144:
        shl (8|M0)               r39.0<1>:d    r45.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r97.0<1>:d    r88.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r39.0<1>:d    r39.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r125.0<1>:ud  r39.0<1;0>:ud     r97.0<1;0>:ud     r61.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (8|M0)                          L33248                  L33248                
L33216:
        mov (8|M0)               r15.0<1>:d    0:w                              
        goto (8|M0)                          L33248                  L33408                
L33248:
        join (8|M0)                          L33408                                
L33264:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r125.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (8|M0)                          L33328                  L33328                
L33296:
        mov (8|M0)               r15.0<1>:d    1:w                              
        goto (8|M0)                          L33328                  L33408                
L33328:
        join (8|M0)                          L33408                                
L33344:
        and (8|M0)    (ne)f0.1   null<1>:d     r124.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r125.0<1;1,0>:d   4:w              
(f0.1)  sel (8|M0)               r15.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L33408:
        join (8|M0)                          L33488                                
L33424:
        add (8|M0)               r101.0<1>:d   r15.0<1;1,0>:d    r124.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r101.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r40.0<1>:d    r101.0<1;1,0>:d   0:w              
(f1.1)  sel (8|M0)               r39.0<1>:d    r6.2<0;1,0>:d     0:w               {F@1}
L33488:
        join (8|M0)                          L33552                                
L33504:
        and (8|M0)               r96.0<1>:d    r21.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r22.0<1>:ud   r96.0<1;0>:ud     r39.0<1;0>:ud     r40.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L33552                  L36752                
L33552:
        join (8|M0)                          L34072                                
L33568:
        and (8|M0)    (ne)f0.1   r55.0<1>:d    r65.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L33648                  L33648                
L33600:
        mov (8|M0)               r72.0<1>:d    -1:w                              
        mov (8|M0)               r89.0<1>:d    -1:w                              
        goto (8|M0)                          L33648                  L33832                
L33648:
        join (8|M0)                          L33832                                
L33664:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r55.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L33768                  L33768                
L33696:
        add (8|M0)               acc0.0<1>:d   r55.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r72.0<1>:d    0:w                              
        shl (8|M0)               r89.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L33768                  L33832                
L33768:
        join (8|M0)                          L33832                                
L33784:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r89.0<1>:d    -1:w                              
        shl (8|M0)               r72.0<1>:d    r6.4<0;1,0>:w     r55.0<1;1,0>:d   {F@1}
L33832:
        join (8|M0)                          L34072                                
L33848:
        bfn.0x60 (8|M0)          r95.0<1>:ud   r72.0<1;0>:ud     r7.7<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r94.0<1>:ud   r89.0<1;0>:ud     r7.7<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r95.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r21.0<1;1,0>:d    -1:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r94.0<1;1,0>:d    0:w               {I@3}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r83.0<1;1,0>:d    -150:w              
(f1.1)  goto (8|M0)                          L34008                  L34008                
L33960:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f0.0)  sel (8|M0)               r22.0<1>:f    r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L34008                  L36752                
L34008:
        join (8|M0)                          L34072                                
L34024:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (8|M0)               r22.0<1>:f    r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L34072                  L36752                
L34072:
        join (8|M0)                          L36504                                
L34088:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r65.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r101.0<1>:d   r94.0<1;0>:d      r65.0<1;0>:d      -46:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r90.0<1;1,0>:d    0:w              
(f0.0)  goto (8|M0)                          L36184                  L36184                
L34152:
        shl (8|M0)               r71.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r70.0<1>:ud   r38.0<1;1,0>:ud   31:w              
        shl (8|M0)               r63.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r71.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r63.0<1>:d    r63.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r63.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r63.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L34384                  L34384                
L34256:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r38.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r93.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L34384                  L34448                
L34304:
        shr (8|M0)               r124.0<1>:ud  r24.0<1;1,0>:ud   1:w              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r92.0<1>:d    0:w                              
        mov (8|M0)               r74.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r124.0<1>:f   r24.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L34384                  L35648                
L34384:
        join (8|M0)                          L34448                                
L34400:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r93.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L34448                  L35560                
L34448:
        join (8|M0)                          L35560                                
L34464:
        add (8|M0)               acc0.0<1>:d   -r38.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r95.0<1>:d    -r38.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r54.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L34544                  L34544                
L34512:
        mov (8|M0)               r91.0<1>:d    r24.0<1;1,0>:d                  
        goto (8|M0)                          L34544                  L34680                
L34544:
        join (8|M0)                          L34680                                
L34560:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r54.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r54.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r54.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r91.0<1>:ud   r24.0<1;1,0>:ud   r54.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r118.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r124.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r124.0<1>:d   r91.0<1;1,0>:d    r118.0<1;1,0>:d  {I@2}
        mov (8|M0)               r91.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@1}
L34680:
        join (8|M0)                          L35560                                
L34696:
        add (8|M0)               r66.0<1>:d    -r38.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.0   r62.0<1>:d    r66.0<1;1,0>:d    63:w               {I@1}
(f0.0)  goto (8|M0)                          L34768                  L34768                
L34736:
        mov (8|M0)               r124.0<1>:d   r24.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L34768                  L34896                
L34768:
        join (8|M0)                          L34896                                
L34784:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r62.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r62.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r62.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r89.0<1>:ud   r24.0<1;1,0>:ud   r62.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r23.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r124.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r124.0<1>:d   r89.0<1;1,0>:d    r23.0<1;1,0>:d   {I@2}
L34896:
        join (8|M0)                          L35560                                
L34912:
        and (8|M0)    (ne)f1.0   r22.0<1>:d    r66.0<1;1,0>:d    63:w              
        and (8|M0)               r92.0<1>:d    r124.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L35000                  L35000                
L34952:
        mov (8|M0)               r32.0<1>:d    -1:w                              
        mov (8|M0)               r39.0<1>:d    -1:w                              
        goto (8|M0)                          L35000                  L35184                
L35000:
        join (8|M0)                          L35184                                
L35016:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r22.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L35120                  L35120                
L35048:
        add (8|M0)               acc0.0<1>:d   r22.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r32.0<1>:d    0:w                              
        shl (8|M0)               r39.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L35120                  L35184                
L35120:
        join (8|M0)                          L35184                                
L35136:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r39.0<1>:d    -1:w                              
        shl (8|M0)               r32.0<1>:d    r6.4<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
L35184:
        join (8|M0)                          L35560                                
L35200:
        bfn.0x60 (8|M0)          r88.0<1>:ud   r32.0<1;0>:ud     r7.7<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r87.0<1>:ud   r39.0<1;0>:ud     r7.7<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r88.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.0   r61.0<1>:d    r95.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r87.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r78.0<1>:d    -acc0.0<1;1,0>:d                
(f0.0)  goto (8|M0)                          L35376                  L35376                
L35344:
        mov (8|M0)               r124.0<1>:d   r24.0<1;1,0>:d                  
        goto (8|M0)                          L35376                  L35504                
L35376:
        join (8|M0)                          L35504                                
L35392:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r61.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r61.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r61.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r84.0<1>:ud   r24.0<1;1,0>:ud   r61.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r20.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r124.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r124.0<1>:d   r84.0<1;1,0>:d    r20.0<1;1,0>:d   {I@2}
L35504:
        join (8|M0)                          L35560                                
L35520:
        mov (8|M0)               r74.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r124.0<1>:d   r91.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L35560                  L35648                
L35560:
        join (8|M0)                          L35648                                
L35576:
        shr (8|M0)               r124.0<1>:ud  r24.0<1;1,0>:ud   2:w              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r92.0<1>:d    0:w                              
        mov (8|M0)               r74.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r124.0<1>:ud  r24.0<1;1,0>:ud   1:w               {F@1}
L35648:
        join (8|M0)                          L36184                                
L35664:
        shl (8|M0)               r105.0<1>:d   r124.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r83.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r105.0<1>:d   r105.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r84.0<1>:d    r74.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r54.0<1>:ud   r105.0<1;0>:ud    r83.0<1;0>:ud     r78.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L35784                  L35784                
L35752:
        mov (8|M0)               r53.0<1>:d    0:w                              
        goto (8|M0)                          L35784                  L35944                
L35784:
        join (8|M0)                          L35944                                
L35800:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r54.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L35864                  L35864                
L35832:
        mov (8|M0)               r53.0<1>:d    1:w                              
        goto (8|M0)                          L35864                  L35944                
L35864:
        join (8|M0)                          L35944                                
L35880:
        and (8|M0)    (ne)f0.0   null<1>:d     r74.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r54.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r53.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L35944:
        join (8|M0)                          L36184                                
L35960:
        add (8|M0)               r20.0<1>:d    r84.0<1;1,0>:d    r53.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r16.0<1>:d    r94.0<1;0>:d      r65.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r20.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r117.0<1>:d   r16.0<1;1,0>:d    r101.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r117.0<1;1,0>:d   255:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L36112                  L36112                
L36040:
(~f1.0) sel (8|M0)               r25.0<1>:d    r20.0<1;1,0>:d    0:w              
        and (8|M0)               r15.0<1>:d    r21.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r82.0<1>:d    r117.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r22.0<1>:ud   r15.0<1;0>:ud     r82.0<1;0>:ud     r25.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L36112                  L36752                
L36112:
        join (8|M0)                          L36184                                
L36128:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r21.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r22.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36184                  L36752                
L36184:
        join (8|M0)                          L36504                                
L36200:
        and (8|M0)    (ne)f1.1   r124.0<1>:d   r65.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L36264                  L36264                
L36232:
        mov (8|M0)               r38.0<1>:d    -1:w                              
        goto (8|M0)                          L36264                  L36392                
L36264:
        join (8|M0)                          L36392                                
L36280:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r124.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  goto (8|M0)                          L36344                  L36344                
L36312:
        mov (8|M0)               r38.0<1>:d    0:w                              
        goto (8|M0)                          L36344                  L36392                
L36344:
        join (8|M0)                          L36392                                
L36360:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r38.0<1>:d    r6.4<0;1,0>:w     r124.0<1;1,0>:d  {F@1}
L36392:
        join (8|M0)                          L36504                                
L36408:
        bfn.0x60 (8|M0)          r52.0<1>:ud   r38.0<1;0>:ud     r7.7<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r65.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r14.0<1>:d    r21.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r80.0<1>:d    r101.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r52.0<1>:d    r52.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r22.0<1>:ud   r14.0<1;0>:ud     r80.0<1;0>:ud     r52.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L36504                  L36752                
L36504:
        join (8|M0)                          L36576                                
L36520:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r21.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r22.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36576                  L36752                
L36576:
        join (8|M0)                          L36648                                
L36592:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r21.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r22.0<1>:f    r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L36648                  L36752                
L36648:
        join (8|M0)                          L36720                                
L36664:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r21.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r22.0<1>:f    r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L36720                  L36752                
L36720:
        join (8|M0)                          L36752                                
L36736:
        bfn.0xF8 (8|M0)          r22.0<1>:ud   r21.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L36752:
        join (8|M0)                          L43160                                
L36768:
        rnde (8|M0)              r51.0<1>:f    r22.0<1;1,0>:f                   {Compacted,I@2}
        shr (8|M0)               r52.0<1>:ud   r51.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.1   r31.0<1>:d    r51.0<1;1,0>:d    8388607:d              
        and (8|M0)               r86.0<1>:d    r52.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L36872                  L36872                
L36848:
        mov (8|M0)               r19.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L36872                  L43112                
L36872:
        join (8|M0)                          L43112                                
L36888:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r31.0<1;1,0>:d    0:w               {Compacted}
        add (8|M0)               r123.0<1>:d   r19.0<1;1,0>:d    -25165824:d               {F@1}
        shr (8|M0)               r45.0<1>:ud   r123.0<1;1,0>:ud  23:w               {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    255:w              
        and (8|M0)               r113.0<1>:d   r45.0<1;1,0>:d    255:w               {Compacted,I@2}
        xor (8|M0)               r20.0<1>:d    r123.0<1;1,0>:d   r51.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r113.0<1;1,0>:d   255:w               {I@2}
(f0.0)  goto (8|M0)                          L43080                  L43080                
L36992:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w              
        or (8|M0)                r79.0<1>:d    r86.0<1;1,0>:d    r31.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r79.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L37072                  L37072                
L37048:
        mov (8|M0)               r19.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L37072                  L43112                
L37072:
        join (8|M0)                          L43080                                
L37088:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    0:w              
        add (8|M0)               r102.0<1>:d   r86.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (8|M0)               r102.0<1>:d   -126:w                              
        add (8|M0)               r96.0<1>:d    r113.0<1;1,0>:d   r102.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r96.0<1;1,0>:d    254:w               {I@1}
(f0.1)  goto (8|M0)                          L43008                  L43008                
L37168:
        or (8|M0)     (eq)f0.0   null<4>:b     r52.0<1;1,0>:d    r45.0<1;1,0>:d  
(f0.0)  goto (8|M0)                          L42936                  L42936                
L37200:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r23.0<1>:d    acc0.0<1;1,0>:d   r31.0<1;1,0>:d  
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        shl (8|M0)               r22.0<1>:d    r23.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r27.0<1>:ud   r23.0<1;1,0>:ud   9:w              
L37312:
(W)     shl (1|M0)               r12.1<1>:d    r6.3<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r12.1<0;1,0>:d   {I@2}
        bfn.0xE0 (8|M0)          r43.0<1>:ud   r6.7<0;0>:ud      r12.1<0;0>:ud     r22.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f1.1) cmp (8|M0)   (eq)f1.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r42.0<1>:d    r6.2<0;1,0>:d     r27.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r14.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.1) cmp (8|M0)  (gt)f1.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r42.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f1.1)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r12.4<1>:ud   r12.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f1.0)  sel (8|M0)               r12.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r121.0<1>:d   r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.0   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r127.0<1>:d   r6.5<0;1,0>:d                   
        mov (8|M0)               r36.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r91.0<1>:d    r12.4<0;1,0>:d                  
(f0.0)  goto (8|M0)                          L37720                  L37720                
L37656:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r12.4<0;1,0>:d                  
(W)     jmpi                                 L37312                                
L37720:
        join (8|M0)                          L42936                                
L37736:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r12.0<1>:hf   0.0:hf                             
        subb (8|M0)              r64.0<1>:ud   r6.2<0;1,0>:ud    r121.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r81.0<1>:d    r96.0<1;0>:d      r64.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r87.0<1>:ud   -acc0.0<1;0>:ud   r12.0<0;0>:uw     -r127.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r81.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r69.0<1>:d    r113.0<1;0>:d     r102.0<1;0>:d     r64.0<1>:d      
(f1.1)  goto (8|M0)                          L42864                  L42864                
L37856:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r81.0<1;1,0>:d    -127:w              
(f1.0)  goto (8|M0)                          L40432                  L40432                
L37888:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r81.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (8|M0)                          L39912                  L39912                
L37920:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r60.0<1>:d    r96.0<1;0>:d      r64.0<1;0>:d      -23:w              
        subb (8|M0)              r101.0<1>:ud  r6.2<0;1,0>:ud    r121.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r12.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r101.0<1;1,0>:ud  r60.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r122.0<1>:ud  -acc0.0<1;0>:ud   r12.0<0;0>:uw     -r127.0<1>:ud    {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   0:w               {I@1}
(~f1.1) cmp (8|M0)    (gt)f1.1   null<1>:ud    r122.0<1;1,0>:ud  0x0:uw             
(f1.1)  goto (8|M0)                          L38120                  L38120                
L38056:
        add3 (8|M0)              acc0.0<1>:d   r69.0<1;0>:d      -r101.0<1;0>:d    -23:w              
        mov (8|M0)               r29.0<1>:d    0:w                              
        shl (8|M0)               r30.0<1>:d    r22.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L38120                  L39848                
L38120:
        join (8|M0)                          L39848                                
L38136:
        add3 (8|M0)              r98.0<1>:d    r101.0<1;0>:d     -r69.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f0.0   null<1>:d     r98.0<1;1,0>:d    2:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L38280                  L38280                
L38176:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L38280                  L38328                
L38208:
        shr (8|M0)               r126.0<1>:ud  r22.0<1;1,0>:ud   1:w              
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r47.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L38280                  L39288                
L38280:
        join (8|M0)                          L38328                                
L38296:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    1:w              
(f1.0)  goto (8|M0)                          L38328                  L39232                
L38328:
        join (8|M0)                          L39232                                
L38344:
        add3 (8|M0)              acc0.0<1>:d   r101.0<1;0>:d     -r60.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r31.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L38424                  L38424                
L38392:
        mov (8|M0)               r79.0<1>:d    r22.0<1;1,0>:d                  
        goto (8|M0)                          L38424                  L38560                
L38424:
        join (8|M0)                          L38560                                
L38440:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r31.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r31.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r31.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r75.0<1>:ud   r22.0<1;1,0>:ud   r31.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r71.0<1>:d    r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r126.0<1>:ud  r27.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.0)  or (8|M0)                r126.0<1>:d   r75.0<1;1,0>:d    r71.0<1;1,0>:d   {I@2}
        mov (8|M0)               r79.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@1}
L38560:
        join (8|M0)                          L39232                                
L38576:
        add3 (8|M0)              r44.0<1>:d    r101.0<1;0>:d     -r60.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.1   r30.0<1>:d    r44.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L38656                  L38656                
L38624:
        mov (8|M0)               r126.0<1>:d   r22.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L38656                  L38784                
L38656:
        join (8|M0)                          L38784                                
L38672:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r30.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r30.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r30.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r73.0<1>:ud   r22.0<1;1,0>:ud   r30.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r70.0<1>:d    r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r126.0<1>:ud  r27.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r126.0<1>:d   r73.0<1;1,0>:d    r70.0<1;1,0>:d   {I@2}
L38784:
        join (8|M0)                          L39232                                
L38800:
        and (8|M0)    (ne)f0.1   r69.0<1>:d    r44.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L38880                  L38880                
L38832:
        mov (8|M0)               r88.0<1>:d    -1:w                              
        mov (8|M0)               r104.0<1>:d   -1:w                              
        goto (8|M0)                          L38880                  L39064                
L38880:
        join (8|M0)                          L39064                                
L38896:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r69.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L39000                  L39000                
L38928:
        add (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r88.0<1>:d    0:w                              
        shl (8|M0)               r104.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L39000                  L39064                
L39000:
        join (8|M0)                          L39064                                
L39016:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r104.0<1>:d   -1:w                              
        shl (8|M0)               r88.0<1>:d    r6.4<0;1,0>:w     r69.0<1;1,0>:d   {F@1}
L39064:
        join (8|M0)                          L39232                                
L39080:
        bfn.0x60 (8|M0)          r72.0<1>:ud   r88.0<1;0>:ud     r7.7<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r71.0<1>:ud   r104.0<1;0>:ud    r7.7<0;0>:ud      r27.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r72.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r69.0<1>:d    r126.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r38.0<1>:f    r79.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r71.0<1;1,0>:d    0:w               {I@3}
        and (8|M0)               r47.0<1>:d    r69.0<1;1,0>:d    2:w               {Compacted,I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r54.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L39232                  L39288                
L39232:
        join (8|M0)                          L39288                                
L39248:
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r47.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
L39288:
        join (8|M0)                          L39848                                
L39304:
        and (8|M0)    (ne)f1.1   r29.0<1>:d    r98.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L39368                  L39368                
L39336:
        mov (8|M0)               r126.0<1>:d   r22.0<1;1,0>:d                  
        goto (8|M0)                          L39368                  L39496                
L39368:
        join (8|M0)                          L39496                                
L39384:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r29.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (8|M0)               acc0.0<1>:d   r29.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r67.0<1>:ud   r22.0<1;1,0>:ud   r29.0<1;1,0>:d  
(~f1.0) shr (8|M0)               r126.0<1>:ud  r27.0<1;1,0>:ud   acc0.0<1;1,0>:d 
(f1.0)  add (8|M0)               acc0.0<1>:d   -r29.0<1;1,0>:d   32:w              
(f1.0)  shl (8|M0)               r68.0<1>:d    r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
(f1.0)  or (8|M0)                r126.0<1>:d   r67.0<1;1,0>:d    r68.0<1;1,0>:d   {I@1}
L39496:
        join (8|M0)                          L39848                                
L39512:
        shl (8|M0)               r14.0<1>:d    r38.0<1;1,0>:d    2:w               {Compacted,F@1}
        and (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    4:w               {Compacted,I@1}
        bfn.0xFE (8|M0)          r119.0<1>:ud  r14.0<1;0>:ud     r47.0<1;0>:ud     r54.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r119.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L39608                  L39608                
L39576:
        mov (8|M0)               r123.0<1>:d   0:w                              
        goto (8|M0)                          L39608                  L39768                
L39608:
        join (8|M0)                          L39768                                
L39624:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r119.0<1;1,0>:ud  0x4:uw             
(~f0.0) goto (8|M0)                          L39688                  L39688                
L39656:
        mov (8|M0)               r123.0<1>:d   1:w                              
        goto (8|M0)                          L39688                  L39768                
L39688:
        join (8|M0)                          L39768                                
L39704:
        and (8|M0)    (ne)f0.0   null<1>:d     r126.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r119.0<1;1,0>:d   4:w              
(f0.0)  sel (8|M0)               r123.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L39768:
        join (8|M0)                          L39848                                
L39784:
        add (8|M0)               r99.0<1>:d    r123.0<1;1,0>:d   r126.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r99.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r30.0<1>:d    r99.0<1;1,0>:d    0:w              
(f1.0)  sel (8|M0)               r29.0<1>:d    r6.2<0;1,0>:d     0:w               {F@1}
L39848:
        join (8|M0)                          L39912                                
L39864:
        and (8|M0)               r66.0<1>:d    r20.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r19.0<1>:ud   r66.0<1;0>:ud     r29.0<1;0>:ud     r30.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L39912                  L43112                
L39912:
        join (8|M0)                          L40432                                
L39928:
        and (8|M0)    (ne)f1.1   r37.0<1>:d    r64.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L40008                  L40008                
L39960:
        mov (8|M0)               r50.0<1>:d    -1:w                              
        mov (8|M0)               r67.0<1>:d    -1:w                              
        goto (8|M0)                          L40008                  L40192                
L40008:
        join (8|M0)                          L40192                                
L40024:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r37.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L40128                  L40128                
L40056:
        add (8|M0)               acc0.0<1>:d   r37.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r50.0<1>:d    0:w                              
        shl (8|M0)               r67.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L40128                  L40192                
L40128:
        join (8|M0)                          L40192                                
L40144:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r67.0<1>:d    -1:w                              
        shl (8|M0)               r50.0<1>:d    r6.4<0;1,0>:w     r37.0<1;1,0>:d   {F@1}
L40192:
        join (8|M0)                          L40432                                
L40208:
        bfn.0x60 (8|M0)          r65.0<1>:ud   r50.0<1;0>:ud     r7.7<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r64.0<1>:ud   r67.0<1;0>:ud     r7.7<0;0>:ud      r27.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r65.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r20.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    -150:w              
(f0.1)  goto (8|M0)                          L40368                  L40368                
L40320:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r19.0<1>:f    r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L40368                  L43112                
L40368:
        join (8|M0)                          L40432                                
L40384:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r19.0<1>:f    r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L40432                  L43112                
L40432:
        join (8|M0)                          L42864                                
L40448:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r64.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r100.0<1>:d   r96.0<1;0>:d      r64.0<1;0>:d      -46:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r87.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L42544                  L42544                
L40512:
        shl (8|M0)               r60.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r59.0<1>:ud   r36.0<1;1,0>:ud   31:w              
        shl (8|M0)               r53.0<1>:d    r91.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r60.0<1;1,0>:ud   0x4E:uw              {A@1}
        or (8|M0)                r53.0<1>:d    r53.0<1;1,0>:d    r59.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r53.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r53.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L40744                  L40744                
L40616:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    39:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r91.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L40744                  L40808                
L40664:
        shr (8|M0)               r126.0<1>:ud  r22.0<1;1,0>:ud   1:w              
        mov (8|M0)               r77.0<1>:d    0:w                              
        mov (8|M0)               r37.0<1>:d    0:w                              
        mov (8|M0)               r71.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r126.0<1>:f   r22.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L40744                  L42016                
L40744:
        join (8|M0)                          L40808                                
L40760:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r36.0<1;1,0>:d    38:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r91.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L40808                  L41928                
L40808:
        join (8|M0)                          L41928                                
L40824:
        add (8|M0)               acc0.0<1>:d   -r36.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r93.0<1>:d    -r36.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.0   r45.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L40904                  L40904                
L40872:
        mov (8|M0)               r92.0<1>:d    r22.0<1;1,0>:d                  
        goto (8|M0)                          L40904                  L41040                
L40904:
        join (8|M0)                          L41040                                
L40920:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r45.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r45.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r45.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r61.0<1>:ud   r22.0<1;1,0>:ud   r45.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r103.0<1>:d   r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r126.0<1>:ud  r27.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r126.0<1>:d   r61.0<1;1,0>:d    r103.0<1;1,0>:d  {I@2}
        mov (8|M0)               r92.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@1}
L41040:
        join (8|M0)                          L41928                                
L41056:
        add (8|M0)               r61.0<1>:d    -r36.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r52.0<1>:d    r61.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L41128                  L41128                
L41096:
        mov (8|M0)               r78.0<1>:d    r22.0<1;1,0>:d                  
        goto (8|M0)                          L41128                  L41264                
L41128:
        join (8|M0)                          L41264                                
L41144:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r52.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r52.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r52.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r59.0<1>:ud   r22.0<1;1,0>:ud   r52.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r117.0<1>:d   r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r126.0<1>:ud  r27.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r126.0<1>:d   r59.0<1;1,0>:d    r117.0<1;1,0>:d  {I@2}
        mov (8|M0)               r78.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@1}
L41264:
        join (8|M0)                          L41928                                
L41280:
        and (8|M0)    (ne)f0.0   r116.0<1>:d   r61.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L41360                  L41360                
L41312:
        mov (8|M0)               r19.0<1>:d    -1:w                              
        mov (8|M0)               r30.0<1>:d    -1:w                              
        goto (8|M0)                          L41360                  L41544                
L41360:
        join (8|M0)                          L41544                                
L41376:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r116.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L41480                  L41480                
L41408:
        add (8|M0)               acc0.0<1>:d   r116.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r19.0<1>:d    0:w                              
        shl (8|M0)               r30.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L41480                  L41544                
L41480:
        join (8|M0)                          L41544                                
L41496:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r30.0<1>:d    -1:w                              
        shl (8|M0)               r19.0<1>:d    r6.4<0;1,0>:w     r116.0<1;1,0>:d  {F@1}
L41544:
        join (8|M0)                          L41928                                
L41560:
        bfn.0x60 (8|M0)          r58.0<1>:ud   r19.0<1;0>:ud     r7.7<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r57.0<1>:ud   r30.0<1;0>:ud     r7.7<0;0>:ud      r27.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r58.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.0   r51.0<1>:d    r93.0<1;1,0>:d    63:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r57.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r77.0<1>:d    -acc0.0<1;1,0>:d                
(f1.0)  goto (8|M0)                          L41736                  L41736                
L41704:
        mov (8|M0)               r126.0<1>:d   r22.0<1;1,0>:d                  
        goto (8|M0)                          L41736                  L41864                
L41736:
        join (8|M0)                          L41864                                
L41752:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r51.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r51.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r51.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r54.0<1>:ud   r22.0<1;1,0>:ud   r51.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r115.0<1>:d   r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r126.0<1>:ud  r27.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r126.0<1>:d   r54.0<1;1,0>:d    r115.0<1;1,0>:d  {I@2}
L41864:
        join (8|M0)                          L41928                                
L41880:
        shl (8|M0)               r53.0<1>:d    r78.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r71.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        and (8|M0)               r37.0<1>:d    r53.0<1;1,0>:d    2:w               {Compacted,I@1}
        mov (8|M0)               r126.0<1>:f   r92.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L41928                  L42016                
L41928:
        join (8|M0)                          L42016                                
L41944:
        shr (8|M0)               r126.0<1>:ud  r22.0<1;1,0>:ud   2:w               {F@1}
        mov (8|M0)               r77.0<1>:d    0:w                              
        mov (8|M0)               r37.0<1>:d    0:w                              
        mov (8|M0)               r71.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r126.0<1>:ud  r22.0<1;1,0>:ud   1:w               {F@1}
L42016:
        join (8|M0)                          L42544                                
L42032:
        shl (8|M0)               r66.0<1>:d    r126.0<1;1,0>:d   2:w               {Compacted,I@2}
        and (8|M0)               r74.0<1>:d    r71.0<1;1,0>:d    8388607:d              
        and (8|M0)               r66.0<1>:d    r66.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r36.0<1>:ud   r66.0<1;0>:ud     r37.0<1;0>:ud     r77.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L42136                  L42136                
L42104:
        mov (8|M0)               r35.0<1>:d    0:w                              
        goto (8|M0)                          L42136                  L42296                
L42136:
        join (8|M0)                          L42296                                
L42152:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r36.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L42216                  L42216                
L42184:
        mov (8|M0)               r35.0<1>:d    1:w                              
        goto (8|M0)                          L42216                  L42296                
L42216:
        join (8|M0)                          L42296                                
L42232:
        and (8|M0)    (ne)f1.1   null<1>:d     r71.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r36.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r35.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L42296:
        join (8|M0)                          L42544                                
L42312:
        add (8|M0)               r121.0<1>:d   r74.0<1;1,0>:d    r35.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r116.0<1>:d   r96.0<1;0>:d      r64.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r121.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r105.0<1>:d   r116.0<1;1,0>:d   r100.0<1;1,0>:d  {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r105.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (8|M0)                          L42472                  L42472                
L42400:
(~f0.1) sel (8|M0)               r13.0<1>:d    r121.0<1;1,0>:d   0:w              
        and (8|M0)               r115.0<1>:d   r20.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r52.0<1>:d    r105.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r19.0<1>:ud   r115.0<1;0>:ud    r52.0<1;0>:ud     r13.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L42472                  L43112                
L42472:
        join (8|M0)                          L42544                                
L42488:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r20.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r19.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L42544                  L43112                
L42544:
        join (8|M0)                          L42864                                
L42560:
        and (8|M0)    (ne)f0.1   r116.0<1>:d   r64.0<1;1,0>:d    63:w               {F@1}
(f0.1)  goto (8|M0)                          L42624                  L42624                
L42592:
        mov (8|M0)               r21.0<1>:d    -1:w                              
        goto (8|M0)                          L42624                  L42752                
L42624:
        join (8|M0)                          L42752                                
L42640:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r116.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  goto (8|M0)                          L42704                  L42704                
L42672:
        mov (8|M0)               r21.0<1>:d    0:w                              
        goto (8|M0)                          L42704                  L42752                
L42704:
        join (8|M0)                          L42752                                
L42720:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r21.0<1>:d    r6.4<0;1,0>:w     r116.0<1;1,0>:d  {F@1}
L42752:
        join (8|M0)                          L42864                                
L42768:
        bfn.0x60 (8|M0)          r34.0<1>:ud   r21.0<1;0>:ud     r7.7<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r64.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r114.0<1>:d   r20.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r50.0<1>:d    r100.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r34.0<1>:d    r34.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r19.0<1>:ud   r114.0<1;0>:ud    r50.0<1;0>:ud     r34.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L42864                  L43112                
L42864:
        join (8|M0)                          L42936                                
L42880:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r20.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r19.0<1>:f    r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L42936                  L43112                
L42936:
        join (8|M0)                          L43008                                
L42952:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r19.0<1>:f    r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L43008                  L43112                
L43008:
        join (8|M0)                          L43080                                
L43024:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r20.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r19.0<1>:f    r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L43080                  L43112                
L43080:
        join (8|M0)                          L43112                                
L43096:
        bfn.0xF8 (8|M0)          r19.0<1>:ud   r20.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L43112:
        join (8|M0)                          L43160                                
L43128:
        cmp (8|M0)    (lt)f1.1   null<1>:f     r11.0<1;1,0>:f    0.0:f               {I@7}
(f1.1)  sel (8|M0)               r43.0<1>:f    -r19.0<1;1,0>:f   r19.0<1;1,0>:f   {I@2}
L43160:
        join (8|M0)                          L43648                                
L43176:
(W)     mov (1|M0)               f0.0<1>:uw    r7.13<0;1,0>:uw                 
(f0.0)  goto (8|M0)                          L43368                  L43368                
L43208:
        shl (8|M0)               r108.0<1>:d   r10.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r107.0<1>:ud  r10.0<1;1,0>:ud   31:w              
        shl (8|M0)               r33.0<1>:d    r9.0<1;1,0>:d     1:w               {Compacted}
        addc (8|M0)              r12.0<1>:ud   r108.0<1;1,0>:ud  r7.4<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        sync.nop                             null                             {Compacted,$6.dst}
        mov (8|M0)               r11.0<1>:hf   r43.0<1;1,0>:f                   {F@1}
        or (8|M0)                r33.0<1>:d    r33.0<1;1,0>:d    r107.0<1;1,0>:d  {Compacted,I@2}
        mov (8|M0)               r49.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r48.0<1>:ud   r11.0<1;1,0>:uw                  {F@1}
        add3 (8|M0)              r80.1<2>:ud   r49.0<1;0>:ud     r33.0<1;0>:ud     r7.5<0>:ud       {I@2}
        mov (8|M0)               r80.0<2>:d    r12.0<1;1,0>:d                  
        send.ugm (8|M0)          null     r80     r48:1   0x0            0x040E0B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64.wb.wb
        goto (8|M0)                          L43368                  L43496                
L43368:
        join (8|M0)                          L43496                                
L43384:
        shl (8|M0)               r106.0<1>:d   r10.0<1;1,0>:d    2:w               {Compacted}
        shr (8|M0)               r105.0<1>:ud  r10.0<1;1,0>:ud   30:w              
        shl (8|M0)               r32.0<1>:d    r9.0<1;1,0>:d     2:w               {Compacted}
        sync.nop                             null                             {Compacted,$6.dst}
        addc (8|M0)              r11.0<1>:ud   r106.0<1;1,0>:ud  r7.4<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (8|M0)                r32.0<1>:d    r32.0<1;1,0>:d    r105.0<1;1,0>:d  {Compacted,I@2}
        mov (8|M0)               r47.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r66.1<2>:ud   r47.0<1;0>:ud     r32.0<1;0>:ud     r7.5<0>:ud       {I@1}
        mov (8|M0)               r66.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (8|M0)          null     r66     r43:1   0x0            0x040E0584           {A@1,$5} // wr:2+1, rd:0; store.ugm.d32.a64.wb.wb
L43496:
        join (8|M0)                          L43648                                
L43512:
        addc (8|M0)              r96.0<1>:ud   r10.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r96.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r97.0<1>:ud   acc0.0<1;1,0>:ud  r9.0<1;1,0>:ud  
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r97.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:ud    r97.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f1.1) goto (8|M0)                          L43648                  L43648                
L43600:
(f1.1)  sel (8|M0)               r10.0<1>:d    r96.0<1;1,0>:d    r8.0<1;1,0>:d   
(f1.1)  sel (8|M0)               r9.0<1>:d     r97.0<1;1,0>:d    r3.0<1;1,0>:d   
(W)     jmpi                                 L768                                
L43648:
        join (8|M0)                          L43664                                
L43664:
(W)     mov (8|M0)               r112.0<1>:f   r2.0<1;1,0>:f                    {Compacted}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L43688:
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x52:ud                             
L43752:
        shr (8|M0)               r45.0<1>:ud   r117.0<1;1,0>:ud  23:w              
        shr (8|M0)               r46.0<1>:ud   r78.0<1;1,0>:ud   23:w              
        and (8|M0)    (eq)f0.1   r97.0<1>:d    r45.0<1;1,0>:d    255:w               {I@2}
        and (8|M0)               r23.0<1>:d    r78.0<1;1,0>:d    8388607:d              
        and (8|M0)               r98.0<1>:d    r117.0<1;1,0>:d   8388607:d              
        shr (8|M0)               r119.0<1>:ud  r78.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    0:w               {I@4}
        shr (8|M0)               r125.0<1>:ud  r117.0<1;1,0>:ud  31:w              
        and (8|M0)               r96.0<1>:d    r46.0<1;1,0>:d    255:w               {Compacted}
(f1.0)  goto (8|M0)                          L43960                  L43960                
L43904:
(W)     mov (1|M0)               r6.16<2>:b    1:w                              
        add (8|M0)               r81.0<1>:d    r96.0<1;1,0>:d    -r97.0<1;1,0>:d  {Compacted,I@3}
        mov (8|M0)               r17.0<1>:b    r6.16<0;1,0>:b                   {I@2}
        goto (8|M0)                          L43960                  L44048                
L43960:
        join (8|M0)                          L44048                                
L43976:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L44048                  L50520                
L44008:
(W)     mov (1|M0)               r6.16<2>:b    0:w                              
        add (8|M0)               r81.0<1>:d    r96.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r17.0<1>:b    r6.16<0;1,0>:b                   {I@2}
L44048:
        join (8|M0)                          L50520                                
L44064:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    0:w               {I@3}
(f1.0)  goto (8|M0)                          L48008                  L48008                
L44096:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r81.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L44256                  L44256                
L44128:
        shr (8|M0)               r124.0<1>:ud  r98.0<1;1,0>:ud   1:w              
        cmp (8|M0)    (eq)f1.1   r44.0<1>:d    r97.0<1;1,0>:d    0:w              
        and (8|M0)               r99.0<1>:d    r117.0<1;1,0>:d   1:w               {Compacted}
        or (8|M0)                r24.0<1>:d    r124.0<1;1,0>:d   4194304:d               {I@3}
        mov (8|M0)               r101.0<1>:d   0:w                              
        mov (8|M0)               r103.0<1>:f   r99.0<1;1,0>:f                   {Compacted,I@3}
        bfn.0xD8 (8|M0)          r102.0<1>:ud  r44.0<1;0>:ud     r124.0<1;0>:ud    r24.0<1>:ud      {I@2} // s0&s1|~s0&s2
        mov (8|M0)               r99.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L44256                  L44952                
L44256:
        join (8|M0)                          L44952                                
L44272:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r81.0<1;1,0>:ud   0x18:uw             
(f1.0)  goto (8|M0)                          L44688                  L44688                
L44304:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r81.0<1;1,0>:d    25:w              
        mov (8|M0)               r99.0<1>:d    r17.0<1;1,0>:ub                 
(f1.1)  goto (8|M0)                          L44448                  L44448                
L44352:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    25:w              
(~f1.0) goto (8|M0)                          L44448                  L44592                
L44384:
        cmp (8|M0)    (ne)f1.0   r101.0<1>:d   r98.0<1;1,0>:d    0:w              
        mov (8|M0)               r103.0<1>:d   0:w                              
        mov (8|M0)               r102.0<1>:d   0:w                              
        goto (8|M0)                          L44448                  L44952                
L44448:
        join (8|M0)                          L44592                                
L44464:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r81.0<1;1,0>:d    24:w              
(~f1.1) goto (8|M0)                          L44592                  L44592                
L44496:
        shr (8|M0)               r22.0<1>:ud   r117.0<1;1,0>:ud  22:w              
        and (8|M0)               r43.0<1>:d    r117.0<1;1,0>:d   4194303:d              
        mov (8|M0)               r103.0<1>:f   r99.0<1;1,0>:f                   {Compacted,I@7}
        mov (8|M0)               r102.0<1>:d   0:w                              
        cmp (8|M0)    (ne)f1.1   r101.0<1>:d   r43.0<1;1,0>:d    0:w               {I@2}
        and (8|M0)               r99.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted,F@1}
        goto (8|M0)                          L44592                  L44952                
L44592:
        join (8|M0)                          L44688                                
L44608:
        cmp (8|M0)    (ne)f1.0   r101.0<1>:d   r117.0<1;1,0>:d   0:w              
        mov (8|M0)               r99.0<1>:d    0:w                              
        mov (8|M0)               r103.0<1>:d   0:w                              
        mov (8|M0)               r102.0<1>:d   0:w                              
        goto (8|M0)                          L44688                  L44952                
L44688:
        join (8|M0)                          L44952                                
L44704:
        add (8|M0)               acc0.0<1>:d   r81.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r81.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    0:w              
        shr (8|M0)               r27.0<1>:ud   r98.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r105.0<1>:d   r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:d     -1:w                              
        add (8|M0)               acc0.0<1>:d   -r81.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r113.0<1>:ud  r98.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r26.0<1>:ud   r105.0<1;0>:ud    r6.4<0;0>:ud      r98.0<1>:ud      {I@3} // (s0^s1)&s2
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r25.0<1>:ud   r98.0<1;1,0>:ud   r81.0<1;1,0>:d  
        and (8|M0)               r99.0<1>:d    r113.0<1;1,0>:d   1:w               {Compacted}
        shl (8|M0)               r100.0<1>:d   r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(f1.0)  mov (8|M0)               r100.0<1>:d   0:w                              
        cmp (8|M0)    (ne)f1.1   r101.0<1>:d   r26.0<1;1,0>:d    0:w              
        mov (8|M0)               r103.0<1>:f   r99.0<1;1,0>:f                   {Compacted,I@4}
        or (8|M0)                r102.0<1>:d   r25.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@2}
        and (8|M0)               r99.0<1>:d    r27.0<1;1,0>:d    1:w               {Compacted,F@1}
L44952:
        join (8|M0)                          L48008                                
L44968:
        cmp (8|M0)    (ne)f1.0   r118.0<1>:d   r101.0<1;1,0>:d   0:w               {I@4}
        shl (8|M0)               r115.0<1>:d   r102.0<1;1,0>:d   3:w               {Compacted,I@4}
        shl (8|M0)               r42.0<1>:d    r103.0<1;1,0>:d   2:w               {Compacted}
        shl (8|M0)               r41.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted,I@5}
        mov (8|M0)               r118.0<1>:d   -r118.0<1;1,0>:d                 {I@4}
        or (8|M0)                r115.0<1>:d   r115.0<1;1,0>:d   r42.0<1;1,0>:d   {Compacted,I@3}
        shl (8|M0)               r117.0<1>:d   r23.0<1;1,0>:d    3:w               {Compacted}
        bfn.0xFE (8|M0)          r111.0<1>:ud  r115.0<1;0>:ud    r41.0<1;0>:ud     r118.0<1>:ud     {I@2} // s0|s1|s2
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r117.0<1;1,0>:ud  r111.0<1;1,0>:ud {I@1}
(f1.1)  goto (8|M0)                          L45136                  L45136                
L45088:
        add (8|M0)               r120.0<1>:d   r117.0<1;1,0>:d   -r111.0<1;1,0>:d {Compacted}
        and (8|M0)               r104.0<1>:d   r120.0<1;1,0>:d   7:w               {Compacted,I@1}
        shr (8|M0)               r116.0<1>:ud  r120.0<1;1,0>:ud  3:w              
        goto (8|M0)                          L45136                  L47616                
L45136:
        join (8|M0)                          L47616                                
L45152:
        or (8|M0)                acc0.0<1>:d   r117.0<1;1,0>:d   67108864:d              
        add (8|M0)               r71.0<1>:d    acc0.0<1;1,0>:d   -r111.0<1;1,0>:d
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    33554432:d               {I@1}
(~f1.0) goto (8|M0)                          L47200                  L47200                
L45216:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    16777216:d              
(~f1.1) goto (8|M0)                          L47152                  L47152                
L45248:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    8388608:d              
(~f1.0) goto (8|M0)                          L47104                  L47104                
L45280:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L47056                  L47056                
L45312:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L47008                  L47008                
L45344:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    1048576:d              
(~f1.1) goto (8|M0)                          L46960                  L46960                
L45376:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    524288:d              
(~f1.0) goto (8|M0)                          L46912                  L46912                
L45408:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    262144:d              
(~f1.1) goto (8|M0)                          L46864                  L46864                
L45440:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    131072:d              
(~f1.0) goto (8|M0)                          L46816                  L46816                
L45472:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L46768                  L46768                
L45504:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L46720                  L46720                
L45536:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    16384:w              
(~f1.1) goto (8|M0)                          L46672                  L46672                
L45568:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    8192:w              
(~f1.0) goto (8|M0)                          L46624                  L46624                
L45600:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    4096:w              
(~f1.1) goto (8|M0)                          L46576                  L46576                
L45632:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    2048:w              
(~f1.0) goto (8|M0)                          L46528                  L46528                
L45664:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L46480                  L46480                
L45696:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L46432                  L46432                
L45728:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    256:w              
(~f1.1) goto (8|M0)                          L46384                  L46384                
L45760:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    128:w              
(~f1.0) goto (8|M0)                          L46336                  L46336                
L45792:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    64:w              
(~f1.1) goto (8|M0)                          L46288                  L46288                
L45824:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    32:w              
(~f1.0) goto (8|M0)                          L46240                  L46240                
L45856:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L46192                  L46192                
L45888:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L46144                  L46144                
L45920:
        and (8|M0)    (eq)f1.1   null<1>:d     r71.0<1;1,0>:d    4:w              
(~f1.1) goto (8|M0)                          L46096                  L46096                
L45952:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L46048                  L46048                
L45984:
        and (8|M0)    (eq)f1.0   null<1>:d     r71.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (8|M0)               r73.0<1>:d    r6.8<0;1,0>:w     25:w               {F@1}
        goto (8|M0)                          L46048                  L47232                
L46048:
        join (8|M0)                          L46096                                
L46064:
        mov (8|M0)               r73.0<1>:d    24:w                              
        goto (8|M0)                          L46096                  L47232                
L46096:
        join (8|M0)                          L46144                                
L46112:
        mov (8|M0)               r73.0<1>:d    23:w                              
        goto (8|M0)                          L46144                  L47232                
L46144:
        join (8|M0)                          L46192                                
L46160:
        mov (8|M0)               r73.0<1>:d    22:w                              
        goto (8|M0)                          L46192                  L47232                
L46192:
        join (8|M0)                          L46240                                
L46208:
        mov (8|M0)               r73.0<1>:d    21:w                              
        goto (8|M0)                          L46240                  L47232                
L46240:
        join (8|M0)                          L46288                                
L46256:
        mov (8|M0)               r73.0<1>:d    20:w                              
        goto (8|M0)                          L46288                  L47232                
L46288:
        join (8|M0)                          L46336                                
L46304:
        mov (8|M0)               r73.0<1>:d    19:w                              
        goto (8|M0)                          L46336                  L47232                
L46336:
        join (8|M0)                          L46384                                
L46352:
        mov (8|M0)               r73.0<1>:d    18:w                              
        goto (8|M0)                          L46384                  L47232                
L46384:
        join (8|M0)                          L46432                                
L46400:
        mov (8|M0)               r73.0<1>:d    17:w                              
        goto (8|M0)                          L46432                  L47232                
L46432:
        join (8|M0)                          L46480                                
L46448:
        mov (8|M0)               r73.0<1>:d    16:w                              
        goto (8|M0)                          L46480                  L47232                
L46480:
        join (8|M0)                          L46528                                
L46496:
        mov (8|M0)               r73.0<1>:d    15:w                              
        goto (8|M0)                          L46528                  L47232                
L46528:
        join (8|M0)                          L46576                                
L46544:
        mov (8|M0)               r73.0<1>:d    14:w                              
        goto (8|M0)                          L46576                  L47232                
L46576:
        join (8|M0)                          L46624                                
L46592:
        mov (8|M0)               r73.0<1>:d    13:w                              
        goto (8|M0)                          L46624                  L47232                
L46624:
        join (8|M0)                          L46672                                
L46640:
        mov (8|M0)               r73.0<1>:d    12:w                              
        goto (8|M0)                          L46672                  L47232                
L46672:
        join (8|M0)                          L46720                                
L46688:
        mov (8|M0)               r73.0<1>:d    11:w                              
        goto (8|M0)                          L46720                  L47232                
L46720:
        join (8|M0)                          L46768                                
L46736:
        mov (8|M0)               r73.0<1>:d    10:w                              
        goto (8|M0)                          L46768                  L47232                
L46768:
        join (8|M0)                          L46816                                
L46784:
        mov (8|M0)               r73.0<1>:d    9:w                              
        goto (8|M0)                          L46816                  L47232                
L46816:
        join (8|M0)                          L46864                                
L46832:
        mov (8|M0)               r73.0<1>:d    8:w                              
        goto (8|M0)                          L46864                  L47232                
L46864:
        join (8|M0)                          L46912                                
L46880:
        mov (8|M0)               r73.0<1>:d    7:w                              
        goto (8|M0)                          L46912                  L47232                
L46912:
        join (8|M0)                          L46960                                
L46928:
        mov (8|M0)               r73.0<1>:d    6:w                              
        goto (8|M0)                          L46960                  L47232                
L46960:
        join (8|M0)                          L47008                                
L46976:
        mov (8|M0)               r73.0<1>:d    5:w                              
        goto (8|M0)                          L47008                  L47232                
L47008:
        join (8|M0)                          L47056                                
L47024:
        mov (8|M0)               r73.0<1>:d    4:w                              
        goto (8|M0)                          L47056                  L47232                
L47056:
        join (8|M0)                          L47104                                
L47072:
        mov (8|M0)               r73.0<1>:d    3:w                              
        goto (8|M0)                          L47104                  L47232                
L47104:
        join (8|M0)                          L47152                                
L47120:
        mov (8|M0)               r73.0<1>:d    2:w                              
        goto (8|M0)                          L47152                  L47232                
L47152:
        join (8|M0)                          L47200                                
L47168:
        mov (8|M0)               r73.0<1>:d    1:w                              
        goto (8|M0)                          L47200                  L47232                
L47200:
        join (8|M0)                          L47232                                
L47216:
        mov (8|M0)               r73.0<1>:d    0:w                              
L47232:
        join (8|M0)                          L47616                                
L47248:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r81.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f0.1)  sel (8|M0)               r17.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r19.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.0   null<1>:uw    r19.0<1;1,0>:uw   r17.0<1;1,0>:uw  {I@1}
(f1.0)  goto (8|M0)                          L47544                  L47544                
L47344:
        add (8|M0)               r79.0<1>:d    r73.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r96.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r96.0<1;1,0>:ud   r79.0<1;1,0>:ud  {I@2}
        not (8|M0)               acc2.0<1>:d   r73.0<1;1,0>:d                  
        and (8|M0)               r18.0<1>:d    r78.0<1;1,0>:d    -2147483648:d              
        add (8|M0)               acc2.0<1>:d   r96.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f1.0) mov (8|M0)               r79.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r68.0<1>:d    acc2.0<1;1,0>:d   23:w              
        shl (8|M0)               r79.0<1>:d    r71.0<1;1,0>:d    r79.0<1;1,0>:d   {Compacted,I@2}
(~f1.0) mov (8|M0)               r68.0<1>:d    0:w                              
        shr (8|M0)               r79.0<1>:ud   r79.0<1;1,0>:ud   3:w               {I@2}
        and (8|M0)               r79.0<1>:d    r79.0<1;1,0>:d    8388607:d               {I@1}
        bfn.0xFE (8|M0)          r79.0<1>:ud   r18.0<1;0>:ud     r68.0<1;0>:ud     r79.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L47544                  L50632                
L47544:
        join (8|M0)                          L47616                                
L47560:
        shr (8|M0)               r39.0<1>:ud   r71.0<1;1,0>:ud   2:w              
        shl (8|M0)               r38.0<1>:d    r71.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r96.0<1>:d    r96.0<1;1,0>:d    -1:w               {Compacted}
        and (8|M0)               r116.0<1>:d   r39.0<1;1,0>:d    8388607:d               {I@3}
        and (8|M0)               r104.0<1>:d   r38.0<1;1,0>:d    6:w               {Compacted,I@3}
L47616:
        join (8|M0)                          L48008                                
L47632:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   0:w               {I@2}
(f1.1)  goto (8|M0)                          L47824                  L47824                
L47664:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r104.0<1;1,0>:ud  0x4:uw             
(f1.0)  goto (8|M0)                          L47776                  L47776                
L47696:
        and (8|M0)    (ne)f1.1   null<1>:d     r116.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r109.0<1>:d   r6.8<0;1,0>:w     0:w               {F@1}
        goto (8|M0)                          L47776                  L47856                
L47776:
        join (8|M0)                          L47824                                
L47792:
        mov (8|M0)               r109.0<1>:d   1:w                              
        goto (8|M0)                          L47824                  L47856                
L47824:
        join (8|M0)                          L47856                                
L47840:
        mov (8|M0)               r109.0<1>:d   0:w                              
L47856:
        join (8|M0)                          L48008                                
L47872:
        add (8|M0)               r108.0<1>:d   r116.0<1;1,0>:d   r109.0<1;1,0>:d  {Compacted,I@2}
        and (8|M0)               r17.0<1>:d    r78.0<1;1,0>:d    -2147483648:d              
        cmp (8|M0)    (gt)f1.1   r37.0<1>:ud   r108.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r108.0<1;1,0>:ud  0x7FFFFF:ud             
        add3 (8|M0)              acc0.0<1>:d   r96.0<1;0>:d      -r37.0<1;0>:d     0:w               {I@2}
(~f0.1) sel (8|M0)               r21.0<1>:d    r108.0<1;1,0>:d   0:w              
        shl (8|M0)               r107.0<1>:d   acc0.0<1;1,0>:d   23:w              
        bfn.0xFE (8|M0)          r79.0<1>:ud   r17.0<1;0>:ud     r107.0<1;0>:ud    r21.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L48008                  L50632                
L48008:
        join (8|M0)                          L50520                                
L48024:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r23.0<1;1,0>:d    r98.0<1;1,0>:d  
(W)     mov (1|M0)               r6.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.5<1>:d     8388608:d                              
(f0.1)  goto (8|M0)                          L50440                  L50440                
L48080:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r23.0<1;1,0>:ud   r98.0<1;1,0>:ud 
(f1.1)  goto (8|M0)                          L48256                  L48256                
L48112:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L48176                  L48176                
L48144:
        add (8|M0)               r77.0<1>:d    r98.0<1;1,0>:d    -r23.0<1;1,0>:d  {Compacted}
        mov (8|M0)               r119.0<1>:f   r125.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L48176                  L48360                
L48176:
        join (8|M0)                          L48256                                
L48192:
        or (8|M0)                acc0.0<1>:d   r23.0<1;1,0>:d    8388608:d              
        add (8|M0)               r110.0<1>:d   acc0.0<1;1,0>:d   -r98.0<1;1,0>:d 
        bfn.0xF8 (8|M0)          r79.0<1>:ud   r78.0<1;0>:ud     r6.6<0;0>:ud      r110.0<1>:ud     {A@1} // s0&s1|s2
        goto (8|M0)                          L48256                  L50632                
L48256:
        join (8|M0)                          L48360                                
L48272:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r97.0<1;1,0>:d    0:w              
        add (8|M0)               r77.0<1>:d    r23.0<1;1,0>:d    -r98.0<1;1,0>:d  {Compacted}
(~f0.1) goto (8|M0)                          L48360                  L48360                
L48312:
        and (8|M0)               r36.0<1>:d    r78.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r79.0<1>:ud   r36.0<1;0>:ud     r77.0<1;0>:ud     r6.5<0>:ud       {I@1} // s0|s1|s2
        goto (8|M0)                          L48360                  L50632                
L48360:
        join (8|M0)                          L50440                                
L48376:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L50152                  L50152                
L48408:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L50104                  L50104                
L48440:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    1048576:d              
(~f0.1) goto (8|M0)                          L50056                  L50056                
L48472:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    524288:d              
(~f1.1) goto (8|M0)                          L50008                  L50008                
L48504:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    262144:d              
(~f1.0) goto (8|M0)                          L49960                  L49960                
L48536:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    131072:d              
(~f0.1) goto (8|M0)                          L49912                  L49912                
L48568:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L49864                  L49864                
L48600:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L49816                  L49816                
L48632:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    16384:w              
(~f0.1) goto (8|M0)                          L49768                  L49768                
L48664:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    8192:w              
(~f1.1) goto (8|M0)                          L49720                  L49720                
L48696:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    4096:w              
(~f1.0) goto (8|M0)                          L49672                  L49672                
L48728:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    2048:w              
(~f0.1) goto (8|M0)                          L49624                  L49624                
L48760:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L49576                  L49576                
L48792:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L49528                  L49528                
L48824:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    256:w              
(~f0.1) goto (8|M0)                          L49480                  L49480                
L48856:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    128:w              
(~f1.1) goto (8|M0)                          L49432                  L49432                
L48888:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    64:w              
(~f1.0) goto (8|M0)                          L49384                  L49384                
L48920:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    32:w              
(~f0.1) goto (8|M0)                          L49336                  L49336                
L48952:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L49288                  L49288                
L48984:
        and (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L49240                  L49240                
L49016:
        and (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    4:w              
(~f0.1) goto (8|M0)                          L49192                  L49192                
L49048:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L49144                  L49144                
L49080:
        and (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (8|M0)               r82.0<1>:d    r6.8<0;1,0>:w     22:w               {F@1}
        goto (8|M0)                          L49144                  L50184                
L49144:
        join (8|M0)                          L49192                                
L49160:
        mov (8|M0)               r82.0<1>:d    21:w                              
        goto (8|M0)                          L49192                  L50184                
L49192:
        join (8|M0)                          L49240                                
L49208:
        mov (8|M0)               r82.0<1>:d    20:w                              
        goto (8|M0)                          L49240                  L50184                
L49240:
        join (8|M0)                          L49288                                
L49256:
        mov (8|M0)               r82.0<1>:d    19:w                              
        goto (8|M0)                          L49288                  L50184                
L49288:
        join (8|M0)                          L49336                                
L49304:
        mov (8|M0)               r82.0<1>:d    18:w                              
        goto (8|M0)                          L49336                  L50184                
L49336:
        join (8|M0)                          L49384                                
L49352:
        mov (8|M0)               r82.0<1>:d    17:w                              
        goto (8|M0)                          L49384                  L50184                
L49384:
        join (8|M0)                          L49432                                
L49400:
        mov (8|M0)               r82.0<1>:d    16:w                              
        goto (8|M0)                          L49432                  L50184                
L49432:
        join (8|M0)                          L49480                                
L49448:
        mov (8|M0)               r82.0<1>:d    15:w                              
        goto (8|M0)                          L49480                  L50184                
L49480:
        join (8|M0)                          L49528                                
L49496:
        mov (8|M0)               r82.0<1>:d    14:w                              
        goto (8|M0)                          L49528                  L50184                
L49528:
        join (8|M0)                          L49576                                
L49544:
        mov (8|M0)               r82.0<1>:d    13:w                              
        goto (8|M0)                          L49576                  L50184                
L49576:
        join (8|M0)                          L49624                                
L49592:
        mov (8|M0)               r82.0<1>:d    12:w                              
        goto (8|M0)                          L49624                  L50184                
L49624:
        join (8|M0)                          L49672                                
L49640:
        mov (8|M0)               r82.0<1>:d    11:w                              
        goto (8|M0)                          L49672                  L50184                
L49672:
        join (8|M0)                          L49720                                
L49688:
        mov (8|M0)               r82.0<1>:d    10:w                              
        goto (8|M0)                          L49720                  L50184                
L49720:
        join (8|M0)                          L49768                                
L49736:
        mov (8|M0)               r82.0<1>:d    9:w                              
        goto (8|M0)                          L49768                  L50184                
L49768:
        join (8|M0)                          L49816                                
L49784:
        mov (8|M0)               r82.0<1>:d    8:w                              
        goto (8|M0)                          L49816                  L50184                
L49816:
        join (8|M0)                          L49864                                
L49832:
        mov (8|M0)               r82.0<1>:d    7:w                              
        goto (8|M0)                          L49864                  L50184                
L49864:
        join (8|M0)                          L49912                                
L49880:
        mov (8|M0)               r82.0<1>:d    6:w                              
        goto (8|M0)                          L49912                  L50184                
L49912:
        join (8|M0)                          L49960                                
L49928:
        mov (8|M0)               r82.0<1>:d    5:w                              
        goto (8|M0)                          L49960                  L50184                
L49960:
        join (8|M0)                          L50008                                
L49976:
        mov (8|M0)               r82.0<1>:d    4:w                              
        goto (8|M0)                          L50008                  L50184                
L50008:
        join (8|M0)                          L50056                                
L50024:
        mov (8|M0)               r82.0<1>:d    3:w                              
        goto (8|M0)                          L50056                  L50184                
L50056:
        join (8|M0)                          L50104                                
L50072:
        mov (8|M0)               r82.0<1>:d    2:w                              
        goto (8|M0)                          L50104                  L50184                
L50104:
        join (8|M0)                          L50152                                
L50120:
        mov (8|M0)               r82.0<1>:d    1:w                              
        goto (8|M0)                          L50152                  L50184                
L50152:
        join (8|M0)                          L50184                                
L50168:
        mov (8|M0)               r82.0<1>:d    0:w                              
L50184:
        join (8|M0)                          L50440                                
L50200:
        add (8|M0)               r123.0<1>:d   r82.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r96.0<1;1,0>:ud   r123.0<1;1,0>:ud {I@1}
(f1.0)  goto (8|M0)                          L50296                  L50296                
L50240:
        add (8|M0)               acc0.0<1>:d   r96.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r121.0<1>:d   0:w                              
        shl (8|M0)               r122.0<1>:d   r77.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L50296                  L50384                
L50296:
        join (8|M0)                          L50384                                
L50312:
        not (8|M0)               acc0.0<1>:d   r82.0<1;1,0>:d                  
        shl (8|M0)               r34.0<1>:d    r77.0<1;1,0>:d    r123.0<1;1,0>:d  {Compacted}
        add (8|M0)               acc0.0<1>:d   r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
        and (8|M0)               r122.0<1>:d   r34.0<1;1,0>:d    8388607:d               {I@2}
        shl (8|M0)               r121.0<1>:d   acc0.0<1;1,0>:d   23:w              
L50384:
        join (8|M0)                          L50440                                
L50400:
        shl (8|M0)               r33.0<1>:d    r119.0<1;1,0>:d   31:w               {Compacted}
        bfn.0xFE (8|M0)          r79.0<1>:ud   r33.0<1;0>:ud     r121.0<1;0>:ud    r122.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L50440                  L50632                
L50440:
        join (8|M0)                          L50520                                
L50456:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r97.0<1;1,0>:d    0:w              
        bfn.0xF8 (8|M0)          r11.0<1>:ud   r78.0<1;0>:ud     r6.6<0;0>:ud      r6.5<0>:ud       // s0&s1|s2
(f0.1)  sel (8|M0)               r79.0<1>:f    r11.0<1;1,0>:f    0.0:f               {I@1}
        goto (8|M0)                          L50520                  L50632                
L50520:
        join (8|M0)                          L50632                                
L50536:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r23.0<1;1,0>:ud   r98.0<1;1,0>:ud  {F@1}
        add (8|M0)               acc0.0<1>:d   r98.0<1;1,0>:d    -r23.0<1;1,0>:d 
        add (8|M0)               r112.0<1>:d   r23.0<1;1,0>:d    -r98.0<1;1,0>:d  {Compacted}
(f0.1)  sel (8|M0)               acc2.0<1>:d   r119.0<1;1,0>:d   r125.0<1;1,0>:d 
(~f0.1) mov (8|M0)               r112.0<1>:d   acc0.0<1;1,0>:d                 
        shl (8|M0)               r106.0<1>:d   acc2.0<1;1,0>:d   31:w              
        or (8|M0)                r79.0<1>:d    r106.0<1;1,0>:d   r112.0<1;1,0>:d  {Compacted,I@1}
L50632:
        join (8|M0)                          L50648                                
L50648:
        mov (8|M0)               r102.0<1>:f   r79.0<1;1,0>:f                   {Compacted,I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r6.2                             {A@1}
L50704:
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
