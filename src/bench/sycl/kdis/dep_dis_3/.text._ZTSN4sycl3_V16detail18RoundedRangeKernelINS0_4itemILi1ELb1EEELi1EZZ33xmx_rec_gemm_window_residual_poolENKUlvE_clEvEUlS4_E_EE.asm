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
(W)     mov (8|M0)               r80.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r80.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r80.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r10.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r12.0<1>:ud   r2.0<0;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted,I@1}
        add (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r13.0<1>:ud   r2.0<0;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r54.0<1>:ud   r12.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r50.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r55.0<1>:ud   r13.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r51.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r50.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r50.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L15904                  L15904                
L520:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     0:w               {$2.dst}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     0:w              
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r5.24<0;1,0>:b    0:w              
        mov (16|M0)              r38.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r48.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r8.0<1>:d     r6.6<1;1,0>:d                   
(W)     mov (2|M0)               r35.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
(W)     mov (2|M0)               r8.5<1>:d     r7.2<1;1,0>:d                   
(W)     mov (2|M0)               r35.2<1>:d    r7.4<1;1,0>:d                   
(W)     mov (2|M0)               r35.4<1>:d    r7.6<1;1,0>:d                   
(W)     mov (1|M0)               r81.0<1>:f    -0.0:f                               {Compacted}
(W)     mov (1|M0)               r35.7<1>:f    inf:f                               {Compacted}
(W)     mov (1|M0)               r35.6<1>:d    -1:w                              
(W)     mov (1|M0)               r8.7<1>:d     7:w                              
(W)     mov (1|M0)               r81.2<1>:uw   f1.1<0;1,0>:uw                  
L720:
(W)     mov (1|M0)               f1.0<1>:uw    r81.2<0;1,0>:uw                  {I@1}
(~f1.0) goto (16|M0)                         L784                  L784                
L752:
        mov (16|M0)              r60.0<1>:d    -1:w                              
        goto (16|M0)                         L784                  L1168                
L784:
        join (16|M0)                         L1168                                
L800:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$3.src}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r10.0<1>:f    r38.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r5.7<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f    r5.7<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r14.0<1>:d    r38.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r20.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r20.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      -r6.0<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r28.0<1>:f    r5.7<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r30.0<1>:ud   r28.0<1;1,0>:f                   {A@1}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r32.0<1>:d    r32.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r33.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r33.0<1>:d    r33.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r38.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r10.0<1>:ud   r32.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r60.0<1>:d    r30.0<1;0>:d      r16.0<1;0>:d      -r10.0<1>:d      {I@1}
L1168:
        join (16|M0)                         L15904                                
L1184:
        shr (16|M0)              r58.0<1>:ud   r60.0<1;1,0>:ud   6:w               {I@2}
(~f0.1) goto (16|M0)                         L1248                  L1248                
L1216:
        mov (16|M0)              r110.0<1>:d   -1:w                              
        goto (16|M0)                         L1248                  L1640                
L1248:
        join (16|M0)                         L1640                                
L1264:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$3.src}
(W)     mov (1|M0)               r2.0<1>:f     r5.1<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r10.0<1>:f    r58.0<1;1,0>:ud                  {Compacted,I@6}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r5.7<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f    r5.7<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.1<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r14.0<1>:d    r58.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r20.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r20.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      -r6.0<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r28.0<1>:f    r5.7<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r30.0<1>:ud   r28.0<1;1,0>:f                   {A@1}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r5.2<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r32.0<1>:d    r32.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r33.0<1;1,0>:d    r5.2<0;1,0>:uw  
        mach (8|M8)              r33.0<1>:d    r33.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r58.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r10.0<1>:ud   r32.0<1;1,0>:ud   r5.1<0;1,0>:ud   {I@1}
        add3 (16|M0)             r110.0<1>:d   r30.0<1;0>:d      r16.0<1;0>:d      -r10.0<1>:d      {I@1}
L1640:
        join (16|M0)                         L15904                                
L1656:
(W)     mul (8|M0)               acc0.0<1>:d   r110.0<1;1,0>:d   r5.2<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r12.0<1>:d    r110.0<1;1,0>:d   r5.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r111.0<1;1,0>:d   r5.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:d    r111.0<1;1,0>:d   r5.1<0;1,0>:d    {Compacted}
        shl (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   3:w               {Compacted,$3.src}
        add (16|M0)              r12.0<1>:d    r58.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        shr (16|M0)              r10.0<1>:ud   r60.0<1;1,0>:ud   3:w              
        shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    3:w               {Compacted,I@2}
        bfn.0xEA (16|M0)         r6.0<1>:ud    r2.0<1;0>:ud      r10.0<1;0>:ud     r8.7<0>:ud       {I@2} // s0|s1&s2
        bfn.0xEA (16|M0)         r2.0<1>:ud    r12.0<1;0>:ud     r60.0<1;0>:ud     r8.7<0>:ud       {I@2} // s0|s1&s2
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    r5.3<0;1,0>:ud   {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r6.0<1;1,0>:ud    r5.2<0;1,0>:ud  
(f1.0)  goto (16|M0)                         L15736                  L15736                
L1816:
        add (16|M0)              r114.0<1>:d   r6.0<1;1,0>:d     -r5.2<0;1,0>:d   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r114.0<1;1,0>:ud  r5.4<0;1,0>:ud   {I@1}
(~f1.1) goto (16|M0)                         L15736                  L15736                
L1856:
        add (16|M0)              r116.0<1>:d   r2.0<1;1,0>:d     -r5.3<0;1,0>:d   {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r116.0<1;1,0>:ud  r5.5<0;1,0>:ud   {I@1}
(~f1.0) goto (16|M0)                         L15736                  L15736                
L1896:
(W)     mul (8|M0)               acc0.0<1>:d   r60.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted}
        mach (8|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r61.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r61.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r114.0<1;1,0>:ud  r5.10<0;1,0>:uw 
        mach (8|M0)              r10.0<1>:ud   r114.0<1;1,0>:ud  r5.5<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r104.0<1>:d   r38.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r115.0<1;1,0>:ud  r5.10<0;1,0>:uw 
        mach (8|M8)              r11.0<1>:ud   r115.0<1;1,0>:ud  r5.5<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        mov (16|M0)              r16.0<1>:f    r10.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r116.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r117.0<1;1,0>:ud {AccWrEn}
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        mul (8|M0)               acc0.0<1>:ud  r18.0<1;1,0>:ud   r5.0<0;1,0>:uw   {I@4}
        mach (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r19.0<1;1,0>:ud   r5.0<0;1,0>:uw   {I@5}
        mach (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:ud    r20.0<2;1,0>:uw 
        mach (8|M0)              r10.0<1>:d    r5.0<0;1,0>:ud    r20.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r5.0<0;1,0>:ud    r21.0<2;1,0>:uw  {I@7}
        mov (16|M0)              r12.0<1>:f    r22.0<1;1,0>:f                   {Compacted,A@4}
        mach (8|M8)              r11.0<1>:d    r5.0<0;1,0>:ud    r21.0<1;1,0>:d  
        addc (8|M0)              r46.0<1>:ud   r12.0<1;1,0>:ud   r104.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
        add (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@2}
        add (8|M0)               r44.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@1}
        addc (8|M8)              r47.0<1>:ud   r13.0<1;1,0>:ud   r105.0<1;1,0>:ud {AccWrEn}
        add (8|M8)               r45.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
(f0.0)  goto (16|M0)                         L2536                  L2536                
L2320:
        shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    1:w               {Compacted,I@3}
        addc (8|M0)              r14.0<1>:ud   r2.0<1;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r10.0<1>:ud   r46.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r15.0<1>:ud   r3.0<1;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M8)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r17.1<2>:ud   r16.0<1;0>:ud     r12.0<1;0>:ud     r8.1<0>:ud       {I@2}
        add3 (8|M8)              r19.1<2>:ud   r22.0<1;0>:ud     r13.0<1;0>:ud     r8.1<0>:ud       {I@2}
        mov (8|M0)               r17.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M8)               r19.0<2>:d    r15.0<1;1,0>:d                  
        send.ugm (16|M0)         r24      r17     null:0  0x0            0x08280B80           {A@1,$7} // wr:4+0, rd:2; load.ugm.d16u32.a64.ca.ca
        mov (16|M0)              r9.0<1>:uw    r24.0<2;1,0>:uw                  {$7.dst}
        sync.nop                             null                             {Compacted,$4.dst}
        mov (16|M0)              r52.0<1>:f    r9.0<1;1,0>:hf                   {I@1}
        goto (16|M0)                         L2536                  L2712                
L2536:
        join (16|M0)                         L2712                                
L2552:
        shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    2:w               {Compacted}
        addc (8|M0)              r14.0<1>:ud   r2.0<1;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r10.0<1>:ud   r46.0<1;1,0>:ud   30:w              
        shl (16|M0)              r12.0<1>:d    r44.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r15.0<1>:ud   r3.0<1;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M8)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r17.1<2>:ud   r16.0<1;0>:ud     r12.0<1;0>:ud     r8.1<0>:ud       {I@2}
        add3 (8|M8)              r19.1<2>:ud   r22.0<1;0>:ud     r13.0<1;0>:ud     r8.1<0>:ud       {I@2}
        mov (8|M0)               r17.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M8)               r19.0<2>:d    r15.0<1;1,0>:d                  
        send.ugm (16|M0)         r52      r17     null:0  0x0            0x08280580           {A@1,$4} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
L2712:
        join (16|M0)                         L15736                                
L2728:
        shl (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   2:w               {Compacted}
        addc (8|M0)              r10.0<1>:ud   r2.0<1;1,0>:ud    r35.0<0;1,0>:ud  {AccWrEn,Compacted,I@1}
        shl (16|M0)              r42.0<1>:d    r38.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r3.0<1;1,0>:ud    r35.0<0;1,0>:ud  {AccWrEn}
        shl (16|M0)              r18.0<1>:d    r48.0<1;1,0>:d    2:w               {Compacted,$4.src}
        mov (8|M8)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r16.0<1>:ud   r42.0<1;1,0>:ud   r8.5<0;1,0>:ud   {AccWrEn,Compacted,I@5}
        shr (16|M0)              r20.0<1>:ud   r38.0<1;1,0>:ud   30:w              
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r17.0<1>:ud   r43.0<1;1,0>:ud   r8.5<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r24.0<1>:ud   r104.0<1;1,0>:ud  30:w              
        or (16|M0)               r40.0<1>:d    r18.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@4}
        mov (8|M8)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r27.1<2>:ud   r12.0<1;0>:ud     r24.0<1;0>:ud     r35.1<0>:ud      {I@3}
        add3 (8|M8)              r29.1<2>:ud   r14.0<1;0>:ud     r25.0<1;0>:ud     r35.1<0>:ud     
        add3 (8|M0)              r31.1<2>:ud   r22.0<1;0>:ud     r40.0<1;0>:ud     r8.6<0>:ud       {I@4}
        mov (8|M0)               r27.0<2>:d    r10.0<1;1,0>:d                  
        add3 (8|M8)              r33.1<2>:ud   r26.0<1;0>:ud     r41.0<1;0>:ud     r8.6<0>:ud       {I@5}
        mov (8|M8)               r29.0<2>:d    r11.0<1;1,0>:d                  
        mov (8|M0)               r31.0<2>:d    r16.0<1;1,0>:d                  
        mov (8|M8)               r33.0<2>:d    r17.0<1;1,0>:d                  
        send.ugm (16|M0)         r2       r27     null:0  0x0            0x08280580           {A@3,$8} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        send.ugm (16|M0)         r36      r31     null:0  0x0            0x08280580           {A@1,$9} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        sync.allwr                           ($8,$9)                
        mad (16|M0)              r56.0<1>:f    r36.0<1;0>:f      r2.0<1;0>:f       r52.0<1>:f       {Compacted,$4.dst}
        and (16|M0)              r18.0<1>:d    r56.0<1;1,0>:d    2147483647:d               {F@1}
        sel (16|M0)   (lt)f0.0   r74.0<1>:f    r18.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r52.0<1>:ud   r74.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r114.0<1>:d   r74.0<1;1,0>:d    8388607:d              
        and (16|M0)              r112.0<1>:d   r52.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r10.0<1>:ud   r112.0<1;1,0>:ud  0x79:uw             
        shl (16|M0)              r62.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.1) goto (16|M0)                         L3208                  L3208                
L3176:
        mov (16|M0)              r108.0<1>:ud  0x7FC00000:ud                             
        goto (16|M0)                         L3208                  L9200                
L3208:
        join (16|M0)                         L9200                                
L3224:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   0:w              
        add (16|M0)              r24.0<1>:d    -r62.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   255:w              
        xor (16|M0)              r78.0<1>:d    r24.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L9168                  L9168                
L3296:
        or (16|M0)    (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   r114.0<1;1,0>:d 
(~f1.1) goto (16|M0)                         L3360                  L3360                
L3328:
        mov (16|M0)              r108.0<1>:ud  0x0:ud                             
        goto (16|M0)                         L3360                  L9200                
L3360:
        join (16|M0)                         L9168                                
L3376:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   0:w              
        shr (16|M0)              r76.0<1>:ud   r24.0<1;1,0>:ud   23:w              
        add (16|M0)              r74.0<1>:d    r112.0<1;1,0>:d   -127:w               {Compacted}
(f1.1)  mov (16|M0)              r74.0<1>:d    -126:w                              
        add (16|M0)              r72.0<1>:d    r76.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r72.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L9104                  L9104                
L3472:
        or (16|M0)    (eq)f1.0   null<4>:b     r52.0<1;1,0>:d    r76.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L9040                  L9040                
L3504:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r81.6<1>:d    0:w                              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r114.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r70.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r68.0<1>:ud   r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r81.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r81.4<1>:d    0:w                              
L3608:
(W)     shl (1|M0)               r2.0<1>:d     r81.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r81.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r81.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r81.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r70.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r81.2<1>:ud   r81.3<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r81.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r81.6<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r81.2<0;1,0>:d    r68.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r81.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r81.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.13<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r6.0<1>:ud    r81.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r9.0<1>:uw    r5.13<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r5.13<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r81.7<1>:ud   r3.0<0;1,0>:ud    r81.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r102.0<1>:d   r81.4<0;1,0>:d                  
        mov (16|M0)              r100.0<1>:d   r81.5<0;1,0>:d                  
        mov (16|M0)              r66.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r64.0<1>:d    r81.7<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L4008                  L4008                
L3944:
(W)     mov (1|M0)               r81.3<1>:d    r81.2<0;1,0>:d                  
(W)     mov (1|M0)               r81.4<1>:d    r6.0<0;1,0>:d                   
(W)     mov (1|M0)               r81.5<1>:d    r81.7<0;1,0>:d                  
(W)     jmpi                                 L3608                                
L4008:
        join (16|M0)                         L9040                                
L4024:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r98.0<1>:ud   r2.0<0;1,0>:ud    r102.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r120.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r100.0<1>:ud    {A@1}
        subb (8|M8)              r99.0<1>:ud   r2.0<0;1,0>:ud    r103.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r124.0<1>:d   r72.0<1;0>:d      r98.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r124.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r121.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r101.0<1>:ud   
        add3 (16|M0)             r6.0<1>:d     r76.0<1;0>:d      r74.0<1;0>:d      r98.0<1>:d      
(f1.1)  goto (16|M0)                         L8976                  L8976                
L4176:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r124.0<1;1,0>:d   -127:w              
(f1.0)  goto (16|M0)                         L6656                  L6656                
L4208:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r124.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L6152                  L6152                
L4240:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r60.0<1>:ud   r2.0<0;1,0>:ud    r102.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r64.0<1>:d    r72.0<1;0>:d      r98.0<1;0>:d      -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r100.0<1>:ud    {F@1}
        subb (8|M8)              r61.0<1>:ud   r2.0<0;1,0>:ud    r103.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:ud   r64.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r101.0<1>:ud   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.1)  goto (16|M0)                         L4464                  L4464                
L4408:
        add3 (16|M0)             r2.0<1>:d     r6.0<1;0>:d       -r60.0<1;0>:d     -23:w              
        mov (16|M0)              r20.0<1>:d    0:w                              
        shl (16|M0)              r22.0<1>:d    r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L4464                  L6088                
L4464:
        join (16|M0)                         L6088                                
L4480:
        add3 (16|M0)             r58.0<1>:d    r60.0<1;0>:d      -r6.0<1;0>:d      23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r58.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L4624                  L4624                
L4520:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r58.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L4624                  L4672                
L4552:
        shr (16|M0)              r122.0<1>:ud  r70.0<1;1,0>:ud   1:w              
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r82.0<1>:d    0:w                              
        mov (16|M0)              r92.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L4624                  L5560                
L4624:
        join (16|M0)                         L4672                                
L4640:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L4672                  L5504                
L4672:
        join (16|M0)                         L5504                                
L4688:
        add3 (16|M0)             r2.0<1>:d     r60.0<1;0>:d      -r64.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r10.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L4760                  L4760                
L4736:
        mov (16|M0)              r52.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4760                  L4872                
L4760:
        join (16|M0)                         L4872                                
L4776:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r122.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f1.0)  or (16|M0)               r122.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r52.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@1}
L4872:
        join (16|M0)                         L5504                                
L4888:
        add3 (16|M0)             r60.0<1>:d    r60.0<1;0>:d      -r64.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r6.0<1>:d     r60.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L4960                  L4960                
L4936:
        mov (16|M0)              r122.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4960                  L5064                
L4960:
        join (16|M0)                         L5064                                
L4976:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r6.0<1;1,0>:ud    0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r6.0<1;1,0>:d     -32:w              
(~f1.0) shr (16|M0)              r122.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r6.0<1;1,0>:d    32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r6.0<1;1,0>:d   
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r122.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L5064:
        join (16|M0)                         L5504                                
L5080:
        and (16|M0)   (ne)f1.1   r96.0<1>:d    r60.0<1;1,0>:d    63:w              
        and (16|M0)              r82.0<1>:d    r122.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L5168                  L5168                
L5120:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        mov (16|M0)              r104.0<1>:d   -1:w                              
        goto (16|M0)                         L5168                  L5352                
L5168:
        join (16|M0)                         L5352                                
L5184:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L5288                  L5288                
L5216:
        add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r104.0<1>:d   r5.13<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5288                  L5352                
L5288:
        join (16|M0)                         L5352                                
L5304:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r104.0<1>:d   -1:w                              
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r96.0<1;1,0>:d   {F@1}
L5352:
        join (16|M0)                         L5504                                
L5368:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r35.6<0;0>:ud     r70.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r104.0<1;0>:ud    r35.6<0;0>:ud     r68.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r92.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.13<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r84.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L5504                  L5560                
L5504:
        join (16|M0)                         L5560                                
L5520:
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r82.0<1>:d    0:w                              
        mov (16|M0)              r92.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
L5560:
        join (16|M0)                         L6088                                
L5576:
        and (16|M0)   (ne)f1.1   r126.0<1>:d   r58.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L5632                  L5632                
L5608:
        mov (16|M0)              r122.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5632                  L5736                
L5632:
        join (16|M0)                         L5736                                
L5648:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r122.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r122.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L5736:
        join (16|M0)                         L6088                                
L5752:
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r36.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r84.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r36.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L5856                  L5856                
L5824:
        mov (16|M0)              r58.0<1>:d    0:w                              
        goto (16|M0)                         L5856                  L6016                
L5856:
        join (16|M0)                         L6016                                
L5872:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r36.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L5936                  L5936                
L5904:
        mov (16|M0)              r58.0<1>:d    1:w                              
        goto (16|M0)                         L5936                  L6016                
L5936:
        join (16|M0)                         L6016                                
L5952:
        and (16|M0)   (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r58.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6016:
        join (16|M0)                         L6088                                
L6032:
        add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    r122.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.7<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r22.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r20.0<1>:d    r5.7<0;1,0>:d     0:w               {Compacted,F@1}
L6088:
        join (16|M0)                         L6152                                
L6104:
        and (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r108.0<1>:ud  r2.0<1;0>:ud      r20.0<1;0>:ud     r22.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L6152                  L9200                
L6152:
        join (16|M0)                         L6656                                
L6168:
        and (16|M0)   (ne)f1.1   r72.0<1>:d    r98.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L6248                  L6248                
L6200:
        mov (16|M0)              r86.0<1>:d    -1:w                              
        mov (16|M0)              r94.0<1>:d    -1:w                              
        goto (16|M0)                         L6248                  L6432                
L6248:
        join (16|M0)                         L6432                                
L6264:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L6368                  L6368                
L6296:
        add (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r86.0<1>:d    0:w                              
        shl (16|M0)              r94.0<1>:d    r5.13<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6368                  L6432                
L6368:
        join (16|M0)                         L6432                                
L6384:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r94.0<1>:d    -1:w                              
        shl (16|M0)              r86.0<1>:d    r2.0<0;1,0>:w     r72.0<1;1,0>:d   {F@1}
L6432:
        join (16|M0)                         L6656                                
L6448:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r86.0<1;0>:ud     r35.6<0;0>:ud     r70.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r94.0<1;0>:ud     r35.6<0;0>:ud     r68.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r78.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r124.0<1;1,0>:d   -150:w              
(f1.1)  goto (16|M0)                         L6600                  L6600                
L6560:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r108.0<1>:f   r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L6600                  L9200                
L6600:
        join (16|M0)                         L6656                                
L6616:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r108.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L6656                  L9200                
L6656:
        join (16|M0)                         L8976                                
L6672:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r98.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r112.0<1>:d   r72.0<1;0>:d      r98.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L8664                  L8664                
L6736:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L6968                  L6968                
L6840:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L6968                  L7032                
L6888:
        shr (16|M0)              r122.0<1>:ud  r70.0<1;1,0>:ud   1:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r36.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r122.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6968                  L8136                
L6968:
        join (16|M0)                         L7032                                
L6984:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r64.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L7032                  L8048                
L7032:
        join (16|M0)                         L8048                                
L7048:
        add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r22.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r116.0<1>:d   -r66.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L7120                  L7120                
L7096:
        mov (16|M0)              r114.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L7120                  L7232                
L7120:
        join (16|M0)                         L7232                                
L7136:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r122.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r22.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r22.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r122.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r114.0<1>:f   r122.0<1;1,0>:f                  {Compacted,I@1}
L7232:
        join (16|M0)                         L8048                                
L7248:
        add (16|M0)              r32.0<1>:d    -r66.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r26.0<1>:d    r32.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L7312                  L7312                
L7288:
        mov (16|M0)              r122.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L7312                  L7416                
L7312:
        join (16|M0)                         L7416                                
L7328:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r122.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r26.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r122.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L7416:
        join (16|M0)                         L8048                                
L7432:
        and (16|M0)   (ne)f1.0   r110.0<1>:d   r32.0<1;1,0>:d    63:w              
        and (16|M0)              r118.0<1>:d   r122.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L7520                  L7520                
L7472:
        mov (16|M0)              r126.0<1>:d   -1:w                              
        mov (16|M0)              r104.0<1>:d   -1:w                              
        goto (16|M0)                         L7520                  L7704                
L7520:
        join (16|M0)                         L7704                                
L7536:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L7640                  L7640                
L7568:
        add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r126.0<1>:d   0:w                              
        shl (16|M0)              r104.0<1>:d   r5.13<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L7640                  L7704                
L7640:
        join (16|M0)                         L7704                                
L7656:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r104.0<1>:d   -1:w                              
        shl (16|M0)              r126.0<1>:d   r2.0<0;1,0>:w     r110.0<1;1,0>:d  {F@1}
L7704:
        join (16|M0)                         L8048                                
L7720:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r126.0<1;0>:ud    r35.6<0;0>:ud     r70.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r104.0<1;0>:ud    r35.6<0;0>:ud     r68.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.13<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.0   r24.0<1>:d    r116.0<1;1,0>:d   63:w              
        mov (16|M0)              r126.0<1>:d   -r12.0<1;1,0>:d                  {I@2}
(f1.0)  goto (16|M0)                         L7888                  L7888                
L7864:
        mov (16|M0)              r122.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L7888                  L7992                
L7888:
        join (16|M0)                         L7992                                
L7904:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r122.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r24.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r122.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L7992:
        join (16|M0)                         L8048                                
L8008:
        mov (16|M0)              r36.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r122.0<1>:d   r114.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L8048                  L8136                
L8048:
        join (16|M0)                         L8136                                
L8064:
        shr (16|M0)              r122.0<1>:ud  r70.0<1;1,0>:ud   2:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r36.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r122.0<1>:ud  r70.0<1;1,0>:ud   1:w               {F@1}
L8136:
        join (16|M0)                         L8664                                
L8152:
        shl (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r118.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r84.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r100.0<1>:d   r36.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L8272                  L8272                
L8240:
        mov (16|M0)              r70.0<1>:d    0:w                              
        goto (16|M0)                         L8272                  L8432                
L8272:
        join (16|M0)                         L8432                                
L8288:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r84.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L8352                  L8352                
L8320:
        mov (16|M0)              r70.0<1>:d    1:w                              
        goto (16|M0)                         L8352                  L8432                
L8352:
        join (16|M0)                         L8432                                
L8368:
        and (16|M0)   (ne)f1.1   null<1>:d     r36.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r70.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L8432:
        join (16|M0)                         L8664                                
L8448:
        add (16|M0)              r30.0<1>:d    r100.0<1;1,0>:d   r70.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r30.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r72.0<1;0>:d      r98.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r28.0<1>:d    r2.0<1;1,0>:d     r112.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r28.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L8600                  L8600                
L8528:
(~f1.1) sel (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r78.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r28.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r108.0<1>:ud  r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L8600                  L9200                
L8600:
        join (16|M0)                         L8664                                
L8616:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r78.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r108.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8664                  L9200                
L8664:
        join (16|M0)                         L8976                                
L8680:
        and (16|M0)   (ne)f1.1   r18.0<1>:d    r98.0<1;1,0>:d    63:w               {F@1}
(f1.1)  goto (16|M0)                         L8744                  L8744                
L8712:
        mov (16|M0)              r64.0<1>:d    -1:w                              
        goto (16|M0)                         L8744                  L8872                
L8744:
        join (16|M0)                         L8872                                
L8760:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L8824                  L8824                
L8792:
        mov (16|M0)              r64.0<1>:d    0:w                              
        goto (16|M0)                         L8824                  L8872                
L8824:
        join (16|M0)                         L8872                                
L8840:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r64.0<1>:d    r2.0<0;1,0>:w     r18.0<1;1,0>:d   {F@1}
L8872:
        join (16|M0)                         L8976                                
L8888:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r64.0<1;0>:ud     r35.6<0;0>:ud     r70.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r98.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r78.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r112.0<1;1,0>:d   23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r108.0<1>:ud  r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L8976                  L9200                
L8976:
        join (16|M0)                         L9040                                
L8992:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r78.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r108.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L9040                  L9200                
L9040:
        join (16|M0)                         L9104                                
L9056:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r108.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L9104                  L9200                
L9104:
        join (16|M0)                         L9168                                
L9120:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r78.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r108.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L9168                  L9200                
L9168:
        join (16|M0)                         L9200                                
L9184:
        bfn.0xF8 (16|M0)         r108.0<1>:ud  r78.0<1;0>:ud     r81.0<0;0>:ud     r35.7<0>:ud      {F@1} // s0&s1|s2
L9200:
        join (16|M0)                         L15736                                
L9216:
        rnde (16|M0)             r82.0<1>:f    r108.0<1;1,0>:f                  {Compacted,I@2}
        shr (16|M0)              r36.0<1>:ud   r82.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r124.0<1>:d   r82.0<1;1,0>:d    8388607:d              
        and (16|M0)              r116.0<1>:d   r36.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r116.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (16|M0)                         L9328                  L9328                
L9296:
        mov (16|M0)              r106.0<1>:ud  0x7FC00000:ud                             
        goto (16|M0)                         L9328                  L15376                
L9328:
        join (16|M0)                         L15376                                
L9344:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r32.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   255:w              
        and (16|M0)              r96.0<1>:d    r32.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r94.0<1>:d    r2.0<1;1,0>:d     r82.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L15344                  L15344                
L9456:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r116.0<1;1,0>:d   r124.0<1;1,0>:d  {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L9544                  L9544                
L9512:
        mov (16|M0)              r106.0<1>:ud  0x0:ud                             
        goto (16|M0)                         L9544                  L15376                
L9544:
        join (16|M0)                         L15344                                
L9560:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r116.0<1;1,0>:d   0:w              
        add (16|M0)              r92.0<1>:d    r116.0<1;1,0>:d   -127:w               {Compacted}
(f1.0)  mov (16|M0)              r92.0<1>:d    -126:w                              
        add (16|M0)              r90.0<1>:d    r96.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r90.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (16|M0)                         L15280                  L15280                
L9640:
        or (16|M0)    (eq)f1.1   null<4>:b     r36.0<1;1,0>:d    r32.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L15216                  L15216                
L9672:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r81.6<1>:d    0:w                              
(f1.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r124.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r88.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r86.0<1>:ud   r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r81.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r81.4<1>:d    0:w                              
L9776:
(W)     shl (1|M0)               r2.0<1>:d     r81.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r81.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r81.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r81.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r88.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r81.2<1>:ud   r81.3<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r81.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r81.6<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r81.2<0;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r81.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    r81.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.13<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r6.0<1>:ud    r81.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r9.0<1>:uw    r5.13<0;1,0>:uw   0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.13<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r81.7<1>:ud   r3.0<0;1,0>:ud    r81.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r110.0<1>:d   r81.4<0;1,0>:d                  
        mov (16|M0)              r108.0<1>:d   r81.5<0;1,0>:d                  
        mov (16|M0)              r84.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r82.0<1>:d    r81.7<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L10176                  L10176                
L10112:
(W)     mov (1|M0)               r81.3<1>:d    r81.2<0;1,0>:d                  
(W)     mov (1|M0)               r81.4<1>:d    r6.0<0;1,0>:d                   
(W)     mov (1|M0)               r81.5<1>:d    r81.7<0;1,0>:d                  
(W)     jmpi                                 L9776                                
L10176:
        join (16|M0)                         L15216                                
L10192:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r106.0<1>:ud  r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r22.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {A@1}
        subb (8|M8)              r107.0<1>:ud  r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r26.0<1>:d    r90.0<1;0>:d      r106.0<1;0>:d     -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r23.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
        add3 (16|M0)             r30.0<1>:d    r96.0<1;0>:d      r92.0<1;0>:d      r106.0<1>:d     
(f1.0)  goto (16|M0)                         L15152                  L15152                
L10344:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r26.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L12832                  L12832                
L10376:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r26.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L12328                  L12328                
L10408:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r74.0<1>:ud   r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r76.0<1>:d    r90.0<1;0>:d      r106.0<1;0>:d     -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {F@1}
        subb (8|M8)              r75.0<1>:ud   r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:ud   r76.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (16|M0)                         L10632                  L10632                
L10576:
        add3 (16|M0)             r2.0<1>:d     r30.0<1;0>:d      -r74.0<1;0>:d     -23:w              
        mov (16|M0)              r12.0<1>:d    0:w                              
        shl (16|M0)              r14.0<1>:d    r88.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L10632                  L12264                
L10632:
        join (16|M0)                         L12264                                
L10648:
        add3 (16|M0)             r72.0<1>:d    r74.0<1;0>:d      -r30.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L10800                  L10800                
L10696:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L10800                  L10848                
L10728:
        shr (16|M0)              r24.0<1>:ud   r88.0<1;1,0>:ud   1:w              
        mov (16|M0)              r102.0<1>:d   0:w                              
        mov (16|M0)              r90.0<1>:d    0:w                              
        mov (16|M0)              r122.0<1>:f   r24.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L10800                  L11736                
L10800:
        join (16|M0)                         L10848                                
L10816:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r72.0<1;1,0>:d    1:w              
(f1.1)  goto (16|M0)                         L10848                  L11680                
L10848:
        join (16|M0)                         L11680                                
L10864:
        add3 (16|M0)             r2.0<1>:d     r74.0<1;0>:d      -r76.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r124.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L10936                  L10936                
L10912:
        mov (16|M0)              r70.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10936                  L11048                
L10936:
        join (16|M0)                         L11048                                
L10952:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r124.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r24.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r124.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r24.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r70.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@1}
L11048:
        join (16|M0)                         L11680                                
L11064:
        add3 (16|M0)             r58.0<1>:d    r74.0<1;0>:d      -r76.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r122.0<1>:d   r58.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L11136                  L11136                
L11112:
        mov (16|M0)              r24.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11136                  L11240                
L11136:
        join (16|M0)                         L11240                                
L11152:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r24.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r24.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L11240:
        join (16|M0)                         L11680                                
L11256:
        and (16|M0)   (ne)f1.0   r78.0<1>:d    r58.0<1;1,0>:d    63:w              
        and (16|M0)              r90.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L11344                  L11344                
L11296:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        mov (16|M0)              r98.0<1>:d    -1:w                              
        goto (16|M0)                         L11344                  L11528                
L11344:
        join (16|M0)                         L11528                                
L11360:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L11464                  L11464                
L11392:
        add (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r92.0<1>:d    0:w                              
        shl (16|M0)              r98.0<1>:d    r5.13<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11464                  L11528                
L11464:
        join (16|M0)                         L11528                                
L11480:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r98.0<1>:d    -1:w                              
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r78.0<1;1,0>:d   {F@1}
L11528:
        join (16|M0)                         L11680                                
L11544:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r92.0<1;0>:ud     r35.6<0;0>:ud     r88.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r98.0<1;0>:ud     r35.6<0;0>:ud     r86.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r122.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.13<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r102.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L11680                  L11736                
L11680:
        join (16|M0)                         L11736                                
L11696:
        mov (16|M0)              r102.0<1>:d   0:w                              
        mov (16|M0)              r90.0<1>:d    0:w                              
        mov (16|M0)              r122.0<1>:f   r88.0<1;1,0>:f                   {Compacted}
L11736:
        join (16|M0)                         L12264                                
L11752:
        and (16|M0)   (ne)f1.0   r120.0<1>:d   r72.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L11808                  L11808                
L11784:
        mov (16|M0)              r24.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11808                  L11912                
L11808:
        join (16|M0)                         L11912                                
L11824:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r120.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r24.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r24.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L11912:
        join (16|M0)                         L12264                                
L11928:
        shl (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r30.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r102.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L12032                  L12032                
L12000:
        mov (16|M0)              r32.0<1>:d    0:w                              
        goto (16|M0)                         L12032                  L12192                
L12032:
        join (16|M0)                         L12192                                
L12048:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r30.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L12112                  L12112                
L12080:
        mov (16|M0)              r32.0<1>:d    1:w                              
        goto (16|M0)                         L12112                  L12192                
L12112:
        join (16|M0)                         L12192                                
L12128:
        and (16|M0)   (ne)f1.1   null<1>:d     r24.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r30.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r32.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L12192:
        join (16|M0)                         L12264                                
L12208:
        add (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.7<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.7<0;1,0>:d     0:w               {Compacted,F@1}
L12264:
        join (16|M0)                         L12328                                
L12280:
        and (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r106.0<1>:ud  r2.0<1;0>:ud      r12.0<1;0>:ud     r14.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L12328                  L15376                
L12328:
        join (16|M0)                         L12832                                
L12344:
        and (16|M0)   (ne)f1.0   r62.0<1>:d    r106.0<1;1,0>:d   63:w               {I@3}
(f1.0)  goto (16|M0)                         L12424                  L12424                
L12376:
        mov (16|M0)              r68.0<1>:d    -1:w                              
        mov (16|M0)              r76.0<1>:d    -1:w                              
        goto (16|M0)                         L12424                  L12608                
L12424:
        join (16|M0)                         L12608                                
L12440:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L12544                  L12544                
L12472:
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r68.0<1>:d    0:w                              
        shl (16|M0)              r76.0<1>:d    r5.13<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12544                  L12608                
L12544:
        join (16|M0)                         L12608                                
L12560:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r76.0<1>:d    -1:w                              
        shl (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     r62.0<1;1,0>:d   {F@1}
L12608:
        join (16|M0)                         L12832                                
L12624:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r35.6<0;0>:ud     r88.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r76.0<1;0>:ud     r35.6<0;0>:ud     r86.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r94.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L12776                  L12776                
L12736:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r106.0<1>:f   r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L12776                  L15376                
L12776:
        join (16|M0)                         L12832                                
L12792:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r106.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L12832                  L15376                
L12832:
        join (16|M0)                         L15152                                
L12848:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r106.0<1;1,0>:ud  0x18:uw              {F@1}
        add3 (16|M0)             r14.0<1>:d    r90.0<1;0>:d      r106.0<1;0>:d     -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L14840                  L14840                
L12912:
        shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L13144                  L13144                
L13016:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L13144                  L13208                
L13064:
        shr (16|M0)              r24.0<1>:ud   r88.0<1;1,0>:ud   1:w              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r68.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r24.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13144                  L14312                
L13144:
        join (16|M0)                         L13208                                
L13160:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L13208                  L14224                
L13208:
        join (16|M0)                         L14224                                
L13224:
        add (16|M0)              r2.0<1>:d     -r84.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r12.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r18.0<1>:d    -r84.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L13296                  L13296                
L13272:
        mov (16|M0)              r16.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13296                  L13408                
L13296:
        join (16|M0)                         L13408                                
L13312:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r24.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r12.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r24.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r16.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@1}
L13408:
        join (16|M0)                         L14224                                
L13424:
        add (16|M0)              r66.0<1>:d    -r84.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r20.0<1>:d    r66.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L13488                  L13488                
L13464:
        mov (16|M0)              r24.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13488                  L13592                
L13488:
        join (16|M0)                         L13592                                
L13504:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r24.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r20.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r20.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r24.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L13592:
        join (16|M0)                         L14224                                
L13608:
        and (16|M0)   (ne)f1.1   r102.0<1>:d   r66.0<1;1,0>:d    63:w              
        and (16|M0)              r20.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L13696                  L13696                
L13648:
        mov (16|M0)              r108.0<1>:d   -1:w                              
        mov (16|M0)              r118.0<1>:d   -1:w                              
        goto (16|M0)                         L13696                  L13880                
L13696:
        join (16|M0)                         L13880                                
L13712:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L13816                  L13816                
L13744:
        add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r108.0<1>:d   0:w                              
        shl (16|M0)              r118.0<1>:d   r5.13<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L13816                  L13880                
L13816:
        join (16|M0)                         L13880                                
L13832:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r118.0<1>:d   -1:w                              
        shl (16|M0)              r108.0<1>:d   r2.0<0;1,0>:w     r102.0<1;1,0>:d  {F@1}
L13880:
        join (16|M0)                         L14224                                
L13896:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r108.0<1;0>:ud    r35.6<0;0>:ud     r88.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r118.0<1;0>:ud    r35.6<0;0>:ud     r86.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.13<1>:hf   -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.13<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.1   r18.0<1>:d    r18.0<1;1,0>:d    63:w              
        mov (16|M0)              r28.0<1>:d    -r12.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L14064                  L14064                
L14040:
        mov (16|M0)              r24.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L14064                  L14168                
L14064:
        join (16|M0)                         L14168                                
L14080:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r24.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r18.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r18.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r24.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L14168:
        join (16|M0)                         L14224                                
L14184:
        mov (16|M0)              r68.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r24.0<1>:d    r16.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L14224                  L14312                
L14224:
        join (16|M0)                         L14312                                
L14240:
        shr (16|M0)              r24.0<1>:ud   r88.0<1;1,0>:ud   2:w              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r68.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r24.0<1>:ud   r88.0<1;1,0>:ud   1:w               {F@1}
L14312:
        join (16|M0)                         L14840                                
L14328:
        shl (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r66.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r28.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r96.0<1>:d    r68.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L14448                  L14448                
L14416:
        mov (16|M0)              r60.0<1>:d    0:w                              
        goto (16|M0)                         L14448                  L14608                
L14448:
        join (16|M0)                         L14608                                
L14464:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r66.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L14528                  L14528                
L14496:
        mov (16|M0)              r60.0<1>:d    1:w                              
        goto (16|M0)                         L14528                  L14608                
L14528:
        join (16|M0)                         L14608                                
L14544:
        and (16|M0)   (ne)f1.0   null<1>:d     r68.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r60.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L14608:
        join (16|M0)                         L14840                                
L14624:
        add (16|M0)              r26.0<1>:d    r96.0<1;1,0>:d    r60.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r26.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r90.0<1;0>:d      r106.0<1;0>:d     -45:w              
(f1.0)  sel (16|M0)              r16.0<1>:d    r2.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L14776                  L14776                
L14704:
(~f1.0) sel (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r94.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r106.0<1>:ud  r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14776                  L15376                
L14776:
        join (16|M0)                         L14840                                
L14792:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r94.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r106.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14840                  L15376                
L14840:
        join (16|M0)                         L15152                                
L14856:
        and (16|M0)   (ne)f1.0   r10.0<1>:d    r106.0<1;1,0>:d   63:w               {F@1}
(f1.0)  goto (16|M0)                         L14920                  L14920                
L14888:
        mov (16|M0)              r52.0<1>:d    -1:w                              
        goto (16|M0)                         L14920                  L15048                
L14920:
        join (16|M0)                         L15048                                
L14936:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L15000                  L15000                
L14968:
        mov (16|M0)              r52.0<1>:d    0:w                              
        goto (16|M0)                         L15000                  L15048                
L15000:
        join (16|M0)                         L15048                                
L15016:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     r10.0<1;1,0>:d   {F@1}
L15048:
        join (16|M0)                         L15152                                
L15064:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r35.6<0;0>:ud     r88.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r106.0<1;1,0>:d  23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r94.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r106.0<1>:ud  r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L15152                  L15376                
L15152:
        join (16|M0)                         L15216                                
L15168:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r94.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r106.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L15216                  L15376                
L15216:
        join (16|M0)                         L15280                                
L15232:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r106.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L15280                  L15376                
L15280:
        join (16|M0)                         L15344                                
L15296:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r94.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r106.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L15344                  L15376                
L15344:
        join (16|M0)                         L15376                                
L15360:
        bfn.0xF8 (16|M0)         r106.0<1>:ud  r94.0<1;0>:ud     r81.0<0;0>:ud     r35.7<0>:ud      {F@1} // s0&s1|s2
L15376:
        join (16|M0)                         L15736                                
L15392:
        shl (16|M0)              r10.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   r35.2<0;1,0>:ud  {AccWrEn,Compacted,I@1}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r56.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r17.0<1>:ud   r11.0<1;1,0>:ud   r35.2<0;1,0>:ud  {AccWrEn}
        shr (16|M0)              r12.0<1>:ud   r46.0<1;1,0>:ud   31:w              
        shl (16|M0)              r14.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M8)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r26.0<1>:ud   r42.0<1;1,0>:ud   r35.4<0;1,0>:ud  {AccWrEn,Compacted}
(f1.0)  sel (16|M0)              r2.0<1>:f     -r106.0<1;1,0>:f  r106.0<1;1,0>:f  {Compacted}
        or (16|M0)               r14.0<1>:d    r14.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r27.0<1>:ud   r43.0<1;1,0>:ud   r35.4<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               r9.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r9.8<1>:hf    r3.0<1;1,0>:f                   
        mov (8|M8)               r32.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r19.1<2>:ud   r18.0<1;0>:ud     r14.0<1;0>:ud     r35.3<0>:ud      {I@4}
        add3 (8|M8)              r21.1<2>:ud   r24.0<1;0>:ud     r15.0<1;0>:ud     r35.3<0>:ud     
        add3 (8|M0)              r28.1<2>:ud   r12.0<1;0>:ud     r40.0<1;0>:ud     r35.5<0>:ud      {I@5}
        mov (16|M0)              r2.0<1>:ud    r9.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r19.0<2>:d    r16.0<1;1,0>:d                  
        add3 (8|M8)              r30.1<2>:ud   r32.0<1;0>:ud     r41.0<1;0>:ud     r35.5<0>:ud      {I@6}
        mov (8|M8)               r21.0<2>:d    r17.0<1;1,0>:d                  
        mov (8|M0)               r28.0<2>:d    r26.0<1;1,0>:d                  
        mov (8|M8)               r30.0<2>:d    r27.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r19     r2:2    0x0            0x080E0B84           {A@3,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
        send.ugm (16|M0)         null     r28     r56:2   0x0            0x080E0584           {A@1,$10} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
L15736:
        join (16|M0)                         L15904                                
L15752:
        addc (8|M0)              r28.0<1>:ud   r38.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn,Compacted,$10.src}
        add (8|M0)               r118.0<1>:ud  acc0.0<1;1,0>:ud  r48.0<1;1,0>:ud 
        addc (8|M8)              r29.0<1>:ud   r39.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r28.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r119.0<1>:ud  acc0.0<1;1,0>:ud  r49.0<1;1,0>:ud 
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r118.0<1;1,0>:ud  r4.7<0;1,0>:ud  
(~f1.1) goto (16|M0)                         L15904                  L15904                
L15872:
(f1.1)  sel (16|M0)              r38.0<1>:d    r28.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r48.0<1>:d    r118.0<1;1,0>:d   r50.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L720                                
L15904:
        join (16|M0)                         L15920                                
L15920:
(W)     mov (8|M0)               r127.0<1>:f   r80.0<1;1,0>:f                   {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L15944:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x5C:ud                             
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
