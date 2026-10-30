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
        mov (1|M0)               r15.1<1>:f    r0.1<0;1,0>:f                    {Compacted,A@1}
        mov (1|M0)               r15.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        shl (1|M0)               r15.1<1>:d    r15.1<0;1,0>:d    3:w               {Compacted,F@1}
        shr (1|M0)               r1.2<1>:ud    r15.0<0;1,0>:ud   0x2:uw              {I@2}
        mov (1|M0)               r25.7<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        add (1|M0)               r15.1<1>:d    r15.1<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r26.5<1>:d    r15.1<0;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (8|M0)              r26.6         L10112                                 {A@1}
L352:
        mov (1|M0)               r15.5<1>:d    r26.1<0;1,0>:d                  
        shl (1|M0)               r15.2<1>:ud   r15.0<0;1,0>:ud   0x1:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r15.5<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r17.0<1>:d    r15.5<0;1,0>:d    r2.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r15.5<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r15.5<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r5.2<1>:d     r15.5<0;1,0>:d    2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r4.3<1>:ud    r15.5<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r3.0<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r5.3<1>:d     r4.3<0;1,0>:d     0:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r17.0<1>:d    r15.1<0;1,0>:d    -r17.0<0;1,0>:d  {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r3.1<0;0>:d       r5.3<0>:d        {I@3}
        shl (1|M0)               r15.4<1>:d    r2.3<0;1,0>:d     1:w              
        send.ugm (1|M0)          r18      r12     null:0  0x0            0x04100580           {A@1,$2} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r17.2<2>:f    0.0:f                              
        mov (1|M0)               r17.3<2>:f    0.0:f                              
        and (1|M0)               r15.2<1>:ud   r15.2<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r15.6<1>:d    r2.0<0;1,0>:d                   
        shl (1|M0)               r15.3<1>:d    r17.0<0;1,0>:d    5:w               {Compacted}
        add3 (1|M0)              r15.7<1>:d    r8.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d       
L744:
        shl (1|M0)               r1.2<1>:d     r17.2<0;1,0>:d    3:w               {F@2}
        shl (1|M0)               r1.6<1>:d     r17.3<0;1,0>:d    1:w               {F@1}
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r15.2<0;1,0>:d   {I@2}
        shl (1|M0)               r5.2<1>:d     r17.2<0;1,0>:d    1:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r15.3<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r9.1<1>:ud    0x1:uw               r1.2<0;0>:ud      r15.3<0>:ud      // s0|s1|s2
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.7<1>:ud    r1.5<0;1,0>:ud    0x1E:uw             
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r6.0<1>:ud    r15.6<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.7<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.7<1>:ud    r17.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x4:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r15.7<0;0>:d      r2.1<0>:d        {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@6}
        or (1|M0)                r5.3<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d    {I@5}
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w               {I@2}
        shl (1|M0)               r5.3<1>:d     r9.1<0;1,0>:d     2:w              
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$4} // wr:2+0, rd:1; load.ugm.d32.a64
        sync.nop                             null                             {Compacted,F@1}
        send.ugm (1|M0)          r2       r10     null:0  0x0            0x04100580           {$5} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r4.6<1>:w     r5.4<0;1,0>:w     2:w              
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r3.3<0;0>:d       r2.1<0>:d        {$5.dst}
        shr (1|M0)               r5.2<1>:ud    r9.1<0;1,0>:ud    0x1E:uw              {$4.dst}
        addc (1|M0)              r11.0<1>:ud   r3.2<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          r13      r12     null:0  0x0            0x04100580           {A@3,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r5.4<1>:d     r5.2<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        mov (1|M0)               r6.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r12.0<0;0>:d      r3.3<0;0>:d       r5.4<0>:d        {I@1}
        add (1|M0)               a0.0<1>:uw    r4.6<0;1,0>:uw    0x260:uw              {A@1}
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x04100580           {A@1,$7} // wr:2+0, rd:1; load.ugm.d32.a64
        add3 (1|M0)              r1.3<1>:d     r15.3<0;0>:d      r2.3<0;0>:d       r1.2<0>:d       
        add3 (1|M0)              r1.4<1>:d     r15.3<0;0>:d      r15.4<0;0>:d      r1.2<0>:d       
        mov (1|M0)               r2.7<1>:f     r9.0<0;1,0>:d                    {Compacted}
        mov (1|M0)               r9.0<1>:f     r2.0<0;1,0>:d                    {Compacted}
        add3 (1|M0)              r2.0<1>:d     r15.3<0;0>:d      r2.3<0;0>:d       r1.2<0>:d        {F@1}
        mul (1|M0)               r2.7<1>:f     r18.0<0;1,0>:f    r2.7<0;1,0>:f    {$2.dst}
        shl (1|M0)               r8.0<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@1}
        mul (1|M0)               r9.0<1>:f     r18.0<0;1,0>:f    r9.0<0;1,0>:f    {Compacted}
        sync.nop                             null                             {Compacted,$6.dst}
        mul (1|M0)               r13.0<1>:f    r13.0<0;1,0>:f    r2.7<0;1,0>:f    {Compacted,F@2}
        addc (1|M0)              r10.0<1>:ud   r15.6<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,I@1}
        shr (1|M0)               r2.7<1>:ud    r2.0<0;1,0>:ud    0x1E:uw              {F@1}
        mov (1|M0)               r1.10<2>:hf   r13.0<0;1,0>:f                  
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r8.1<1>:d     r2.7<0;1,0>:d     0:w               {I@2}
        mul (1|M0)               r7.0<1>:f     r7.0<0;1,0>:f     r9.0<0;1,0>:f    {Compacted,$7.dst}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r[a0.0]<1>:f  r1.10<0;1,0>:hf                  {F@3}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r15.7<0;0>:d      r8.1<0>:d        {I@1}
        mov (1|M0)               r1.10<2>:hf   r7.0<0;1,0>:f                    {F@3}
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,F@1}
        send.ugm (1|M0)          r6       r12     null:0  0x0            0x04100580           {A@2,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r14.1<1>:d    r9.0<0;0>:d       r3.3<0;0>:d       r8.1<0>:d        {I@1}
        mov (1|M0)               r[a0.0,4]<1>:f  r1.10<0;1,0>:hf               
        send.ugm (1|M0)          r2       r14     null:0  0x0            0x04100580           {A@1,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r4.6<0;1,0>:uw    0x280:uw              {A@1}
        mov (1|M0)               r5.2<1>:f     r6.0<0;1,0>:d                    {Compacted,$8.dst}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        mul (1|M0)               r5.2<1>:f     r18.0<0;1,0>:f    r5.2<0;1,0>:f   
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,$9.dst}
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     r5.2<0;1,0>:f    {Compacted,F@2}
        add (1|M0)               r5.2<1>:d     r1.3<0;1,0>:d     1:w               {F@1}
        add3 (1|M0)              r16.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r8.1<1>:d     r5.2<0;1,0>:d     2:w               {I@2}
        mov (1|M0)               r1.10<2>:hf   r2.0<0;1,0>:f                   
        shr (1|M0)               r2.0<1>:ud    r5.2<0;1,0>:ud    0x1E:uw              {F@1}
        addc (1|M0)              r9.0<1>:ud    r3.2<0;1,0>:ud    r8.1<0;1,0>:ud   {AccWrEn,I@2}
        send.ugm (1|M0)          r7       r16     null:0  0x0            0x04100580           {$10} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r8.2<1>:d     r2.0<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r11.0<0;0>:d      r3.3<0;0>:d       r8.2<0>:d        {I@1}
        add3 (1|M0)              r12.0<1>:d    r15.3<0;0>:d      r15.4<0;0>:d      r1.2<0>:d       
        send.ugm (1|M0)          r10      r6      null:0  0x0            0x04100580           {A@1,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@1}
        shr (1|M0)               r5.2<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r13.0<1>:ud   r15.6<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r5.2<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r9.0<0;0>:d       r15.7<0;0>:d      r2.1<0>:d        {I@1}
        mov (1|M0)               r[a0.0]<1>:f  r1.10<0;1,0>:hf                 
        send.ugm (1|M0)          r6       r14     null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r5.2<1>:d     r1.4<0;1,0>:d     1:w              
        shr (1|M0)               r5.4<1>:ud    r5.2<0;1,0>:ud    0x1E:uw              {I@1}
        sync.nop                             null                             {Compacted,$10.src}
        or (1|M0)                r7.1<1>:d     r5.4<0;1,0>:d     0:w               {I@1}
        mov (1|M0)               r8.0<1>:f     r7.0<0;1,0>:d                    {Compacted}
        mul (1|M0)               r8.0<1>:f     r18.0<0;1,0>:f    r8.0<0;1,0>:f    {Compacted,F@1}
        sync.nop                             null                             {Compacted,$10.dst}
        mul (1|M0)               r10.0<1>:f    r10.0<0;1,0>:f    r8.0<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r7.0<2>:hf    r10.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r[a0.0,4]<1>:f  r7.0<0;1,0>:hf                 {F@1}
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,F@1}
        add (1|M0)               a0.0<1>:uw    r4.6<0;1,0>:uw    0x2A0:uw              {A@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r3.3<0;0>:d       r2.1<0>:d        {I@1}
        addc (1|M0)              r9.0<1>:ud    r14.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x04100580           {A@1,$12} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r7.0<1>:d     r5.2<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.7<1>:f     r6.0<0;1,0>:d                    {Compacted,$11.dst}
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r6.0<1>:f     r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r12.0<0;0>:d      r14.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r13      r6      null:0  0x0            0x04100580           {A@1,$13} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$12.src}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r3.3<0;0>:d       r7.1<0>:d        {I@1}
        mul (1|M0)               r2.7<1>:f     r18.0<0;1,0>:f    r2.7<0;1,0>:f   
        send.ugm (1|M0)          r6       r10     null:0  0x0            0x04100580           {A@1,$12} // wr:2+0, rd:1; load.ugm.d32.a64
        addc (1|M0)              r9.0<1>:ud    r17.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r17.4<1>:d    r9.0<0;1,0>:d                    {I@1}
        mul (1|M0)               r[a0.0]<1>:f  r11.0<0;1,0>:f    r2.7<0;1,0>:f    {F@1}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@1}
        add3 (1|M0)              r17.5<1>:d    r11.0<0;0>:d      r17.3<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r17.5<0;1,0>:d    0:w               {I@1}
        mov (1|M0)               r1.2<1>:f     r13.0<0;1,0>:d                   {Compacted,$13.dst}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r17.4<0;1,0>:d    4:w              
        mul (1|M0)               r1.2<1>:f     r18.0<0;1,0>:f    r1.2<0;1,0>:f    {F@1}
        sync.nop                             null                             {Compacted,$12.dst}
        mul (1|M0)               r[a0.0,4]<1>:f  r6.0<0;1,0>:f   r1.2<0;1,0>:f    {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.1.any8h) goto (8|M0)                    L4640                  L4640                
L2560:
        mul (1|M0)               r1.4<1>:f     r19.4<0;1,0>:f    r19.4<0;1,0>:f  
        mul (1|M0)               r5.3<1>:f     r19.6<0;1,0>:f    r19.6<0;1,0>:f  
        mov (1|M0)               r2.0<2>:hf    r1.4<0;1,0>:f                    {F@2}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {F@2}
        mul (1|M0)               r1.4<1>:f     r20.4<0;1,0>:f    r20.4<0;1,0>:f  
        mov (1|M0)               r4.3<1>:f     r2.0<0;1,0>:hf                   {F@3}
        mul (1|M0)               r5.3<1>:f     r20.6<0;1,0>:f    r20.6<0;1,0>:f  
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.0<2>:hf    r1.4<0;1,0>:f                    {F@4}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r19.0<0;0>:f      r19.0<0>:f       {F@4}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {F@4}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r19.2<0;0>:f      r19.2<0>:f       {F@4}
        mul (1|M0)               r1.4<1>:f     r19.5<0;1,0>:f    r19.5<0;1,0>:f  
        mov (1|M0)               r5.4<2>:hf    r4.3<0;1,0>:f                    {F@4}
        mul (1|M0)               r5.3<1>:f     r19.7<0;1,0>:f    r19.7<0;1,0>:f  
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.3<1>:f     r2.0<0;1,0>:hf                  
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                  
        mov (1|M0)               r2.0<2>:hf    r1.4<0;1,0>:f                    {F@6}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r20.0<0;0>:f      r20.0<0>:f       {F@3}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                   
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r20.2<0;0>:f      r20.2<0>:f       {F@4}
        add (1|M0)               r5.4<1>:hf    r5.4<0;1,0>:hf    r8.0<0;1,0>:hf  
        mul (1|M0)               r1.4<1>:f     r20.5<0;1,0>:f    r20.5<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r4.3<0;1,0>:f                    {F@5}
        mul (1|M0)               r5.3<1>:f     r20.7<0;1,0>:f    r20.7<0;1,0>:f  
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@5}
        mov (1|M0)               r4.3<1>:f     r2.0<0;1,0>:hf                  
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                  
        mov (1|M0)               r2.0<2>:hf    r1.4<0;1,0>:f                    {F@6}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r19.1<0;0>:f      r19.1<0>:f       {F@3}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                   
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r19.3<0;0>:f      r19.3<0>:f       {F@4}
        add (1|M0)               r9.0<1>:hf    r9.0<0;1,0>:hf    r8.0<0;1,0>:hf  
        mov (1|M0)               r9.2<2>:hf    r4.3<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.3<1>:f     r2.0<0;1,0>:hf                  
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                  
        shl (1|M0)               r15.0<1>:ud   r15.0<0;1,0>:ud   0x2:uw             
(W)     mov (1|M0)               r2.0<1>:ud    0x3FFF0:ud                              {F@2}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r20.1<0;0>:f      r20.1<0>:f      
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r20.3<0;0>:f      r20.3<0>:f       {F@2}
        add (1|M0)               r9.2<1>:hf    r9.2<0;1,0>:hf    r8.0<0;1,0>:hf  
        and (1|M0)               r1.4<1>:ud    r15.0<0;1,0>:ud   0x3FFF0:ud              {I@2}
        mov (1|M0)               r9.4<2>:hf    r4.3<0;1,0>:f                    {F@3}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@3}
        bfn.0xEA (1|M0)          r15.0<1>:ud   r15.2<0;0>:ud     r15.0<0;0>:ud     r2.0<0>:ud       {I@2} // s0|s1&s2
        add (1|M0)               r9.4<1>:hf    r9.4<0;1,0>:hf    r8.0<0;1,0>:hf   {F@1}
        shl (1|M0)               r11.0<1>:ud   r15.0<0;1,0>:ud   0x2:uw              {I@1}
        mov (1|M0)               r10.0<1>:f    r5.4<0;1,0>:hf                  
        mov (1|M0)               r6.0<1>:f     r9.0<0;1,0>:hf                  
        mov (1|M0)               r10.1<1>:f    r9.2<0;1,0>:hf                  
        mov (1|M0)               r6.1<1>:f     r9.4<0;1,0>:hf                   {F@4}
        or (1|M0)                r7.0<1>:ud    r11.0<0;1,0>:ud   0x20:uw              {I@1}
        send.slm (1|M0)          null     r11     r10:2   0x0            0x02000704           {A@2,$14} // wr:1+2, rd:0; store.slm.d64.a32
        send.slm (1|M0)          null     r7      r6:2    0x0            0x02000704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64.a32
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                  
        mov (1|M0)               r22.0<1>:ud   r19.0<0;1,0>:ud                 
        mov (1|M0)               r24.0<1>:f    r19.4<0;1,0>:f                   {Compacted}
        mov (1|M0)               r26.0<1>:f    r19.2<0;1,0>:f                   {Compacted}
        mov (1|M0)               r28.0<1>:f    r19.6<0;1,0>:f                   {Compacted}
        mov (1|M0)               r30.0<1>:ud   r20.0<0;1,0>:ud                 
        mov (1|M0)               r32.0<1>:f    r20.4<0;1,0>:f                   {Compacted}
        mov (1|M0)               r34.0<1>:f    r20.2<0;1,0>:f                   {Compacted}
        mov (1|M0)               r36.0<1>:f    r20.6<0;1,0>:f                   {Compacted}
        mov (1|M0)               r38.0<1>:f    r19.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r40.0<1>:f    r19.5<0;1,0>:f                   {Compacted}
        mov (1|M0)               r42.0<1>:f    r19.3<0;1,0>:f                   {Compacted}
        mov (1|M0)               r44.0<1>:f    r19.7<0;1,0>:f                   {Compacted}
        mov (1|M0)               r46.0<1>:f    r20.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r48.0<1>:f    r20.5<0;1,0>:f                   {Compacted}
        mov (1|M0)               r50.0<1>:f    r20.3<0;1,0>:f                   {Compacted}
        mov (1|M0)               r52.0<1>:f    r20.7<0;1,0>:f                   {Compacted}
(W)     send.slm (1|M0)          r8       r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r12.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r12.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r8.0<1;1,0>:ud                   {$0.dst}
(W)     send.gtwy (1|M0)         null     r12     null:0  0x0            0x02000004           {A@2,$1} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shr (1|M0)               r4.3<1>:ud    r1.2<0;1,0>:ud    0x1A:uw             
        mov (2|M0)               r6.0<1>:w     0x1010101:v                               {$15.src}
        shl (1|M0)               r23.0<1>:ud   r1.4<0;1,0>:ud    0x2:uw             
        shr (1|M0)               r2.0<1>:ud    r15.1<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r5.2<1>:d     r15.1<0;1,0>:d    8:w              
        shl (1|M0)               r5.4<1>:d     r1.2<0;1,0>:d     6:w              
        or (1|M0)                r5.5<1>:d     r4.3<0;1,0>:d     0:w               {I@6}
        mul (2|M0)               r5.6<1>:d     r6.0<1;1,0>:w     192:w               {I@6}
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r12      r23     null:0  0x0            0x0210B700           {A@6,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        or (1|M0)                r5.3<1>:d     r2.0<0;1,0>:d     0:w               {Compacted,I@5}
        shl (1|M0)               r7.2<1>:d     r5.2<0;1,0>:d     2:w               {I@5}
        and (2|M0)               r5.4<1>:d     r5.4<1;1,0>:d     r5.6<1;1,0>:d    {I@3}
        shr (1|M0)               r7.1<1>:ud    r5.2<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r7.0<1>:d     r5.3<0;1,0>:d     2:w               {Compacted,I@4}
        addc (1|M0)              r2.0<1>:ud    r3.6<0;1,0>:ud    r7.2<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r1.6<1>:d     r5.4<0;1,0>:d     2:w               {I@4}
        shl (1|M0)               r1.4<1>:d     r5.5<0;1,0>:d     2:w              
        shr (1|M0)               r1.5<1>:ud    r5.4<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@5}
        add (1|M0)               r1.2<1>:f     r12.1<0;1,0>:f    r12.5<0;1,0>:f   {$2.dst}
        add (1|M0)               r5.3<1>:f     r12.2<0;1,0>:f    r12.6<0;1,0>:f  
        add (1|M0)               r6.1<1>:f     r12.3<0;1,0>:f    r12.7<0;1,0>:f  
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@4}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r7.3<0>:d        {I@3}
        add (1|M0)               r2.0<1>:f     r12.0<0;1,0>:f    r12.4<0;1,0>:f   {Compacted,I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r54.0<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r5.4<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.6<2>:hf    r2.0<0;1,0>:f                    {F@2}
        add3 (1|M0)              r54.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@2}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {I@2}
        mov (1|M0)               r9.0<2>:hf    r6.1<0;1,0>:f                    {I@1}
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r6.0<0;1,0>:hf   {F@2}
        add (1|M0)               r5.4<1>:hf    r5.4<0;1,0>:hf    r9.0<0;1,0>:hf   {F@2}
        addc (1|M0)              r10.0<1>:ud   r54.0<0;1,0>:ud   0x10:ud              {AccWrEn,$14.src}
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r5.4<0;1,0>:hf   {F@1}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r60.0<1>:f    r4.6<0;1,0>:hf                   {F@1}
        addc (1|M0)              r7.0<1>:ud    r54.0<0;1,0>:ud   0x30:ud              {AccWrEn}
        sel (1|M0)    (ge)f0.0   r60.0<1>:f    r60.0<0;1,0>:f    6.198883e-05:f               {F@1}
        mov (1|M0)               r58.0<1>:d    r7.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r2.0<2>:hf    r60.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:d     r2.0<0;1,0>:uw                   {F@1}
        add3 (1|M0)              r58.1<1>:d    r8.0<0;0>:d       r54.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r1.3<1>:d     r7.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.2<1>:ud    r7.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r8.0<1>:ud    r3.4<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r56.0<1>:d    r10.0<0;1,0>:d                  
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:d     r8.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r6.1<1>:d     r10.0<0;0>:d      r3.5<0;0>:d       r1.4<0>:d        {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r3.7<0;1,0>:d     0:w              
        send.ugm (1|M0)          r62      r6      null:0  0x0            0x04100580           {A@2,$3} // wr:2+0, rd:1; load.ugm.d32.a64
        add3 (1|M0)              r56.1<1>:d    r11.0<0;0>:d      r54.1<0;0>:d      0:w              
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any8h) goto (8|M0)                     L4640                  L4784                
L4624:
        goto (8|M0)                          L4640                  L4688                
L4640:
        join (8|M0)                          L4688                                
L4656:
(W)     mov (2|M0)               r17.2<1>:ud   r17.4<1;1,0>:ud                 
        goto.b (8|M0)                        L4688                  L744                
L4688:
        join (8|M0)                          L4784                                
L4704:
        addc (1|M0)              r2.0<1>:ud    r54.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        send.ugm (1|M0)          null     r54     r60:1   0x0            0x04000584           {$4} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r54.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          null     r8      r62:1   0x0            0x04000584           {A@1,$3} // wr:2+1, rd:0; store.ugm.d32.a64
L4784:
        join (8|M0)                          L4800                                
L4800:
        or (1|M0)                r2.0<1>:ud    r23.0<0;1,0>:ud   0x20:uw             
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$3.src}
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0210B700           {A@2,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        add (1|M0)               r1.2<1>:f     r6.0<0;1,0>:f     r6.4<0;1,0>:f    {$5.dst}
        add (1|M0)               r5.2<1>:f     r6.1<0;1,0>:f     r6.5<0;1,0>:f   
        add (1|M0)               r7.1<1>:f     r6.2<0;1,0>:f     r6.6<0;1,0>:f   
        add (1|M0)               r8.1<1>:f     r6.3<0;1,0>:f     r6.7<0;1,0>:f   
        mov (1|M0)               r4.6<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r7.0<2>:hf    r5.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@4}
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r8.0<0;1,0>:hf   {F@2}
        add (1|M0)               r7.0<1>:hf    r7.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@2}
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r64.0<1>:f    r4.6<0;1,0>:hf                   {F@1}
        sel (1|M0)    (ge)f0.0   r64.0<1>:f    r64.0<0;1,0>:f    6.198883e-05:f               {F@1}
        mov (1|M0)               r1.4<2>:hf    r64.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r2.0<1>:d     r1.4<0;1,0>:uw                   {F@1}
        shl (1|M0)               r5.2<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@1}
        shr (1|M0)               r2.7<1>:ud    r2.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r5.3<1>:d     r2.7<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:d     r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r8.1<1>:d     r10.0<0;0>:d      r3.5<0;0>:d       r5.3<0>:d        {I@2}
        send.ugm (1|M0)          r66      r8      null:0  0x0            0x04100580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64
(f1.1.any8h) goto (8|M0)                     L6296                  L6296                
L5224:
        addc (1|M0)              r2.0<1>:ud    r54.0<0;1,0>:ud   0x8:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x4:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r54.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r56.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r58.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r64:1   0x0            0x04000584           {A@4,$7} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r56.0<0;1,0>:ud   0x8:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r2.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@6}
        add3 (1|M0)              r2.1<1>:d     r12.0<0;0>:d      r56.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        addc (1|M0)              r9.0<1>:ud    r58.0<0;1,0>:ud   0x8:ud              {AccWrEn}
        send.ugm (1|M0)          null     r10     r66:1   0x0            0x04000584           {A@4,$6} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r56     r22:1   0x0            0x04000584           {$8} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r58     r30:1   0x0            0x04000584           {$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r2      r38:1   0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r14.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        addc (1|M0)              r6.0<1>:ud    r56.0<0;1,0>:ud   0xC:ud              {AccWrEn,F@1}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r58.0<0;1,0>:ud   0xC:ud              {AccWrEn,F@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r58.1<0;0>:d      0:w              
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r56.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r58.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r56.0<0;1,0>:ud   0x10:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r46:1   0x0            0x04000584           {A@5,$11} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r14.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$11.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@2}
        addc (1|M0)              r6.0<1>:ud    r58.0<0;1,0>:ud   0x10:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r10     r26:1   0x0            0x04000584           {A@6,$12} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r14.1<1>:d    r11.0<0;0>:d      r56.1<0;0>:d      0:w              
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r56.0<0;1,0>:ud   0x14:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r12     r34:1   0x0            0x04000584           {A@7,$13} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r58.1<0;0>:d      0:w               {I@7}
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@7}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r58.0<0;1,0>:ud   0x14:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r14     r42:1   0x0            0x04000584           {A@6,$14} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r56.1<0;0>:d      0:w              
        mov (1|M0)               r14.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$14.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r56.0<0;1,0>:ud   0x18:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r10     r50:1   0x0            0x04000584           {A@6,$15} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r14.1<1>:d    r11.0<0;0>:d      r58.1<0;0>:d      0:w              
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$15.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r58.0<0;1,0>:ud   0x18:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r12     r24:1   0x0            0x04000584           {A@6,$0} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r56.1<0;0>:d      0:w              
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r56.0<0;1,0>:ud   0x1C:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r14     r32:1   0x0            0x04000584           {A@6,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r58.1<0;0>:d      0:w              
        mov (1|M0)               r14.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$1.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r58.0<0;1,0>:ud   0x1C:ud              {AccWrEn,F@1}
        add3 (1|M0)              r14.1<1>:d    r11.0<0;0>:d      r56.1<0;0>:d      0:w               {I@7}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r40:1   0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r48:1   0x0            0x04000584           {$5} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r14     r28:1   0x0            0x04000584           {$7} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$2.src}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r58.1<0;0>:d      0:w              
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$5.src}
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r56.1<0;0>:d      0:w              
        mov (1|M0)               r14.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$7.src}
        add3 (1|M0)              r14.1<1>:d    r11.0<0;0>:d      r58.1<0;0>:d      0:w              
        send.ugm (1|M0)          null     r10     r36:1   0x0            0x04000584           {A@3,$10} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r44:1   0x0            0x04000584           {A@2,$4} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r14     r52:1   0x0            0x04000584           {A@1,$3} // wr:2+1, rd:0; store.ugm.d32.a64
L6296:
        join (8|M0)                          L6312                                
L6312:
        mov (1|M0)               r17.6<1>:d    r17.0<0;1,0>:d                  
        mov (1|M0)               r17.7<1>:d    0:w                              
        shl (1|M0)               r1.4<1>:d     r17.6<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r17.6<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r17.7<0;1,0>:d    2:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.1<0;0>:d       r1.5<0>:d        {I@1}
        mov (1|M0)               r26.5<1>:f    r15.5<0;1,0>:f                  
        send.ugm (1|M0)          r7       r8      null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r25.7<1>:d    r4.2<0;1,0>:d                   
        mov (1|M0)               r17.2<2>:hf   r7.0<0;1,0>:f                    {$11.dst}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (8|M0)              r26.6         L10112                                 {A@1}
L6576:
(W)     mul (1|M0)               acc0.0<1>:d   r26.1<0;1,0>:d    r4.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r26.1<0;1,0>:d    r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r26.1<0;1,0>:ud   r2.4<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:ud    r26.1<0;1,0>:ud   r2.2<0;1,0>:ud   {AccWrEn,F@1}
        mov (1|M0)               r1.4<1>:d     r4.2<0;1,0>:d                   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r5.4<1>:d     r15.5<0;1,0>:d    -r2.0<0;1,0>:d   {I@5}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r17.6<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r22.4<2>:f    0.0:f                              
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r1.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r11.0<1>:ud   r1.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r17.7<0>:d       {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r1.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r12.0<1>:d    r1.3<0;1,0>:d     r1.4<0;1,0>:d   
        addc (1|M0)              r13.0<1>:ud   r10.0<0;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r5.3<1>:d     r12.0<0;0>:d      r11.0<0;0>:d      0:w               {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r54.0<0;1,0>:ud   0x50:ud              {AccWrEn}
        add3 (1|M0)              r8.1<1>:d     r14.0<0;0>:d      r5.3<0;0>:d       0:w               {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r54.0<0;1,0>:ud   0x70:ud              {AccWrEn}
        shr (1|M0)               r6.0<1>:ud    r13.0<0;1,0>:ud   0x1B:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r54.0<0;1,0>:ud   0x90:ud              {AccWrEn}
        shl (1|M0)               r4.3<1>:d     r8.1<0;1,0>:d     5:w               {I@6}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r22.5<2>:f    0.0:f                              
        shl (1|M0)               r18.1<1>:d    r13.0<0;1,0>:d    5:w               {Compacted}
        mov (1|M0)               r18.3<1>:d    r7.0<0;1,0>:d                   
        add3 (1|M0)              r18.4<1>:d    r9.0<0;0>:d       r54.1<0;0>:d      0:w               {I@7}
        mov (1|M0)               r18.5<1>:d    r2.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r18.6<1>:d    r10.0<0;0>:d      r54.1<0;0>:d      0:w               {I@7}
        mov (1|M0)               r22.1<1>:d    r8.0<0;1,0>:d                    {I@7}
        or (1|M0)                r18.2<1>:d    r4.3<0;1,0>:d     r6.0<0;1,0>:d    {I@7}
        add3 (1|M0)              r22.2<1>:d    r11.0<0;0>:d      r54.1<0;0>:d      0:w               {I@7}
L7120:
        shl (1|M0)               r22.6<1>:d    r22.4<0;1,0>:d    1:w               {F@2}
        shl (1|M0)               r2.0<1>:d     r22.5<0;1,0>:d    1:w               {Compacted,F@1}
        shl (1|M0)               r5.3<1>:d     r22.6<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r22.4<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r18.3<0;1,0>:ud   r5.3<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r22.7<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($14,$15)                
        addc (1|M0)              r8.0<1>:ud    r18.5<0;1,0>:ud   r5.3<0;1,0>:ud   {AccWrEn,$13.src}
        shr (1|M0)               r5.2<1>:ud    r22.6<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.3<1>:d     r22.7<0;1,0>:d    2:w               {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r22.1<0;1,0>:ud   r5.3<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r1.2<1>:d     r22.4<0;1,0>:d    3:w              
        or (1|M0)                r5.4<1>:d     r4.3<0;1,0>:d     r5.2<0;1,0>:d    {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r25.1<1>:d    0:w                              
(W)     mov (1|M0)               f0.0<1>:uw    0x1:uw                             
        mov (1|M0)               r27.0<2>:f    0.0:f                              
        mov (1|M0)               r27.1<2>:f    0.0:f                              
        mov (1|M0)               r23.1<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r23.3<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r23.5<1>:d    r2.0<0;1,0>:d                    {I@7}
        or (1|M0)                r25.0<1>:d    r1.2<0;1,0>:d     r15.2<0;1,0>:d   {I@7}
        add3 (1|M0)              r23.2<1>:d    r7.0<0;0>:d       r18.4<0;0>:d      r5.4<0>:d        {I@7}
        add3 (1|M0)              r23.4<1>:d    r9.0<0;0>:d       r18.6<0;0>:d      r5.4<0>:d       
        add3 (1|M0)              r23.6<1>:d    r10.0<0;0>:d      r22.2<0;0>:d      r5.4<0>:d        {I@7}
L7520:
        or (2|M0)                r1.2<1>:d     r27.0<1;1,0>:d    r22.6<1;1,0>:d   {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$12.src}
        shl (1|M0)               r17.3<1>:w    r1.4<0;1,0>:w     2:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r17.3<0;1,0>:uw   0x260:uw              {A@1}
        mul (1|M0)               r2.0<1>:f     r62.0<0;1,0>:f    r[a0.0]<0;1,0>:f
        mov (1|M0)               r18.14<2>:hf  r2.0<0;1,0>:f                    {A@1}
        mul (1|M0)               r22.6<1>:hf   r18.14<0;1,0>:hf  5.65625:hf              {F@1}
        mul (1|M0)               r22.7<1>:hf   r22.6<0;1,0>:hf   r17.2<0;1,0>:hf  {F@1}
        mov (1|M0)               r68.0<1>:f    r22.7<0;1,0>:hf                  {F@1}
(f1.0.any8h) goto (8|M0)                     L7968                  L7968                
L7688:
        shl (1|M0)               r1.4<1>:d     r27.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r27.1<0;1,0>:d    2:w              
        addc (1|M0)              r7.0<1>:ud    r23.1<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r27.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        addc (1|M0)              r9.0<1>:ud    r23.3<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r23.5<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r2.0<1>:f     r22.6<0;1,0>:hf                 
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r18.14<0;1,0>:hf                
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r23.2<0;0>:d      r1.5<0>:d        {I@4}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r23.4<0;0>:d      r1.5<0>:d        {I@4}
        mov (1|M0)               r16.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r16.1<1>:d    r14.0<0;0>:d      r23.6<0;0>:d      r1.5<0>:d        {I@3}
        send.ugm (1|M0)          null     r10     r6:1    0x0            0x04000584           {A@3,$0} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r2:1    0x0            0x04000584           {A@2,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r16     r68:1   0x0            0x04000584           {A@1,$12} // wr:2+1, rd:0; store.ugm.d32.a64
L7968:
        join (8|M0)                          L9864                                
L7984:
        cmp (1|M0)    (lt)f1.0   null<1>:hf    r22.7<0;1,0>:hf   0.0:hf             
(f1.0)  mov (1|M0)               r68.0<1>:f    -r68.0<0;1,0>:f                  {$12.src}
        sel (1|M0)    (lt)f0.0   r68.0<1>:f    r68.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r24.1<1>:ud   r68.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r24.1<1>:ud   r24.1<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r24.1<1>:ud   r24.1<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r24.1<1>:ud   r24.1<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r24.1<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r68.0<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r23.7<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r24.2<1>:f    r23.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r68.0<1>:f    -r24.2<0;0>:f     r1.2<0;0>:f       r68.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r68.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any8h) goto (8|M0)                     L8320                  L8320                
L8224:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r68.0<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r23.7<1>:d    r23.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r24.2<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r23.7<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r24.2<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L8320                  L8352                
L8320:
        join (8|M0)                          L8352                                
L8336:
        add (1|M0)               r24.2<1>:f    r24.2<0;1,0>:f    1.0:f               {F@1}
L8352:
        join (8|M0)                          L9864                                
L8368:
        add (1|M0)               a0.0<1>:uw    r17.3<0;1,0>:uw   0x280:uw              {A@1}
        add (1|M0)               r24.1<1>:ud   r24.1<0;1,0>:ud   0xFE800000:ud             
        bfn.0xFE (2|M0)          r27.0<1>:ud   r27.0<1;0>:ud     r18.1<1;0>:ud     r25.0<1>:ud      // s0|s1|s2
        mul (1|M0)               r24.2<1>:f    r24.2<0;1,0>:f    r24.1<0;1,0>:f   {A@1}
        mul (1|M0)               r4.3<1>:f     r66.0<0;1,0>:f    r[a0.0]<0;1,0>:f
(f1.0)  mov (1|M0)               r24.2<1>:f    -r24.2<0;1,0>:f                  {A@1}
        mov (1|M0)               r5.4<2>:hf    r4.3<0;1,0>:f                    {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.3<0;1,0>:f     0xB3000000:f              
        mov (1|M0)               r24.6<1>:f    r5.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r1.4<2>:hf    r24.2<0;1,0>:f                  
        shl (1|M0)               r1.3<1>:d     r27.1<0;1,0>:d    1:w               {I@1}
(f1.1)  mov (1|M0)               r24.6<1>:f    -r24.6<0;1,0>:f                  {F@2}
        shr (1|M0)               r1.4<1>:ud    r27.0<0;1,0>:ud   0x1F:uw             
        sel (1|M0)    (lt)f0.0   r24.6<1>:f    r24.6<0;1,0>:f    448.0:f               {F@1}
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {$0.src}
        shr (1|M0)               r24.7<1>:ud   r24.6<0;1,0>:ud   0x17:uw              {F@1}
        or (1|M0)                r24.4<1>:d    r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@3}
        and (1|M0)               r24.7<1>:ud   r24.7<0;1,0>:ud   0xFF:uw              {I@2}
        shl (1|M0)               r24.3<1>:d    r27.0<0;1,0>:d    1:w               {Compacted}
        sel (1|M0)    (ge)f0.0   r24.7<1>:ud   r24.7<0;1,0>:ud   0x79:uw              {I@2}
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r2.0<1>:ud    r4.4<0;1,0>:ud    r24.3<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r24.7<1>:ud   r24.7<0;1,0>:ud   0x17:uw              {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r1.2<1>:ud    -r24.7<0;1,0>:ud  0x80800000:ud              {I@2}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        mul (1|M0)               r1.3<1>:f     r24.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       r24.4<0>:d      
        mov (1|M0)               r24.5<1>:d    r1.3<0;1,0>:f                    {F@1}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r25.2<1>:f    r24.5<0;1,0>:d                   {I@1}
        mad (1|M0)               r24.6<1>:f    -r25.2<0;0>:f     r1.2<0;0>:f       r24.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r24.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any8h) goto (8|M0)                     L9000                  L9000                
L8904:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.6<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r24.5<1>:d    r24.5<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r25.2<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r24.5<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r25.2<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L9000                  L9032                
L9000:
        join (8|M0)                          L9032                                
L9016:
        add (1|M0)               r25.2<1>:f    r25.2<0;1,0>:f    1.0:f               {F@1}
L9032:
        join (8|M0)                          L9864                                
L9048:
        add (1|M0)               a0.0<1>:uw    r17.3<0;1,0>:uw   0x2A0:uw              {A@1}
        add (1|M0)               r24.7<1>:ud   r24.7<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r4.6<0;1,0>:ud    r24.3<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r25.2<1>:f    r25.2<0;1,0>:f    r24.7<0;1,0>:f   {A@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r4.3<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r5.2<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f1.1)  mov (1|M0)               r25.2<1>:f    -r25.2<0;1,0>:f                  {A@1}
(f1.0)  sel (1|M0)               r25.4<1>:f    r4.3<0;1,0>:f     r5.2<0;1,0>:f    {F@2}
        mov (1|M0)               r1.4<2>:hf    r25.2<0;1,0>:f                   {F@2}
        sel (1|M0)    (lt)f0.0   r25.4<1>:f    r25.4<0;1,0>:f    448.0:f               {F@2}
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        shr (1|M0)               r25.5<1>:ud   r25.4<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r25.5<1>:ud   r25.5<0;1,0>:ud   0xFF:uw              {I@2}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        sel (1|M0)    (ge)f0.0   r25.5<1>:ud   r25.5<0;1,0>:ud   0x79:uw              {I@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.7<0;0>:d       r24.4<0>:d      
        shl (1|M0)               r25.5<1>:ud   r25.5<0;1,0>:ud   0x17:uw              {I@2}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@1,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add (1|M0)               r1.2<1>:ud    -r25.5<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r25.4<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r25.3<1>:d    r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r25.6<1>:f    r25.3<0;1,0>:d                   {I@1}
        mad (1|M0)               r25.4<1>:f    -r25.6<0;0>:f     r1.2<0;0>:f       r25.4<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r25.4<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any8h) goto (8|M0)                     L9568                  L9568                
L9480:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r25.4<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r25.3<1>:d    r25.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r25.6<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r25.3<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r25.6<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L9568                  L9600                
L9568:
        join (8|M0)                          L9600                                
L9584:
        add (1|M0)               r25.6<1>:f    r25.6<0;1,0>:f    1.0:f               {F@1}
L9600:
        join (8|M0)                          L9864                                
L9616:
        add (1|M0)               r25.5<1>:ud   r25.5<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r24.3<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r25.6<1>:f    r25.6<0;1,0>:f    r25.5<0;1,0>:f   {A@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0)  mov (1|M0)               r25.6<1>:f    -r25.6<0;1,0>:f                  {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<2>:hf    r25.6<0;1,0>:f                   {F@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r24.4<0>:d       {I@1}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f0.0.any8h) goto (8|M0)                    L9864                  L9864                
L9800:
(W)     mov (1|M0)               f0.0<1>:uw    0x0:uw                             
        mov (1|M0)               r27.0<2>:f    1.4013e-45:f                              
        mov (1|M0)               r27.1<2>:d    0:d                              
        goto.b (8|M0)                        L9864                  L7520                
L9864:
        join (8|M0)                          L10032                                
L9880:
        addc (1|M0)              r2.0<1>:ud    r22.4<0;1,0>:ud   0x1:ud              {AccWrEn,$1.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        mov (1|M0)               r26.2<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r26.3<1>:d    r6.0<0;0>:d       r22.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r26.3<0;1,0>:d    0:w               {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r26.2<0;1,0>:d    4:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any8h) goto (8|M0)                     L10032                  L10032                
L10000:
(W)     mov (2|M0)               r22.4<1>:ud   r26.2<1;1,0>:ud                 
        goto.b (8|M0)                        L10032                  L7120                
L10032:
        join (8|M0)                          L10048                                
L10048:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$0.src}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$2} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$2.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L10112:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r25.7<0;1,0>:ud                  {A@1}
        mov (1|M0)               r2.7<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$3}
        mov (1|M0)               r1.5<1>:f     r26.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$3.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r2.7<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r26.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.3<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r26.4<1>:ud   r25.7<0;1,0>:ud   -r26.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r26.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.2<1>:ud    r4.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r26.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r5.3<1>:f     r5.2<0;1,0>:ud                   {I@1}
(W)     mov (1|M0)               r4.6<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r5.3<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r5.3<1>:f     r2.0<0;0>:f       r5.3<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r5.3<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r5.2<1>:ud    r5.2<0;1,0>:ud    r6.0<0;1,0>:ud   {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.2<0;1,0>:ud    r25.14<0;1,0>:uw {I@1}
        mach (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r25.7<0;1,0>:ud 
        add (1|M0)               r26.5<1>:ud   r26.5<0;1,0>:ud   -r7.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r26.5<0;1,0>:ud   r25.7<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r8.0<1>:d     r4.6<0;1,0>:w     0:w              
        add (1|M0)               r26.1<1>:ud   r5.2<0;1,0>:ud    r8.0<0;1,0>:ud   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r26.6                            {A@1}
L10648:
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
