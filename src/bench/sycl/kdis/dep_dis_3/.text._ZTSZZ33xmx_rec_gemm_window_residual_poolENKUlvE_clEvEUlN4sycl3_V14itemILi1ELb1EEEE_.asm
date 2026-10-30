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
(W)     mov (8|M0)               r46.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r6.0<0;1,0>:d     0:w               {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r46.2<0;1,0>:uw  {I@3}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r46.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r36.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@1}
(~f1.0) goto (16|M0)                         L416                  L416                
L384:
        mov (16|M0)              r34.0<1>:d    -1:w                              
        goto (16|M0)                         L416                  L776                
L416:
        join (16|M0)                         L776                                
L432:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,$1.dst}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$3}
        mov (16|M0)              r10.0<1>:f    r36.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f    r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r6.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r14.0<1>:d    r36.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r4.7<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r20.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r20.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      -r4.7<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r28.0<1>:f    r4.6<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r30.0<1>:ud   r28.0<1;1,0>:f                   {A@1}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r6.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r32.0<1>:d    r32.0<1;1,0>:d    r6.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r33.0<1;1,0>:d    r6.0<0;1,0>:uw  
        mach (8|M8)              r33.0<1>:d    r33.0<1;1,0>:d    r6.0<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r36.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r10.0<1>:ud   r32.0<1;1,0>:ud   r6.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r34.0<1>:d    r30.0<1;0>:d      r16.0<1;0>:d      -r10.0<1>:d      {I@1}
L776:
        join (16|M0)                         L792                                
L792:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r6.1<0;1,0>:d     0:w              
        shr (16|M0)              r38.0<1>:ud   r34.0<1;1,0>:ud   6:w               {I@3}
(~f0.1) goto (16|M0)                         L872                  L872                
L840:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        goto (16|M0)                         L872                  L1240                
L872:
        join (16|M0)                         L1240                                
L888:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r6.1<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,$1.dst}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r10.0<1>:f    r38.0<1;1,0>:ud                  {Compacted,I@6}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f    r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r6.1<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r14.0<1>:d    r38.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r4.7<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r20.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r20.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      -r4.7<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r28.0<1>:f    r4.6<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r30.0<1>:ud   r28.0<1;1,0>:f                   {A@1}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r6.2<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r32.0<1>:d    r32.0<1;1,0>:d    r6.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r33.0<1;1,0>:d    r6.2<0;1,0>:uw  
        mach (8|M8)              r33.0<1>:d    r33.0<1;1,0>:d    r6.1<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r38.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r10.0<1>:ud   r32.0<1;1,0>:ud   r6.1<0;1,0>:ud   {I@1}
        add3 (16|M0)             r100.0<1>:d   r30.0<1;0>:d      r16.0<1;0>:d      -r10.0<1>:d      {I@1}
L1240:
        join (16|M0)                         L1256                                
L1256:
(W)     mul (8|M0)               acc0.0<1>:d   r100.0<1;1,0>:d   r6.2<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r12.0<1>:d    r100.0<1;1,0>:d   r6.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r101.0<1;1,0>:d   r6.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:d    r101.0<1;1,0>:d   r6.1<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r4.6<1>:d     7:w                              
        add (16|M0)              r12.0<1>:d    r38.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    3:w               {Compacted,I@1}
        bfn.0xEA (16|M0)         r64.0<1>:ud   r12.0<1;0>:ud     r34.0<1;0>:ud     r4.6<0>:ud       {I@1} // s0|s1&s2
        shl (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   3:w               {Compacted,$1.dst}
        shr (16|M0)              r10.0<1>:ud   r34.0<1;1,0>:ud   3:w              
        cmp (16|M0)   (lt)f0.0   null<1>:d     r64.0<1;1,0>:ud   r6.3<0;1,0>:ud   {I@3}
        bfn.0xEA (16|M0)         r76.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r4.6<0>:ud       {I@2} // s0|s1&s2
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r76.0<1;1,0>:ud   r6.2<0;1,0>:ud   {I@1}
(f0.0)  goto (16|M0)                         L14504                  L14504                
L1432:
        add (16|M0)              r108.0<1>:d   r76.0<1;1,0>:d    -r6.2<0;1,0>:d   {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r108.0<1;1,0>:ud  r6.4<0;1,0>:ud   {I@1}
(~f0.0) goto (16|M0)                         L14504                  L14504                
L1472:
        add (16|M0)              r22.0<1>:d    r64.0<1;1,0>:d    -r6.3<0;1,0>:d   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:ud   r6.5<0;1,0>:ud   {I@1}
(~f1.1) goto (16|M0)                         L14504                  L14504                
L1512:
(W)     mul (8|M0)               acc0.0<1>:d   r34.0<1;1,0>:d    r6.0<0;1,0>:uw   {Compacted}
        mach (8|M0)              r2.0<1>:d     r34.0<1;1,0>:d    r6.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r35.0<1;1,0>:d    r6.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r35.0<1;1,0>:d    r6.0<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r108.0<1;1,0>:ud  r6.10<0;1,0>:uw 
        mach (8|M0)              r10.0<1>:ud   r108.0<1;1,0>:ud  r6.5<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r100.0<1>:d   r36.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r109.0<1;1,0>:ud  r6.10<0;1,0>:uw 
        mach (8|M8)              r11.0<1>:ud   r109.0<1;1,0>:ud  r6.5<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               r4.24<2>:b    r6.24<0;1,0>:b    1:w              
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r16.0<1>:f    r10.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r22.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:w     r4.24<0;1,0>:b    0:w              
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r23.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        mul (8|M0)               acc0.0<1>:ud  r18.0<1;1,0>:ud   r6.0<0;1,0>:uw   {I@5}
        mach (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r19.0<1;1,0>:ud   r6.0<0;1,0>:uw   {I@5}
        mach (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r6.0<0;1,0>:ud    r20.0<2;1,0>:uw 
        mach (8|M0)              r10.0<1>:d    r6.0<0;1,0>:ud    r20.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r6.0<0;1,0>:ud    r21.0<2;1,0>:uw  {I@7}
        mach (8|M8)              r11.0<1>:d    r6.0<0;1,0>:ud    r21.0<1;1,0>:d  
        add (16|M0)              r40.0<1>:d    r22.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@5}
        add (16|M0)              r12.0<1>:d    r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L2000                  L2000                
L1904:
        shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    1:w               {Compacted,I@3}
(W)     mov (1|M0)               a0.0<1>:ud    r7.4<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r7.2<0;1,0>:d    {Compacted,I@2}
        send.ugm (16|M0)         r10      r2      null:0  a0.0        0x24280B00           {ExBSO,A@1,$5} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        mov (16|M0)              r5.0<1>:uw    r10.0<2;1,0>:uw                  {$5.dst}
        mov (16|M0)              r62.0<1>:f    r5.0<1;1,0>:hf                   {I@1}
        goto (16|M0)                         L2000                  L2064                
L2000:
        join (16|M0)                         L2064                                
L2016:
        shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    2:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r7.4<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r7.2<0;1,0>:d    {Compacted,I@2}
        send.ugm (16|M0)         r62      r2      null:0  a0.0        0x24280500           {ExBSO,A@1,$6} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
L2064:
        join (16|M0)                         L14504                                
L2080:
(W)     mov (1|M0)               a0.0<1>:ud    r7.5<0;1,0>:d                    {A@1}
        shl (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   2:w               {Compacted,$6.src}
        shl (16|M0)              r42.0<1>:d    r36.0<1;1,0>:d    2:w               {Compacted}
        send.ugm (16|M0)         r10      r2      null:0  a0.0        0x24280500           {ExBSO,A@2,$7} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r7.6<0;1,0>:d                    {A@1}
(W)     mov (1|M0)               r8.3<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r8.2<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r8.1<1>:d     -1:w                              
        send.ugm (16|M0)         r12      r42     null:0  a0.0        0x24280500           {ExBSO,A@3,$8} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        sync.allwr                           ($7,$8)                
        mad (16|M0)              r44.0<1>:f    r12.0<1;0>:f      r10.0<1;0>:f      r62.0<1>:f       {Compacted,$6.dst}
        and (16|M0)              r14.0<1>:d    r44.0<1;1,0>:d    2147483647:d               {F@1}
        sel (16|M0)   (lt)f0.0   r70.0<1>:f    r14.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r72.0<1>:ud   r70.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r120.0<1>:d   r70.0<1;1,0>:d    8388607:d              
        and (16|M0)              r86.0<1>:d    r72.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r16.0<1>:ud   r86.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r48.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.1) goto (16|M0)                         L2368                  L2368                
L2336:
        mov (16|M0)              r84.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L2368                  L8264                
L2368:
        join (16|M0)                         L8264                                
L2384:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r120.0<1;1,0>:d   0:w              
        add (16|M0)              r54.0<1>:d    -r48.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    255:w              
        xor (16|M0)              r52.0<1>:d    r54.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L8232                  L8232                
L2456:
        or (16|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    r120.0<1;1,0>:d 
(~f0.1) goto (16|M0)                         L2520                  L2520                
L2488:
        mov (16|M0)              r84.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L2520                  L8264                
L2520:
        join (16|M0)                         L8232                                
L2536:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    0:w              
        shr (16|M0)              r26.0<1>:ud   r54.0<1;1,0>:ud   23:w              
        add (16|M0)              r54.0<1>:d    r86.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r54.0<1>:d    -126:w                              
        add (16|M0)              r64.0<1>:d    r26.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r64.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L8168                  L8168                
L2624:
        or (16|M0)    (eq)f1.1   null<4>:b     r72.0<1;1,0>:d    r26.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L8104                  L8104                
L2656:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.0<1>:d     0:w                              
(f0.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r58.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r60.0<1>:ud   r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r8.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r8.4<1>:d     0:w                              
L2760:
(W)     shl (1|M0)               r2.0<1>:d     r8.7<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r6.0<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r8.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r6.0<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r58.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r8.6<1>:ud    r8.7<0;1,0>:ud    1:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r8.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r6.0<0;1,0>:d    {I@3}
        and (16|M0)              r12.0<1>:d    r8.6<0;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@3}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r8.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r8.6<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r8.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f0.0)  sel (16|M0)              r5.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    r5.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r6.1<1>:ud    r3.0<0;1,0>:ud    r8.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r94.0<1>:d    r8.4<0;1,0>:d                   
        mov (16|M0)              r92.0<1>:d    r8.5<0;1,0>:d                   
        mov (16|M0)              r76.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r106.0<1>:d   r6.1<0;1,0>:d                    {I@3}
(f0.0)  goto (16|M0)                         L3144                  L3144                
L3080:
(W)     mov (1|M0)               r8.7<1>:d     r8.6<0;1,0>:d                   
(W)     mov (1|M0)               r8.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r8.5<1>:d     r6.1<0;1,0>:d                   
(W)     jmpi                                 L2760                                
L3144:
        join (16|M0)                         L8104                                
L3160:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r68.0<1>:ud   r2.0<0;1,0>:ud    r94.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r90.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r92.0<1>:ud     {A@1}
        subb (8|M8)              r69.0<1>:ud   r2.0<0;1,0>:ud    r95.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r20.0<1>:d    r64.0<1;0>:d      r68.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r20.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r91.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r93.0<1>:ud    
        add3 (16|M0)             r88.0<1>:d    r26.0<1;0>:d      r54.0<1;0>:d      r68.0<1>:d      
(f1.0)  goto (16|M0)                         L8048                  L8048                
L3312:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r20.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L5744                  L5744                
L3344:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r20.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L5248                  L5248                
L3376:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r98.0<1>:ud   r2.0<0;1,0>:ud    r94.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r4.0<1>:d     r64.0<1;0>:d      r68.0<1;0>:d      -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r92.0<1>:ud     {F@1}
        subb (8|M8)              r99.0<1>:ud   r2.0<0;1,0>:ud    r95.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r98.0<1;1,0>:ud   r4.0<1;1,0>:ud   {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r93.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f0.1)  goto (16|M0)                         L3600                  L3600                
L3544:
        add3 (16|M0)             r2.0<1>:d     r88.0<1;0>:d      -r98.0<1;0>:d     -23:w              
        mov (16|M0)              r38.0<1>:d    0:w                              
        shl (16|M0)              r50.0<1>:d    r58.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L3600                  L5184                
L3600:
        join (16|M0)                         L5184                                
L3616:
        add3 (16|M0)             r24.0<1>:d    r98.0<1;0>:d      -r88.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L3768                  L3768                
L3664:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L3768                  L3872                
L3696:
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r124.0<1>:d   0:w                              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r118.0<1>:f   r80.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L3768                  L4672                
L3768:
        join (16|M0)                         L3872                                
L3784:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r24.0<1;1,0>:d    1:w              
(~f0.1) goto (16|M0)                         L3872                  L3872                
L3816:
        mov (16|M0)              r124.0<1>:d   0:w                              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r118.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3872                  L4672                
L3872:
        join (16|M0)                         L4672                                
L3888:
        add3 (16|M0)             r2.0<1>:d     r98.0<1;0>:d      -r4.0<1;0>:d      -1:w              
        and (16|M0)   (ne)f0.0   r120.0<1>:d   r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L3952                  L3952                
L3928:
        mov (16|M0)              r94.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3952                  L4064                
L3952:
        join (16|M0)                         L4064                                
L3968:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r120.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r58.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r94.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@1}
L4064:
        join (16|M0)                         L4672                                
L4080:
        add3 (16|M0)             r74.0<1>:d    r98.0<1;0>:d      -r4.0<1;0>:d      -2:w              
        and (16|M0)   (ne)f1.0   r118.0<1>:d   r74.0<1;1,0>:d    63:w               {A@1}
(f1.0)  goto (16|M0)                         L4152                  L4152                
L4128:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4152                  L4256                
L4152:
        join (16|M0)                         L4256                                
L4168:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r80.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r118.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r58.0<1;1,0>:ud   r118.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L4256:
        join (16|M0)                         L4672                                
L4272:
        and (16|M0)   (ne)f0.0   r88.0<1>:d    r74.0<1;1,0>:d    63:w               {Compacted}
        and (16|M0)              r16.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (16|M0)                         L4352                  L4352                
L4304:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        mov (16|M0)              r96.0<1>:d    -1:w                              
        goto (16|M0)                         L4352                  L4536                
L4352:
        join (16|M0)                         L4536                                
L4368:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r88.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L4472                  L4472                
L4400:
        add (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r92.0<1>:d    0:w                              
        shl (16|M0)              r96.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4472                  L4536                
L4472:
        join (16|M0)                         L4536                                
L4488:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r96.0<1>:d    -1:w                              
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r88.0<1;1,0>:d   {F@1}
L4536:
        join (16|M0)                         L4672                                
L4552:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r92.0<1;0>:ud     r8.1<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r96.0<1;0>:ud     r8.1<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r118.0<1>:f   r94.0<1;1,0>:f                   {Compacted}
(f0.1)  sel (16|M0)              r12.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r124.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
L4672:
        join (16|M0)                         L5184                                
L4688:
        and (16|M0)   (ne)f1.0   r116.0<1>:d   r24.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L4744                  L4744                
L4720:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4744                  L4848                
L4744:
        join (16|M0)                         L4848                                
L4760:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r80.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r58.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L4848:
        join (16|M0)                         L5184                                
L4864:
        shl (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r16.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r28.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r124.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r28.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L4960                  L4960                
L4928:
        mov (16|M0)              r34.0<1>:d    0:w                              
        goto (16|M0)                         L4960                  L5112                
L4960:
        join (16|M0)                         L5112                                
L4976:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r28.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L5040                  L5040                
L5008:
        mov (16|M0)              r34.0<1>:d    1:w                              
        goto (16|M0)                         L5040                  L5112                
L5040:
        join (16|M0)                         L5112                                
L5056:
        and (16|M0)   (ne)f0.0   null<1>:d     r80.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r28.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r34.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L5112:
        join (16|M0)                         L5184                                
L5128:
        add (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r50.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r38.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L5184:
        join (16|M0)                         L5248                                
L5200:
        and (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r84.0<1>:ud   r2.0<1;0>:ud      r38.0<1;0>:ud     r50.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L5248                  L8264                
L5248:
        join (16|M0)                         L5744                                
L5264:
        and (16|M0)   (ne)f1.0   r68.0<1>:d    r68.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L5344                  L5344                
L5296:
        mov (16|M0)              r82.0<1>:d    -1:w                              
        mov (16|M0)              r86.0<1>:d    -1:w                              
        goto (16|M0)                         L5344                  L5528                
L5344:
        join (16|M0)                         L5528                                
L5360:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r68.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L5464                  L5464                
L5392:
        add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r82.0<1>:d    0:w                              
        shl (16|M0)              r86.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5464                  L5528                
L5464:
        join (16|M0)                         L5528                                
L5480:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r86.0<1>:d    -1:w                              
        shl (16|M0)              r82.0<1>:d    r2.0<0;1,0>:w     r68.0<1;1,0>:d   {F@1}
L5528:
        join (16|M0)                         L5744                                
L5544:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r8.1<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r86.0<1;0>:ud     r8.1<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    -1:w               {Compacted}
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r20.0<1;1,0>:d    -150:w              
(f0.0)  goto (16|M0)                         L5688                  L5688                
L5648:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5688                  L8264                
L5688:
        join (16|M0)                         L5744                                
L5704:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5744                  L8264                
L5744:
        join (16|M0)                         L8048                                
L5760:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r68.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r70.0<1>:d    r64.0<1;0>:d      r68.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L7744                  L7744                
L5824:
        shl (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r76.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r106.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L6056                  L6056                
L5928:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r106.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L6056                  L6120                
L5976:
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:d    0:w                              
        mov (16|M0)              r16.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6056                  L7216                
L6056:
        join (16|M0)                         L6120                                
L6072:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r106.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L6120                  L7128                
L6120:
        join (16|M0)                         L7128                                
L6136:
        add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r4.0<1>:d     r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r116.0<1>:d   -r76.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L6208                  L6208                
L6184:
        mov (16|M0)              r108.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6208                  L6320                
L6208:
        join (16|M0)                         L6320                                
L6224:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r4.0<1;1,0>:d     -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r4.0<1;1,0>:d    32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r58.0<1;1,0>:ud   r4.0<1;1,0>:d   
(f1.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r108.0<1>:f   r80.0<1;1,0>:f                   {Compacted,I@1}
L6320:
        join (16|M0)                         L7128                                
L6336:
        add (16|M0)              r82.0<1>:d    -r76.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r12.0<1>:d    r82.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L6400                  L6400                
L6376:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6400                  L6504                
L6400:
        join (16|M0)                         L6504                                
L6416:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r80.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r12.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r10.0<1>:ud   r58.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L6504:
        join (16|M0)                         L7128                                
L6520:
        and (16|M0)   (ne)f1.1   r100.0<1>:d   r82.0<1;1,0>:d    63:w              
        and (16|M0)              r24.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L6608                  L6608                
L6560:
        mov (16|M0)              r110.0<1>:d   -1:w                              
        mov (16|M0)              r114.0<1>:d   -1:w                              
        goto (16|M0)                         L6608                  L6792                
L6608:
        join (16|M0)                         L6792                                
L6624:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r100.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L6728                  L6728                
L6656:
        add (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r110.0<1>:d   0:w                              
        shl (16|M0)              r114.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6728                  L6792                
L6728:
        join (16|M0)                         L6792                                
L6744:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r114.0<1>:d   -1:w                              
        shl (16|M0)              r110.0<1>:d   r2.0<0;1,0>:w     r100.0<1;1,0>:d  {F@1}
L6792:
        join (16|M0)                         L7128                                
L6808:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r110.0<1;0>:ud    r8.1<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r114.0<1;0>:ud    r8.1<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r10.0<1>:d    r116.0<1;1,0>:d   63:w              
(f0.0)  sel (16|M0)              r12.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r14.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L6968                  L6968                
L6944:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6968                  L7072                
L6968:
        join (16|M0)                         L7072                                
L6984:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:ud   0x20:uw             
(~f0.0) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r80.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f0.0)  shr (16|M0)              r10.0<1>:ud   r58.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f0.0)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L7072:
        join (16|M0)                         L7128                                
L7088:
        mov (16|M0)              r16.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r80.0<1>:d    r108.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L7128                  L7216                
L7128:
        join (16|M0)                         L7216                                
L7144:
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   2:w              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:d    0:w                              
        mov (16|M0)              r16.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   1:w               {F@1}
L7216:
        join (16|M0)                         L7744                                
L7232:
        shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r80.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r14.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r112.0<1>:d   r16.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L7352                  L7352                
L7320:
        mov (16|M0)              r66.0<1>:d    0:w                              
        goto (16|M0)                         L7352                  L7512                
L7352:
        join (16|M0)                         L7512                                
L7368:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r80.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L7432                  L7432                
L7400:
        mov (16|M0)              r66.0<1>:d    1:w                              
        goto (16|M0)                         L7432                  L7512                
L7432:
        join (16|M0)                         L7512                                
L7448:
        and (16|M0)   (ne)f1.1   null<1>:d     r16.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L7512:
        join (16|M0)                         L7744                                
L7528:
        add (16|M0)              r60.0<1>:d    r112.0<1;1,0>:d   r66.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r60.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r64.0<1;0>:d      r68.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r58.0<1>:d    r2.0<1;1,0>:d     r70.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r58.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L7680                  L7680                
L7608:
(~f1.0) sel (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r52.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r58.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r84.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7680                  L8264                
L7680:
        join (16|M0)                         L7744                                
L7696:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r52.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7744                  L8264                
L7744:
        join (16|M0)                         L8048                                
L7760:
        and (16|M0)   (ne)f0.0   r36.0<1>:d    r68.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L7816                  L7816                
L7784:
        mov (16|M0)              r50.0<1>:d    -1:w                              
        goto (16|M0)                         L7816                  L7944                
L7816:
        join (16|M0)                         L7944                                
L7832:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r36.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L7896                  L7896                
L7864:
        mov (16|M0)              r50.0<1>:d    0:w                              
        goto (16|M0)                         L7896                  L7944                
L7896:
        join (16|M0)                         L7944                                
L7912:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r50.0<1>:d    r2.0<0;1,0>:w     r36.0<1;1,0>:d   {F@1}
L7944:
        join (16|M0)                         L8048                                
L7960:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r50.0<1;0>:ud     r8.1<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r68.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r52.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r70.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r84.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L8048                  L8264                
L8048:
        join (16|M0)                         L8104                                
L8064:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8104                  L8264                
L8104:
        join (16|M0)                         L8168                                
L8120:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r52.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L8168                  L8264                
L8168:
        join (16|M0)                         L8232                                
L8184:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r52.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8232                  L8264                
L8232:
        join (16|M0)                         L8264                                
L8248:
        bfn.0xF8 (16|M0)         r84.0<1>:ud   r52.0<1;0>:ud     r8.3<0;0>:ud      r8.2<0>:ud       {F@1} // s0&s1|s2
L8264:
        join (16|M0)                         L14504                                
L8280:
        rnde (16|M0)             r78.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r70.0<1>:ud   r78.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r78.0<1;1,0>:d    8388607:d              
        and (16|M0)              r102.0<1>:d   r70.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (16|M0)                         L8392                  L8392                
L8360:
        mov (16|M0)              r82.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L8392                  L14344                
L8392:
        join (16|M0)                         L14344                                
L8408:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r66.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   255:w              
        and (16|M0)              r58.0<1>:d    r66.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r58.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r50.0<1>:d    r2.0<1;1,0>:d     r78.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L14312                  L14312                
L8520:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r58.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r102.0<1;1,0>:d   r108.0<1;1,0>:d  {Compacted}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.1) goto (16|M0)                         L8608                  L8608                
L8576:
        mov (16|M0)              r82.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L8608                  L14344                
L8608:
        join (16|M0)                         L14312                                
L8624:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   0:w              
        add (16|M0)              r52.0<1>:d    r102.0<1;1,0>:d   -127:w               {Compacted}
(f1.1)  mov (16|M0)              r52.0<1>:d    -126:w                              
        add (16|M0)              r62.0<1>:d    r58.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r62.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L14248                  L14248                
L8704:
        or (16|M0)    (eq)f0.1   null<4>:b     r70.0<1;1,0>:d    r66.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L14184                  L14184                
L8736:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.0<1>:d     0:w                              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r108.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r54.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r56.0<1>:ud   r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r8.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r8.4<1>:d     0:w                              
L8840:
(W)     shl (1|M0)               r2.0<1>:d     r8.7<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r6.0<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r8.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r6.0<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r54.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r8.6<1>:ud    r8.7<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r8.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r6.0<0;1,0>:d    {I@3}
        and (16|M0)              r12.0<1>:d    r8.6<0;1,0>:d     r56.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r8.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r12.0<1;1,0>:d    r8.6<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r8.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r5.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r5.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r6.1<1>:ud    r3.0<0;1,0>:ud    r8.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r90.0<1>:d    r8.4<0;1,0>:d                   
        mov (16|M0)              r88.0<1>:d    r8.5<0;1,0>:d                   
        mov (16|M0)              r78.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r104.0<1>:d   r6.1<0;1,0>:d                    {I@3}
(f1.1)  goto (16|M0)                         L9224                  L9224                
L9160:
(W)     mov (1|M0)               r8.7<1>:d     r8.6<0;1,0>:d                   
(W)     mov (1|M0)               r8.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r8.5<1>:d     r6.1<0;1,0>:d                   
(W)     jmpi                                 L8840                                
L9224:
        join (16|M0)                         L14184                                
L9240:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r66.0<1>:ud   r2.0<0;1,0>:ud    r90.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r86.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r88.0<1>:ud     {A@1}
        subb (8|M8)              r67.0<1>:ud   r2.0<0;1,0>:ud    r91.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r62.0<1;0>:d      r66.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@1}
        add3 (8|M8)              r87.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r89.0<1>:ud    
        add3 (16|M0)             r84.0<1>:d    r58.0<1;0>:d      r52.0<1;0>:d      r66.0<1>:d      
(f0.0)  goto (16|M0)                         L14128                  L14128                
L9384:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r18.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L11816                  L11816                
L9416:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L11320                  L11320                
L9448:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r96.0<1>:ud   r2.0<0;1,0>:ud    r90.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r122.0<1>:d   r62.0<1;0>:d      r66.0<1;0>:d      -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r88.0<1>:ud     {F@1}
        subb (8|M8)              r97.0<1>:ud   r2.0<0;1,0>:ud    r91.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r96.0<1;1,0>:ud   r122.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r89.0<1>:ud    
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (16|M0)                         L9672                  L9672                
L9616:
        add3 (16|M0)             r2.0<1>:d     r84.0<1;0>:d      -r96.0<1;0>:d     -23:w              
        mov (16|M0)              r30.0<1>:d    0:w                              
        shl (16|M0)              r32.0<1>:d    r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9672                  L11256                
L9672:
        join (16|M0)                         L11256                                
L9688:
        add3 (16|M0)             r30.0<1>:d    r96.0<1;0>:d      -r84.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r30.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L9832                  L9832                
L9736:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (16|M0)                         L9832                  L9936                
L9760:
        shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   1:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r106.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9832                  L10744                
L9832:
        join (16|M0)                         L9936                                
L9848:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r30.0<1;1,0>:d    1:w              
(~f1.1) goto (16|M0)                         L9936                  L9936                
L9880:
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r106.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9936                  L10744                
L9936:
        join (16|M0)                         L10744                                
L9952:
        add3 (16|M0)             r2.0<1>:d     r96.0<1;0>:d      -r122.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.0   r114.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L10024                  L10024                
L10000:
        mov (16|M0)              r98.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10024                  L10136                
L10024:
        join (16|M0)                         L10136                                
L10040:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r54.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r74.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r98.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@1}
L10136:
        join (16|M0)                         L10744                                
L10152:
        add3 (16|M0)             r68.0<1>:d    r96.0<1;0>:d      -r122.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.0   r112.0<1>:d   r68.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L10216                  L10216                
L10192:
        mov (16|M0)              r74.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10216                  L10320                
L10216:
        join (16|M0)                         L10320                                
L10232:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r112.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r54.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r74.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L10320:
        join (16|M0)                         L10744                                
L10336:
        and (16|M0)   (ne)f1.0   r76.0<1>:d    r68.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10416                  L10416                
L10368:
        mov (16|M0)              r84.0<1>:d    -1:w                              
        mov (16|M0)              r90.0<1>:d    -1:w                              
        goto (16|M0)                         L10416                  L10600                
L10416:
        join (16|M0)                         L10600                                
L10432:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L10536                  L10536                
L10464:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r84.0<1>:d    0:w                              
        shl (16|M0)              r90.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10536                  L10600                
L10536:
        join (16|M0)                         L10600                                
L10552:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r90.0<1>:d    -1:w                              
        shl (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L10600:
        join (16|M0)                         L10744                                
L10616:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r84.0<1;0>:ud     r8.1<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r90.0<1;0>:ud     r8.1<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r14.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r12.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r106.0<1>:f   r98.0<1;1,0>:f                   {Compacted}
        and (16|M0)              r112.0<1>:d   r14.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r126.0<1>:d   -r12.0<1;1,0>:d                  {I@2}
L10744:
        join (16|M0)                         L11256                                
L10760:
        and (16|M0)   (ne)f0.0   r110.0<1>:d   r30.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L10808                  L10808                
L10784:
        mov (16|M0)              r74.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10808                  L10912                
L10808:
        join (16|M0)                         L10912                                
L10824:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r54.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r74.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L10912:
        join (16|M0)                         L11256                                
L10928:
        shl (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r22.0<1>:ud   r2.0<1;0>:ud      r112.0<1;0>:ud    r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L11024                  L11024                
L10992:
        mov (16|M0)              r26.0<1>:d    0:w                              
        goto (16|M0)                         L11024                  L11184                
L11024:
        join (16|M0)                         L11184                                
L11040:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L11104                  L11104                
L11072:
        mov (16|M0)              r26.0<1>:d    1:w                              
        goto (16|M0)                         L11104                  L11184                
L11104:
        join (16|M0)                         L11184                                
L11120:
        and (16|M0)   (ne)f1.1   null<1>:d     r74.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r26.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L11184:
        join (16|M0)                         L11256                                
L11200:
        add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r32.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r30.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L11256:
        join (16|M0)                         L11320                                
L11272:
        and (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r82.0<1>:ud   r2.0<1;0>:ud      r30.0<1;0>:ud     r32.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L11320                  L14344                
L11320:
        join (16|M0)                         L11816                                
L11336:
        and (16|M0)   (ne)f0.0   r38.0<1>:d    r66.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L11408                  L11408                
L11360:
        mov (16|M0)              r62.0<1>:d    -1:w                              
        mov (16|M0)              r72.0<1>:d    -1:w                              
        goto (16|M0)                         L11408                  L11592                
L11408:
        join (16|M0)                         L11592                                
L11424:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r38.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L11528                  L11528                
L11456:
        add (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r62.0<1>:d    0:w                              
        shl (16|M0)              r72.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11528                  L11592                
L11528:
        join (16|M0)                         L11592                                
L11544:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r72.0<1>:d    -1:w                              
        shl (16|M0)              r62.0<1>:d    r2.0<0;1,0>:w     r38.0<1;1,0>:d   {F@1}
L11592:
        join (16|M0)                         L11816                                
L11608:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r62.0<1;0>:ud     r8.1<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r72.0<1;0>:ud     r8.1<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L11760                  L11760                
L11720:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r82.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11760                  L14344                
L11760:
        join (16|M0)                         L11816                                
L11776:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r82.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11816                  L14344                
L11816:
        join (16|M0)                         L14128                                
L11832:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r66.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r72.0<1>:d    r62.0<1;0>:d      r66.0<1;0>:d      -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L13816                  L13816                
L11896:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r78.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r104.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L12128                  L12128                
L12000:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r78.0<1;1,0>:d    39:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(~f0.1) goto (16|M0)                         L12128                  L12184                
L12048:
        shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   1:w              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r14.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r74.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12128                  L13296                
L12128:
        join (16|M0)                         L12184                                
L12144:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r78.0<1;1,0>:d    38:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r104.0<1;1,0>:d   0:w               {I@4}
(f0.0)  goto (16|M0)                         L12184                  L13208                
L12184:
        join (16|M0)                         L13208                                
L12200:
        add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r122.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r114.0<1>:d   -r78.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L12272                  L12272                
L12248:
        mov (16|M0)              r106.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12272                  L12384                
L12272:
        join (16|M0)                         L12384                                
L12288:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r10.0<1>:ud   r54.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r74.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r106.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@1}
L12384:
        join (16|M0)                         L13208                                
L12400:
        add (16|M0)              r78.0<1>:d    -r78.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r126.0<1>:d   r78.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L12464                  L12464                
L12440:
        mov (16|M0)              r92.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12464                  L12576                
L12464:
        join (16|M0)                         L12576                                
L12480:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r54.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r74.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r92.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@1}
L12576:
        join (16|M0)                         L13208                                
L12592:
        and (16|M0)   (ne)f0.1   r94.0<1>:d    r78.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L12672                  L12672                
L12624:
        mov (16|M0)              r98.0<1>:d    -1:w                              
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L12672                  L12856                
L12672:
        join (16|M0)                         L12856                                
L12688:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r94.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L12792                  L12792                
L12720:
        add (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r98.0<1>:d    0:w                              
        shl (16|M0)              r102.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12792                  L12856                
L12792:
        join (16|M0)                         L12856                                
L12808:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r102.0<1>:d   -1:w                              
        shl (16|M0)              r98.0<1>:d    r2.0<0;1,0>:w     r94.0<1;1,0>:d   {F@1}
L12856:
        join (16|M0)                         L13208                                
L12872:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r98.0<1;0>:ud     r8.1<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r102.0<1;0>:ud    r8.1<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r12.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.1   r124.0<1>:d   r114.0<1;1,0>:d   63:w              
        mov (16|M0)              r12.0<1>:d    -r12.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L13040                  L13040                
L13016:
        mov (16|M0)              r74.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13040                  L13144                
L13040:
        join (16|M0)                         L13144                                
L13056:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r124.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r124.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r54.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r74.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L13144:
        join (16|M0)                         L13208                                
L13160:
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r14.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r104.0<1>:d   r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r74.0<1>:f    r106.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L13208                  L13296                
L13208:
        join (16|M0)                         L13296                                
L13224:
        shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r14.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   1:w               {F@1}
L13296:
        join (16|M0)                         L13816                                
L13312:
        shl (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r60.0<1>:ud   r2.0<1;0>:ud      r104.0<1;0>:ud    r12.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r60.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r110.0<1>:d   r14.0<1;1,0>:d    8388607:d              
(~f0.1) goto (16|M0)                         L13424                  L13424                
L13392:
        mov (16|M0)              r36.0<1>:d    0:w                              
        goto (16|M0)                         L13424                  L13584                
L13424:
        join (16|M0)                         L13584                                
L13440:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r60.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (16|M0)                         L13504                  L13504                
L13472:
        mov (16|M0)              r36.0<1>:d    1:w                              
        goto (16|M0)                         L13504                  L13584                
L13504:
        join (16|M0)                         L13584                                
L13520:
        and (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r60.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r36.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L13584:
        join (16|M0)                         L13816                                
L13600:
        add (16|M0)              r56.0<1>:d    r110.0<1;1,0>:d   r36.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r56.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r62.0<1;0>:d      r66.0<1;0>:d      -45:w              
(f0.0)  sel (16|M0)              r34.0<1>:d    r2.0<1;1,0>:d     r72.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r34.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L13752                  L13752                
L13680:
(~f0.0) sel (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r50.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r34.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r82.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13752                  L14344                
L13752:
        join (16|M0)                         L13816                                
L13768:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r50.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r82.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13816                  L14344                
L13816:
        join (16|M0)                         L14128                                
L13832:
        and (16|M0)   (ne)f1.0   r28.0<1>:d    r66.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L13896                  L13896                
L13864:
        mov (16|M0)              r32.0<1>:d    -1:w                              
        goto (16|M0)                         L13896                  L14024                
L13896:
        join (16|M0)                         L14024                                
L13912:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r28.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L13976                  L13976                
L13944:
        mov (16|M0)              r32.0<1>:d    0:w                              
        goto (16|M0)                         L13976                  L14024                
L13976:
        join (16|M0)                         L14024                                
L13992:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r32.0<1>:d    r2.0<0;1,0>:w     r28.0<1;1,0>:d   {F@1}
L14024:
        join (16|M0)                         L14128                                
L14040:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r32.0<1;0>:ud     r8.1<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r66.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r50.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r72.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r82.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14128                  L14344                
L14128:
        join (16|M0)                         L14184                                
L14144:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r50.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r82.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14184                  L14344                
L14184:
        join (16|M0)                         L14248                                
L14200:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r50.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r82.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L14248                  L14344                
L14248:
        join (16|M0)                         L14312                                
L14264:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r82.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14312                  L14344                
L14312:
        join (16|M0)                         L14344                                
L14328:
        bfn.0xF8 (16|M0)         r82.0<1>:ud   r50.0<1;0>:ud     r8.3<0;0>:ud      r8.2<0>:ud       {F@1} // s0&s1|s2
L14344:
        join (16|M0)                         L14504                                
L14360:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r44.0<1;1,0>:f    0.0:f               {Compacted,I@7}
        shl (16|M0)              r10.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r82.0<1;1,0>:f   r82.0<1;1,0>:f   {Compacted,I@3}
(W)     mov (1|M0)               a0.0<1>:ud    r7.7<0;1,0>:d                    {A@1}
        mov (8|M0)               r5.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r5.8<1>:hf    r3.0<1;1,0>:f                   
        add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    r7.3<0;1,0>:d    {Compacted,I@2}
        mov (16|M0)              r12.0<1>:ud   r5.0<1;1,0>:uw                   {A@1}
        send.ugm (16|M0)         null     r10     r12:2   a0.0        0x240E0B04           {ExBSO,A@1,$9} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r8.0<0;1,0>:d                    {A@1}
        send.ugm (16|M0)         null     r42     r44:2   a0.0        0x240E0504           {ExBSO,$10} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
L14504:
        join (16|M0)                         L14520                                
L14520:
(W)     mov (8|M0)               r127.0<1>:f   r46.0<1;1,0>:f                   {Compacted}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L14544:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x5D:ud                             
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
