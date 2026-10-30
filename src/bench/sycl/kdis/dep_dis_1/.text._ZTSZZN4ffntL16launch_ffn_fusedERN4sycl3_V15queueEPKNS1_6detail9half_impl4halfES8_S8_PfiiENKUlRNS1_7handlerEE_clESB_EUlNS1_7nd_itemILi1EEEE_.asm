L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        shr (1|M0)               r1.3<1>:uw    r1.0<0;1,0>:uw    0x4:uw              {A@1}
        shl (1|M0)               r1.2<1>:d     r0.1<0;1,0>:d     2:w              
        mov (2|M0)               r90.0<1>:d    0x100:v                              
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:uw   {I@2}
        mov (2|M0)               r114.4<1>:d   0x1:v                              
        sync.nop                             null                             {Compacted,$1.dst}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r82.0<1>:d    r1.2<0;1,0>:d     4:w               {Compacted}
        shl (1|M0)               r3.4<1>:d     r2.0<0;1,0>:d     8:w               {Compacted,I@2}
        shr (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r4.0<1>:d     r3.4<0;1,0>:d     1:w               {Compacted,I@2}
        or (1|M0)                r1.2<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r3.5<1>:d     r2.1<0;1,0>:d     0:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r2.2<0;1,0>:ud    r4.0<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r3.7<1>:ud    r3.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     8:w               {Compacted,I@4}
        shl (1|M0)               r3.6<1>:d     r3.5<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r85.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.1<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@3}
        addc (1|M0)              r7.0<1>:ud    r85.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        shl (1|M0)               r3.6<1>:d     r9.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r9.1<1>:d     r1.4<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r4.0<1>:ud    r2.2<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r3.5<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.4<1>:d     r9.1<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r83.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.7<1>:d     r3.4<0;1,0>:d     r3.5<0;1,0>:d    {I@2}
        addc (1|M0)              r2.0<1>:ud    r83.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        mul (2|M0)               r90.0<1>:d    r90.0<1;1,0>:d    2304:w              
        add3 (1|M0)              r85.1<1>:d    r6.0<0;0>:d       r2.3<0;0>:d       r4.1<0>:d       
        add3 (1|M0)              r83.1<1>:d    r5.0<0;0>:d       r2.3<0;0>:d       r3.7<0>:d        {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r42.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r44.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r46.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r48.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r114.6<1>:f   r2.6<0;1,0>:f                   
        asr (1|M0)               r114.7<1>:d   r2.6<0;1,0>:d     31:w              
        mov (1|M0)               r82.2<2>:f    0.0:f                              
        mov (1|M0)               r82.3<2>:f    0.0:f                              
        shl (1|M0)               r114.0<1>:d   r1.3<0;1,0>:uw    12:w              
        mul (2|M0)               r114.1<1>:d   r114.4<1;1,0>:d   2048:w              
        mov (1|M0)               r84.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r91.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@7}
        add (2|M0)               r90.0<1>:d    r90.0<1;1,0>:d    -2304:w               {I@7}
        add3 (1|M0)              r84.1<1>:d    r8.0<0;0>:d       r85.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r91.1<1>:d    r6.0<0;0>:d       r83.1<0;0>:d      0:w               {I@6}
L880:
        shl (1|M0)               r2.0<1>:d     r82.2<0;1,0>:d    8:w               {Compacted,A@1}
        shl (1|M0)               r1.2<1>:d     r82.3<0;1,0>:d    8:w              
        shr (1|M0)               r1.3<1>:ud    r82.2<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r3.5<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@3}
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.4<0;1,0>:ud    r3.5<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r3.4<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.7<1>:d     r2.1<0;1,0>:d     1:w               {I@3}
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        or (1|M0)                r3.6<1>:d     r2.7<0;1,0>:d     r3.4<0;1,0>:d    {I@2}
        addc (1|M0)              r31.0<1>:ud   r6.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r2.5<0;0>:d       r3.6<0>:d        {I@2}
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r6.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r7       r85     null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r15      r84     null:0  0x0            0x0280E780           {$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r23      r6      null:0  0x0            0x0280E780           {$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {A@1,$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        bfn.0xEA (2|M0)          r2.0<1>:ud    r114.1<1;0>:ud    r2.0<1;0>:ud      r90.0<1>:ud      // s0|s1&s2
        shl (1|M0)               r82.5<1>:d    r82.2<0;1,0>:d    9:w              
        shl (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r1.2<1>:d     r2.1<0;1,0>:d     1:w              
        addc (1|M0)              r4.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r31.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r32.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r32.1<1>:d    r31.0<0;0>:d      r6.1<0;0>:d       0:w               {I@1}
        mov (1|M0)               r82.4<1>:d    0:w                              
        sync.allwr                           ($3,$5,$6,$7)                
        dpas.8x8 (8|M0)          r74:f         null:f            r74:hf            r74.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r74:f         r42:f             r23:hf            r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r58:f         r42:f             r23:hf            r15.0:hf         {$3}
        sync.nop                             null                             {Compacted,$3.src}
        send.ugm (1|M0)          r23      r6      null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r66:f         r42:f             r34:hf            r7.0:hf          {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r7       r83     null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r50:f         r42:f             r34:hf            r15.0:hf         {$11}
        sync.nop                             null                             {Compacted,$11.src}
        send.ugm (1|M0)          r15      r91     null:0  0x0            0x0280E780           {$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r33      r32     null:0  0x0            0x0280E780           {A@1,$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($3,$8,$9,$10,$11,$12,$13)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r74:f         null:f            r74:hf            r74.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r74:f         r74:f             r23:hf            r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r58:f         r58:f             r23:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r66:f         r66:f             r33:hf            r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r50:f         r50:f             r33:hf            r15.0:hf         {$3}
L1688:
        or (1|M0)                r1.2<1>:d     r82.4<0;1,0>:d    r82.0<0;1,0>:d   {I@1}
        mov (1|M0)               r1.3<1>:d     0:w                              
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    r114.6<0;1,0>:ud {I@2}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud {I@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xFE (1|M0)          r2.0<1>:ud    0x8:uw               r82.4<0;0>:ud     r82.0<0>:ud      {$15.src} // s0|s1|s2
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(f0.0)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        shl (1|M0)               r82.2<1>:w    r82.8<0;1,0>:w    5:w              
(f1.1)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.0<0;1,0>:ud    r114.6<0;1,0>:ud {I@6}
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f0.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@1}
(f0.1.any16h) goto (16|M0)                   L2040                  L2040                
L1992:
        mov (8|M0)               r89.0<1>:uw   0x0:uw                             
        mov (8|M0)               r88.0<1>:hf   0.0:hf                              {$14.src}
        goto (16|M0)                         L2040                  L3680                
L2040:
        join (16|M0)                         L3680                                
L2056:
        mov (1|M0)               r83.2<1>:ud   0xBD650000:ud                             
        mov (1|M0)               r82.7<1>:f    0x3EE50000:f                              
        mov (1|M0)               r82.6<1>:f    0x3F650000:f                              
        mov (1|M0)               r83.3<1>:d    0:w                              
L2120:
        mad (1|M0)               r1.3<1>:w     r82.2<0;0>:w      r83.6<0;0>:w      4:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x940:uw              {A@1}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                 {$3.dst}
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r2.1<1>:f     r2.0<0;1,0>:hf                   {A@1}
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     4.0:f               {F@1}
(~f0.0) sel (1|M0)               r3.4<1>:f     r2.1<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r3.5<1>:f     r82.7<0;0>:f      r83.2<0;0>:f      (abs)r3.4<0>:f   {F@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r4.0<2>:hf    r3.5<0;1,0>:f                    {F@1}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r3.4<1>:f     r82.6<0;0>:f      r5.0<0;0>:f       r3.4<0>:f        {F@1}
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r6.0<2>:hf    r3.4<0;1,0>:f                    {F@1}
        mul (1|M0)    (lt)f0.1   r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.0<1>:f     r2.0<0;1,0>:hf                   {F@1}
(f0.1)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                   {F@1}
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r3.5<1>:ud    r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r3.5<1>:ud    r3.5<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r3.5<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.0<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r3.4<1>:f     r2.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r3.4<0;0>:f      r1.2<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L2680                  L2680                
L2592:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {I@2}
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r3.4<0;1,0>:f     1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w               {A@1}
(~f1.0) mov (1|M0)               r3.4<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L2680                  L2712                
L2680:
        join (16|M0)                         L2712                                
L2696:
        add (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     1.0:f               {F@1}
L2712:
        join (16|M0)                         L2896                                
L2728:
        add (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFE800000:ud             
        shl (1|M0)               r1.3<1>:w     r83.6<0;1,0>:w    1:w              
        mul (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     r3.5<0;1,0>:f    {A@1}
        add (1|M0)               r83.3<1>:d    r83.3<0;1,0>:d    1:w               {Compacted}
(f0.1)  mov (1|M0)               r3.4<1>:f     -r3.4<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r83.3<0;1,0>:d    8:w               {A@1}
(W)     mov (1|M0)               r2.0<2>:hf    r3.4<0;1,0>:f                   
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB20:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L2896                  L2120                
L2896:
        join (16|M0)                         L3680                                
L2912:
        mov (1|M0)               r83.3<1>:d    0:w                              
L2928:
        mad (1|M0)               r1.3<1>:w     r82.2<0;0>:w      r83.6<0;0>:w      4:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x840:uw              {A@1}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r2.1<1>:f     r2.0<0;1,0>:hf                   {A@1}
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     4.0:f               {F@1}
(~f0.0) sel (1|M0)               r3.4<1>:f     r2.1<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r3.5<1>:f     r82.7<0;0>:f      r83.2<0;0>:f      (abs)r3.4<0>:f   {F@1}
        mov (1|M0)               r4.0<2>:hf    r3.5<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r3.4<1>:f     r82.6<0;0>:f      r5.0<0;0>:f       r3.4<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r3.4<0;1,0>:f                    {F@1}
        mul (1|M0)    (lt)f0.0   r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.0<1>:f     r2.0<0;1,0>:hf                   {F@1}
(f0.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                   {F@1}
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r3.5<1>:ud    r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r3.5<1>:ud    r3.5<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r3.5<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.0<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r3.4<1>:f     r2.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r3.4<0;0>:f      r1.2<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L3464                  L3464                
L3376:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r2.0<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r3.4<0;1,0>:f     1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r2.1<0;1,0>:d     0:w               {A@1}
(~f0.1) mov (1|M0)               r3.4<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L3464                  L3496                
L3464:
        join (16|M0)                         L3496                                
L3480:
        add (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     1.0:f               {F@1}
L3496:
        join (16|M0)                         L3680                                
L3512:
        shl (1|M0)               r1.3<1>:w     r83.6<0;1,0>:w    1:w              
        add (1|M0)               r83.3<1>:d    r83.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFE800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:d     r83.3<0;1,0>:d    8:w               {I@2}
        mul (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     r3.5<0;1,0>:f    {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB00:uw              {A@1}
(f0.0)  mov (1|M0)               r3.4<1>:f     -r3.4<0;1,0>:f                   {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(W)     mov (1|M0)               r2.0<2>:hf    r3.4<0;1,0>:f                   
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(~f0.0.any16h) goto.b (16|M0)                L3680                  L2928                
L3680:
        join (16|M0)                         L5648                                
L3696:
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L3776                  L3776                
L3728:
        mov (8|M0)               r87.0<1>:uw   0x0:uw                              {$4.src}
        mov (8|M0)               r86.0<1>:hf   0.0:hf                              {$2.src}
        goto (16|M0)                         L3776                  L5416                
L3776:
        join (16|M0)                         L5416                                
L3792:
        mov (1|M0)               r83.2<1>:ud   0xBD650000:ud                             
        mov (1|M0)               r82.7<1>:f    0x3EE50000:f                              
        mov (1|M0)               r82.6<1>:f    0x3F650000:f                              
        mov (1|M0)               r83.3<1>:d    0:w                              
L3856:
        mad (1|M0)               r1.3<1>:w     r82.2<0;0>:w      r83.6<0;0>:w      4:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x740:uw              {A@1}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                 {$3.dst}
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r2.1<1>:f     r2.0<0;1,0>:hf                   {A@1}
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     4.0:f               {F@1}
(~f0.0) sel (1|M0)               r3.4<1>:f     r2.1<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r3.5<1>:f     r82.7<0;0>:f      r83.2<0;0>:f      (abs)r3.4<0>:f   {F@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r4.0<2>:hf    r3.5<0;1,0>:f                    {F@1}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r3.4<1>:f     r82.6<0;0>:f      r5.0<0;0>:f       r3.4<0>:f        {F@1}
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r6.0<2>:hf    r3.4<0;1,0>:f                    {F@1}
        mul (1|M0)    (lt)f0.0   r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.0<1>:f     r2.0<0;1,0>:hf                   {F@1}
(f0.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                   {F@1}
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r3.5<1>:ud    r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r3.5<1>:ud    r3.5<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r3.5<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.0<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r3.4<1>:f     r2.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r3.4<0;0>:f      r1.2<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L4416                  L4416                
L4328:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.5:f              
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r3.4<0;1,0>:f     1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w               {A@1}
(~f1.0) mov (1|M0)               r3.4<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L4416                  L4448                
L4416:
        join (16|M0)                         L4448                                
L4432:
        add (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     1.0:f               {F@1}
L4448:
        join (16|M0)                         L4632                                
L4464:
        shl (1|M0)               r1.3<1>:w     r83.6<0;1,0>:w    1:w              
        add (1|M0)               r83.3<1>:d    r83.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFE800000:ud             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r83.3<0;1,0>:d    8:w               {I@2}
        mul (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     r3.5<0;1,0>:f    {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAE0:uw              {A@1}
(f0.0)  mov (1|M0)               r3.4<1>:f     -r3.4<0;1,0>:f                   {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(W)     mov (1|M0)               r2.0<2>:hf    r3.4<0;1,0>:f                   
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(~f0.0.any16h) goto.b (16|M0)                L4632                  L3856                
L4632:
        join (16|M0)                         L5416                                
L4648:
        mov (1|M0)               r83.3<1>:d    0:w                              
L4664:
        mad (1|M0)               r1.3<1>:w     r82.2<0;0>:w      r83.6<0;0>:w      4:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x640:uw              {A@1}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r2.1<1>:f     r2.0<0;1,0>:hf                   {A@1}
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     4.0:f               {F@1}
(~f0.1) sel (1|M0)               r3.4<1>:f     r2.1<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r3.5<1>:f     r82.7<0;0>:f      r83.2<0;0>:f      (abs)r3.4<0>:f   {F@1}
        mov (1|M0)               r4.0<2>:hf    r3.5<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r3.4<1>:f     r82.6<0;0>:f      r5.0<0;0>:f       r3.4<0>:f        {F@1}
        mov (1|M0)               r6.0<2>:hf    r3.4<0;1,0>:f                    {F@1}
        mul (1|M0)    (lt)f1.0   r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.0<1>:f     r2.0<0;1,0>:hf                   {F@1}
(f1.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                   {F@1}
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r3.5<1>:ud    r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r3.5<1>:ud    r3.5<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r3.5<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.0<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r3.4<1>:f     r2.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r3.4<0;0>:f      r1.2<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L5200                  L5200                
L5112:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r2.0<0;1,0>:f     0.5:f              
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r3.4<0;1,0>:f     1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r2.1<0;1,0>:d     0:w               {A@1}
(~f0.1) mov (1|M0)               r3.4<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5200                  L5232                
L5200:
        join (16|M0)                         L5232                                
L5216:
        add (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     1.0:f               {F@1}
L5232:
        join (16|M0)                         L5416                                
L5248:
        shl (1|M0)               r1.3<1>:w     r83.6<0;1,0>:w    1:w              
        add (1|M0)               r83.3<1>:d    r83.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFE800000:ud             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r83.3<0;1,0>:d    8:w               {I@2}
        mul (1|M0)               r3.4<1>:f     r3.4<0;1,0>:f     r3.5<0;1,0>:f    {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAC0:uw              {A@1}
(f1.0)  mov (1|M0)               r3.4<1>:f     -r3.4<0;1,0>:f                   {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(W)     mov (1|M0)               r2.0<2>:hf    r3.4<0;1,0>:f                   
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(~f1.0.any16h) goto.b (16|M0)                L5416                  L4664                
L5416:
        join (16|M0)                         L5648                                
L5432:
        shl (1|M0)               r1.2<1>:ud    r82.4<0;1,0>:ud   0x5:uw             
        add (1|M0)               r82.4<1>:ud   r82.4<0;1,0>:ud   0x1:uw             
        bfn.0xFE (1|M0)          r2.0<1>:ud    r1.2<0;0>:ud      r82.5<0;0>:ud     r114.0<0>:ud     {A@1} // s0|s1|s2
        cmp (1|M0)    (eq)f1.0   null<1>:d     r82.4<0;1,0>:d    8:w               {I@2}
        sync.nop                             null                             {Compacted,$14.src}
        or (1|M0)                r4.0<1>:ud    r2.0<0;1,0>:ud    0x10:uw              {I@2}
        or (1|M0)                r5.0<1>:ud    r2.0<0;1,0>:ud    0x100:uw              {$4.src}
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0x110:uw              {$2.src}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        send.slm (1|M0)          null     r2      r89:1   0x0            0x02009704           {$15} // wr:1+1, rd:0; store.slm.d64x2t.a32
        send.slm (1|M0)          null     r4      r88:1   0x0            0x02009704           {A@4,$14} // wr:1+1, rd:0; store.slm.d64x2t.a32
        send.slm (1|M0)          null     r5      r87:1   0x0            0x02009704           {A@3,$4} // wr:1+1, rd:0; store.slm.d64x2t.a32
        send.slm (1|M0)          null     r6      r86:1   0x0            0x02009704           {A@2,$2} // wr:1+1, rd:0; store.slm.d64x2t.a32
(~f0.1.any16h) goto.b (16|M0)                L5648                  L1688                
L5648:
        join (16|M0)                         L5816                                
L5664:
        addc (1|M0)              r2.0<1>:ud    r82.2<0;1,0>:ud   0x1:ud              {AccWrEn,$15.src}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r3.4<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r3.5<1>:d     r4.0<0;0>:d       r82.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r3.5<0;1,0>:d     0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r3.4<0;1,0>:d     8:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L5816                  L5816                
L5784:
(W)     mov (2|M0)               r82.2<1>:ud   r3.4<1;1,0>:ud                  
        goto.b (16|M0)                       L5816                  L880                
L5816:
        join (16|M0)                         L5832                                
L5832:
        sync.nop                             null                             {Compacted,$14.src}
(W)     send.slm (1|M0)          r4       r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r5.2<1>:f     0.0:f                               {Compacted,$4.src}
(W)     mov (2|M0)               r5.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$0.dst}
(W)     send.gtwy (1|M0)         null     r5      null:0  0x0            0x02000004           {A@2,$1} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r82.0<0;1,0>:ud   r114.6<0;1,0>:ud
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r1.5<1>:ud    r82.0<0;1,0>:ud   0x1B:uw             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     5:w              
        shl (1|M0)               r1.6<1>:d     r82.0<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@2}
(f0.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        sync.nop                             null                             {Compacted,$15.src}
        shr (1|M0)               r2.1<1>:ud    r1.6<0;1,0>:ud    0x1E:uw              {I@4}
        shl (1|M0)               r2.0<1>:d     r1.7<0;1,0>:d     2:w               {Compacted,I@4}
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@3}
        or (1|M0)                r3.5<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    8:w               {Compacted}
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
(W)     mov (1|M0)               r50.4<1>:uw   f1.1<0;1,0>:uw                   {$3.dst}
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud   {I@3}
        shl (1|M0)               r3.4<1>:d     r1.6<0;1,0>:d     2:w              
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        addc (1|M0)              r4.0<1>:ud    r3.2<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
(f1.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r50.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@3}
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    1:w               {Compacted,F@1}
(f1.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f0.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    9:w               {Compacted}
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
(W)     mov (1|M0)               r50.5<1>:uw   f1.0<0;1,0>:uw                  
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
(f0.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$1.src}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
        or (1|M0)                r66.0<1>:ud   r114.0<0;1,0>:ud  0x100:uw             
        or (1|M0)                r65.0<1>:ud   r114.0<0;1,0>:ud  0x200:uw             
        or (1|M0)                r64.0<1>:ud   r114.0<0;1,0>:ud  0x300:uw             
(f1.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f1.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)                r63.0<1>:ud   r114.0<0;1,0>:ud  0x400:uw             
        or (1|M0)                r62.0<1>:ud   r114.0<0;1,0>:ud  0x500:uw             
(W)     mov (1|M0)               r50.6<1>:uw   f0.1<0;1,0>:uw                  
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud  
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    10:w               {Compacted}
        or (1|M0)                r61.0<1>:ud   r114.0<0;1,0>:ud  0x600:uw             
        or (1|M0)                r60.0<1>:ud   r114.0<0;1,0>:ud  0x700:uw             
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
        or (1|M0)                r59.0<1>:ud   r114.0<0;1,0>:ud  0x800:uw             
        or (1|M0)                r58.0<1>:ud   r114.0<0;1,0>:ud  0x900:uw             
        or (1|M0)                r57.0<1>:ud   r114.0<0;1,0>:ud  0xA00:uw             
(f0.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        or (1|M0)     (ne)f0.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)                r56.0<1>:ud   r114.0<0;1,0>:ud  0xB00:uw             
        or (1|M0)                r55.0<1>:ud   r114.0<0;1,0>:ud  0xC00:uw             
(W)     mov (1|M0)               r50.7<1>:uw   f0.0<0;1,0>:uw                  
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    3:w               {Compacted}
        or (1|M0)                r54.0<1>:ud   r114.0<0;1,0>:ud  0xD00:uw             
        or (1|M0)                r53.0<1>:ud   r114.0<0;1,0>:ud  0xE00:uw             
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
        or (1|M0)                r52.0<1>:ud   r114.0<0;1,0>:ud  0xF00:uw             
        mul (2|M0)               r52.3<1>:d    r114.4<1;1,0>:d   512:w              
        mul (2|M0)               r52.1<1>:d    r114.4<1;1,0>:d   1024:w              
(f0.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f0.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mul (2|M0)               r51.5<1>:d    r114.4<1;1,0>:d   1536:w              
        mul (2|M0)               r51.3<1>:d    r114.4<1;1,0>:d   2560:w              
(W)     mov (1|M0)               r50.8<1>:uw   f1.1<0;1,0>:uw                  
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud  
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    11:w               {Compacted}
        mul (2|M0)               r51.1<1>:d    r114.4<1;1,0>:d   3072:w              
        mov (1|M0)               r52.6<2>:f    0.0:f                              
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
        mov (1|M0)               r52.7<2>:f    0.0:f                              
        add3 (1|M0)              r50.1<1>:d    r5.0<0;0>:d       r3.3<0;0>:d       r3.5<0>:d       
        mul (2|M0)               r114.4<1>:d   r114.4<1;1,0>:d   3584:w              
(f1.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        or (1|M0)     (ne)f1.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
(f0.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.9<1>:uw   f1.0<0;1,0>:uw                  
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    4:w               {Compacted}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(f1.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f1.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.10<1>:uw  f0.1<0;1,0>:uw                  
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud  
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    12:w               {Compacted}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
(f0.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        or (1|M0)     (ne)f0.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.11<1>:uw  f0.0<0;1,0>:uw                  
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    5:w               {Compacted}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(f0.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f0.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.12<1>:uw  f1.1<0;1,0>:uw                  
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud  
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    13:w               {Compacted}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
(f1.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        or (1|M0)     (ne)f1.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
(f0.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.13<1>:uw  f1.0<0;1,0>:uw                  
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    6:w               {Compacted}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(f1.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f1.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.14<1>:uw  f0.1<0;1,0>:uw                   {Compacted}
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud  
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    14:w               {Compacted}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
(f0.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    r114.7<0;1,0>:ud
        or (1|M0)     (ne)f0.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r50.15<1>:uw  f0.0<0;1,0>:uw                  
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
        or (1|M0)                r4.0<1>:d     r82.0<0;1,0>:d    7:w               {Compacted}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(f0.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@1}
(f0.1)  sel (1|M0)               r1.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r51.0<1>:uw   f1.1<0;1,0>:uw                   {Compacted}
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud  
        or (1|M0)                r2.0<1>:d     r82.0<0;1,0>:d    15:w               {Compacted}
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r114.6<0;1,0>:ud  r2.0<0;1,0>:ud   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r114.7<0;1,0>:d   r1.3<0;1,0>:d   
(f1.1)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@1}
(f0.0)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r51.1<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r4.0<0;1,0>:ud    r114.6<0;1,0>:ud
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r1.3<0;1,0>:d     r114.7<0;1,0>:d 
(f1.0)  sel (1|M0)               r1.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r114.7<0;1,0>:ud  r1.3<0;1,0>:ud  
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.8<0;1,0>:uw    r1.9<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r3.9<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:uw    0x1:uw                             
        or (1|M0)     (ne)f0.0   null<1>:uw    r3.8<0;1,0>:uw    r3.9<0;1,0>:uw   {I@2}
L8368:
        shl (1|M0)               r1.2<1>:d     r52.7<0;1,0>:d    8:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r52.6<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r1.4<1>:d     r52.6<0;1,0>:d    8:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.4<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.5<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.allrd                           ($1,$3,$5,$12,$13,$14)                
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r3.5<0>:d        {I@1}
        addc (1|M0)              r31.0<1>:ud   r6.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          r23      r6      null:0  0x0            0x0280E780           {A@2,$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r32.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r32.1<1>:d    r2.0<0;0>:d       r6.1<0;0>:d       0:w               {I@1}
        or (2|M0)                r1.2<1>:d     r1.4<1;1,0>:d     r52.3<1;1,0>:d  
        send.ugm (1|M0)          r33      r32     null:0  0x0            0x0280E780           {A@1,$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allrd                           ($0,$6,$7,$8,$9,$11,$15)                
        send.slm (1|M0)          r7       r114    null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r66     null:0  0x0            0x0280E700           {$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r3.4<1>:d     r1.2<0;1,0>:d     1:w               {I@1}
        shl (1|M0)               r1.6<1>:d     r1.3<0;1,0>:d     1:w              
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.5<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d    {I@2}
        or (2|M0)                r1.2<1>:d     r1.4<1;1,0>:d     r52.1<1;1,0>:d  
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r3.1<0;0>:d       r3.5<0>:d        {I@2}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,A@1}
        shl (1|M0)               r1.6<1>:d     r1.3<0;1,0>:d     1:w              
        shr (1|M0)               r1.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        or (2|M0)                r1.2<1>:d     r1.4<1;1,0>:d     r51.5<1;1,0>:d  
        or (1|M0)                r2.1<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d    {I@2}
        shl (1|M0)               r1.6<1>:d     r1.3<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r1.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
(W)     and (1|M0)               f1.1<1>:uw    r50.4<0;1,0>:uw   0x1:uw             
        sync.allwr                           ($3,$9,$12,$14)                
        dpas.8x8 (8|M0)          r106:f        null:f            r106:hf           r106.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r106:f        r42:f             r23:hf            r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r42:f             r23:hf            r15.0:hf         {$12}
        addc (1|M0)              r30.0<1>:ud   r5.0<0;1,0>:ud    0x100:ud              {AccWrEn,$12.src}
        mov (1|M0)               r31.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r32.0<1>:f    r30.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r32.1<1>:d    r31.0<0;0>:d      r5.1<0;0>:d       0:w               {I@1}
        sync.nop                             null                             {Compacted,$10.dst}
        dpas.8x8 (8|M0)          r98:f         null:f            r98:hf            r98.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r98:f         r42:f             r33:hf            r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r42:f             r33:hf            r15.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r33      r32     null:0  0x0            0x0280E780           {A@1,$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r5      null:0  0x0            0x0280E780           {$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r6       r65     null:0  0x0            0x0280E700           {$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r64     null:0  0x0            0x0280E700           {$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r30.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        addc (1|M0)              r31.0<1>:ud   r30.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r30.1<1>:d    r5.0<0;0>:d       r3.1<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r2.1<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d   
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (2|M0)                r1.2<1>:d     r1.4<1;1,0>:d     r114.1<1;1,0>:d 
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r1.6<1>:d     r1.3<0;1,0>:d     1:w              
        shr (1|M0)               r1.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        or (2|M0)                r1.2<1>:d     r1.4<1;1,0>:d     r51.3<1;1,0>:d  
        sync.allwr                           ($1,$2,$8,$10)                
        dpas.8x8 (8|M0)          r98:f         null:f            r98:hf            r98.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r98:f         r98:f             r33:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r33:hf            r14.0:hf         {$10}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,$10.src}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r30.1<0;0>:d      0:w              
        sync.nop                             null                             {Compacted,$0.dst}
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {$12}
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {A@1,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$6}
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0280E780           {$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r30.0<1>:f    r4.0<0;1,0>:f                    {Compacted,$15.src}
        sync.nop                             null                             {Compacted,$12.src}
        send.slm (1|M0)          r6       r63     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r62     null:0  0x0            0x0280E700           {$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r31.0<1>:ud   r30.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r30.1<1>:d    r5.0<0;0>:d       r3.1<0;0>:d       r2.1<0>:d       
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r30.1<0;0>:d      0:w               {I@1}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.1<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.6<1>:d     r1.3<0;1,0>:d     1:w              
        shr (1|M0)               r1.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        or (2|M0)                r1.2<1>:d     r1.4<1;1,0>:d     r51.1<1;1,0>:d  
        or (2|M0)                r1.4<1>:d     r1.4<1;1,0>:d     r114.4<1;1,0>:d 
        sync.allwr                           ($5,$7,$10,$11)                
        dpas.8x8 (8|M0)          r98:f         r98:f             r34:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r34:hf            r14.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {A@1,$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($6,$12,$15)                
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$12}
        sync.nop                             null                             {Compacted,$12.src}
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0280E780           {$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r30.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@7}
        send.slm (1|M0)          r6       r61     null:0  0x0            0x0280E700           {$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r60     null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r31.0<1>:ud   r30.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r30.1<1>:d    r5.0<0;0>:d       r3.1<0;0>:d       r2.1<0>:d        {I@7}
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r30.1<0;0>:d      0:w               {I@1}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.1<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.6<1>:d     r1.3<0;1,0>:d     1:w              
        shr (1|M0)               r1.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        shr (1|M0)               r1.3<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r1.5<0;1,0>:d     1:w              
        sync.allwr                           ($3,$4,$10,$14)                
        dpas.8x8 (8|M0)          r98:f         r98:f             r34:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r34:hf            r14.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {A@1,$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($12,$13)                
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$12}
        sync.nop                             null                             {Compacted,$12.src}
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r30.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@7}
        send.slm (1|M0)          r6       r59     null:0  0x0            0x0280E700           {$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r58     null:0  0x0            0x0280E700           {$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r31.0<1>:ud   r30.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r30.1<1>:d    r5.0<0;0>:d       r3.1<0;0>:d       r2.1<0>:d        {I@7}
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r30.1<0;0>:d      0:w               {I@1}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.1<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.4<1>:d     r52.6<0;1,0>:d    4:w              
        shl (1|M0)               r3.4<1>:d     r1.4<0;1,0>:d     2:w               {I@1}
        sync.allwr                           ($0,$1,$9,$10)                
        dpas.8x8 (8|M0)          r98:f         r98:f             r34:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r34:hf            r14.0:hf         {$10}
        sync.nop                             null                             {Compacted,F@1}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($2,$12)                
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$12}
        sync.nop                             null                             {Compacted,$12.src}
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0280E780           {$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r30.0<1>:f    r4.0<0;1,0>:f                    {Compacted,$11.src}
        send.slm (1|M0)          r6       r57     null:0  0x0            0x0280E700           {$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r56     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r31.0<1>:ud   r30.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r30.1<1>:d    r5.0<0;0>:d       r3.1<0;0>:d       r2.1<0>:d       
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r30.1<0;0>:d      0:w               {I@1}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:d     r52.7<0;1,0>:d    4:w              
        shr (1|M0)               r1.3<1>:ud    r52.6<0;1,0>:ud   0x1C:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@1}
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     2:w               {Compacted,I@1}
        sync.allwr                           ($6,$8,$10,$15)                
        dpas.8x8 (8|M0)          r98:f         r98:f             r34:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r34:hf            r14.0:hf         {$10}
        sync.nop                             null                             {Compacted,F@1}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($11,$12)                
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$12}
        sync.nop                             null                             {Compacted,$12.src}
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0280E780           {$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r30.0<1>:f    r4.0<0;1,0>:f                    {Compacted,$0.src}
        send.slm (1|M0)          r6       r55     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r54     null:0  0x0            0x0280E700           {$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r31.0<1>:ud   r30.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r30.1<1>:d    r5.0<0;0>:d       r3.1<0;0>:d       r2.1<0>:d       
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r33.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r33.1<1>:d    r32.0<0;0>:d      r30.1<0;0>:d      0:w               {I@1}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r50.0<0;1,0>:ud   r3.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r3.5<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allwr                           ($3,$5,$7,$10)                
        dpas.8x8 (8|M0)          r98:f         r98:f             r34:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r34:hf            r14.0:hf         {$10}
        sync.nop                             null                             {Compacted,F@1}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r34      r33     null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($0,$12)                
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$12}
        sync.nop                             null                             {Compacted,$12.src}
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r6       r53     null:0  0x0            0x0280E700           {$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r52     null:0  0x0            0x0280E700           {$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($1,$2,$6,$9,$10,$12)                
        dpas.8x8 (8|M0)          r98:f         r98:f             r34:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r82:f         r82:f             r34:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r106:f        r106:f            r22:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r90:f         r90:f             r22:hf            r14.0:hf         {$14}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r11.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r5.0<0;0>:d       r50.1<0;0>:d      r3.5<0>:d        {I@1}
(~f1.1.any16h) goto (16|M0)                  L11592                  L11592                
L11504:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r11     r106:1  0x0            0x0200C584           {A@3,$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          null     r5      r98:1   0x0            0x0200C584           {A@1,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L11592:
        join (16|M0)                         L15400                                
L11608:
(W)     and (1|M0)               f1.1<1>:uw    r50.5<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L11784                  L11784                
L11640:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x400:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r5      r90:1   0x0            0x0200C584           {A@2,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r82:1   0x0            0x0200C584           {A@1,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L11784:
        join (16|M0)                         L15400                                
L11800:
(W)     and (1|M0)               f1.1<1>:uw    r50.6<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L11984                  L11984                
L11832:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x80:ud              {AccWrEn}
        sync.allrd                           ($4,$5)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r107:1  0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r99:1   0x0            0x0200C584           {A@1,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L11984:
        join (16|M0)                         L15400                                
L12000:
(W)     and (1|M0)               f1.1<1>:uw    r50.7<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12232                  L12232                
L12032:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x80:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($4,$5,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r91:1   0x0            0x0200C584           {A@2,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r83:1   0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L12232:
        join (16|M0)                         L15400                                
L12248:
(W)     and (1|M0)               f1.1<1>:uw    r50.8<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12440                  L12440                
L12280:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        sync.allrd                           ($4,$5,$14)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        sync.allrd                           ($7,$15)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r108:1  0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r100:1  0x0            0x0200C584           {A@1,$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L12440:
        join (16|M0)                         L15400                                
L12456:
(W)     and (1|M0)               f1.1<1>:uw    r50.9<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12712                  L12712                
L12488:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($4,$5,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($8,$15)                
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r92:1   0x0            0x0200C584           {A@2,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r84:1   0x0            0x0200C584           {A@1,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L12712:
        join (16|M0)                         L15400                                
L12728:
(W)     and (1|M0)               f1.1<1>:uw    r50.10<0;1,0>:uw  0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12928                  L12928                
L12760:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x180:ud              {AccWrEn}
        sync.allrd                           ($4,$5,$14)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        sync.allrd                           ($7,$8,$15)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r109:1  0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r101:1  0x0            0x0200C584           {A@1,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L12928:
        join (16|M0)                         L15400                                
L12944:
(W)     and (1|M0)               f1.1<1>:uw    r50.11<0;1,0>:uw  0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13216                  L13216                
L12976:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x180:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($4,$5,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$8,$15)                
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        sync.allrd                           ($6,$9)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sync.allrd                           ($3,$11)                
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r93:1   0x0            0x0200C584           {A@2,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r85:1   0x0            0x0200C584           {A@1,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L13216:
        join (16|M0)                         L15400                                
L13232:
(W)     and (1|M0)               f1.1<1>:uw    r50.12<0;1,0>:uw  0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13448                  L13448                
L13264:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x200:ud              {AccWrEn}
        sync.allrd                           ($4,$5,$14)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        sync.allrd                           ($9,$10)                
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        sync.allrd                           ($2,$7,$8,$15)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r5      r110:1  0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r102:1  0x0            0x0200C584           {A@1,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L13448:
        join (16|M0)                         L15400                                
L13464:
(W)     and (1|M0)               f1.1<1>:uw    r50.13<0;1,0>:uw  0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13736                  L13736                
L13496:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x200:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($4,$5,$12,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$8,$15)                
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        sync.allrd                           ($6,$9,$10)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sync.allrd                           ($0,$3,$11)                
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r94:1   0x0            0x0200C584           {A@2,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r86:1   0x0            0x0200C584           {A@1,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L13736:
        join (16|M0)                         L15400                                
L13752:
(W)     and (1|M0)               f1.1<1>:uw    r50.14<0;1,0>:uw  0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L13968                  L13968                
L13784:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x280:ud              {AccWrEn}
        sync.allrd                           ($4,$5,$12,$14)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        sync.allrd                           ($9,$10)                
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        sync.allrd                           ($2,$7,$8,$15)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r5      r111:1  0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r103:1  0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L13968:
        join (16|M0)                         L15400                                
L13984:
(W)     and (1|M0)               f1.1<1>:uw    r50.15<0;1,0>:uw  0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L14256                  L14256                
L14016:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x280:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($4,$5,$12,$13,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6,$8,$15)                
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        sync.allrd                           ($9,$10)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sync.allrd                           ($0,$3,$11)                
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r95:1   0x0            0x0200C584           {A@2,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r87:1   0x0            0x0200C584           {A@1,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L14256:
        join (16|M0)                         L15400                                
L14272:
(W)     and (1|M0)               f1.1<1>:uw    r51.0<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L14488                  L14488                
L14304:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x300:ud              {AccWrEn}
        sync.allrd                           ($4,$5,$12,$13,$14)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        sync.allrd                           ($7,$9,$10)                
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        sync.allrd                           ($2,$8,$15)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r5      r112:1  0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r104:1  0x0            0x0200C584           {A@1,$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L14488:
        join (16|M0)                         L15400                                
L14504:
(W)     and (1|M0)               f1.1<1>:uw    r51.1<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L14776                  L14776                
L14536:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x300:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($1,$4,$5,$12,$13,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6,$8,$15)                
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        sync.allrd                           ($9,$10)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sync.allrd                           ($0,$3,$11)                
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r96:1   0x0            0x0200C584           {A@2,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r88:1   0x0            0x0200C584           {A@1,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L14776:
        join (16|M0)                         L15400                                
L14792:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L15008                  L15008                
L14824:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x380:ud              {AccWrEn}
        sync.allrd                           ($1,$4,$5,$12,$13,$14)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        sync.allrd                           ($2,$7,$9,$10)                
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        sync.allrd                           ($8,$15)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r5      r113:1  0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r105:1  0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L15008:
        join (16|M0)                         L15400                                
L15024:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L15288                  L15288                
L15056:
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x380:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($1,$3,$4,$5,$12,$13,$14)                
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6,$8,$11,$15)                
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:ud              {AccWrEn,$7.src}
        sync.allrd                           ($9,$10)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        send.ugm (1|M0)          null     r7      r97:1   0x0            0x0200C584           {A@2,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r89:1   0x0            0x0200C584           {A@1,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
L15288:
        join (16|M0)                         L15400                                
L15304:
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L15400                  L15400                
L15336:
(W)     mov (1|M0)               f1.0<1>:uw    0x0:uw                             
        mov (1|M0)               r52.6<2>:f    1.4013e-45:f                              
        mov (1|M0)               r52.7<2>:d    0:d                              
        goto.b (16|M0)                       L15400                  L8368                
L15400:
        join (16|M0)                         L15416                                
L15416:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$4} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$4.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L15472:
        nop                    
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
