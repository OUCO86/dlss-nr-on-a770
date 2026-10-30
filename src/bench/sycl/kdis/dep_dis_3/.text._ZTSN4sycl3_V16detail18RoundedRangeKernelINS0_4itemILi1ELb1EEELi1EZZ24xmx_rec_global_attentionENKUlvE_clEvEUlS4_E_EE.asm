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
(W)     mov (8|M0)               r44.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r44.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r44.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@1}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r36.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r34.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r37.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r36.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r35.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r34.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L20872                  L20872                
L520:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w               {Compacted,$2.dst}
        mov (16|M0)              r40.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r38.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r45.0<1>:d    r5.2<1;1,0>:d                   
(W)     mov (2|M0)               r45.2<1>:d    r5.4<1;1,0>:d                   
(W)     mov (1|M0)               r5.3<1>:f     inf:f                               {Compacted,I@2}
(W)     mov (1|M0)               r5.2<1>:d     -1:w                              
(W)     mov (2|M0)               r5.5<1>:d     r5.6<1;1,0>:d                   
(W)     mov (1|M0)               r5.4<1>:d     -2147483648:d                              
L632:
(~f0.0) goto (16|M0)                         L680                  L680                
L648:
        mov (16|M0)              r24.0<1>:d    -1:w                              
        goto (16|M0)                         L680                  L1056                
L680:
        join (16|M0)                         L1056                                
L696:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$3.src}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r8.0<1>:f     r40.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r6.0<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r6.0<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r40.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r6.1<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r6.1<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r6.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r40.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f0.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r24.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1056:
        join (16|M0)                         L20872                                
L1072:
(W)     mul (8|M0)               acc0.0<1>:d   r24.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r24.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted,$3.src}
(W)     mul (8|M8)               acc0.0<1>:d   r25.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r25.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r8.0<1>:d     r40.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@1}
        shr (16|M0)              r10.0<1>:ud   r8.0<1;1,0>:ud    5:w               {I@1}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r5.2<0;1,0>:uw   {I@1}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r5.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r18.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M0)              r16.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r20.0<1>:ud   r16.0<1;1,0>:ud   r24.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        shl (16|M0)              r12.0<1>:d    r8.0<1;1,0>:d     2:w               {Compacted}
        add (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud  r18.0<1;1,0>:ud 
        addc (8|M8)              r21.0<1>:ud   r17.0<1;1,0>:ud   r25.0<1;1,0>:ud  {AccWrEn}
        and (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    124:w               {Compacted,I@3}
        add (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud  r19.0<1;1,0>:ud 
        shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    7:w               {Compacted,I@3}
        shr (16|M0)              r24.0<1>:ud   r20.0<1;1,0>:ud   25:w              
        shl (16|M0)              r26.0<1>:d    r22.0<1;1,0>:d    7:w               {Compacted,I@3}
        addc (8|M0)              r10.0<1>:ud   r2.0<1;1,0>:ud    r45.0<0;1,0>:ud  {AccWrEn,Compacted,I@3}
        or (16|M0)               r26.0<1>:d    r26.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r28.0<1>:ud   acc0.0<1;0>:ud    r26.0<1;0>:ud     r45.1<0>:ud      {I@1}
        addc (8|M8)              r11.0<1>:ud   r3.0<1;1,0>:ud    r45.0<0;1,0>:ud  {AccWrEn}
        shl (16|M0)              r8.0<1>:d     r22.0<1;1,0>:d    2:w               {Compacted}
        add3 (8|M8)              r29.0<1>:ud   acc0.0<1;0>:ud    r27.0<1;0>:ud     r45.1<0>:ud     
        addc (8|M0)              r14.0<1>:ud   r10.0<1;1,0>:ud   r12.0<1;1,0>:ud  {AccWrEn,Compacted}
        shr (16|M0)              r26.0<1>:ud   r20.0<1;1,0>:ud   30:w              
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r15.0<1>:ud   r11.0<1;1,0>:ud   r13.0<1;1,0>:ud  {AccWrEn,I@6}
        add (8|M0)               r30.1<2>:ud   r16.0<1;1,0>:ud   r28.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r30.0<2>:d    r14.0<1;1,0>:d                  
        add (8|M8)               r32.1<2>:ud   r18.0<1;1,0>:ud   r29.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r32.0<2>:d    r15.0<1;1,0>:d                  
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r26.0<1;1,0>:d   {Compacted}
        send.ugm (16|M0)         r2       r30     null:0  0x0            0x08280580           {A@2,$5} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        shl (16|M0)              r24.0<1>:d    r20.0<1;1,0>:d    2:w               {Compacted}
        addc (8|M0)              r106.0<1>:ud  r24.0<1;1,0>:ud   r45.2<0;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r104.0<1>:ud  acc0.0<1;0>:ud    r8.0<1;0>:ud      r45.3<0>:ud     
        addc (8|M8)              r107.0<1>:ud  r25.0<1;1,0>:ud   r45.2<0;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r105.0<1>:ud  acc0.0<1;0>:ud    r9.0<1;0>:ud      r45.3<0>:ud     
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                    {$5.dst}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
        mov (8|M0)               r94.0<1>:f    r7.0<1;1,0>:hf                   {F@2}
        mov (8|M8)               r95.0<1>:f    r7.8<1;1,0>:hf                   {F@2}
        shr (16|M0)              r126.0<1>:ud  r94.0<1;1,0>:ud   23:w               {A@1}
        and (16|M0)   (ne)f1.0   r26.0<1>:d    r94.0<1;1,0>:d    8388607:d              
        and (16|M0)              r54.0<1>:d    r126.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L1760                  L1760                
L1728:
        mov (16|M0)              r42.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1760                  L8128                
L1760:
        join (16|M0)                         L8128                                
L1776:
        mov (8|M0)               r7.0<2>:d     r106.0<1;1,0>:d                 
        mov (8|M8)               r9.0<2>:d     r107.0<1;1,0>:d                 
        mov (8|M0)               r7.1<2>:d     r104.0<1;1,0>:d                 
        mov (8|M8)               r9.1<2>:d     r105.0<1;1,0>:d                 
        send.ugm (16|M0)         r92      r7      null:0  0x0            0x08280580           {A@1,$6} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        shr (16|M0)              r102.0<1>:ud  r92.0<1;1,0>:ud   23:w               {$6.dst}
        and (16|M0)   (ne)f0.1   r18.0<1>:d    r92.0<1;1,0>:d    8388607:d              
        and (16|M0)              r52.0<1>:d    r102.0<1;1,0>:d   255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r52.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (16|M0)                         L1960                  L1960                
L1928:
        mov (16|M0)              r42.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1960                  L8128                
L1960:
        join (16|M0)                         L8128                                
L1976:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r26.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r18.0<1;1,0>:d    0:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    255:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r50.0<1>:d    r92.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted}
(f0.1)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.1   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.1)  goto (16|M0)                         L8096                  L8096                
L2128:
        or (16|M0)    (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    r18.0<1;1,0>:d  
        or (16|M0)               r2.0<1>:d     r54.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L2216                  L2216                
L2184:
        mov (16|M0)              r42.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L2216                  L8128                
L2216:
        join (16|M0)                         L8096                                
L2232:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r52.0<1;1,0>:d    0:w              
        add (16|M0)              r84.0<1>:d    r54.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M0)              r90.0<1>:d    r52.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r84.0<1>:d    -126:w                              
(f0.1)  mov (16|M0)              r90.0<1>:d    -126:w                              
        add (16|M0)              r66.0<1>:d    r84.0<1;1,0>:d    r90.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r66.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (16|M0)                         L8032                  L8032                
L2352:
        or (16|M0)    (eq)f1.1   null<4>:b     r126.0<1;1,0>:d   r102.0<1;1,0>:d 
(f1.1)  goto (16|M0)                         L7968                  L7968                
L2384:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r45.7<1>:d    0:w                              
(f1.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
(f0.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d              
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r26.0<1;1,0>:d   {Compacted,I@2}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:ud  r8.0<1;1,0>:ud    r10.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r45.6<1>:f    -0.0:f                               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r9.0<1;1,0>:ud    r11.0<2;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r9.0<1;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r45.4<1>:d    0:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r64.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r52.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L2576:
(W)     shl (1|M0)               r2.0<1>:d     r45.6<0;1,0>:d    31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r45.7<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f0.1   null<1>:d     r45.4<0;1,0>:ud   0x3E:uw             
(W)     or (1|M0)                r45.7<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r8.0<1>:ud    r52.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r5.7<1>:ud    r45.6<0;1,0>:ud   1:w              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:d     r45.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r45.7<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r64.0<1;1,0>:d    r5.7<0;1,0>:d    {Compacted,I@3}
(W&~f0.1) cmp (16|M0) (gt)f0.1   null<1>:d     r45.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r5.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r45.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f0.1)  sel (16|M0)              r7.0<1>:uw    r6.0<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r6.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    r45.5<0;1,0>:ud  {Compacted,I@2}
        mov (16|M0)              r124.0<1>:d   r45.4<0;1,0>:d                  
        mov (16|M0)              r122.0<1>:d   r45.5<0;1,0>:d                  
        mov (16|M0)              r100.0<1>:f   r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r110.0<1>:f   r3.0<0;1,0>:f                    {Compacted,I@3}
(f1.1)  goto (16|M0)                         L2952                  L2952                
L2888:
(W)     mov (1|M0)               r45.6<1>:d    r5.7<0;1,0>:d                   
(W)     mov (1|M0)               r45.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r45.5<1>:d    r3.0<0;1,0>:d                   
(W)     jmpi                                 L2576                                
L2952:
        join (16|M0)                         L7968                                
L2968:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
        subb (8|M0)              r78.0<1>:ud   r2.0<0;1,0>:ud    r124.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r114.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r122.0<1>:ud    {F@1}
        subb (8|M8)              r79.0<1>:ud   r2.0<0;1,0>:ud    r125.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r102.0<1>:d   r66.0<1;0>:d      r78.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r102.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r115.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r123.0<1>:ud   
        add3 (16|M0)             r112.0<1>:d   r84.0<1;0>:d      r90.0<1;0>:d      r78.0<1>:d      
(f1.0)  goto (16|M0)                         L7904                  L7904                
L3120:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r102.0<1;1,0>:d   -127:w              
(f0.1)  goto (16|M0)                         L5592                  L5592                
L3152:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r102.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L5088                  L5088                
L3184:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r28.0<1>:ud   r2.0<0;1,0>:ud    r124.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r126.0<1>:d   r66.0<1;0>:d      r78.0<1;0>:d      104:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r122.0<1>:ud    {F@1}
        subb (8|M8)              r29.0<1>:ud   r2.0<0;1,0>:ud    r125.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r28.0<1;1,0>:ud   r126.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r123.0<1>:ud   
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L3408                  L3408                
L3352:
        add3 (16|M0)             r2.0<1>:d     r112.0<1;0>:d     -r28.0<1;0>:d     104:w              
        mov (16|M0)              r56.0<1>:d    0:w                              
        shl (16|M0)              r58.0<1>:d    r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L3408                  L5024                
L3408:
        join (16|M0)                         L5024                                
L3424:
        add3 (16|M0)             r108.0<1>:d   r28.0<1;0>:d      -r112.0<1;0>:d    -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r108.0<1;1,0>:d   2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L3560                  L3560                
L3464:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r108.0<1;1,0>:d   2:w              
(~f0.1) goto (16|M0)                         L3560                  L3608                
L3496:
        shr (16|M0)              r98.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        and (16|M0)              r24.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r102.0<1>:f   r98.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L3560                  L4496                
L3560:
        join (16|M0)                         L3608                                
L3576:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   1:w              
(f1.1)  goto (16|M0)                         L3608                  L4440                
L3608:
        join (16|M0)                         L4440                                
L3624:
        add3 (16|M0)             r2.0<1>:d     r28.0<1;0>:d      -r126.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.0   r62.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L3696                  L3696                
L3672:
        mov (16|M0)              r12.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3696                  L3808                
L3696:
        join (16|M0)                         L3808                                
L3712:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r98.0<1>:ud   r64.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r62.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r98.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r12.0<1>:f    r98.0<1;1,0>:f                   {Compacted,I@1}
L3808:
        join (16|M0)                         L4440                                
L3824:
        add3 (16|M0)             r96.0<1>:d    r28.0<1;0>:d      -r126.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.1   r60.0<1>:d    r96.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L3896                  L3896                
L3872:
        mov (16|M0)              r98.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3896                  L4000                
L3896:
        join (16|M0)                         L4000                                
L3912:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r60.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r98.0<1>:ud   r64.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r60.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r60.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r98.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4000:
        join (16|M0)                         L4440                                
L4016:
        and (16|M0)   (ne)f0.1   r56.0<1>:d    r96.0<1;1,0>:d    63:w              
        and (16|M0)              r24.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L4104                  L4104                
L4056:
        mov (16|M0)              r70.0<1>:d    -1:w                              
        mov (16|M0)              r78.0<1>:d    -1:w                              
        goto (16|M0)                         L4104                  L4288                
L4104:
        join (16|M0)                         L4288                                
L4120:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r56.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L4224                  L4224                
L4152:
        add (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r70.0<1>:d    0:w                              
        shl (16|M0)              r78.0<1>:d    r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4224                  L4288                
L4224:
        join (16|M0)                         L4288                                
L4240:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r78.0<1>:d    -1:w                              
        shl (16|M0)              r70.0<1>:d    r2.0<0;1,0>:w     r56.0<1;1,0>:d   {F@1}
L4288:
        join (16|M0)                         L4440                                
L4304:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r70.0<1;0>:ud     r5.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r64.0<1;0>:ud     r78.0<1;0>:ud     r5.2<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r102.0<1>:f   r12.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.0<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r118.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L4440                  L4496                
L4440:
        join (16|M0)                         L4496                                
L4456:
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r24.0<1>:d    0:w                              
        mov (16|M0)              r102.0<1>:f   r52.0<1;1,0>:f                   {Compacted}
L4496:
        join (16|M0)                         L5024                                
L4512:
        and (16|M0)   (ne)f1.0   r58.0<1>:d    r108.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L4568                  L4568                
L4544:
        mov (16|M0)              r98.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4568                  L4672                
L4568:
        join (16|M0)                         L4672                                
L4584:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r58.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r98.0<1>:ud   r64.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r58.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r58.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r98.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4672:
        join (16|M0)                         L5024                                
L4688:
        shl (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r24.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r116.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r118.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (16|M0)                         L4792                  L4792                
L4760:
        mov (16|M0)              r120.0<1>:d   0:w                              
        goto (16|M0)                         L4792                  L4952                
L4792:
        join (16|M0)                         L4952                                
L4808:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L4872                  L4872                
L4840:
        mov (16|M0)              r120.0<1>:d   1:w                              
        goto (16|M0)                         L4872                  L4952                
L4872:
        join (16|M0)                         L4952                                
L4888:
        and (16|M0)   (ne)f0.1   null<1>:d     r98.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   4:w              
(f0.1)  sel (16|M0)              r120.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L4952:
        join (16|M0)                         L5024                                
L4968:
        add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   r98.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r58.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r56.0<1>:d    r6.0<0;1,0>:d     0:w               {Compacted,F@1}
L5024:
        join (16|M0)                         L5088                                
L5040:
        and (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r42.0<1>:ud   r2.0<1;0>:ud      r56.0<1;0>:ud     r58.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L5088                  L8128                
L5088:
        join (16|M0)                         L5592                                
L5104:
        and (16|M0)   (ne)f0.1   r14.0<1>:d    r78.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L5184                  L5184                
L5136:
        mov (16|M0)              r24.0<1>:d    -1:w                              
        mov (16|M0)              r54.0<1>:d    -1:w                              
        goto (16|M0)                         L5184                  L5368                
L5184:
        join (16|M0)                         L5368                                
L5200:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L5304                  L5304                
L5232:
        add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r24.0<1>:d    0:w                              
        shl (16|M0)              r54.0<1>:d    r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5304                  L5368                
L5304:
        join (16|M0)                         L5368                                
L5320:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r54.0<1>:d    -1:w                              
        shl (16|M0)              r24.0<1>:d    r2.0<0;1,0>:w     r14.0<1;1,0>:d   {F@1}
L5368:
        join (16|M0)                         L5592                                
L5384:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r24.0<1;0>:ud     r5.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r64.0<1;0>:ud     r54.0<1;0>:ud     r5.2<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   -150:w              
(f1.0)  goto (16|M0)                         L5536                  L5536                
L5496:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r42.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5536                  L8128                
L5536:
        join (16|M0)                         L5592                                
L5552:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r42.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5592                  L8128                
L5592:
        join (16|M0)                         L7904                                
L5608:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (16|M0)             r86.0<1>:d    r66.0<1;0>:d      r78.0<1;0>:d      81:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L7592                  L7592                
L5672:
        shl (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   1:w               {Compacted}
        shr (16|M0)              r8.0<1>:ud    r100.0<1;1,0>:ud  31:w              
        shl (16|M0)              r10.0<1>:d    r110.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L5904                  L5904                
L5776:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L5904                  L5968                
L5824:
        shr (16|M0)              r98.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r32.0<1>:d    0:w                              
        mov (16|M0)              r96.0<1>:f    r98.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r98.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5904                  L7064                
L5904:
        join (16|M0)                         L5968                                
L5920:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r110.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L5968                  L6984                
L5968:
        join (16|M0)                         L6984                                
L5984:
        add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r76.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r42.0<1>:d    -r100.0<1;1,0>:d  40:w               {Compacted}
(f0.1)  goto (16|M0)                         L6056                  L6056                
L6032:
        mov (16|M0)              r18.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6056                  L6168                
L6056:
        join (16|M0)                         L6168                                
L6072:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r98.0<1>:ud   r64.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r76.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r98.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r18.0<1>:f    r98.0<1;1,0>:f                   {Compacted,I@1}
L6168:
        join (16|M0)                         L6984                                
L6184:
        add (16|M0)              r104.0<1>:d   -r100.0<1;1,0>:d  38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r82.0<1>:d    r104.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (16|M0)                         L6248                  L6248                
L6224:
        mov (16|M0)              r98.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6248                  L6352                
L6248:
        join (16|M0)                         L6352                                
L6264:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r98.0<1>:ud   r64.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r82.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r82.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r98.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6352:
        join (16|M0)                         L6984                                
L6368:
        and (16|M0)   (ne)f1.1   r84.0<1>:d    r104.0<1;1,0>:d   63:w              
        and (16|M0)              r32.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L6456                  L6456                
L6408:
        mov (16|M0)              r90.0<1>:d    -1:w                              
        mov (16|M0)              r100.0<1>:d   -1:w                              
        goto (16|M0)                         L6456                  L6640                
L6456:
        join (16|M0)                         L6640                                
L6472:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r84.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L6576                  L6576                
L6504:
        add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r90.0<1>:d    0:w                              
        shl (16|M0)              r100.0<1>:d   r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6576                  L6640                
L6576:
        join (16|M0)                         L6640                                
L6592:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r100.0<1>:d   -1:w                              
        shl (16|M0)              r90.0<1>:d    r2.0<0;1,0>:w     r84.0<1;1,0>:d   {F@1}
L6640:
        join (16|M0)                         L6984                                
L6656:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r90.0<1;0>:ud     r5.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r64.0<1;0>:ud     r100.0<1;0>:ud    r5.2<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r80.0<1>:d    r42.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.0<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r16.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L6824                  L6824                
L6800:
        mov (16|M0)              r98.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6824                  L6928                
L6824:
        join (16|M0)                         L6928                                
L6840:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r80.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r98.0<1>:ud   r64.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r80.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r80.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r98.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6928:
        join (16|M0)                         L6984                                
L6944:
        mov (16|M0)              r96.0<1>:f    r98.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r98.0<1>:d    r18.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L6984                  L7064                
L6984:
        join (16|M0)                         L7064                                
L7000:
        shr (16|M0)              r98.0<1>:ud   r52.0<1;1,0>:ud   2:w              
        and (16|M0)              r32.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r96.0<1>:f    r98.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r98.0<1>:ud   r52.0<1;1,0>:ud   1:w               {F@1}
L7064:
        join (16|M0)                         L7592                                
L7080:
        shl (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r32.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r22.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r16.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r24.0<1>:d    r96.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L7200                  L7200                
L7168:
        mov (16|M0)              r12.0<1>:d    0:w                              
        goto (16|M0)                         L7200                  L7360                
L7200:
        join (16|M0)                         L7360                                
L7216:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L7280                  L7280                
L7248:
        mov (16|M0)              r12.0<1>:d    1:w                              
        goto (16|M0)                         L7280                  L7360                
L7280:
        join (16|M0)                         L7360                                
L7296:
        and (16|M0)   (ne)f1.0   null<1>:d     r96.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r12.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L7360:
        join (16|M0)                         L7592                                
L7376:
        add (16|M0)              r80.0<1>:d    r24.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r80.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r66.0<1;0>:d      r78.0<1;0>:d      82:w              
(f0.1)  sel (16|M0)              r66.0<1>:d    r2.0<1;1,0>:d     r86.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L7528                  L7528                
L7456:
(~f0.1) sel (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r50.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r42.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7528                  L8128                
L7528:
        join (16|M0)                         L7592                                
L7544:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r50.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r42.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7592                  L8128                
L7592:
        join (16|M0)                         L7904                                
L7608:
        and (16|M0)   (ne)f1.0   r54.0<1>:d    r78.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L7672                  L7672                
L7640:
        mov (16|M0)              r126.0<1>:d   -1:w                              
        goto (16|M0)                         L7672                  L7800                
L7672:
        join (16|M0)                         L7800                                
L7688:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r54.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (16|M0)                         L7752                  L7752                
L7720:
        mov (16|M0)              r126.0<1>:d   0:w                              
        goto (16|M0)                         L7752                  L7800                
L7752:
        join (16|M0)                         L7800                                
L7768:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r126.0<1>:d   r2.0<0;1,0>:w     r54.0<1;1,0>:d   {F@1}
L7800:
        join (16|M0)                         L7904                                
L7816:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r126.0<1;0>:ud    r5.2<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r8.0<1>:d     -r78.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r50.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r86.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r42.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7904                  L8128                
L7904:
        join (16|M0)                         L7968                                
L7920:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r42.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7968                  L8128                
L7968:
        join (16|M0)                         L8032                                
L7984:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r50.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (16|M0)              r42.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L8032                  L8128                
L8032:
        join (16|M0)                         L8096                                
L8048:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r50.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r42.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8096                  L8128                
L8096:
        join (16|M0)                         L8128                                
L8112:
        bfn.0xF8 (16|M0)         r42.0<1>:ud   r50.0<1;0>:ud     r5.4<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L8128:
        join (16|M0)                         L20872                                
L8144:
        mov (8|M0)               r2.0<1>:hf    r42.0<1;1,0>:f                   {I@2}
        mov (8|M8)               r2.8<1>:hf    r43.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:f     r2.0<1;1,0>:hf                   {F@2}
        mov (8|M8)               r9.0<1>:f     r2.8<1;1,0>:hf                   {F@2}
        and (16|M0)              r10.0<1>:d    r8.0<1;1,0>:d     2147483647:d               {A@1}
        sel (16|M0)   (lt)f0.0   r48.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r94.0<1>:ud   r48.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r98.0<1>:d    r48.0<1;1,0>:d    8388607:d              
        and (16|M0)              r26.0<1>:d    r94.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r26.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r12.0<1>:ud   r26.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r46.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f0.1) goto (16|M0)                         L8360                  L8360                
L8328:
        mov (16|M0)              r10.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L8360                  L14336                
L8360:
        join (16|M0)                         L14336                                
L8376:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    0:w              
        add (16|M0)              r76.0<1>:d    -r46.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    255:w              
        xor (16|M0)              r48.0<1>:d    r76.0<1;1,0>:d    r48.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L14304                  L14304                
L8448:
        or (16|M0)    (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    r98.0<1;1,0>:d  
(~f1.1) goto (16|M0)                         L8512                  L8512                
L8480:
        mov (16|M0)              r10.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L8512                  L14336                
L8512:
        join (16|M0)                         L14304                                
L8528:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    0:w              
        shr (16|M0)              r108.0<1>:ud  r76.0<1;1,0>:ud   23:w              
        add (16|M0)              r106.0<1>:d   r26.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r106.0<1>:d   -126:w                              
        add (16|M0)              r68.0<1>:d    r108.0<1;1,0>:d   r106.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r68.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L14240                  L14240                
L8624:
        or (16|M0)    (eq)f0.1   null<4>:b     r94.0<1;1,0>:d    r108.0<1;1,0>:d 
(f0.1)  goto (16|M0)                         L14176                  L14176                
L8656:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r45.7<1>:d    0:w                              
(f1.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r98.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r62.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r60.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r45.6<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r45.4<1>:d    0:w                              
L8760:
(W)     shl (1|M0)               r2.0<1>:d     r45.6<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r45.7<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r45.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r45.7<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r62.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.7<1>:ud    r45.6<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r45.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r45.7<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r5.7<0;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r45.5<0;1,0>:ud   0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r5.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r45.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r7.0<1>:uw    r6.0<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r6.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    r45.5<0;1,0>:ud  {Compacted,I@2}
        mov (16|M0)              r120.0<1>:d   r45.4<0;1,0>:d                  
        mov (16|M0)              r118.0<1>:d   r45.5<0;1,0>:d                  
        mov (16|M0)              r74.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r104.0<1>:f   r3.0<0;1,0>:f                    {Compacted,I@3}
(f1.0)  goto (16|M0)                         L9136                  L9136                
L9072:
(W)     mov (1|M0)               r45.6<1>:d    r5.7<0;1,0>:d                   
(W)     mov (1|M0)               r45.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r45.5<1>:d    r3.0<0;1,0>:d                   
(W)     jmpi                                 L8760                                
L9136:
        join (16|M0)                         L14176                                
L9152:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
        subb (8|M0)              r72.0<1>:ud   r2.0<0;1,0>:ud    r120.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r124.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r118.0<1>:ud    {F@1}
        subb (8|M8)              r73.0<1>:ud   r2.0<0;1,0>:ud    r121.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r122.0<1>:d   r108.0<1;0>:d     r106.0<1;0>:d     r72.0<1>:d       {I@1}
        add3 (16|M0)             r106.0<1>:d   r68.0<1;0>:d      r72.0<1;0>:d      -173:w              
        cmp (16|M0)   (gt)f1.1   null<1>:d     r106.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r125.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r119.0<1>:ud   
(f1.1)  goto (16|M0)                         L14112                  L14112                
L9304:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r106.0<1;1,0>:d   -127:w              
(f1.0)  goto (16|M0)                         L11792                  L11792                
L9336:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r106.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L11288                  L11288                
L9368:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@6}
        subb (8|M0)              r32.0<1>:ud   r2.0<0;1,0>:ud    r120.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r14.0<1>:d    r68.0<1;0>:d      r72.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r118.0<1>:ud    {F@1}
        subb (8|M8)              r33.0<1>:ud   r2.0<0;1,0>:ud    r121.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r32.0<1;1,0>:ud   r14.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r119.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L9592                  L9592                
L9536:
        add3 (16|M0)             r2.0<1>:d     r122.0<1;0>:d     -r32.0<1;0>:d     -23:w              
        mov (16|M0)              r72.0<1>:d    0:w                              
        shl (16|M0)              r74.0<1>:d    r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9592                  L11224                
L9592:
        join (16|M0)                         L11224                                
L9608:
        add3 (16|M0)             r114.0<1>:d   r32.0<1;0>:d      -r122.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r114.0<1;1,0>:d   2:w               {I@1}
(f1.1)  goto (16|M0)                         L9760                  L9760                
L9656:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   2:w              
(~f1.0) goto (16|M0)                         L9760                  L9808                
L9688:
        shr (16|M0)              r88.0<1>:ud   r62.0<1;1,0>:ud   1:w              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r124.0<1>:f   r88.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9760                  L10696                
L9760:
        join (16|M0)                         L9808                                
L9776:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r114.0<1;1,0>:d   1:w              
(f0.1)  goto (16|M0)                         L9808                  L10640                
L9808:
        join (16|M0)                         L10640                                
L9824:
        add3 (16|M0)             r2.0<1>:d     r32.0<1;0>:d      -r14.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r74.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L9896                  L9896                
L9872:
        mov (16|M0)              r16.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9896                  L10008                
L9896:
        join (16|M0)                         L10008                                
L9912:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r74.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r88.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r74.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   r74.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r88.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r16.0<1>:f    r88.0<1;1,0>:f                   {Compacted,I@1}
L10008:
        join (16|M0)                         L10640                                
L10024:
        add3 (16|M0)             r100.0<1>:d   r32.0<1;0>:d      -r14.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r72.0<1>:d    r100.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (16|M0)                         L10096                  L10096                
L10072:
        mov (16|M0)              r88.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10096                  L10200                
L10096:
        join (16|M0)                         L10200                                
L10112:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r88.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r72.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   r72.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r88.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10200:
        join (16|M0)                         L10640                                
L10216:
        and (16|M0)   (ne)f1.0   r76.0<1>:d    r100.0<1;1,0>:d   63:w              
        and (16|M0)              r30.0<1>:d    r88.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L10304                  L10304                
L10256:
        mov (16|M0)              r82.0<1>:d    -1:w                              
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L10304                  L10488                
L10304:
        join (16|M0)                         L10488                                
L10320:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L10424                  L10424                
L10352:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r82.0<1>:d    0:w                              
        shl (16|M0)              r88.0<1>:d    r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10424                  L10488                
L10424:
        join (16|M0)                         L10488                                
L10440:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r88.0<1>:d    -1:w                              
        shl (16|M0)              r82.0<1>:d    r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L10488:
        join (16|M0)                         L10640                                
L10504:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r5.2<0;0>:ud      r62.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r88.0<1;0>:ud     r5.2<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r124.0<1>:f   r16.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.0<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r12.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L10640                  L10696                
L10640:
        join (16|M0)                         L10696                                
L10656:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r124.0<1>:f   r62.0<1;1,0>:f                   {Compacted}
L10696:
        join (16|M0)                         L11224                                
L10712:
        and (16|M0)   (ne)f1.1   r70.0<1>:d    r114.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L10768                  L10768                
L10744:
        mov (16|M0)              r88.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10768                  L10872                
L10768:
        join (16|M0)                         L10872                                
L10784:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r88.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r70.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   r70.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r88.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10872:
        join (16|M0)                         L11224                                
L10888:
        shl (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r30.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r124.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r12.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r124.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (16|M0)                         L10992                  L10992                
L10960:
        mov (16|M0)              r10.0<1>:d    0:w                              
        goto (16|M0)                         L10992                  L11152                
L10992:
        join (16|M0)                         L11152                                
L11008:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r124.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L11072                  L11072                
L11040:
        mov (16|M0)              r10.0<1>:d    1:w                              
        goto (16|M0)                         L11072                  L11152                
L11072:
        join (16|M0)                         L11152                                
L11088:
        and (16|M0)   (ne)f0.1   null<1>:d     r88.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r124.0<1;1,0>:d   4:w              
(f0.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L11152:
        join (16|M0)                         L11224                                
L11168:
        add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r74.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r72.0<1>:d    r6.0<0;1,0>:d     0:w               {Compacted,F@1}
L11224:
        join (16|M0)                         L11288                                
L11240:
        and (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r10.0<1>:ud   r2.0<1;0>:ud      r72.0<1;0>:ud     r74.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L11288                  L14336                
L11288:
        join (16|M0)                         L11792                                
L11304:
        and (16|M0)   (ne)f1.0   r32.0<1>:d    r72.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L11384                  L11384                
L11336:
        mov (16|M0)              r68.0<1>:d    -1:w                              
        mov (16|M0)              r74.0<1>:d    -1:w                              
        goto (16|M0)                         L11384                  L11568                
L11384:
        join (16|M0)                         L11568                                
L11400:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r32.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L11504                  L11504                
L11432:
        add (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r68.0<1>:d    0:w                              
        shl (16|M0)              r74.0<1>:d    r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11504                  L11568                
L11504:
        join (16|M0)                         L11568                                
L11520:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r74.0<1>:d    -1:w                              
        shl (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     r32.0<1;1,0>:d   {F@1}
L11568:
        join (16|M0)                         L11792                                
L11584:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r5.2<0;0>:ud      r62.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r74.0<1;0>:ud     r5.2<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r48.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r106.0<1;1,0>:d   -150:w              
(f1.1)  goto (16|M0)                         L11736                  L11736                
L11696:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11736                  L14336                
L11736:
        join (16|M0)                         L11792                                
L11752:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11792                  L14336                
L11792:
        join (16|M0)                         L14112                                
L11808:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r80.0<1>:d    r68.0<1;0>:d      r72.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L13800                  L13800                
L11872:
        shl (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r104.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L12104                  L12104                
L11976:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r104.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L12104                  L12168                
L12024:
        shr (16|M0)              r88.0<1>:ud   r62.0<1;1,0>:ud   1:w              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r50.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:f   r88.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r88.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12104                  L13272                
L12104:
        join (16|M0)                         L12168                                
L12120:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r74.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L12168                  L13184                
L12168:
        join (16|M0)                         L13184                                
L12184:
        add (16|M0)              r2.0<1>:d     -r74.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r88.0<1>:d    r2.0<1;1,0>:d     63:w               {A@1}
        add (16|M0)              r52.0<1>:d    -r74.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L12256                  L12256                
L12232:
        mov (16|M0)              r126.0<1>:f   r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12256                  L12368                
L12256:
        join (16|M0)                         L12368                                
L12272:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r88.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r88.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {I@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r88.0<1;1,0>:d   32:w               {Compacted,I@1}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   r88.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r88.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r126.0<1>:f   r88.0<1;1,0>:f                   {Compacted,I@1}
L12368:
        join (16|M0)                         L13184                                
L12384:
        add (16|M0)              r108.0<1>:d   -r74.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r92.0<1>:d    r108.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L12448                  L12448                
L12424:
        mov (16|M0)              r88.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12448                  L12552                
L12448:
        join (16|M0)                         L12552                                
L12464:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r92.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r88.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r92.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   r92.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r88.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12552:
        join (16|M0)                         L13184                                
L12568:
        and (16|M0)   (ne)f0.1   r96.0<1>:d    r108.0<1;1,0>:d   63:w              
        and (16|M0)              r50.0<1>:d    r88.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L12656                  L12656                
L12608:
        mov (16|M0)              r116.0<1>:d   -1:w                              
        mov (16|M0)              r122.0<1>:d   -1:w                              
        goto (16|M0)                         L12656                  L12840                
L12656:
        join (16|M0)                         L12840                                
L12672:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L12776                  L12776                
L12704:
        add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r116.0<1>:d   0:w                              
        shl (16|M0)              r122.0<1>:d   r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12776                  L12840                
L12776:
        join (16|M0)                         L12840                                
L12792:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r122.0<1>:d   -1:w                              
        shl (16|M0)              r116.0<1>:d   r2.0<0;1,0>:w     r96.0<1;1,0>:d   {F@1}
L12840:
        join (16|M0)                         L13184                                
L12856:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r116.0<1;0>:ud    r5.2<0;0>:ud      r62.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r122.0<1;0>:ud    r5.2<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r90.0<1>:d    r52.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.0<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r22.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L13024                  L13024                
L13000:
        mov (16|M0)              r88.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13024                  L13128                
L13024:
        join (16|M0)                         L13128                                
L13040:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r90.0<1;1,0>:ud   0x20:uw             
(~f0.1) add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r88.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r90.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   r90.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r88.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L13128:
        join (16|M0)                         L13184                                
L13144:
        mov (16|M0)              r100.0<1>:f   r88.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r88.0<1>:d    r126.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L13184                  L13272                
L13184:
        join (16|M0)                         L13272                                
L13200:
        shr (16|M0)              r88.0<1>:ud   r62.0<1;1,0>:ud   2:w              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r50.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:f   r88.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r88.0<1>:ud   r62.0<1;1,0>:ud   1:w               {F@1}
L13272:
        join (16|M0)                         L13800                                
L13288:
        shl (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r50.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r66.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r22.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r32.0<1>:d    r100.0<1;1,0>:d   8388607:d              
(~f1.1) goto (16|M0)                         L13408                  L13408                
L13376:
        mov (16|M0)              r30.0<1>:d    0:w                              
        goto (16|M0)                         L13408                  L13568                
L13408:
        join (16|M0)                         L13568                                
L13424:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r66.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L13488                  L13488                
L13456:
        mov (16|M0)              r30.0<1>:d    1:w                              
        goto (16|M0)                         L13488                  L13568                
L13488:
        join (16|M0)                         L13568                                
L13504:
        and (16|M0)   (ne)f1.0   null<1>:d     r100.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r30.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L13568:
        join (16|M0)                         L13800                                
L13584:
        add (16|M0)              r88.0<1>:d    r32.0<1;1,0>:d    r30.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r88.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r68.0<1;0>:d      r72.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r86.0<1>:d    r2.0<1;1,0>:d     r80.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L13736                  L13736                
L13664:
(~f1.1) sel (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r48.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r86.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r10.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13736                  L14336                
L13736:
        join (16|M0)                         L13800                                
L13752:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r48.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13800                  L14336                
L13800:
        join (16|M0)                         L14112                                
L13816:
        and (16|M0)   (ne)f1.1   r70.0<1>:d    r72.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L13880                  L13880                
L13848:
        mov (16|M0)              r20.0<1>:d    -1:w                              
        goto (16|M0)                         L13880                  L14008                
L13880:
        join (16|M0)                         L14008                                
L13896:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.0)  goto (16|M0)                         L13960                  L13960                
L13928:
        mov (16|M0)              r20.0<1>:d    0:w                              
        goto (16|M0)                         L13960                  L14008                
L13960:
        join (16|M0)                         L14008                                
L13976:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r20.0<1>:d    r2.0<0;1,0>:w     r70.0<1;1,0>:d   {F@1}
L14008:
        join (16|M0)                         L14112                                
L14024:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r20.0<1;0>:ud     r5.2<0;0>:ud      r62.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r72.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r48.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r80.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r10.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14112                  L14336                
L14112:
        join (16|M0)                         L14176                                
L14128:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r48.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14176                  L14336                
L14176:
        join (16|M0)                         L14240                                
L14192:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r48.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L14240                  L14336                
L14240:
        join (16|M0)                         L14304                                
L14256:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r48.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14304                  L14336                
L14304:
        join (16|M0)                         L14336                                
L14320:
        bfn.0xF8 (16|M0)         r10.0<1>:ud   r48.0<1;0>:ud     r5.4<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L14336:
        join (16|M0)                         L20872                                
L14352:
        rnde (16|M0)             r64.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r92.0<1>:ud   r64.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r114.0<1>:d   r64.0<1;1,0>:d    8388607:d              
        and (16|M0)              r48.0<1>:d    r92.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (16|M0)                         L14464                  L14464                
L14432:
        mov (16|M0)              r8.0<1>:ud    0x7FC00000:ud                             
        goto (16|M0)                         L14464                  L20472                
L14464:
        join (16|M0)                         L20472                                
L14480:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r90.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r48.0<1;1,0>:d    255:w              
        and (16|M0)              r94.0<1>:d    r90.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r54.0<1>:d    r2.0<1;1,0>:d     r64.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L20440                  L20440                
L14592:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r48.0<1;1,0>:d    r114.0<1;1,0>:d  {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L14680                  L14680                
L14648:
        mov (16|M0)              r8.0<1>:ud    0x0:ud                             
        goto (16|M0)                         L14680                  L20472                
L14680:
        join (16|M0)                         L20440                                
L14696:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    0:w              
        add (16|M0)              r102.0<1>:d   r48.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r102.0<1>:d   -126:w                              
        add (16|M0)              r70.0<1>:d    r94.0<1;1,0>:d    r102.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r70.0<1;1,0>:d    254:w               {I@1}
(f0.1)  goto (16|M0)                         L20376                  L20376                
L14776:
        or (16|M0)    (eq)f1.1   null<4>:b     r92.0<1;1,0>:d    r90.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L20320                  L20320                
L14808:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r45.7<1>:d    0:w                              
(f1.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r114.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r58.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r56.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r45.6<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r45.4<1>:d    0:w                              
L14912:
(W)     shl (1|M0)               r2.0<1>:d     r45.6<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r45.7<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r45.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r45.7<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r58.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.7<1>:ud    r45.6<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r45.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r45.7<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r5.7<0;1,0>:d     r56.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r45.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r5.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r45.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r7.0<1>:uw    r6.0<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r6.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    r45.5<0;1,0>:ud  {Compacted,I@2}
        mov (16|M0)              r116.0<1>:d   r45.4<0;1,0>:d                  
        mov (16|M0)              r114.0<1>:d   r45.5<0;1,0>:d                  
        mov (16|M0)              r92.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r112.0<1>:f   r3.0<0;1,0>:f                    {Compacted,I@3}
(f0.1)  goto (16|M0)                         L15288                  L15288                
L15224:
(W)     mov (1|M0)               r45.6<1>:d    r5.7<0;1,0>:d                   
(W)     mov (1|M0)               r45.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r45.5<1>:d    r3.0<0;1,0>:d                   
(W)     jmpi                                 L14912                                
L15288:
        join (16|M0)                         L20320                                
L15304:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
        subb (8|M0)              r76.0<1>:ud   r2.0<0;1,0>:ud    r116.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r120.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r114.0<1>:ud    {F@1}
        subb (8|M8)              r77.0<1>:ud   r2.0<0;1,0>:ud    r117.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r104.0<1>:d   r70.0<1;0>:d      r76.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r104.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r121.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r115.0<1>:ud   
        add3 (16|M0)             r118.0<1>:d   r94.0<1;0>:d      r102.0<1;0>:d     r76.0<1>:d      
(f1.0)  goto (16|M0)                         L20256                  L20256                
L15456:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r104.0<1;1,0>:d   -127:w              
(f0.1)  goto (16|M0)                         L17936                  L17936                
L15488:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r104.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L17432                  L17432                
L15520:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r2.0<0;1,0>:ud    r116.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r10.0<1>:d    r70.0<1;0>:d      r76.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r114.0<1>:ud    {F@1}
        subb (8|M8)              r31.0<1>:ud   r2.0<0;1,0>:ud    r117.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r30.0<1;1,0>:ud   r10.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r115.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L15744                  L15744                
L15688:
        add3 (16|M0)             r2.0<1>:d     r118.0<1;0>:d     -r30.0<1;0>:d     -23:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        shl (16|M0)              r64.0<1>:d    r58.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L15744                  L17368                
L15744:
        join (16|M0)                         L17368                                
L15760:
        add3 (16|M0)             r110.0<1>:d   r30.0<1;0>:d      -r118.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r110.0<1;1,0>:d   2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L15904                  L15904                
L15800:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r110.0<1;1,0>:d   2:w              
(~f0.1) goto (16|M0)                         L15904                  L15952                
L15832:
        shr (16|M0)              r96.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:f   r96.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L15904                  L16840                
L15904:
        join (16|M0)                         L15952                                
L15920:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r110.0<1;1,0>:d   1:w              
(f1.1)  goto (16|M0)                         L15952                  L16784                
L15952:
        join (16|M0)                         L16784                                
L15968:
        add3 (16|M0)             r2.0<1>:d     r30.0<1;0>:d      -r10.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r68.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L16040                  L16040                
L16016:
        mov (16|M0)              r14.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16040                  L16152                
L16040:
        join (16|M0)                         L16152                                
L16056:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r68.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r96.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r68.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r68.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r14.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
L16152:
        join (16|M0)                         L16784                                
L16168:
        add3 (16|M0)             r98.0<1>:d    r30.0<1;0>:d      -r10.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r66.0<1>:d    r98.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L16240                  L16240                
L16216:
        mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16240                  L16344                
L16240:
        join (16|M0)                         L16344                                
L16256:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r66.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r96.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r66.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L16344:
        join (16|M0)                         L16784                                
L16360:
        and (16|M0)   (ne)f0.1   r62.0<1>:d    r98.0<1;1,0>:d    63:w              
        and (16|M0)              r28.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L16448                  L16448                
L16400:
        mov (16|M0)              r72.0<1>:d    -1:w                              
        mov (16|M0)              r80.0<1>:d    -1:w                              
        goto (16|M0)                         L16448                  L16632                
L16448:
        join (16|M0)                         L16632                                
L16464:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L16568                  L16568                
L16496:
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r72.0<1>:d    0:w                              
        shl (16|M0)              r80.0<1>:d    r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L16568                  L16632                
L16568:
        join (16|M0)                         L16632                                
L16584:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r80.0<1>:d    -1:w                              
        shl (16|M0)              r72.0<1>:d    r2.0<0;1,0>:w     r62.0<1;1,0>:d   {F@1}
L16632:
        join (16|M0)                         L16784                                
L16648:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r72.0<1;0>:ud     r5.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r80.0<1;0>:ud     r5.2<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r112.0<1>:f   r14.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.0<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r120.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L16784                  L16840                
L16784:
        join (16|M0)                         L16840                                
L16800:
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
L16840:
        join (16|M0)                         L17368                                
L16856:
        and (16|M0)   (ne)f1.0   r64.0<1>:d    r110.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L16912                  L16912                
L16888:
        mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16912                  L17016                
L16912:
        join (16|M0)                         L17016                                
L16928:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r64.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r96.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r64.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r64.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L17016:
        join (16|M0)                         L17368                                
L17032:
        shl (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r28.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r118.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r120.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (16|M0)                         L17136                  L17136                
L17104:
        mov (16|M0)              r122.0<1>:d   0:w                              
        goto (16|M0)                         L17136                  L17296                
L17136:
        join (16|M0)                         L17296                                
L17152:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r118.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L17216                  L17216                
L17184:
        mov (16|M0)              r122.0<1>:d   1:w                              
        goto (16|M0)                         L17216                  L17296                
L17216:
        join (16|M0)                         L17296                                
L17232:
        and (16|M0)   (ne)f0.1   null<1>:d     r96.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r118.0<1;1,0>:d   4:w              
(f0.1)  sel (16|M0)              r122.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L17296:
        join (16|M0)                         L17368                                
L17312:
        add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   r96.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r64.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r62.0<1>:d    r6.0<0;1,0>:d     0:w               {Compacted,F@1}
L17368:
        join (16|M0)                         L17432                                
L17384:
        and (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r8.0<1>:ud    r2.0<1;0>:ud      r62.0<1;0>:ud     r64.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L17432                  L20472                
L17432:
        join (16|M0)                         L17936                                
L17448:
        and (16|M0)   (ne)f0.1   r18.0<1>:d    r76.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L17528                  L17528                
L17480:
        mov (16|M0)              r28.0<1>:d    -1:w                              
        mov (16|M0)              r60.0<1>:d    -1:w                              
        goto (16|M0)                         L17528                  L17712                
L17528:
        join (16|M0)                         L17712                                
L17544:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L17648                  L17648                
L17576:
        add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r60.0<1>:d    r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L17648                  L17712                
L17648:
        join (16|M0)                         L17712                                
L17664:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r60.0<1>:d    -1:w                              
        shl (16|M0)              r28.0<1>:d    r2.0<0;1,0>:w     r18.0<1;1,0>:d   {F@1}
L17712:
        join (16|M0)                         L17936                                
L17728:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r28.0<1;0>:ud     r5.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r60.0<1;0>:ud     r5.2<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r54.0<1;1,0>:d    -1:w              
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   -150:w              
(f1.0)  goto (16|M0)                         L17880                  L17880                
L17840:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L17880                  L20472                
L17880:
        join (16|M0)                         L17936                                
L17896:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L17936                  L20472                
L17936:
        join (16|M0)                         L20256                                
L17952:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r82.0<1>:d    r70.0<1;0>:d      r76.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L19944                  L19944                
L18016:
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r92.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r112.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L18248                  L18248                
L18120:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r92.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L18248                  L18312                
L18168:
        shr (16|M0)              r96.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r46.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18248                  L19416                
L18248:
        join (16|M0)                         L18312                                
L18264:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L18312                  L19328                
L18312:
        join (16|M0)                         L19328                                
L18328:
        add (16|M0)              r2.0<1>:d     -r92.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r78.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r48.0<1>:d    -r92.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L18400                  L18400                
L18376:
        mov (16|M0)              r22.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18400                  L18512                
L18400:
        join (16|M0)                         L18512                                
L18416:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r96.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r78.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r22.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
L18512:
        join (16|M0)                         L19328                                
L18528:
        add (16|M0)              r106.0<1>:d   -r92.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r86.0<1>:d    r106.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (16|M0)                         L18592                  L18592                
L18568:
        mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18592                  L18696                
L18592:
        join (16|M0)                         L18696                                
L18608:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r96.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r86.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r86.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L18696:
        join (16|M0)                         L19328                                
L18712:
        and (16|M0)   (ne)f1.1   r86.0<1>:d    r106.0<1;1,0>:d   63:w              
        and (16|M0)              r46.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L18800                  L18800                
L18752:
        mov (16|M0)              r94.0<1>:d    -1:w                              
        mov (16|M0)              r108.0<1>:d   -1:w                              
        goto (16|M0)                         L18800                  L18984                
L18800:
        join (16|M0)                         L18984                                
L18816:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L18920                  L18920                
L18848:
        add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r94.0<1>:d    0:w                              
        shl (16|M0)              r108.0<1>:d   r6.0<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L18920                  L18984                
L18920:
        join (16|M0)                         L18984                                
L18936:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r108.0<1>:d   -1:w                              
        shl (16|M0)              r94.0<1>:d    r2.0<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L18984:
        join (16|M0)                         L19328                                
L19000:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r94.0<1;0>:ud     r5.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r108.0<1;0>:ud    r5.2<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r84.0<1>:d    r48.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.0<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r20.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L19168                  L19168                
L19144:
        mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19168                  L19272                
L19168:
        join (16|M0)                         L19272                                
L19184:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r84.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r96.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r84.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r84.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L19272:
        join (16|M0)                         L19328                                
L19288:
        mov (16|M0)              r98.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r96.0<1>:d    r22.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L19328                  L19416                
L19328:
        join (16|M0)                         L19416                                
L19344:
        shr (16|M0)              r96.0<1>:ud   r58.0<1;1,0>:ud   2:w              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r46.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r96.0<1>:ud   r58.0<1;1,0>:ud   1:w               {F@1}
L19416:
        join (16|M0)                         L19944                                
L19432:
        shl (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r46.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r26.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r20.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r28.0<1>:d    r98.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L19552                  L19552                
L19520:
        mov (16|M0)              r16.0<1>:d    0:w                              
        goto (16|M0)                         L19552                  L19712                
L19552:
        join (16|M0)                         L19712                                
L19568:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r26.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L19632                  L19632                
L19600:
        mov (16|M0)              r16.0<1>:d    1:w                              
        goto (16|M0)                         L19632                  L19712                
L19632:
        join (16|M0)                         L19712                                
L19648:
        and (16|M0)   (ne)f1.0   null<1>:d     r98.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r16.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L19712:
        join (16|M0)                         L19944                                
L19728:
        add (16|M0)              r84.0<1>:d    r28.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r84.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r70.0<1;0>:d      r76.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r68.0<1>:d    r2.0<1;1,0>:d     r82.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r68.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L19880                  L19880                
L19808:
(~f1.0) sel (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r54.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r8.0<1>:ud    r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L19880                  L20472                
L19880:
        join (16|M0)                         L19944                                
L19896:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r54.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19944                  L20472                
L19944:
        join (16|M0)                         L20256                                
L19960:
        and (16|M0)   (ne)f1.0   r60.0<1>:d    r76.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L20024                  L20024                
L19992:
        mov (16|M0)              r8.0<1>:d     -1:w                               {F@1}
        goto (16|M0)                         L20024                  L20152                
L20024:
        join (16|M0)                         L20152                                
L20040:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r60.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (16|M0)                         L20104                  L20104                
L20072:
        mov (16|M0)              r8.0<1>:d     0:w                              
        goto (16|M0)                         L20104                  L20152                
L20104:
        join (16|M0)                         L20152                                
L20120:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     r60.0<1;1,0>:d   {F@1}
L20152:
        join (16|M0)                         L20256                                
L20168:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r8.0<1;0>:ud      r5.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r76.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r54.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r82.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r8.0<1>:ud    r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L20256                  L20472                
L20256:
        join (16|M0)                         L20320                                
L20272:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r54.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L20320                  L20472                
L20320:
        join (16|M0)                         L20376                                
L20336:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r54.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L20376                  L20472                
L20376:
        join (16|M0)                         L20440                                
L20392:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r54.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (16|M0)              r8.0<1>:f     r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L20440                  L20472                
L20440:
        join (16|M0)                         L20472                                
L20456:
        bfn.0xF8 (16|M0)         r8.0<1>:ud    r54.0<1;0>:ud     r5.4<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L20472:
        join (16|M0)                         L20872                                
L20488:
        cmp (16|M0)   (lt)f1.1   null<1>:f     r42.0<1;1,0>:f    0xB3000000:f               {I@7}
        shr (16|M0)              r10.0<1>:ud   r40.0<1;1,0>:ud   31:w              
(f1.1)  sel (16|M0)              r2.0<1>:f     -r8.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,I@3}
        shl (16|M0)              r8.0<1>:d     r40.0<1;1,0>:d    1:w               {Compacted,F@1}
        addc (8|M0)              r14.0<1>:ud   r8.0<1;1,0>:ud    r5.5<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shl (16|M0)              r12.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r15.0<1>:ud   r9.0<1;1,0>:ud    r5.5<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                   
        mov (8|M8)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r112.0<1>:ud  r40.0<1;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
        add (8|M0)               r56.0<1>:ud   acc0.0<1;1,0>:ud  r38.0<1;1,0>:ud 
        addc (8|M8)              r113.0<1>:ud  r41.0<1;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@7}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r112.0<1;1,0>:ud  r4.6<0;1,0>:ud   {I@2}
        add (8|M8)               r57.0<1>:ud   acc0.0<1;1,0>:ud  r39.0<1;1,0>:ud 
        mov (16|M0)              r2.0<1>:ud    r7.0<1;1,0>:uw                   {A@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r56.0<1;1,0>:d    r4.7<0;1,0>:d    {I@2}
        add3 (8|M0)              r17.1<2>:ud   r16.0<1;0>:ud     r12.0<1;0>:ud     r5.6<0>:ud      
        add3 (8|M8)              r19.1<2>:ud   r22.0<1;0>:ud     r13.0<1;0>:ud     r5.6<0>:ud      
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r56.0<1;1,0>:ud   r4.7<0;1,0>:ud  
        mov (8|M0)               r17.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M8)               r19.0<2>:d    r15.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r17     r2:2    0x0            0x080E0B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(~f1.1) goto (16|M0)                         L20872                  L20872                
L20840:
(f1.1)  sel (16|M0)              r40.0<1>:d    r112.0<1;1,0>:d   r36.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r38.0<1>:d    r56.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L632                                
L20872:
        join (16|M0)                         L20888                                
L20888:
(W)     mov (8|M0)               r127.0<1>:f   r44.0<1;1,0>:f                   {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L20912:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x47:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
