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
(W)     mov (8|M0)               r66.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r66.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r66.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@1}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r34.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r32.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r35.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r34.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r33.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r32.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L14952                  L14952                
L552:
(W)     mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     r5.2<0;1,0>:uw   {Compacted,$2.dst}
(W)     shl (1|M0)               r6.5<1>:d     r5.1<0;1,0>:d     5:w              
(W)     mach (1|M0)              r2.0<1>:d     r5.0<0;1,0>:d     r5.1<0;1,0>:d    {Compacted}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.2<0;1,0>:d     0:w               {Compacted}
        mov (16|M0)              r40.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r38.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r6.5<0;1,0>:d     0:w               {I@3}
(W)     mov (2|M0)               r7.3<1>:d     r6.2<1;1,0>:d                    {$3.dst}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
(W)     shl (1|M0)               r6.6<1>:d     r2.0<0;1,0>:d     5:w               {Compacted,I@4}
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:d     -1:w                              
L680:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r6.6<0;1,0>:ud    r40.0<1;1,0>:ud  {A@2}
(~f1.0) goto (16|M0)                         L14784                  L14784                
L712:
(~f0.1) goto (16|M0)                         L760                  L760                
L728:
        mov (16|M0)              r48.0<1>:d    -1:w                              
        goto (16|M0)                         L760                  L1144                
L760:
        join (16|M0)                         L1144                                
L776:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$4.src}
(W)     mov (1|M0)               r2.0<1>:f     r6.5<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r8.0<1>:f     r40.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r5.3<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r5.3<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r6.5<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r40.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r5.4<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r5.4<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r5.3<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r6.10<0;1,0>:uw  {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r6.5<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r6.10<0;1,0>:uw 
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r6.5<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r40.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r6.5<0;1,0>:ud   {I@1}
        add3 (16|M0)             r48.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1144:
        join (16|M0)                         L14784                                
L1160:
(W)     mul (8|M0)               acc0.0<1>:d   r48.0<1;1,0>:d    r6.10<0;1,0>:uw  {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r6.5<0;1,0>:d    {Compacted,$4.src}
(W)     mul (8|M8)               acc0.0<1>:d   r49.0<1;1,0>:d    r6.10<0;1,0>:uw 
        mach (8|M8)              r3.0<1>:d     r49.0<1;1,0>:d    r6.5<0;1,0>:d    {Compacted}
        add (16|M0)              r36.0<1>:d    r40.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@1}
        shr (16|M0)              r46.0<1>:ud   r36.0<1;1,0>:ud   5:w               {I@1}
(~f0.0) goto (16|M0)                         L1272                  L1272                
L1240:
        mov (16|M0)              r14.0<1>:d    -1:w                              
        goto (16|M0)                         L1272                  L1640                
L1272:
        join (16|M0)                         L1640                                
L1288:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.2<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r8.0<1>:f     r48.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r5.3<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r5.3<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.2<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r48.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r5.4<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r5.4<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r5.3<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.4<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.2<0;1,0>:ud   {I@1}
        add3 (16|M0)             r14.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1640:
        join (16|M0)                         L14784                                
L1656:
(W)     mul (8|M0)               acc0.0<1>:d   r14.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r14.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r15.0<1;1,0>:d    r5.4<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r15.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r14.0<1;1,0>:ud   r5.2<0;1,0>:uw  
        mach (8|M0)              r10.0<1>:ud   r14.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r8.0<1>:d     r48.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r15.0<1;1,0>:ud   r5.2<0;1,0>:uw  
        mach (8|M8)              r11.0<1>:ud   r15.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r16.0<1>:f    r10.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r46.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r47.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        mul (8|M0)               acc0.0<1>:ud  r18.0<1;1,0>:ud   r5.4<0;1,0>:uw   {I@4}
        mach (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r19.0<1;1,0>:ud   r5.4<0;1,0>:uw   {I@5}
        mach (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r18.0<1>:d    r40.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r5.2<0;1,0>:ud    r20.0<2;1,0>:uw 
        mach (8|M0)              r10.0<1>:d    r5.2<0;1,0>:ud    r20.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r5.2<0;1,0>:ud    r21.0<2;1,0>:uw  {I@7}
        mov (16|M0)              r12.0<1>:f    r22.0<1;1,0>:f                   {Compacted,A@4}
        mach (8|M8)              r11.0<1>:d    r5.2<0;1,0>:ud    r21.0<1;1,0>:d  
        addc (8|M0)              r16.0<1>:ud   r12.0<1;1,0>:ud   r8.0<1;1,0>:ud   {AccWrEn,Compacted,F@1}
        add (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@2}
        add (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@1}
        addc (8|M8)              r17.0<1>:ud   r13.0<1;1,0>:ud   r9.0<1;1,0>:ud   {AccWrEn}
        shr (16|M0)              r22.0<1>:ud   r40.0<1;1,0>:ud   30:w              
        add (8|M8)               r25.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
        addc (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   r7.3<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r20.0<1>:d    r38.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   r7.3<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r20.0<1>:d    r20.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M8)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r26.1<2>:ud   r10.0<1;0>:ud     r20.0<1;0>:ud     r7.4<0>:ud       {I@2}
        add3 (8|M8)              r28.1<2>:ud   r8.0<1;0>:ud      r21.0<1;0>:ud     r7.4<0>:ud       {I@2}
        mov (8|M0)               r26.0<2>:d    r2.0<1;1,0>:d                   
        mov (8|M8)               r28.0<2>:d    r3.0<1;1,0>:d                   
        shl (16|M0)              r42.0<1>:d    r16.0<1;1,0>:d    6:w               {Compacted}
        send.ugm (16|M0)         r50      r26     null:0  0x0            0x08280580           {A@2,$7} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    6:w               {Compacted}
        shr (16|M0)              r16.0<1>:ud   r16.0<1;1,0>:ud   26:w              
        or (16|M0)               r44.0<1>:d    r24.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
        and (16|M0)              r12.0<1>:d    r50.0<1;1,0>:d    2147483647:d               {$7.dst}
        sel (16|M0)   (lt)f0.0   r110.0<1>:f   r12.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r116.0<1>:ud  r110.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.1   r20.0<1>:d    r110.0<1;1,0>:d   8388607:d              
        and (16|M0)              r16.0<1>:d    r116.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r14.0<1>:ud   r16.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r62.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.1) goto (16|M0)                         L2408                  L2408                
L2376:
        mov (16|M0)              r8.0<1>:ud    0x7FC00000:ud                             
        goto (16|M0)                         L2408                  L8376                
L2408:
        join (16|M0)                         L8376                                
L2424:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
        add (16|M0)              r104.0<1>:d   -r62.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    255:w              
        xor (16|M0)              r60.0<1>:d    r104.0<1;1,0>:d   r110.0<1;1,0>:d  {Compacted,I@2}
(f1.0)  goto (16|M0)                         L8344                  L8344                
L2496:
        or (16|M0)    (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    r20.0<1;1,0>:d  
(~f1.1) goto (16|M0)                         L2560                  L2560                
L2528:
        mov (16|M0)              r8.0<1>:ud    0x0:ud                             
        goto (16|M0)                         L2560                  L8376                
L2560:
        join (16|M0)                         L8344                                
L2576:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    0:w              
        shr (16|M0)              r84.0<1>:ud   r104.0<1;1,0>:ud  23:w              
        add (16|M0)              r82.0<1>:d    r16.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r82.0<1>:d    -126:w                              
        add (16|M0)              r58.0<1>:d    r84.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r58.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L8280                  L8280                
L2672:
        or (16|M0)    (eq)f1.0   null<4>:b     r116.0<1;1,0>:d   r84.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L8216                  L8216                
L2704:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r7.6<1>:d     0:w                              
(f1.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r20.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r56.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r54.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r7.5<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r14.0<1>:d    0:w                              
L2808:
(W)     shl (1|M0)               r2.0<1>:d     r7.5<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r7.6<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r7.6<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r56.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.7<1>:ud    r7.5<0;1,0>:ud    1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r14.1<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r7.6<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r6.7<0;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r14.1<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r6.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r5.6<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r14.0<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r12.0<1>:uw   r5.6<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.6<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r7.7<1>:ud    r3.0<0;1,0>:ud    r14.1<0;1,0>:ud  {I@2}
        mov (16|M0)              r114.0<1>:f   r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r112.0<1>:d   r14.1<0;1,0>:d                  
        mov (16|M0)              r52.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r80.0<1>:d    r7.7<0;1,0>:d                    {I@2}
(f1.0)  goto (16|M0)                         L3184                  L3184                
L3128:
(W)     mov (1|M0)               r7.5<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r14.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r14.1<1>:d    r7.7<0;1,0>:d                   
(W)     jmpi                                 L2808                                
L3184:
        join (16|M0)                         L8216                                
L3200:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r64.0<1>:ud   r2.0<0;1,0>:ud    r114.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r16.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r112.0<1>:ud    {A@1}
        subb (8|M8)              r65.0<1>:ud   r2.0<0;1,0>:ud    r115.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r14.0<1>:d    r84.0<1;0>:d      r82.0<1;0>:d      r64.0<1>:d       {I@1}
        add3 (16|M0)             r82.0<1>:d    r58.0<1;0>:d      r64.0<1;0>:d      -173:w              
        cmp (16|M0)   (gt)f1.1   null<1>:d     r82.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r17.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r113.0<1>:ud   
(f1.1)  goto (16|M0)                         L8152                  L8152                
L3352:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r82.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L5832                  L5832                
L3384:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r82.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L5328                  L5328                
L3416:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@6}
        subb (8|M0)              r20.0<1>:ud   r2.0<0;1,0>:ud    r114.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r64.0<1>:d    r58.0<1;0>:d      r64.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r112.0<1>:ud    {F@1}
        subb (8|M8)              r21.0<1>:ud   r2.0<0;1,0>:ud    r115.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r20.0<1;1,0>:ud   r64.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r113.0<1>:ud   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.1)  goto (16|M0)                         L3640                  L3640                
L3584:
        add3 (16|M0)             r2.0<1>:d     r14.0<1;0>:d      -r20.0<1;0>:d     -23:w              
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r102.0<1>:d   r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L3640                  L5264                
L3640:
        join (16|M0)                         L5264                                
L3656:
        add3 (16|M0)             r110.0<1>:d   r20.0<1;0>:d      -r14.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r110.0<1;1,0>:d   2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L3800                  L3800                
L3696:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r110.0<1;1,0>:d   2:w              
(~f1.1) goto (16|M0)                         L3800                  L3848                
L3728:
        shr (16|M0)              r92.0<1>:ud   r56.0<1;1,0>:ud   1:w              
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M0)              r86.0<1>:d    0:w                              
        mov (16|M0)              r48.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L3800                  L4736                
L3800:
        join (16|M0)                         L3848                                
L3816:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   1:w              
(f1.0)  goto (16|M0)                         L3848                  L4680                
L3848:
        join (16|M0)                         L4680                                
L3864:
        add3 (16|M0)             r2.0<1>:d     r20.0<1;0>:d      -r64.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r52.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L3936                  L3936                
L3912:
        mov (16|M0)              r120.0<1>:f   r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3936                  L4048                
L3936:
        join (16|M0)                         L4048                                
L3952:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r52.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r92.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r52.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r52.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r120.0<1>:f   r92.0<1;1,0>:f                   {Compacted,I@1}
L4048:
        join (16|M0)                         L4680                                
L4064:
        add3 (16|M0)             r122.0<1>:d   r20.0<1;0>:d      -r64.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r48.0<1>:d    r122.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L4136                  L4136                
L4112:
        mov (16|M0)              r92.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4136                  L4240                
L4136:
        join (16|M0)                         L4240                                
L4152:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r48.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r92.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r48.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r48.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4240:
        join (16|M0)                         L4680                                
L4256:
        and (16|M0)   (ne)f1.1   r126.0<1>:d   r122.0<1;1,0>:d   63:w              
        and (16|M0)              r86.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L4344                  L4344                
L4296:
        mov (16|M0)              r10.0<1>:d    -1:w                              
        mov (16|M0)              r14.0<1>:d    -1:w                              
        goto (16|M0)                         L4344                  L4528                
L4344:
        join (16|M0)                         L4528                                
L4360:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L4464                  L4464                
L4392:
        add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r10.0<1>:d    0:w                              
        shl (16|M0)              r14.0<1>:d    r5.6<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4464                  L4528                
L4464:
        join (16|M0)                         L4528                                
L4480:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r14.0<1>:d    -1:w                              
        shl (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     r126.0<1;1,0>:d  {F@1}
L4528:
        join (16|M0)                         L4680                                
L4544:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r10.0<1;0>:ud     r6.2<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r14.0<1;0>:ud     r6.2<0;0>:ud      r54.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r48.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:d    r5.6<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r58.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L4680                  L4736                
L4680:
        join (16|M0)                         L4736                                
L4696:
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M0)              r86.0<1>:d    0:w                              
        mov (16|M0)              r48.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
L4736:
        join (16|M0)                         L5264                                
L4752:
        and (16|M0)   (ne)f1.1   r46.0<1>:d    r110.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L4808                  L4808                
L4784:
        mov (16|M0)              r92.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4808                  L4912                
L4808:
        join (16|M0)                         L4912                                
L4824:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r46.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r92.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r46.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r46.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4912:
        join (16|M0)                         L5264                                
L4928:
        shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r86.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r90.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r58.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L5032                  L5032                
L5000:
        mov (16|M0)              r94.0<1>:d    0:w                              
        goto (16|M0)                         L5032                  L5192                
L5032:
        join (16|M0)                         L5192                                
L5048:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r90.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L5112                  L5112                
L5080:
        mov (16|M0)              r94.0<1>:d    1:w                              
        goto (16|M0)                         L5112                  L5192                
L5112:
        join (16|M0)                         L5192                                
L5128:
        and (16|M0)   (ne)f1.0   null<1>:d     r92.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r94.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L5192:
        join (16|M0)                         L5264                                
L5208:
        add (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.3<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r102.0<1>:d   r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r100.0<1>:d   r5.3<0;1,0>:d     0:w               {Compacted,F@1}
L5264:
        join (16|M0)                         L5328                                
L5280:
        and (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r8.0<1>:ud    r2.0<1;0>:ud      r100.0<1;0>:ud    r102.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L5328                  L8376                
L5328:
        join (16|M0)                         L5832                                
L5344:
        and (16|M0)   (ne)f1.1   r108.0<1>:d   r64.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L5424                  L5424                
L5376:
        mov (16|M0)              r120.0<1>:d   -1:w                              
        mov (16|M0)              r124.0<1>:d   -1:w                              
        goto (16|M0)                         L5424                  L5608                
L5424:
        join (16|M0)                         L5608                                
L5440:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L5544                  L5544                
L5472:
        add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r120.0<1>:d   0:w                              
        shl (16|M0)              r124.0<1>:d   r5.6<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5544                  L5608                
L5544:
        join (16|M0)                         L5608                                
L5560:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r124.0<1>:d   -1:w                              
        shl (16|M0)              r120.0<1>:d   r2.0<0;1,0>:w     r108.0<1;1,0>:d  {F@1}
L5608:
        join (16|M0)                         L5832                                
L5624:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r120.0<1;0>:ud    r6.2<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r124.0<1;0>:ud    r6.2<0;0>:ud      r54.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L5776                  L5776                
L5736:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5776                  L8376                
L5776:
        join (16|M0)                         L5832                                
L5792:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5832                  L8376                
L5832:
        join (16|M0)                         L8152                                
L5848:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r64.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r86.0<1>:d    r58.0<1;0>:d      r64.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L7840                  L7840                
L5912:
        shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L6144                  L6144                
L6016:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L6144                  L6208                
L6064:
        shr (16|M0)              r92.0<1>:ud   r56.0<1;1,0>:ud   1:w              
        mov (16|M0)              r82.0<1>:d    0:w                              
        mov (16|M0)              r108.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r92.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6144                  L7312                
L6144:
        join (16|M0)                         L6208                                
L6160:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L6208                  L7224                
L6208:
        join (16|M0)                         L7224                                
L6224:
        add (16|M0)              r2.0<1>:d     -r52.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r68.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r104.0<1>:d   -r52.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L6296                  L6296                
L6272:
        mov (16|M0)              r98.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6296                  L6408                
L6296:
        join (16|M0)                         L6408                                
L6312:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r68.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r92.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r68.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r68.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r98.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@1}
L6408:
        join (16|M0)                         L7224                                
L6424:
        add (16|M0)              r126.0<1>:d   -r52.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r72.0<1>:d    r126.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (16|M0)                         L6488                  L6488                
L6464:
        mov (16|M0)              r92.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6488                  L6592                
L6488:
        join (16|M0)                         L6592                                
L6504:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r92.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r72.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r72.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6592:
        join (16|M0)                         L7224                                
L6608:
        and (16|M0)   (ne)f1.0   r18.0<1>:d    r126.0<1;1,0>:d   63:w              
        and (16|M0)              r108.0<1>:d   r92.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L6696                  L6696                
L6648:
        mov (16|M0)              r28.0<1>:d    -1:w                              
        mov (16|M0)              r46.0<1>:d    -1:w                              
        goto (16|M0)                         L6696                  L6880                
L6696:
        join (16|M0)                         L6880                                
L6712:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L6816                  L6816                
L6744:
        add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r46.0<1>:d    r5.6<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6816                  L6880                
L6816:
        join (16|M0)                         L6880                                
L6832:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r46.0<1>:d    -1:w                              
        shl (16|M0)              r28.0<1>:d    r2.0<0;1,0>:w     r18.0<1;1,0>:d   {F@1}
L6880:
        join (16|M0)                         L7224                                
L6896:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r28.0<1;0>:ud     r6.2<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r46.0<1;0>:ud     r6.2<0;0>:ud      r54.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r10.0<1>:d    r5.6<0;1,0>:w     0:w               {F@1}
        and (16|M0)   (ne)f1.0   r70.0<1>:d    r104.0<1;1,0>:d   63:w              
        mov (16|M0)              r82.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f1.0)  goto (16|M0)                         L7064                  L7064                
L7040:
        mov (16|M0)              r92.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L7064                  L7168                
L7064:
        join (16|M0)                         L7168                                
L7080:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r92.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r70.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r70.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L7168:
        join (16|M0)                         L7224                                
L7184:
        mov (16|M0)              r78.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r92.0<1>:d    r98.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L7224                  L7312                
L7224:
        join (16|M0)                         L7312                                
L7240:
        shr (16|M0)              r92.0<1>:ud   r56.0<1;1,0>:ud   2:w              
        mov (16|M0)              r82.0<1>:d    0:w                              
        mov (16|M0)              r108.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r92.0<1>:ud   r56.0<1;1,0>:ud   1:w               {F@1}
L7312:
        join (16|M0)                         L7840                                
L7328:
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r108.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r118.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r82.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r24.0<1>:d    r78.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L7448                  L7448                
L7416:
        mov (16|M0)              r106.0<1>:d   0:w                              
        goto (16|M0)                         L7448                  L7608                
L7448:
        join (16|M0)                         L7608                                
L7464:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r118.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L7528                  L7528                
L7496:
        mov (16|M0)              r106.0<1>:d   1:w                              
        goto (16|M0)                         L7528                  L7608                
L7528:
        join (16|M0)                         L7608                                
L7544:
        and (16|M0)   (ne)f1.1   null<1>:d     r78.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   4:w              
(f1.1)  sel (16|M0)              r106.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L7608:
        join (16|M0)                         L7840                                
L7624:
        add (16|M0)              r110.0<1>:d   r24.0<1;1,0>:d    r106.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r110.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r58.0<1;0>:d      r64.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r108.0<1>:d   r2.0<1;1,0>:d     r86.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (16|M0)                         L7776                  L7776                
L7704:
(~f1.1) sel (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   0:w              
        and (16|M0)              r8.0<1>:d     r60.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r108.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (16|M0)         r8.0<1>:ud    r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7776                  L8376                
L7776:
        join (16|M0)                         L7840                                
L7792:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7840                  L8376                
L7840:
        join (16|M0)                         L8152                                
L7856:
        and (16|M0)   (ne)f1.1   r98.0<1>:d    r64.0<1;1,0>:d    63:w               {F@1}
(f1.1)  goto (16|M0)                         L7920                  L7920                
L7888:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        goto (16|M0)                         L7920                  L8048                
L7920:
        join (16|M0)                         L8048                                
L7936:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L8000                  L8000                
L7968:
        mov (16|M0)              r100.0<1>:d   0:w                              
        goto (16|M0)                         L8000                  L8048                
L8000:
        join (16|M0)                         L8048                                
L8016:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r98.0<1;1,0>:d   {F@1}
L8048:
        join (16|M0)                         L8152                                
L8064:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r6.2<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r64.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r60.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r86.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r8.0<1>:ud    r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L8152                  L8376                
L8152:
        join (16|M0)                         L8216                                
L8168:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r60.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8216                  L8376                
L8216:
        join (16|M0)                         L8280                                
L8232:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r60.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L8280                  L8376                
L8280:
        join (16|M0)                         L8344                                
L8296:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r60.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8344                  L8376                
L8344:
        join (16|M0)                         L8376                                
L8360:
        bfn.0xF8 (16|M0)         r8.0<1>:ud    r60.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L8376:
        join (16|M0)                         L14784                                
L8392:
        rnde (16|M0)             r116.0<1>:f   r8.0<1;1,0>:f                    {Compacted,I@2}
        shr (16|M0)              r114.0<1>:ud  r116.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.0   r26.0<1>:d    r116.0<1;1,0>:d   8388607:d              
        and (16|M0)              r22.0<1>:d    r114.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L8504                  L8504                
L8472:
        mov (16|M0)              r126.0<1>:ud  0x7FC00000:ud                             
        goto (16|M0)                         L8504                  L14528                
L8504:
        join (16|M0)                         L14528                                
L8520:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r112.0<1>:ud  r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    255:w              
        and (16|M0)              r94.0<1>:d    r112.0<1;1,0>:d   255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r74.0<1>:d    r2.0<1;1,0>:d     r116.0<1;1,0>:d  {Compacted}
(f1.1)  goto (16|M0)                         L14496                  L14496                
L8632:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r22.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L8720                  L8720                
L8688:
        mov (16|M0)              r126.0<1>:ud  0x0:ud                             
        goto (16|M0)                         L8720                  L14528                
L8720:
        join (16|M0)                         L14496                                
L8736:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w              
        add (16|M0)              r102.0<1>:d   r22.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r102.0<1>:d   -126:w                              
        add (16|M0)              r72.0<1>:d    r94.0<1;1,0>:d    r102.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r72.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (16|M0)                         L14432                  L14432                
L8816:
        or (16|M0)    (eq)f1.1   null<4>:b     r114.0<1;1,0>:d   r112.0<1;1,0>:d 
(f1.1)  goto (16|M0)                         L14368                  L14368                
L8848:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r7.6<1>:d     0:w                              
(f1.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r26.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r70.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r68.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r7.5<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r14.0<1>:d    0:w                              
L8952:
(W)     shl (1|M0)               r2.0<1>:d     r7.5<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r7.6<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r14.0<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r7.6<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r70.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.7<1>:ud    r7.5<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r14.1<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r7.6<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r6.7<0;1,0>:d     r68.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r14.1<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r6.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r5.6<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r14.0<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r12.0<1>:uw   r5.6<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r5.6<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r7.7<1>:ud    r3.0<0;1,0>:ud    r14.1<0;1,0>:ud  {I@2}
        mov (16|M0)              r124.0<1>:f   r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r122.0<1>:d   r14.1<0;1,0>:d                  
        mov (16|M0)              r76.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r90.0<1>:d    r7.7<0;1,0>:d                    {I@2}
(f1.1)  goto (16|M0)                         L9328                  L9328                
L9272:
(W)     mov (1|M0)               r7.5<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r14.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r14.1<1>:d    r7.7<0;1,0>:d                   
(W)     jmpi                                 L8952                                
L9328:
        join (16|M0)                         L14368                                
L9344:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r78.0<1>:ud   r2.0<0;1,0>:ud    r124.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r122.0<1>:ud    {A@1}
        subb (8|M8)              r79.0<1>:ud   r2.0<0;1,0>:ud    r125.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r80.0<1>:d    r72.0<1;0>:d      r78.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r80.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r123.0<1>:ud   
        add3 (16|M0)             r10.0<1>:d    r94.0<1;0>:d      r102.0<1;0>:d     r78.0<1>:d      
(f1.0)  goto (16|M0)                         L14304                  L14304                
L9496:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r80.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L11984                  L11984                
L9528:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r80.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L11480                  L11480                
L9560:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r18.0<1>:ud   r2.0<0;1,0>:ud    r124.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r52.0<1>:d    r72.0<1;0>:d      r78.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r122.0<1>:ud    {F@1}
        subb (8|M8)              r19.0<1>:ud   r2.0<0;1,0>:ud    r125.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:ud   r52.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r123.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L9784                  L9784                
L9728:
        add3 (16|M0)             r2.0<1>:d     r10.0<1;0>:d      -r18.0<1;0>:d     -23:w              
        mov (16|M0)              r92.0<1>:d    0:w                              
        shl (16|M0)              r94.0<1>:d    r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9784                  L11416                
L9784:
        join (16|M0)                         L11416                                
L9800:
        add3 (16|M0)             r118.0<1>:d   r18.0<1;0>:d      -r10.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r118.0<1;1,0>:d   2:w               {I@1}
(f1.1)  goto (16|M0)                         L9952                  L9952                
L9848:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   2:w              
(~f1.0) goto (16|M0)                         L9952                  L10000                
L9880:
        shr (16|M0)              r106.0<1>:ud  r70.0<1;1,0>:ud   1:w              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:f    r106.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L9952                  L10888                
L9952:
        join (16|M0)                         L10000                                
L9968:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   1:w              
(f1.1)  goto (16|M0)                         L10000                  L10832                
L10000:
        join (16|M0)                         L10832                                
L10016:
        add3 (16|M0)             r2.0<1>:d     r18.0<1;0>:d      -r52.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r30.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L10088                  L10088                
L10064:
        mov (16|M0)              r20.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10088                  L10200                
L10088:
        join (16|M0)                         L10200                                
L10104:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r30.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r106.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r30.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   r30.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r106.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r20.0<1>:f    r106.0<1;1,0>:f                  {Compacted,I@1}
L10200:
        join (16|M0)                         L10832                                
L10216:
        add3 (16|M0)             r120.0<1>:d   r18.0<1;0>:d      -r52.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r28.0<1>:d    r120.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (16|M0)                         L10288                  L10288                
L10264:
        mov (16|M0)              r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10288                  L10392                
L10288:
        join (16|M0)                         L10392                                
L10304:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r28.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r106.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r28.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   r28.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r106.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10392:
        join (16|M0)                         L10832                                
L10408:
        and (16|M0)   (ne)f1.0   r114.0<1>:d   r120.0<1;1,0>:d   63:w              
        and (16|M0)              r84.0<1>:d    r106.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L10496                  L10496                
L10448:
        mov (16|M0)              r122.0<1>:d   -1:w                              
        mov (16|M0)              r8.0<1>:d     -1:w                              
        goto (16|M0)                         L10496                  L10680                
L10496:
        join (16|M0)                         L10680                                
L10512:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L10616                  L10616                
L10544:
        add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r122.0<1>:d   0:w                              
        shl (16|M0)              r8.0<1>:d     r5.6<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10616                  L10680                
L10616:
        join (16|M0)                         L10680                                
L10632:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r8.0<1>:d     -1:w                              
        shl (16|M0)              r122.0<1>:d   r2.0<0;1,0>:w     r114.0<1;1,0>:d  {F@1}
L10680:
        join (16|M0)                         L10832                                
L10696:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r122.0<1;0>:ud    r6.2<0;0>:ud      r70.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r8.0<1;0>:ud      r6.2<0;0>:ud      r68.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r24.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r5.6<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r30.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L10832                  L10888                
L10832:
        join (16|M0)                         L10888                                
L10848:
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
L10888:
        join (16|M0)                         L11416                                
L10904:
        and (16|M0)   (ne)f1.0   r26.0<1>:d    r118.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L10960                  L10960                
L10936:
        mov (16|M0)              r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10960                  L11064                
L10960:
        join (16|M0)                         L11064                                
L10976:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r106.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r26.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r106.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11064:
        join (16|M0)                         L11416                                
L11080:
        shl (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r84.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r86.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r30.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L11184                  L11184                
L11152:
        mov (16|M0)              r88.0<1>:d    0:w                              
        goto (16|M0)                         L11184                  L11344                
L11184:
        join (16|M0)                         L11344                                
L11200:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r86.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L11264                  L11264                
L11232:
        mov (16|M0)              r88.0<1>:d    1:w                              
        goto (16|M0)                         L11264                  L11344                
L11264:
        join (16|M0)                         L11344                                
L11280:
        and (16|M0)   (ne)f1.1   null<1>:d     r106.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r88.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L11344:
        join (16|M0)                         L11416                                
L11360:
        add (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    r106.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.3<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r94.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r92.0<1>:d    r5.3<0;1,0>:d     0:w               {Compacted,F@1}
L11416:
        join (16|M0)                         L11480                                
L11432:
        and (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r126.0<1>:ud  r2.0<1;0>:ud      r92.0<1;0>:ud     r94.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L11480                  L14528                
L11480:
        join (16|M0)                         L11984                                
L11496:
        and (16|M0)   (ne)f1.0   r98.0<1>:d    r78.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L11576                  L11576                
L11528:
        mov (16|M0)              r104.0<1>:d   -1:w                              
        mov (16|M0)              r112.0<1>:d   -1:w                              
        goto (16|M0)                         L11576                  L11760                
L11576:
        join (16|M0)                         L11760                                
L11592:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L11696                  L11696                
L11624:
        add (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r104.0<1>:d   0:w                              
        shl (16|M0)              r112.0<1>:d   r5.6<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11696                  L11760                
L11696:
        join (16|M0)                         L11760                                
L11712:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r112.0<1>:d   -1:w                              
        shl (16|M0)              r104.0<1>:d   r2.0<0;1,0>:w     r98.0<1;1,0>:d   {F@1}
L11760:
        join (16|M0)                         L11984                                
L11776:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r104.0<1;0>:ud    r6.2<0;0>:ud      r70.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r112.0<1;0>:ud    r6.2<0;0>:ud      r68.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L11928                  L11928                
L11888:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r126.0<1>:f   r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11928                  L14528                
L11928:
        join (16|M0)                         L11984                                
L11944:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r126.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11984                  L14528                
L11984:
        join (16|M0)                         L14304                                
L12000:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r78.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r88.0<1>:d    r72.0<1;0>:d      r78.0<1;0>:d      -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L13992                  L13992                
L12064:
        shl (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r76.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L12296                  L12296                
L12168:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r76.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L12296                  L12360                
L12216:
        shr (16|M0)              r106.0<1>:ud  r70.0<1;1,0>:ud   1:w              
        mov (16|M0)              r80.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r76.0<1>:f    r106.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12296                  L13464                
L12296:
        join (16|M0)                         L12360                                
L12312:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    38:w               {F@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L12360                  L13376                
L12360:
        join (16|M0)                         L13376                                
L12376:
        add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r54.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r100.0<1>:d   -r76.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L12448                  L12448                
L12424:
        mov (16|M0)              r96.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12448                  L12560                
L12448:
        join (16|M0)                         L12560                                
L12464:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r54.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r106.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r54.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   r54.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r106.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r96.0<1>:f    r106.0<1;1,0>:f                  {Compacted,I@1}
L12560:
        join (16|M0)                         L13376                                
L12576:
        add (16|M0)              r124.0<1>:d   -r76.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r58.0<1>:d    r124.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L12640                  L12640                
L12616:
        mov (16|M0)              r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12640                  L12744                
L12640:
        join (16|M0)                         L12744                                
L12656:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r58.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r106.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r58.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   r58.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r106.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12744:
        join (16|M0)                         L13376                                
L12760:
        and (16|M0)   (ne)f1.1   r12.0<1>:d    r124.0<1;1,0>:d   63:w              
        and (16|M0)              r116.0<1>:d   r106.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L12848                  L12848                
L12800:
        mov (16|M0)              r16.0<1>:d    -1:w                              
        mov (16|M0)              r22.0<1>:d    -1:w                              
        goto (16|M0)                         L12848                  L13032                
L12848:
        join (16|M0)                         L13032                                
L12864:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L12968                  L12968                
L12896:
        add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r16.0<1>:d    0:w                              
        shl (16|M0)              r22.0<1>:d    r5.6<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12968                  L13032                
L12968:
        join (16|M0)                         L13032                                
L12984:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r22.0<1>:d    -1:w                              
        shl (16|M0)              r16.0<1>:d    r2.0<0;1,0>:w     r12.0<1;1,0>:d   {F@1}
L13032:
        join (16|M0)                         L13376                                
L13048:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r16.0<1;0>:ud     r6.2<0;0>:ud      r70.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r22.0<1;0>:ud     r6.2<0;0>:ud      r68.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r10.0<1>:d    r5.6<0;1,0>:w     0:w               {F@1}
        and (16|M0)   (ne)f1.1   r56.0<1>:d    r100.0<1;1,0>:d   63:w              
        mov (16|M0)              r80.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L13216                  L13216                
L13192:
        mov (16|M0)              r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13216                  L13320                
L13216:
        join (16|M0)                         L13320                                
L13232:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r106.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r56.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   r56.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r106.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L13320:
        join (16|M0)                         L13376                                
L13336:
        mov (16|M0)              r76.0<1>:f    r106.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r106.0<1>:d   r96.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L13376                  L13464                
L13376:
        join (16|M0)                         L13464                                
L13392:
        shr (16|M0)              r106.0<1>:ud  r70.0<1;1,0>:ud   2:w              
        mov (16|M0)              r80.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r76.0<1>:f    r106.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r106.0<1>:ud  r70.0<1;1,0>:ud   1:w               {F@1}
L13464:
        join (16|M0)                         L13992                                
L13480:
        shl (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r116.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r102.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r80.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r22.0<1>:d    r76.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L13600                  L13600                
L13568:
        mov (16|M0)              r96.0<1>:d    0:w                              
        goto (16|M0)                         L13600                  L13760                
L13600:
        join (16|M0)                         L13760                                
L13616:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r102.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L13680                  L13680                
L13648:
        mov (16|M0)              r96.0<1>:d    1:w                              
        goto (16|M0)                         L13680                  L13760                
L13680:
        join (16|M0)                         L13760                                
L13696:
        and (16|M0)   (ne)f1.0   null<1>:d     r76.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r96.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L13760:
        join (16|M0)                         L13992                                
L13776:
        add (16|M0)              r106.0<1>:d   r22.0<1;1,0>:d    r96.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r106.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r72.0<1;0>:d      r78.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r96.0<1>:d    r2.0<1;1,0>:d     r88.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L13928                  L13928                
L13856:
(~f1.0) sel (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   0:w              
        and (16|M0)              r8.0<1>:d     r74.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r96.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r126.0<1>:ud  r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13928                  L14528                
L13928:
        join (16|M0)                         L13992                                
L13944:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r126.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13992                  L14528                
L13992:
        join (16|M0)                         L14304                                
L14008:
        and (16|M0)   (ne)f1.0   r90.0<1>:d    r78.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L14072                  L14072                
L14040:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        goto (16|M0)                         L14072                  L14200                
L14072:
        join (16|M0)                         L14200                                
L14088:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.1)  goto (16|M0)                         L14152                  L14152                
L14120:
        mov (16|M0)              r92.0<1>:d    0:w                              
        goto (16|M0)                         L14152                  L14200                
L14152:
        join (16|M0)                         L14200                                
L14168:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r90.0<1;1,0>:d   {F@1}
L14200:
        join (16|M0)                         L14304                                
L14216:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r92.0<1;0>:ud     r6.2<0;0>:ud      r70.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r78.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r74.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r88.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r126.0<1>:ud  r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14304                  L14528                
L14304:
        join (16|M0)                         L14368                                
L14320:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r126.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14368                  L14528                
L14368:
        join (16|M0)                         L14432                                
L14384:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r74.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r126.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L14432                  L14528                
L14432:
        join (16|M0)                         L14496                                
L14448:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r126.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14496                  L14528                
L14496:
        join (16|M0)                         L14528                                
L14512:
        bfn.0xF8 (16|M0)         r126.0<1>:ud  r74.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L14528:
        join (16|M0)                         L14784                                
L14544:
        addc (8|M0)              r10.0<1>:ud   r42.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r14.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r50.0<1;1,0>:f    0.0:f               {Compacted,I@7}
        add3 (8|M0)              r12.0<1>:ud   acc0.0<1;0>:ud    r44.0<1;0>:ud     r6.1<0>:ud      
        and (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    62:w               {Compacted,I@2}
        addc (8|M8)              r11.0<1>:ud   r43.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
(f1.0)  sel (16|M0)              r2.0<1>:f     -r126.0<1;1,0>:f  r126.0<1;1,0>:f  {Compacted}
        add3 (8|M8)              r13.0<1>:ud   acc0.0<1;0>:ud    r45.0<1;0>:ud     r6.1<0>:ud      
        addc (8|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   r14.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r8.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r17.0<1>:ud   r11.0<1;1,0>:ud   r15.0<1;1,0>:ud  {AccWrEn,I@4}
        mov (8|M8)               r8.8<1>:hf    r3.0<1;1,0>:f                   
        mov (8|M8)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r19.1<2>:ud   r18.0<1;1,0>:ud   r12.0<1;1,0>:ud  {Compacted,I@3}
        mov (16|M0)              r2.0<1>:ud    r8.0<1;1,0>:uw                   {A@1}
        add (8|M8)               r21.1<2>:ud   r24.0<1;1,0>:ud   r13.0<1;1,0>:ud  {Compacted,I@3}
        mov (8|M0)               r19.0<2>:d    r16.0<1;1,0>:d                  
        mov (8|M8)               r21.0<2>:d    r17.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r19     r2:2    0x0            0x080E0B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
L14784:
        join (16|M0)                         L14952                                
L14800:
        addc (8|M0)              r84.0<1>:ud   r40.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        add (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud  r38.0<1;1,0>:ud 
        addc (8|M8)              r85.0<1>:ud   r41.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r84.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r25.0<1>:ud   acc0.0<1;1,0>:ud  r39.0<1;1,0>:ud 
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f1.0) goto (16|M0)                         L14952                  L14952                
L14920:
(f1.0)  sel (16|M0)              r40.0<1>:d    r84.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M0)              r38.0<1>:d    r24.0<1;1,0>:d    r32.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L680                                
L14952:
        join (16|M0)                         L14968                                
L14968:
(W)     mov (8|M0)               r127.0<1>:f   r66.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L14992:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x78:ud                             
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
