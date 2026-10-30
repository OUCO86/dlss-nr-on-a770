L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r79.0<2>:b    r5.4<0;1,0>:b     1:w              
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r79.1<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.7<0;1,0>:d     r2.12<0;1,0>:uw 
        mach (1|M0)              r11.0<1>:d    r2.7<0;1,0>:d     r2.6<0;1,0>:d    {AccWrEn}
        mov (1|M0)               r79.6<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r79.7<1>:d    r9.0<0;0>:d       r7.0<0;0>:d       0:w               {I@5}
        mov (1|M0)               r14.1<1>:d    r11.0<0;1,0>:d                   {I@4}
        mov (1|M0)               r14.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        asr (1|M0)               r79.2<1>:d    r2.7<0;1,0>:d     31:w              
(W)     mov (2|M0)               r12.4<1>:ud   r79.6<1;1,0>:ud                  {I@3}
(W)     mov (2|M0)               r12.2<1>:ud   r14.0<1;1,0>:ud                  {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r11.0         L68368                                 {A@1}
L536:
(W)     mul (1|M0)               acc0.0<1>:d   r79.4<0;1,0>:d    r14.2<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r79.4<0;1,0>:d    r14.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r79.5<0;1,0>:d    r14.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r7.0<1>:d     r79.5<0;1,0>:d    r14.0<0;1,0>:d   {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r79.4<0;1,0>:ud   r14.0<0;1,0>:uw 
        mach (1|M0)              r9.0<1>:ud    r79.4<0;1,0>:ud   r14.0<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r80.5<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        subb (1|M0)              r10.0<1>:ud   r79.6<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r79.4<0;1,0>:d    r3.6<0;1,0>:uw  
        mach (1|M0)              r12.0<1>:d    r79.4<0;1,0>:d    r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r79.5<0;1,0>:d    r3.4<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:d    r79.5<0;1,0>:d    r3.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r79.4<0;1,0>:ud   r3.4<0;1,0>:uw  
        mach (1|M0)              r15.0<1>:ud   r79.4<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r80.1<1>:d    r10.0<0;1,0>:d                   {I@7}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.4<1>:d     r13.0<0;0>:d      r15.0<0;0>:d      r12.0<0>:d       {I@3}
        shl (1|M0)               r6.0<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@2}
        add3 (1|M0)              r80.2<1>:d    r79.7<0;0>:d      -r11.0<0;0>:d     -r1.3<0>:d      
        addc (1|M0)              r7.0<1>:ud    r3.0<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r5.6<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r79.4<0;1,0>:d    r3.14<0;1,0>:uw 
        mach (1|M0)              r9.0<1>:d     r79.4<0;1,0>:d    r3.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r79.5<0;1,0>:d    r3.12<0;1,0>:uw 
        mach (1|M0)              r10.0<1>:d    r79.5<0;1,0>:d    r3.6<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r79.4<0;1,0>:ud   r3.12<0;1,0>:uw 
        mach (1|M0)              r12.0<1>:ud   r79.4<0;1,0>:ud   r3.6<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r4.1<1>:d     r2.4<0;1,0>:d     1:w              
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r1.3<1>:d     r10.0<0;0>:d      r12.0<0;0>:d      r9.0<0>:d        {I@3}
        or (1|M0)                r6.1<1>:d     r4.1<0;1,0>:d     r5.6<0;1,0>:d    {I@3}
        shl (1|M0)               r5.6<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,I@3}
        shr (1|M0)               r2.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,I@4}
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,I@3}
        mov (1|M0)               r79.6<1>:d    r7.0<0;1,0>:d                   
        or (1|M0)                r5.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r80.4<1>:d    r80.1<0;1,0>:d                  
        add3 (1|M0)              r79.7<1>:d    r8.0<0;0>:d       r3.1<0;0>:d       r6.1<0>:d       
        mov (1|M0)               r3.6<1>:d     r6.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r3.7<1>:d     r7.0<0;0>:d       r3.5<0;0>:d       r5.7<0>:d        {I@4}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r3.2          L67792                                 {A@1}
L1232:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r4.0<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r3.0<0;1,0>:d     r2.14<0;1,0>:uw  {Compacted}
        mach (1|M0)              r80.0<1>:d    r3.0<0;1,0>:d     r2.7<0;1,0>:d    {Compacted}
        mov (16|M0)              r47.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r49.0<1>:ud   0x0:ud                             
        mov (16|M0)              r51.0<1>:ud   0x0:ud                             
        mov (16|M0)              r53.0<1>:ud   0x0:ud                             
        mov (16|M0)              r55.0<1>:ud   0x0:ud                             
        mov (16|M0)              r57.0<1>:ud   0x0:ud                             
        mov (16|M0)              r59.0<1>:ud   0x0:ud                             
        mov (16|M0)              r61.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r73.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r75.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r77.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r80.0<1>:d    r80.1<0;1,0>:d    -r80.0<0;1,0>:d  {Compacted,I@7}
(~f0.1.any16h) goto (16|M0)                  L2528                  L2528                
L1488:
(W)     mul (1|M0)               acc0.0<1>:d   r3.0<0;1,0>:d     r4.0<0;1,0>:uw   {Compacted}
        mach (1|M0)              r6.0<1>:d     r3.0<0;1,0>:d     r4.0<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r3.0<0;1,0>:d     r4.0<0;1,0>:uw   {Compacted}
        mov (1|M0)               r80.1<1>:d    r80.0<0;1,0>:d                   {I@5}
        asr (1|M0)               r80.2<1>:d    r80.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r80.6<1>:d    r4.0<0;1,0>:d                   
        mov (1|M0)               r80.7<1>:d    0:w                              
        mov (1|M0)               r80.4<2>:f    0.0:f                              
        mov (1|M0)               r80.5<2>:f    0.0:f                              
        mach (1|M0)              r81.0<1>:d    r3.0<0;1,0>:d     r4.0<0;1,0>:d    {Compacted}
        asr (1|M0)               r81.1<1>:d    r6.0<0;1,0>:d     31:w               {Compacted,I@7}
L1616:
        addc (1|M0)              r6.0<1>:ud    r80.4<0;1,0>:ud   r81.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r5.6<1>:d     r6.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r8.1<1>:d     r5.6<0;1,0>:d     1:w               {I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r80.5<0;0>:d      r81.1<0>:d       {A@1}
        addc (1|M0)              r9.0<1>:ud    r79.6<0;1,0>:ud   r8.1<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.4<1>:ud    r6.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r80.4<0;1,0>:d    r79.4<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:d     r80.4<0;1,0>:d    r79.2<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r80.5<0;1,0>:d    r79.2<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r80.5<0;1,0>:d    r79.1<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r80.4<0;1,0>:ud   r79.2<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:ud   r80.4<0;1,0>:ud   r79.1<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@7}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        addc (1|M0)              r14.0<1>:ud   r12.0<0;1,0>:ud   r80.1<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r8.0<1>:ud    r5.6<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      r7.0<0>:d       
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        or (1|M0)                r8.2<1>:d     r4.1<0;1,0>:d     r8.0<0;1,0>:d    {I@2}
        add3 (1|M0)              r2.4<1>:d     r15.0<0;0>:d      r1.3<0;0>:d       r80.2<0>:d       {I@2}
        shl (1|M0)               r8.0<1>:d     r14.0<0;1,0>:d    8:w               {Compacted}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        shr (1|M0)               r5.6<1>:ud    r14.0<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r4.1<1>:d     r2.4<0;1,0>:d     8:w               {I@3}
        shl (1|M0)               r9.0<1>:d     r8.0<0;1,0>:d     1:w               {Compacted,A@1}
        or (1|M0)                r8.1<1>:d     r4.1<0;1,0>:d     r5.6<0;1,0>:d    {I@2}
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r79.7<0;0>:d      r8.2<0>:d       
        shr (1|M0)               r8.3<1>:ud    r8.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r8.2<1>:d     r8.1<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,A@4}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        or (1|M0)                r9.1<1>:d     r8.2<0;1,0>:d     r8.3<0;1,0>:d    {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       r9.1<0>:d        {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r15      r11     null:0  0x0            0x0280E780           {$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r31      r10     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r23      r14     null:0  0x0            0x0280E780           {A@2,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r39      r8      null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r9.0<1>:ud    r80.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r5.6<1>:d     r9.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r5.6<0;1,0>:d     r80.6<0;1,0>:d   {I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r80.5<0;0>:d      0:w               {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r5.7<0;1,0>:d     r80.7<0;1,0>:d   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($2,$3,$4,$5,$6)                
        dpas.8x8 (8|M0)          r71:f         r71:f             r31:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r55:f         r55:f             r31:hf            r23.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r63:f         r63:f             r39:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r47:f         r47:f             r39:hf            r23.0:hf         {$2}
(f0.0.any16h) goto (16|M0)                   L2528                  L2528                
L2496:
(W)     mov (2|M0)               r80.4<1>:ud   r5.6<1;1,0>:ud                  
        goto.b (16|M0)                       L2528                  L1616                
L2528:
        join (16|M0)                         L2544                                
L2544:
(W)     mul (1|M0)               acc0.0<1>:d   r79.4<0;1,0>:d    r4.10<0;1,0>:uw 
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.7<0;1,0>:d     4:w              
        mach (1|M0)              r6.0<1>:d     r79.4<0;1,0>:d    r4.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r79.5<0;1,0>:d    r4.8<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:d     r79.5<0;1,0>:d    r4.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r79.4<0;1,0>:ud   r4.8<0;1,0>:uw  
        shl (1|M0)               r3.0<1>:d     r3.0<0;1,0>:d     4:w               {Compacted}
        mach (1|M0)              r9.0<1>:ud    r79.4<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r3.3<1>:uw    f1.1<0;1,0>:uw                  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.0<0;1,0>:d     r4.6<0;1,0>:d    {I@4}
        shl (1|M0)               r5.6<1>:d     r80.0<0;1,0>:d    4:w               {Compacted}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@5}
        addc (1|M0)              r10.0<1>:ud   r8.0<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@4}
        and (1|M0)               r6.0<1>:d     r4.7<0;1,0>:d     -3:w               {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r6.0<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r12.0<1>:ud   r10.0<0;1,0>:ud   r5.6<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r6.0<1>:uw    0xECA86420:uv                             
        and (1|M0)               r4.1<1>:d     r4.7<0;1,0>:d     -2:w              
        add3 (1|M0)              r2.4<1>:d     r11.0<0;0>:d      r1.3<0;0>:d       r4.3<0>:d        {I@5}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r7.0<4>:uw    r6.0<1;1,0>:uw                   {I@4}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r4.7<0;1,0>:d     2:w              
        mov (1|M0)               r3.4<1>:d     r5.0<0;1,0>:d                   
        mov (1|M0)               r3.5<1>:d     0:w                              
        mov (8|M0)               r119.0<1>:f   r71.0<1;1,0>:f                   {Compacted,$2.dst}
        mov (8|M0)               r118.0<1>:f   r63.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r96.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r95.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     8:w               {Compacted}
        mov (1|M0)               r3.2<1>:d     r12.0<0;1,0>:d                  
(W)     mov (1|M0)               r3.2<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.1<0;1,0>:d     2:w               {I@7}
        add3 (1|M0)              r3.3<1>:d     r13.0<0;0>:d      r2.4<0;0>:d       0:w               {I@7}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r79.0<0;1,0>:b    0:w              
        mov (8|M0)               r79.0<2>:ud   r7.0<4;1,0>:uw                   {I@7}
        mov (8|M0)               r79.1<2>:ud   0.0:f                              
(~f1.1.any16h) goto (16|M0)                  L6840                  L6840                
L3088:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L4848                  L4848                
L3120:
        mov (1|M0)               r1.2<1>:d     r3.0<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d     31:w               {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                              
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L3728:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0]<0;1,0>:f                 {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0]<0;1,0>:f                
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f              
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L4448                  L4448                
L4208:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L4448                  L4664                
L4448:
        join (16|M0)                         L4664                                
L4464:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L4664:
        join (16|M0)                         L4848                                
L4680:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L4848                  L6840                
L4816:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L4848                  L3728                
L4848:
        join (16|M0)                         L6840                                
L4864:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L5120                  L5120                
L4896:
        mov (8|M0)               r6.0<1>:hf    r71.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.nop                             null                             {Compacted,$9.src}
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r119.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L5120                  L5168                
L5120:
        join (16|M0)                         L5168                                
L5136:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L5168                  L5800                
L5168:
        join (16|M0)                         L5800                                
L5184:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r119.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r119.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($7,$9)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r119.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r119.0<1>:d   r119.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L5600                  L5600                
L5400:
        mov (8|M0)               r6.0<1>:hf    r63.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r118.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L5600:
        join (16|M0)                         L5800                                
L5616:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r118.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r118.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r118.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r118.0<1>:d   r118.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L5800                  L5896                
L5800:
        join (16|M0)                         L5896                                
L5816:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r71.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r63.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r119.0<1>:f   r1.8<1;1,0>:hf                   {F@2}
(f1.1.any16h) mov (8|M0)         r118.0<1>:f   r6.0<1;1,0>:hf                   {A@2}
L5896:
        join (16|M0)                         L6840                                
L5912:
        mov (1|M0)               r1.2<1>:d     r3.0<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d     31:w               {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.nop                             null                             {Compacted,$9.src}
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L6640                  L6640                
L6152:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r119.0<1;1,0>:f                 
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r118.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L6640                  L6840                
L6640:
        join (16|M0)                         L6840                                
L6656:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r119:1  0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r118:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L6840:
        join (16|M0)                         L6856                                
L6856:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L10784                  L10784                
L6904:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8704                  L8704                
L6936:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.nop                             null                             {Compacted,$9.src}
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$12.src}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L7592:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0]<0;1,0>:f                
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f              
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($0,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L8312                  L8312                
L8072:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L8312                  L8528                
L8312:
        join (16|M0)                         L8528                                
L8328:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$0} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L8528:
        join (16|M0)                         L8704                                
L8544:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$1.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L8704                  L10784                
L8672:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L8704                  L7592                
L8704:
        join (16|M0)                         L10784                                
L8720:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8992                  L8992                
L8752:
        mov (8|M0)               r6.0<1>:hf    r55.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r96.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L8992                  L9040                
L8992:
        join (16|M0)                         L9040                                
L9008:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9040                  L9680                
L9040:
        join (16|M0)                         L9680                                
L9056:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r96.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r96.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r96.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r96.0<1>:d    r96.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9480                  L9480                
L9272:
        mov (8|M0)               r6.0<1>:hf    r47.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r95.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L9480:
        join (16|M0)                         L9680                                
L9496:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r95.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r95.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r95.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r95.0<1>:d    r95.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L9680                  L9776                
L9680:
        join (16|M0)                         L9776                                
L9696:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r55.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r47.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r96.0<1>:f    r1.8<1;1,0>:hf                   {F@2}
(f1.1.any16h) mov (8|M0)         r95.0<1>:f    r6.0<1;1,0>:hf                   {A@2}
L9776:
        join (16|M0)                         L10784                                
L9792:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.nop                             null                             {Compacted,$12.src}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L10576                  L10576                
L10056:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r96.0<1;1,0>:f                  
        sync.allrd                           ($1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$11.src}
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r95.0<1;1,0>:f                  
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L10576                  L10784                
L10576:
        join (16|M0)                         L10784                                
L10592:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r96:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r95:1   0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L10784:
        join (16|M0)                         L10800                                
L10800:
        or (1|M0)                r3.7<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        mov (8|M0)               r112.0<1>:f   r72.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.7<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r111.0<1>:f   r64.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r94.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r93.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     9:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L14840                  L14840                
L10896:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12728                  L12728                
L10928:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        sync.allrd                           ($1,$2,$3,$10,$11)                
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                               {$8.src}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L11608:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,32]<0;1,0>:f              {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,32]<0;1,0>:f  -4.001953e+00:f            {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0,32]<0;1,0>:f             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,32]<0;1,0>:f  -4.001953e+00:f           
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L12328                  L12328                
L12088:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L12328                  L12544                
L12328:
        join (16|M0)                         L12544                                
L12344:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L12544:
        join (16|M0)                         L12728                                
L12560:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L12728                  L14840                
L12696:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L12728                  L11608                
L12728:
        join (16|M0)                         L14840                                
L12744:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13024                  L13024                
L12776:
        mov (8|M0)               r6.0<1>:hf    r72.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r112.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L13024                  L13072                
L13024:
        join (16|M0)                         L13072                                
L13040:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13072                  L13720                
L13072:
        join (16|M0)                         L13720                                
L13088:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r112.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r112.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r112.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r112.0<1>:d   r112.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13520                  L13520                
L13304:
        mov (8|M0)               r6.0<1>:hf    r64.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r111.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L13520:
        join (16|M0)                         L13720                                
L13536:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r111.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r111.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r111.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r111.0<1>:d   r111.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L13720                  L13816                
L13720:
        join (16|M0)                         L13816                                
L13736:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r72.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r64.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r112.0<1>:f   r1.8<1;1,0>:hf                   {F@2}
(f1.1.any16h) mov (8|M0)         r111.0<1>:f   r6.0<1;1,0>:hf                   {A@2}
L13816:
        join (16|M0)                         L14840                                
L13832:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$10)                
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L14640                  L14640                
L14128:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r112.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$1.src}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r111.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L14640                  L14840                
L14640:
        join (16|M0)                         L14840                                
L14656:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r112:1  0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r111:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L14840:
        join (16|M0)                         L14856                                
L14856:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L18872                  L18872                
L14904:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L16744                  L16744                
L14936:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($1,$2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L15632:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,32]<0;1,0>:f             
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,32]<0;1,0>:f  -4.001953e+00:f            {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,32]<0;1,0>:f             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,32]<0;1,0>:f  -4.001953e+00:f           
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($1,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L16352                  L16352                
L16112:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L16352                  L16568                
L16352:
        join (16|M0)                         L16568                                
L16368:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L16568:
        join (16|M0)                         L16744                                
L16584:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$0.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16744                  L18872                
L16712:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L16744                  L15632                
L16744:
        join (16|M0)                         L18872                                
L16760:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L17040                  L17040                
L16792:
        mov (8|M0)               r6.0<1>:hf    r56.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r94.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L17040                  L17088                
L17040:
        join (16|M0)                         L17088                                
L17056:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L17088                  L17736                
L17088:
        join (16|M0)                         L17736                                
L17104:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r94.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r94.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r94.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r94.0<1>:d    r94.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L17536                  L17536                
L17320:
        mov (8|M0)               r6.0<1>:hf    r48.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r93.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L17536:
        join (16|M0)                         L17736                                
L17552:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r93.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r93.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r93.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r93.0<1>:d    r93.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L17736                  L17832                
L17736:
        join (16|M0)                         L17832                                
L17752:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r56.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r48.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r94.0<1>:f    r1.8<1;1,0>:hf                   {F@2}
(f1.1.any16h) mov (8|M0)         r93.0<1>:f    r6.0<1;1,0>:hf                   {A@2}
L17832:
        join (16|M0)                         L18872                                
L17848:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L18664                  L18664                
L18136:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r94.0<1;1,0>:f                  
        sync.allrd                           ($0,$1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r93.0<1;1,0>:f                  
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L18664                  L18872                
L18664:
        join (16|M0)                         L18872                                
L18680:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r94:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r93:1   0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L18872:
        join (16|M0)                         L18888                                
L18888:
        or (1|M0)                r3.7<1>:d     r3.0<0;1,0>:d     2:w               {Compacted}
        mov (8|M0)               r110.0<1>:f   r73.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.7<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r109.0<1>:f   r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r92.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r91.0<1>:f    r49.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     10:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L22936                  L22936                
L18984:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L20816                  L20816                
L19016:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        sync.allrd                           ($2,$3,$10,$11)                
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                               {$8.src}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L19696:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,64]<0;1,0>:f              {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,64]<0;1,0>:f  -4.001953e+00:f            {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0,64]<0;1,0>:f             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,64]<0;1,0>:f  -4.001953e+00:f           
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L20416                  L20416                
L20176:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L20416                  L20632                
L20416:
        join (16|M0)                         L20632                                
L20432:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L20632:
        join (16|M0)                         L20816                                
L20648:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L20816                  L22936                
L20784:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L20816                  L19696                
L20816:
        join (16|M0)                         L22936                                
L20832:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L21112                  L21112                
L20864:
        mov (8|M0)               r6.0<1>:hf    r73.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r110.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L21112                  L21160                
L21112:
        join (16|M0)                         L21160                                
L21128:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L21160                  L21808                
L21160:
        join (16|M0)                         L21808                                
L21176:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r110.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r110.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r110.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r110.0<1>:d   r110.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L21608                  L21608                
L21392:
        mov (8|M0)               r6.0<1>:hf    r65.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r109.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L21608:
        join (16|M0)                         L21808                                
L21624:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r109.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r109.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r109.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r109.0<1>:d   r109.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L21808                  L21904                
L21808:
        join (16|M0)                         L21904                                
L21824:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r73.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r65.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r110.0<1>:f   r1.8<1;1,0>:hf                   {F@2}
(f1.1.any16h) mov (8|M0)         r109.0<1>:f   r6.0<1;1,0>:hf                   {A@2}
L21904:
        join (16|M0)                         L22936                                
L21920:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$10)                
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L22736                  L22736                
L22216:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r110.0<1;1,0>:f                 
        sync.allrd                           ($0,$1)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r109.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L22736                  L22936                
L22736:
        join (16|M0)                         L22936                                
L22752:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r110:1  0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r109:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L22936:
        join (16|M0)                         L22952                                
L22952:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L26968                  L26968                
L23000:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L24840                  L24840                
L23032:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L23728:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,64]<0;1,0>:f             
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,64]<0;1,0>:f  -4.001953e+00:f            {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,64]<0;1,0>:f             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,64]<0;1,0>:f  -4.001953e+00:f           
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($0,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L24448                  L24448                
L24208:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L24448                  L24664                
L24448:
        join (16|M0)                         L24664                                
L24464:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$0} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L24664:
        join (16|M0)                         L24840                                
L24680:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$1.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L24840                  L26968                
L24808:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L24840                  L23728                
L24840:
        join (16|M0)                         L26968                                
L24856:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L25136                  L25136                
L24888:
        mov (8|M0)               r6.0<1>:hf    r57.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r92.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L25136                  L25184                
L25136:
        join (16|M0)                         L25184                                
L25152:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L25184                  L25832                
L25184:
        join (16|M0)                         L25832                                
L25200:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r92.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r92.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r92.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r92.0<1>:d    r92.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L25632                  L25632                
L25416:
        mov (8|M0)               r6.0<1>:hf    r49.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r91.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L25632:
        join (16|M0)                         L25832                                
L25648:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r91.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r91.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r91.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r91.0<1>:d    r91.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L25832                  L25928                
L25832:
        join (16|M0)                         L25928                                
L25848:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r57.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r49.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r92.0<1>:f    r1.8<1;1,0>:hf                   {F@2}
(f1.1.any16h) mov (8|M0)         r91.0<1>:f    r6.0<1;1,0>:hf                   {A@2}
L25928:
        join (16|M0)                         L26968                                
L25944:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L26760                  L26760                
L26232:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r92.0<1;1,0>:f                  
        sync.allrd                           ($0,$1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r91.0<1;1,0>:f                  
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L26760                  L26968                
L26760:
        join (16|M0)                         L26968                                
L26776:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r92:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r91:1   0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L26968:
        join (16|M0)                         L26984                                
L26984:
        or (1|M0)                r3.7<1>:d     r3.0<0;1,0>:d     3:w               {Compacted}
        mov (8|M0)               r127.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.7<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r108.0<1>:f   r66.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r89.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r84.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     11:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L31064                  L31064                
L27080:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L28912                  L28912                
L27112:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        sync.allrd                           ($2,$3,$10,$11)                
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                               {$8.src}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L27792:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,96]<0;1,0>:f              {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,96]<0;1,0>:f  -4.001953e+00:f            {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0,96]<0;1,0>:f             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,96]<0;1,0>:f  -4.001953e+00:f           
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L28512                  L28512                
L28272:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L28512                  L28728                
L28512:
        join (16|M0)                         L28728                                
L28528:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L28728:
        join (16|M0)                         L28912                                
L28744:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L28912                  L31064                
L28880:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L28912                  L27792                
L28912:
        join (16|M0)                         L31064                                
L28928:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L29208                  L29208                
L28960:
        mov (8|M0)               r6.0<1>:hf    r74.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r127.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L29208                  L29256                
L29208:
        join (16|M0)                         L29256                                
L29224:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L29256                  L29904                
L29256:
        join (16|M0)                         L29904                                
L29272:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r127.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r127.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r100.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r100.0<1>:f   (abs)r100.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r100.0<1>:d   r100.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L29704                  L29704                
L29488:
        mov (8|M0)               r6.0<1>:hf    r66.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r108.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L29704:
        join (16|M0)                         L29904                                
L29720:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r108.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r108.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r104.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r104.0<1>:f   (abs)r104.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r104.0<1>:d   r104.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L29904                  L30032                
L29904:
        join (16|M0)                         L30032                                
L29920:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r74.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r66.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r100.0<1>:ud  r127.0<1;1,0>:ud                
(~f1.1.any16h) mov (8|M0)        r104.0<1>:ud  r108.0<1;1,0>:ud                
(f1.1.any16h) mov (8|M0)         r100.0<1>:f   r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r104.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L30032:
        join (16|M0)                         L31064                                
L30048:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$10)                
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L30864                  L30864                
L30344:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r100.0<1;1,0>:f                 
        sync.allrd                           ($0,$1)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r104.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L30864                  L31064                
L30864:
        join (16|M0)                         L31064                                
L30880:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r100:1  0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r104:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L31064:
        join (16|M0)                         L31080                                
L31080:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L35128                  L35128                
L31128:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L32968                  L32968                
L31160:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L31856:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,96]<0;1,0>:f             
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,96]<0;1,0>:f  -4.001953e+00:f            {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,96]<0;1,0>:f             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,96]<0;1,0>:f  -4.001953e+00:f           
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($1,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L32576                  L32576                
L32336:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L32576                  L32792                
L32576:
        join (16|M0)                         L32792                                
L32592:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L32792:
        join (16|M0)                         L32968                                
L32808:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$0.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L32968                  L35128                
L32936:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L32968                  L31856                
L32968:
        join (16|M0)                         L35128                                
L32984:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L33264                  L33264                
L33016:
        mov (8|M0)               r6.0<1>:hf    r58.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r89.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L33264                  L33312                
L33264:
        join (16|M0)                         L33312                                
L33280:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L33312                  L33960                
L33312:
        join (16|M0)                         L33960                                
L33328:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r89.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r89.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r117.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r117.0<1>:f   (abs)r117.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r117.0<1>:d   r117.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L33760                  L33760                
L33544:
        mov (8|M0)               r6.0<1>:hf    r50.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r84.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L33760:
        join (16|M0)                         L33960                                
L33776:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r84.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r84.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r123.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r123.0<1>:f   (abs)r123.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r123.0<1>:d   r123.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L33960                  L34088                
L33960:
        join (16|M0)                         L34088                                
L33976:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r58.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r50.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r117.0<1>:ud  r89.0<1;1,0>:ud                 
(~f1.1.any16h) mov (8|M0)        r123.0<1>:ud  r84.0<1;1,0>:ud                 
(f1.1.any16h) mov (8|M0)         r117.0<1>:f   r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r123.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L34088:
        join (16|M0)                         L35128                                
L34104:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L34920                  L34920                
L34392:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r117.0<1;1,0>:f                 
        sync.allrd                           ($0,$1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r123.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L34920                  L35128                
L34920:
        join (16|M0)                         L35128                                
L34936:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r117:1  0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r123:1  0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L35128:
        join (16|M0)                         L35144                                
L35144:
        or (1|M0)                r3.7<1>:d     r3.0<0;1,0>:d     4:w               {Compacted}
        mov (8|M0)               r126.0<1>:f   r75.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.7<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r107.0<1>:f   r67.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r88.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r83.0<1>:f    r51.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     12:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L39224                  L39224                
L35240:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L37072                  L37072                
L35272:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        sync.allrd                           ($2,$3,$10,$11)                
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                               {$8.src}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L35952:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,128]<0;1,0>:f             {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,128]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0,128]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,128]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L36672                  L36672                
L36432:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L36672                  L36888                
L36672:
        join (16|M0)                         L36888                                
L36688:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L36888:
        join (16|M0)                         L37072                                
L36904:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L37072                  L39224                
L37040:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L37072                  L35952                
L37072:
        join (16|M0)                         L39224                                
L37088:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L37368                  L37368                
L37120:
        mov (8|M0)               r6.0<1>:hf    r75.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r126.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L37368                  L37416                
L37368:
        join (16|M0)                         L37416                                
L37384:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L37416                  L38064                
L37416:
        join (16|M0)                         L38064                                
L37432:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r126.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r126.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r99.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r99.0<1>:f    (abs)r99.0<1;1,0>:f              {Compacted,F@1}
(f1.1)  or (8|M0)                r99.0<1>:d    r99.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L37864                  L37864                
L37648:
        mov (8|M0)               r6.0<1>:hf    r67.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r107.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L37864:
        join (16|M0)                         L38064                                
L37880:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r107.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r107.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r103.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r103.0<1>:f   (abs)r103.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r103.0<1>:d   r103.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L38064                  L38192                
L38064:
        join (16|M0)                         L38192                                
L38080:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r75.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r67.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r99.0<1>:ud   r126.0<1;1,0>:ud                
(~f1.1.any16h) mov (8|M0)        r103.0<1>:ud  r107.0<1;1,0>:ud                
(f1.1.any16h) mov (8|M0)         r99.0<1>:f    r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r103.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L38192:
        join (16|M0)                         L39224                                
L38208:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$10)                
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L39024                  L39024                
L38504:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r99.0<1;1,0>:f                  
        sync.allrd                           ($0,$1)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r103.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L39024                  L39224                
L39024:
        join (16|M0)                         L39224                                
L39040:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r99:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r103:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L39224:
        join (16|M0)                         L39240                                
L39240:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L43288                  L43288                
L39288:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L41128                  L41128                
L39320:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L40016:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,128]<0;1,0>:f            
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,128]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,128]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,128]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($0,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L40736                  L40736                
L40496:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L40736                  L40952                
L40736:
        join (16|M0)                         L40952                                
L40752:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$0} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L40952:
        join (16|M0)                         L41128                                
L40968:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$1.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L41128                  L43288                
L41096:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L41128                  L40016                
L41128:
        join (16|M0)                         L43288                                
L41144:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L41424                  L41424                
L41176:
        mov (8|M0)               r6.0<1>:hf    r59.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r88.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L41424                  L41472                
L41424:
        join (16|M0)                         L41472                                
L41440:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L41472                  L42120                
L41472:
        join (16|M0)                         L42120                                
L41488:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r88.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r88.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r116.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r116.0<1>:f   (abs)r116.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r116.0<1>:d   r116.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L41920                  L41920                
L41704:
        mov (8|M0)               r6.0<1>:hf    r51.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r83.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L41920:
        join (16|M0)                         L42120                                
L41936:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r83.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r83.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r122.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r122.0<1>:f   (abs)r122.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r122.0<1>:d   r122.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L42120                  L42248                
L42120:
        join (16|M0)                         L42248                                
L42136:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r59.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r51.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r116.0<1>:ud  r88.0<1;1,0>:ud                 
(~f1.1.any16h) mov (8|M0)        r122.0<1>:ud  r83.0<1;1,0>:ud                 
(f1.1.any16h) mov (8|M0)         r116.0<1>:f   r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r122.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L42248:
        join (16|M0)                         L43288                                
L42264:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L43080                  L43080                
L42552:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r116.0<1;1,0>:f                 
        sync.allrd                           ($0,$1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r122.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L43080                  L43288                
L43080:
        join (16|M0)                         L43288                                
L43096:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r116:1  0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r122:1  0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L43288:
        join (16|M0)                         L43304                                
L43304:
        or (1|M0)                r3.7<1>:d     r3.0<0;1,0>:d     5:w               {Compacted}
        mov (8|M0)               r125.0<1>:f   r76.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.7<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r106.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r87.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     13:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L47384                  L47384                
L43400:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L45232                  L45232                
L43432:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
        sync.allrd                           ($2,$3,$10,$11)                
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                               {$8.src}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@2}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r8.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L44112:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,160]<0;1,0>:f             {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,160]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0,160]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,160]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L44832                  L44832                
L44592:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L44832                  L45048                
L44832:
        join (16|M0)                         L45048                                
L44848:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L45048:
        join (16|M0)                         L45232                                
L45064:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L45232                  L47384                
L45200:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L45232                  L44112                
L45232:
        join (16|M0)                         L47384                                
L45248:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L45528                  L45528                
L45280:
        mov (8|M0)               r6.0<1>:hf    r76.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r125.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L45528                  L45576                
L45528:
        join (16|M0)                         L45576                                
L45544:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L45576                  L46224                
L45576:
        join (16|M0)                         L46224                                
L45592:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r125.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r125.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r98.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r98.0<1>:f    (abs)r98.0<1;1,0>:f              {Compacted,F@1}
(f1.1)  or (8|M0)                r98.0<1>:d    r98.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L46024                  L46024                
L45808:
        mov (8|M0)               r6.0<1>:hf    r68.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r106.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L46024:
        join (16|M0)                         L46224                                
L46040:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r106.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r106.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r102.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r102.0<1>:f   (abs)r102.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r102.0<1>:d   r102.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L46224                  L46352                
L46224:
        join (16|M0)                         L46352                                
L46240:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r76.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r68.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r98.0<1>:ud   r125.0<1;1,0>:ud                
(~f1.1.any16h) mov (8|M0)        r102.0<1>:ud  r106.0<1;1,0>:ud                
(f1.1.any16h) mov (8|M0)         r98.0<1>:f    r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r102.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L46352:
        join (16|M0)                         L47384                                
L46368:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@3}
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw  
        sync.allrd                           ($0,$1,$9,$15)                
        mach (1|M0)              r9.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r9.0<0;0>:d       r6.0<0>:d        {I@3}
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$10)                
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L47184                  L47184                
L46664:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r98.0<1;1,0>:f                  
        sync.allrd                           ($0,$1)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r102.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L47184                  L47384                
L47184:
        join (16|M0)                         L47384                                
L47200:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r98:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r102:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L47384:
        join (16|M0)                         L47400                                
L47400:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L51432                  L51432                
L47448:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L49280                  L49280                
L47480:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@6}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r8.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r7.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r6.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L48168:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,160]<0;1,0>:f            
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,160]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,160]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,160]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($1,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L48888                  L48888                
L48648:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L48888                  L49104                
L48888:
        join (16|M0)                         L49104                                
L48904:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L49104:
        join (16|M0)                         L49280                                
L49120:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$0.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L49280                  L51432                
L49248:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L49280                  L48168                
L49280:
        join (16|M0)                         L51432                                
L49296:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L49576                  L49576                
L49328:
        mov (8|M0)               r6.0<1>:hf    r60.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r87.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L49576                  L49624                
L49576:
        join (16|M0)                         L49624                                
L49592:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L49624                  L50272                
L49624:
        join (16|M0)                         L50272                                
L49640:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r87.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r87.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r115.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r115.0<1>:f   (abs)r115.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r115.0<1>:d   r115.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L50072                  L50072                
L49856:
        mov (8|M0)               r6.0<1>:hf    r52.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r82.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L50072:
        join (16|M0)                         L50272                                
L50088:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r82.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r82.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r121.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r121.0<1>:f   (abs)r121.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r121.0<1>:d   r121.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L50272                  L50400                
L50272:
        join (16|M0)                         L50400                                
L50288:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r60.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r52.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r115.0<1>:ud  r87.0<1;1,0>:ud                 
(~f1.1.any16h) mov (8|M0)        r121.0<1>:ud  r82.0<1;1,0>:ud                 
(f1.1.any16h) mov (8|M0)         r115.0<1>:f   r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r121.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L50400:
        join (16|M0)                         L51432                                
L50416:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@7}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L51224                  L51224                
L50696:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r115.0<1;1,0>:f                 
        sync.allrd                           ($0,$1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r121.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L51224                  L51432                
L51224:
        join (16|M0)                         L51432                                
L51240:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r115:1  0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r121:1  0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L51432:
        join (16|M0)                         L51448                                
L51448:
        or (1|M0)                r3.7<1>:d     r3.0<0;1,0>:d     6:w               {Compacted}
        mov (8|M0)               r124.0<1>:f   r77.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.7<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r105.0<1>:f   r69.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r86.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r81.0<1>:f    r53.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     14:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L55512                  L55512                
L51544:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L53368                  L53368                
L51576:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
        sync.allrd                           ($0,$1,$2,$3,$10,$11)                
        mov (1|M0)               r13.2<1>:f    0xBD650000:f                               {$8.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@6}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r15.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.3<1>:d    r7.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r13.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r13.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.1<1>:f    0x3EE50000:f                              
        mov (1|M0)               r15.2<2>:f    0.0:f                              
        mov (1|M0)               r15.3<2>:f    0.0:f                              
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r15.6<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r15.4<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:f    0x3F650000:f                               {I@6}
        add3 (1|M0)              r15.7<1>:d    r6.0<0;0>:d       r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.5<1>:d    r12.0<0;0>:d      r13.4<0;0>:d      0:w               {I@5}
L52248:
        shl (1|M0)               r1.3<1>:w     r3.14<0;1,0>:w    2:w               {I@5}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,192]<0;1,0>:f             {$8.src}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,192]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.10<2>:hf  r[a0.0,192]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,192]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$9)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.1<0;0>:f      r13.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r13.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r13.10<1>:hf  r13.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r13.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r13.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L52968                  L52968                
L52728:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r15.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.1<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L52968                  L53184                
L52968:
        join (16|M0)                         L53184                                
L52984:
        shl (1|M0)               r1.4<1>:d     r15.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r15.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r13.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r15.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r13.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r15.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L53184:
        join (16|M0)                         L53368                                
L53200:
        addc (1|M0)              r6.0<1>:ud    r15.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r15.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L53368                  L55512                
L53336:
(W)     mov (2|M0)               r15.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L53368                  L52248                
L53368:
        join (16|M0)                         L55512                                
L53384:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L53664                  L53664                
L53416:
        mov (8|M0)               r6.0<1>:hf    r77.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r124.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L53664                  L53712                
L53664:
        join (16|M0)                         L53712                                
L53680:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L53712                  L54360                
L53712:
        join (16|M0)                         L54360                                
L53728:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r124.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r124.0<1;1,0>:f   0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r97.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r97.0<1>:f    (abs)r97.0<1;1,0>:f              {Compacted,F@1}
(f1.1)  or (8|M0)                r97.0<1>:d    r97.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L54160                  L54160                
L53944:
        mov (8|M0)               r6.0<1>:hf    r69.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r105.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L54160:
        join (16|M0)                         L54360                                
L54176:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r105.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r105.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r101.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r101.0<1>:f   (abs)r101.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r101.0<1>:d   r101.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L54360                  L54488                
L54360:
        join (16|M0)                         L54488                                
L54376:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r77.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r69.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r97.0<1>:ud   r124.0<1;1,0>:ud                
(~f1.1.any16h) mov (8|M0)        r101.0<1>:ud  r105.0<1;1,0>:ud                
(f1.1.any16h) mov (8|M0)         r97.0<1>:f    r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r101.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L54488:
        join (16|M0)                         L55512                                
L54504:
        mov (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@7}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$10)                
        mov (1|M0)               r4.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f1.1.any16h) goto (16|M0)                   L55312                  L55312                
L54792:
        shl (1|M0)               r2.3<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r97.0<1;1,0>:f                  
        sync.allrd                           ($0,$1)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r101.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L55312                  L55512                
L55312:
        join (16|M0)                         L55512                                
L55328:
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r4.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r97:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r101:1  0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L55512:
        join (16|M0)                         L55528                                
L55528:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L59560                  L59560                
L55576:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L57408                  L57408                
L55608:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@6}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r8.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r7.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r6.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L56296:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,192]<0;1,0>:f            
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,192]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,192]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,192]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($0,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L57016                  L57016                
L56776:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L57016                  L57232                
L57016:
        join (16|M0)                         L57232                                
L57032:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$0} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L57232:
        join (16|M0)                         L57408                                
L57248:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$1.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L57408                  L59560                
L57376:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L57408                  L56296                
L57408:
        join (16|M0)                         L59560                                
L57424:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L57704                  L57704                
L57456:
        mov (8|M0)               r6.0<1>:hf    r61.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r86.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L57704                  L57752                
L57704:
        join (16|M0)                         L57752                                
L57720:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L57752                  L58400                
L57752:
        join (16|M0)                         L58400                                
L57768:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r86.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r86.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r114.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r114.0<1>:f   (abs)r114.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r114.0<1>:d   r114.0<1;1,0>:d   -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L58200                  L58200                
L57984:
        mov (8|M0)               r6.0<1>:hf    r53.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r81.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L58200:
        join (16|M0)                         L58400                                
L58216:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r81.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r81.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r120.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r120.0<1>:f   (abs)r120.0<1;1,0>:f             {Compacted,F@1}
(f1.1)  or (8|M0)                r120.0<1>:d   r120.0<1;1,0>:d   -2147483648:d               {F@1}
        goto (16|M0)                         L58400                  L58528                
L58400:
        join (16|M0)                         L58528                                
L58416:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r61.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r53.0<1;1,0>:f                  
(~f1.1.any16h) mov (8|M0)        r114.0<1>:ud  r86.0<1;1,0>:ud                 
(~f1.1.any16h) mov (8|M0)        r120.0<1>:ud  r81.0<1;1,0>:ud                 
(f1.1.any16h) mov (8|M0)         r114.0<1>:f   r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r120.0<1>:f   r6.0<1;1,0>:hf                   {A@1}
L58528:
        join (16|M0)                         L59560                                
L58544:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@7}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L59352                  L59352                
L58824:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r114.0<1;1,0>:f                 
        sync.allrd                           ($0,$1,$2,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:hf    r120.0<1;1,0>:f                 
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                   {F@2}
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L59352                  L59560                
L59352:
        join (16|M0)                         L59560                                
L59368:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r114:1  0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r120:1  0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L59560:
        join (16|M0)                         L59576                                
L59576:
        or (1|M0)                r3.6<1>:d     r3.0<0;1,0>:d     7:w               {Compacted}
        mov (8|M0)               r2.0<1>:f     r78.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.6<0;1,0>:d     r4.6<0;1,0>:d    {I@1}
        mov (8|M0)               r113.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r90.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r85.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r3.0<1>:d     r3.0<0;1,0>:d     15:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L63696                  L63696                
L59672:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L61504                  L61504                
L59704:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r15.2<1>:f    0xBD650000:f                              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@6}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {A@2}
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        sync.allrd                           ($2,$8,$10)                
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.6<1>:d     r12.0<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        addc (1|M0)              r8.0<1>:ud    r3.6<0;1,0>:ud    0x10:ud              {AccWrEn,I@2}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r15.3<1>:d    r7.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r15.3<0;1,0>:ud   0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.7<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r15.4<1>:d    r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.1<1>:f    0x3EE50000:f                              
        mov (1|M0)               r15.0<1>:f    0x3F650000:f                              
        mov (1|M0)               r13.2<2>:f    0.0:f                              
        mov (1|M0)               r13.3<2>:f    0.0:f                              
        mov (1|M0)               r13.6<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r13.4<1>:d    r11.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r13.0<1>:d    0:w                              
        add3 (1|M0)              r13.7<1>:d    r6.0<0;0>:d       r3.7<0;0>:d       0:w               {I@6}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r15.4<0;0>:d      0:w               {I@5}
L60392:
        shl (1|M0)               r1.3<1>:w     r13.0<0;1,0>:w    2:w               {I@3}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r15.12<2>:hf  r[a0.0,224]<0;1,0>:f            
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,224]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r15.12<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r15.10<2>:hf  r[a0.0,224]<0;1,0>:f            
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f               {A@1}
        mov (1|M0)               r7.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,224]<0;1,0>:f  -4.001953e+00:f          
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {A@1}
        mad (1|M0)               r2.4<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r2.3<0>:f  
        sync.allrd                           ($7,$8)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r15.1<0;0>:f      r15.2<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r8.0<1>:f     r15.0<0;0>:f      r5.6<0;0>:f       r8.0<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                   
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r15.12<1>:hf  r15.12<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mul (1|M0)               r15.10<1>:hf  r15.10<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r14.0<1>:f    r15.12<0;1,0>:hf                 {F@2}
        mov (1|M0)               r4.0<1>:f     r15.10<0;1,0>:hf                 {F@2}
(f1.1.any16h) goto (16|M0)                   L61112                  L61112                
L60872:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r15.12<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r15.10<0;1,0>:uw                 {F@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r13.7<0;0>:d      r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L61112                  L61328                
L61112:
        join (16|M0)                         L61328                                
L61128:
        shl (1|M0)               r1.4<1>:d     r13.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r15.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.4<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.4<0;0>:d      r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.5<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$8} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r4:1    0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L61328:
        join (16|M0)                         L61504                                
L61344:
        addc (1|M0)              r6.0<1>:ud    r13.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$10.src}
        add (1|M0)               r13.0<1>:d    r13.0<0;1,0>:d    1:w               {Compacted,$9.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r7.0<0;0>:d       r13.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.0<0;1,0>:d     8:w               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L61504                  L63696                
L61472:
(W)     mov (2|M0)               r13.2<1>:ud   r4.0<1;1,0>:ud                  
        goto.b (16|M0)                       L61504                  L60392                
L61504:
        join (16|M0)                         L63696                                
L61520:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L61800                  L61800                
L61552:
        mov (8|M0)               r6.0<1>:hf    r78.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($0,$1,$5,$8,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r2.0<1>:f     r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L61800                  L61848                
L61800:
        join (16|M0)                         L61848                                
L61816:
(W)     and (1|M0)               f1.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L61848                  L62512                
L61848:
        join (16|M0)                         L62512                                
L61864:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r2.0<1;1,0>:f  448.0:f             {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r2.0<1;1,0>:f     0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        sync.allrd                           ($0,$1,$5,$7,$8,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$2.src}
        mul (8|M0)               r12.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted,$10.src}
        mov (8|M0)               r12.0<1>:f    (abs)r12.0<1;1,0>:f              {Compacted,F@1}
(f1.1)  or (8|M0)                r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L62304                  L62304                
L62088:
        mov (8|M0)               r6.0<1>:hf    r70.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                             
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r113.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
L62304:
        join (16|M0)                         L62512                                
L62320:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r113.0<1;1,0>:f  448.0:f           {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r113.0<1;1,0>:f   0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$3.src}
        mul (8|M0)               r13.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted,$11.src}
        mov (8|M0)               r13.0<1>:f    (abs)r13.0<1;1,0>:f              {Compacted,F@1}
(f1.1)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L62512                  L62664                
L62512:
        join (16|M0)                         L62664                                
L62528:
(W)     and (1|M0)               f1.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f1.1.any16h) mov (8|M0)         r1.8<1>:hf    r78.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r70.0<1;1,0>:f                  
        sync.allrd                           ($0,$1,$2,$9,$10)                
(~f1.1.any16h) mov (8|M0)        r12.0<1>:ud   r2.0<1;1,0>:ud                   {$8.src}
        sync.nop                             null                             {Compacted,$3.src}
(~f1.1.any16h) mov (8|M0)        r13.0<1>:ud   r113.0<1;1,0>:ud                 {$11.src}
(f1.1.any16h) mov (8|M0)         r12.0<1>:f    r1.8<1;1,0>:hf                   {A@2}
(f1.1.any16h) mov (8|M0)         r13.0<1>:f    r6.0<1;1,0>:hf                   {A@1}
L62664:
        join (16|M0)                         L63696                                
L62680:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$8,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@7}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.6<1>:d     r10.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r3.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@2}
(f1.1.any16h) goto (16|M0)                   L63488                  L63488                
L62960:
        shl (1|M0)               r2.3<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r1.8<1>:hf    r12.0<1;1,0>:f                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        mov (8|M0)               r6.0<1>:hf    r13.0<1;1,0>:f                  
        sync.allrd                           ($0,$1,$2,$8,$9,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,F@2}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {F@1}
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d      
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                  
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                  
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L63488                  L63696                
L63488:
        join (16|M0)                         L63696                                
L63504:
        shl (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r3.7<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r12:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r13:1   0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L63696:
        join (16|M0)                         L63712                                
L63712:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.0<0;1,0>:d     r4.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L67720                  L67720                
L63760:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L65568                  L65568                
L63792:
        mov (1|M0)               r1.2<1>:d     r3.0<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d     31:w               {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
        sync.allrd                           ($0,$1,$2,$3,$9,$10,$11,$14)                
        mov (1|M0)               r13.5<1>:f    0xBD650000:f                               {$8.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($5,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@6}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        shl (1|M0)               r10.2<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        addc (1|M0)              r12.0<1>:ud   r5.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r3.0<1>:f     r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    0x10:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.7<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r10.1<1>:ud   r10.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r5.7<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     2:w              
        mov (1|M0)               r3.4<1>:d     r7.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     r10.1<0;1,0>:d   {I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        addc (1|M0)              r11.0<1>:ud   r3.4<0;1,0>:ud    0x20:ud              {AccWrEn,I@4}
        add3 (1|M0)              r3.1<1>:d     r13.0<0;0>:d      r5.3<0;0>:d       r10.3<0>:d       {I@3}
        add3 (1|M0)              r3.5<1>:d     r9.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.4<1>:f    0x3EE50000:f                              
        mov (1|M0)               r3.7<1>:f     0x3F650000:f                              
        mov (1|M0)               r13.1<2>:f    0.0:f                              
        mov (1|M0)               r3.6<1>:d     0:w                              
        mov (1|M0)               r3.2<1>:d     r8.0<0;1,0>:d                   
        mov (1|M0)               r13.2<1>:d    r11.0<0;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<2>:f    0.0:f                               {I@6}
        add3 (1|M0)              r3.3<1>:d     r6.0<0;0>:d       r3.1<0;0>:d       0:w              
        add3 (1|M0)              r13.3<1>:d    r12.0<0;0>:d      r3.5<0;0>:d       0:w               {I@5}
L64448:
        shl (1|M0)               r1.3<1>:w     r3.12<0;1,0>:w    2:w               {I@5}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r13.14<2>:hf  r[a0.0,224]<0;1,0>:f            
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0,224]<0;1,0>:f  -4.001953e+00:f           {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r1.2<1>:f     r13.14<0;1,0>:hf                 {F@2}
        sel (1|M0)    (lt)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r13.12<2>:hf  r[a0.0,224]<0;1,0>:f            
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0,224]<0;1,0>:f  -4.001953e+00:f           {A@1}
        mov (1|M0)               r7.0<1>:f     r13.12<0;1,0>:hf                 {A@1}
(~f0.0) sel (1|M0)               r2.3<1>:f     r1.2<0;1,0>:f     -4.0:f              
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     4.0:f               {F@2}
        mad (1|M0)               r2.4<1>:f     r13.4<0;0>:f      r13.5<0;0>:f      (abs)r2.3<0>:f   {F@2}
        sync.allrd                           ($1,$15)                
(~f1.1) sel (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f     -4.0:f               {F@2}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.1<1>:f     r13.4<0;0>:f      r13.5<0;0>:f      (abs)r8.0<0>:f   {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r4.2<2>:hf    r8.1<0;1,0>:f                    {F@2}
        mad (1|M0)               r2.3<1>:f     r3.7<0;0>:f       r5.6<0;0>:f       r2.3<0>:f        {F@2}
        mov (1|M0)               r5.6<1>:f     r4.2<0;1,0>:hf                   {F@2}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@2}
        mad (1|M0)               r8.0<1>:f     r3.7<0;0>:f       r5.6<0;0>:f       r8.0<0>:f        {F@2}
        mul (1|M0)               r13.14<1>:hf  r13.14<0;1,0>:hf  r6.0<0;1,0>:hf   {F@2}
        mov (1|M0)               r2.6<2>:hf    r8.0<0;1,0>:f                    {F@2}
        mov (1|M0)               r14.0<1>:f    r13.14<0;1,0>:hf                 {F@2}
        mul (1|M0)               r13.12<1>:hf  r13.12<0;1,0>:hf  r2.6<0;1,0>:hf   {F@2}
        mov (1|M0)               r2.0<1>:f     r13.12<0;1,0>:hf                 {F@1}
(f0.1.any16h) goto (16|M0)                   L65160                  L65160                
L64928:
        shl (1|M0)               r1.4<1>:d     r13.0<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r13.1<0;1,0>:d    1:w              
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r3.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:d    r13.14<0;1,0>:uw                
        mov (1|M0)               r14.0<1>:d    r13.12<0;1,0>:uw                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r3.3<0;0>:d       r1.5<0>:d        {I@4}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (1|M0)          null     r12     r14:1   0x0            0x04000B84           {A@1,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L65160                  L65368                
L65160:
        join (16|M0)                         L65368                                
L65176:
        shl (1|M0)               r1.4<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r13.1<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.2<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r13.3<0;0>:d      r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@2,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r2:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
L65368:
        join (16|M0)                         L65568                                
L65384:
        addc (1|M0)              r6.0<1>:ud    r13.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r3.6<1>:d     r3.6<0;1,0>:d     1:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($0,$2)                
        mov (1|M0)               r13.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r13.7<1>:d    r7.0<0;0>:d       r13.1<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r13.7<0;1,0>:d    0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r13.6<0;1,0>:d    8:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L65568                  L67720                
L65536:
(W)     mov (2|M0)               r13.0<1>:ud   r13.6<1;1,0>:ud                 
        goto.b (16|M0)                       L65568                  L64448                
L65568:
        join (16|M0)                         L67720                                
L65584:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L65864                  L65864                
L65616:
        mov (8|M0)               r6.0<1>:hf    r62.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                              {$2.src}
        sync.allrd                           ($0,$1,$5,$8,$9,$13,$15)                
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted,$7.src}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r90.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        goto (16|M0)                         L65864                  L65912                
L65864:
        join (16|M0)                         L65912                                
L65880:
(W)     and (1|M0)               f0.1<1>:uw    r3.2<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L65912                  L66568                
L65912:
        join (16|M0)                         L66568                                
L65928:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r90.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r90.0<1;1,0>:f    0.0:f               {A@2}
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@2}
        sync.allrd                           ($0,$1,$5,$7,$8,$9,$13,$15)                
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$3.src}
        mul (8|M0)               r14.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted,$11.src}
        mov (8|M0)               r14.0<1>:f    (abs)r14.0<1;1,0>:f              {Compacted,F@1}
(f0.1)  or (8|M0)                r14.0<1>:d    r14.0<1;1,0>:d    -2147483648:d               {F@1}
(~f1.1.any16h) goto (16|M0)                  L66368                  L66368                
L66152:
        mov (8|M0)               r6.0<1>:hf    r54.0<1;1,0>:f                  
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        mov (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:hf                   {F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -4.0:f               {Compacted}
        mov (1|M0)               r2.3<1>:ud    0x3F650000:ud                              {$2.src}
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (8|M0)               r9.0<1>:f     r1.3<0;0>:f       (abs)r8.0<1;0>:f  r1.2<0>:f        {A@1}
        mov (8|M0)               r6.8<1>:hf    r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               acc0.0<1>:f   r6.8<1;1,0>:hf                   {F@1}
        mad (8|M0)               r8.0<1>:f     r2.3<0;0>:f       acc0.0<1;0>:f     r8.0<1>:f        {Compacted,I@1}
        sync.allrd                           ($6,$14)                
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        mul (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:hf    r11.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r85.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
L66368:
        join (16|M0)                         L66568                                
L66384:
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r85.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r85.0<1;1,0>:f    0.0:f              
        shr (8|M0)               r7.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r8.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        add (8|M0)               r9.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (8|M0)               r15.0<1>:f    acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r15.0<1>:f    (abs)r15.0<1;1,0>:f              {Compacted,F@1}
(f1.1)  or (8|M0)                r15.0<1>:d    r15.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L66568                  L66712                
L66568:
        join (16|M0)                         L66712                                
L66584:
(W)     and (1|M0)               f0.1<1>:uw    r3.3<0;1,0>:uw    0x1:uw             
(f0.1.any16h) mov (8|M0)         r1.8<1>:hf    r62.0<1;1,0>:f                  
(f0.1.any16h) mov (8|M0)         r6.0<1>:hf    r54.0<1;1,0>:f                  
        sync.allrd                           ($0,$1,$3,$9,$11)                
(~f0.1.any16h) mov (8|M0)        r14.0<1>:ud   r90.0<1;1,0>:ud                  {$8.src}
(~f0.1.any16h) mov (8|M0)        r15.0<1>:ud   r85.0<1;1,0>:ud                 
(f0.1.any16h) mov (8|M0)         r14.0<1>:f    r1.8<1;1,0>:hf                   {A@2}
(f0.1.any16h) mov (8|M0)         r15.0<1>:f    r6.0<1;1,0>:hf                   {A@1}
L66712:
        join (16|M0)                         L67720                                
L66728:
        mov (1|M0)               r1.2<1>:d     r3.0<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d     31:w               {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.10<0;1,0>:uw 
        sync.allrd                           ($0,$1,$5,$8,$9,$13,$15)                
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r3.5<0;1,0>:d    {$7.src}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.8<0;1,0>:uw   {I@7}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.4<0;1,0>:d   
        sync.allrd                           ($4,$12)                
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        sync.nop                             null                             {Compacted,$2.src}
        add3 (1|M0)              r2.4<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r3.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r2.4<0>:d        {I@1}
(f0.0.any16h) goto (16|M0)                   L67520                  L67520                
L67000:
        shl (1|M0)               r2.3<1>:d     r3.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r1.2<1>:d     r3.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r3.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r5.3<0;0>:d       r2.4<0>:d        {I@2}
        mov (8|M0)               r9.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r9.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r1.8<1>:hf    r14.0<1;1,0>:f                  
        addc (8|M0)              r11.0<1>:ud   r9.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@1}
        mov (8|M0)               r6.0<1>:hf    r15.0<1;1,0>:f                  
        sync.allrd                           ($0,$1,$2,$9,$10)                
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        sync.allrd                           ($3,$11)                
        mov (8|M0)               r13.0<2>:d    r11.0<1;1,0>:d                   {A@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.5<1>:d     r8.0<0;0>:d       r5.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.0<1>:d    r79.1<2;1,0>:d                   {F@1}
        addc (8|M0)              r20.0<1>:ud   r18.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r9.1<4;2>:d       r15.0<1>:d       {I@2}
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r17.0<1>:d    r1.8<1;1,0>:uw                  
        add3 (8|M0)              r9.0<1>:d     r11.0<1;0>:d      r18.1<4;2>:d      r15.0<1>:d       {I@2}
        mov (8|M0)               r21.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:d    r6.0<1;1,0>:uw                  
        mov (8|M0)               r13.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r13     r17:1   0x0            0x04000B84           {A@2,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r21     r10:1   0x0            0x04000B84           {A@1,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L67520                  L67720                
L67520:
        join (16|M0)                         L67720                                
L67536:
        shl (1|M0)               r1.4<1>:d     r3.0<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r3.1<0;1,0>:d     2:w              
        addc (1|M0)              r6.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r3.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r15:1   0x0            0x0200C584           {A@1,$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L67720:
        join (16|M0)                         L67736                                
L67736:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$13} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$13.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L67792:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r80.5<0;1,0>:d              {A@1}
        mov (1|M0)               r5.7<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.6<1>:f     r1.3<0;1,0>:f                    {@2,$14}
        mov (1|M0)               r2.4<1>:f     (abs)r80.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$14.dst}
        mad (1|M0)               r5.6<1>:f     r5.6<0;0>:f       r5.7<0;0>:f       r5.6<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r80.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.6<0;1,0>:f     r2.4<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r4.1<1>:f     r2.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r80.5<1>:d    r80.5<0;1,0>:d    r80.4<0;1,0>:d  
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r7.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r4.1<0;0>:f       r7.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r80.5<1>:d    r80.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r5.6<1>:f     r5.6<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.6<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r9.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r4.1<1>:d     r6.0<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r80.5<0;0>:d      r4.1<0>:d        {I@1}
        xor (1|M0)               r3.0<1>:d     r7.0<0;1,0>:d     r80.5<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r3.2                             {A@1}
L68368:
        mov (2|M0)               r12.0<1>:d    0x1:v                              
        mov (1|M0)               r11.6<2>:f    0.0:f                              
        mov (1|M0)               r11.7<2>:f    0.0:f                              
        mov (1|M0)               r11.4<2>:f    0.0:f                              
        mov (1|M0)               r11.5<2>:d    0:d                              
        mov (1|M0)               r11.2<1>:d    63:w                              
L68464:
        and (1|M0)    (eq)f1.0   r2.3<1>:d     r11.2<0;1,0>:d    63:w               {I@1}
(W)     mov (1|M0)               r2.10<1>:hf   0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r7.2<1>:ud    r11.4<0;1,0>:ud   0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r2.3<0;1,0>:ud    0x20:uw              {I@3}
(f1.0)  sel (1|M0)               r5.6<1>:d     r2.10<0;1,0>:w    -1:w               {F@1}
        add (1|M0)               r2.4<1>:d     -r2.3<0;1,0>:d    32:w              
        add (1|M0)               r6.0<1>:d     r2.3<0;1,0>:d     -32:w               {Compacted}
        and (1|M0)               r5.7<1>:d     r12.5<0;1,0>:d    r5.6<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r12.4<0;1,0>:ud   r2.3<0;1,0>:ud  
(f1.1)  sel (1|M0)               r4.1<1>:d     r2.10<0;1,0>:w    -1:w              
        shr (1|M0)               r6.0<1>:ud    r12.5<0;1,0>:ud   r6.0<0;1,0>:ud   {Compacted,I@4}
        shl (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     r2.4<0;1,0>:d    {I@4}
        shr (1|M0)               r1.3<1>:ud    r12.5<0;1,0>:ud   r2.3<0;1,0>:ud  
        shl (1|M0)               r2.5<1>:d     r11.5<0;1,0>:d    1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r4.1<0;1,0>:ud   {I@5}
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    ~r4.1<0;1,0>:ud  {Compacted,I@5}
        and (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     r4.1<0;1,0>:d    {I@5}
        shl (1|M0)               r8.0<1>:d     r11.4<0;1,0>:d    1:w               {Compacted}
        and (1|M0)               r7.1<1>:ud    r1.3<0;1,0>:ud    r4.1<0;1,0>:ud   {I@6}
        or (1|M0)                r8.1<1>:d     r2.5<0;1,0>:d     r7.2<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r1.2<0;0>:ud      r5.7<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r8.0<1>:ud    r8.0<1;0>:ud      r7.0<1;0>:ud      r12.0<1>:ud      {I@1} // s0|s1&s2
        and (1|M0)               r5.6<1>:d     r5.6<0;1,0>:d     1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r8.0<0;1,0>:ud    r12.2<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r8.1<0;1,0>:ud    r12.3<0;1,0>:ud 
(W)     mov (1|M0)               r2.10<1>:hf   0x1:hf                             
        shl (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:uw    r2.3<0;1,0>:ud   {F@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r8.1<0;1,0>:d     r12.3<0;1,0>:d  
(f0.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        subb (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    r12.2<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r5.6<1>:ud    r5.6<0;1,0>:ud    r2.4<0;1,0>:ud   {I@7}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r11.2<0;1,0>:d    0:w              
        shl (1|M0)               r5.7<1>:d     r2.10<0;1,0>:w    -r2.4<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@3}
        and (1|M0)               r79.4<1>:ud   r2.3<0;1,0>:ud    r4.1<0;1,0>:ud  
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r79.5<1>:ud   r5.7<0;0>:ud      r5.6<0;0>:ud      r4.1<0>:ud       {I@5} // s0&~s2|s1&s2
        add (1|M0)               r5.1<1>:d     r11.2<0;1,0>:d    -1:w              
        mov (1|M0)               r11.4<1>:d    r9.0<0;1,0>:d                   
        add3 (1|M0)              r11.5<1>:d    r8.1<0;0>:d       -r10.0<0;0>:d     -r12.3<0>:d      {I@4}
        or (2|M0)                r79.4<1>:d    r79.4<1;1,0>:d    r11.6<1;1,0>:d   {I@4}
(f0.0)  mov (1|M0)               r11.4<1>:d    r8.0<0;1,0>:d                   
(f0.0)  mov (1|M0)               r11.5<1>:d    r8.1<0;1,0>:d                   
(f0.0)  mov (1|M0)               r79.4<1>:d    r11.6<0;1,0>:d                  
(f0.0)  mov (1|M0)               r79.5<1>:d    r11.7<0;1,0>:d                  
(f1.1.any16h) goto (16|M0)                   L69272                  L69272                
L69224:
(W)     mov (2|M0)               r11.6<1>:ud   r79.4<1;1,0>:ud                  {I@2}
        mov (1|M0)               r11.2<1>:d    r5.1<0;1,0>:d                   
        goto.b (16|M0)                       L69272                  L68464                
L69272:
        join (16|M0)                         L69288                                
L69288:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r11.0                            {A@1}
L69336:
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
