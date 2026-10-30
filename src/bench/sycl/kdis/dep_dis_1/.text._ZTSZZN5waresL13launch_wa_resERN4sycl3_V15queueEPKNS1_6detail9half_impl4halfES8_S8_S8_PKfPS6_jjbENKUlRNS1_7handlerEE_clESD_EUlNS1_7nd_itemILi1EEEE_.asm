L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$1.src}
(W)     send.dc0 (8|M0)          r4       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        mov (1|M0)               r96.1<1>:d    r1.0<0;1,0>:uw                   {A@1}
        shr (1|M0)               r1.2<1>:ud    r0.1<0;1,0>:ud    0x15:uw             
        shl (1|M0)               r1.3<1>:d     r0.1<0;1,0>:d     11:w              
        sync.nop                             null                             {Compacted,$2.dst}
        shl (1|M0)               r4.4<1>:ud    r96.1<0;1,0>:ud   0x3:uw              {I@3}
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@3}
        shl (1|M0)               r87.0<1>:d    r1.3<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r87.2<1>:ud   r96.1<0;1,0>:ud   0x1:uw             
        shr (1|M0)               r2.1<1>:ud    r1.3<0;1,0>:ud    0x1F:uw              {$1.dst}
        and (1|M0)               r5.1<1>:ud    r4.4<0;1,0>:ud    0x8:uw              {I@5}
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@5}
        addc (1|M0)              r5.0<1>:ud    r2.2<0;1,0>:ud    r87.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r1.5<1>:ud    r87.2<0;1,0>:ud   0x5:uw              {I@5}
        shl (1|M0)               r5.3<1>:d     r5.1<0;1,0>:d     1:w               {I@4}
        or (1|M0)                r87.1<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r5.2<1>:ud    r5.1<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r2.3<0;0>:d       r87.1<0>:d       {I@3}
        shl (1|M0)               r6.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r5.4<1>:d     r5.2<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r6.1<1>:d     r1.6<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r1.3<1>:d     r2.0<0;0>:d       r4.3<0;0>:d       r5.4<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       r6.1<0>:d        {I@1}
        shl (1|M0)               r3.3<1>:ud    r87.2<0;1,0>:ud   0x4:uw             
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x02109780           {A@1,$3} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r4.3<1>:ud    r1.5<0;1,0>:ud    0x100:uw             
        or (1|M0)                r1.4<1>:ud    r3.3<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shl (1|M0)               r5.2<1>:d     r4.3<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@2}
        addc (1|M0)              r5.0<1>:ud    r7.0<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@2}
        add (1|M0)               r2.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw              {I@2}
        shr (1|M0)               r4.5<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.3<1>:d     r4.5<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r5.3<0>:d        {I@1}
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x80:uw             
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x02109780           {A@1,$4} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r1.4<1>:ud    r3.3<0;1,0>:ud    0x100:uw             
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        or (1|M0)                r1.4<1>:ud    r1.4<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw              {I@2}
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@2}
        add (1|M0)               r4.3<1>:ud    r1.5<0;1,0>:ud    0x300:uw             
        mov (1|M0)               r96.6<1>:d    r1.0<0;1,0>:uw                  
        shl (1|M0)               r7.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@2}
        mov (1|M0)               r96.7<1>:d    0:w                              
        shl (1|M0)               r1.6<1>:d     r96.6<0;1,0>:d    5:w               {I@3}
        and (1|M0)               r96.3<1>:d    r1.0<0;1,0>:uw    7:w              
        and (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw    0xFFF8:uw             
        mov (1|M0)               r96.0<1>:d    r0.1<0;1,0>:ud                  
        send.slm (1|M0)          null     r2      r11:1   0x0            0x02009704           {$3} // wr:1+1, rd:0; store.slm.d64x2t.a32
        addc (1|M0)              r11.0<1>:ud   r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,$3.src}
        add (1|M0)               r2.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r1.7<1>:d     r12.0<0;0>:d      r1.3<0;0>:d       0:w               {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r5.0<0;0>:d       r1.7<0;0>:d       r6.1<0>:d        {I@1}
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x180:uw             
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x02109780           {A@1,$5} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@1}
        send.slm (1|M0)          null     r2      r10:1   0x0            0x02009704           {$4} // wr:1+1, rd:0; store.slm.d64x2t.a32
        add (1|M0)               r2.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw              {$4.src}
        addc (1|M0)              r10.0<1>:ud   r11.0<0;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn}
        add (1|M0)               r1.4<1>:ud    r3.3<0;1,0>:ud    0x200:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r12.0<0;0>:d      r1.7<0;0>:d       r5.3<0>:d        {I@1}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw             
        send.ugm (1|M0)          r13      r14     null:0  0x0            0x02109780           {A@1,$6} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        or (1|M0)                r1.4<1>:ud    r1.4<0;1,0>:ud    r5.1<0;1,0>:ud  
        add (1|M0)               r6.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw              {I@2}
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@2}
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x280:uw             
        add (1|M0)               r5.2<1>:ud    r1.5<0;1,0>:ud    0x400:uw             
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw              {I@1}
        send.slm (1|M0)          null     r2      r9:1    0x0            0x02009704           {$5} // wr:1+1, rd:0; store.slm.d64x2t.a32
        add (1|M0)               r2.0<1>:ud    r1.5<0;1,0>:ud    0x200:uw              {$5.src}
        shl (1|M0)               r7.1<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@1}
        shr (1|M0)               r2.7<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r7.2<1>:d     r2.7<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r5.0<0;0>:d       r1.3<0;0>:d       r7.2<0>:d        {I@1}
        shr (1|M0)               r2.0<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x02109780           {A@1,$7} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r7.3<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r7.4<1>:d     r2.0<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r5.0<0;0>:d       r1.3<0;0>:d       r7.4<0>:d        {I@1}
        send.slm (1|M0)          null     r6      r13:1   0x0            0x02009704           {$6} // wr:1+1, rd:0; store.slm.d64x2t.a32
        send.ugm (1|M0)          r12      r9      null:0  0x0            0x02109780           {A@1,$8} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r6.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw              {$6.src}
        add (1|M0)               r1.4<1>:ud    r3.3<0;1,0>:ud    0x300:uw             
        add (1|M0)               r4.3<1>:ud    r1.5<0;1,0>:ud    0x500:uw             
        or (1|M0)                r1.4<1>:ud    r1.4<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shr (1|M0)               r4.5<1>:ud    r4.3<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@2}
        or (1|M0)                r5.3<1>:d     r4.5<0;1,0>:d     0:w               {I@2}
        add (1|M0)               r5.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw              {I@2}
        add (1|M0)               r1.4<1>:ud    r3.3<0;1,0>:ud    0x400:uw             
        shr (1|M0)               r2.7<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r1.4<1>:ud    r1.4<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@1}
        send.slm (1|M0)          null     r6      r10:1   0x0            0x02009704           {$7} // wr:1+1, rd:0; store.slm.d64x2t.a32
        addc (1|M0)              r10.0<1>:ud   r11.0<0;1,0>:ud   r7.1<0;1,0>:ud   {AccWrEn,$7.src}
        add (1|M0)               r6.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw             
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r2.0<0;0>:d       r1.7<0;0>:d       r7.2<0>:d        {I@1}
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x380:uw             
        send.ugm (1|M0)          r8       r13     null:0  0x0            0x02109780           {A@1,$9} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        send.slm (1|M0)          null     r6      r12:1   0x0            0x02009704           {$8} // wr:1+1, rd:0; store.slm.d64x2t.a32
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   r7.3<0;1,0>:ud   {AccWrEn,$8.src}
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r1.7<0;0>:d       r7.4<0>:d        {I@1}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw             
        send.ugm (1|M0)          r10      r12     null:0  0x0            0x02109780           {A@1,$10} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r2.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw              {I@1}
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x480:uw             
        add (1|M0)               r7.1<1>:ud    r1.5<0;1,0>:ud    0x600:uw             
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shl (1|M0)               r11.1<1>:d    r7.1<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw              {I@2}
        shr (1|M0)               r7.3<1>:ud    r7.1<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r11.2<1>:d    r7.3<0;1,0>:d     0:w               {I@1}
        send.slm (1|M0)          null     r5      r8:1    0x0            0x02009704           {$9} // wr:1+1, rd:0; store.slm.d64x2t.a32
        shl (1|M0)               r8.0<1>:d     r5.2<0;1,0>:d     1:w               {Compacted,$9.src}
        shr (1|M0)               r5.0<1>:ud    r5.2<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r8.1<1>:d     r5.0<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       r8.1<0>:d        {I@1}
        shl (1|M0)               r5.2<1>:d     r4.3<0;1,0>:d     1:w              
        send.ugm (1|M0)          r13      r12     null:0  0x0            0x02109780           {A@1,$11} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r5.0<1>:ud    r7.0<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@1}
        send.slm (1|M0)          null     r2      r10:1   0x0            0x02009704           {$10} // wr:1+1, rd:0; store.slm.d64x2t.a32
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r9.1<1>:d     r6.0<0;0>:d       r1.3<0;0>:d       r5.3<0>:d        {I@1}
        add (1|M0)               r2.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw              {$10.src}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x02109780           {A@1,$12} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,$11.src}
        add (1|M0)               r1.4<1>:ud    r3.3<0;1,0>:ud    0x500:uw             
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        or (1|M0)                r1.4<1>:ud    r1.4<0;1,0>:ud    r5.1<0;1,0>:ud   {I@1}
        add (1|M0)               r4.3<1>:ud    r1.5<0;1,0>:ud    0x700:uw             
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@2}
        shl (1|M0)               r7.1<1>:d     r4.3<0;1,0>:d     1:w               {I@2}
        add (1|M0)               r5.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw              {I@2}
        shr (1|M0)               r4.5<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        add (1|M0)               r1.4<1>:ud    r3.3<0;1,0>:ud    0x600:uw             
        or (1|M0)                r7.2<1>:d     r4.5<0;1,0>:d     0:w               {I@2}
        or (1|M0)                r1.4<1>:ud    r1.4<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        shr (1|M0)               r1.5<1>:ud    r96.6<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    0x1:uw              {I@2}
        shl (1|M0)               r4.5<1>:d     r1.6<0;1,0>:d     1:w              
        send.slm (1|M0)          null     r2      r13:1   0x0            0x02009704           {$11} // wr:1+1, rd:0; store.slm.d64x2t.a32
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        add (1|M0)               r2.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw             
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r1.7<0;0>:d       r8.1<0>:d        {I@2}
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x580:uw             
        send.ugm (1|M0)          r15      r14     null:0  0x0            0x02109780           {A@1,$13} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@1}
        send.slm (1|M0)          null     r2      r10:1   0x0            0x02009704           {$12} // wr:1+1, rd:0; store.slm.d64x2t.a32
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,$12.src}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw              {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r6.0<0;0>:d       r1.7<0;0>:d       r5.3<0>:d        {I@1}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r11.1<0;1,0>:ud  {AccWrEn,F@1}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x02109780           {A@2,$14} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        add (1|M0)               r8.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw             
        add (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0x680:uw             
        or (1|M0)                r4.2<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {I@1}
        shl (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    0x1:uw              {I@1}
        send.slm (1|M0)          null     r5      r15:1   0x0            0x02009704           {$13} // wr:1+1, rd:0; store.slm.d64x2t.a32
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,F@1}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r1.3<0;0>:d       r11.2<0>:d       {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r9       r6      null:0  0x0            0x02109780           {A@2,$15} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   r11.1<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,$15.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r1.3<0;0>:d       r7.2<0>:d        {I@3}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r1.7<0;0>:d       r11.2<0>:d       {I@2}
        send.slm (1|M0)          null     r8      r10:1   0x0            0x02009704           {$14} // wr:1+1, rd:0; store.slm.d64x2t.a32
        sync.nop                             null                             {Compacted,$14.src}
        send.ugm (1|M0)          r10      r6      null:0  0x0            0x02109780           {A@2,$0} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        send.ugm (1|M0)          r15      r14     null:0  0x0            0x02109780           {A@1,$1} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r8.0<1>:ud    r1.4<0;1,0>:ud    0x8000:uw             
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   r7.1<0;1,0>:ud   {AccWrEn,$0.src}
        shl (1|M0)               r1.4<1>:d     r96.7<0;1,0>:d    5:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.3<1>:d     r96.3<0;1,0>:d    2:w               {Compacted}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r1.7<0;0>:d       r7.2<0>:d        {I@2}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d   
        add (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     16:w              
        shl (1|M0)               r2.1<1>:d     r1.7<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r1.4<1>:d     r1.4<0;1,0>:d     r96.3<0;1,0>:d   {I@2}
        or (1|M0)                r4.6<1>:d     r2.1<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02009704           {$15} // wr:1+1, rd:0; store.slm.d64x2t.a32
        add (1|M0)               r9.0<1>:ud    r3.3<0;1,0>:ud    0x700:uw              {$15.src}
        add (1|M0)               r8.0<1>:ud    r4.2<0;1,0>:ud    0x8000:uw             
        or (1|M0)                r9.0<1>:ud    r9.0<0;1,0>:ud    r5.1<0;1,0>:ud   {Compacted,I@2}
        add (1|M0)               r3.3<1>:ud    r3.3<0;1,0>:ud    0x780:uw             
        shl (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x1:uw              {I@2}
        or (1|M0)                r3.3<1>:ud    r3.3<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        add (1|M0)               r2.0<1>:ud    r9.0<0;1,0>:ud    0x8000:uw              {I@2}
        send.slm (1|M0)          null     r8      r10:1   0x0            0x02009704           {$0} // wr:1+1, rd:0; store.slm.d64x2t.a32
        send.slm (1|M0)          null     r2      r15:1   0x0            0x02009704           {A@1,$1} // wr:1+1, rd:0; store.slm.d64x2t.a32
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r87.0<0;1,0>:ud  {AccWrEn,$1.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,F@1}
        send.ugm (1|M0)          r10      r8      null:0  0x0            0x02109780           {$2} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add3 (1|M0)              r4.4<1>:d     r5.0<0;0>:d       r2.5<0;0>:d       r87.1<0>:d       {I@1}
        addc (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r3.3<1>:ud    r3.3<0;1,0>:ud    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r4.4<0;0>:d       r4.6<0>:d        {I@1}
        add (1|M0)               r12.0<1>:ud   r3.3<0;1,0>:ud    0x8000:uw             
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$3} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        shl (1|M0)               r3.3<1>:ud    r96.1<0;1,0>:ud   0x5:uw             
        and (1|M0)               r4.8<2>:b     r2.24<0;1,0>:b    1:w              
        and (1|M0)               r3.3<1>:ud    r3.3<0;1,0>:ud    0x1FFF00:ud              {I@2}
        or (1|M0)                r4.7<1>:d     r3.3<0;1,0>:d     r1.3<0;1,0>:d    {I@1}
        add (1|M0)               r4.3<1>:d     r3.3<0;1,0>:d     2560:w              
        add (1|M0)               r5.0<1>:d     r4.7<0;1,0>:d     0x9020:uw              {I@2}
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x9040:uw              {$3.src}
        add (1|M0)               r13.0<1>:d    r4.7<0;1,0>:d     0x9060:uw             
        or (1|M0)                r4.3<1>:d     r4.3<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        send.slm (1|M0)          null     r12     r10:1   0x0            0x02009704           {$2} // wr:1+1, rd:0; store.slm.d64x2t.a32
        add (1|M0)               r10.0<1>:d    r4.7<0;1,0>:d     0x9000:uw              {$2.src}
        mov (1|M0)               r9.0<1>:hf    r8.0<0;1,0>:hf                   {$3.dst}
        mov (1|M0)               r9.1<1>:hf    r8.1<0;1,0>:hf                  
        mov (1|M0)               r11.0<1>:hf   r8.2<0;1,0>:hf                  
        send.slm (1|M0)          null     r10     r9:1    0x0            0x02000504           {A@1,$4} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r11.1<1>:hf   r8.3<0;1,0>:hf                  
        mov (1|M0)               r6.0<1>:hf    r8.4<0;1,0>:hf                  
        mov (1|M0)               r6.1<1>:hf    r8.5<0;1,0>:hf                  
        mov (1|M0)               r12.0<1>:hf   r8.6<0;1,0>:hf                  
        mov (1|M0)               r12.1<1>:hf   r8.7<0;1,0>:hf                  
        mov (1|M0)               r9.0<1>:hf    r8.8<0;1,0>:hf                   {$4.src}
        mov (1|M0)               r9.1<1>:hf    r8.9<0;1,0>:hf                  
        add (1|M0)               r10.0<1>:d    r4.7<0;1,0>:d     0x9080:uw             
        send.slm (1|M0)          null     r5      r11:1   0x0            0x02000504           {A@7,$5} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@5,$6} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r13     r12:1   0x0            0x02000504           {A@3,$7} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r10     r9:1    0x0            0x02000504           {A@1,$8} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r5.0<1>:hf    r8.10<0;1,0>:hf                  {$5.src}
        mov (1|M0)               r5.1<1>:hf    r8.11<0;1,0>:hf                 
        add (1|M0)               r11.0<1>:d    r4.7<0;1,0>:d     0x90A0:uw             
        shl (1|M0)               r9.0<1>:d     r1.4<0;1,0>:d     5:w               {Compacted,$8.src}
        send.slm (1|M0)          null     r11     r5:1    0x0            0x02000504           {A@1,$9} // wr:1+1, rd:0; store.slm.d32.a32
        sync.nop                             null                             {Compacted,$9.src}
        shl (1|M0)               r5.0<1>:d     r9.0<0;1,0>:d     1:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:hf    r8.12<0;1,0>:hf                  {$6.src}
        mov (1|M0)               r6.1<1>:hf    r8.13<0;1,0>:hf                 
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x90C0:uw             
        shr (1|M0)               r2.1<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@3}
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@1,$10} // wr:1+1, rd:0; store.slm.d32.a32
        or (1|M0)                r5.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r7.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r4.4<0;0>:d       r5.1<0>:d        {I@1}
        mov (1|M0)               r12.0<1>:hf   r8.14<0;1,0>:hf                  {$7.src}
        mov (1|M0)               r12.1<1>:hf   r8.15<0;1,0>:hf                 
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$11} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        add (1|M0)               r13.0<1>:d    r4.7<0;1,0>:d     0x90E0:uw             
        add (1|M0)               r4.7<1>:d     r3.3<0;1,0>:d     512:w              
        add (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     32:w              
        or (1|M0)                r4.7<1>:d     r4.7<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        send.slm (1|M0)          null     r13     r12:1   0x0            0x02000504           {$12} // wr:1+1, rd:0; store.slm.d32.a32
        or (1|M0)                r1.4<1>:d     r1.4<0;1,0>:d     r96.3<0;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$12.src}
        add (1|M0)               r12.0<1>:d    r4.7<0;1,0>:d     0x9000:uw              {I@2}
        add (1|M0)               r13.0<1>:d    r4.7<0;1,0>:d     0x9020:uw             
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x9040:uw              {$11.src}
        add (1|M0)               r14.0<1>:d    r4.7<0;1,0>:d     0x9060:uw             
        shl (1|M0)               r5.2<1>:d     r1.4<0;1,0>:d     5:w               {I@5}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     48:w              
        shr (1|M0)               r2.1<1>:ud    r5.2<0;1,0>:ud    0x1F:uw              {I@2}
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r96.3<0;1,0>:d   {I@2}
        or (1|M0)                r9.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r11.0<1>:hf   r8.0<0;1,0>:hf                   {$11.dst}
        mov (1|M0)               r11.1<1>:hf   r8.1<0;1,0>:hf                  
        mov (1|M0)               r9.0<1>:hf    r8.2<0;1,0>:hf                  
        mov (1|M0)               r9.1<1>:hf    r8.3<0;1,0>:hf                  
        send.slm (1|M0)          null     r12     r11:1   0x0            0x02000504           {A@3,$13} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r13     r9:1    0x0            0x02000504           {A@1,$14} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r6.0<1>:hf    r8.4<0;1,0>:hf                  
        mov (1|M0)               r6.1<1>:hf    r8.5<0;1,0>:hf                  
        mov (1|M0)               r10.0<1>:hf   r8.6<0;1,0>:hf                  
        mov (1|M0)               r10.1<1>:hf   r8.7<0;1,0>:hf                  
        mov (1|M0)               r11.0<1>:hf   r8.8<0;1,0>:hf                   {$13.src}
        mov (1|M0)               r11.1<1>:hf   r8.9<0;1,0>:hf                  
        add (1|M0)               r12.0<1>:d    r4.7<0;1,0>:d     0x9080:uw             
        mov (1|M0)               r9.0<1>:hf    r8.10<0;1,0>:hf                  {$14.src}
        mov (1|M0)               r9.1<1>:hf    r8.11<0;1,0>:hf                 
        add (1|M0)               r13.0<1>:d    r4.7<0;1,0>:d     0x90A0:uw             
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@7,$15} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r14     r10:1   0x0            0x02000504           {A@5,$0} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r12     r11:1   0x0            0x02000504           {A@2,$1} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r13     r9:1    0x0            0x02000504           {A@1,$2} // wr:1+1, rd:0; store.slm.d32.a32
        shl (1|M0)               r9.0<1>:d     r5.2<0;1,0>:d     1:w               {Compacted,$2.src}
        mov (1|M0)               r6.0<1>:hf    r8.12<0;1,0>:hf                  {$15.src}
        mov (1|M0)               r6.1<1>:hf    r8.13<0;1,0>:hf                 
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x90C0:uw             
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@2}
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@1,$3} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r7.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r4.4<0;0>:d       r9.1<0>:d        {I@1}
        mov (1|M0)               r10.0<1>:hf   r8.14<0;1,0>:hf                  {$0.src}
        mov (1|M0)               r10.1<1>:hf   r8.15<0;1,0>:hf                 
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$4} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        add (1|M0)               r14.0<1>:d    r4.7<0;1,0>:d     0x90E0:uw             
        add (1|M0)               r4.7<1>:d     r3.3<0;1,0>:d     1024:w              
        send.slm (1|M0)          null     r14     r10:1   0x0            0x02000504           {A@2,$5} // wr:1+1, rd:0; store.slm.d32.a32
        or (1|M0)                r4.7<1>:d     r4.7<0;1,0>:d     r1.3<0;1,0>:d    {I@1}
        shl (1|M0)               r5.2<1>:d     r1.2<0;1,0>:d     5:w              
        add (1|M0)               r12.0<1>:d    r4.7<0;1,0>:d     0x9000:uw              {I@2}
        add (1|M0)               r14.0<1>:d    r4.7<0;1,0>:d     0x9020:uw              {$5.src}
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x9040:uw              {$4.src}
        add (1|M0)               r15.0<1>:d    r4.7<0;1,0>:d     0x9060:uw             
        shl (1|M0)               r9.2<1>:d     r5.2<0;1,0>:d     1:w               {I@5}
        shr (1|M0)               r2.1<1>:ud    r5.2<0;1,0>:ud    0x1F:uw             
        add (1|M0)               r1.2<1>:d     r3.3<0;1,0>:d     2048:w              
        or (1|M0)                r9.3<1>:d     r2.1<0;1,0>:d     0:w               {I@2}
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r10.0<1>:hf   r8.0<0;1,0>:hf                   {$4.dst}
        mov (1|M0)               r10.1<1>:hf   r8.1<0;1,0>:hf                  
        mov (1|M0)               r13.0<1>:hf   r8.2<0;1,0>:hf                  
        send.slm (1|M0)          null     r12     r10:1   0x0            0x02000504           {A@2,$6} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r13.1<1>:hf   r8.3<0;1,0>:hf                  
        mov (1|M0)               r6.0<1>:hf    r8.4<0;1,0>:hf                  
        mov (1|M0)               r6.1<1>:hf    r8.5<0;1,0>:hf                  
        mov (1|M0)               r11.0<1>:hf   r8.6<0;1,0>:hf                  
        mov (1|M0)               r11.1<1>:hf   r8.7<0;1,0>:hf                  
        mov (1|M0)               r10.0<1>:hf   r8.8<0;1,0>:hf                   {$6.src}
        mov (1|M0)               r10.1<1>:hf   r8.9<0;1,0>:hf                  
        add (1|M0)               r12.0<1>:d    r4.7<0;1,0>:d     0x9080:uw             
        send.slm (1|M0)          null     r14     r13:1   0x0            0x02000504           {A@7,$7} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@5,$8} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r15     r11:1   0x0            0x02000504           {A@3,$9} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r12     r10:1   0x0            0x02000504           {A@1,$10} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r13.0<1>:hf   r8.10<0;1,0>:hf                  {$7.src}
        mov (1|M0)               r13.1<1>:hf   r8.11<0;1,0>:hf                 
        add (1|M0)               r14.0<1>:d    r4.7<0;1,0>:d     0x90A0:uw             
        mov (1|M0)               r6.0<1>:hf    r8.12<0;1,0>:hf                  {$8.src}
        mov (1|M0)               r6.1<1>:hf    r8.13<0;1,0>:hf                 
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x90C0:uw             
        addc (1|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r9.2<0;1,0>:ud   {AccWrEn,$10.src}
        send.slm (1|M0)          null     r14     r13:1   0x0            0x02000504           {A@3,$11} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@1,$12} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r7.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r4.4<0;0>:d       r9.3<0>:d        {I@1}
        mov (1|M0)               r11.0<1>:hf   r8.14<0;1,0>:hf                  {$9.src}
        mov (1|M0)               r11.1<1>:hf   r8.15<0;1,0>:hf                 
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$13} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        add (1|M0)               r15.0<1>:d    r4.7<0;1,0>:d     0x90E0:uw             
        add (1|M0)               r4.7<1>:d     r3.3<0;1,0>:d     1536:w              
        send.slm (1|M0)          null     r15     r11:1   0x0            0x02000504           {A@2,$14} // wr:1+1, rd:0; store.slm.d32.a32
        or (1|M0)                r4.7<1>:d     r4.7<0;1,0>:d     r1.3<0;1,0>:d    {I@1}
        add (1|M0)               r12.0<1>:d    r4.7<0;1,0>:d     0x9000:uw              {I@1}
        add (1|M0)               r14.0<1>:d    r4.7<0;1,0>:d     0x9020:uw              {$11.src}
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x9040:uw              {$13.src}
        add (1|M0)               r15.0<1>:d    r4.7<0;1,0>:d     0x9060:uw              {$14.src}
        mov (1|M0)               r11.0<1>:hf   r8.0<0;1,0>:hf                   {$13.dst}
        mov (1|M0)               r11.1<1>:hf   r8.1<0;1,0>:hf                  
        mov (1|M0)               r13.0<1>:hf   r8.2<0;1,0>:hf                  
        send.slm (1|M0)          null     r12     r11:1   0x0            0x02000504           {A@2,$15} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r13.1<1>:hf   r8.3<0;1,0>:hf                  
        mov (1|M0)               r6.0<1>:hf    r8.4<0;1,0>:hf                  
        mov (1|M0)               r6.1<1>:hf    r8.5<0;1,0>:hf                  
        mov (1|M0)               r10.0<1>:hf   r8.6<0;1,0>:hf                  
        mov (1|M0)               r10.1<1>:hf   r8.7<0;1,0>:hf                  
        mov (1|M0)               r11.0<1>:hf   r8.8<0;1,0>:hf                   {$15.src}
        mov (1|M0)               r11.1<1>:hf   r8.9<0;1,0>:hf                  
        add (1|M0)               r12.0<1>:d    r4.7<0;1,0>:d     0x9080:uw             
        send.slm (1|M0)          null     r14     r13:1   0x0            0x02000504           {A@4,$0} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@3,$1} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r15     r10:1   0x0            0x02000504           {A@2,$2} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r12     r11:1   0x0            0x02000504           {A@1,$3} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r13.0<1>:hf   r8.10<0;1,0>:hf                  {$0.src}
        mov (1|M0)               r13.1<1>:hf   r8.11<0;1,0>:hf                 
        add (1|M0)               r14.0<1>:d    r4.7<0;1,0>:d     0x90A0:uw             
        addc (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    0x20:ud              {AccWrEn,$3.src}
        send.slm (1|M0)          null     r14     r13:1   0x0            0x02000504           {A@1,$4} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r4.5<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.5<1>:d     r12.0<0;0>:d      r4.4<0;0>:d       0:w               {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:hf    r8.12<0;1,0>:hf                  {$1.src}
        mov (1|M0)               r6.1<1>:hf    r8.13<0;1,0>:hf                 
        add (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     0x90C0:uw             
        mov (1|M0)               r16.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r16.1<1>:d    r14.0<0;0>:d      r1.5<0;0>:d       r4.6<0>:d        {I@2}
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@2,$5} // wr:1+1, rd:0; store.slm.d32.a32
        sync.nop                             null                             {Compacted,$5.src}
        send.ugm (1|M0)          r6       r16     null:0  0x0            0x0210B780           {A@1,$6} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r10.0<1>:hf   r8.14<0;1,0>:hf                  {$2.src}
        mov (1|M0)               r10.1<1>:hf   r8.15<0;1,0>:hf                 
        add (1|M0)               r15.0<1>:d    r4.7<0;1,0>:d     0x90E0:uw             
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     0x9000:uw             
        send.slm (1|M0)          null     r15     r10:1   0x0            0x02000504           {A@1,$7} // wr:1+1, rd:0; store.slm.d32.a32
        add (1|M0)               r13.0<1>:d    r1.2<0;1,0>:d     0x9040:uw             
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     0x9020:uw              {$7.src}
        add (1|M0)               r15.0<1>:d    r1.2<0;1,0>:d     0x9060:uw             
        mov (1|M0)               r7.0<1>:hf    r6.0<0;1,0>:hf                   {$6.dst}
        mov (1|M0)               r7.1<1>:hf    r6.1<0;1,0>:hf                  
        mov (1|M0)               r8.0<1>:hf    r6.2<0;1,0>:hf                  
        send.slm (1|M0)          null     r2      r7:1    0x0            0x02000504           {A@2,$8} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r8.1<1>:hf    r6.3<0;1,0>:hf                  
        mov (1|M0)               r12.0<1>:hf   r6.4<0;1,0>:hf                  
        mov (1|M0)               r12.1<1>:hf   r6.5<0;1,0>:hf                  
        mov (1|M0)               r14.0<1>:hf   r6.6<0;1,0>:hf                  
        mov (1|M0)               r14.1<1>:hf   r6.7<0;1,0>:hf                  
        mov (1|M0)               r2.0<1>:hf    r6.8<0;1,0>:hf                   {$8.src}
        mov (1|M0)               r2.1<1>:hf    r6.9<0;1,0>:hf                  
        add (1|M0)               r7.0<1>:d     r1.2<0;1,0>:d     0x9080:uw             
        send.slm (1|M0)          null     r10     r8:1    0x0            0x02000504           {A@3,$9} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r13     r12:1   0x0            0x02000504           {A@5,$10} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r15     r14:1   0x0            0x02000504           {A@2,$11} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r2:1    0x0            0x02000504           {A@1,$12} // wr:1+1, rd:0; store.slm.d32.a32
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,$12.src}
        mov (1|M0)               r8.0<1>:hf    r6.10<0;1,0>:hf                  {$9.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.1<1>:hf    r6.11<0;1,0>:hf                 
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     0x90A0:uw             
        mov (1|M0)               r16.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r16.1<1>:d    r7.0<0;0>:d       r1.5<0;0>:d       r5.1<0>:d        {I@2}
        send.slm (1|M0)          null     r10     r8:1    0x0            0x02000504           {A@2,$13} // wr:1+1, rd:0; store.slm.d32.a32
        sync.nop                             null                             {Compacted,$13.src}
        send.ugm (1|M0)          r8       r16     null:0  0x0            0x0210B780           {A@1,$14} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        add (1|M0)               r6.0<1>:d     r4.3<0;1,0>:d     0x9000:uw             
        mov (1|M0)               r12.0<1>:hf   r6.12<0;1,0>:hf                  {$10.src}
        mov (1|M0)               r12.1<1>:hf   r6.13<0;1,0>:hf                 
        add (1|M0)               r13.0<1>:d    r1.2<0;1,0>:d     0x90C0:uw             
        mov (1|M0)               r14.0<1>:hf   r6.14<0;1,0>:hf                  {$11.src}
        mov (1|M0)               r14.1<1>:hf   r6.15<0;1,0>:hf                 
        add (1|M0)               r15.0<1>:d    r1.2<0;1,0>:d     0x90E0:uw             
        send.slm (1|M0)          null     r13     r12:1   0x0            0x02000504           {A@2,$15} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r15     r14:1   0x0            0x02000504           {A@1,$0} // wr:1+1, rd:0; store.slm.d32.a32
        add (1|M0)               r5.0<1>:d     r4.3<0;1,0>:d     0x9040:uw             
        add (1|M0)               r13.0<1>:d    r4.3<0;1,0>:d     0x9020:uw              {$15.src}
        add (1|M0)               r14.0<1>:d    r4.3<0;1,0>:d     0x9060:uw              {$0.src}
        add (1|M0)               r1.2<1>:d     r3.3<0;1,0>:d     3072:w              
        add (1|M0)               r3.3<1>:d     r3.3<0;1,0>:d     3584:w              
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        or (1|M0)                r3.3<1>:d     r3.3<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r10.0<1>:hf   r8.0<0;1,0>:hf                   {$14.dst}
        mov (1|M0)               r10.1<1>:hf   r8.1<0;1,0>:hf                  
        mov (1|M0)               r12.0<1>:hf   r8.2<0;1,0>:hf                  
        send.slm (1|M0)          null     r6      r10:1   0x0            0x02000504           {A@2,$1} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r12.1<1>:hf   r8.3<0;1,0>:hf                  
        mov (1|M0)               r2.0<1>:hf    r8.4<0;1,0>:hf                  
        mov (1|M0)               r2.1<1>:hf    r8.5<0;1,0>:hf                  
        mov (1|M0)               r7.0<1>:hf    r8.6<0;1,0>:hf                  
        mov (1|M0)               r7.1<1>:hf    r8.7<0;1,0>:hf                  
        mov (1|M0)               r6.0<1>:hf    r8.8<0;1,0>:hf                   {$1.src}
        mov (1|M0)               r6.1<1>:hf    r8.9<0;1,0>:hf                  
        add (1|M0)               r10.0<1>:d    r4.3<0;1,0>:d     0x9080:uw             
        send.slm (1|M0)          null     r13     r12:1   0x0            0x02000504           {A@7,$2} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r5      r2:1    0x0            0x02000504           {A@5,$3} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r14     r7:1    0x0            0x02000504           {A@3,$4} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r10     r6:1    0x0            0x02000504           {A@1,$5} // wr:1+1, rd:0; store.slm.d32.a32
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn,$5.src}
        mov (1|M0)               r12.0<1>:hf   r8.10<0;1,0>:hf                  {$2.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.1<1>:hf   r8.11<0;1,0>:hf                 
        add (1|M0)               r13.0<1>:d    r4.3<0;1,0>:d     0x90A0:uw             
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r1.5<0;0>:d       r9.1<0>:d        {I@2}
        send.slm (1|M0)          null     r13     r12:1   0x0            0x02000504           {A@2,$6} // wr:1+1, rd:0; store.slm.d32.a32
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r12      r15     null:0  0x0            0x0210B780           {A@1,$7} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r2.0<1>:hf    r8.12<0;1,0>:hf                  {$3.src}
        mov (1|M0)               r2.1<1>:hf    r8.13<0;1,0>:hf                 
        add (1|M0)               r5.0<1>:d     r4.3<0;1,0>:d     0x90C0:uw             
        mov (1|M0)               r7.0<1>:hf    r8.14<0;1,0>:hf                  {$4.src}
        send.slm (1|M0)          null     r5      r2:1    0x0            0x02000504           {A@1,$8} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r7.1<1>:hf    r8.15<0;1,0>:hf                 
        add (1|M0)               r14.0<1>:d    r4.3<0;1,0>:d     0x90E0:uw             
        add (1|M0)               r5.0<1>:d     r1.2<0;1,0>:d     0x9000:uw              {$8.src}
        send.slm (1|M0)          null     r14     r7:1    0x0            0x02000504           {A@1,$9} // wr:1+1, rd:0; store.slm.d32.a32
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     0x9020:uw             
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     0x9040:uw             
        add (1|M0)               r13.0<1>:d    r1.2<0;1,0>:d     0x9060:uw             
        mov (1|M0)               r2.0<1>:hf    r12.0<0;1,0>:hf                  {$7.dst}
        mov (1|M0)               r2.1<1>:hf    r12.1<0;1,0>:hf                 
        mov (1|M0)               r7.0<1>:hf    r12.2<0;1,0>:hf                  {$9.src}
        send.slm (1|M0)          null     r5      r2:1    0x0            0x02000504           {A@2,$10} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r7.1<1>:hf    r12.3<0;1,0>:hf                 
        mov (1|M0)               r6.0<1>:hf    r12.4<0;1,0>:hf                 
        mov (1|M0)               r6.1<1>:hf    r12.5<0;1,0>:hf                 
        mov (1|M0)               r10.0<1>:hf   r12.6<0;1,0>:hf                 
        mov (1|M0)               r10.1<1>:hf   r12.7<0;1,0>:hf                 
        mov (1|M0)               r2.0<1>:hf    r12.8<0;1,0>:hf                  {$10.src}
        mov (1|M0)               r2.1<1>:hf    r12.9<0;1,0>:hf                 
        add (1|M0)               r5.0<1>:d     r1.2<0;1,0>:d     0x9080:uw             
        send.slm (1|M0)          null     r8      r7:1    0x0            0x02000504           {A@4,$11} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000504           {A@3,$12} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r13     r10:1   0x0            0x02000504           {A@2,$13} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r5      r2:1    0x0            0x02000504           {A@1,$14} // wr:1+1, rd:0; store.slm.d32.a32
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   r9.2<0;1,0>:ud   {AccWrEn,$14.src}
        mov (1|M0)               r7.0<1>:hf    r12.10<0;1,0>:hf                 {$11.src}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.1<1>:hf    r12.11<0;1,0>:hf                
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     0x90A0:uw             
        mov (1|M0)               r14.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r5.0<0;0>:d       r1.5<0;0>:d       r9.3<0>:d        {I@2}
        send.slm (1|M0)          null     r8      r7:1    0x0            0x02000504           {A@2,$15} // wr:1+1, rd:0; store.slm.d32.a32
        sync.nop                             null                             {Compacted,$15.src}
        send.ugm (1|M0)          r7       r14     null:0  0x0            0x0210B780           {A@1,$0} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r6.0<1>:hf    r12.12<0;1,0>:hf                 {$12.src}
        mov (1|M0)               r6.1<1>:hf    r12.13<0;1,0>:hf                
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     0x90C0:uw             
        mov (1|M0)               r10.0<1>:hf   r12.14<0;1,0>:hf                 {$13.src}
        mov (1|M0)               r10.1<1>:hf   r12.15<0;1,0>:hf                
        add (1|M0)               r13.0<1>:d    r1.2<0;1,0>:d     0x90E0:uw             
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000504           {A@2,$1} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r13     r10:1   0x0            0x02000504           {A@1,$2} // wr:1+1, rd:0; store.slm.d32.a32
        add (1|M0)               r12.0<1>:d    r3.3<0;1,0>:d     0x9060:uw             
        add (1|M0)               r11.0<1>:d    r3.3<0;1,0>:d     0x9020:uw             
        add (1|M0)               r5.0<1>:d     r3.3<0;1,0>:d     0x9040:uw             
        add (1|M0)               r8.0<1>:d     r3.3<0;1,0>:d     0x9000:uw             
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r6.0<1>:hf    r7.0<0;1,0>:hf                   {$0.dst}
        mov (1|M0)               r6.1<1>:hf    r7.1<0;1,0>:hf                  
        mov (1|M0)               r10.0<1>:hf   r7.2<0;1,0>:hf                   {$2.src}
        mov (1|M0)               r10.1<1>:hf   r7.3<0;1,0>:hf                  
        mov (1|M0)               r2.0<1>:hf    r7.4<0;1,0>:hf                  
        mov (1|M0)               r2.1<1>:hf    r7.5<0;1,0>:hf                  
        mov (1|M0)               r9.0<1>:hf    r7.6<0;1,0>:hf                  
        mov (1|M0)               r9.1<1>:hf    r7.7<0;1,0>:hf                  
        send.slm (1|M0)          null     r8      r6:1    0x0            0x02000504           {A@1,$3} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r11     r10:1   0x0            0x02000504           {A@5,$4} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r5      r2:1    0x0            0x02000504           {A@3,$5} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r12     r9:1    0x0            0x02000504           {A@1,$6} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r6.0<1>:hf    r7.8<0;1,0>:hf                   {$3.src}
        mov (1|M0)               r6.1<1>:hf    r7.9<0;1,0>:hf                  
        add (1|M0)               r8.0<1>:d     r3.3<0;1,0>:d     0x9080:uw             
        mov (1|M0)               r10.0<1>:hf   r7.10<0;1,0>:hf                  {$4.src}
        mov (1|M0)               r10.1<1>:hf   r7.11<0;1,0>:hf                 
        add (1|M0)               r11.0<1>:d    r3.3<0;1,0>:d     0x90A0:uw             
        mov (1|M0)               r2.0<1>:hf    r7.12<0;1,0>:hf                  {$5.src}
        mov (1|M0)               r2.1<1>:hf    r7.13<0;1,0>:hf                 
        add (1|M0)               r5.0<1>:d     r3.3<0;1,0>:d     0x90C0:uw             
        mov (1|M0)               r9.0<1>:hf    r7.14<0;1,0>:hf                  {$6.src}
        mov (1|M0)               r9.1<1>:hf    r7.15<0;1,0>:hf                 
        add (1|M0)               r12.0<1>:d    r3.3<0;1,0>:d     0x90E0:uw             
        send.slm (1|M0)          null     r8      r6:1    0x0            0x02000504           {A@4,$7} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r11     r10:1   0x0            0x02000504           {A@3,$8} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r5      r2:1    0x0            0x02000504           {A@2,$9} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r12     r9:1    0x0            0x02000504           {A@1,$10} // wr:1+1, rd:0; store.slm.d32.a32
        sync.nop                             null                             {Compacted,$7.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$11} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r8.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r8.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r8      null:0  0x0            0x02000004           {A@2,$12} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:w     r4.8<0;1,0>:b     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L11960                  L11960                
L9032:
        shl (1|M0)               r1.5<1>:d     r96.7<0;1,0>:d    3:w              
        shr (1|M0)               r1.6<1>:ud    r96.6<0;1,0>:ud   0x1D:uw             
        mov (2|M0)               r4.8<1>:w     0x1010101:v                              
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r87.0<0;1,0>:ud  {AccWrEn,$9.src}
        shl (1|M0)               r4.2<1>:d     r96.6<0;1,0>:d    3:w              
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     r1.6<0;1,0>:d    {I@4}
        mul (2|M0)               r6.0<1>:d     r4.8<1;1,0>:w     16:w               {I@4}
        mov (2|M0)               r7.8<1>:w     0x8080808:uv                             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (2|M0)               r6.0<1>:d     r4.2<1;1,0>:d     r6.0<1;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r87.1<0>:d       {I@2}
        and (2|M0)               r4.2<1>:d     r4.2<1;1,0>:d     r7.8<1;1,0>:w   
        shl (1|M0)               r5.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:ud    r96.1<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r2.1<1>:d     r6.1<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$10.src}
        shl (1|M0)               r9.0<1>:d     r4.2<0;1,0>:d     1:w               {Compacted,I@5}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@5}
        shl (1|M0)               r3.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r4.4<1>:ud    r4.2<0;1,0>:ud    0x1F:uw             
        and (1|M0)               r71.1<1>:ud   r1.4<0;1,0>:ud    0x7FFE00:ud              {I@7}
        or (1|M0)                r5.1<1>:d     r2.1<0;1,0>:d     r2.7<0;1,0>:d    {I@6}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r10.0<1>:ud   r7.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r9.1<1>:d     r3.3<0;1,0>:d     r4.4<0;1,0>:d    {I@5}
        shl (1|M0)               r1.2<1>:d     r71.1<0;1,0>:d    1:w               {I@5}
        or (1|M0)                r4.2<1>:ud    r71.1<0;1,0>:ud   0x20:uw             
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r5.1<0>:d        {I@5}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r10.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r10.2<1>:d    r6.0<0;0>:d       r7.2<0;0>:d       r9.1<0>:d        {I@2}
        shl (1|M0)               r6.0<1>:d     r4.2<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r71.1<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r3.3<1>:ud    r4.2<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r10.0<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.3<1>:d     r2.1<0;1,0>:d     0:w               {I@4}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r11.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r13.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r11.1<1>:d    r8.0<0;0>:d       r10.2<0;0>:d      r1.3<0>:d        {I@3}
        add3 (1|M0)              r13.1<1>:d    r9.0<0;0>:d       r10.2<0;0>:d      r6.1<0>:d        {I@2}
        send.ugm (1|M0)          r12      r11     null:0  0x0            0x02109780           {A@2,$13} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$14} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        shl (1|M0)               r2.0<1>:ud    r96.1<0;1,0>:ud   0x8:uw             
        or (1|M0)                r1.2<1>:ud    r71.1<0;1,0>:ud   0x40:uw             
        or (1|M0)                r9.4<1>:ud    r71.1<0;1,0>:ud   0x60:uw             
        add (1|M0)               r8.0<1>:ud    r2.0<0;1,0>:ud    0xA000:uw              {I@3}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r11.0<1>:ud   r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w               {I@4}
        mov (1|M0)               r6.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r10.2<0;0>:d      r4.3<0>:d        {I@1}
        or (1|M0)                r1.2<1>:ud    r71.1<0;1,0>:ud   0x80:uw             
        send.ugm (1|M0)          r9       r6      null:0  0x0            0x02109780           {A@1,$15} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0xA020:uw              {$15.src}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r1.2<1>:ud    r71.1<0;1,0>:ud   0xC0:uw             
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w               {I@2}
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw              {I@2}
        mov (8|M0)               r5.0<2>:uw    r12.0<1;1,0>:uw                  {$13.dst}
        mov (8|M0)               r5.1<2>:uw    r14.0<1;1,0>:uw                  {$14.dst}
        send.slm (1|M0)          null     r8      r5:1    0x0            0x0200B704           {A@1,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$0.src}
        shl (1|M0)               r5.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$15.dst}
        or (1|M0)                r5.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted}
        addc (1|M0)              r8.0<1>:ud    r10.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r9.4<1>:ud    r71.1<0;1,0>:ud   0xA0:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r5.1<0>:d        {I@1}
        addc (1|M0)              r7.0<1>:ud    r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$1} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<2>:uw   r9.0<1;1,0>:uw                  
        or (1|M0)                r6.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@3}
        mov (1|M0)               r5.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r5.1<1>:d     r8.0<0;0>:d       r10.2<0;0>:d      r4.3<0>:d        {I@3}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r9       r5      null:0  0x0            0x02109780           {A@1,$2} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r5.0<1>:ud    r2.0<0;1,0>:ud    0xA040:uw              {$2.src}
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w              
        or (1|M0)                r1.2<1>:ud    r71.1<0;1,0>:ud   0x100:uw             
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw              {I@1}
        mov (8|M0)               r11.1<2>:uw   r14.0<1;1,0>:uw                  {$1.dst}
        send.slm (1|M0)          null     r6      r11:1   0x0            0x0200B704           {A@1,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$3.src}
        shl (1|M0)               r6.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$2.dst}
        or (1|M0)                r9.4<1>:ud    r71.1<0;1,0>:ud   0xE0:uw             
        addc (1|M0)              r11.0<1>:ud   r10.0<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw              {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r6.1<0>:d        {I@1}
        mov (8|M0)               r7.0<2>:uw    r9.0<1;1,0>:uw                  
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$4} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r8.0<1>:ud    r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r5.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r11.0<0;0>:d      r10.2<0;0>:d      r4.3<0>:d        {I@1}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r9       r6      null:0  0x0            0x02109780           {A@1,$5} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0xA060:uw              {$5.src}
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w              
        or (1|M0)                r1.2<1>:ud    r71.1<0;1,0>:ud   0x140:uw             
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw              {I@1}
        mov (8|M0)               r7.1<2>:uw    r14.0<1;1,0>:uw                  {$4.dst}
        send.slm (1|M0)          null     r5      r7:1    0x0            0x0200B704           {A@1,$6} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$6.src}
        shl (1|M0)               r5.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$5.dst}
        or (1|M0)                r9.4<1>:ud    r71.1<0;1,0>:ud   0x120:uw             
        addc (1|M0)              r7.0<1>:ud    r10.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw              {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r5.1<0>:d        {I@1}
        mov (8|M0)               r8.0<2>:uw    r9.0<1;1,0>:uw                  
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$7} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r11.0<1>:ud   r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r6.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r5.1<1>:d     r7.0<0;0>:d       r10.2<0;0>:d      r4.3<0>:d        {I@1}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r9       r5      null:0  0x0            0x02109780           {A@1,$11} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r5.0<1>:ud    r2.0<0;1,0>:ud    0xA080:uw              {$11.src}
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w              
        or (1|M0)                r1.2<1>:ud    r1.4<0;1,0>:ud    0x180:uw             
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw              {I@1}
        mov (8|M0)               r8.1<2>:uw    r14.0<1;1,0>:uw                  {$7.dst}
        send.slm (1|M0)          null     r6      r8:1    0x0            0x0200B704           {A@1,$13} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$13.src}
        shl (1|M0)               r6.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$11.dst}
        or (1|M0)                r9.4<1>:ud    r71.1<0;1,0>:ud   0x160:uw             
        addc (1|M0)              r8.0<1>:ud    r10.0<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw              {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r6.1<0>:d        {I@1}
        mov (8|M0)               r11.0<2>:uw   r9.0<1;1,0>:uw                  
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$14} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r7.0<1>:ud    r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r5.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r8.0<0;0>:d       r10.2<0;0>:d      r4.3<0>:d        {I@1}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r9       r6      null:0  0x0            0x02109780           {A@1,$15} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0xA0A0:uw              {$15.src}
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w              
        or (1|M0)                r1.2<1>:ud    r1.4<0;1,0>:ud    0x1C0:uw             
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1F:uw              {I@1}
        mov (8|M0)               r11.1<2>:uw   r14.0<1;1,0>:uw                  {$14.dst}
        send.slm (1|M0)          null     r5      r11:1   0x0            0x0200B704           {A@1,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$0.src}
        shl (1|M0)               r5.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$15.dst}
        or (1|M0)                r9.4<1>:ud    r1.4<0;1,0>:ud    0x1A0:uw             
        addc (1|M0)              r11.0<1>:ud   r10.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw              {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r5.1<0>:d        {I@1}
        mov (8|M0)               r7.0<2>:uw    r9.0<1;1,0>:uw                  
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$1} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r8.0<1>:ud    r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r6.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r5.1<1>:d     r11.0<0;0>:d      r10.2<0;0>:d      r4.3<0>:d        {I@1}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r9       r5      null:0  0x0            0x02109780           {A@1,$2} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r5.0<1>:ud    r2.0<0;1,0>:ud    0xA0C0:uw              {$2.src}
        or (1|M0)                r4.3<1>:d     r1.5<0;1,0>:d     0:w              
        mov (8|M0)               r7.1<2>:uw    r14.0<1;1,0>:uw                  {$1.dst}
        send.slm (1|M0)          null     r6      r7:1    0x0            0x0200B704           {A@1,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$3.src}
        shl (1|M0)               r6.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$2.dst}
        or (1|M0)                r9.4<1>:ud    r1.4<0;1,0>:ud    0x1E0:uw             
        addc (1|M0)              r7.0<1>:ud    r10.0<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.4<0;1,0>:ud    0x1F:uw              {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r6.1<0>:d        {I@1}
        mov (8|M0)               r8.0<2>:uw    r9.0<1;1,0>:uw                  
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$4} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        addc (1|M0)              r11.0<1>:ud   r10.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r5.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r10.2<0;0>:d      r4.3<0>:d        {I@1}
        send.ugm (1|M0)          r9       r6      null:0  0x0            0x02109780           {A@1,$5} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        add (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0xA0E0:uw              {$5.src}
        mov (8|M0)               r8.1<2>:uw    r14.0<1;1,0>:uw                  {$4.dst}
        send.slm (1|M0)          null     r5      r8:1    0x0            0x0200B704           {A@1,$6} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$6.src}
        shl (1|M0)               r5.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted,$5.dst}
        addc (1|M0)              r8.0<1>:ud    r10.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.2<0;0>:d      r5.1<0>:d        {I@1}
        mov (8|M0)               r11.0<2>:uw   r9.0<1;1,0>:uw                  
        send.ugm (1|M0)          r14      r13     null:0  0x0            0x02109780           {A@1,$7} // wr:1+0, rd:1; load.ugm.d64x2t.a64
        mov (8|M0)               r11.1<2>:uw   r14.0<1;1,0>:uw                  {$7.dst}
        send.slm (1|M0)          null     r6      r11:1   0x0            0x0200B704           {A@1,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
        goto (16|M0)                         L11960                  L12008                
L11960:
        join (16|M0)                         L12008                                
L11976:
        shl (1|M0)               r71.1<1>:ud   r96.1<0;1,0>:ud   0x7:uw             
        and (1|M0)               r71.1<1>:ud   r71.1<0;1,0>:ud   0x7FFE00:ud              {I@1}
L12008:
        join (16|M0)                         L12024                                
L12024:
        cmp (1|M0)    (lt)f0.1   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
        shl (1|M0)               r1.2<1>:ud    r96.1<0;1,0>:ud   0x6:uw             
        shr (1|M0)               r4.2<1>:ud    r96.1<0;1,0>:ud   0x2:uw             
        bfn.0xEA (1|M0)          r71.1<1>:ud   r71.1<0;0>:ud     r1.2<0;0>:ud      0xC0:uw              {I@2} // s0|s1&s2
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        and (1|M0)               r1.3<1>:ud    r1.2<0;1,0>:ud    0xC0:uw             
        shl (1|M0)               r71.1<1>:ud   r71.1<0;1,0>:ud   0x1:uw              {I@3}
        shl (1|M0)               r15.0<1>:ud   r1.3<0;1,0>:ud    0x1:uw              {I@2}
        add (1|M0)               r71.0<1>:ud   r71.1<0;1,0>:ud   0x8000:uw              {I@2}
(~f0.0.any16h) goto (16|M0)                  L12296                  L12296                
L12184:
        sync.nop                             null                             {Compacted,$9.src}
        or (1|M0)                r2.0<1>:ud    r15.0<0;1,0>:ud   0x9000:uw              {I@3}
        sync.nop                             null                             {Compacted,$12.src}
        send.slm (1|M0)          r5       r71     null:0  0x0            0x0240D700           {A@3,$13} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r9       r2      null:0  0x0            0x0240D700           {A@1,$14} // wr:1+0, rd:4; load.slm.d64x16t.a32
        or (1|M0)                r13.0<1>:ud   r15.0<0;1,0>:ud   0x1000:uw             
        send.slm (1|M0)          null     r15     r5:4    0x0            0x0200D704           {$13} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r13     r9:4    0x0            0x0200D704           {A@1,$14} // wr:1+4, rd:0; store.slm.d64x16t.a32
L12296:
        join (16|M0)                         L12312                                
L12312:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r1.8<1>:hf    0.0:hf                             
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L12712                  L12712                
L12392:
        cmp (1|M0)    (lt)f1.1   null<1>:uw    r1.0<0;1,0>:uw    0xC:uw             
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L12568                  L12568                
L12440:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.2<0;1,0>:d     3:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12568                  L12904                
L12488:
        mov (1|M0)               r1.5<1>:d     1536:w                              
        mov (1|M0)               r1.3<1>:d     0x9600:uw                             
        mov (1|M0)               r1.2<1>:d     5632:w                              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        goto (16|M0)                         L12568                  L12776                
L12568:
        join (16|M0)                         L12712                                
L12584:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.2<0;1,0>:d     2:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12712                  L12904                
L12632:
        mov (1|M0)               r1.5<1>:d     1024:w                              
        mov (1|M0)               r1.3<1>:d     0x9400:uw                             
        mov (1|M0)               r1.2<1>:d     5120:w                              
(W)     mov (1|M0)               r1.8<1>:hf    0x1:hf                             
        goto (16|M0)                         L12712                  L12776                
L12712:
        join (16|M0)                         L12776                                
L12728:
        mov (1|M0)               r1.5<1>:d     512:w                              
        mov (1|M0)               r1.3<1>:d     0x9200:uw                             
        mov (1|M0)               r1.2<1>:d     4608:w                              
L12776:
        join (16|M0)                         L12904                                
L12792:
        sync.allrd                           ($10,$14)                
        or (1|M0)                r9.0<1>:ud    r15.0<0;1,0>:ud   r1.3<0;1,0>:ud   {Compacted,I@3}
        sync.nop                             null                             {Compacted,$12.src}
        send.slm (1|M0)          r5       r71     null:0  0x0            0x0240D700           {$15} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r10      r9      null:0  0x0            0x0240D700           {A@1,$0} // wr:1+0, rd:4; load.slm.d64x16t.a32
        or (1|M0)                r2.0<1>:ud    r15.0<0;1,0>:ud   r1.5<0;1,0>:ud   {Compacted,$9.src}
        or (1|M0)                r14.0<1>:ud   r15.0<0;1,0>:ud   r1.2<0;1,0>:ud   {Compacted}
        send.slm (1|M0)          null     r2      r5:4    0x0            0x0200D704           {A@2,$15} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r14     r10:4   0x0            0x0200D704           {A@1,$0} // wr:1+4, rd:0; store.slm.d64x16t.a32
L12904:
        join (16|M0)                         L12920                                
L12920:
        and (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw    3:w              
        sync.allrd                           ($9,$13,$15)                
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$1} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$11.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$1.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$2} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r71.0<1>:d    r4.2<0;1,0>:d     9:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     9:w              
        add (1|M0)               r16.0<1>:ud   r71.1<0;1,0>:ud   0x8200:uw             
(~f0.1.any16h) goto (16|M0)                  L13248                  L13248                
L13112:
        or (1|M0)                r2.0<1>:ud    r15.0<0;1,0>:ud   0x9800:uw             
        sync.allrd                           ($2,$12)                
        send.slm (1|M0)          r5       r16     null:0  0x0            0x0240D700           {A@3,$3} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r9       r2      null:0  0x0            0x0240D700           {A@1,$4} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$0.src}
        or (1|M0)                r13.0<1>:ud   r15.0<0;1,0>:ud   0x800:uw              {$14.src}
        or (1|M0)                r14.0<1>:ud   r15.0<0;1,0>:ud   0x1800:uw             
        send.slm (1|M0)          null     r13     r5:4    0x0            0x0200D704           {A@2,$3} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r14     r9:4    0x0            0x0200D704           {A@1,$4} // wr:1+4, rd:0; store.slm.d64x16t.a32
L13248:
        join (16|M0)                         L13264                                
L13264:
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L13440                  L13440                
L13296:
        or (1|M0)                r2.0<1>:ud    r15.0<0;1,0>:ud   0x9A00:uw             
        sync.allrd                           ($2,$12)                
        send.slm (1|M0)          r5       r16     null:0  0x0            0x0240D700           {$5} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r9       r2      null:0  0x0            0x0240D700           {A@1,$6} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sync.allrd                           ($0,$3)                
        or (1|M0)                r13.0<1>:ud   r15.0<0;1,0>:ud   0xA00:uw              {$14.src}
        or (1|M0)                r14.0<1>:ud   r15.0<0;1,0>:ud   0x1A00:uw              {$4.src}
        send.slm (1|M0)          null     r13     r5:4    0x0            0x0200D704           {A@2,$5} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r14     r9:4    0x0            0x0200D704           {A@1,$6} // wr:1+4, rd:0; store.slm.d64x16t.a32
L13440:
        join (16|M0)                         L13456                                
L13456:
(W)     and (1|M0)               f0.0<1>:uw    r1.8<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L13640                  L13640                
L13488:
        or (1|M0)                r2.0<1>:ud    r15.0<0;1,0>:ud   0x9C00:uw             
        sync.allrd                           ($2,$12)                
        send.slm (1|M0)          r5       r16     null:0  0x0            0x0240D700           {$7} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r9       r2      null:0  0x0            0x0240D700           {A@1,$9} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sync.allrd                           ($0,$3,$5)                
        or (1|M0)                r13.0<1>:ud   r15.0<0;1,0>:ud   0xC00:uw              {$14.src}
        sync.nop                             null                             {Compacted,$6.src}
        or (1|M0)                r14.0<1>:ud   r15.0<0;1,0>:ud   0x1C00:uw              {$4.src}
        send.slm (1|M0)          null     r13     r5:4    0x0            0x0200D704           {A@2,$7} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r14     r9:4    0x0            0x0200D704           {A@1,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
L13640:
        join (16|M0)                         L13656                                
L13656:
(W)     and (1|M0)               f0.0<1>:uw    r1.3<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L13848                  L13848                
L13688:
        or (1|M0)                r2.0<1>:ud    r15.0<0;1,0>:ud   0x9E00:uw             
        sync.allrd                           ($2,$12)                
        send.slm (1|M0)          r5       r16     null:0  0x0            0x0240D700           {$11} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r9       r2      null:0  0x0            0x0240D700           {A@1,$13} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sync.allrd                           ($0,$3,$5,$7)                
        or (1|M0)                r13.0<1>:ud   r15.0<0;1,0>:ud   0xE00:uw              {$14.src}
        sync.allrd                           ($6,$9)                
        or (1|M0)                r14.0<1>:ud   r15.0<0;1,0>:ud   0x1E00:uw              {$4.src}
        send.slm (1|M0)          null     r13     r5:4    0x0            0x0200D704           {A@2,$11} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r14     r9:4    0x0            0x0200D704           {A@1,$13} // wr:1+4, rd:0; store.slm.d64x16t.a32
L13848:
        join (16|M0)                         L13864                                
L13864:
        or (1|M0)                r2.0<1>:d     r1.3<0;1,0>:d     4096:w              
        sync.allrd                           ($0,$3,$5,$7,$11)                
        or (1|M0)                r13.0<1>:ud   r71.0<0;1,0>:ud   0x100:uw              {$14.src}
        or (1|M0)                r30.0<1>:d    r1.3<0;1,0>:d     4352:w              
        sync.allrd                           ($2,$12)                
        send.slm (1|M0)          r5       r71     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r2      null:0  0x0            0x0280E700           {A@3,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r13     null:0  0x0            0x0280E700           {A@2,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r31      r30     null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (16|M0)              r39.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r41.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r43.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r45.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r47.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r49.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r51.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r53.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r55.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r57.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r59.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r61.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($0,$1,$3,$15)                
        dpas.8x8 (8|M0)          r39:f         null:f            r39:hf            r39.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r39:f         r39:f             r22:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r47:f         r47:f             r31:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r55:f         r55:f             r22:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r63:f         r63:f             r31:hf            r14.0:hf         {$15}
(W)     send.slm (1|M0)          r13      r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r30.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r30.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r13.0<1;1,0>:ud                  {$5.dst}
(W)     send.gtwy (1|M0)         null     r30     null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        add (1|M0)               r2.0<1>:ud    r71.0<0;1,0>:ud   0x800:uw             
        or (1|M0)                r5.0<1>:d     r1.3<0;1,0>:d     6144:w               {$15.src}
        or (1|M0)                r7.0<1>:d     r1.3<0;1,0>:d     6400:w              
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0x100:uw              {I@3}
        send.slm (1|M0)          r22      r2      null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r79      r5      null:0  0x0            0x0280E700           {A@3,$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r8       r7      null:0  0x0            0x0280E700           {A@2,$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r71      r6      null:0  0x0            0x0280E700           {A@1,$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($7,$8,$9,$10,$15)                
        dpas.8x8 (8|M0)          r39:f         r39:f             r79:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r47:f         r47:f             r8:hf             r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r55:f         r55:f             r79:hf            r71.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r63:f         r63:f             r8:hf             r71.0:hf         {$15}
(W)     send.slm (1|M0)          r16      r0      null:0  0x0            0x0210001F           {$11} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r17.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r17.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r16.0<1;1,0>:ud                  {$11.dst}
(W)     send.gtwy (1|M0)         null     r17     null:0  0x0            0x02000004           {A@2,$12} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     12:w              
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     6:w              
        or (1|M0)                r4.2<1>:d     r4.2<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
        add (1|M0)               r2.0<1>:d     r4.2<0;1,0>:d     8192:w               {I@1}
        add (1|M0)               r5.0<1>:d     r4.2<0;1,0>:d     8224:w              
        add (1|M0)               r6.0<1>:d     r4.2<0;1,0>:d     10240:w              
        add (1|M0)               r7.0<1>:d     r4.2<0;1,0>:d     10272:w              
        send.slm (1|M0)          null     r2      r39:1   0x0            0x0200B704           {A@4,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r5      r47:1   0x0            0x0200B704           {A@3,$13} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r55:1   0x0            0x0200B704           {A@2,$14} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r63:1   0x0            0x0200B704           {A@1,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        add (1|M0)               r8.0<1>:d     r4.2<0;1,0>:d     8448:w              
        add (1|M0)               r9.0<1>:d     r4.2<0;1,0>:d     8480:w              
        add (1|M0)               r10.0<1>:d    r4.2<0;1,0>:d     10496:w              
        add (1|M0)               r2.0<1>:d     r4.2<0;1,0>:d     10528:w               {$15.src}
        add (1|M0)               r5.0<1>:d     r4.2<0;1,0>:d     8704:w               {$13.src}
        add (1|M0)               r6.0<1>:d     r4.2<0;1,0>:d     8736:w               {$14.src}
        add (1|M0)               r7.0<1>:d     r4.2<0;1,0>:d     10752:w               {$0.src}
        send.slm (1|M0)          null     r8      r40:1   0x0            0x0200B704           {A@7,$1} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r48:1   0x0            0x0200B704           {A@6,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r56:1   0x0            0x0200B704           {A@5,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r2      r64:1   0x0            0x0200B704           {A@4,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r5      r41:1   0x0            0x0200B704           {A@3,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r49:1   0x0            0x0200B704           {A@2,$7} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r57:1   0x0            0x0200B704           {A@1,$8} // wr:1+1, rd:0; store.slm.d64x4t.a32
        add (1|M0)               r8.0<1>:d     r4.2<0;1,0>:d     10784:w               {$1.src}
        add (1|M0)               r9.0<1>:d     r4.2<0;1,0>:d     8960:w               {$2.src}
        add (1|M0)               r10.0<1>:d    r4.2<0;1,0>:d     8992:w               {$3.src}
        add (1|M0)               r2.0<1>:d     r4.2<0;1,0>:d     11008:w               {$4.src}
        add (1|M0)               r5.0<1>:d     r4.2<0;1,0>:d     11040:w               {$5.src}
        add (1|M0)               r6.0<1>:d     r4.2<0;1,0>:d     9216:w               {$7.src}
        add (1|M0)               r7.0<1>:d     r4.2<0;1,0>:d     9248:w               {$8.src}
        send.slm (1|M0)          null     r8      r65:1   0x0            0x0200B704           {A@7,$9} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r42:1   0x0            0x0200B704           {A@6,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r50:1   0x0            0x0200B704           {A@5,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r2      r58:1   0x0            0x0200B704           {A@4,$13} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r5      r66:1   0x0            0x0200B704           {A@3,$14} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r43:1   0x0            0x0200B704           {A@2,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r51:1   0x0            0x0200B704           {A@1,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        add (1|M0)               r8.0<1>:d     r4.2<0;1,0>:d     11264:w               {$9.src}
        add (1|M0)               r9.0<1>:d     r4.2<0;1,0>:d     11296:w               {$10.src}
        add (1|M0)               r10.0<1>:d    r4.2<0;1,0>:d     9472:w               {$11.src}
        add (1|M0)               r2.0<1>:d     r4.2<0;1,0>:d     9504:w               {$13.src}
        add (1|M0)               r5.0<1>:d     r4.2<0;1,0>:d     11520:w               {$14.src}
        add (1|M0)               r6.0<1>:d     r4.2<0;1,0>:d     11552:w               {$15.src}
        add (1|M0)               r7.0<1>:d     r4.2<0;1,0>:d     9728:w               {$0.src}
        send.slm (1|M0)          null     r8      r59:1   0x0            0x0200B704           {A@7,$1} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r67:1   0x0            0x0200B704           {A@6,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r44:1   0x0            0x0200B704           {A@5,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r2      r52:1   0x0            0x0200B704           {A@4,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r5      r60:1   0x0            0x0200B704           {A@3,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r68:1   0x0            0x0200B704           {A@2,$7} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r45:1   0x0            0x0200B704           {A@1,$8} // wr:1+1, rd:0; store.slm.d64x4t.a32
        add (1|M0)               r8.0<1>:d     r4.2<0;1,0>:d     9760:w               {$1.src}
        add (1|M0)               r9.0<1>:d     r4.2<0;1,0>:d     11776:w               {$2.src}
        add (1|M0)               r10.0<1>:d    r4.2<0;1,0>:d     11808:w               {$3.src}
        add (1|M0)               r2.0<1>:d     r4.2<0;1,0>:d     9984:w               {$4.src}
        add (1|M0)               r5.0<1>:d     r4.2<0;1,0>:d     10016:w               {$5.src}
        add (1|M0)               r6.0<1>:d     r4.2<0;1,0>:d     12032:w               {$7.src}
        add (1|M0)               r7.0<1>:d     r4.2<0;1,0>:d     12064:w               {$8.src}
        send.slm (1|M0)          null     r8      r53:1   0x0            0x0200B704           {A@7,$9} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r61:1   0x0            0x0200B704           {A@6,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r69:1   0x0            0x0200B704           {A@5,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r2      r46:1   0x0            0x0200B704           {A@4,$13} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r5      r54:1   0x0            0x0200B704           {A@3,$14} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r62:1   0x0            0x0200B704           {A@2,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r70:1   0x0            0x0200B704           {A@1,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$9.src}
(W)     send.slm (1|M0)          r8       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r9.2<1>:f     0.0:f                               {Compacted,$10.src}
(W)     mov (2|M0)               r9.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r8.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r9      null:0  0x0            0x02000004           {A@2,$1} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r87.3<1>:ud   r96.1<0;1,0>:ud   0x2:uw             
        shr (1|M0)               r87.5<1>:ud   r96.1<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r96.1<1>:ud   r96.1<0;1,0>:ud   0x1:uw             
        add (1|M0)               r87.5<1>:ud   r96.0<0;1,0>:ud   r87.5<0;1,0>:ud  {I@2}
        and (1|M0)               r96.1<1>:ud   r96.1<0;1,0>:ud   0x1FFF8:ud              {I@2}
        and (1|M0)               r87.5<1>:ud   r87.5<0;1,0>:ud   0x3FFFFFF:ud              {I@2}
        bfn.0xEA (1|M0)          r96.1<1>:ud   r96.1<0;0>:ud     r87.2<0;0>:ud     0x1:uw              {I@2} // s0|s1&s2
        mov (1|M0)               r87.2<1>:f    r3.2<0;1,0>:f                    {I@1}
        shl (1|M0)               r96.1<1>:ud   r96.1<0;1,0>:ud   0x8:uw             
        add (1|M0)               r96.1<1>:ud   r96.1<0;1,0>:ud   0x6000:uw              {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r96.4         L39080                                 {A@1}
L16000:
        shr (1|M0)               r1.2<1>:ud    r87.2<0;1,0>:ud   0x14:uw              {F@1}
        shl (1|M0)               r1.3<1>:d     r87.2<0;1,0>:d    12:w              
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@2}
        shl (1|M0)               r4.2<1>:d     r1.3<0;1,0>:d     2:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r1.3<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r87.7<1>:f    0x3D380000:f                              
        mov (1|M0)               r87.6<1>:f    0x3FA68000:f                              
        mov (1|M0)               r87.2<1>:d    0:w                              
        mov (1|M0)               r87.4<1>:d    r5.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r87.5<1>:d    r6.0<0;0>:d       r3.5<0;0>:d       r4.3<0>:d        {I@3}
L16208:
        or (1|M0)                r1.2<1>:ud    r87.2<0;1,0>:ud   r87.3<0;1,0>:ud  {I@3}
        add (1|M0)               r87.2<1>:ud   r87.2<0;1,0>:ud   0x1:uw             
        shl (1|M0)               r3.3<1>:ud    r1.2<0;1,0>:ud    0x6:uw              {I@2}
        shl (1|M0)               r1.3<1>:ud    r1.2<0;1,0>:ud    0x8:uw             
        and (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:ud    0xFC0:uw              {I@2}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r2.0<1>:ud    r1.3<0;1,0>:ud    0x2000:uw              {I@2}
        shl (1|M0)               r14.0<1>:d    r4.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r4.4<1>:ud    r4.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r15.0<1>:ud   r87.4<0;1,0>:ud   r14.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r14.1<1>:d    r4.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r17.0<1>:d    r15.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r17.1<1>:d    r16.0<0;0>:d      r87.5<0;0>:d      r14.1<0>:d       {I@2}
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0240D700           {$6} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.ugm (1|M0)          r18      r17     null:0  0x0            0x0240D780           {A@1,$7} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        add (1|M0)               r9.0<1>:ud    r1.3<0;1,0>:ud    0x2080:uw             
        addc (1|M0)              r2.0<1>:ud    r17.0<0;1,0>:ud   0x80:ud              {AccWrEn,$6.src}
        send.slm (1|M0)          r10      r9      null:0  0x0            0x0240D700           {A@2,$8} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r22.0<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r22.1<1>:d    r9.0<0;0>:d       r17.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0x5:uw             
        send.ugm (1|M0)          r23      r22     null:0  0x0            0x0240D780           {A@2,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        sync.nop                             null                             {Compacted,$7.dst}
        add (16|M0)              r27.0<1>:f    r7.0<1;1,0>:f     r20.0<1;1,0>:f   {Compacted,$6.dst}
        add (16|M0)              r29.0<1>:f    r5.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r14.0<1>:hf   r27.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r14.8<1>:hf   r28.0<1;1,0>:f                  
        mov (8|M0)               r15.0<1>:hf   r29.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r15.8<1>:hf   r30.0<1;1,0>:f                  
        mov (8|M0)               r5.0<1>:f     r14.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r6.0<1>:f     r14.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r35.0<1>:f    r15.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r36.0<1>:f    r15.8<1;1,0>:hf                  {F@4}
        mad (16|M0)              r5.0<1>:f     r87.6<0;0>:f      r5.0<1;0>:f       r87.7<0>:f       {F@3}
        sync.nop                             null                             {Compacted,$9.dst}
        add (16|M0)              r31.0<1>:f    r12.0<1;1,0>:f    r25.0<1;1,0>:f   {Compacted,$8.dst}
        add (16|M0)              r33.0<1>:f    r10.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted}
        mad (16|M0)              r35.0<1>:f    r87.6<0;0>:f      r35.0<1;0>:f      r87.7<0>:f       {F@4}
        mov (8|M0)               r8.0<1>:hf    r5.0<1;1,0>:f                    {F@4}
        mov (8|M0)               r8.8<1>:hf    r6.0<1;1,0>:f                   
        mov (8|M0)               r9.0<1>:hf    r31.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r9.8<1>:hf    r32.0<1;1,0>:f                  
        mov (8|M0)               r16.0<1>:hf   r33.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r16.8<1>:hf   r34.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r35.0<1;1,0>:f                   {F@7}
        mov (8|M0)               r7.8<1>:hf    r36.0<1;1,0>:f                  
        mov (8|M0)               r5.0<1>:f     r8.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r6.0<1>:f     r8.8<1;1,0>:hf                   {F@7}
        mov (8|M0)               r12.0<1>:f    r9.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r13.0<1>:f    r9.8<1;1,0>:hf                   {F@7}
        mov (8|M0)               r10.0<1>:f    r16.0<1;1,0>:hf                  {F@7}
        mov (8|M0)               r11.0<1>:f    r16.8<1;1,0>:hf                  {F@7}
        mov (8|M0)               r17.0<1>:f    r7.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r18.0<1>:f    r7.8<1;1,0>:hf                   {F@7}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r5.0<1;1,0>:f     1.03125:f               {F@7}
        mad (16|M0)              r12.0<1>:f    r87.6<0;0>:f      r12.0<1;0>:f      r87.7<0>:f       {F@6}
        mad (16|M0)              r10.0<1>:f    r87.6<0;0>:f      r10.0<1;0>:f      r87.7<0>:f       {F@5}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r17.0<1;1,0>:f    1.03125:f               {F@4}
        sel (16|M0)   (lt)f0.0   r5.0<1>:f     acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r15.0<1>:hf   r12.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r15.8<1>:hf   r13.0<1;1,0>:f                  
        mov (8|M0)               r14.0<1>:hf   r10.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r14.8<1>:hf   r11.0<1;1,0>:f                  
        sel (16|M0)   (lt)f0.0   r17.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r16.0<1>:ud   r5.1<2;1,0>:ud                   {F@6}
        mov (8|M0)               r13.0<1>:ud   r5.0<2;1,0>:ud                   {F@4}
        mov (8|M0)               r9.0<1>:f     r15.0<1;1,0>:hf                 
        mov (8|M0)               r10.0<1>:f    r15.8<1;1,0>:hf                 
        mov (8|M0)               r19.0<1>:f    r14.0<1;1,0>:hf                  {F@5}
        mov (8|M0)               r20.0<1>:f    r14.8<1;1,0>:hf                  {F@5}
        mov (8|M0)               r7.0<1>:ud    r17.1<2;1,0>:ud                  {F@5}
        mov (8|M0)               r11.0<1>:ud   r17.0<2;1,0>:ud                 
        mov (8|M0)               r15.0<2>:hf   r16.0<1;1,0>:f                   {I@4}
        mov (8|M0)               r14.0<2>:hf   r13.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r8.0<1>:hf    r7.0<1;1,0>:f                    {I@2}
        mov (8|M0)               r12.0<1>:hf   r11.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r8.8<1>:uw    r15.0<2;1,0>:uw                  {F@4}
        mov (8|M0)               r12.8<1>:uw   r14.0<2;1,0>:uw                  {F@3}
        mov (16|M0)              r17.0<1>:d    r8.0<1;1,0>:uw                   {A@2}
        shl (16|M0)              r24.0<1>:d    r12.0<1;1,0>:uw   5:w               {A@1}
        shl (16|M0)              r17.0<1>:d    r17.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    2146992128:d               {I@2}
        add (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    r17.0<1;1,0>:d   {Compacted,I@1}
        mov (8|M0)               r15.0<1>:f    r24.0<1;1,0>:hf                  {I@1}
        mov (8|M0)               r16.0<1>:f    r24.8<1;1,0>:hf                 
        add (1|M0)               r1.3<1>:f     r15.0<0;1,0>:f    r15.1<0;1,0>:f   {F@2}
        mov (8|M0)               r13.0<1>:f    r25.0<1;1,0>:hf                 
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r15.2<0;1,0>:f   {F@2}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r9.0<1;1,0>:f     1.03125:f              
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r15.3<0;1,0>:f   {F@2}
        mov (8|M0)               r14.0<1>:f    r25.8<1;1,0>:hf                 
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r15.4<0;1,0>:f   {F@2}
        sel (16|M0)   (lt)f0.0   r9.0<1>:f     acc0.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r15.5<0;1,0>:f   {F@2}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r19.0<1;1,0>:f    1.03125:f              
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r15.6<0;1,0>:f   {F@2}
        mov (8|M0)               r23.0<1>:ud   r9.0<2;1,0>:ud                  
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r15.7<0;1,0>:f   {F@1}
        mov (8|M0)               r11.0<1>:ud   r9.1<2;1,0>:ud                  
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.0<0;1,0>:f   {Compacted,F@1}
        sel (16|M0)   (lt)f0.0   r19.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.1<0;1,0>:f   {F@2}
        mov (8|M0)               r7.0<2>:hf    r23.0<1;1,0>:f                   {I@2}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.2<0;1,0>:f   {F@2}
        mov (8|M0)               r12.0<2>:hf   r11.0<1;1,0>:f                   {I@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.3<0;1,0>:f   {F@2}
        mov (8|M0)               r21.0<1>:ud   r19.0<2;1,0>:ud                 
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.4<0;1,0>:f   {F@1}
        mov (8|M0)               r22.8<1>:uw   r7.0<2;1,0>:uw                  
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.5<0;1,0>:f   {F@1}
        mov (8|M0)               r7.0<1>:ud    r19.1<2;1,0>:ud                 
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.6<0;1,0>:f   {F@1}
        mov (8|M0)               r8.8<1>:uw    r12.0<2;1,0>:uw                 
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r16.7<0;1,0>:f   {F@1}
        mov (8|M0)               r22.0<1>:hf   r21.0<1;1,0>:f                   {I@4}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.0<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r8.0<1>:hf    r7.0<1;1,0>:f                    {I@2}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.1<0;1,0>:f   {F@2}
        shl (16|M0)              r5.0<1>:d     r22.0<1;1,0>:uw   5:w              
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.2<0;1,0>:f   {F@1}
        mov (16|M0)              r17.0<1>:d    r8.0<1;1,0>:uw                   {I@2}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.3<0;1,0>:f   {F@1}
        add (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     2146992128:d               {I@2}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.4<0;1,0>:f   {F@1}
        shl (16|M0)              r17.0<1>:d    r17.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.5<0;1,0>:f   {F@1}
        add (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r17.0<1;1,0>:d   {Compacted,I@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.6<0;1,0>:f   {F@1}
        mov (8|M0)               r23.0<1>:f    r5.0<1;1,0>:hf                   {I@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r13.7<0;1,0>:f   {F@2}
        mov (8|M0)               r24.0<1>:f    r5.8<1;1,0>:hf                  
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r21.0<1>:f    r6.0<1;1,0>:hf                  
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.1<0;1,0>:f   {F@2}
        mov (8|M0)               r22.0<1>:f    r6.8<1;1,0>:hf                  
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.2<0;1,0>:f   {F@2}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r14.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r23.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r24.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r21.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.3<1>:f     r1.3<0;1,0>:f     r22.7<0;1,0>:f   {F@1}
        mov (1|M0)               r2.0<2>:hf    r1.3<0;1,0>:f                    {F@1}
        math.inv (8|M0)          r5.0<1>:hf    r2.0<0;1,0>:hf                   {@1,$10}
        mov (1|M0)               r2.0<1>:uw    r5.0<0;1,0>:uw                   {$10.dst}
        mov (1|M0)               r3.3<1>:f     r2.0<0;1,0>:hf                   {I@1}
        bfn.0xEA (1|M0)          r2.0<1>:ud    r96.1<0;0>:ud     r1.2<0;0>:ud      0xE0:uw              {F@1} // s0|s1&s2
        mul (16|M0)              r15.0<1>:f    r3.3<0;1,0>:f     r15.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r6.0<1>:hf    r15.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r6.8<1>:hf    r16.0<1;1,0>:f                  
        mul (16|M0)              r13.0<1>:f    r3.3<0;1,0>:f     r13.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r7.0<1>:f     (abs)r6.0<1;1,0>:hf              {F@3}
        mov (8|M0)               r8.0<1>:f     (abs)r6.8<1;1,0>:hf              {F@3}
        mov (8|M0)               r9.0<1>:hf    r13.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r9.8<1>:hf    r14.0<1;1,0>:f                  
        sel (16|M0)   (lt)f0.0   r7.0<1>:f     r7.0<1;1,0>:f     448.0:f               {Compacted,F@3}
        mov (8|M0)               r10.0<1>:f    (abs)r9.0<1;1,0>:hf              {F@3}
        mov (8|M0)               r11.0<1>:f    (abs)r9.8<1;1,0>:hf              {F@3}
        shr (16|M0)              r17.0<1>:ud   r7.0<1;1,0>:ud    0x17:uw              {F@3}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@1}
        sel (16|M0)   (ge)f0.0   r25.0<2>:ub   r17.0<4;1,0>:ub   0x79:uw              {I@1}
        shr (16|M0)              r19.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (16|M0)              r27.0<1>:d    r25.0<2;1,0>:ub                  {I@2}
        sel (16|M0)   (ge)f0.0   r26.0<2>:ub   r19.0<4;1,0>:ub   0x79:uw              {I@2}
        shl (16|M0)              r27.0<1>:d    r27.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (16|M0)              r5.0<1>:d     r26.0<2;1,0>:ub                  {I@2}
        add (16|M0)              r29.0<1>:d    r27.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r27.0<1>:d    -r27.0<1;1,0>:d   -2139095040:d              
        shl (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     23:w               {Compacted,I@3}
        mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r27.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              r23.0<1>:f    r3.3<0;1,0>:f     r23.0<1;1,0>:f   {Compacted}
        add (16|M0)              r31.0<1>:d    r5.0<1;1,0>:d     -25165824:d               {I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (16|M0)              r5.0<1>:d     -r5.0<1;1,0>:d    -2139095040:d              
        cmp (16|M0)   (lt)f0.0   null<1>:f     r15.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r29.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted,I@1}
        mov (8|M0)               r6.0<1>:hf    r23.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r6.8<1>:hf    r24.0<1;1,0>:f                  
        mul (16|M0)              r21.0<1>:f    r3.3<0;1,0>:f     r21.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r17.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (16|M0)             acc0.0<1>:f   acc2.0<1;1,0>:f                 
        mov (8|M0)               r7.0<1>:f     (abs)r6.0<1;1,0>:hf              {F@5}
        mov (8|M0)               r8.0<1>:f     (abs)r6.8<1;1,0>:hf              {F@5}
(f0.0)  or (16|M0)               r17.0<1>:d    r17.0<1;1,0>:d    -2147483648:d               {F@4}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r31.0<1;1,0>:f   {Compacted}
        sel (16|M0)   (lt)f0.0   r7.0<1>:f     r7.0<1;1,0>:f     448.0:f               {Compacted,F@2}
        cmp (16|M0)   (lt)f0.0   null<1>:f     r13.0<1;1,0>:f    0xB3000000:f               {Compacted,I@1}
        mov (8|M0)               r10.0<1>:hf   r21.0<1;1,0>:f                  
        mov (8|M0)               r10.8<1>:hf   r22.0<1;1,0>:f                  
        mov (16|M0)              r19.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        shr (16|M0)              r13.0<1>:ud   r7.0<1;1,0>:ud    0x17:uw              {A@4}
        mov (8|M0)               r11.0<1>:f    (abs)r10.0<1;1,0>:hf             {F@3}
        mov (8|M0)               r12.0<1>:f    (abs)r10.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r9.0<1>:hf    r17.0<1;1,0>:f                  
(f0.0)  or (16|M0)               r19.0<1>:d    r19.0<1;1,0>:d    -2147483648:d               {F@4}
        sel (16|M0)   (lt)f0.0   r11.0<1>:f    r11.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        sel (16|M0)   (ge)f0.0   r17.0<2>:ub   r13.0<4;1,0>:ub   0x79:uw              {A@2}
        mov (8|M0)               r5.0<1>:hf    r19.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r5.8<1>:hf    r20.0<1;1,0>:f                  
        shr (16|M0)              r15.0<1>:ud   r11.0<1;1,0>:ud   0x17:uw              {F@3}
        mov (16|M0)              r19.0<1>:d    r17.0<2;1,0>:ub                  {A@1}
        mov (8|M0)               r9.8<1>:hf    r18.0<1;1,0>:f                  
        shl (16|M0)              r19.0<1>:d    r19.0<1;1,0>:d    23:w               {Compacted,I@1}
        sel (16|M0)   (ge)f0.0   r18.0<2>:ub   r15.0<4;1,0>:ub   0x79:uw              {F@1}
        add (16|M0)              r27.0<1>:d    r19.0<1;1,0>:d    -25165824:d               {I@2}
        mov (16|M0)              r25.0<1>:d    r18.0<2;1,0>:ub                  {I@2}
        add (16|M0)              r19.0<1>:d    -r19.0<1;1,0>:d   -2139095040:d              
        shl (16|M0)              r25.0<1>:d    r25.0<1;1,0>:d    23:w               {Compacted,I@2}
        mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r19.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r29.0<1>:d    r25.0<1;1,0>:d    -25165824:d               {I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (16|M0)              r25.0<1>:d    -r25.0<1;1,0>:d   -2139095040:d              
        cmp (16|M0)   (lt)f0.0   null<1>:f     r23.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r27.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   r11.0<1;1,0>:f    r25.0<1;1,0>:f   {Compacted,I@1}
        mov (16|M0)              r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (16|M0)             acc0.0<1>:f   acc2.0<1;1,0>:f                 
(f0.0)  or (16|M0)               r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r29.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:f     r21.0<1;1,0>:f    0xB3000000:f               {Compacted,I@1}
        mov (16|M0)              r15.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f0.0)  or (16|M0)               r15.0<1>:d    r15.0<1;1,0>:d    -2147483648:d               {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r87.2<0;1,0>:d    4:w              
        or (1|M0)                r7.0<1>:ud    r2.0<0;1,0>:ud    0x200:uw             
        or (1|M0)                r8.0<1>:ud    r2.0<0;1,0>:ud    0x400:uw             
        mov (8|M0)               r6.0<1>:hf    r13.0<1;1,0>:f                  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r6.8<1>:hf    r14.0<1;1,0>:f                  
        or (1|M0)                r11.0<1>:ud   r2.0<0;1,0>:ud    0x600:uw             
        mov (8|M0)               r10.0<1>:hf   r15.0<1;1,0>:f                   {I@6}
        mov (8|M0)               r10.8<1>:hf   r16.0<1;1,0>:f                  
        send.slm (1|M0)          null     r2      r9:1    0x0            0x0200B704           {$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,I@4}
        send.slm (1|M0)          null     r7      r5:1    0x0            0x0200B704           {$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r8      r6:1    0x0            0x0200B704           {A@3,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r11     r10:1   0x0            0x0200B704           {A@1,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
(~f0.0.any16h) goto.b (16|M0)                L20144                  L16208                
L20144:
        join (16|M0)                         L20160                                
L20160:
        sync.nop                             null                             {Compacted,$3.src}
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$11} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$4.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$12} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r2.0<1>:ud    r3.6<0;1,0>:ud    r87.0<0;1,0>:ud  {AccWrEn,$2.src}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r96.2<1>:ud   r96.3<0;1,0>:ud   0x1:uw             
        and (1|M0)               r96.1<1>:d    r1.0<0;1,0>:uw    1:w              
        mov (1|M0)               r87.2<1>:d    r2.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r87.3<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       r87.1<0>:d       {I@4}
(f0.0.any16h) goto (16|M0)                   L20440                  L20440                
L20376:
        shl (1|M0)               r3.3<1>:ud    r96.3<0;1,0>:ud   0x7:uw             
        or (1|M0)                r2.0<1>:ud    r3.3<0;1,0>:ud    0xA000:uw              {I@1}
        send.slm (1|M0)          r109     r2      null:0  0x0            0x0240D700           {A@1,$13} // wr:1+0, rd:4; load.slm.d64x16t.a32
        goto (16|M0)                         L20440                  L20848                
L20440:
        join (16|M0)                         L20848                                
L20456:
        shl (1|M0)               r1.2<1>:d     r96.7<0;1,0>:d    6:w              
        shr (1|M0)               r1.3<1>:ud    r96.6<0;1,0>:ud   0x1A:uw             
        mov (2|M0)               r2.0<1>:w     0x1010101:v                               {$13.src}
        shl (1|M0)               r1.4<1>:d     r96.6<0;1,0>:d    6:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mul (2|M0)               r4.2<1>:d     r2.0<1;1,0>:w     192:w               {I@3}
        mul (2|M0)               r4.4<1>:d     r2.0<1;1,0>:w     256:w              
        and (2|M0)               r4.2<1>:d     r1.4<1;1,0>:d     r4.2<1;1,0>:d    {I@2}
        and (2|M0)               r1.4<1>:d     r1.4<1;1,0>:d     r4.4<1;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$12.src}
        shl (1|M0)               r6.5<1>:d     r4.2<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r5.1<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     1:w              
        shr (1|M0)               r5.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r87.2<0;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r6.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r6.4<1>:ud    r4.2<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r5.2<1>:d     r3.3<0;1,0>:d     r5.0<0;1,0>:d    {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r6.6<1>:d     r6.3<0;1,0>:d     r6.4<0;1,0>:d    {I@4}
        add3 (1|M0)              r6.2<1>:d     r7.0<0;0>:d       r87.3<0;0>:d      r5.2<0>:d        {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r6.2<0;0>:d       r6.6<0>:d        {I@1}
        shl (1|M0)               r3.3<1>:ud    r96.3<0;1,0>:ud   0x7:uw             
        send.ugm (1|M0)          r109     r9      null:0  0x0            0x0240D780           {A@1,$13} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L20848:
        join (16|M0)                         L20864                                
L20864:
        or (1|M0)                r3.0<1>:d     r3.3<0;1,0>:d     4096:w               {I@2}
        send.slm (1|M0)          null     r3      r109:4  0x0            0x0200D704           {A@1,$13} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$14} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$12.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$14.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$15} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r96.3<1>:ud   r96.3<0;1,0>:ud   0x6:uw             
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        and (1|M0)               r1.2<1>:ud    r96.3<0;1,0>:ud   0xC0:uw              {I@2}
        shl (1|M0)               r3.1<1>:ud    r96.2<0;1,0>:ud   0xB:uw              {$13.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r87.2<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r3.7<1>:d     r96.1<0;1,0>:d    9:w              
        and (1|M0)               r3.4<1>:ud    r96.3<0;1,0>:ud   0x100:uw             
        mov (1|M0)               r3.5<1>:d     r7.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r3.6<1>:d     r5.0<0;0>:d       r87.3<0;0>:d      r2.1<0>:d        {I@4}
(f0.0.any16h) goto (16|M0)                   L21240                  L21240                
L21192:
        or (1|M0)                r2.0<1>:d     r3.3<0;1,0>:d     0xA400:uw             
        send.slm (1|M0)          r105     r2      null:0  0x0            0x0240D700           {A@1,$0} // wr:1+0, rd:4; load.slm.d64x16t.a32
        goto (16|M0)                         L21240                  L21384                
L21240:
        join (16|M0)                         L21384                                
L21256:
        or (1|M0)                r1.2<1>:ud    r3.4<0;1,0>:ud    0x200:uw             
        sync.nop                             null                             {Compacted,$0.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@1}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r3.5<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.6<0;0>:d       r2.1<0>:d        {I@1}
        send.ugm (1|M0)          r105     r7      null:0  0x0            0x0240D780           {A@1,$0} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L21384:
        join (16|M0)                         L21400                                
L21400:
        or (1|M0)                r40.0<1>:d    r3.3<0;1,0>:d     5120:w              
        or (1|M0)                r2.0<1>:ud    r3.1<0;1,0>:ud    0x6000:uw              {$0.src}
        send.slm (1|M0)          null     r40     r105:4  0x0            0x0200D704           {A@2,$0} // wr:1+4, rd:0; store.slm.d64x16t.a32
        or (1|M0)                r42.0<1>:d    r3.7<0;1,0>:d     4096:w              
        or (1|M0)                r13.0<1>:ud   r3.1<0;1,0>:ud    0x6100:uw             
        or (1|M0)                r41.0<1>:d    r3.7<0;1,0>:d     4352:w              
        mov (16|M0)              r88.0<1>:ud   0x0:ud                             
        mov (16|M0)              r90.0<1>:ud   0x0:ud                             
        sync.nop                             null                             {Compacted,$15.src}
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0280E700           {A@6,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r13     null:0  0x0            0x0280E700           {A@4,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r42     null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r30      r41     null:0  0x0            0x0280E700           {A@3,$4} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (16|M0)              r92.0<1>:ud   0x0:ud                             
        mov (16|M0)              r94.0<1>:ud   0x0:ud                             
        mov (16|M0)              r80.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r82.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r84.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r86.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r74.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r76.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r78.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r64.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r66.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r68.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r70.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($1,$2,$3,$4)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r88:f         null:f            r88:hf            r88.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r88:f         r88:f             r22:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r80:f         r80:f             r30:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r72:f         r72:f             r22:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r64:f         r64:f             r30:hf            r14.0:hf         {$1}
(W)     send.slm (1|M0)          r13      r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r38.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r38.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r13.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r38     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L22024                  L22024                
L21976:
        or (1|M0)                r2.0<1>:d     r3.3<0;1,0>:d     0xA800:uw             
        send.slm (1|M0)          r97      r2      null:0  0x0            0x0240D700           {A@1,$8} // wr:1+0, rd:4; load.slm.d64x16t.a32
        goto (16|M0)                         L22024                  L22176                
L22024:
        join (16|M0)                         L22176                                
L22040:
        or (1|M0)                r1.2<1>:ud    r3.4<0;1,0>:ud    0x400:uw             
        sync.nop                             null                             {Compacted,$8.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@1}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r5.0<1>:ud    r3.5<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.6<0;0>:d       r2.1<0>:d        {I@1}
        send.ugm (1|M0)          r97      r7      null:0  0x0            0x0240D780           {A@1,$8} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L22176:
        join (16|M0)                         L22192                                
L22192:
        send.slm (1|M0)          null     r3      r97:4   0x0            0x0200D704           {$8} // wr:1+4, rd:0; store.slm.d64x16t.a32
        or (1|M0)                r2.0<1>:ud    r3.1<0;1,0>:ud    0x6200:uw             
        or (1|M0)                r13.0<1>:ud   r3.1<0;1,0>:ud    0x6300:uw             
        or (1|M0)                r3.0<1>:d     r3.7<0;1,0>:d     5120:w               {$8.src}
        or (1|M0)                r97.0<1>:d    r3.7<0;1,0>:d     5376:w              
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0280E700           {A@4,$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r13     null:0  0x0            0x0280E700           {A@3,$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r3      null:0  0x0            0x0280E700           {A@2,$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r30      r97     null:0  0x0            0x0280E700           {A@1,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($1,$9,$10,$11,$12)                
        dpas.8x8 (8|M0)          r88:f         null:f            r88:hf            r88.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r88:f         r88:f             r22:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r72:f         r72:f             r22:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r80:f         r80:f             r30:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r64:f         r64:f             r30:hf            r14.0:hf         {$1}
        sync.nop                             null                             {Compacted,$7.src}
(W)     send.slm (1|M0)          r38      r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r39.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r39.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r38.0<1;1,0>:ud                  {$13.dst}
(W)     send.gtwy (1|M0)         null     r39     null:0  0x0            0x02000004           {A@2,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L22616                  L22616                
L22568:
        or (1|M0)                r2.0<1>:d     r3.3<0;1,0>:d     0xAC00:uw             
        send.slm (1|M0)          r101     r2      null:0  0x0            0x0240D700           {A@1,$15} // wr:1+0, rd:4; load.slm.d64x16t.a32
        goto (16|M0)                         L22616                  L22768                
L22616:
        join (16|M0)                         L22768                                
L22632:
        or (1|M0)                r1.2<1>:ud    r3.4<0;1,0>:ud    0x600:uw             
        sync.nop                             null                             {Compacted,$15.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@1}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r5.0<1>:ud    r3.5<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.6<0;0>:d       r2.1<0>:d        {I@1}
        send.ugm (1|M0)          r101     r7      null:0  0x0            0x0240D780           {A@1,$15} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L22768:
        join (16|M0)                         L22784                                
L22784:
        send.slm (1|M0)          null     r40     r101:4  0x0            0x0200D704           {$15} // wr:1+4, rd:0; store.slm.d64x16t.a32
        or (1|M0)                r2.0<1>:ud    r3.1<0;1,0>:ud    0x6400:uw             
        or (1|M0)                r13.0<1>:ud   r3.1<0;1,0>:ud    0x6500:uw             
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0280E700           {A@2,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r13     null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r42     null:0  0x0            0x0280E700           {$4} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r30      r41     null:0  0x0            0x0280E700           {$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($1,$2,$3,$4,$6)                
        dpas.8x8 (8|M0)          r88:f         null:f            r88:hf            r88.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r88:f         r88:f             r22:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r72:f         r72:f             r22:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r80:f         r80:f             r30:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r64:f         r64:f             r30:hf            r14.0:hf         {$1}
(W)     send.slm (1|M0)          r38      r0      null:0  0x0            0x0210001F           {$7} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r39.2<1>:f    0.0:f                               {Compacted,$14.src}
(W)     mov (2|M0)               r39.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r38.0<1;1,0>:ud                  {$7.dst}
(W)     send.gtwy (1|M0)         null     r39     null:0  0x0            0x02000004           {A@2,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        or (1|M0)                r2.0<1>:ud    r3.1<0;1,0>:ud    0x6600:uw             
        or (1|M0)                r13.0<1>:ud   r3.1<0;1,0>:ud    0x6700:uw             
        send.slm (1|M0)          r56      r3      null:0  0x0            0x0280E700           {$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r5       r97     null:0  0x0            0x0280E700           {$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r40      r2      null:0  0x0            0x0280E700           {A@2,$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r48      r13     null:0  0x0            0x0280E700           {A@1,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($1,$9,$10,$11,$12)                
        dpas.8x8 (8|M0)          r88:f         r88:f             r56:hf            r40.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r80:f         r80:f             r5:hf             r40.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r72:f         r72:f             r56:hf            r48.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r64:f         r64:f             r5:hf             r48.0:hf         {$1}
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r15.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r15.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$13.dst}
(W)     send.gtwy (1|M0)         null     r15     null:0  0x0            0x02000004           {A@2,$2} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r97.1<1>:d    r96.0<0;1,0>:d                  
        mov (1|M0)               r96.3<1>:d    r3.2<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r96.4         L38576                                 {A@1}
L23440:
(W)     mul (1|M0)               acc0.0<1>:d   r96.3<0;1,0>:d    r3.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r96.3<0;1,0>:d    r3.2<0;1,0>:d   
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r88.0<1;1,0>:f  448.0:f            {Compacted}
        add (1|M0)               r96.0<1>:d    r96.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,I@1}
        shl (1|M0)               r4.6<1>:d     r96.1<0;1,0>:d    4:w              
        shl (1|M0)               r4.4<1>:d     r96.0<0;1,0>:d    5:w               {Compacted,I@2}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        shl (1|M0)               r5.1<1>:d     r4.4<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r1.5<1>:d     r4.6<0;1,0>:d     1:w              
        shr (1|M0)               r5.0<1>:ud    r4.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn,I@3}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r10.0<4;1,0>:ub   0x79:uw             
        shr (1|M0)               r6.3<1>:ud    r4.6<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r5.2<1>:d     r5.0<0;1,0>:d     0:w               {Compacted,I@4}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@5}
        mov (8|M0)               r11.0<1>:d    r7.12<2;1,0>:ub                  {I@5}
        or (1|M0)                r1.6<1>:d     r6.3<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r6.2<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       r5.2<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@4}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r6.2<0;0>:d       r1.6<0>:d        {I@2}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r80.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        add (8|M0)               r5.0<1>:d     r11.0<1;1,0>:d    -25165824:d              
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r8.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r8.0<4;1,0>:ub    0x79:uw              {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r10.0<1>:d    r7.12<2;1,0>:ub                  {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r88.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r5.0<1;1,0>:f    {Compacted}
        shl (8|M0)               r10.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r12.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r11.0<1>:d    r10.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r10.0<1>:d    -r10.0<1;1,0>:d   -2139095040:d              
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     (abs)r72.0<1;1,0>:f  448.0:f            {Compacted}
(f0.0)  or (8|M0)                r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r10.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r4.8<1>:hf    r12.0<1;1,0>:f                   {I@1}
        shr (8|M0)               r12.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {A@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r11.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (lt)f0.0   r11.0<1>:f    (abs)r64.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {I@1}
        shr (8|M0)               r12.0<1>:ud   r11.0<1;1,0>:ud   0x17:uw              {F@1}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        add (8|M0)               r10.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r14.0<1>:d    r7.12<2;1,0>:ub                  {I@3}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r80.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc1.0<1>:f   r8.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r96.3<0;1,0>:ud   0x1A:uw             
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r72.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        mul (8|M0)               acc1.0<1>:f   r11.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted}
        shl (1|M0)               r1.3<1>:d     r96.3<0;1,0>:d    6:w               {Compacted}
        shl (1|M0)               r1.5<1>:ud    r96.2<0;1,0>:ud   0x4:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w              
        mov (8|M0)               r6.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        shl (1|M0)               r3.3<1>:ud    r96.2<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r4.2<1>:d     r3.2<0;1,0>:d     5:w              
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@3}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               r8.0<1>:f     acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r64.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        mov (8|M0)               r9.0<1>:hf    r5.0<1;1,0>:f                   
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw   {A@3}
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                   
        or (1|M0)                r6.2<1>:ud    r3.3<0;1,0>:ud    0x8:uw              {F@1}
        mov (1|M0)               r6.3<1>:d     0:w                              
        mov (8|M0)               r8.0<1>:f     (abs)r8.0<1;1,0>:f               {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw  
        or (2|M0)                r6.2<1>:d     r1.3<1;1,0>:d     r6.2<1;1,0>:d    {I@3}
        mach (1|M0)              r15.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
(f0.0)  or (8|M0)                r8.0<1>:d     r8.0<1;1,0>:d     -2147483648:d               {F@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r6.3<0;1,0>:d     r4.4<0;1,0>:uw   {I@4}
        mov (8|M0)               r5.8<1>:hf    r8.0<1;1,0>:f                    {I@3}
        mach (1|M0)              r8.0<1>:d     r6.3<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        mul (1|M0)               acc0.0<1>:ud  r6.2<0;1,0>:ud    r4.4<0;1,0>:uw  
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w              
        shl (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@5}
        mach (1|M0)              r11.0<1>:ud   r6.2<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.5<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r6.1<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@5}
        mov (8|M0)               r13.0<1>:uw   0xECA86420:uv                             
        or (1|M0)                r1.7<1>:d     r1.2<0;1,0>:d     r1.5<0;1,0>:d    {I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.6<1>:d     r2.0<0;1,0>:d                    {I@4}
        mov (8|M0)               r18.0<4>:uw   r13.0<1;1,0>:uw                  {I@4}
        add3 (1|M0)              r7.7<1>:d     r12.0<0;0>:d      r7.2<0;0>:d       r1.7<0>:d        {I@3}
        mov (8|M0)               r16.0<2>:ud   r7.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r20.0<2>:ud   r18.0<4;1,0>:uw                  {I@3}
        mov (8|M0)               r16.1<2>:ud   r7.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r20.1<2>:ud   0.0:f                              
        add3 (1|M0)              r7.4<1>:d     r8.0<0;0>:d       r11.0<0;0>:d      0:w              
        addc (8|M0)              r6.0<1>:ud    r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r22.0<1>:d    r20.1<2;1,0>:d                  
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r23.0<1>:d    r8.0<1;0>:d       r16.1<4;2>:d      r22.0<1>:d       {I@2}
        mov (1|M0)               r24.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r24.0<0;0>:d      r7.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r18.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r12.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r14.0<2>:d    r6.0<1;1,0>:d                   
        addc (8|M0)              r13.0<1>:ud   r18.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (1|M0)               r4.5<1>:d     r10.0<0;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r14.1<2>:d    r23.0<1;1,0>:d                  
        shr (1|M0)               r2.0<1>:ud    r10.0<0;1,0>:ud   0x1F:uw             
        send.ugm (8|M0)          null     r14     r12:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r7.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,$3.src}
        or (1|M0)                r4.6<1>:d     r4.4<0;1,0>:d     r2.0<0;1,0>:d    {I@3}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r15.0<0;0>:d      r7.2<0;0>:d       r4.6<0>:d        {I@2}
        mov (8|M0)               r16.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r8.0<1>:d     r6.0<1;0>:d       r18.1<4;2>:d      r22.0<1>:d      
        addc (8|M0)              r6.0<1>:ud    r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r25.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r25.1<2>:d    r8.0<1;1,0>:d                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r12.0<1>:d    r9.0<1;1,0>:uw                  
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.5<1>:d     r11.0<0;0>:d      r1.7<0;0>:d       0:w               {I@2}
        add3 (8|M0)              r9.0<1>:d     r8.0<1;0>:d       r16.1<4;2>:d      r22.0<1>:d      
        mov (8|M0)               r14.0<2>:ud   r4.4<0;1,0>:ud                   {I@3}
        mov (8|M0)               r14.1<2>:ud   r4.5<0;1,0>:ud                   {I@3}
        send.ugm (8|M0)          null     r25     r12:1   0x0            0x04000B84           {$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<1>:d    r5.0<1;1,0>:uw                  
        mov (8|M0)               r12.0<2>:d    r6.0<1;1,0>:d                    {$4.src}
        mov (8|M0)               r12.1<2>:d    r9.0<1;1,0>:d                    {I@5}
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r89.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted}
        send.ugm (8|M0)          null     r12     r10:1   0x0            0x04000B84           {$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$5.src}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r8.0<1>:d     r5.8<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r19.0<1;0>:d      r14.1<4;2>:d      r22.0<1>:d       {I@3}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r81.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r11.0<1>:d    r7.12<2;1,0>:ub                 
        mov (8|M0)               r23.0<2>:d    r18.0<1;1,0>:d                  
        mov (8|M0)               r23.1<2>:d    r6.0<1;1,0>:d                    {I@3}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@4}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@2}
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        send.ugm (8|M0)          null     r23     r8:1    0x0            0x04000B84           {$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$6.src}
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@3}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (8|M0)               r10.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r89.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r73.0<1;1,0>:f  448.0:f            {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   r5.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {A@2}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r65.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {F@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw             
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        add (8|M0)               r8.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r14.0<1>:d    r7.12<2;1,0>:ub                  {I@3}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r81.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc1.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r73.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        mul (8|M0)               acc1.0<1>:f   r10.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x1:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               r6.0<1>:f     acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r65.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        mov (8|M0)               r11.0<1>:hf   r9.0<1;1,0>:f                   
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw   {A@3}
        mov (8|M0)               r9.0<1>:hf    r5.0<1;1,0>:f                   
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0x9:uw              {F@1}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mov (8|M0)               r6.0<1>:f     (abs)r6.0<1;1,0>:f               {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw  
        or (2|M0)                r5.6<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@3}
        mach (1|M0)              r15.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.7<0;1,0>:d     r4.4<0;1,0>:uw   {I@4}
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@3}
        mach (1|M0)              r6.0<1>:d     r5.7<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r4.4<0;1,0>:uw  
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w              
        shl (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@5}
        mach (1|M0)              r13.0<1>:ud   r5.6<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.5<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r5.5<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r1.7<1>:d     r1.2<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r7.7<1>:d     r8.0<0;0>:d       r7.2<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r16.0<2>:ud   r7.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r7.7<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      0:w              
        addc (8|M0)              r10.0<1>:ud   r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r7.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r23.0<1>:d    r6.0<1;0>:d       r16.1<4;2>:d      r22.0<1>:d       {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r15.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r2.0<0;0>:d       r7.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r24.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r24.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r18.1<2>:d    r23.0<1;1,0>:d                  
        addc (8|M0)              r8.0<1>:ud    r24.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@4}
        send.ugm (8|M0)          null     r18     r14:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        shr (1|M0)               r4.5<1>:ud    r12.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r7.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r2.1<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@3}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r15.0<0;0>:d      r7.2<0;0>:d       r2.1<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r26.0<1;0>:d      r24.1<4;2>:d      r22.0<1>:d      
        mov (8|M0)               r16.0<2>:ud   r1.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r16.1<2>:ud   r1.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r27.0<2>:d    r8.0<1;1,0>:d                   
        mov (8|M0)               r27.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r10.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r18.0<1>:d    r8.0<1;0>:d       r16.1<4;2>:d      r22.0<1>:d       {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r14.0<0;0>:d      r1.7<0;0>:d       0:w               {I@1}
        mov (8|M0)               r23.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r23.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        send.ugm (8|M0)          null     r27     r10:1   0x0            0x04000B84           {$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r12.0<1>:d    r9.0<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:d    r6.0<1;1,0>:d                    {$8.src}
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r90.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r10.1<2>:d    r18.0<1;1,0>:d                  
        addc (8|M0)              r15.0<1>:ud   r23.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,A@2}
        send.ugm (8|M0)          null     r10     r12:1   0x0            0x04000B84           {A@2,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$9.src}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r8.0<1>:d     r5.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r19.0<1;0>:d      r23.1<4;2>:d      r22.0<1>:d       {I@3}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r82.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r11.0<1>:d    r7.12<2;1,0>:ub                 
        mov (8|M0)               r25.0<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r25.1<2>:d    r6.0<1;1,0>:d                    {I@3}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@4}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@2}
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        send.ugm (8|M0)          null     r25     r8:1    0x0            0x04000B84           {$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@3}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (8|M0)               r10.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@1}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r90.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r74.0<1;1,0>:f  448.0:f            {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   r5.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {A@2}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r66.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {F@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw             
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        add (8|M0)               r8.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r14.0<1>:d    r7.12<2;1,0>:ub                  {I@3}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r82.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc1.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r74.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        mul (8|M0)               acc1.0<1>:f   r10.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x2:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               r6.0<1>:f     acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r66.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        mov (8|M0)               r11.0<1>:hf   r9.0<1;1,0>:f                   
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw   {A@3}
        mov (8|M0)               r9.0<1>:hf    r5.0<1;1,0>:f                   
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0xA:uw              {F@1}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mov (8|M0)               r6.0<1>:f     (abs)r6.0<1;1,0>:f               {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw  
        or (2|M0)                r5.6<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@3}
        mach (1|M0)              r15.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.7<0;1,0>:d     r4.4<0;1,0>:uw   {I@4}
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@3}
        mach (1|M0)              r6.0<1>:d     r5.7<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r4.4<0;1,0>:uw  
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w              
        shl (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@5}
        mach (1|M0)              r13.0<1>:ud   r5.6<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.5<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r5.5<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r1.7<1>:d     r1.2<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r7.7<1>:d     r8.0<0;0>:d       r7.2<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r16.0<2>:ud   r7.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r7.7<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      0:w              
        addc (8|M0)              r10.0<1>:ud   r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r22.0<1>:d    r20.1<2;1,0>:d                  
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r8.0<0;0>:d       r7.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r23.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r23.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r14.0<1>:d    r6.0<1;0>:d       r16.1<4;2>:d      r22.0<1>:d      
        shl (1|M0)               r4.5<1>:d     r12.0<0;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r25.0<1>:ud   r23.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        shr (1|M0)               r2.0<1>:ud    r12.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r18.1<2>:d    r14.0<1;1,0>:d                   {I@6}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@7}
        send.ugm (8|M0)          null     r18     r15:1   0x0            0x04000B84           {A@3,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        or (1|M0)                r4.6<1>:d     r4.4<0;1,0>:d     r2.0<0;1,0>:d   
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r1.6<1>:d     r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r15.0<0;0>:d      r7.2<0;0>:d       r4.6<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r10.0<1;0>:d      r23.1<4;2>:d      r22.0<1>:d      
        mov (8|M0)               r16.0<2>:ud   r1.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r16.1<2>:ud   r1.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r26.0<2>:d    r25.0<1;1,0>:d                  
        mov (8|M0)               r26.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r14.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        send.ugm (8|M0)          null     r26     r14:1   0x0            0x04000B84           {A@3,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r4.5<1>:d     r8.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$12.src}
        mov (8|M0)               r13.0<2>:ud   r4.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.1<2>:ud   r4.5<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r11.0<1>:d    r10.0<1;0>:d      r16.1<4;2>:d      r22.0<1>:d      
        addc (8|M0)              r15.0<1>:ud   r13.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r91.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r18.0<2>:d    r6.0<1;1,0>:d                   
        mov (8|M0)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.1<2>:d    r11.0<1;1,0>:d                  
        shr (8|M0)               r11.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r12.0<1>:d    r9.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r23.0<1;0>:d      r13.1<4;2>:d      r22.0<1>:d       {I@4}
        mov (8|M0)               r9.0<1>:d     r5.0<1;1,0>:uw                  
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r11.0<4;1,0>:ub   0x79:uw              {I@4}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r83.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r24.0<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@2}
        mov (8|M0)               r24.1<2>:d    r6.0<1;1,0>:d                   
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@3}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@2}
        send.ugm (8|M0)          null     r18     r12:1   0x0            0x04000B84           {$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r9:1    0x0            0x04000B84           {$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$13.src}
        add (8|M0)               r12.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@2}
        sync.nop                             null                             {Compacted,$14.src}
        mov (8|M0)               r9.0<1>:d     r7.12<2;1,0>:ub                  {I@2}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        shl (8|M0)               r9.0<1>:d     r9.0<1;1,0>:d     23:w               {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:f   r10.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,I@2}
        add (8|M0)               r8.0<1>:d     r9.0<1;1,0>:d     -25165824:d               {A@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (8|M0)               r9.0<1>:d     -r9.0<1;1,0>:d    -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r91.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   r5.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,I@1}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r83.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r75.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r10.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
(f0.0)  or (8|M0)                r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@1}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r11.0<1>:hf   r10.0<1;1,0>:f                   {I@2}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r67.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                  
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {A@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw             
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        add (8|M0)               r9.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r14.0<1>:d    r7.12<2;1,0>:ub                  {I@3}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r75.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        mul (8|M0)               acc1.0<1>:f   r10.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted,I@1}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x3:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               r6.0<1>:f     acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r67.0<1;1,0>:f    0.0:f               {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw   {A@2}
        mov (8|M0)               r8.0<1>:hf    r5.0<1;1,0>:f                   
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0xB:uw              {F@1}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mov (8|M0)               r6.0<1>:f     (abs)r6.0<1;1,0>:f               {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw  
        or (2|M0)                r5.6<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@3}
        mach (1|M0)              r15.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.7<0;1,0>:d     r4.4<0;1,0>:uw   {I@4}
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@3}
        mach (1|M0)              r6.0<1>:d     r5.7<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r4.4<0;1,0>:uw  
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w              
        shl (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@5}
        mach (1|M0)              r10.0<1>:ud   r5.6<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.5<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r5.5<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r1.7<1>:d     r1.2<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r7.7<1>:d     r12.0<0;0>:d      r7.2<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r16.0<2>:ud   r7.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r7.7<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r10.0<0;0>:d      0:w              
        addc (8|M0)              r13.0<1>:ud   r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r7.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r23.0<1>:d    r6.0<1;0>:d       r16.1<4;2>:d      r22.0<1>:d       {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r15.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r2.0<0;0>:d       r7.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r24.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r24.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.0<2>:d    r13.0<1;1,0>:d                  
        shl (1|M0)               r2.0<1>:d     r9.0<0;1,0>:d     1:w               {Compacted}
        mov (8|M0)               r18.1<2>:d    r23.0<1;1,0>:d                  
        addc (8|M0)              r12.0<1>:ud   r24.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@4}
        send.ugm (8|M0)          null     r18     r14:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        shr (1|M0)               r4.5<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r7.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,$15.src}
        or (1|M0)                r2.1<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@3}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r14.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r15.0<0;0>:d      r7.2<0;0>:d       r2.1<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r26.0<1;0>:d      r24.1<4;2>:d      r22.0<1>:d      
        mov (8|M0)               r16.0<2>:ud   r1.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r16.1<2>:ud   r1.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r27.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r27.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r16.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r13.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r18.0<1>:d    r11.0<1;0>:d      r16.1<4;2>:d      r22.0<1>:d       {I@2}
        send.ugm (8|M0)          null     r27     r13:1   0x0            0x04000B84           {$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r9.0<1>:d     r8.0<1;1,0>:uw                  
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r12.0<2>:d    r6.0<1;1,0>:d                    {$0.src}
        mov (8|M0)               r12.1<2>:d    r18.0<1;1,0>:d                   {I@4}
        mov (1|M0)               r2.0<1>:f     r10.0<0;1,0>:f                   {Compacted}
        send.ugm (8|M0)          null     r12     r9:1    0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (1|M0)              r2.1<1>:d     r14.0<0;0>:d      r1.7<0;0>:d       0:w              
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r92.0<1;1,0>:f  448.0:f            {Compacted,$1.src}
        mov (8|M0)               r23.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r23.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@3}
        addc (8|M0)              r15.0<1>:ud   r23.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r7.12<2;1,0>:ub                  {I@2}
        mov (8|M0)               r8.0<1>:d     r5.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r19.0<1;0>:d      r23.1<4;2>:d      r22.0<1>:d       {I@3}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@3}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r84.0<1;1,0>:f  448.0:f            {Compacted,I@3}
        mov (8|M0)               r25.0<2>:d    r15.0<1;1,0>:d                  
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@2}
        mov (8|M0)               r25.1<2>:d    r6.0<1;1,0>:d                   
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@1}
        send.ugm (8|M0)          null     r25     r8:1    0x0            0x04000B84           {$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$2.src}
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r92.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r76.0<1;1,0>:f  448.0:f            {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {A@1}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r10.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@3}
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        mul (8|M0)               acc0.0<1>:f   r5.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                   {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r68.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r8.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r84.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc1.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        mov (8|M0)               r14.0<1>:d    r7.12<2;1,0>:ub                  {I@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r76.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x4:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@3}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@3}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted,I@3}
        mov (8|M0)               r11.0<1>:hf   r9.0<1;1,0>:f                   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw   {I@2}
        mov (8|M0)               r9.0<1>:hf    r5.0<1;1,0>:f                    {I@2}
        rnde (8|M0)              acc2.0<1>:f   r10.0<1;1,0>:f                   {F@3}
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0xC:uw              {F@2}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mach (1|M0)              r16.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r68.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        or (2|M0)                r5.6<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@2}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r4.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r13.0<1>:ud   r5.6<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,F@2}
        shl (1|M0)               r1.5<1>:d     r15.0<0;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r16.0<0;0>:d      0:w               {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.7<0;1,0>:d     r4.4<0;1,0>:uw  
        shr (1|M0)               r1.2<1>:ud    r15.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@5}
        shl (1|M0)               r7.5<1>:d     r5.5<0;1,0>:d     1:w               {I@4}
        mach (1|M0)              r6.0<1>:d     r5.7<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.6<1>:d     r7.5<0;1,0>:d     r1.2<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.2<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r8.3<1>:d     r8.0<0;0>:d       r7.2<0;0>:d       r1.6<0>:d        {I@2}
        mov (8|M0)               r17.0<2>:ud   r8.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r17.1<2>:ud   r8.3<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      0:w              
        addc (8|M0)              r10.0<1>:ud   r17.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r20.1<2;1,0>:d                  
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r16.0<1>:d    r4.8<1;1,0>:uw                  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r8.0<0;0>:d       r8.3<0;0>:d       0:w               {I@2}
        mov (8|M0)               r24.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r24.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r17.1<4;2>:d      r14.0<1>:d      
        shl (1|M0)               r4.5<1>:d     r12.0<0;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r19.0<1>:ud   r24.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r22.0<2>:d    r10.0<1;1,0>:d                  
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        shr (1|M0)               r2.0<1>:ud    r12.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r22.1<2>:d    r15.0<1;1,0>:d                   {I@6}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@7}
        send.ugm (8|M0)          null     r22     r16:1   0x0            0x04000B84           {A@3,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        or (1|M0)                r4.6<1>:d     r4.4<0;1,0>:d     r2.0<0;1,0>:d   
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r1.6<1>:d     r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r16.0<0;0>:d      r7.2<0;0>:d       r4.6<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r10.0<1;0>:d      r24.1<4;2>:d      r14.0<1>:d      
        mov (8|M0)               r17.0<2>:ud   r1.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.1<2>:ud   r1.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r26.0<2>:d    r19.0<1;1,0>:d                  
        mov (8|M0)               r26.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r17.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r15.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        send.ugm (8|M0)          null     r26     r15:1   0x0            0x04000B84           {A@3,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r4.5<1>:d     r8.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r15.0<2>:ud   r4.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.1<2>:ud   r4.5<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r11.0<1>:d    r10.0<1;0>:d      r17.1<4;2>:d      r14.0<1>:d      
        addc (8|M0)              r13.0<1>:ud   r15.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r93.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r22.0<2>:d    r6.0<1;1,0>:d                   
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r22.1<2>:d    r11.0<1;1,0>:d                  
        shr (8|M0)               r11.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r12.0<1>:d    r9.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r19.0<1;0>:d      r15.1<4;2>:d      r14.0<1>:d       {I@4}
        mov (8|M0)               r9.0<1>:d     r5.0<1;1,0>:uw                  
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r11.0<4;1,0>:ub   0x79:uw              {I@4}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r85.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r24.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@2}
        mov (8|M0)               r24.1<2>:d    r6.0<1;1,0>:d                   
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@3}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@2}
        send.ugm (8|M0)          null     r22     r12:1   0x0            0x04000B84           {$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r9:1    0x0            0x04000B84           {$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$5.src}
        add (8|M0)               r12.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (8|M0)               r9.0<1>:d     r7.12<2;1,0>:ub                  {I@2}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        shl (8|M0)               r9.0<1>:d     r9.0<1;1,0>:d     23:w               {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:f   r10.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,I@2}
        add (8|M0)               r8.0<1>:d     r9.0<1;1,0>:d     -25165824:d               {A@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (8|M0)               r9.0<1>:d     -r9.0<1;1,0>:d    -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r93.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   r5.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r77.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@3}
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r85.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw             
        mov (8|M0)               r10.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                  
(f0.0)  or (8|M0)                r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@2}
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {A@1}
        mov (8|M0)               r11.0<1>:hf   r10.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r69.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r9.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r15.0<1>:d    r7.12<2;1,0>:ub                  {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r77.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        shl (8|M0)               r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted,I@1}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x5:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r15.0<1;1,0>:d    -25165824:d               {A@3}
        add (8|M0)               r15.0<1>:d    -r15.0<1;1,0>:d   -2139095040:d              
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@3}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r15.0<1;1,0>:f   {Compacted,I@3}
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw   {I@2}
        mov (8|M0)               r8.0<1>:hf    r5.0<1;1,0>:f                    {I@2}
        rnde (8|M0)              acc2.0<1>:f   r10.0<1;1,0>:f                   {F@2}
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0xD:uw              {F@2}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mach (1|M0)              r17.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r69.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        or (2|M0)                r5.6<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r4.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r10.0<1>:ud   r5.6<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,F@4}
        shl (1|M0)               r1.5<1>:d     r16.0<0;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r17.0<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.7<0;1,0>:d     r4.4<0;1,0>:uw  
        shr (1|M0)               r1.2<1>:ud    r16.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@5}
        shl (1|M0)               r7.5<1>:d     r5.5<0;1,0>:d     1:w               {I@4}
        mach (1|M0)              r6.0<1>:d     r5.7<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.6<1>:d     r7.5<0;1,0>:d     r1.2<0;1,0>:d    {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.4<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r8.5<1>:d     r12.0<0;0>:d      r7.2<0;0>:d       r1.6<0>:d        {I@2}
        mov (8|M0)               r18.0<2>:ud   r8.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r8.5<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r10.0<0;0>:d      0:w              
        addc (8|M0)              r13.0<1>:ud   r18.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r16.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r17.0<1>:ud   r8.4<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r18.1<4;2>:d      r14.0<1>:d       {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r17.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r2.0<0;0>:d       r8.5<0;0>:d       0:w               {I@2}
        mov (8|M0)               r24.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r24.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        shl (1|M0)               r2.0<1>:d     r9.0<0;1,0>:d     1:w               {Compacted}
        addc (8|M0)              r12.0<1>:ud   r24.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r22.0<2>:d    r13.0<1;1,0>:d                  
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        shr (1|M0)               r4.5<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r22.1<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r7.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@7}
        send.ugm (8|M0)          null     r22     r16:1   0x0            0x04000B84           {A@3,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        or (1|M0)                r2.1<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d   
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        mov (1|M0)               r1.6<1>:d     r15.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.7<1>:d     r16.0<0;0>:d      r7.2<0;0>:d       r2.1<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r26.0<1;0>:d      r24.1<4;2>:d      r14.0<1>:d      
        mov (8|M0)               r17.0<2>:ud   r1.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.1<2>:ud   r1.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r27.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r27.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r17.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r13.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r19.0<1>:d    r11.0<1;0>:d      r17.1<4;2>:d      r14.0<1>:d       {I@2}
        send.ugm (8|M0)          null     r27     r13:1   0x0            0x04000B84           {$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r9.0<1>:d     r8.0<1;1,0>:uw                  
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r12.0<2>:d    r6.0<1;1,0>:d                    {$8.src}
        mov (8|M0)               r12.1<2>:d    r19.0<1;1,0>:d                   {I@4}
        mov (1|M0)               r2.0<1>:f     r10.0<0;1,0>:f                   {Compacted}
        send.ugm (8|M0)          null     r12     r9:1    0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (1|M0)              r2.1<1>:d     r15.0<0;0>:d      r1.7<0;0>:d       0:w              
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r94.0<1;1,0>:f  448.0:f            {Compacted,$9.src}
        mov (8|M0)               r22.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r22.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@3}
        addc (8|M0)              r16.0<1>:ud   r22.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r7.12<2;1,0>:ub                  {I@2}
        mov (8|M0)               r8.0<1>:d     r5.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r24.0<1;0>:d      r22.1<4;2>:d      r14.0<1>:d       {I@3}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@3}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r86.0<1;1,0>:f  448.0:f            {Compacted,I@3}
        mov (8|M0)               r25.0<2>:d    r16.0<1;1,0>:d                  
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@2}
        mov (8|M0)               r25.1<2>:d    r6.0<1;1,0>:d                   
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@1}
        send.ugm (8|M0)          null     r25     r8:1    0x0            0x04000B84           {$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r94.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r78.0<1;1,0>:f  448.0:f            {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {A@1}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r10.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@3}
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        mul (8|M0)               acc0.0<1>:f   r5.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                   {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r70.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r8.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r86.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc1.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        mov (8|M0)               r14.0<1>:d    r7.12<2;1,0>:ub                  {I@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r78.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x6:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@3}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@3}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted,I@3}
        mov (8|M0)               r11.0<1>:hf   r9.0<1;1,0>:f                   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw   {I@2}
        mov (8|M0)               r9.0<1>:hf    r5.0<1;1,0>:f                    {I@2}
        rnde (8|M0)              acc2.0<1>:f   r10.0<1;1,0>:f                   {F@3}
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0xE:uw              {F@2}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mach (1|M0)              r16.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r70.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        or (2|M0)                r5.6<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@2}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r4.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r13.0<1>:ud   r5.6<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,F@2}
        shl (1|M0)               r1.5<1>:d     r15.0<0;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r16.0<0;0>:d      0:w               {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.7<0;1,0>:d     r4.4<0;1,0>:uw  
        shr (1|M0)               r1.2<1>:ud    r15.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@5}
        shl (1|M0)               r7.5<1>:d     r5.5<0;1,0>:d     1:w               {I@4}
        mach (1|M0)              r6.0<1>:d     r5.7<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.6<1>:d     r7.5<0;1,0>:d     r1.2<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.2<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r8.3<1>:d     r8.0<0;0>:d       r7.2<0;0>:d       r1.6<0>:d        {I@2}
        mov (8|M0)               r17.0<2>:ud   r8.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r17.1<2>:ud   r8.3<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      0:w              
        addc (8|M0)              r10.0<1>:ud   r17.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r20.1<2;1,0>:d                  
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r16.0<1>:d    r4.8<1;1,0>:uw                  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r8.0<0;0>:d       r8.3<0;0>:d       0:w               {I@2}
        mov (8|M0)               r24.0<2>:ud   r1.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r24.1<2>:ud   r1.7<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r17.1<4;2>:d      r14.0<1>:d      
        shl (1|M0)               r4.5<1>:d     r12.0<0;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r19.0<1>:ud   r24.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r22.0<2>:d    r10.0<1;1,0>:d                  
        shl (1|M0)               r4.4<1>:d     r7.4<0;1,0>:d     1:w              
        shr (1|M0)               r2.0<1>:ud    r12.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r22.1<2>:d    r15.0<1;1,0>:d                   {I@6}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@7}
        send.ugm (8|M0)          null     r22     r16:1   0x0            0x04000B84           {A@3,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        or (1|M0)                r4.6<1>:d     r4.4<0;1,0>:d     r2.0<0;1,0>:d   
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r1.6<1>:d     r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.7<1>:d     r16.0<0;0>:d      r7.2<0;0>:d       r4.6<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r10.0<1;0>:d      r24.1<4;2>:d      r14.0<1>:d      
        mov (8|M0)               r17.0<2>:ud   r1.6<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.1<2>:ud   r1.7<0;1,0>:ud                   {I@3}
        mov (8|M0)               r26.0<2>:d    r19.0<1;1,0>:d                  
        mov (8|M0)               r26.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r17.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r15.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.6<0;1,0>:ud    0x10:ud              {AccWrEn}
        send.ugm (8|M0)          null     r26     r15:1   0x0            0x04000B84           {A@3,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r4.5<1>:d     r8.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$12.src}
        mov (8|M0)               r15.0<2>:ud   r4.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.1<2>:ud   r4.5<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r11.0<1>:d    r10.0<1;0>:d      r17.1<4;2>:d      r14.0<1>:d      
        addc (8|M0)              r13.0<1>:ud   r15.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r95.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r22.0<2>:d    r6.0<1;1,0>:d                   
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r22.1<2>:d    r11.0<1;1,0>:d                  
        shr (8|M0)               r11.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r12.0<1>:d    r9.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r19.0<1;0>:d      r15.1<4;2>:d      r14.0<1>:d       {I@4}
        mov (8|M0)               r9.0<1>:d     r5.0<1;1,0>:uw                  
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r11.0<4;1,0>:ub   0x79:uw              {I@4}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r87.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r24.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r8.0<1>:d     r7.12<2;1,0>:ub                  {I@2}
        mov (8|M0)               r24.1<2>:d    r6.0<1;1,0>:d                   
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted,I@3}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@2}
        send.ugm (8|M0)          null     r22     r12:1   0x0            0x04000B84           {$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r9:1    0x0            0x04000B84           {$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$13.src}
        add (8|M0)               r12.0<1>:d    r8.0<1;1,0>:d     -25165824:d               {I@2}
        sync.nop                             null                             {Compacted,$14.src}
        mov (8|M0)               r9.0<1>:d     r7.12<2;1,0>:ub                  {I@2}
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        shl (8|M0)               r9.0<1>:d     r9.0<1;1,0>:d     23:w               {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:f   r10.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,I@2}
        add (8|M0)               r8.0<1>:d     r9.0<1;1,0>:d     -25165824:d               {A@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add (8|M0)               r9.0<1>:d     -r9.0<1;1,0>:d    -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r95.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   r5.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r79.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc1.0<1;1,0>:f                 
        shr (8|M0)               r12.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@3}
(f0.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r87.0<1;1,0>:f    0.0:f               {Compacted,I@1}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw             
        mov (8|M0)               r10.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r4.8<1>:hf    r13.0<1;1,0>:f                  
(f0.0)  or (8|M0)                r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@2}
        mov (8|M0)               r13.0<1>:d    r7.12<2;1,0>:ub                  {A@1}
        mov (8|M0)               r11.0<1>:hf   r10.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r71.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r9.0<1>:d     r13.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r13.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r7.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r15.0<1>:d    r7.12<2;1,0>:ub                  {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r79.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted}
        shl (8|M0)               r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted,I@1}
        or (1|M0)                r1.5<1>:ud    r3.3<0;1,0>:ud    0x7:uw             
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r15.0<1;1,0>:d    -25165824:d               {A@3}
        add (8|M0)               r15.0<1>:d    -r15.0<1;1,0>:d   -2139095040:d              
        or (2|M0)                r1.5<1>:d     r1.3<1;1,0>:d     r1.5<1;1,0>:d    {I@3}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r15.0<1;1,0>:f   {Compacted,I@3}
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r4.4<0;1,0>:uw   {I@2}
        mov (8|M0)               r8.0<1>:hf    r5.0<1;1,0>:f                    {I@2}
        rnde (8|M0)              acc2.0<1>:f   r10.0<1;1,0>:f                   {F@2}
        or (1|M0)                r5.6<1>:ud    r3.3<0;1,0>:ud    0xF:uw              {F@2}
        mov (1|M0)               r5.7<1>:d     0:w                              
        mach (1|M0)              r17.0<1>:ud   r1.5<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r71.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        or (2|M0)                r1.3<1>:d     r1.3<1;1,0>:d     r5.6<1;1,0>:d    {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r4.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mach (1|M0)              r2.0<1>:d     r1.6<0;1,0>:d     r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.3<0;1,0>:ud    r4.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r10.0<1>:ud   r1.3<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,F@4}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        add3 (1|M0)              r5.5<1>:d     r2.0<0;0>:d       r17.0<0;0>:d      0:w               {I@4}
        shl (1|M0)               r2.0<1>:d     r16.0<0;1,0>:d    1:w               {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.4<0;1,0>:d     r4.4<0;1,0>:uw  
        shr (1|M0)               r7.6<1>:ud    r16.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                    {I@6}
        shl (1|M0)               r7.5<1>:d     r5.5<0;1,0>:d     1:w               {I@5}
        mach (1|M0)              r6.0<1>:d     r1.4<0;1,0>:d     r4.2<0;1,0>:d    {F@1}
        addc (1|M0)              r12.0<1>:ud   r7.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r2.1<1>:d     r7.5<0;1,0>:d     r7.6<0;1,0>:d    {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.4<1>:d     r12.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r8.5<1>:d     r13.0<0;0>:d      r7.2<0;0>:d       r2.1<0>:d        {I@2}
        mov (8|M0)               r18.0<2>:ud   r8.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.1<2>:ud   r8.5<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r7.4<1>:d     r6.0<0;0>:d       r10.0<0;0>:d      0:w              
        addc (8|M0)              r15.0<1>:ud   r18.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shl (1|M0)               r4.2<1>:d     r9.0<0;1,0>:d     1:w               {Compacted}
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r17.0<1>:ud   r8.4<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r24.0<1>:d    r6.0<1;0>:d       r18.1<4;2>:d      r14.0<1>:d       {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r17.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.3<1>:d     r12.0<0;0>:d      r8.5<0;0>:d       0:w               {I@2}
        mov (8|M0)               r25.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r25.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.0<1>:d    r4.8<1;1,0>:uw                  
        addc (8|M0)              r13.0<1>:ud   r25.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shr (1|M0)               r2.1<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.0<1>:d     r7.4<0;1,0>:d     1:w               {Compacted}
        mov (8|M0)               r22.0<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r27.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r22.1<2>:d    r24.0<1;1,0>:d                  
        addc (1|M0)              r12.0<1>:ud   r7.0<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        send.ugm (8|M0)          null     r22     r16:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d   
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        mov (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.3<1>:d     r16.0<0;0>:d      r7.2<0;0>:d       r4.3<0>:d        {I@2}
        add3 (8|M0)              r6.0<1>:d     r27.0<1;0>:d      r25.1<4;2>:d      r14.0<1>:d      
        mov (8|M0)               r17.0<2>:ud   r1.2<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.1<2>:ud   r1.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r28.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r28.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r17.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r15.0<1>:d    r11.0<1;1,0>:uw                 
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        send.ugm (8|M0)          null     r28     r15:1   0x0            0x04000B84           {A@3,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r1.5<1>:d     r10.0<0;0>:d      r1.3<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$0.src}
        mov (8|M0)               r15.0<2>:ud   r1.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r15.1<2>:ud   r1.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r22.0<2>:d    r6.0<1;1,0>:d                   
        addc (8|M0)              r7.0<1>:ud    r15.0<2;1,0>:ud   r20.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        add3 (8|M0)              r13.0<1>:d    r11.0<1;0>:d      r17.1<4;2>:d      r14.0<1>:d      
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r8.0<1;1,0>:uw                  
        add3 (8|M0)              r6.0<1>:d     r12.0<1;0>:d      r15.1<4;2>:d      r14.0<1>:d       {I@2}
        mov (8|M0)               r24.0<2>:d    r7.0<1;1,0>:d                   
        mov (8|M0)               r22.1<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r8.0<1>:d     r5.0<1;1,0>:uw                  
        mov (8|M0)               r24.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        send.ugm (8|M0)          null     r22     r9:1    0x0            0x04000B84           {A@3,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r8:1    0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
(W)     send.ugm (1|M0)          r9       r0      null:0  0x0            0x0210641F           {$3} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r9.0<1;1,0>:ud                   {$3.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L38576:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r96.3<0;1,0>:ud                  {Compacted,A@1}
        mov (1|M0)               r2.7<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$4}
        mov (1|M0)               r1.5<1>:f     r97.1<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$4.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r2.7<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r97.0<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r3.3<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r97.0<1>:ud   r96.3<0;1,0>:ud   -r97.0<0;1,0>:ud {Compacted,I@2}
        add (1|M0)               r1.6<1>:ud    r97.1<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r4.2<1>:ud    r3.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r97.0<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r4.3<1>:f     r4.2<0;1,0>:ud                   {I@1}
(W)     mov (1|M0)               r3.6<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r4.3<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r4.3<1>:f     r2.0<0;0>:f       r4.3<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r4.3<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r5.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    r5.0<0;1,0>:ud   {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.2<0;1,0>:ud    r96.6<0;1,0>:uw  {I@1}
        mach (1|M0)              r6.0<1>:ud    r4.2<0;1,0>:ud    r96.3<0;1,0>:ud 
        add (1|M0)               r97.1<1>:ud   r97.1<0;1,0>:ud   -r6.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r97.1<0;1,0>:ud   r96.3<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r7.0<1>:d     r3.6<0;1,0>:w     0:w              
        add (1|M0)               r96.3<1>:ud   r4.2<0;1,0>:ud    r7.0<0;1,0>:ud   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r96.4                            {A@1}
L39080:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r87.2<0;1,0>:ud                  {A@1}
        mov (1|M0)               r2.7<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$5}
        mov (1|M0)               r1.5<1>:f     r87.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$5.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r2.7<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r87.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r3.3<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r87.4<1>:ud   r87.2<0;1,0>:ud   -r87.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r87.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.0<1>:ud    r3.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r87.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r4.2<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@1}
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r4.2<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r4.2<1>:f     r2.0<0;0>:f       r4.2<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r4.2<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r5.1<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    r5.1<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.0<0;1,0>:ud    r87.4<0;1,0>:uw  {I@1}
        mach (1|M0)              r5.0<1>:ud    r5.0<0;1,0>:ud    r87.2<0;1,0>:ud  {Compacted}
        add (1|M0)               r87.5<1>:ud   r87.5<0;1,0>:ud   -r5.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r87.5<0;1,0>:ud   r87.2<0;1,0>:ud  {I@1}
(f0.0)  mov (1|M0)               r87.2<1>:d    0:w                              
        add (1|M0)               r87.2<1>:ud   r87.5<0;1,0>:ud   -r87.2<0;1,0>:ud {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r96.4                            {A@1}
L39576:
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
