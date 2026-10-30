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
(W)     mov (8|M0)               r9.0<1>:ud    r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r9.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r9.1<0;1,0>:ud   {AccWrEn,$1.dst}
        mov (16|M0)              r10.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (2|M0)               r48.0<1>:d    r4.6<1;1,0>:d                   
        addc (8|M0)              r12.0<1>:ud   r2.0<0;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted,I@2}
        add (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r13.0<1>:ud   r2.0<0;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r50.0<1>:ud   r12.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r52.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r51.0<1>:ud   r13.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r50.0<1;1,0>:ud   r48.0<0;1,0>:ud  {I@1}
        add (8|M8)               r53.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r52.0<1;1,0>:d    r48.1<0;1,0>:d   {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r52.0<1;1,0>:ud   r48.1<0;1,0>:ud 
(~f0.0) goto (16|M0)                         L5096                  L5096                
L536:
(W)     shr (1|M0)               r2.0<1>:ud    r5.0<0;1,0>:ud    20:w               {$2.dst}
(W)     asr (1|M0)               r2.1<1>:d     r5.0<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r49.2<1>:f    1.463628e-39:f                              
(W)     asr (1|M0)               r49.0<1>:d    r5.0<0;1,0>:d     31:w               {Compacted}
(W)     and (1|M0)               r5.5<1>:d     r5.0<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r3.0<1>:ud    r2.1<0;0>:ud      r49.2<0;0>:ud     r2.0<0>:ud       {A@1} // s0&s1|s2
(W)     mov (1|M0)               r49.4<1>:f    1.048576e+06:f                               {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r49.0<0;1,0>:ud   8:w               {I@3}
(W)     mov (1|M0)               r49.3<1>:f    r5.5<0;1,0>:ud                   {I@3}
(W)     mov (1|M0)               r80.4<1>:f    r3.0<0;1,0>:ud                   {Compacted,I@2}
(W)     mov (1|M0)               r49.5<1>:f    0x53800000:f                               {Compacted}
(W)     mov (1|M0)               r80.5<1>:f    r2.2<0;1,0>:ud                   {I@1}
(W)     mad (1|M0)               r6.0<1>:f     r49.3<0;0>:f      r49.4<0;0>:f      r80.4<0>:f       {F@3}
(W)     asr (1|M0)               r54.1<1>:d    r5.1<0;1,0>:d     31:w               {Compacted}
(W)     mad (1|M0)               r7.0<1>:f     r6.0<0;0>:f       r49.5<0;0>:f      r80.5<0>:f       {F@1}
(W)     asr (1|M0)               r54.3<1>:d    r5.4<0;1,0>:d     31:w              
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r8.3<1>:f     r7.0<0;1,0>:f                    {$3}
(W)     mov (1|M0)               r8.4<1>:f     -4.172325e-07:f                               {Compacted}
(W)     add (1|M0)               r2.0<1>:d     r54.1<0;1,0>:d    r5.1<0;1,0>:d    {I@2}
(W)     add (1|M0)               r3.0<1>:d     r54.3<0;1,0>:d    r5.4<0;1,0>:d    {I@2}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r5.0<0;1,0>:d     0:w              
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     0:w              
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.4<0;1,0>:d     0:w               {Compacted}
        mov (16|M0)              r56.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r58.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r48.2<1>:d    r5.2<1;1,0>:d                   
(W)     mov (2|M0)               r48.4<1>:d    r6.2<1;1,0>:d                   
(W)     mov (2|M0)               r48.6<1>:d    r6.4<1;1,0>:d                   
(W)     asr (1|M0)               r49.1<1>:d    r6.6<0;1,0>:d     31:w              
(W)     mov (1|M0)               r54.5<1>:d    7:w                              
(W)     mov (1|M0)               r54.6<1>:f    0xCF800000:f                               {Compacted}
(W)     mov (1|M0)               r54.7<1>:f    -1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r55.0<1>:f    -1.0:f                               {Compacted}
(W)     mul (1|M0)               r49.7<1>:f    r49.3<0;1,0>:f    9.536743e-07:f              
(W)     mul (1|M0)               r55.4<1>:f    r80.4<0;1,0>:f    -1.048576e+06:f              
(W)     mul (1|M0)               r54.0<1>:f    r80.4<0;1,0>:f    9.536743e-07:f               {Compacted}
(W)     mul (1|M0)               r55.5<1>:f    r80.5<0;1,0>:f    -1.048576e+06:f              
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r49.6<1>:f    r8.3<0;0>:f       r8.4<0;0>:f       r8.3<0>:f        {F@7}
(W)     xor (1|M0)               r54.2<1>:d    r2.0<0;1,0>:d     r54.1<0;1,0>:d   {I@7}
(W)     xor (1|M0)               r54.4<1>:d    r3.0<0;1,0>:d     r54.3<0;1,0>:d   {I@7}
L1080:
        shr (16|M0)              r2.0<1>:ud    r58.0<1;1,0>:ud   8:w               {F@7}
        sync.nop                             null                             {Compacted,$4.src}
        or (16|M0)               r14.0<1>:d    r2.0<1;1,0>:d     r49.0<0;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r14.0<1;1,0>:ud   0x1:uw              {I@1}
        shl (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    24:w               {Compacted}
        shr (16|M0)              r12.0<1>:ud   r56.0<1;1,0>:ud   8:w              
        and (16|M0)              r60.0<1>:d    r56.0<1;1,0>:d    3:w               {Compacted}
        shr (16|M0)              r62.0<1>:ud   r56.0<1;1,0>:ud   2:w              
        or (16|M0)               r64.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@3}
(~f1.1) goto (16|M0)                         L1656                  L1656                
L1200:
(~f1.0) goto (16|M0)                         L1248                  L1248                
L1216:
        mov (16|M0)              r66.0<1>:d    -1:w                              
        goto (16|M0)                         L1248                  L1608                
L1248:
        join (16|M0)                         L1608                                
L1264:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r10.0<1>:f    r64.0<1;1,0>:ud                  {Compacted,I@7}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r5.5<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f    r5.5<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r14.0<1>:d    r64.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r5.6<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r20.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r20.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      -r5.6<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r28.0<1>:f    r5.5<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r30.0<1>:ud   r28.0<1;1,0>:f                   {A@1}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r32.0<1>:d    r32.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r33.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r33.0<1>:d    r33.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r64.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r10.0<1>:ud   r32.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r66.0<1>:d    r30.0<1;0>:d      r16.0<1;0>:d      -r10.0<1>:d      {I@1}
L1608:
        join (16|M0)                         L1656                                
L1624:
        mov (16|M0)              r68.0<1>:d    0:w                              
        goto (16|M0)                         L1656                  L2688                
L1656:
        join (16|M0)                         L2688                                
L1672:
        shr (16|M0)              r2.0<1>:ud    r58.0<1;1,0>:ud   16:w              
        mov (16|M0)              r10.0<1>:f    r2.0<1;1,0>:ud                   {Compacted,I@1}
        shl (16|M0)              r22.0<1>:d    r58.0<1;1,0>:d    4:w               {Compacted}
        shr (16|M0)              r24.0<1>:ud   r56.0<1;1,0>:ud   28:w              
        mul (16|M0)              acc0.0<1>:f   r49.6<0;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@1}
        shr (16|M0)              r20.0<1>:ud   r64.0<1;1,0>:ud   20:w              
        or (16|M0)               r24.0<1>:d    r24.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@2}
        rndd (16|M0)             r14.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        bfn.0xF8 (16|M0)         r20.0<1>:ud   r24.0<1;0>:ud     r49.2<0;0>:ud     r20.0<1>:ud      {I@1} // s0&s1|s2
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r14.0<1;0>:f      -r49.3<0>:f      {Compacted,F@1}
        mov (16|M0)              r26.0<1>:f    r20.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r14.0<1;0>:f      r55.4<0>:f       {Compacted}
        mad (16|M0)              acc2.0<1>:f   r26.0<1;0>:f      acc0.0<1;0>:f     r49.4<0>:f       {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r49.6<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r2.0<1>:f     acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc2.0<1>:f   r49.7<0;1,0>:f    r2.0<1;1,0>:f    {Compacted,F@1}
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        and (16|M0)              r24.0<1>:d    r64.0<1;1,0>:d    1048575:d              
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r2.0<1;0>:f       -r80.4<0>:f     
        mad (16|M0)              r32.0<1>:f    -acc2.0<1;0>:f    r2.0<1;0>:f       r49.7<0>:f      
        mov (16|M0)              r20.0<1>:f    r24.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r10.0<1>:f    acc0.0<1;0>:f     r2.0<1;0>:f       r55.5<0>:f       {Compacted}
        mad (16|M0)              r22.0<1>:f    r26.0<1;0>:f      r32.0<1;0>:f      r54.7<0>:f       {Compacted,F@3}
        mad (16|M0)              r34.0<1>:f    r10.0<1;0>:f      acc2.0<1;0>:f     r55.0<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r20.0<1;0>:f      r22.0<1;0>:f      r49.4<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r34.0<1;0>:f      r49.5<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r49.6<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r18.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r49.7<0;1,0>:f    r18.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              acc2.0<1>:f   r54.0<0;1,0>:f    r18.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r12.0<1>:f    r34.0<1;0>:f      r18.0<1;0>:f      -r80.5<0>:f      {Compacted}
        mad (16|M0)              r10.0<1>:f    r22.0<1;0>:f      acc0.0<1;0>:f     r55.0<0>:f       {Compacted}
        mad (16|M0)              r32.0<1>:f    -acc2.0<1;0>:f    r18.0<1;0>:f      r54.0<0>:f      
        mad (16|M0)              r40.0<1>:f    -acc0.0<1;0>:f    r18.0<1;0>:f      r49.7<0>:f      
        mad (16|M0)              acc2.0<1>:f   r12.0<1;0>:f      acc2.0<1;0>:f     r55.0<0>:f       {Compacted,F@4}
        mad (16|M0)              r42.0<1>:f    r10.0<1;0>:f      r32.0<1;0>:f      r54.7<0>:f       {Compacted,F@3}
        mad (16|M0)              r26.0<1>:f    r20.0<1;0>:f      r40.0<1;0>:f      r54.7<0>:f       {Compacted,F@3}
        mad (16|M0)              acc0.0<1>:f   r42.0<1;0>:f      acc2.0<1;0>:f     r49.4<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r26.0<1;0>:f      acc0.0<1;0>:f     r49.4<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r49.6<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r16.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mad (16|M0)              acc0.0<1>:f   acc2.0<1;0>:f     -r16.0<1;0>:f     r80.5<0>:f       {F@1}
        mul (16|M0)              acc2.0<1>:f   acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        rndz (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r22.0<1>:f    r42.0<1;0>:f      -r16.0<1;0>:f     r80.4<0>:f       {Compacted}
        mad (16|M0)              r30.0<1>:f    r26.0<1;0>:f      -r16.0<1;0>:f     r49.3<0>:f       {Compacted}
        mad (16|M0)              r26.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r54.6<0>:f      
        mov (16|M0)              r38.0<1>:d    r14.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r12.0<1>:d    r16.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r10.0<1>:d    r22.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r14.0<1>:d    r30.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r16.0<1>:ud   r26.0<1;1,0>:f                   {F@1}
        mov (16|M0)              r34.0<1>:d    r2.0<1;1,0>:f                    {Compacted}
        asr (16|M0)              r28.0<1>:d    r14.0<1;1,0>:d    31:w               {Compacted,I@3}
        addc (8|M0)              r22.0<1>:ud   r14.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    8:w               {Compacted,I@4}
        asr (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    31:w               {Compacted}
        mov (16|M0)              r44.0<1>:d    r18.0<1;1,0>:f                   {Compacted}
        add3 (8|M0)              r30.0<1>:ud   acc0.0<1;0>:ud    r16.0<1;0>:ud     r28.0<1>:ud      {I@3}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     20:w               {Compacted,I@3}
        shl (16|M0)              r18.0<1>:d    r10.0<1;1,0>:d    20:w               {Compacted}
        addc (8|M8)              r23.0<1>:ud   r15.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M0)              r10.0<1>:ud   r10.0<1;1,0>:ud   12:w              
        add3 (8|M8)              r31.0<1>:ud   acc0.0<1;0>:ud    r17.0<1;0>:ud     r29.0<1>:ud     
        or (16|M0)               r24.0<1>:d    r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@2}
        addc (8|M0)              r40.0<1>:ud   r22.0<1;1,0>:ud   r18.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r5.10<1>:w    -1:w                              
        add3 (8|M0)              r2.0<1>:ud    acc0.0<1;0>:ud    r30.0<1;0>:ud     r24.0<1>:ud      {I@3}
        addc (8|M8)              r41.0<1>:ud   r23.0<1;1,0>:ud   r19.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r20.0<1>:d    r34.0<1;1,0>:d    20:w               {Compacted}
        cmp (16|M0)   (ge)f1.1   null<1>:d     r40.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@2}
        add3 (8|M8)              r3.0<1>:ud    acc0.0<1;0>:ud    r31.0<1;0>:ud     r25.0<1>:ud     
        shr (16|M0)              r26.0<1>:ud   r34.0<1;1,0>:ud   12:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     r49.0<0;1,0>:d   {I@2}
        shl (16|M0)              r10.0<1>:d    r38.0<1;1,0>:d    8:w               {Compacted}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    r49.0<0;1,0>:ud 
        addc (8|M0)              r32.0<1>:ud   r20.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f1.1)  sel (16|M0)              r14.0<1>:d    r5.10<0;1,0>:w    0:w              
        add3 (8|M0)              r36.0<1>:ud   acc0.0<1;0>:ud    r26.0<1;0>:ud     r10.0<1>:ud      {I@4}
        add3 (16|M0)             r16.0<1>:d    r12.0<1;0>:d      r44.0<1;0>:d      -r14.0<1>:d      {I@2}
        addc (8|M8)              r33.0<1>:ud   r21.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        add3 (8|M8)              r37.0<1>:ud   acc0.0<1;0>:ud    r27.0<1;0>:ud     r11.0<1>:ud     
        addc (8|M0)              r66.0<1>:ud   r32.0<1;1,0>:ud   r16.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        add (8|M0)               r68.0<1>:ud   acc0.0<1;1,0>:ud  r36.0<1;1,0>:ud 
        addc (8|M8)              r67.0<1>:ud   r33.0<1;1,0>:ud   r17.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M8)               r69.0<1>:ud   acc0.0<1;1,0>:ud  r37.0<1;1,0>:ud  {I@4}
L2688:
        join (16|M0)                         L5096                                
L2704:
        mul (8|M0)               acc0.0<1>:ud  r66.0<1;1,0>:ud   r5.0<0;1,0>:uw   {I@5}
        mach (8|M0)              r2.0<1>:ud    r66.0<1;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,Compacted}
        shr (16|M0)              r22.0<1>:ud   r56.0<1;1,0>:ud   3:w              
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r67.0<1;1,0>:ud   r5.0<0;1,0>:uw   {I@7}
        mach (8|M8)              r3.0<1>:ud    r67.0<1;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r20.0<1>:d    r66.0<1;1,0>:d    5:w               {Compacted}
        mov (8|M8)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r66.0<1;1,0>:ud   r49.0<0;1,0>:uw 
        mach (8|M0)              r12.0<1>:d    r66.0<1;1,0>:ud   r49.0<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r67.0<1;1,0>:ud   r49.0<0;1,0>:uw 
        mach (8|M8)              r13.0<1>:d    r67.0<1;1,0>:ud   r49.0<0;1,0>:d  
        add (16|M0)              r70.0<1>:d    r64.0<1;1,0>:d    -r10.0<1;1,0>:d  {Compacted,I@5}
(W)     mul (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:ud    r68.0<2;1,0>:uw 
        add (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r12.0<1;1,0>:d   {Compacted,I@3}
        mach (8|M0)              r12.0<1>:d    r5.0<0;1,0>:ud    r68.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r5.0<0;1,0>:ud    r69.0<2;1,0>:uw 
        and (16|M0)              r22.0<1>:d    r22.0<1;1,0>:d    28:w               {Compacted}
        shl (16|M0)              r18.0<1>:d    r70.0<1;1,0>:d    3:w               {Compacted,I@6}
        mach (8|M8)              r13.0<1>:d    r5.0<0;1,0>:ud    r69.0<1;1,0>:d  
        bfn.0xFE (16|M0)         r74.0<1>:ud   r20.0<1;0>:ud     r22.0<1;0>:ud     r60.0<1>:ud      {I@3} // s0|s1|s2
        bfn.0xEA (16|M0)         r72.0<1>:ud   r18.0<1;0>:ud     r62.0<1;0>:ud     r54.5<0>:ud      {I@3} // s0|s1&s2
        add (16|M0)              r16.0<1>:d    r14.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
(~f0.1) goto (16|M0)                         L3048                  L3048                
L3016:
        mov (16|M0)              r76.0<1>:d    -1:w                              
        goto (16|M0)                         L3048                  L3472                
L3048:
        join (16|M0)                         L3472                                
L3064:
        asr (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    28:w               {Compacted}
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r72.0<1;1,0>:d   {Compacted,I@1}
        xor (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r5.5<1>:f     r54.2<0;1,0>:ud                  {A@1}
(W)     mov (1|M0)               r6.7<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r6.1<1>:f     r5.5<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r7.0<1>:f     r6.1<0;0>:f       r6.7<0;0>:f       r6.1<0>:f        {F@2}
(W)     mov (1|M0)               r5.6<1>:ud    r5.5<0;1,0>:f                   
        mov (16|M0)              r18.0<1>:ud   r14.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r16.0<1>:f    r14.0<1;1,0>:f    r7.0<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r6.0<1>:d     r54.2<0;1,0>:d    -r5.6<0;1,0>:d   {I@2}
        add (16|M0)              r18.0<1>:d    r12.0<1;1,0>:d    -r18.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r10.0<1>:ud   r16.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r7.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r20.0<1>:f    r18.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r22.0<1>:f    r10.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r14.0<1;0>:f      r22.0<1;0>:f      -r5.5<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r20.0<1;0>:f      r22.0<1;0>:f      -r7.1<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r30.0<1>:f    r7.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r32.0<1>:ud   r30.0<1;1,0>:f                   {A@1}
        add (16|M0)              r34.0<1>:d    r32.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r34.0<1;1,0>:d    r54.4<0;1,0>:uw  {Compacted,I@1}
        mach (8|M0)              r16.0<1>:d    r34.0<1;1,0>:d    r54.2<0;1,0>:d   {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r35.0<1;1,0>:d    r54.4<0;1,0>:uw 
        mach (8|M8)              r17.0<1>:d    r35.0<1;1,0>:d    r54.2<0;1,0>:d   {Compacted}
        xor (16|M0)              r36.0<1>:d    r54.1<0;1,0>:d    r2.0<1;1,0>:d    {Compacted}
        add (16|M0)              r16.0<1>:d    r12.0<1;1,0>:d    -r16.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.1   r14.0<1>:ud   r16.0<1;1,0>:ud   r54.2<0;1,0>:ud  {I@1}
        add3 (16|M0)             r18.0<1>:d    r34.0<1;0>:d      r36.0<1;0>:d      -r14.0<1>:d      {I@1}
        bfn.0x96 (16|M0)         r76.0<1>:ud   r18.0<1;0>:ud     r54.1<0;0>:ud     r2.0<1>:ud       {I@1} // s0^s1^s2
L3472:
        join (16|M0)                         L5096                                
L3488:
(~f0.0) goto (16|M0)                         L3536                  L3536                
L3504:
        mov (16|M0)              r78.0<1>:d    -1:w                              
        goto (16|M0)                         L3536                  L3960                
L3536:
        join (16|M0)                         L3960                                
L3552:
        asr (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    26:w               {Compacted}
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r74.0<1;1,0>:d   {Compacted,I@1}
        xor (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r5.5<1>:f     r54.4<0;1,0>:ud                  {A@1}
(W)     mov (1|M0)               r6.7<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r6.1<1>:f     r5.5<0;1,0>:f                    {@2,$7}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        sync.nop                             null                             {Compacted,$7.dst}
(W)     mad (1|M0)               r7.0<1>:f     r6.1<0;0>:f       r6.7<0;0>:f       r6.1<0>:f        {F@2}
(W)     mov (1|M0)               r5.6<1>:ud    r5.5<0;1,0>:f                   
        mov (16|M0)              r18.0<1>:ud   r14.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r16.0<1>:f    r14.0<1;1,0>:f    r7.0<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r6.0<1>:d     r54.4<0;1,0>:d    -r5.6<0;1,0>:d   {I@2}
        add (16|M0)              r18.0<1>:d    r12.0<1;1,0>:d    -r18.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r10.0<1>:ud   r16.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r7.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r20.0<1>:f    r18.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r22.0<1>:f    r10.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r14.0<1;0>:f      r22.0<1;0>:f      -r5.5<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r20.0<1;0>:f      r22.0<1;0>:f      -r7.1<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r30.0<1>:f    r7.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r32.0<1>:ud   r30.0<1;1,0>:f                   {A@1}
        add (16|M0)              r34.0<1>:d    r32.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r34.0<1;1,0>:d    r54.8<0;1,0>:uw  {Compacted,I@1}
        mach (8|M0)              r16.0<1>:d    r34.0<1;1,0>:d    r54.4<0;1,0>:d   {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r35.0<1;1,0>:d    r54.8<0;1,0>:uw 
        mach (8|M8)              r17.0<1>:d    r35.0<1;1,0>:d    r54.4<0;1,0>:d   {Compacted}
        xor (16|M0)              r36.0<1>:d    r54.3<0;1,0>:d    r2.0<1;1,0>:d    {Compacted}
        add (16|M0)              r16.0<1>:d    r12.0<1;1,0>:d    -r16.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.1   r14.0<1>:ud   r16.0<1;1,0>:ud   r54.4<0;1,0>:ud  {I@1}
        add3 (16|M0)             r18.0<1>:d    r34.0<1;0>:d      r36.0<1;0>:d      -r14.0<1>:d      {I@1}
        bfn.0x96 (16|M0)         r78.0<1>:ud   r18.0<1;0>:ud     r54.3<0;0>:ud     r2.0<1>:ud       {I@1} // s0^s1^s2
L3960:
        join (16|M0)                         L5096                                
L3976:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    r76.0<1;1,0>:d   {I@2}
(f1.1)  goto (16|M0)                         L4056                  L4056                
L4008:
(W)     mov (1|M0)               r2.0<2>:b     0:w                              
        mov (16|M0)              r80.0<1>:b    r2.0<0;1,0>:b                    {I@1}
        goto (16|M0)                         L4056                  L4792                
L4056:
        join (16|M0)                         L4792                                
L4072:
        mul (8|M0)               acc0.0<1>:ud  r76.0<1;1,0>:ud   r48.12<0;1,0>:uw
        mach (8|M0)              r10.0<1>:ud   r76.0<1;1,0>:ud   r48.6<0;1,0>:ud  {AccWrEn,Compacted}
        asr (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    31:w               {Compacted}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r77.0<1;1,0>:ud   r48.12<0;1,0>:uw
        mach (8|M8)              r11.0<1>:ud   r77.0<1;1,0>:ud   r48.6<0;1,0>:ud  {AccWrEn}
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:ud   r48.14<0;1,0>:uw
        mach (8|M0)              r16.0<1>:d    r76.0<1;1,0>:ud   r48.7<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r77.0<1;1,0>:ud   r48.14<0;1,0>:uw
        mach (8|M8)              r17.0<1>:d    r77.0<1;1,0>:ud   r48.7<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r48.6<0;1,0>:ud   r2.0<2;1,0>:uw   {I@7}
        add (16|M0)              r18.0<1>:d    r10.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r16.0<1>:d    r48.6<0;1,0>:ud   r2.0<1;1,0>:d   
(W)     mul (8|M8)               acc0.0<1>:d   r48.6<0;1,0>:ud   r3.0<2;1,0>:uw  
        mach (8|M8)              r17.0<1>:d    r48.6<0;1,0>:ud   r3.0<1;1,0>:d   
(W)     mul (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:d    r5.2<0;1,0>:uw   {Compacted}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        mach (8|M0)              r12.0<1>:d    r76.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted,F@1}
(W)     mul (8|M8)               acc0.0<1>:d   r77.0<1;1,0>:d    r5.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:d    r77.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        add (16|M0)              r12.0<1>:d    r72.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:ud  r12.0<1;1,0>:ud   r6.12<0;1,0>:uw  {I@1}
        mach (8|M0)              r10.0<1>:ud   r12.0<1;1,0>:ud   r6.6<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r13.0<1;1,0>:ud   r6.12<0;1,0>:uw 
        mach (8|M8)              r11.0<1>:ud   r13.0<1;1,0>:ud   r6.6<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r12.0<1;1,0>:ud   r49.2<0;1,0>:uw 
        mach (8|M0)              r16.0<1>:d    r12.0<1;1,0>:ud   r49.1<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r13.0<1;1,0>:ud   r49.2<0;1,0>:uw 
        mach (8|M8)              r17.0<1>:d    r13.0<1;1,0>:ud   r49.1<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:d    r5.8<0;1,0>:uw   {Compacted}
        mach (8|M0)              r26.0<1>:d    r76.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r77.0<1;1,0>:d    r5.8<0;1,0>:uw  
        mov (16|M0)              r2.0<1>:f     r22.0<1;1,0>:f                   {Compacted,A@7}
        mach (8|M8)              r27.0<1>:d    r77.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
        addc (8|M0)              r22.0<1>:ud   r14.0<1;1,0>:ud   r48.4<0;1,0>:ud  {AccWrEn,Compacted,F@1}
        add (16|M0)              r18.0<1>:d    r10.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@6}
        add3 (8|M0)              r30.0<1>:ud   acc0.0<1;0>:ud    r20.0<1;0>:ud     r48.5<0>:ud     
        addc (8|M8)              r23.0<1>:ud   r15.0<1;1,0>:ud   r48.4<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        add3 (8|M8)              r31.0<1>:ud   acc0.0<1;0>:ud    r21.0<1;0>:ud     r48.5<0>:ud     
        addc (8|M0)              r12.0<1>:ud   r22.0<1;1,0>:ud   r2.0<1;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r28.0<1>:d    r74.0<1;1,0>:d    -r26.0<1;1,0>:d  {Compacted}
        add3 (8|M0)              r10.0<1>:ud   acc0.0<1;0>:ud    r30.0<1;0>:ud     r24.0<1>:ud      {A@1}
        addc (8|M8)              r13.0<1>:ud   r23.0<1;1,0>:ud   r3.0<1;1,0>:ud   {AccWrEn,I@5}
        add3 (8|M8)              r11.0<1>:ud   acc0.0<1;0>:ud    r31.0<1;0>:ud     r25.0<1>:ud      {I@5}
        addc (8|M0)              r16.0<1>:ud   r12.0<1;1,0>:ud   r28.0<1;1,0>:ud  {AccWrEn,Compacted,I@4}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r17.0<1>:ud   r13.0<1;1,0>:ud   r29.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M0)               r32.1<2>:ud   r18.0<1;1,0>:ud   r10.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r32.0<2>:d    r16.0<1;1,0>:d                  
        add (8|M8)               r34.1<2>:ud   r26.0<1;1,0>:ud   r11.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r34.0<2>:d    r17.0<1;1,0>:d                  
        send.ugm (16|M0)         r14      r32     null:0  0x0            0x08280980           {A@1,$8} // wr:4+0, rd:2; load.ugm.d8u32.a64.ca.ca
        mov (16|M0)              r80.0<1>:b    r14.0<4;1,0>:b                   {$8.dst}
L4792:
        join (16|M0)                         L5096                                
L4808:
        addc (8|M0)              r2.0<1>:ud    r56.0<1;1,0>:ud   r48.2<0;1,0>:ud  {AccWrEn,Compacted}
        mov (16|M0)              r18.0<1>:ud   r80.0<1;1,0>:ub                  {I@3}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r57.0<1;1,0>:ud   r48.2<0;1,0>:ud  {AccWrEn}
        add3 (8|M0)              r11.1<2>:ud   r10.0<1;0>:ud     r58.0<1;0>:ud     r48.3<0>:ud      {I@2}
        mov (8|M8)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r11.0<2>:d    r2.0<1;1,0>:d                   
        add (8|M0)               r84.0<1>:ud   acc0.0<1;1,0>:ud  r58.0<1;1,0>:ud 
        addc (8|M8)              r83.0<1>:ud   r57.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn}
        add3 (8|M8)              r13.1<2>:ud   r16.0<1;0>:ud     r59.0<1;0>:ud     r48.3<0>:ud      {I@5}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r82.0<1;1,0>:ud   r48.0<0;1,0>:ud  {I@2}
        add (8|M8)               r85.0<1>:ud   acc0.0<1;1,0>:ud  r59.0<1;1,0>:ud 
        mov (8|M8)               r13.0<2>:d    r3.0<1;1,0>:d                   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    r48.1<0;1,0>:d   {I@2}
        send.ugm (16|M0)         null     r11     r18:2   0x0            0x080E0984           {A@2,$4} // wr:4+2, rd:0; store.ugm.d8u32.a64.wb.wb
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r84.0<1;1,0>:ud   r48.1<0;1,0>:ud 
(~f1.1) goto (16|M0)                         L5096                  L5096                
L5064:
(f1.1)  sel (16|M0)              r56.0<1>:d    r82.0<1;1,0>:d    r50.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r58.0<1>:d    r84.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L1080                                
L5096:
        join (16|M0)                         L5112                                
L5112:
(W)     mov (8|M0)               r127.0<1>:f   r9.0<1;1,0>:f                    {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5136:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x19:ud                             
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
