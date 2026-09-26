; Linear-sweep disassembly of the byte ranges NOT reached by the recursive
; descent (and not strings).  Speculative: much of this is data.  Use it to
; look up code the descent missed (computed jumps, tables the scan did not
; recognise); if a routine here is real, add its entry to KNOWN in disasm_rom.py.


; ---- gap 010007b8..010007c5 (14 bytes) ----
010007b8  4e75              rts      
010007ba  2efc00000002      move.l   #$2, (a7)+
010007c0  61ff00003926      bsr.l    led_blink_halt

; ---- gap 01000c28..01000c67 (64 bytes) ----
01000c28  ffff              dc.w     $ffff
01000c2a  ffff              dc.w     $ffff
01000c2c  ffff              dc.w     $ffff
01000c2e  ffff              dc.w     $ffff
01000c30  ffff              dc.w     $ffff
01000c32  ffff              dc.w     $ffff
01000c34  ffff              dc.w     $ffff
01000c36  ffff              dc.w     $ffff
01000c38  ffff              dc.w     $ffff
01000c3a  ffff              dc.w     $ffff
01000c3c  ffff              dc.w     $ffff
01000c3e  ffff              dc.w     $ffff
01000c40  ffff              dc.w     $ffff
01000c42  ffff              dc.w     $ffff
01000c44  ffff              dc.w     $ffff
01000c46  ffff              dc.w     $ffff
01000c48  00000000          ori.b    #$0, d0
01000c4c  00000000          ori.b    #$0, d0
01000c50  00000000          ori.b    #$0, d0
01000c54  00000000          ori.b    #$0, d0
01000c58  00000000          ori.b    #$0, d0
01000c5c  00000000          ori.b    #$0, d0
01000c60  00000000          ori.b    #$0, d0
01000c64  00000000          ori.b    #$0, d0

; ---- gap 010047fa..01004809 (16 bytes) ----
010047fa  48e7fffc          movem.l  d0-d7/a0-a5, -(a7)
010047fe  4eb901004872      jsr      post_snd_in_dma_reset.l
01004804  4cdf3fff          movem.l  (a7)+, d0-d7/a0-a5
01004808  4e73              rte      

; ---- gap 0100482a..0100483d (20 bytes) ----
0100482a  48e7fffc          movem.l  d0-d7/a0-a5, -(a7)
0100482e  4eb9010055f2      jsr      post_snd_out_overrun_intr.l
01004834  4cdf3fff          movem.l  (a7)+, d0-d7/a0-a5
01004838  4e73              rte      
0100483a  4e5e              unlk     a6
0100483c  4e75              rts      

; ---- gap 01007eee..01007f65 (120 bytes) ----
01007eee  0c8200000040      cmpi.l   #$40, d2
01007ef4  6fff0000002e      ble.l    $1007f24
01007efa  2008              move.l   a0, d0
01007efc  2209              move.l   a1, d1
01007efe  b181              eor.l    d0, d1
01007f00  028100000003      andi.l   #$3, d1
01007f06  66ff0000001c      bne.l    $1007f24
01007f0c  9280              sub.l    d0, d1
01007f0e  028100000003      andi.l   #$3, d1
01007f14  67ff0000000e      beq.l    $1007f24
01007f1a  9481              sub.l    d1, d2
01007f1c  5381              subq.l   #$1, d1
01007f1e  12d8              move.b   (a0)+, (a1)+
01007f20  51c9fffc          dbra     d1, $1007f1e
01007f24  2002              move.l   d2, d0
01007f26  e488              lsr.l    #$2, d0
01007f28  67ff0000003e      beq.l    $1007f68
01007f2e  5380              subq.l   #$1, d0
01007f30  0c800000ffff      cmpi.l   #$ffff, d0
01007f36  6fff0000001c      ble.l    $1007f54
01007f3c  203c0000ffff      move.l   #$ffff, d0
01007f42  22d8              move.l   (a0)+, (a1)+
01007f44  51c8fffc          dbra     d0, $1007f42
01007f48  048200040000      subi.l   #$40000, d2
01007f4e  60ffffffffd4      bra.l    $1007f24
01007f54  22d8              move.l   (a0)+, (a1)+
01007f56  51c8fffc          dbra     d0, $1007f54
01007f5a  028200000003      andi.l   #$3, d2
01007f60  60ff00000006      bra.l    $1007f68

; ---- gap 01007f7c..01007ff1 (118 bytes) ----
01007f7c  0c8200000040      cmpi.l   #$40, d2
01007f82  6fff0000002c      ble.l    $1007fb0
01007f88  2008              move.l   a0, d0
01007f8a  2209              move.l   a1, d1
01007f8c  b181              eor.l    d0, d1
01007f8e  028100000003      andi.l   #$3, d1
01007f94  66ff0000001a      bne.l    $1007fb0
01007f9a  028000000003      andi.l   #$3, d0
01007fa0  67ff0000000e      beq.l    $1007fb0
01007fa6  9480              sub.l    d0, d2
01007fa8  5380              subq.l   #$1, d0
01007faa  1320              move.b   -(a0), -(a1)
01007fac  51c8fffc          dbra     d0, $1007faa
01007fb0  2002              move.l   d2, d0
01007fb2  e488              lsr.l    #$2, d0
01007fb4  67ff0000003e      beq.l    $1007ff4
01007fba  5380              subq.l   #$1, d0
01007fbc  0c800000ffff      cmpi.l   #$ffff, d0
01007fc2  6fff0000001c      ble.l    $1007fe0
01007fc8  203c0000ffff      move.l   #$ffff, d0
01007fce  2320              move.l   -(a0), -(a1)
01007fd0  51c8fffc          dbra     d0, $1007fce
01007fd4  048200040000      subi.l   #$40000, d2
01007fda  60ff00000004      bra.l    $1007fe0
01007fe0  2320              move.l   -(a0), -(a1)
01007fe2  51c8fffc          dbra     d0, $1007fe0
01007fe6  028200000003      andi.l   #$3, d2
01007fec  60ff00000006      bra.l    $1007ff4

; ---- gap 01011bee..01012c4d (4192 bytes) ----
01011bee  4e71              nop      
01011bf0  0100              btst.l   d0, d0
01011bf2  0d6c0100          bchg.b   d6, $100(a4)
01011bf6  0d64              bchg.b   d6, -(a4)
01011bf8  0100              btst.l   d0, d0
01011bfa  0d6c0100          bchg.b   d6, $100(a4)
01011bfe  0d7a              dc.w     $0d7a
01011c00  0100              btst.l   d0, d0
01011c02  0d96              bclr.b   d6, (a6)
01011c04  0100              btst.l   d0, d0
01011c06  0d96              bclr.b   d6, (a6)
01011c08  0100              btst.l   d0, d0
01011c0a  0d86              bclr.b   d6, d6
01011c0c  0100              btst.l   d0, d0
01011c0e  0d86              bclr.b   d6, d6
01011c10  0100              btst.l   d0, d0
01011c12  0dbc              dc.w     $0dbc
01011c14  0100              btst.l   d0, d0
01011c16  0dbc              dc.w     $0dbc
01011c18  0100              btst.l   d0, d0
01011c1a  0dac0100          bclr.b   d6, $100(a4)
01011c1e  0dac0100          bclr.b   d6, $100(a4)
01011c22  1d7201001d72      move.b   (a2, d0.w), $1d72(a6)
01011c28  0100              btst.l   d0, d0
01011c2a  1d500100          move.b   (a0), $100(a6)
01011c2e  1d500100          move.b   (a0), $100(a6)
01011c32  1d5e0100          move.b   (a6)+, $100(a6)
01011c36  1d5e0100          move.b   (a6)+, $100(a6)
01011c3a  1d5e0100          move.b   (a6)+, $100(a6)
01011c3e  1d560100          move.b   (a6), $100(a6)
01011c42  22b00100          move.l   (a0, d0.w), (a1)
01011c46  22ba0100          move.l   $1011d48(pc), (a1)
01011c4a  22ba0100          move.l   $1011d4c(pc), (a1)
01011c4e  22ba0100          move.l   $1011d50(pc), (a1)
01011c52  22ba0100          move.l   $1011d54(pc), (a1)
01011c56  22ba0100          move.l   $1011d58(pc), (a1)
01011c5a  22ba0100          move.l   $1011d5c(pc), (a1)
01011c5e  22ba0100          move.l   $1011d60(pc), (a1)
01011c62  22ba0100          move.l   $1011d64(pc), (a1)
01011c66  22ba0100          move.l   $1011d68(pc), (a1)
01011c6a  22ba0100          move.l   $1011d6c(pc), (a1)
01011c6e  22ba0100          move.l   $1011d70(pc), (a1)
01011c72  22ba0100          move.l   $1011d74(pc), (a1)
01011c76  22ba0100          move.l   $1011d78(pc), (a1)
01011c7a  22ba0100          move.l   $1011d7c(pc), (a1)
01011c7e  22ba0100          move.l   $1011d80(pc), (a1)
01011c82  22ba0100          move.l   $1011d84(pc), (a1)
01011c86  1ef80100          move.b   $100.w, (a7)+
01011c8a  22ba0100          move.l   $1011d8c(pc), (a1)
01011c8e  22780100          movea.l  $100.w, a1
01011c92  223a0100          move.l   $1011d94(pc), d1
01011c96  22ba0100          move.l   $1011d98(pc), (a1)
01011c9a  22ba0100          move.l   $1011d9c(pc), (a1)
01011c9e  22ba0100          move.l   $1011da0(pc), (a1)
01011ca2  22ba0100          move.l   $1011da4(pc), (a1)
01011ca6  22ba0100          move.l   $1011da8(pc), (a1)
01011caa  22ba0100          move.l   $1011dac(pc), (a1)
01011cae  22ba0100          move.l   $1011db0(pc), (a1)
01011cb2  22ba0100          move.l   $1011db4(pc), (a1)
01011cb6  22ba0100          move.l   $1011db8(pc), (a1)
01011cba  22ba0100          move.l   $1011dbc(pc), (a1)
01011cbe  22ba0100          move.l   $1011dc0(pc), (a1)
01011cc2  22ba0100          move.l   $1011dc4(pc), (a1)
01011cc6  22ba0100          move.l   $1011dc8(pc), (a1)
01011cca  1ffe              dc.w     $1ffe
01011ccc  0100              btst.l   d0, d0
01011cce  1fd8              dc.w     $1fd8
01011cd0  0100              btst.l   d0, d0
01011cd2  22cc              move.l   a4, (a1)+
01011cd4  0100              btst.l   d0, d0
01011cd6  2012              move.l   (a2), d0
01011cd8  0100              btst.l   d0, d0
01011cda  219a0100          move.l   (a2)+, (a0, d0.w)
01011cde  22ba0100          move.l   $1011de0(pc), (a1)
01011ce2  22ba0100          move.l   $1011de4(pc), (a1)
01011ce6  22b00100          move.l   (a0, d0.w), (a1)
01011cea  22ba0100          move.l   $1011dec(pc), (a1)
01011cee  22ba0100          move.l   $1011df0(pc), (a1)
01011cf2  22ba0100          move.l   $1011df4(pc), (a1)
01011cf6  22ba0100          move.l   $1011df8(pc), (a1)
01011cfa  203a0100          move.l   $1011dfc(pc), d0
01011cfe  22ba0100          move.l   $1011e00(pc), (a1)
01011d02  22ba0100          move.l   $1011e04(pc), (a1)
01011d06  213a0100          move.l   $1011e08(pc), -(a0)
01011d0a  22ba0100          move.l   $1011e0c(pc), (a1)
01011d0e  2026              move.l   -(a6), d0
01011d10  0100              btst.l   d0, d0
01011d12  216801006560      move.l   $100(a0), $6560(a0)
01011d18  0100              btst.l   d0, d0
01011d1a  658c              bcs.b    $1011ca8
01011d1c  0100              btst.l   d0, d0
01011d1e  6566              bcs.b    $1011d86
01011d20  0100              btst.l   d0, d0
01011d22  657a              bcs.b    $1011d9e
01011d24  0100              btst.l   d0, d0
01011d26  662a              bne.b    $1011d52
01011d28  0100              btst.l   d0, d0
01011d2a  7b24              dc.w     $7b24
01011d2c  0100              btst.l   d0, d0
01011d2e  78ae              moveq    #$ae, d4
01011d30  0100              btst.l   d0, d0
01011d32  78ae              moveq    #$ae, d4
01011d34  0100              btst.l   d0, d0
01011d36  78ae              moveq    #$ae, d4
01011d38  0100              btst.l   d0, d0
01011d3a  78ae              moveq    #$ae, d4
01011d3c  0100              btst.l   d0, d0
01011d3e  78ae              moveq    #$ae, d4
01011d40  0100              btst.l   d0, d0
01011d42  78ae              moveq    #$ae, d4
01011d44  0100              btst.l   d0, d0
01011d46  78ae              moveq    #$ae, d4
01011d48  0100              btst.l   d0, d0
01011d4a  78ae              moveq    #$ae, d4
01011d4c  0100              btst.l   d0, d0
01011d4e  78ae              moveq    #$ae, d4
01011d50  0100              btst.l   d0, d0
01011d52  78ae              moveq    #$ae, d4
01011d54  0100              btst.l   d0, d0
01011d56  78d6              moveq    #$d6, d4
01011d58  0100              btst.l   d0, d0
01011d5a  78da              moveq    #$da, d4
01011d5c  0100              btst.l   d0, d0
01011d5e  78da              moveq    #$da, d4
01011d60  0100              btst.l   d0, d0
01011d62  78da              moveq    #$da, d4
01011d64  0100              btst.l   d0, d0
01011d66  78da              moveq    #$da, d4
01011d68  0100              btst.l   d0, d0
01011d6a  78da              moveq    #$da, d4
01011d6c  0100              btst.l   d0, d0
01011d6e  78da              moveq    #$da, d4
01011d70  0100              btst.l   d0, d0
01011d72  78da              moveq    #$da, d4
01011d74  0100              btst.l   d0, d0
01011d76  78da              moveq    #$da, d4
01011d78  0100              btst.l   d0, d0
01011d7a  78da              moveq    #$da, d4
01011d7c  0100              btst.l   d0, d0
01011d7e  78ae              moveq    #$ae, d4
01011d80  0100              btst.l   d0, d0
01011d82  78ae              moveq    #$ae, d4
01011d84  0100              btst.l   d0, d0
01011d86  78ae              moveq    #$ae, d4
01011d88  0100              btst.l   d0, d0
01011d8a  78ae              moveq    #$ae, d4
01011d8c  0100              btst.l   d0, d0
01011d8e  78ae              moveq    #$ae, d4
01011d90  0100              btst.l   d0, d0
01011d92  78ae              moveq    #$ae, d4
01011d94  0100              btst.l   d0, d0
01011d96  78ae              moveq    #$ae, d4
01011d98  0100              btst.l   d0, d0
01011d9a  78ae              moveq    #$ae, d4
01011d9c  0100              btst.l   d0, d0
01011d9e  78ae              moveq    #$ae, d4
01011da0  0100              btst.l   d0, d0
01011da2  78ae              moveq    #$ae, d4
01011da4  0100              btst.l   d0, d0
01011da6  78e4              moveq    #$e4, d4
01011da8  0100              btst.l   d0, d0
01011daa  78ae              moveq    #$ae, d4
01011dac  0100              btst.l   d0, d0
01011dae  78ae              moveq    #$ae, d4
01011db0  0100              btst.l   d0, d0
01011db2  78ae              moveq    #$ae, d4
01011db4  0100              btst.l   d0, d0
01011db6  78ae              moveq    #$ae, d4
01011db8  0100              btst.l   d0, d0
01011dba  78ae              moveq    #$ae, d4
01011dbc  0100              btst.l   d0, d0
01011dbe  78ae              moveq    #$ae, d4
01011dc0  0100              btst.l   d0, d0
01011dc2  78ae              moveq    #$ae, d4
01011dc4  0100              btst.l   d0, d0
01011dc6  78ae              moveq    #$ae, d4
01011dc8  0100              btst.l   d0, d0
01011dca  78ae              moveq    #$ae, d4
01011dcc  0100              btst.l   d0, d0
01011dce  78ae              moveq    #$ae, d4
01011dd0  0100              btst.l   d0, d0
01011dd2  78e8              moveq    #$e8, d4
01011dd4  0100              btst.l   d0, d0
01011dd6  78ae              moveq    #$ae, d4
01011dd8  0100              btst.l   d0, d0
01011dda  78ae              moveq    #$ae, d4
01011ddc  0100              btst.l   d0, d0
01011dde  78ae              moveq    #$ae, d4
01011de0  0100              btst.l   d0, d0
01011de2  78ae              moveq    #$ae, d4
01011de4  0100              btst.l   d0, d0
01011de6  78ae              moveq    #$ae, d4
01011de8  0100              btst.l   d0, d0
01011dea  78ae              moveq    #$ae, d4
01011dec  0100              btst.l   d0, d0
01011dee  78ae              moveq    #$ae, d4
01011df0  0100              btst.l   d0, d0
01011df2  78ae              moveq    #$ae, d4
01011df4  0100              btst.l   d0, d0
01011df6  78e0              moveq    #$e0, d4
01011df8  0100              btst.l   d0, d0
01011dfa  78ae              moveq    #$ae, d4
01011dfc  0100              btst.l   d0, d0
01011dfe  78ae              moveq    #$ae, d4
01011e00  0100              btst.l   d0, d0
01011e02  78ae              moveq    #$ae, d4
01011e04  0100              btst.l   d0, d0
01011e06  78ae              moveq    #$ae, d4
01011e08  0100              btst.l   d0, d0
01011e0a  78ae              moveq    #$ae, d4
01011e0c  0100              btst.l   d0, d0
01011e0e  78ae              moveq    #$ae, d4
01011e10  0100              btst.l   d0, d0
01011e12  78ae              moveq    #$ae, d4
01011e14  0100              btst.l   d0, d0
01011e16  78ae              moveq    #$ae, d4
01011e18  0100              btst.l   d0, d0
01011e1a  78ae              moveq    #$ae, d4
01011e1c  0100              btst.l   d0, d0
01011e1e  7926              dc.w     $7926
01011e20  0100              btst.l   d0, d0
01011e22  7904              dc.w     $7904
01011e24  0100              btst.l   d0, d0
01011e26  78e4              moveq    #$e4, d4
01011e28  0100              btst.l   d0, d0
01011e2a  78ae              moveq    #$ae, d4
01011e2c  0100              btst.l   d0, d0
01011e2e  78ae              moveq    #$ae, d4
01011e30  0100              btst.l   d0, d0
01011e32  78ae              moveq    #$ae, d4
01011e34  0100              btst.l   d0, d0
01011e36  78ae              moveq    #$ae, d4
01011e38  0100              btst.l   d0, d0
01011e3a  78ae              moveq    #$ae, d4
01011e3c  0100              btst.l   d0, d0
01011e3e  78ae              moveq    #$ae, d4
01011e40  0100              btst.l   d0, d0
01011e42  78ae              moveq    #$ae, d4
01011e44  0100              btst.l   d0, d0
01011e46  78bc              moveq    #$bc, d4
01011e48  0100              btst.l   d0, d0
01011e4a  78ae              moveq    #$ae, d4
01011e4c  0100              btst.l   d0, d0
01011e4e  78ae              moveq    #$ae, d4
01011e50  0100              btst.l   d0, d0
01011e52  78e8              moveq    #$e8, d4
01011e54  0100              btst.l   d0, d0
01011e56  78ae              moveq    #$ae, d4
01011e58  0100              btst.l   d0, d0
01011e5a  78ae              moveq    #$ae, d4
01011e5c  0100              btst.l   d0, d0
01011e5e  78ae              moveq    #$ae, d4
01011e60  0100              btst.l   d0, d0
01011e62  7b06              dc.w     $7b06
01011e64  0100              btst.l   d0, d0
01011e66  78ae              moveq    #$ae, d4
01011e68  0100              btst.l   d0, d0
01011e6a  78e4              moveq    #$e4, d4
01011e6c  0100              btst.l   d0, d0
01011e6e  78ae              moveq    #$ae, d4
01011e70  0100              btst.l   d0, d0
01011e72  78ae              moveq    #$ae, d4
01011e74  0100              btst.l   d0, d0
01011e76  78e0              moveq    #$e0, d4
01011e78  0100              btst.l   d0, d0
01011e7a  a47c              dc.w     $a47c
01011e7c  0100              btst.l   d0, d0
01011e7e  a4ca              dc.w     $a4ca
01011e80  0100              btst.l   d0, d0
01011e82  a4ca              dc.w     $a4ca
01011e84  0100              btst.l   d0, d0
01011e86  a4ca              dc.w     $a4ca
01011e88  0100              btst.l   d0, d0
01011e8a  a4ca              dc.w     $a4ca
01011e8c  0100              btst.l   d0, d0
01011e8e  a4ca              dc.w     $a4ca
01011e90  0100              btst.l   d0, d0
01011e92  a47c              dc.w     $a47c
01011e94  0100              btst.l   d0, d0
01011e96  a4ca              dc.w     $a4ca
01011e98  0100              btst.l   d0, d0
01011e9a  a704              dc.w     $a704
01011e9c  0100              btst.l   d0, d0
01011e9e  a6a4              dc.w     $a6a4
01011ea0  0100              btst.l   d0, d0
01011ea2  a6b4              dc.w     $a6b4
01011ea4  0100              btst.l   d0, d0
01011ea6  a69c              dc.w     $a69c
01011ea8  0100              btst.l   d0, d0
01011eaa  a71a              dc.w     $a71a
01011eac  0100              btst.l   d0, d0
01011eae  a6f2              dc.w     $a6f2
01011eb0  0100              btst.l   d0, d0
01011eb2  a678              dc.w     $a678
01011eb4  0100              btst.l   d0, d0
01011eb6  a98a              dc.w     $a98a
01011eb8  0100              btst.l   d0, d0
01011eba  a988              dc.w     $a988
01011ebc  0100              btst.l   d0, d0
01011ebe  a986              dc.w     $a986
01011ec0  0100              btst.l   d0, d0
01011ec2  a984              dc.w     $a984
01011ec4  0100              btst.l   d0, d0
01011ec6  a982              dc.w     $a982
01011ec8  0100              btst.l   d0, d0
01011eca  a980              dc.w     $a980
01011ecc  0100              btst.l   d0, d0
01011ece  a97e              dc.w     $a97e
01011ed0  0100              btst.l   d0, d0
01011ed2  a97c              dc.w     $a97c
01011ed4  0100              btst.l   d0, d0
01011ed6  a97a              dc.w     $a97a
01011ed8  0100              btst.l   d0, d0
01011eda  a978              dc.w     $a978
01011edc  0100              btst.l   d0, d0
01011ede  a976              dc.w     $a976
01011ee0  0100              btst.l   d0, d0
01011ee2  a974              dc.w     $a974
01011ee4  0100              btst.l   d0, d0
01011ee6  a972              dc.w     $a972
01011ee8  0100              btst.l   d0, d0
01011eea  a970              dc.w     $a970
01011eec  0100              btst.l   d0, d0
01011eee  a96e              dc.w     $a96e
01011ef0  0100              btst.l   d0, d0
01011ef2  a96c              dc.w     $a96c
01011ef4  0100              btst.l   d0, d0
01011ef6  a96a              dc.w     $a96a
01011ef8  0100              btst.l   d0, d0
01011efa  a968              dc.w     $a968
01011efc  0100              btst.l   d0, d0
01011efe  a966              dc.w     $a966
01011f00  0100              btst.l   d0, d0
01011f02  a964              dc.w     $a964
01011f04  0100              btst.l   d0, d0
01011f06  a962              dc.w     $a962
01011f08  0100              btst.l   d0, d0
01011f0a  a960              dc.w     $a960
01011f0c  0100              btst.l   d0, d0
01011f0e  a95e              dc.w     $a95e
01011f10  0100              btst.l   d0, d0
01011f12  a95c              dc.w     $a95c
01011f14  0100              btst.l   d0, d0
01011f16  a95a              dc.w     $a95a
01011f18  0100              btst.l   d0, d0
01011f1a  a958              dc.w     $a958
01011f1c  0100              btst.l   d0, d0
01011f1e  a956              dc.w     $a956
01011f20  0100              btst.l   d0, d0
01011f22  a954              dc.w     $a954
01011f24  0100              btst.l   d0, d0
01011f26  a952              dc.w     $a952
01011f28  0100              btst.l   d0, d0
01011f2a  a950              dc.w     $a950
01011f2c  0100              btst.l   d0, d0
01011f2e  a94e              dc.w     $a94e
01011f30  0100              btst.l   d0, d0
01011f32  a94c              dc.w     $a94c
01011f34  0100              btst.l   d0, d0
01011f36  b7b00100          eor.l    d3, (a0, d0.w)
01011f3a  b41e              cmp.b    (a6)+, d2
01011f3c  0100              btst.l   d0, d0
01011f3e  b488              cmp.l    a0, d2
01011f40  0100              btst.l   d0, d0
01011f42  b4d2              cmpa.w   (a2), a2
01011f44  0100              btst.l   d0, d0
01011f46  b54a              cmpm.w   (a2)+, (a2)+
01011f48  0100              btst.l   d0, d0
01011f4a  b5ba              dc.w     $b5ba
01011f4c  0100              btst.l   d0, d0
01011f4e  b744              eor.w    d3, d4
01011f50  0100              btst.l   d0, d0
01011f52  b608              dc.w     $b608
01011f54  0100              btst.l   d0, d0
01011f56  b656              cmp.w    (a6), d3
01011f58  0100              btst.l   d0, d0
01011f5a  b6a4              cmp.l    -(a4), d3
01011f5c  0100              btst.l   d0, d0
01011f5e  b6d2              cmpa.w   (a2), a3
01011f60  0100              btst.l   d0, d0
01011f62  b6fc0100          cmpa.w   #$100, a3
01011f66  b726              eor.b    d3, -(a6)
01011f68  0100              btst.l   d0, d0
01011f6a  b7a4              eor.l    d3, -(a4)
01011f6c  0100              btst.l   d0, d0
01011f6e  b7760100          eor.w    d3, (a6, d0.w)
01011f72  b77e              dc.w     $b77e
01011f74  0100              btst.l   d0, d0
01011f76  b786              eor.l    d3, d6
01011f78  0100              btst.l   d0, d0
01011f7a  b78e              cmpm.l   (a6)+, (a3)+
01011f7c  0100              btst.l   d0, d0
01011f7e  b796              eor.l    d3, (a6)
01011f80  0100              btst.l   d0, d0
01011f82  b79e              eor.l    d3, (a6)+
01011f84  0100              btst.l   d0, d0
01011f86  b3b00100          eor.l    d1, (a0, d0.w)
01011f8a  b3b00100          eor.l    d1, (a0, d0.w)
01011f8e  b3b00100          eor.l    d1, (a0, d0.w)
01011f92  b3b00100          eor.l    d1, (a0, d0.w)
01011f96  b3b00100          eor.l    d1, (a0, d0.w)
01011f9a  b3b00100          eor.l    d1, (a0, d0.w)
01011f9e  b3b00100          eor.l    d1, (a0, d0.w)
01011fa2  b3b00100          eor.l    d1, (a0, d0.w)
01011fa6  b3b00100          eor.l    d1, (a0, d0.w)
01011faa  b3b00100          eor.l    d1, (a0, d0.w)
01011fae  b3b00100          eor.l    d1, (a0, d0.w)
01011fb2  b3b00100          eor.l    d1, (a0, d0.w)
01011fb6  b3ee0100          cmpa.l   $100(a6), a1
01011fba  b3fe              dc.w     $b3fe
01011fbc  0100              btst.l   d0, d0
01011fbe  b4680100          cmp.w    $100(a0), d2
01011fc2  b3b00100          eor.l    d1, (a0, d0.w)
01011fc6  b5280100          eor.b    d2, $100(a0)
01011fca  b5760100          eor.w    d2, (a6, d0.w)
01011fce  b598              eor.l    d2, (a0)+
01011fd0  0100              btst.l   d0, d0
01011fd2  b5e6              cmpa.l   -(a6), a2
01011fd4  0100              btst.l   d0, d0
01011fd6  b6340100          cmp.b    (a4, d0.w), d3
01011fda  b682              cmp.l    d2, d3
01011fdc  0100              btst.l   d0, d0
01011fde  b99e              eor.l    d4, (a6)+
01011fe0  0100              btst.l   d0, d0
01011fe2  b9a2              eor.l    d4, -(a2)
01011fe4  0100              btst.l   d0, d0
01011fe6  b994              eor.l    d4, (a4)
01011fe8  0100              btst.l   d0, d0
01011fea  b9a2              eor.l    d4, -(a2)
01011fec  0100              btst.l   d0, d0
01011fee  b994              eor.l    d4, (a4)
01011ff0  0100              btst.l   d0, d0
01011ff2  b9a2              eor.l    d4, -(a2)
01011ff4  0100              btst.l   d0, d0
01011ff6  b994              eor.l    d4, (a4)
01011ff8  0100              btst.l   d0, d0
01011ffa  b9a2              eor.l    d4, -(a2)
01011ffc  0100              btst.l   d0, d0
01011ffe  b994              eor.l    d4, (a4)
01012000  0010171c          ori.b    #$1c, (a0)
01012004  2024              move.l   -(a4), d0
01012006  272a2d30          move.l   $2d30(a2), -(a3)
0101200a  3235373a3c3e40424446  move.w   ([$3c3e4042, a5, d3.w * 8], $4446), d1
01012014  4749              dc.w     $4749
01012016  4b4d              dc.w     $4b4d
01012018  4e505153          link.w   a0, #$5153
0101201c  5456              addq.w   #$2, (a6)
0101201e  5759              subq.w   #$3, (a1)+
01012020  5a5c              addq.w   #$5, (a4)+
01012022  5d5e              subq.w   #$6, (a6)+
01012024  6061              bra.b    $1012087
01012026  6264              bhi.b    $101208c
01012028  6566              bcs.b    $1012090
0101202a  6769              beq.b    $1012095
0101202c  6a6b              bpl.b    $1012099
0101202e  6c6d              bge.b    $101209d
01012030  6f70              ble.b    $10120a2
01012032  7172              dc.w     $7172
01012034  7374              dc.w     $7374
01012036  7576              dc.w     $7576
01012038  7779              dc.w     $7779
0101203a  7a7b              moveq    #$7b, d5
0101203c  7c7d              moveq    #$7d, d6
0101203e  7e7f              moveq    #$7f, d7
01012040  8081              or.l     d1, d0
01012042  8283              or.l     d3, d1
01012044  8485              or.l     d5, d2
01012046  8687              or.l     d7, d3
01012048  8788898a          unpk     -(a0), -(a3), #$898a
0101204c  8b8c8d8e          unpk     -(a4), -(a5), #$8d8e
01012050  8f90              or.l     d7, (a0)
01012052  9191              sub.l    d0, (a1)
01012054  9293              sub.l    (a3), d1
01012056  9495              sub.l    (a5), d2
01012058  9697              sub.l    (a7), d3
0101205a  9798              sub.l    d3, (a0)+
0101205c  999a              sub.l    d4, (a2)+
0101205e  9b9c              sub.l    d5, (a4)+
01012060  9c9d              sub.l    (a5)+, d6
01012062  9e9f              sub.l    (a7)+, d7
01012064  a0a0              dc.w     $a0a0
01012066  a1a2              dc.w     $a1a2
01012068  a3a4              dc.w     $a3a4
0101206a  a4a5              dc.w     $a4a5
0101206c  a6a7              dc.w     $a6a7
0101206e  a7a8              dc.w     $a7a8
01012070  a9aa              dc.w     $a9aa
01012072  aaab              dc.w     $aaab
01012074  acad              dc.w     $acad
01012076  adae              dc.w     $adae
01012078  afb0              dc.w     $afb0
0101207a  b0b1b2b3          cmp.l    -$4d(a1, a3.w), d0
0101207e  b3b4b5b5b6b7b7b8  eor.l    d1, ([$b6b7b7b8], a3.w * 4)
01012086  b9ba              dc.w     $b9ba
01012088  babbbcbc          cmp.l    $1012046(pc, a3.l), d5
0101208c  bdbe              dc.w     $bdbe
0101208e  bebf              dc.w     $bebf
01012090  c0c0              mulu.w   d0, d0
01012092  c1c2              muls.w   d2, d0
01012094  c2c3              mulu.w   d3, d1
01012096  c4c4              mulu.w   d4, d2
01012098  c5c6              muls.w   d6, d2
0101209a  c6c7              mulu.w   d7, d3
0101209c  c7c8              dc.w     $c7c8
0101209e  c9c9              dc.w     $c9c9
010120a0  cacb              dc.w     $cacb
010120a2  cbcc              dc.w     $cbcc
010120a4  cccd              dc.w     $cccd
010120a6  cece              dc.w     $cece
010120a8  cfd0              muls.w   (a0), d7
010120aa  d0d1              adda.w   (a1), a0
010120ac  d1d2              adda.l   (a2), a0
010120ae  d3d3              adda.l   (a3), a1
010120b0  d4d4              adda.w   (a4), a2
010120b2  d5d6              adda.l   (a6), a2
010120b4  d6d7              adda.w   (a7), a3
010120b6  d7d8              adda.l   (a0)+, a3
010120b8  d9d9              adda.l   (a1)+, a4
010120ba  dada              adda.w   (a2)+, a5
010120bc  dbdc              adda.l   (a4)+, a5
010120be  dcdd              adda.w   (a5)+, a6
010120c0  ddde              adda.l   (a6)+, a6
010120c2  dedf              adda.w   (a7)+, a7
010120c4  e0e0              asr.w    -(a0)
010120c6  e1e1              asl.w    -(a1)
010120c8  e2e2              lsr.w    -(a2)
010120ca  e3e4              lsl.w    -(a4)
010120cc  e4e5              roxr.w   -(a5)
010120ce  e5e6              roxl.w   -(a6)
010120d0  e6e7              ror.w    -(a7)
010120d2  e7e8e9e9          rol.w    -$1617(a0)
010120d6  eaea              dc.w     $eaea
010120d8  ebeb              dc.w     $ebeb
010120da  ecec              dc.w     $ecec
010120dc  eded              dc.w     $eded
010120de  eeee              dc.w     $eeee
010120e0  eff0              dc.w     $eff0
010120e2  f0f1f1f2f2f3      fbf.l    $f2f413d7                   ; $f2f413d7 = NextBus slot space
010120e8  f3f4              dc.w     $f3f4
010120ea  f4f5              cpushp   #$3, a5
010120ec  f5f6              dc.w     $f5f6
010120ee  f6f7f7f8f8f9      fbf.l    $f8fa19e9                   ; $f8fa19e9 = NextBus slot space
010120f4  f9fa              dc.w     $f9fa
010120f6  fafbfbfcfcfd      fbf.l    $fcfe1df5                   ; $fcfe1df5 = NextBus slot space
010120fc  fdfe              dc.w     $fdfe
010120fe  feff0100bf94      fbf.l    $201e094                    ; $0201e094 = RAMDAC (Brooktree Bt463)
01012104  0100              btst.l   d0, d0
01012106  bf98              eor.l    d7, (a0)+
01012108  0100              btst.l   d0, d0
0101210a  bf94              eor.l    d7, (a4)
0101210c  0100              btst.l   d0, d0
0101210e  bf98              eor.l    d7, (a0)+
01012110  0100              btst.l   d0, d0
01012112  bf94              eor.l    d7, (a4)
01012114  0100              btst.l   d0, d0
01012116  bf98              eor.l    d7, (a0)+
01012118  0100              btst.l   d0, d0
0101211a  bf94              eor.l    d7, (a4)
0101211c  0100              btst.l   d0, d0
0101211e  bf98              eor.l    d7, (a0)+
01012120  0100              btst.l   d0, d0
01012122  bf94              eor.l    d7, (a4)
01012124  0100              btst.l   d0, d0
01012126  c6a4              and.l    -(a4), d3
01012128  0100              btst.l   d0, d0
0101212a  c68a              dc.w     $c68a
0101212c  0100              btst.l   d0, d0
0101212e  c6a4              and.l    -(a4), d3
01012130  0100              btst.l   d0, d0
01012132  c68a              dc.w     $c68a
01012134  0100              btst.l   d0, d0
01012136  c6a4              and.l    -(a4), d3
01012138  0100              btst.l   d0, d0
0101213a  c68a              dc.w     $c68a
0101213c  0100              btst.l   d0, d0
0101213e  c958              and.w    d4, (a0)+
01012140  0100              btst.l   d0, d0
01012142  c96c0100          and.w    d4, $100(a4)
01012146  c986              dc.w     $c986
01012148  0100              btst.l   d0, d0
0101214a  c9e6              muls.w   -(a6), d4
0101214c  0100              btst.l   d0, d0
0101214e  c9a80100          and.l    d4, $100(a0)
01012152  cb8e              exg.l    d5, a6
01012154  0100              btst.l   d0, d0
01012156  cb8e              exg.l    d5, a6
01012158  0100              btst.l   d0, d0
0101215a  cb8e              exg.l    d5, a6
0101215c  0100              btst.l   d0, d0
0101215e  cb8e              exg.l    d5, a6
01012160  0100              btst.l   d0, d0
01012162  cb8e              exg.l    d5, a6
01012164  0100              btst.l   d0, d0
01012166  cb8e              exg.l    d5, a6
01012168  0100              btst.l   d0, d0
0101216a  cb8e              exg.l    d5, a6
0101216c  0100              btst.l   d0, d0
0101216e  cb8e              exg.l    d5, a6
01012170  0100              btst.l   d0, d0
01012172  cb8e              exg.l    d5, a6
01012174  0100              btst.l   d0, d0
01012176  cb8e              exg.l    d5, a6
01012178  0100              btst.l   d0, d0
0101217a  cb8e              exg.l    d5, a6
0101217c  0100              btst.l   d0, d0
0101217e  cb8e              exg.l    d5, a6
01012180  0100              btst.l   d0, d0
01012182  cb8e              exg.l    d5, a6
01012184  0100              btst.l   d0, d0
01012186  cb8e              exg.l    d5, a6
01012188  0100              btst.l   d0, d0
0101218a  cb8e              exg.l    d5, a6
0101218c  0100              btst.l   d0, d0
0101218e  cb8e              exg.l    d5, a6
01012190  0100              btst.l   d0, d0
01012192  cb8e              exg.l    d5, a6
01012194  0100              btst.l   d0, d0
01012196  cb8e              exg.l    d5, a6
01012198  0100              btst.l   d0, d0
0101219a  cb8e              exg.l    d5, a6
0101219c  0100              btst.l   d0, d0
0101219e  cb8e              exg.l    d5, a6
010121a0  0100              btst.l   d0, d0
010121a2  cb8e              exg.l    d5, a6
010121a4  0100              btst.l   d0, d0
010121a6  cb8e              exg.l    d5, a6
010121a8  0100              btst.l   d0, d0
010121aa  cb8e              exg.l    d5, a6
010121ac  0100              btst.l   d0, d0
010121ae  cb8e              exg.l    d5, a6
010121b0  0100              btst.l   d0, d0
010121b2  cb8e              exg.l    d5, a6
010121b4  0100              btst.l   d0, d0
010121b6  cb8e              exg.l    d5, a6
010121b8  0100              btst.l   d0, d0
010121ba  cb8e              exg.l    d5, a6
010121bc  0100              btst.l   d0, d0
010121be  cb8e              exg.l    d5, a6
010121c0  0100              btst.l   d0, d0
010121c2  cb8e              exg.l    d5, a6
010121c4  0100              btst.l   d0, d0
010121c6  cb8e              exg.l    d5, a6
010121c8  0100              btst.l   d0, d0
010121ca  cb8e              exg.l    d5, a6
010121cc  0100              btst.l   d0, d0
010121ce  cb8e              exg.l    d5, a6
010121d0  0100              btst.l   d0, d0
010121d2  cb8e              exg.l    d5, a6
010121d4  0100              btst.l   d0, d0
010121d6  cb8e              exg.l    d5, a6
010121d8  0100              btst.l   d0, d0
010121da  cb8e              exg.l    d5, a6
010121dc  0100              btst.l   d0, d0
010121de  cb8e              exg.l    d5, a6
010121e0  0100              btst.l   d0, d0
010121e2  cb8e              exg.l    d5, a6
010121e4  0100              btst.l   d0, d0
010121e6  cb8e              exg.l    d5, a6
010121e8  0100              btst.l   d0, d0
010121ea  cb8e              exg.l    d5, a6
010121ec  0100              btst.l   d0, d0
010121ee  cb8e              exg.l    d5, a6
010121f0  0100              btst.l   d0, d0
010121f2  cb8e              exg.l    d5, a6
010121f4  0100              btst.l   d0, d0
010121f6  cb8e              exg.l    d5, a6
010121f8  0100              btst.l   d0, d0
010121fa  cb8e              exg.l    d5, a6
010121fc  0100              btst.l   d0, d0
010121fe  cb8e              exg.l    d5, a6
01012200  0100              btst.l   d0, d0
01012202  cb8e              exg.l    d5, a6
01012204  0100              btst.l   d0, d0
01012206  cb8e              exg.l    d5, a6
01012208  0100              btst.l   d0, d0
0101220a  cb8e              exg.l    d5, a6
0101220c  0100              btst.l   d0, d0
0101220e  cb8e              exg.l    d5, a6
01012210  0100              btst.l   d0, d0
01012212  cb8e              exg.l    d5, a6
01012214  0100              btst.l   d0, d0
01012216  cb8e              exg.l    d5, a6
01012218  0100              btst.l   d0, d0
0101221a  cb8e              exg.l    d5, a6
0101221c  0100              btst.l   d0, d0
0101221e  cb8e              exg.l    d5, a6
01012220  0100              btst.l   d0, d0
01012222  cb8e              exg.l    d5, a6
01012224  0100              btst.l   d0, d0
01012226  cb8e              exg.l    d5, a6
01012228  0100              btst.l   d0, d0
0101222a  cb8e              exg.l    d5, a6
0101222c  0100              btst.l   d0, d0
0101222e  ca3e              dc.w     $ca3e
01012230  0100              btst.l   d0, d0
01012232  cb8e              exg.l    d5, a6
01012234  0100              btst.l   d0, d0
01012236  cb8e              exg.l    d5, a6
01012238  0100              btst.l   d0, d0
0101223a  cb8e              exg.l    d5, a6
0101223c  0100              btst.l   d0, d0
0101223e  cb8e              exg.l    d5, a6
01012240  0100              btst.l   d0, d0
01012242  cb8e              exg.l    d5, a6
01012244  0100              btst.l   d0, d0
01012246  cb8e              exg.l    d5, a6
01012248  0100              btst.l   d0, d0
0101224a  cb8e              exg.l    d5, a6
0101224c  0100              btst.l   d0, d0
0101224e  cb8e              exg.l    d5, a6
01012250  0100              btst.l   d0, d0
01012252  c99e              and.l    d4, (a6)+
01012254  0100              btst.l   d0, d0
01012256  c9ce              dc.w     $c9ce
01012258  0100              btst.l   d0, d0
0101225a  c962              and.w    d4, -(a2)
0101225c  0100              btst.l   d0, d0
0101225e  ca82              and.l    d2, d5
01012260  0100              btst.l   d0, d0
01012262  caac0100          and.l    $100(a4), d5
01012266  cac6              mulu.w   d6, d5
01012268  0100              btst.l   d0, d0
0101226a  cb14              and.b    d5, (a4)
0101226c  0100              btst.l   d0, d0
0101226e  cae80100          mulu.w   $100(a0), d5
01012272  cb8e              exg.l    d5, a6
01012274  0100              btst.l   d0, d0
01012276  cb8e              exg.l    d5, a6
01012278  0100              btst.l   d0, d0
0101227a  cb8e              exg.l    d5, a6
0101227c  0100              btst.l   d0, d0
0101227e  cb8e              exg.l    d5, a6
01012280  0100              btst.l   d0, d0
01012282  cb8e              exg.l    d5, a6
01012284  0100              btst.l   d0, d0
01012286  cb8e              exg.l    d5, a6
01012288  0100              btst.l   d0, d0
0101228a  cb8e              exg.l    d5, a6
0101228c  0100              btst.l   d0, d0
0101228e  cb8e              exg.l    d5, a6
01012290  0100              btst.l   d0, d0
01012292  cb8e              exg.l    d5, a6
01012294  0100              btst.l   d0, d0
01012296  cb8e              exg.l    d5, a6
01012298  0100              btst.l   d0, d0
0101229a  cb8e              exg.l    d5, a6
0101229c  0100              btst.l   d0, d0
0101229e  cb8e              exg.l    d5, a6
010122a0  0100              btst.l   d0, d0
010122a2  cb8e              exg.l    d5, a6
010122a4  0100              btst.l   d0, d0
010122a6  cb8e              exg.l    d5, a6
010122a8  0100              btst.l   d0, d0
010122aa  cb8e              exg.l    d5, a6
010122ac  0100              btst.l   d0, d0
010122ae  cb8e              exg.l    d5, a6
010122b0  0100              btst.l   d0, d0
010122b2  cb8e              exg.l    d5, a6
010122b4  0100              btst.l   d0, d0
010122b6  cb8e              exg.l    d5, a6
010122b8  0100              btst.l   d0, d0
010122ba  cb8e              exg.l    d5, a6
010122bc  0100              btst.l   d0, d0
010122be  cb8e              exg.l    d5, a6
010122c0  0100              btst.l   d0, d0
010122c2  cb8e              exg.l    d5, a6
010122c4  0100              btst.l   d0, d0
010122c6  cb8e              exg.l    d5, a6
010122c8  0100              btst.l   d0, d0
010122ca  cb8e              exg.l    d5, a6
010122cc  0100              btst.l   d0, d0
010122ce  cb8e              exg.l    d5, a6
010122d0  0100              btst.l   d0, d0
010122d2  cb8e              exg.l    d5, a6
010122d4  0100              btst.l   d0, d0
010122d6  cb8e              exg.l    d5, a6
010122d8  0100              btst.l   d0, d0
010122da  cb8e              exg.l    d5, a6
010122dc  0100              btst.l   d0, d0
010122de  cb8e              exg.l    d5, a6
010122e0  0100              btst.l   d0, d0
010122e2  cb8e              exg.l    d5, a6
010122e4  0100              btst.l   d0, d0
010122e6  cb8e              exg.l    d5, a6
010122e8  0100              btst.l   d0, d0
010122ea  cb8e              exg.l    d5, a6
010122ec  0100              btst.l   d0, d0
010122ee  cb8e              exg.l    d5, a6
010122f0  0100              btst.l   d0, d0
010122f2  cb8e              exg.l    d5, a6
010122f4  0100              btst.l   d0, d0
010122f6  cb8e              exg.l    d5, a6
010122f8  0100              btst.l   d0, d0
010122fa  cb8e              exg.l    d5, a6
010122fc  0100              btst.l   d0, d0
010122fe  cb8e              exg.l    d5, a6
01012300  0100              btst.l   d0, d0
01012302  cb8e              exg.l    d5, a6
01012304  0100              btst.l   d0, d0
01012306  cb8e              exg.l    d5, a6
01012308  0100              btst.l   d0, d0
0101230a  cb8e              exg.l    d5, a6
0101230c  0100              btst.l   d0, d0
0101230e  cb8e              exg.l    d5, a6
01012310  0100              btst.l   d0, d0
01012312  cb8e              exg.l    d5, a6
01012314  0100              btst.l   d0, d0
01012316  cb8e              exg.l    d5, a6
01012318  0100              btst.l   d0, d0
0101231a  cb8e              exg.l    d5, a6
0101231c  0100              btst.l   d0, d0
0101231e  cb8e              exg.l    d5, a6
01012320  0100              btst.l   d0, d0
01012322  cb8e              exg.l    d5, a6
01012324  0100              btst.l   d0, d0
01012326  cb8e              exg.l    d5, a6
01012328  0100              btst.l   d0, d0
0101232a  cb8e              exg.l    d5, a6
0101232c  0100              btst.l   d0, d0
0101232e  cb8e              exg.l    d5, a6
01012330  0100              btst.l   d0, d0
01012332  cb8e              exg.l    d5, a6
01012334  0100              btst.l   d0, d0
01012336  cb8e              exg.l    d5, a6
01012338  0100              btst.l   d0, d0
0101233a  cb8e              exg.l    d5, a6
0101233c  0100              btst.l   d0, d0
0101233e  cb8e              exg.l    d5, a6
01012340  0100              btst.l   d0, d0
01012342  cb8e              exg.l    d5, a6
01012344  0100              btst.l   d0, d0
01012346  cb8e              exg.l    d5, a6
01012348  0100              btst.l   d0, d0
0101234a  cb8e              exg.l    d5, a6
0101234c  0100              btst.l   d0, d0
0101234e  cb740100          and.w    d5, (a4, d0.w)
01012352  cb8e              exg.l    d5, a6
01012354  0100              btst.l   d0, d0
01012356  cb8e              exg.l    d5, a6
01012358  0100              btst.l   d0, d0
0101235a  cb8e              exg.l    d5, a6
0101235c  0100              btst.l   d0, d0
0101235e  cb8e              exg.l    d5, a6
01012360  0100              btst.l   d0, d0
01012362  cb8e              exg.l    d5, a6
01012364  0100              btst.l   d0, d0
01012366  cb8e              exg.l    d5, a6
01012368  0100              btst.l   d0, d0
0101236a  cb8e              exg.l    d5, a6
0101236c  0100              btst.l   d0, d0
0101236e  cb8e              exg.l    d5, a6
01012370  0100              btst.l   d0, d0
01012372  cade              mulu.w   (a6)+, d5
01012374  0100              btst.l   d0, d0
01012376  cb06              abcd.b   d6, d5
01012378  0100              btst.l   d0, d0
0101237a  ca8a              dc.w     $ca8a
0101237c  0100              btst.l   d0, d0
0101237e  cd680100          and.w    d6, $100(a0)
01012382  cd7c              dc.w     $cd7c
01012384  0100              btst.l   d0, d0
01012386  cd96              and.l    d6, (a6)
01012388  0100              btst.l   d0, d0
0101238a  cdf60100          muls.w   (a6, d0.w), d6
0101238e  cdb80100          and.l    d6, $100.w
01012392  cf9e              and.l    d7, (a6)+
01012394  0100              btst.l   d0, d0
01012396  cf9e              and.l    d7, (a6)+
01012398  0100              btst.l   d0, d0
0101239a  cf9e              and.l    d7, (a6)+
0101239c  0100              btst.l   d0, d0
0101239e  cf9e              and.l    d7, (a6)+
010123a0  0100              btst.l   d0, d0
010123a2  cf9e              and.l    d7, (a6)+
010123a4  0100              btst.l   d0, d0
010123a6  cf9e              and.l    d7, (a6)+
010123a8  0100              btst.l   d0, d0
010123aa  cf9e              and.l    d7, (a6)+
010123ac  0100              btst.l   d0, d0
010123ae  cf9e              and.l    d7, (a6)+
010123b0  0100              btst.l   d0, d0
010123b2  cf9e              and.l    d7, (a6)+
010123b4  0100              btst.l   d0, d0
010123b6  cf9e              and.l    d7, (a6)+
010123b8  0100              btst.l   d0, d0
010123ba  cf9e              and.l    d7, (a6)+
010123bc  0100              btst.l   d0, d0
010123be  cf9e              and.l    d7, (a6)+
010123c0  0100              btst.l   d0, d0
010123c2  cf9e              and.l    d7, (a6)+
010123c4  0100              btst.l   d0, d0
010123c6  cf9e              and.l    d7, (a6)+
010123c8  0100              btst.l   d0, d0
010123ca  cf9e              and.l    d7, (a6)+
010123cc  0100              btst.l   d0, d0
010123ce  cf9e              and.l    d7, (a6)+
010123d0  0100              btst.l   d0, d0
010123d2  cf9e              and.l    d7, (a6)+
010123d4  0100              btst.l   d0, d0
010123d6  cf9e              and.l    d7, (a6)+
010123d8  0100              btst.l   d0, d0
010123da  cf9e              and.l    d7, (a6)+
010123dc  0100              btst.l   d0, d0
010123de  cf9e              and.l    d7, (a6)+
010123e0  0100              btst.l   d0, d0
010123e2  cf9e              and.l    d7, (a6)+
010123e4  0100              btst.l   d0, d0
010123e6  cf9e              and.l    d7, (a6)+
010123e8  0100              btst.l   d0, d0
010123ea  cf9e              and.l    d7, (a6)+
010123ec  0100              btst.l   d0, d0
010123ee  cf9e              and.l    d7, (a6)+
010123f0  0100              btst.l   d0, d0
010123f2  cf9e              and.l    d7, (a6)+
010123f4  0100              btst.l   d0, d0
010123f6  cf9e              and.l    d7, (a6)+
010123f8  0100              btst.l   d0, d0
010123fa  cf9e              and.l    d7, (a6)+
010123fc  0100              btst.l   d0, d0
010123fe  cf9e              and.l    d7, (a6)+
01012400  0100              btst.l   d0, d0
01012402  cf9e              and.l    d7, (a6)+
01012404  0100              btst.l   d0, d0
01012406  cf9e              and.l    d7, (a6)+
01012408  0100              btst.l   d0, d0
0101240a  cf9e              and.l    d7, (a6)+
0101240c  0100              btst.l   d0, d0
0101240e  cf9e              and.l    d7, (a6)+
01012410  0100              btst.l   d0, d0
01012412  cf9e              and.l    d7, (a6)+
01012414  0100              btst.l   d0, d0
01012416  cf9e              and.l    d7, (a6)+
01012418  0100              btst.l   d0, d0
0101241a  cf9e              and.l    d7, (a6)+
0101241c  0100              btst.l   d0, d0
0101241e  cf9e              and.l    d7, (a6)+
01012420  0100              btst.l   d0, d0
01012422  cf9e              and.l    d7, (a6)+
01012424  0100              btst.l   d0, d0
01012426  cf9e              and.l    d7, (a6)+
01012428  0100              btst.l   d0, d0
0101242a  cf9e              and.l    d7, (a6)+
0101242c  0100              btst.l   d0, d0
0101242e  cf9e              and.l    d7, (a6)+
01012430  0100              btst.l   d0, d0
01012432  cf9e              and.l    d7, (a6)+
01012434  0100              btst.l   d0, d0
01012436  cf9e              and.l    d7, (a6)+
01012438  0100              btst.l   d0, d0
0101243a  cf9e              and.l    d7, (a6)+
0101243c  0100              btst.l   d0, d0
0101243e  cf9e              and.l    d7, (a6)+
01012440  0100              btst.l   d0, d0
01012442  cf9e              and.l    d7, (a6)+
01012444  0100              btst.l   d0, d0
01012446  cf9e              and.l    d7, (a6)+
01012448  0100              btst.l   d0, d0
0101244a  cf9e              and.l    d7, (a6)+
0101244c  0100              btst.l   d0, d0
0101244e  cf9e              and.l    d7, (a6)+
01012450  0100              btst.l   d0, d0
01012452  cf9e              and.l    d7, (a6)+
01012454  0100              btst.l   d0, d0
01012456  cf9e              and.l    d7, (a6)+
01012458  0100              btst.l   d0, d0
0101245a  cf9e              and.l    d7, (a6)+
0101245c  0100              btst.l   d0, d0
0101245e  cf9e              and.l    d7, (a6)+
01012460  0100              btst.l   d0, d0
01012462  cf9e              and.l    d7, (a6)+
01012464  0100              btst.l   d0, d0
01012466  cf9e              and.l    d7, (a6)+
01012468  0100              btst.l   d0, d0
0101246a  cf9e              and.l    d7, (a6)+
0101246c  0100              btst.l   d0, d0
0101246e  ce4e              dc.w     $ce4e
01012470  0100              btst.l   d0, d0
01012472  cf9e              and.l    d7, (a6)+
01012474  0100              btst.l   d0, d0
01012476  cf9e              and.l    d7, (a6)+
01012478  0100              btst.l   d0, d0
0101247a  cf9e              and.l    d7, (a6)+
0101247c  0100              btst.l   d0, d0
0101247e  cf9e              and.l    d7, (a6)+
01012480  0100              btst.l   d0, d0
01012482  cf9e              and.l    d7, (a6)+
01012484  0100              btst.l   d0, d0
01012486  cf9e              and.l    d7, (a6)+
01012488  0100              btst.l   d0, d0
0101248a  cf9e              and.l    d7, (a6)+
0101248c  0100              btst.l   d0, d0
0101248e  cf9e              and.l    d7, (a6)+
01012490  0100              btst.l   d0, d0
01012492  cdae0100          and.l    d6, $100(a6)
01012496  cdde              muls.w   (a6)+, d6
01012498  0100              btst.l   d0, d0
0101249a  cd720100          and.w    d6, (a2, d0.w)
0101249e  ce92              and.l    (a2), d7
010124a0  0100              btst.l   d0, d0
010124a2  cebc0100ced6      and.l    #kbd_b_down_shift_l, d7
010124a8  0100              btst.l   d0, d0
010124aa  cf24              and.b    d7, -(a4)
010124ac  0100              btst.l   d0, d0
010124ae  cef80100          mulu.w   $100.w, d7
010124b2  cf9e              and.l    d7, (a6)+
010124b4  0100              btst.l   d0, d0
010124b6  cf9e              and.l    d7, (a6)+
010124b8  0100              btst.l   d0, d0
010124ba  cf9e              and.l    d7, (a6)+
010124bc  0100              btst.l   d0, d0
010124be  cf9e              and.l    d7, (a6)+
010124c0  0100              btst.l   d0, d0
010124c2  cf9e              and.l    d7, (a6)+
010124c4  0100              btst.l   d0, d0
010124c6  cf9e              and.l    d7, (a6)+
010124c8  0100              btst.l   d0, d0
010124ca  cf9e              and.l    d7, (a6)+
010124cc  0100              btst.l   d0, d0
010124ce  cf9e              and.l    d7, (a6)+
010124d0  0100              btst.l   d0, d0
010124d2  cf9e              and.l    d7, (a6)+
010124d4  0100              btst.l   d0, d0
010124d6  cf9e              and.l    d7, (a6)+
010124d8  0100              btst.l   d0, d0
010124da  cf9e              and.l    d7, (a6)+
010124dc  0100              btst.l   d0, d0
010124de  cf9e              and.l    d7, (a6)+
010124e0  0100              btst.l   d0, d0
010124e2  cf9e              and.l    d7, (a6)+
010124e4  0100              btst.l   d0, d0
010124e6  cf9e              and.l    d7, (a6)+
010124e8  0100              btst.l   d0, d0
010124ea  cf9e              and.l    d7, (a6)+
010124ec  0100              btst.l   d0, d0
010124ee  cf9e              and.l    d7, (a6)+
010124f0  0100              btst.l   d0, d0
010124f2  cf9e              and.l    d7, (a6)+
010124f4  0100              btst.l   d0, d0
010124f6  cf9e              and.l    d7, (a6)+
010124f8  0100              btst.l   d0, d0
010124fa  cf9e              and.l    d7, (a6)+
010124fc  0100              btst.l   d0, d0
010124fe  cf9e              and.l    d7, (a6)+
01012500  0100              btst.l   d0, d0
01012502  cf9e              and.l    d7, (a6)+
01012504  0100              btst.l   d0, d0
01012506  cf9e              and.l    d7, (a6)+
01012508  0100              btst.l   d0, d0
0101250a  cf9e              and.l    d7, (a6)+
0101250c  0100              btst.l   d0, d0
0101250e  cf9e              and.l    d7, (a6)+
01012510  0100              btst.l   d0, d0
01012512  cf9e              and.l    d7, (a6)+
01012514  0100              btst.l   d0, d0
01012516  cf9e              and.l    d7, (a6)+
01012518  0100              btst.l   d0, d0
0101251a  cf9e              and.l    d7, (a6)+
0101251c  0100              btst.l   d0, d0
0101251e  cf9e              and.l    d7, (a6)+
01012520  0100              btst.l   d0, d0
01012522  cf9e              and.l    d7, (a6)+
01012524  0100              btst.l   d0, d0
01012526  cf9e              and.l    d7, (a6)+
01012528  0100              btst.l   d0, d0
0101252a  cf9e              and.l    d7, (a6)+
0101252c  0100              btst.l   d0, d0
0101252e  cf9e              and.l    d7, (a6)+
01012530  0100              btst.l   d0, d0
01012532  cf9e              and.l    d7, (a6)+
01012534  0100              btst.l   d0, d0
01012536  cf9e              and.l    d7, (a6)+
01012538  0100              btst.l   d0, d0
0101253a  cf9e              and.l    d7, (a6)+
0101253c  0100              btst.l   d0, d0
0101253e  cf9e              and.l    d7, (a6)+
01012540  0100              btst.l   d0, d0
01012542  cf9e              and.l    d7, (a6)+
01012544  0100              btst.l   d0, d0
01012546  cf9e              and.l    d7, (a6)+
01012548  0100              btst.l   d0, d0
0101254a  cf9e              and.l    d7, (a6)+
0101254c  0100              btst.l   d0, d0
0101254e  cf9e              and.l    d7, (a6)+
01012550  0100              btst.l   d0, d0
01012552  cf9e              and.l    d7, (a6)+
01012554  0100              btst.l   d0, d0
01012556  cf9e              and.l    d7, (a6)+
01012558  0100              btst.l   d0, d0
0101255a  cf9e              and.l    d7, (a6)+
0101255c  0100              btst.l   d0, d0
0101255e  cf9e              and.l    d7, (a6)+
01012560  0100              btst.l   d0, d0
01012562  cf9e              and.l    d7, (a6)+
01012564  0100              btst.l   d0, d0
01012566  cf9e              and.l    d7, (a6)+
01012568  0100              btst.l   d0, d0
0101256a  cf9e              and.l    d7, (a6)+
0101256c  0100              btst.l   d0, d0
0101256e  cf9e              and.l    d7, (a6)+
01012570  0100              btst.l   d0, d0
01012572  cf9e              and.l    d7, (a6)+
01012574  0100              btst.l   d0, d0
01012576  cf9e              and.l    d7, (a6)+
01012578  0100              btst.l   d0, d0
0101257a  cf9e              and.l    d7, (a6)+
0101257c  0100              btst.l   d0, d0
0101257e  cf9e              and.l    d7, (a6)+
01012580  0100              btst.l   d0, d0
01012582  cf9e              and.l    d7, (a6)+
01012584  0100              btst.l   d0, d0
01012586  cf9e              and.l    d7, (a6)+
01012588  0100              btst.l   d0, d0
0101258a  cf9e              and.l    d7, (a6)+
0101258c  0100              btst.l   d0, d0
0101258e  cf84              dc.w     $cf84
01012590  0100              btst.l   d0, d0
01012592  cf9e              and.l    d7, (a6)+
01012594  0100              btst.l   d0, d0
01012596  cf9e              and.l    d7, (a6)+
01012598  0100              btst.l   d0, d0
0101259a  cf9e              and.l    d7, (a6)+
0101259c  0100              btst.l   d0, d0
0101259e  cf9e              and.l    d7, (a6)+
010125a0  0100              btst.l   d0, d0
010125a2  cf9e              and.l    d7, (a6)+
010125a4  0100              btst.l   d0, d0
010125a6  cf9e              and.l    d7, (a6)+
010125a8  0100              btst.l   d0, d0
010125aa  cf9e              and.l    d7, (a6)+
010125ac  0100              btst.l   d0, d0
010125ae  cf9e              and.l    d7, (a6)+
010125b0  0100              btst.l   d0, d0
010125b2  ceee0100          mulu.w   $100(a6), d7
010125b6  cf16              and.b    d7, (a6)
010125b8  0100              btst.l   d0, d0
010125ba  ce9a              and.l    (a2)+, d7
010125bc  0100              btst.l   d0, d0
010125be  d194              add.l    d0, (a4)
010125c0  0100              btst.l   d0, d0
010125c2  d1a80100          add.l    d0, $100(a0)
010125c6  d1c2              adda.l   d2, a0
010125c8  0100              btst.l   d0, d0
010125ca  d222              add.b    -(a2), d1
010125cc  0100              btst.l   d0, d0
010125ce  d1e4              adda.l   -(a4), a0
010125d0  0100              btst.l   d0, d0
010125d2  d3ca              adda.l   a2, a1
010125d4  0100              btst.l   d0, d0
010125d6  d3ca              adda.l   a2, a1
010125d8  0100              btst.l   d0, d0
010125da  d3ca              adda.l   a2, a1
010125dc  0100              btst.l   d0, d0
010125de  d3ca              adda.l   a2, a1
010125e0  0100              btst.l   d0, d0
010125e2  d3ca              adda.l   a2, a1
010125e4  0100              btst.l   d0, d0
010125e6  d3ca              adda.l   a2, a1
010125e8  0100              btst.l   d0, d0
010125ea  d3ca              adda.l   a2, a1
010125ec  0100              btst.l   d0, d0
010125ee  d3ca              adda.l   a2, a1
010125f0  0100              btst.l   d0, d0
010125f2  d3ca              adda.l   a2, a1
010125f4  0100              btst.l   d0, d0
010125f6  d3ca              adda.l   a2, a1
010125f8  0100              btst.l   d0, d0
010125fa  d3ca              adda.l   a2, a1
010125fc  0100              btst.l   d0, d0
010125fe  d3ca              adda.l   a2, a1
01012600  0100              btst.l   d0, d0
01012602  d3ca              adda.l   a2, a1
01012604  0100              btst.l   d0, d0
01012606  d3ca              adda.l   a2, a1
01012608  0100              btst.l   d0, d0
0101260a  d3ca              adda.l   a2, a1
0101260c  0100              btst.l   d0, d0
0101260e  d3ca              adda.l   a2, a1
01012610  0100              btst.l   d0, d0
01012612  d3ca              adda.l   a2, a1
01012614  0100              btst.l   d0, d0
01012616  d3ca              adda.l   a2, a1
01012618  0100              btst.l   d0, d0
0101261a  d3ca              adda.l   a2, a1
0101261c  0100              btst.l   d0, d0
0101261e  d3ca              adda.l   a2, a1
01012620  0100              btst.l   d0, d0
01012622  d3ca              adda.l   a2, a1
01012624  0100              btst.l   d0, d0
01012626  d3ca              adda.l   a2, a1
01012628  0100              btst.l   d0, d0
0101262a  d3ca              adda.l   a2, a1
0101262c  0100              btst.l   d0, d0
0101262e  d3ca              adda.l   a2, a1
01012630  0100              btst.l   d0, d0
01012632  d3ca              adda.l   a2, a1
01012634  0100              btst.l   d0, d0
01012636  d3ca              adda.l   a2, a1
01012638  0100              btst.l   d0, d0
0101263a  d3ca              adda.l   a2, a1
0101263c  0100              btst.l   d0, d0
0101263e  d3ca              adda.l   a2, a1
01012640  0100              btst.l   d0, d0
01012642  d3ca              adda.l   a2, a1
01012644  0100              btst.l   d0, d0
01012646  d3ca              adda.l   a2, a1
01012648  0100              btst.l   d0, d0
0101264a  d3ca              adda.l   a2, a1
0101264c  0100              btst.l   d0, d0
0101264e  d3ca              adda.l   a2, a1
01012650  0100              btst.l   d0, d0
01012652  d3ca              adda.l   a2, a1
01012654  0100              btst.l   d0, d0
01012656  d3ca              adda.l   a2, a1
01012658  0100              btst.l   d0, d0
0101265a  d3ca              adda.l   a2, a1
0101265c  0100              btst.l   d0, d0
0101265e  d3ca              adda.l   a2, a1
01012660  0100              btst.l   d0, d0
01012662  d3ca              adda.l   a2, a1
01012664  0100              btst.l   d0, d0
01012666  d3ca              adda.l   a2, a1
01012668  0100              btst.l   d0, d0
0101266a  d3ca              adda.l   a2, a1
0101266c  0100              btst.l   d0, d0
0101266e  d3ca              adda.l   a2, a1
01012670  0100              btst.l   d0, d0
01012672  d3ca              adda.l   a2, a1
01012674  0100              btst.l   d0, d0
01012676  d3ca              adda.l   a2, a1
01012678  0100              btst.l   d0, d0
0101267a  d3ca              adda.l   a2, a1
0101267c  0100              btst.l   d0, d0
0101267e  d3ca              adda.l   a2, a1
01012680  0100              btst.l   d0, d0
01012682  d3ca              adda.l   a2, a1
01012684  0100              btst.l   d0, d0
01012686  d3ca              adda.l   a2, a1
01012688  0100              btst.l   d0, d0
0101268a  d3ca              adda.l   a2, a1
0101268c  0100              btst.l   d0, d0
0101268e  d3ca              adda.l   a2, a1
01012690  0100              btst.l   d0, d0
01012692  d3ca              adda.l   a2, a1
01012694  0100              btst.l   d0, d0
01012696  d3ca              adda.l   a2, a1
01012698  0100              btst.l   d0, d0
0101269a  d3ca              adda.l   a2, a1
0101269c  0100              btst.l   d0, d0
0101269e  d3ca              adda.l   a2, a1
010126a0  0100              btst.l   d0, d0
010126a2  d3ca              adda.l   a2, a1
010126a4  0100              btst.l   d0, d0
010126a6  d3ca              adda.l   a2, a1
010126a8  0100              btst.l   d0, d0
010126aa  d3ca              adda.l   a2, a1
010126ac  0100              btst.l   d0, d0
010126ae  d27a0100          add.w    $10127b0(pc), d1
010126b2  d3ca              adda.l   a2, a1
010126b4  0100              btst.l   d0, d0
010126b6  d3ca              adda.l   a2, a1
010126b8  0100              btst.l   d0, d0
010126ba  d3ca              adda.l   a2, a1
010126bc  0100              btst.l   d0, d0
010126be  d3ca              adda.l   a2, a1
010126c0  0100              btst.l   d0, d0
010126c2  d3ca              adda.l   a2, a1
010126c4  0100              btst.l   d0, d0
010126c6  d3ca              adda.l   a2, a1
010126c8  0100              btst.l   d0, d0
010126ca  d3ca              adda.l   a2, a1
010126cc  0100              btst.l   d0, d0
010126ce  d3ca              adda.l   a2, a1
010126d0  0100              btst.l   d0, d0
010126d2  d1da              adda.l   (a2)+, a0
010126d4  0100              btst.l   d0, d0
010126d6  d20a              dc.w     $d20a
010126d8  0100              btst.l   d0, d0
010126da  d19e              add.l    d0, (a6)+
010126dc  0100              btst.l   d0, d0
010126de  d2be              dc.w     $d2be
010126e0  0100              btst.l   d0, d0
010126e2  d2e80100          adda.w   $100(a0), a1
010126e6  d302              addx.b   d2, d1
010126e8  0100              btst.l   d0, d0
010126ea  d350              add.w    d1, (a0)
010126ec  0100              btst.l   d0, d0
010126ee  d324              add.b    d1, -(a4)
010126f0  0100              btst.l   d0, d0
010126f2  d3ca              adda.l   a2, a1
010126f4  0100              btst.l   d0, d0
010126f6  d3ca              adda.l   a2, a1
010126f8  0100              btst.l   d0, d0
010126fa  d3ca              adda.l   a2, a1
010126fc  0100              btst.l   d0, d0
010126fe  d3ca              adda.l   a2, a1
01012700  0100              btst.l   d0, d0
01012702  d3ca              adda.l   a2, a1
01012704  0100              btst.l   d0, d0
01012706  d3ca              adda.l   a2, a1
01012708  0100              btst.l   d0, d0
0101270a  d3ca              adda.l   a2, a1
0101270c  0100              btst.l   d0, d0
0101270e  d3ca              adda.l   a2, a1
01012710  0100              btst.l   d0, d0
01012712  d3ca              adda.l   a2, a1
01012714  0100              btst.l   d0, d0
01012716  d3ca              adda.l   a2, a1
01012718  0100              btst.l   d0, d0
0101271a  d3ca              adda.l   a2, a1
0101271c  0100              btst.l   d0, d0
0101271e  d3ca              adda.l   a2, a1
01012720  0100              btst.l   d0, d0
01012722  d3ca              adda.l   a2, a1
01012724  0100              btst.l   d0, d0
01012726  d3ca              adda.l   a2, a1
01012728  0100              btst.l   d0, d0
0101272a  d3ca              adda.l   a2, a1
0101272c  0100              btst.l   d0, d0
0101272e  d3ca              adda.l   a2, a1
01012730  0100              btst.l   d0, d0
01012732  d3ca              adda.l   a2, a1
01012734  0100              btst.l   d0, d0
01012736  d3ca              adda.l   a2, a1
01012738  0100              btst.l   d0, d0
0101273a  d3ca              adda.l   a2, a1
0101273c  0100              btst.l   d0, d0
0101273e  d3ca              adda.l   a2, a1
01012740  0100              btst.l   d0, d0
01012742  d3ca              adda.l   a2, a1
01012744  0100              btst.l   d0, d0
01012746  d3ca              adda.l   a2, a1
01012748  0100              btst.l   d0, d0
0101274a  d3ca              adda.l   a2, a1
0101274c  0100              btst.l   d0, d0
0101274e  d3ca              adda.l   a2, a1
01012750  0100              btst.l   d0, d0
01012752  d3ca              adda.l   a2, a1
01012754  0100              btst.l   d0, d0
01012756  d3ca              adda.l   a2, a1
01012758  0100              btst.l   d0, d0
0101275a  d3ca              adda.l   a2, a1
0101275c  0100              btst.l   d0, d0
0101275e  d3ca              adda.l   a2, a1
01012760  0100              btst.l   d0, d0
01012762  d3ca              adda.l   a2, a1
01012764  0100              btst.l   d0, d0
01012766  d3ca              adda.l   a2, a1
01012768  0100              btst.l   d0, d0
0101276a  d3ca              adda.l   a2, a1
0101276c  0100              btst.l   d0, d0
0101276e  d3ca              adda.l   a2, a1
01012770  0100              btst.l   d0, d0
01012772  d3ca              adda.l   a2, a1
01012774  0100              btst.l   d0, d0
01012776  d3ca              adda.l   a2, a1
01012778  0100              btst.l   d0, d0
0101277a  d3ca              adda.l   a2, a1
0101277c  0100              btst.l   d0, d0
0101277e  d3ca              adda.l   a2, a1
01012780  0100              btst.l   d0, d0
01012782  d3ca              adda.l   a2, a1
01012784  0100              btst.l   d0, d0
01012786  d3ca              adda.l   a2, a1
01012788  0100              btst.l   d0, d0
0101278a  d3ca              adda.l   a2, a1
0101278c  0100              btst.l   d0, d0
0101278e  d3ca              adda.l   a2, a1
01012790  0100              btst.l   d0, d0
01012792  d3ca              adda.l   a2, a1
01012794  0100              btst.l   d0, d0
01012796  d3ca              adda.l   a2, a1
01012798  0100              btst.l   d0, d0
0101279a  d3ca              adda.l   a2, a1
0101279c  0100              btst.l   d0, d0
0101279e  d3ca              adda.l   a2, a1
010127a0  0100              btst.l   d0, d0
010127a2  d3ca              adda.l   a2, a1
010127a4  0100              btst.l   d0, d0
010127a6  d3ca              adda.l   a2, a1
010127a8  0100              btst.l   d0, d0
010127aa  d3ca              adda.l   a2, a1
010127ac  0100              btst.l   d0, d0
010127ae  d3ca              adda.l   a2, a1
010127b0  0100              btst.l   d0, d0
010127b2  d3ca              adda.l   a2, a1
010127b4  0100              btst.l   d0, d0
010127b6  d3ca              adda.l   a2, a1
010127b8  0100              btst.l   d0, d0
010127ba  d3ca              adda.l   a2, a1
010127bc  0100              btst.l   d0, d0
010127be  d3ca              adda.l   a2, a1
010127c0  0100              btst.l   d0, d0
010127c2  d3ca              adda.l   a2, a1
010127c4  0100              btst.l   d0, d0
010127c6  d3ca              adda.l   a2, a1
010127c8  0100              btst.l   d0, d0
010127ca  d3ca              adda.l   a2, a1
010127cc  0100              btst.l   d0, d0
010127ce  d3b00100          add.l    d1, (a0, d0.w)
010127d2  d3ca              adda.l   a2, a1
010127d4  0100              btst.l   d0, d0
010127d6  d3ca              adda.l   a2, a1
010127d8  0100              btst.l   d0, d0
010127da  d3ca              adda.l   a2, a1
010127dc  0100              btst.l   d0, d0
010127de  d3ca              adda.l   a2, a1
010127e0  0100              btst.l   d0, d0
010127e2  d3ca              adda.l   a2, a1
010127e4  0100              btst.l   d0, d0
010127e6  d3ca              adda.l   a2, a1
010127e8  0100              btst.l   d0, d0
010127ea  d3ca              adda.l   a2, a1
010127ec  0100              btst.l   d0, d0
010127ee  d3ca              adda.l   a2, a1
010127f0  0100              btst.l   d0, d0
010127f2  d31a              add.b    d1, (a2)+
010127f4  0100              btst.l   d0, d0
010127f6  d342              addx.w   d2, d1
010127f8  0100              btst.l   d0, d0
010127fa  d2c6              adda.w   d6, a1
010127fc  0100              btst.l   d0, d0
010127fe  d5ee0100          adda.l   $100(a6), a2
01012802  d602              add.b    d2, d3
01012804  0100              btst.l   d0, d0
01012806  d61c              add.b    (a4)+, d3
01012808  0100              btst.l   d0, d0
0101280a  d67c0100          add.w    #$100, d3
0101280e  d63e              dc.w     $d63e
01012810  0100              btst.l   d0, d0
01012812  d824              add.b    -(a4), d4
01012814  0100              btst.l   d0, d0
01012816  d824              add.b    -(a4), d4
01012818  0100              btst.l   d0, d0
0101281a  d824              add.b    -(a4), d4
0101281c  0100              btst.l   d0, d0
0101281e  d824              add.b    -(a4), d4
01012820  0100              btst.l   d0, d0
01012822  d824              add.b    -(a4), d4
01012824  0100              btst.l   d0, d0
01012826  d824              add.b    -(a4), d4
01012828  0100              btst.l   d0, d0
0101282a  d824              add.b    -(a4), d4
0101282c  0100              btst.l   d0, d0
0101282e  d824              add.b    -(a4), d4
01012830  0100              btst.l   d0, d0
01012832  d824              add.b    -(a4), d4
01012834  0100              btst.l   d0, d0
01012836  d824              add.b    -(a4), d4
01012838  0100              btst.l   d0, d0
0101283a  d824              add.b    -(a4), d4
0101283c  0100              btst.l   d0, d0
0101283e  d824              add.b    -(a4), d4
01012840  0100              btst.l   d0, d0
01012842  d824              add.b    -(a4), d4
01012844  0100              btst.l   d0, d0
01012846  d824              add.b    -(a4), d4
01012848  0100              btst.l   d0, d0
0101284a  d824              add.b    -(a4), d4
0101284c  0100              btst.l   d0, d0
0101284e  d824              add.b    -(a4), d4
01012850  0100              btst.l   d0, d0
01012852  d824              add.b    -(a4), d4
01012854  0100              btst.l   d0, d0
01012856  d824              add.b    -(a4), d4
01012858  0100              btst.l   d0, d0
0101285a  d824              add.b    -(a4), d4
0101285c  0100              btst.l   d0, d0
0101285e  d824              add.b    -(a4), d4
01012860  0100              btst.l   d0, d0
01012862  d824              add.b    -(a4), d4
01012864  0100              btst.l   d0, d0
01012866  d824              add.b    -(a4), d4
01012868  0100              btst.l   d0, d0
0101286a  d824              add.b    -(a4), d4
0101286c  0100              btst.l   d0, d0
0101286e  d824              add.b    -(a4), d4
01012870  0100              btst.l   d0, d0
01012872  d824              add.b    -(a4), d4
01012874  0100              btst.l   d0, d0
01012876  d824              add.b    -(a4), d4
01012878  0100              btst.l   d0, d0
0101287a  d824              add.b    -(a4), d4
0101287c  0100              btst.l   d0, d0
0101287e  d824              add.b    -(a4), d4
01012880  0100              btst.l   d0, d0
01012882  d824              add.b    -(a4), d4
01012884  0100              btst.l   d0, d0
01012886  d824              add.b    -(a4), d4
01012888  0100              btst.l   d0, d0
0101288a  d824              add.b    -(a4), d4
0101288c  0100              btst.l   d0, d0
0101288e  d824              add.b    -(a4), d4
01012890  0100              btst.l   d0, d0
01012892  d824              add.b    -(a4), d4
01012894  0100              btst.l   d0, d0
01012896  d824              add.b    -(a4), d4
01012898  0100              btst.l   d0, d0
0101289a  d824              add.b    -(a4), d4
0101289c  0100              btst.l   d0, d0
0101289e  d824              add.b    -(a4), d4
010128a0  0100              btst.l   d0, d0
010128a2  d824              add.b    -(a4), d4
010128a4  0100              btst.l   d0, d0
010128a6  d824              add.b    -(a4), d4
010128a8  0100              btst.l   d0, d0
010128aa  d824              add.b    -(a4), d4
010128ac  0100              btst.l   d0, d0
010128ae  d824              add.b    -(a4), d4
010128b0  0100              btst.l   d0, d0
010128b2  d824              add.b    -(a4), d4
010128b4  0100              btst.l   d0, d0
010128b6  d824              add.b    -(a4), d4
010128b8  0100              btst.l   d0, d0
010128ba  d824              add.b    -(a4), d4
010128bc  0100              btst.l   d0, d0
010128be  d824              add.b    -(a4), d4
010128c0  0100              btst.l   d0, d0
010128c2  d824              add.b    -(a4), d4
010128c4  0100              btst.l   d0, d0
010128c6  d824              add.b    -(a4), d4
010128c8  0100              btst.l   d0, d0
010128ca  d824              add.b    -(a4), d4
010128cc  0100              btst.l   d0, d0
010128ce  d824              add.b    -(a4), d4
010128d0  0100              btst.l   d0, d0
010128d2  d824              add.b    -(a4), d4
010128d4  0100              btst.l   d0, d0
010128d6  d824              add.b    -(a4), d4
010128d8  0100              btst.l   d0, d0
010128da  d824              add.b    -(a4), d4
010128dc  0100              btst.l   d0, d0
010128de  d824              add.b    -(a4), d4
010128e0  0100              btst.l   d0, d0
010128e2  d824              add.b    -(a4), d4
010128e4  0100              btst.l   d0, d0
010128e6  d824              add.b    -(a4), d4
010128e8  0100              btst.l   d0, d0
010128ea  d824              add.b    -(a4), d4
010128ec  0100              btst.l   d0, d0
010128ee  d6d4              adda.w   (a4), a3
010128f0  0100              btst.l   d0, d0
010128f2  d824              add.b    -(a4), d4
010128f4  0100              btst.l   d0, d0
010128f6  d824              add.b    -(a4), d4
010128f8  0100              btst.l   d0, d0
010128fa  d824              add.b    -(a4), d4
010128fc  0100              btst.l   d0, d0
010128fe  d824              add.b    -(a4), d4
01012900  0100              btst.l   d0, d0
01012902  d824              add.b    -(a4), d4
01012904  0100              btst.l   d0, d0
01012906  d824              add.b    -(a4), d4
01012908  0100              btst.l   d0, d0
0101290a  d824              add.b    -(a4), d4
0101290c  0100              btst.l   d0, d0
0101290e  d824              add.b    -(a4), d4
01012910  0100              btst.l   d0, d0
01012912  d6340100          add.b    (a4, d0.w), d3
01012916  d664              add.w    -(a4), d3
01012918  0100              btst.l   d0, d0
0101291a  d5f80100          adda.l   $100.w, a2
0101291e  d718              add.b    d3, (a0)+
01012920  0100              btst.l   d0, d0
01012922  d742              addx.w   d2, d3
01012924  0100              btst.l   d0, d0
01012926  d75c              add.w    d3, (a4)+
01012928  0100              btst.l   d0, d0
0101292a  d7aa0100          add.l    d3, $100(a2)
0101292e  d77e              dc.w     $d77e
01012930  0100              btst.l   d0, d0
01012932  d824              add.b    -(a4), d4
01012934  0100              btst.l   d0, d0
01012936  d824              add.b    -(a4), d4
01012938  0100              btst.l   d0, d0
0101293a  d824              add.b    -(a4), d4
0101293c  0100              btst.l   d0, d0
0101293e  d824              add.b    -(a4), d4
01012940  0100              btst.l   d0, d0
01012942  d824              add.b    -(a4), d4
01012944  0100              btst.l   d0, d0
01012946  d824              add.b    -(a4), d4
01012948  0100              btst.l   d0, d0
0101294a  d824              add.b    -(a4), d4
0101294c  0100              btst.l   d0, d0
0101294e  d824              add.b    -(a4), d4
01012950  0100              btst.l   d0, d0
01012952  d824              add.b    -(a4), d4
01012954  0100              btst.l   d0, d0
01012956  d824              add.b    -(a4), d4
01012958  0100              btst.l   d0, d0
0101295a  d824              add.b    -(a4), d4
0101295c  0100              btst.l   d0, d0
0101295e  d824              add.b    -(a4), d4
01012960  0100              btst.l   d0, d0
01012962  d824              add.b    -(a4), d4
01012964  0100              btst.l   d0, d0
01012966  d824              add.b    -(a4), d4
01012968  0100              btst.l   d0, d0
0101296a  d824              add.b    -(a4), d4
0101296c  0100              btst.l   d0, d0
0101296e  d824              add.b    -(a4), d4
01012970  0100              btst.l   d0, d0
01012972  d824              add.b    -(a4), d4
01012974  0100              btst.l   d0, d0
01012976  d824              add.b    -(a4), d4
01012978  0100              btst.l   d0, d0
0101297a  d824              add.b    -(a4), d4
0101297c  0100              btst.l   d0, d0
0101297e  d824              add.b    -(a4), d4
01012980  0100              btst.l   d0, d0
01012982  d824              add.b    -(a4), d4
01012984  0100              btst.l   d0, d0
01012986  d824              add.b    -(a4), d4
01012988  0100              btst.l   d0, d0
0101298a  d824              add.b    -(a4), d4
0101298c  0100              btst.l   d0, d0
0101298e  d824              add.b    -(a4), d4
01012990  0100              btst.l   d0, d0
01012992  d824              add.b    -(a4), d4
01012994  0100              btst.l   d0, d0
01012996  d824              add.b    -(a4), d4
01012998  0100              btst.l   d0, d0
0101299a  d824              add.b    -(a4), d4
0101299c  0100              btst.l   d0, d0
0101299e  d824              add.b    -(a4), d4
010129a0  0100              btst.l   d0, d0
010129a2  d824              add.b    -(a4), d4
010129a4  0100              btst.l   d0, d0
010129a6  d824              add.b    -(a4), d4
010129a8  0100              btst.l   d0, d0
010129aa  d824              add.b    -(a4), d4
010129ac  0100              btst.l   d0, d0
010129ae  d824              add.b    -(a4), d4
010129b0  0100              btst.l   d0, d0
010129b2  d824              add.b    -(a4), d4
010129b4  0100              btst.l   d0, d0
010129b6  d824              add.b    -(a4), d4
010129b8  0100              btst.l   d0, d0
010129ba  d824              add.b    -(a4), d4
010129bc  0100              btst.l   d0, d0
010129be  d824              add.b    -(a4), d4
010129c0  0100              btst.l   d0, d0
010129c2  d824              add.b    -(a4), d4
010129c4  0100              btst.l   d0, d0
010129c6  d824              add.b    -(a4), d4
010129c8  0100              btst.l   d0, d0
010129ca  d824              add.b    -(a4), d4
010129cc  0100              btst.l   d0, d0
010129ce  d824              add.b    -(a4), d4
010129d0  0100              btst.l   d0, d0
010129d2  d824              add.b    -(a4), d4
010129d4  0100              btst.l   d0, d0
010129d6  d824              add.b    -(a4), d4
010129d8  0100              btst.l   d0, d0
010129da  d824              add.b    -(a4), d4
010129dc  0100              btst.l   d0, d0
010129de  d824              add.b    -(a4), d4
010129e0  0100              btst.l   d0, d0
010129e2  d824              add.b    -(a4), d4
010129e4  0100              btst.l   d0, d0
010129e6  d824              add.b    -(a4), d4
010129e8  0100              btst.l   d0, d0
010129ea  d824              add.b    -(a4), d4
010129ec  0100              btst.l   d0, d0
010129ee  d824              add.b    -(a4), d4
010129f0  0100              btst.l   d0, d0
010129f2  d824              add.b    -(a4), d4
010129f4  0100              btst.l   d0, d0
010129f6  d824              add.b    -(a4), d4
010129f8  0100              btst.l   d0, d0
010129fa  d824              add.b    -(a4), d4
010129fc  0100              btst.l   d0, d0
010129fe  d824              add.b    -(a4), d4
01012a00  0100              btst.l   d0, d0
01012a02  d824              add.b    -(a4), d4
01012a04  0100              btst.l   d0, d0
01012a06  d824              add.b    -(a4), d4
01012a08  0100              btst.l   d0, d0
01012a0a  d824              add.b    -(a4), d4
01012a0c  0100              btst.l   d0, d0
01012a0e  d80a              dc.w     $d80a
01012a10  0100              btst.l   d0, d0
01012a12  d824              add.b    -(a4), d4
01012a14  0100              btst.l   d0, d0
01012a16  d824              add.b    -(a4), d4
01012a18  0100              btst.l   d0, d0
01012a1a  d824              add.b    -(a4), d4
01012a1c  0100              btst.l   d0, d0
01012a1e  d824              add.b    -(a4), d4
01012a20  0100              btst.l   d0, d0
01012a22  d824              add.b    -(a4), d4
01012a24  0100              btst.l   d0, d0
01012a26  d824              add.b    -(a4), d4
01012a28  0100              btst.l   d0, d0
01012a2a  d824              add.b    -(a4), d4
01012a2c  0100              btst.l   d0, d0
01012a2e  d824              add.b    -(a4), d4
01012a30  0100              btst.l   d0, d0
01012a32  d7740100          add.w    d3, (a4, d0.w)
01012a36  d79c              add.l    d3, (a4)+
01012a38  0100              btst.l   d0, d0
01012a3a  d720              add.b    d3, -(a0)
01012a3c  0100              btst.l   d0, d0
01012a3e  df740100          add.w    d7, (a4, d0.w)
01012a42  de50              add.w    (a0), d7
01012a44  0100              btst.l   d0, d0
01012a46  df740100          add.w    d7, (a4, d0.w)
01012a4a  dee2              adda.w   -(a2), a7
01012a4c  0100              btst.l   d0, d0
01012a4e  de9a              add.l    (a2)+, d7
01012a50  0100              btst.l   d0, d0
01012a52  df5e              add.w    d7, (a6)+
01012a54  0100              btst.l   d0, d0
01012a56  de86              add.l    d6, d7
01012a58  0100              btst.l   d0, d0
01012a5a  df1e              add.b    d7, (a6)+
01012a5c  0100              btst.l   d0, d0
01012a5e  dfe4              adda.l   -(a4), a7
01012a60  0100              btst.l   d0, d0
01012a62  e05e              ror.w    #$8, d6
01012a64  0100              btst.l   d0, d0
01012a66  dfda              adda.l   (a2)+, a7
01012a68  0100              btst.l   d0, d0
01012a6a  e0e6              asr.w    -(a6)
01012a6c  0100              btst.l   d0, d0
01012a6e  dfda              adda.l   (a2)+, a7
01012a70  0100              btst.l   d0, d0
01012a72  dfda              adda.l   (a2)+, a7
01012a74  0100              btst.l   d0, d0
01012a76  e106              asl.b    #$8, d6
01012a78  0100              btst.l   d0, d0
01012a7a  e0f40100          asr.w    (a4, d0.w)
01012a7e  f43a              cpusha   #$0
01012a80  0100              btst.l   d0, d0
01012a82  f66c0100f796      fsf.b    -$86a(a4)
01012a88  0100              btst.l   d0, d0
01012a8a  f796              dc.w     $f796
01012a8c  0100              btst.l   d0, d0
01012a8e  f7340100          fsave    (a4, d0.w)
01012a92  f7780100          frestore $100.w
01012a96  f716              fsave    (a6)
01012a98  0100              btst.l   d0, d0
01012a9a  f6960100          fbf.w    $1012b9c
01012a9e  f796              dc.w     $f796
01012aa0  0100              btst.l   d0, d0
01012aa2  f796              dc.w     $f796
01012aa4  0100              btst.l   d0, d0
01012aa6  f796              dc.w     $f796
01012aa8  0100              btst.l   d0, d0
01012aaa  f6ac0100          fbf.w    $1012bac
01012aae  f6b20100          fbf.w    $1012bb0
01012ab2  f6fa0101089e      fbf.l    $2023352                    ; $02023352 = NBIC (non-Turbo cube) +$3352
01012ab8  0101              btst.l   d0, d1
01012aba  08e20101          bset.b   #$1, -(a2)
01012abe  09700101          bchg.b   d4, ([a0, d0.w])
01012ac2  09700101          bchg.b   d4, ([a0, d0.w])
01012ac6  09700101          bchg.b   d4, ([a0, d0.w])
01012aca  09700101          bchg.b   d4, ([a0, d0.w])
01012ace  08e20101          bset.b   #$1, -(a2)
01012ad2  08e20101          bset.b   #$1, -(a2)
01012ad6  08e20101          bset.b   #$1, -(a2)
01012ada  08e20101          bset.b   #$1, -(a2)
01012ade  09700101          bchg.b   d4, ([a0, d0.w])
01012ae2  08e20101          bset.b   #$1, -(a2)
01012ae6  08e20101          bset.b   #$1, -(a2)
01012aea  09700101          bchg.b   d4, ([a0, d0.w])
01012aee  08e20101          bset.b   #$1, -(a2)
01012af2  08e20101          bset.b   #$1, -(a2)
01012af6  08e20101          bset.b   #$1, -(a2)
01012afa  0f3a0101          btst.l   d7, $1012bfd(pc)
01012afe  0f480101          movep.l  $101(a0), d7
01012b02  0f58              bchg.b   d7, (a0)+
01012b04  0101              btst.l   d0, d1
01012b06  0f62              bchg.b   d7, -(a2)
01012b08  0101              btst.l   d0, d1
01012b0a  0f760101          bchg.b   d7, ([a6, d0.w])
01012b0e  15360101          move.b   ([a6, d0.w]), -(a2)
01012b12  15540101          move.b   (a4), $101(a2)
01012b16  15540101          move.b   (a4), $101(a2)
01012b1a  15360101          move.b   ([a6, d0.w]), -(a2)
01012b1e  15360101          move.b   ([a6, d0.w]), -(a2)
01012b22  15360101          move.b   ([a6, d0.w]), -(a2)
01012b26  15540101          move.b   (a4), $101(a2)
01012b2a  15360101          move.b   ([a6, d0.w]), -(a2)
01012b2e  15360101          move.b   ([a6, d0.w]), -(a2)
01012b32  15540101          move.b   (a4), $101(a2)
01012b36  15360101          move.b   ([a6, d0.w]), -(a2)
01012b3a  15360101          move.b   ([a6, d0.w]), -(a2)
01012b3e  15540101          move.b   (a4), $101(a2)
01012b42  15360101          move.b   ([a6, d0.w]), -(a2)
01012b46  15540101          move.b   (a4), $101(a2)
01012b4a  15540101          move.b   (a4), $101(a2)
01012b4e  15540101          move.b   (a4), $101(a2)
01012b52  15540101          move.b   (a4), $101(a2)
01012b56  15540101          move.b   (a4), $101(a2)
01012b5a  15540101          move.b   (a4), $101(a2)
01012b5e  15360101          move.b   ([a6, d0.w]), -(a2)
01012b62  187e              dc.w     $187e
01012b64  0101              btst.l   d0, d1
01012b66  187e              dc.w     $187e
01012b68  0101              btst.l   d0, d1
01012b6a  1864              dc.w     $1864
01012b6c  0101              btst.l   d0, d1
01012b6e  1864              dc.w     $1864
01012b70  0101              btst.l   d0, d1
01012b72  1864              dc.w     $1864
01012b74  0101              btst.l   d0, d1
01012b76  187e              dc.w     $187e
01012b78  0101              btst.l   d0, d1
01012b7a  1864              dc.w     $1864
01012b7c  0101              btst.l   d0, d1
01012b7e  1864              dc.w     $1864
01012b80  0101              btst.l   d0, d1
01012b82  1864              dc.w     $1864
01012b84  0101              btst.l   d0, d1
01012b86  1864              dc.w     $1864
01012b88  0101              btst.l   d0, d1
01012b8a  1864              dc.w     $1864
01012b8c  0101              btst.l   d0, d1
01012b8e  187e              dc.w     $187e
01012b90  0101              btst.l   d0, d1
01012b92  1864              dc.w     $1864
01012b94  0101              btst.l   d0, d1
01012b96  1864              dc.w     $1864
01012b98  0101              btst.l   d0, d1
01012b9a  1864              dc.w     $1864
01012b9c  0101              btst.l   d0, d1
01012b9e  187e              dc.w     $187e
01012ba0  0101              btst.l   d0, d1
01012ba2  187e              dc.w     $187e
01012ba4  0101              btst.l   d0, d1
01012ba6  1864              dc.w     $1864
01012ba8  0101              btst.l   d0, d1
01012baa  1864              dc.w     $1864
01012bac  0101              btst.l   d0, d1
01012bae  1864              dc.w     $1864
01012bb0  0101              btst.l   d0, d1
01012bb2  1864              dc.w     $1864
01012bb4  0101              btst.l   d0, d1
01012bb6  1864              dc.w     $1864
01012bb8  0101              btst.l   d0, d1
01012bba  1864              dc.w     $1864
01012bbc  0101              btst.l   d0, d1
01012bbe  1864              dc.w     $1864
01012bc0  0101              btst.l   d0, d1
01012bc2  1864              dc.w     $1864
01012bc4  0101              btst.l   d0, d1
01012bc6  1864              dc.w     $1864
01012bc8  0101              btst.l   d0, d1
01012bca  1864              dc.w     $1864
01012bcc  0101              btst.l   d0, d1
01012bce  1864              dc.w     $1864
01012bd0  0101              btst.l   d0, d1
01012bd2  187e              dc.w     $187e
01012bd4  0101              btst.l   d0, d1
01012bd6  19e8              dc.w     $19e8
01012bd8  0101              btst.l   d0, d1
01012bda  19e8              dc.w     $19e8
01012bdc  0101              btst.l   d0, d1
01012bde  1a44              dc.w     $1a44
01012be0  0101              btst.l   d0, d1
01012be2  1a60              dc.w     $1a60
01012be4  0101              btst.l   d0, d1
01012be6  1a60              dc.w     $1a60
01012be8  0101              btst.l   d0, d1
01012bea  19e8              dc.w     $19e8
01012bec  0101              btst.l   d0, d1
01012bee  1a60              dc.w     $1a60
01012bf0  0101              btst.l   d0, d1
01012bf2  1a60              dc.w     $1a60
01012bf4  0101              btst.l   d0, d1
01012bf6  1a60              dc.w     $1a60
01012bf8  0101              btst.l   d0, d1
01012bfa  1a60              dc.w     $1a60
01012bfc  0101              btst.l   d0, d1
01012bfe  1a24              move.b   -(a4), d5
01012c00  3000              move.w   d0, d0
01012c02  3100              move.w   d0, -(a0)
01012c04  3200              move.w   d0, d1
01012c06  3300              move.w   d0, -(a1)
01012c08  3400              move.w   d0, d2
01012c0a  3500              move.w   d0, -(a2)
01012c0c  3600              move.w   d0, d3
01012c0e  3700              move.w   d0, -(a3)
01012c10  7063              moveq    #$63, d0
01012c12  0073720010cf      ori.w    #$7200, -$31(a3, d1.w)
01012c18  0274726163650e73  andi.w   #$7261, ([$e73, a4])
01012c20  8e750d6d8d69      or.w     ([$8d69, a5]), d7
01012c26  c903              abcd.b   d3, d4
01012c28  6970              bvs.b    $1012c9a
01012c2a  6c05              bge.b    $1012c31
01012c2c  7804              moveq    #$4, d4
01012c2e  6e03              bgt.b    $1012c33
01012c30  7a02              moveq    #$2, d5
01012c32  7601              moveq    #$1, d3
01012c34  63007573          bls.w    $101a1a9
01012c38  7000              moveq    #$0, d0
01012c3a  6973              bvs.b    $1012caf
01012c3c  7000              moveq    #$0, d0
01012c3e  6d73              blt.b    $1012cb3
01012c40  7000              moveq    #$0, d0
01012c42  7662              moveq    #$62, d3
01012c44  7200              moveq    #$0, d1
01012c46  7366              dc.w     $7366
01012c48  63006466          bls.w    $10190b0
01012c4c  6300              dc.w     $6300

; ---- gap 01012c53..01012c5a (8 bytes) ----
01012c53  1020              move.b   -(a0), d0
01012c55  6465              bcc.b    $1012cbc
01012c57  1069              dc.w     $1069
01012c59  6500              dc.w     $6500

; ---- gap 01012c64..01012d4d (234 bytes) ----
01012c64  1020              move.b   -(a0), d0
01012c66  4e4d              trap     #$d
01012c68  491f              chk.l    (a7)+, d4
01012c6a  7077              moveq    #$77, d0
01012c6c  7266              moveq    #$66, d1
01012c6e  6169              bsr.b    $1012cd9
01012c70  6c1e              bge.b    $1012c90
01012c72  7379              dc.w     $7379
01012c74  7374              dc.w     $7374
01012c76  696d              bvs.b    $1012ce5
01012c78  6572              bcs.b    $1012cec
01012c7a  1d656e65          move.b   -(a5), $6e65(a6)
01012c7e  7454              moveq    #$54, d2
01012c80  5844              addq.w   #$4, d4
01012c82  4d41              dc.w     $4d41
01012c84  1c65              dc.w     $1c65
01012c86  6e65              bgt.b    $1012ced
01012c88  7452              moveq    #$52, d2
01012c8a  5844              addq.w   #$4, d4
01012c8c  4d41              dc.w     $4d41
01012c8e  1b73637369444d411a6f7074  move.b   ([$69444d41, a3], $1a6f7074), -$5556(a5) ; $1a6f7074 = RAM MWF mirrors (non-Turbo mono only)
01012c9a  6963              bvs.b    $1012cff
01012c9c  616c              bsr.b    $1012d0a
01012c9e  444d              dc.w     $444d
01012ca0  4119              chk.l    (a1)+, d0
01012ca2  7072              moveq    #$72, d0
01012ca4  696e              bvs.b    $1012d14
01012ca6  7465              moveq    #$65, d2
01012ca8  7244              moveq    #$44, d1
01012caa  4d41              dc.w     $4d41
01012cac  1873              dc.w     $1873
01012cae  6f75              ble.b    $1012d25
01012cb0  6e64              bgt.b    $1012d16
01012cb2  6f75              ble.b    $1012d29
01012cb4  7444              moveq    #$44, d2
01012cb6  4d41              dc.w     $4d41
01012cb8  17736f756e64696e444d  move.b   ([$6e64696e, a3]), $444d(a3)
01012cc2  4116              chk.l    (a6), d0
01012cc4  7363              dc.w     $7363
01012cc6  6344              bls.b    $1012d0c
01012cc8  4d41              dc.w     $4d41
01012cca  15647370          move.b   -(a4), $7370(a2)
01012cce  444d              dc.w     $444d
01012cd0  4114              chk.l    (a4), d0
01012cd2  6d32              blt.b    $1012d06
01012cd4  7244              moveq    #$44, d1
01012cd6  4d41              dc.w     $4d41
01012cd8  1372326d444d      move.b   $6d(a2, d3.w), $444d(a1)
01012cde  4112              chk.l    (a2), d0
01012ce0  7363              dc.w     $7363
01012ce2  6311              bls.b    $1012cf5
01012ce4  7270              moveq    #$70, d1
01012ce6  6910              bvs.b    $1012cf8
01012ce8  6275              bhi.b    $1012d5f
01012cea  730f              dc.w     $730f
01012cec  7274              moveq    #$74, d1
01012cee  630e              bls.b    $1012cfe
01012cf0  6f70              ble.b    $1012d62
01012cf2  7469              moveq    #$69, d2
01012cf4  6361              bls.b    str_01012d57
01012cf6  6c0d              bge.b    $1012d05
01012cf8  7363              dc.w     $7363
01012cfa  7369              dc.w     $7369
01012cfc  0c7072696e74      cmpi.w   #$7269, $74(a0, d6.l)
01012d02  6572              bcs.b    $1012d76
01012d04  0b65              bchg.b   d5, -(a5)
01012d06  6e65              bgt.b    $1012d6d
01012d08  7454              moveq    #$54, d2
01012d0a  580a              dc.w     $580a
01012d0c  656e              bcs.b    $1012d7c
01012d0e  6574              bcs.b    $1012d84
01012d10  5258              addq.w   #$1, (a0)+
01012d12  09736f756e647275  bchg.b   d4, ([$6e647275, a3])
01012d1a  6e08              bgt.b    $1012d24
01012d1c  7068              moveq    #$68, d0
01012d1e  6f6e              ble.b    str_01012d8e
01012d20  6507              bcs.b    $1012d29
01012d22  6473              bcc.b    $1012d97
01012d24  7006              moveq    #$6, d0
01012d26  7669              moveq    #$69, d3
01012d28  6465              bcc.b    $1012d8f
01012d2a  6f05              ble.b    $1012d31
01012d2c  6d6f              blt.b    $1012d9d
01012d2e  6e69              bgt.b    $1012d99
01012d30  746f              moveq    #$6f, d2
01012d32  7204              moveq    #$4, d1
01012d34  6b79              bmi.b    $1012daf
01012d36  6264              bhi.b    $1012d9c
01012d38  2f6d6f757365      move.l   $6f75(a5), $7365(a7)
01012d3e  03706f7765720273  bchg.b   d1, ([$65720273, a0])
01012d46  6f66              ble.b    $1012dae
01012d48  7469              moveq    #$69, d2
01012d4a  6e74              bgt.b    $1012dc0
01012d4c  3201              move.w   d1, d1

; ---- gap 01012d65..01012d88 (36 bytes) ----
01012d65  10dd              move.b   (a5)+, (a0)+
01012d67  04736964d108      subi.w   #$6964, (a3, a5.w)
01012d6d  444d              dc.w     $444d
01012d6f  4172              dc.w     $4172
01012d71  6576              bcs.b    $1012de9
01012d73  c908              abcd.b   -(a0), -(a4)
01012d75  4350              dc.w     $4350
01012d77  55726576c702766d  subq.w   #$2, ([$c702766d, a2])
01012d7f  7373              dc.w     $7373
01012d81  c502              abcd.b   d2, d2
01012d83  6d6d              blt.b    $1012df2
01012d85  7373              dc.w     $7373
01012d87  c102              abcd.b   d2, d0

; ---- gap 01012d93..01012e11 (127 bytes) ----
01012d93  10a0              move.b   -(a0), (a0)
01012d95  4453              neg.w    (a3)
01012d97  5072657365741f445350626c  addq.w   #$8, ([$65741f44, a2], $5350626c)
01012da3  6f63              ble.b    $1012e08
01012da5  6b1e              bmi.b    $1012dc5
01012da7  4453              neg.w    (a3)
01012da9  50756e70          addq.w   #$8, $70(a5, d6.l)
01012dad  6b1d              bmi.b    $1012dcc
01012daf  4453              neg.w    (a3)
01012db1  5062              addq.w   #$8, -(a2)
01012db3  1c44              dc.w     $1c44
01012db5  5350              subq.w   #$1, (a0)
01012db7  611b              bsr.b    $1012dd4
01012db9  7270              moveq    #$70, d1
01012dbb  691a              bvs.b    $1012dd7
01012dbd  736f              dc.w     $736f
01012dbf  6674              bne.b    $1012e35
01012dc1  696e              bvs.b    $1012e31
01012dc3  7432              moveq    #$32, d2
01012dc5  19736f6674696e74  move.b   ([$7469, a3]), $6e74(a4)
01012dcd  31d5046d          move.w   (a5), $46d.w
01012dd1  656d              bcs.b    $1012e40
01012dd3  3235364b          move.w   $4b(a5, d3.w), d1
01012dd7  2f344dd1          move.l   ([]), -(a7)
01012ddb  046d656d314d      subi.w   #$656d, $314d(a5)
01012de1  2f344d10          move.l   (a4, d4.l * 4), -(a7)
01012de5  7469              moveq    #$69, d2
01012de7  6d65              blt.b    $1012e4e
01012de9  7269              moveq    #$69, d1
01012deb  706c              moveq    #$6c, d0
01012ded  37cd              dc.w     $37cd
01012def  0352              bchg.b   d1, (a2)
01012df1  4f4d              dc.w     $4f4d
01012df3  7761              dc.w     $7761
01012df5  6974              bvs.b    $1012e6b
01012df7  0b727464          bchg.b   d5, $64(a2, d7.w)
01012dfb  6174              bsr.b    $1012e71
01012dfd  610a              bsr.b    $1012e09
01012dff  7274              moveq    #$74, d1
01012e01  636c              bls.b    $1012e6f
01012e03  6b09              bmi.b    $1012e0e
01012e05  7274              moveq    #$74, d1
01012e07  6365              bls.b    $1012e6e
01012e09  8852              or.w     (a2), d4
01012e0b  4f4d              dc.w     $4f4d
01012e0d  6f76              ble.b    $1012e85
01012e0f  6c79              bge.b    $1012e8a
01012e11  0165              dc.w     $0165

; ---- gap 01012e19..01012ed4 (188 bytes) ----
01012e19  1020              move.b   -(a0), d0
01012e1b  4e4d              trap     #$d
01012e1d  491f              chk.l    (a7)+, d4
01012e1f  7061              moveq    #$61, d0
01012e21  7269              moveq    #$69, d1
01012e23  7479              moveq    #$79, d2
01012e25  1e73              dc.w     $1e73
01012e27  7973              dc.w     $7973
01012e29  7469              moveq    #$69, d2
01012e2b  6d65              blt.b    $1012e92
01012e2d  721d              moveq    #$1d, d1
01012e2f  656e              bcs.b    $1012e9f
01012e31  6574              bcs.b    $1012ea7
01012e33  5458              addq.w   #$2, (a0)+
01012e35  444d              dc.w     $444d
01012e37  411c              chk.l    (a4)+, d0
01012e39  656e              bcs.b    $1012ea9
01012e3b  6574              bcs.b    $1012eb1
01012e3d  5258              addq.w   #$1, (a0)+
01012e3f  444d              dc.w     $444d
01012e41  411b              chk.l    (a3)+, d0
01012e43  7363              dc.w     $7363
01012e45  7369              dc.w     $7369
01012e47  444d              dc.w     $444d
01012e49  4119              chk.l    (a1)+, d0
01012e4b  7072              moveq    #$72, d0
01012e4d  696e              bvs.b    $1012ebd
01012e4f  7465              moveq    #$65, d2
01012e51  7244              moveq    #$44, d1
01012e53  4d41              dc.w     $4d41
01012e55  1873              dc.w     $1873
01012e57  6f75              ble.b    $1012ece
01012e59  6e64              bgt.b    $1012ebf
01012e5b  6f75              ble.b    $1012ed2
01012e5d  7444              moveq    #$44, d2
01012e5f  4d41              dc.w     $4d41
01012e61  17736f756e64696e444d  move.b   ([$6e64696e, a3]), $444d(a3)
01012e6b  4115              chk.l    (a5), d0
01012e6d  6473              bcc.b    $1012ee2
01012e6f  7044              moveq    #$44, d0
01012e71  4d41              dc.w     $4d41
01012e73  1273              dc.w     $1273
01012e75  6363              bls.b    $1012eda
01012e77  117270691062      move.b   $69(a2, d7.w), $1062(a0)
01012e7d  7573              dc.w     $7573
01012e7f  0f64              bchg.b   d7, -(a4)
01012e81  7370              dc.w     $7370
01012e83  0e76              dc.w     $0e76
01012e85  6964              bvs.b    $1012eeb
01012e87  656f              bcs.b    $1012ef8
01012e89  0d736373690c7072696e7465  bchg.b   d6, ([$690c7072, a3], $696e7465)
01012e95  720b              moveq    #$b, d1
01012e97  656e              bcs.b    $1012f07
01012e99  6574              bcs.b    $1012f0f
01012e9b  5458              addq.w   #$2, (a0)+
01012e9d  0a656e65          eori.w   #$6e65, -(a5)
01012ea1  7452              moveq    #$52, d2
01012ea3  5809              dc.w     $5809
01012ea5  736f              dc.w     $736f
01012ea7  756e              dc.w     $756e
01012ea9  6472              bcc.b    $1012f1d
01012eab  756e              dc.w     $756e
01012ead  0866              dc.w     $0866
01012eaf  6c6f              bge.b    $1012f20
01012eb1  7070              moveq    #$70, d0
01012eb3  7905              dc.w     $7905
01012eb5  6d6f              blt.b    $1012f26
01012eb7  6e69              bgt.b    $1012f22
01012eb9  746f              moveq    #$6f, d2
01012ebb  7204              moveq    #$4, d1
01012ebd  6b79              bmi.b    $1012f38
01012ebf  6264              bhi.b    $1012f25
01012ec1  2f6d6f757365      move.l   $6f75(a5), $7365(a7)
01012ec7  03727463          bchg.b   d1, $63(a2, d7.w)
01012ecb  02736f667469      andi.w   #$6f66, $69(a3, d7.w)
01012ed1  6e74              bgt.b    $1012f47
01012ed3  3201              move.w   d1, d1

; ---- gap 01012ede..01012eff (34 bytes) ----
01012ede  10dd              move.b   (a5)+, (a0)+
01012ee0  04736964cd04      subi.w   #$6964, (a3, a4.l * 4)
01012ee6  6d61              blt.b    $1012f49
01012ee8  6368              bls.b    $1012f52
01012eea  696e              bvs.b    $1012f5a
01012eec  65c9              bcs.b    $1012eb7
01012eee  04726576c702766d  subi.w   #$6576, ([a2, a4.w * 8], $766d)
01012ef6  7373              dc.w     $7373
01012ef8  c502              abcd.b   d2, d2
01012efa  6d6d              blt.b    $1012f69
01012efc  7373              dc.w     $7373
01012efe  c103              abcd.b   d3, d0

; ---- gap 01012f05..01012f71 (109 bytes) ----
01012f05  10a0              move.b   -(a0), (a0)
01012f07  4453              neg.w    (a3)
01012f09  5072657365741f445350626c  addq.w   #$8, ([$65741f44, a2], $5350626c)
01012f15  6f63              ble.b    $1012f7a
01012f17  6b1e              bmi.b    $1012f37
01012f19  4453              neg.w    (a3)
01012f1b  50756e70          addq.w   #$8, $70(a5, d6.l)
01012f1f  6b1d              bmi.b    $1012f3e
01012f21  4453              neg.w    (a3)
01012f23  5062              addq.w   #$8, -(a2)
01012f25  1c44              dc.w     $1c44
01012f27  5350              subq.w   #$1, (a0)
01012f29  611b              bsr.b    $1012f46
01012f2b  7270              moveq    #$70, d1
01012f2d  691a              bvs.b    $1012f49
01012f2f  736f              dc.w     $736f
01012f31  6674              bne.b    $1012fa7
01012f33  696e              bvs.b    $1012fa3
01012f35  7432              moveq    #$32, d2
01012f37  19736f6674696e74  move.b   ([$7469, a3]), $6e74(a4)
01012f3f  3118              move.w   (a0)+, -(a0)
01012f41  4453              neg.w    (a3)
01012f43  50747864          addq.w   #$8, $64(a4, d7.l)
01012f47  696e              bvs.b    $1012fb7
01012f49  740d              moveq    #$d, d2
01012f4b  766d              moveq    #$6d, d3
01012f4d  6f64              ble.b    $1012fb3
01012f4f  650b              bcs.b    $1012f5c
01012f51  7274              moveq    #$74, d1
01012f53  6461              bcc.b    $1012fb6
01012f55  7461              moveq    #$61, d2
01012f57  0a7274636c6b      eori.w   #$7463, $6b(a2, d6.l)
01012f5d  09727463          bchg.b   d4, $63(a2, d7.w)
01012f61  6508              bcs.b    $1012f6b
01012f63  6c6f              bge.b    $1012fd4
01012f65  6361              bls.b    $1012fc8
01012f67  6c06              bge.b    $1012f6f
01012f69  4453              neg.w    (a3)
01012f6b  506d656d          addq.w   #$8, $656d(a5)
01012f6f  656e              bcs.b    $1012fdf
01012f71  0165              dc.w     $0165

; ---- gap 010130e8..010130fa (19 bytes) ----
010130e8  5544              subq.w   #$2, d4
010130ea  00555000          ori.w    #$5000, (a5)
010130ee  5344              subq.w   #$1, d4
010130f0  00535000          ori.w    #$5000, (a3)
010130f4  6370              bls.b    $1013166
010130f6  7500              dc.w     $7500
010130f8  6e6f              bgt.b    $1013169
010130fa  0031              dc.w     $0031

; ---- gap 01013562..0101356a (9 bytes) ----
01013562  6664              bne.b    $10135c8
01013564  00464400          ori.w    #$4400, d6
01013568  2d68              dc.w     $2d68
0101356a  004e              dc.w     $004e

; ---- gap 01013608..0101360d (6 bytes) ----
01013608  4e65              move     a5, usp
0101360a  5854              addq.w   #$4, (a4)
0101360c  3e00              move.w   d0, d7

; ---- gap 010137b4..010137cb (24 bytes) ----
010137b4  257325733a2000253038783f  move.l   ([$3a200025, a3], $3038783f), -$5556(a2)
010137c0  2000              move.l   d0, d0
010137c2  25623f20          move.l   -(a2), $3f20(a2)
010137c6  0025733f          ori.b    #$3f, -(a5)
010137ca  2000              move.l   d0, d0

; ---- gap 010137e5..010137ee (10 bytes) ----
010137e5  7965              dc.w     $7965
010137e7  7300              dc.w     $7300
010137e9  2025              move.l   -(a5), d0
010137eb  733f              dc.w     $733f
010137ed  2000              move.l   d0, d0

; ---- gap 01013839..01013852 (26 bytes) ----
01013839  25303878          move.l   $78(a0, d3.l), -(a2)
0101383d  00253034          ori.b    #$34, -(a5)
01013841  7800              moveq    #$0, d4
01013843  25303278          move.l   $78(a0, d3.w), -(a2)
01013847  0025783a          ori.b    #$3a, -(a5)
0101384b  2000              move.l   d0, d0
0101384d  3f20              move.w   -(a0), -(a7)
0101384f  00257300          ori.b    #$0, -(a5)

; ---- gap 01013d82..01013d8c (11 bytes) ----
01013d82  2825              move.l   -(a5), d4
01013d84  642c              bcc.b    $1013db2
01013d86  25642c25          move.l   -(a4), $2c25(a2)
01013d8a  6429              bcc.b    $1013db5
01013d8c  0062              dc.w     $0062

; ---- gap 01013ded..01013df6 (10 bytes) ----
01013ded  0925              btst.l   d4, -(a5)
01013def  733a              dc.w     $733a
01013df1  2025              move.l   -(a5), d0
01013df3  732e              dc.w     $732e
01013df5  0a00              dc.w     $0a00

; ---- gap 01013e33..01013e48 (22 bytes) ----
01013e33  25732825642c      move.l   $25(a3, d2.l), $642c(a2)
01013e39  25642c25          move.l   -(a4), $2c25(a2)
01013e3d  6429              bcc.b    $1013e68
01013e3f  257300257328      move.l   $25(a3, d0.w), $7328(a2)
01013e45  2925              move.l   -(a5), -(a4)
01013e47  7300              dc.w     $7300

; ---- gap 01013eb3..01013ebc (10 bytes) ----
01013eb3  0820              dc.w     $0820
01013eb5  0800              dc.w     $0800
01013eb7  30740030          movea.w  $30(a4, d0.w), a0
01013ebb  7800              moveq    #$0, d4

; ---- gap 01013f02..01013f0a (9 bytes) ----
01013f02  6931              bvs.b    $1013f35
01013f04  006932006933      ori.w    #$3200, $6933(a1)
01013f0a  004e              dc.w     $004e

; ---- gap 01014385..0101438e (10 bytes) ----
01014385  2025              move.l   -(a5), d0
01014387  643a              bcc.b    $10143c3
01014389  303a2564          move.w   $10168ef(pc), d0
0101438d  0a00              dc.w     $0a00

; ---- gap 0101448d..01014492 (6 bytes) ----
0101448d  5265              addq.w   #$1, -(a5)
0101448f  6164              bsr.b    $10144f5
01014491  0057              dc.w     $0057

; ---- gap 010145a8..01014aee (1351 bytes) ----
010145a8  00000000          ori.b    #$0, d0
010145ac  00000000          ori.b    #$0, d0
010145b0  00000000          ori.b    #$0, d0
010145b4  00000000          ori.b    #$0, d0
010145b8  0100              btst.l   d0, d0
010145ba  009200000000      ori.l    #$0, (a2)
010145c0  00000000          ori.b    #$0, d0
010145c4  0100              btst.l   d0, d0
010145c6  00b001012c000000  ori.l    #str_regnames_0_7, (a0, d0.w)
010145ce  00000000          ori.b    #$0, d0
010145d2  00000000          ori.b    #$0, d0
010145d6  00000000          ori.b    #$0, d0
010145da  00000101          ori.b    #$1, d0
010145de  2c02              move.l   d2, d6
010145e0  00000004          ori.b    #$4, d0
010145e4  00000000          ori.b    #$0, d0
010145e8  00000000          ori.b    #$0, d0
010145ec  00000000          ori.b    #$0, d0
010145f0  0101              btst.l   d0, d1
010145f2  2c04              move.l   d4, d6
010145f4  00000008          ori.b    #$8, d0
010145f8  00000000          ori.b    #$0, d0
010145fc  00000000          ori.b    #$0, d0
01014600  00000000          ori.b    #$0, d0
01014604  0101              btst.l   d0, d1
01014606  2c06              move.l   d6, d6
01014608  0000000c          ori.b    #$c, d0
0101460c  00000000          ori.b    #$0, d0
01014610  00000000          ori.b    #$0, d0
01014614  00000000          ori.b    #$0, d0
01014618  0101              btst.l   d0, d1
0101461a  2c08              move.l   a0, d6
0101461c  00000010          ori.b    #$10, d0
01014620  00000000          ori.b    #$0, d0
01014624  00000000          ori.b    #$0, d0
01014628  00000000          ori.b    #$0, d0
0101462c  0101              btst.l   d0, d1
0101462e  2c0a              move.l   a2, d6
01014630  00000014          ori.b    #$14, d0
01014634  00000000          ori.b    #$0, d0
01014638  00000000          ori.b    #$0, d0
0101463c  00000000          ori.b    #$0, d0
01014640  0101              btst.l   d0, d1
01014642  2c0c              move.l   a4, d6
01014644  00000018          ori.b    #$18, d0
01014648  00000000          ori.b    #$0, d0
0101464c  00000000          ori.b    #$0, d0
01014650  00000000          ori.b    #$0, d0
01014654  0101              btst.l   d0, d1
01014656  2c0e              move.l   a6, d6
01014658  0000001c          ori.b    #$1c, d0
0101465c  00000000          ori.b    #$0, d0
01014660  00000000          ori.b    #$0, d0
01014664  00000000          ori.b    #$0, d0
01014668  00000000          ori.b    #$0, d0
0101466c  00000000          ori.b    #$0, d0
01014670  00000000          ori.b    #$0, d0
01014674  00000000          ori.b    #$0, d0
01014678  00000000          ori.b    #$0, d0
0101467c  0101              btst.l   d0, d1
0101467e  2c00              move.l   d0, d6
01014680  00000020          ori.b    #$20, d0
01014684  00000000          ori.b    #$0, d0
01014688  00000000          ori.b    #$0, d0
0101468c  00000000          ori.b    #$0, d0
01014690  0101              btst.l   d0, d1
01014692  2c02              move.l   d2, d6
01014694  00000024          ori.b    #$24, d0
01014698  00000000          ori.b    #$0, d0
0101469c  00000000          ori.b    #$0, d0
010146a0  00000000          ori.b    #$0, d0
010146a4  0101              btst.l   d0, d1
010146a6  2c04              move.l   d4, d6
010146a8  00000028          ori.b    #$28, d0
010146ac  00000000          ori.b    #$0, d0
010146b0  00000000          ori.b    #$0, d0
010146b4  00000000          ori.b    #$0, d0
010146b8  0101              btst.l   d0, d1
010146ba  2c06              move.l   d6, d6
010146bc  0000002c          ori.b    #$2c, d0
010146c0  00000000          ori.b    #$0, d0
010146c4  00000000          ori.b    #$0, d0
010146c8  00000000          ori.b    #$0, d0
010146cc  0101              btst.l   d0, d1
010146ce  2c08              move.l   a0, d6
010146d0  00000030          ori.b    #$30, d0
010146d4  00000000          ori.b    #$0, d0
010146d8  00000000          ori.b    #$0, d0
010146dc  00000000          ori.b    #$0, d0
010146e0  0101              btst.l   d0, d1
010146e2  2c0a              move.l   a2, d6
010146e4  00000034          ori.b    #$34, d0
010146e8  00000000          ori.b    #$0, d0
010146ec  00000000          ori.b    #$0, d0
010146f0  00000000          ori.b    #$0, d0
010146f4  0101              btst.l   d0, d1
010146f6  2c0c              move.l   a4, d6
010146f8  00000038          ori.b    #$38, d0
010146fc  00000000          ori.b    #$0, d0
01014700  00000000          ori.b    #$0, d0
01014704  00000000          ori.b    #$0, d0
01014708  0101              btst.l   d0, d1
0101470a  2c0e              move.l   a6, d6
0101470c  0000003c          ori.b    #$3c, d0
01014710  00000000          ori.b    #$0, d0
01014714  00000000          ori.b    #$0, d0
01014718  00000000          ori.b    #$0, d0
0101471c  00000000          ori.b    #$0, d0
01014720  00000000          ori.b    #$0, d0
01014724  00000000          ori.b    #$0, d0
01014728  00000000          ori.b    #$0, d0
0101472c  00000000          ori.b    #$0, d0
01014730  0101              btst.l   d0, d1
01014732  2c10              move.l   (a0), d6
01014734  00000086          ori.b    #$86, d0
01014738  00000000          ori.b    #$0, d0
0101473c  00000000          ori.b    #$0, d0
01014740  00000000          ori.b    #$0, d0
01014744  0101              btst.l   d0, d1
01014746  2c13              move.l   (a3), d6
01014748  00000082          ori.b    #$82, d0
0101474c  0100              btst.l   d0, d0
0101474e  274e0101          move.l   a6, $101(a3)
01014752  2c16              move.l   (a6), d6
01014754  00000000          ori.b    #$0, d0
01014758  0101              btst.l   d0, d1
0101475a  2c360000          move.l   (a6, d0.w), d6
0101475e  00400000          ori.w    #$0, d0
01014762  00000000          ori.b    #$0, d0
01014766  00000000          ori.b    #$0, d0
0101476a  00000101          ori.b    #$1, d0
0101476e  2c3a0000          move.l   $1014770(pc), d6
01014772  00440000          ori.w    #$0, d4
01014776  00000000          ori.b    #$0, d0
0101477a  00000000          ori.b    #$0, d0
0101477e  00000101          ori.b    #$1, d0
01014782  2c3e              dc.w     $2c3e
01014784  00000048          ori.b    #$48, d0
01014788  00000000          ori.b    #$0, d0
0101478c  00000000          ori.b    #$0, d0
01014790  00000000          ori.b    #$0, d0
01014794  0101              btst.l   d0, d1
01014796  2c42              movea.l  d2, a6
01014798  00000054          ori.b    #$54, d0
0101479c  00000000          ori.b    #$0, d0
010147a0  00000000          ori.b    #$0, d0
010147a4  00000000          ori.b    #$0, d0
010147a8  0101              btst.l   d0, d1
010147aa  2c46              movea.l  d6, a6
010147ac  0000004c          ori.b    #$4c, d0
010147b0  00000000          ori.b    #$0, d0
010147b4  00000000          ori.b    #$0, d0
010147b8  00000000          ori.b    #$0, d0
010147bc  0101              btst.l   d0, d1
010147be  2c4a              movea.l  a2, a6
010147c0  00000050          ori.b    #$50, d0
010147c4  00000000          ori.b    #$0, d0
010147c8  00000000          ori.b    #$0, d0
010147cc  00000000          ori.b    #$0, d0
010147d0  0101              btst.l   d0, d1
010147d2  2c4e              movea.l  a6, a6
010147d4  0000005c          ori.b    #$5c, d0
010147d8  0100              btst.l   d0, d0
010147da  274e0101          move.l   a6, $101(a3)
010147de  2c53              movea.l  (a3), a6
010147e0  00000000          ori.b    #$0, d0
010147e4  00000000          ori.b    #$0, d0
010147e8  00000000          ori.b    #$0, d0
010147ec  00000000          ori.b    #$0, d0
010147f0  00000000          ori.b    #$0, d0
010147f4  00000000          ori.b    #$0, d0
010147f8  0101              btst.l   d0, d1
010147fa  2c5b              movea.l  (a3)+, a6
010147fc  02007000          andi.b   #$0, d0
01014800  0100              btst.l   d0, d0
01014802  274e0101          move.l   a6, $101(a3)
01014806  2c64              movea.l  -(a4), a6
01014808  00000000          ori.b    #$0, d0
0101480c  0101              btst.l   d0, d1
0101480e  2d570200          move.l   (a7), $200(a6)
01014812  7800              moveq    #$0, d4
01014814  0100              btst.l   d0, d0
01014816  274e0101          move.l   a6, $101(a3)
0101481a  2c64              movea.l  -(a4), a6
0101481c  00000000          ori.b    #$0, d0
01014820  0101              btst.l   d0, d1
01014822  2d600200          move.l   -(a0), $200(a6)
01014826  c000              and.b    d0, d0
01014828  0100              btst.l   d0, d0
0101482a  274e0101          move.l   a6, $101(a3)
0101482e  2d650000          move.l   -(a5), $0(a6)
01014832  00000101          ori.b    #$1, d0
01014836  2d8e0200          move.l   a6, (a6, d0.w * 2)
0101483a  d000              add.b    d0, d0
0101483c  0100              btst.l   d0, d0
0101483e  274e0101          move.l   a6, $101(a3)
01014842  2d930000          move.l   (a3), (a6, d0.w)
01014846  00000000          ori.b    #$0, d0
0101484a  00000000          ori.b    #$0, d0
0101484e  00000000          ori.b    #$0, d0
01014852  00000000          ori.b    #$0, d0
01014856  00000000          ori.b    #$0, d0
0101485a  00000101          ori.b    #$1, d0
0101485e  2c5b              movea.l  (a3)+, a6
01014860  02007000          andi.b   #$0, d0
01014864  0100              btst.l   d0, d0
01014866  274e0101          move.l   a6, $101(a3)
0101486a  2e19              move.l   (a1)+, d7
0101486c  00000000          ori.b    #$0, d0
01014870  0101              btst.l   d0, d1
01014872  2d570200          move.l   (a7), $200(a6)
01014876  7800              moveq    #$0, d4
01014878  0100              btst.l   d0, d0
0101487a  274e0101          move.l   a6, $101(a3)
0101487e  2e19              move.l   (a1)+, d7
01014880  00000000          ori.b    #$0, d0
01014884  0101              btst.l   d0, d1
01014886  2d600200          move.l   -(a0), $200(a6)
0101488a  c000              and.b    d0, d0
0101488c  0100              btst.l   d0, d0
0101488e  274e0101          move.l   a6, $101(a3)
01014892  2ede              move.l   (a6)+, (a7)+
01014894  00000000          ori.b    #$0, d0
01014898  0101              btst.l   d0, d1
0101489a  2d8e0200          move.l   a6, (a6, d0.w * 2)
0101489e  d000              add.b    d0, d0
010148a0  0100              btst.l   d0, d0
010148a2  274e0101          move.l   a6, $101(a3)
010148a6  2f05              move.l   d5, -(a7)
010148a8  00000000          ori.b    #$0, d0
010148ac  00000000          ori.b    #$0, d0
010148b0  00000000          ori.b    #$0, d0
010148b4  00000000          ori.b    #$0, d0
010148b8  00000000          ori.b    #$0, d0
010148bc  00000000          ori.b    #$0, d0
010148c0  0101              btst.l   d0, d1
010148c2  2f79000000120100  move.l   $12.l, $100(a7)
010148ca  27e2              dc.w     $27e2
010148cc  0000000c          ori.b    #$c, d0
010148d0  00000000          ori.b    #$0, d0
010148d4  0101              btst.l   d0, d1
010148d6  2f860000          move.l   d6, (a7, d0.w)
010148da  00100100          ori.b    #$0, (a0)
010148de  287c00000000      movea.l  #$0, a4
010148e4  00000000          ori.b    #$0, d0
010148e8  0101              btst.l   d0, d1
010148ea  2f910000          move.l   (a1), (a7, d0.w)
010148ee  00010100          ori.b    #$0, d1
010148f2  287c00000000      movea.l  #$0, a4
010148f8  00000000          ori.b    #$0, d0
010148fc  0101              btst.l   d0, d1
010148fe  2fae00000040      move.l   $0(a6), $40(a7, d0.w)
01014904  0100              btst.l   d0, d0
01014906  287c00000000      movea.l  #$0, a4
0101490c  00000000          ori.b    #$0, d0
01014910  0101              btst.l   d0, d1
01014912  2fbf              dc.w     $2fbf
01014914  00000002          ori.b    #$2, d0
01014918  0100              btst.l   d0, d0
0101491a  287c00000000      movea.l  #$0, a4
01014920  00000000          ori.b    #$0, d0
01014924  0101              btst.l   d0, d1
01014926  2fcb              dc.w     $2fcb
01014928  00000004          ori.b    #$4, d0
0101492c  0100              btst.l   d0, d0
0101492e  287c00000000      movea.l  #$0, a4
01014934  00000000          ori.b    #$0, d0
01014938  0101              btst.l   d0, d1
0101493a  2fe0              dc.w     $2fe0
0101493c  00000008          ori.b    #$8, d0
01014940  0100              btst.l   d0, d0
01014942  287c00000000      movea.l  #$0, a4
01014948  00000000          ori.b    #$0, d0
0101494c  0101              btst.l   d0, d1
0101494e  2ff3              dc.w     $2ff3
01014950  08000000          btst.b   #$0, d0
01014954  0100              btst.l   d0, d0
01014956  29aa00000000      move.l   $0(a2), (a4, d0.w)
0101495c  00000000          ori.b    #$0, d0
01014960  0101              btst.l   d0, d1
01014962  3016              move.w   (a6), d0
01014964  00000001          ori.b    #$1, d0
01014968  0100              btst.l   d0, d0
0101496a  29aa00000000      move.l   $0(a2), (a4, d0.w)
01014970  00000000          ori.b    #$0, d0
01014974  0101              btst.l   d0, d1
01014976  3047              movea.w  d7, a0
01014978  00000002          ori.b    #$2, d0
0101497c  0100              btst.l   d0, d0
0101497e  29aa00000000      move.l   $0(a2), (a4, d0.w)
01014984  00000000          ori.b    #$0, d0
01014988  0101              btst.l   d0, d1
0101498a  307d              dc.w     $307d
0101498c  04000000          subi.b   #$0, d0
01014990  0100              btst.l   d0, d0
01014992  29aa00000000      move.l   $0(a2), (a4, d0.w)
01014998  00000000          ori.b    #$0, d0
0101499c  0101              btst.l   d0, d1
0101499e  30b50000          move.w   (a5, d0.w), (a0)
010149a2  00000100          ori.b    #$0, d0
010149a6  291a              move.l   (a2)+, -(a4)
010149a8  00000000          ori.b    #$0, d0
010149ac  00000000          ori.b    #$0, d0
010149b0  00000000          ori.b    #$0, d0
010149b4  00000000          ori.b    #$0, d0
010149b8  00000000          ori.b    #$0, d0
010149bc  00000000          ori.b    #$0, d0
010149c0  00000000          ori.b    #$0, d0
010149c4  0101              btst.l   d0, d1
010149c6  2c00              move.l   d0, d6
010149c8  0101              btst.l   d0, d1
010149ca  30e80101          move.w   $101(a0), (a0)+
010149ce  30eb0101          move.w   $101(a3), (a0)+
010149d2  2c06              move.l   d6, d6
010149d4  0101              btst.l   d0, d1
010149d6  2c08              move.l   a0, d6
010149d8  0101              btst.l   d0, d1
010149da  30ee0101          move.w   $101(a6), (a0)+
010149de  30f10101          move.w   ([a1, d0.w]), (a0)+
010149e2  30f40101          move.w   ([a4, d0.w]), (a0)+
010149e6  30f80101          move.w   $101.w, (a0)+
010149ea  30fb0101          move.w   ([$10149ecpc, d0.w]), (a0)+
010149ee  310f              move.w   a7, -(a0)
010149f0  0101              btst.l   d0, d1
010149f2  3122              move.w   -(a2), -(a0)
010149f4  0101              btst.l   d0, d1
010149f6  31350101          move.w   ([a5, d0.w]), -(a0)
010149fa  313d              dc.w     $313d
010149fc  0101              btst.l   d0, d1
010149fe  314f0101          move.w   a7, $101(a0)
01014a02  31600101          move.w   -(a0), $101(a0)
01014a06  31350101          move.w   ([a5, d0.w]), -(a0)
01014a0a  317b01013196      move.w   ([$1014a0cpc, d0.w]), $3196(a0)
01014a10  0101              btst.l   d0, d1
01014a12  31b001013135010131ca  move.w   ([a0, d0.w]), ([str_010131ca, a0], d3.w)
01014a1c  0101              btst.l   d0, d1
01014a1e  31e30101          move.w   -(a3), $101.w
01014a22  31fb010130f8      move.w   ([$1014a24pc, d0.w]), $30f8.w
01014a28  0101              btst.l   d0, d1
01014a2a  321d              move.w   (a5)+, d1
01014a2c  0101              btst.l   d0, d1
01014a2e  322f0101          move.w   $101(a7), d1
01014a32  3240              movea.w  d0, a1
01014a34  0101              btst.l   d0, d1
01014a36  31350101          move.w   ([a5, d0.w]), -(a0)
01014a3a  321d              move.w   (a5)+, d1
01014a3c  0101              btst.l   d0, d1
01014a3e  322f0101          move.w   $101(a7), d1
01014a42  3240              movea.w  d0, a1
01014a44  0101              btst.l   d0, d1
01014a46  31350101          move.w   ([a5, d0.w]), -(a0)
01014a4a  3251              movea.w  (a1), a1
01014a4c  0101              btst.l   d0, d1
01014a4e  326a0101          movea.w  $101(a2), a1
01014a52  3282              move.w   d2, (a1)
01014a54  0101              btst.l   d0, d1
01014a56  31350101          move.w   ([a5, d0.w]), -(a0)
01014a5a  3251              movea.w  (a1), a1
01014a5c  0101              btst.l   d0, d1
01014a5e  326a0101          movea.w  $101(a2), a1
01014a62  3282              move.w   d2, (a1)
01014a64  00000000          ori.b    #$0, d0
01014a68  0100              btst.l   d0, d0
01014a6a  00000040          ori.b    #$40, d0
01014a6e  00000010          ori.b    #$10, d0
01014a72  00000000          ori.b    #$0, d0
01014a76  00000100          ori.b    #$0, d0
01014a7a  00000040          ori.b    #$40, d0
01014a7e  00000010          ori.b    #$10, d0
01014a82  00000000          ori.b    #$0, d0
01014a86  00000100          ori.b    #$0, d0
01014a8a  00000040          ori.b    #$40, d0
01014a8e  00000010          ori.b    #$10, d0
01014a92  00000000          ori.b    #$0, d0
01014a96  00000100          ori.b    #$0, d0
01014a9a  00000040          ori.b    #$40, d0
01014a9e  00000010          ori.b    #$10, d0
01014aa2  00000000          ori.b    #$0, d0
01014aa6  00000200          ori.b    #$0, d0
01014aaa  00000080          ori.b    #$80, d0
01014aae  00000020          ori.b    #$20, d0
01014ab2  00000000          ori.b    #$0, d0
01014ab6  00000200          ori.b    #$0, d0
01014aba  00000080          ori.b    #$80, d0
01014abe  00000020          ori.b    #$20, d0
01014ac2  00000000          ori.b    #$0, d0
01014ac6  00000200          ori.b    #$0, d0
01014aca  00000080          ori.b    #$80, d0
01014ace  00000020          ori.b    #$20, d0
01014ad2  00000000          ori.b    #$0, d0
01014ad6  00000200          ori.b    #$0, d0
01014ada  00000080          ori.b    #$80, d0
01014ade  00000020          ori.b    #$20, d0
01014ae2  00001014          ori.b    #$14, d0
01014ae6  1921              move.b   -(a1), -(a4)
01014ae8  28324250          move.l   $50(a2, d4.w), d4
01014aec  1014              move.b   (a4), d0
01014aee  1921              dc.w     $1921

; ---- gap 01014af9..01014cd7 (479 bytes) ----
01014af9  0048              dc.w     $0048
01014afb  00000000          ori.b    #$0, d0
01014aff  4800              nbcd.b   d0
01014b01  00000048          ori.b    #$48, d0
01014b05  00000000          ori.b    #$0, d0
01014b09  4800              nbcd.b   d0
01014b0b  00192808          ori.b    #$8, (a1)+
01014b0f  1000              move.b   d0, d0
01014b11  3138680d          move.w   $680d.w, -(a0)
01014b15  00000048          ori.b    #$48, d0
01014b19  00000000          ori.b    #$0, d0
01014b1d  4800              nbcd.b   d0
01014b1f  001a2800          ori.b    #$0, (a2)+
01014b23  1000              move.b   d0, d0
01014b25  3e78000c          movea.w  $c.w, a7
01014b29  00000048          ori.b    #$48, d0
01014b2d  00000000          ori.b    #$0, d0
01014b31  4800              nbcd.b   d0
01014b33  00000048          ori.b    #$48, d0
01014b37  00000000          ori.b    #$0, d0
01014b3b  4800              nbcd.b   d0
01014b3d  00000048          ori.b    #$48, d0
01014b41  00000000          ori.b    #$0, d0
01014b45  4800              nbcd.b   d0
01014b47  00000048          ori.b    #$48, d0
01014b4b  00000000          ori.b    #$0, d0
01014b4f  4800              nbcd.b   d0
01014b51  00000048          ori.b    #$48, d0
01014b55  00000000          ori.b    #$0, d0
01014b59  4800              nbcd.b   d0
01014b5b  00192808          ori.b    #$8, (a1)+
01014b5f  1000              move.b   d0, d0
01014b61  3138680d          move.w   $680d.w, -(a0)
01014b65  00000048          ori.b    #$48, d0
01014b69  00000000          ori.b    #$0, d0
01014b6d  4800              nbcd.b   d0
01014b6f  001a2800          ori.b    #$0, (a2)+
01014b73  1000              move.b   d0, d0
01014b75  3e78000c          movea.w  $c.w, a7
01014b79  00000048          ori.b    #$48, d0
01014b7d  00000000          ori.b    #$0, d0
01014b81  4800              nbcd.b   d0
01014b83  00000048          ori.b    #$48, d0
01014b87  00000000          ori.b    #$0, d0
01014b8b  4800              nbcd.b   d0
01014b8d  00000048          ori.b    #$48, d0
01014b91  00000000          ori.b    #$0, d0
01014b95  4800              nbcd.b   d0
01014b97  00022808          ori.b    #$8, d2
01014b9b  1000              move.b   d0, d0
01014b9d  022808100000      andi.b   #$10, $0(a0)
01014ba3  0048              dc.w     $0048
01014ba5  00000000          ori.b    #$0, d0
01014ba9  4800              nbcd.b   d0
01014bab  00193868          ori.b    #$68, (a1)+
01014baf  1000              move.b   d0, d0
01014bb1  19386810          move.b   $6810.w, -(a4)
01014bb5  00000048          ori.b    #$48, d0
01014bb9  00000000          ori.b    #$0, d0
01014bbd  4800              nbcd.b   d0
01014bbf  001a7860          ori.b    #$60, (a2)+
01014bc3  1000              move.b   d0, d0
01014bc5  1a78              dc.w     $1a78
01014bc7  6010              bra.b    $1014bd9
01014bc9  00000048          ori.b    #$48, d0
01014bcd  00000000          ori.b    #$0, d0
01014bd1  4800              nbcd.b   d0
01014bd3  00022808          ori.b    #$8, d2
01014bd7  1000              move.b   d0, d0
01014bd9  022808100000      andi.b   #$10, $0(a0)
01014bdf  0048              dc.w     $0048
01014be1  00000000          ori.b    #$0, d0
01014be5  4800              nbcd.b   d0
01014be7  00022808          ori.b    #$8, d2
01014beb  1000              move.b   d0, d0
01014bed  022808100000      andi.b   #$10, $0(a0)
01014bf3  0048              dc.w     $0048
01014bf5  00000000          ori.b    #$0, d0
01014bf9  4800              nbcd.b   d0
01014bfb  00062468          ori.b    #$68, d6
01014bff  1000              move.b   d0, d0
01014c01  06246810          addi.b   #$10, -(a4)
01014c05  00000048          ori.b    #$48, d0
01014c09  00000000          ori.b    #$0, d0
01014c0d  4800              nbcd.b   d0
01014c0f  00076460          ori.b    #$60, d7
01014c13  1000              move.b   d0, d0
01014c15  0764              bchg.b   d3, -(a4)
01014c17  6010              bra.b    $1014c29
01014c19  00000048          ori.b    #$48, d0
01014c1d  00000000          ori.b    #$0, d0
01014c21  4800              nbcd.b   d0
01014c23  00022808          ori.b    #$8, d2
01014c27  1000              move.b   d0, d0
01014c29  022808100000      andi.b   #$10, $0(a0)
01014c2f  0048              dc.w     $0048
01014c31  00000000          ori.b    #$0, d0
01014c35  4800              nbcd.b   d0
01014c37  00022808          ori.b    #$8, d2
01014c3b  1000              move.b   d0, d0
01014c3d  022808100000      andi.b   #$10, $0(a0)
01014c43  0048              dc.w     $0048
01014c45  00000000          ori.b    #$0, d0
01014c49  4800              nbcd.b   d0
01014c4b  00193868          ori.b    #$68, (a1)+
01014c4f  1000              move.b   d0, d0
01014c51  19386810          move.b   $6810.w, -(a4)
01014c55  00000048          ori.b    #$48, d0
01014c59  00000000          ori.b    #$0, d0
01014c5d  4800              nbcd.b   d0
01014c5f  001a7860          ori.b    #$60, (a2)+
01014c63  1000              move.b   d0, d0
01014c65  1a78              dc.w     $1a78
01014c67  6010              bra.b    $1014c79
01014c69  00000048          ori.b    #$48, d0
01014c6d  00000000          ori.b    #$0, d0
01014c71  4800              nbcd.b   d0
01014c73  00022808          ori.b    #$8, d2
01014c77  1000              move.b   d0, d0
01014c79  022808100000      andi.b   #$10, $0(a0)
01014c7f  0048              dc.w     $0048
01014c81  00000000          ori.b    #$0, d0
01014c85  4800              nbcd.b   d0
01014c87  00022808          ori.b    #$8, d2
01014c8b  1000              move.b   d0, d0
01014c8d  022808100000      andi.b   #$10, $0(a0)
01014c93  0048              dc.w     $0048
01014c95  00000000          ori.b    #$0, d0
01014c99  4800              nbcd.b   d0
01014c9b  00062468          ori.b    #$68, d6
01014c9f  1000              move.b   d0, d0
01014ca1  06246810          addi.b   #$10, -(a4)
01014ca5  00000048          ori.b    #$48, d0
01014ca9  00000000          ori.b    #$0, d0
01014cad  4800              nbcd.b   d0
01014caf  00076460          ori.b    #$60, d7
01014cb3  1000              move.b   d0, d0
01014cb5  0764              bchg.b   d3, -(a4)
01014cb7  6010              bra.b    $1014cc9
01014cb9  00000048          ori.b    #$48, d0
01014cbd  00000000          ori.b    #$0, d0
01014cc1  4800              nbcd.b   d0
01014cc3  00022808          ori.b    #$8, d2
01014cc7  1000              move.b   d0, d0
01014cc9  022808100000      andi.b   #$10, $0(a0)
01014ccf  0048              dc.w     $0048
01014cd1  00000000          ori.b    #$0, d0
01014cd5  4800              nbcd.b   d0
01014cd7  004e              dc.w     $004e

; ---- gap 01015030..01015656 (1575 bytes) ----
01015030  4448              dc.w     $4448
01015032  4c00              dc.w     $4c00
01015034  4347              dc.w     $4347
01015036  4b00              chk.l    d0, d5
01015038  4246              clr.w    d6
0101503a  4a00              tst.b    d0
0101503c  4145              dc.w     $4145
0101503e  4900              chk.l    d0, d4
01015040  5300              subq.b   #$1, d0
01015042  00000000          ori.b    #$0, d0
01015046  00580000          ori.w    #$0, (a0)+
0101504a  00582000          ori.w    #$2000, (a0)+
0101504e  1515              move.b   (a5), -(a2)
01015050  011a              btst.l   d0, (a2)+
01015052  0155              bchg.b   d0, (a5)
01015054  0155              bchg.b   d0, (a5)
01015056  0a550f55          eori.w   #$f55, (a5)
0101505a  145f              dc.w     $145f
0101505c  016a016f          bchg.b   d0, $16f(a2)
01015060  0195              bclr.b   d0, (a5)
01015062  01aa01aa          bclr.b   d0, $1aa(a2)
01015066  04aa08aa09aa0aaa  subi.l   #$8aa09aa, $aaa(a2)         ; $08aa09aa = RAM bank 2
0101506e  14ab01af          move.b   $1af(a3), (a2)
01015072  01b501ba01bf01ea01ef  bclr.b   d0, ([$1bf01ea, d0.w], $1ef) ; $01bf01ea = ROM
0101507c  01f501fa01fe01ff01ff  bset.b   d0, ([$1fe01ff], $1ff)  ; $01fe01ff = ROM
01015086  02ff              dc.w     $02ff
01015088  08ff              dc.w     $08ff
0101508a  0aff              dc.w     $0aff
0101508c  1500              move.b   d0, -(a2)
0101508e  1801              move.b   d1, d4
01015090  06180210          addi.b   #$10, (a0)+
01015094  1802              move.b   d2, d4
01015096  1018              move.b   (a0)+, d0
01015098  02101802          andi.b   #$2, (a0)
0101509c  1018              move.b   (a0)+, d0
0101509e  020c              dc.w     $020c
010150a0  151e              move.b   (a6)+, -(a2)
010150a2  080c              dc.w     $080c
010150a4  1802              move.b   d2, d4
010150a6  0c140f08          cmpi.b   #$8, (a4)
010150aa  0c18020c          cmpi.b   #$c, (a0)+
010150ae  1304              move.b   d4, -(a1)
010150b0  080c              dc.w     $080c
010150b2  1802              move.b   d2, d4
010150b4  0c140f08          cmpi.b   #$8, (a4)
010150b8  0c18020c          cmpi.b   #$c, (a0)+
010150bc  151e              move.b   (a6)+, -(a2)
010150be  080c              dc.w     $080c
010150c0  1802              move.b   d2, d4
010150c2  0c140f08          cmpi.b   #$8, (a4)
010150c6  0c18020c          cmpi.b   #$c, (a0)+
010150ca  1304              move.b   d4, -(a1)
010150cc  080c              dc.w     $080c
010150ce  1802              move.b   d2, d4
010150d0  0c140f08          cmpi.b   #$8, (a4)
010150d4  0c18020c          cmpi.b   #$c, (a0)+
010150d8  151e              move.b   (a6)+, -(a2)
010150da  080c              dc.w     $080c
010150dc  1802              move.b   d2, d4
010150de  0c140f08          cmpi.b   #$8, (a4)
010150e2  0c18020c          cmpi.b   #$c, (a0)+
010150e6  1304              move.b   d4, -(a1)
010150e8  080c              dc.w     $080c
010150ea  1802              move.b   d2, d4
010150ec  0c140f08          cmpi.b   #$8, (a4)
010150f0  0c18020c          cmpi.b   #$c, (a0)+
010150f4  151e              move.b   (a6)+, -(a2)
010150f6  080c              dc.w     $080c
010150f8  1802              move.b   d2, d4
010150fa  0c140f08          cmpi.b   #$8, (a4)
010150fe  0c18020c          cmpi.b   #$c, (a0)+
01015102  1304              move.b   d4, -(a1)
01015104  080c              dc.w     $080c
01015106  1802              move.b   d2, d4
01015108  0c140f08          cmpi.b   #$8, (a4)
0101510c  0c18020c          cmpi.b   #$c, (a0)+
01015110  151e              move.b   (a6)+, -(a2)
01015112  080c              dc.w     $080c
01015114  1802              move.b   d2, d4
01015116  0c140f08          cmpi.b   #$8, (a4)
0101511a  0c18020c          cmpi.b   #$c, (a0)+
0101511e  1304              move.b   d4, -(a1)
01015120  080c              dc.w     $080c
01015122  1802              move.b   d2, d4
01015124  0c140f08          cmpi.b   #$8, (a4)
01015128  0c18020c          cmpi.b   #$c, (a0)+
0101512c  151e              move.b   (a6)+, -(a2)
0101512e  080c              dc.w     $080c
01015130  1802              move.b   d2, d4
01015132  0c140f08          cmpi.b   #$8, (a4)
01015136  0c18020c          cmpi.b   #$c, (a0)+
0101513a  1304              move.b   d4, -(a1)
0101513c  080c              dc.w     $080c
0101513e  1802              move.b   d2, d4
01015140  0c140f08          cmpi.b   #$8, (a4)
01015144  0c18020c          cmpi.b   #$c, (a0)+
01015148  151e              move.b   (a6)+, -(a2)
0101514a  080c              dc.w     $080c
0101514c  1802              move.b   d2, d4
0101514e  0c140f08          cmpi.b   #$8, (a4)
01015152  0c18020c          cmpi.b   #$c, (a0)+
01015156  1304              move.b   d4, -(a1)
01015158  080c              dc.w     $080c
0101515a  1802              move.b   d2, d4
0101515c  0c140f08          cmpi.b   #$8, (a4)
01015160  0c18020c          cmpi.b   #$c, (a0)+
01015164  151e              move.b   (a6)+, -(a2)
01015166  080c              dc.w     $080c
01015168  1802              move.b   d2, d4
0101516a  0c140f08          cmpi.b   #$8, (a4)
0101516e  0c18020c          cmpi.b   #$c, (a0)+
01015172  1309              dc.w     $1309
01015174  1d0a              dc.w     $1d0a
01015176  080c              dc.w     $080c
01015178  1802              move.b   d2, d4
0101517a  0c14121d          cmpi.b   #$1d, (a4)
0101517e  0b080c18          movep.w  $c18(a0), d5
01015182  020c              dc.w     $020c
01015184  1517              move.b   (a7), -(a2)
01015186  1d15              move.b   (a5), -(a6)
01015188  080c              dc.w     $080c
0101518a  1802              move.b   d2, d4
0101518c  0c140f08          cmpi.b   #$8, (a4)
01015190  0c18020c          cmpi.b   #$c, (a0)+
01015194  1304              move.b   d4, -(a1)
01015196  080c              dc.w     $080c
01015198  1802              move.b   d2, d4
0101519a  0c140f08          cmpi.b   #$8, (a4)
0101519e  0c18020c          cmpi.b   #$c, (a0)+
010151a2  151e              move.b   (a6)+, -(a2)
010151a4  080c              dc.w     $080c
010151a6  1802              move.b   d2, d4
010151a8  0c140f08          cmpi.b   #$8, (a4)
010151ac  0c18020c          cmpi.b   #$c, (a0)+
010151b0  1304              move.b   d4, -(a1)
010151b2  080c              dc.w     $080c
010151b4  1802              move.b   d2, d4
010151b6  0c140f08          cmpi.b   #$8, (a4)
010151ba  0c18020c          cmpi.b   #$c, (a0)+
010151be  151e              move.b   (a6)+, -(a2)
010151c0  080c              dc.w     $080c
010151c2  1802              move.b   d2, d4
010151c4  1018              move.b   (a0)+, d0
010151c6  02101802          andi.b   #$2, (a0)
010151ca  1018              move.b   (a0)+, d0
010151cc  02101802          andi.b   #$2, (a0)
010151d0  1018              move.b   (a0)+, d0
010151d2  02101802          andi.b   #$2, (a0)
010151d6  1018              move.b   (a0)+, d0
010151d8  02101802          andi.b   #$2, (a0)
010151dc  1018              move.b   (a0)+, d0
010151de  02101802          andi.b   #$2, (a0)
010151e2  1018              move.b   (a0)+, d0
010151e4  02101802          andi.b   #$2, (a0)
010151e8  1018              move.b   (a0)+, d0
010151ea  02101802          andi.b   #$2, (a0)
010151ee  1018              move.b   (a0)+, d0
010151f0  02101802          andi.b   #$2, (a0)
010151f4  1018              move.b   (a0)+, d0
010151f6  02101802          andi.b   #$2, (a0)
010151fa  1018              move.b   (a0)+, d0
010151fc  02101802          andi.b   #$2, (a0)
01015200  1018              move.b   (a0)+, d0
01015202  02101802          andi.b   #$2, (a0)
01015206  1018              move.b   (a0)+, d0
01015208  02101802          andi.b   #$2, (a0)
0101520c  0e11              dc.w     $0e11
0101520e  0f18              btst.l   d7, (a0)+
01015210  020e              dc.w     $020e
01015212  1216              move.b   (a6), d1
01015214  0e18              dc.w     $0e18
01015216  020e              dc.w     $020e
01015218  1519              move.b   (a1)+, -(a2)
0101521a  0e18              dc.w     $0e18
0101521c  020e              dc.w     $020e
0101521e  1b1a              move.b   (a2)+, -(a5)
01015220  0e18              dc.w     $0e18
01015222  020d              dc.w     $020d
01015224  111c              move.b   (a4)+, -(a0)
01015226  0e18              dc.w     $0e18
01015228  020d              dc.w     $020d
0101522a  121c              move.b   (a4)+, d1
0101522c  160d              dc.w     $160d
0101522e  1802              move.b   d2, d4
01015230  0d11              btst.l   d6, (a1)
01015232  1c0e              dc.w     $1c0e
01015234  1802              move.b   d2, d4
01015236  0e1b              dc.w     $0e1b
01015238  1a0e              dc.w     $1a0e
0101523a  1802              move.b   d2, d4
0101523c  0e15              dc.w     $0e15
0101523e  190e              dc.w     $190e
01015240  1802              move.b   d2, d4
01015242  0e12              dc.w     $0e12
01015244  160e              dc.w     $160e
01015246  1802              move.b   d2, d4
01015248  0e11              dc.w     $0e11
0101524a  0f18              btst.l   d7, (a0)+
0101524c  02101802          andi.b   #$2, (a0)
01015250  1018              move.b   (a0)+, d0
01015252  1f18              move.b   (a0)+, -(a7)
01015254  1f18              move.b   (a0)+, -(a7)
01015256  031c              btst.l   d1, (a4)+
01015258  0507              btst.l   d2, d7
0101525a  1b18              move.b   (a0)+, -(a5)
0101525c  0303              btst.l   d1, d3
0101525e  1c05              move.b   d5, d6
01015260  071b              btst.l   d3, (a3)+
01015262  1803              move.b   d3, d4
01015264  5300              subq.b   #$1, d0
01015266  00000000          ori.b    #$0, d0
0101526a  00580000          ori.w    #$0, (a0)+
0101526e  00584155          ori.w    #$4155, (a0)+
01015272  0155              bchg.b   d0, (a5)
01015274  02550355          andi.w   #$355, (a5)
01015278  0555              bchg.b   d2, (a5)
0101527a  06550755          addi.w   #$755, (a5)
0101527e  1656              dc.w     $1656
01015280  0157              bchg.b   d0, (a7)
01015282  0159              bchg.b   d0, (a1)+
01015284  015a              bchg.b   d0, (a2)+
01015286  015e              bchg.b   d0, (a6)+
01015288  015f              bchg.b   d0, (a7)+
0101528a  0165              bchg.b   d0, -(a5)
0101528c  0166              bchg.b   d0, -(a6)
0101528e  016a016b          bchg.b   d0, $16b(a2)
01015292  017a              dc.w     $017a
01015294  017f              dc.w     $017f
01015296  0195              bclr.b   d0, (a5)
01015298  0196              bclr.b   d0, (a6)
0101529a  019a              bclr.b   d0, (a2)+
0101529c  01a5              bclr.b   d0, -(a5)
0101529e  01a6              bclr.b   d0, -(a6)
010152a0  01aa01aa          bclr.b   d0, $1aa(a2)
010152a4  02aa05aa06aa07aa  andi.l   #$5aa06aa, $7aa(a2)         ; $05aa06aa = RAM bank 0 (Turbo: 32 MB stride)
010152ac  08aa              dc.w     $08aa
010152ae  0aaa0baa0caa0daa  eori.l   #$baa0caa, $daa(a2)         ; $0baa0caa = RAM bank 3
010152b6  0eaa              dc.w     $0eaa
010152b8  0faa14ab          bclr.b   d7, $14ab(a2)
010152bc  01ad01ae          bclr.b   d0, $1ae(a5)
010152c0  01b501ba01bb06bb08bf  bclr.b   d0, ([$1bb06bb, d0.w], $8bf) ; $01bb06bb = ROM
010152ca  01d5              bset.b   d0, (a5)
010152cc  01ea01ee          bset.b   d0, $1ee(a2)
010152d0  01ee02ee          bset.b   d0, $2ee(a6)
010152d4  07ef01fa          bset.b   d3, $1fa(a7)
010152d8  01fb              dc.w     $01fb
010152da  01fd              dc.w     $01fd
010152dc  01fe              dc.w     $01fe
010152de  01ff              dc.w     $01ff
010152e0  01ff              dc.w     $01ff
010152e2  02ff              dc.w     $02ff
010152e4  06ff              dc.w     $06ff
010152e6  08ff              dc.w     $08ff
010152e8  09ff              dc.w     $09ff
010152ea  0aff              dc.w     $0aff
010152ec  0eff              dc.w     $0eff
010152ee  10ff              dc.w     $10ff
010152f0  12ff              dc.w     $12ff
010152f2  1501              move.b   d1, -(a2)
010152f4  123e              dc.w     $123e
010152f6  3501              move.w   d1, -(a2)
010152f8  013f              dc.w     $013f
010152fa  0101              btst.l   d0, d1
010152fc  3f01              move.w   d1, -(a7)
010152fe  0008              dc.w     $0008
01015300  3f2d0000          move.w   $0(a5), -(a7)
01015304  0837              dc.w     $0837
01015306  3323              move.w   -(a3), -(a1)
01015308  372d0000          move.w   $0(a5), -(a3)
0101530c  0837              dc.w     $0837
0101530e  3323              move.w   -(a3), -(a1)
01015310  372d0000          move.w   $0(a5), -(a3)
01015314  0837              dc.w     $0837
01015316  343d              dc.w     $343d
01015318  36372d00          move.w   (a7, d2.l * 4), d3
0101531c  0008              dc.w     $0008
0101531e  37342227          move.w   $27(a4, d2.w), -(a3)
01015322  372d0000          move.w   $0(a5), -(a3)
01015326  0837              dc.w     $0837
01015328  3422              move.w   -(a2), d2
0101532a  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101532e  0008              dc.w     $0008
01015330  37341603          move.w   $3(a4, d1.w), -(a3)
01015334  141c              move.b   (a4)+, d2
01015336  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101533a  0008              dc.w     $0008
0101533c  37341602          move.w   $2(a4, d1.w), -(a3)
01015340  0d14              btst.l   d6, (a4)
01015342  1d27              move.b   -(a7), -(a6)
01015344  372d0000          move.w   $0(a5), -(a3)
01015348  0837              dc.w     $0837
0101534a  3416              move.w   (a6), d2
0101534c  021e2737          andi.b   #$37, (a6)+
01015350  2d00              move.l   d0, -(a6)
01015352  0008              dc.w     $0008
01015354  3734160a          move.w   $a(a4, d1.w), -(a3)
01015358  0e0f              dc.w     $0e0f
0101535a  1e27              move.b   -(a7), d7
0101535c  372d0000          move.w   $0(a5), -(a3)
01015360  0837              dc.w     $0837
01015362  3416              move.w   (a6), d2
01015364  00151f27          ori.b    #$27, (a5)
01015368  372d0000          move.w   $0(a5), -(a3)
0101536c  0837              dc.w     $0837
0101536e  3416              move.w   (a6), d2
01015370  0e20              dc.w     $0e20
01015372  27372d00          move.l   (a7, d2.l * 4), -(a3)
01015376  0008              dc.w     $0008
01015378  37341609          move.w   $9(a4, d1.w), -(a3)
0101537c  2027              move.l   -(a7), d0
0101537e  372d0000          move.w   $0(a5), -(a3)
01015382  0837              dc.w     $0837
01015384  3416              move.w   (a6), d2
01015386  1420              move.b   -(a0), d2
01015388  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101538c  0008              dc.w     $0008
0101538e  3734160f          move.w   $f(a4, d1.w), -(a3)
01015392  2027              move.l   -(a7), d0
01015394  372d0000          move.w   $0(a5), -(a3)
01015398  0837              dc.w     $0837
0101539a  3416              move.w   (a6), d2
0101539c  1520              move.b   -(a0), -(a2)
0101539e  27372d00          move.l   (a7, d2.l * 4), -(a3)
010153a2  0008              dc.w     $0008
010153a4  3734160f          move.w   $f(a4, d1.w), -(a3)
010153a8  2027              move.l   -(a7), d0
010153aa  372d0000          move.w   $0(a5), -(a3)
010153ae  0837              dc.w     $0837
010153b0  3416              move.w   (a6), d2
010153b2  2127              move.l   -(a7), -(a0)
010153b4  372d0000          move.w   $0(a5), -(a3)
010153b8  0837              dc.w     $0837
010153ba  3416              move.w   (a6), d2
010153bc  0f20              btst.l   d7, -(a0)
010153be  27372d00          move.l   (a7, d2.l * 4), -(a3)
010153c2  0008              dc.w     $0008
010153c4  37341621          move.w   $21(a4, d1.w), -(a3)
010153c8  27372d00          move.l   (a7, d2.l * 4), -(a3)
010153cc  0008              dc.w     $0008
010153ce  373417212737      move.w   ([$2737, a4, d1.w * 8]), -(a3)
010153d4  2d00              move.l   d0, -(a6)
010153d6  0008              dc.w     $0008
010153d8  373417212737      move.w   ([$2737, a4, d1.w * 8]), -(a3)
010153de  2d00              move.l   d0, -(a6)
010153e0  0008              dc.w     $0008
010153e2  37341621          move.w   $21(a4, d1.w), -(a3)
010153e6  27372d00          move.l   (a7, d2.l * 4), -(a3)
010153ea  0008              dc.w     $0008
010153ec  37341621          move.w   $21(a4, d1.w), -(a3)
010153f0  27372d00          move.l   (a7, d2.l * 4), -(a3)
010153f4  0008              dc.w     $0008
010153f6  373417212737      move.w   ([$2737, a4, d1.w * 8]), -(a3)
010153fc  2d00              move.l   d0, -(a6)
010153fe  0008              dc.w     $0008
01015400  37342227          move.w   $27(a4, d2.w), -(a3)
01015404  372d0000          move.w   $0(a5), -(a3)
01015408  0837              dc.w     $0837
0101540a  3417              move.w   (a7), d2
0101540c  2127              move.l   -(a7), -(a0)
0101540e  372d0000          move.w   $0(a5), -(a3)
01015412  0837              dc.w     $0837
01015414  3422              move.w   -(a2), d2
01015416  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101541a  0008              dc.w     $0008
0101541c  37342227          move.w   $27(a4, d2.w), -(a3)
01015420  372d0000          move.w   $0(a5), -(a3)
01015424  0837              dc.w     $0837
01015426  3422              move.w   -(a2), d2
01015428  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101542c  0008              dc.w     $0008
0101542e  37342227          move.w   $27(a4, d2.w), -(a3)
01015432  372d0000          move.w   $0(a5), -(a3)
01015436  0837              dc.w     $0837
01015438  3422              move.w   -(a2), d2
0101543a  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101543e  0008              dc.w     $0008
01015440  37342227          move.w   $27(a4, d2.w), -(a3)
01015444  372d0000          move.w   $0(a5), -(a3)
01015448  0837              dc.w     $0837
0101544a  3422              move.w   -(a2), d2
0101544c  27372d00          move.l   (a7, d2.l * 4), -(a3)
01015450  0008              dc.w     $0008
01015452  37342227          move.w   $27(a4, d2.w), -(a3)
01015456  372d0000          move.w   $0(a5), -(a3)
0101545a  0837              dc.w     $0837
0101545c  3422              move.w   -(a2), d2
0101545e  27372d00          move.l   (a7, d2.l * 4), -(a3)
01015462  0008              dc.w     $0008
01015464  37342227          move.w   $27(a4, d2.w), -(a3)
01015468  372d0000          move.w   $0(a5), -(a3)
0101546c  0837              dc.w     $0837
0101546e  3422              move.w   -(a2), d2
01015470  27372d00          move.l   (a7, d2.l * 4), -(a3)
01015474  0008              dc.w     $0008
01015476  37342227          move.w   $27(a4, d2.w), -(a3)
0101547a  372d0000          move.w   $0(a5), -(a3)
0101547e  0837              dc.w     $0837
01015480  3422              move.w   -(a2), d2
01015482  27372d00          move.l   (a7, d2.l * 4), -(a3)
01015486  0008              dc.w     $0008
01015488  37342227          move.w   $27(a4, d2.w), -(a3)
0101548c  372d0000          move.w   $0(a5), -(a3)
01015490  0837              dc.w     $0837
01015492  3422              move.w   -(a2), d2
01015494  27372d00          move.l   (a7, d2.l * 4), -(a3)
01015498  0008              dc.w     $0008
0101549a  37342227          move.w   $27(a4, d2.w), -(a3)
0101549e  372d0000          move.w   $0(a5), -(a3)
010154a2  0837              dc.w     $0837
010154a4  343d              dc.w     $343d
010154a6  36372d00          move.w   (a7, d2.l * 4), d3
010154aa  0008              dc.w     $0008
010154ac  373323372d00000837332337  move.w   ([$2d000008, a3], d2.w * 2, $37332337), -(a3)
010154b8  2d00              move.l   d0, -(a6)
010154ba  0008              dc.w     $0008
010154bc  3f2d0000          move.w   $0(a5), -(a7)
010154c0  083f              dc.w     $083f
010154c2  2d00              move.l   d0, -(a6)
010154c4  0008              dc.w     $0008
010154c6  3f2d0000          move.w   $0(a5), -(a7)
010154ca  083f              dc.w     $083f
010154cc  2d00              move.l   d0, -(a6)
010154ce  0008              dc.w     $0008
010154d0  3f2d0005          move.w   $5(a5), -(a7)
010154d4  2b13              move.l   (a3), -(a5)
010154d6  04053036          subi.b   #$36, d5
010154da  322f3630          move.w   $3630(a7), d1
010154de  2d04              move.l   d4, -(a6)
010154e0  053a2d04          btst.l   d2, $10181e6(pc)
010154e4  053a2d04          btst.l   d2, $10181ea(pc)
010154e8  050c3935          movep.w  $3935(a4), d2
010154ec  0505              btst.l   d2, d5
010154ee  0c39350500081b39  cmpi.b   #$5, $81b39.l
010154f6  331a              move.w   (a2)+, -(a1)
010154f8  2800              move.l   d0, d4
010154fa  000b              dc.w     $000b
010154fc  1b39331a2600      move.b   $331a2600.l, -(a5)
01015502  000b              dc.w     $000b
01015504  1a25              move.b   -(a5), d5
01015506  2a291a26          move.l   $1a26(a1), d5
0101550a  0000111a          ori.b    #$1a, d0
0101550e  27311a25          move.l   $25(a1, d1.l), -(a3)
01015512  0000111a          ori.b    #$1a, d0
01015516  2b1a              move.l   (a2)+, -(a5)
01015518  2500              move.l   d0, -(a2)
0101551a  002e1a27311b      ori.b    #$27, $311b(a6)
01015520  2d00              move.l   d0, -(a6)
01015522  2e18              move.l   (a0)+, d7
01015524  2538343a          move.l   $343a.w, -(a2)
01015528  36383319          move.w   $3319.w, d3
0101552c  2d08              move.l   a0, -(a6)
0101552e  1925              move.b   -(a5), -(a4)
01015530  38343a36          move.w   $36(a4, d3.l), d4
01015534  383319280819      move.w   $819(a3, d1.l), d4
0101553a  253d              dc.w     $253d
0101553c  3319              move.w   (a1)+, -(a1)
0101553e  280b              move.l   a3, d4
01015540  1925              move.b   -(a5), -(a4)
01015542  3d3319260b192538  move.w   ([$b19, a3], d1.l, $2538), -(a6)
0101554a  343a3638          move.w   $1018b84(pc), d2
0101554e  3319              move.w   (a1)+, -(a1)
01015550  2611              move.l   (a1), d3
01015552  2425              move.l   -(a5), d2
01015554  1124              move.b   -(a4), -(a0)
01015556  2512              move.l   (a2), -(a2)
01015558  4012              negx.b   (a2)
0101555a  4012              negx.b   (a2)
0101555c  4012              negx.b   (a2)
0101555e  400f              dc.w     $400f
01015560  1e14              move.b   (a4), d7
01015562  1e0f              dc.w     $1e0f
01015564  1e07              move.b   d7, d7
01015566  1e12              move.b   (a2), d7
01015568  3b35103c          move.w   $3c(a5, d1.w), -(a5)
0101556c  0f1e              btst.l   d7, (a6)+
0101556e  2c1e              move.l   (a6)+, d6
01015570  0f1e              btst.l   d7, (a6)+
01015572  271e              move.l   (a6)+, -(a3)
01015574  1240              dc.w     $1240
01015576  1240              dc.w     $1240
01015578  1240              dc.w     $1240
0101557a  1240              dc.w     $1240
0101557c  06060000          addi.b   #$0, d6
01015580  5300              subq.b   #$1, d0
01015582  00000000          ori.b    #$0, d0
01015586  0100              btst.l   d0, d0
01015588  00000032          ori.b    #$32, d0
0101558c  5455              addq.w   #$2, (a5)
0101558e  0155              bchg.b   d0, (a5)
01015590  02550355          andi.w   #$355, (a5)
01015594  04550555          subi.w   #$555, (a5)
01015598  06550755          addi.w   #$755, (a5)
0101559c  0955              bchg.b   d4, (a5)
0101559e  0a550b55          eori.w   #$b55, (a5)
010155a2  0c550d55          cmpi.w   #$d55, (a5)
010155a6  0e55              dc.w     $0e55
010155a8  0f55              bchg.b   d7, (a5)
010155aa  13551555          move.b   (a5), $1555(a1)
010155ae  1d552155          move.b   (a5), $2155(a6)
010155b2  2655              movea.l  (a5), a3
010155b4  2d554056          move.l   (a5), $4056(a6)
010155b8  0157              bchg.b   d0, (a7)
010155ba  0157              bchg.b   d0, (a7)
010155bc  025b015d          andi.w   #$15d, (a3)+
010155c0  015e              bchg.b   d0, (a6)+
010155c2  015f              bchg.b   d0, (a7)+
010155c4  015f              bchg.b   d0, (a7)+
010155c6  025f056d          andi.w   #$56d, (a7)+
010155ca  016e016f          bchg.b   d0, $16f(a6)
010155ce  016f0275          bchg.b   d0, $275(a7)
010155d2  0179017d017d      bchg.b   d0, $17d017d.l              ; $017d017d = ROM
010155d8  027d              dc.w     $027d
010155da  037d              dc.w     $037d
010155dc  057e              dc.w     $057e
010155de  017f              dc.w     $017f
010155e0  017f              dc.w     $017f
010155e2  029501960197      andi.l   #$1960197, (a5)             ; $01960197 = ROM
010155e8  019b              bclr.b   d0, (a3)+
010155ea  019f              bclr.b   d0, (a7)+
010155ec  01ae01af          bclr.b   d0, $1af(a6)
010155f0  01b501b901bd01be  bclr.b   d0, ([$1bd01be, d0.w])      ; $01bd01be = ROM
010155f8  01be              dc.w     $01be
010155fa  02bf              dc.w     $02bf
010155fc  01d5              bset.b   d0, (a5)
010155fe  01d6              bset.b   d0, (a6)
01015600  01d7              bset.b   d0, (a7)
01015602  01d7              bset.b   d0, (a7)
01015604  02da              dc.w     $02da
01015606  01db              bset.b   d0, (a3)+
01015608  01dd              bset.b   d0, (a5)+
0101560a  01de              bset.b   d0, (a6)+
0101560c  01df              bset.b   d0, (a7)+
0101560e  01e5              bset.b   d0, -(a5)
01015610  01e6              bset.b   d0, -(a6)
01015612  01eb01ed          bset.b   d0, $1ed(a3)
01015616  01ef01f5          bset.b   d0, $1f5(a7)
0101561a  01f502f5          bset.b   d0, -$b(a5, d0.w)
0101561e  03f601f701f901fa  bset.b   d1, ([$1f901fa])            ; $01f901fa = ROM
01015626  01fb              dc.w     $01fb
01015628  01fd              dc.w     $01fd
0101562a  01fe              dc.w     $01fe
0101562c  01ff              dc.w     $01ff
0101562e  01ff              dc.w     $01ff
01015630  02ff              dc.w     $02ff
01015632  03ff              dc.w     $03ff
01015634  0414001b          subi.b   #$1b, (a4)
01015638  002950411550      ori.b    #$41, $1550(a1)
0101563e  4150              dc.w     $4150
01015640  4f16              chk.l    (a6), d7
01015642  5338374b          subq.b   #$1, $374b.w
01015646  2400              move.l   d0, d2
01015648  1b460050          move.b   d6, $50(a5)
0101564c  001b4000          ori.b    #$0, (a3)+
01015650  1b01              move.b   d1, -(a5)
01015652  1b460024          move.b   d6, $24(a5)
01015656  1850              dc.w     $1850

; ---- gap 0101565c..01015670 (21 bytes) ----
0101565c  204f              movea.l  a7, a0
0101565e  1650              dc.w     $1650
01015660  4b15              chk.l    (a5), d5
01015662  5041              addq.w   #$8, d1
01015664  5200              addq.b   #$1, d0
01015666  163d              dc.w     $163d
01015668  4b06              chk.l    d6, d5
0101566a  00202b29          ori.b    #$29, -(a0)
0101566e  504b              addq.w   #$8, a3
01015670  1b50              dc.w     $1b50

; ---- gap 0101567a..0101572e (181 bytes) ----
0101567a  1b460050          move.b   d6, $50(a5)
0101567e  00291b001b2b      ori.b    #$0, $1b2b(a1)
01015684  00204e00          ori.b    #$0, -(a0)
01015688  24295046          move.l   $5046(a1), d2
0101568c  5138513a          subq.b   #$8, $513a.w
01015690  511b              subq.b   #$8, (a3)+
01015692  504e              addq.w   #$8, a6
01015694  5200              addq.b   #$1, d0
01015696  1645              dc.w     $1645
01015698  4f06              chk.l    d6, d7
0101569a  00293824004e      ori.b    #$24, $4e(a1)
010156a0  292b3746          move.l   $3746(a3), -(a4)
010156a4  184a              dc.w     $184a
010156a6  3800              move.w   d0, d4
010156a8  4600              not.b    d0
010156aa  1b41204e          move.b   d1, $204e(a5)
010156ae  001b4600          ori.b    #$0, (a3)+
010156b2  5000              addq.b   #$8, d0
010156b4  4e1b              dc.w     $4e1b
010156b6  001b3800          ori.b    #$0, (a3)+
010156ba  294f0024          move.l   a7, $24(a4)
010156be  4f15              chk.l    (a5), d7
010156c0  4e46              trap     #$6
010156c2  164a              dc.w     $164a
010156c4  4b18              chk.l    (a0)+, d5
010156c6  4a381b50          tst.b    $1b50.w
010156ca  003700461b00      ori.b    #$46, (a7, d1.l * 2)
010156d0  164f              dc.w     $164f
010156d2  2006              move.l   d6, d0
010156d4  003741240024      ori.b    #$24, $24(a7, d0.w)
010156da  3400              move.w   d0, d2
010156dc  1b46004d          move.b   d6, $4d(a5)
010156e0  3800              move.w   d0, d4
010156e2  4600              not.b    d0
010156e4  2000              move.l   d0, d0
010156e6  164e              dc.w     $164e
010156e8  001b4600          ori.b    #$0, (a3)+
010156ec  5016              addq.b   #$8, (a6)
010156ee  461b              not.b    (a3)+
010156f0  001b4100          ori.b    #$0, (a3)+
010156f4  37500028          move.w   (a0), $28(a3)
010156f8  4600              not.b    d0
010156fa  2846              movea.l  d6, a4
010156fc  004d              dc.w     $004d
010156fe  3800              move.w   d0, d4
01015700  4d38164f          chk.l    $164f.w, d6
01015704  001b0046          ori.b    #$46, (a3)+
01015708  1b00              move.b   d0, -(a5)
0101570a  164e              dc.w     $164e
0101570c  1b46011b          move.b   d6, $11b(a5)
01015710  02004724          andi.b   #$24, d0
01015714  00244b01          ori.b    #$1, -(a4)
01015718  4600              not.b    d0
0101571a  37380046          move.w   $46.w, -(a3)
0101571e  002800164e00      ori.b    #$16, $4e00(a0)
01015724  1b460050          move.b   d6, $50(a5)
01015728  1b381b00          move.b   $1b00.w, -(a5)
0101572c  1b46              dc.w     $1b46
0101572e  0050              dc.w     $0050

; ---- gap 01015735..01015767 (51 bytes) ----
01015735  1f460050          move.b   d6, $50(a7)
01015739  2b00              move.l   d0, -(a5)
0101573b  37381650          move.w   $1650.w, -(a3)
0101573f  2b01              move.l   d1, -(a5)
01015741  461b              not.b    (a3)+
01015743  00163828          ori.b    #$28, (a6)
01015747  3701              move.w   d1, -(a3)
01015749  4f02              chk.l    d2, d7
0101574b  00472400          ori.w    #$2400, d7
0101574f  4b46              dc.w     $4b46
01015751  0146              bchg.b   d0, d6
01015753  002938004600      ori.b    #$0, $4600(a1)
01015759  2401              move.l   d1, d2
0101575b  2400              move.l   d0, d2
0101575d  1b460050          move.b   d6, $50(a5)
01015761  2900              move.l   d0, -(a4)
01015763  1b00              move.b   d0, -(a5)
01015765  1b4b              dc.w     $1b4b
01015767  1550              dc.w     $1550

; ---- gap 0101576e..010157a0 (51 bytes) ----
0101576e  1b461550          move.b   d6, $1550(a5)
01015772  0129381b          btst.l   d0, $381b(a1)
01015776  404e              dc.w     $404e
01015778  0146              bchg.b   d0, d6
0101577a  1b00              move.b   d0, -(a5)
0101577c  16384e18          move.b   $4e18.w, d3
01015780  461b              not.b    (a3)+
01015782  4150              dc.w     $4150
01015784  4e00              dc.w     $4e00
01015786  15413329          move.b   d1, $3329(a2)
0101578a  5047              addq.w   #$8, d7
0101578c  0146              bchg.b   d0, d6
0101578e  0029504e5124      ori.b    #$4e, $5124(a1)
01015794  01295146          btst.l   d0, $5146(a1)
01015798  00504e00          ori.w    #$4e00, (a0)
0101579c  1b00              move.b   d0, -(a5)
0101579e  1b34              dc.w     $1b34
010157a0  1645              dc.w     $1645

; ---- gap 010157a6..010157c5 (32 bytes) ----
010157a6  1b514501          move.b   (a1), $4501(a5)
010157aa  29510050          move.l   (a1), $50(a4)
010157ae  3800              move.w   d0, d4
010157b0  461b              not.b    (a3)+
010157b2  00163946          ori.b    #$46, (a6)
010157b6  003600504e00      ori.b    #$50, (a6, d4.l * 8)
010157bc  16382429          move.b   $2429.w, d3
010157c0  504e              addq.w   #$8, a6
010157c2  4601              not.b    d1
010157c4  4600              not.b    d0

; ---- gap 010157cc..010158e8 (285 bytes) ----
010157cc  5346              subq.w   #$1, d6
010157ce  0051001b          ori.w    #$1b, (a1)
010157d2  001b2818          ori.b    #$18, (a3)+
010157d6  4046              negx.w   d6
010157d8  34293800          move.w   $3800(a1), d2
010157dc  1b512f01          move.b   (a1), $2f01(a5)
010157e0  29504e00          move.l   (a0), $4e00(a4)
010157e4  184e              dc.w     $184e
010157e6  00461b00          ori.w    #$1b00, d6
010157ea  163a3800          move.b   $1018fec(pc), d3
010157ee  1b460316          move.b   d6, $316(a5)
010157f2  504e              addq.w   #$8, a6
010157f4  2400              move.l   d0, d2
010157f6  29460146          move.l   d6, $146(a4)
010157fa  002938004600      ori.b    #$0, $4600(a1)
01015800  2400              move.l   d0, d2
01015802  504e              addq.w   #$8, a6
01015804  001b4600          ori.b    #$0, (a3)+
01015808  501b              addq.b   #$8, (a3)+
0101580a  381b              move.w   (a3)+, d4
0101580c  001b201b          ori.b    #$1b, (a3)+
01015810  2f462829          move.l   d6, $2829(a7)
01015814  3800              move.w   d0, d4
01015816  1b46001b          move.b   d6, $1b(a5)
0101581a  01293820          btst.l   d0, $3820(a1)
0101581e  01370046          btst.l   d0, $46(a7, d0.w)
01015822  1b00              move.b   d0, -(a5)
01015824  163a3800          move.b   $1019026(pc), d3
01015828  3600              move.w   d0, d3
0101582a  504e              addq.w   #$8, a6
0101582c  001b5124          ori.b    #$24, (a3)+
01015830  001b4b01          ori.b    #$1, (a3)+
01015834  4600              not.b    d0
01015836  37380046          move.w   $46.w, -(a3)
0101583a  002800164e00      ori.b    #$16, $4e00(a0)
01015840  1b500050          move.b   (a0), $50(a5)
01015844  1646              dc.w     $1646
01015846  1b00              move.b   d0, -(a5)
01015848  1c311b46          move.b   ([a1]), d6
0101584c  1b354100          move.b   (a5, d4.w), -(a5)
01015850  1f46001b          move.b   d6, $1b(a7)
01015854  2b24              move.l   -(a4), -(a5)
01015856  37381b2b          move.w   $1b2b.w, -(a3)
0101585a  00200046          ori.b    #$46, -(a0)
0101585e  1b00              move.b   d0, -(a5)
01015860  163a3818          move.b   $101907a(pc), d3
01015864  461b              not.b    (a3)+
01015866  4150              dc.w     $4150
01015868  4e00              dc.w     $4e00
0101586a  1b2b2024          move.b   $2024(a3), -(a5)
0101586e  001b3400          ori.b    #$0, (a3)+
01015872  1b46004d          move.b   d6, $4d(a5)
01015876  3800              move.w   d0, d4
01015878  4600              not.b    d0
0101587a  2000              move.l   d0, d0
0101587c  164e              dc.w     $164e
0101587e  001b5000          ori.b    #$0, (a3)+
01015882  5000              addq.b   #$8, d0
01015884  4e1b              dc.w     $4e1b
01015886  001b1830          ori.b    #$30, (a3)+
0101588a  1b46184f          move.b   d6, $184f(a5)
0101588e  4600              not.b    d0
01015890  2846              movea.l  d6, a4
01015892  00183828          ori.b    #$28, (a0)+
01015896  4d38184e          chk.l    $184e.w, d6
0101589a  00200046          ori.b    #$46, -(a0)
0101589e  1b00              move.b   d0, -(a5)
010158a0  16380037          move.b   $37.w, d3
010158a4  014f0220          movep.l  $220(a7), d0
010158a8  001b3400          ori.b    #$0, (a3)+
010158ac  2a2b3746          move.l   $3746(a3), d5
010158b0  184a              dc.w     $184a
010158b2  3800              move.w   d0, d4
010158b4  4600              not.b    d0
010158b6  1b41204e          move.b   d1, $204e(a5)
010158ba  001b503a          ori.b    #$3a, (a3)+
010158be  5000              addq.b   #$8, d0
010158c0  291b              move.l   (a3)+, -(a4)
010158c2  001b164e          ori.b    #$4e, (a3)+
010158c6  1b46154e          move.b   d6, $154e(a5)
010158ca  4f15              chk.l    (a5), d7
010158cc  4e46              trap     #$6
010158ce  00164b1b          ori.b    #$1b, (a6)
010158d2  4a381650          tst.b    $1650.w
010158d6  2b370046          move.l   $46(a7, d0.w), -(a5)
010158da  18381b2b          move.b   $1b2b.w, d4
010158de  0046011b          ori.w    #$11b, d6
010158e2  02280018514e      andi.b   #$18, $514e(a0)
010158e8  1b50              dc.w     $1b50

; ---- gap 010158f0..010159ab (188 bytes) ----
010158f0  1651              dc.w     $1651
010158f2  4e00              dc.w     $4e00
010158f4  1b4d              dc.w     $1b4d
010158f6  5045              addq.w   #$8, d5
010158f8  001b4051          ori.b    #$51, (a3)+
010158fc  154b              dc.w     $154b
010158fe  1b46004e          move.b   d6, $4e(a5)
01015902  29504701          move.l   (a0), $4701(a4)
01015906  513a              dc.w     $513a
01015908  3816              move.w   (a6), d4
0101590a  4050              negx.w   (a0)
0101590c  4e00              dc.w     $4e00
0101590e  4616              not.b    (a6)
01015910  5116              subq.b   #$8, (a6)
01015912  3806              move.w   d6, d4
01015914  2400              move.l   d0, d2
01015916  1651              dc.w     $1651
01015918  4115              chk.l    (a5), d0
0101591a  5041              addq.w   #$8, d1
0101591c  504f              addq.w   #$8, a7
0101591e  1651              dc.w     $1651
01015920  4601              not.b    d1
01015922  374a4e00          move.w   a2, $4e00(a3)
01015926  1b49              dc.w     $1b49
01015928  502f0016          addq.b   #$8, $16(a7)
0101592c  5200              addq.b   #$1, d0
0101592e  461b              not.b    (a3)+
01015930  4600              not.b    d0
01015932  2418              move.l   (a0)+, d2
01015934  502b4601          addq.b   #$8, $4601(a3)
01015938  204f              movea.l  a7, a0
0101593a  4a381639          tst.b    $1639.w
0101593e  5041              addq.w   #$8, d1
01015940  00460037          ori.w    #$37, d6
01015944  4b16              chk.l    (a6), d5
01015946  3806              move.w   d6, d4
01015948  0850              dc.w     $0850
0101594a  11460e24          move.b   d6, $e24(a0)
0101594e  00164e00          ori.b    #$0, (a6)
01015952  4616              not.b    (a6)
01015954  4e00              dc.w     $4e00
01015956  1b46001b          move.b   d6, $1b(a5)
0101595a  5146              subq.w   #$8, d6
0101595c  0f46              bchg.b   d7, d6
0101595e  15504b03          move.b   (a0), $4b03(a2)
01015962  380c              move.w   a4, d4
01015964  16380128          move.b   $128.w, d3
01015968  00184e00          ori.b    #$0, (a0)+
0101596c  4616              not.b    (a6)
0101596e  4f00              chk.l    d0, d7
01015970  2046              movea.l  d6, a0
01015972  001b5146          ori.b    #$46, (a3)+
01015976  5000              addq.b   #$8, d0
01015978  34374137410024504e1b4b51  move.w   ([$41002450, a7], d4.w, $4e1b4b51), d2
01015984  204b              movea.l  a3, a0
01015986  204b              movea.l  a3, a0
01015988  1b472051          move.b   d7, $2051(a5)
0101598c  00192220          ori.b    #$20, (a1)+
01015990  4e18              dc.w     $4e18
01015992  411b              chk.l    (a3)+, d0
01015994  00190035          ori.b    #$35, (a1)+
01015998  03380116          btst.l   d1, $116.w
0101599c  3801              move.w   d1, d4
0101599e  2000              move.l   d0, d0
010159a0  1b34154b16400024  move.b   ([a4], $16400024), -(a5)    ; $16400024 = RAM MWF mirrors (non-Turbo mono only)
010159a8  3300              move.w   d0, -(a1)
010159aa  1f01              move.b   d1, -(a7)

; ---- gap 010159b4..010159f5 (66 bytes) ----
010159b4  4e504e29          link.w   a0, #$4e29
010159b8  52374f374f294e46372b2038  addq.b   #$1, ([$4f294e46, a7], d4.l * 8, $372b2038)
010159c4  1922              move.b   -(a2), -(a4)
010159c6  3750204b          move.w   (a0), $204b(a3)
010159ca  1f00              move.b   d0, -(a7)
010159cc  2915              move.l   (a5), -(a4)
010159ce  502b0119          addq.b   #$8, $119(a3)
010159d2  3e01              move.w   d1, d7
010159d4  1638011b          move.b   $11b.w, d3
010159d8  001b2816          ori.b    #$16, (a3)+
010159dc  4e18              dc.w     $4e18
010159de  3d384b24          move.w   $4b24.w, -(a6)
010159e2  00240016          ori.b    #$16, -(a4)
010159e6  3d3a4550          move.w   $1019f38(pc), -(a6)
010159ea  38373834          move.w   $34(a7, d3.l), d4
010159ee  164e              dc.w     $164e
010159f0  4600              not.b    d0
010159f2  341b              move.w   (a3)+, d2
010159f4  001b              dc.w     $001b

; ---- gap 010159ff..01015b56 (344 bytes) ----
010159ff  1641              dc.w     $1641
01015a01  1922              move.b   -(a2), -(a4)
01015a03  4b40              dc.w     $4b40
01015a05  2600              move.l   d0, d3
01015a07  4a3b3800          tst.b    $1015a09(pc,d3.l)
01015a0b  2416              move.l   (a6), d2
01015a0d  4601              not.b    d1
01015a0f  1838011b          move.b   $11b.w, d4
01015a13  2b20              move.l   -(a0), -(a5)
01015a15  1f16              move.b   (a6), -(a7)
01015a17  4e18              dc.w     $4e18
01015a19  2d42461b          move.l   d2, $461b(a6)
01015a1d  0046001c          ori.w    #$1c, d6
01015a21  2c46              movea.l  d6, a6
01015a23  2400              move.l   d0, d2
01015a25  29382418          move.l   $2418.w, -(a4)
01015a29  3446              movea.w  d6, a2
01015a2b  004b              dc.w     $004b
01015a2d  0128461b          btst.l   d0, $461b(a0)
01015a31  461b              not.b    (a3)+
01015a33  4b20              chk.l    -(a0), d5
01015a35  4a41              tst.w    d1
01015a37  4e46              trap     #$6
01015a39  4a51              tst.w    (a1)
01015a3b  46382533          not.b    $2533.w
01015a3f  16384a3a          move.b   $4a3a.w, d3
01015a43  3800              move.w   d0, d4
01015a45  2400              move.l   d0, d2
01015a47  3801              move.w   d1, d4
01015a49  1b2f0118          move.b   $118(a7), -(a5)
01015a4d  38281b18          move.w   $1b18(a0), d4
01015a51  301b              move.w   (a3)+, d0
01015a53  004d              dc.w     $004d
01015a55  3818              move.w   (a0)+, d4
01015a57  2c41              movea.l  d1, a6
01015a59  00281b004624      ori.b    #$0, $4624(a0)
01015a5f  003400332024      ori.b    #$33, $24(a4, d2.w)
01015a65  504b              addq.w   #$8, a3
01015a67  4601              not.b    d1
01015a69  4b46              dc.w     $4b46
01015a6b  1b461b46          move.b   d6, $1b46(a5)
01015a6f  1b4d              dc.w     $1b4d
01015a71  3a4a              movea.w  a2, a5
01015a73  464a              dc.w     $464a
01015a75  514e              subq.w   #$8, a6
01015a77  3820              move.w   -(a0), d4
01015a79  4b46              dc.w     $4b46
01015a7b  0115              btst.l   d0, (a5)
01015a7d  502b0024          addq.b   #$8, $24(a3)
01015a81  1646              dc.w     $1646
01015a83  011c              btst.l   d0, (a4)+
01015a85  0116              btst.l   d0, (a6)
01015a87  3824              move.w   -(a4), d4
01015a89  1b18              move.b   (a0)+, -(a5)
01015a8b  1a1b              move.b   (a3)+, d5
01015a8d  003700164338004b1b00  ori.b    #$16, $4b1b00(a7, d4.w * 2) ; $004b1b00 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01015a97  4624              not.b    -(a4)
01015a99  15461b41          move.b   d6, $1b41(a2)
01015a9d  25504f4d          move.l   (a0), $4f4d(a2)
01015aa1  4b15              chk.l    (a5), d5
01015aa3  46364b20461b      not.b    $461b(a6, d4.l * 2)
01015aa9  502d3847          addq.b   #$8, $3847(a5)
01015aad  22383741          move.l   $3741.w, d1
01015ab1  1842              dc.w     $1842
01015ab3  4101              chk.l    d1, d0
01015ab5  1650              dc.w     $1650
01015ab7  0124              btst.l   d0, -(a4)
01015ab9  193e              dc.w     $193e
01015abb  0120              btst.l   d0, -(a0)
01015abd  02164134          andi.b   #$34, (a6)
01015ac1  1b2f1b20          move.b   $1b20(a7), -(a5)
01015ac5  00292b005000      ori.b    #$0, $5000(a1)
01015acb  15411b00          move.b   d1, $1b00(a2)
01015acf  4624              not.b    -(a4)
01015ad1  18381b47          move.b   $1b47.w, d4
01015ad5  2441              movea.l  d1, a2
01015ad7  2050              movea.l  (a0), a0
01015ad9  4f16              chk.l    (a6), d7
01015adb  41294e37          chk.l    $4e37(a1), d0
01015adf  5046              addq.w   #$8, d6
01015ae1  1b501b16          move.b   (a0), $1b16(a5)
01015ae5  3846              movea.w  d6, a4
01015ae7  2238204f          move.l   $204f.w, d1
01015aeb  00163801          ori.b    #$1, (a6)
01015aef  1845              dc.w     $1845
01015af1  401b              negx.b   (a3)+
01015af3  5046              addq.w   #$8, d6
01015af5  3801              move.w   d1, d4
01015af7  2802              move.l   d2, d4
01015af9  15464b18          move.b   d6, $4b18(a2)
01015afd  401b              negx.b   (a3)+
01015aff  2800              move.l   d0, d4
01015b01  4d380024          chk.l    $24.w, d6
01015b05  0018381b          ori.b    #$1b, (a0)+
01015b09  00462420          ori.w    #$2420, d6
01015b0d  0150              bchg.b   d0, (a0)
01015b0f  3824              move.w   -(a4), d4
01015b11  001b4b20          ori.b    #$20, (a3)+
01015b15  18383620          move.b   $3620.w, d4
01015b19  4546              dc.w     $4546
01015b1b  1b451b16          move.b   d5, $1b16(a5)
01015b1f  3a382238          move.w   $2238.w, d5
01015b23  15502b18          move.b   (a0), $2b18(a2)
01015b27  2e41              movea.l  d1, a7
01015b29  001b2d40          ori.b    #$40, (a3)+
01015b2d  1b504602          move.b   (a0), $4602(a5)
01015b31  2402              move.l   d2, d2
01015b33  0047163f          ori.w    #$163f, d7
01015b37  1824              move.b   -(a4), d4
01015b39  1642              dc.w     $1642
01015b3b  4600              not.b    d0
01015b3d  2400              move.l   d0, d2
01015b3f  1b00              move.b   d0, -(a5)
01015b41  1b00              move.b   d0, -(a5)
01015b43  4624              not.b    -(a4)
01015b45  3401              move.w   d1, d2
01015b47  2951001b          move.l   (a1), $1b(a4)
01015b4b  461c              not.b    (a4)+
01015b4d  2b461b00          move.l   d6, $1b00(a5)
01015b51  1b461b40          move.b   d6, $1b40(a5)
01015b55  1b16              move.b   (a6), -(a5)

; ---- gap 01015b5c..01015be2 (135 bytes) ----
01015b5c  3d381b20          move.w   $1b20.w, -(a6)
01015b60  4b00              chk.l    d0, d5
01015b62  1b00              move.b   d0, -(a5)
01015b64  5000              addq.b   #$8, d0
01015b66  2403              move.l   d3, d2
01015b68  2402              move.l   d2, d2
01015b6a  004c              dc.w     $004c
01015b6c  4616              not.b    (a6)
01015b6e  4416              neg.b    (a6)
01015b70  3418              move.w   (a0)+, d2
01015b72  384b              movea.w  a3, a4
01015b74  00240024          ori.b    #$24, -(a4)
01015b78  001b2c46          ori.b    #$46, (a3)+
01015b7c  2846              movea.l  d6, a4
01015b7e  16382951          move.b   $2951.w, d3
01015b82  461b              not.b    (a3)+
01015b84  461c              not.b    (a4)+
01015b86  00461b00          ori.w    #$1b00, d6
01015b8a  1b4b              dc.w     $1b4b
01015b8c  201d              move.l   (a5)+, d0
01015b8e  504e              addq.w   #$8, a6
01015b90  463a              dc.w     $463a
01015b92  381f              move.w   (a7)+, d4
01015b94  2500              move.l   d0, -(a2)
01015b96  1b00              move.b   d0, -(a5)
01015b98  4e00              dc.w     $4e00
01015b9a  2403              move.l   d3, d2
01015b9c  3302              move.w   d2, -(a1)
01015b9e  002938154e16      ori.b    #$15, $4e16(a1)
01015ba4  4b1b              chk.l    (a3)+, d5
01015ba6  00240024          ori.b    #$24, -(a4)
01015baa  00460018          ori.w    #$18, d6
01015bae  3a41              movea.w  d1, a5
01015bb0  29381641          move.l   $1641.w, -(a4)
01015bb4  3400              move.w   d0, d2
01015bb6  244b              movea.l  a3, a2
01015bb8  204b              movea.l  a3, a0
01015bba  2100              move.l   d0, -(a0)
01015bbc  4b20              chk.l    -(a0), d5
01015bbe  46283428          not.b    $3428(a0)
01015bc2  1b2f504e          move.b   $504e(a7), -(a5)
01015bc6  003a              dc.w     $003a
01015bc8  004b              dc.w     $004b
01015bca  3d382600          move.w   $2600.w, -(a6)
01015bce  1b2e5000          move.b   $5000(a6), -(a5)
01015bd2  2403              move.l   d3, d2
01015bd4  4602              not.b    d2
01015bd6  002938004b15      ori.b    #$0, $4b15(a1)
01015bdc  46280020          not.b    $20(a0)
01015be0  0024              dc.w     $0024
01015be2  0051              dc.w     $0051

; ---- gap 01015bed..01015bf3 (7 bytes) ----
01015bed  2437              dc.w     $2437
01015bef  4f37              dc.w     $4f37
01015bf1  4f28              dc.w     $4f28
01015bf3  0037              dc.w     $0037

; ---- gap 01015bff..01015c24 (38 bytes) ----
01015bff  3a00              move.w   d0, d5
01015c01  37502b33          move.w   (a0), $2b33(a3)
01015c05  204b              movea.l  a3, a0
01015c07  00185040          ori.b    #$40, (a0)+
01015c0b  3824              move.w   -(a4), d4
01015c0d  16384624          move.b   $4624.w, d3
01015c11  461b              not.b    (a3)+
01015c13  0100              btst.l   d0, d0
01015c15  202b0046          move.l   $46(a3), d0
01015c19  00462400          ori.w    #$2400, d6
01015c1d  1b00              move.b   d0, -(a5)
01015c1f  2400              move.l   d0, d2
01015c21  5146              subq.w   #$8, d6
01015c23  5000              addq.b   #$8, d0

; ---- gap 01015c2b..01015c74 (74 bytes) ----
01015c2b  2420              move.l   -(a0), d2
01015c2d  4b20              chk.l    -(a0), d5
01015c2f  4b24              chk.l    -(a4), d5
01015c31  00204b29          ori.b    #$29, -(a0)
01015c35  461b              not.b    (a3)+
01015c37  464a              dc.w     $464a
01015c39  4602              not.b    d2
01015c3b  3a00              move.w   d0, d5
01015c3d  204f              movea.l  a7, a0
01015c3f  00461841          ori.w    #$1841, d6
01015c43  00155016          ori.b    #$16, (a5)
01015c47  4600              not.b    d0
01015c49  16384624          move.b   $4624.w, d3
01015c4d  461b              not.b    (a3)+
01015c4f  0112              btst.l   d0, (a2)
01015c51  4f05              chk.l    d5, d7
01015c53  3809              move.w   a1, d4
01015c55  3822              move.w   -(a2), d4
01015c57  04133809          subi.b   #$9, (a3)
01015c5b  3822              move.w   -(a2), d4
01015c5d  04014604          subi.b   #$4, d1
01015c61  4601              not.b    d1
01015c63  2901              move.l   d1, -(a4)
01015c65  2400              move.l   d0, d2
01015c67  164e              dc.w     $164e
01015c69  00241019          ori.b    #$19, -(a4)
01015c6d  2200              move.l   d0, d1
01015c6f  2938193e          move.l   $193e.w, -(a4)
01015c73  1600              move.b   d0, d3

; ---- gap 01015c7a..01015c90 (23 bytes) ----
01015c7a  0146              bchg.b   d0, d6
01015c7c  04460150          subi.w   #$150, d6
01015c80  0124              btst.l   d0, -(a4)
01015c82  00164e00          ori.b    #$0, (a6)
01015c86  240d              move.l   a5, d2
01015c88  460b              dc.w     $460b
01015c8a  2500              move.l   d0, -(a2)
01015c8c  4719              chk.l    (a1)+, d3
01015c8e  3e01              move.w   d1, d7
01015c90  163a              dc.w     $163a

; ---- gap 01015c96..01016d3a (4261 bytes) ----
01015c96  0146              bchg.b   d0, d6
01015c98  04460146          subi.w   #$146, d6
01015c9c  0124              btst.l   d0, -(a4)
01015c9e  0124              btst.l   d0, -(a4)
01015ca0  00240d46          ori.b    #$46, -(a4)
01015ca4  0b46              bchg.b   d5, d6
01015ca6  1b15              move.b   (a5), -(a5)
01015ca8  4133193e023a38244b00  chk.l    ([$23a3824, a3], d1.l, $4b00), d0
01015cb2  0146              bchg.b   d0, d6
01015cb4  04460146          subi.w   #$146, d6
01015cb8  0124              btst.l   d0, -(a4)
01015cba  0124              btst.l   d0, -(a4)
01015cbc  00240d46          ori.b    #$46, -(a4)
01015cc0  0a154118          eori.b   #$18, (a5)
01015cc4  2d382419          move.l   $2419.w, -(a6)
01015cc8  3e02              move.w   d2, d7
01015cca  3a382434          move.w   $2434.w, d5
01015cce  001b4e4a          ori.b    #$4a, (a3)+
01015cd2  4e16              dc.w     $4e16
01015cd4  5016              addq.b   #$8, (a6)
01015cd6  4e46              trap     #$6
01015cd8  351b              move.w   (a3)+, -(a2)
01015cda  5018              addq.b   #$8, (a0)+
01015cdc  4a4e              tst.w    a6
01015cde  3716              move.w   (a6), -(a3)
01015ce0  4e1b              dc.w     $4e1b
01015ce2  293d              dc.w     $293d
01015ce4  394a3d46          move.w   a2, $3d46(a4)
01015ce8  2041              movea.l  d1, a0
01015cea  4a4e              tst.w    a6
01015cec  164e              dc.w     $164e
01015cee  501e              addq.b   #$8, (a6)+
01015cf0  37405046          move.w   d0, $5046(a3)
01015cf4  1b461b46          move.b   d6, $1b46(a5)
01015cf8  241b              move.l   (a3)+, d2
01015cfa  461b              not.b    (a3)+
01015cfc  461b              not.b    (a3)+
01015cfe  504f              addq.w   #$8, a7
01015d00  4118              chk.l    (a0)+, d0
01015d02  2d382419          move.l   $2419.w, -(a6)
01015d06  3e00              move.w   d0, d7
01015d08  1b17              move.b   (a7), -(a5)
01015d0a  3825              move.w   -(a5), d4
01015d0c  002831511b50      ori.b    #$51, $1b50(a0)
01015d12  4050              negx.w   (a0)
01015d14  4a50              tst.w    (a0)
01015d16  3c4c              movea.w  a4, a6
01015d18  29504f50          move.l   (a0), $4f50(a4)
01015d1c  3a4e              movea.w  a6, a5
01015d1e  2429454d          move.l   $454d(a1), d2
01015d22  5045              addq.w   #$8, d5
01015d24  4e504e51          link.w   a0, #$4e51
01015d28  1b513550          move.b   (a1), $3550(a5)
01015d2c  481b              nbcd.b   (a3)+
01015d2e  461b              not.b    (a3)+
01015d30  4624              not.b    -(a4)
01015d32  1b4e              dc.w     $1b4e
01015d34  29461b51          move.l   d6, $1b51(a4)
01015d38  3816              move.w   (a6), d4
01015d3a  3a382419          move.w   $2419.w, d5
01015d3e  011b              btst.l   d0, (a3)+
01015d40  00163824          ori.b    #$24, (a6)
01015d44  2800              move.l   d0, d4
01015d46  231b              move.l   (a3)+, -(a1)
01015d48  4e1b              dc.w     $4e1b
01015d4a  3116              move.w   (a6), -(a0)
01015d4c  4516              chk.l    (a6), d2
01015d4e  4d2c4734          chk.l    $4734(a4), d6
01015d52  1650              dc.w     $1650
01015d54  163a4e46          move.b   $101ab9c(pc), d3
01015d58  29464e29          move.l   d6, $4e29(a4)
01015d5c  46354628          not.b    $28(a5, d4.w)
01015d60  4e1b              dc.w     $4e1b
01015d62  3116              move.w   (a6), -(a0)
01015d64  503a              dc.w     $503a
01015d66  3848              movea.w  a0, a4
01015d68  1b331f33241f2434331b0037  move.b   ([$241f2434, a3, d1.l * 8], $331b0037), -(a5)
01015d74  3816              move.w   (a6), d4
01015d76  3a382419          move.w   $2419.w, d5
01015d7a  0316              btst.l   d1, (a6)
01015d7c  3824              move.w   -(a4), d4
01015d7e  2000              move.l   d0, d0
01015d80  003746164e00      ori.b    #$16, (a7, d4.l * 8)
01015d86  2400              move.l   d0, d2
01015d88  5000              addq.b   #$8, d0
01015d8a  474b              dc.w     $474b
01015d8c  164e              dc.w     $164e
01015d8e  163a5038          move.b   $101adc8(pc), d3
01015d92  29384629          move.l   $4629.w, -(a4)
01015d96  3829381b          move.w   $381b(a1), d4
01015d9a  4616              not.b    (a6)
01015d9c  4e00              dc.w     $4e00
01015d9e  5016              addq.b   #$8, (a6)
01015da0  3800              move.w   d0, d4
01015da2  471b              chk.l    (a3)+, d3
01015da4  271b              move.l   (a3)+, -(a3)
01015da6  4624              not.b    -(a4)
01015da8  1f15              move.b   (a5), -(a7)
01015daa  4a381640          tst.b    $1640.w
01015dae  001b1903          ori.b    #$3, (a3)+
01015db2  1638241b          move.b   $241b.w, d3
01015db6  00185046          ori.b    #$46, (a0)+
01015dba  164e              dc.w     $164e
01015dbc  00240051          ori.b    #$51, -(a4)
01015dc0  4816              nbcd.b   (a6)
01015dc2  4e16              dc.w     $4e16
01015dc4  3a50              movea.w  (a0), a5
01015dc6  41293846          chk.l    $3846(a1), d0
01015dca  29382938          move.l   $2938.w, -(a4)
01015dce  1b46164e          move.b   d6, $164e(a5)
01015dd2  00501650          ori.w    #$1650, (a0)
01015dd6  2b471b26          move.l   d7, $1b26(a5)
01015dda  3524              move.w   -(a4), -(a2)
01015ddc  1841              dc.w     $1841
01015dde  2518              move.l   (a0)+, -(a2)
01015de0  3a38164e          move.w   $164e.w, d5
01015de4  00163e03          ori.b    #$3, (a6)
01015de8  1638241b          move.b   $241b.w, d3
01015dec  00201b46          ori.b    #$46, -(a0)
01015df0  164e              dc.w     $164e
01015df2  00240050          ori.b    #$50, -(a4)
01015df6  0147              bchg.b   d0, d7
01015df8  164e              dc.w     $164e
01015dfa  163a4e46          move.b   $101ac42(pc), d3
01015dfe  29384629          move.l   $4629.w, -(a4)
01015e02  3829381b          move.w   $381b(a1), d4
01015e06  4616              not.b    (a6)
01015e08  4e00              dc.w     $4e00
01015e0a  5000              addq.b   #$8, d0
01015e0c  37481b1e          move.w   a0, $1b1e(a3)
01015e10  331e              move.w   (a6)+, -(a1)
01015e12  4323              chk.l    -(a3), d1
01015e14  1841              dc.w     $1841
01015e16  1f24              move.b   -(a4), -(a7)
01015e18  2016              move.l   (a6), d0
01015e1a  3816              move.w   (a6), d4
01015e1c  4000              negx.b   d0
01015e1e  1b19              move.b   (a1)+, -(a5)
01015e20  0316              btst.l   d1, (a6)
01015e22  3824              move.w   -(a4), d4
01015e24  1b2b241b          move.b   $241b(a3), -(a5)
01015e28  4616              not.b    (a6)
01015e2a  4e00              dc.w     $4e00
01015e2c  2400              move.l   d0, d2
01015e2e  5001              addq.b   #$8, d1
01015e30  4716              chk.l    (a6), d3
01015e32  4e16              dc.w     $4e16
01015e34  3a4e              movea.w  a6, a5
01015e36  34293846          move.w   $3846(a1), d2
01015e3a  29382938          move.l   $2938.w, -(a4)
01015e3e  1b46164e          move.b   d6, $164e(a5)
01015e42  00500148          ori.w    #$148, (a0)
01015e46  201a              move.l   (a2)+, d0
01015e48  321a              move.w   (a2)+, d1
01015e4a  43321b46          chk.l    ([a2]), d1
01015e4e  1a332416          move.b   $16(a3, d2.w), d5
01015e52  3816              move.w   (a6), d4
01015e54  3a382419          move.w   $2419.w, d5
01015e58  0316              btst.l   d1, (a6)
01015e5a  3824              move.w   -(a4), d4
01015e5c  18382420          move.b   $2420.w, d4
01015e60  4e1b              dc.w     $4e1b
01015e62  3116              move.w   (a6), -(a0)
01015e64  4516              chk.l    (a6), d2
01015e66  4d3947341b4e      chk.l    $47341b4e.l, d6
01015e6c  163a4e28          move.b   $101ac96(pc), d3
01015e70  29384629          move.l   $4629.w, -(a4)
01015e74  38284628          move.w   $4628(a0), d4
01015e78  4e1b              dc.w     $4e1b
01015e7a  3116              move.w   (a6), -(a0)
01015e7c  5016              addq.b   #$8, (a6)
01015e7e  3848              movea.w  a0, a4
01015e80  371b              move.w   (a3)+, -(a3)
01015e82  461b              not.b    (a3)+
01015e84  3a46              movea.w  d6, a5
01015e86  24341b46          move.l   ([a4]), d2
01015e8a  4b16              chk.l    (a6), d5
01015e8c  3816              move.w   (a6), d4
01015e8e  3a382419          move.w   $2419.w, d5
01015e92  0316              btst.l   d1, (a6)
01015e94  3824              move.w   -(a4), d4
01015e96  16382937          move.b   $2937.w, d3
01015e9a  511b              subq.b   #$8, (a3)+
01015e9c  5040              addq.w   #$8, d0
01015e9e  504a              addq.w   #$8, a2
01015ea0  5047              addq.w   #$8, d7
01015ea2  29504e16          move.l   (a0), $4e16(a4)
01015ea6  3a4e              movea.w  a6, a5
01015ea8  1b293846          move.b   $3846(a1), -(a5)
01015eac  29382450          move.l   $2450.w, -(a4)
01015eb0  4e511b51          link.w   a1, #$1b51
01015eb4  1650              dc.w     $1650
01015eb6  414e              dc.w     $414e
01015eb8  5040              addq.w   #$8, d0
01015eba  1841              dc.w     $1841
01015ebc  183a414e          move.b   $101a00c(pc), d4
01015ec0  2918              move.l   (a0)+, -(a4)
01015ec2  4151              dc.w     $4151
01015ec4  3816              move.w   (a6), d4
01015ec6  3a382419          move.w   $2419.w, d5
01015eca  011b              btst.l   d0, (a3)+
01015ecc  00163824          ori.b    #$24, (a6)
01015ed0  16381b40          move.b   $1b40.w, d3
01015ed4  4a4e              tst.w    a6
01015ed6  1650              dc.w     $1650
01015ed8  164e              dc.w     $164e
01015eda  46372b46          not.b    ([a7])
01015ede  1b4d              dc.w     $1b4d
01015ee0  4e16              dc.w     $4e16
01015ee2  3a4e              movea.w  a6, a5
01015ee4  1850              dc.w     $1850
01015ee6  3846              movea.w  d6, a4
01015ee8  29382429          move.l   $2429.w, -(a4)
01015eec  464a              dc.w     $464a
01015eee  4e16              dc.w     $4e16
01015ef0  4e500050          link.w   a0, #$50
01015ef4  2b24              move.l   -(a4), -(a5)
01015ef6  291b              move.l   (a3)+, -(a4)
01015ef8  1638163a          move.b   $163a.w, d3
01015efc  3846              movea.w  d6, a4
01015efe  1b16              move.b   (a6), -(a5)
01015f00  3850              movea.w  (a0), a4
01015f02  4f41              dc.w     $4f41
01015f04  182d3824          move.b   $3824(a5), d4
01015f08  19514000          move.b   (a1), $4000(a4)
01015f0c  16382416          move.b   $2416.w, d3
01015f10  380b              move.w   a3, d4
01015f12  182b0016          move.b   $16(a3), d4
01015f16  3807              move.w   d7, d4
01015f18  4602              not.b    d2
01015f1a  460b              dc.w     $460b
01015f1c  16380015          move.b   $15.w, d3
01015f20  4118              chk.l    (a0)+, d0
01015f22  2d382419          move.l   $2419.w, -(a6)
01015f26  0316              btst.l   d1, (a6)
01015f28  3824              move.w   -(a4), d4
01015f2a  010a241b          movep.w  $241b(a2), d0
01015f2e  2b00              move.l   d0, -(a5)
01015f30  16380746          move.b   $746.w, d3
01015f34  02460b18          andi.w   #$b18, d6
01015f38  2b01              move.l   d1, -(a5)
01015f3a  461b              not.b    (a3)+
01015f3c  15413319          move.b   d1, $3319(a2)
01015f40  0316              btst.l   d1, (a6)
01015f42  3824              move.w   -(a4), d4
01015f44  010a2950          movep.w  $2950(a2), d0
01015f48  01293807          btst.l   d0, $3807(a1)
01015f4c  4602              not.b    d2
01015f4e  460b              dc.w     $460b
01015f50  2902              move.l   d2, -(a4)
01015f52  2500              move.l   d0, -(a2)
01015f54  4719              chk.l    (a1)+, d3
01015f56  0316              btst.l   d1, (a6)
01015f58  504e              addq.w   #$8, a6
01015f5a  010a184b          movep.w  $184b(a2), d0
01015f5e  01290846          btst.l   d0, $846(a1)
01015f62  02460b28          andi.w   #$b28, d6
01015f66  02192200          andi.b   #$0, (a1)+
01015f6a  29381903          move.l   $1903.w, -(a4)
01015f6e  1650              dc.w     $1650
01015f70  4e01              dc.w     $4e01
01015f72  00005300          ori.b    #$0, d0
01015f76  00000000          ori.b    #$0, d0
01015f7a  01b80000          bclr.b   d0, $0.w
01015f7e  00b08e0001000200  ori.l    #$8e000100, (a0, d0.w * 2)
01015f86  0300              btst.l   d1, d0
01015f88  04000500          subi.b   #$0, d0
01015f8c  06001000          addi.b   #$0, d0
01015f90  4e00              dc.w     $4e00
01015f92  5900              subq.b   #$4, d0
01015f94  6d01              blt.b    $1015f97
01015f96  0102              btst.l   d0, d2
01015f98  0103              btst.l   d0, d3
01015f9a  0105              btst.l   d0, d5
01015f9c  0106              btst.l   d0, d6
01015f9e  0107              btst.l   d0, d7
01015fa0  01080109          movep.w  $109(a0), d0
01015fa4  010a010b          movep.w  $10b(a2), d0
01015fa8  010f0116          movep.w  $116(a7), d0
01015fac  011b              btst.l   d0, (a3)+
01015fae  011f              btst.l   d0, (a7)+
01015fb0  012f013f          btst.l   d0, $13f(a7)
01015fb4  0140              bchg.b   d0, d0
01015fb6  0143              bchg.b   d0, d3
01015fb8  0150              bchg.b   d0, (a0)
01015fba  0155              bchg.b   d0, (a5)
01015fbc  0155              bchg.b   d0, (a5)
01015fbe  02550355          andi.w   #$355, (a5)
01015fc2  04550555          subi.w   #$555, (a5)
01015fc6  06550755          addi.w   #$755, (a5)
01015fca  0855              dc.w     $0855
01015fcc  0955              bchg.b   d4, (a5)
01015fce  0a550b55          eori.w   #$b55, (a5)
01015fd2  0c550d55          cmpi.w   #$d55, (a5)
01015fd6  0e55              dc.w     $0e55
01015fd8  0f55              bchg.b   d7, (a5)
01015fda  1055              dc.w     $1055
01015fdc  15551655          move.b   (a5), $1655(a2)
01015fe0  17551855          move.b   (a5), $1855(a3)
01015fe4  4655              not.w    (a5)
01015fe6  4755              dc.w     $4755
01015fe8  4855              pea.l    (a5)
01015fea  4955              dc.w     $4955
01015fec  4a55              tst.w    (a5)
01015fee  4b55              dc.w     $4b55
01015ff0  4c55              dc.w     $4c55
01015ff2  4d55              dc.w     $4d55
01015ff4  4e554f55          link.w   a5, #$4f55
01015ff8  5055              addq.w   #$8, (a5)
01015ffa  5155              subq.w   #$8, (a5)
01015ffc  5255              addq.w   #$1, (a5)
01015ffe  5355              subq.w   #$1, (a5)
01016000  5455              addq.w   #$2, (a5)
01016002  5555              subq.w   #$2, (a5)
01016004  5655              addq.w   #$3, (a5)
01016006  5755              subq.w   #$3, (a5)
01016008  5855              addq.w   #$4, (a5)
0101600a  5955              subq.w   #$4, (a5)
0101600c  5e55              addq.w   #$7, (a5)
0101600e  5f55              subq.w   #$7, (a5)
01016010  6055              bra.b    $1016067
01016012  6c56              bge.b    $101606a
01016014  0157              bchg.b   d0, (a7)
01016016  015b              bchg.b   d0, (a3)+
01016018  015b              bchg.b   d0, (a3)+
0101601a  025f0161          andi.w   #$161, (a7)+
0101601e  016a016f          bchg.b   d0, $16f(a2)
01016022  017e              dc.w     $017e
01016024  017f              dc.w     $017f
01016026  0180              bclr.b   d0, d0
01016028  0185              bclr.b   d0, d5
0101602a  0186              bclr.b   d0, d6
0101602c  0187              bclr.b   d0, d7
0101602e  018a018b          movep.w  d0, $18b(a2)
01016032  0190              bclr.b   d0, (a0)
01016034  0195              bclr.b   d0, (a5)
01016036  0196              bclr.b   d0, (a6)
01016038  0197              bclr.b   d0, (a7)
0101603a  019b              bclr.b   d0, (a3)+
0101603c  019f              bclr.b   d0, (a7)+
0101603e  01a1              bclr.b   d0, -(a1)
01016040  01a4              bclr.b   d0, -(a4)
01016042  01a5              bclr.b   d0, -(a5)
01016044  01a901aa          bclr.b   d0, $1aa(a1)
01016048  05aa11aa          bclr.b   d2, $11aa(a2)
0101604c  4eaa59aa          jsr      $59aa(a2)
01016050  6caf              bge.b    $1016001
01016052  01be              dc.w     $01be
01016054  01bf              dc.w     $01bf
01016056  01c0              bset.b   d0, d0
01016058  01d0              bset.b   d0, (a0)
0101605a  01d3              bset.b   d0, (a3)
0101605c  01d5              bset.b   d0, (a5)
0101605e  01d6              bset.b   d0, (a6)
01016060  01e0              bset.b   d0, -(a0)
01016062  01e4              bset.b   d0, -(a4)
01016064  01e5              bset.b   d0, -(a5)
01016066  01e6              bset.b   d0, -(a6)
01016068  01ef01f0          bset.b   d0, $1f0(a7)
0101606c  01f401f501f601f8  bset.b   d0, ([$1f601f8])            ; $01f601f8 = ROM
01016074  01f901fb01fc      bset.b   d0, $1fb01fc.l              ; $01fb01fc = ROM
0101607a  01fd              dc.w     $01fd
0101607c  01fe              dc.w     $01fe
0101607e  01ff              dc.w     $01ff
01016080  01ff              dc.w     $01ff
01016082  02ff              dc.w     $02ff
01016084  03ff              dc.w     $03ff
01016086  04ff              dc.w     $04ff
01016088  05ff              dc.w     $05ff
0101608a  06ff              dc.w     $06ff
0101608c  07ff              dc.w     $07ff
0101608e  08ff              dc.w     $08ff
01016090  09ff              dc.w     $09ff
01016092  0aff              dc.w     $0aff
01016094  0bff              dc.w     $0bff
01016096  0cff              dc.w     $0cff
01016098  0dff              dc.w     $0dff
0101609a  6dff6e090c09      blt.l    $6f0a6ca5
010160a0  1409              dc.w     $1409
010160a2  180a              dc.w     $180a
010160a4  48680a48          pea.l    $a48(a0)
010160a8  680a              bvc.b    $10160b4
010160aa  48680a48          pea.l    $a48(a0)
010160ae  680a              bvc.b    $10160ba
010160b0  48680a48          pea.l    $a48(a0)
010160b4  680a              bvc.b    $10160c0
010160b6  48680a48          pea.l    $a48(a0)
010160ba  680a              bvc.b    $10160c6
010160bc  48680a30          pea.l    $a30(a0)
010160c0  6e3e              bgt.b    $1016100
010160c2  680a              bvc.b    $10160ce
010160c4  2f50723e          move.l   (a0), $723e(a7)
010160c8  680a              bvc.b    $10160d4
010160ca  2e49              movea.l  a1, a7
010160cc  7f77              dc.w     $7f77
010160ce  3e680a2e          movea.w  $a2e(a0), a7
010160d2  507f              dc.w     $507f
010160d4  7a3e              moveq    #$3e, d5
010160d6  680a              bvc.b    $10160e2
010160d8  2d49807d          move.l   a1, -$7f83(a6)
010160dc  3e680a1f          movea.w  $a1f(a0), a7
010160e0  6462              bcc.b    $1016144
010160e2  5080              addq.l   #$8, d0
010160e4  7e4f              moveq    #$4f, d7
010160e6  6561              bcs.b    $1016149
010160e8  1f680a1f5306      move.b   $a1f(a0), $5306(a7)
010160ee  15821a07          move.b   d2, $7(a2, d1.l)
010160f2  0a1f680a          eori.b   #$a, (a7)+
010160f6  1f542c50          move.b   (a4), $2c50(a7)
010160fa  825a              or.w     (a2)+, d1
010160fc  394e1f68          move.w   a6, $1f68(a4)
01016100  0a1f542b          eori.b   #$2b, (a7)+
01016104  4983              chk.w    d3, d4
01016106  6e39              bgt.b    $1016141
01016108  4e1f              dc.w     $4e1f
0101610a  680a              bvc.b    $1016116
0101610c  1f542b50          move.b   (a4), $2b50(a7)
01016110  8372394e          or.w     d1, ([a2])
01016114  1f680a1f542a      move.b   $a1f(a0), $542a(a7)
0101611a  4984              chk.w    d4, d4
0101611c  7739              dc.w     $7739
0101611e  4e1f              dc.w     $4e1f
01016120  680a              bvc.b    $101612c
01016122  1f542a50          move.b   (a4), $2a50(a7)
01016126  7f72              dc.w     $7f72
01016128  000d              dc.w     $000d
0101612a  6a7f              bpl.b    $10161ab
0101612c  7a39              moveq    #$39, d5
0101612e  4e1f              dc.w     $4e1f
01016130  680a              bvc.b    $101613c
01016132  1f542949          move.b   (a4), $2949(a7)
01016136  7f7d              dc.w     $7f7d
01016138  020f              dc.w     $020f
0101613a  7f7d              dc.w     $7f7d
0101613c  394e1f68          move.w   a6, $1f68(a4)
01016140  0a1f5429          eori.b   #$29, (a7)+
01016144  507f              dc.w     $507f
01016146  6c03              bge.b    $101614b
01016148  527e              dc.w     $527e
0101614a  394e1f68          move.w   a6, $1f68(a4)
0101614e  0a1f5428          eori.b   #$28, (a7)+
01016152  497f              dc.w     $497f
01016154  7e04              moveq    #$4, d7
01016156  147f              dc.w     $147f
01016158  394e1f68          move.w   a6, $1f68(a4)
0101615c  0a1f5428          eori.b   #$28, (a7)+
01016160  507f              dc.w     $507f
01016162  7604              moveq    #$4, d3
01016164  0b7f              dc.w     $0b7f
01016166  5a384e1f          addq.b   #$5, $4e1f.w
0101616a  680a              bvc.b    $1016176
0101616c  1f542749          move.b   (a4), $2749(a7)
01016170  8070011d          or.w     ([a0], d0.w), d0
01016174  1a01              move.b   d1, d5
01016176  6a6e              bpl.b    $10161e6
01016178  384e              movea.w  a6, a4
0101617a  1f680a1f5427      move.b   $a1f(a0), $5427(a7)
01016180  5080              addq.l   #$8, d0
01016182  1a00              move.b   d0, d5
01016184  17801a00          move.b   d0, (a3, d1.l * 2)
01016188  1872              dc.w     $1872
0101618a  384e              movea.w  a6, a4
0101618c  1f680a1f5426      move.b   $a1f(a0), $5426(a7)
01016192  4980              chk.w    d0, d4
01016194  7e00              moveq    #$0, d7
01016196  0a8176001377      eori.l   #$76001377, d1
0101619c  384e              movea.w  a6, a4
0101619e  1f680a1f5426      move.b   $a1f(a0), $5426(a7)
010161a4  5080              addq.l   #$8, d0
010161a6  7c00              moveq    #$0, d6
010161a8  0f81              bclr.b   d7, d1
010161aa  7d00              dc.w     $7d00
010161ac  0c7a384e1f68      cmpi.w   #$384e, $1018116(pc)
010161b2  0a1f5425          eori.b   #$25, (a7)+
010161b6  4981              chk.w    d1, d4
010161b8  7600              moveq    #$0, d3
010161ba  1782000a          move.b   d2, $a(a3, d0.w)
010161be  7d38              dc.w     $7d38
010161c0  4e1f              dc.w     $4e1f
010161c2  680a              bvc.b    $10161ce
010161c4  1f542550          move.b   (a4), $2550(a7)
010161c8  81750052          or.w     d0, $52(a5, d0.w)
010161cc  8179017e384e      or.w     d0, $17e384e.l              ; $017e384e = ROM
010161d2  1f680a1f5424      move.b   $a1f(a0), $5424(a7)
010161d8  4982              chk.w    d2, d4
010161da  6c008253          bge.w    $100e42f
010161de  016a384e          bchg.b   d0, $384e(a2)
010161e2  1f680a1f5424      move.b   $a1f(a0), $5424(a7)
010161e8  5082              addq.l   #$8, d2
010161ea  6b0b              bmi.b    $10161f7
010161ec  817c              dc.w     $817c
010161ee  0113              btst.l   d0, (a3)
010161f0  7f5a              dc.w     $7f5a
010161f2  374e1f68          move.w   a6, $1f68(a3)
010161f6  0a1f5423          eori.b   #$23, (a7)+
010161fa  4980              chk.w    d0, d4
010161fc  6d80              blt.b    $101617e
010161fe  530c              dc.w     $530c
01016200  8153              or.w     d0, (a3)
01016202  0180              bclr.b   d0, d0
01016204  6e37              bgt.b    $101623d
01016206  4e1f              dc.w     $4e1f
01016208  680a              bvc.b    $1016214
0101620a  1f542350          move.b   (a4), $2350(a7)
0101620e  7f7d              dc.w     $7f7d
01016210  0b80              bclr.b   d5, d0
01016212  1a0f              dc.w     $1a0f
01016214  807901138072      or.w     $1138072.l, d0              ; $01138072 = ROM
0101621a  374e1f68          move.w   a6, $1f68(a3)
0101621e  0a1f5422          eori.b   #$22, (a7)+
01016222  4980              chk.w    d0, d4
01016224  7000              moveq    #$0, d0
01016226  801a              or.b     (a2)+, d0
01016228  1480              move.b   d0, (a2)
0101622a  6b01              bmi.b    $101622d
0101622c  6a80              bpl.b    $10161ae
0101622e  7737              dc.w     $7737
01016230  4e1f              dc.w     $4e1f
01016232  680a              bvc.b    $101623e
01016234  1f542250          move.b   (a4), $2250(a7)
01016238  8079006a7f00      or.w     $6a7f00.l, d0               ; $006a7f00 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101623e  147f              dc.w     $147f
01016240  7901              dc.w     $7901
01016242  1481              move.b   d1, (a2)
01016244  7a37              moveq    #$37, d5
01016246  4e1f              dc.w     $4e1f
01016248  680a              bvc.b    $1016254
0101624a  1f542149          move.b   (a4), $2149(a7)
0101624e  817c              dc.w     $817c
01016250  00197f00          ori.b    #$0, (a1)+
01016254  147f              dc.w     $147f
01016256  5301              subq.b   #$1, d1
01016258  6a7f              bpl.b    $10162d9
0101625a  6e4d              bgt.b    $10162a9
0101625c  7d37              dc.w     $7d37
0101625e  4e1f              dc.w     $4e1f
01016260  680a              bvc.b    $101626c
01016262  1f542150          move.b   (a4), $2150(a7)
01016266  817e              dc.w     $817e
01016268  00187f00          ori.b    #$0, (a0)+
0101626c  1479              dc.w     $1479
0101626e  0113              btst.l   d0, (a3)
01016270  806b147e          or.w     $147e(a3), d0
01016274  374e1f68          move.w   a6, $1f68(a3)
01016278  0a1f5420          eori.b   #$20, (a7)+
0101627c  4983              chk.w    d3, d4
0101627e  00147f00          ori.b    #$0, (a4)
01016282  146b              dc.w     $146b
01016284  016a806b          bchg.b   d0, -$7f95(a2)
01016288  147f              dc.w     $147f
0101628a  374e1f68          move.w   a6, $1f68(a3)
0101628e  0a1f5420          eori.b   #$20, (a7)+
01016292  5083              addq.l   #$8, d3
01016294  5313              subq.b   #$1, (a3)
01016296  7f00              dc.w     $7f00
01016298  1001              move.b   d1, d0
0101629a  13816b14          move.b   d1, (a1, d6.l * 2)
0101629e  7f5a              dc.w     $7f5a
010162a0  364e              movea.w  a6, a3
010162a2  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010162a8  4984              chk.w    d4, d4
010162aa  6b0c              bmi.b    $10162b8
010162ac  7f03              dc.w     $7f03
010162ae  6a81              bpl.b    $1016231
010162b0  5314              subq.b   #$1, (a4)
010162b2  7f6e              dc.w     $7f6e
010162b4  364e              movea.w  a6, a3
010162b6  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010162bc  5084              addq.l   #$8, d4
010162be  700b              moveq    #$b, d0
010162c0  7f1a              dc.w     $7f1a
010162c2  0113              btst.l   d0, (a3)
010162c4  821a              or.b     (a2)+, d1
010162c6  177f              dc.w     $177f
010162c8  7236              moveq    #$36, d1
010162ca  4e1f              dc.w     $4e1f
010162cc  680a              bvc.b    $10162d8
010162ce  1f541e49          move.b   (a4), $1e49(a7)
010162d2  8575007f          or.w     d2, $7f(a5, d0.w)
010162d6  1a01              move.b   d1, d5
010162d8  6a82              bpl.b    $101625c
010162da  00177f77          ori.b    #$77, (a7)
010162de  364e              movea.w  a6, a3
010162e0  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
010162e6  5085              addq.l   #$8, d5
010162e8  7900              dc.w     $7900
010162ea  6a53              bpl.b    $101633f
010162ec  0013827e          ori.b    #$7e, (a3)
010162f0  00187f7a          ori.b    #$7a, (a0)+
010162f4  364e              movea.w  a6, a3
010162f6  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
010162fc  4986              chk.w    d6, d4
010162fe  7c00              moveq    #$0, d6
01016300  196b006a827c      move.b   $6a(a3), -$7d84(a4)
01016306  00197f7d          ori.b    #$7d, (a1)+
0101630a  364e              movea.w  a6, a3
0101630c  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
01016312  4d86              chk.w    d6, d6
01016314  7e00              moveq    #$0, d7
01016316  186c              dc.w     $186c
01016318  0b83              bclr.b   d5, d3
0101631a  7600              moveq    #$0, d3
0101631c  527f              dc.w     $527f
0101631e  7e36              moveq    #$36, d7
01016320  4e1f              dc.w     $4e1f
01016322  680a              bvc.b    $101632e
01016324  1f541d4b          move.b   (a4), $1d4b(a7)
01016328  7d6a              dc.w     $7d6a
0101632a  8500              sbcd.b   d0, d2
0101632c  1475              dc.w     $1475
0101632e  008375008136      ori.l    #$75008136, d3
01016334  4e1f              dc.w     $4e1f
01016336  680a              bvc.b    $1016342
01016338  1f541d5c          move.b   (a4), $1d5c(a7)
0101633c  7e0b              moveq    #$b, d7
0101633e  8553              or.w     d2, (a3)
01016340  13760019826b      move.b   $19(a6, d0.w), -$7d95(a1)
01016346  0b81              bclr.b   d5, d1
01016348  5a354e1f          addq.b   #$5, $1f(a5, d4.l)
0101634c  680a              bvc.b    $1016358
0101634e  1f541d6f          move.b   (a4), $1d6f(a7)
01016352  7f00              dc.w     $7f00
01016354  13846b0c          move.b   d4, (a1, d6.l * 2)
01016358  7c00              moveq    #$0, d6
0101635a  1482              move.b   d2, (a2)
0101635c  000c              dc.w     $000c
0101635e  816e354e          or.w     d0, $354e(a6)
01016362  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
01016368  727f              moveq    #$7f, d1
0101636a  5300              subq.b   #$1, d0
0101636c  1683              move.b   d3, (a3)
0101636e  700b              moveq    #$b, d0
01016370  7f00              dc.w     $7f00
01016372  0b81              bclr.b   d5, d1
01016374  7600              moveq    #$0, d3
01016376  1480              move.b   d0, (a2)
01016378  7472              moveq    #$72, d2
0101637a  354e1f68          move.w   a6, $1f68(a2)
0101637e  0a1f5449          eori.b   #$49, (a7)+
01016382  776a              dc.w     $776a
01016384  6b01              bmi.b    $1016387
01016386  1682              move.b   d2, (a3)
01016388  7500              dc.w     $7500
0101638a  7f53              dc.w     $7f53
0101638c  00188053          ori.b    #$53, (a0)+
01016390  00197f7e          ori.b    #$7e, (a1)+
01016394  1477              dc.w     $1477
01016396  354e1f68          move.w   a6, $1f68(a2)
0101639a  0a1f544a          eori.b   #$4a, (a7)+
0101639e  7a52              moveq    #$52, d5
010163a0  7002              moveq    #$2, d0
010163a2  1881              move.b   d1, (a4)
010163a4  7900              dc.w     $7900
010163a6  6a70              bpl.b    $1016418
010163a8  000a              dc.w     $000a
010163aa  6a71              bpl.b    $101641d
010163ac  0180              bclr.b   d0, d0
010163ae  7013              moveq    #$13, d0
010163b0  7a35              moveq    #$35, d5
010163b2  4e1f              dc.w     $4e1f
010163b4  680a              bvc.b    $10163c0
010163b6  1f544b7d          move.b   (a4), $4b7d(a7)
010163ba  50750350          addq.w   #$8, (a5, invalid.w)
010163be  807c0019          or.w     #$19, d0
010163c2  7904              dc.w     $7904
010163c4  0c7f              dc.w     $0c7f
010163c6  7e00              moveq    #$0, d7
010163c8  0c7d              dc.w     $0c7d
010163ca  354e1f68          move.w   a6, $1f68(a2)
010163ce  0a1f544b          eori.b   #$4b, (a7)+
010163d2  7e4d              moveq    #$4d, d7
010163d4  7904              dc.w     $7904
010163d6  6a7f              bpl.b    $1016457
010163d8  7e00              moveq    #$0, d7
010163da  187e              dc.w     $187e
010163dc  04147f70          subi.b   #$70, (a4)
010163e0  000b              dc.w     $000b
010163e2  7e35              moveq    #$35, d7
010163e4  4e1f              dc.w     $4e1f
010163e6  680a              bvc.b    $10163f2
010163e8  1f544d7f          move.b   (a4), $4d7f(a7)
010163ec  4b7c              dc.w     $4b7c
010163ee  040b              dc.w     $040b
010163f0  8000              or.b     d0, d0
010163f2  147f              dc.w     $147f
010163f4  6c03              bge.b    $10163f9
010163f6  6a7e              bpl.b    $1016476
010163f8  010b7f35          movep.w  $7f35(a3), d0
010163fc  4e1f              dc.w     $4e1f
010163fe  680a              bvc.b    $101640a
01016400  1f544d7f          move.b   (a4), $4d7f(a7)
01016404  5c7e              dc.w     $5c7e
01016406  0011030e          ori.b    #$e, (a1)
0101640a  7f53              dc.w     $7f53
0101640c  137f              dc.w     $137f
0101640e  7d02              dc.w     $7d02
01016410  0f7f              dc.w     $0f7f
01016412  7001              moveq    #$1, d0
01016414  187f              dc.w     $187f
01016416  5a344e1f          addq.b   #$5, $1f(a4, d4.l)
0101641a  680a              bvc.b    $1016426
0101641c  1f54507f          move.b   (a4), $507f(a7)
01016420  6f7f              ble.b    $10164a1
01016422  00137a03          ori.b    #$3, (a3)
01016426  0e6b              dc.w     $0e6b
01016428  0c8072000e6a      cmpi.l   #$72000e6a, d0
0101642e  7e01              moveq    #$1, d7
01016430  0b80              bclr.b   d5, d0
01016432  6e34              bgt.b    $1016468
01016434  4e1f              dc.w     $4e1f
01016436  680a              bvc.b    $1016442
01016438  1f54507f          move.b   (a4), $507f(a7)
0101643c  727f              moveq    #$7f, d1
0101643e  530c              dc.w     $530c
01016440  7f7a              dc.w     $7f7a
01016442  040b              dc.w     $040b
01016444  84700118          or.w     (a0, d0.w), d2
01016448  8072344e          or.w     $4e(a2, d3.w), d0
0101644c  1f680a1f5452      move.b   $a1f(a0), $5452(a7)
01016452  7f77              dc.w     $7f77
01016454  6a6b              bpl.b    $10164c1
01016456  0b80              bclr.b   d5, d0
01016458  7604              moveq    #$4, d3
0101645a  837e              dc.w     $837e
0101645c  010b8177          movep.w  -$7e89(a3), d0
01016460  344e              movea.w  a6, a2
01016462  1f680a1f5452      move.b   $a1f(a0), $5452(a7)
01016468  7f7a              dc.w     $7f7a
0101646a  52700081          addq.w   #$1, -$7f(a0, d0.w)
0101646e  7103              dc.w     $7103
01016470  6a82              bpl.b    $10163f4
01016472  7001              moveq    #$1, d0
01016474  1881              move.b   d1, (a4)
01016476  7a34              moveq    #$34, d5
01016478  4e1f              dc.w     $4e1f
0101647a  680a              bvc.b    $1016486
0101647c  1f546a7f          move.b   (a4), $6a7f(a7)
01016480  7d50              dc.w     $7d50
01016482  7500              dc.w     $7500
01016484  6a81              bpl.b    $1016407
01016486  6c02              bge.b    $101648a
01016488  19817e01          move.b   d1, $1(a4, d7.l)
0101648c  0b82              bclr.b   d5, d2
0101648e  7d34              dc.w     $7d34
01016490  4e1f              dc.w     $4e1f
01016492  680a              bvc.b    $101649e
01016494  1f546a7f          move.b   (a4), $6a7f(a7)
01016498  7e4d              moveq    #$4d, d7
0101649a  7900              dc.w     $7900
0101649c  19825901          move.b   d2, ([a4, d5.l])
010164a0  1881              move.b   d1, (a4)
010164a2  7001              moveq    #$1, d0
010164a4  1482              move.b   d2, (a2)
010164a6  7e34              moveq    #$34, d7
010164a8  4e1f              dc.w     $4e1f
010164aa  680a              bvc.b    $10164b6
010164ac  1f54814b          move.b   (a4), -$7eb5(a7)
010164b0  7c00              moveq    #$0, d6
010164b2  1883              move.b   d3, (a4)
010164b4  5900              subq.b   #$4, d0
010164b6  1480              move.b   d0, (a2)
010164b8  7e02              moveq    #$2, d7
010164ba  1483              move.b   d3, (a2)
010164bc  344e              movea.w  a6, a2
010164be  1f680a1f5581      move.b   $a1f(a0), $5581(a7)
010164c4  5c7e              dc.w     $5c7e
010164c6  00148459          ori.b    #$59, (a4)
010164ca  13807002          move.b   d0, $2(a1, d7.w)
010164ce  13835a33          move.b   d3, $33(a1, d5.l)
010164d2  4e1f              dc.w     $4e1f
010164d4  680a              bvc.b    $10164e0
010164d6  1f55816f          move.b   (a5), -$7e91(a7)
010164da  7f00              dc.w     $7f00
010164dc  13851b7f7e010a6b  move.b   d5, ([$7e010a6b, a1])
010164e4  0c836e334e1f      cmpi.l   #$6e334e1f, d3
010164ea  680a              bvc.b    $10164f6
010164ec  1f568172          move.b   (a6), -$7e8e(a7)
010164f0  7f53              dc.w     $7f53
010164f2  0c8770011870      cmpi.l   #$70011870, d7
010164f8  0b83              bclr.b   d5, d3
010164fa  7233              moveq    #$33, d1
010164fc  4e1f              dc.w     $4e1f
010164fe  680a              bvc.b    $101650a
01016500  1f568177          move.b   (a6), -$7e89(a7)
01016504  6a6b              bpl.b    $1016571
01016506  0b87              bclr.b   d5, d7
01016508  5300              subq.b   #$1, d0
0101650a  0b7f              dc.w     $0b7f
0101650c  7500              dc.w     $7500
0101650e  8377334e          or.w     d1, ([a7])
01016512  1f680a1f5881      move.b   $a1f(a0), $5881(a7)
01016518  7a52              moveq    #$52, d5
0101651a  7000              moveq    #$0, d0
0101651c  857b              dc.w     $857b
0101651e  7f6b              dc.w     $7f6b
01016520  00187f79          ori.b    #$79, (a0)+
01016524  006a827a334e      ori.w    #$827a, $334e(a2)
0101652a  1f680a1f5881      move.b   $a1f(a0), $5881(a7)
01016530  7d50              dc.w     $7d50
01016532  7500              dc.w     $7500
01016534  6a84              bpl.b    $10164ba
01016536  754d              dc.w     $754d
01016538  6c0b              bge.b    $1016545
0101653a  807c0019          or.w     #$19, d0
0101653e  827d              dc.w     $827d
01016540  334e1f68          move.w   a6, $1f68(a1)
01016544  0a1f5e81          eori.b   #$81, (a7)+
01016548  7e4d              moveq    #$4d, d7
0101654a  7900              dc.w     $7900
0101654c  19846c0b          move.b   d4, $b(a4, d6.l)
01016550  7518              dc.w     $7518
01016552  807e              dc.w     $807e
01016554  0018827e          ori.b    #$7e, (a0)+
01016558  334e1f68          move.w   a6, $1f68(a1)
0101655c  0a1f4d82          eori.b   #$82, (a7)+
01016560  4b7c              dc.w     $4b7c
01016562  0018846b          ori.b    #$6b, (a0)+
01016566  0c7982001483334e  cmpi.w   #$8200, $1483334e.l         ; $1483334e = RAM MWF mirrors (non-Turbo mono only)
0101656e  1f680a1f5082      move.b   $a1f(a0), $5082(a7)
01016574  5c7e              dc.w     $5c7e
01016576  0014846b          ori.b    #$6b, (a4)
0101657a  0c835313835a      cmpi.l   #$5313835a, d3
01016580  324e              movea.w  a6, a1
01016582  1f680a1f5082      move.b   $a1f(a0), $5082(a7)
01016588  6f7f              ble.b    $1016609
0101658a  00138453          ori.b    #$53, (a3)
0101658e  0f83              bclr.b   d7, d3
01016590  6b0c              bmi.b    $101659e
01016592  836e324e          or.w     d1, $324e(a6)
01016596  1f680a1f5282      move.b   $a1f(a0), $5282(a7)
0101659c  727f              moveq    #$7f, d1
0101659e  530c              dc.w     $530c
010165a0  841a              or.b     (a2)+, d2
010165a2  1383700b          move.b   d3, $b(a1, d7.w)
010165a6  8372324e          or.w     d1, $4e(a2, d3.w)
010165aa  1f680a1f6a82      move.b   $a1f(a0), $6a82(a7)
010165b0  776a              dc.w     $776a
010165b2  6b0b              bmi.b    $10165bf
010165b4  8400              or.b     d0, d2
010165b6  1483              move.b   d3, (a2)
010165b8  7500              dc.w     $7500
010165ba  8377324e          or.w     d1, $4e(a7, d3.w)
010165be  1f680a1f6a82      move.b   $a1f(a0), $6a82(a7)
010165c4  7a52              moveq    #$52, d5
010165c6  7000              moveq    #$0, d0
010165c8  837e              dc.w     $837e
010165ca  00178379          ori.b    #$79, (a7)
010165ce  006a827a324e      ori.w    #$827a, $324e(a2)
010165d4  1f680a1f837d      move.b   $a1f(a0), -$7c83(a7)
010165da  5075006a          addq.w   #$8, $6a(a5, d0.w)
010165de  827d              dc.w     $827d
010165e0  0018837c          ori.b    #$7c, (a0)+
010165e4  0019827d          ori.b    #$7d, (a1)+
010165e8  324e              movea.w  a6, a1
010165ea  1f680a1e4983      move.b   $a1e(a0), $4983(a7)
010165f0  7e4d              moveq    #$4d, d7
010165f2  7913              dc.w     $7913
010165f4  837c              dc.w     $837c
010165f6  0019837e          ori.b    #$7e, (a1)+
010165fa  0018827e          ori.b    #$7e, (a0)+
010165fe  324e              movea.w  a6, a1
01016600  1f680a1e4984      move.b   $a1e(a0), $4984(a7)
01016606  4b7c              dc.w     $4b7c
01016608  6a83              bpl.b    $101658d
0101660a  7900              dc.w     $7900
0101660c  5284              addq.l   #$1, d4
0101660e  00148332          ori.b    #$32, (a4)
01016612  4e1f              dc.w     $4e1f
01016614  680a              bvc.b    $1016620
01016616  1e4a              dc.w     $1e4a
01016618  845c              or.w     (a4)+, d2
0101661a  8576006a          or.w     d2, $6a(a6, d0.w)
0101661e  8453              or.w     (a3), d2
01016620  13835a31          move.b   d3, $31(a1, d5.l)
01016624  4e1f              dc.w     $4e1f
01016626  680a              bvc.b    $1016632
01016628  1e4a              dc.w     $1e4a
0101662a  846f8575          or.w     -$7a8b(a7), d2
0101662e  00856b0c836e      ori.l    #$6b0c836e, d5
01016634  314e1f68          move.w   a6, $1f68(a0)
01016638  0a1e4b84          eori.b   #$84, (a6)+
0101663c  727f              moveq    #$7f, d1
0101663e  7950              dc.w     $7950
01016640  82700a85          or.w     -$7b(a0, d0.l), d1
01016644  700b              moveq    #$b, d0
01016646  8372314e          or.w     d1, ([a2])
0101664a  1f680a1e4b84      move.b   $a1e(a0), $4b84(a7)
01016650  776a              dc.w     $776a
01016652  760a              moveq    #$a, d3
01016654  6a81              bpl.b    $10165d7
01016656  6c0b              bge.b    $1016663
01016658  85750083          or.w     d2, -$7d(a5, d0.w)
0101665c  7231              moveq    #$31, d1
0101665e  4e1f              dc.w     $4e1f
01016660  680a              bvc.b    $101666c
01016662  1e4d              dc.w     $1e4d
01016664  847a5275          or.w     $101b8db(pc), d2
01016668  000e              dc.w     $000e
0101666a  816b0c85          or.w     d0, $c85(a3)
0101666e  7900              dc.w     $7900
01016670  6a82              bpl.b    $10165f4
01016672  5a314e1f          addq.b   #$5, $1f(a1, d4.l)
01016676  680a              bvc.b    $1016682
01016678  1e4d              dc.w     $1e4d
0101667a  847d              dc.w     $847d
0101667c  507001168053      addq.w   #$8, ([a0], d0.w, $8053)
01016682  0f85              bclr.b   d7, d5
01016684  7c00              moveq    #$0, d6
01016686  19817a32          move.b   d1, $32(a4, d7.l)
0101668a  4e1f              dc.w     $4e1f
0101668c  680a              bvc.b    $1016698
0101668e  1e50              dc.w     $1e50
01016690  847e              dc.w     $847e
01016692  4d6c              dc.w     $4d6c
01016694  02507f1a          andi.w   #$7f1a, (a0)
01016698  13857e00          move.b   d5, (a1, d7.l * 8)
0101669c  1881              move.b   d1, (a4)
0101669e  5a324e1f          addq.b   #$5, $1f(a2, d4.l)
010166a2  680a              bvc.b    $10166ae
010166a4  1e52              dc.w     $1e52
010166a6  854b7102          pack     -(a3), -(a2), #$7102
010166aa  0a6a00148600      eori.w   #$14, -$7a00(a2)
010166b0  1480              move.b   d0, (a2)
010166b2  7a49              moveq    #$49, d5
010166b4  5a314e1f          addq.b   #$5, $1f(a1, d4.l)
010166b8  680a              bvc.b    $10166c4
010166ba  1e52              dc.w     $1e52
010166bc  855c              or.w     d2, (a4)+
010166be  7f59              dc.w     $7f59
010166c0  020d              dc.w     $020d
010166c2  00178653          ori.b    #$53, (a7)
010166c6  13805a50          move.b   d0, $50(a1, d5.l)
010166ca  324e              movea.w  a6, a1
010166cc  1f680a1e5085      move.b   $a1e(a0), $5085(a7)
010166d2  6f7f              ble.b    $1016753
010166d4  7e1a              moveq    #$1a, d7
010166d6  0318              btst.l   d1, (a0)+
010166d8  866b0c7f          or.w     $c7f(a3), d3
010166dc  7a49              moveq    #$49, d5
010166de  7e32              moveq    #$32, d7
010166e0  4e1f              dc.w     $4e1f
010166e2  680a              bvc.b    $10166ee
010166e4  1e4d              dc.w     $1e4d
010166e6  8572807a          or.w     d2, $7a(a2, a0.w)
010166ea  0316              btst.l   d1, (a6)
010166ec  8670187f          or.w     $7f(a0, d1.l), d3
010166f0  5a50              addq.w   #$5, (a0)
010166f2  7d32              dc.w     $7d32
010166f4  4e1f              dc.w     $4e1f
010166f6  680a              bvc.b    $1016702
010166f8  1e4b              dc.w     $1e4b
010166fa  85776a80          or.w     d2, -$80(a7, d6.l)
010166fe  7103              dc.w     $7103
01016700  5085              addq.l   #$8, d5
01016702  787f              moveq    #$7f, d4
01016704  7a49              moveq    #$49, d5
01016706  7f7a              dc.w     $7f7a
01016708  324e              movea.w  a6, a1
0101670a  1f680a1e4a85      move.b   $a1e(a0), $4a85(a7)
01016710  7a52              moveq    #$52, d5
01016712  8159              or.w     d0, (a1)+
01016714  020a              dc.w     $020a
01016716  6a86              bpl.b    $101669e
01016718  5a50              addq.w   #$5, (a0)
0101671a  7f77              dc.w     $7f77
0101671c  324e              movea.w  a6, a1
0101671e  1f680a1e4985      move.b   $a1e(a0), $4985(a7)
01016724  7d50              dc.w     $7d50
01016726  817e              dc.w     $817e
01016728  1a02              move.b   d2, d5
0101672a  0e85              dc.w     $0e85
0101672c  7a49              moveq    #$49, d5
0101672e  8072324e          or.w     $4e(a2, d3.w), d0
01016732  1f680a1f857e      move.b   $a1f(a0), -$7a82(a7)
01016738  4d82              chk.w    d2, d6
0101673a  6b03              bmi.b    $101673f
0101673c  1684              move.b   d4, (a3)
0101673e  5a50              addq.w   #$5, (a0)
01016740  806e324e          or.w     $324e(a6), d0
01016744  1f680a1f6a85      move.b   $a1f(a0), $6a85(a7)
0101674a  4b82              chk.w    d2, d5
0101674c  6b04              bmi.b    $1016752
0101674e  5082              addq.l   #$8, d2
01016750  7a49              moveq    #$49, d5
01016752  815a              or.w     d0, (a2)+
01016754  324e              movea.w  a6, a1
01016756  1f680a1f5285      move.b   $a1f(a0), $5285(a7)
0101675c  5c82              addq.l   #$6, d2
0101675e  530f              dc.w     $530f
01016760  6002              bra.b    $1016764
01016762  0a6a815a5081      eori.w   #$815a, $5081(a2)
01016768  334e1f68          move.w   a6, $1f68(a1)
0101676c  0a1f5085          eori.b   #$85, (a7)+
01016770  6f82              ble.b    $10166f4
01016772  1a13              move.b   (a3), d5
01016774  7f59              dc.w     $7f59
01016776  0218807a          andi.b   #$7a, (a0)+
0101677a  4981              chk.w    d1, d4
0101677c  7e33              moveq    #$33, d7
0101677e  4e1f              dc.w     $4e1f
01016780  680a              bvc.b    $101678c
01016782  1f4d              dc.w     $1f4d
01016784  85728200          or.w     d2, (a2, a0.w * 2)
01016788  147f              dc.w     $147f
0101678a  7e1a              moveq    #$1a, d7
0101678c  0119              btst.l   d0, (a1)+
0101678e  805a              or.w     (a2)+, d0
01016790  5081              addq.l   #$8, d1
01016792  7e33              moveq    #$33, d7
01016794  4e1f              dc.w     $4e1f
01016796  680a              bvc.b    $10167a2
01016798  1f5d8577          move.b   (a5)+, -$7a89(a7)
0101679c  6a80              bpl.b    $101671e
0101679e  7e00              moveq    #$0, d7
010167a0  17807a01          move.b   d0, $1(a3, d7.l)
010167a4  527f              dc.w     $527f
010167a6  7a49              moveq    #$49, d5
010167a8  827d              dc.w     $827d
010167aa  334e1f68          move.w   a6, $1f68(a1)
010167ae  0a1f5685          eori.b   #$85, (a7)+
010167b2  7a52              moveq    #$52, d5
010167b4  807d              dc.w     $807d
010167b6  00188171          ori.b    #$71, (a0)+
010167ba  006a7f5a5082      ori.w    #$7f5a, $5082(a2)
010167c0  7a33              moveq    #$33, d5
010167c2  4e1f              dc.w     $4e1f
010167c4  680a              bvc.b    $10167d0
010167c6  1f55857d          move.b   (a5), -$7a83(a7)
010167ca  5080              addq.l   #$8, d0
010167cc  7c00              moveq    #$0, d6
010167ce  1982597f7a498377  move.b   d2, ([$7a498377, a4])
010167d6  334e1f68          move.w   a6, $1f68(a1)
010167da  0a1f5485          eori.b   #$85, (a7)+
010167de  7e4d              moveq    #$4d, d7
010167e0  80790052827e      or.w     $52827e.l, d0               ; $0052827e = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
010167e6  7f5a              dc.w     $7f5a
010167e8  5083              addq.l   #$8, d3
010167ea  7233              moveq    #$33, d1
010167ec  4e1f              dc.w     $4e1f
010167ee  680a              bvc.b    $10167fa
010167f0  1f546a85          move.b   (a4), $6a85(a7)
010167f4  4b80              chk.w    d0, d5
010167f6  7600              moveq    #$0, d3
010167f8  6a83              bpl.b    $101677d
010167fa  7a49              moveq    #$49, d5
010167fc  846e334e          or.w     $334e(a6), d2
01016800  1f680a1f5452      move.b   $a1f(a0), $5452(a7)
01016806  855c              or.w     d2, (a4)+
01016808  80750084          or.w     -$7c(a5, d0.w), d0
0101680c  5a50              addq.w   #$5, (a0)
0101680e  845a              or.w     (a2)+, d2
01016810  334e1f68          move.w   a6, $1f68(a1)
01016814  0a1f5450          eori.b   #$50, (a7)+
01016818  856f8070          or.w     d2, -$7f90(a7)
0101681c  0a837a498534      eori.l   #$7a498534, d3
01016822  4e1f              dc.w     $4e1f
01016824  680a              bvc.b    $1016830
01016826  1f544d85          move.b   (a4), $4d85(a7)
0101682a  7280              moveq    #$80, d1
0101682c  6c0b              bge.b    $1016839
0101682e  835a              or.w     d1, (a2)+
01016830  5084              addq.l   #$8, d4
01016832  7e34              moveq    #$34, d7
01016834  4e1f              dc.w     $4e1f
01016836  680a              bvc.b    $1016842
01016838  1f544b85          move.b   (a4), $4b85(a7)
0101683c  776a              dc.w     $776a
0101683e  7f6b              dc.w     $7f6b
01016840  0c827a49857d      cmpi.l   #$7a49857d, d2
01016846  344e              movea.w  a6, a2
01016848  1f680a1f544a      move.b   $a1f(a0), $544a(a7)
0101684e  857a              dc.w     $857a
01016850  527f              dc.w     $527f
01016852  530f              dc.w     $530f
01016854  825a              or.w     (a2)+, d1
01016856  5085              addq.l   #$8, d5
01016858  7a34              moveq    #$34, d5
0101685a  4e1f              dc.w     $4e1f
0101685c  680a              bvc.b    $1016868
0101685e  1f544985          move.b   (a4), $4985(a7)
01016862  7d50              dc.w     $7d50
01016864  7f1a              dc.w     $7f1a
01016866  13817a49          move.b   d1, $49(a1, d7.l)
0101686a  8677344e          or.w     $4e(a7, d3.w), d3
0101686e  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
01016874  857e              dc.w     $857e
01016876  4d7f              dc.w     $4d7f
01016878  0014815a          ori.b    #$5a, (a4)
0101687c  5086              addq.l   #$8, d6
0101687e  7234              moveq    #$34, d1
01016880  4e1f              dc.w     $4e1f
01016882  680a              bvc.b    $101688e
01016884  1f541d6a          move.b   (a4), $1d6a(a7)
01016888  854b7e00          pack     -(a3), -(a2), #$7e00
0101688c  17807a49          move.b   d0, $49(a3, d7.l)
01016890  8772344e          or.w     d3, $4e(a2, d3.w)
01016894  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
0101689a  5285              addq.l   #$1, d5
0101689c  5c7d              dc.w     $5c7d
0101689e  0018805a          ori.b    #$5a, (a0)+
010168a2  5087              addq.l   #$8, d7
010168a4  6e34              bgt.b    $10168da
010168a6  4e1f              dc.w     $4e1f
010168a8  680a              bvc.b    $10168b4
010168aa  1f541d50          move.b   (a4), $1d50(a7)
010168ae  856f7c00          or.w     d2, $7c00(a7)
010168b2  197f              dc.w     $197f
010168b4  7a49              moveq    #$49, d5
010168b6  885a              or.w     (a2)+, d4
010168b8  344e              movea.w  a6, a2
010168ba  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
010168c0  4d85              chk.w    d5, d6
010168c2  7279              moveq    #$79, d1
010168c4  00527f5a          ori.w    #$7f5a, (a2)
010168c8  5088              addq.l   #$8, a0
010168ca  354e1f68          move.w   a6, $1f68(a2)
010168ce  0a1f541d          eori.b   #$1d, (a7)+
010168d2  4b85              chk.w    d5, d5
010168d4  7769              dc.w     $7769
010168d6  1a6a              dc.w     $1a6a
010168d8  7a49              moveq    #$49, d5
010168da  887e              dc.w     $887e
010168dc  354e1f68          move.w   a6, $1f68(a2)
010168e0  0a1f541d          eori.b   #$1d, (a7)+
010168e4  4a85              tst.l    d5
010168e6  7a52              moveq    #$52, d5
010168e8  7a7f              moveq    #$7f, d5
010168ea  5a50              addq.w   #$5, (a0)
010168ec  887d              dc.w     $887d
010168ee  354e1f68          move.w   a6, $1f68(a2)
010168f2  0a1f541d          eori.b   #$1d, (a7)+
010168f6  4985              chk.w    d5, d4
010168f8  7d50              dc.w     $7d50
010168fa  7f7a              dc.w     $7f7a
010168fc  4989              dc.w     $4989
010168fe  7a35              moveq    #$35, d5
01016900  4e1f              dc.w     $4e1f
01016902  680a              bvc.b    $101690e
01016904  1f541e85          move.b   (a4), $1e85(a7)
01016908  7e4d              moveq    #$4d, d7
0101690a  7f5a              dc.w     $7f5a
0101690c  5089              addq.l   #$8, a1
0101690e  7735              dc.w     $7735
01016910  4e1f              dc.w     $4e1f
01016912  680a              bvc.b    $101691e
01016914  1f541e6a          move.b   (a4), $1e6a(a7)
01016918  854b7a49          pack     -(a3), -(a2), #$7a49
0101691c  8a72354e          or.w     ([a2]), d5
01016920  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
01016926  5285              addq.l   #$1, d5
01016928  5b5a              subq.w   #$5, (a2)+
0101692a  508a              addq.l   #$8, a2
0101692c  6e35              bgt.b    $1016963
0101692e  4e1f              dc.w     $4e1f
01016930  680a              bvc.b    $101693c
01016932  1f541e50          move.b   (a4), $1e50(a7)
01016936  856e498b          or.w     d2, $498b(a6)
0101693a  5a354e1f          addq.b   #$5, $1f(a5, d4.l)
0101693e  680a              bvc.b    $101694a
01016940  1f541e4d          move.b   (a4), $1e4d(a7)
01016944  8572508b          or.w     d2, -$75(a2, d5.w)
01016948  364e              movea.w  a6, a3
0101694a  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
01016950  4b85              chk.w    d5, d5
01016952  6f8b              ble.b    $10168df
01016954  7e36              moveq    #$36, d7
01016956  4e1f              dc.w     $4e1f
01016958  680a              bvc.b    $1016964
0101695a  1f541e4a          move.b   (a4), $1e4a(a7)
0101695e  855c              or.w     d2, (a4)+
01016960  8b7d              dc.w     $8b7d
01016962  364e              movea.w  a6, a3
01016964  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
0101696a  4985              chk.w    d5, d4
0101696c  4b8b              dc.w     $4b8b
0101696e  7236              moveq    #$36, d1
01016970  4e1f              dc.w     $4e1f
01016972  680a              bvc.b    $101697e
01016974  1f541f84          move.b   (a4), $1f84(a7)
01016978  7e4d              moveq    #$4d, d7
0101697a  8a7e              dc.w     $8a7e
0101697c  374e1f68          move.w   a6, $1f68(a3)
01016980  0a1f541f          eori.b   #$1f, (a7)+
01016984  6a83              bpl.b    $1016909
01016986  7e50              moveq    #$50, d7
01016988  8a72374e          or.w     ([a2]), d5
0101698c  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
01016992  5283              addq.l   #$1, d3
01016994  7d50              dc.w     $7d50
01016996  897e              dc.w     $897e
01016998  384e              movea.w  a6, a4
0101699a  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010169a0  5083              addq.l   #$8, d3
010169a2  7a52              moveq    #$52, d5
010169a4  8972384e          or.w     d4, $4e(a2, d3.l)
010169a8  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010169ae  4d83              chk.w    d3, d6
010169b0  7a6a              moveq    #$6a, d5
010169b2  887e              dc.w     $887e
010169b4  394e1f68          move.w   a6, $1f68(a4)
010169b8  0a1f541f          eori.b   #$1f, (a7)+
010169bc  4b83              chk.w    d3, d5
010169be  726a              moveq    #$6a, d1
010169c0  8872394e          or.w     ([a2]), d4
010169c4  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010169ca  4a83              tst.l    d3
010169cc  7388              dc.w     $7388
010169ce  7e3a              moveq    #$3a, d7
010169d0  4e1f              dc.w     $4e1f
010169d2  680a              bvc.b    $10169de
010169d4  1f541f49          move.b   (a4), $1f49(a7)
010169d8  836f8872          or.w     d1, -$778e(a7)
010169dc  3a4e              movea.w  a6, a5
010169de  1f680a1f5420      move.b   $a1f(a0), $5420(a7)
010169e4  835c              or.w     d1, (a4)+
010169e6  877e              dc.w     $877e
010169e8  3b4e1f68          move.w   a6, $1f68(a5)
010169ec  0a1f5420          eori.b   #$20, (a7)+
010169f0  6a82              bpl.b    $1016974
010169f2  4b87              chk.w    d7, d5
010169f4  723b              moveq    #$3b, d1
010169f6  4e1f              dc.w     $4e1f
010169f8  680a              bvc.b    $1016a04
010169fa  1f542052          move.b   (a4), $2052(a7)
010169fe  817e              dc.w     $817e
01016a00  4d86              chk.w    d6, d6
01016a02  7e3c              moveq    #$3c, d7
01016a04  4e1f              dc.w     $4e1f
01016a06  680a              bvc.b    $1016a12
01016a08  1f542050          move.b   (a4), $2050(a7)
01016a0c  817e              dc.w     $817e
01016a0e  5086              addq.l   #$8, d6
01016a10  723c              moveq    #$3c, d1
01016a12  4e1f              dc.w     $4e1f
01016a14  680a              bvc.b    $1016a20
01016a16  1f54204d          move.b   (a4), $204d(a7)
01016a1a  817d              dc.w     $817d
01016a1c  5085              addq.l   #$8, d5
01016a1e  7e3d              moveq    #$3d, d7
01016a20  4e1f              dc.w     $4e1f
01016a22  680a              bvc.b    $1016a2e
01016a24  1f54204b          move.b   (a4), $204b(a7)
01016a28  817a              dc.w     $817a
01016a2a  5285              addq.l   #$1, d5
01016a2c  723d              moveq    #$3d, d1
01016a2e  4e1f              dc.w     $4e1f
01016a30  680a              bvc.b    $1016a3c
01016a32  1f54204a          move.b   (a4), $204a(a7)
01016a36  81776a84          or.w     d0, -$7c(a7, d6.l)
01016a3a  7e3e              moveq    #$3e, d7
01016a3c  4e1f              dc.w     $4e1f
01016a3e  680a              bvc.b    $1016a4a
01016a40  1f542049          move.b   (a4), $2049(a7)
01016a44  81726a84          or.w     d0, -$7c(a2, d6.l)
01016a48  723e              moveq    #$3e, d1
01016a4a  4e1f              dc.w     $4e1f
01016a4c  680a              bvc.b    $1016a58
01016a4e  1f542181          move.b   (a4), $2181(a7)
01016a52  6f84              ble.b    $10169d8
01016a54  7e3f              moveq    #$3f, d7
01016a56  4e1f              dc.w     $4e1f
01016a58  680a              bvc.b    $1016a64
01016a5a  1f54216a          move.b   (a4), $216a(a7)
01016a5e  805b              or.w     (a3)+, d0
01016a60  84723f4e          or.w     ([a2]), d2
01016a64  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
01016a6a  5280              addq.l   #$1, d0
01016a6c  5d83              subq.l   #$6, d3
01016a6e  7e40              moveq    #$40, d7
01016a70  4e1f              dc.w     $4e1f
01016a72  680a              bvc.b    $1016a7e
01016a74  1f542150          move.b   (a4), $2150(a7)
01016a78  804b              dc.w     $804b
01016a7a  8372404e          or.w     d1, $4e(a2, d4.w)
01016a7e  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
01016a84  4d7f              dc.w     $4d7f
01016a86  7e4d              moveq    #$4d, d7
01016a88  827e              dc.w     $827e
01016a8a  414e              dc.w     $414e
01016a8c  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
01016a92  4b7f              dc.w     $4b7f
01016a94  7d50              dc.w     $7d50
01016a96  8272414e          or.w     ([a2]), d1
01016a9a  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
01016aa0  4a7f              dc.w     $4a7f
01016aa2  7a52              moveq    #$52, d5
01016aa4  817e              dc.w     $817e
01016aa6  424e              dc.w     $424e
01016aa8  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
01016aae  497f              dc.w     $497f
01016ab0  776a              dc.w     $776a
01016ab2  8172424e          or.w     d0, $4e(a2, d4.w)
01016ab6  1f680a1f5422      move.b   $a1f(a0), $5422(a7)
01016abc  7f72              dc.w     $7f72
01016abe  6a80              bpl.b    $1016a40
01016ac0  7e43              moveq    #$43, d7
01016ac2  4e1f              dc.w     $4e1f
01016ac4  680a              bvc.b    $1016ad0
01016ac6  1f54226a          move.b   (a4), $226a(a7)
01016aca  7381              dc.w     $7381
01016acc  7243              moveq    #$43, d1
01016ace  4e1f              dc.w     $4e1f
01016ad0  680a              bvc.b    $1016adc
01016ad2  1f542252          move.b   (a4), $2252(a7)
01016ad6  6f80              ble.b    $1016a58
01016ad8  7e44              moveq    #$44, d7
01016ada  4e1f              dc.w     $4e1f
01016adc  680a              bvc.b    $1016ae8
01016ade  1f576362          move.b   (a7), $6362(a7)
01016ae2  505c              addq.w   #$8, (a4)+
01016ae4  8072665f          or.w     $5f(a2, d6.w), d0
01016ae8  1f680a1f1a05      move.b   $a1f(a0), $1a05(a7)
01016aee  175d7f7e          move.b   (a5)+, $7f7e(a3)
01016af2  1c08              dc.w     $1c08
01016af4  0a1f680a          eori.b   #$a, (a7)+
01016af8  264c              movea.l  a4, a3
01016afa  7f72              dc.w     $7f72
01016afc  4568              dc.w     $4568
01016afe  0a26494d          eori.b   #$4d, -(a6)
01016b02  7e46              moveq    #$46, d7
01016b04  680a              bvc.b    $1016b10
01016b06  2649              movea.l  a1, a3
01016b08  50724668          addq.w   #$8, $68(a2, d4.w)
01016b0c  0a275147          eori.b   #$47, -(a7)
01016b10  680a              bvc.b    $1016b1c
01016b12  275a4768          move.l   (a2)+, $4768(a3)
01016b16  0a48              dc.w     $0a48
01016b18  680a              bvc.b    $1016b24
01016b1a  48680a48          pea.l    $a48(a0)
01016b1e  680a              bvc.b    $1016b2a
01016b20  48680a48          pea.l    $a48(a0)
01016b24  680a              bvc.b    $1016b30
01016b26  48680a48          pea.l    $a48(a0)
01016b2a  680a              bvc.b    $1016b36
01016b2c  48680a48          pea.l    $a48(a0)
01016b30  680b              bvc.b    $1016b3d
01016b32  6768              beq.b    $1016b9c
01016b34  1267              dc.w     $1267
01016b36  6819              bvc.b    $1016b51
01016b38  8c8d              dc.w     $8c8d
01016b3a  00005300          ori.b    #$0, d0
01016b3e  00000000          ori.b    #$0, d0
01016b42  00500000          ori.w    #$0, (a0)
01016b46  00548900          ori.w    #$8900, (a4)
01016b4a  0100              btst.l   d0, d0
01016b4c  02000300          andi.b   #$0, d0
01016b50  04000500          subi.b   #$0, d0
01016b54  0900              btst.l   d4, d0
01016b56  0e01              dc.w     $0e01
01016b58  0102              btst.l   d0, d2
01016b5a  0104              btst.l   d0, d4
01016b5c  0104              btst.l   d0, d4
01016b5e  02050106          andi.b   #$6, d5
01016b62  010a0110          movep.w  $110(a2), d0
01016b66  0111              btst.l   d0, (a1)
01016b68  0111              btst.l   d0, (a1)
01016b6a  02110311          andi.b   #$11, (a1)
01016b6e  04140115          subi.b   #$15, (a4)
01016b72  011b              btst.l   d0, (a3)+
01016b74  012a012e          btst.l   d0, $12e(a2)
01016b78  013a0140          btst.l   d0, $1016cba(pc)
01016b7c  0140              bchg.b   d0, d0
01016b7e  02410144          andi.w   #$144, d1
01016b82  0144              bchg.b   d0, d4
01016b84  02440345          andi.w   #$345, d4
01016b88  0150              bchg.b   d0, (a0)
01016b8a  0151              bchg.b   d0, (a1)
01016b8c  0151              bchg.b   d0, (a1)
01016b8e  02520153          andi.w   #$153, (a2)
01016b92  0154              bchg.b   d0, (a4)
01016b94  0155              bchg.b   d0, (a5)
01016b96  0155              bchg.b   d0, (a5)
01016b98  02550355          andi.w   #$355, (a5)
01016b9c  04550555          subi.w   #$555, (a5)
01016ba0  06550755          addi.w   #$755, (a5)
01016ba4  0855              dc.w     $0855
01016ba6  0a550c55          eori.w   #$c55, (a5)
01016baa  0e56              dc.w     $0e56
01016bac  0157              bchg.b   d0, (a7)
01016bae  0159              bchg.b   d0, (a1)+
01016bb0  015a              bchg.b   d0, (a2)+
01016bb2  015b              bchg.b   d0, (a3)+
01016bb4  015e              bchg.b   d0, (a6)+
01016bb6  015f              bchg.b   d0, (a7)+
01016bb8  0164              bchg.b   d0, -(a4)
01016bba  0165              bchg.b   d0, -(a5)
01016bbc  0166              bchg.b   d0, -(a6)
01016bbe  0166              bchg.b   d0, -(a6)
01016bc0  0266036a          andi.w   #$36a, -(a6)
01016bc4  016b016e          bchg.b   d0, $16e(a3)
01016bc8  0195              bclr.b   d0, (a5)
01016bca  0196              bclr.b   d0, (a6)
01016bcc  0198              bclr.b   d0, (a0)+
01016bce  0199              bclr.b   d0, (a1)+
01016bd0  0199              bclr.b   d0, (a1)+
01016bd2  039a              bclr.b   d1, (a2)+
01016bd4  01a0              bclr.b   d0, -(a0)
01016bd6  01a1              bclr.b   d0, -(a1)
01016bd8  01a5              bclr.b   d0, -(a5)
01016bda  01a6              bclr.b   d0, -(a6)
01016bdc  01a801a9          bclr.b   d0, $1a9(a0)
01016be0  01aa01aa          bclr.b   d0, $1aa(a2)
01016be4  02aa03aa04aa06aa  andi.l   #$3aa04aa, $6aa(a2)
01016bec  07aa11aa          bclr.b   d3, $11aa(a2)
01016bf0  12ab01ac          move.b   $1ac(a3), (a1)
01016bf4  01ae01af          bclr.b   d0, $1af(a6)
01016bf8  01af02b5          bclr.b   d0, $2b5(a7)
01016bfc  01b801b9          bclr.b   d0, $1b9.w
01016c00  01ba              dc.w     $01ba
01016c02  01ba              dc.w     $01ba
01016c04  02bb              dc.w     $02bb
01016c06  01bb              dc.w     $01bb
01016c08  02bb              dc.w     $02bb
01016c0a  03bc              dc.w     $03bc
01016c0c  01bd              dc.w     $01bd
01016c0e  01be              dc.w     $01be
01016c10  01bf              dc.w     $01bf
01016c12  01c0              bset.b   d0, d0
01016c14  01c1              bset.b   d0, d1
01016c16  01c2              bset.b   d0, d2
01016c18  01c4              bset.b   d0, d4
01016c1a  01d0              bset.b   d0, (a0)
01016c1c  01d1              bset.b   d0, (a1)
01016c1e  01d4              bset.b   d0, (a4)
01016c20  01d5              bset.b   d0, (a5)
01016c22  01d9              bset.b   d0, (a1)+
01016c24  01e5              bset.b   d0, -(a5)
01016c26  01e6              bset.b   d0, -(a6)
01016c28  01e801e9          bset.b   d0, $1e9(a0)
01016c2c  01ea01eb          bset.b   d0, $1eb(a2)
01016c30  01ec01ee          bset.b   d0, $1ee(a4)
01016c34  01ee02ee          bset.b   d0, $2ee(a6)
01016c38  03ef01f2          bset.b   d1, $1f2(a7)
01016c3c  01f501f601f801fa  bset.b   d0, ([$1f801fa])            ; $01f801fa = ROM
01016c44  01fb              dc.w     $01fb
01016c46  01fc              dc.w     $01fc
01016c48  01fe              dc.w     $01fe
01016c4a  01ff              dc.w     $01ff
01016c4c  01ff              dc.w     $01ff
01016c4e  02ff              dc.w     $02ff
01016c50  03ff              dc.w     $03ff
01016c52  04ff              dc.w     $04ff
01016c54  05ff              dc.w     $05ff
01016c56  08ff              dc.w     $08ff
01016c58  11ff              dc.w     $11ff
01016c5a  1229052c          move.b   $52c(a1), d1
01016c5e  2619              move.l   (a1)+, d3
01016c60  0114              btst.l   d0, (a4)
01016c62  2d650307          move.l   -(a5), $307(a6)
01016c66  2626              move.l   -(a6), d3
01016c68  164d              dc.w     $164d
01016c6a  142d724f          move.b   $724f(a5), d2
01016c6e  5e26              addq.b   #$7, -(a6)
01016c70  2617              move.l   (a7), d3
01016c72  4d14              chk.l    (a4), d6
01016c74  2d724f5e2626      move.l   ([a2]), $2626(a6)
01016c7a  174d              dc.w     $174d
01016c7c  6c2d              bge.b    $1016cab
01016c7e  724f              moveq    #$4f, d1
01016c80  5e26              addq.b   #$7, -(a6)
01016c82  2617              move.l   (a7), d3
01016c84  574c              subq.w   #$3, a4
01016c86  6481              bcc.b    $1016c09
01016c88  7a2b              moveq    #$2b, d5
01016c8a  724e              moveq    #$4e, d1
01016c8c  7b5e              dc.w     $7b5e
01016c8e  2625              move.l   -(a5), d3
01016c90  5664              addq.w   #$3, -(a4)
01016c92  164d              dc.w     $164d
01016c94  622a              bhi.b    $1016cc0
01016c96  1f724d54795c      move.b   (a2, invalid.w), $795c(a7)
01016c9c  6c25              bge.b    $1016cc3
01016c9e  5661              addq.w   #$3, -(a1)
01016ca0  164d              dc.w     $164d
01016ca2  47291f26          chk.l    $1f26(a1), d3
01016ca6  724d              moveq    #$4d, d1
01016ca8  5467              addq.w   #$2, -(a7)
01016caa  5c6c2556          addq.w   #$6, $2556(a4)
01016cae  464e              dc.w     $464e
01016cb0  472a1472          chk.l    $1472(a2), d3
01016cb4  4d4b              dc.w     $4d4b
01016cb6  0d5c              bchg.b   d6, (a4)+
01016cb8  6c25              bge.b    $1016cdf
01016cba  564f              addq.w   #$3, a7
01016cbc  4728211f          chk.l    $211f(a0), d3
01016cc0  21724f5c6c25      move.l   (a2, invalid.w), $6c25(a0)
01016cc6  564f              addq.w   #$3, a7
01016cc8  4a27              tst.b    -(a7)
01016cca  2126              move.l   -(a6), -(a0)
01016ccc  251f              move.l   (a7)+, -(a2)
01016cce  724f              moveq    #$4f, d1
01016cd0  5c6c2556          addq.w   #$6, $2556(a4)
01016cd4  4f4a              dc.w     $4f4a
01016cd6  281f              move.l   (a7)+, d4
01016cd8  1072              dc.w     $1072
01016cda  4f5c              dc.w     $4f5c
01016cdc  6c25              bge.b    $1016d03
01016cde  564f              addq.w   #$3, a7
01016ce0  4a26              tst.b    -(a6)
01016ce2  2225              move.l   -(a5), d1
01016ce4  1c07              move.b   d7, d6
01016ce6  724f              moveq    #$4f, d1
01016ce8  5c6c2356          addq.w   #$6, $2356(a4)
01016cec  4f4a              dc.w     $4f4a
01016cee  1f26              move.b   -(a6), -(a7)
01016cf0  1410              move.b   (a0), d2
01016cf2  0b724f5c          bchg.b   d5, (a2, invalid.w)
01016cf6  5923              subq.b   #$4, -(a3)
01016cf8  564f              addq.w   #$3, a7
01016cfa  4a26              tst.b    -(a6)
01016cfc  0f25              btst.l   d7, -(a5)
01016cfe  1c00              move.b   d0, d6
01016d00  07724f5c          bchg.b   d3, (a2, invalid.w)
01016d04  5923              subq.b   #$4, -(a3)
01016d06  564f              addq.w   #$3, a7
01016d08  4a25              tst.b    -(a5)
01016d0a  260f              move.l   a7, d3
01016d0c  0009              dc.w     $0009
01016d0e  1b724f5c5923      move.b   (a2, invalid.w), $5923(a5)
01016d14  564f              addq.w   #$3, a7
01016d16  6126              bsr.b    $1016d3e
01016d18  1d1b              move.b   (a3)+, -(a6)
01016d1a  0007804f          ori.b    #$4f, d7
01016d1e  5c59              addq.w   #$6, (a1)+
01016d20  23564e54          move.l   (a6), $4e54(a1)
01016d24  701c              moveq    #$1c, d0
01016d26  0f0e0009          movep.w  $9(a6), d7
01016d2a  0773724e          bchg.b   d3, $4e(a3, d7.w)
01016d2e  5c59              addq.w   #$6, (a1)+
01016d30  2480              move.l   d0, (a2)
01016d32  4e63              move     a3, usp
01016d34  4a26              tst.b    -(a6)
01016d36  1c1b              move.b   (a3)+, d6
01016d38  0e00              dc.w     $0e00
01016d3a  0772              dc.w     $0772

; ---- gap 01016d47..01016eb8 (370 bytes) ----
01016d47  0e01              dc.w     $0e01
01016d49  07715472          bchg.b   d3, $72(a1, d5.w)
01016d4d  4d64              dc.w     $4d64
01016d4f  7a24              moveq    #$24, d5
01016d51  4e56724a          link.w   a6, #$724a
01016d55  1d1b              move.b   (a3)+, -(a6)
01016d57  0107              btst.l   d0, d7
01016d59  7243              moveq    #$43, d1
01016d5b  5c4e              addq.w   #$6, a6
01016d5d  7a24              moveq    #$24, d5
01016d5f  4e5e              unlk     a6
01016d61  5c7021030f72393f  addq.w   #$6, ([a0, d2.w], $f72393f) ; $0f72393f = VRAM MWF mirrors (non-Turbo mono only)
01016d69  4e7a244e          movec    invalid, d2
01016d6d  764a              moveq    #$4a, d3
01016d6f  191b              move.b   (a3)+, -(a4)
01016d71  010e0771          movep.w  $771(a6), d0
01016d75  41354e7a          chk.l    $7a(a5, d4.l), d0
01016d79  244d              movea.l  a5, a2
01016d7b  545f              addq.w   #$2, (a7)+
01016d7d  4a21              tst.b    -(a1)
01016d7f  031b              btst.l   d1, (a3)+
01016d81  7239              moveq    #$39, d1
01016d83  31724d7a244d5680755a1902  move.w   ([$244d5680, a2], $755a), $1902(a0)
01016d8f  190b              dc.w     $190b
01016d91  7140              dc.w     $7140
01016d93  265c              movea.l  (a4)+, a3
01016d95  4d7a              dc.w     $4d7a
01016d97  244d              movea.l  a5, a2
01016d99  5e81              addq.l   #$7, d1
01016d9b  7e4a              moveq    #$4a, d7
01016d9d  2019              move.l   (a1)+, d0
01016d9f  0019070f          ori.b    #$f, (a1)+
01016da3  6f33              ble.b    $1016dd8
01016da5  1c3f              dc.w     $1c3f
01016da7  4d7a              dc.w     $4d7a
01016da9  244d              movea.l  a5, a2
01016dab  7880              moveq    #$80, d4
01016dad  7574              dc.w     $7574
01016daf  1901              move.b   d1, -(a4)
01016db1  07091f71          movep.w  $1f71(a1), d3
01016db5  400f              dc.w     $400f
01016db7  154d              dc.w     $154d
01016db9  7a24              moveq    #$24, d5
01016dbb  4c54              dc.w     $4c54
01016dbd  6481              bcc.b    $1016d40
01016dbf  7e5a              moveq    #$5a, d7
01016dc1  1900              move.b   d0, -(a4)
01016dc3  1a0f              dc.w     $1a0f
01016dc5  266f261c          movea.l  $261c(a7), a3
01016dc9  0872              dc.w     $0872
01016dcb  4c7a              dc.w     $4c7a
01016dcd  244c              movea.l  a4, a2
01016dcf  5464              addq.w   #$2, -(a4)
01016dd1  82741900          or.w     (a4, d1.l), d1
01016dd5  0a1c216d          eori.b   #$6d, (a4)+
01016dd9  260e              move.l   a6, d3
01016ddb  19724c7a244c      move.b   $7a(a2, d4.l), $244c(a4)
01016de1  5678817e          addq.w   #$3, $817e.w
01016de5  5a19              addq.b   #$5, (a1)+
01016de7  0919              btst.l   d4, (a1)+
01016de9  0f14              btst.l   d7, (a4)
01016deb  266e251c          movea.l  $251c(a6), a3
01016def  005c4c7a          ori.w    #$4c7a, (a4)+
01016df3  244c              movea.l  a4, a2
01016df5  575e              subq.w   #$3, (a6)+
01016df7  6481              bcc.b    $1016d7a
01016df9  741b              moveq    #$1b, d2
01016dfb  0009              dc.w     $0009
01016dfd  1f26              move.b   -(a6), -(a7)
01016dff  146c              dc.w     $146c
01016e01  0f01              btst.l   d7, d1
01016e03  184c              dc.w     $184c
01016e05  7a24              moveq    #$24, d5
01016e07  4c5c              dc.w     $4c5c
01016e09  7578              dc.w     $7578
01016e0b  817c              dc.w     $817c
01016e0d  1911              move.b   (a1), -(a4)
01016e0f  1f26              move.b   -(a6), -(a7)
01016e11  6b1c              bmi.b    $1016e2f
01016e13  0e00              dc.w     $0e00
01016e15  3f4c7a24          move.w   a4, $7a24(a7)
01016e19  4c5e              dc.w     $4c5e
01016e1b  545e              addq.w   #$2, (a6)+
01016e1d  647f              bcc.b    $1016e9e
01016e1f  2109              move.l   a1, -(a0)
01016e21  1c286a0e          move.b   $6a0e(a0), d6
01016e25  000f              dc.w     $000f
01016e27  174c              dc.w     $174c
01016e29  7a24              moveq    #$24, d5
01016e2b  4c72              dc.w     $4c72
01016e2d  5c56              addq.w   #$6, (a6)
01016e2f  787f              moveq    #$7f, d4
01016e31  1910              move.b   (a0), -(a4)
01016e33  1c27              move.b   -(a7), d6
01016e35  6819              bvc.b    $1016e50
01016e37  001c354c          ori.b    #$4c, (a4)+
01016e3b  7a24              moveq    #$24, d5
01016e3d  4c72              dc.w     $4c72
01016e3f  4d5e              dc.w     $4d5e
01016e41  611c              bsr.b    $1016e5f
01016e43  1f25              move.b   -(a5), -(a7)
01016e45  28690007          movea.l  $7(a1), a4
01016e49  14354c7a          move.b   $7a(a5, d4.l), d2
01016e4d  2454              movea.l  (a4), a2
01016e4f  434d              dc.w     $434d
01016e51  56742110          addq.w   #$3, (a4, d2.w)
01016e55  1f27              move.b   -(a7), -(a7)
01016e57  68001c21          bvc.w    $1018a7a
01016e5b  31727a245449      move.w   $24(a2, d7.l), $5449(a0)
01016e61  3b4c5a1c          move.w   a4, $5a1c(a5)
01016e65  1f29690f          move.b   $690f(a1), -(a7)
01016e69  1426              move.b   -(a6), d2
01016e6b  4172              dc.w     $4172
01016e6d  7a24              moveq    #$24, d5
01016e6f  5444              addq.w   #$2, d4
01016e71  454a              dc.w     $454a
01016e73  2621              move.l   -(a1), d3
01016e75  1f28651f          move.b   $651f(a0), -(a7)
01016e79  263b727a          move.l   $1016ef5(pc, d7.w), d3
01016e7d  2454              movea.l  (a4), a2
01016e7f  4026              negx.b   -(a6)
01016e81  3b381c1f          move.w   $1c1f.w, -(a5)
01016e85  29661433          move.l   -(a6), $1433(a4)
01016e89  434c              dc.w     $434c
01016e8b  727a              moveq    #$7a, d1
01016e8d  2454              movea.l  (a4), a2
01016e8f  4027              negx.b   -(a7)
01016e91  33422b68          move.w   d2, $2b68(a1)
01016e95  313a3d4c          move.w   $101abe3(pc), -(a0)
01016e99  727a              moveq    #$7a, d1
01016e9b  2456              movea.l  (a6), a2
01016e9d  0f28251f          btst.l   d7, $251f(a0)
01016ea1  14296c33          move.b   $6c33(a1), d2
01016ea5  454d              dc.w     $454d
01016ea7  5c7a              dc.w     $5c7a
01016ea9  2456              movea.l  (a6), a2
01016eab  1e26              move.b   -(a6), d7
01016ead  252b6f3a          move.l   $6f3a(a3), -(a2)
01016eb1  4d72              dc.w     $4d72
01016eb3  5c7a              dc.w     $5c7a
01016eb5  2456              movea.l  (a6), a2
01016eb7  1213              move.b   (a3), d1

; ---- gap 01016ec3..01017340 (1150 bytes) ----
01016ec3  0900              btst.l   d4, d0
01016ec5  1900              move.b   d0, -(a4)
01016ec7  2b724c5e545d      move.l   $5e(a2, d4.l), $545d(a5)
01016ecd  7a24              moveq    #$24, d5
01016ecf  5604              addq.b   #$3, d4
01016ed1  2b7277785c7a24560207  move.l   $5c7a2456(a2, invalid.w), $207(a5)
01016edb  0e2b              dc.w     $0e2b
01016edd  7e60              moveq    #$60, d7
01016edf  645c              bcc.b    $1016f3d
01016ee1  7a24              moveq    #$24, d5
01016ee3  5600              addq.b   #$3, d0
01016ee5  091e              btst.l   d4, (a6)+
01016ee7  2b75837e5c7a24560710  move.l   ([$5c7a2456, a5]), $710(a5)
01016ef1  1425              move.b   -(a5), d2
01016ef3  2b855c7a          move.l   d5, $7a(a5, d5.l)
01016ef7  2456              movea.l  (a6), a2
01016ef9  1c1f              move.b   (a7)+, d6
01016efb  2725              move.l   -(a5), -(a3)
01016efd  2b80845c          move.l   d0, $5c(a5, a0.w)
01016f01  7a24              moveq    #$24, d5
01016f03  560f              dc.w     $560f
01016f05  2733422b          move.l   $2b(a3, d4.w), -(a3)
01016f09  735e              dc.w     $735e
01016f0b  647e              bcc.b    $1016f8b
01016f0d  815c              or.w     d0, (a4)+
01016f0f  7a24              moveq    #$24, d5
01016f11  56283a38          addq.b   #$3, $3a38(a0)
01016f15  2b7256775c7a      move.l   $77(a2, d5.w), $5c7a(a5)
01016f1b  2456              movea.l  (a6), a2
01016f1d  2644              movea.l  d4, a3
01016f1f  422b724c          clr.b    $724c(a3)
01016f23  545f              addq.w   #$2, (a7)+
01016f25  7d7a              dc.w     $7d7a
01016f27  2454              movea.l  (a4), a2
01016f29  3c3d              dc.w     $3c3d
01016f2b  4a2b6f3d          tst.b    $6f3d(a3)
01016f2f  4d75              dc.w     $4d75
01016f31  727a              moveq    #$7a, d1
01016f33  2454              movea.l  (a4), a2
01016f35  33434549          move.w   d3, $4549(a1)
01016f39  422b6d43          clr.b    $6d43(a3)
01016f3d  4e727a24          stop     #$7a24
01016f41  543b              dc.w     $543b
01016f43  4b4c              dc.w     $4b4c
01016f45  4a2b6c3c          tst.b    $6c3c(a3)
01016f49  4c72              dc.w     $4c72
01016f4b  7a24              moveq    #$24, d5
01016f4d  5426              addq.b   #$2, -(a6)
01016f4f  4e4a              trap     #$a
01016f51  506c2633          addq.w   #$8, $2633(a4)
01016f55  434c              dc.w     $434c
01016f57  727a              moveq    #$7a, d1
01016f59  2454              movea.l  (a4), a2
01016f5b  4a06              tst.b    d6
01016f5d  0c727a244c6e      cmpi.w   #$7a24, $6e(a2, d4.l)
01016f63  30354c7a          move.w   $7a(a5, d4.l), d0
01016f67  244c              movea.l  a4, a2
01016f69  6e30              bgt.b    $1016f9b
01016f6b  354c7a24          move.w   a4, $7a24(a2)
01016f6f  4c5b              dc.w     $4c5b
01016f71  303f              dc.w     $303f
01016f73  4c7a              dc.w     $4c7a
01016f75  244c              movea.l  a4, a2
01016f77  5b288628          subq.b   #$5, -$79d8(a0)
01016f7b  3f4c7a24          move.w   a4, $7a24(a7)
01016f7f  4c56              dc.w     $4c56
01016f81  305c              movea.w  (a4)+, a0
01016f83  4c7a              dc.w     $4c7a
01016f85  244c              movea.l  a4, a2
01016f87  56305c4c          addq.b   #$3, $4c(a0, d5.l)
01016f8b  7a24              moveq    #$24, d5
01016f8d  4c54              dc.w     $4c54
01016f8f  4027              negx.b   -(a7)
01016f91  8627              or.b     -(a7), d3
01016f93  31724c7a244c      move.w   $7a(a2, d4.l), $244c(a0)
01016f99  5440              addq.w   #$2, d0
01016f9b  2f31724c          move.l   $4c(a1, d7.w), -(a7)
01016f9f  7a24              moveq    #$24, d5
01016fa1  4d6e              dc.w     $4d6e
01016fa3  2f354d7a24574c5b2786  move.l   ([$24574c5b, a5], $2786), -(a7)
01016fad  273f              dc.w     $273f
01016faf  4c7d              dc.w     $4c7d
01016fb1  7a24              moveq    #$24, d5
01016fb3  6416              bcc.b    $1016fcb
01016fb5  5c2f5654          addq.b   #$6, $5654(a7)
01016fb9  7d7a              dc.w     $7d7a
01016fbb  2461              movea.l  -(a1), a2
01016fbd  1656              dc.w     $1656
01016fbf  402e315c          negx.b   $315c(a6)
01016fc3  5467              addq.w   #$2, -(a7)
01016fc5  7a24              moveq    #$24, d5
01016fc7  464c              dc.w     $464c
01016fc9  5448              addq.w   #$2, a0
01016fcb  2686              move.l   d6, (a3)
01016fcd  2634724c          move.l   $4c(a4, d7.w), d3
01016fd1  0d7a              dc.w     $0d7a
01016fd3  244e              movea.l  a6, a2
01016fd5  712e              dc.w     $712e
01016fd7  3e4e              movea.w  a6, a7
01016fd9  7a24              moveq    #$24, d5
01016fdb  4e5c              unlk     a4
01016fdd  2e56              movea.l  (a6), a7
01016fdf  4e7a244e          movec    invalid, d2
01016fe3  5640              addq.w   #$3, d0
01016fe5  2d317d4e          move.l   ([a1]), -(a6)
01016fe9  7a24              moveq    #$24, d5
01016feb  4e54712d          link.w   a4, #$712d
01016fef  3e4f              movea.w  a7, a7
01016ff1  7a24              moveq    #$24, d5
01016ff3  804e              dc.w     $804e
01016ff5  6340              bls.b    $1017037
01016ff7  2b31634e          move.l   ([a1]), -(a5)
01016ffb  577a              dc.w     $577a
01016ffd  2636634d          move.l   ([a6]), d3
01017001  54712b3e724d58262623  addq.w   #$2, ([$724d5826, a1], d2.l * 2, $2623)
0101700b  734e              dc.w     $734e
0101700d  6340              bls.b    $101704f
0101700f  2931634e          move.l   ([a1]), -(a4)
01017013  5c782626          addq.w   #$6, $2626.w
01017017  23734e547229      move.l   $54(a3, d4.l), $7229(a1)
0101701d  54724e5c          addq.w   #$2, $5c(a2, d4.l)
01017021  7826              moveq    #$26, d4
01017023  2508              move.l   a0, -(a2)
01017025  634f              bls.b    $1017076
01017027  647d              bcc.b    $10170a6
01017029  4d57              dc.w     $4d57
0101702b  804f              dc.w     $804f
0101702d  5755              subq.w   #$3, (a5)
0101702f  0b325157          btst.l   d5, ([a2])
01017033  827d              dc.w     $827d
01017035  517a              dc.w     $517a
01017037  3253              movea.w  (a3), a1
01017039  7a32              moveq    #$32, d5
0101703b  7252              moveq    #$52, d1
0101703d  7a26              moveq    #$26, d5
0101703f  887a2637          or.w     $1019678(pc), d4
01017043  876c0000          or.w     d3, $0(a4)
01017047  00530000          ori.w    #$0, (a3)
0101704b  00000000          ori.b    #$0, d0
0101704f  4800              nbcd.b   d0
01017051  0000295f          ori.b    #$5f, d0
01017055  00010002          ori.b    #$2, d1
01017059  00030004          ori.b    #$4, d3
0101705d  0101              btst.l   d0, d1
0101705f  04010402          subi.b   #$2, d1
01017063  0501              btst.l   d2, d1
01017065  1001              move.b   d1, d0
01017067  1101              move.b   d1, -(a0)
01017069  1102              move.b   d2, -(a0)
0101706b  1103              move.b   d3, -(a0)
0101706d  1401              move.b   d1, d2
0101706f  1501              move.b   d1, -(a2)
01017071  4001              negx.b   d1
01017073  4002              negx.b   d2
01017075  4101              chk.l    d1, d0
01017077  4401              neg.b    d1
01017079  4402              neg.b    d2
0101707b  4404              neg.b    d4
0101707d  4501              chk.l    d1, d2
0101707f  5001              addq.b   #$8, d1
01017081  5101              subq.b   #$8, d1
01017083  5201              addq.b   #$1, d1
01017085  5301              subq.b   #$1, d1
01017087  5401              addq.b   #$2, d1
01017089  5501              subq.b   #$2, d1
0101708b  5502              subq.b   #$2, d2
0101708d  5503              subq.b   #$2, d3
0101708f  5504              subq.b   #$2, d4
01017091  5506              subq.b   #$2, d6
01017093  5601              addq.b   #$3, d1
01017095  5801              addq.b   #$4, d1
01017097  5901              subq.b   #$4, d1
01017099  6401              bcc.b    $101709c
0101709b  6501              bcs.b    $101709e
0101709d  6601              bne.b    $10170a0
0101709f  6603              bne.b    $10170a4
010170a1  6801              bvc.b    $10170a4
010170a3  8001              or.b     d1, d0
010170a5  9401              sub.b    d1, d2
010170a7  9501              subx.b   d1, d2
010170a9  9601              sub.b    d1, d3
010170ab  9801              sub.b    d1, d4
010170ad  9901              subx.b   d1, d4
010170af  9902              subx.b   d2, d4
010170b1  9903              subx.b   d3, d4
010170b3  9a01              sub.b    d1, d5
010170b5  a601              dc.w     $a601
010170b7  a801              dc.w     $a801
010170b9  a901              dc.w     $a901
010170bb  aa01              dc.w     $aa01
010170bd  aa02              dc.w     $aa02
010170bf  aa03              dc.w     $aa03
010170c1  aa04              dc.w     $aa04
010170c3  aa06              dc.w     $aa06
010170c5  ab01              dc.w     $ab01
010170c7  ac01              dc.w     $ac01
010170c9  ae01              dc.w     $ae01
010170cb  ae02              dc.w     $ae02
010170cd  af01              dc.w     $af01
010170cf  b801              cmp.b    d1, d4
010170d1  b901              eor.b    d4, d1
010170d3  ba01              cmp.b    d1, d5
010170d5  ba02              cmp.b    d2, d5
010170d7  bb01              eor.b    d5, d1
010170d9  bb02              eor.b    d5, d2
010170db  bb03              eor.b    d5, d3
010170dd  bc01              cmp.b    d1, d6
010170df  be01              cmp.b    d1, d7
010170e1  bf01              eor.b    d7, d1
010170e3  c001              and.b    d1, d0
010170e5  c801              and.b    d1, d4
010170e7  d401              add.b    d1, d2
010170e9  d501              addx.b   d1, d2
010170eb  d901              addx.b   d1, d4
010170ed  e101              asl.b    #$8, d1
010170ef  e401              asr.b    #$2, d1
010170f1  e501              asl.b    #$2, d1
010170f3  e601              asr.b    #$3, d1
010170f5  e801              asr.b    #$4, d1
010170f7  ea01              asr.b    #$5, d1
010170f9  eb01              asl.b    #$5, d1
010170fb  ec01              asr.b    #$6, d1
010170fd  ee01              asr.b    #$7, d1
010170ff  ee02              asr.b    #$7, d2
01017101  ee03              asr.b    #$7, d3
01017103  ef01              asl.b    #$7, d1
01017105  fa01fb01          fmovem   invalid, d1
01017109  fc01fe01          fmovem   invalid, d1
0101710d  ff01              dc.w     $ff01
0101710f  ff02              dc.w     $ff02
01017111  ff04              dc.w     $ff04
01017113  173a3631          move.b   $101a746(pc), -(a3)
01017117  191a              move.b   (a2)+, -(a4)
01017119  0900              btst.l   d4, d0
0101711b  0510              btst.l   d2, (a0)
0101711d  5136173a36441a121000  subq.b   #$8, ([$36441a12, a6, d1.w * 8], $1000)
01017127  045b3617          subi.w   #$3617, (a3)+
0101712b  3a353850          move.w   $50(a5, d3.l), d5
0101712f  1109              dc.w     $1109
01017131  0800              dc.w     $0800
01017133  0504              btst.l   d2, d4
01017135  5251              addq.w   #$1, (a1)
01017137  3518              move.w   (a0)+, -(a2)
01017139  5b3545311a111008  subq.b   #$5, ([$1a111008, a5, d4.w * 4]) ; $1a111008 = RAM MWF mirrors (non-Turbo mono only)
01017141  00045145          ori.b    #$45, d4
01017145  3518              move.w   (a0)+, -(a2)
01017147  35385131          move.w   $5131.w, -(a2)
0101714b  1600              move.b   d0, d3
0101714d  0801              dc.w     $0801
0101714f  04513851          subi.w   #$3851, (a1)
01017153  3418              move.w   (a0)+, d2
01017155  353a2431          move.w   $1019588(pc), -(a2)
01017159  1210              move.b   (a0), d1
0101715b  0104              btst.l   d0, d4
0101715d  51383f34          subq.b   #$8, $3f34.w
01017161  18353e21          move.b   $21(a5, d3.l), d4
01017165  3116              move.w   (a6), -(a0)
01017167  0309513a          movep.w  $513a(a1), d1
0101716b  54341835          addq.b   #$2, $35(a4, d1.l)
0101716f  4e1f              dc.w     $4e1f
01017171  260e              move.l   a6, d3
01017173  1001              move.b   d1, d0
01017175  0804              dc.w     $0804
01017177  5142              subq.w   #$8, d2
01017179  3418              move.w   (a0)+, d2
0101717b  34382921          move.w   $2921.w, d2
0101717f  3116              move.w   (a6), -(a0)
01017181  0310              btst.l   d1, (a0)
01017183  513a              dc.w     $513a
01017185  5451              addq.w   #$2, (a1)
01017187  3318              move.w   (a0)+, -(a1)
01017189  343a1a1f          move.w   $1018baa(pc), d2
0101718d  260e              move.l   a6, d3
0101718f  020e              dc.w     $020e
01017191  0754              bchg.b   d3, (a4)
01017193  4146              dc.w     $4146
01017195  3f331834          move.w   $34(a3, d1.l), -(a7)
01017199  3e09              move.w   a1, d7
0101719b  1a2b150e          move.b   $150e(a3), d5
0101719f  000e              dc.w     $000e
010171a1  0409              dc.w     $0409
010171a3  5157              subq.w   #$8, (a7)
010171a5  5c54              addq.w   #$6, (a4)
010171a7  3318              move.w   (a0)+, -(a1)
010171a9  344d              movea.w  a5, a2
010171ab  111f              move.b   (a7)+, -(a0)
010171ad  260e              move.l   a6, d3
010171af  0104              btst.l   d0, d4
010171b1  0514              btst.l   d2, (a4)
010171b3  5241              addq.w   #$1, d1
010171b5  5c59              addq.w   #$6, (a1)+
010171b7  3318              move.w   (a0)+, -(a1)
010171b9  33382709          move.w   $2709.w, -(a1)
010171bd  1a2b0e00          move.b   $e00(a3), d5
010171c1  0f091a54          movep.w  $1a54(a1), d7
010171c5  575c              subq.w   #$3, (a4)+
010171c7  5b51              subq.w   #$5, (a1)
010171c9  18333800          move.b   (a3, d3.l), d4
010171cd  051a              btst.l   d2, (a2)+
010171cf  220e              move.l   a6, d1
010171d1  00061116          ori.b    #$16, d6
010171d5  5946              subq.w   #$4, d6
010171d7  5c5b              addq.w   #$6, (a3)+
010171d9  5118              subq.b   #$8, (a0)+
010171db  333a0004          move.w   $10171e1(pc), -(a1)
010171df  0d20              btst.l   d6, -(a0)
010171e1  0e05              dc.w     $0e05
010171e3  0e09              dc.w     $0e09
010171e5  0d1a              btst.l   d6, (a2)+
010171e7  545d              addq.w   #$2, (a5)+
010171e9  593f              dc.w     $593f
010171eb  18333901          move.b   ([a3, d3.l]), d4
010171ef  1119              move.b   (a1)+, -(a0)
010171f1  1000              move.b   d0, d0
010171f3  0514              btst.l   d2, (a4)
010171f5  1a0d              dc.w     $1a0d
010171f7  595c              subq.w   #$4, (a4)+
010171f9  5b54              subq.w   #$5, (a4)
010171fb  5818              addq.b   #$4, (a0)+
010171fd  333e              dc.w     $333e
010171ff  01090c0e          movep.w  $c0e(a1), d0
01017203  0b14              btst.l   d5, (a4)
01017205  1a57              dc.w     $1a57
01017207  5c59              addq.w   #$6, (a1)+
01017209  413a1833          chk.l    $1018a3e(pc), d0
0101720d  3d11              move.w   (a1), -(a6)
0101720f  00051116          ori.b    #$16, d5
01017213  0511              btst.l   d2, (a1)
01017215  1c5c              dc.w     $1c5c
01017217  5b54              subq.w   #$5, (a4)
01017219  5154              subq.w   #$8, (a4)
0101721b  18334e09          move.b   $9(a3, d4.l), d4
0101721f  0004080e          ori.b    #$e, d4
01017223  0a111b5c          eori.b   #$5c, (a1)
01017227  593f              dc.w     $593f
01017229  3a381833          move.w   $1833.w, d5
0101722d  4e19              dc.w     $4e19
0101722f  0e00              dc.w     $0e00
01017231  0511              btst.l   d2, (a1)
01017233  1419              move.b   (a1)+, d2
01017235  1c5b              dc.w     $1c5b
01017237  54343818          addq.b   #$2, $18(a4, d3.l)
0101723b  38291a09          move.w   $1a09(a1), d4
0101723f  0008              dc.w     $0008
01017241  160a              dc.w     $160a
01017243  141b              move.b   (a3)+, d2
01017245  593f              dc.w     $593f
01017247  3424              move.w   -(a4), d2
01017249  18382a1a          move.b   $2a1a.w, d4
0101724d  1911              move.b   (a1), -(a4)
0101724f  0511              btst.l   d2, (a1)
01017251  141d              move.b   (a5)+, d2
01017253  54332d2f18382d1a1600  addq.b   #$2, ([$1838, a3], d2.l * 4, $2d1a1600)
0101725d  1a16              move.b   (a6), d5
0101725f  141c              move.b   (a4)+, d2
01017261  51302518          subq.b   #$8, (a0, d2.w * 4)
01017265  38332423          move.w   $23(a3, d2.w), d4
01017269  190e              dc.w     $190e
0101726b  1114              move.b   (a4), -(a0)
0101726d  1d4b              dc.w     $1d4b
0101726f  2d1a              move.l   (a2)+, -(a6)
01017271  1f18              move.b   (a0)+, -(a7)
01017273  3833322c          move.w   $2c(a3, d3.w), d4
01017277  2908              move.l   a0, -(a4)
01017279  1e4f              dc.w     $1e4f
0101727b  231b              move.l   (a3)+, -(a1)
0101727d  1f18              move.b   (a0)+, -(a7)
0101727f  3a343023          move.w   $23(a4, d3.w), d5
01017283  1914              move.b   (a4), -(a4)
01017285  0d1d              btst.l   d6, (a5)+
01017287  4a1c              tst.b    (a4)+
01017289  1118              move.b   (a0)+, -(a0)
0101728b  3a352c2b          move.w   $2b(a5, d2.l), d5
0101728f  1e4a              dc.w     $1e4a
01017291  1a0b              dc.w     $1a0b
01017293  183a4034          move.b   $101b2c9(pc), d4
01017297  221e              move.l   (a6)+, d1
01017299  4913              chk.l    (a3), d4
0101729b  183b5154          move.b   (a16, invalid.w), d4
0101729f  33311e47          move.w   $47(a1, d1.l), -(a1)
010172a3  04000800          subi.b   #$0, d0
010172a7  183a5943          move.b   $101cbec(pc), d4
010172ab  311e              move.w   (a6)+, -(a0)
010172ad  4703              chk.l    d3, d3
010172af  183a5b56          move.b   $101ce07(pc), d4
010172b3  531e              subq.b   #$1, (a6)+
010172b5  4803              nbcd.b   d3
010172b7  183a5e5a          move.b   $101d113(pc), d4
010172bb  1e4c              dc.w     $1e4c
010172bd  0a08              dc.w     $0a08
010172bf  00183a5e          ori.b    #$5e, (a0)+
010172c3  5a1e              addq.b   #$5, (a6)+
010172c5  4a28120e          tst.b    $120e(a0)
010172c9  183a5e5a          move.b   $101d125(pc), d4
010172cd  1e4a              dc.w     $1e4a
010172cf  1b16              move.b   (a6), -(a5)
010172d1  0918              btst.l   d4, (a0)+
010172d3  3a5c              movea.w  (a4)+, a5
010172d5  575b              subq.w   #$3, (a3)+
010172d7  5450              addq.w   #$2, (a0)
010172d9  1e4f              dc.w     $1e4f
010172db  231b              move.l   (a3)+, -(a1)
010172dd  1118              move.b   (a0)+, -(a0)
010172df  3a5c              movea.w  (a4)+, a5
010172e1  423f              dc.w     $423f
010172e3  311e              move.w   (a6)+, -(a0)
010172e5  4b2c1c18          chk.l    $1c18(a4), d5
010172e9  3c55              movea.w  (a5), a6
010172eb  5133311e4f25      subq.b   #$8, ([a3], d3.w, $4f25)
010172f1  1a18              move.b   (a0)+, d5
010172f3  3841              movea.w  d1, a4
010172f5  34322b1e5132      move.w   ([a2], d2.l * 2, $5132), d2
010172fb  2e18              move.l   (a0)+, d7
010172fd  38352422          move.w   $22(a5, d2.w), d4
01017301  1e51              dc.w     $1e51
01017303  33302423          move.w   $23(a0, d2.w), -(a1)
01017307  1838332e          move.b   $332e.w, d4
0101730b  191e              move.b   (a6)+, -(a4)
0101730d  51342d18          subq.b   #$8, (a4, d2.l * 4)
01017311  381f              move.w   (a7)+, d4
01017313  2423              move.l   -(a3), d2
01017315  1a19              move.b   (a1)+, d5
01017317  3751351a          move.w   (a1), $351a(a3)
0101731b  00550000          ori.w    #$0, (a5)
0101731f  00000000          ori.b    #$0, d0
01017323  4800              nbcd.b   d0
01017325  00002952          ori.b    #$52, d0
01017329  aeaa              dc.w     $aeaa
0101732b  aaaa              dc.w     $aaaa
0101732d  aaa8              dc.w     $aaa8
0101732f  5455              addq.w   #$2, (a5)
01017331  1100              move.b   d0, -(a0)
01017333  0441eaaa          subi.w   #$eaaa, d1
01017337  aaaa              dc.w     $aaaa
01017339  aa52              dc.w     $aa52
0101733b  aeaa              dc.w     $aeaa
0101733d  aaaa              dc.w     $aaaa
0101733f  aabc              dc.w     $aabc

; ---- gap 01017346..01017386 (65 bytes) ----
01017346  01fe              dc.w     $01fe
01017348  aaaa              dc.w     $aaaa
0101734a  aaaa              dc.w     $aaaa
0101734c  52aeaaaa          addq.l   #$1, -$5556(a6)
01017350  aaab              dc.w     $aaab
01017352  e844              asr.w    #$4, d4
01017354  1110              move.b   (a0), -(a0)
01017356  000401eb          ori.b    #$eb, d4
0101735a  eaaa              lsr.l    d5, d2
0101735c  aaaa              dc.w     $aaaa
0101735e  53fe              dc.w     $53fe
01017360  aaaa              dc.w     $aaaa
01017362  aabd              dc.w     $aabd
01017364  4055              negx.w   (a5)
01017366  4441              neg.w    d1
01017368  1000              move.b   d0, d0
0101736a  01c1              bset.b   d0, d1
0101736c  7eaa              moveq    #$aa, d7
0101736e  aaaa              dc.w     $aaaa
01017370  53aaaaaa          subq.l   #$1, -$5556(a2)
01017374  abe8              dc.w     $abe8
01017376  00510010          ori.w    #$10, (a1)
0101737a  000001c0          ori.b    #$c0, d0
0101737e  2bea              dc.w     $2bea
01017380  aaaa              dc.w     $aaaa
01017382  53aaaaaa          subq.l   #$1, -$5556(a2)
01017386  ae40              dc.w     $ae40

; ---- gap 0101738d..010175d5 (585 bytes) ----
0101738d  0001c101          ori.b    #$1, d1
01017391  baaaaa53          cmp.l    -$55ad(a2), d5
01017395  aaaa              dc.w     $aaaa
01017397  aab9              dc.w     $aab9
01017399  1100              move.b   d0, -(a0)
0101739b  5100              subq.b   #$8, d0
0101739d  00000011          ori.b    #$11, d0
010173a1  c044              and.w    d4, d0
010173a3  6eaa              bgt.b    $101734f
010173a5  aa53              dc.w     $aa53
010173a7  aaaa              dc.w     $aaaa
010173a9  aae4              dc.w     $aae4
010173ab  4440              neg.w    d0
010173ad  4041              negx.w   d1
010173af  00001001          ori.b    #$1, d0
010173b3  c111              and.b    d0, (a1)
010173b5  1baaaa53aaaa      move.b   -$55ad(a2), -$56(a5, a2.l)
010173bb  ab99              dc.w     $ab99
010173bd  5110              subq.b   #$8, (a0)
010173bf  5100              subq.b   #$8, d0
010173c1  00000041          ori.b    #$41, d0
010173c5  c445              and.w    d5, d2
010173c7  66ea              bne.b    $10173b3
010173c9  aa53              dc.w     $aa53
010173cb  aaaa              dc.w     $aaaa
010173cd  ae65              dc.w     $ae65
010173cf  1444              dc.w     $1444
010173d1  4000              negx.b   d0
010173d3  00004005          ori.b    #$5, d0
010173d7  d114              add.b    d0, (a4)
010173d9  59ba              dc.w     $59ba
010173db  aa53              dc.w     $aa53
010173dd  aaaa              dc.w     $aaaa
010173df  ba59              cmp.w    (a1)+, d5
010173e1  5510              subq.b   #$2, (a0)
010173e3  5040              addq.w   #$8, d0
010173e5  00400111          ori.w    #$111, d0
010173e9  c455              and.w    (a5), d2
010173eb  65ae              bcs.b    $101739b
010173ed  aa53              dc.w     $aa53
010173ef  aaaa              dc.w     $aaaa
010173f1  eaa6              asr.l    d5, d6
010173f3  6550              bcs.b    $1017445
010173f5  4000              negx.b   d0
010173f7  00010445          ori.b    #$45, d1
010173fb  c559              and.w    d2, (a1)+
010173fd  9aabaa53          sub.l    -$55ad(a3), d5
01017401  aaab              dc.w     $aaab
01017403  aaa9              dc.w     $aaa9
01017405  9954              sub.w    d4, (a4)
01017407  4000              negx.b   d0
01017409  4040              negx.w   d0
0101740b  1155d566          move.b   (a5), -$2a9a(a0)
0101740f  6aaa              bpl.b    $10173bb
01017411  ea53              roxr.w   #$5, d3
01017413  aaab              dc.w     $aaab
01017415  baaa6654          cmp.l    $6654(a2), d5
01017419  4000              negx.b   d0
0101741b  04044451          subi.b   #$51, d4
0101741f  d599              add.l    d2, (a1)+
01017421  aaae              dc.w     $aaae
01017423  ea53              roxr.w   #$5, d3
01017425  aaae              dc.w     $aaae
01017427  eeaa              lsr.l    d7, d2
01017429  a998              dc.w     $a998
0101742b  4004              negx.b   d4
0101742d  4011              negx.b   (a1)
0101742f  1555e66a          move.b   (a5), -$1996(a2)
01017433  aabb              dc.w     $aabb
01017435  ba53              cmp.w    (a3), d5
01017437  aaae              dc.w     $aaae
01017439  bbaaaa64          eor.l    d5, -$559c(a2)
0101743d  4100              chk.l    d0, d0
0101743f  04455515          subi.w   #$5515, d5
01017443  d9aaaaee          add.l    d4, -$5512(a2)
01017447  ba53              cmp.w    (a3), d5
01017449  aabb              dc.w     $aabb
0101744b  eeee              dc.w     $eeee
0101744d  ba98              cmp.l    (a0)+, d5
0101744f  4011              negx.b   (a1)
01017451  1111              move.b   (a1), -(a0)
01017453  4555              dc.w     $4555
01017455  e6ae              lsr.l    d3, d6
01017457  bbbb              dc.w     $bbbb
01017459  ee53              roxr.w   #$7, d3
0101745b  aabb              dc.w     $aabb
0101745d  fbbb              dc.w     $fbbb
0101745f  aaa4              dc.w     $aaa4
01017461  5104              subq.b   #$8, d4
01017463  4455              neg.w    (a5)
01017465  5555              subq.w   #$2, (a5)
01017467  daaaeeef          add.l    -$1111(a2), d5
0101746b  ee53              roxr.w   #$7, d3
0101746d  aaef              dc.w     $aaef
0101746f  beeeeba8          cmpa.w   -$1458(a6), a7
01017473  4011              negx.b   (a1)
01017475  11445555          move.b   d4, $5555(a0)
01017479  eaeb              dc.w     $eaeb
0101747b  bbbe              dc.w     $bbbe
0101747d  fb53              frestore (a3)
0101747f  aaef              dc.w     $aaef
01017481  fffb              dc.w     $fffb
01017483  bab84445          cmp.l    $4445.w, d5
01017487  5455              addq.w   #$2, (a5)
01017489  5555              subq.w   #$2, (a5)
0101748b  eeae              lsr.l    d7, d6
0101748d  efff              dc.w     $efff
0101748f  fb53              frestore (a3)
01017491  abbf              dc.w     $abbf
01017493  ffbe              dc.w     $ffbe
01017495  eee8              dc.w     $eee8
01017497  5111              subq.b   #$8, (a1)
01017499  11455555          move.b   d5, $5555(a0)
0101749d  ebbb              rol.l    d5, d3
0101749f  beff              dc.w     $beff
010174a1  fe53abbf          ftrapueq.b (a3)
010174a5  bffbbbac4445      cmpa.l   $4445(a3.l * 2), a7
010174ab  5555              subq.w   #$2, (a5)
010174ad  5555              subq.w   #$2, (a5)
010174af  faeeeffefe53      fbf.l    $f1007304                   ; $f1007304 = NextBus slot space
010174b5  abbb              dc.w     $abbb
010174b7  efff              dc.w     $efff
010174b9  eee8              dc.w     $eee8
010174bb  5551              subq.w   #$2, (a1)
010174bd  4555              dc.w     $4555
010174bf  5555              subq.w   #$2, (a5)
010174c1  ebbb              rol.l    d5, d3
010174c3  fffb              dc.w     $fffb
010174c5  ee53              roxr.w   #$7, d3
010174c7  abbf              dc.w     $abbf
010174c9  beff              dc.w     $beff
010174cb  fbb8              dc.w     $fbb8
010174cd  4445              neg.w    d5
010174cf  5555              subq.w   #$2, (a5)
010174d1  5555              subq.w   #$2, (a5)
010174d3  eeef              dc.w     $eeef
010174d5  ffbe              dc.w     $ffbe
010174d7  fe53abbb          ftrapole.b (a3)
010174db  ffef              dc.w     $ffef
010174dd  feec55555555      fbf.l    $5656ca34
010174e3  5555              subq.w   #$2, (a5)
010174e5  fbbf              dc.w     $fbbf
010174e7  fbff              dc.w     $fbff
010174e9  ee53              roxr.w   #$7, d3
010174eb  aeee              dc.w     $aeee
010174ed  eeff              dc.w     $eeff
010174ef  eff845155555      bfins    d4, $5555.w{20:21}
010174f5  5555              subq.w   #$2, (a5)
010174f7  effb              dc.w     $effb
010174f9  ffbb              dc.w     $ffbb
010174fb  bb53              eor.w    d5, (a3)
010174fd  aebb              dc.w     $aebb
010174ff  bbbb              dc.w     $bbbb
01017501  ffbc              dc.w     $ffbc
01017503  5555              subq.w   #$2, (a5)
01017505  5555              subq.w   #$2, (a5)
01017507  5555              subq.w   #$2, (a5)
01017509  feffeeeeee53      fbf.l    $eff0635e
0101750f  aeee              dc.w     $aeee
01017511  eeee              dc.w     $eeee
01017513  effc              dc.w     $effc
01017515  5555              subq.w   #$2, (a5)
01017517  5555              subq.w   #$2, (a5)
01017519  5555              subq.w   #$2, (a5)
0101751b  fffb              dc.w     $fffb
0101751d  bbbb              dc.w     $bbbb
0101751f  bb53              eor.w    d5, (a3)
01017521  aebb              dc.w     $aebb
01017523  bbbb              dc.w     $bbbb
01017525  bbb85555          eor.l    d5, $5555.w
01017529  5555              subq.w   #$2, (a5)
0101752b  5555              subq.w   #$2, (a5)
0101752d  eeee              dc.w     $eeee
0101752f  eeee              dc.w     $eeee
01017531  ee53              roxr.w   #$7, d3
01017533  aeee              dc.w     $aeee
01017535  eaea              dc.w     $eaea
01017537  aaec              dc.w     $aaec
01017539  5555              subq.w   #$2, (a5)
0101753b  5555              subq.w   #$2, (a5)
0101753d  5555              subq.w   #$2, (a5)
0101753f  fbaa              dc.w     $fbaa
01017541  abab              dc.w     $abab
01017543  bb53              eor.w    d5, (a3)
01017545  aee6              dc.w     $aee6
01017547  9aaaaaa4          sub.l    -$555c(a2), d5
0101754b  5555              subq.w   #$2, (a5)
0101754d  5555              subq.w   #$2, (a5)
0101754f  5555              subq.w   #$2, (a5)
01017551  daaaaaa6          add.l    -$555a(a2), d5
01017555  9b53              sub.w    d5, (a3)
01017557  aeaa              dc.w     $aeaa
01017559  a9a9              dc.w     $a9a9
0101755b  9998              sub.l    d4, (a0)+
0101755d  5555              subq.w   #$2, (a5)
0101755f  5555              subq.w   #$2, (a5)
01017561  5555              subq.w   #$2, (a5)
01017563  e666              asr.w    d3, d6
01017565  6a6a              bpl.b    $10175d1
01017567  aa53              dc.w     $aa53
01017569  aeaa              dc.w     $aeaa
0101756b  6a66              bpl.b    $10175d3
0101756d  6654              bne.b    $10175c3
0101756f  5555              subq.w   #$2, (a5)
01017571  5555              subq.w   #$2, (a5)
01017573  5555              subq.w   #$2, (a5)
01017575  d599              add.l    d2, (a1)+
01017577  99a9aa53          sub.l    d4, -$55ad(a1)
0101757b  aea6              dc.w     $aea6
0101757d  a999              dc.w     $a999
0101757f  9550              sub.w    d2, (a0)
01017581  5555              subq.w   #$2, (a5)
01017583  5555              subq.w   #$2, (a5)
01017585  5555              subq.w   #$2, (a5)
01017587  c556              and.w    d2, (a6)
01017589  666a              bne.b    $10175f5
0101758b  9a53              sub.w    (a3), d5
0101758d  aeaa              dc.w     $aeaa
0101758f  6666              bne.b    $10175f7
01017591  5544              subq.w   #$2, d4
01017593  5555              subq.w   #$2, (a5)
01017595  5555              subq.w   #$2, (a5)
01017597  5555              subq.w   #$2, (a5)
01017599  d155              add.w    d0, (a5)
0101759b  9999              sub.l    d4, (a1)+
0101759d  aa53              dc.w     $aa53
0101759f  ae99              dc.w     $ae99
010175a1  9995              sub.l    d4, (a5)
010175a3  5510              subq.b   #$2, (a0)
010175a5  5555              subq.w   #$2, (a5)
010175a7  5555              subq.w   #$2, (a5)
010175a9  5555              subq.w   #$2, (a5)
010175ab  c455              and.w    (a5), d2
010175ad  5666              addq.w   #$3, -(a6)
010175af  6653              bne.b    $1017604
010175b1  aea6              dc.w     $aea6
010175b3  6555              bcs.b    img_arrow_1
010175b5  5440              addq.w   #$2, d0
010175b7  5555              subq.w   #$2, (a5)
010175b9  5555              subq.w   #$2, (a5)
010175bb  5555              subq.w   #$2, (a5)
010175bd  c115              and.b    d0, (a5)
010175bf  5559              subq.w   #$2, (a1)+
010175c1  9a53              sub.w    (a3), d5
010175c3  ab59              dc.w     $ab59
010175c5  9555              sub.w    d2, (a5)
010175c7  1104              move.b   d4, -(a0)
010175c9  5555              subq.w   #$2, (a5)
010175cb  5555              subq.w   #$2, (a5)
010175cd  5555              subq.w   #$2, (a5)
010175cf  d044              add.w    d4, d0
010175d1  5556              subq.w   #$2, (a6)
010175d3  6553              bcs.b    $1017628
010175d5  ab55              dc.w     $ab55

; ---- gap 010175db..01017fee (2580 bytes) ----
010175db  5555              subq.w   #$2, (a5)
010175dd  5555              subq.w   #$2, (a5)
010175df  5555              subq.w   #$2, (a5)
010175e1  c011              and.b    (a1), d0
010175e3  5555              subq.w   #$2, (a5)
010175e5  5553              subq.w   #$2, (a3)
010175e7  ab55              dc.w     $ab55
010175e9  5551              subq.w   #$2, (a1)
010175eb  1000              move.b   d0, d0
010175ed  5555              subq.w   #$2, (a5)
010175ef  5555              subq.w   #$2, (a5)
010175f1  5555              subq.w   #$2, (a5)
010175f3  c004              and.b    d4, d0
010175f5  4555              dc.w     $4555
010175f7  5553              subq.w   #$2, (a3)
010175f9  ab55              dc.w     $ab55
010175fb  5444              addq.w   #$2, d4
010175fd  4444              neg.w    d4
010175ff  aaaa              dc.w     $aaaa
01017601  aaaa              dc.w     $aaaa
01017603  aaaa              dc.w     $aaaa
01017605  d111              add.b    d0, (a1)
01017607  1115              move.b   (a5), -(a0)
01017609  5555              subq.w   #$2, (a5)
0101760b  00000000          ori.b    #$0, d0
0101760f  00001000          ori.b    #$0, d0
01017613  00001111          ori.b    #$11, d0
01017617  13d145044ff5      move.b   (a1), $45044ff5.l
0101761d  5511              subq.b   #$2, (a1)
0101761f  3ffc              dc.w     $3ffc
01017621  5545              subq.w   #$2, d5
01017623  ffff              dc.w     $ffff
01017625  5513              subq.b   #$2, (a3)
01017627  ffff              dc.w     $ffff
01017629  d54f              addx.w   -(a7), -(a2)
0101762b  ffff              dc.w     $ffff
0101762d  f57f              dc.w     $f57f
0101762f  ffff              dc.w     $ffff
01017631  fdff              dc.w     $fdff
01017633  ffff              dc.w     $ffff
01017635  ffff              dc.w     $ffff
01017637  ffff              dc.w     $ffff
01017639  ff15              fsave    (a5)
0101763b  ffff              dc.w     $ffff
0101763d  5555              subq.w   #$2, (a5)
0101763f  ffff              dc.w     $ffff
01017641  5555              subq.w   #$2, (a5)
01017643  ffff              dc.w     $ffff
01017645  5555              subq.w   #$2, (a5)
01017647  ffff              dc.w     $ffff
01017649  5555              subq.w   #$2, (a5)
0101764b  ffff              dc.w     $ffff
0101764d  5555              subq.w   #$2, (a5)
0101764f  ffff              dc.w     $ffff
01017651  5555              subq.w   #$2, (a5)
01017653  ffff              dc.w     $ffff
01017655  5555              subq.w   #$2, (a5)
01017657  ffff              dc.w     $ffff
01017659  5555              subq.w   #$2, (a5)
0101765b  00000000          ori.b    #$0, d0
0101765f  00001000          ori.b    #$0, d0
01017663  00001100          ori.b    #$0, d0
01017667  03c0              bset.b   d1, d0
01017669  00000ff0          ori.b    #$f0, d0
0101766d  4040              negx.w   d0
0101766f  3ffc              dc.w     $3ffc
01017671  0100              btst.l   d0, d0
01017673  ffff              dc.w     $ffff
01017675  0403ffff          subi.b   #$ff, d3
01017679  d10f              addx.b   -(a7), -(a0)
0101767b  ffff              dc.w     $ffff
0101767d  f43f              cpusha   #$0
0101767f  ffff              dc.w     $ffff
01017681  fdff              dc.w     $fdff
01017683  ffff              dc.w     $ffff
01017685  ffff              dc.w     $ffff
01017687  ffff              dc.w     $ffff
01017689  ff04              dc.w     $ff04
0101768b  ffff              dc.w     $ffff
0101768d  5511              subq.b   #$2, (a1)
0101768f  ffff              dc.w     $ffff
01017691  5545              subq.w   #$2, d5
01017693  ffff              dc.w     $ffff
01017695  5511              subq.b   #$2, (a1)
01017697  ffff              dc.w     $ffff
01017699  5545              subq.w   #$2, d5
0101769b  ffff              dc.w     $ffff
0101769d  5551              subq.w   #$2, (a1)
0101769f  ffff              dc.w     $ffff
010176a1  5545              subq.w   #$2, d5
010176a3  ffff              dc.w     $ffff
010176a5  5555              subq.w   #$2, (a5)
010176a7  ffff              dc.w     $ffff
010176a9  5555              subq.w   #$2, (a5)
010176ab  00000000          ori.b    #$0, d0
010176af  00001000          ori.b    #$0, d0
010176b3  00001155          ori.b    #$55, d0
010176b7  13c004444ff1      move.b   d0, $4444ff1.l              ; $04444ff1 = RAM bank 0 (Turbo: 32 MB stride)
010176bd  00113ffc          ori.b    #$fc, (a1)
010176c1  0444ffff          subi.w   #$ffff, d4
010176c5  0003ffff          ori.b    #$ff, d3
010176c9  c04f              dc.w     $c04f
010176cb  ffff              dc.w     $ffff
010176cd  f03fffff          fmovem   invalid, 
010176d1  fcffffffffff      fbf.l    $10176d2
010176d7  ffff              dc.w     $ffff
010176d9  ff00              dc.w     $ff00
010176db  ffff              dc.w     $ffff
010176dd  4040              negx.w   d0
010176df  ffff              dc.w     $ffff
010176e1  0100              btst.l   d0, d0
010176e3  ffff              dc.w     $ffff
010176e5  0400ffff          subi.b   #$ff, d0
010176e9  1100              move.b   d0, -(a0)
010176eb  ffff              dc.w     $ffff
010176ed  4404              neg.b    d4
010176ef  ffff              dc.w     $ffff
010176f1  1500              move.b   d0, -(a2)
010176f3  ffff              dc.w     $ffff
010176f5  5511              subq.b   #$2, (a1)
010176f7  ffff              dc.w     $ffff
010176f9  4555              dc.w     $4555
010176fb  00000000          ori.b    #$0, d0
010176ff  00002000          ori.b    #$0, d0
01017703  000014a8          ori.b    #$a8, d0
01017707  503f              dc.w     $503f
01017709  ffff              dc.w     $ffff
0101770b  fc01e9a8          fmovem   d2, d1
0101770f  43fa9544          lea.l    $1010c55(pc), a1
01017713  0c41eab8          cmpi.w   #$eab8, d1
01017717  0eea              dc.w     $0eea
01017719  7550              dc.w     $7550
0101771b  0ea5              dc.w     $0ea5
0101771d  e9a8              lsl.l    d4, d0
0101771f  0eea              dc.w     $0eea
01017721  bd44              eor.w    d6, d4
01017723  0ea1              dc.w     $0ea1
01017725  e6ec3aea          ror.w    $3aea(a4)
01017729  7350              dc.w     $7350
0101772b  0ea5              dc.w     $0ea5
0101772d  e9b8              rol.l    d4, d0
0101772f  3abe              dc.w     $3abe
01017731  b1c4              cmpa.l   d4, a0
01017733  0ea5              dc.w     $0ea5
01017735  e6ec3a67          ror.w    $3a67(a4)
01017739  f0700ea1d9b83a95011f  fssub.b  $3a95011f(a5.l)
01017743  fea5e5ec          fbf.w    $1015d31
01017747  3a64              movea.w  -(a4), a5
01017749  4057              negx.w   (a7)
0101774b  aaa5              dc.w     $aaa5
0101774d  d5f83a95          adda.l   $3a95.w, a2
01017751  0115              btst.l   d0, (a5)
01017753  eaa5              asr.l    d5, d5
01017755  d4fc5e64          adda.w   #$5e64, a2
01017759  4055              negx.w   (a5)
0101775b  7955              dc.w     $7955
0101775d  d1fc5e950115      adda.l   #$5e950115, a0
01017763  ea55              roxr.w   #$5, d5
01017765  c4bc47e44057      and.l    #$47e44057, d2
0101776b  a955              dc.w     $a955
0101776d  d0ec517d          adda.w   $517d(a4), a0
01017771  011e              btst.l   d0, (a6)+
01017773  a555              dc.w     $a555
01017775  c4b84517          and.l    $4517.w, d2
01017779  f07a9555d0a8      ftrapole.w #$d0a8
0101777f  5551              subq.w   #$2, (a1)
01017781  71ea              dc.w     $71ea
01017783  5555              subq.w   #$2, (a5)
01017785  c064              and.w    -(a4), d0
01017787  4445              neg.w    d5
01017789  73a9              dc.w     $73a9
0101778b  5555              subq.w   #$2, (a5)
0101778d  c198              and.l    d0, (a0)+
0101778f  5555              subq.w   #$2, (a5)
01017791  7ea5              moveq    #$a5, d7
01017793  5555              subq.w   #$2, (a5)
01017795  c454              and.w    (a4), d2
01017797  4515              chk.l    (a5), d2
01017799  7695              moveq    #$95, d3
0101779b  5555              subq.w   #$2, (a5)
0101779d  d554              add.w    d2, (a4)
0101779f  5555              subq.w   #$2, (a5)
010177a1  5655              addq.w   #$3, (a5)
010177a3  5555              subq.w   #$2, (a5)
010177a5  e653              roxr.w   #$3, d3
010177a7  00000000          ori.b    #$0, d0
010177ab  00005000          ori.b    #$0, d0
010177af  00002934          ori.b    #$34, d0
010177b3  00010002          ori.b    #$2, d1
010177b7  00030004          ori.b    #$4, d3
010177bb  0101              btst.l   d0, d1
010177bd  04010402          subi.b   #$2, d1
010177c1  0501              btst.l   d2, d1
010177c3  1001              move.b   d1, d0
010177c5  1101              move.b   d1, -(a0)
010177c7  1102              move.b   d2, -(a0)
010177c9  1103              move.b   d3, -(a0)
010177cb  1501              move.b   d1, -(a2)
010177cd  4001              negx.b   d1
010177cf  4002              negx.b   d2
010177d1  4101              chk.l    d1, d0
010177d3  4401              neg.b    d1
010177d5  4402              neg.b    d2
010177d7  4501              chk.l    d1, d2
010177d9  5001              addq.b   #$8, d1
010177db  5101              subq.b   #$8, d1
010177dd  5201              addq.b   #$1, d1
010177df  5301              subq.b   #$1, d1
010177e1  5401              addq.b   #$2, d1
010177e3  5501              subq.b   #$2, d1
010177e5  5502              subq.b   #$2, d2
010177e7  5503              subq.b   #$2, d3
010177e9  5504              subq.b   #$2, d4
010177eb  5506              subq.b   #$2, d6
010177ed  a801              dc.w     $a801
010177ef  aa01              dc.w     $aa01
010177f1  aa02              dc.w     $aa02
010177f3  aa03              dc.w     $aa03
010177f5  aa04              dc.w     $aa04
010177f7  aa06              dc.w     $aa06
010177f9  ab01              dc.w     $ab01
010177fb  ae01              dc.w     $ae01
010177fd  af01              dc.w     $af01
010177ff  b501              eor.b    d2, d1
01017801  ba01              cmp.b    d1, d5
01017803  bc01              cmp.b    d1, d6
01017805  bf01              eor.b    d7, d1
01017807  ea01              asr.b    #$5, d1
01017809  f501              pflushn  (a1)
0101780b  fa01fc01          fmovem   invalid, d1
0101780f  fe01ff01          fmovem   invalid, d1
01017813  ff02              dc.w     $ff02
01017815  ff03              dc.w     $ff03
01017817  ff04              dc.w     $ff04
01017819  ff05              dc.w     $ff05
0101781b  1524              move.b   -(a4), -(a2)
0101781d  211d              move.l   (a5)+, -(a0)
0101781f  1718              move.b   (a0)+, -(a3)
01017821  0900              btst.l   d4, d0
01017823  050f2a21          movep.w  $2a21(a7), d2
01017827  2726              move.l   -(a6), -(a3)
01017829  1524              move.b   -(a4), -(a2)
0101782b  21281811          move.l   $1811(a0), -(a0)
0101782f  0f00              btst.l   d7, d0
01017831  042e21272615      subi.b   #$27, $2615(a6)
01017837  2420              move.l   -(a0), d2
01017839  232d1009          move.l   $1009(a5), -(a1)
0101783d  0800              dc.w     $0800
0101783f  0504              btst.l   d2, d4
01017841  2f2a2027          move.l   $2027(a2), -(a7)
01017845  2616              move.l   (a6), d3
01017847  2e20              move.l   -(a0), d7
01017849  292d1810          move.l   $1810(a5), -(a4)
0101784d  0f080004          movep.w  $4(a0), d7
01017851  2f2e2027          move.l   $2027(a6), -(a7)
01017855  2616              move.l   (a6), d3
01017857  2023              move.l   -(a3), d0
01017859  2f2d1400          move.l   $1400(a5), -(a7)
0101785d  0801              dc.w     $0801
0101785f  04302a1f292b1620252f2d11  subi.b   #$1f, ([$1620, a0, d2.l], $252f2d11)
0101786b  0f01              btst.l   d7, d1
0101786d  04302c202b162029  subi.b   #$20, ([a0], d2.l * 2, $2029)
01017875  2f2d1403          move.l   $1403(a5), -(a7)
01017879  09302e20          btst.l   d4, $20(a0, d2.l)
0101787d  2b16              move.l   (a6), -(a5)
0101787f  20302d0d          move.l   ([a0], d2.l * 4), d0
01017883  0f01              btst.l   d7, d1
01017885  0804              dc.w     $0804
01017887  3120              move.w   -(a0), -(a0)
01017889  2b16              move.l   (a6), -(a5)
0101788b  1f23              move.b   -(a3), -(a7)
0101788d  302d1403          move.w   $1403(a5), d0
01017891  0f312a1f          btst.l   d7, $1f(a1, d2.l)
01017895  2b16              move.l   (a6), -(a5)
01017897  1f25              move.b   -(a5), -(a7)
01017899  302d0d02          move.w   $d02(a5), d0
0101789d  0d07              btst.l   d6, d7
0101789f  312c1f2b          move.w   $1f2b(a4), -(a0)
010178a3  161f              move.b   (a7)+, d3
010178a5  29302d130d000d04  move.l   ([a0, d2.l * 4], $d000d04), -(a4) ; $0d000d04 = VRAM MWF mirrors (non-Turbo mono only)
010178ad  09312e1f          btst.l   d4, $1f(a1, d2.l)
010178b1  2b16              move.l   (a6), -(a5)
010178b3  1f312d0d          move.b   ([a1], d2.l * 4), -(a7)
010178b7  0104              btst.l   d0, d4
010178b9  0512              btst.l   d2, (a2)
010178bb  321f              move.w   (a7)+, d1
010178bd  2b16              move.l   (a6), -(a5)
010178bf  1e23              move.b   -(a3), d7
010178c1  312d0d00          move.w   $d00(a5), -(a0)
010178c5  0e09              dc.w     $0e09
010178c7  18322a1e          move.b   $1e(a2, d2.l), d4
010178cb  2b16              move.l   (a6), -(a5)
010178cd  1e23              move.b   -(a3), d7
010178cf  312d0d00          move.w   $d00(a5), -(a0)
010178d3  06101432          addi.b   #$32, (a0)
010178d7  2a1e              move.l   (a6)+, d5
010178d9  2b16              move.l   (a6), -(a5)
010178db  1e25              move.b   -(a5), d7
010178dd  312d0d05          move.w   $d05(a5), -(a0)
010178e1  0d090c18          movep.w  $c18(a1), d6
010178e5  322c1e2b          move.w   $1e2b(a4), d1
010178e9  161e              move.b   (a6)+, d3
010178eb  25312d0f00051218  move.l   ([a1], d2.l * 4, $51218), -(a2)
010178f3  0c322c1e2b161e29  cmpi.b   #$1e, ([a2], d2.l * 2, $1e29)
010178fb  312d0d0b          move.w   $d0b(a5), -(a0)
010178ff  1218              move.b   (a0)+, d1
01017901  322e1e2b          move.w   $1e2b(a6), d1
01017905  161e              move.b   (a6)+, d3
01017907  29312d14          move.l   (a1, d2.l * 4), -(a4)
0101790b  0510              btst.l   d2, (a0)
0101790d  1a322e1e          move.b   $1e(a2, d2.l), d5
01017911  2b16              move.l   (a6), -(a5)
01017913  1e322d0d          move.b   ([a2], d2.l * 4), d7
01017917  0a101933          eori.b   #$33, (a0)
0101791b  1e2b161e          move.b   $161e(a3), d7
0101791f  322d1012          move.w   $1012(a5), d1
01017923  171a              move.b   (a2)+, -(a3)
01017925  331e              move.w   (a6)+, -(a1)
01017927  2b16              move.l   (a6), -(a5)
01017929  23322d14          move.l   (a2, d2.l * 4), -(a1)
0101792d  0a121933          eori.b   #$33, (a2)
01017931  2a2b1623          move.l   $1623(a3), d5
01017935  322d1012          move.w   $1012(a5), d1
01017939  1b332a2b          move.b   $2b(a3, d2.l), -(a5)
0101793d  1623              move.b   -(a3), d3
0101793f  322d1814          move.w   $1814(a5), d1
01017943  121a              move.b   (a2)+, d1
01017945  332a2b16          move.w   $2b16(a2), -(a1)
01017949  23322d10          move.l   (a2, d2.l * 4), -(a1)
0101794d  121b              move.b   (a3)+, d1
0101794f  332a2b16          move.w   $2b16(a2), -(a1)
01017953  23322d1c          move.l   (a2, d2.l * 4), -(a1)
01017957  332a2b16          move.w   $2b16(a2), -(a1)
0101795b  25322d120c1b      move.l   ([a2, d2.l * 4], $c1b), -(a2)
01017961  332c2b16          move.w   $2b16(a4), -(a1)
01017965  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017969  332c2b16          move.w   $2b16(a4), -(a1)
0101796d  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017971  332c2b16          move.w   $2b16(a4), -(a1)
01017975  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017979  332c2b16          move.w   $2b16(a4), -(a1)
0101797d  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017981  332c2b16          move.w   $2b16(a4), -(a1)
01017985  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017989  332c2b16          move.w   $2b16(a4), -(a1)
0101798d  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017991  332c2b16          move.w   $2b16(a4), -(a1)
01017995  25322d1c          move.l   (a2, d2.l * 4), -(a2)
01017999  332c2b16          move.w   $2b16(a4), -(a1)
0101799d  25322d1c          move.l   (a2, d2.l * 4), -(a2)
010179a1  332c2b16          move.w   $2b16(a4), -(a1)
010179a5  25322d1c          move.l   (a2, d2.l * 4), -(a2)
010179a9  332c2b16          move.w   $2b16(a4), -(a1)
010179ad  25322d1c          move.l   (a2, d2.l * 4), -(a2)
010179b1  332c2b16          move.w   $2b16(a4), -(a1)
010179b5  25322d1c          move.l   (a2, d2.l * 4), -(a2)
010179b9  332c2b16          move.w   $2b16(a4), -(a1)
010179bd  23322d1c          move.l   (a2, d2.l * 4), -(a1)
010179c1  332a2b16          move.w   $2b16(a2), -(a1)
010179c5  23322d1c          move.l   (a2, d2.l * 4), -(a1)
010179c9  332a2b16          move.w   $2b16(a2), -(a1)
010179cd  23322d1c          move.l   (a2, d2.l * 4), -(a1)
010179d1  332a2b16          move.w   $2b16(a2), -(a1)
010179d5  23322d22332a2b00  move.l   ([$332a, a2, d2.l * 4], $2b00), -(a1)
010179dd  00530000          ori.w    #$0, (a3)
010179e1  00000000          ori.b    #$0, d0
010179e5  5800              addq.b   #$4, d0
010179e7  0000549c          ori.b    #$9c, d0
010179eb  00010002          ori.b    #$2, d1
010179ef  00030101          ori.b    #$1, d3
010179f3  02010301          andi.b   #$1, d1
010179f7  04010501          subi.b   #$1, d1
010179fb  06010801          addi.b   #$1, d1
010179ff  0901              btst.l   d4, d1
01017a01  0a010e01          eori.b   #$1, d1
01017a05  1001              move.b   d1, d0
01017a07  1101              move.b   d1, -(a0)
01017a09  1201              move.b   d1, d1
01017a0b  1501              move.b   d1, -(a2)
01017a0d  1701              move.b   d1, -(a3)
01017a0f  1901              move.b   d1, -(a4)
01017a11  1a01              move.b   d1, d5
01017a13  1b01              move.b   d1, -(a5)
01017a15  2501              move.l   d1, -(a2)
01017a17  2a01              move.l   d1, d5
01017a19  2b01              move.l   d1, -(a5)
01017a1b  3a01              move.w   d1, d5
01017a1d  4001              negx.b   d1
01017a1f  4101              chk.l    d1, d0
01017a21  4501              chk.l    d1, d2
01017a23  4901              chk.l    d1, d4
01017a25  5001              addq.b   #$8, d1
01017a27  5101              subq.b   #$8, d1
01017a29  5201              addq.b   #$1, d1
01017a2b  5401              addq.b   #$2, d1
01017a2d  5501              subq.b   #$2, d1
01017a2f  5502              subq.b   #$2, d2
01017a31  5503              subq.b   #$2, d3
01017a33  5504              subq.b   #$2, d4
01017a35  5505              subq.b   #$2, d5
01017a37  5506              subq.b   #$2, d6
01017a39  5507              subq.b   #$2, d7
01017a3b  5508              dc.w     $5508
01017a3d  5509              dc.w     $5509
01017a3f  550a              dc.w     $550a
01017a41  550b              dc.w     $550b
01017a43  550c              dc.w     $550c
01017a45  550d              dc.w     $550d
01017a47  550e              dc.w     $550e
01017a49  550f              dc.w     $550f
01017a4b  5510              subq.b   #$2, (a0)
01017a4d  5512              subq.b   #$2, (a2)
01017a4f  5513              subq.b   #$2, (a3)
01017a51  5514              subq.b   #$2, (a4)
01017a53  5515              subq.b   #$2, (a5)
01017a55  5601              addq.b   #$3, d1
01017a57  5701              subq.b   #$3, d1
01017a59  5801              addq.b   #$4, d1
01017a5b  5901              subq.b   #$4, d1
01017a5d  5902              subq.b   #$4, d2
01017a5f  5a01              addq.b   #$5, d1
01017a61  5b01              subq.b   #$5, d1
01017a63  5d01              subq.b   #$6, d1
01017a65  5e01              addq.b   #$7, d1
01017a67  5f01              subq.b   #$7, d1
01017a69  6401              bcc.b    $1017a6c
01017a6b  6501              bcs.b    $1017a6e
01017a6d  6601              bne.b    $1017a70
01017a6f  6604              bne.b    $1017a75
01017a71  6701              beq.b    $1017a74
01017a73  6801              bvc.b    $1017a76
01017a75  6901              bvs.b    $1017a78
01017a77  6a01              bpl.b    $1017a7a
01017a79  6b01              bmi.b    $1017a7c
01017a7b  6d01              blt.b    $1017a7e
01017a7d  6e01              bgt.b    $1017a80
01017a7f  6f01              ble.b    $1017a82
01017a81  7401              moveq    #$1, d2
01017a83  7601              moveq    #$1, d3
01017a85  7901              dc.w     $7901
01017a87  7a01              moveq    #$1, d5
01017a89  7e01              moveq    #$1, d7
01017a8b  7f01              dc.w     $7f01
01017a8d  8001              or.b     d1, d0
01017a8f  8101              sbcd.b   d1, d0
01017a91  9101              subx.b   d1, d0
01017a93  9201              sub.b    d1, d1
01017a95  9401              sub.b    d1, d2
01017a97  9501              subx.b   d1, d2
01017a99  9502              subx.b   d2, d2
01017a9b  9601              sub.b    d1, d3
01017a9d  9801              sub.b    d1, d4
01017a9f  9901              subx.b   d1, d4
01017aa1  9902              subx.b   d2, d4
01017aa3  9903              subx.b   d3, d4
01017aa5  9a01              sub.b    d1, d5
01017aa7  9d01              subx.b   d1, d6
01017aa9  9e01              sub.b    d1, d7
01017aab  9f01              subx.b   d1, d7
01017aad  a001              dc.w     $a001
01017aaf  a101              dc.w     $a101
01017ab1  a201              dc.w     $a201
01017ab3  a301              dc.w     $a301
01017ab5  a401              dc.w     $a401
01017ab7  a501              dc.w     $a501
01017ab9  a502              dc.w     $a502
01017abb  a601              dc.w     $a601
01017abd  a701              dc.w     $a701
01017abf  a801              dc.w     $a801
01017ac1  a901              dc.w     $a901
01017ac3  aa01              dc.w     $aa01
01017ac5  aa02              dc.w     $aa02
01017ac7  aa03              dc.w     $aa03
01017ac9  aa04              dc.w     $aa04
01017acb  ab01              dc.w     $ab01
01017acd  ad01              dc.w     $ad01
01017acf  ae01              dc.w     $ae01
01017ad1  af01              dc.w     $af01
01017ad3  b501              eor.b    d2, d1
01017ad5  b601              cmp.b    d1, d3
01017ad7  b901              eor.b    d4, d1
01017ad9  ba01              cmp.b    d1, d5
01017adb  bb01              eor.b    d5, d1
01017add  bb02              eor.b    d5, d2
01017adf  bb03              eor.b    d5, d3
01017ae1  bd01              eor.b    d6, d1
01017ae3  be01              cmp.b    d1, d7
01017ae5  bf01              eor.b    d7, d1
01017ae7  bf02              eor.b    d7, d2
01017ae9  c001              and.b    d1, d0
01017aeb  c101              abcd.b   d1, d0
01017aed  c401              and.b    d1, d2
01017aef  d401              add.b    d1, d2
01017af1  d501              addx.b   d1, d2
01017af3  d901              addx.b   d1, d4
01017af5  df01              addx.b   d1, d7
01017af7  e501              asl.b    #$2, d1
01017af9  e601              asr.b    #$3, d1
01017afb  e901              asl.b    #$4, d1
01017afd  ea01              asr.b    #$5, d1
01017aff  eb01              asl.b    #$5, d1
01017b01  ee01              asr.b    #$7, d1
01017b03  ee02              asr.b    #$7, d2
01017b05  ee03              asr.b    #$7, d3
01017b07  ef01              asl.b    #$7, d1
01017b09  f001f101          fmovem   fp7, d1
01017b0d  f201f501          fmovem   fp7, d1
01017b11  f901              dc.w     $f901
01017b13  fa01fb01          fmovem   invalid, d1
01017b17  fd01              dc.w     $fd01
01017b19  fe01ff01          fmovem   invalid, d1
01017b1d  ff02              dc.w     $ff02
01017b1f  ff03              dc.w     $ff03
01017b21  ff04              dc.w     $ff04
01017b23  27356c63          move.l   $63(a5, d6.l), -(a3)
01017b27  37685a29276a      move.w   $5a29(a0), $276a(a3)
01017b2d  103589742a264621  move.b   $2a264621(a5, invalid.w), d0
01017b35  4774              dc.w     $4774
01017b37  2c25              move.l   -(a5), d6
01017b39  35566c4d          move.w   (a6), $6c4d(a2)
01017b3d  2d25              move.l   -(a5), -(a6)
01017b3f  4414              neg.b    (a4)
01017b41  932e2555          sub.b    d1, $2555(a6)
01017b45  4924              chk.l    -(a4), d4
01017b47  466d2824          not.w    $2824(a5)
01017b4b  383b6622          move.w   $1017b6f(pc, d6.w), d4
01017b4f  466c5620          not.w    $5620(a4)
01017b53  076d6b25          bchg.b   d3, $6b25(a5)
01017b57  2440              movea.l  d0, a2
01017b59  7122              dc.w     $7122
01017b5b  6c56              bge.b    $1017bb3
01017b5d  21414013          move.l   d1, $4013(a0)
01017b61  22356c24          move.l   $24(a5, d6.l), d1
01017b65  245d              movea.l  (a5)+, a2
01017b67  9221              sub.b    -(a1), d1
01017b69  6c1d              bge.b    $1017b88
01017b6b  136d6b3a6d6b      move.b   $6b3a(a5), $6d6b(a1)
01017b71  0366              bchg.b   d1, -(a6)
01017b73  2323              move.l   -(a3), -(a1)
01017b75  3514              move.w   (a4), -(a2)
01017b77  663a              bne.b    $1017bb3
01017b79  21453a70          move.l   d5, $3a70(a0)
01017b7d  7877              moveq    #$77, d4
01017b7f  4a8a              tst.l    a2
01017b81  6d35              blt.b    $1017bb8
01017b83  3a23              move.w   -(a3), d5
01017b85  23373835          move.l   $35(a7, d3.l), -(a1)
01017b89  563a              dc.w     $563a
01017b8b  6b5f              bmi.b    $1017bec
01017b8d  9997              sub.l    d4, (a7)
01017b8f  7299              moveq    #$99, d1
01017b91  885d              or.w     (a5)+, d4
01017b93  6722              beq.b    $1017bb7
01017b95  2341673a          move.l   d1, $673a(a1)
01017b99  6c8b              bge.b    $1017b26
01017b9b  7388              dc.w     $7388
01017b9d  247297726c3a22234175  movea.l  ([$6c3a2223, a2], $4175), a2
01017ba7  216c8e972847      move.l   -$7169(a4), $2847(a0)
01017bad  9457              sub.w    (a7), d2
01017baf  2123              move.l   -(a3), -(a0)
01017bb1  3a8f              move.w   a7, (a5)
01017bb3  1670              dc.w     $1670
01017bb5  972a4a6b          sub.b    d3, $4a6b(a2)
01017bb9  4021              negx.b   -(a1)
01017bbb  235d8016          move.l   (a5)+, -$7fea(a1)
01017bbf  7d56              dc.w     $7d56
01017bc1  2a358807          move.l   $7(a5, a0.l), d5
01017bc5  2123              move.l   -(a3), -(a0)
01017bc7  3a373b932c4b0421  move.w   ([, d3.l * 2], $2c4b0421), d5 ; $2c4b0421 = color VRAM (non-Turbo color station)
01017bcf  23584550          move.l   (a0)+, $4550(a1)
01017bd3  562c3a35          addq.b   #$3, $3a35(a4)
01017bd7  8322              or.b     d1, -(a2)
01017bd9  35457096          move.w   d5, $7096(a2)
01017bdd  2d356656          move.l   $56(a5, d6.w), -(a6)
01017be1  22385d7d          move.l   $5d7d.w, d1
01017be5  862e5a74          or.b     $5a74(a6), d3
01017be9  2241              movea.l  d1, a1
01017beb  4698              not.l    (a0)+
01017bed  3066              movea.w  -(a6), a0
01017bef  2256              movea.l  (a6), a1
01017bf1  7088              moveq    #$88, d0
01017bf3  2f667121          move.l   -(a6), $7121(a7)
01017bf7  35387393          move.w   $7393.w, -(a2)
01017bfb  2f554d21          move.l   (a5), $4d21(a7)
01017bff  3841              movea.w  d1, a4
01017c01  7d88              dc.w     $7d88
01017c03  562e625e          addq.b   #$3, $625e(a6)
01017c07  21405d7d          move.l   d0, $5d7d(a0)
01017c0b  6656              bne.b    $1017c63
01017c0d  2e56              movea.l  (a6), a7
01017c0f  4821              nbcd.b   -(a1)
01017c11  5146              subq.w   #$8, d6
01017c13  856b152e          or.w     d2, $152e(a3)
01017c17  587135033b3e660b  addq.w   #$4, ([a1, d3.w * 4], $3b3e660b)
01017c1f  2d353b7135083c36  move.l   ([$35083c36, a5]), -(a6)
01017c27  8210              or.b     (a0), d1
01017c29  662c              bne.b    $1017c57
01017c2b  3846              movea.w  d6, a4
01017c2d  7439              moveq    #$39, d2
01017c2f  4021              negx.b   -(a1)
01017c31  8621              or.b     -(a1), d3
01017c33  3a2b3a54          move.w   $3a54(a3), d5
01017c37  6c92              bge.b    $1017bcb
01017c39  3841              movea.w  d1, a4
01017c3b  7421              moveq    #$21, d2
01017c3d  4556              dc.w     $4556
01017c3f  21662935          move.l   -(a6), $2935(a0)
01017c43  6608              bne.b    $1017c4d
01017c45  7083              moveq    #$83, d0
01017c47  413a8321          chk.l    od_drive_query(pc), d0
01017c4b  3a5a              movea.w  (a2)+, a5
01017c4d  563a              dc.w     $563a
01017c4f  5627              addq.b   #$3, -(a7)
01017c51  356b22732140      move.w   $2273(a3), $2140(a2)
01017c57  4683              not.l    d3
01017c59  21368922466c2435  move.l   ([$466c, a6, a0.l], $2435), -(a0)
01017c61  6c5a              bge.b    $1017cbd
01017c63  213a567b          move.l   $101d2e0(pc), -(a0)
01017c67  21414723          move.l   d1, $4723(a0)
01017c6b  94682119          sub.w    $2119(a0), d2
01017c6f  386f6b56          movea.w  $6b56(a7), a4
01017c73  0321              btst.l   d1, -(a1)
01017c75  6c58              bge.b    $1017ccf
01017c77  8321              or.b     d1, -(a1)
01017c79  56702350          addq.w   #$3, (a0, invalid.w)
01017c7d  6c6b              bge.b    $1017cea
01017c7f  1922              move.b   -(a2), -(a4)
01017c81  201b              move.l   (a3)+, d0
01017c83  230f              move.l   a7, -(a1)
01017c85  466c8422          not.w    -$7bde(a4)
01017c89  5870233b8b6c355621200322  addq.w   #$4, ([$8b6c3556, a0, d2.w * 2], $21200322)
01017c95  41356c8e          chk.l    -$72(a5, d6.l), d0
01017c99  9222              sub.b    -(a2), d1
01017c9b  5672247d          addq.w   #$3, $7d(a2, d2.w)
01017c9f  7735              dc.w     $7735
01017ca1  6b5a              bmi.b    $1017cfd
01017ca3  5921              subq.b   #$4, -(a1)
01017ca5  5b5d              subq.w   #$5, (a5)+
01017ca7  35787d562253      move.w   $7d56.w, $2253(a2)
01017cad  4924              chk.l    -(a4), d4
01017caf  3b98436d6b35      move.w   (a0)+, ([$6b35, a5])
01017cb5  6f8e              ble.b    $1017c45
01017cb7  9323              sub.b    d1, -(a3)
01017cb9  5213              addq.b   #$1, (a3)
01017cbb  254a6c8b          move.l   a2, $6c8b(a2)
01017cbf  6c6b              bge.b    $1017d2c
01017cc1  356c70787094      move.w   $7078(a4), $7094(a2)
01017cc7  2406              move.l   d6, d2
01017cc9  3a26              move.w   -(a6), d5
01017ccb  4798              chk.w    (a0)+, d3
01017ccd  7943              dc.w     $7943
01017ccf  7e97              moveq    #$97, d7
01017cd1  8825              or.b     -(a5), d4
01017cd3  075a              bchg.b   d3, (a2)+
01017cd5  27469894          move.l   d6, -$676c(a3)
01017cd9  7098              moveq    #$98, d0
01017cdb  9766              sub.w    d3, -(a6)
01017cdd  260a              move.l   a2, d3
01017cdf  3a336635          move.w   $35(a3, d6.w), d5
01017ce3  336b35336635      move.w   $3533(a3), $6635(a1)
01017ce9  336b21563289      move.w   $2156(a3), $3289(a1)
01017cef  34765732774045324f5a  movea.w  ([$77404532, a6, d5.w * 8], $4f5a), a2
01017cf9  0832              dc.w     $0832
01017cfb  4966              dc.w     $4966
01017cfd  0366              bchg.b   d1, -(a6)
01017cff  313e              dc.w     $313e
01017d01  651a              bcs.b    $1017d1d
01017d03  5a21              addq.b   #$5, -(a1)
01017d05  3b989221          move.w   (a0)+, $21(a5, a1.w)
01017d09  7b2c              dc.w     $7b2c
01017d0b  3686              move.w   d6, (a3)
01017d0d  1041              dc.w     $1041
01017d0f  563a              dc.w     $563a
01017d11  6c73              bge.b    $1017d86
01017d13  987b3b9a833b      sub.w    ([$1017d15, d3.l * 2], $833b), d4
01017d19  9a23              sub.b    -(a3), d5
01017d1b  35921c38          move.w   (a2), $38(a2, d1.l)
01017d1f  5d66              subq.w   #$6, -(a6)
01017d21  5a5f              addq.w   #$5, (a7)+
01017d23  6c7d              bge.b    $1017da2
01017d25  959b              sub.l    d2, (a3)+
01017d27  959b              sub.l    d2, (a3)+
01017d29  8321              or.b     d1, -(a1)
01017d2b  21933521411f      move.l   (a3), ([$411f, a0, d3.w * 4])
01017d31  4148              dc.w     $4148
01017d33  5a47              addq.w   #$5, d7
01017d35  686e              bvc.b    $1017da5
01017d37  89686d70          or.w     d4, $6d70(a0)
01017d3b  6c83              bge.b    $1017cc0
01017d3d  2121              move.l   -(a1), -(a0)
01017d3f  4c38              dc.w     $4c38
01017d41  5a21              addq.b   #$5, -(a1)
01017d43  6221              bhi.b    $1017d66
01017d45  3821              move.w   -(a1), d4
01017d47  111e              move.b   (a6)+, -(a0)
01017d49  23831e22          move.l   d3, $22(a1, d1.l)
01017d4d  3521              move.w   -(a1), -(a2)
01017d4f  8321              or.b     d1, -(a1)
01017d51  213a6c68          move.l   $101e9bb(pc), -(a0)
01017d55  211e              move.l   (a6)+, -(a0)
01017d57  0e12              dc.w     $0e12
01017d59  0e04              dc.w     $0e04
01017d5b  1d02              move.b   d2, -(a6)
01017d5d  831d              or.b     d1, (a5)+
01017d5f  0104              btst.l   d0, d4
01017d61  218321213570      move.l   d3, ([$3570, a0, d2.w])
01017d67  6b5a              bmi.b    $1017dc3
01017d69  1d00              move.b   d0, -(a6)
01017d6b  091b              btst.l   d4, (a3)+
01017d6d  041d0251          subi.b   #$51, (a5)+
01017d71  0d01              btst.l   d6, d1
01017d73  04005621          subi.b   #$21, d0
01017d77  22728b41          movea.l  ([a2]), a1
01017d7b  1d00              move.b   d0, -(a6)
01017d7d  0603041d          addi.b   #$1d, d3
01017d81  027f              dc.w     $027f
01017d83  0d01              btst.l   d6, d1
01017d85  0300              btst.l   d1, d0
01017d87  5621              addq.b   #$3, -(a1)
01017d89  223e              dc.w     $223e
01017d8b  956c6100          sub.w    d2, $6100(a4)
01017d8f  0603041e          addi.b   #$1e, d3
01017d93  23811e23          move.l   d1, $23(a1, d1.l)
01017d97  0e56              dc.w     $0e56
01017d99  2122              move.l   -(a2), -(a0)
01017d9b  35978b8f00060c05  move.w   (a7), ([], a0.l * 2, $60c05)
01017da3  215c8321          move.l   (a4)+, -$7cdf(a0)
01017da7  5c21              addq.b   #$6, -(a1)
01017da9  8321              or.b     d1, -(a1)
01017dab  234a9562          move.l   a2, -$6a9e(a1)
01017daf  21384e11          move.l   $4e11.w, -(a0)
01017db3  4287              clr.l    d7
01017db5  425a              clr.w    (a2)+
01017db7  8321              or.b     d1, -(a1)
01017db9  247d              dc.w     $247d
01017dbb  9021              sub.b    -(a1), d0
01017dbd  3d881158          move.w   a0, (a6, invalid.w)
01017dc1  6e84              bgt.b    $1017d47
01017dc3  686d              bvc.b    $1017e32
01017dc5  7041              moveq    #$41, d0
01017dc7  8321              or.b     d1, -(a1)
01017dc9  24359141          move.l   ([a5]), d2
01017dcd  4987              chk.w    d7, d4
01017dcf  11697a89697a      move.b   $7a89(a1), $697a(a0)
01017dd5  6c83              bge.b    $1017d5a
01017dd7  2126              move.l   -(a6), -(a0)
01017dd9  5a60              addq.w   #$5, -(a0)
01017ddb  5d47              subq.w   #$6, d7
01017ddd  778d              dc.w     $778d
01017ddf  95778c8e          sub.w    d2, -$72(a7, a0.l)
01017de3  8b832125          unpk     d3, d5, #$2125
01017de7  356c735d4795      move.w   $735d(a4), $4795(a2)
01017ded  9b95              sub.l    d5, (a5)
01017def  9b83              subx.l   d3, d5
01017df1  2125              move.l   -(a5), -(a0)
01017df3  36787e46          movea.w  $7e46.w, a3
01017df7  3b9a833b9a23253b9893217c  move.w   (a2)+, ([$9a23253b, a5, a0.w * 2], $9893217c)
01017e03  359997282a40      move.w   (a1)+, $2a40(a2, a1.w * 8)
01017e09  010e5627          movep.w  $5627(a6), d0
01017e0d  2a4e              movea.l  a6, a5
01017e0f  1906              move.b   d6, -(a4)
01017e11  4183              chk.w    d3, d0
01017e13  272a4e19          move.l   $4e19(a2), -(a3)
01017e17  033a8327          btst.l   d1, $1010140(pc)
01017e1b  2a4e              movea.l  a6, a5
01017e1d  1906              move.b   d6, -(a4)
01017e1f  4183              chk.w    d3, d0
01017e21  272a4e19          move.l   $4e19(a2), -(a3)
01017e25  033a8327          btst.l   d1, $101014e(pc)
01017e29  2a4e              movea.l  a6, a5
01017e2b  1906              move.b   d6, -(a4)
01017e2d  4183              chk.w    d3, d0
01017e2f  272a4e19          move.l   $4e19(a2), -(a3)
01017e33  033a8327          btst.l   d1, $101015c(pc)
01017e37  2a4e              movea.l  a6, a5
01017e39  1906              move.b   d6, -(a4)
01017e3b  4183              chk.w    d3, d0
01017e3d  272a4a9a          move.l   $4a9a(a2), -(a3)
01017e41  282a3d3f          move.l   $3d3f(a2), d4
01017e45  0873              dc.w     $0873
01017e47  282a3d55          move.l   $3d55(a2), d4
01017e4b  0889              dc.w     $0889
01017e4d  282a3d3f          move.l   $3d3f(a2), d4
01017e51  0c64282a          cmpi.w   #$282a, -(a4)
01017e55  3d551817          move.w   (a5), $1817(a6)
01017e59  282a3d40          move.l   $3d40(a2), d4
01017e5d  443b              dc.w     $443b
01017e5f  282a4001          move.l   $4001(a2), d4
01017e63  1056              dc.w     $1056
01017e65  272a4e19          move.l   $4e19(a2), -(a3)
01017e69  06418327          addi.w   #$8327, d1
01017e6d  2a4e              movea.l  a6, a5
01017e6f  1903              move.b   d3, -(a4)
01017e71  3a83              move.w   d3, (a5)
01017e73  272a5056          move.l   $5056(a2), -(a3)
01017e77  357383270000005300000000  move.w   ([a3], a0.w * 2, $530000), $0(a2) ; $00530000 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01017e83  00005800          ori.b    #$0, d0
01017e87  00003f92          ori.b    #$92, d0
01017e8b  00010002          ori.b    #$2, d1
01017e8f  00030101          ori.b    #$1, d3
01017e93  02010301          andi.b   #$1, d1
01017e97  04010501          subi.b   #$1, d1
01017e9b  06010801          addi.b   #$1, d1
01017e9f  0901              btst.l   d4, d1
01017ea1  0a010b01          eori.b   #$1, d1
01017ea5  0e01              dc.w     $0e01
01017ea7  1001              move.b   d1, d0
01017ea9  1101              move.b   d1, -(a0)
01017eab  1501              move.b   d1, -(a2)
01017ead  1601              move.b   d1, d3
01017eaf  1701              move.b   d1, -(a3)
01017eb1  1901              move.b   d1, -(a4)
01017eb3  2a01              move.l   d1, d5
01017eb5  4001              negx.b   d1
01017eb7  4401              neg.b    d1
01017eb9  4501              chk.l    d1, d2
01017ebb  4601              not.b    d1
01017ebd  4701              chk.l    d1, d3
01017ebf  4901              chk.l    d1, d4
01017ec1  4a01              tst.b    d1
01017ec3  5001              addq.b   #$8, d1
01017ec5  5101              subq.b   #$8, d1
01017ec7  5201              addq.b   #$1, d1
01017ec9  5401              addq.b   #$2, d1
01017ecb  5501              subq.b   #$2, d1
01017ecd  5502              subq.b   #$2, d2
01017ecf  5503              subq.b   #$2, d3
01017ed1  5504              subq.b   #$2, d4
01017ed3  5505              subq.b   #$2, d5
01017ed5  5506              subq.b   #$2, d6
01017ed7  5507              subq.b   #$2, d7
01017ed9  5508              dc.w     $5508
01017edb  5509              dc.w     $5509
01017edd  550a              dc.w     $550a
01017edf  550b              dc.w     $550b
01017ee1  550c              dc.w     $550c
01017ee3  550d              dc.w     $550d
01017ee5  550e              dc.w     $550e
01017ee7  550f              dc.w     $550f
01017ee9  5512              subq.b   #$2, (a2)
01017eeb  5513              subq.b   #$2, (a3)
01017eed  5514              subq.b   #$2, (a4)
01017eef  5515              subq.b   #$2, (a5)
01017ef1  5601              addq.b   #$3, d1
01017ef3  5602              addq.b   #$3, d2
01017ef5  5701              subq.b   #$3, d1
01017ef7  5801              addq.b   #$4, d1
01017ef9  5901              subq.b   #$4, d1
01017efb  5a01              addq.b   #$5, d1
01017efd  5b01              subq.b   #$5, d1
01017eff  5d01              subq.b   #$6, d1
01017f01  5e01              addq.b   #$7, d1
01017f03  5f01              subq.b   #$7, d1
01017f05  6101              bsr.b    $1017f08
01017f07  6401              bcc.b    $1017f0a
01017f09  6501              bcs.b    $1017f0c
01017f0b  6601              bne.b    $1017f0e
01017f0d  6602              bne.b    $1017f11
01017f0f  6604              bne.b    $1017f15
01017f11  6701              beq.b    $1017f14
01017f13  6901              bvs.b    $1017f16
01017f15  6a01              bpl.b    $1017f18
01017f17  6b01              bmi.b    $1017f1a
01017f19  6d01              blt.b    $1017f1c
01017f1b  6e01              bgt.b    $1017f1e
01017f1d  6f01              ble.b    $1017f20
01017f1f  7501              dc.w     $7501
01017f21  7601              moveq    #$1, d3
01017f23  7901              dc.w     $7901
01017f25  7a01              moveq    #$1, d5
01017f27  7d01              dc.w     $7d01
01017f29  7f01              dc.w     $7f01
01017f2b  8001              or.b     d1, d0
01017f2d  8401              or.b     d1, d2
01017f2f  9001              sub.b    d1, d0
01017f31  9101              subx.b   d1, d0
01017f33  9401              sub.b    d1, d2
01017f35  9501              subx.b   d1, d2
01017f37  9502              subx.b   d2, d2
01017f39  9601              sub.b    d1, d3
01017f3b  9901              subx.b   d1, d4
01017f3d  9902              subx.b   d2, d4
01017f3f  9903              subx.b   d3, d4
01017f41  9a01              sub.b    d1, d5
01017f43  9b01              subx.b   d1, d5
01017f45  9d01              subx.b   d1, d6
01017f47  9e01              sub.b    d1, d7
01017f49  9f01              subx.b   d1, d7
01017f4b  a001              dc.w     $a001
01017f4d  a101              dc.w     $a101
01017f4f  a401              dc.w     $a401
01017f51  a501              dc.w     $a501
01017f53  a502              dc.w     $a502
01017f55  a601              dc.w     $a601
01017f57  a701              dc.w     $a701
01017f59  a801              dc.w     $a801
01017f5b  a901              dc.w     $a901
01017f5d  aa01              dc.w     $aa01
01017f5f  aa02              dc.w     $aa02
01017f61  aa03              dc.w     $aa03
01017f63  aa04              dc.w     $aa04
01017f65  ab01              dc.w     $ab01
01017f67  ad01              dc.w     $ad01
01017f69  ae01              dc.w     $ae01
01017f6b  af01              dc.w     $af01
01017f6d  b501              eor.b    d2, d1
01017f6f  ba01              cmp.b    d1, d5
01017f71  bb01              eor.b    d5, d1
01017f73  bb03              eor.b    d5, d3
01017f75  bd01              eor.b    d6, d1
01017f77  be01              cmp.b    d1, d7
01017f79  bf01              eor.b    d7, d1
01017f7b  c001              and.b    d1, d0
01017f7d  c401              and.b    d1, d2
01017f7f  d501              addx.b   d1, d2
01017f81  d901              addx.b   d1, d4
01017f83  df01              addx.b   d1, d7
01017f85  e501              asl.b    #$2, d1
01017f87  e601              asr.b    #$3, d1
01017f89  e901              asl.b    #$4, d1
01017f8b  ea01              asr.b    #$5, d1
01017f8d  eb01              asl.b    #$5, d1
01017f8f  ee01              asr.b    #$7, d1
01017f91  ee02              asr.b    #$7, d2
01017f93  ee03              asr.b    #$7, d3
01017f95  ef01              asl.b    #$7, d1
01017f97  f001f101          fmovem   fp7, d1
01017f9b  f201f501          fmovem   fp7, d1
01017f9f  f901              dc.w     $f901
01017fa1  fa01fb01          fmovem   invalid, d1
01017fa5  fd01              dc.w     $fd01
01017fa7  fe01ff01          fmovem   invalid, d1
01017fab  ff03              dc.w     $ff03
01017fad  ff04              dc.w     $ff04
01017faf  263369651a65      move.l   ([$1a65, a3]), d3
01017fb5  58282668          addq.b   #$4, $2668(a0)
01017fb9  2011              move.l   (a1), d0
01017fbb  6d71              blt.b    $101802e
01017fbd  2925              move.l   -(a5), -(a4)
01017fbf  4507              chk.l    d7, d2
01017fc1  464a              dc.w     $464a
01017fc3  2b24              move.l   -(a4), -(a5)
01017fc5  3355394c          move.w   (a5), $394c(a1)
01017fc9  2c24              move.l   -(a4), d6
01017fcb  4446              neg.w    d6
01017fcd  682d              bvc.b    $1017ffc
01017fcf  2455              movea.l  (a5), a2
01017fd1  7623              moveq    #$23, d3
01017fd3  456a              dc.w     $456a
01017fd5  2723              move.l   -(a3), -(a3)
01017fd7  360c              move.w   a4, d3
01017fd9  7d21              dc.w     $7d21
01017fdb  4569              dc.w     $4569
01017fdd  5221              addq.b   #$1, -(a1)
01017fdf  6a68              bpl.b    $1018049
01017fe1  2423              move.l   -(a3), d2
01017fe3  3e3a2169          move.w   $101a14e(pc), d7
01017fe7  5520              subq.b   #$2, -(a0)
01017fe9  1d456920          move.b   d5, $6920(a6)
01017fed  1c11              move.b   (a1), d6

; ---- gap 01018006..0101820d (520 bytes) ----
01018006  4569              dc.w     $4569
01018008  6d73              blt.b    $101807d
0101800a  7285              moveq    #$85, d1
0101800c  8163              or.w     d0, -(a3)
0101800e  4569              dc.w     $4569
01018010  3822              move.w   -(a2), d4
01018012  22376e33          move.l   $33(a7, d6.l), d1
01018016  5517              subq.b   #$2, (a7)
01018018  6982              bvs.b    $1017f9c
0101801a  8f80908b          unpk     d0, d7, #$908b
0101801e  6a64              bpl.b    $1018084
01018020  2122              move.l   -(a2), -(a0)
01018022  4071633863858f8a  negx.w   $63858f8a(a1, d6.w * 2)
0101802a  2369768e6918      move.l   $768e(a1), $6918(a1)
01018030  2122              move.l   -(a2), -(a0)
01018032  3d4b2069          move.w   a3, $2069(a6)
01018036  808e              dc.w     $808e
01018038  27468b15          move.l   d6, -$74eb(a3)
0101803c  5520              subq.b   #$2, -(a0)
0101803e  22387145          move.l   $7145.w, d1
01018042  6d8b              blt.b    $1017fcf
01018044  29491d3f          move.l   a1, $1d3f(a4)
01018048  2022              move.l   -(a2), d0
0101804a  5b7a              dc.w     $5b7a
0101804c  4577              dc.w     $4577
0101804e  5529337b          subq.b   #$2, $337b(a1)
01018052  5820              addq.b   #$4, -(a0)
01018054  22383639          move.l   $3639.w, d1
01018058  8a2b4033          or.b     $4033(a3), d5
0101805c  2022              move.l   -(a2), d0
0101805e  5744              subq.w   #$3, d4
01018060  4955              dc.w     $4955
01018062  2b38337a          move.l   $337a.w, -(a5)
01018066  2210              move.l   (a0), d1
01018068  6d6e              blt.b    $10180d8
0101806a  2c336355          move.l   ([a3]), d6
0101806e  213617777d2d5871  move.l   ([$7d2d5871, a6]), -(a0)
01018076  2140208f          move.l   d0, $208f(a0)
0101807a  2e1f              move.l   (a7)+, d7
0101807c  2021              move.l   -(a1), d0
0101807e  5566              subq.w   #$2, -(a6)
01018080  7f2e              dc.w     $7f2e
01018082  52372033          addq.b   #$1, $33(a7, d2.w)
01018086  37708a2e534c      move.w   $2e(a0, a0.l), $534c(a3)
0101808c  20374077          move.l   $77(a7, d4.w), d0
01018090  7f55              dc.w     $7f55
01018092  2d635d20          move.l   -(a3), $5d20(a6)
01018096  3f5b7763          move.w   (a3)+, $7763(a7)
0101809a  552d5547          subq.b   #$2, $5547(a5)
0101809e  2055              movea.l  (a5), a0
010180a0  457c              dc.w     $457c
010180a2  683f              bvc.b    $10180e3
010180a4  2d576e34          move.l   (a7), $6e34(a6)
010180a8  6d3c              blt.b    $10180e6
010180aa  6538              bcs.b    $10180e4
010180ac  2c33396e3447      move.l   ([$3447, a3]), d6
010180b2  357a20632b36      move.w   $101a117(pc), $2b36(a2)
010180b8  1471              dc.w     $1471
010180ba  360a              move.w   a2, d3
010180bc  4e20              dc.w     $4e20
010180be  891c              or.b     d4, (a4)+
010180c0  0b2a3854          btst.l   d5, $3854(a2)
010180c4  4589              dc.w     $4589
010180c6  360f              move.w   a7, d3
010180c8  7120              dc.w     $7120
010180ca  4e500363          link.w   a0, #$363
010180ce  28336320397a      move.l   $397a(a3, d6.w * 2), d4
010180d4  3d07              move.w   d7, -(a6)
010180d6  7a20              moveq    #$20, d5
010180d8  3c51              movea.w  (a1), a6
010180da  20385526          move.l   $5526.w, d0
010180de  3368205b3c20      move.w   $205b(a0), $3c20(a1)
010180e4  3f20              move.w   -(a0), -(a7)
010180e6  5520              subq.b   #$2, -(a0)
010180e8  357a21456923      move.w   $101a22f(pc), $6923(a2)
010180ee  336958033845      move.w   $5803(a1), $3845(a1)
010180f4  4720              chk.l    -(a0), d3
010180f6  4122              chk.l    -(a2), d0
010180f8  6365              bls.b    $101815f
010180fa  21366c68          move.l   $68(a6, d6.l), -(a0)
010180fe  5520              subq.b   #$2, -(a0)
01018100  03696d55          bchg.b   d1, $6d55(a1)
01018104  2055              movea.l  (a5), a0
01018106  6d22              blt.b    $101812a
01018108  4569              dc.w     $4569
0101810a  6820              bvc.b    $101812c
0101810c  1c10              move.b   (a0), d6
0101810e  2103              move.l   d3, -(a0)
01018110  21383369          move.l   $3369.w, -(a0)
01018114  8521              or.b     d2, -(a1)
01018116  5746              subq.w   #$3, d6
01018118  2239826a5210      move.l   $826a5210.l, d1
0101811e  2115              move.l   (a5), -(a0)
01018120  2041              movea.l  d1, a0
01018122  33858921556f      move.w   d5, ([$556f, a1, a0.l])
01018128  237772695437      move.l   $69(a7, d7.w), $5437(a1)
0101812e  5951              subq.w   #$4, (a1)
01018130  585b              addq.w   #$4, (a3)+
01018132  6943              bvs.b    $1018177
01018134  7755              dc.w     $7755
01018136  21556f23          move.l   (a5), $6f23(a0)
0101813a  3c8f              move.w   a7, (a6)
0101813c  7355              dc.w     $7355
0101813e  6b55              bmi.b    $1018195
01018140  6b5c              bmi.b    $101819e
01018142  8a22              or.b     -(a2), d5
01018144  5748              subq.w   #$3, a0
01018146  2449              movea.l  a1, a2
01018148  8e7b6b55          or.w     ([$101814apc]), d7
0101814c  6d73              blt.b    $10181c1
0101814e  7769              dc.w     $7769
01018150  23556f25          move.l   (a5), $6f25(a1)
01018154  4680              not.l    d0
01018156  7469              moveq    #$69, d2
01018158  778e              dc.w     $778e
0101815a  8a24              or.b     -(a4), d5
0101815c  556e2645          subq.w   #$2, $2645(a6)
01018160  9080              sub.l    d0, d0
01018162  8f63              or.w     d7, -(a3)
01018164  25584631          move.l   (a0)+, $4631(a2)
01018168  6319              bls.b    $1018183
0101816a  31671031          move.w   -(a7), $1031(a0)
0101816e  6008              bra.b    $1018178
01018170  31621055          move.w   -(a2), $1055(a0)
01018174  307a3267          movea.w  $101b3dd(pc), a0
01018178  5630653f4430455833304563  addq.b   #$3, ([$44304558, a0], d6.w * 4, $33304563)
01018184  2063              movea.l  -(a3), a0
01018186  2f3963205520      move.l   $63205520.l, -(a7)
0101818c  398f8920752b      move.w   a7, $752b(a4, a0.l)
01018192  357f              dc.w     $357f
01018194  3f1d              move.w   (a5)+, -(a7)
01018196  55386970          subq.b   #$2, $6970.w
0101819a  8f753990          or.w     d7, (d3.l)
0101819e  7a39              moveq    #$39, d5
010181a0  9022              sub.b    -(a2), d0
010181a2  338b37061b63      move.w   a3, ([a1], d3.w * 8, $1b63)
010181a8  585e              addq.w   #$4, (a6)+
010181aa  6977              bvs.b    $1018223
010181ac  8c91              or.l     (a1), d6
010181ae  8c91              or.l     (a1), d6
010181b0  7a20              moveq    #$20, d5
010181b2  208e              move.l   a6, (a0)
010181b4  5500              subq.b   #$2, d0
010181b6  401e              negx.b   (a6)+
010181b8  4047              negx.w   d7
010181ba  5846              addq.w   #$4, d6
010181bc  656b              bcs.b    $1018229
010181be  8065              or.w     -(a5), d0
010181c0  6a6d              bpl.b    $101822f
010181c2  697a              bvs.b    $101823e
010181c4  2020              move.l   -(a0), d0
010181c6  4f67              dc.w     $4f67
010181c8  1620              move.b   -(a0), d3
010181ca  6120              bsr.b    $10181ec
010181cc  3720              move.w   -(a0), -(a3)
010181ce  121d              move.b   (a5)+, d1
010181d0  227a1d21          movea.l  $1019ef3(pc), a1
010181d4  3320              move.w   -(a0), -(a1)
010181d6  7a20              moveq    #$20, d5
010181d8  203c7f1e201d      move.l   #$7f1e201d, d0
010181de  0f13              btst.l   d7, (a3)
010181e0  0f04              btst.l   d7, d4
010181e2  1c02              move.b   d2, d6
010181e4  7a1c              moveq    #$1c, d5
010181e6  0104              btst.l   d0, d4
010181e8  207a2020          movea.l  $101a20a(pc), a0
010181ec  358b2058          move.w   a3, $58(a2, d2.w)
010181f0  1c00              move.b   d0, d6
010181f2  0917              btst.l   d4, (a7)
010181f4  041c0250          subi.b   #$50, (a4)+
010181f8  0e01              dc.w     $0e01
010181fa  04005520          subi.b   #$20, d0
010181fe  218d5b40          move.l   a5, (a0, invalid.w)
01018202  1c00              move.b   d0, d6
01018204  0603041c          addi.b   #$1c, d3
01018208  02780e010300      andi.w   #$e01, $300.w

; ---- gap 01018216..01018938 (1827 bytes) ----
01018216  0603041d          addi.b   #$1d, d3
0101821a  22791d220f55      movea.l  $1d220f55.l, a1             ; $1d220f55 = RAM MWF mirrors (non-Turbo mono only)
01018220  2021              move.l   -(a1), d0
01018222  336982860006      move.w   -$7d7a(a1), $6(a1)
01018228  0d05              btst.l   d6, d5
0101822a  205a              movea.l  (a2)+, a0
0101822c  7a20              moveq    #$20, d5
0101822e  5a20              addq.b   #$5, -(a0)
01018230  7a20              moveq    #$20, d5
01018232  2249              movea.l  a1, a1
01018234  8c61              or.w     -(a1), d6
01018236  20374d12427e      move.l   ([a7, d4.l * 4], $427e), d0
0101823c  4258              clr.w    (a0)+
0101823e  7a20              moveq    #$20, d5
01018240  237787203b7f1257  move.l   $3b7f(a7, a0.w * 8), $1257(a1)
01018248  6b7b              bmi.b    $10182c5
0101824a  656a              bcs.b    $10182b6
0101824c  6d40              blt.b    $101828e
0101824e  7a20              moveq    #$20, d5
01018250  23338840          move.l   $40(a3, a0.l), -(a1)
01018254  487e              dc.w     $487e
01018256  1266              dc.w     $1266
01018258  7480              moveq    #$80, d2
0101825a  6674              bne.b    $10182d0
0101825c  697a              bvs.b    $10182d8
0101825e  2025              move.l   -(a5), d0
01018260  585f              addq.w   #$4, (a7)+
01018262  5b46              subq.w   #$5, d6
01018264  7284              moveq    #$84, d1
01018266  8c728385          or.w     ([], a0.w * 2), d6
0101826a  827a2000          or.w     $101a26c(pc), d1
0101826e  5300              subq.b   #$1, d0
01018270  00000000          ori.b    #$0, d0
01018274  00580000          ori.w    #$0, (a0)+
01018278  003f              dc.w     $003f
0101827a  9300              subx.b   d0, d1
0101827c  0100              btst.l   d0, d0
0101827e  02000301          andi.b   #$1, d0
01018282  0102              btst.l   d0, d2
01018284  0103              btst.l   d0, d3
01018286  0104              btst.l   d0, d4
01018288  0105              btst.l   d0, d5
0101828a  0107              btst.l   d0, d7
0101828c  0108010e          movep.w  $10e(a0), d0
01018290  0110              btst.l   d0, (a0)
01018292  0111              btst.l   d0, (a1)
01018294  0111              btst.l   d0, (a1)
01018296  02120115          andi.b   #$15, (a2)
0101829a  0116              btst.l   d0, (a6)
0101829c  0117              btst.l   d0, (a7)
0101829e  0119              btst.l   d0, (a1)+
010182a0  011a              btst.l   d0, (a2)+
010182a2  0129012a          btst.l   d0, $12a(a1)
010182a6  0140              bchg.b   d0, d0
010182a8  0141              bchg.b   d0, d1
010182aa  0144              bchg.b   d0, d4
010182ac  0145              bchg.b   d0, d5
010182ae  014a0150          movep.l  $150(a2), d0
010182b2  0151              bchg.b   d0, (a1)
010182b4  0154              bchg.b   d0, (a4)
010182b6  0155              bchg.b   d0, (a5)
010182b8  0155              bchg.b   d0, (a5)
010182ba  02550355          andi.w   #$355, (a5)
010182be  04550555          subi.w   #$555, (a5)
010182c2  06550755          addi.w   #$755, (a5)
010182c6  0855              dc.w     $0855
010182c8  0955              bchg.b   d4, (a5)
010182ca  0a550b55          eori.w   #$b55, (a5)
010182ce  0c550d55          cmpi.w   #$d55, (a5)
010182d2  0e55              dc.w     $0e55
010182d4  0f55              bchg.b   d7, (a5)
010182d6  1255              dc.w     $1255
010182d8  13551456          move.b   (a5), $1456(a1)
010182dc  0156              bchg.b   d0, (a6)
010182de  02570158          andi.w   #$158, (a7)
010182e2  0159              bchg.b   d0, (a1)+
010182e4  0159              bchg.b   d0, (a1)+
010182e6  025a015a          andi.w   #$15a, (a2)+
010182ea  025b015e          andi.w   #$15e, (a3)+
010182ee  015f              bchg.b   d0, (a7)+
010182f0  0160              bchg.b   d0, -(a0)
010182f2  0161              bchg.b   d0, -(a1)
010182f4  0164              bchg.b   d0, -(a4)
010182f6  0165              bchg.b   d0, -(a5)
010182f8  0166              bchg.b   d0, -(a6)
010182fa  0166              bchg.b   d0, -(a6)
010182fc  02660469          andi.w   #$469, -(a6)
01018300  016a016b          bchg.b   d0, $16b(a2)
01018304  016d016e          bchg.b   d0, $16e(a5)
01018308  016f0175          bchg.b   d0, $175(a7)
0101830c  0179017a017e      bchg.b   d0, $17a017e.l              ; $017a017e = ROM
01018312  017f              dc.w     $017f
01018314  0180              bclr.b   d0, d0
01018316  0184              bclr.b   d0, d4
01018318  0185              bclr.b   d0, d5
0101831a  0186              bclr.b   d0, d6
0101831c  0190              bclr.b   d0, (a0)
0101831e  0194              bclr.b   d0, (a4)
01018320  0195              bclr.b   d0, (a5)
01018322  0195              bclr.b   d0, (a5)
01018324  029601970199      andi.l   #$1970199, (a6)             ; $01970199 = ROM
0101832a  0199              bclr.b   d0, (a1)+
0101832c  0299039a019b      andi.l   #$39a019b, (a1)+
01018332  019d              bclr.b   d0, (a5)+
01018334  019e              bclr.b   d0, (a6)+
01018336  019f              bclr.b   d0, (a7)+
01018338  01a0              bclr.b   d0, -(a0)
0101833a  01a5              bclr.b   d0, -(a5)
0101833c  01a6              bclr.b   d0, -(a6)
0101833e  01a7              bclr.b   d0, -(a7)
01018340  01a901aa          bclr.b   d0, $1aa(a1)
01018344  01aa02aa          bclr.b   d0, $2aa(a2)
01018348  03aa04ab          bclr.b   d1, $4ab(a2)
0101834c  01ad01ae          bclr.b   d0, $1ae(a5)
01018350  01af01b0          bclr.b   d0, $1b0(a7)
01018354  01b101b501b901ba  bclr.b   d0, ([$1b901ba], d0.w)      ; $01b901ba = ROM
0101835c  01bb              dc.w     $01bb
0101835e  01bb              dc.w     $01bb
01018360  03bd              dc.w     $03bd
01018362  01be              dc.w     $01be
01018364  01bf              dc.w     $01bf
01018366  01c0              bset.b   d0, d0
01018368  01c4              bset.b   d0, d4
0101836a  01d5              bset.b   d0, (a5)
0101836c  01d6              bset.b   d0, (a6)
0101836e  01d9              bset.b   d0, (a1)+
01018370  01df              bset.b   d0, (a7)+
01018372  01e4              bset.b   d0, -(a4)
01018374  01e5              bset.b   d0, -(a5)
01018376  01e6              bset.b   d0, -(a6)
01018378  01e901ea          bset.b   d0, $1ea(a1)
0101837c  01eb01ed          bset.b   d0, $1ed(a3)
01018380  01ee01ee          bset.b   d0, $1ee(a6)
01018384  02ee              dc.w     $02ee
01018386  03ef01f2          bset.b   d1, $1f2(a7)
0101838a  01f501f901fa01fb  bset.b   d0, ([$1fa01fb])            ; $01fa01fb = ROM
01018392  01fd              dc.w     $01fd
01018394  01fe              dc.w     $01fe
01018396  01fe              dc.w     $01fe
01018398  02ff              dc.w     $02ff
0101839a  01ff              dc.w     $01ff
0101839c  02ff              dc.w     $02ff
0101839e  03ff              dc.w     $03ff
010183a0  04243064          subi.b   #$64, -(a4)
010183a4  6012              bra.b    $10183b8
010183a6  3f572624          move.w   (a7), $2624(a7)
010183aa  6317              bls.b    $10183c3
010183ac  36684827          movea.w  $4827(a0), a3
010183b0  23433056          move.l   d3, $3056(a1)
010183b4  6f29              ble.b    $10183df
010183b6  223019686f2a      move.l   $6f2a(a0, invalid.w), d1
010183bc  2242              movea.l  d2, a1
010183be  1189              dc.w     $1189
010183c0  2b22              move.l   -(a2), -(a5)
010183c2  536a2143          subq.w   #$1, $2143(a2)
010183c6  6525              bcs.b    $10183ed
010183c8  2134387d          move.l   $7d(a4, d3.l), -(a0)
010183cc  1f436453          move.b   d3, $6453(a7)
010183d0  1f656322          move.b   -(a5), $6322(a7)
010183d4  213e              dc.w     $213e
010183d6  6a1f              bpl.b    $10183f7
010183d8  6451              bcc.b    $101842b
010183da  0f40              bchg.b   d7, d0
010183dc  4303              chk.l    d3, d1
010183de  1e306421          move.b   $21(a0, d6.w), d7
010183e2  2150881e          move.l   (a0), -$77e2(a0)
010183e6  641e              bcc.b    $1018406
010183e8  3e366636          move.w   $36(a6, d6.w), d7
010183ec  6463              bcc.b    $1018451
010183ee  1e60              dc.w     $1e60
010183f0  2020              move.l   -(a0), d0
010183f2  3160361e          move.w   -(a0), $361e(a0)
010183f6  4360              dc.w     $4360
010183f8  38717082          movea.w  -$7e(a1, d7.w), a4
010183fc  5b65              subq.w   #$5, -(a5)
010183fe  3f13              move.w   (a3), -(a7)
01018400  2020              move.l   -(a0), d0
01018402  3463              movea.w  -(a3), a2
01018404  3053              movea.w  (a3), a0
01018406  3664              movea.w  -(a4), a3
01018408  826b908d          or.w     -$6f73(a3), d1
0101840c  6b8f              bmi.b    $101839d
0101840e  8064              or.w     -(a4), d0
01018410  1c60              dc.w     $1c60
01018412  1f20              move.b   -(a0), -(a7)
01018414  3f6e5f366486      move.w   $5f36(a6), $6486(a7)
0101841a  8a6f216a          or.w     $216a(a7), d5
0101841e  8e30361f          or.b     $1f(a0, d3.w), d7
01018422  203f              dc.w     $203f
01018424  7016              moveq    #$16, d0
01018426  4386              chk.w    d6, d1
01018428  8d60              or.w     d6, -(a0)
0101842a  2444              movea.l  d4, a2
0101842c  6454              bcc.b    $1018482
0101842e  1e20              move.b   -(a0), d7
01018430  3688              move.w   a0, (a3)
01018432  3e44              movea.w  d4, a7
01018434  8d60              or.w     d6, -(a0)
01018436  263a603e          move.l   $101e476(pc), d3
0101843a  1e20              move.b   -(a0), d7
0101843c  5a7942476327      addq.w   #$5, $42476327.l
01018442  307f              dc.w     $307f
01018444  1f20              move.b   -(a0), -(a7)
01018446  37647029          move.w   -(a4), $7029(a3)
0101844a  49301e20          chk.l    $20(a0, d1.l), d4
0101844e  5543              subq.w   #$2, d3
01018450  7053              moveq    #$53, d0
01018452  29363078          move.l   $78(a6, d3.w), -(a4)
01018456  1f304268          move.b   $68(a0, d4.w), -(a7)
0101845a  8c2a305f          or.b     $305f(a2), d6
0101845e  1e1f              move.b   (a7)+, d7
01018460  345a              movea.w  (a2)+, a2
01018462  757d              dc.w     $757d
01018464  2b4e481f          move.l   a6, $481f(a5)
01018468  3f438f2c          move.w   d3, -$70d4(a7)
0101846c  1660              dc.w     $1660
0101846e  1f536880          move.b   (a3), $6880(a7)
01018472  2c60              movea.l  -(a0), a6
01018474  691e              bvs.b    $1018494
01018476  3007              move.w   d7, d0
01018478  6b8a              bmi.b    $1018404
0101847a  2c53              movea.l  (a3), a6
0101847c  491e              chk.l    (a6)+, d4
0101847e  330c              move.w   a4, -(a1)
01018480  757c              dc.w     $757c
01018482  532b605c          subq.b   #$1, $605c(a3)
01018486  1e3d              dc.w     $1e3d
01018488  197551532b53451e533e  move.b   ([a5], $2b53451e), $533e(a4)
01018492  7b1e              dc.w     $7b1e
01018494  3e2b5569          move.w   $5569(a3), d7
01018498  31623a30          move.w   -(a2), $3a30(a0)
0101849c  362a3008          move.w   $3008(a2), d3
010184a0  6931              bvs.b    $10184d3
010184a2  4532631e6029      chk.l    ([a2], d6.w * 2, $6029), d2
010184a8  420f              dc.w     $420f
010184aa  4835731e8a1e      nbcd.b   ([a5], d7.w * 2, $8a1e)
010184b0  36283653          move.w   $3653(a0), d3
010184b4  6088              bra.b    $101843e
010184b6  343f              dc.w     $343f
010184b8  6e1e              bgt.b    $10184d8
010184ba  4b53              dc.w     $4b53
010184bc  1e60              dc.w     $1e60
010184be  26306030          move.l   $30(a0, d6.w), d3
010184c2  6878              bvc.b    $101853c
010184c4  3f36781e          move.w   $1e(a6, d7.l), -(a7)
010184c8  3a57              movea.w  (a7), a5
010184ca  533653243063      subq.b   #$1, $3063(a6, d5.w * 2)
010184d0  175a6b1e          move.b   (a2)+, $6b1e(a3)
010184d4  3e43              movea.w  d3, a7
010184d6  781e              moveq    #$1e, d4
010184d8  3280              move.w   d0, (a1)
010184da  1e1d              move.b   (a5)+, d7
010184dc  15642130          move.b   -(a4), $2130(a2)
010184e0  6457              bcc.b    $1018539
010184e2  1e19              move.b   (a1)+, d7
010184e4  4373              dc.w     $4373
010184e6  1e3f              dc.w     $1e3f
010184e8  4420              neg.b    -(a0)
010184ea  8a61              or.w     -(a1), d5
010184ec  1b0f              dc.w     $1b0f
010184ee  3467              movea.w  -(a7), a2
010184f0  634f              bls.b    $1018541
010184f2  1f606878          move.b   -(a0), $6878(a7)
010184f6  1e53              dc.w     $1e53
010184f8  6820              bvc.b    $101851a
010184fa  4c64              dc.w     $4c64
010184fc  5220              addq.b   #$1, -(a0)
010184fe  031f              btst.l   d1, (a7)+
01018500  1b07              move.b   d7, -(a5)
01018502  3643              movea.w  d3, a3
01018504  606b              bra.b    $1018571
01018506  1f17              move.b   (a7), -(a7)
01018508  1120              move.b   -(a0), -(a0)
0101850a  3883              move.w   d3, (a4)
0101850c  5364              subq.w   #$1, -(a4)
0101850e  531e              subq.b   #$1, (a6)+
01018510  031f              btst.l   d1, (a7)+
01018512  1b10              move.b   (a0), -(a5)
01018514  3f64816e          move.w   -(a4), -$7e92(a7)
01018518  1f16              move.b   (a6), -(a7)
0101851a  3621              move.w   -(a1), d3
0101851c  7560              dc.w     $7560
0101851e  6463              bcc.b    $1018583
01018520  571e              subq.b   #$3, (a6)+
01018522  5852              addq.w   #$4, (a2)
01018524  1a64              dc.w     $1a64
01018526  7170              dc.w     $7170
01018528  204f              movea.l  a7, a0
0101852a  5a21              addq.b   #$5, -(a1)
0101852c  3a80              move.w   d0, (a5)
0101852e  7165              dc.w     $7165
01018530  3065              movea.w  -(a5), a0
01018532  6336              bls.b    $101856a
01018534  6486              bcc.b    $10184bc
01018536  8920              or.b     d4, -(a0)
01018538  5546              subq.w   #$2, d6
0101853a  2244              movea.l  d4, a1
0101853c  8d836436          unpk     d3, d6, #$6436
01018540  6662              bne.b    $10185a4
01018542  758a              dc.w     $758a
01018544  21536a23          move.l   (a3), $6a23(a0)
01018548  448f              dc.w     $448f
0101854a  7144              dc.w     $7144
0101854c  7175              dc.w     $7175
0101854e  7464              moveq    #$64, d2
01018550  8922              or.b     d4, -(a2)
01018552  53692468          subq.w   #$1, $2468(a1)
01018556  8f6b9160          or.w     d7, -$6ea0(a3)
0101855a  2357442f          move.l   (a7), $442f(a1)
0101855e  6038              bra.b    $1018598
01018560  2f63432f          move.l   -(a3), $432f(a7)
01018564  6038              bra.b    $101859e
01018566  2f633653          move.l   -(a3), $3653(a7)
0101856a  2e80              move.l   d0, (a7)
0101856c  3053              movea.w  (a3), a0
0101856e  2e6f5160          movea.l  $5160(a7), a7
01018572  2e701b14          movea.l  (a0, d1.l * 2), a7
01018576  2e4b              movea.l  a3, a7
01018578  4e36              dc.w     $4e36
0101857a  2e46              movea.l  d6, a7
0101857c  1c30602d          move.b   $2d(a0, d6.w), d6
01018580  39301e57          move.w   $57(a0, d1.l), -(a4)
01018584  1e388f88          move.b   $8f88.w, d7
01018588  1e73              dc.w     $1e73
0101858a  29305a3e          move.l   $3e(a0, d5.l), -(a4)
0101858e  3f533664          move.w   (a3), $3664(a7)
01018592  6b8f              bmi.b    $1018523
01018594  7338              dc.w     $7338
01018596  91783891          sub.w    d0, $3891.w
0101859a  20307057          move.l   $57(a0, d7.w), d0
0101859e  345a              movea.w  (a2)+, a2
010185a0  6057              bra.b    $10185f9
010185a2  5d64              subq.w   #$6, -(a4)
010185a4  758b              dc.w     $758b
010185a6  928b              sub.l    a3, d1
010185a8  92781e1e          sub.w    $1e1e.w, d1
010185ac  7461              moveq    #$61, d2
010185ae  1e3c0e3f          move.b   #$3f, d7
010185b2  4557              dc.w     $4557
010185b4  4461              neg.w    -(a1)
010185b6  6680              bne.b    $1018538
010185b8  6165              bsr.b    $101861f
010185ba  6864              bvc.b    $1018620
010185bc  781e              moveq    #$1e, d4
010185be  1e4c              dc.w     $1e4c
010185c0  6357              bls.b    $1018619
010185c2  163c1e34          move.b   #$34, d3
010185c6  1e11              move.b   (a1), d7
010185c8  1c20              move.b   -(a0), d6
010185ca  781c              moveq    #$1c, d4
010185cc  1f301e78          move.b   $78(a0, d1.l), -(a7)
010185d0  1e1e              move.b   (a6)+, d7
010185d2  3a80              move.w   d0, (a5)
010185d4  61000d12          bsr.w    $10192e8
010185d8  0c041b02          cmpi.b   #$2, d4
010185dc  781b              moveq    #$1b, d4
010185de  0104              btst.l   d0, d4
010185e0  1e78              dc.w     $1e78
010185e2  1e1e              move.b   (a6)+, d7
010185e4  328b              move.w   a3, (a1)
010185e6  6318              bls.b    $1018600
010185e8  0b00              btst.l   d5, d0
010185ea  0919              btst.l   d4, (a1)+
010185ec  041b024d          subi.b   #$4d, (a3)+
010185f0  0b01              btst.l   d5, d1
010185f2  0400531e          subi.b   #$1e, d0
010185f6  1f8d              dc.w     $1f8d
010185f8  830c1b00          sbcd     -(a4), -(a1), #$1b00
010185fc  0603041b          addi.b   #$1b, d3
01018600  02760b010300      andi.w   #$b01, (a6, d0.w * 2)
01018606  531e              subq.b   #$1, (a6)+
01018608  1f3a8b1e          move.b   $1011128(pc), -(a7)
0101860c  3b00              move.w   d0, -(a5)
0101860e  0603041c          addi.b   #$1c, d3
01018612  20771c20          movea.l  $20(a7, d1.l), a0
01018616  0c531e1f          cmpi.w   #$1e1f, (a3)
0101861a  308d              move.w   a5, (a0)
0101861c  576c0006          subq.w   #$3, $6(a4)
01018620  0a051e59          eori.b   #$59, d5
01018624  781e              moveq    #$1e, d4
01018626  591e              subq.b   #$4, (a6)+
01018628  781e              moveq    #$1e, d4
0101862a  2046              movea.l  d6, a0
0101862c  613c              bsr.b    $101866a
0101862e  1e344a11          move.b   $11(a4, d4.l), d7
01018632  417e              dc.w     $417e
01018634  4157              dc.w     $4157
01018636  781e              moveq    #$1e, d4
01018638  21646d1e          move.l   -(a4), $6d1e(a0)
0101863c  397f              dc.w     $397f
0101863e  1155667a          move.b   (a5), $667a(a0)
01018642  6165              bsr.b    $10186a9
01018644  683f              bvc.b    $1018685
01018646  781e              moveq    #$1e, d4
01018648  2130873f467e116272806272  move.l   ([$467e1162, a0], a0.w * 8, $72806272), -(a0)
01018654  6478              bcc.b    $10186ce
01018656  1e23              move.b   -(a3), d7
01018658  575e              subq.w   #$3, (a6)+
0101865a  5a44              addq.w   #$5, d4
0101865c  7085              moveq    #$85, d0
0101865e  8b708486          or.w     d5, -$7a(a0, a0.w)
01018662  83781e00          or.w     d1, $1e00.w
01018666  5300              subq.b   #$1, d0
01018668  00000000          ori.b    #$0, d0
0101866c  00500000          ori.w    #$0, (a0)
01018670  005fa900          ori.w    #$a900, (a7)+
01018674  0100              btst.l   d0, d0
01018676  0e00              dc.w     $0e00
01018678  0f00              btst.l   d7, d0
0101867a  1101              move.b   d1, -(a0)
0101867c  0102              btst.l   d0, d2
0101867e  0102              btst.l   d0, d2
01018680  02030105          andi.b   #$5, d3
01018684  0106              btst.l   d0, d6
01018686  0107              btst.l   d0, d7
01018688  0108010a          movep.w  $10a(a0), d0
0101868c  010b010d          movep.w  $10d(a3), d0
01018690  010e010f          movep.w  $10f(a6), d0
01018694  0110              btst.l   d0, (a0)
01018696  0111              btst.l   d0, (a1)
01018698  0114              btst.l   d0, (a4)
0101869a  0115              btst.l   d0, (a5)
0101869c  0116              btst.l   d0, (a6)
0101869e  0119              btst.l   d0, (a1)+
010186a0  011f              btst.l   d0, (a7)+
010186a2  0120              btst.l   d0, -(a0)
010186a4  0126              btst.l   d0, -(a6)
010186a6  012a012b          btst.l   d0, $12b(a2)
010186aa  012f0133          btst.l   d0, $133(a7)
010186ae  0135013d013f0140  btst.l   d0, ([$13f0140, a5], d0.w)  ; $013f0140 = ROM
010186b6  0148014a          movep.l  $14a(a0), d0
010186ba  014e014f          movep.l  $14f(a6), d0
010186be  0150              bchg.b   d0, (a0)
010186c0  0151              bchg.b   d0, (a1)
010186c2  0152              bchg.b   d0, (a2)
010186c4  0154              bchg.b   d0, (a4)
010186c6  0155              bchg.b   d0, (a5)
010186c8  0155              bchg.b   d0, (a5)
010186ca  02550355          andi.w   #$355, (a5)
010186ce  04550556          subi.w   #$556, (a5)
010186d2  0157              bchg.b   d0, (a7)
010186d4  0158              bchg.b   d0, (a0)+
010186d6  0159              bchg.b   d0, (a1)+
010186d8  0159              bchg.b   d0, (a1)+
010186da  025a015b          andi.w   #$15b, (a2)+
010186de  015e              bchg.b   d0, (a6)+
010186e0  015f              bchg.b   d0, (a7)+
010186e2  0160              bchg.b   d0, -(a0)
010186e4  0162              bchg.b   d0, -(a2)
010186e6  0164              bchg.b   d0, -(a4)
010186e8  0165              bchg.b   d0, -(a5)
010186ea  0166              bchg.b   d0, -(a6)
010186ec  0166              bchg.b   d0, -(a6)
010186ee  02660366          andi.w   #$366, -(a6)
010186f2  04660667          subi.w   #$667, -(a6)
010186f6  016a016b          bchg.b   d0, $16b(a2)
010186fa  016c016e          bchg.b   d0, $16e(a4)
010186fe  016f0170          bchg.b   d0, $170(a7)
01018702  0179017a017e      bchg.b   d0, $17a017e.l              ; $017a017e = ROM
01018708  017f              dc.w     $017f
0101870a  0180              bclr.b   d0, d0
0101870c  0181              bclr.b   d0, d1
0101870e  0182              bclr.b   d0, d2
01018710  0187              bclr.b   d0, d7
01018712  018a018f          movep.w  d0, $18f(a2)
01018716  0190              bclr.b   d0, (a0)
01018718  0192              bclr.b   d0, (a2)
0101871a  0195              bclr.b   d0, (a5)
0101871c  0196              bclr.b   d0, (a6)
0101871e  0198              bclr.b   d0, (a0)+
01018720  0199              bclr.b   d0, (a1)+
01018722  0199              bclr.b   d0, (a1)+
01018724  0299049a019b      andi.l   #$49a019b, (a1)+            ; $049a019b = RAM bank 0 (Turbo: 32 MB stride)
0101872a  019d              bclr.b   d0, (a5)+
0101872c  019e              bclr.b   d0, (a6)+
0101872e  01a0              bclr.b   d0, -(a0)
01018730  01a2              bclr.b   d0, -(a2)
01018732  01a5              bclr.b   d0, -(a5)
01018734  01a6              bclr.b   d0, -(a6)
01018736  01a801a9          bclr.b   d0, $1a9(a0)
0101873a  01a902aa          bclr.b   d0, $2aa(a1)
0101873e  01aa02aa          bclr.b   d0, $2aa(a2)
01018742  03aa07aa          bclr.b   d1, $7aa(a2)
01018746  0faa10aa          bclr.b   d7, $10aa(a2)
0101874a  11ab01ad01ae01af01b2  move.b   $1ad(a3), ([$1af], d0.w, $1b2)
01018754  01b601b701b901ba01bb01bb  bclr.b   d0, ([$1b901ba], d0.w, $1bb01bb) ; $01b901ba = ROM; $01bb01bb = ROM
01018760  02bb              dc.w     $02bb
01018762  03bd              dc.w     $03bd
01018764  01be              dc.w     $01be
01018766  01be              dc.w     $01be
01018768  02bf              dc.w     $02bf
0101876a  01bf              dc.w     $01bf
0101876c  02c0              dc.w     $02c0
0101876e  01c1              bset.b   d0, d1
01018770  01c2              bset.b   d0, d2
01018772  01c3              bset.b   d0, d3
01018774  01c5              bset.b   d0, d5
01018776  01c6              bset.b   d0, d6
01018778  01c901cd          movep.l  d0, $1cd(a1)
0101877c  01d2              bset.b   d0, (a2)
0101877e  01d9              bset.b   d0, (a1)+
01018780  01e1              bset.b   d0, -(a1)
01018782  01e2              bset.b   d0, -(a2)
01018784  01e5              bset.b   d0, -(a5)
01018786  01e6              bset.b   d0, -(a6)
01018788  01e801e9          bset.b   d0, $1e9(a0)
0101878c  01ea01eb          bset.b   d0, $1eb(a2)
01018790  01ee01ee          bset.b   d0, $1ee(a6)
01018794  02ee              dc.w     $02ee
01018796  03ee0fef          bset.b   d1, $fef(a6)
0101879a  01ef02f0          bset.b   d0, $2f0(a7)
0101879e  01f101f201fa01fb01fb  bset.b   d0, ([$1fa01fb], $1fb)  ; $01fa01fb = ROM
010187a8  02fc              dc.w     $02fc
010187aa  01fd              dc.w     $01fd
010187ac  01fe              dc.w     $01fe
010187ae  01fe              dc.w     $01fe
010187b0  02fe              dc.w     $02fe
010187b2  04ff              dc.w     $04ff
010187b4  01ff              dc.w     $01ff
010187b6  02ff              dc.w     $02ff
010187b8  03ff              dc.w     $03ff
010187ba  04ff              dc.w     $04ff
010187bc  05ff              dc.w     $05ff
010187be  06ff              dc.w     $06ff
010187c0  07ff              dc.w     $07ff
010187c2  0fff              dc.w     $0fff
010187c4  1226              move.b   -(a6), d1
010187c6  031e              btst.l   d1, (a6)+
010187c8  2a286b78          move.l   $6b78(a0), d5
010187cc  2a37a82a          move.l   $2a(a7, a2.l), d5
010187d0  2f939501          move.l   (a3), ([a7, a1.w * 4])
010187d4  07a0              bclr.b   d3, -(a0)
010187d6  2a2f7b0c          move.l   $7b0c(a7), d5
010187da  6999              bvs.b    $1018775
010187dc  2a2f5e65          move.l   $5e65(a7), d5
010187e0  8d6ca299          or.w     d6, -$5d67(a4)
010187e4  757b              dc.w     $757b
010187e6  9f8f              subx.l   -(a7), -(a7)
010187e8  9d8d              subx.l   -(a5), -(a6)
010187ea  7b2a              dc.w     $7b2a
010187ec  2a50              movea.l  (a0), a5
010187ee  6fa2              ble.b    $1018792
010187f0  8d6ea499          or.w     d6, -$5b67(a6)
010187f4  775f              dc.w     $775f
010187f6  752a              dc.w     $752a
010187f8  2f1a              move.l   (a2)+, -(a7)
010187fa  9d8f              subx.l   -(a7), -(a6)
010187fc  6e9d              bgt.b    $101879b
010187fe  6575              bcs.b    $1018875
01018800  7ca2              moveq    #$a2, d6
01018802  9d90              sub.l    d6, (a0)
01018804  8d5f              or.w     d6, (a7)+
01018806  7b2a              dc.w     $7b2a
01018808  2f1b              move.l   (a3)+, -(a7)
0101880a  7574              dc.w     $7574
0101880c  6c8d              bge.b    $101879b
0101880e  656e              bcs.b    $101887e
01018810  99a4              sub.l    d4, -(a4)
01018812  9966              sub.w    d4, -(a6)
01018814  53752a29          subq.w   #$1, $29(a5, d2.l)
01018818  6e8f              bgt.b    $10187a9
0101881a  6579              bcs.b    $1018895
0101881c  3265              movea.w  -(a5), a1
0101881e  757b              dc.w     $757b
01018820  a49d              dc.w     $a49d
01018822  6639              bne.b    $101885d
01018824  7b2a              dc.w     $7b2a
01018826  296f73578915      move.l   $7357(a7), -$76eb(a4)
0101882c  4265              clr.w    -(a5)
0101882e  8f99              or.l     d7, (a1)+
01018830  a399              dc.w     $a399
01018832  6563              bcs.b    $1018897
01018834  53752a29          subq.w   #$1, $29(a5, d2.l)
01018838  748a              moveq    #$8a, d2
0101883a  4154              dc.w     $4154
0101883c  325a              movea.w  (a2)+, a1
0101883e  6c7b              bge.b    $10188bb
01018840  a49d              dc.w     $a49d
01018842  8d65              or.w     d6, -(a5)
01018844  397b2a287b57      move.w   $101886e(pc, d2.l), $7b57(a4)
0101884a  5d2a2f42          subq.b   #$6, $2f42(a2)
0101884e  6593              bcs.b    $10187e3
01018850  7ba4              dc.w     $7ba4
01018852  9863              sub.w    -(a3), d4
01018854  53752a28          subq.w   #$1, $28(a5, d2.l)
01018858  743c              moveq    #$3c, d2
0101885a  482b5765          nbcd.b   $5765(a3)
0101885e  75a5              dc.w     $75a5
01018860  7965              dc.w     $7965
01018862  397b2a287b57      move.w   $101888c(pc, d2.l), $7b57(a4)
01018868  893b              dc.w     $893b
0101886a  2a3c6c6ea599      move.l   #$6c6ea599, d5
01018870  6353              bls.b    $10188c5
01018872  752a              dc.w     $752a
01018874  28744155          movea.l  ([a4]), a4
01018878  2b32657599a379a0  move.l   ([$99a379a0, a2]), -(a5)
01018880  8d397b2a2878      or.b     d6, $7b2a2878.l
01018886  5d54              subq.w   #$6, (a4)
01018888  572a2f42          subq.b   #$3, $2f42(a2)
0101888c  6ea6              bgt.b    $1018834
0101888e  7353              dc.w     $7353
01018890  752a              dc.w     $752a
01018892  287449613b2a      movea.l  ([$3b2a, a4]), a4
01018898  3265              movea.w  -(a5), a1
0101889a  7593              dc.w     $7593
0101889c  a293              dc.w     $a293
0101889e  758f              dc.w     $758f
010188a0  9d397b2a2878      sub.b    d6, $7b2a2878.l
010188a6  7463              moveq    #$63, d2
010188a8  5754              subq.w   #$3, (a4)
010188aa  2f426ea5          move.l   d2, $6ea5(a7)
010188ae  7578              dc.w     $7578
010188b0  53752a28          subq.w   #$1, $28(a5, d2.l)
010188b4  7498              moveq    #$98, d2
010188b6  653c              bcs.b    $10188f4
010188b8  3b2a576c          move.w   $576c(a2), -(a5)
010188bc  75a2              dc.w     $75a2
010188be  9990              sub.l    d4, (a0)
010188c0  8e397b2a2878      or.b     $7b2a2878.l, d7
010188c6  8d65              or.w     d6, -(a5)
010188c8  582a3c6e          addq.b   #$4, $3c6e(a2)
010188cc  a279              dc.w     $a279
010188ce  937753752a287567  sub.w    d1, ([$2a287567, a7])
010188d6  3c2a326c          move.w   $326c(a2), d6
010188da  7ba2              dc.w     $7ba2
010188dc  9d90              sub.l    d6, (a0)
010188de  8d887b2a          unpk     -(a0), -(a6), #$7b2a
010188e2  287b6e66          movea.l  $101894a(pc, d6.l), a4
010188e6  582f4299          addq.b   #$4, $4299(a7)
010188ea  a199              dc.w     $a199
010188ec  7674              moveq    #$74, d3
010188ee  6585              bcs.b    $1018875
010188f0  752a              dc.w     $752a
010188f2  28797566613c      movea.l  $7566613c.l, a4
010188f8  325b              movea.w  (a3)+, a1
010188fa  7ba0              dc.w     $7ba0
010188fc  99798f8d6c65      sub.w    d4, $8f8d6c65.l
01018902  887b2a28          or.w     $101892c(pc, d2.l), d4
01018906  7b90              dc.w     $7b90
01018908  6657              bne.b    $1018961
0101890a  5542              subq.w   #$2, d2
0101890c  93a1              sub.l    d1, -(a1)
0101890e  99756e66          sub.w    d4, $66(a5, d6.l)
01018912  7075              moveq    #$75, d0
01018914  2a287b76          move.l   $7b76(a0), d5
01018918  7466              moveq    #$66, d2
0101891a  3b65799d          move.w   -(a5), $799d(a5)
0101891e  998f              subx.l   -(a7), -(a4)
01018920  8d67              or.w     d6, -(a7)
01018922  5f7b              dc.w     $5f7b
01018924  2a287ba0          move.l   $7ba0(a0), d5
01018928  908d              sub.l    a5, d0
0101892a  6557              bcs.b    $1018983
0101892c  347ba1756e675f75  movea.w  ([$6f68e8a3, pc]), a2
01018934  2a287b79          move.l   $7b79(a0), d5
01018938  a076              dc.w     $a076

; ---- gap 0101893e..0101a88f (8018 bytes) ----
0101893e  469d              not.l    (a5)+
01018940  8d67              or.w     d6, -(a7)
01018942  5a5f              addq.w   #$5, (a7)+
01018944  7b2a              dc.w     $7b2a
01018946  287ba290          movea.l  $10188d8(pc, a2.w), a4
0101894a  5a4d              addq.w   #$5, a5
0101894c  2a0f              move.l   a7, d5
0101894e  996e6661          sub.w    d4, $6661(a6)
01018952  6353              bls.b    $10189a7
01018954  752a              dc.w     $752a
01018956  287b9479          movea.l  $10189d1(pc, a1.w), a4
0101895a  a075              dc.w     $a075
0101895c  6214              bhi.b    $1018972
0101895e  2a27              move.l   -(a7), d5
01018960  8d66              or.w     d6, -(a6)
01018962  5a65              addq.w   #$5, -(a5)
01018964  3c397b2a287b      move.w   $7b2a287b.l, d6
0101896a  a299              dc.w     $a299
0101896c  a087              dc.w     $a087
0101896e  2a0e              move.l   a6, d5
01018970  2a5a              movea.l  (a2)+, a5
01018972  6542              bcs.b    $10189b6
01018974  6358              bls.b    $10189ce
01018976  53752a28          subq.w   #$1, $28(a5, d2.l)
0101897a  7ba3              dc.w     $7ba3
0101897c  9396              sub.l    d1, (a6)
0101897e  2a1f              move.l   (a7)+, d5
01018980  2a8d              move.l   a5, (a5)
01018982  6561              bcs.b    $10189e5
01018984  3e397b2a287b      move.w   $7b2a287b.l, d7
0101898a  a39d              dc.w     $a39d
0101898c  812c4963          or.b     d0, $4963(a4)
01018990  5953              subq.w   #$4, (a3)
01018992  752a              dc.w     $752a
01018994  287ba481          movea.l  $1018917(pc, a2.w), a4
01018998  2b3c493d3b2f      move.l   #$493d3b2f, -(a5)
0101899e  2a397b2a287b      move.l   $7b2a287b.l, d5
010189a4  a414              dc.w     $a414
010189a6  2a09              move.l   a1, d5
010189a8  2a5c              movea.l  (a4)+, a5
010189aa  542b543b          addq.b   #$2, $543b(a3)
010189ae  53752a28          subq.w   #$1, $28(a5, d2.l)
010189b2  7ba4              dc.w     $7ba4
010189b4  1529173c          move.b   $173c(a1), -(a2)
010189b8  452f2d39          chk.l    $2d39(a7), d2
010189bc  7b2a              dc.w     $7b2a
010189be  287ba414          movea.l  $10189d4(pc, a2.w), a4
010189c2  3110              move.w   (a0), -(a0)
010189c4  575c              subq.w   #$3, (a4)+
010189c6  2e28752a          move.l   $752a(a0), d7
010189ca  287ba419          movea.l  $10189e5(pc, a2.w), a4
010189ce  3c20              move.w   -(a0), d6
010189d0  3c45              movea.w  d5, a6
010189d2  3b2a332a          move.w   $332a(a2), -(a5)
010189d6  397b2a287ba4      move.w   $1018a00(pc, d2.l), $7ba4(a4)
010189dc  3257              movea.w  (a7), a1
010189de  7857              moveq    #$57, d4
010189e0  6d58              blt.b    $1018a3a
010189e2  2b3253752a287ba4  move.l   ([$2a287ba4, a2]), -(a5)
010189ea  823d              dc.w     $823d
010189ec  42713f2a397b2a28  clr.w    ([$397b, a1, d3.l * 8], $2a28)
010189f4  7ba3              dc.w     $7ba3
010189f6  9983              subx.l   d3, d4
010189f8  6661              bne.b    $1018a5b
010189fa  7165              dc.w     $7165
010189fc  5953              subq.w   #$4, (a3)
010189fe  752a              dc.w     $752a
01018a00  287ba29e          movea.l  $10189a0(pc, a2.w), a4
01018a04  885a              or.w     (a2)+, d4
01018a06  3665              movea.w  -(a5), a3
01018a08  8f66              or.w     d7, -(a6)
01018a0a  613d              bsr.b    $1018a49
01018a0c  397b2a287ba1      move.w   $1018a36(pc, d2.l), $7ba1(a4)
01018a12  937b              dc.w     $937b
01018a14  8f8b654a          unpk     -(a3), -(a7), #$654a
01018a18  659d              bcs.b    $10189b7
01018a1a  9867              sub.w    -(a7), d4
01018a1c  6353              bls.b    $1018a71
01018a1e  752a              dc.w     $752a
01018a20  287b9ea0          movea.l  $10189c2(pc, a1.l), a4
01018a24  9975658d          sub.w    d4, ([], d6.w * 4)
01018a28  656f              bcs.b    $1018a99
01018a2a  998e              subx.l   -(a6), -(a4)
01018a2c  7567              dc.w     $7567
01018a2e  5f7b              dc.w     $5f7b
01018a30  2a287ba1          move.l   $7ba1(a0), d5
01018a34  9161              sub.w    d0, -(a1)
01018a36  4a65              tst.w    -(a5)
01018a38  a07b              dc.w     $a07b
01018a3a  7990              dc.w     $7990
01018a3c  8d65              or.w     d6, -(a5)
01018a3e  39752a287b93      move.w   $28(a5, d2.l), $7b93(a4)
01018a44  7765              dc.w     $7765
01018a46  5735a199          subq.b   #$3, ([, a2.w])
01018a4a  8ea0              or.l     -(a0), d7
01018a4c  775f              dc.w     $775f
01018a4e  7b2a              dc.w     $7b2a
01018a50  2875a09d          movea.l  -$63(a5, a2.w), a4
01018a54  9065              sub.w    -(a5), d0
01018a56  2a356ca2          move.l   -$5e(a5, d6.l), d5
01018a5a  939d              sub.l    d1, (a5)+
01018a5c  9085              sub.l    d5, d0
01018a5e  752a              dc.w     $752a
01018a60  287b7765643c      movea.l  ([$101ee9e, pc]), a4
01018a66  7ca0              moveq    #$a0, d6
01018a68  79a0              dc.w     $79a0
01018a6a  7ba0              dc.w     $7ba0
01018a6c  995f              sub.w    d4, (a7)+
01018a6e  7b2a              dc.w     $7b2a
01018a70  287b9165614e      movea.l  ([$101ebc0, pc]), a4
01018a76  4293              clr.l    (a3)
01018a78  a299              dc.w     $a299
01018a7a  9d99              sub.l    d6, (a1)+
01018a7c  a088              dc.w     $a088
01018a7e  752a              dc.w     $752a
01018a80  287976665747      movea.l  $76665747.l, a4
01018a86  5579a393a079      subq.w   #$2, $a393a079.l
01018a8c  887b2a28          or.w     $1018ab6(pc, d2.l), d4
01018a90  7b90              dc.w     $7b90
01018a92  6561              bcs.b    $1018af5
01018a94  3b441a93          move.w   d4, $1a93(a5)
01018a98  a29d              dc.w     $a29d
01018a9a  a099              dc.w     $a099
01018a9c  a097              dc.w     $a097
01018a9e  752a              dc.w     $752a
01018aa0  287599665754      movea.l  ([$5754, a5]), a4
01018aa6  350d              move.w   a5, -(a2)
01018aa8  7993              dc.w     $7993
01018aaa  a29d              dc.w     $a29d
01018aac  a099              dc.w     $a099
01018aae  887b2a28          or.w     $1018ad8(pc, d2.l), d4
01018ab2  798f              dc.w     $798f
01018ab4  7465              moveq    #$65, d2
01018ab6  3c2a367e          move.w   $367e(a2), d6
01018aba  93a5              sub.l    d1, -(a5)
01018abc  7b70              dc.w     $7b70
01018abe  752a              dc.w     $752a
01018ac0  28759865          movea.l  $65(a5, a1.l), a4
01018ac4  6357              bls.b    $1018b1d
01018ac6  5441              addq.w   #$2, d1
01018ac8  954b              subx.w   -(a3), -(a2)
01018aca  7ba5              dc.w     $7ba5
01018acc  887b2a28          or.w     $1018af6(pc, d2.l), d4
01018ad0  7998              dc.w     $7998
01018ad2  6561              bcs.b    $1018b35
01018ad4  3b2a429b          move.w   $429b(a2), -(a5)
01018ad8  17a499a07075      move.b   -(a4), $7075(a1.l)
01018ade  2a287574          move.l   $7574(a0), d5
01018ae2  6358              bls.b    $1018b3c
01018ae4  2a65              movea.l  -(a5), a5
01018ae6  7b1d              dc.w     $7b1d
01018ae8  a59d              dc.w     $a59d
01018aea  887b2a28          or.w     $1018b14(pc, d2.l), d4
01018aee  788f              moveq    #$8f, d4
01018af0  613c              bsr.b    $1018b2e
01018af2  3b2f326e          move.w   $326e(a7), -(a5)
01018af6  7d7b              dc.w     $7d7b
01018af8  a475              dc.w     $a475
01018afa  7075              moveq    #$75, d0
01018afc  2a287443          move.l   $7443(a0), d5
01018b00  6057              bra.b    $1018b59
01018b02  5432656f951c      addq.b   #$2, ([$951c, a2])
01018b08  a48d              dc.w     $a48d
01018b0a  5f7b              dc.w     $5f7b
01018b0c  2a287865          move.l   $7865(a0), d5
01018b10  8c3c2a2f          or.b     #$2f, d6
01018b14  42759b0aa29d      clr.w    ([a5, a1.l * 2], $a29d)
01018b1a  9365              sub.w    d1, -(a5)
01018b1c  7075              moveq    #$75, d0
01018b1e  2a287443          move.l   $7443(a0), d5
01018b22  7357              dc.w     $7357
01018b24  5434656e9304      addq.b   #$2, ([$9304, a4])
01018b2a  a37b              dc.w     $a37b
01018b2c  a088              dc.w     $a088
01018b2e  7b2a              dc.w     $7b2a
01018b30  28786e9d          movea.l  $6e9d.w, a4
01018b34  3c2a4265          move.w   $4265(a2), d6
01018b38  75a0              dc.w     $75a0
01018b3a  7d1c              dc.w     $7d1c
01018b3c  a488              dc.w     $a488
01018b3e  752a              dc.w     $752a
01018b40  28746c7b          movea.l  $7b(a4, d6.l), a4
01018b44  572a5a65          subq.b   #$3, $5a65(a2)
01018b48  937b              dc.w     $937b
01018b4a  950a              subx.b   -(a2), -(a2)
01018b4c  a19d              dc.w     $a19d
01018b4e  a188              dc.w     $a188
01018b50  7b2a              dc.w     $7b2a
01018b52  28796ea08a2a      movea.l  $6ea08a2a.l, a4
01018b58  4265              clr.w    -(a5)
01018b5a  7599              dc.w     $7599
01018b5c  9b00              subx.b   d0, d5
01018b5e  a19a              dc.w     $a19a
01018b60  7588              dc.w     $7588
01018b62  752a              dc.w     $752a
01018b64  28746fa09d3b      movea.l  $9d3b(d6.l * 8), a4
01018b6a  5a65              addq.w   #$5, -(a5)
01018b6c  937b              dc.w     $937b
01018b6e  a000              dc.w     $a000
01018b70  93a1              sub.l    d1, -(a1)
01018b72  524a              addq.w   #$1, a2
01018b74  887b2a28          or.w     $1018b9e(pc, d2.l), d4
01018b78  7978              dc.w     $7978
01018b7a  5aa0              addq.l   #$5, -(a0)
01018b7c  8d65              or.w     d6, -(a5)
01018b7e  6e75              bgt.b    $1018bf5
01018b80  9da0              sub.l    d6, -(a0)
01018b82  804f              dc.w     $804f
01018b84  a08d              dc.w     $a08d
01018b86  210f              move.l   a7, -(a0)
01018b88  88752a28          or.w     $28(a5, d2.l), d4
01018b8c  748a              moveq    #$8a, d2
01018b8e  3c46              movea.w  d6, a6
01018b90  9d66              sub.w    d6, -(a6)
01018b92  93a1              sub.l    d1, -(a1)
01018b94  9d12              sub.b    d6, (a2)
01018b96  7a09              moveq    #$9, d5
01018b98  2488              move.l   a0, (a2)
01018b9a  7b2a              dc.w     $7b2a
01018b9c  2875585b          movea.l  $5b(a5, d5.l), a4
01018ba0  a08d              dc.w     $a08d
01018ba2  6c79              bge.b    $1018c1d
01018ba4  93a0              sub.l    d1, -(a0)
01018ba6  9b22              sub.b    d5, -(a2)
01018ba8  17841651          move.b   d4, $51(a3, d1.w)
01018bac  5f752a28          subq.w   #$7, $28(a5, d2.l)
01018bb0  723d              moveq    #$3d, d1
01018bb2  41a1              chk.w    -(a1), d0
01018bb4  6593              bcs.b    $1018b49
01018bb6  a20f              dc.w     $a20f
01018bb8  0609              dc.w     $0609
01018bba  25887b2a28785705  move.l   a0, ([$2878, a2, d7.l * 2], $5705)
01018bc2  5aa1              addq.l   #$5, -(a1)
01018bc4  9d7b              dc.w     $9d7b
01018bc6  a27d              dc.w     $a27d
01018bc8  0b11              btst.l   d5, (a1)
01018bca  4c20              dc.w     $4c20
01018bcc  5f752a28          subq.w   #$7, $28(a5, d2.l)
01018bd0  793a              dc.w     $793a
01018bd2  148a              dc.w     $148a
01018bd4  a29d              dc.w     $a29d
01018bd6  8f94              or.l     d7, (a4)
01018bd8  9518              sub.b    d2, (a0)+
01018bda  2920              move.l   -(a0), -(a4)
01018bdc  9d88              subx.l   -(a0), -(a6)
01018bde  7b2a              dc.w     $7b2a
01018be0  2878562a          movea.l  $562a.w, a4
01018be4  86a5              or.l     -(a5), d3
01018be6  759b              dc.w     $759b
01018be8  4d2a1099          chk.l    $1099(a2), d6
01018bec  5f752a28          subq.w   #$7, $28(a5, d2.l)
01018bf0  793a              dc.w     $793a
01018bf2  2f8aa39d          move.l   a2, ([], a2.w * 2)
01018bf6  6e8f              bgt.b    $1018b87
01018bf8  a008              dc.w     $a008
01018bfa  2a10              move.l   (a0), d5
01018bfc  8f5f              or.w     d7, (a7)+
01018bfe  7b2a              dc.w     $7b2a
01018c00  28785a5b          movea.l  $5a5b.w, a4
01018c04  5aa3              addq.l   #$5, -(a3)
01018c06  9d6c757b          sub.w    d6, $757b(a4)
01018c0a  7e29              moveq    #$29, d7
01018c0c  207453752a287b3c  movea.l  ([$2a287b3c, a4]), a0
01018c14  7941              dc.w     $7941
01018c16  a69b              dc.w     $a69b
01018c18  3826              move.w   -(a6), d4
01018c1a  9d8d              subx.l   -(a5), -(a6)
01018c1c  397b2a287b58      move.w   $1018c46(pc, d2.l), $7b58(a4)
01018c22  5ba6              subq.l   #$5, -(a6)
01018c24  96310799          sub.b    ([, d0.w * 8]), d3
01018c28  6353              bls.b    $1018c7d
01018c2a  752a              dc.w     $752a
01018c2c  287b8a3c          movea.l  $1018c6a(pc, a0.l), a4
01018c30  458d              dc.w     $458d
01018c32  613d              bsr.b    $1018c71
01018c34  4ba1              chk.w    -(a1), d5
01018c36  9b2f108f          sub.b    d5, $108f(a7)
01018c3a  6139              bsr.b    $1018c75
01018c3c  7b2a              dc.w     $7b2a
01018c3e  287b9c57          movea.l  $1018c97(pc, a1.l), a4
01018c42  996e6358          sub.w    d4, $6358(a6)
01018c46  7ba2              dc.w     $7ba2
01018c48  137b74575375      move.b   $1018ca1(pc, d7.w), $5375(a1)
01018c4e  2a287ba1          move.l   $7ba1(a0), d5
01018c52  8f8d6140          unpk     -(a5), -(a7), #$6140
01018c56  7f9d              dc.w     $7f9d
01018c58  8d3c              dc.w     $8d3c
01018c5a  397b2a287ba2      move.w   $1018c84(pc, d2.l), $7ba2(a4)
01018c60  7468              moveq    #$68, d2
01018c62  6c99              bge.b    $1018bfd
01018c64  6357              bls.b    $1018cbd
01018c66  53752a28          subq.w   #$1, $28(a5, d2.l)
01018c6a  5e02              addq.b   #$7, d2
01018c6c  057b              dc.w     $057b
01018c6e  2a286b75          move.l   $6b75(a0), d5
01018c72  2a286b7b          move.l   $6b7b(a0), d5
01018c76  2a286b75          move.l   $6b75(a0), d5
01018c7a  2a286b7b          move.l   $6b7b(a0), d5
01018c7e  2a296b75          move.l   $6b75(a1), d5
01018c82  2a2a1a6a          move.l   $1a6a(a2), d5
01018c86  7b2a              dc.w     $7b2a
01018c88  2a23              move.l   -(a3), d5
01018c8a  6a75              bpl.b    $1018d01
01018c8c  2a2a286a          move.l   $286a(a2), d5
01018c90  7b2a              dc.w     $7b2a
01018c92  2a296a75          move.l   $6a75(a1), d5
01018c96  2a2b1a69          move.l   $1a69(a3), d5
01018c9a  7b2a              dc.w     $7b2a
01018c9c  2b23              move.l   -(a3), -(a5)
01018c9e  6975              bvs.b    $1018d15
01018ca0  2a2b2869          move.l   $2869(a3), d5
01018ca4  7b2a              dc.w     $7b2a
01018ca6  2b30a799          move.l   ([, a2.w * 8]), -(a5)
01018caa  2a2c9293          move.l   -$6d6d(a4), d5
01018cae  2a2c4ba7          move.l   $4ba7(a4), d5
01018cb2  2a00              move.l   d0, d5
01018cb4  00005500          ori.b    #$0, d0
01018cb8  00000000          ori.b    #$0, d0
01018cbc  0048              dc.w     $0048
01018cbe  00000041          ori.b    #$41, d0
01018cc2  56a0              addq.l   #$3, -(a0)
01018cc4  aaea              dc.w     $aaea
01018cc6  abff              dc.w     $abff
01018cc8  ffff              dc.w     $ffff
01018cca  fbbb              dc.w     $fbbb
01018ccc  bffe              dc.w     $bffe
01018cce  fefefeeefeea      fbf.l    $fff08bba                   ; $fff08bba = NextBus slot space
01018cd4  558a              subq.l   #$2, a2
01018cd6  afff              dc.w     $afff
01018cd8  ffff              dc.w     $ffff
01018cda  ffff              dc.w     $ffff
01018cdc  ffee              dc.w     $ffee
01018cde  baa99ffb          cmp.l    -$6005(a1), d5
01018ce2  bbbb              dc.w     $bbbb
01018ce4  bba2              eor.l    d5, -(a2)
01018ce6  562afeee          addq.b   #$3, -$112(a2)
01018cea  aeff              dc.w     $aeff
01018cec  aeea              dc.w     $aeea
01018cee  aa66              dc.w     $aa66
01018cf0  5599              subq.l   #$2, (a1)+
01018cf2  9abe              dc.w     $9abe
01018cf4  eeee              dc.w     $eeee
01018cf6  eaa2              asr.l    d5, d2
01018cf8  562bbbba          addq.b   #$3, -$4446(a3)
01018cfc  abfb              dc.w     $abfb
01018cfe  fbaa              dc.w     $fbaa
01018d00  a999              dc.w     $a999
01018d02  5566              subq.w   #$2, -(a6)
01018d04  aaab              dc.w     $aaab
01018d06  fbaa              dc.w     $fbaa
01018d08  aa92              dc.w     $aa92
01018d0a  54aeeeaa          addq.l   #$2, -$1156(a6)
01018d0e  bfff              dc.w     $bfff
01018d10  eeee              dc.w     $eeee
01018d12  a665              dc.w     $a665
01018d14  9599              sub.l    d2, (a1)+
01018d16  aaaa              dc.w     $aaaa
01018d18  eeaa              lsr.l    d7, d2
01018d1a  aa62              dc.w     $aa62
01018d1c  54afb999          addq.l   #$2, -$4667(a7)
01018d20  ffef              dc.w     $ffef
01018d22  bbaaa999          eor.l    d5, -$5667(a2)
01018d26  5566              subq.w   #$2, -(a6)
01018d28  aaab              dc.w     $aaab
01018d2a  bbaaa992          eor.l    d5, -$566e(a2)
01018d2e  54ba              dc.w     $54ba
01018d30  e667              asr.w    d3, d7
01018d32  eeff              dc.w     $eeff
01018d34  eeea              dc.w     $eeea
01018d36  a665              dc.w     $a665
01018d38  559a              subq.l   #$2, (a2)+
01018d3a  6aae              bpl.b    $1018cea
01018d3c  eeea              dc.w     $eeea
01018d3e  aa62              dc.w     $aa62
01018d40  52bf              dc.w     $52bf
01018d42  999f              sub.l    d4, (a7)+
01018d44  fffe              dc.w     $fffe
01018d46  fbae              dc.w     $fbae
01018d48  a999              dc.w     $a999
01018d4a  9566              sub.w    d2, -(a6)
01018d4c  aaeb              dc.w     $aaeb
01018d4e  bbba              dc.w     $bbba
01018d50  a992              dc.w     $a992
01018d52  52ba              dc.w     $52ba
01018d54  667b              bne.b    $1018dd1
01018d56  efbf              rol.l    d7, d7
01018d58  beeaaa65          cmpa.w   -$559b(a2), a7
01018d5c  559a              subq.l   #$2, (a2)+
01018d5e  aaae              dc.w     $aaae
01018d60  eefe              dc.w     $eefe
01018d62  aa62              dc.w     $aa62
01018d64  52bf              dc.w     $52bf
01018d66  99effffb          suba.l   -$5(a7), a4
01018d6a  fbba              dc.w     $fbba
01018d6c  a999              dc.w     $a999
01018d6e  566aaabb          addq.w   #$3, -$5545(a2)
01018d72  bbefa992          cmpa.l   -$566e(a7), a5
01018d76  52ba              dc.w     $52ba
01018d78  67ffffffbeea      beq.l    $1014c64
01018d7e  aa65              dc.w     $aa65
01018d80  559a              subq.l   #$2, (a2)+
01018d82  aaee              dc.w     $aaee
01018d84  eeff              dc.w     $eeff
01018d86  ea62              asr.w    d5, d2
01018d88  52bd              dc.w     $52bd
01018d8a  9eff              dc.w     $9eff
01018d8c  ffbf              dc.w     $ffbf
01018d8e  ffba              dc.w     $ffba
01018d90  a999              dc.w     $a999
01018d92  566aaabb          addq.w   #$3, -$5545(a2)
01018d96  bfbe              dc.w     $bfbe
01018d98  f992              dc.w     $f992
01018d9a  52ba              dc.w     $52ba
01018d9c  7fff              dc.w     $7fff
01018d9e  fffe              dc.w     $fffe
01018da0  fbee              dc.w     $fbee
01018da2  aa65              dc.w     $aa65
01018da4  59a6              subq.l   #$4, -(a6)
01018da6  aeee              dc.w     $aeee
01018da8  fbff              dc.w     $fbff
01018daa  fe6252bd          ftrapor.b -(a2)
01018dae  bfff              dc.w     $bfff
01018db0  ffff              dc.w     $ffff
01018db2  ffba              dc.w     $ffba
01018db4  a999              dc.w     $a999
01018db6  566abbbb          addq.w   #$3, -$4445(a2)
01018dba  ffff              dc.w     $ffff
01018dbc  fd92              dc.w     $fd92
01018dbe  52ba              dc.w     $52ba
01018dc0  ffff              dc.w     $ffff
01018dc2  ffff              dc.w     $ffff
01018dc4  fbee              dc.w     $fbee
01018dc6  aa65              dc.w     $aa65
01018dc8  59aaaeff          subq.l   #$4, -$5101(a2)
01018dcc  bfbf              dc.w     $bfbf
01018dce  fe6252bd          ftrapor.b -(a2)
01018dd2  ffff              dc.w     $ffff
01018dd4  ffff              dc.w     $ffff
01018dd6  fffb              dc.w     $fffb
01018dd8  aa99              dc.w     $aa99
01018dda  566abbbb          addq.w   #$3, -$4445(a2)
01018dde  ffff              dc.w     $ffff
01018de0  ff92              dc.w     $ff92
01018de2  52bb              dc.w     $52bb
01018de4  ffff              dc.w     $ffff
01018de6  ffff              dc.w     $ffff
01018de8  efbe              rol.l    d7, d6
01018dea  aa65              dc.w     $aa65
01018dec  59aaeeff          subq.l   #$4, -$1101(a2)
01018df0  fbff              dc.w     $fbff
01018df2  ffa2              dc.w     $ffa2
01018df4  52bf              dc.w     $52bf
01018df6  ffff              dc.w     $ffff
01018df8  ffff              dc.w     $ffff
01018dfa  fffb              dc.w     $fffb
01018dfc  aa95              dc.w     $aa95
01018dfe  66ab              bne.b    $1018dab
01018e00  bfeeffff          cmpa.l   -$1(a6), a7
01018e04  ff92              dc.w     $ff92
01018e06  52bf              dc.w     $52bf
01018e08  ffff              dc.w     $ffff
01018e0a  ffff              dc.w     $ffff
01018e0c  ffbe              dc.w     $ffbe
01018e0e  eb65              asl.w    d5, d5
01018e10  59aeefff          subq.l   #$4, -$1001(a6)
01018e14  ffff              dc.w     $ffff
01018e16  ffe2              dc.w     $ffe2
01018e18  52bf              dc.w     $52bf
01018e1a  ffff              dc.w     $ffff
01018e1c  ffff              dc.w     $ffff
01018e1e  fffb              dc.w     $fffb
01018e20  ba95              cmp.l    (a5), d5
01018e22  66bb              bne.b    $1018ddf
01018e24  bfbf              dc.w     $bfbf
01018e26  ffff              dc.w     $ffff
01018e28  ffe2              dc.w     $ffe2
01018e2a  52bf              dc.w     $52bf
01018e2c  ffff              dc.w     $ffff
01018e2e  ffff              dc.w     $ffff
01018e30  ffff              dc.w     $ffff
01018e32  ea65              asr.w    d5, d5
01018e34  5aeefffe          spl.b    -$2(a6)
01018e38  ffff              dc.w     $ffff
01018e3a  ffe2              dc.w     $ffe2
01018e3c  52bf              dc.w     $52bf
01018e3e  bfefffff          cmpa.l   -$1(a7), a7
01018e42  fffb              dc.w     $fffb
01018e44  ba95              cmp.l    (a5), d5
01018e46  6bbb              bmi.b    $1018e03
01018e48  fbff              dc.w     $fbff
01018e4a  ffff              dc.w     $ffff
01018e4c  ffe2              dc.w     $ffe2
01018e4e  52bf              dc.w     $52bf
01018e50  ffff              dc.w     $ffff
01018e52  ffff              dc.w     $ffff
01018e54  ffff              dc.w     $ffff
01018e56  e000              asr.b    #$8, d0
01018e58  5eff              dc.w     $5eff
01018e5a  ffff              dc.w     $ffff
01018e5c  ffff              dc.w     $ffff
01018e5e  ffe2              dc.w     $ffe2
01018e60  52be              dc.w     $52be
01018e62  fbff              dc.w     $fbff
01018e64  ffff              dc.w     $ffff
01018e66  ffff              dc.w     $ffff
01018e68  c155              and.w    d0, (a5)
01018e6a  0fefbfff          bset.b   d7, -$4001(a7)
01018e6e  ffff              dc.w     $ffff
01018e70  fff2              dc.w     $fff2
01018e72  52bf              dc.w     $52bf
01018e74  ffef              dc.w     $ffef
01018e76  beff              dc.w     $beff
01018e78  bff81555          cmpa.l   $1555.w, a7
01018e7c  52ff              dc.w     $52ff
01018e7e  ffff              dc.w     $ffff
01018e80  fffe              dc.w     $fffe
01018e82  fff2              dc.w     $fff2
01018e84  52bf              dc.w     $52bf
01018e86  efff              dc.w     $efff
01018e88  fffb              dc.w     $fffb
01018e8a  ffe1              dc.w     $ffe1
01018e8c  550d              dc.w     $550d
01018e8e  55ff              dc.w     $55ff
01018e90  ffff              dc.w     $ffff
01018e92  ffff              dc.w     $ffff
01018e94  fff2              dc.w     $fff2
01018e96  52be              dc.w     $52be
01018e98  ffbe              dc.w     $ffbe
01018e9a  fbff              dc.w     $fbff
01018e9c  eff1553d55ffffffffff  bfins    d5, ([$ffffffff]){20:5} ; $ffffffff = NextBus slot space
01018ea6  fbf2              dc.w     $fbf2
01018ea8  52bf              dc.w     $52bf
01018eaa  bbff              dc.w     $bbff
01018eac  ffef              dc.w     $ffef
01018eae  ffc5              dc.w     $ffc5
01018eb0  5555              subq.w   #$2, (a5)
01018eb2  557f              dc.w     $557f
01018eb4  ffff              dc.w     $ffff
01018eb6  fefefff252be      fbf.l    $f3e176                     ; $00f3e176 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01018ebc  eeee              dc.w     $eeee
01018ebe  effe              dc.w     $effe
01018ec0  fbc5              dc.w     $fbc5
01018ec2  5555              subq.w   #$2, (a5)
01018ec4  667f              bne.b    $1018f45
01018ec6  bfbf              dc.w     $bfbf
01018ec8  ffff              dc.w     $ffff
01018eca  efe2              dc.w     $efe2
01018ecc  52bf              dc.w     $52bf
01018ece  bbbb              dc.w     $bbbb
01018ed0  bbbf              dc.w     $bbbf
01018ed2  ff15              fsave    (a5)
01018ed4  5506              subq.b   #$2, d6
01018ed6  559f              subq.l   #$2, (a7)+
01018ed8  fffe              dc.w     $fffe
01018eda  fffb              dc.w     $fffb
01018edc  fef252baeeee      fbf.l    $53bc7dcc
01018ee2  eeee              dc.w     $eeee
01018ee4  ee16              roxr.b   #$7, d6
01018ee6  541f              addq.b   #$2, (a7)+
01018ee8  666e              bne.b    $1018f58
01018eea  fbef              dc.w     $fbef
01018eec  efbf              rol.l    d7, d7
01018eee  fff2              dc.w     $fff2
01018ef0  52be              dc.w     $52be
01018ef2  aaaa              dc.w     $aaaa
01018ef4  aabb              dc.w     $aabb
01018ef6  bb15              eor.b    d5, (a5)
01018ef8  580f              dc.w     $580f
01018efa  999f              sub.l    d4, (a7)+
01018efc  ffff              dc.w     $ffff
01018efe  fefeeee252be      fbf.l    $efe3e1be
01018f04  aaaa              dc.w     $aaaa
01018f06  aaaa              dc.w     $aaaa
01018f08  aa26              dc.w     $aa26
01018f0a  663f              bne.b    $1018f4b
01018f0c  666e              bne.b    $1018f7c
01018f0e  bbbb              dc.w     $bbbb
01018f10  bbbb              dc.w     $bbbb
01018f12  bbb252be          eor.l    d5, -$42(a2, d5.w)
01018f16  aaaa              dc.w     $aaaa
01018f18  aaaa              dc.w     $aaaa
01018f1a  aa55              dc.w     $aa55
01018f1c  99bd              dc.w     $99bd
01018f1e  99adaaee          sub.l    d4, -$5512(a5)
01018f22  eeee              dc.w     $eeee
01018f24  eee2              dc.w     $eee2
01018f26  52be              dc.w     $52be
01018f28  aaaa              dc.w     $aaaa
01018f2a  aaaa              dc.w     $aaaa
01018f2c  6656              bne.b    $1018f84
01018f2e  6666              bne.b    $1018f96
01018f30  6ab6              bpl.b    $1018ee8
01018f32  6aaa              bpl.b    $1018ede
01018f34  abbb              dc.w     $abbb
01018f36  bba2              eor.l    d5, -(a2)
01018f38  52be              dc.w     $52be
01018f3a  a699              dc.w     $a699
01018f3c  9999              sub.l    d4, (a1)+
01018f3e  9959              sub.w    d4, (a1)+
01018f40  aaaa              dc.w     $aaaa
01018f42  a6b5              dc.w     $a6b5
01018f44  aaaa              dc.w     $aaaa
01018f46  eaaa              lsr.l    d5, d2
01018f48  aab2              dc.w     $aab2
01018f4a  52bd              dc.w     $52bd
01018f4c  aa66              dc.w     $aa66
01018f4e  6665              bne.b    $1018fb5
01018f50  5562              subq.w   #$2, -(a2)
01018f52  9a5e              sub.w    (a6)+, d5
01018f54  aad5              dc.w     $aad5
01018f56  66aa              bne.b    $1018f02
01018f58  aaaa              dc.w     $aaaa
01018f5a  aea2              dc.w     $aea2
01018f5c  52be              dc.w     $52be
01018f5e  9999              sub.l    d4, (a1)+
01018f60  9956              sub.w    d4, (a6)
01018f62  559b              subq.l   #$2, (a3)+
01018f64  aa7e              dc.w     $aa7e
01018f66  ab65              dc.w     $ab65
01018f68  999a              sub.l    d4, (a2)+
01018f6a  6aaa              bpl.b    $1018f16
01018f6c  aa92              dc.w     $aa92
01018f6e  52be              dc.w     $52be
01018f70  6666              bne.b    $1018fd8
01018f72  5595              subq.l   #$2, (a5)
01018f74  566beaaa          addq.w   #$3, -$1556(a3)
01018f78  ae99              dc.w     $ae99
01018f7a  5666              addq.w   #$3, -(a6)
01018f7c  aaaa              dc.w     $aaaa
01018f7e  aaa2              dc.w     $aaa2
01018f80  52bd              dc.w     $52bd
01018f82  9995              sub.l    d4, (a5)
01018f84  5555              subq.w   #$2, (a5)
01018f86  59aefeaa          subq.l   #$4, -$156(a6)
01018f8a  fa665599          fsueq.b  -(a6)
01018f8e  999a              sub.l    d4, (a2)+
01018f90  a6a2              dc.w     $a6a2
01018f92  52be              dc.w     $52be
01018f94  6559              bcs.b    $1018fef
01018f96  5555              subq.w   #$2, (a5)
01018f98  66bb              bne.b    $1018f55
01018f9a  efff              dc.w     $efff
01018f9c  fe999566          fbf.w    $1012504
01018fa0  6666              bne.b    $1019008
01018fa2  6aa2              bpl.b    $1018f46
01018fa4  52bd              dc.w     $52bd
01018fa6  5555              subq.w   #$2, (a5)
01018fa8  5565              subq.w   #$2, -(a5)
01018faa  9aaefffe          sub.l    -$2(a6), d5
01018fae  fba6              dc.w     $fba6
01018fb0  6555              bcs.b    $1019007
01018fb2  9999              sub.l    d4, (a1)+
01018fb4  99a2              sub.l    d4, -(a2)
01018fb6  52bd              dc.w     $52bd
01018fb8  5955              subq.w   #$4, (a5)
01018fba  5556              subq.w   #$2, (a6)
01018fbc  6affefffbe99      bpl.l    $f1014e57                   ; $f1014e57 = NextBus slot space
01018fc2  9955              sub.w    d4, (a5)
01018fc4  5566              subq.w   #$2, -(a6)
01018fc6  6562              bcs.b    $101902a
01018fc8  52be              dc.w     $52be
01018fca  9555              sub.w    d2, (a5)
01018fcc  5599              subq.l   #$2, (a1)+
01018fce  aac2              dc.w     $aac2
01018fd0  ffff              dc.w     $ffff
01018fd2  fbaa              dc.w     $fbaa
01018fd4  6655              bne.b    $101902b
01018fd6  5595              subq.l   #$2, (a5)
01018fd8  99e2              suba.l   -(a2), a4
01018fda  52be              dc.w     $52be
01018fdc  5555              subq.w   #$2, (a5)
01018fde  5666              addq.w   #$3, -(a6)
01018fe0  aaf0              dc.w     $aaf0
01018fe2  bffbfeea          cmpa.l   $1018fce(pc, a7.l), a7
01018fe6  9999              sub.l    d4, (a1)+
01018fe8  5559              subq.w   #$2, (a1)+
01018fea  55e2              scs.b    -(a2)
01018fec  52bf              dc.w     $52bf
01018fee  5555              subq.w   #$2, (a5)
01018ff0  999a              sub.l    d4, (a2)+
01018ff2  6abc              bpl.b    $1018fb0
01018ff4  2eff              dc.w     $2eff
01018ff6  bfba              dc.w     $bfba
01018ff8  a666              dc.w     $a666
01018ffa  5555              subq.w   #$2, (a5)
01018ffc  59f252bb          svs.b    -$45(a2, d5.w)
01019000  d565              add.w    d2, -(a5)
01019002  6666              bne.b    $101906a
01019004  aaef              dc.w     $aaef
01019006  0bff              dc.w     $0bff
01019008  fbee              dc.w     $fbee
0101900a  aa99              dc.w     $aa99
0101900c  9555              sub.w    d2, (a5)
0101900e  56e2              sne.b    -(a2)
01019010  52be              dc.w     $52be
01019012  e995              roxl.l   #$4, d5
01019014  999a              sub.l    d4, (a2)+
01019016  abbb              dc.w     $abbb
01019018  c1ff              dc.w     $c1ff
0101901a  bfabba66          eor.l    d7, -$459a(a3)
0101901e  6655              bne.b    $1019075
01019020  57b252bb          subq.l   #$3, -$45(a2, d5.w)
01019024  e656              roxr.w   #$3, d6
01019026  666a              bne.b    $1019092
01019028  aaef              dc.w     $aaef
0101902a  f07f              dc.w     $f07f
0101902c  fbee              dc.w     $fbee
0101902e  aaa9              dc.w     $aaa9
01019030  9995              sub.l    d4, (a5)
01019032  5fe2              sle.b    -(a2)
01019034  52be              dc.w     $52be
01019036  f959              frestore (a1)+
01019038  99aaabbf          sub.l    d4, -$5441(a2)
0101903c  fc1ffffb          fmovem   invalid, (a7)+
01019040  aa9a              dc.w     $aa9a
01019042  6665              bne.b    $10190a9
01019044  5fb252bb          subq.l   #$7, -$45(a2, d5.w)
01019048  be66              cmp.w    -(a6), d7
0101904a  66aa              bne.b    $1018ff6
0101904c  aefe              dc.w     $aefe
0101904e  fb33fbbeeaaa99996ee2  fsave    ([$eaaa9999], a7.l * 2, $6ee2)
01019058  52bd              dc.w     $52bd
0101905a  ee55              roxr.w   #$7, d5
0101905c  99abbbef          sub.l    d4, -$4411(a3)
01019060  ffc0              dc.w     $ffc0
01019062  bffbbaa9          cmpa.l   $101900d(pc, a3.l), a7
01019066  a666              dc.w     $a666
01019068  bbb252ba          eor.l    d5, -$46(a2, d5.w)
0101906c  6ba6              bmi.b    $1019014
0101906e  6aaa              bpl.b    $101901a
01019070  aefe              dc.w     $aefe
01019072  fff0              dc.w     $fff0
01019074  2fbe              dc.w     $2fbe
01019076  eeaa              lsr.l    d7, d2
01019078  aa99              dc.w     $aa99
0101907a  eaa2              asr.l    d5, d2
0101907c  52bd              dc.w     $52bd
0101907e  aafa              dc.w     $aafa
01019080  a6aa              dc.w     $a6aa
01019082  bbff              dc.w     $bbff
01019084  fffc              dc.w     $fffc
01019086  07ff              dc.w     $07ff
01019088  baea9a6f          cmpa.w   -$6591(a2), a5
0101908c  aab2              dc.w     $aab2
0101908e  52ba              dc.w     $52ba
01019090  6bbe              bmi.b    $1019050
01019092  aaaa              dc.w     $aaaa
01019094  efbf              rol.l    d7, d7
01019096  efff              dc.w     $efff
01019098  02fb              dc.w     $02fb
0101909a  eeaa              lsr.l    d7, d2
0101909c  aabf              dc.w     $aabf
0101909e  ffe2              dc.w     $ffe2
010190a0  52bd              dc.w     $52bd
010190a2  aeff              dc.w     $aeff
010190a4  aabb              dc.w     $aabb
010190a6  bbfbffffc02fbbab  cmpa.l   ([$c1314c53]), a5
010190ae  aaff              dc.w     $aaff
010190b0  ffe2              dc.w     $ffe2
010190b2  52ba              dc.w     $52ba
010190b4  abbf              dc.w     $abbf
010190b6  aaaa              dc.w     $aaaa
010190b8  efff              dc.w     $efff
010190ba  fffe              dc.w     $fffe
010190bc  f007eeea          fmovem   d6, d7
010190c0  aeff              dc.w     $aeff
010190c2  ffe2              dc.w     $ffe2
010190c4  52be              dc.w     $52be
010190c6  aeff              dc.w     $aeff
010190c8  eebb              ror.l    d7, d3
010190ca  beff              dc.w     $beff
010190cc  ffff              dc.w     $ffff
010190ce  fc00fbba          fmovem   invalid, d0
010190d2  fbfb              dc.w     $fbfb
010190d4  bbe2              cmpa.l   -(a2), a5
010190d6  52ba              dc.w     $52ba
010190d8  afff              dc.w     $afff
010190da  feaeefef          fbf.w    $10180cb
010190de  ffff              dc.w     $ffff
010190e0  ff00              dc.w     $ff00
010190e2  eeef              dc.w     $eeef
010190e4  ff90              dc.w     $ff90
010190e6  7ee2              moveq    #$e2, d7
010190e8  52be              dc.w     $52be
010190ea  bd9a              eor.l    d6, (a2)+
010190ec  ffff              dc.w     $ffff
010190ee  bfff              dc.w     $bfff
010190f0  fffe              dc.w     $fffe
010190f2  efc3              dc.w     $efc3
010190f4  87ff              dc.w     $87ff
010190f6  ea40              asr.w    #$5, d0
010190f8  0ee2              dc.w     $0ee2
010190fa  52ba              dc.w     $52ba
010190fc  e666              asr.w    d3, d6
010190fe  6ffe              ble.b    $10190fe
01019100  bbbf              dc.w     $bbbf
01019102  fefffefe11be      fbf.l    $ffffa2c2                   ; $ffffa2c2 = NextBus slot space
01019108  be06              cmp.b    d6, d7
0101910a  4ee2              dc.w     $4ee2
0101910c  52bb              dc.w     $52bb
0101910e  9999              sub.l    d4, (a1)+
01019110  9bff              dc.w     $9bff
01019112  ebff              dc.w     $ebff
01019114  ffff              dc.w     $ffff
01019116  effc              dc.w     $effc
01019118  481f              nbcd.b   (a7)+
0101911a  cd19              and.b    d6, (a1)+
0101911c  8fa2              or.l     d7, -(a2)
0101911e  52b76666          addq.l   #$1, $66(a7, d6.w)
01019122  67fffffffffb      beq.l    $101911f
01019128  ffef              dc.w     $ffef
0101912a  0e02              dc.w     $0e02
0101912c  02064fe2          andi.b   #$e2, d6
01019130  52bd              dc.w     $52bd
01019132  9902              subx.b   d2, d4
01019134  9aff              dc.w     $9aff
01019136  ffee              dc.w     $ffee
01019138  ffff              dc.w     $ffff
0101913a  befe              dc.w     $befe
0101913c  c008              dc.w     $c008
0101913e  1080              move.b   d0, (a0)
01019140  3fa252be          move.w   -(a2), -$42(a7, d5.w)
01019144  6415              bcc.b    $101915b
01019146  e6ff              dc.w     $e6ff
01019148  ffff              dc.w     $ffff
0101914a  fbbf              dc.w     $fbbf
0101914c  ffff              dc.w     $ffff
0101914e  f020543f          dc.w     $9
01019152  fee255000000      fbf.l    $56019154
01019158  00000048          ori.b    #$48, d0
0101915c  00000041          ori.b    #$41, d0
01019160  56a0              addq.l   #$3, -(a0)
01019162  aaea              dc.w     $aaea
01019164  abff              dc.w     $abff
01019166  ffff              dc.w     $ffff
01019168  fbbb              dc.w     $fbbb
0101916a  bffe              dc.w     $bffe
0101916c  fefefeeefeea      fbf.l    $fff09058                   ; $fff09058 = NextBus slot space
01019172  558a              subq.l   #$2, a2
01019174  afff              dc.w     $afff
01019176  ffff              dc.w     $ffff
01019178  ffff              dc.w     $ffff
0101917a  ffff              dc.w     $ffff
0101917c  fbfe              dc.w     $fbfe
0101917e  effb              dc.w     $effb
01019180  bbbb              dc.w     $bbbb
01019182  bba2              eor.l    d5, -(a2)
01019184  562afeee          addq.b   #$3, -$112(a2)
01019188  aeff              dc.w     $aeff
0101918a  ffff              dc.w     $ffff
0101918c  ffff              dc.w     $ffff
0101918e  bfbb              dc.w     $bfbb
01019190  aafe              dc.w     $aafe
01019192  eeee              dc.w     $eeee
01019194  eaa2              asr.l    d5, d2
01019196  562bbbba          addq.b   #$3, -$4446(a3)
0101919a  abff              dc.w     $abff
0101919c  ffff              dc.w     $ffff
0101919e  ffef              dc.w     $ffef
010191a0  ffee              dc.w     $ffee
010191a2  eaaf              lsr.l    d5, d7
010191a4  fbaa              dc.w     $fbaa
010191a6  aa92              dc.w     $aa92
010191a8  54aeeeaa          addq.l   #$2, -$1156(a6)
010191ac  beff              dc.w     $beff
010191ae  ffff              dc.w     $ffff
010191b0  fffe              dc.w     $fffe
010191b2  fbfb              dc.w     $fbfb
010191b4  aea6              dc.w     $aea6
010191b6  feaaaa62          fbf.w    $1013c1a
010191ba  54afb999          addq.l   #$2, -$4667(a7)
010191be  fffb              dc.w     $fffb
010191c0  ffff              dc.w     $ffff
010191c2  ffff              dc.w     $ffff
010191c4  ffee              dc.w     $ffee
010191c6  eaaa              lsr.l    d5, d2
010191c8  7faa              dc.w     $7faa
010191ca  a992              dc.w     $a992
010191cc  54ba              dc.w     $54ba
010191ce  e667              asr.w    d3, d7
010191d0  bfff              dc.w     $bfff
010191d2  ffff              dc.w     $ffff
010191d4  ffff              dc.w     $ffff
010191d6  ffbb              dc.w     $ffbb
010191d8  aaa9              dc.w     $aaa9
010191da  99eaaa62          suba.l   -$559e(a2), a4
010191de  52bf              dc.w     $52bf
010191e0  999f              sub.l    d4, (a7)+
010191e2  eeff              dc.w     $eeff
010191e4  ffff              dc.w     $ffff
010191e6  fffe              dc.w     $fffe
010191e8  fbee              dc.w     $fbee
010191ea  eaa6              asr.l    d5, d6
010191ec  667a              bne.b    $1019268
010191ee  a992              dc.w     $a992
010191f0  52ba              dc.w     $52ba
010191f2  667a              bne.b    $101926e
010191f4  fffe              dc.w     $fffe
010191f6  ffff              dc.w     $ffff
010191f8  ffff              dc.w     $ffff
010191fa  ffba              dc.w     $ffba
010191fc  aa99              dc.w     $aa99
010191fe  996eaa62          sub.w    d4, -$559e(a6)
01019202  52bf              dc.w     $52bf
01019204  99fbbbefffff      suba.l   ([$1029205]), a4            ; $01029205 = ROM
0101920a  fffb              dc.w     $fffb
0101920c  feeeea66665f      fbf.l    $eb67f86d
01019212  a992              dc.w     $a992
01019214  52ba              dc.w     $52ba
01019216  67ae              beq.b    $10191c6
01019218  eeff              dc.w     $eeff
0101921a  ffff              dc.w     $ffff
0101921c  ffff              dc.w     $ffff
0101921e  efba              rol.l    d7, d2
01019220  aa99              dc.w     $aa99
01019222  9566              sub.w    d2, -(a6)
01019224  ea62              asr.w    d5, d2
01019226  52bd              dc.w     $52bd
01019228  9fbb              dc.w     $9fbb
0101922a  bbefbfff          cmpa.l   -$4001(a7), a5
0101922e  ffff              dc.w     $ffff
01019230  feeeaa666555      fbf.l    $ab67f787
01019236  b992              eor.l    d4, (a2)
01019238  52ba              dc.w     $52ba
0101923a  7aae              moveq    #$ae, d5
0101923c  eeff              dc.w     $eeff
0101923e  ffff              dc.w     $ffff
01019240  fffe              dc.w     $fffe
01019242  efba              rol.l    d7, d2
01019244  a999              dc.w     $a999
01019246  9556              sub.w    d2, (a6)
01019248  ae62              dc.w     $ae62
0101924a  52bd              dc.w     $52bd
0101924c  baebbbbe          cmpa.w   -$4442(a3), a5
01019250  ffff              dc.w     $ffff
01019252  ffff              dc.w     $ffff
01019254  feeea6665595      fbf.l    $a767e7eb
0101925a  7d92              dc.w     $7d92
0101925c  52ba              dc.w     $52ba
0101925e  faaaaeef          fbf.w    $101414f
01019262  fbff              dc.w     $fbff
01019264  ffff              dc.w     $ffff
01019266  bbaa9995          eor.l    d5, -$666b(a2)
0101926a  5559              subq.w   #$2, (a1)+
0101926c  9f62              sub.w    d7, -(a2)
0101926e  52bd              dc.w     $52bd
01019270  eaaa              lsr.l    d5, d2
01019272  ebbb              rol.l    d5, d3
01019274  bfefffff          cmpa.l   -$1(a7), a7
01019278  feea66595666      fbf.l    $675ae8e0
0101927e  6b92              bmi.b    $1019212
01019280  52bb              dc.w     $52bb
01019282  aaaa              dc.w     $aaaa
01019284  aaee              dc.w     $aaee
01019286  ffff              dc.w     $ffff
01019288  fffe              dc.w     $fffe
0101928a  fbba              dc.w     $fbba
0101928c  9955              sub.w    d4, (a5)
0101928e  5999              subq.l   #$4, (a1)+
01019290  aae2              dc.w     $aae2
01019292  52bf              dc.w     $52bf
01019294  a66a              dc.w     $a66a
01019296  aabb              dc.w     $aabb
01019298  bbff              dc.w     $bbff
0101929a  ffff              dc.w     $ffff
0101929c  eeaa              lsr.l    d7, d2
0101929e  6555              bcs.b    $10192f5
010192a0  6666              bne.b    $1019308
010192a2  aad2              dc.w     $aad2
010192a4  52bf              dc.w     $52bf
010192a6  999a              sub.l    d4, (a2)+
010192a8  aaae              dc.w     $aaae
010192aa  efef              dc.w     $efef
010192ac  bfff              dc.w     $bfff
010192ae  fba9              dc.w     $fba9
010192b0  9555              sub.w    d2, (a5)
010192b2  999a              sub.l    d4, (a2)+
010192b4  aae2              dc.w     $aae2
010192b6  52be              dc.w     $52be
010192b8  6666              bne.b    $1019320
010192ba  aaab              dc.w     $aaab
010192bc  bbff              dc.w     $bbff
010192be  fffe              dc.w     $fffe
010192c0  eea6              asr.l    d7, d6
010192c2  5566              subq.w   #$2, -(a6)
010192c4  66aa              bne.b    $1019270
010192c6  aab2              dc.w     $aab2
010192c8  52bd              dc.w     $52bd
010192ca  9999              sub.l    d4, (a1)+
010192cc  9aaaaeff          sub.l    -$5101(a2), d5
010192d0  ffff              dc.w     $ffff
010192d2  fa995599          fbf.w    $101e86d
010192d6  aaaa              dc.w     $aaaa
010192d8  aaa2              dc.w     $aaa2
010192da  52bd              dc.w     $52bd
010192dc  5566              subq.w   #$2, -(a6)
010192de  66aa              bne.b    $101928a
010192e0  abee              dc.w     $abee
010192e2  ffff              dc.w     $ffff
010192e4  ea65              asr.w    d5, d5
010192e6  6666              bne.b    $101934e
010192e8  aaaa              dc.w     $aaaa
010192ea  abb2              dc.w     $abb2
010192ec  52bd              dc.w     $52bd
010192ee  5555              subq.w   #$2, (a5)
010192f0  999a              sub.l    d4, (a2)+
010192f2  aaff              dc.w     $aaff
010192f4  e000              asr.b    #$8, d0
010192f6  6995              bvs.b    $101928d
010192f8  99aaaaae          sub.l    d4, -$5552(a2)
010192fc  eee2              dc.w     $eee2
010192fe  52bd              dc.w     $52bd
01019300  5555              subq.w   #$2, (a5)
01019302  5666              addq.w   #$3, -(a6)
01019304  aabf              dc.w     $aabf
01019306  c155              and.w    d0, (a5)
01019308  0956              bchg.b   d4, (a6)
0101930a  66aa              bne.b    $10192b6
0101930c  aabb              dc.w     $aabb
0101930e  bbb252bd          eor.l    d5, -$43(a2, d5.w)
01019312  5555              subq.w   #$2, (a5)
01019314  5559              subq.w   #$2, (a1)+
01019316  9aac1555          sub.l    $1555(a4), d5
0101931a  5059              addq.w   #$8, (a1)+
0101931c  aaaa              dc.w     $aaaa
0101931e  aeee              dc.w     $aeee
01019320  eee2              dc.w     $eee2
01019322  52bd              dc.w     $52bd
01019324  9955              sub.w    d4, (a5)
01019326  5556              subq.w   #$2, (a6)
01019328  6661              bne.b    $101938b
0101932a  550d              dc.w     $550d
0101932c  552aaabb          subq.b   #$2, -$5545(a2)
01019330  bbbb              dc.w     $bbbb
01019332  bbf252be          cmpa.l   -$42(a2, d5.w), a5
01019336  6655              bne.b    $101938d
01019338  5555              subq.w   #$2, (a5)
0101933a  99b1553d55eaaeee  sub.l    d4, ([$55eaaeee, a1], d5.w * 4)
01019342  eeff              dc.w     $eeff
01019344  ffb2              dc.w     $ffb2
01019346  52bd              dc.w     $52bd
01019348  9999              sub.l    d4, (a1)+
0101934a  5555              subq.w   #$2, (a5)
0101934c  5605              addq.b   #$3, d5
0101934e  5555              subq.w   #$2, (a5)
01019350  557b              dc.w     $557b
01019352  bbbf              dc.w     $bbbf
01019354  ffee              dc.w     $ffee
01019356  fbf2              dc.w     $fbf2
01019358  52be              dc.w     $52be
0101935a  6666              bne.b    $10193c2
0101935c  6555              bcs.b    $10193b3
0101935e  5505              subq.b   #$2, d5
01019360  5555              subq.w   #$2, (a5)
01019362  667a              bne.b    $10193de
01019364  efff              dc.w     $efff
01019366  efff              dc.w     $efff
01019368  fff2              dc.w     $fff2
0101936a  52bd              dc.w     $52bd
0101936c  9999              sub.l    d4, (a1)+
0101936e  9999              sub.l    d4, (a1)+
01019370  5515              subq.b   #$2, (a5)
01019372  5506              subq.b   #$2, d6
01019374  559f              subq.l   #$2, (a7)+
01019376  ffbe              dc.w     $ffbe
01019378  feefbff252be      fbf.l    $c0f3e638
0101937e  aaaa              dc.w     $aaaa
01019380  a666              dc.w     $a666
01019382  6616              bne.b    $101939a
01019384  541f              addq.b   #$2, (a7)+
01019386  666e              bne.b    $10193f6
01019388  efff              dc.w     $efff
0101938a  ffff              dc.w     $ffff
0101938c  ffb2              dc.w     $ffb2
0101938e  52be              dc.w     $52be
01019390  aaaa              dc.w     $aaaa
01019392  aaa9              dc.w     $aaa9
01019394  9a15              sub.b    (a5), d5
01019396  580f              dc.w     $580f
01019398  999f              sub.l    d4, (a7)+
0101939a  feefeffffff2      fbf.l    $f101938e                   ; $f101938e = NextBus slot space
010193a0  52be              dc.w     $52be
010193a2  aaaa              dc.w     $aaaa
010193a4  aaaa              dc.w     $aaaa
010193a6  aa26              dc.w     $aa26
010193a8  663f              bne.b    $10193e9
010193aa  666f              bne.b    $101941b
010193ac  ffff              dc.w     $ffff
010193ae  ffff              dc.w     $ffff
010193b0  fff2              dc.w     $fff2
010193b2  52be              dc.w     $52be
010193b4  eaea              dc.w     $eaea
010193b6  aaaa              dc.w     $aaaa
010193b8  aa19              dc.w     $aa19
010193ba  99bd              dc.w     $99bd
010193bc  99afffff          sub.l    d4, -$1(a7)
010193c0  ffff              dc.w     $ffff
010193c2  fff2              dc.w     $fff2
010193c4  52be              dc.w     $52be
010193c6  aaab              dc.w     $aaab
010193c8  abbb              dc.w     $abbb
010193ca  bb86              eor.l    d5, d6
010193cc  6666              bne.b    $1019434
010193ce  6abf              bpl.b    $101938f
010193d0  ffff              dc.w     $ffff
010193d2  ffff              dc.w     $ffff
010193d4  fff2              dc.w     $fff2
010193d6  52be              dc.w     $52be
010193d8  aeae              dc.w     $aeae
010193da  eeee              dc.w     $eeee
010193dc  efc9              dc.w     $efc9
010193de  aaaa              dc.w     $aaaa
010193e0  a6bf              dc.w     $a6bf
010193e2  ffff              dc.w     $ffff
010193e4  ffff              dc.w     $ffff
010193e6  fff2              dc.w     $fff2
010193e8  52bf              dc.w     $52bf
010193ea  bbbb              dc.w     $bbbb
010193ec  bbbb              dc.w     $bbbb
010193ee  fef29a5eaaff      fbf.l    $9b603eef
010193f4  ffff              dc.w     $ffff
010193f6  ffff              dc.w     $ffff
010193f8  fff2              dc.w     $fff2
010193fa  52be              dc.w     $52be
010193fc  eeee              dc.w     $eeee
010193fe  eeff              dc.w     $eeff
01019400  bffcaa7eaafb      cmpa.l   #$aa7eaafb, a7
01019406  ffff              dc.w     $ffff
01019408  ffff              dc.w     $ffff
0101940a  fff2              dc.w     $fff2
0101940c  52bf              dc.w     $52bf
0101940e  abbf              dc.w     $abbf
01019410  bfeffbff          cmpa.l   -$401(a7), a7
01019414  eaaa              lsr.l    d5, d2
01019416  afbf              dc.w     $afbf
01019418  bbff              dc.w     $bbff
0101941a  ffff              dc.w     $ffff
0101941c  fff2              dc.w     $fff2
0101941e  52bf              dc.w     $52bf
01019420  fefbfbfeffff      fbf.l    $fd009421                   ; $fd009421 = NextBus slot space
01019426  beaafabb          cmp.l    -$545(a2), d7
0101942a  ffbf              dc.w     $ffbf
0101942c  ffff              dc.w     $ffff
0101942e  fff2              dc.w     $fff2
01019430  52bf              dc.w     $52bf
01019432  bfbf              dc.w     $bfbf
01019434  bfbf              dc.w     $bfbf
01019436  ffff              dc.w     $ffff
01019438  ffff              dc.w     $ffff
0101943a  5aeefbff          spl.b    -$401(a6)
0101943e  ffff              dc.w     $ffff
01019440  fff2              dc.w     $fff2
01019442  52bf              dc.w     $52bf
01019444  efff              dc.w     $efff
01019446  fbff              dc.w     $fbff
01019448  ffff              dc.w     $ffff
0101944a  ffa6              dc.w     $ffa6
0101944c  56bb              dc.w     $56bb
0101944e  bfbb              dc.w     $bfbb
01019450  ffff              dc.w     $ffff
01019452  fff2              dc.w     $fff2
01019454  52bf              dc.w     $52bf
01019456  fefbffffffab      fbf.l    $1019403
0101945c  fea659ae          fbf.w    $101ee0c
01019460  efff              dc.w     $efff
01019462  ffff              dc.w     $ffff
01019464  fff2              dc.w     $fff2
01019466  52bf              dc.w     $52bf
01019468  bfff              dc.w     $bfff
0101946a  ffff              dc.w     $ffff
0101946c  ff82              dc.w     $ff82
0101946e  baa9566b          cmp.l    $566b(a1), d5
01019472  bbbe              dc.w     $bbbe
01019474  efbf              rol.l    d7, d7
01019476  fff2              dc.w     $fff2
01019478  52bf              dc.w     $52bf
0101947a  ffef              dc.w     $ffef
0101947c  beff              dc.w     $beff
0101947e  ffb0              dc.w     $ffb0
01019480  baa6              cmp.l    -(a6), d5
01019482  55aaeeef          subq.l   #$2, -$1111(a2)
01019486  ffff              dc.w     $ffff
01019488  ffe2              dc.w     $ffe2
0101948a  52bf              dc.w     $52bf
0101948c  fbff              dc.w     $fbff
0101948e  ffff              dc.w     $ffff
01019490  ffec              dc.w     $ffec
01019492  2a99              move.l   (a1)+, (a5)
01019494  566abbbb          addq.w   #$3, -$4445(a2)
01019498  effe              dc.w     $effe
0101949a  ffb2              dc.w     $ffb2
0101949c  52bb              dc.w     $52bb
0101949e  ffff              dc.w     $ffff
010194a0  ffff              dc.w     $ffff
010194a2  fffb              dc.w     $fffb
010194a4  0bb6559aaaee      bclr.b   d5, ([, d5.w * 4], $aaee)
010194aa  fbbf              dc.w     $fbbf
010194ac  efe2              dc.w     $efe2
010194ae  52be              dc.w     $52be
010194b0  ffbe              dc.w     $ffbe
010194b2  ffff              dc.w     $ffff
010194b4  fffe              dc.w     $fffe
010194b6  c1ea566a          muls.w   $566a(a2), d0
010194ba  aabb              dc.w     $aabb
010194bc  bfff              dc.w     $bfff
010194be  ffb2              dc.w     $ffb2
010194c0  52bb              dc.w     $52bb
010194c2  ffff              dc.w     $ffff
010194c4  ffff              dc.w     $ffff
010194c6  ffbf              dc.w     $ffbf
010194c8  b075559aaaee      cmp.w    ([, d5.w * 4], $aaee), d0
010194ce  eefb              dc.w     $eefb
010194d0  ffe2              dc.w     $ffe2
010194d2  52be              dc.w     $52be
010194d4  ffff              dc.w     $ffff
010194d6  ffff              dc.w     $ffff
010194d8  fbfb              dc.w     $fbfb
010194da  ec1e              ror.b    #$6, d6
010194dc  5566              subq.w   #$2, -(a6)
010194de  aabb              dc.w     $aabb
010194e0  bbbf              dc.w     $bbbf
010194e2  bfb252bb          eor.l    d7, -$45(a2, d5.w)
010194e6  bbff              dc.w     $bbff
010194e8  ffff              dc.w     $ffff
010194ea  ffbf              dc.w     $ffbf
010194ec  ff33d559          fsave    ([a3])
010194f0  aaae              dc.w     $aaae
010194f2  eeef              dc.w     $eeef
010194f4  fee252bdefff      fbf.l    $53bf84f5
010194fa  ffff              dc.w     $ffff
010194fc  fffe              dc.w     $fffe
010194fe  fec0b5666aab      fbf.l    $b667ffab
01019504  bbbb              dc.w     $bbbb
01019506  fbb2              dc.w     $fbb2
01019508  52ba              dc.w     $52ba
0101950a  6bbf              bmi.b    $10194cb
0101950c  ffff              dc.w     $ffff
0101950e  eeef              dc.w     $eeef
01019510  bff02d59          cmpa.l   ([a0]), a7
01019514  9aaaeeef          sub.l    -$1111(a2), d5
01019518  eaa2              asr.l    d5, d2
0101951a  52bd              dc.w     $52bd
0101951c  aaef              dc.w     $aaef
0101951e  ffff              dc.w     $ffff
01019520  fffe              dc.w     $fffe
01019522  effc              dc.w     $effc
01019524  0756              bchg.b   d3, (a6)
01019526  66ae              bne.b    $10194d6
01019528  bbefaab2          cmpa.l   -$554e(a7), a5
0101952c  52ba              dc.w     $52ba
0101952e  6bbb              bmi.b    $10194eb
01019530  fffe              dc.w     $fffe
01019532  fffb              dc.w     $fffb
01019534  baef01e5          cmpa.w   $1e5(a7), a5
01019538  9aaaaeff          sub.l    -$5101(a2), d5
0101953c  ffe2              dc.w     $ffe2
0101953e  52bd              dc.w     $52bd
01019540  aefe              dc.w     $aefe
01019542  ffff              dc.w     $ffff
01019544  fbbe              dc.w     $fbbe
01019546  eabf              ror.l    d5, d7
01019548  c02f66aa          and.b    $66aa(a7), d0
0101954c  ebff              dc.w     $ebff
0101954e  ffe2              dc.w     $ffe2
01019550  52ba              dc.w     $52ba
01019552  abbf              dc.w     $abbf
01019554  afef              dc.w     $afef
01019556  fffb              dc.w     $fffb
01019558  ba9b              cmp.l    (a3)+, d5
0101955a  f007d9aa          fmovem   d7, invalid
0101955e  beff              dc.w     $beff
01019560  ffe2              dc.w     $ffe2
01019562  52be              dc.w     $52be
01019564  aeff              dc.w     $aeff
01019566  ebff              dc.w     $ebff
01019568  beeeeaa6          cmpa.w   -$155a(a6), a7
0101956c  fc00f66b          fmovem   fp1-fp2/fp4/fp6-fp7, d0
01019570  fffb              dc.w     $fffb
01019572  bbe2              cmpa.l   -(a2), a5
01019574  52ba              dc.w     $52ba
01019576  afff              dc.w     $afff
01019578  febffffb          fbf.w    $1019575
0101957c  ae99              dc.w     $ae99
0101957e  af00              dc.w     $af00
01019580  efbf              rol.l    d7, d7
01019582  ff90              dc.w     $ff90
01019584  7ee2              moveq    #$e2, d7
01019586  52be              dc.w     $52be
01019588  bd9a              eor.l    d6, (a2)+
0101958a  ffeb              dc.w     $ffeb
0101958c  fbee              dc.w     $fbee
0101958e  eaa6              asr.l    d5, d6
01019590  afc3              dc.w     $afc3
01019592  87ff              dc.w     $87ff
01019594  ea40              asr.w    #$5, d0
01019596  0ee2              dc.w     $0ee2
01019598  52ba              dc.w     $52ba
0101959a  e666              asr.w    d3, d6
0101959c  6ffe              ble.b    $101959c
0101959e  afbb              dc.w     $afbb
010195a0  ba99              cmp.l    (a1)+, d5
010195a2  6bfe              bmi.b    $10195a2
010195a4  11be              dc.w     $11be
010195a6  be06              cmp.b    d6, d7
010195a8  4ee2              dc.w     $4ee2
010195aa  52bb              dc.w     $52bb
010195ac  9999              sub.l    d4, (a1)+
010195ae  9bff              dc.w     $9bff
010195b0  ebee              dc.w     $ebee
010195b2  eaa6              asr.l    d5, d6
010195b4  5afc              trappl   
010195b6  481f              nbcd.b   (a7)+
010195b8  cd19              and.b    d6, (a1)+
010195ba  8fa2              or.l     d7, -(a2)
010195bc  52b76666          addq.l   #$1, $66(a7, d6.w)
010195c0  67ffffbeaaa9      beq.l    $c0406b                     ; $00c0406b = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
010195c6  56bf              dc.w     $56bf
010195c8  0e02              dc.w     $0e02
010195ca  02064fe2          andi.b   #$e2, d6
010195ce  52bd              dc.w     $52bd
010195d0  9902              subx.b   d2, d4
010195d2  9aff              dc.w     $9aff
010195d4  fffe              dc.w     $fffe
010195d6  faa6557f          fbf.w    $101eb57
010195da  c008              dc.w     $c008
010195dc  1080              move.b   d0, (a0)
010195de  3fa252be          move.w   -(a2), -$42(a7, d5.w)
010195e2  6415              bcc.b    $10195f9
010195e4  e6ff              dc.w     $e6ff
010195e6  ffff              dc.w     $ffff
010195e8  feeeefeff020      fbf.l    $f0f1860a                   ; $f0f1860a = NextBus slot space
010195ee  543f              dc.w     $543f
010195f0  fee200000444      fbf.l    $1019a36
010195f6  0b50              bchg.b   d5, (a0)
010195f8  0e10              dc.w     $0e10
010195fa  0c0a              dc.w     $0c0a
010195fc  0d00              btst.l   d6, d0
010195fe  0e11              dc.w     $0e11
01019600  0a0003c1          eori.b   #$c1, d0
01019604  05ea0f00          bset.b   d2, $f00(a2)
01019608  ffff              dc.w     $ffff
0101960a  ffff              dc.w     $ffff
0101960c  ffff              dc.w     $ffff
0101960e  ffff              dc.w     $ffff
01019610  ffff              dc.w     $ffff
01019612  ffff              dc.w     $ffff
01019614  000003a2          ori.b    #$a2, d0
01019618  0710              btst.l   d3, (a0)
0101961a  0a1e0ca3          eori.b   #$a3, (a6)+
0101961e  0e7e              dc.w     $0e7e
01019620  0f98              bclr.b   d7, (a0)+
01019622  0fe2              bset.b   d7, -(a2)
01019624  0f5a              bchg.b   d7, (a2)+
01019626  0e08              dc.w     $0e08
01019628  0bfd              dc.w     $0bfd
0101962a  0956              bchg.b   d4, (a6)
0101962c  063602c8ff39fbb7f871  addi.b   #$c8, ([$fbb7f871, a6, a7.l * 8]) ; $fbb7f871 = NextBus slot space
01019636  f593              dc.w     $f593
01019638  f341              frestore ea(0,1)
0101963a  f19a              dc.w     $f19a
0101963c  f0b4f098          fbf.w    $10186d6
01019640  f149              dc.w     $f149
01019642  f2bbf4db          fbf.w    $1018b1f
01019646  f78d              dc.w     $f78d
01019648  faabfe0d          fbf.w    $1019457
0101964c  0184              bclr.b   d0, d4
0101964e  04e4              dc.w     $04e4
01019650  0801              dc.w     $0801
01019652  0ab00ccf0e430ef9  eori.l   #$ccf0e43, -$7(a0, d0.l)    ; $0ccf0e43 = VRAM (Turbo; color 2 MB at $0C000000)
0101965a  0ee8              dc.w     $0ee8
0101965c  0e12              dc.w     $0e12
0101965e  0c820a4f0796      cmpi.l   #$a4f0796, d2               ; $0a4f0796 = RAM bank 3
01019664  047c              dc.w     $047c
01019666  0129fdcb          btst.l   d0, -$235(a1)
0101966a  fa8df79b          fbf.w    $1018e07
0101966e  f51a              pflusha  
01019670  f32cf1ea          fsave    -$e16(a4)
01019674  f163              dc.w     $f163
01019676  f19e              dc.w     $f19e
01019678  f297f440          fbf.w    $1018aba
0101967c  f683f941          fbf.w    $1018fbf
01019680  fc55ff97          fsor.b   (a5)
01019684  02da              dc.w     $02da
01019686  05f508be          bset.b   d2, -$42(a5, d0.l)
0101968a  0b10              btst.l   d5, (a0)
0101968c  0cce              dc.w     $0cce
0101968e  0de1              bset.b   d6, -(a1)
01019690  0e3b              dc.w     $0e3b
01019692  0dd9              bset.b   d6, (a1)+
01019694  0cc0              dc.w     $0cc0
01019696  0aff              dc.w     $0aff
01019698  08af              dc.w     $08af
0101969a  05ee02e2          bset.b   d2, $2e2(a6)
0101969e  ffb4              dc.w     $ffb4
010196a0  fc8cf995          fbf.w    $1019037
010196a4  f6f5f4d1f342      fbf.l    $f5d389e8                   ; $f5d389e8 = NextBus slot space
010196aa  f25df22d          ftrapor.b (a5)+
010196ae  f2b5f3eb          fbf.w    $1018a9b
010196b2  f5c1              dc.w     $f5c1
010196b4  f81bfadc          fmovem   invalid, (a3)+
010196b8  fdde              dc.w     $fdde
010196ba  00f8              dc.w     $00f8
010196bc  040306d6          subi.b   #$d6, d3
010196c0  094c0b44          movep.l  $b44(a4), d4
010196c4  0ca50d5d0d65      cmpi.l   #$d5d0d65, -(a5)            ; $0d5d0d65 = VRAM MWF mirrors (non-Turbo mono only)
010196ca  0cbb0b690982071f0460016b  cmpi.l   #$b690982, ([$10196ccpc], d0.w * 8, $460016b) ; $0b690982 = RAM bank 3; $0460016b = RAM bank 0 (Turbo: 32 MB stride)
010196d6  fe66fb79          ftrapoge.b -(a6)
010196da  f8cbf67ff4b2      fbf.l    $f7818b8e                   ; $f7818b8e = NextBus slot space
010196e0  f37e              frestore ea(7,6)
010196e2  f2eff30ef3d9      fbf.l    $f4108abd                   ; $f4108abd = NextBus slot space
010196e8  f543              dc.w     $f543
010196ea  f739f9a2fc5c      fsave    $f9a2fc5c.l                 ; $f9a2fc5c = NextBus slot space
010196f0  ff44              dc.w     $ff44
010196f2  023105000789      andi.b   #$0, ([, d0.w * 8])
010196f8  09ad0b4e          bclr.b   d4, $b4e(a5)
010196fc  0c580cbe          cmpi.w   #$cbe, (a0)+
01019700  0c7a0b930a13      cmpi.w   #$b93, $101a115(pc)
01019706  080f              dc.w     $080f
01019708  05a3              bclr.b   d2, -(a3)
0101970a  02ef              dc.w     $02ef
0101970c  0017fd41          ori.b    #$41, (a7)
01019710  fa92f82d          fbf.w    $1018f3f
01019714  f632f4bbf3dbf39cf401  fmovem   fp0/fp2-fp4/fp6-fp7, ([], $f39cf401) ; $f39cf401 = NextBus slot space
0101971e  f504              pflushn  (a4)
01019720  f697f8a5          fbf.w    $1018fc7
01019724  fb13              fsave    (a3)
01019726  fdbf              dc.w     $fdbf
01019728  0085034305d2      ori.l    #$34305d2, d5
0101972e  0812              dc.w     $0812
01019730  09e5              bset.b   d4, -(a5)
01019732  0b330bec0c06      btst.l   d5, $c06(invalid.w)
01019738  0b82              bclr.b   d5, d2
0101973a  0a6508c1          eori.w   #$8c1, -(a5)
0101973e  06aa043d019bfee7  addi.l   #$43d019b, -$119(a2)        ; $043d019b = RAM bank 0 (Turbo: 32 MB stride)
01019746  fc44f9d4          fsolt.b  d4
0101974a  f7b9              dc.w     $f7b9
0101974c  f60df4e7f454      move16   $f4e7f454.l, (a5)+          ; $f4e7f454 = NextBus slot space
01019752  f45d              cinva    #$1
01019754  f4ff              cpusha   #$3
01019756  f632f7e6fa02      fmovem   fp0-fp2/fp5-fp6, $2(a2, a7.l)
0101975c  fc6cff0301a4      fsoge.b  $1a4(a4)
01019762  042c067b0872      subi.b   #$7b, $872(a4)
01019768  09f80af8          bset.b   d4, $af8.w
0101976c  0b66              bchg.b   d5, -(a6)
0101976e  0b3c0a7f0937      btst.l   d5, #$a7f0937               ; $0a7f0937 = RAM bank 3
01019774  07770556          bchg.b   d3, ([a7])
01019778  02f0              dc.w     $02f0
0101977a  0066fddb          ori.w    #$fddb, -(a6)
0101977e  fb6df93e          frestore -$6c2(a5)
01019782  f76bf60c          frestore -$9f4(a3)
01019786  f531f4e6          fsave    -$1a(a1, a7.w)
0101978a  f52ef605          fsave    -$9fb(a6)
0101978e  f75f              frestore (a7)+
01019790  f92afb4d          fsave    -$4b3(a2)
01019794  fdad              dc.w     $fdad
01019796  0027029e          ori.b    #$9e, -(a7)
0101979a  04f0              dc.w     $04f0
0101979c  06fe              dc.w     $06fe
0101979e  08ae              dc.w     $08ae
010197a0  09e90aa0          bset.b   d4, $aa0(a1)
010197a4  0ac9              dc.w     $0ac9
010197a6  0a640976          eori.w   #$976, -(a4)
010197aa  080c              dc.w     $080c
010197ac  0638041501bd      addi.b   #$15, $1bd.w
010197b2  ff52              frestore (a2)
010197b4  fcf1fabcf8ce      fbf.l    $fbbe9084                   ; $fbbe9084 = NextBus slot space
010197ba  f741              dc.w     $f741
010197bc  f62af595f58b      fmovem   fp0/fp3/fp5/fp7, -$a75(a2)
010197c2  f60cf70ff888      move16   $f70ff888.l, (a4)+          ; $f70ff888 = NextBus slot space
010197c8  fa62fc84          fsolt.b  -(a2)
010197cc  fed2012d0376      fbf.l    $22e9b44
010197d2  0590              bclr.b   d2, (a0)
010197d4  075d              bchg.b   d3, (a5)+
010197d6  08c8              dc.w     $08c8
010197d8  09bd              dc.w     $09bd
010197da  0a300a1c0982086b  eori.b   #$1c, ([, d0.l], $86b)
010197e2  06e6              dc.w     $06e6
010197e4  050802e9          movep.w  $2e9(a0), d2
010197e8  00a5fe5cfc2b      ori.l    #$fe5cfc2b, -(a5)           ; $fe5cfc2b = NextBus slot space
010197ee  fa2ef880f737      fmovem   invalid, -$8c9(a6)
010197f4  f664f610          fsf.b    -(a4)
010197f8  f640f6f1          fssub.b  d0
010197fc  f819f9a9          fmovem   invalid, (a1)+
01019800  fb8a              dc.w     $fb8a
01019802  fda5              dc.w     $fda5
01019804  ffdd              dc.w     $ffdd
01019806  0213042c          andi.b   #$2c, (a3)
0101980a  060d              dc.w     $060d
0101980c  079b              bclr.b   d3, (a3)+
0101980e  08c3              dc.w     $08c3
01019810  097609ab0960089a0762  bchg.b   d4, ([$960, d0.l], $89a0762) ; $089a0762 = RAM bank 2
0101981a  05cb03e8          movep.l  d2, $3e8(a3)
0101981e  01d3              bset.b   d0, (a3)
01019820  ffaa              dc.w     $ffaa
01019822  fd86              dc.w     $fd86
01019824  fb85              dc.w     $fb85
01019826  f9c1              dc.w     $f9c1
01019828  f852f74a          fsugt.b  (a2)
0101982c  f6b6f69d          fbf.w    $1018ecb
01019830  f701              dc.w     $f701
01019832  f7db              dc.w     $f7db
01019834  f920              fsave    -(a0)
01019836  fabffca2          fbf.w    $10194da
0101983a  feaf00ca          fbf.w    $1019906
0101983e  02da              dc.w     $02da
01019840  04c2              dc.w     $04c2
01019842  066907ba08a3      addi.w   #$7ba, $8a3(a1)
01019848  0919              btst.l   d4, (a1)+
0101984a  0916              btst.l   d4, (a6)
0101984c  089b              dc.w     $089b
0101984e  07af065e          bclr.b   d3, $65e(a7)
01019852  04ba              dc.w     $04ba
01019854  02da              dc.w     $02da
01019856  00d6              dc.w     $00d6
01019858  fec9fccefaff      fbf.l    $fdd09359                   ; $fdd09359 = NextBus slot space
0101985e  f974f841          frestore $41(a4, a7.l)
01019862  f776f71d          frestore ([a6], a7.w * 8)
01019866  f739f7caf8c6      fsave    $f7caf8c6.l                 ; $f7caf8c6 = NextBus slot space
0101986c  fa21fbc8          fmovem   invalid, -(a1)
01019870  fda6              dc.w     $fda6
01019872  ffa0              dc.w     $ffa0
01019874  019d              bclr.b   d0, (a5)+
01019876  0383              bclr.b   d1, d3
01019878  053806a7          btst.l   d2, $6a7.w
0101987c  07bd              dc.w     $07bd
0101987e  086b              dc.w     $086b
01019880  08a9              dc.w     $08a9
01019882  0874              dc.w     $0874
01019884  07d0              bset.b   d3, (a0)
01019886  06c5              dc.w     $6c5
01019888  0561              bchg.b   d2, -(a1)
0101988a  03b801e0          bclr.b   d1, $1e0.w
0101988e  fff1              dc.w     $fff1
01019890  fe04fc34          fmovem   invalid, d4
01019894  fa97f944          fbf.w    $10191da
01019898  f84bf7b9f795      fdbf     d3, $1019031
0101989e  f7e1              dc.w     $f7e1
010198a0  f897f9af          fbf.w    $1019251
010198a4  fb19              dc.w     $fb19
010198a6  fcc3fe960078      fbf.l    $ff979920                   ; $ff979920 = NextBus slot space
010198ac  0254040f          andi.w   #$40f, (a4)
010198b0  0592              bclr.b   d2, (a2)
010198b2  06ca              dc.w     $6ca
010198b4  07a7              bclr.b   d3, -(a7)
010198b6  081e              dc.w     $081e
010198b8  0829              dc.w     $0829
010198ba  07c80701          movep.l  d3, $701(a0)
010198be  05de              bset.b   d2, (a6)+
010198c0  046e02c600fa      subi.w   #$2c6, $fa(a6)
010198c6  ff24              fsave    -(a4)
010198c8  fd5b              frestore (a3)+
010198ca  fbb6              dc.w     $fbb6
010198cc  fa4cf92ef86c      fdbf     d4, $101913c
010198d2  f80ff81b          fmovem   invalid, a7
010198d6  f890f966          fbf.w    $101923e
010198da  fa93fc07          fbf.w    $10194e3
010198de  fdad              dc.w     $fdad
010198e0  ff71013902f0047f  frestore ([$2f0047f, a1, d0.w])
010198e8  05d0              bset.b   d2, (a0)
010198ea  06d4              dc.w     $06d4
010198ec  077c              dc.w     $077c
010198ee  07c0              bset.b   d3, d0
010198f0  079d              bclr.b   d3, (a5)+
010198f2  0716              btst.l   d3, (a6)
010198f4  063204fd038701e4002a  addi.b   #$fd, ([], d0.w * 2, $1e4002a) ; $01e4002a = ROM
010198fe  fe70fccbfb53fa1af930  fsuge.b  ([a0], $fa1af930)       ; $fa1af930 = NextBus slot space
01019908  f8a2f875          fbf.w    $101917f
0101990c  f8acf944          fbf.w    $1019252
01019910  fa34fb71fce8      fmovem   invalid, -$18(a4, a7.l)
01019916  fe860036          fbf.w    $101994e
0101991a  01e2              bset.b   d0, -(a2)
0101991c  037304d5          bchg.b   d1, -$2b(a3, d0.w)
01019920  05f606c6          bset.b   d2, -$3a(a6, d0.w)
01019924  073d              dc.w     $073d
01019926  0753              bchg.b   d3, (a3)
01019928  07080661          movep.w  $661(a0), d3
0101992c  0566              bchg.b   d2, -(a6)
0101992e  042402ad          subi.b   #$ad, -(a4)
01019932  0114              btst.l   d0, (a4)
01019934  ff70fdd3fc55fb09  frestore ([], $fc55fb09)             ; $fc55fb09 = NextBus slot space
0101993c  fa00f948          fmovem   invalid, d0
01019940  f8e9f8e8f945      fbf.l    $f9ea9287                   ; $f9ea9287 = NextBus slot space
01019946  f9fb              dc.w     $f9fb
01019948  fafffc45fdba      fbf.l    $fd479704                   ; $fd479704 = NextBus slot space
0101994e  ff4d              dc.w     $ff4d
01019950  00e6              dc.w     $00e6
01019952  027203dd0513060406a5  andi.w   #$3dd, ([a2, d0.w * 4], $60406a5) ; $060406a5 = RAM bank 1
0101995c  06ee              dc.w     $06ee
0101995e  06db              dc.w     $06db
01019960  066d05aa049e      addi.w   #$5aa, $49e(a5)
01019966  0355              bchg.b   d1, (a5)
01019968  01e2              bset.b   d0, -(a2)
0101996a  0057feca          ori.w    #$feca, (a7)
0101996e  fd4e              dc.w     $fd4e
01019970  fbf7              dc.w     $fbf7
01019972  fad7f9fcf972      fbf.l    $fafe92e6                   ; $fafe92e6 = NextBus slot space
01019978  f93f              dc.w     $f93f
0101997a  f965              dc.w     $f965
0101997c  f9e3              dc.w     $f9e3
0101997e  fab1fbc4          fbf.w    $1019544
01019982  fd0e              dc.w     $fd0e
01019984  fe7e              dc.w     $fe7e
01019986  00000180          ori.b    #$80, d0
0101998a  02ec              dc.w     $02ec
0101998c  042f053a05fe      subi.b   #$3a, $5fe(a7)
01019992  067306910659      addi.w   #$691, $59(a3, d0.w)
01019998  05cd04f5          movep.l  d2, $4f5(a5)
0101999c  03dc              bset.b   d1, (a4)+
0101999e  02920126ffae      andi.l   #$126ffae, (a2)             ; $0126ffae = ROM
010199a4  fe3bfce0fbb0fabbfa0c  fmovem   invalid, $fabbfa0c(a7.l * 2) ; $fabbfa0c = NextBus slot space
010199ae  f9ad              dc.w     $f9ad
010199b0  f9a1              dc.w     $f9a1
010199b2  f9ea              dc.w     $f9ea
010199b4  fa83fb64          fbf.w    $101951a
010199b8  fc81fdcc          fbf.w    $1019786
010199bc  ff3200a0          fsave    -$60(a2, d0.w)
010199c0  0206034f          andi.b   #$4f, d6
010199c4  046b054c05e6      subi.w   #$54c, $5e6(a3)
010199ca  0631062a05d1      addi.b   #$2a, ([])
010199d0  052c0443          btst.l   d2, $443(a4)
010199d4  0323              btst.l   d1, -(a3)
010199d6  01db              bset.b   d0, (a3)+
010199d8  007b              dc.w     $007b
010199da  ff17              fsave    (a7)
010199dc  fdc0              dc.w     $fdc0
010199de  fc87fb7e          fbf.w    $101955e
010199e2  fab2fa2d          fbf.w    $1019411
010199e6  f9f5              dc.w     $f9f5
010199e8  fa0dfa74          fmovem   invalid, a5
010199ec  fb24              fsave    -(a4)
010199ee  fc13fd36          fmovem   invalid, (a3)
010199f2  fe7cffd5          ftrapole 
010199f6  012e0276          btst.l   d0, $276(a6)
010199fa  039d              bclr.b   d1, (a5)+
010199fc  0493054c05bd      subi.l   #$54c05bd, (a3)             ; $054c05bd = RAM bank 0 (Turbo: 32 MB stride)
01019a02  05e2              bset.b   d2, -(a2)
01019a04  05ba              dc.w     $05ba
01019a06  0546              bchg.b   d2, d6
01019a08  048c              dc.w     $048c
01019a0a  0397              bclr.b   d1, (a7)
01019a0c  02740131ffe1fe93  andi.w   #$131, ([$fe93])
01019a14  fd59              frestore (a1)+
01019a16  fc43fb60          fsub.b   d3
01019a1a  fabbfa5c          fbf.w    $1019478
01019a1e  fa49fa81fb01      fdbf     d1, $1019523
01019a24  fbc3              dc.w     $fbc3
01019a26  fcbdfde0          fbf.w    $1019808
01019a2a  ff1e              dc.w     $ff1e
01019a2c  006601a8          ori.w    #$1a8, -(a6)
01019a30  02d3              dc.w     $02d3
01019a32  03d8              bset.b   d1, (a0)+
01019a34  04a8053a0587058a  subi.l   #$53a0587, $58a(a0)         ; $053a0587 = RAM bank 0 (Turbo: 32 MB stride)
01019a3c  0543              bchg.b   d2, d3
01019a3e  04b803ee02f201cf  subi.l   #$3ee02f2, $1cf.w           ; $03ee02f2 = NCC cache tag RAM
01019a46  0096ff57fe21      ori.l    #$ff57fe21, (a6)            ; $ff57fe21 = NextBus slot space
01019a4c  fd05              dc.w     $fd05
01019a4e  fc12fb54          fmovem   invalid, (a2)
01019a52  fad4fa99faa6      fbf.l    $fb9b94fa                   ; $fb9b94fa = NextBus slot space
01019a58  faf9fb8ffc5f      fbf.l    $fc9196b9                   ; $fc9196b9 = NextBus slot space
01019a5e  fd5e              frestore (a6)+
01019a60  fe7f              dc.w     $fe7f
01019a62  ffb2              dc.w     $ffb2
01019a64  00e8              dc.w     $00e8
01019a66  0211031e          andi.b   #$1e, (a1)
01019a6a  040004ac          subi.b   #$ac, d0
01019a6e  051b              btst.l   d2, (a3)+
01019a70  0545              bchg.b   d2, d5
01019a72  052904c9          btst.l   d2, $4c9(a1)
01019a76  042a03550255      subi.b   #$55, $255(a2)
01019a7c  01360009          btst.l   d0, $9(a6, d0.w)
01019a80  fedefdc1fcc4      fbf.l    $fec39746                   ; $fec39746 = NextBus slot space
01019a86  fbf2              dc.w     $fbf2
01019a88  fb57              frestore (a7)
01019a8a  fafafae0fb0a      fbf.l    $fbe29596                   ; $fbe29596 = NextBus slot space
01019a90  fb75fc1c          frestore $1c(a5, a7.l)
01019a94  fcf6fdf7ff12      fbf.l    $fef999a8                   ; $fef999a8 = NextBus slot space
01019a9a  003701590268      ori.b    #$59, $68(a7, d0.w)
01019aa0  0356              bchg.b   d1, (a6)
01019aa2  041704a1          subi.b   #$a1, (a7)
01019aa6  04ee              dc.w     $04ee
01019aa8  04f9              dc.w     $04f9
01019aaa  04c2              dc.w     $04c2
01019aac  044c              dc.w     $044c
01019aae  039e              bclr.b   d1, (a6)+
01019ab0  02c1              dc.w     $02c1
01019ab2  01c1              bset.b   d0, d1
01019ab4  00aaff8cfe75fd73  ori.l    #$ff8cfe75, -$28d(a2)       ; $ff8cfe75 = NextBus slot space
01019abc  fc94fbe3          fbf.w    $10196a1
01019ac0  fb69fb2d          frestore -$4d3(a1)
01019ac4  fb30fb73fbf2fca6fd86fe86  fsave    ([$fbf2fca6, a0], $fd86fe86) ; $fbf2fca6 = NextBus slot space; $fd86fe86 = NextBus slot space
01019ad0  ff98              dc.w     $ff98
01019ad2  00ad01b902ae037e  ori.l    #$1b902ae, $37e(a5)         ; $01b902ae = ROM
01019ada  041f0489          subi.b   #$89, (a7)+
01019ade  04b604a5045703cf  subi.l   #$4a50457, ([])             ; $04a50457 = RAM bank 0 (Turbo: 32 MB stride)
01019ae6  0316              btst.l   d1, (a6)
01019ae8  02350137002a      andi.b   #$37, $2a(a5, d0.w)
01019aee  ff1d              dc.w     $ff1d
01019af0  fe1cfd35          fmovem   invalid, (a4)+
01019af4  fc74fbe2fb88      fdsub.b  (a7.l * 2)
01019afa  fb69fb87          frestore -$479(a1)
01019afe  fbe0              dc.w     $fbe0
01019b00  fc6ffd2cfe0f      ftrapogl.b -$1f1(a7)
01019b06  ff0a              dc.w     $ff0a
01019b08  00100115          ori.b    #$15, (a0)
01019b0c  020a              dc.w     $020a
01019b0e  02e4              dc.w     $02e4
01019b10  0397              bclr.b   d1, (a7)
01019b12  04190465          subi.b   #$65, (a1)+
01019b16  0476044c03e90354  subi.w   #$44c, ([$354])
01019b1e  029201b000b8      andi.l   #$1b000b8, (a2)             ; $01b000b8 = ROM
01019b24  ffb8              dc.w     $ffb8
01019b26  febdfdd3          fbf.w    $10198fb
01019b2a  fd06              dc.w     $fd06
01019b2c  fc62fbef          ftrapueq.b -(a2)
01019b30  fbb1              dc.w     $fbb1
01019b32  fbad              dc.w     $fbad
01019b34  fbe2              dc.w     $fbe2
01019b36  fc4efce9fdad      fdbf     d6, $10198e7
01019b3c  fe8fff83          fbf.w    $1019ac1
01019b40  007c016e          ori.w    #$16e, sr
01019b44  024c              dc.w     $024c
01019b46  030b03a1          movep.w  $3a1(a3), d1
01019b4a  04070436          subi.b   #$36, d7
01019b4e  042e03ee037b      subi.b   #$ee, $37b(a6)
01019b54  02da              dc.w     $02da
01019b56  02140134          andi.b   #$34, (a4)
01019b5a  0044ff53          ori.w    #$ff53, d4
01019b5e  fe6afd98fce6      fsun.b   -$31a(a2)
01019b64  fc5efc07          fsor.b   (a6)+
01019b68  fbe4              dc.w     $fbe4
01019b6a  fbf8              dc.w     $fbf8
01019b6c  fc41fcbc          ftrapogl.b d1
01019b70  fd61              dc.w     $fd61
01019b72  fe28ff07fff2      fmovem   invalid, -$e(a0)
01019b78  00db              dc.w     $00db
01019b7a  01b902800325      bclr.b   d0, $2800325.l
01019b80  039f              bclr.b   d1, (a7)+
01019b82  03e903ff          bset.b   d1, $3ff(a1)
01019b86  03e1              bset.b   d1, -(a1)
01019b88  038e030e          movep.w  d1, $30e(a6)
01019b8c  0265019d          andi.w   #$19d, -(a5)
01019b90  00c1              dc.w     $00c1
01019b92  ffdd              dc.w     $ffdd
01019b94  fefafe26fd6b      fbf.l    $ff289901                   ; $ff289901 = NextBus slot space
01019b9a  fcd3fc66fc29      fbf.l    $fd6897c5                   ; $fd6897c5 = NextBus slot space
01019ba0  fc1ffc48          fmovem   invalid, (a7)+
01019ba4  fca2fd28          fbf.w    $10198ce
01019ba8  fdd4              dc.w     $fdd4
01019baa  fe9cff75          fbf.w    $1019b21
01019bae  0053012e          ori.w    #$12e, (a3)
01019bb2  01f702a6          bset.b   d0, -$5a(a7, d0.w)
01019bb6  0332039203c3      btst.l   d1, ([, d0.w * 2], $3c3)
01019bbc  03c2              bset.b   d1, d2
01019bbe  038f032d          movep.w  d1, $32d(a7)
01019bc2  02a201f4012e      andi.l   #$1f4012e, -(a2)            ; $01f4012e = ROM
01019bc8  0058ff80          ori.w    #$ff80, (a0)+
01019bcc  feaefdef          fbf.w    $10199bd
01019bd0  fd4b              dc.w     $fd4b
01019bd2  fcccfc78fc53      fbf.l    $fd7a9827                   ; $fd7a9827 = NextBus slot space
01019bd8  fc5ffc9b          fsuge.b  (a7)+
01019bdc  fd03              dc.w     $fd03
01019bde  fd93              dc.w     $fd93
01019be0  fe42ff07          fsor.b   d2
01019be4  ffd9              dc.w     $ffd9
01019be6  00aa0173022802c0  ori.l    #$1730228, $2c0(a2)         ; $01730228 = ROM
01019bee  0333037b0395037f033b02cc  btst.l   d1, ([$395037f, a3], $33b02cc)
01019bfa  0239018a00c6fffa  andi.b   #$8a, $c6fffa.l             ; $00c6fffa = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019c02  ff2efe6e          fsave    -$192(a6)
01019c06  fdc4              dc.w     $fdc4
01019c08  fd37fcd0          fsave    -$30(a7, a7.l)
01019c0c  fc94fc85          fbf.w    $1019893
01019c10  fca4fcf0          fbf.w    $1019902
01019c14  fd64              dc.w     $fd64
01019c16  fdf9              dc.w     $fdf9
01019c18  fea9ff6a          fbf.w    $1019b84
01019c1c  003100f601ad024d  ori.b    #$f6, ([$24d], d0.w)
01019c24  02cf              dc.w     $02cf
01019c26  032a035b          btst.l   d1, $35b(a2)
01019c2a  0360              bchg.b   d1, -(a0)
01019c2c  033802e5          btst.l   d1, $2e5.w
01019c30  026d01d50125      andi.w   #$1d5, $125(a5)
01019c36  0067ffa5          ori.w    #$ffa5, -(a7)
01019c3a  fee8fe3afda4      fbf.l    $ff3c99e0                   ; $ff3c99e0 = NextBus slot space
01019c40  fd2efcde          fsave    -$322(a6)
01019c44  fcb7fcbd          fbf.w    $1019903
01019c48  fcedfd45fdc2      fbf.l    $fe479a0c                   ; $fe479a0c = NextBus slot space
01019c4e  fe5cff0a          fsugt.b  (a4)+
01019c52  ffc5              dc.w     $ffc5
01019c54  0081013701dc      ori.l    #$13701dc, d1               ; $013701dc = ROM
01019c5a  026702d2          andi.w   #$2d2, -(a7)
01019c5e  0318              btst.l   d1, (a0)+
01019c60  0334032602ee0290  btst.l   d1, ([$2ee, a4], d0.w * 2, $290)
01019c68  02100175          andi.b   #$75, (a0)
01019c6c  00c8              dc.w     $00c8
01019c6e  0011ff5b          ori.b    #$5b, (a1)
01019c72  feadfe11          fbf.w    $1019a85
01019c76  fd90              dc.w     $fd90
01019c78  fd2ffcf4          fsave    -$30c(a7)
01019c7c  fce2fcf8fd37      fbf.l    $fdfa99b5                   ; $fdfa99b5 = NextBus slot space
01019c82  fd9b              dc.w     $fd9b
01019c84  fe1dfeb9          fmovem   invalid, (a5)+
01019c88  ff64              dc.w     $ff64
01019c8a  001600c7          ori.b    #$c7, (a6)
01019c8e  016d01ff          bchg.b   d0, $1ff(a5)
01019c92  027702cd02fe      andi.w   #$2cd, -$2(a7, d0.w)
01019c98  0307              btst.l   d1, d7
01019c9a  02e8              dc.w     $02e8
01019c9c  02a3023b01b6      andi.l   #$23b01b6, -(a3)
01019ca2  011b              btst.l   d0, (a3)+
01019ca4  0072ffc5ff1afe7c  ori.w    #$ffc5, ([a2, a7.l * 8], $fe7c)
01019cac  fdf3              dc.w     $fdf3
01019cae  fd85              dc.w     $fd85
01019cb0  fd39fd12fd11      fsave    $fd12fd11.l                 ; $fd12fd11 = NextBus slot space
01019cb6  fd38fd83          fsave    $fd83.w
01019cba  fdee              dc.w     $fdee
01019cbc  fe75ff10ffb6005f01030199  fsf.b    ([$5f0103], a7.l * 8, $199) ; $005f0103 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019cc8  0219027d          andi.b   #$7d, (a1)+
01019ccc  02bf              dc.w     $02bf
01019cce  02dd              dc.w     $02dd
01019cd0  02d5              dc.w     $02d5
01019cd2  02a8025801e80161  andi.l   #$25801e8, $161(a0)
01019cda  00c7              dc.w     $00c7
01019cdc  0024ff80          ori.b    #$80, -(a4)
01019ce0  fee3fe55fdde      fbf.l    $ff579ac0                   ; $ff579ac0 = NextBus slot space
01019ce6  fd84              dc.w     $fd84
01019ce8  fd4a              dc.w     $fd4a
01019cea  fd35fd45          fsave    ([a5])
01019cee  fd79fdcefe40      frestore $fdcefe40.l                 ; $fdcefe40 = NextBus slot space
01019cf4  fec8ff610000      fbf.l    $629cf6                     ; $00629cf6 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019cfa  009f013501bb      ori.l    #$13501bb, (a7)+            ; $013501bb = ROM
01019d00  0229027a02aa      andi.b   #$7a, $2aa(a1)
01019d06  02b702a00266020d  andi.l   #$2a00266, $d(a7, d0.w)
01019d0e  0198              bclr.b   d0, (a0)+
01019d10  0110              btst.l   d0, (a0)
01019d12  0079ffdeff45feb6  ori.w    #$ffde, $ff45feb6.l         ; $ff45feb6 = NextBus slot space
01019d1a  fe38fdd2fd8a      fmovem   invalid, $fd8a.w
01019d20  fd63              dc.w     $fd63
01019d22  fd5e              frestore (a6)+
01019d24  fd7cfdbb          frestore #$bb
01019d28  fe18fe8e          fmovem   invalid, (a0)+
01019d2c  ff17              fsave    (a7)
01019d2e  ffab              dc.w     $ffab
01019d30  004200d6          ori.w    #$d6, d2
01019d34  015e              bchg.b   d0, (a6)+
01019d36  01d4              bset.b   d0, (a4)
01019d38  02300270028f      andi.b   #$70, -$71(a0, d0.w)
01019d3e  028c              dc.w     $028c
01019d40  0268022301c3      andi.w   #$223, $1c3(a0)
01019d46  014c00c4          movep.l  $c4(a4), d0
01019d4a  0032ffa0ff12fe91  ori.b    #$a0, ([a2, a7.l * 8], $fe91)
01019d52  fe23fdcf          fmovem   invalid, -(a3)
01019d56  fd98              dc.w     $fd98
01019d58  fd80              dc.w     $fd80
01019d5a  fd8b              dc.w     $fd8b
01019d5c  fdb5              dc.w     $fdb5
01019d5e  fdfe              dc.w     $fdfe
01019d60  fe61fed9          fsueq.b  -(a1)
01019d64  ff60              dc.w     $ff60
01019d66  ffee              dc.w     $ffee
01019d68  007c0104          ori.w    #$104, sr
01019d6c  017e              dc.w     $017e
01019d6e  01e4              bset.b   d0, -(a4)
01019d70  0230025f026f      andi.b   #$5f, $6f(a0, d0.w)
01019d76  025e022e          andi.w   #$22e, (a6)+
01019d7a  01e1              bset.b   d0, -(a1)
01019d7c  017c              dc.w     $017c
01019d7e  0103              btst.l   d0, d3
01019d80  007e              dc.w     $007e
01019d82  fff3              dc.w     $fff3
01019d84  ff69fee7          frestore -$119(a1)
01019d88  fe75fe17fdd2fdab  fsor.b   ([], $fdab)
01019d90  fda3              dc.w     $fda3
01019d92  fdba              dc.w     $fdba
01019d94  fdef              dc.w     $fdef
01019d96  fe40fea7          ftrapeq.b d0
01019d9a  ff1f              dc.w     $ff1f
01019d9c  ffa3              dc.w     $ffa3
01019d9e  002a00af012b      ori.b    #$af, $12b(a2)
01019da4  0197              bclr.b   d0, (a7)
01019da6  01ed0229          bset.b   d0, $229(a5)
01019daa  0249              dc.w     $0249
01019dac  024a              dc.w     $024a
01019dae  022d01f301a0      andi.b   #$f3, $1a0(a5)
01019db4  013700bf          btst.l   d0, -$41(a7, d0.w)
01019db8  003e              dc.w     $003e
01019dba  ffba              dc.w     $ffba
01019dbc  ff3a              dc.w     $ff3a
01019dbe  fec5fe60fe11      fbf.l    $ff629bd1                   ; $ff629bd1 = NextBus slot space
01019dc4  fddd              dc.w     $fddd
01019dc6  fdc4              dc.w     $fdc4
01019dc8  fdca              dc.w     $fdca
01019dca  fdec              dc.w     $fdec
01019dcc  fe2afe80fee9      fmovem   invalid, -$117(a2)
01019dd2  ff61              dc.w     $ff61
01019dd4  ffe0              dc.w     $ffe0
01019dd6  006000da          ori.w    #$da, -(a0)
01019dda  014a01a7          movep.l  $1a7(a2), d0
01019dde  01ef021c          bset.b   d0, $21c(a7)
01019de2  022d022201fa      andi.b   #$22, $1fa(a5)
01019de8  01b9016100f6      bclr.b   d0, $16100f6.l              ; $016100f6 = ROM
01019dee  00800004ff88      ori.l    #$4ff88, d0
01019df4  ff13              fsave    (a3)
01019df6  feaafe53          fbf.w    $1019c4b
01019dfa  fe13fded          fmovem   invalid, (a3)
01019dfe  fde2              dc.w     $fde2
01019e00  fdf3              dc.w     $fdf3
01019e02  fe1ffe64          fmovem   invalid, (a7)+
01019e06  febeff29          fbf.w    $1019d31
01019e0a  ff9e              dc.w     $ff9e
01019e0c  0016008e          ori.b    #$8e, (a6)
01019e10  00fe              dc.w     $00fe
01019e12  0161              bchg.b   d0, -(a1)
01019e14  01b101ea020a020e  bclr.b   d0, ([$20a], $20e)
01019e1c  01f701c7          bset.b   d0, ([])
01019e20  017f              dc.w     $017f
01019e22  0123              btst.l   d0, -(a3)
01019e24  00b90046ffd0ff5dfef2  ori.l    #$46ffd0, $ff5dfef2.l   ; $0046ffd0 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup); $ff5dfef2 = NextBus slot space
01019e2e  fe96fe4d          fbf.w    $1019c7d
01019e32  fe1afe01          fmovem   invalid, (a2)+
01019e36  fe03fe1f          fmovem   invalid, d3
01019e3a  fe53fe9e          fsne.b   (a3)
01019e3e  fefaff64ffd5      fbf.l    $669e15                     ; $00669e15 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019e44  004700b6          ori.w    #$b6, d7
01019e48  011b              btst.l   d0, (a3)+
01019e4a  017101b401e001f3  bchg.b   d0, $1e001f3(d0.w)          ; $01e001f3 = ROM
01019e52  01ec01cb          bset.b   d0, $1cb(a4)
01019e56  0193              bclr.b   d0, (a3)
01019e58  0146              bchg.b   d0, d6
01019e5a  00e9              dc.w     $00e9
01019e5c  00800011ffa3      ori.l    #$11ffa3, d0                ; $0011ffa3 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019e62  ff38fed9          fsave    $fed9.w
01019e66  fe89fe4d          fbf.w    $1019cb5
01019e6a  fe27fe1a          fmovem   invalid, -(a7)
01019e6e  fe27fe4b          fmovem   invalid, -(a7)
01019e72  fe87fed5          fbf.w    $1019d49
01019e76  ff33ff9b00060072  fsave    ([, a7.l * 8], $60072)
01019e7e  00d8              dc.w     $00d8
01019e80  0132017c01b201d1  btst.l   d0, $1b201d1(a2, invalid.w) ; $01b201d1 = ROM
01019e88  01d8              bset.b   d0, (a0)+
01019e8a  01c7              bset.b   d0, d7
01019e8c  019e              bclr.b   d0, (a6)+
01019e8e  0160              bchg.b   d0, -(a0)
01019e90  0110              btst.l   d0, (a0)
01019e92  00b2004cffe3ff7bff1afec5  ori.l    #$4cffe3, ([$ff1afec5, a2], $aaaaaaaa) ; $004cffe3 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup); $ff1afec5 = NextBus slot space
01019e9e  fe81fe52          fbf.w    $1019cf2
01019ea2  fe38fe37fe4d      fmovem   invalid, $fe4d.w
01019ea8  fe79feb9ff0aff68  ftrapoge.b $ff0aff68.l               ; $ff0aff68 = NextBus slot space
01019eb0  ffcd              dc.w     $ffcd
01019eb2  0033009700f3      ori.b    #$97, -$d(a3, d0.w)
01019eb8  0142              bchg.b   d0, d2
01019eba  0180              bclr.b   d0, d0
01019ebc  01aa01be          bclr.b   d0, $1be(a2)
01019ec0  01ba              dc.w     $01ba
01019ec2  01a0              bclr.b   d0, -(a0)
01019ec4  0170012e00dc007f  bchg.b   d0, ([$dc, a0], d0.w, $7f)
01019ecc  001cffb9          ori.b    #$b9, (a4)+
01019ed0  ff59              frestore (a1)+
01019ed2  ff02              dc.w     $ff02
01019ed4  feb8fe80          fbf.w    $1019d56
01019ed8  fe5cfe4d          fsule.b  (a4)+
01019edc  fe56fe74          ftanh.b  (a6)
01019ee0  fea6feeb          fbf.w    $1019dcd
01019ee4  ff3d              dc.w     $ff3d
01019ee6  ff99              dc.w     $ff99
01019ee8  fffa              dc.w     $fffa
01019eea  005a00b6          ori.w    #$b6, (a2)+
01019eee  0108014d          movep.w  $14d(a0), d0
01019ef2  017f              dc.w     $017f
01019ef4  019e              bclr.b   d0, (a6)+
01019ef6  01a7              bclr.b   d0, -(a7)
01019ef8  019a              bclr.b   d0, (a2)+
01019efa  01780143          bchg.b   d0, $143.w
01019efe  00fd              dc.w     $00fd
01019f00  00ab0050fff2ff94  ori.l    #$50fff2, -$6c(a3)          ; $0050fff2 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019f08  ff3c              dc.w     $ff3c
01019f0a  feeffeb0fe83      fbf.l    $ffb29d8f                   ; $ffb29d8f = NextBus slot space
01019f10  fe6afe65fe76      ftentox.b -$18a(a2)
01019f16  fe9cfed3          fbf.w    $1019deb
01019f1a  ff1a              dc.w     $ff1a
01019f1c  ff6dffc7          frestore -$39(a5)
01019f20  0022007c          ori.b    #$7c, -(a2)
01019f24  00d0              dc.w     $00d0
01019f26  0118              btst.l   d0, (a0)+
01019f28  0152              bchg.b   d0, (a2)
01019f2a  017a              dc.w     $017a
01019f2c  018e018d          movep.w  d0, $18d(a6)
01019f30  01780150          bchg.b   d0, $150.w
01019f34  0116              btst.l   d0, (a6)
01019f36  00cf              dc.w     $00cf
01019f38  007d              dc.w     $007d
01019f3a  0024ffcb          ori.b    #$cb, -(a4)
01019f3e  ff75ff25fee2      frestore ([$fee2, a5], a7.l * 8)
01019f44  feadfe8b          fbf.w    $1019dd1
01019f48  fe7bfe80fe99fec4  ftrapf.w #$fe99fec4                  ; $fe99fec4 = NextBus slot space
01019f50  feffff48ff99      fbf.l    $4a9eeb                     ; $004a9eeb = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019f56  fff0              dc.w     $fff0
01019f58  00460099          ori.w    #$99, d6
01019f5c  00e4              dc.w     $00e4
01019f5e  0123              btst.l   d0, -(a3)
01019f60  0152              bchg.b   d0, (a2)
01019f62  0170017b01720156012800eb  bchg.b   d0, ([$1720156, a0], $12800eb) ; $01720156 = ROM; $012800eb = ROM
01019f6e  00a30052fffe      ori.l    #$52fffe, -(a3)             ; $0052fffe = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019f74  ffaa              dc.w     $ffaa
01019f76  ff5a              frestore (a2)+
01019f78  ff14              fsave    (a4)
01019f7a  fedafeaffe96      fbf.l    $ffb19e12                   ; $ffb19e12 = NextBus slot space
01019f80  fe90fe9d          fbf.w    $1019e1f
01019f84  febcfeec          fbf.w    $1019e72
01019f88  ff2aff73          fsave    -$8d(a2)
01019f8c  ffc2              dc.w     $ffc2
01019f8e  00140065          ori.b    #$65, (a4)
01019f92  00b100f30129014f  ori.l    #$f30129, ([a1])            ; $00f30129 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019f9a  0163              bchg.b   d0, -(a3)
01019f9c  0165              bchg.b   d0, -(a5)
01019f9e  0154              bchg.b   d0, (a4)
01019fa0  01320101          btst.l   d0, ([a2, d0.w])
01019fa4  00c2              dc.w     $00c2
01019fa6  0079002affdbff8d  ori.w    #$2a, $ffdbff8d.l           ; $ffdbff8d = NextBus slot space
01019fae  ff45              dc.w     $ff45
01019fb0  ff07              dc.w     $ff07
01019fb2  fed6feb5fea5      fbf.l    $ffb79e59                   ; $ffb79e59 = NextBus slot space
01019fb8  fea7febb          fbf.w    $1019e75
01019fbc  fedfff13ff52      fbf.l    $159f10                     ; $00159f10 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019fc2  ff9b              dc.w     $ff9b
01019fc4  ffe8              dc.w     $ffe8
01019fc6  0035008000c4      ori.b    #$80, -$3c(a5, d0.w)
01019fcc  00fe              dc.w     $00fe
01019fce  012a0147          btst.l   d0, $147(a2)
01019fd2  0153              bchg.b   d0, (a3)
01019fd4  014d0136          movep.l  $136(a5), d0
01019fd8  010f00da          movep.w  $da(a7), d0
01019fdc  009a00520007      ori.l    #$520007, (a2)+             ; $00520007 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
01019fe2  ffbc              dc.w     $ffbc
01019fe4  ff74ff34fefefed6  frestore $fefefed6(a4, a7.l * 8)     ; $fefefed6 = NextBus slot space
01019fec  febefeb6          fbf.w    $1019ea4
01019ff0  fec0fedaff03      fbf.l    $ffdc9ef5                   ; $ffdc9ef5 = NextBus slot space
01019ff6  ff39ff79ffc0      fsave    $ff79ffc0.l                 ; $ff79ffc0 = NextBus slot space
01019ffc  0009              dc.w     $0009
01019ffe  00520097          ori.w    #$97, (a2)
0101a002  00d3              dc.w     $00d3
0101a004  0105              btst.l   d0, d5
0101a006  0128013d          btst.l   d0, $13d(a0)
0101a00a  0140              bchg.b   d0, d0
0101a00c  0134011700ec00b5  btst.l   d0, ([a4], d0.w, $ec00b5)   ; $00ec00b5 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a014  0075002fffe8ffa1  ori.w    #$2f, $ffa1(invalid.w)
0101a01c  ff60              dc.w     $ff60
0101a01e  ff27              fsave    -(a7)
0101a020  fefafedafeca      fbf.l    $ffdc9eec                   ; $ffdc9eec = NextBus slot space
0101a026  fecafedafef9      fbf.l    $ffdc9f21                   ; $ffdc9f21 = NextBus slot space
0101a02c  ff25              fsave    -(a5)
0101a02e  ff5d              frestore (a5)+
0101a030  ff9d              dc.w     $ff9d
0101a032  ffe2              dc.w     $ffe2
0101a034  0027006b          ori.b    #$6b, -(a7)
0101a038  00a900de01070123  ori.l    #$de0107, $123(a1)          ; $00de0107 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a040  012f012c          btst.l   d0, $12c(a7)
0101a044  0119              btst.l   d0, (a1)+
0101a046  00f8              dc.w     $00f8
0101a048  00ca              dc.w     $00ca
0101a04a  00920052000f      ori.l    #$52000f, (a2)              ; $0052000f = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a050  ffcc              dc.w     $ffcc
0101a052  ff8a              dc.w     $ff8a
0101a054  ff50              frestore (a0)
0101a056  ff1f              dc.w     $ff1f
0101a058  fef9fee1fed9      fbf.l    $ffe39f33                   ; $ffe39f33 = NextBus slot space
0101a05e  fedffef5ff18      fbf.l    $fff79f78                   ; $fff79f78 = NextBus slot space
0101a064  ff47              dc.w     $ff47
0101a066  ff7f              dc.w     $ff7f
0101a068  ffbe              dc.w     $ffbe
0101a06a  00000041          ori.b    #$41, d0
0101a06e  007f              dc.w     $007f
0101a070  00b700e40106011a011f  ori.l    #$e40106, ([a7, d0.w], $11f) ; $00e40106 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a07a  0116              btst.l   d0, (a6)
0101a07c  00fe              dc.w     $00fe
0101a07e  00d9              dc.w     $00d9
0101a080  00a900700032fff2  ori.l    #$700032, -$e(a1)           ; $00700032 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a088  ffb3              dc.w     $ffb3
0101a08a  ff78ff44          frestore $ff44.w
0101a08e  ff1a              dc.w     $ff1a
0101a090  fefcfeebfee9      fbf.l    $ffed9f7b                   ; $ffed9f7b = NextBus slot space
0101a096  fef6ff10ff37      fbf.l    $129fcf                     ; $00129fcf = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a09c  ff67              dc.w     $ff67
0101a09e  ffa0              dc.w     $ffa0
0101a0a0  ffdd              dc.w     $ffdd
0101a0a2  001b0058          ori.b    #$58, (a3)+
0101a0a6  009000c100e7      ori.l    #$c100e7, (a0)              ; $00c100e7 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a0ac  0102              btst.l   d0, d2
0101a0ae  010f010d          movep.w  $10d(a7), d0
0101a0b2  00fe              dc.w     $00fe
0101a0b4  00e2              dc.w     $00e2
0101a0b6  00ba              dc.w     $00ba
0101a0b8  0089              dc.w     $0089
0101a0ba  00510015          ori.w    #$15, (a1)
0101a0be  ffd9              dc.w     $ffd9
0101a0c0  ff9e              dc.w     $ff9e
0101a0c2  ff68ff3b          frestore -$c5(a0)
0101a0c6  ff18              dc.w     $ff18
0101a0c8  ff01              dc.w     $ff01
0101a0ca  fef8fefcff0e      fbf.l    $fffe9fda                   ; $fffe9fda = NextBus slot space
0101a0d0  ff2cff55          fsave    -$ab(a4)
0101a0d4  ff86              dc.w     $ff86
0101a0d6  ffbe              dc.w     $ffbe
0101a0d8  fff9              dc.w     $fff9
0101a0da  0033006b009e      ori.b    #$6b, -$62(a3, d0.w)
0101a0e0  00c8              dc.w     $00c8
0101a0e2  00e7              dc.w     $00e7
0101a0e4  00fb              dc.w     $00fb
0101a0e6  0101              btst.l   d0, d1
0101a0e8  00fa              dc.w     $00fa
0101a0ea  00e6              dc.w     $00e6
0101a0ec  00c7              dc.w     $00c7
0101a0ee  009d006b0034      ori.l    #$6b0034, (a5)+             ; $006b0034 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a0f4  fffb              dc.w     $fffb
0101a0f6  ffc2              dc.w     $ffc2
0101a0f8  ff8c              dc.w     $ff8c
0101a0fa  ff5d              frestore (a5)+
0101a0fc  ff36ff1aff09      fsave    ([a6, a7.l * 8], $ff09)
0101a102  ff06              dc.w     $ff06
0101a104  ff10              fsave    (a0)
0101a106  ff26              fsave    -(a6)
0101a108  ff47              dc.w     $ff47
0101a10a  ff71ffa3ffda00110048  frestore ([$ffda, a7.l * 8], $110048) ; $00110048 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a114  007b              dc.w     $007b
0101a116  00a800cc00e500f2  ori.l    #$cc00e5, $f2(a0)           ; $00cc00e5 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a11e  00f2              dc.w     $00f2
0101a120  00e6              dc.w     $00e6
0101a122  00ce              dc.w     $00ce
0101a124  00ac0081004f0019  ori.l    #$81004f, $19(a4)           ; $0081004f = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a12c  ffe4              dc.w     $ffe4
0101a12e  ffaf              dc.w     $ffaf
0101a130  ff7e              dc.w     $ff7e
0101a132  ff54              frestore (a4)
0101a134  ff34ff1eff14      fsave    ([a4], a7.l * 8, $ff14)
0101a13a  ff16              fsave    (a6)
0101a13c  ff24              fsave    -(a4)
0101a13e  ff3e              dc.w     $ff3e
0101a140  ff61              dc.w     $ff61
0101a142  ff8d              dc.w     $ff8d
0101a144  ffbe              dc.w     $ffbe
0101a146  fff3              dc.w     $fff3
0101a148  0027005a          ori.b    #$5a, -(a7)
0101a14c  0088              dc.w     $0088
0101a14e  00af00cc00df00e6  ori.l    #$cc00df, $e6(a7)           ; $00cc00df = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a156  00e2              dc.w     $00e2
0101a158  00d1              dc.w     $00d1
0101a15a  00b6009200660035  ori.l    #$920066, $35(a6, d0.w)     ; $00920066 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a162  0001ffcf          ori.b    #$cf, d1
0101a166  ff9e              dc.w     $ff9e
0101a168  ff73ff4f          frestore ([a3])
0101a16c  ff34ff24ff20      fsave    $ff20(a4, a7.l * 8)
0101a172  ff27              fsave    -(a7)
0101a174  ff39ff56ff7b      fsave    $ff56ff7b.l                 ; $ff56ff7b = NextBus slot space
0101a17a  ffa7              dc.w     $ffa7
0101a17c  ffd8              dc.w     $ffd8
0101a17e  0009              dc.w     $0009
0101a180  003b              dc.w     $003b
0101a182  0069009200b3      ori.w    #$92, $b3(a1)
0101a188  00ca              dc.w     $00ca
0101a18a  00d7              dc.w     $00d7
0101a18c  00d9              dc.w     $00d9
0101a18e  00d0              dc.w     $00d0
0101a190  00bc              dc.w     $00bc
0101a192  009e0078004c      ori.l    #$78004c, (a6)+             ; $0078004c = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a198  001dffed          ori.b    #$ed, (a5)+
0101a19c  ffbd              dc.w     $ffbd
0101a19e  ff91              dc.w     $ff91
0101a1a0  ff6bff4c          frestore -$b4(a3)
0101a1a4  ff37ff2dff2e      fsave    ([$ff2e, a7], a7.l * 8)
0101a1aa  ff39ff4fff6e      fsave    $ff4fff6e.l                 ; $ff4fff6e = NextBus slot space
0101a1b0  ff94              dc.w     $ff94
0101a1b2  ffc0              dc.w     $ffc0
0101a1b4  ffef              dc.w     $ffef
0101a1b6  001d004b          ori.b    #$4b, (a5)+
0101a1ba  0075009800b4      ori.w    #$98, -$4c(a5, d0.w)
0101a1c0  00c6              dc.w     $00c6
0101a1c2  00ce              dc.w     $00ce
0101a1c4  00cb              dc.w     $00cb
0101a1c6  00be              dc.w     $00be
0101a1c8  00a600870060      ori.l    #$870060, -(a6)             ; $00870060 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a1ce  00350007ffdaffae  ori.b    #$7, ([], $ffae)
0101a1d6  ff86              dc.w     $ff86
0101a1d8  ff65              dc.w     $ff65
0101a1da  ff4c              dc.w     $ff4c
0101a1dc  ff3d              dc.w     $ff3d
0101a1de  ff37ff3dff4cff64  fsave    ([$ff4cff64, a7], a7.l * 8) ; $ff4cff64 = NextBus slot space
0101a1e6  ff85              dc.w     $ff85
0101a1e8  ffab              dc.w     $ffab
0101a1ea  ffd6              dc.w     $ffd6
0101a1ec  0002002f          ori.b    #$2f, d2
0101a1f0  0059007e          ori.w    #$7e, (a1)+
0101a1f4  009d00b300c0      ori.l    #$b300c0, (a5)+             ; $00b300c0 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a1fa  00c3              dc.w     $00c3
0101a1fc  00bc              dc.w     $00bc
0101a1fe  00ab009100700049  ori.l    #$910070, $49(a3)           ; $00910070 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a206  001ffff4          ori.b    #$f4, (a7)+
0101a20a  ffc9              dc.w     $ffc9
0101a20c  ffa1              dc.w     $ffa1
0101a20e  ff7e              dc.w     $ff7e
0101a210  ff62              dc.w     $ff62
0101a212  ff4e              dc.w     $ff4e
0101a214  ff44              dc.w     $ff44
0101a216  ff43              dc.w     $ff43
0101a218  ff4c              dc.w     $ff4c
0101a21a  ff5f              frestore (a7)+
0101a21c  ff79ff9bffc1      frestore $ff9bffc1.l                 ; $ff9bffc1 = NextBus slot space
0101a222  ffeb              dc.w     $ffeb
0101a224  0015003e          ori.b    #$3e, (a5)
0101a228  00640085          ori.w    #$85, -(a4)
0101a22c  009f00b000b8      ori.l    #$b000b8, (a7)+             ; $00b000b8 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a232  00b700ac0098007d  ori.l    #$ac0098, $7d(a7, d0.w)     ; $00ac0098 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a23a  005b0034          ori.w    #$34, (a3)+
0101a23e  000b              dc.w     $000b
0101a240  ffe3              dc.w     $ffe3
0101a242  ffbb              dc.w     $ffbb
0101a244  ff97              dc.w     $ff97
0101a246  ff79ff61ff52      frestore $ff61ff52.l                 ; $ff61ff52 = NextBus slot space
0101a24c  ff4d              dc.w     $ff4d
0101a24e  ff50              frestore (a0)
0101a250  ff5c              frestore (a4)+
0101a252  ff71ff8effb0      frestore ([], a7.l * 8, $ffb0)
0101a258  ffd6              dc.w     $ffd6
0101a25a  fffe              dc.w     $fffe
0101a25c  0025004b          ori.b    #$4b, -(a5)
0101a260  006d0089009e      ori.w    #$89, $9e(a5)
0101a266  00ab00af00a9009b  ori.l    #$af00a9, $9b(a3)           ; $00af00a9 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a26e  008500680046      ori.l    #$680046, d5                ; $00680046 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a274  0021fffa          ori.b    #$fa, -(a1)
0101a278  ffd4              dc.w     $ffd4
0101a27a  ffaf              dc.w     $ffaf
0101a27c  ff8f              dc.w     $ff8f
0101a27e  ff75ff63ff58ff56ff5e  frestore ([$ff58, a5], $ff56ff5e) ; $ff56ff5e = NextBus slot space
0101a288  ff6dff84          frestore -$7c(a5)
0101a28c  ffa1              dc.w     $ffa1
0101a28e  ffc3              dc.w     $ffc3
0101a290  ffe9              dc.w     $ffe9
0101a292  000e              dc.w     $000e
0101a294  003300560074      ori.b    #$56, $74(a3, d0.w)
0101a29a  008b              dc.w     $008b
0101a29c  009c00a400a4      ori.l    #$a400a4, (a4)+             ; $00a400a4 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a2a2  009b008b0073      ori.l    #$8b0073, (a3)+             ; $008b0073 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a2a8  00550033          ori.w    #$33, (a5)
0101a2ac  000f              dc.w     $000f
0101a2ae  ffeb              dc.w     $ffeb
0101a2b0  ffc7              dc.w     $ffc7
0101a2b2  ffa6              dc.w     $ffa6
0101a2b4  ff8a              dc.w     $ff8a
0101a2b6  ff74ff66ff60      frestore ([$ff60, a4])
0101a2bc  ff62              dc.w     $ff62
0101a2be  ff6cff7e          frestore -$82(a4)
0101a2c2  ff96              dc.w     $ff96
0101a2c4  ffb4              dc.w     $ffb4
0101a2c6  ffd6              dc.w     $ffd6
0101a2c8  fffa              dc.w     $fffa
0101a2ca  001d003f          ori.b    #$3f, (a5)+
0101a2ce  005e0078          ori.w    #$78, (a6)+
0101a2d2  008c              dc.w     $008c
0101a2d4  0098009c0099      ori.l    #$9c0099, (a0)+             ; $009c0099 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a2da  008d              dc.w     $008d
0101a2dc  007a              dc.w     $007a
0101a2de  00610043          ori.w    #$43, -(a1)
0101a2e2  0022ffff          ori.b    #$ff, -(a2)
0101a2e6  ffdd              dc.w     $ffdd
0101a2e8  ffbc              dc.w     $ffbc
0101a2ea  ff9f              dc.w     $ff9f
0101a2ec  ff87              dc.w     $ff87
0101a2ee  ff75ff6bff68ff6dff7a  frestore ([$ff68, a5], $ff6dff7a) ; $ff6dff7a = NextBus slot space
0101a2f8  ff8e              dc.w     $ff8e
0101a2fa  ffa8              dc.w     $ffa8
0101a2fc  ffc6              dc.w     $ffc6
0101a2fe  ffe7              dc.w     $ffe7
0101a300  0008              dc.w     $0008
0101a302  002a00490064      ori.b    #$49, $64(a2)
0101a308  007a              dc.w     $007a
0101a30a  008a              dc.w     $008a
0101a30c  00930093008d      ori.l    #$93008d, (a3)              ; $0093008d = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a312  007e              dc.w     $007e
0101a314  006a00500032      ori.w    #$50, $32(a2)
0101a31a  0011fff1          ori.b    #$f1, (a1)
0101a31e  ffd1              dc.w     $ffd1
0101a320  ffb3              dc.w     $ffb3
0101a322  ff99              dc.w     $ff99
0101a324  ff85              dc.w     $ff85
0101a326  ff77ff71ff72ff7a  frestore ([$ff72ff7a, a7])           ; $ff72ff7a = NextBus slot space
0101a32e  ff89              dc.w     $ff89
0101a330  ff9e              dc.w     $ff9e
0101a332  ffb8              dc.w     $ffb8
0101a334  ffd6              dc.w     $ffd6
0101a336  fff6              dc.w     $fff6
0101a338  00160035          ori.b    #$35, (a6)
0101a33c  00510069          ori.w    #$69, (a1)
0101a340  007b              dc.w     $007b
0101a342  0087008c0089      ori.l    #$8c0089, d7                ; $008c0089 = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a348  00800070005a      ori.l    #$70005a, d0                ; $0070005a = low memory (ROM alias at reset / exception vectors after MMU/TMC setup)
0101a34e  003f              dc.w     $003f
0101a350  00220003          ori.b    #$3, -(a2)
0101a354  0226017c          andi.b   #$7c, -(a6)
0101a358  0101              btst.l   d0, d1
0101a35a  3c49              movea.w  a1, a6
0101a35c  0100              btst.l   d0, d0
0101a35e  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a364  6b3c              bmi.b    $101a3a2
0101a366  02050280          andi.b   #$80, d5
0101a36a  01d0              bset.b   d0, (a0)
0101a36c  0101              btst.l   d0, d1
0101a36e  7048              moveq    #$48, d0
0101a370  0305              btst.l   d1, d5
0101a372  028001d00101      andi.l   #$1d00101, d0               ; $01d00101 = ROM
0101a378  731c              dc.w     $731c
0101a37a  0105              btst.l   d0, d5
0101a37c  0226017c          andi.b   #$7c, -(a6)
0101a380  0101              btst.l   d0, d1
0101a382  3c5f              movea.w  (a7)+, a6
0101a384  0500              btst.l   d2, d0
0101a386  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a38c  6b3c              bmi.b    $101a3ca
0101a38e  060102a0          addi.b   #$a0, d1
0101a392  01c0              bset.b   d0, d0
0101a394  0101              btst.l   d0, d1
0101a396  760a              moveq    #$a, d3
0101a398  0722              btst.l   d3, -(a2)
0101a39a  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a3a0  6b3c              bmi.b    $101a3de
0101a3a2  0801              dc.w     $0801
0101a3a4  02a001c80101      andi.l   #$1c80101, -(a0)            ; $01c80101 = ROM
0101a3aa  765a              moveq    #$5a, d3
0101a3ac  0922              btst.l   d4, -(a2)
0101a3ae  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a3b4  6b3c              bmi.b    $101a3f2
0101a3b6  0a0102a0          eori.b   #$a0, d1
0101a3ba  01d0              bset.b   d0, (a0)
0101a3bc  0101              btst.l   d0, d1
0101a3be  76aa              moveq    #$aa, d3
0101a3c0  0522              btst.l   d2, -(a2)
0101a3c2  0226017c          andi.b   #$7c, -(a6)
0101a3c6  0101              btst.l   d0, d1
0101a3c8  3c720c00          movea.w  (a2, d0.l * 4), a6
0101a3cc  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a3d2  6b3c              bmi.b    $101a410
0101a3d4  0d22              btst.l   d6, -(a2)
0101a3d6  029801c90101      andi.l   #$1c90101, (a0)+            ; $01c90101 = ROM
0101a3dc  76fa              moveq    #$fa, d3
0101a3de  0c220226          cmpi.b   #$26, -(a2)
0101a3e2  0186              bclr.b   d0, d6
0101a3e4  0101              btst.l   d0, d1
0101a3e6  3c83              move.w   d3, (a6)
0101a3e8  0f00              btst.l   d7, d0
0101a3ea  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a3f0  6b3c              bmi.b    $101a42e
0101a3f2  1022              move.b   -(a2), d0
0101a3f4  028001d00101      andi.l   #$1d00101, d0               ; $01d00101 = ROM
0101a3fa  77a6              dc.w     $77a6
0101a3fc  0f22              btst.l   d7, -(a2)
0101a3fe  0226017c          andi.b   #$7c, -(a6)
0101a402  0101              btst.l   d0, d1
0101a404  3c49              movea.w  a1, a6
0101a406  1200              move.b   d0, d1
0101a408  028001e50101      andi.l   #$1e50101, d0               ; $01e50101 = ROM
0101a40e  8666              or.w     -(a6), d3
0101a410  1305              move.b   d5, -(a1)
0101a412  028001e00101      andi.l   #$1e00101, d0               ; $01e00101 = ROM
0101a418  8cb61405          or.l     $5(a6, d1.w), d6
0101a41c  028001e00101      andi.l   #$1e00101, d0               ; $01e00101 = ROM
0101a422  9154              sub.w    d0, (a4)
0101a424  1205              move.b   d5, d1
0101a426  02260186          andi.b   #$86, -(a6)
0101a42a  0101              btst.l   d0, d1
0101a42c  3c8c              move.w   a4, (a6)
0101a42e  1600              move.b   d0, d3
0101a430  028001e50101      andi.l   #$1e50101, d0               ; $01e50101 = ROM
0101a436  8666              or.w     -(a6), d3
0101a438  1644              dc.w     $1644
0101a43a  0226017c          andi.b   #$7c, -(a6)
0101a43e  0101              btst.l   d0, d1
0101a440  3c97              move.w   (a7), (a6)
0101a442  1800              move.b   d0, d4
0101a444  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a44a  79de              dc.w     $79de
0101a44c  1905              move.b   d5, -(a4)
0101a44e  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a454  7e7e              moveq    #$7e, d7
0101a456  1a05              move.b   d5, d5
0101a458  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a45e  826e1805          or.w     $1805(a6), d1
0101a462  02260186          andi.b   #$86, -(a6)
0101a466  0101              btst.l   d0, d1
0101a468  3cb01c00          move.w   (a0, d1.l * 4), (a6)
0101a46c  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a472  79de              dc.w     $79de
0101a474  1c44              dc.w     $1c44
0101a476  0226017c          andi.b   #$7c, -(a6)
0101a47a  0101              btst.l   d0, d1
0101a47c  3cbc1e44          move.w   #$1e44, (a6)
0101a480  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a486  6b3c              bmi.b    $101a4c4
0101a488  1f05              move.b   d5, -(a7)
0101a48a  028001d00101      andi.l   #$1d00101, d0               ; $01d00101 = ROM
0101a490  7048              moveq    #$48, d0
0101a492  2005              move.l   d5, d0
0101a494  028001d00101      andi.l   #$1d00101, d0               ; $01d00101 = ROM
0101a49a  731c              dc.w     $731c
0101a49c  1e05              move.b   d5, d7
0101a49e  02260186          andi.b   #$86, -(a6)
0101a4a2  0101              btst.l   d0, d1
0101a4a4  3c83              move.w   d3, (a6)
0101a4a6  2200              move.l   d0, d1
0101a4a8  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a4ae  6b3c              bmi.b    $101a4ec
0101a4b0  2322              move.l   -(a2), -(a1)
0101a4b2  028001d00101      andi.l   #$1d00101, d0               ; $01d00101 = ROM
0101a4b8  77a6              dc.w     $77a6
0101a4ba  2222              move.l   -(a2), d1
0101a4bc  0226017c          andi.b   #$7c, -(a6)
0101a4c0  0101              btst.l   d0, d1
0101a4c2  3c5f              movea.w  (a7)+, a6
0101a4c4  2500              move.l   d0, -(a2)
0101a4c6  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a4cc  6b3c              bmi.b    $101a50a
0101a4ce  2601              move.l   d1, d3
0101a4d0  02a001c00101      andi.l   #$1c00101, -(a0)            ; $01c00101 = ROM
0101a4d6  760a              moveq    #$a, d3
0101a4d8  2722              move.l   -(a2), -(a3)
0101a4da  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a4e0  6b3c              bmi.b    $101a51e
0101a4e2  2801              move.l   d1, d4
0101a4e4  02a001c80101      andi.l   #$1c80101, -(a0)            ; $01c80101 = ROM
0101a4ea  765a              moveq    #$5a, d3
0101a4ec  2922              move.l   -(a2), -(a4)
0101a4ee  028001df0101      andi.l   #$1df0101, d0               ; $01df0101 = ROM
0101a4f4  6b3c              bmi.b    $101a532
0101a4f6  2a01              move.l   d1, d5
0101a4f8  02a001d00101      andi.l   #$1d00101, -(a0)            ; $01d00101 = ROM
0101a4fe  76aa              moveq    #$aa, d3
0101a500  2522              move.l   -(a2), -(a2)
0101a502  0101              btst.l   d0, d1
0101a504  329a              move.w   (a2)+, (a1)
0101a506  0101              btst.l   d0, d1
0101a508  a582              dc.w     $a582
0101a50a  0101              btst.l   d0, d1
0101a50c  a95c              dc.w     $a95c
0101a50e  0101              btst.l   d0, d1
0101a510  3cd4              move.w   (a4), (a6)+
0101a512  171b              move.b   (a3)+, -(a3)
0101a514  ffff              dc.w     $ffff
0101a516  0101              btst.l   d0, d1
0101a518  3cf80101          move.w   $101.w, (a6)+
0101a51c  a582              dc.w     $a582
0101a51e  0101              btst.l   d0, d1
0101a520  a95c              dc.w     $a95c
0101a522  0101              btst.l   d0, d1
0101a524  3cfb171bffff0101  move.w   ([$101a526pc, d1.w * 8], $ffff0101), (a6)+ ; $ffff0101 = NextBus slot space
0101a52c  3d27              move.w   -(a7), -(a6)
0101a52e  0101              btst.l   d0, d1
0101a530  b1cc              cmpa.l   a4, a0
0101a532  0101              btst.l   d0, d1
0101a534  b1b40101          eor.l    d0, ([a4, d0.w])
0101a538  3d2a1115          move.w   $1115(a2), -(a6)
0101a53c  ffff              dc.w     $ffff
0101a53e  0101              btst.l   d0, d1
0101a540  3d340101          move.w   ([a4, d0.w]), -(a6)
0101a544  b1cc              cmpa.l   a4, a0
0101a546  0101              btst.l   d0, d1
0101a548  b3760101          eor.w    d1, ([a6, d0.w])
0101a54c  3d37000e          move.w   $e(a7, d0.w), -(a6)
0101a550  040b              dc.w     $040b
0101a552  0101              btst.l   d0, d1
0101a554  35620101          move.w   -(a2), $101(a2)
0101a558  b1cc              cmpa.l   a4, a0
0101a55a  0101              btst.l   d0, d1
0101a55c  b3bc              dc.w     $b3bc
0101a55e  0101              btst.l   d0, d1
0101a560  3d441d21          move.w   d4, $1d21(a6)
0101a564  24ff              dc.w     $24ff
0101a566  00000000          ori.b    #$0, d0
0101a56a  00000000          ori.b    #$0, d0
0101a56e  00000000          ori.b    #$0, d0
0101a572  00000000          ori.b    #$0, d0
0101a576  00000000          ori.b    #$0, d0
0101a57a  0000ffff          ori.b    #$ff, d0
0101a57e  ffff              dc.w     $ffff
0101a580  ffff              dc.w     $ffff
0101a582  0100              btst.l   d0, d0
0101a584  69cc              bvs.b    $101a552
0101a586  0100              btst.l   d0, d0
0101a588  6a2e              bpl.b    $101a5b8
0101a58a  0100              btst.l   d0, d0
0101a58c  6a44              bpl.b    $101a5d2
0101a58e  00000000          ori.b    #$0, d0
0101a592  00000000          ori.b    #$0, d0
0101a596  9414              sub.b    (a4), d2
0101a598  020e              dc.w     $020e
0101a59a  0000dc0d          ori.b    #$d, d0
0101a59e  0305              btst.l   d1, d5
0101a5a0  f700              dc.w     $f700
0101a5a2  a614              dc.w     $a614
0101a5a4  0a0d              dc.w     $0a0d
0101a5a6  0000b012          ori.b    #$12, d0
0101a5aa  0910              btst.l   d4, (a0)
0101a5ac  0200b914          andi.b   #$14, d0
0101a5b0  0e0d              dc.w     $0e0d
0101a5b2  0000ce14          ori.b    #$14, d0
0101a5b6  0c0d              dc.w     $0c0d
0101a5b8  0000eb0d          ori.b    #$d, d0
0101a5bc  0205f700          andi.b   #$0, d5
0101a5c0  c300              abcd.b   d0, d1
0101a5c2  04120400          subi.b   #$0, (a2)
0101a5c6  c900              abcd.b   d0, d4
0101a5c8  04120400          subi.b   #$0, (a2)
0101a5cc  e21a              ror.b    #$1, d2
0101a5ce  0507              btst.l   d2, d7
0101a5d0  fa00da15          fmovem   d0, invalid
0101a5d4  080a              dc.w     $080a
0101a5d6  ff00              dc.w     $ff00
0101a5d8  e811              roxr.b   #$4, d1
0101a5da  02050300          andi.b   #$0, d5
0101a5de  00000000          ori.b    #$0, d0
0101a5e2  0000ed14          ori.b    #$14, d0
0101a5e6  02020000          andi.b   #$0, d2
0101a5ea  f014050e          fsin     fp1, fp2
0101a5ee  00003e14          ori.b    #$14, d0
0101a5f2  080d              dc.w     $080d
0101a5f4  00004614          ori.b    #$14, d0
0101a5f8  050d0000          movep.w  $0(a5), d2
0101a5fc  4b14              chk.l    (a4), d5
0101a5fe  080d              dc.w     $080d
0101a600  00005314          ori.b    #$14, d0
0101a604  080d              dc.w     $080d
0101a606  00005b14          ori.b    #$14, d0
0101a60a  090d0000          movep.w  $0(a5), d4
0101a60e  6414              bcc.b    $101a624
0101a610  080d              dc.w     $080d
0101a612  00006c14          ori.b    #$14, d0
0101a616  080d              dc.w     $080d
0101a618  00007414          ori.b    #$14, d0
0101a61c  080d              dc.w     $080d
0101a61e  00007c14          ori.b    #$14, d0
0101a622  080d              dc.w     $080d
0101a624  00008414          ori.b    #$14, d0
0101a628  080d              dc.w     $080d
0101a62a  0000e604          ori.b    #$4, d0
0101a62e  020a              dc.w     $020a
0101a630  0000e601          ori.b    #$1, d0
0101a634  020d              dc.w     $020d
0101a636  0300              btst.l   d1, d0
0101a638  e425              asr.b    d2, d5
0101a63a  0809              dc.w     $0809
0101a63c  fe000000          fmove    fp0, fp0
0101a640  00000000          ori.b    #$0, d0
0101a644  ec25              asr.b    d6, d5
0101a646  0809              dc.w     $0809
0101a648  fe00dd23          fmovem   d0, invalid
0101a64c  070e0000          movep.w  $0(a6), d3
0101a650  9612              sub.b    (a2), d3
0101a652  1010              move.b   (a0), d0
0101a654  0100              btst.l   d0, d0
0101a656  0123              btst.l   d0, -(a3)
0101a658  0c0e              dc.w     $0c0e
0101a65a  00000d23          ori.b    #$23, d0
0101a65e  0b0e0000          movep.w  $0(a6), d5
0101a662  1823              move.b   -(a3), d4
0101a664  0c0e              dc.w     $0c0e
0101a666  00002423          ori.b    #$23, d0
0101a66a  0b0e0000          movep.w  $0(a6), d5
0101a66e  2f23              move.l   -(a3), -(a7)
0101a670  090e0000          movep.w  $0(a6), d4
0101a674  3823              move.w   -(a3), d4
0101a676  090e0000          movep.w  $0(a6), d4
0101a67a  4123              chk.l    -(a3), d0
0101a67c  0c0e              dc.w     $0c0e
0101a67e  00004d23          ori.b    #$23, d0
0101a682  0b0e0000          movep.w  $0(a6), d5
0101a686  5823              addq.b   #$4, -(a3)
0101a688  020e              dc.w     $020e
0101a68a  00005a23          ori.b    #$23, d0
0101a68e  080e              dc.w     $080e
0101a690  00006223          ori.b    #$23, d0
0101a694  0c0e              dc.w     $0c0e
0101a696  00006e23          ori.b    #$23, d0
0101a69a  080e              dc.w     $080e
0101a69c  00007623          ori.b    #$23, d0
0101a6a0  0e0e              dc.w     $0e0e
0101a6a2  00008423          ori.b    #$23, d0
0101a6a6  0b0e0000          movep.w  $0(a6), d5
0101a6aa  8f23              or.b     d7, -(a3)
0101a6ac  0d0e0000          movep.w  $0(a6), d6
0101a6b0  9c23              sub.b    -(a3), d6
0101a6b2  0a0e              dc.w     $0a0e
0101a6b4  0000a622          ori.b    #$22, d0
0101a6b8  0d0f0100          movep.w  $100(a7), d6
0101a6bc  b323              eor.b    d1, -(a3)
0101a6be  0a0e              dc.w     $0a0e
0101a6c0  0000bd23          ori.b    #$23, d0
0101a6c4  0b0e0000          movep.w  $0(a6), d5
0101a6c8  c823              and.b    -(a3), d4
0101a6ca  0a0e              dc.w     $0a0e
0101a6cc  0000d223          ori.b    #$23, d0
0101a6d0  0b0e0000          movep.w  $0(a6), d5
0101a6d4  0114              btst.l   d0, (a4)
0101a6d6  0c0e              dc.w     $0c0e
0101a6d8  00000d14          ori.b    #$14, d0
0101a6dc  100e              dc.w     $100e
0101a6de  00001d14          ori.b    #$14, d0
0101a6e2  0b0e0000          movep.w  $0(a6), d5
0101a6e6  2814              move.l   (a4), d4
0101a6e8  0c0e              dc.w     $0c0e
0101a6ea  00003414          ori.b    #$14, d0
0101a6ee  0a0e              dc.w     $0a0e
0101a6f0  0000ef00          ori.b    #$0, d0
0101a6f4  04120400          subi.b   #$0, (a2)
0101a6f8  f804050e          fsin     fp1, fp2
0101a6fc  0000f300          ori.b    #$0, d0
0101a700  04120400          subi.b   #$0, (a2)
0101a704  c71d              and.b    d3, (a5)+
0101a706  0704              btst.l   d3, d4
0101a708  f700              dc.w     $f700
0101a70a  dc04              add.b    d4, d6
0101a70c  0901              btst.l   d4, d1
0101a70e  00000000          ori.b    #$0, d0
0101a712  00000000          ori.b    #$0, d0
0101a716  0104              btst.l   d0, d4
0101a718  070a0000          movep.w  $0(a2), d3
0101a71c  0804              dc.w     $0804
0101a71e  090e0000          movep.w  $0(a6), d4
0101a722  1104              move.b   d4, -(a0)
0101a724  080a              dc.w     $080a
0101a726  00001904          ori.b    #$4, d0
0101a72a  090e0000          movep.w  $0(a6), d4
0101a72e  2204              move.l   d4, d1
0101a730  080a              dc.w     $080a
0101a732  00002a04          ori.b    #$4, d0
0101a736  060e              dc.w     $060e
0101a738  00003000          ori.b    #$0, d0
0101a73c  090e0400          movep.w  $400(a6), d4
0101a740  3904              move.w   d4, -(a4)
0101a742  080e              dc.w     $080e
0101a744  00004304          ori.b    #$4, d0
0101a748  020e              dc.w     $020e
0101a74a  00004100          ori.b    #$0, d0
0101a74e  04120400          subi.b   #$0, (a2)
0101a752  4504              chk.l    d4, d2
0101a754  080e              dc.w     $080e
0101a756  00004d04          ori.b    #$4, d0
0101a75a  020e              dc.w     $020e
0101a75c  00004f04          ori.b    #$4, d0
0101a760  0c0a              dc.w     $0c0a
0101a762  00005b04          ori.b    #$4, d0
0101a766  080a              dc.w     $080a
0101a768  00006304          ori.b    #$4, d0
0101a76c  090a0000          movep.w  $0(a2), d4
0101a770  6c00090e          bge.w    tbl_console_backends
0101a774  04007500          subi.b   #$0, d0
0101a778  090e0400          movep.w  $400(a6), d4
0101a77c  7e04              moveq    #$4, d7
0101a77e  050a0000          movep.w  $0(a2), d2
0101a782  8304              sbcd.b   d4, d1
0101a784  070a0000          movep.w  $0(a2), d3
0101a788  8a04              or.b     d4, d5
0101a78a  060d              dc.w     $060d
0101a78c  00009004          ori.b    #$4, d0
0101a790  080a              dc.w     $080a
0101a792  00009804          ori.b    #$4, d0
0101a796  080a              dc.w     $080a
0101a798  0000a004          ori.b    #$4, d0
0101a79c  0c0a              dc.w     $0c0a
0101a79e  0000ac04          ori.b    #$4, d0
0101a7a2  080a              dc.w     $080a
0101a7a4  0000b400          ori.b    #$0, d0
0101a7a8  080e              dc.w     $080e
0101a7aa  0400bc04          subi.b   #$4, d0
0101a7ae  070a0000          movep.w  $0(a2), d3
0101a7b2  cd00              abcd.b   d0, d6
0101a7b4  06120400          addi.b   #$0, (a2)
0101a7b8  da00              add.b    d0, d5
0101a7ba  0112              btst.l   d0, (a2)
0101a7bc  0400d300          subi.b   #$0, d0
0101a7c0  06120400          addi.b   #$0, (a2)
0101a7c4  00000000          ori.b    #$0, d0
0101a7c8  00000000          ori.b    #$0, d0
0101a7cc  00000000          ori.b    #$0, d0
0101a7d0  00000000          ori.b    #$0, d0
0101a7d4  00000000          ori.b    #$0, d0
0101a7d8  00000000          ori.b    #$0, d0
0101a7dc  00000000          ori.b    #$0, d0
0101a7e0  00000000          ori.b    #$0, d0
0101a7e4  00000000          ori.b    #$0, d0
0101a7e8  00000000          ori.b    #$0, d0
0101a7ec  00000000          ori.b    #$0, d0
0101a7f0  00000000          ori.b    #$0, d0
0101a7f4  00000000          ori.b    #$0, d0
0101a7f8  00000000          ori.b    #$0, d0
0101a7fc  00000000          ori.b    #$0, d0
0101a800  00000000          ori.b    #$0, d0
0101a804  00000000          ori.b    #$0, d0
0101a808  00000000          ori.b    #$0, d0
0101a80c  00000000          ori.b    #$0, d0
0101a810  00000000          ori.b    #$0, d0
0101a814  00000000          ori.b    #$0, d0
0101a818  00000000          ori.b    #$0, d0
0101a81c  00000000          ori.b    #$0, d0
0101a820  00000000          ori.b    #$0, d0
0101a824  00000000          ori.b    #$0, d0
0101a828  00000000          ori.b    #$0, d0
0101a82c  00000000          ori.b    #$0, d0
0101a830  00000000          ori.b    #$0, d0
0101a834  00000000          ori.b    #$0, d0
0101a838  00000000          ori.b    #$0, d0
0101a83c  00000000          ori.b    #$0, d0
0101a840  00000000          ori.b    #$0, d0
0101a844  00000000          ori.b    #$0, d0
0101a848  00000000          ori.b    #$0, d0
0101a84c  00000000          ori.b    #$0, d0
0101a850  00000000          ori.b    #$0, d0
0101a854  00000000          ori.b    #$0, d0
0101a858  00000000          ori.b    #$0, d0
0101a85c  00000000          ori.b    #$0, d0
0101a860  00000000          ori.b    #$0, d0
0101a864  00000000          ori.b    #$0, d0
0101a868  00000000          ori.b    #$0, d0
0101a86c  00000000          ori.b    #$0, d0
0101a870  00000000          ori.b    #$0, d0
0101a874  00000000          ori.b    #$0, d0
0101a878  00000000          ori.b    #$0, d0
0101a87c  00000000          ori.b    #$0, d0
0101a880  00000000          ori.b    #$0, d0
0101a884  00000000          ori.b    #$0, d0
0101a888  00000000          ori.b    #$0, d0
0101a88c  00000000          ori.b    #$0, d0

; ---- gap 0101a8a1..0101ae8b (1515 bytes) ----
0101a8a1  00000000          ori.b    #$0, d0
0101a8a5  00001f00          ori.b    #$0, d0
0101a8a9  3b00              move.w   d0, -(a5)
0101a8ab  5a00              addq.b   #$5, d0
0101a8ad  7800              moveq    #$0, d4
0101a8af  9700              subx.b   d0, d3
0101a8b1  b500              eor.b    d2, d0
0101a8b3  d400              add.b    d0, d2
0101a8b5  f301              fsave    ea(0,1)
0101a8b7  1101              move.b   d1, -(a0)
0101a8b9  3001              move.w   d1, d0
0101a8bb  4e00              dc.w     $4e00
0101a8bd  8080              or.l     d0, d0
0101a8bf  008000008080      ori.l    #$8080, d0
0101a8c5  00008000          ori.b    #$0, d0
0101a8c9  8080              or.l     d0, d0
0101a8cb  008000008000      ori.l    #$8000, d0
0101a8d1  8080              or.l     d0, d0
0101a8d3  00008080          ori.b    #$80, d0
0101a8d7  008000008080      ori.l    #$8080, d0
0101a8dd  00008000          ori.b    #$0, d0
0101a8e1  8080              or.l     d0, d0
0101a8e3  00008080          ori.b    #$80, d0
0101a8e7  008000008000      ori.l    #$8000, d0
0101a8ed  8080              or.l     d0, d0
0101a8ef  008000008080      ori.l    #$8080, d0
0101a8f5  00008000          ori.b    #$0, d0
0101a8f9  8080              or.l     d0, d0
0101a8fb  008000008000      ori.l    #$8000, d0
0101a901  8080              or.l     d0, d0
0101a903  00008080          ori.b    #$80, d0
0101a907  008000008000      ori.l    #$8000, d0
0101a90d  8080              or.l     d0, d0
0101a90f  008000008080      ori.l    #$8080, d0
0101a915  00008000          ori.b    #$0, d0
0101a919  8080              or.l     d0, d0
0101a91b  00008080          ori.b    #$80, d0
0101a91f  008000008080      ori.l    #$8080, d0
0101a925  00008000          ori.b    #$0, d0
0101a929  8080              or.l     d0, d0
0101a92b  008000008000      ori.l    #$8000, d0
0101a931  8080              or.l     d0, d0
0101a933  00008080          ori.b    #$80, d0
0101a937  008000008000      ori.l    #$8000, d0
0101a93d  3836a000          move.w   (a6, a2.w), d4
0101a941  3d09              move.w   a1, -(a6)
0101a943  0001008d          ori.b    #$8d, d1
0101a947  6801              bvc.b    $101a94a
0101a949  008d              dc.w     $008d
0101a94b  6801              bvc.b    $101a94e
0101a94d  008c              dc.w     $008c
0101a94f  7201              moveq    #$1, d1
0101a951  008c              dc.w     $008c
0101a953  f400              dc.w     $f400
0101a955  00000000          ori.b    #$0, d0
0101a959  00000001          ori.b    #$1, d0
0101a95d  008e              dc.w     $008e
0101a95f  5e01              addq.b   #$7, d1
0101a961  0095b2010091      ori.l    #$b2010091, (a5)
0101a967  1601              move.b   d1, d3
0101a969  00928a01008e      ori.l    #$8a01008e, (a2)
0101a96f  5600              addq.b   #$3, d0
0101a971  000001ff          ori.b    #$ff, d0
0101a975  ffff              dc.w     $ffff
0101a977  00010001          ori.b    #$1, d1
0101a97b  00010101          ori.b    #$1, d1
0101a97f  0101              btst.l   d0, d1
0101a981  02010200          andi.b   #$0, d1
0101a985  5c00              addq.b   #$6, d0
0101a987  7c00              moveq    #$0, d6
0101a989  5d00              subq.b   #$6, d0
0101a98b  7d00              dc.w     $7d00
0101a98d  5b00              subq.b   #$5, d0
0101a98f  7b00              dc.w     $7b00
0101a991  69004900          bvs.w    $101f293
0101a995  6f004f00          ble.w    $101f897
0101a999  7000              moveq    #$0, d0
0101a99b  5001              addq.b   #$8, d1
0101a99d  0301              btst.l   d1, d1
0101a99f  0301              btst.l   d1, d1
0101a9a1  00010000          ori.b    #$0, d1
0101a9a5  3000              move.w   d0, d0
0101a9a7  3000              move.w   d0, d0
0101a9a9  2e00              move.l   d0, d7
0101a9ab  2e00              move.l   d0, d7
0101a9ad  0d00              btst.l   d6, d0
0101a9af  0d01              btst.l   d6, d1
0101a9b1  00010001          ori.b    #$1, d1
0101a9b5  04010401          subi.b   #$1, d1
0101a9b9  0501              btst.l   d2, d1
0101a9bb  0500              btst.l   d2, d0
0101a9bd  3100              move.w   d0, -(a0)
0101a9bf  3100              move.w   d0, -(a0)
0101a9c1  3400              move.w   d0, d2
0101a9c3  3400              move.w   d0, d2
0101a9c5  3600              move.w   d0, d3
0101a9c7  3600              move.w   d0, d3
0101a9c9  3300              move.w   d0, -(a1)
0101a9cb  3300              move.w   d0, -(a1)
0101a9cd  2b00              move.l   d0, -(a5)
0101a9cf  2b01              move.l   d1, -(a5)
0101a9d1  06010600          addi.b   #$0, d1
0101a9d5  3200              move.w   d0, d1
0101a9d7  3200              move.w   d0, d1
0101a9d9  3500              move.w   d0, -(a2)
0101a9db  3501              move.w   d1, -(a2)
0101a9dd  0701              btst.l   d3, d1
0101a9df  0701              btst.l   d3, d1
0101a9e1  0801              dc.w     $0801
0101a9e3  0800              dc.w     $0800
0101a9e5  7f00              dc.w     $7f00
0101a9e7  0800              dc.w     $0800
0101a9e9  3d00              move.w   d0, -(a6)
0101a9eb  2b00              move.l   d0, -(a5)
0101a9ed  2d00              move.l   d0, -(a6)
0101a9ef  5f00              subq.b   #$7, d0
0101a9f1  3800              move.w   d0, d4
0101a9f3  2a00              move.l   d0, d5
0101a9f5  3900              move.w   d0, -(a4)
0101a9f7  2800              move.l   d0, d4
0101a9f9  3000              move.w   d0, d0
0101a9fb  2900              move.l   d0, -(a4)
0101a9fd  3700              move.w   d0, -(a3)
0101a9ff  3700              move.w   d0, -(a3)
0101aa01  3800              move.w   d0, d4
0101aa03  3800              move.w   d0, d4
0101aa05  3900              move.w   d0, -(a4)
0101aa07  3900              move.w   d0, -(a4)
0101aa09  2d00              move.l   d0, -(a6)
0101aa0b  2d00              move.l   d0, -(a6)
0101aa0d  2a00              move.l   d0, d5
0101aa0f  2a00              move.l   d0, d5
0101aa11  60007e00          bra.w    $1022813                    ; $01022813 = ROM
0101aa15  3d00              move.w   d0, -(a6)
0101aa17  7c00              moveq    #$0, d6
0101aa19  2f00              move.l   d0, -(a7)
0101aa1b  5c01              addq.b   #$6, d1
0101aa1d  00010000          ori.b    #$0, d1
0101aa21  0d00              btst.l   d6, d0
0101aa23  0d00              btst.l   d6, d0
0101aa25  2700              move.l   d0, -(a3)
0101aa27  2200              move.l   d0, d1
0101aa29  3b00              move.w   d0, -(a5)
0101aa2b  3a00              move.w   d0, d5
0101aa2d  6c004c00          bge.w    $101f62f
0101aa31  2c00              move.l   d0, d6
0101aa33  3c00              move.w   d0, d6
0101aa35  2e00              move.l   d0, d7
0101aa37  3e00              move.w   d0, d7
0101aa39  2f00              move.l   d0, -(a7)
0101aa3b  3f00              move.w   d0, -(a7)
0101aa3d  7a00              moveq    #$0, d5
0101aa3f  5a00              addq.b   #$5, d0
0101aa41  7800              moveq    #$0, d4
0101aa43  5800              addq.b   #$4, d0
0101aa45  63004300          bls.w    $101ed47
0101aa49  7600              moveq    #$0, d3
0101aa4b  5600              addq.b   #$3, d0
0101aa4d  62004200          bhi.w    $101ec4f
0101aa51  6d004d00          blt.w    $101f753
0101aa55  6e004e00          bgt.w    $101f857
0101aa59  2000              move.l   d0, d0
0101aa5b  2000              move.l   d0, d0
0101aa5d  61004100          bsr.w    $101eb5f
0101aa61  7300              dc.w     $7300
0101aa63  5300              subq.b   #$1, d0
0101aa65  64004400          bcc.w    $101ee67
0101aa69  66004600          bne.w    $101f06b
0101aa6d  67004700          beq.w    $101f16f
0101aa71  6b004b00          bmi.w    $101f573
0101aa75  6a004a00          bpl.w    $101f477
0101aa79  68004800          bvc.w    $101f27b
0101aa7d  0900              btst.l   d4, d0
0101aa7f  0900              btst.l   d4, d0
0101aa81  7100              dc.w     $7100
0101aa83  5100              subq.b   #$8, d0
0101aa85  7700              dc.w     $7700
0101aa87  5700              subq.b   #$3, d0
0101aa89  65004500          bcs.w    $101ef8b
0101aa8d  7200              moveq    #$0, d1
0101aa8f  5200              addq.b   #$1, d0
0101aa91  7500              dc.w     $7500
0101aa93  5500              subq.b   #$2, d0
0101aa95  7900              dc.w     $7900
0101aa97  5900              subq.b   #$4, d0
0101aa99  7400              moveq    #$0, d2
0101aa9b  5400              addq.b   #$2, d0
0101aa9d  1b00              move.b   d0, -(a5)
0101aa9f  7e00              moveq    #$0, d7
0101aaa1  3100              move.w   d0, -(a0)
0101aaa3  2100              move.l   d0, -(a0)
0101aaa5  3200              move.w   d0, d1
0101aaa7  4000              negx.b   d0
0101aaa9  3300              move.w   d0, -(a1)
0101aaab  2300              move.l   d0, -(a1)
0101aaad  3400              move.w   d0, d2
0101aaaf  2400              move.l   d0, d2
0101aab1  3700              move.w   d0, -(a3)
0101aab3  2600              move.l   d0, d3
0101aab5  3600              move.w   d0, d3
0101aab7  5e00              addq.b   #$7, d0
0101aab9  3500              move.w   d0, -(a2)
0101aabb  2501              move.l   d1, -(a2)
0101aabd  00010001          ori.b    #$1, d1
0101aac1  0101              btst.l   d0, d1
0101aac3  0101              btst.l   d0, d1
0101aac5  02010200          andi.b   #$0, d1
0101aac9  1c00              move.b   d0, d6
0101aacb  1c00              move.b   d0, d6
0101aacd  1d00              move.b   d0, -(a6)
0101aacf  1d00              move.b   d0, -(a6)
0101aad1  1b00              move.b   d0, -(a5)
0101aad3  1b00              move.b   d0, -(a5)
0101aad5  0900              btst.l   d4, d0
0101aad7  0900              btst.l   d4, d0
0101aad9  0f00              btst.l   d7, d0
0101aadb  0f00              btst.l   d7, d0
0101aadd  1000              move.b   d0, d0
0101aadf  1001              move.b   d1, d0
0101aae1  0301              btst.l   d1, d1
0101aae3  0301              btst.l   d1, d1
0101aae5  00010000          ori.b    #$0, d1
0101aae9  3000              move.w   d0, d0
0101aaeb  3000              move.w   d0, d0
0101aaed  2e00              move.l   d0, d7
0101aaef  2e00              move.l   d0, d7
0101aaf1  0d00              btst.l   d6, d0
0101aaf3  0d01              btst.l   d6, d1
0101aaf5  00010001          ori.b    #$1, d1
0101aaf9  04010401          subi.b   #$1, d1
0101aafd  0501              btst.l   d2, d1
0101aaff  0500              btst.l   d2, d0
0101ab01  3100              move.w   d0, -(a0)
0101ab03  3100              move.w   d0, -(a0)
0101ab05  3400              move.w   d0, d2
0101ab07  3400              move.w   d0, d2
0101ab09  3600              move.w   d0, d3
0101ab0b  3600              move.w   d0, d3
0101ab0d  3300              move.w   d0, -(a1)
0101ab0f  3300              move.w   d0, -(a1)
0101ab11  2b00              move.l   d0, -(a5)
0101ab13  2b01              move.l   d1, -(a5)
0101ab15  06010600          addi.b   #$0, d1
0101ab19  3200              move.w   d0, d1
0101ab1b  3200              move.w   d0, d1
0101ab1d  3500              move.w   d0, -(a2)
0101ab1f  3501              move.w   d1, -(a2)
0101ab21  0701              btst.l   d3, d1
0101ab23  0701              btst.l   d3, d1
0101ab25  0801              dc.w     $0801
0101ab27  08010001          btst.b   #$1, d1
0101ab2b  00003d00          ori.b    #$0, d0
0101ab2f  2b00              move.l   d0, -(a5)
0101ab31  1f00              move.b   d0, -(a7)
0101ab33  1f00              move.b   d0, -(a7)
0101ab35  3800              move.w   d0, d4
0101ab37  2a00              move.l   d0, d5
0101ab39  3900              move.w   d0, -(a4)
0101ab3b  2800              move.l   d0, d4
0101ab3d  3000              move.w   d0, d0
0101ab3f  2900              move.l   d0, -(a4)
0101ab41  3700              move.w   d0, -(a3)
0101ab43  3700              move.w   d0, -(a3)
0101ab45  3800              move.w   d0, d4
0101ab47  3800              move.w   d0, d4
0101ab49  3900              move.w   d0, -(a4)
0101ab4b  3900              move.w   d0, -(a4)
0101ab4d  2d00              move.l   d0, -(a6)
0101ab4f  2d00              move.l   d0, -(a6)
0101ab51  2a00              move.l   d0, d5
0101ab53  2a00              move.l   d0, d5
0101ab55  60007e00          bra.w    $1022957                    ; $01022957 = ROM
0101ab59  3d00              move.w   d0, -(a6)
0101ab5b  1c00              move.b   d0, d6
0101ab5d  2f00              move.l   d0, -(a7)
0101ab5f  1c01              move.b   d1, d6
0101ab61  00010000          ori.b    #$0, d1
0101ab65  0d00              btst.l   d6, d0
0101ab67  0d00              btst.l   d6, d0
0101ab69  2700              move.l   d0, -(a3)
0101ab6b  2200              move.l   d0, d1
0101ab6d  3b00              move.w   d0, -(a5)
0101ab6f  3a00              move.w   d0, d5
0101ab71  0c000c00          cmpi.b   #$0, d0
0101ab75  2c00              move.l   d0, d6
0101ab77  3c00              move.w   d0, d6
0101ab79  2e00              move.l   d0, d7
0101ab7b  3e00              move.w   d0, d7
0101ab7d  2f00              move.l   d0, -(a7)
0101ab7f  3f00              move.w   d0, -(a7)
0101ab81  1a00              move.b   d0, d5
0101ab83  1a00              move.b   d0, d5
0101ab85  1800              move.b   d0, d4
0101ab87  1800              move.b   d0, d4
0101ab89  0300              btst.l   d1, d0
0101ab8b  0300              btst.l   d1, d0
0101ab8d  1600              move.b   d0, d3
0101ab8f  1600              move.b   d0, d3
0101ab91  02000200          andi.b   #$0, d0
0101ab95  0d00              btst.l   d6, d0
0101ab97  0d00              btst.l   d6, d0
0101ab99  0e00              dc.w     $0e00
0101ab9b  0e00              dc.w     $0e00
0101ab9d  00000000          ori.b    #$0, d0
0101aba1  0100              btst.l   d0, d0
0101aba3  0100              btst.l   d0, d0
0101aba5  1300              move.b   d0, -(a1)
0101aba7  1300              move.b   d0, -(a1)
0101aba9  04000400          subi.b   #$0, d0
0101abad  06000600          addi.b   #$0, d0
0101abb1  0700              btst.l   d3, d0
0101abb3  0700              btst.l   d3, d0
0101abb5  0b00              btst.l   d5, d0
0101abb7  0b00              btst.l   d5, d0
0101abb9  0a000a00          eori.b   #$0, d0
0101abbd  0800              dc.w     $0800
0101abbf  0800              dc.w     $0800
0101abc1  0900              btst.l   d4, d0
0101abc3  0900              btst.l   d4, d0
0101abc5  1100              move.b   d0, -(a0)
0101abc7  1100              move.b   d0, -(a0)
0101abc9  1700              move.b   d0, -(a3)
0101abcb  1700              move.b   d0, -(a3)
0101abcd  0500              btst.l   d2, d0
0101abcf  0500              btst.l   d2, d0
0101abd1  1200              move.b   d0, d1
0101abd3  1200              move.b   d0, d1
0101abd5  1500              move.b   d0, -(a2)
0101abd7  1500              move.b   d0, -(a2)
0101abd9  1900              move.b   d0, -(a4)
0101abdb  1900              move.b   d0, -(a4)
0101abdd  1400              move.b   d0, d2
0101abdf  1400              move.b   d0, d2
0101abe1  1b00              move.b   d0, -(a5)
0101abe3  7e00              moveq    #$0, d7
0101abe5  3100              move.w   d0, -(a0)
0101abe7  2100              move.l   d0, -(a0)
0101abe9  00000000          ori.b    #$0, d0
0101abed  3300              move.w   d0, -(a1)
0101abef  2300              move.l   d0, -(a1)
0101abf1  3400              move.w   d0, d2
0101abf3  2400              move.l   d0, d2
0101abf5  3700              move.w   d0, -(a3)
0101abf7  2600              move.l   d0, d3
0101abf9  1e00              move.b   d0, d7
0101abfb  1e00              move.b   d0, d7
0101abfd  3500              move.w   d0, -(a2)
0101abff  2500              move.l   d0, -(a2)
0101ac01  00000000          ori.b    #$0, d0
0101ac05  00000000          ori.b    #$0, d0
0101ac09  00000020          ori.b    #$20, d0
0101ac0d  2020              move.l   -(a0), d0
0101ac0f  2020              move.l   -(a0), d0
0101ac11  2000              move.l   d0, d0
0101ac13  2000              move.l   d0, d0
0101ac15  00000050          ori.b    #$50, d0
0101ac19  5000              addq.b   #$8, d0
0101ac1b  00000000          ori.b    #$0, d0
0101ac1f  00000000          ori.b    #$0, d0
0101ac23  00005050          ori.b    #$50, d0
0101ac27  f850f850          fsf.b    (a0)
0101ac2b  5000              addq.b   #$8, d0
0101ac2d  00000020          ori.b    #$20, d0
0101ac31  70a8              moveq    #$a8, d0
0101ac33  a070              dc.w     $a070
0101ac35  28a87020          move.l   $7020(a0), (a4)
0101ac39  00000044          ori.b    #$44, d0
0101ac3d  a4a8              dc.w     $a4a8
0101ac3f  50285494          addq.b   #$8, $5494(a0)
0101ac43  8800              or.b     d0, d4
0101ac45  00000060          ori.b    #$60, d0
0101ac49  9080              sub.l    d0, d0
0101ac4b  40a0              negx.l   -(a0)
0101ac4d  9488              sub.l    a0, d2
0101ac4f  7400              moveq    #$0, d2
0101ac51  00000020          ori.b    #$20, d0
0101ac55  2040              movea.l  d0, a0
0101ac57  00000000          ori.b    #$0, d0
0101ac5b  00000000          ori.b    #$0, d0
0101ac5f  00102020          ori.b    #$20, (a0)
0101ac63  4040              negx.w   d0
0101ac65  4040              negx.w   d0
0101ac67  2020              move.l   -(a0), d0
0101ac69  1000              move.b   d0, d0
0101ac6b  00402020          ori.w    #$2020, d0
0101ac6f  1010              move.b   (a0), d0
0101ac71  1010              move.b   (a0), d0
0101ac73  2020              move.l   -(a0), d0
0101ac75  4000              negx.b   d0
0101ac77  0020a870          ori.b    #$70, -(a0)
0101ac7b  70a8              moveq    #$a8, d0
0101ac7d  2000              move.l   d0, d0
0101ac7f  00000000          ori.b    #$0, d0
0101ac83  00000020          ori.b    #$20, d0
0101ac87  20f82020          move.l   $2020.w, (a0)+
0101ac8b  00000000          ori.b    #$0, d0
0101ac8f  00000000          ori.b    #$0, d0
0101ac93  00000000          ori.b    #$0, d0
0101ac97  1020              move.b   -(a0), d0
0101ac99  00000000          ori.b    #$0, d0
0101ac9d  000000f8          ori.b    #$f8, d0
0101aca1  00000000          ori.b    #$0, d0
0101aca5  00000000          ori.b    #$0, d0
0101aca9  00000000          ori.b    #$0, d0
0101acad  00002000          ori.b    #$0, d0
0101acb1  00000008          ori.b    #$8, d0
0101acb5  0810              dc.w     $0810
0101acb7  1020              move.b   -(a0), d0
0101acb9  2040              movea.l  d0, a0
0101acbb  4000              negx.b   d0
0101acbd  00000070          ori.b    #$70, d0
0101acc1  8898              or.l     (a0)+, d4
0101acc3  a8c8              dc.w     $a8c8
0101acc5  8888              dc.w     $8888
0101acc7  7000              moveq    #$0, d0
0101acc9  00000020          ori.b    #$20, d0
0101accd  60a0              bra.b    $101ac6f
0101accf  2020              move.l   -(a0), d0
0101acd1  2020              move.l   -(a0), d0
0101acd3  f8000000          fmove    fp0, fp0
0101acd7  007088081020      ori.w    #$8808, $20(a0, d1.w)
0101acdd  4080              negx.l   d0
0101acdf  f8000000          fmove    fp0, fp0
0101ace3  007088083008      ori.w    #$8808, $8(a0, d3.w)
0101ace9  0888              dc.w     $0888
0101aceb  7000              moveq    #$0, d0
0101aced  00000010          ori.b    #$10, d0
0101acf1  3050              movea.w  (a0), a0
0101acf3  90f81010          suba.w   $1010.w, a0
0101acf7  1000              move.b   d0, d0
0101acf9  000000f8          ori.b    #$f8, d0
0101acfd  8080              or.l     d0, d0
0101acff  f0880808          fbf.w    $101b509
0101ad03  f0000000          fmove    fp0, fp0
0101ad07  00304080f088      ori.b    #$80, -$78(a0, a7.w)
0101ad0d  8888              dc.w     $8888
0101ad0f  7000              moveq    #$0, d0
0101ad11  000000f8          ori.b    #$f8, d0
0101ad15  8808              dc.w     $8808
0101ad17  1010              move.b   (a0), d0
0101ad19  2020              move.l   -(a0), d0
0101ad1b  2000              move.l   d0, d0
0101ad1d  00000070          ori.b    #$70, d0
0101ad21  8888              dc.w     $8888
0101ad23  7088              moveq    #$88, d0
0101ad25  8888              dc.w     $8888
0101ad27  7000              moveq    #$0, d0
0101ad29  00000070          ori.b    #$70, d0
0101ad2d  8888              dc.w     $8888
0101ad2f  88780810          or.w     $810.w, d4
0101ad33  60000000          bra.w    $101ad35
0101ad37  00000020          ori.b    #$20, d0
0101ad3b  00000000          ori.b    #$0, d0
0101ad3f  2000              move.l   d0, d0
0101ad41  00000000          ori.b    #$0, d0
0101ad45  00200000          ori.b    #$0, -(a0)
0101ad49  00002040          ori.b    #$40, d0
0101ad4d  00000000          ori.b    #$0, d0
0101ad51  0008              dc.w     $0008
0101ad53  30c0              move.w   d0, (a0)+
0101ad55  3008              move.w   a0, d0
0101ad57  00000000          ori.b    #$0, d0
0101ad5b  00000000          ori.b    #$0, d0
0101ad5f  f800f800          fmovem   invalid, d0
0101ad63  00000000          ori.b    #$0, d0
0101ad67  00000080          ori.b    #$80, d0
0101ad6b  6018              bra.b    $101ad85
0101ad6d  6080              bra.b    $101acef
0101ad6f  00000000          ori.b    #$0, d0
0101ad73  007088880810      ori.w    #$8888, $10(a0, d0.l)
0101ad79  2000              move.l   d0, d0
0101ad7b  2000              move.l   d0, d0
0101ad7d  00000030          ori.b    #$30, d0
0101ad81  4898              dc.w     $4898
0101ad83  a8a8              dc.w     $a8a8
0101ad85  a898              dc.w     $a898
0101ad87  40380000          negx.b   $0.w
0101ad8b  00202020          ori.b    #$20, -(a0)
0101ad8f  5050              addq.w   #$8, (a0)
0101ad91  f8888800          fbf.w    $1013593
0101ad95  000000f0          ori.b    #$f0, d0
0101ad99  8888              dc.w     $8888
0101ad9b  f0888888          fbf.w    $1013625
0101ad9f  f0000000          fmove    fp0, fp0
0101ada3  007088808080      ori.w    #$8880, -$80(a0, a0.w)
0101ada9  8088              dc.w     $8088
0101adab  7000              moveq    #$0, d0
0101adad  000000e0          ori.b    #$e0, d0
0101adb1  9088              sub.l    a0, d0
0101adb3  8888              dc.w     $8888
0101adb5  8890              or.l     (a0), d4
0101adb7  e000              asr.b    #$8, d0
0101adb9  000000f8          ori.b    #$f8, d0
0101adbd  8080              or.l     d0, d0
0101adbf  f0808080          fbf.w    $1012e41
0101adc3  f8000000          fmove    fp0, fp0
0101adc7  00f8              dc.w     $00f8
0101adc9  8080              or.l     d0, d0
0101adcb  f0808080          fbf.w    $1012e4d
0101adcf  8000              or.b     d0, d0
0101add1  00000070          ori.b    #$70, d0
0101add5  8880              or.l     d0, d4
0101add7  8098              or.l     (a0)+, d0
0101add9  8888              dc.w     $8888
0101addb  7000              moveq    #$0, d0
0101addd  00000088          ori.b    #$88, d0
0101ade1  8888              dc.w     $8888
0101ade3  f8888888          fbf.w    $101366d
0101ade7  8800              or.b     d0, d4
0101ade9  00000070          ori.b    #$70, d0
0101aded  2020              move.l   -(a0), d0
0101adef  2020              move.l   -(a0), d0
0101adf1  2020              move.l   -(a0), d0
0101adf3  7000              moveq    #$0, d0
0101adf5  00000008          ori.b    #$8, d0
0101adf9  0808              dc.w     $0808
0101adfb  0808              dc.w     $0808
0101adfd  8888              dc.w     $8888
0101adff  7000              moveq    #$0, d0
0101ae01  00000088          ori.b    #$88, d0
0101ae05  90a0              sub.l    -(a0), d0
0101ae07  c0c0              mulu.w   d0, d0
0101ae09  a090              dc.w     $a090
0101ae0b  8800              or.b     d0, d4
0101ae0d  00000080          ori.b    #$80, d0
0101ae11  8080              or.l     d0, d0
0101ae13  8080              or.l     d0, d0
0101ae15  8080              or.l     d0, d0
0101ae17  f8000000          fmove    fp0, fp0
0101ae1b  0088              dc.w     $0088
0101ae1d  d8d8              adda.w   (a0)+, a4
0101ae1f  a888              dc.w     $a888
0101ae21  8888              dc.w     $8888
0101ae23  8800              or.b     d0, d4
0101ae25  00000088          ori.b    #$88, d0
0101ae29  c8c8              dc.w     $c8c8
0101ae2b  a8a8              dc.w     $a8a8
0101ae2d  9898              sub.l    (a0)+, d4
0101ae2f  8800              or.b     d0, d4
0101ae31  00000070          ori.b    #$70, d0
0101ae35  8888              dc.w     $8888
0101ae37  8888              dc.w     $8888
0101ae39  8888              dc.w     $8888
0101ae3b  7000              moveq    #$0, d0
0101ae3d  000000f0          ori.b    #$f0, d0
0101ae41  8888              dc.w     $8888
0101ae43  88f08080          divu.w   -$80(a0, a0.w), d4
0101ae47  8000              or.b     d0, d0
0101ae49  00000070          ori.b    #$70, d0
0101ae4d  8888              dc.w     $8888
0101ae4f  8888              dc.w     $8888
0101ae51  8888              dc.w     $8888
0101ae53  7010              moveq    #$10, d0
0101ae55  0c0000f0          cmpi.b   #$f0, d0
0101ae59  8888              dc.w     $8888
0101ae5b  88f0a090          divu.w   -$70(a0, a2.w), d4
0101ae5f  8800              or.b     d0, d4
0101ae61  00000070          ori.b    #$70, d0
0101ae65  8880              or.l     d0, d4
0101ae67  7008              moveq    #$8, d0
0101ae69  0888              dc.w     $0888
0101ae6b  7000              moveq    #$0, d0
0101ae6d  000000f8          ori.b    #$f8, d0
0101ae71  2020              move.l   -(a0), d0
0101ae73  2020              move.l   -(a0), d0
0101ae75  2020              move.l   -(a0), d0
0101ae77  2000              move.l   d0, d0
0101ae79  00000088          ori.b    #$88, d0
0101ae7d  8888              dc.w     $8888
0101ae7f  8888              dc.w     $8888
0101ae81  8888              dc.w     $8888
0101ae83  7000              moveq    #$0, d0
0101ae85  00000088          ori.b    #$88, d0
0101ae89  8888              dc.w     $8888
0101ae8b  8850              dc.w     $8850

; ---- gap 0101ae91..0101aead (29 bytes) ----
0101ae91  00000088          ori.b    #$88, d0
0101ae95  88a8a8a8          or.l     -$5758(a0), d4
0101ae99  5050              addq.w   #$8, (a0)
0101ae9b  5000              addq.b   #$8, d0
0101ae9d  00000088          ori.b    #$88, d0
0101aea1  8850              or.w     (a0), d4
0101aea3  2020              move.l   -(a0), d0
0101aea5  5088              addq.l   #$8, a0
0101aea7  8800              or.b     d0, d4
0101aea9  00000088          ori.b    #$88, d0
0101aead  8850              dc.w     $8850

; ---- gap 0101aeb5..0101b00b (343 bytes) ----
0101aeb5  000000f8          ori.b    #$f8, d0
0101aeb9  0810              dc.w     $0810
0101aebb  2020              move.l   -(a0), d0
0101aebd  4080              negx.l   d0
0101aebf  f8000000          fmove    fp0, fp0
0101aec3  007040404040      ori.w    #$4040, $40(a0, d4.w)
0101aec9  4040              negx.w   d0
0101aecb  4040              negx.w   d0
0101aecd  7000              moveq    #$0, d0
0101aecf  00404020          ori.w    #$4020, d0
0101aed3  2010              move.l   (a0), d0
0101aed5  1008              dc.w     $1008
0101aed7  08000000          btst.b   #$0, d0
0101aedb  003010101010      ori.b    #$10, $10(a0, d1.w)
0101aee1  1010              move.b   (a0), d0
0101aee3  1010              move.b   (a0), d0
0101aee5  3000              move.w   d0, d0
0101aee7  00205088          ori.b    #$88, -(a0)
0101aeeb  00000000          ori.b    #$0, d0
0101aeef  00000000          ori.b    #$0, d0
0101aef3  00000000          ori.b    #$0, d0
0101aef7  00000000          ori.b    #$0, d0
0101aefb  0000fc00          ori.b    #$0, d0
0101aeff  00201000          ori.b    #$0, -(a0)
0101af03  00000000          ori.b    #$0, d0
0101af07  00000000          ori.b    #$0, d0
0101af0b  00000070          ori.b    #$70, d0
0101af0f  88788888          or.w     $8888.w, d4
0101af13  7800              moveq    #$0, d4
0101af15  00000080          ori.b    #$80, d0
0101af19  80f08888          divu.w   -$78(a0, a0.l), d0
0101af1d  8888              dc.w     $8888
0101af1f  f0000000          fmove    fp0, fp0
0101af23  00000070          ori.b    #$70, d0
0101af27  8880              or.l     d0, d4
0101af29  8088              dc.w     $8088
0101af2b  7000              moveq    #$0, d0
0101af2d  00000008          ori.b    #$8, d0
0101af31  0878              dc.w     $0878
0101af33  8888              dc.w     $8888
0101af35  8888              dc.w     $8888
0101af37  7800              moveq    #$0, d4
0101af39  00000000          ori.b    #$0, d0
0101af3d  007088f88088      ori.w    #$88f8, -$78(a0, a0.w)
0101af43  7000              moveq    #$0, d0
0101af45  00000018          ori.b    #$18, d0
0101af49  20782020          movea.l  $2020.w, a0
0101af4d  2020              move.l   -(a0), d0
0101af4f  2000              move.l   d0, d0
0101af51  00000000          ori.b    #$0, d0
0101af55  007888888888      ori.w    #$8888, $8888.w
0101af5b  7808              moveq    #$8, d4
0101af5d  7000              moveq    #$0, d0
0101af5f  008080f08888      ori.l    #$80f08888, d0
0101af65  8888              dc.w     $8888
0101af67  8800              or.b     d0, d4
0101af69  00000020          ori.b    #$20, d0
0101af6d  00e0              dc.w     $00e0
0101af6f  2020              move.l   -(a0), d0
0101af71  2020              move.l   -(a0), d0
0101af73  f8000000          fmove    fp0, fp0
0101af77  0008              dc.w     $0008
0101af79  003808080808      ori.b    #$8, $808.w
0101af7f  0808              dc.w     $0808
0101af81  7000              moveq    #$0, d0
0101af83  00808090a0c0      ori.l    #$8090a0c0, d0
0101af89  a090              dc.w     $a090
0101af8b  8800              or.b     d0, d4
0101af8d  00000060          ori.b    #$60, d0
0101af91  2020              move.l   -(a0), d0
0101af93  2020              move.l   -(a0), d0
0101af95  2020              move.l   -(a0), d0
0101af97  f8000000          fmove    fp0, fp0
0101af9b  000000d0          ori.b    #$d0, d0
0101af9f  a8a8              dc.w     $a8a8
0101afa1  a8a8              dc.w     $a8a8
0101afa3  a800              dc.w     $a800
0101afa5  00000000          ori.b    #$0, d0
0101afa9  00b0c88888888800  ori.l    #$c8888888, (a0, a0.l)
0101afb1  00000000          ori.b    #$0, d0
0101afb5  007088888888      ori.w    #$8888, -$78(a0, a0.l)
0101afbb  7000              moveq    #$0, d0
0101afbd  00000000          ori.b    #$0, d0
0101afc1  00f0              dc.w     $00f0
0101afc3  8888              dc.w     $8888
0101afc5  8888              dc.w     $8888
0101afc7  f0808000          fbf.w    $1012fc9
0101afcb  00000078          ori.b    #$78, d0
0101afcf  8888              dc.w     $8888
0101afd1  8888              dc.w     $8888
0101afd3  7808              moveq    #$8, d4
0101afd5  08000000          btst.b   #$0, d0
0101afd9  00d8              dc.w     $00d8
0101afdb  6040              bra.b    $101b01d
0101afdd  4040              negx.w   d0
0101afdf  e000              asr.b    #$8, d0
0101afe1  00000000          ori.b    #$0, d0
0101afe5  007088700888      ori.w    #$8870, -$78(a0, d0.l)
0101afeb  7000              moveq    #$0, d0
0101afed  00000040          ori.b    #$40, d0
0101aff1  40f04040          move.w   sr, $40(a0, d4.w)
0101aff5  4048              dc.w     $4048
0101aff7  3000              move.w   d0, d0
0101aff9  00000000          ori.b    #$0, d0
0101affd  0088              dc.w     $0088
0101afff  8888              dc.w     $8888
0101b001  8898              or.l     (a0)+, d4
0101b003  68000000          bvc.w    $101b005
0101b007  00000088          ori.b    #$88, d0
0101b00b  8850              dc.w     $8850

; ---- gap 0101b011..0101b33f (815 bytes) ----
0101b011  00000000          ori.b    #$0, d0
0101b015  0088              dc.w     $0088
0101b017  88a8a850          or.l     -$57b0(a0), d4
0101b01b  5000              addq.b   #$8, d0
0101b01d  00000000          ori.b    #$0, d0
0101b021  0088              dc.w     $0088
0101b023  5020              addq.b   #$8, -(a0)
0101b025  2050              movea.l  (a0), a0
0101b027  8800              or.b     d0, d4
0101b029  00000000          ori.b    #$0, d0
0101b02d  0088              dc.w     $0088
0101b02f  8850              or.w     (a0), d4
0101b031  5020              addq.b   #$8, -(a0)
0101b033  2040              movea.l  d0, a0
0101b035  8000              or.b     d0, d0
0101b037  000000f8          ori.b    #$f8, d0
0101b03b  1020              move.b   -(a0), d0
0101b03d  4080              negx.l   d0
0101b03f  f8000000          fmove    fp0, fp0
0101b043  00102020          ori.b    #$20, (a0)
0101b047  2040              movea.l  d0, a0
0101b049  2020              move.l   -(a0), d0
0101b04b  2020              move.l   -(a0), d0
0101b04d  1000              move.b   d0, d0
0101b04f  00202020          ori.b    #$20, -(a0)
0101b053  2020              move.l   -(a0), d0
0101b055  2020              move.l   -(a0), d0
0101b057  2020              move.l   -(a0), d0
0101b059  2000              move.l   d0, d0
0101b05b  00402020          ori.w    #$2020, d0
0101b05f  2010              move.l   (a0), d0
0101b061  2020              move.l   -(a0), d0
0101b063  2020              move.l   -(a0), d0
0101b065  4000              negx.b   d0
0101b067  00000000          ori.b    #$0, d0
0101b06b  6890              bvc.b    $101affd
0101b06d  00000000          ori.b    #$0, d0
0101b071  00000000          ori.b    #$0, d0
0101b075  00000000          ori.b    #$0, d0
0101b079  00000000          ori.b    #$0, d0
0101b07d  00000001          ori.b    #$1, d0
0101b081  00b9720100b9e60100bc  ori.l    #$720100b9, $e60100bc.l
0101b08b  7801              moveq    #$1, d4
0101b08d  00be              dc.w     $00be
0101b08f  7c01              moveq    #$1, d6
0101b091  00c1              dc.w     $00c1
0101b093  aa01              dc.w     $aa01
0101b095  0040a801          ori.w    #$a801, d0
0101b099  00be              dc.w     $00be
0101b09b  be01              cmp.b    d1, d7
0101b09d  00b9a80100bb8e0100bc  ori.l    #$a80100bb, $8e0100bc.l
0101b0a7  7801              moveq    #$1, d4
0101b0a9  00be              dc.w     $00be
0101b0ab  7c01              moveq    #$1, d6
0101b0ad  00c1              dc.w     $00c1
0101b0af  aa01              dc.w     $aa01
0101b0b1  0040a801          ori.w    #$a801, d0
0101b0b5  00be              dc.w     $00be
0101b0b7  be01              cmp.b    d1, d7
0101b0b9  00bf              dc.w     $00bf
0101b0bb  7201              moveq    #$1, d1
0101b0bd  00bf              dc.w     $00bf
0101b0bf  9e01              sub.b    d1, d7
0101b0c1  00c1              dc.w     $00c1
0101b0c3  4601              not.b    d1
0101b0c5  00c1              dc.w     $00c1
0101b0c7  4e01              dc.w     $4e01
0101b0c9  00c1              dc.w     $00c1
0101b0cb  aa01              dc.w     $aa01
0101b0cd  00c1              dc.w     $00c1
0101b0cf  aa01              dc.w     $aa01
0101b0d1  00c1              dc.w     $00c1
0101b0d3  8a00              or.b     d0, d5
0101b0d5  0103              btst.l   d0, d3
0101b0d7  070f1f3e          movep.w  $1f3e(a7), d3
0101b0db  3d3b372f1e3c3933270e  move.w   ([$101cf19, pc], d3.w * 8, $3933270e), -(a6)
0101b0e5  1d3a352b          move.b   $101e612(pc), -(a6)
0101b0e9  162c1830          move.b   $1830(a4), d3
0101b0ed  2102              move.l   d2, -(a0)
0101b0ef  050b172e          movep.w  $172e(a3), d2
0101b0f3  1c383123          move.b   $3123.w, d6
0101b0f7  060d              dc.w     $060d
0101b0f9  1b362d1a3429      move.b   ([a6, d2.l * 4], $3429), -(a5)
0101b0ff  1224              move.b   -(a4), d1
0101b101  0811              dc.w     $0811
0101b103  2204              move.l   d4, d1
0101b105  0913              btst.l   d4, (a3)
0101b107  260c              move.l   a4, d3
0101b109  1932250a152a      move.b   ([a2, d2.w * 4], $152a), -(a4)
0101b10f  14281000          move.b   $1000(a0), d2
0101b113  000100d9          ori.b    #$d9, d1
0101b117  aa01              dc.w     $aa01
0101b119  00d9              dc.w     $00d9
0101b11b  aa01              dc.w     $aa01
0101b11d  00c7              dc.w     $00c7
0101b11f  8801              or.b     d1, d4
0101b121  00d9              dc.w     $00d9
0101b123  aa01              dc.w     $aa01
0101b125  00d9              dc.w     $00d9
0101b127  aa01              dc.w     $aa01
0101b129  00d9              dc.w     $00d9
0101b12b  aa01              dc.w     $aa01
0101b12d  00d9              dc.w     $00d9
0101b12f  aa01              dc.w     $aa01
0101b131  00d9              dc.w     $00d9
0101b133  aa39              dc.w     $aa39
0101b135  3a3b3c40          move.w   $101b177(pc, d3.l), d5
0101b139  3d313233          move.w   $33(a1, d3.w), -(a6)
0101b13d  340a              move.w   a2, d2
0101b13f  35424344          move.w   d2, $4344(a2)
0101b143  4547              dc.w     $4547
0101b145  484a              bkpt     #$2
0101b147  4b4c              dc.w     $4b4c
0101b149  4d4f              dc.w     $4d4f
0101b14b  501c              addq.b   #$8, (a4)+
0101b14d  1f4e              dc.w     $1f4e
0101b14f  1d1e              move.b   (a6)+, -(a6)
0101b151  2004              move.l   d4, d0
0101b153  0746              bchg.b   d3, d6
0101b155  0506              btst.l   d2, d6
0101b157  082a              dc.w     $082a
0101b159  2d3f              dc.w     $2d3f
0101b15b  2b3e              dc.w     $2b3e
0101b15d  2c03              move.l   d3, d6
0101b15f  2e3037362f4138261b00  move.l   ([$2f413826, a0], d3.w * 8, $1b00), d7
0101b169  4900              chk.l    d0, d4
0101b16b  00000000          ori.b    #$0, d0
0101b16f  0910              btst.l   d4, (a0)
0101b171  0f16              btst.l   d7, (a6)
0101b173  00000c00          ori.b    #$0, d0
0101b177  2500              move.l   d0, -(a2)
0101b179  1500              move.b   d0, -(a2)
0101b17b  4900              chk.l    d0, d4
0101b17d  0000280d          ori.b    #$d, d0
0101b181  00240000          ori.b    #$0, -(a4)
0101b185  270b              move.l   a3, -(a3)
0101b187  1117              move.b   (a7), -(a0)
0101b189  1412              move.b   (a2), d2
0101b18b  1813              move.b   (a3), d4
0101b18d  2100              move.l   d0, -(a0)
0101b18f  2223              move.l   -(a3), d1
0101b191  000000d0          ori.b    #$d0, d0
0101b195  cfce              dc.w     $cfce
0101b197  cc9e              and.l    (a6)+, d6
0101b199  9f00              subx.b   d0, d7
0101b19b  9d00              subx.b   d0, d6
0101b19d  8800              or.b     d0, d4
0101b19f  8400              or.b     d0, d2
0101b1a1  a000              dc.w     $a000
0101b1a3  9c00              sub.b    d0, d6
0101b1a5  8500              sbcd.b   d0, d2
0101b1a7  1a19              move.b   (a1)+, d5
0101b1a9  29cd              dc.w     $29cd
0101b1ab  02cb              dc.w     $02cb
0101b1ad  01ca0000          movep.l  d0, $0(a2)
0101b1b1  00000001          ori.b    #$1, d0
0101b1b5  00e1              dc.w     $00e1
0101b1b7  ec01              asr.b    #$6, d1
0101b1b9  00e2              dc.w     $00e2
0101b1bb  f00100e6          fdadd    fp0, fp1
0101b1bf  4601              not.b    d1
0101b1c1  00e7              dc.w     $00e7
0101b1c3  2601              move.l   d1, d3
0101b1c5  00e7              dc.w     $00e7
0101b1c7  2e00              move.l   d0, d7
0101b1c9  00000101          ori.b    #$1, d0
0101b1cd  00eb              dc.w     $00eb
0101b1cf  c401              and.b    d1, d2
0101b1d1  00f0              dc.w     $00f0
0101b1d3  4401              neg.b    d1
0101b1d5  00ec              dc.w     $00ec
0101b1d7  4e2d              dc.w     $4e2d
0101b1d9  00000000          ori.b    #$0, d0
0101b1dd  002d00000000      ori.b    #$0, $0(a5)
0101b1e3  002d00000000      ori.b    #$0, $0(a5)
0101b1e9  002900010142      ori.b    #$1, $142(a1)
0101b1ef  952d0001          sub.b    d2, $1(a5)
0101b1f3  0142              bchg.b   d0, d2
0101b1f5  ad2d              dc.w     $ad2d
0101b1f7  00000000          ori.b    #$0, d0
0101b1fb  002d00000000      ori.b    #$0, $0(a5)
0101b201  002d00000000      ori.b    #$0, $0(a5)
0101b207  002d00000000      ori.b    #$0, $0(a5)
0101b20d  000d              dc.w     $000d
0101b20f  00000000          ori.b    #$0, d0
0101b213  004c              dc.w     $004c
0101b215  00000000          ori.b    #$0, d0
0101b219  008000000000      ori.l    #$0, d0
0101b21f  002d00000000      ori.b    #$0, $0(a5)
0101b225  002d00000000      ori.b    #$0, $0(a5)
0101b22b  002d00000000      ori.b    #$0, $0(a5)
0101b231  000d              dc.w     $000d
0101b233  00000000          ori.b    #$0, d0
0101b237  00600001          ori.w    #$1, -(a0)
0101b23b  0142              bchg.b   d0, d2
0101b23d  bc0d              dc.w     $bc0d
0101b23f  00000000          ori.b    #$0, d0
0101b243  002d00000000      ori.b    #$0, $0(a5)
0101b249  002d00000000      ori.b    #$0, $0(a5)
0101b24f  00200001          ori.b    #$1, -(a0)
0101b253  0142              bchg.b   d0, d2
0101b255  ce2d0000          and.b    $0(a5), d7
0101b259  0000002d          ori.b    #$2d, d0
0101b25d  00000000          ori.b    #$0, d0
0101b261  002d00000000      ori.b    #$0, $0(a5)
0101b267  002d00000000      ori.b    #$0, $0(a5)
0101b26d  002d00000000      ori.b    #$0, $0(a5)
0101b273  00210000          ori.b    #$0, -(a1)
0101b277  00000020          ori.b    #$20, d0
0101b27b  00000000          ori.b    #$0, d0
0101b27f  002d00000000      ori.b    #$0, $0(a5)
0101b285  004c              dc.w     $004c
0101b287  00000000          ori.b    #$0, d0
0101b28b  004c              dc.w     $004c
0101b28d  00000000          ori.b    #$0, d0
0101b291  002d00010142      ori.b    #$1, $142(a5)
0101b297  df4c              addx.w   -(a4), -(a7)
0101b299  00000000          ori.b    #$0, d0
0101b29d  004c              dc.w     $004c
0101b29f  00000000          ori.b    #$0, d0
0101b2a3  00600000          ori.w    #$0, -(a0)
0101b2a7  0000004c          ori.b    #$4c, d0
0101b2ab  00000000          ori.b    #$0, d0
0101b2af  004c              dc.w     $004c
0101b2b1  00000000          ori.b    #$0, d0
0101b2b5  002d00000000      ori.b    #$0, $0(a5)
0101b2bb  002d00000000      ori.b    #$0, $0(a5)
0101b2c1  002d00000000      ori.b    #$0, $0(a5)
0101b2c7  002d00000000      ori.b    #$0, $0(a5)
0101b2cd  002d00000000      ori.b    #$0, $0(a5)
0101b2d3  002d00000000      ori.b    #$0, $0(a5)
0101b2d9  008000000000      ori.l    #$0, d0
0101b2df  002d00000000      ori.b    #$0, $0(a5)
0101b2e5  00600000          ori.w    #$0, -(a0)
0101b2e9  00000060          ori.b    #$60, d0
0101b2ed  00000000          ori.b    #$0, d0
0101b2f1  00600000          ori.w    #$0, -(a0)
0101b2f5  00000060          ori.b    #$60, d0
0101b2f9  00000000          ori.b    #$0, d0
0101b2fd  008000000000      ori.l    #$0, d0
0101b303  008000000000      ori.l    #$0, d0
0101b309  008000000000      ori.l    #$0, d0
0101b30f  008000000000      ori.l    #$0, d0
0101b315  008000000000      ori.l    #$0, d0
0101b31b  00200000          ori.b    #$0, -(a0)
0101b31f  00000020          ori.b    #$20, d0
0101b323  00000000          ori.b    #$0, d0
0101b327  002d00000000      ori.b    #$0, $0(a5)
0101b32d  002d00000000      ori.b    #$0, $0(a5)
0101b333  00200000          ori.b    #$0, -(a0)
0101b337  00000020          ori.b    #$20, d0
0101b33b  00000000          ori.b    #$0, d0
0101b33f  0043              dc.w     $0043

; ---- gap 0101b34c..0101b3d3 (136 bytes) ----
0101b34c  00000000          ori.b    #$0, d0
0101b350  00000000          ori.b    #$0, d0
0101b354  00000000          ori.b    #$0, d0
0101b358  00000000          ori.b    #$0, d0
0101b35c  0003c460          ori.b    #$60, d3
0101b360  ffff              dc.w     $ffff
0101b362  ffff              dc.w     $ffff
0101b364  ffff              dc.w     $ffff
0101b366  ffff              dc.w     $ffff
0101b368  00000400          ori.b    #$0, d0
0101b36c  00040000          ori.b    #$0, d4
0101b370  00001035          ori.b    #$35, d0
0101b374  00100100          ori.b    #$0, (a0)
0101b378  f2440100          fsf.b    d4
0101b37c  f2c00100f2c8      fbf.l    $202a646                    ; $0202a646 = NBIC (non-Turbo cube) +$a646
0101b382  0100              btst.l   d0, d0
0101b384  f2fe0100f22e      fbf.l    $202a5b4                    ; $0202a5b4 = NBIC (non-Turbo cube) +$a5b4
0101b38a  00000001          ori.b    #$1, d0
0101b38e  00000002          ori.b    #$2, d0
0101b392  0101              btst.l   d0, d1
0101b394  42ea0101          move.w   ccr, $101(a2)
0101b398  42f00101          move.w   ccr, ([a0, d0.w])
0101b39c  42f80101          move.w   ccr, $101.w
0101b3a0  4300              chk.l    d0, d1
0101b3a2  3500              move.w   d0, -(a2)
0101b3a4  003344353300      ori.b    #$35, (a3, d3.w * 2)
0101b3aa  00000026          ori.b    #$26, d0
0101b3ae  00000001          ori.b    #$1, d0
0101b3b2  00040500          ori.b    #$0, d4
0101b3b6  0300              btst.l   d1, d0
0101b3b8  00000500          ori.b    #$0, d0
0101b3bc  0101              btst.l   d0, d1
0101b3be  0562              bchg.b   d2, -(a2)
0101b3c0  0101              btst.l   d0, d1
0101b3c2  068001010688      addi.l   #fd_read, d0
0101b3c8  0101              btst.l   d0, d1
0101b3ca  06d6              dc.w     $06d6
0101b3cc  0101              btst.l   d0, d1
0101b3ce  06de              dc.w     $06de
0101b3d0  00000001          ori.b    #$1, d0

; ---- gap 0101b3e2..0101ffff (19486 bytes) ----
0101b3e2  00000000          ori.b    #$0, d0
0101b3e6  00000000          ori.b    #$0, d0
0101b3ea  00000000          ori.b    #$0, d0
0101b3ee  00000000          ori.b    #$0, d0
0101b3f2  00000000          ori.b    #$0, d0
0101b3f6  00000000          ori.b    #$0, d0
0101b3fa  00000000          ori.b    #$0, d0
0101b3fe  04000001          subi.b   #$1, d0
0101b402  00000000          ori.b    #$0, d0
0101b406  00030000          ori.b    #$0, d3
0101b40a  00100000          ori.b    #$0, (a0)
0101b40e  00200000          ori.b    #$0, -(a0)
0101b412  00030200          ori.b    #$0, d3
0101b416  00000050          ori.b    #$50, d0
0101b41a  00000001          ori.b    #$1, d0
0101b41e  00000002          ori.b    #$2, d0
0101b422  02000000          andi.b   #$0, d0
0101b426  00500000          ori.w    #$0, (a0)
0101b42a  00020000          ori.b    #$0, d2
0101b42e  00010200          ori.b    #$0, d1
0101b432  00000050          ori.b    #$50, d0
0101b436  00000003          ori.b    #$3, d0
0101b43a  00000000          ori.b    #$0, d0
0101b43e  00000000          ori.b    #$0, d0
0101b442  00000000          ori.b    #$0, d0
0101b446  00000000          ori.b    #$0, d0
0101b44a  0001000b          ori.b    #$b, d1
0101b44e  4000              negx.b   d0
0101b450  08000000          btst.b   #$0, d0
0101b454  00010000          ori.b    #$0, d1
0101b458  00020016          ori.b    #$16, d2
0101b45c  8000              or.b     d0, d0
0101b45e  1000              move.b   d0, d0
0101b460  00000001          ori.b    #$1, d0
0101b464  00000003          ori.b    #$3, d0
0101b468  002d00002000      ori.b    #$0, $2000(a5)
0101b46e  00000001          ori.b    #$1, d0
0101b472  00000000          ori.b    #$0, d0
0101b476  000b              dc.w     $000b
0101b478  4000              negx.b   d0
0101b47a  3000              move.w   d0, d0
0101b47c  00000001          ori.b    #$1, d0
0101b480  00000000          ori.b    #$0, d0
0101b484  00000000          ori.b    #$0, d0
0101b488  00000000          ori.b    #$0, d0
0101b48c  00000000          ori.b    #$0, d0
0101b490  00000000          ori.b    #$0, d0
0101b494  00000000          ori.b    #$0, d0
0101b498  00000000          ori.b    #$0, d0
0101b49c  00000000          ori.b    #$0, d0
0101b4a0  00000000          ori.b    #$0, d0
0101b4a4  00000000          ori.b    #$0, d0
0101b4a8  00000000          ori.b    #$0, d0
0101b4ac  00000000          ori.b    #$0, d0
0101b4b0  00000000          ori.b    #$0, d0
0101b4b4  00000000          ori.b    #$0, d0
0101b4b8  00000000          ori.b    #$0, d0
0101b4bc  00000000          ori.b    #$0, d0
0101b4c0  00000000          ori.b    #$0, d0
0101b4c4  00000000          ori.b    #$0, d0
0101b4c8  00000000          ori.b    #$0, d0
0101b4cc  00000000          ori.b    #$0, d0
0101b4d0  00000000          ori.b    #$0, d0
0101b4d4  00000000          ori.b    #$0, d0
0101b4d8  00000000          ori.b    #$0, d0
0101b4dc  00000000          ori.b    #$0, d0
0101b4e0  00000000          ori.b    #$0, d0
0101b4e4  00000000          ori.b    #$0, d0
0101b4e8  00000000          ori.b    #$0, d0
0101b4ec  00000000          ori.b    #$0, d0
0101b4f0  00000000          ori.b    #$0, d0
0101b4f4  00000000          ori.b    #$0, d0
0101b4f8  00000000          ori.b    #$0, d0
0101b4fc  00000000          ori.b    #$0, d0
0101b500  00000000          ori.b    #$0, d0
0101b504  00000000          ori.b    #$0, d0
0101b508  00000000          ori.b    #$0, d0
0101b50c  00000000          ori.b    #$0, d0
0101b510  00000000          ori.b    #$0, d0
0101b514  00000000          ori.b    #$0, d0
0101b518  00000000          ori.b    #$0, d0
0101b51c  00000000          ori.b    #$0, d0
0101b520  00000000          ori.b    #$0, d0
0101b524  00000000          ori.b    #$0, d0
0101b528  00000000          ori.b    #$0, d0
0101b52c  00000000          ori.b    #$0, d0
0101b530  00000000          ori.b    #$0, d0
0101b534  00000000          ori.b    #$0, d0
0101b538  00000000          ori.b    #$0, d0
0101b53c  00000000          ori.b    #$0, d0
0101b540  00000000          ori.b    #$0, d0
0101b544  00000000          ori.b    #$0, d0
0101b548  00000000          ori.b    #$0, d0
0101b54c  00000000          ori.b    #$0, d0
0101b550  00000000          ori.b    #$0, d0
0101b554  00000000          ori.b    #$0, d0
0101b558  00000000          ori.b    #$0, d0
0101b55c  00000000          ori.b    #$0, d0
0101b560  00000000          ori.b    #$0, d0
0101b564  00000000          ori.b    #$0, d0
0101b568  00000000          ori.b    #$0, d0
0101b56c  00000000          ori.b    #$0, d0
0101b570  00000000          ori.b    #$0, d0
0101b574  00000000          ori.b    #$0, d0
0101b578  00000000          ori.b    #$0, d0
0101b57c  00000000          ori.b    #$0, d0
0101b580  00000000          ori.b    #$0, d0
0101b584  00000000          ori.b    #$0, d0
0101b588  00000000          ori.b    #$0, d0
0101b58c  00000000          ori.b    #$0, d0
0101b590  00000000          ori.b    #$0, d0
0101b594  00000000          ori.b    #$0, d0
0101b598  00000000          ori.b    #$0, d0
0101b59c  00000000          ori.b    #$0, d0
0101b5a0  00000000          ori.b    #$0, d0
0101b5a4  00000000          ori.b    #$0, d0
0101b5a8  00000000          ori.b    #$0, d0
0101b5ac  00000000          ori.b    #$0, d0
0101b5b0  00000000          ori.b    #$0, d0
0101b5b4  00000000          ori.b    #$0, d0
0101b5b8  00000000          ori.b    #$0, d0
0101b5bc  00000000          ori.b    #$0, d0
0101b5c0  00000000          ori.b    #$0, d0
0101b5c4  00000000          ori.b    #$0, d0
0101b5c8  00000000          ori.b    #$0, d0
0101b5cc  00000000          ori.b    #$0, d0
0101b5d0  00000000          ori.b    #$0, d0
0101b5d4  00000000          ori.b    #$0, d0
0101b5d8  00000000          ori.b    #$0, d0
0101b5dc  00000000          ori.b    #$0, d0
0101b5e0  00000000          ori.b    #$0, d0
0101b5e4  00000000          ori.b    #$0, d0
0101b5e8  00000000          ori.b    #$0, d0
0101b5ec  00000000          ori.b    #$0, d0
0101b5f0  00000000          ori.b    #$0, d0
0101b5f4  00000000          ori.b    #$0, d0
0101b5f8  00000000          ori.b    #$0, d0
0101b5fc  00000000          ori.b    #$0, d0
0101b600  00000000          ori.b    #$0, d0
0101b604  00000000          ori.b    #$0, d0
0101b608  00000000          ori.b    #$0, d0
0101b60c  00000000          ori.b    #$0, d0
0101b610  00000000          ori.b    #$0, d0
0101b614  00000000          ori.b    #$0, d0
0101b618  00000000          ori.b    #$0, d0
0101b61c  00000000          ori.b    #$0, d0
0101b620  00000000          ori.b    #$0, d0
0101b624  00000000          ori.b    #$0, d0
0101b628  00000000          ori.b    #$0, d0
0101b62c  00000000          ori.b    #$0, d0
0101b630  00000000          ori.b    #$0, d0
0101b634  00000000          ori.b    #$0, d0
0101b638  00000000          ori.b    #$0, d0
0101b63c  00000000          ori.b    #$0, d0
0101b640  00000000          ori.b    #$0, d0
0101b644  00000000          ori.b    #$0, d0
0101b648  00000000          ori.b    #$0, d0
0101b64c  00000000          ori.b    #$0, d0
0101b650  00000000          ori.b    #$0, d0
0101b654  00000000          ori.b    #$0, d0
0101b658  00000000          ori.b    #$0, d0
0101b65c  00000000          ori.b    #$0, d0
0101b660  00000000          ori.b    #$0, d0
0101b664  00000000          ori.b    #$0, d0
0101b668  00000000          ori.b    #$0, d0
0101b66c  00000000          ori.b    #$0, d0
0101b670  00000000          ori.b    #$0, d0
0101b674  00000000          ori.b    #$0, d0
0101b678  00000000          ori.b    #$0, d0
0101b67c  00000000          ori.b    #$0, d0
0101b680  00000000          ori.b    #$0, d0
0101b684  00000000          ori.b    #$0, d0
0101b688  00000000          ori.b    #$0, d0
0101b68c  00000000          ori.b    #$0, d0
0101b690  00000000          ori.b    #$0, d0
0101b694  00000000          ori.b    #$0, d0
0101b698  00000000          ori.b    #$0, d0
0101b69c  00000000          ori.b    #$0, d0
0101b6a0  00000000          ori.b    #$0, d0
0101b6a4  00000000          ori.b    #$0, d0
0101b6a8  00000000          ori.b    #$0, d0
0101b6ac  00000000          ori.b    #$0, d0
0101b6b0  00000000          ori.b    #$0, d0
0101b6b4  00000000          ori.b    #$0, d0
0101b6b8  00000000          ori.b    #$0, d0
0101b6bc  00000000          ori.b    #$0, d0
0101b6c0  00000000          ori.b    #$0, d0
0101b6c4  00000000          ori.b    #$0, d0
0101b6c8  00000000          ori.b    #$0, d0
0101b6cc  00000000          ori.b    #$0, d0
0101b6d0  00000000          ori.b    #$0, d0
0101b6d4  00000000          ori.b    #$0, d0
0101b6d8  00000000          ori.b    #$0, d0
0101b6dc  00000000          ori.b    #$0, d0
0101b6e0  00000000          ori.b    #$0, d0
0101b6e4  00000000          ori.b    #$0, d0
0101b6e8  00000000          ori.b    #$0, d0
0101b6ec  00000000          ori.b    #$0, d0
0101b6f0  00000000          ori.b    #$0, d0
0101b6f4  00000000          ori.b    #$0, d0
0101b6f8  00000000          ori.b    #$0, d0
0101b6fc  00000000          ori.b    #$0, d0
0101b700  00000000          ori.b    #$0, d0
0101b704  00000000          ori.b    #$0, d0
0101b708  00000000          ori.b    #$0, d0
0101b70c  00000000          ori.b    #$0, d0
0101b710  00000000          ori.b    #$0, d0
0101b714  00000000          ori.b    #$0, d0
0101b718  00000000          ori.b    #$0, d0
0101b71c  00000000          ori.b    #$0, d0
0101b720  00000000          ori.b    #$0, d0
0101b724  00000000          ori.b    #$0, d0
0101b728  00000000          ori.b    #$0, d0
0101b72c  00000000          ori.b    #$0, d0
0101b730  00000000          ori.b    #$0, d0
0101b734  00000000          ori.b    #$0, d0
0101b738  00000000          ori.b    #$0, d0
0101b73c  00000000          ori.b    #$0, d0
0101b740  00000000          ori.b    #$0, d0
0101b744  00000000          ori.b    #$0, d0
0101b748  00000000          ori.b    #$0, d0
0101b74c  00000000          ori.b    #$0, d0
0101b750  00000000          ori.b    #$0, d0
0101b754  00000000          ori.b    #$0, d0
0101b758  00000000          ori.b    #$0, d0
0101b75c  00000000          ori.b    #$0, d0
0101b760  00000000          ori.b    #$0, d0
0101b764  00000000          ori.b    #$0, d0
0101b768  00000000          ori.b    #$0, d0
0101b76c  00000000          ori.b    #$0, d0
0101b770  00000000          ori.b    #$0, d0
0101b774  00000000          ori.b    #$0, d0
0101b778  00000000          ori.b    #$0, d0
0101b77c  00000000          ori.b    #$0, d0
0101b780  00000000          ori.b    #$0, d0
0101b784  00000000          ori.b    #$0, d0
0101b788  00000000          ori.b    #$0, d0
0101b78c  00000000          ori.b    #$0, d0
0101b790  00000000          ori.b    #$0, d0
0101b794  00000000          ori.b    #$0, d0
0101b798  00000000          ori.b    #$0, d0
0101b79c  00000000          ori.b    #$0, d0
0101b7a0  00000000          ori.b    #$0, d0
0101b7a4  00000000          ori.b    #$0, d0
0101b7a8  00000000          ori.b    #$0, d0
0101b7ac  00000000          ori.b    #$0, d0
0101b7b0  00000000          ori.b    #$0, d0
0101b7b4  00000000          ori.b    #$0, d0
0101b7b8  00000000          ori.b    #$0, d0
0101b7bc  00000000          ori.b    #$0, d0
0101b7c0  00000000          ori.b    #$0, d0
0101b7c4  00000000          ori.b    #$0, d0
0101b7c8  00000000          ori.b    #$0, d0
0101b7cc  00000000          ori.b    #$0, d0
0101b7d0  00000000          ori.b    #$0, d0
0101b7d4  00000000          ori.b    #$0, d0
0101b7d8  00000000          ori.b    #$0, d0
0101b7dc  00000000          ori.b    #$0, d0
0101b7e0  00000000          ori.b    #$0, d0
0101b7e4  00000000          ori.b    #$0, d0
0101b7e8  00000000          ori.b    #$0, d0
0101b7ec  00000000          ori.b    #$0, d0
0101b7f0  00000000          ori.b    #$0, d0
0101b7f4  00000000          ori.b    #$0, d0
0101b7f8  00000000          ori.b    #$0, d0
0101b7fc  00000000          ori.b    #$0, d0
0101b800  00000000          ori.b    #$0, d0
0101b804  00000000          ori.b    #$0, d0
0101b808  00000000          ori.b    #$0, d0
0101b80c  00000000          ori.b    #$0, d0
0101b810  00000000          ori.b    #$0, d0
0101b814  00000000          ori.b    #$0, d0
0101b818  00000000          ori.b    #$0, d0
0101b81c  00000000          ori.b    #$0, d0
0101b820  00000000          ori.b    #$0, d0
0101b824  00000000          ori.b    #$0, d0
0101b828  00000000          ori.b    #$0, d0
0101b82c  00000000          ori.b    #$0, d0
0101b830  00000000          ori.b    #$0, d0
0101b834  00000000          ori.b    #$0, d0
0101b838  00000000          ori.b    #$0, d0
0101b83c  00000000          ori.b    #$0, d0
0101b840  00000000          ori.b    #$0, d0
0101b844  00000000          ori.b    #$0, d0
0101b848  00000000          ori.b    #$0, d0
0101b84c  00000000          ori.b    #$0, d0
0101b850  00000000          ori.b    #$0, d0
0101b854  00000000          ori.b    #$0, d0
0101b858  00000000          ori.b    #$0, d0
0101b85c  00000000          ori.b    #$0, d0
0101b860  00000000          ori.b    #$0, d0
0101b864  00000000          ori.b    #$0, d0
0101b868  00000000          ori.b    #$0, d0
0101b86c  00000000          ori.b    #$0, d0
0101b870  00000000          ori.b    #$0, d0
0101b874  00000000          ori.b    #$0, d0
0101b878  00000000          ori.b    #$0, d0
0101b87c  00000000          ori.b    #$0, d0
0101b880  00000000          ori.b    #$0, d0
0101b884  00000000          ori.b    #$0, d0
0101b888  00000000          ori.b    #$0, d0
0101b88c  00000000          ori.b    #$0, d0
0101b890  00000000          ori.b    #$0, d0
0101b894  00000000          ori.b    #$0, d0
0101b898  00000000          ori.b    #$0, d0
0101b89c  00000000          ori.b    #$0, d0
0101b8a0  00000000          ori.b    #$0, d0
0101b8a4  00000000          ori.b    #$0, d0
0101b8a8  00000000          ori.b    #$0, d0
0101b8ac  00000000          ori.b    #$0, d0
0101b8b0  00000000          ori.b    #$0, d0
0101b8b4  00000000          ori.b    #$0, d0
0101b8b8  00000000          ori.b    #$0, d0
0101b8bc  00000000          ori.b    #$0, d0
0101b8c0  00000000          ori.b    #$0, d0
0101b8c4  00000000          ori.b    #$0, d0
0101b8c8  00000000          ori.b    #$0, d0
0101b8cc  00000000          ori.b    #$0, d0
0101b8d0  00000000          ori.b    #$0, d0
0101b8d4  00000000          ori.b    #$0, d0
0101b8d8  00000000          ori.b    #$0, d0
0101b8dc  00000000          ori.b    #$0, d0
0101b8e0  00000000          ori.b    #$0, d0
0101b8e4  00000000          ori.b    #$0, d0
0101b8e8  00000000          ori.b    #$0, d0
0101b8ec  00000000          ori.b    #$0, d0
0101b8f0  00000000          ori.b    #$0, d0
0101b8f4  00000000          ori.b    #$0, d0
0101b8f8  00000000          ori.b    #$0, d0
0101b8fc  00000000          ori.b    #$0, d0
0101b900  00000000          ori.b    #$0, d0
0101b904  00000000          ori.b    #$0, d0
0101b908  00000000          ori.b    #$0, d0
0101b90c  00000000          ori.b    #$0, d0
0101b910  00000000          ori.b    #$0, d0
0101b914  00000000          ori.b    #$0, d0
0101b918  00000000          ori.b    #$0, d0
0101b91c  00000000          ori.b    #$0, d0
0101b920  00000000          ori.b    #$0, d0
0101b924  00000000          ori.b    #$0, d0
0101b928  00000000          ori.b    #$0, d0
0101b92c  00000000          ori.b    #$0, d0
0101b930  00000000          ori.b    #$0, d0
0101b934  00000000          ori.b    #$0, d0
0101b938  00000000          ori.b    #$0, d0
0101b93c  00000000          ori.b    #$0, d0
0101b940  00000000          ori.b    #$0, d0
0101b944  00000000          ori.b    #$0, d0
0101b948  00000000          ori.b    #$0, d0
0101b94c  00000000          ori.b    #$0, d0
0101b950  00000000          ori.b    #$0, d0
0101b954  00000000          ori.b    #$0, d0
0101b958  00000000          ori.b    #$0, d0
0101b95c  00000000          ori.b    #$0, d0
0101b960  00000000          ori.b    #$0, d0
0101b964  00000000          ori.b    #$0, d0
0101b968  00000000          ori.b    #$0, d0
0101b96c  00000000          ori.b    #$0, d0
0101b970  00000000          ori.b    #$0, d0
0101b974  00000000          ori.b    #$0, d0
0101b978  00000000          ori.b    #$0, d0
0101b97c  00000000          ori.b    #$0, d0
0101b980  00000000          ori.b    #$0, d0
0101b984  00000000          ori.b    #$0, d0
0101b988  00000000          ori.b    #$0, d0
0101b98c  00000000          ori.b    #$0, d0
0101b990  00000000          ori.b    #$0, d0
0101b994  00000000          ori.b    #$0, d0
0101b998  00000000          ori.b    #$0, d0
0101b99c  00000000          ori.b    #$0, d0
0101b9a0  00000000          ori.b    #$0, d0
0101b9a4  00000000          ori.b    #$0, d0
0101b9a8  00000000          ori.b    #$0, d0
0101b9ac  00000000          ori.b    #$0, d0
0101b9b0  00000000          ori.b    #$0, d0
0101b9b4  00000000          ori.b    #$0, d0
0101b9b8  00000000          ori.b    #$0, d0
0101b9bc  00000000          ori.b    #$0, d0
0101b9c0  00000000          ori.b    #$0, d0
0101b9c4  00000000          ori.b    #$0, d0
0101b9c8  00000000          ori.b    #$0, d0
0101b9cc  00000000          ori.b    #$0, d0
0101b9d0  00000000          ori.b    #$0, d0
0101b9d4  00000000          ori.b    #$0, d0
0101b9d8  00000000          ori.b    #$0, d0
0101b9dc  00000000          ori.b    #$0, d0
0101b9e0  00000000          ori.b    #$0, d0
0101b9e4  00000000          ori.b    #$0, d0
0101b9e8  00000000          ori.b    #$0, d0
0101b9ec  00000000          ori.b    #$0, d0
0101b9f0  00000000          ori.b    #$0, d0
0101b9f4  00000000          ori.b    #$0, d0
0101b9f8  00000000          ori.b    #$0, d0
0101b9fc  00000000          ori.b    #$0, d0
0101ba00  00000000          ori.b    #$0, d0
0101ba04  00000000          ori.b    #$0, d0
0101ba08  00000000          ori.b    #$0, d0
0101ba0c  00000000          ori.b    #$0, d0
0101ba10  00000000          ori.b    #$0, d0
0101ba14  00000000          ori.b    #$0, d0
0101ba18  00000000          ori.b    #$0, d0
0101ba1c  00000000          ori.b    #$0, d0
0101ba20  00000000          ori.b    #$0, d0
0101ba24  00000000          ori.b    #$0, d0
0101ba28  00000000          ori.b    #$0, d0
0101ba2c  00000000          ori.b    #$0, d0
0101ba30  00000000          ori.b    #$0, d0
0101ba34  00000000          ori.b    #$0, d0
0101ba38  00000000          ori.b    #$0, d0
0101ba3c  00000000          ori.b    #$0, d0
0101ba40  00000000          ori.b    #$0, d0
0101ba44  00000000          ori.b    #$0, d0
0101ba48  00000000          ori.b    #$0, d0
0101ba4c  00000000          ori.b    #$0, d0
0101ba50  00000000          ori.b    #$0, d0
0101ba54  00000000          ori.b    #$0, d0
0101ba58  00000000          ori.b    #$0, d0
0101ba5c  00000000          ori.b    #$0, d0
0101ba60  00000000          ori.b    #$0, d0
0101ba64  00000000          ori.b    #$0, d0
0101ba68  00000000          ori.b    #$0, d0
0101ba6c  00000000          ori.b    #$0, d0
0101ba70  00000000          ori.b    #$0, d0
0101ba74  00000000          ori.b    #$0, d0
0101ba78  00000000          ori.b    #$0, d0
0101ba7c  00000000          ori.b    #$0, d0
0101ba80  00000000          ori.b    #$0, d0
0101ba84  00000000          ori.b    #$0, d0
0101ba88  00000000          ori.b    #$0, d0
0101ba8c  00000000          ori.b    #$0, d0
0101ba90  00000000          ori.b    #$0, d0
0101ba94  00000000          ori.b    #$0, d0
0101ba98  00000000          ori.b    #$0, d0
0101ba9c  00000000          ori.b    #$0, d0
0101baa0  00000000          ori.b    #$0, d0
0101baa4  00000000          ori.b    #$0, d0
0101baa8  00000000          ori.b    #$0, d0
0101baac  00000000          ori.b    #$0, d0
0101bab0  00000000          ori.b    #$0, d0
0101bab4  00000000          ori.b    #$0, d0
0101bab8  00000000          ori.b    #$0, d0
0101babc  00000000          ori.b    #$0, d0
0101bac0  00000000          ori.b    #$0, d0
0101bac4  00000000          ori.b    #$0, d0
0101bac8  00000000          ori.b    #$0, d0
0101bacc  00000000          ori.b    #$0, d0
0101bad0  00000000          ori.b    #$0, d0
0101bad4  00000000          ori.b    #$0, d0
0101bad8  00000000          ori.b    #$0, d0
0101badc  00000000          ori.b    #$0, d0
0101bae0  00000000          ori.b    #$0, d0
0101bae4  00000000          ori.b    #$0, d0
0101bae8  00000000          ori.b    #$0, d0
0101baec  00000000          ori.b    #$0, d0
0101baf0  00000000          ori.b    #$0, d0
0101baf4  00000000          ori.b    #$0, d0
0101baf8  00000000          ori.b    #$0, d0
0101bafc  00000000          ori.b    #$0, d0
0101bb00  00000000          ori.b    #$0, d0
0101bb04  00000000          ori.b    #$0, d0
0101bb08  00000000          ori.b    #$0, d0
0101bb0c  00000000          ori.b    #$0, d0
0101bb10  00000000          ori.b    #$0, d0
0101bb14  00000000          ori.b    #$0, d0
0101bb18  00000000          ori.b    #$0, d0
0101bb1c  00000000          ori.b    #$0, d0
0101bb20  00000000          ori.b    #$0, d0
0101bb24  00000000          ori.b    #$0, d0
0101bb28  00000000          ori.b    #$0, d0
0101bb2c  00000000          ori.b    #$0, d0
0101bb30  00000000          ori.b    #$0, d0
0101bb34  00000000          ori.b    #$0, d0
0101bb38  00000000          ori.b    #$0, d0
0101bb3c  00000000          ori.b    #$0, d0
0101bb40  00000000          ori.b    #$0, d0
0101bb44  00000000          ori.b    #$0, d0
0101bb48  00000000          ori.b    #$0, d0
0101bb4c  00000000          ori.b    #$0, d0
0101bb50  00000000          ori.b    #$0, d0
0101bb54  00000000          ori.b    #$0, d0
0101bb58  00000000          ori.b    #$0, d0
0101bb5c  00000000          ori.b    #$0, d0
0101bb60  00000000          ori.b    #$0, d0
0101bb64  00000000          ori.b    #$0, d0
0101bb68  00000000          ori.b    #$0, d0
0101bb6c  00000000          ori.b    #$0, d0
0101bb70  00000000          ori.b    #$0, d0
0101bb74  00000000          ori.b    #$0, d0
0101bb78  00000000          ori.b    #$0, d0
0101bb7c  00000000          ori.b    #$0, d0
0101bb80  00000000          ori.b    #$0, d0
0101bb84  00000000          ori.b    #$0, d0
0101bb88  00000000          ori.b    #$0, d0
0101bb8c  00000000          ori.b    #$0, d0
0101bb90  00000000          ori.b    #$0, d0
0101bb94  00000000          ori.b    #$0, d0
0101bb98  00000000          ori.b    #$0, d0
0101bb9c  00000000          ori.b    #$0, d0
0101bba0  00000000          ori.b    #$0, d0
0101bba4  00000000          ori.b    #$0, d0
0101bba8  00000000          ori.b    #$0, d0
0101bbac  00000000          ori.b    #$0, d0
0101bbb0  00000000          ori.b    #$0, d0
0101bbb4  00000000          ori.b    #$0, d0
0101bbb8  00000000          ori.b    #$0, d0
0101bbbc  00000000          ori.b    #$0, d0
0101bbc0  00000000          ori.b    #$0, d0
0101bbc4  00000000          ori.b    #$0, d0
0101bbc8  00000000          ori.b    #$0, d0
0101bbcc  00000000          ori.b    #$0, d0
0101bbd0  00000000          ori.b    #$0, d0
0101bbd4  00000000          ori.b    #$0, d0
0101bbd8  00000000          ori.b    #$0, d0
0101bbdc  00000000          ori.b    #$0, d0
0101bbe0  00000000          ori.b    #$0, d0
0101bbe4  00000000          ori.b    #$0, d0
0101bbe8  00000000          ori.b    #$0, d0
0101bbec  00000000          ori.b    #$0, d0
0101bbf0  00000000          ori.b    #$0, d0
0101bbf4  00000000          ori.b    #$0, d0
0101bbf8  00000000          ori.b    #$0, d0
0101bbfc  00000000          ori.b    #$0, d0
0101bc00  00000000          ori.b    #$0, d0
0101bc04  00000000          ori.b    #$0, d0
0101bc08  00000000          ori.b    #$0, d0
0101bc0c  00000000          ori.b    #$0, d0
0101bc10  00000000          ori.b    #$0, d0
0101bc14  00000000          ori.b    #$0, d0
0101bc18  00000000          ori.b    #$0, d0
0101bc1c  00000000          ori.b    #$0, d0
0101bc20  00000000          ori.b    #$0, d0
0101bc24  00000000          ori.b    #$0, d0
0101bc28  00000000          ori.b    #$0, d0
0101bc2c  00000000          ori.b    #$0, d0
0101bc30  00000000          ori.b    #$0, d0
0101bc34  00000000          ori.b    #$0, d0
0101bc38  00000000          ori.b    #$0, d0
0101bc3c  00000000          ori.b    #$0, d0
0101bc40  00000000          ori.b    #$0, d0
0101bc44  00000000          ori.b    #$0, d0
0101bc48  00000000          ori.b    #$0, d0
0101bc4c  00000000          ori.b    #$0, d0
0101bc50  00000000          ori.b    #$0, d0
0101bc54  00000000          ori.b    #$0, d0
0101bc58  00000000          ori.b    #$0, d0
0101bc5c  00000000          ori.b    #$0, d0
0101bc60  00000000          ori.b    #$0, d0
0101bc64  00000000          ori.b    #$0, d0
0101bc68  00000000          ori.b    #$0, d0
0101bc6c  00000000          ori.b    #$0, d0
0101bc70  00000000          ori.b    #$0, d0
0101bc74  00000000          ori.b    #$0, d0
0101bc78  00000000          ori.b    #$0, d0
0101bc7c  00000000          ori.b    #$0, d0
0101bc80  00000000          ori.b    #$0, d0
0101bc84  00000000          ori.b    #$0, d0
0101bc88  00000000          ori.b    #$0, d0
0101bc8c  00000000          ori.b    #$0, d0
0101bc90  00000000          ori.b    #$0, d0
0101bc94  00000000          ori.b    #$0, d0
0101bc98  00000000          ori.b    #$0, d0
0101bc9c  00000000          ori.b    #$0, d0
0101bca0  00000000          ori.b    #$0, d0
0101bca4  00000000          ori.b    #$0, d0
0101bca8  00000000          ori.b    #$0, d0
0101bcac  00000000          ori.b    #$0, d0
0101bcb0  00000000          ori.b    #$0, d0
0101bcb4  00000000          ori.b    #$0, d0
0101bcb8  00000000          ori.b    #$0, d0
0101bcbc  00000000          ori.b    #$0, d0
0101bcc0  00000000          ori.b    #$0, d0
0101bcc4  00000000          ori.b    #$0, d0
0101bcc8  00000000          ori.b    #$0, d0
0101bccc  00000000          ori.b    #$0, d0
0101bcd0  00000000          ori.b    #$0, d0
0101bcd4  00000000          ori.b    #$0, d0
0101bcd8  00000000          ori.b    #$0, d0
0101bcdc  00000000          ori.b    #$0, d0
0101bce0  00000000          ori.b    #$0, d0
0101bce4  00000000          ori.b    #$0, d0
0101bce8  00000000          ori.b    #$0, d0
0101bcec  00000000          ori.b    #$0, d0
0101bcf0  00000000          ori.b    #$0, d0
0101bcf4  00000000          ori.b    #$0, d0
0101bcf8  00000000          ori.b    #$0, d0
0101bcfc  00000000          ori.b    #$0, d0
0101bd00  00000000          ori.b    #$0, d0
0101bd04  00000000          ori.b    #$0, d0
0101bd08  00000000          ori.b    #$0, d0
0101bd0c  00000000          ori.b    #$0, d0
0101bd10  00000000          ori.b    #$0, d0
0101bd14  00000000          ori.b    #$0, d0
0101bd18  00000000          ori.b    #$0, d0
0101bd1c  00000000          ori.b    #$0, d0
0101bd20  00000000          ori.b    #$0, d0
0101bd24  00000000          ori.b    #$0, d0
0101bd28  00000000          ori.b    #$0, d0
0101bd2c  00000000          ori.b    #$0, d0
0101bd30  00000000          ori.b    #$0, d0
0101bd34  00000000          ori.b    #$0, d0
0101bd38  00000000          ori.b    #$0, d0
0101bd3c  00000000          ori.b    #$0, d0
0101bd40  00000000          ori.b    #$0, d0
0101bd44  00000000          ori.b    #$0, d0
0101bd48  00000000          ori.b    #$0, d0
0101bd4c  00000000          ori.b    #$0, d0
0101bd50  00000000          ori.b    #$0, d0
0101bd54  00000000          ori.b    #$0, d0
0101bd58  00000000          ori.b    #$0, d0
0101bd5c  00000000          ori.b    #$0, d0
0101bd60  00000000          ori.b    #$0, d0
0101bd64  00000000          ori.b    #$0, d0
0101bd68  00000000          ori.b    #$0, d0
0101bd6c  00000000          ori.b    #$0, d0
0101bd70  00000000          ori.b    #$0, d0
0101bd74  00000000          ori.b    #$0, d0
0101bd78  00000000          ori.b    #$0, d0
0101bd7c  00000000          ori.b    #$0, d0
0101bd80  00000000          ori.b    #$0, d0
0101bd84  00000000          ori.b    #$0, d0
0101bd88  00000000          ori.b    #$0, d0
0101bd8c  00000000          ori.b    #$0, d0
0101bd90  00000000          ori.b    #$0, d0
0101bd94  00000000          ori.b    #$0, d0
0101bd98  00000000          ori.b    #$0, d0
0101bd9c  00000000          ori.b    #$0, d0
0101bda0  00000000          ori.b    #$0, d0
0101bda4  00000000          ori.b    #$0, d0
0101bda8  00000000          ori.b    #$0, d0
0101bdac  00000000          ori.b    #$0, d0
0101bdb0  00000000          ori.b    #$0, d0
0101bdb4  00000000          ori.b    #$0, d0
0101bdb8  00000000          ori.b    #$0, d0
0101bdbc  00000000          ori.b    #$0, d0
0101bdc0  00000000          ori.b    #$0, d0
0101bdc4  00000000          ori.b    #$0, d0
0101bdc8  00000000          ori.b    #$0, d0
0101bdcc  00000000          ori.b    #$0, d0
0101bdd0  00000000          ori.b    #$0, d0
0101bdd4  00000000          ori.b    #$0, d0
0101bdd8  00000000          ori.b    #$0, d0
0101bddc  00000000          ori.b    #$0, d0
0101bde0  00000000          ori.b    #$0, d0
0101bde4  00000000          ori.b    #$0, d0
0101bde8  00000000          ori.b    #$0, d0
0101bdec  00000000          ori.b    #$0, d0
0101bdf0  00000000          ori.b    #$0, d0
0101bdf4  00000000          ori.b    #$0, d0
0101bdf8  00000000          ori.b    #$0, d0
0101bdfc  00000000          ori.b    #$0, d0
0101be00  00000000          ori.b    #$0, d0
0101be04  00000000          ori.b    #$0, d0
0101be08  00000000          ori.b    #$0, d0
0101be0c  00000000          ori.b    #$0, d0
0101be10  00000000          ori.b    #$0, d0
0101be14  00000000          ori.b    #$0, d0
0101be18  00000000          ori.b    #$0, d0
0101be1c  00000000          ori.b    #$0, d0
0101be20  00000000          ori.b    #$0, d0
0101be24  00000000          ori.b    #$0, d0
0101be28  00000000          ori.b    #$0, d0
0101be2c  00000000          ori.b    #$0, d0
0101be30  00000000          ori.b    #$0, d0
0101be34  00000000          ori.b    #$0, d0
0101be38  00000000          ori.b    #$0, d0
0101be3c  00000000          ori.b    #$0, d0
0101be40  00000000          ori.b    #$0, d0
0101be44  00000000          ori.b    #$0, d0
0101be48  00000000          ori.b    #$0, d0
0101be4c  00000000          ori.b    #$0, d0
0101be50  00000000          ori.b    #$0, d0
0101be54  00000000          ori.b    #$0, d0
0101be58  00000000          ori.b    #$0, d0
0101be5c  00000000          ori.b    #$0, d0
0101be60  00000000          ori.b    #$0, d0
0101be64  00000000          ori.b    #$0, d0
0101be68  00000000          ori.b    #$0, d0
0101be6c  00000000          ori.b    #$0, d0
0101be70  00000000          ori.b    #$0, d0
0101be74  00000000          ori.b    #$0, d0
0101be78  00000000          ori.b    #$0, d0
0101be7c  00000000          ori.b    #$0, d0
0101be80  00000000          ori.b    #$0, d0
0101be84  00000000          ori.b    #$0, d0
0101be88  00000000          ori.b    #$0, d0
0101be8c  00000000          ori.b    #$0, d0
0101be90  00000000          ori.b    #$0, d0
0101be94  00000000          ori.b    #$0, d0
0101be98  00000000          ori.b    #$0, d0
0101be9c  00000000          ori.b    #$0, d0
0101bea0  00000000          ori.b    #$0, d0
0101bea4  00000000          ori.b    #$0, d0
0101bea8  00000000          ori.b    #$0, d0
0101beac  00000000          ori.b    #$0, d0
0101beb0  00000000          ori.b    #$0, d0
0101beb4  00000000          ori.b    #$0, d0
0101beb8  00000000          ori.b    #$0, d0
0101bebc  00000000          ori.b    #$0, d0
0101bec0  00000000          ori.b    #$0, d0
0101bec4  00000000          ori.b    #$0, d0
0101bec8  00000000          ori.b    #$0, d0
0101becc  00000000          ori.b    #$0, d0
0101bed0  00000000          ori.b    #$0, d0
0101bed4  00000000          ori.b    #$0, d0
0101bed8  00000000          ori.b    #$0, d0
0101bedc  00000000          ori.b    #$0, d0
0101bee0  00000000          ori.b    #$0, d0
0101bee4  00000000          ori.b    #$0, d0
0101bee8  00000000          ori.b    #$0, d0
0101beec  00000000          ori.b    #$0, d0
0101bef0  00000000          ori.b    #$0, d0
0101bef4  00000000          ori.b    #$0, d0
0101bef8  00000000          ori.b    #$0, d0
0101befc  00000000          ori.b    #$0, d0
0101bf00  00000000          ori.b    #$0, d0
0101bf04  00000000          ori.b    #$0, d0
0101bf08  00000000          ori.b    #$0, d0
0101bf0c  00000000          ori.b    #$0, d0
0101bf10  00000000          ori.b    #$0, d0
0101bf14  00000000          ori.b    #$0, d0
0101bf18  00000000          ori.b    #$0, d0
0101bf1c  00000000          ori.b    #$0, d0
0101bf20  00000000          ori.b    #$0, d0
0101bf24  00000000          ori.b    #$0, d0
0101bf28  00000000          ori.b    #$0, d0
0101bf2c  00000000          ori.b    #$0, d0
0101bf30  00000000          ori.b    #$0, d0
0101bf34  00000000          ori.b    #$0, d0
0101bf38  00000000          ori.b    #$0, d0
0101bf3c  00000000          ori.b    #$0, d0
0101bf40  00000000          ori.b    #$0, d0
0101bf44  00000000          ori.b    #$0, d0
0101bf48  00000000          ori.b    #$0, d0
0101bf4c  00000000          ori.b    #$0, d0
0101bf50  00000000          ori.b    #$0, d0
0101bf54  00000000          ori.b    #$0, d0
0101bf58  00000000          ori.b    #$0, d0
0101bf5c  00000000          ori.b    #$0, d0
0101bf60  00000000          ori.b    #$0, d0
0101bf64  00000000          ori.b    #$0, d0
0101bf68  00000000          ori.b    #$0, d0
0101bf6c  00000000          ori.b    #$0, d0
0101bf70  00000000          ori.b    #$0, d0
0101bf74  00000000          ori.b    #$0, d0
0101bf78  00000000          ori.b    #$0, d0
0101bf7c  00000000          ori.b    #$0, d0
0101bf80  00000000          ori.b    #$0, d0
0101bf84  00000000          ori.b    #$0, d0
0101bf88  00000000          ori.b    #$0, d0
0101bf8c  00000000          ori.b    #$0, d0
0101bf90  00000000          ori.b    #$0, d0
0101bf94  00000000          ori.b    #$0, d0
0101bf98  00000000          ori.b    #$0, d0
0101bf9c  00000000          ori.b    #$0, d0
0101bfa0  00000000          ori.b    #$0, d0
0101bfa4  00000000          ori.b    #$0, d0
0101bfa8  00000000          ori.b    #$0, d0
0101bfac  00000000          ori.b    #$0, d0
0101bfb0  00000000          ori.b    #$0, d0
0101bfb4  00000000          ori.b    #$0, d0
0101bfb8  00000000          ori.b    #$0, d0
0101bfbc  00000000          ori.b    #$0, d0
0101bfc0  00000000          ori.b    #$0, d0
0101bfc4  00000000          ori.b    #$0, d0
0101bfc8  00000000          ori.b    #$0, d0
0101bfcc  00000000          ori.b    #$0, d0
0101bfd0  00000000          ori.b    #$0, d0
0101bfd4  00000000          ori.b    #$0, d0
0101bfd8  00000000          ori.b    #$0, d0
0101bfdc  00000000          ori.b    #$0, d0
0101bfe0  00000000          ori.b    #$0, d0
0101bfe4  00000000          ori.b    #$0, d0
0101bfe8  00000000          ori.b    #$0, d0
0101bfec  00000000          ori.b    #$0, d0
0101bff0  00000000          ori.b    #$0, d0
0101bff4  00000000          ori.b    #$0, d0
0101bff8  00000000          ori.b    #$0, d0
0101bffc  00000000          ori.b    #$0, d0
0101c000  00000000          ori.b    #$0, d0
0101c004  00000000          ori.b    #$0, d0
0101c008  00000000          ori.b    #$0, d0
0101c00c  00000000          ori.b    #$0, d0
0101c010  00000000          ori.b    #$0, d0
0101c014  00000000          ori.b    #$0, d0
0101c018  00000000          ori.b    #$0, d0
0101c01c  00000000          ori.b    #$0, d0
0101c020  00000000          ori.b    #$0, d0
0101c024  00000000          ori.b    #$0, d0
0101c028  00000000          ori.b    #$0, d0
0101c02c  00000000          ori.b    #$0, d0
0101c030  00000000          ori.b    #$0, d0
0101c034  00000000          ori.b    #$0, d0
0101c038  00000000          ori.b    #$0, d0
0101c03c  00000000          ori.b    #$0, d0
0101c040  00000000          ori.b    #$0, d0
0101c044  00000000          ori.b    #$0, d0
0101c048  00000000          ori.b    #$0, d0
0101c04c  00000000          ori.b    #$0, d0
0101c050  00000000          ori.b    #$0, d0
0101c054  00000000          ori.b    #$0, d0
0101c058  00000000          ori.b    #$0, d0
0101c05c  00000000          ori.b    #$0, d0
0101c060  00000000          ori.b    #$0, d0
0101c064  00000000          ori.b    #$0, d0
0101c068  00000000          ori.b    #$0, d0
0101c06c  00000000          ori.b    #$0, d0
0101c070  00000000          ori.b    #$0, d0
0101c074  00000000          ori.b    #$0, d0
0101c078  00000000          ori.b    #$0, d0
0101c07c  00000000          ori.b    #$0, d0
0101c080  00000000          ori.b    #$0, d0
0101c084  00000000          ori.b    #$0, d0
0101c088  00000000          ori.b    #$0, d0
0101c08c  00000000          ori.b    #$0, d0
0101c090  00000000          ori.b    #$0, d0
0101c094  00000000          ori.b    #$0, d0
0101c098  00000000          ori.b    #$0, d0
0101c09c  00000000          ori.b    #$0, d0
0101c0a0  00000000          ori.b    #$0, d0
0101c0a4  00000000          ori.b    #$0, d0
0101c0a8  00000000          ori.b    #$0, d0
0101c0ac  00000000          ori.b    #$0, d0
0101c0b0  00000000          ori.b    #$0, d0
0101c0b4  00000000          ori.b    #$0, d0
0101c0b8  00000000          ori.b    #$0, d0
0101c0bc  00000000          ori.b    #$0, d0
0101c0c0  00000000          ori.b    #$0, d0
0101c0c4  00000000          ori.b    #$0, d0
0101c0c8  00000000          ori.b    #$0, d0
0101c0cc  00000000          ori.b    #$0, d0
0101c0d0  00000000          ori.b    #$0, d0
0101c0d4  00000000          ori.b    #$0, d0
0101c0d8  00000000          ori.b    #$0, d0
0101c0dc  00000000          ori.b    #$0, d0
0101c0e0  00000000          ori.b    #$0, d0
0101c0e4  00000000          ori.b    #$0, d0
0101c0e8  00000000          ori.b    #$0, d0
0101c0ec  00000000          ori.b    #$0, d0
0101c0f0  00000000          ori.b    #$0, d0
0101c0f4  00000000          ori.b    #$0, d0
0101c0f8  00000000          ori.b    #$0, d0
0101c0fc  00000000          ori.b    #$0, d0
0101c100  00000000          ori.b    #$0, d0
0101c104  00000000          ori.b    #$0, d0
0101c108  00000000          ori.b    #$0, d0
0101c10c  00000000          ori.b    #$0, d0
0101c110  00000000          ori.b    #$0, d0
0101c114  00000000          ori.b    #$0, d0
0101c118  00000000          ori.b    #$0, d0
0101c11c  00000000          ori.b    #$0, d0
0101c120  00000000          ori.b    #$0, d0
0101c124  00000000          ori.b    #$0, d0
0101c128  00000000          ori.b    #$0, d0
0101c12c  00000000          ori.b    #$0, d0
0101c130  00000000          ori.b    #$0, d0
0101c134  00000000          ori.b    #$0, d0
0101c138  00000000          ori.b    #$0, d0
0101c13c  00000000          ori.b    #$0, d0
0101c140  00000000          ori.b    #$0, d0
0101c144  00000000          ori.b    #$0, d0
0101c148  00000000          ori.b    #$0, d0
0101c14c  00000000          ori.b    #$0, d0
0101c150  00000000          ori.b    #$0, d0
0101c154  00000000          ori.b    #$0, d0
0101c158  00000000          ori.b    #$0, d0
0101c15c  00000000          ori.b    #$0, d0
0101c160  00000000          ori.b    #$0, d0
0101c164  00000000          ori.b    #$0, d0
0101c168  00000000          ori.b    #$0, d0
0101c16c  00000000          ori.b    #$0, d0
0101c170  00000000          ori.b    #$0, d0
0101c174  00000000          ori.b    #$0, d0
0101c178  00000000          ori.b    #$0, d0
0101c17c  00000000          ori.b    #$0, d0
0101c180  00000000          ori.b    #$0, d0
0101c184  00000000          ori.b    #$0, d0
0101c188  00000000          ori.b    #$0, d0
0101c18c  00000000          ori.b    #$0, d0
0101c190  00000000          ori.b    #$0, d0
0101c194  00000000          ori.b    #$0, d0
0101c198  00000000          ori.b    #$0, d0
0101c19c  00000000          ori.b    #$0, d0
0101c1a0  00000000          ori.b    #$0, d0
0101c1a4  00000000          ori.b    #$0, d0
0101c1a8  00000000          ori.b    #$0, d0
0101c1ac  00000000          ori.b    #$0, d0
0101c1b0  00000000          ori.b    #$0, d0
0101c1b4  00000000          ori.b    #$0, d0
0101c1b8  00000000          ori.b    #$0, d0
0101c1bc  00000000          ori.b    #$0, d0
0101c1c0  00000000          ori.b    #$0, d0
0101c1c4  00000000          ori.b    #$0, d0
0101c1c8  00000000          ori.b    #$0, d0
0101c1cc  00000000          ori.b    #$0, d0
0101c1d0  00000000          ori.b    #$0, d0
0101c1d4  00000000          ori.b    #$0, d0
0101c1d8  00000000          ori.b    #$0, d0
0101c1dc  00000000          ori.b    #$0, d0
0101c1e0  00000000          ori.b    #$0, d0
0101c1e4  00000000          ori.b    #$0, d0
0101c1e8  00000000          ori.b    #$0, d0
0101c1ec  00000000          ori.b    #$0, d0
0101c1f0  00000000          ori.b    #$0, d0
0101c1f4  00000000          ori.b    #$0, d0
0101c1f8  00000000          ori.b    #$0, d0
0101c1fc  00000000          ori.b    #$0, d0
0101c200  00000000          ori.b    #$0, d0
0101c204  00000000          ori.b    #$0, d0
0101c208  00000000          ori.b    #$0, d0
0101c20c  00000000          ori.b    #$0, d0
0101c210  00000000          ori.b    #$0, d0
0101c214  00000000          ori.b    #$0, d0
0101c218  00000000          ori.b    #$0, d0
0101c21c  00000000          ori.b    #$0, d0
0101c220  00000000          ori.b    #$0, d0
0101c224  00000000          ori.b    #$0, d0
0101c228  00000000          ori.b    #$0, d0
0101c22c  00000000          ori.b    #$0, d0
0101c230  00000000          ori.b    #$0, d0
0101c234  00000000          ori.b    #$0, d0
0101c238  00000000          ori.b    #$0, d0
0101c23c  00000000          ori.b    #$0, d0
0101c240  00000000          ori.b    #$0, d0
0101c244  00000000          ori.b    #$0, d0
0101c248  00000000          ori.b    #$0, d0
0101c24c  00000000          ori.b    #$0, d0
0101c250  00000000          ori.b    #$0, d0
0101c254  00000000          ori.b    #$0, d0
0101c258  00000000          ori.b    #$0, d0
0101c25c  00000000          ori.b    #$0, d0
0101c260  00000000          ori.b    #$0, d0
0101c264  00000000          ori.b    #$0, d0
0101c268  00000000          ori.b    #$0, d0
0101c26c  00000000          ori.b    #$0, d0
0101c270  00000000          ori.b    #$0, d0
0101c274  00000000          ori.b    #$0, d0
0101c278  00000000          ori.b    #$0, d0
0101c27c  00000000          ori.b    #$0, d0
0101c280  00000000          ori.b    #$0, d0
0101c284  00000000          ori.b    #$0, d0
0101c288  00000000          ori.b    #$0, d0
0101c28c  00000000          ori.b    #$0, d0
0101c290  00000000          ori.b    #$0, d0
0101c294  00000000          ori.b    #$0, d0
0101c298  00000000          ori.b    #$0, d0
0101c29c  00000000          ori.b    #$0, d0
0101c2a0  00000000          ori.b    #$0, d0
0101c2a4  00000000          ori.b    #$0, d0
0101c2a8  00000000          ori.b    #$0, d0
0101c2ac  00000000          ori.b    #$0, d0
0101c2b0  00000000          ori.b    #$0, d0
0101c2b4  00000000          ori.b    #$0, d0
0101c2b8  00000000          ori.b    #$0, d0
0101c2bc  00000000          ori.b    #$0, d0
0101c2c0  00000000          ori.b    #$0, d0
0101c2c4  00000000          ori.b    #$0, d0
0101c2c8  00000000          ori.b    #$0, d0
0101c2cc  00000000          ori.b    #$0, d0
0101c2d0  00000000          ori.b    #$0, d0
0101c2d4  00000000          ori.b    #$0, d0
0101c2d8  00000000          ori.b    #$0, d0
0101c2dc  00000000          ori.b    #$0, d0
0101c2e0  00000000          ori.b    #$0, d0
0101c2e4  00000000          ori.b    #$0, d0
0101c2e8  00000000          ori.b    #$0, d0
0101c2ec  00000000          ori.b    #$0, d0
0101c2f0  00000000          ori.b    #$0, d0
0101c2f4  00000000          ori.b    #$0, d0
0101c2f8  00000000          ori.b    #$0, d0
0101c2fc  00000000          ori.b    #$0, d0
0101c300  00000000          ori.b    #$0, d0
0101c304  00000000          ori.b    #$0, d0
0101c308  00000000          ori.b    #$0, d0
0101c30c  00000000          ori.b    #$0, d0
0101c310  00000000          ori.b    #$0, d0
0101c314  00000000          ori.b    #$0, d0
0101c318  00000000          ori.b    #$0, d0
0101c31c  00000000          ori.b    #$0, d0
0101c320  00000000          ori.b    #$0, d0
0101c324  00000000          ori.b    #$0, d0
0101c328  00000000          ori.b    #$0, d0
0101c32c  00000000          ori.b    #$0, d0
0101c330  00000000          ori.b    #$0, d0
0101c334  00000000          ori.b    #$0, d0
0101c338  00000000          ori.b    #$0, d0
0101c33c  00000000          ori.b    #$0, d0
0101c340  00000000          ori.b    #$0, d0
0101c344  00000000          ori.b    #$0, d0
0101c348  00000000          ori.b    #$0, d0
0101c34c  00000000          ori.b    #$0, d0
0101c350  00000000          ori.b    #$0, d0
0101c354  00000000          ori.b    #$0, d0
0101c358  00000000          ori.b    #$0, d0
0101c35c  00000000          ori.b    #$0, d0
0101c360  00000000          ori.b    #$0, d0
0101c364  00000000          ori.b    #$0, d0
0101c368  00000000          ori.b    #$0, d0
0101c36c  00000000          ori.b    #$0, d0
0101c370  00000000          ori.b    #$0, d0
0101c374  00000000          ori.b    #$0, d0
0101c378  00000000          ori.b    #$0, d0
0101c37c  00000000          ori.b    #$0, d0
0101c380  00000000          ori.b    #$0, d0
0101c384  00000000          ori.b    #$0, d0
0101c388  00000000          ori.b    #$0, d0
0101c38c  00000000          ori.b    #$0, d0
0101c390  00000000          ori.b    #$0, d0
0101c394  00000000          ori.b    #$0, d0
0101c398  00000000          ori.b    #$0, d0
0101c39c  00000000          ori.b    #$0, d0
0101c3a0  00000000          ori.b    #$0, d0
0101c3a4  00000000          ori.b    #$0, d0
0101c3a8  00000000          ori.b    #$0, d0
0101c3ac  00000000          ori.b    #$0, d0
0101c3b0  00000000          ori.b    #$0, d0
0101c3b4  00000000          ori.b    #$0, d0
0101c3b8  00000000          ori.b    #$0, d0
0101c3bc  00000000          ori.b    #$0, d0
0101c3c0  00000000          ori.b    #$0, d0
0101c3c4  00000000          ori.b    #$0, d0
0101c3c8  00000000          ori.b    #$0, d0
0101c3cc  00000000          ori.b    #$0, d0
0101c3d0  00000000          ori.b    #$0, d0
0101c3d4  00000000          ori.b    #$0, d0
0101c3d8  00000000          ori.b    #$0, d0
0101c3dc  00000000          ori.b    #$0, d0
0101c3e0  00000000          ori.b    #$0, d0
0101c3e4  00000000          ori.b    #$0, d0
0101c3e8  00000000          ori.b    #$0, d0
0101c3ec  00000000          ori.b    #$0, d0
0101c3f0  00000000          ori.b    #$0, d0
0101c3f4  00000000          ori.b    #$0, d0
0101c3f8  00000000          ori.b    #$0, d0
0101c3fc  00000000          ori.b    #$0, d0
0101c400  00000000          ori.b    #$0, d0
0101c404  00000000          ori.b    #$0, d0
0101c408  00000000          ori.b    #$0, d0
0101c40c  00000000          ori.b    #$0, d0
0101c410  00000000          ori.b    #$0, d0
0101c414  00000000          ori.b    #$0, d0
0101c418  00000000          ori.b    #$0, d0
0101c41c  00000000          ori.b    #$0, d0
0101c420  00000000          ori.b    #$0, d0
0101c424  00000000          ori.b    #$0, d0
0101c428  00000000          ori.b    #$0, d0
0101c42c  00000000          ori.b    #$0, d0
0101c430  00000000          ori.b    #$0, d0
0101c434  00000000          ori.b    #$0, d0
0101c438  00000000          ori.b    #$0, d0
0101c43c  00000000          ori.b    #$0, d0
0101c440  00000000          ori.b    #$0, d0
0101c444  00000000          ori.b    #$0, d0
0101c448  00000000          ori.b    #$0, d0
0101c44c  00000000          ori.b    #$0, d0
0101c450  00000000          ori.b    #$0, d0
0101c454  00000000          ori.b    #$0, d0
0101c458  00000000          ori.b    #$0, d0
0101c45c  00000000          ori.b    #$0, d0
0101c460  00000000          ori.b    #$0, d0
0101c464  00000000          ori.b    #$0, d0
0101c468  00000000          ori.b    #$0, d0
0101c46c  00000000          ori.b    #$0, d0
0101c470  00000000          ori.b    #$0, d0
0101c474  00000000          ori.b    #$0, d0
0101c478  00000000          ori.b    #$0, d0
0101c47c  00000000          ori.b    #$0, d0
0101c480  00000000          ori.b    #$0, d0
0101c484  00000000          ori.b    #$0, d0
0101c488  00000000          ori.b    #$0, d0
0101c48c  00000000          ori.b    #$0, d0
0101c490  00000000          ori.b    #$0, d0
0101c494  00000000          ori.b    #$0, d0
0101c498  00000000          ori.b    #$0, d0
0101c49c  00000000          ori.b    #$0, d0
0101c4a0  00000000          ori.b    #$0, d0
0101c4a4  00000000          ori.b    #$0, d0
0101c4a8  00000000          ori.b    #$0, d0
0101c4ac  00000000          ori.b    #$0, d0
0101c4b0  00000000          ori.b    #$0, d0
0101c4b4  00000000          ori.b    #$0, d0
0101c4b8  00000000          ori.b    #$0, d0
0101c4bc  00000000          ori.b    #$0, d0
0101c4c0  00000000          ori.b    #$0, d0
0101c4c4  00000000          ori.b    #$0, d0
0101c4c8  00000000          ori.b    #$0, d0
0101c4cc  00000000          ori.b    #$0, d0
0101c4d0  00000000          ori.b    #$0, d0
0101c4d4  00000000          ori.b    #$0, d0
0101c4d8  00000000          ori.b    #$0, d0
0101c4dc  00000000          ori.b    #$0, d0
0101c4e0  00000000          ori.b    #$0, d0
0101c4e4  00000000          ori.b    #$0, d0
0101c4e8  00000000          ori.b    #$0, d0
0101c4ec  00000000          ori.b    #$0, d0
0101c4f0  00000000          ori.b    #$0, d0
0101c4f4  00000000          ori.b    #$0, d0
0101c4f8  00000000          ori.b    #$0, d0
0101c4fc  00000000          ori.b    #$0, d0
0101c500  00000000          ori.b    #$0, d0
0101c504  00000000          ori.b    #$0, d0
0101c508  00000000          ori.b    #$0, d0
0101c50c  00000000          ori.b    #$0, d0
0101c510  00000000          ori.b    #$0, d0
0101c514  00000000          ori.b    #$0, d0
0101c518  00000000          ori.b    #$0, d0
0101c51c  00000000          ori.b    #$0, d0
0101c520  00000000          ori.b    #$0, d0
0101c524  00000000          ori.b    #$0, d0
0101c528  00000000          ori.b    #$0, d0
0101c52c  00000000          ori.b    #$0, d0
0101c530  00000000          ori.b    #$0, d0
0101c534  00000000          ori.b    #$0, d0
0101c538  00000000          ori.b    #$0, d0
0101c53c  00000000          ori.b    #$0, d0
0101c540  00000000          ori.b    #$0, d0
0101c544  00000000          ori.b    #$0, d0
0101c548  00000000          ori.b    #$0, d0
0101c54c  00000000          ori.b    #$0, d0
0101c550  00000000          ori.b    #$0, d0
0101c554  00000000          ori.b    #$0, d0
0101c558  00000000          ori.b    #$0, d0
0101c55c  00000000          ori.b    #$0, d0
0101c560  00000000          ori.b    #$0, d0
0101c564  00000000          ori.b    #$0, d0
0101c568  00000000          ori.b    #$0, d0
0101c56c  00000000          ori.b    #$0, d0
0101c570  00000000          ori.b    #$0, d0
0101c574  00000000          ori.b    #$0, d0
0101c578  00000000          ori.b    #$0, d0
0101c57c  00000000          ori.b    #$0, d0
0101c580  00000000          ori.b    #$0, d0
0101c584  00000000          ori.b    #$0, d0
0101c588  00000000          ori.b    #$0, d0
0101c58c  00000000          ori.b    #$0, d0
0101c590  00000000          ori.b    #$0, d0
0101c594  00000000          ori.b    #$0, d0
0101c598  00000000          ori.b    #$0, d0
0101c59c  00000000          ori.b    #$0, d0
0101c5a0  00000000          ori.b    #$0, d0
0101c5a4  00000000          ori.b    #$0, d0
0101c5a8  00000000          ori.b    #$0, d0
0101c5ac  00000000          ori.b    #$0, d0
0101c5b0  00000000          ori.b    #$0, d0
0101c5b4  00000000          ori.b    #$0, d0
0101c5b8  00000000          ori.b    #$0, d0
0101c5bc  00000000          ori.b    #$0, d0
0101c5c0  00000000          ori.b    #$0, d0
0101c5c4  00000000          ori.b    #$0, d0
0101c5c8  00000000          ori.b    #$0, d0
0101c5cc  00000000          ori.b    #$0, d0
0101c5d0  00000000          ori.b    #$0, d0
0101c5d4  00000000          ori.b    #$0, d0
0101c5d8  00000000          ori.b    #$0, d0
0101c5dc  00000000          ori.b    #$0, d0
0101c5e0  00000000          ori.b    #$0, d0
0101c5e4  00000000          ori.b    #$0, d0
0101c5e8  00000000          ori.b    #$0, d0
0101c5ec  00000000          ori.b    #$0, d0
0101c5f0  00000000          ori.b    #$0, d0
0101c5f4  00000000          ori.b    #$0, d0
0101c5f8  00000000          ori.b    #$0, d0
0101c5fc  00000000          ori.b    #$0, d0
0101c600  00000000          ori.b    #$0, d0
0101c604  00000000          ori.b    #$0, d0
0101c608  00000000          ori.b    #$0, d0
0101c60c  00000000          ori.b    #$0, d0
0101c610  00000000          ori.b    #$0, d0
0101c614  00000000          ori.b    #$0, d0
0101c618  00000000          ori.b    #$0, d0
0101c61c  00000000          ori.b    #$0, d0
0101c620  00000000          ori.b    #$0, d0
0101c624  00000000          ori.b    #$0, d0
0101c628  00000000          ori.b    #$0, d0
0101c62c  00000000          ori.b    #$0, d0
0101c630  00000000          ori.b    #$0, d0
0101c634  00000000          ori.b    #$0, d0
0101c638  00000000          ori.b    #$0, d0
0101c63c  00000000          ori.b    #$0, d0
0101c640  00000000          ori.b    #$0, d0
0101c644  00000000          ori.b    #$0, d0
0101c648  00000000          ori.b    #$0, d0
0101c64c  00000000          ori.b    #$0, d0
0101c650  00000000          ori.b    #$0, d0
0101c654  00000000          ori.b    #$0, d0
0101c658  00000000          ori.b    #$0, d0
0101c65c  00000000          ori.b    #$0, d0
0101c660  00000000          ori.b    #$0, d0
0101c664  00000000          ori.b    #$0, d0
0101c668  00000000          ori.b    #$0, d0
0101c66c  00000000          ori.b    #$0, d0
0101c670  00000000          ori.b    #$0, d0
0101c674  00000000          ori.b    #$0, d0
0101c678  00000000          ori.b    #$0, d0
0101c67c  00000000          ori.b    #$0, d0
0101c680  00000000          ori.b    #$0, d0
0101c684  00000000          ori.b    #$0, d0
0101c688  00000000          ori.b    #$0, d0
0101c68c  00000000          ori.b    #$0, d0
0101c690  00000000          ori.b    #$0, d0
0101c694  00000000          ori.b    #$0, d0
0101c698  00000000          ori.b    #$0, d0
0101c69c  00000000          ori.b    #$0, d0
0101c6a0  00000000          ori.b    #$0, d0
0101c6a4  00000000          ori.b    #$0, d0
0101c6a8  00000000          ori.b    #$0, d0
0101c6ac  00000000          ori.b    #$0, d0
0101c6b0  00000000          ori.b    #$0, d0
0101c6b4  00000000          ori.b    #$0, d0
0101c6b8  00000000          ori.b    #$0, d0
0101c6bc  00000000          ori.b    #$0, d0
0101c6c0  00000000          ori.b    #$0, d0
0101c6c4  00000000          ori.b    #$0, d0
0101c6c8  00000000          ori.b    #$0, d0
0101c6cc  00000000          ori.b    #$0, d0
0101c6d0  00000000          ori.b    #$0, d0
0101c6d4  00000000          ori.b    #$0, d0
0101c6d8  00000000          ori.b    #$0, d0
0101c6dc  00000000          ori.b    #$0, d0
0101c6e0  00000000          ori.b    #$0, d0
0101c6e4  00000000          ori.b    #$0, d0
0101c6e8  00000000          ori.b    #$0, d0
0101c6ec  00000000          ori.b    #$0, d0
0101c6f0  00000000          ori.b    #$0, d0
0101c6f4  00000000          ori.b    #$0, d0
0101c6f8  00000000          ori.b    #$0, d0
0101c6fc  00000000          ori.b    #$0, d0
0101c700  00000000          ori.b    #$0, d0
0101c704  00000000          ori.b    #$0, d0
0101c708  00000000          ori.b    #$0, d0
0101c70c  00000000          ori.b    #$0, d0
0101c710  00000000          ori.b    #$0, d0
0101c714  00000000          ori.b    #$0, d0
0101c718  00000000          ori.b    #$0, d0
0101c71c  00000000          ori.b    #$0, d0
0101c720  00000000          ori.b    #$0, d0
0101c724  00000000          ori.b    #$0, d0
0101c728  00000000          ori.b    #$0, d0
0101c72c  00000000          ori.b    #$0, d0
0101c730  00000000          ori.b    #$0, d0
0101c734  00000000          ori.b    #$0, d0
0101c738  00000000          ori.b    #$0, d0
0101c73c  00000000          ori.b    #$0, d0
0101c740  00000000          ori.b    #$0, d0
0101c744  00000000          ori.b    #$0, d0
0101c748  00000000          ori.b    #$0, d0
0101c74c  00000000          ori.b    #$0, d0
0101c750  00000000          ori.b    #$0, d0
0101c754  00000000          ori.b    #$0, d0
0101c758  00000000          ori.b    #$0, d0
0101c75c  00000000          ori.b    #$0, d0
0101c760  00000000          ori.b    #$0, d0
0101c764  00000000          ori.b    #$0, d0
0101c768  00000000          ori.b    #$0, d0
0101c76c  00000000          ori.b    #$0, d0
0101c770  00000000          ori.b    #$0, d0
0101c774  00000000          ori.b    #$0, d0
0101c778  00000000          ori.b    #$0, d0
0101c77c  00000000          ori.b    #$0, d0
0101c780  00000000          ori.b    #$0, d0
0101c784  00000000          ori.b    #$0, d0
0101c788  00000000          ori.b    #$0, d0
0101c78c  00000000          ori.b    #$0, d0
0101c790  00000000          ori.b    #$0, d0
0101c794  00000000          ori.b    #$0, d0
0101c798  00000000          ori.b    #$0, d0
0101c79c  00000000          ori.b    #$0, d0
0101c7a0  00000000          ori.b    #$0, d0
0101c7a4  00000000          ori.b    #$0, d0
0101c7a8  00000000          ori.b    #$0, d0
0101c7ac  00000000          ori.b    #$0, d0
0101c7b0  00000000          ori.b    #$0, d0
0101c7b4  00000000          ori.b    #$0, d0
0101c7b8  00000000          ori.b    #$0, d0
0101c7bc  00000000          ori.b    #$0, d0
0101c7c0  00000000          ori.b    #$0, d0
0101c7c4  00000000          ori.b    #$0, d0
0101c7c8  00000000          ori.b    #$0, d0
0101c7cc  00000000          ori.b    #$0, d0
0101c7d0  00000000          ori.b    #$0, d0
0101c7d4  00000000          ori.b    #$0, d0
0101c7d8  00000000          ori.b    #$0, d0
0101c7dc  00000000          ori.b    #$0, d0
0101c7e0  00000000          ori.b    #$0, d0
0101c7e4  00000000          ori.b    #$0, d0
0101c7e8  00000000          ori.b    #$0, d0
0101c7ec  00000000          ori.b    #$0, d0
0101c7f0  00000000          ori.b    #$0, d0
0101c7f4  00000000          ori.b    #$0, d0
0101c7f8  00000000          ori.b    #$0, d0
0101c7fc  00000000          ori.b    #$0, d0
0101c800  00000000          ori.b    #$0, d0
0101c804  00000000          ori.b    #$0, d0
0101c808  00000000          ori.b    #$0, d0
0101c80c  00000000          ori.b    #$0, d0
0101c810  00000000          ori.b    #$0, d0
0101c814  00000000          ori.b    #$0, d0
0101c818  00000000          ori.b    #$0, d0
0101c81c  00000000          ori.b    #$0, d0
0101c820  00000000          ori.b    #$0, d0
0101c824  00000000          ori.b    #$0, d0
0101c828  00000000          ori.b    #$0, d0
0101c82c  00000000          ori.b    #$0, d0
0101c830  00000000          ori.b    #$0, d0
0101c834  00000000          ori.b    #$0, d0
0101c838  00000000          ori.b    #$0, d0
0101c83c  00000000          ori.b    #$0, d0
0101c840  00000000          ori.b    #$0, d0
0101c844  00000000          ori.b    #$0, d0
0101c848  00000000          ori.b    #$0, d0
0101c84c  00000000          ori.b    #$0, d0
0101c850  00000000          ori.b    #$0, d0
0101c854  00000000          ori.b    #$0, d0
0101c858  00000000          ori.b    #$0, d0
0101c85c  00000000          ori.b    #$0, d0
0101c860  00000000          ori.b    #$0, d0
0101c864  00000000          ori.b    #$0, d0
0101c868  00000000          ori.b    #$0, d0
0101c86c  00000000          ori.b    #$0, d0
0101c870  00000000          ori.b    #$0, d0
0101c874  00000000          ori.b    #$0, d0
0101c878  00000000          ori.b    #$0, d0
0101c87c  00000000          ori.b    #$0, d0
0101c880  00000000          ori.b    #$0, d0
0101c884  00000000          ori.b    #$0, d0
0101c888  00000000          ori.b    #$0, d0
0101c88c  00000000          ori.b    #$0, d0
0101c890  00000000          ori.b    #$0, d0
0101c894  00000000          ori.b    #$0, d0
0101c898  00000000          ori.b    #$0, d0
0101c89c  00000000          ori.b    #$0, d0
0101c8a0  00000000          ori.b    #$0, d0
0101c8a4  00000000          ori.b    #$0, d0
0101c8a8  00000000          ori.b    #$0, d0
0101c8ac  00000000          ori.b    #$0, d0
0101c8b0  00000000          ori.b    #$0, d0
0101c8b4  00000000          ori.b    #$0, d0
0101c8b8  00000000          ori.b    #$0, d0
0101c8bc  00000000          ori.b    #$0, d0
0101c8c0  00000000          ori.b    #$0, d0
0101c8c4  00000000          ori.b    #$0, d0
0101c8c8  00000000          ori.b    #$0, d0
0101c8cc  00000000          ori.b    #$0, d0
0101c8d0  00000000          ori.b    #$0, d0
0101c8d4  00000000          ori.b    #$0, d0
0101c8d8  00000000          ori.b    #$0, d0
0101c8dc  00000000          ori.b    #$0, d0
0101c8e0  00000000          ori.b    #$0, d0
0101c8e4  00000000          ori.b    #$0, d0
0101c8e8  00000000          ori.b    #$0, d0
0101c8ec  00000000          ori.b    #$0, d0
0101c8f0  00000000          ori.b    #$0, d0
0101c8f4  00000000          ori.b    #$0, d0
0101c8f8  00000000          ori.b    #$0, d0
0101c8fc  00000000          ori.b    #$0, d0
0101c900  00000000          ori.b    #$0, d0
0101c904  00000000          ori.b    #$0, d0
0101c908  00000000          ori.b    #$0, d0
0101c90c  00000000          ori.b    #$0, d0
0101c910  00000000          ori.b    #$0, d0
0101c914  00000000          ori.b    #$0, d0
0101c918  00000000          ori.b    #$0, d0
0101c91c  00000000          ori.b    #$0, d0
0101c920  00000000          ori.b    #$0, d0
0101c924  00000000          ori.b    #$0, d0
0101c928  00000000          ori.b    #$0, d0
0101c92c  00000000          ori.b    #$0, d0
0101c930  00000000          ori.b    #$0, d0
0101c934  00000000          ori.b    #$0, d0
0101c938  00000000          ori.b    #$0, d0
0101c93c  00000000          ori.b    #$0, d0
0101c940  00000000          ori.b    #$0, d0
0101c944  00000000          ori.b    #$0, d0
0101c948  00000000          ori.b    #$0, d0
0101c94c  00000000          ori.b    #$0, d0
0101c950  00000000          ori.b    #$0, d0
0101c954  00000000          ori.b    #$0, d0
0101c958  00000000          ori.b    #$0, d0
0101c95c  00000000          ori.b    #$0, d0
0101c960  00000000          ori.b    #$0, d0
0101c964  00000000          ori.b    #$0, d0
0101c968  00000000          ori.b    #$0, d0
0101c96c  00000000          ori.b    #$0, d0
0101c970  00000000          ori.b    #$0, d0
0101c974  00000000          ori.b    #$0, d0
0101c978  00000000          ori.b    #$0, d0
0101c97c  00000000          ori.b    #$0, d0
0101c980  00000000          ori.b    #$0, d0
0101c984  00000000          ori.b    #$0, d0
0101c988  00000000          ori.b    #$0, d0
0101c98c  00000000          ori.b    #$0, d0
0101c990  00000000          ori.b    #$0, d0
0101c994  00000000          ori.b    #$0, d0
0101c998  00000000          ori.b    #$0, d0
0101c99c  00000000          ori.b    #$0, d0
0101c9a0  00000000          ori.b    #$0, d0
0101c9a4  00000000          ori.b    #$0, d0
0101c9a8  00000000          ori.b    #$0, d0
0101c9ac  00000000          ori.b    #$0, d0
0101c9b0  00000000          ori.b    #$0, d0
0101c9b4  00000000          ori.b    #$0, d0
0101c9b8  00000000          ori.b    #$0, d0
0101c9bc  00000000          ori.b    #$0, d0
0101c9c0  00000000          ori.b    #$0, d0
0101c9c4  00000000          ori.b    #$0, d0
0101c9c8  00000000          ori.b    #$0, d0
0101c9cc  00000000          ori.b    #$0, d0
0101c9d0  00000000          ori.b    #$0, d0
0101c9d4  00000000          ori.b    #$0, d0
0101c9d8  00000000          ori.b    #$0, d0
0101c9dc  00000000          ori.b    #$0, d0
0101c9e0  00000000          ori.b    #$0, d0
0101c9e4  00000000          ori.b    #$0, d0
0101c9e8  00000000          ori.b    #$0, d0
0101c9ec  00000000          ori.b    #$0, d0
0101c9f0  00000000          ori.b    #$0, d0
0101c9f4  00000000          ori.b    #$0, d0
0101c9f8  00000000          ori.b    #$0, d0
0101c9fc  00000000          ori.b    #$0, d0
0101ca00  00000000          ori.b    #$0, d0
0101ca04  00000000          ori.b    #$0, d0
0101ca08  00000000          ori.b    #$0, d0
0101ca0c  00000000          ori.b    #$0, d0
0101ca10  00000000          ori.b    #$0, d0
0101ca14  00000000          ori.b    #$0, d0
0101ca18  00000000          ori.b    #$0, d0
0101ca1c  00000000          ori.b    #$0, d0
0101ca20  00000000          ori.b    #$0, d0
0101ca24  00000000          ori.b    #$0, d0
0101ca28  00000000          ori.b    #$0, d0
0101ca2c  00000000          ori.b    #$0, d0
0101ca30  00000000          ori.b    #$0, d0
0101ca34  00000000          ori.b    #$0, d0
0101ca38  00000000          ori.b    #$0, d0
0101ca3c  00000000          ori.b    #$0, d0
0101ca40  00000000          ori.b    #$0, d0
0101ca44  00000000          ori.b    #$0, d0
0101ca48  00000000          ori.b    #$0, d0
0101ca4c  00000000          ori.b    #$0, d0
0101ca50  00000000          ori.b    #$0, d0
0101ca54  00000000          ori.b    #$0, d0
0101ca58  00000000          ori.b    #$0, d0
0101ca5c  00000000          ori.b    #$0, d0
0101ca60  00000000          ori.b    #$0, d0
0101ca64  00000000          ori.b    #$0, d0
0101ca68  00000000          ori.b    #$0, d0
0101ca6c  00000000          ori.b    #$0, d0
0101ca70  00000000          ori.b    #$0, d0
0101ca74  00000000          ori.b    #$0, d0
0101ca78  00000000          ori.b    #$0, d0
0101ca7c  00000000          ori.b    #$0, d0
0101ca80  00000000          ori.b    #$0, d0
0101ca84  00000000          ori.b    #$0, d0
0101ca88  00000000          ori.b    #$0, d0
0101ca8c  00000000          ori.b    #$0, d0
0101ca90  00000000          ori.b    #$0, d0
0101ca94  00000000          ori.b    #$0, d0
0101ca98  00000000          ori.b    #$0, d0
0101ca9c  00000000          ori.b    #$0, d0
0101caa0  00000000          ori.b    #$0, d0
0101caa4  00000000          ori.b    #$0, d0
0101caa8  00000000          ori.b    #$0, d0
0101caac  00000000          ori.b    #$0, d0
0101cab0  00000000          ori.b    #$0, d0
0101cab4  00000000          ori.b    #$0, d0
0101cab8  00000000          ori.b    #$0, d0
0101cabc  00000000          ori.b    #$0, d0
0101cac0  00000000          ori.b    #$0, d0
0101cac4  00000000          ori.b    #$0, d0
0101cac8  00000000          ori.b    #$0, d0
0101cacc  00000000          ori.b    #$0, d0
0101cad0  00000000          ori.b    #$0, d0
0101cad4  00000000          ori.b    #$0, d0
0101cad8  00000000          ori.b    #$0, d0
0101cadc  00000000          ori.b    #$0, d0
0101cae0  00000000          ori.b    #$0, d0
0101cae4  00000000          ori.b    #$0, d0
0101cae8  00000000          ori.b    #$0, d0
0101caec  00000000          ori.b    #$0, d0
0101caf0  00000000          ori.b    #$0, d0
0101caf4  00000000          ori.b    #$0, d0
0101caf8  00000000          ori.b    #$0, d0
0101cafc  00000000          ori.b    #$0, d0
0101cb00  00000000          ori.b    #$0, d0
0101cb04  00000000          ori.b    #$0, d0
0101cb08  00000000          ori.b    #$0, d0
0101cb0c  00000000          ori.b    #$0, d0
0101cb10  00000000          ori.b    #$0, d0
0101cb14  00000000          ori.b    #$0, d0
0101cb18  00000000          ori.b    #$0, d0
0101cb1c  00000000          ori.b    #$0, d0
0101cb20  00000000          ori.b    #$0, d0
0101cb24  00000000          ori.b    #$0, d0
0101cb28  00000000          ori.b    #$0, d0
0101cb2c  00000000          ori.b    #$0, d0
0101cb30  00000000          ori.b    #$0, d0
0101cb34  00000000          ori.b    #$0, d0
0101cb38  00000000          ori.b    #$0, d0
0101cb3c  00000000          ori.b    #$0, d0
0101cb40  00000000          ori.b    #$0, d0
0101cb44  00000000          ori.b    #$0, d0
0101cb48  00000000          ori.b    #$0, d0
0101cb4c  00000000          ori.b    #$0, d0
0101cb50  00000000          ori.b    #$0, d0
0101cb54  00000000          ori.b    #$0, d0
0101cb58  00000000          ori.b    #$0, d0
0101cb5c  00000000          ori.b    #$0, d0
0101cb60  00000000          ori.b    #$0, d0
0101cb64  00000000          ori.b    #$0, d0
0101cb68  00000000          ori.b    #$0, d0
0101cb6c  00000000          ori.b    #$0, d0
0101cb70  00000000          ori.b    #$0, d0
0101cb74  00000000          ori.b    #$0, d0
0101cb78  00000000          ori.b    #$0, d0
0101cb7c  00000000          ori.b    #$0, d0
0101cb80  00000000          ori.b    #$0, d0
0101cb84  00000000          ori.b    #$0, d0
0101cb88  00000000          ori.b    #$0, d0
0101cb8c  00000000          ori.b    #$0, d0
0101cb90  00000000          ori.b    #$0, d0
0101cb94  00000000          ori.b    #$0, d0
0101cb98  00000000          ori.b    #$0, d0
0101cb9c  00000000          ori.b    #$0, d0
0101cba0  00000000          ori.b    #$0, d0
0101cba4  00000000          ori.b    #$0, d0
0101cba8  00000000          ori.b    #$0, d0
0101cbac  00000000          ori.b    #$0, d0
0101cbb0  00000000          ori.b    #$0, d0
0101cbb4  00000000          ori.b    #$0, d0
0101cbb8  00000000          ori.b    #$0, d0
0101cbbc  00000000          ori.b    #$0, d0
0101cbc0  00000000          ori.b    #$0, d0
0101cbc4  00000000          ori.b    #$0, d0
0101cbc8  00000000          ori.b    #$0, d0
0101cbcc  00000000          ori.b    #$0, d0
0101cbd0  00000000          ori.b    #$0, d0
0101cbd4  00000000          ori.b    #$0, d0
0101cbd8  00000000          ori.b    #$0, d0
0101cbdc  00000000          ori.b    #$0, d0
0101cbe0  00000000          ori.b    #$0, d0
0101cbe4  00000000          ori.b    #$0, d0
0101cbe8  00000000          ori.b    #$0, d0
0101cbec  00000000          ori.b    #$0, d0
0101cbf0  00000000          ori.b    #$0, d0
0101cbf4  00000000          ori.b    #$0, d0
0101cbf8  00000000          ori.b    #$0, d0
0101cbfc  00000000          ori.b    #$0, d0
0101cc00  00000000          ori.b    #$0, d0
0101cc04  00000000          ori.b    #$0, d0
0101cc08  00000000          ori.b    #$0, d0
0101cc0c  00000000          ori.b    #$0, d0
0101cc10  00000000          ori.b    #$0, d0
0101cc14  00000000          ori.b    #$0, d0
0101cc18  00000000          ori.b    #$0, d0
0101cc1c  00000000          ori.b    #$0, d0
0101cc20  00000000          ori.b    #$0, d0
0101cc24  00000000          ori.b    #$0, d0
0101cc28  00000000          ori.b    #$0, d0
0101cc2c  00000000          ori.b    #$0, d0
0101cc30  00000000          ori.b    #$0, d0
0101cc34  00000000          ori.b    #$0, d0
0101cc38  00000000          ori.b    #$0, d0
0101cc3c  00000000          ori.b    #$0, d0
0101cc40  00000000          ori.b    #$0, d0
0101cc44  00000000          ori.b    #$0, d0
0101cc48  00000000          ori.b    #$0, d0
0101cc4c  00000000          ori.b    #$0, d0
0101cc50  00000000          ori.b    #$0, d0
0101cc54  00000000          ori.b    #$0, d0
0101cc58  00000000          ori.b    #$0, d0
0101cc5c  00000000          ori.b    #$0, d0
0101cc60  00000000          ori.b    #$0, d0
0101cc64  00000000          ori.b    #$0, d0
0101cc68  00000000          ori.b    #$0, d0
0101cc6c  00000000          ori.b    #$0, d0
0101cc70  00000000          ori.b    #$0, d0
0101cc74  00000000          ori.b    #$0, d0
0101cc78  00000000          ori.b    #$0, d0
0101cc7c  00000000          ori.b    #$0, d0
0101cc80  00000000          ori.b    #$0, d0
0101cc84  00000000          ori.b    #$0, d0
0101cc88  00000000          ori.b    #$0, d0
0101cc8c  00000000          ori.b    #$0, d0
0101cc90  00000000          ori.b    #$0, d0
0101cc94  00000000          ori.b    #$0, d0
0101cc98  00000000          ori.b    #$0, d0
0101cc9c  00000000          ori.b    #$0, d0
0101cca0  00000000          ori.b    #$0, d0
0101cca4  00000000          ori.b    #$0, d0
0101cca8  00000000          ori.b    #$0, d0
0101ccac  00000000          ori.b    #$0, d0
0101ccb0  00000000          ori.b    #$0, d0
0101ccb4  00000000          ori.b    #$0, d0
0101ccb8  00000000          ori.b    #$0, d0
0101ccbc  00000000          ori.b    #$0, d0
0101ccc0  00000000          ori.b    #$0, d0
0101ccc4  00000000          ori.b    #$0, d0
0101ccc8  00000000          ori.b    #$0, d0
0101cccc  00000000          ori.b    #$0, d0
0101ccd0  00000000          ori.b    #$0, d0
0101ccd4  00000000          ori.b    #$0, d0
0101ccd8  00000000          ori.b    #$0, d0
0101ccdc  00000000          ori.b    #$0, d0
0101cce0  00000000          ori.b    #$0, d0
0101cce4  00000000          ori.b    #$0, d0
0101cce8  00000000          ori.b    #$0, d0
0101ccec  00000000          ori.b    #$0, d0
0101ccf0  00000000          ori.b    #$0, d0
0101ccf4  00000000          ori.b    #$0, d0
0101ccf8  00000000          ori.b    #$0, d0
0101ccfc  00000000          ori.b    #$0, d0
0101cd00  00000000          ori.b    #$0, d0
0101cd04  00000000          ori.b    #$0, d0
0101cd08  00000000          ori.b    #$0, d0
0101cd0c  00000000          ori.b    #$0, d0
0101cd10  00000000          ori.b    #$0, d0
0101cd14  00000000          ori.b    #$0, d0
0101cd18  00000000          ori.b    #$0, d0
0101cd1c  00000000          ori.b    #$0, d0
0101cd20  00000000          ori.b    #$0, d0
0101cd24  00000000          ori.b    #$0, d0
0101cd28  00000000          ori.b    #$0, d0
0101cd2c  00000000          ori.b    #$0, d0
0101cd30  00000000          ori.b    #$0, d0
0101cd34  00000000          ori.b    #$0, d0
0101cd38  00000000          ori.b    #$0, d0
0101cd3c  00000000          ori.b    #$0, d0
0101cd40  00000000          ori.b    #$0, d0
0101cd44  00000000          ori.b    #$0, d0
0101cd48  00000000          ori.b    #$0, d0
0101cd4c  00000000          ori.b    #$0, d0
0101cd50  00000000          ori.b    #$0, d0
0101cd54  00000000          ori.b    #$0, d0
0101cd58  00000000          ori.b    #$0, d0
0101cd5c  00000000          ori.b    #$0, d0
0101cd60  00000000          ori.b    #$0, d0
0101cd64  00000000          ori.b    #$0, d0
0101cd68  00000000          ori.b    #$0, d0
0101cd6c  00000000          ori.b    #$0, d0
0101cd70  00000000          ori.b    #$0, d0
0101cd74  00000000          ori.b    #$0, d0
0101cd78  00000000          ori.b    #$0, d0
0101cd7c  00000000          ori.b    #$0, d0
0101cd80  00000000          ori.b    #$0, d0
0101cd84  00000000          ori.b    #$0, d0
0101cd88  00000000          ori.b    #$0, d0
0101cd8c  00000000          ori.b    #$0, d0
0101cd90  00000000          ori.b    #$0, d0
0101cd94  00000000          ori.b    #$0, d0
0101cd98  00000000          ori.b    #$0, d0
0101cd9c  00000000          ori.b    #$0, d0
0101cda0  00000000          ori.b    #$0, d0
0101cda4  00000000          ori.b    #$0, d0
0101cda8  00000000          ori.b    #$0, d0
0101cdac  00000000          ori.b    #$0, d0
0101cdb0  00000000          ori.b    #$0, d0
0101cdb4  00000000          ori.b    #$0, d0
0101cdb8  00000000          ori.b    #$0, d0
0101cdbc  00000000          ori.b    #$0, d0
0101cdc0  00000000          ori.b    #$0, d0
0101cdc4  00000000          ori.b    #$0, d0
0101cdc8  00000000          ori.b    #$0, d0
0101cdcc  00000000          ori.b    #$0, d0
0101cdd0  00000000          ori.b    #$0, d0
0101cdd4  00000000          ori.b    #$0, d0
0101cdd8  00000000          ori.b    #$0, d0
0101cddc  00000000          ori.b    #$0, d0
0101cde0  00000000          ori.b    #$0, d0
0101cde4  00000000          ori.b    #$0, d0
0101cde8  00000000          ori.b    #$0, d0
0101cdec  00000000          ori.b    #$0, d0
0101cdf0  00000000          ori.b    #$0, d0
0101cdf4  00000000          ori.b    #$0, d0
0101cdf8  00000000          ori.b    #$0, d0
0101cdfc  00000000          ori.b    #$0, d0
0101ce00  00000000          ori.b    #$0, d0
0101ce04  00000000          ori.b    #$0, d0
0101ce08  00000000          ori.b    #$0, d0
0101ce0c  00000000          ori.b    #$0, d0
0101ce10  00000000          ori.b    #$0, d0
0101ce14  00000000          ori.b    #$0, d0
0101ce18  00000000          ori.b    #$0, d0
0101ce1c  00000000          ori.b    #$0, d0
0101ce20  00000000          ori.b    #$0, d0
0101ce24  00000000          ori.b    #$0, d0
0101ce28  00000000          ori.b    #$0, d0
0101ce2c  00000000          ori.b    #$0, d0
0101ce30  00000000          ori.b    #$0, d0
0101ce34  00000000          ori.b    #$0, d0
0101ce38  00000000          ori.b    #$0, d0
0101ce3c  00000000          ori.b    #$0, d0
0101ce40  00000000          ori.b    #$0, d0
0101ce44  00000000          ori.b    #$0, d0
0101ce48  00000000          ori.b    #$0, d0
0101ce4c  00000000          ori.b    #$0, d0
0101ce50  00000000          ori.b    #$0, d0
0101ce54  00000000          ori.b    #$0, d0
0101ce58  00000000          ori.b    #$0, d0
0101ce5c  00000000          ori.b    #$0, d0
0101ce60  00000000          ori.b    #$0, d0
0101ce64  00000000          ori.b    #$0, d0
0101ce68  00000000          ori.b    #$0, d0
0101ce6c  00000000          ori.b    #$0, d0
0101ce70  00000000          ori.b    #$0, d0
0101ce74  00000000          ori.b    #$0, d0
0101ce78  00000000          ori.b    #$0, d0
0101ce7c  00000000          ori.b    #$0, d0
0101ce80  00000000          ori.b    #$0, d0
0101ce84  00000000          ori.b    #$0, d0
0101ce88  00000000          ori.b    #$0, d0
0101ce8c  00000000          ori.b    #$0, d0
0101ce90  00000000          ori.b    #$0, d0
0101ce94  00000000          ori.b    #$0, d0
0101ce98  00000000          ori.b    #$0, d0
0101ce9c  00000000          ori.b    #$0, d0
0101cea0  00000000          ori.b    #$0, d0
0101cea4  00000000          ori.b    #$0, d0
0101cea8  00000000          ori.b    #$0, d0
0101ceac  00000000          ori.b    #$0, d0
0101ceb0  00000000          ori.b    #$0, d0
0101ceb4  00000000          ori.b    #$0, d0
0101ceb8  00000000          ori.b    #$0, d0
0101cebc  00000000          ori.b    #$0, d0
0101cec0  00000000          ori.b    #$0, d0
0101cec4  00000000          ori.b    #$0, d0
0101cec8  00000000          ori.b    #$0, d0
0101cecc  00000000          ori.b    #$0, d0
0101ced0  00000000          ori.b    #$0, d0
0101ced4  00000000          ori.b    #$0, d0
0101ced8  00000000          ori.b    #$0, d0
0101cedc  00000000          ori.b    #$0, d0
0101cee0  00000000          ori.b    #$0, d0
0101cee4  00000000          ori.b    #$0, d0
0101cee8  00000000          ori.b    #$0, d0
0101ceec  00000000          ori.b    #$0, d0
0101cef0  00000000          ori.b    #$0, d0
0101cef4  00000000          ori.b    #$0, d0
0101cef8  00000000          ori.b    #$0, d0
0101cefc  00000000          ori.b    #$0, d0
0101cf00  00000000          ori.b    #$0, d0
0101cf04  00000000          ori.b    #$0, d0
0101cf08  00000000          ori.b    #$0, d0
0101cf0c  00000000          ori.b    #$0, d0
0101cf10  00000000          ori.b    #$0, d0
0101cf14  00000000          ori.b    #$0, d0
0101cf18  00000000          ori.b    #$0, d0
0101cf1c  00000000          ori.b    #$0, d0
0101cf20  00000000          ori.b    #$0, d0
0101cf24  00000000          ori.b    #$0, d0
0101cf28  00000000          ori.b    #$0, d0
0101cf2c  00000000          ori.b    #$0, d0
0101cf30  00000000          ori.b    #$0, d0
0101cf34  00000000          ori.b    #$0, d0
0101cf38  00000000          ori.b    #$0, d0
0101cf3c  00000000          ori.b    #$0, d0
0101cf40  00000000          ori.b    #$0, d0
0101cf44  00000000          ori.b    #$0, d0
0101cf48  00000000          ori.b    #$0, d0
0101cf4c  00000000          ori.b    #$0, d0
0101cf50  00000000          ori.b    #$0, d0
0101cf54  00000000          ori.b    #$0, d0
0101cf58  00000000          ori.b    #$0, d0
0101cf5c  00000000          ori.b    #$0, d0
0101cf60  00000000          ori.b    #$0, d0
0101cf64  00000000          ori.b    #$0, d0
0101cf68  00000000          ori.b    #$0, d0
0101cf6c  00000000          ori.b    #$0, d0
0101cf70  00000000          ori.b    #$0, d0
0101cf74  00000000          ori.b    #$0, d0
0101cf78  00000000          ori.b    #$0, d0
0101cf7c  00000000          ori.b    #$0, d0
0101cf80  00000000          ori.b    #$0, d0
0101cf84  00000000          ori.b    #$0, d0
0101cf88  00000000          ori.b    #$0, d0
0101cf8c  00000000          ori.b    #$0, d0
0101cf90  00000000          ori.b    #$0, d0
0101cf94  00000000          ori.b    #$0, d0
0101cf98  00000000          ori.b    #$0, d0
0101cf9c  00000000          ori.b    #$0, d0
0101cfa0  00000000          ori.b    #$0, d0
0101cfa4  00000000          ori.b    #$0, d0
0101cfa8  00000000          ori.b    #$0, d0
0101cfac  00000000          ori.b    #$0, d0
0101cfb0  00000000          ori.b    #$0, d0
0101cfb4  00000000          ori.b    #$0, d0
0101cfb8  00000000          ori.b    #$0, d0
0101cfbc  00000000          ori.b    #$0, d0
0101cfc0  00000000          ori.b    #$0, d0
0101cfc4  00000000          ori.b    #$0, d0
0101cfc8  00000000          ori.b    #$0, d0
0101cfcc  00000000          ori.b    #$0, d0
0101cfd0  00000000          ori.b    #$0, d0
0101cfd4  00000000          ori.b    #$0, d0
0101cfd8  00000000          ori.b    #$0, d0
0101cfdc  00000000          ori.b    #$0, d0
0101cfe0  00000000          ori.b    #$0, d0
0101cfe4  00000000          ori.b    #$0, d0
0101cfe8  00000000          ori.b    #$0, d0
0101cfec  00000000          ori.b    #$0, d0
0101cff0  00000000          ori.b    #$0, d0
0101cff4  00000000          ori.b    #$0, d0
0101cff8  00000000          ori.b    #$0, d0
0101cffc  00000000          ori.b    #$0, d0
0101d000  00000000          ori.b    #$0, d0
0101d004  00000000          ori.b    #$0, d0
0101d008  00000000          ori.b    #$0, d0
0101d00c  00000000          ori.b    #$0, d0
0101d010  00000000          ori.b    #$0, d0
0101d014  00000000          ori.b    #$0, d0
0101d018  00000000          ori.b    #$0, d0
0101d01c  00000000          ori.b    #$0, d0
0101d020  00000000          ori.b    #$0, d0
0101d024  00000000          ori.b    #$0, d0
0101d028  00000000          ori.b    #$0, d0
0101d02c  00000000          ori.b    #$0, d0
0101d030  00000000          ori.b    #$0, d0
0101d034  00000000          ori.b    #$0, d0
0101d038  00000000          ori.b    #$0, d0
0101d03c  00000000          ori.b    #$0, d0
0101d040  00000000          ori.b    #$0, d0
0101d044  00000000          ori.b    #$0, d0
0101d048  00000000          ori.b    #$0, d0
0101d04c  00000000          ori.b    #$0, d0
0101d050  00000000          ori.b    #$0, d0
0101d054  00000000          ori.b    #$0, d0
0101d058  00000000          ori.b    #$0, d0
0101d05c  00000000          ori.b    #$0, d0
0101d060  00000000          ori.b    #$0, d0
0101d064  00000000          ori.b    #$0, d0
0101d068  00000000          ori.b    #$0, d0
0101d06c  00000000          ori.b    #$0, d0
0101d070  00000000          ori.b    #$0, d0
0101d074  00000000          ori.b    #$0, d0
0101d078  00000000          ori.b    #$0, d0
0101d07c  00000000          ori.b    #$0, d0
0101d080  00000000          ori.b    #$0, d0
0101d084  00000000          ori.b    #$0, d0
0101d088  00000000          ori.b    #$0, d0
0101d08c  00000000          ori.b    #$0, d0
0101d090  00000000          ori.b    #$0, d0
0101d094  00000000          ori.b    #$0, d0
0101d098  00000000          ori.b    #$0, d0
0101d09c  00000000          ori.b    #$0, d0
0101d0a0  00000000          ori.b    #$0, d0
0101d0a4  00000000          ori.b    #$0, d0
0101d0a8  00000000          ori.b    #$0, d0
0101d0ac  00000000          ori.b    #$0, d0
0101d0b0  00000000          ori.b    #$0, d0
0101d0b4  00000000          ori.b    #$0, d0
0101d0b8  00000000          ori.b    #$0, d0
0101d0bc  00000000          ori.b    #$0, d0
0101d0c0  00000000          ori.b    #$0, d0
0101d0c4  00000000          ori.b    #$0, d0
0101d0c8  00000000          ori.b    #$0, d0
0101d0cc  00000000          ori.b    #$0, d0
0101d0d0  00000000          ori.b    #$0, d0
0101d0d4  00000000          ori.b    #$0, d0
0101d0d8  00000000          ori.b    #$0, d0
0101d0dc  00000000          ori.b    #$0, d0
0101d0e0  00000000          ori.b    #$0, d0
0101d0e4  00000000          ori.b    #$0, d0
0101d0e8  00000000          ori.b    #$0, d0
0101d0ec  00000000          ori.b    #$0, d0
0101d0f0  00000000          ori.b    #$0, d0
0101d0f4  00000000          ori.b    #$0, d0
0101d0f8  00000000          ori.b    #$0, d0
0101d0fc  00000000          ori.b    #$0, d0
0101d100  00000000          ori.b    #$0, d0
0101d104  00000000          ori.b    #$0, d0
0101d108  00000000          ori.b    #$0, d0
0101d10c  00000000          ori.b    #$0, d0
0101d110  00000000          ori.b    #$0, d0
0101d114  00000000          ori.b    #$0, d0
0101d118  00000000          ori.b    #$0, d0
0101d11c  00000000          ori.b    #$0, d0
0101d120  00000000          ori.b    #$0, d0
0101d124  00000000          ori.b    #$0, d0
0101d128  00000000          ori.b    #$0, d0
0101d12c  00000000          ori.b    #$0, d0
0101d130  00000000          ori.b    #$0, d0
0101d134  00000000          ori.b    #$0, d0
0101d138  00000000          ori.b    #$0, d0
0101d13c  00000000          ori.b    #$0, d0
0101d140  00000000          ori.b    #$0, d0
0101d144  00000000          ori.b    #$0, d0
0101d148  00000000          ori.b    #$0, d0
0101d14c  00000000          ori.b    #$0, d0
0101d150  00000000          ori.b    #$0, d0
0101d154  00000000          ori.b    #$0, d0
0101d158  00000000          ori.b    #$0, d0
0101d15c  00000000          ori.b    #$0, d0
0101d160  00000000          ori.b    #$0, d0
0101d164  00000000          ori.b    #$0, d0
0101d168  00000000          ori.b    #$0, d0
0101d16c  00000000          ori.b    #$0, d0
0101d170  00000000          ori.b    #$0, d0
0101d174  00000000          ori.b    #$0, d0
0101d178  00000000          ori.b    #$0, d0
0101d17c  00000000          ori.b    #$0, d0
0101d180  00000000          ori.b    #$0, d0
0101d184  00000000          ori.b    #$0, d0
0101d188  00000000          ori.b    #$0, d0
0101d18c  00000000          ori.b    #$0, d0
0101d190  00000000          ori.b    #$0, d0
0101d194  00000000          ori.b    #$0, d0
0101d198  00000000          ori.b    #$0, d0
0101d19c  00000000          ori.b    #$0, d0
0101d1a0  00000000          ori.b    #$0, d0
0101d1a4  00000000          ori.b    #$0, d0
0101d1a8  00000000          ori.b    #$0, d0
0101d1ac  00000000          ori.b    #$0, d0
0101d1b0  00000000          ori.b    #$0, d0
0101d1b4  00000000          ori.b    #$0, d0
0101d1b8  00000000          ori.b    #$0, d0
0101d1bc  00000000          ori.b    #$0, d0
0101d1c0  00000000          ori.b    #$0, d0
0101d1c4  00000000          ori.b    #$0, d0
0101d1c8  00000000          ori.b    #$0, d0
0101d1cc  00000000          ori.b    #$0, d0
0101d1d0  00000000          ori.b    #$0, d0
0101d1d4  00000000          ori.b    #$0, d0
0101d1d8  00000000          ori.b    #$0, d0
0101d1dc  00000000          ori.b    #$0, d0
0101d1e0  00000000          ori.b    #$0, d0
0101d1e4  00000000          ori.b    #$0, d0
0101d1e8  00000000          ori.b    #$0, d0
0101d1ec  00000000          ori.b    #$0, d0
0101d1f0  00000000          ori.b    #$0, d0
0101d1f4  00000000          ori.b    #$0, d0
0101d1f8  00000000          ori.b    #$0, d0
0101d1fc  00000000          ori.b    #$0, d0
0101d200  00000000          ori.b    #$0, d0
0101d204  00000000          ori.b    #$0, d0
0101d208  00000000          ori.b    #$0, d0
0101d20c  00000000          ori.b    #$0, d0
0101d210  00000000          ori.b    #$0, d0
0101d214  00000000          ori.b    #$0, d0
0101d218  00000000          ori.b    #$0, d0
0101d21c  00000000          ori.b    #$0, d0
0101d220  00000000          ori.b    #$0, d0
0101d224  00000000          ori.b    #$0, d0
0101d228  00000000          ori.b    #$0, d0
0101d22c  00000000          ori.b    #$0, d0
0101d230  00000000          ori.b    #$0, d0
0101d234  00000000          ori.b    #$0, d0
0101d238  00000000          ori.b    #$0, d0
0101d23c  00000000          ori.b    #$0, d0
0101d240  00000000          ori.b    #$0, d0
0101d244  00000000          ori.b    #$0, d0
0101d248  00000000          ori.b    #$0, d0
0101d24c  00000000          ori.b    #$0, d0
0101d250  00000000          ori.b    #$0, d0
0101d254  00000000          ori.b    #$0, d0
0101d258  00000000          ori.b    #$0, d0
0101d25c  00000000          ori.b    #$0, d0
0101d260  00000000          ori.b    #$0, d0
0101d264  00000000          ori.b    #$0, d0
0101d268  00000000          ori.b    #$0, d0
0101d26c  00000000          ori.b    #$0, d0
0101d270  00000000          ori.b    #$0, d0
0101d274  00000000          ori.b    #$0, d0
0101d278  00000000          ori.b    #$0, d0
0101d27c  00000000          ori.b    #$0, d0
0101d280  00000000          ori.b    #$0, d0
0101d284  00000000          ori.b    #$0, d0
0101d288  00000000          ori.b    #$0, d0
0101d28c  00000000          ori.b    #$0, d0
0101d290  00000000          ori.b    #$0, d0
0101d294  00000000          ori.b    #$0, d0
0101d298  00000000          ori.b    #$0, d0
0101d29c  00000000          ori.b    #$0, d0
0101d2a0  00000000          ori.b    #$0, d0
0101d2a4  00000000          ori.b    #$0, d0
0101d2a8  00000000          ori.b    #$0, d0
0101d2ac  00000000          ori.b    #$0, d0
0101d2b0  00000000          ori.b    #$0, d0
0101d2b4  00000000          ori.b    #$0, d0
0101d2b8  00000000          ori.b    #$0, d0
0101d2bc  00000000          ori.b    #$0, d0
0101d2c0  00000000          ori.b    #$0, d0
0101d2c4  00000000          ori.b    #$0, d0
0101d2c8  00000000          ori.b    #$0, d0
0101d2cc  00000000          ori.b    #$0, d0
0101d2d0  00000000          ori.b    #$0, d0
0101d2d4  00000000          ori.b    #$0, d0
0101d2d8  00000000          ori.b    #$0, d0
0101d2dc  00000000          ori.b    #$0, d0
0101d2e0  00000000          ori.b    #$0, d0
0101d2e4  00000000          ori.b    #$0, d0
0101d2e8  00000000          ori.b    #$0, d0
0101d2ec  00000000          ori.b    #$0, d0
0101d2f0  00000000          ori.b    #$0, d0
0101d2f4  00000000          ori.b    #$0, d0
0101d2f8  00000000          ori.b    #$0, d0
0101d2fc  00000000          ori.b    #$0, d0
0101d300  00000000          ori.b    #$0, d0
0101d304  00000000          ori.b    #$0, d0
0101d308  00000000          ori.b    #$0, d0
0101d30c  00000000          ori.b    #$0, d0
0101d310  00000000          ori.b    #$0, d0
0101d314  00000000          ori.b    #$0, d0
0101d318  00000000          ori.b    #$0, d0
0101d31c  00000000          ori.b    #$0, d0
0101d320  00000000          ori.b    #$0, d0
0101d324  00000000          ori.b    #$0, d0
0101d328  00000000          ori.b    #$0, d0
0101d32c  00000000          ori.b    #$0, d0
0101d330  00000000          ori.b    #$0, d0
0101d334  00000000          ori.b    #$0, d0
0101d338  00000000          ori.b    #$0, d0
0101d33c  00000000          ori.b    #$0, d0
0101d340  00000000          ori.b    #$0, d0
0101d344  00000000          ori.b    #$0, d0
0101d348  00000000          ori.b    #$0, d0
0101d34c  00000000          ori.b    #$0, d0
0101d350  00000000          ori.b    #$0, d0
0101d354  00000000          ori.b    #$0, d0
0101d358  00000000          ori.b    #$0, d0
0101d35c  00000000          ori.b    #$0, d0
0101d360  00000000          ori.b    #$0, d0
0101d364  00000000          ori.b    #$0, d0
0101d368  00000000          ori.b    #$0, d0
0101d36c  00000000          ori.b    #$0, d0
0101d370  00000000          ori.b    #$0, d0
0101d374  00000000          ori.b    #$0, d0
0101d378  00000000          ori.b    #$0, d0
0101d37c  00000000          ori.b    #$0, d0
0101d380  00000000          ori.b    #$0, d0
0101d384  00000000          ori.b    #$0, d0
0101d388  00000000          ori.b    #$0, d0
0101d38c  00000000          ori.b    #$0, d0
0101d390  00000000          ori.b    #$0, d0
0101d394  00000000          ori.b    #$0, d0
0101d398  00000000          ori.b    #$0, d0
0101d39c  00000000          ori.b    #$0, d0
0101d3a0  00000000          ori.b    #$0, d0
0101d3a4  00000000          ori.b    #$0, d0
0101d3a8  00000000          ori.b    #$0, d0
0101d3ac  00000000          ori.b    #$0, d0
0101d3b0  00000000          ori.b    #$0, d0
0101d3b4  00000000          ori.b    #$0, d0
0101d3b8  00000000          ori.b    #$0, d0
0101d3bc  00000000          ori.b    #$0, d0
0101d3c0  00000000          ori.b    #$0, d0
0101d3c4  00000000          ori.b    #$0, d0
0101d3c8  00000000          ori.b    #$0, d0
0101d3cc  00000000          ori.b    #$0, d0
0101d3d0  00000000          ori.b    #$0, d0
0101d3d4  00000000          ori.b    #$0, d0
0101d3d8  00000000          ori.b    #$0, d0
0101d3dc  00000000          ori.b    #$0, d0
0101d3e0  00000000          ori.b    #$0, d0
0101d3e4  00000000          ori.b    #$0, d0
0101d3e8  00000000          ori.b    #$0, d0
0101d3ec  00000000          ori.b    #$0, d0
0101d3f0  00000000          ori.b    #$0, d0
0101d3f4  00000000          ori.b    #$0, d0
0101d3f8  00000000          ori.b    #$0, d0
0101d3fc  00000000          ori.b    #$0, d0
0101d400  00000000          ori.b    #$0, d0
0101d404  00000000          ori.b    #$0, d0
0101d408  00000000          ori.b    #$0, d0
0101d40c  00000000          ori.b    #$0, d0
0101d410  00000000          ori.b    #$0, d0
0101d414  00000000          ori.b    #$0, d0
0101d418  00000000          ori.b    #$0, d0
0101d41c  00000000          ori.b    #$0, d0
0101d420  00000000          ori.b    #$0, d0
0101d424  00000000          ori.b    #$0, d0
0101d428  00000000          ori.b    #$0, d0
0101d42c  00000000          ori.b    #$0, d0
0101d430  00000000          ori.b    #$0, d0
0101d434  00000000          ori.b    #$0, d0
0101d438  00000000          ori.b    #$0, d0
0101d43c  00000000          ori.b    #$0, d0
0101d440  00000000          ori.b    #$0, d0
0101d444  00000000          ori.b    #$0, d0
0101d448  00000000          ori.b    #$0, d0
0101d44c  00000000          ori.b    #$0, d0
0101d450  00000000          ori.b    #$0, d0
0101d454  00000000          ori.b    #$0, d0
0101d458  00000000          ori.b    #$0, d0
0101d45c  00000000          ori.b    #$0, d0
0101d460  00000000          ori.b    #$0, d0
0101d464  00000000          ori.b    #$0, d0
0101d468  00000000          ori.b    #$0, d0
0101d46c  00000000          ori.b    #$0, d0
0101d470  00000000          ori.b    #$0, d0
0101d474  00000000          ori.b    #$0, d0
0101d478  00000000          ori.b    #$0, d0
0101d47c  00000000          ori.b    #$0, d0
0101d480  00000000          ori.b    #$0, d0
0101d484  00000000          ori.b    #$0, d0
0101d488  00000000          ori.b    #$0, d0
0101d48c  00000000          ori.b    #$0, d0
0101d490  00000000          ori.b    #$0, d0
0101d494  00000000          ori.b    #$0, d0
0101d498  00000000          ori.b    #$0, d0
0101d49c  00000000          ori.b    #$0, d0
0101d4a0  00000000          ori.b    #$0, d0
0101d4a4  00000000          ori.b    #$0, d0
0101d4a8  00000000          ori.b    #$0, d0
0101d4ac  00000000          ori.b    #$0, d0
0101d4b0  00000000          ori.b    #$0, d0
0101d4b4  00000000          ori.b    #$0, d0
0101d4b8  00000000          ori.b    #$0, d0
0101d4bc  00000000          ori.b    #$0, d0
0101d4c0  00000000          ori.b    #$0, d0
0101d4c4  00000000          ori.b    #$0, d0
0101d4c8  00000000          ori.b    #$0, d0
0101d4cc  00000000          ori.b    #$0, d0
0101d4d0  00000000          ori.b    #$0, d0
0101d4d4  00000000          ori.b    #$0, d0
0101d4d8  00000000          ori.b    #$0, d0
0101d4dc  00000000          ori.b    #$0, d0
0101d4e0  00000000          ori.b    #$0, d0
0101d4e4  00000000          ori.b    #$0, d0
0101d4e8  00000000          ori.b    #$0, d0
0101d4ec  00000000          ori.b    #$0, d0
0101d4f0  00000000          ori.b    #$0, d0
0101d4f4  00000000          ori.b    #$0, d0
0101d4f8  00000000          ori.b    #$0, d0
0101d4fc  00000000          ori.b    #$0, d0
0101d500  00000000          ori.b    #$0, d0
0101d504  00000000          ori.b    #$0, d0
0101d508  00000000          ori.b    #$0, d0
0101d50c  00000000          ori.b    #$0, d0
0101d510  00000000          ori.b    #$0, d0
0101d514  00000000          ori.b    #$0, d0
0101d518  00000000          ori.b    #$0, d0
0101d51c  00000000          ori.b    #$0, d0
0101d520  00000000          ori.b    #$0, d0
0101d524  00000000          ori.b    #$0, d0
0101d528  00000000          ori.b    #$0, d0
0101d52c  00000000          ori.b    #$0, d0
0101d530  00000000          ori.b    #$0, d0
0101d534  00000000          ori.b    #$0, d0
0101d538  00000000          ori.b    #$0, d0
0101d53c  00000000          ori.b    #$0, d0
0101d540  00000000          ori.b    #$0, d0
0101d544  00000000          ori.b    #$0, d0
0101d548  00000000          ori.b    #$0, d0
0101d54c  00000000          ori.b    #$0, d0
0101d550  00000000          ori.b    #$0, d0
0101d554  00000000          ori.b    #$0, d0
0101d558  00000000          ori.b    #$0, d0
0101d55c  00000000          ori.b    #$0, d0
0101d560  00000000          ori.b    #$0, d0
0101d564  00000000          ori.b    #$0, d0
0101d568  00000000          ori.b    #$0, d0
0101d56c  00000000          ori.b    #$0, d0
0101d570  00000000          ori.b    #$0, d0
0101d574  00000000          ori.b    #$0, d0
0101d578  00000000          ori.b    #$0, d0
0101d57c  00000000          ori.b    #$0, d0
0101d580  00000000          ori.b    #$0, d0
0101d584  00000000          ori.b    #$0, d0
0101d588  00000000          ori.b    #$0, d0
0101d58c  00000000          ori.b    #$0, d0
0101d590  00000000          ori.b    #$0, d0
0101d594  00000000          ori.b    #$0, d0
0101d598  00000000          ori.b    #$0, d0
0101d59c  00000000          ori.b    #$0, d0
0101d5a0  00000000          ori.b    #$0, d0
0101d5a4  00000000          ori.b    #$0, d0
0101d5a8  00000000          ori.b    #$0, d0
0101d5ac  00000000          ori.b    #$0, d0
0101d5b0  00000000          ori.b    #$0, d0
0101d5b4  00000000          ori.b    #$0, d0
0101d5b8  00000000          ori.b    #$0, d0
0101d5bc  00000000          ori.b    #$0, d0
0101d5c0  00000000          ori.b    #$0, d0
0101d5c4  00000000          ori.b    #$0, d0
0101d5c8  00000000          ori.b    #$0, d0
0101d5cc  00000000          ori.b    #$0, d0
0101d5d0  00000000          ori.b    #$0, d0
0101d5d4  00000000          ori.b    #$0, d0
0101d5d8  00000000          ori.b    #$0, d0
0101d5dc  00000000          ori.b    #$0, d0
0101d5e0  00000000          ori.b    #$0, d0
0101d5e4  00000000          ori.b    #$0, d0
0101d5e8  00000000          ori.b    #$0, d0
0101d5ec  00000000          ori.b    #$0, d0
0101d5f0  00000000          ori.b    #$0, d0
0101d5f4  00000000          ori.b    #$0, d0
0101d5f8  00000000          ori.b    #$0, d0
0101d5fc  00000000          ori.b    #$0, d0
0101d600  00000000          ori.b    #$0, d0
0101d604  00000000          ori.b    #$0, d0
0101d608  00000000          ori.b    #$0, d0
0101d60c  00000000          ori.b    #$0, d0
0101d610  00000000          ori.b    #$0, d0
0101d614  00000000          ori.b    #$0, d0
0101d618  00000000          ori.b    #$0, d0
0101d61c  00000000          ori.b    #$0, d0
0101d620  00000000          ori.b    #$0, d0
0101d624  00000000          ori.b    #$0, d0
0101d628  00000000          ori.b    #$0, d0
0101d62c  00000000          ori.b    #$0, d0
0101d630  00000000          ori.b    #$0, d0
0101d634  00000000          ori.b    #$0, d0
0101d638  00000000          ori.b    #$0, d0
0101d63c  00000000          ori.b    #$0, d0
0101d640  00000000          ori.b    #$0, d0
0101d644  00000000          ori.b    #$0, d0
0101d648  00000000          ori.b    #$0, d0
0101d64c  00000000          ori.b    #$0, d0
0101d650  00000000          ori.b    #$0, d0
0101d654  00000000          ori.b    #$0, d0
0101d658  00000000          ori.b    #$0, d0
0101d65c  00000000          ori.b    #$0, d0
0101d660  00000000          ori.b    #$0, d0
0101d664  00000000          ori.b    #$0, d0
0101d668  00000000          ori.b    #$0, d0
0101d66c  00000000          ori.b    #$0, d0
0101d670  00000000          ori.b    #$0, d0
0101d674  00000000          ori.b    #$0, d0
0101d678  00000000          ori.b    #$0, d0
0101d67c  00000000          ori.b    #$0, d0
0101d680  00000000          ori.b    #$0, d0
0101d684  00000000          ori.b    #$0, d0
0101d688  00000000          ori.b    #$0, d0
0101d68c  00000000          ori.b    #$0, d0
0101d690  00000000          ori.b    #$0, d0
0101d694  00000000          ori.b    #$0, d0
0101d698  00000000          ori.b    #$0, d0
0101d69c  00000000          ori.b    #$0, d0
0101d6a0  00000000          ori.b    #$0, d0
0101d6a4  00000000          ori.b    #$0, d0
0101d6a8  00000000          ori.b    #$0, d0
0101d6ac  00000000          ori.b    #$0, d0
0101d6b0  00000000          ori.b    #$0, d0
0101d6b4  00000000          ori.b    #$0, d0
0101d6b8  00000000          ori.b    #$0, d0
0101d6bc  00000000          ori.b    #$0, d0
0101d6c0  00000000          ori.b    #$0, d0
0101d6c4  00000000          ori.b    #$0, d0
0101d6c8  00000000          ori.b    #$0, d0
0101d6cc  00000000          ori.b    #$0, d0
0101d6d0  00000000          ori.b    #$0, d0
0101d6d4  00000000          ori.b    #$0, d0
0101d6d8  00000000          ori.b    #$0, d0
0101d6dc  00000000          ori.b    #$0, d0
0101d6e0  00000000          ori.b    #$0, d0
0101d6e4  00000000          ori.b    #$0, d0
0101d6e8  00000000          ori.b    #$0, d0
0101d6ec  00000000          ori.b    #$0, d0
0101d6f0  00000000          ori.b    #$0, d0
0101d6f4  00000000          ori.b    #$0, d0
0101d6f8  00000000          ori.b    #$0, d0
0101d6fc  00000000          ori.b    #$0, d0
0101d700  00000000          ori.b    #$0, d0
0101d704  00000000          ori.b    #$0, d0
0101d708  00000000          ori.b    #$0, d0
0101d70c  00000000          ori.b    #$0, d0
0101d710  00000000          ori.b    #$0, d0
0101d714  00000000          ori.b    #$0, d0
0101d718  00000000          ori.b    #$0, d0
0101d71c  00000000          ori.b    #$0, d0
0101d720  00000000          ori.b    #$0, d0
0101d724  00000000          ori.b    #$0, d0
0101d728  00000000          ori.b    #$0, d0
0101d72c  00000000          ori.b    #$0, d0
0101d730  00000000          ori.b    #$0, d0
0101d734  00000000          ori.b    #$0, d0
0101d738  00000000          ori.b    #$0, d0
0101d73c  00000000          ori.b    #$0, d0
0101d740  00000000          ori.b    #$0, d0
0101d744  00000000          ori.b    #$0, d0
0101d748  00000000          ori.b    #$0, d0
0101d74c  00000000          ori.b    #$0, d0
0101d750  00000000          ori.b    #$0, d0
0101d754  00000000          ori.b    #$0, d0
0101d758  00000000          ori.b    #$0, d0
0101d75c  00000000          ori.b    #$0, d0
0101d760  00000000          ori.b    #$0, d0
0101d764  00000000          ori.b    #$0, d0
0101d768  00000000          ori.b    #$0, d0
0101d76c  00000000          ori.b    #$0, d0
0101d770  00000000          ori.b    #$0, d0
0101d774  00000000          ori.b    #$0, d0
0101d778  00000000          ori.b    #$0, d0
0101d77c  00000000          ori.b    #$0, d0
0101d780  00000000          ori.b    #$0, d0
0101d784  00000000          ori.b    #$0, d0
0101d788  00000000          ori.b    #$0, d0
0101d78c  00000000          ori.b    #$0, d0
0101d790  00000000          ori.b    #$0, d0
0101d794  00000000          ori.b    #$0, d0
0101d798  00000000          ori.b    #$0, d0
0101d79c  00000000          ori.b    #$0, d0
0101d7a0  00000000          ori.b    #$0, d0
0101d7a4  00000000          ori.b    #$0, d0
0101d7a8  00000000          ori.b    #$0, d0
0101d7ac  00000000          ori.b    #$0, d0
0101d7b0  00000000          ori.b    #$0, d0
0101d7b4  00000000          ori.b    #$0, d0
0101d7b8  00000000          ori.b    #$0, d0
0101d7bc  00000000          ori.b    #$0, d0
0101d7c0  00000000          ori.b    #$0, d0
0101d7c4  00000000          ori.b    #$0, d0
0101d7c8  00000000          ori.b    #$0, d0
0101d7cc  00000000          ori.b    #$0, d0
0101d7d0  00000000          ori.b    #$0, d0
0101d7d4  00000000          ori.b    #$0, d0
0101d7d8  00000000          ori.b    #$0, d0
0101d7dc  00000000          ori.b    #$0, d0
0101d7e0  00000000          ori.b    #$0, d0
0101d7e4  00000000          ori.b    #$0, d0
0101d7e8  00000000          ori.b    #$0, d0
0101d7ec  00000000          ori.b    #$0, d0
0101d7f0  00000000          ori.b    #$0, d0
0101d7f4  00000000          ori.b    #$0, d0
0101d7f8  00000000          ori.b    #$0, d0
0101d7fc  00000000          ori.b    #$0, d0
0101d800  00000000          ori.b    #$0, d0
0101d804  00000000          ori.b    #$0, d0
0101d808  00000000          ori.b    #$0, d0
0101d80c  00000000          ori.b    #$0, d0
0101d810  00000000          ori.b    #$0, d0
0101d814  00000000          ori.b    #$0, d0
0101d818  00000000          ori.b    #$0, d0
0101d81c  00000000          ori.b    #$0, d0
0101d820  00000000          ori.b    #$0, d0
0101d824  00000000          ori.b    #$0, d0
0101d828  00000000          ori.b    #$0, d0
0101d82c  00000000          ori.b    #$0, d0
0101d830  00000000          ori.b    #$0, d0
0101d834  00000000          ori.b    #$0, d0
0101d838  00000000          ori.b    #$0, d0
0101d83c  00000000          ori.b    #$0, d0
0101d840  00000000          ori.b    #$0, d0
0101d844  00000000          ori.b    #$0, d0
0101d848  00000000          ori.b    #$0, d0
0101d84c  00000000          ori.b    #$0, d0
0101d850  00000000          ori.b    #$0, d0
0101d854  00000000          ori.b    #$0, d0
0101d858  00000000          ori.b    #$0, d0
0101d85c  00000000          ori.b    #$0, d0
0101d860  00000000          ori.b    #$0, d0
0101d864  00000000          ori.b    #$0, d0
0101d868  00000000          ori.b    #$0, d0
0101d86c  00000000          ori.b    #$0, d0
0101d870  00000000          ori.b    #$0, d0
0101d874  00000000          ori.b    #$0, d0
0101d878  00000000          ori.b    #$0, d0
0101d87c  00000000          ori.b    #$0, d0
0101d880  00000000          ori.b    #$0, d0
0101d884  00000000          ori.b    #$0, d0
0101d888  00000000          ori.b    #$0, d0
0101d88c  00000000          ori.b    #$0, d0
0101d890  00000000          ori.b    #$0, d0
0101d894  00000000          ori.b    #$0, d0
0101d898  00000000          ori.b    #$0, d0
0101d89c  00000000          ori.b    #$0, d0
0101d8a0  00000000          ori.b    #$0, d0
0101d8a4  00000000          ori.b    #$0, d0
0101d8a8  00000000          ori.b    #$0, d0
0101d8ac  00000000          ori.b    #$0, d0
0101d8b0  00000000          ori.b    #$0, d0
0101d8b4  00000000          ori.b    #$0, d0
0101d8b8  00000000          ori.b    #$0, d0
0101d8bc  00000000          ori.b    #$0, d0
0101d8c0  00000000          ori.b    #$0, d0
0101d8c4  00000000          ori.b    #$0, d0
0101d8c8  00000000          ori.b    #$0, d0
0101d8cc  00000000          ori.b    #$0, d0
0101d8d0  00000000          ori.b    #$0, d0
0101d8d4  00000000          ori.b    #$0, d0
0101d8d8  00000000          ori.b    #$0, d0
0101d8dc  00000000          ori.b    #$0, d0
0101d8e0  00000000          ori.b    #$0, d0
0101d8e4  00000000          ori.b    #$0, d0
0101d8e8  00000000          ori.b    #$0, d0
0101d8ec  00000000          ori.b    #$0, d0
0101d8f0  00000000          ori.b    #$0, d0
0101d8f4  00000000          ori.b    #$0, d0
0101d8f8  00000000          ori.b    #$0, d0
0101d8fc  00000000          ori.b    #$0, d0
0101d900  00000000          ori.b    #$0, d0
0101d904  00000000          ori.b    #$0, d0
0101d908  00000000          ori.b    #$0, d0
0101d90c  00000000          ori.b    #$0, d0
0101d910  00000000          ori.b    #$0, d0
0101d914  00000000          ori.b    #$0, d0
0101d918  00000000          ori.b    #$0, d0
0101d91c  00000000          ori.b    #$0, d0
0101d920  00000000          ori.b    #$0, d0
0101d924  00000000          ori.b    #$0, d0
0101d928  00000000          ori.b    #$0, d0
0101d92c  00000000          ori.b    #$0, d0
0101d930  00000000          ori.b    #$0, d0
0101d934  00000000          ori.b    #$0, d0
0101d938  00000000          ori.b    #$0, d0
0101d93c  00000000          ori.b    #$0, d0
0101d940  00000000          ori.b    #$0, d0
0101d944  00000000          ori.b    #$0, d0
0101d948  00000000          ori.b    #$0, d0
0101d94c  00000000          ori.b    #$0, d0
0101d950  00000000          ori.b    #$0, d0
0101d954  00000000          ori.b    #$0, d0
0101d958  00000000          ori.b    #$0, d0
0101d95c  00000000          ori.b    #$0, d0
0101d960  00000000          ori.b    #$0, d0
0101d964  00000000          ori.b    #$0, d0
0101d968  00000000          ori.b    #$0, d0
0101d96c  00000000          ori.b    #$0, d0
0101d970  00000000          ori.b    #$0, d0
0101d974  00000000          ori.b    #$0, d0
0101d978  00000000          ori.b    #$0, d0
0101d97c  00000000          ori.b    #$0, d0
0101d980  00000000          ori.b    #$0, d0
0101d984  00000000          ori.b    #$0, d0
0101d988  00000000          ori.b    #$0, d0
0101d98c  00000000          ori.b    #$0, d0
0101d990  00000000          ori.b    #$0, d0
0101d994  00000000          ori.b    #$0, d0
0101d998  00000000          ori.b    #$0, d0
0101d99c  00000000          ori.b    #$0, d0
0101d9a0  00000000          ori.b    #$0, d0
0101d9a4  00000000          ori.b    #$0, d0
0101d9a8  00000000          ori.b    #$0, d0
0101d9ac  00000000          ori.b    #$0, d0
0101d9b0  00000000          ori.b    #$0, d0
0101d9b4  00000000          ori.b    #$0, d0
0101d9b8  00000000          ori.b    #$0, d0
0101d9bc  00000000          ori.b    #$0, d0
0101d9c0  00000000          ori.b    #$0, d0
0101d9c4  00000000          ori.b    #$0, d0
0101d9c8  00000000          ori.b    #$0, d0
0101d9cc  00000000          ori.b    #$0, d0
0101d9d0  00000000          ori.b    #$0, d0
0101d9d4  00000000          ori.b    #$0, d0
0101d9d8  00000000          ori.b    #$0, d0
0101d9dc  00000000          ori.b    #$0, d0
0101d9e0  00000000          ori.b    #$0, d0
0101d9e4  00000000          ori.b    #$0, d0
0101d9e8  00000000          ori.b    #$0, d0
0101d9ec  00000000          ori.b    #$0, d0
0101d9f0  00000000          ori.b    #$0, d0
0101d9f4  00000000          ori.b    #$0, d0
0101d9f8  00000000          ori.b    #$0, d0
0101d9fc  00000000          ori.b    #$0, d0
0101da00  00000000          ori.b    #$0, d0
0101da04  00000000          ori.b    #$0, d0
0101da08  00000000          ori.b    #$0, d0
0101da0c  00000000          ori.b    #$0, d0
0101da10  00000000          ori.b    #$0, d0
0101da14  00000000          ori.b    #$0, d0
0101da18  00000000          ori.b    #$0, d0
0101da1c  00000000          ori.b    #$0, d0
0101da20  00000000          ori.b    #$0, d0
0101da24  00000000          ori.b    #$0, d0
0101da28  00000000          ori.b    #$0, d0
0101da2c  00000000          ori.b    #$0, d0
0101da30  00000000          ori.b    #$0, d0
0101da34  00000000          ori.b    #$0, d0
0101da38  00000000          ori.b    #$0, d0
0101da3c  00000000          ori.b    #$0, d0
0101da40  00000000          ori.b    #$0, d0
0101da44  00000000          ori.b    #$0, d0
0101da48  00000000          ori.b    #$0, d0
0101da4c  00000000          ori.b    #$0, d0
0101da50  00000000          ori.b    #$0, d0
0101da54  00000000          ori.b    #$0, d0
0101da58  00000000          ori.b    #$0, d0
0101da5c  00000000          ori.b    #$0, d0
0101da60  00000000          ori.b    #$0, d0
0101da64  00000000          ori.b    #$0, d0
0101da68  00000000          ori.b    #$0, d0
0101da6c  00000000          ori.b    #$0, d0
0101da70  00000000          ori.b    #$0, d0
0101da74  00000000          ori.b    #$0, d0
0101da78  00000000          ori.b    #$0, d0
0101da7c  00000000          ori.b    #$0, d0
0101da80  00000000          ori.b    #$0, d0
0101da84  00000000          ori.b    #$0, d0
0101da88  00000000          ori.b    #$0, d0
0101da8c  00000000          ori.b    #$0, d0
0101da90  00000000          ori.b    #$0, d0
0101da94  00000000          ori.b    #$0, d0
0101da98  00000000          ori.b    #$0, d0
0101da9c  00000000          ori.b    #$0, d0
0101daa0  00000000          ori.b    #$0, d0
0101daa4  00000000          ori.b    #$0, d0
0101daa8  00000000          ori.b    #$0, d0
0101daac  00000000          ori.b    #$0, d0
0101dab0  00000000          ori.b    #$0, d0
0101dab4  00000000          ori.b    #$0, d0
0101dab8  00000000          ori.b    #$0, d0
0101dabc  00000000          ori.b    #$0, d0
0101dac0  00000000          ori.b    #$0, d0
0101dac4  00000000          ori.b    #$0, d0
0101dac8  00000000          ori.b    #$0, d0
0101dacc  00000000          ori.b    #$0, d0
0101dad0  00000000          ori.b    #$0, d0
0101dad4  00000000          ori.b    #$0, d0
0101dad8  00000000          ori.b    #$0, d0
0101dadc  00000000          ori.b    #$0, d0
0101dae0  00000000          ori.b    #$0, d0
0101dae4  00000000          ori.b    #$0, d0
0101dae8  00000000          ori.b    #$0, d0
0101daec  00000000          ori.b    #$0, d0
0101daf0  00000000          ori.b    #$0, d0
0101daf4  00000000          ori.b    #$0, d0
0101daf8  00000000          ori.b    #$0, d0
0101dafc  00000000          ori.b    #$0, d0
0101db00  00000000          ori.b    #$0, d0
0101db04  00000000          ori.b    #$0, d0
0101db08  00000000          ori.b    #$0, d0
0101db0c  00000000          ori.b    #$0, d0
0101db10  00000000          ori.b    #$0, d0
0101db14  00000000          ori.b    #$0, d0
0101db18  00000000          ori.b    #$0, d0
0101db1c  00000000          ori.b    #$0, d0
0101db20  00000000          ori.b    #$0, d0
0101db24  00000000          ori.b    #$0, d0
0101db28  00000000          ori.b    #$0, d0
0101db2c  00000000          ori.b    #$0, d0
0101db30  00000000          ori.b    #$0, d0
0101db34  00000000          ori.b    #$0, d0
0101db38  00000000          ori.b    #$0, d0
0101db3c  00000000          ori.b    #$0, d0
0101db40  00000000          ori.b    #$0, d0
0101db44  00000000          ori.b    #$0, d0
0101db48  00000000          ori.b    #$0, d0
0101db4c  00000000          ori.b    #$0, d0
0101db50  00000000          ori.b    #$0, d0
0101db54  00000000          ori.b    #$0, d0
0101db58  00000000          ori.b    #$0, d0
0101db5c  00000000          ori.b    #$0, d0
0101db60  00000000          ori.b    #$0, d0
0101db64  00000000          ori.b    #$0, d0
0101db68  00000000          ori.b    #$0, d0
0101db6c  00000000          ori.b    #$0, d0
0101db70  00000000          ori.b    #$0, d0
0101db74  00000000          ori.b    #$0, d0
0101db78  00000000          ori.b    #$0, d0
0101db7c  00000000          ori.b    #$0, d0
0101db80  00000000          ori.b    #$0, d0
0101db84  00000000          ori.b    #$0, d0
0101db88  00000000          ori.b    #$0, d0
0101db8c  00000000          ori.b    #$0, d0
0101db90  00000000          ori.b    #$0, d0
0101db94  00000000          ori.b    #$0, d0
0101db98  00000000          ori.b    #$0, d0
0101db9c  00000000          ori.b    #$0, d0
0101dba0  00000000          ori.b    #$0, d0
0101dba4  00000000          ori.b    #$0, d0
0101dba8  00000000          ori.b    #$0, d0
0101dbac  00000000          ori.b    #$0, d0
0101dbb0  00000000          ori.b    #$0, d0
0101dbb4  00000000          ori.b    #$0, d0
0101dbb8  00000000          ori.b    #$0, d0
0101dbbc  00000000          ori.b    #$0, d0
0101dbc0  00000000          ori.b    #$0, d0
0101dbc4  00000000          ori.b    #$0, d0
0101dbc8  00000000          ori.b    #$0, d0
0101dbcc  00000000          ori.b    #$0, d0
0101dbd0  00000000          ori.b    #$0, d0
0101dbd4  00000000          ori.b    #$0, d0
0101dbd8  00000000          ori.b    #$0, d0
0101dbdc  00000000          ori.b    #$0, d0
0101dbe0  00000000          ori.b    #$0, d0
0101dbe4  00000000          ori.b    #$0, d0
0101dbe8  00000000          ori.b    #$0, d0
0101dbec  00000000          ori.b    #$0, d0
0101dbf0  00000000          ori.b    #$0, d0
0101dbf4  00000000          ori.b    #$0, d0
0101dbf8  00000000          ori.b    #$0, d0
0101dbfc  00000000          ori.b    #$0, d0
0101dc00  00000000          ori.b    #$0, d0
0101dc04  00000000          ori.b    #$0, d0
0101dc08  00000000          ori.b    #$0, d0
0101dc0c  00000000          ori.b    #$0, d0
0101dc10  00000000          ori.b    #$0, d0
0101dc14  00000000          ori.b    #$0, d0
0101dc18  00000000          ori.b    #$0, d0
0101dc1c  00000000          ori.b    #$0, d0
0101dc20  00000000          ori.b    #$0, d0
0101dc24  00000000          ori.b    #$0, d0
0101dc28  00000000          ori.b    #$0, d0
0101dc2c  00000000          ori.b    #$0, d0
0101dc30  00000000          ori.b    #$0, d0
0101dc34  00000000          ori.b    #$0, d0
0101dc38  00000000          ori.b    #$0, d0
0101dc3c  00000000          ori.b    #$0, d0
0101dc40  00000000          ori.b    #$0, d0
0101dc44  00000000          ori.b    #$0, d0
0101dc48  00000000          ori.b    #$0, d0
0101dc4c  00000000          ori.b    #$0, d0
0101dc50  00000000          ori.b    #$0, d0
0101dc54  00000000          ori.b    #$0, d0
0101dc58  00000000          ori.b    #$0, d0
0101dc5c  00000000          ori.b    #$0, d0
0101dc60  00000000          ori.b    #$0, d0
0101dc64  00000000          ori.b    #$0, d0
0101dc68  00000000          ori.b    #$0, d0
0101dc6c  00000000          ori.b    #$0, d0
0101dc70  00000000          ori.b    #$0, d0
0101dc74  00000000          ori.b    #$0, d0
0101dc78  00000000          ori.b    #$0, d0
0101dc7c  00000000          ori.b    #$0, d0
0101dc80  00000000          ori.b    #$0, d0
0101dc84  00000000          ori.b    #$0, d0
0101dc88  00000000          ori.b    #$0, d0
0101dc8c  00000000          ori.b    #$0, d0
0101dc90  00000000          ori.b    #$0, d0
0101dc94  00000000          ori.b    #$0, d0
0101dc98  00000000          ori.b    #$0, d0
0101dc9c  00000000          ori.b    #$0, d0
0101dca0  00000000          ori.b    #$0, d0
0101dca4  00000000          ori.b    #$0, d0
0101dca8  00000000          ori.b    #$0, d0
0101dcac  00000000          ori.b    #$0, d0
0101dcb0  00000000          ori.b    #$0, d0
0101dcb4  00000000          ori.b    #$0, d0
0101dcb8  00000000          ori.b    #$0, d0
0101dcbc  00000000          ori.b    #$0, d0
0101dcc0  00000000          ori.b    #$0, d0
0101dcc4  00000000          ori.b    #$0, d0
0101dcc8  00000000          ori.b    #$0, d0
0101dccc  00000000          ori.b    #$0, d0
0101dcd0  00000000          ori.b    #$0, d0
0101dcd4  00000000          ori.b    #$0, d0
0101dcd8  00000000          ori.b    #$0, d0
0101dcdc  00000000          ori.b    #$0, d0
0101dce0  00000000          ori.b    #$0, d0
0101dce4  00000000          ori.b    #$0, d0
0101dce8  00000000          ori.b    #$0, d0
0101dcec  00000000          ori.b    #$0, d0
0101dcf0  00000000          ori.b    #$0, d0
0101dcf4  00000000          ori.b    #$0, d0
0101dcf8  00000000          ori.b    #$0, d0
0101dcfc  00000000          ori.b    #$0, d0
0101dd00  00000000          ori.b    #$0, d0
0101dd04  00000000          ori.b    #$0, d0
0101dd08  00000000          ori.b    #$0, d0
0101dd0c  00000000          ori.b    #$0, d0
0101dd10  00000000          ori.b    #$0, d0
0101dd14  00000000          ori.b    #$0, d0
0101dd18  00000000          ori.b    #$0, d0
0101dd1c  00000000          ori.b    #$0, d0
0101dd20  00000000          ori.b    #$0, d0
0101dd24  00000000          ori.b    #$0, d0
0101dd28  00000000          ori.b    #$0, d0
0101dd2c  00000000          ori.b    #$0, d0
0101dd30  00000000          ori.b    #$0, d0
0101dd34  00000000          ori.b    #$0, d0
0101dd38  00000000          ori.b    #$0, d0
0101dd3c  00000000          ori.b    #$0, d0
0101dd40  00000000          ori.b    #$0, d0
0101dd44  00000000          ori.b    #$0, d0
0101dd48  00000000          ori.b    #$0, d0
0101dd4c  00000000          ori.b    #$0, d0
0101dd50  00000000          ori.b    #$0, d0
0101dd54  00000000          ori.b    #$0, d0
0101dd58  00000000          ori.b    #$0, d0
0101dd5c  00000000          ori.b    #$0, d0
0101dd60  00000000          ori.b    #$0, d0
0101dd64  00000000          ori.b    #$0, d0
0101dd68  00000000          ori.b    #$0, d0
0101dd6c  00000000          ori.b    #$0, d0
0101dd70  00000000          ori.b    #$0, d0
0101dd74  00000000          ori.b    #$0, d0
0101dd78  00000000          ori.b    #$0, d0
0101dd7c  00000000          ori.b    #$0, d0
0101dd80  00000000          ori.b    #$0, d0
0101dd84  00000000          ori.b    #$0, d0
0101dd88  00000000          ori.b    #$0, d0
0101dd8c  00000000          ori.b    #$0, d0
0101dd90  00000000          ori.b    #$0, d0
0101dd94  00000000          ori.b    #$0, d0
0101dd98  00000000          ori.b    #$0, d0
0101dd9c  00000000          ori.b    #$0, d0
0101dda0  00000000          ori.b    #$0, d0
0101dda4  00000000          ori.b    #$0, d0
0101dda8  00000000          ori.b    #$0, d0
0101ddac  00000000          ori.b    #$0, d0
0101ddb0  00000000          ori.b    #$0, d0
0101ddb4  00000000          ori.b    #$0, d0
0101ddb8  00000000          ori.b    #$0, d0
0101ddbc  00000000          ori.b    #$0, d0
0101ddc0  00000000          ori.b    #$0, d0
0101ddc4  00000000          ori.b    #$0, d0
0101ddc8  00000000          ori.b    #$0, d0
0101ddcc  00000000          ori.b    #$0, d0
0101ddd0  00000000          ori.b    #$0, d0
0101ddd4  00000000          ori.b    #$0, d0
0101ddd8  00000000          ori.b    #$0, d0
0101dddc  00000000          ori.b    #$0, d0
0101dde0  00000000          ori.b    #$0, d0
0101dde4  00000000          ori.b    #$0, d0
0101dde8  00000000          ori.b    #$0, d0
0101ddec  00000000          ori.b    #$0, d0
0101ddf0  00000000          ori.b    #$0, d0
0101ddf4  00000000          ori.b    #$0, d0
0101ddf8  00000000          ori.b    #$0, d0
0101ddfc  00000000          ori.b    #$0, d0
0101de00  00000000          ori.b    #$0, d0
0101de04  00000000          ori.b    #$0, d0
0101de08  00000000          ori.b    #$0, d0
0101de0c  00000000          ori.b    #$0, d0
0101de10  00000000          ori.b    #$0, d0
0101de14  00000000          ori.b    #$0, d0
0101de18  00000000          ori.b    #$0, d0
0101de1c  00000000          ori.b    #$0, d0
0101de20  00000000          ori.b    #$0, d0
0101de24  00000000          ori.b    #$0, d0
0101de28  00000000          ori.b    #$0, d0
0101de2c  00000000          ori.b    #$0, d0
0101de30  00000000          ori.b    #$0, d0
0101de34  00000000          ori.b    #$0, d0
0101de38  00000000          ori.b    #$0, d0
0101de3c  00000000          ori.b    #$0, d0
0101de40  00000000          ori.b    #$0, d0
0101de44  00000000          ori.b    #$0, d0
0101de48  00000000          ori.b    #$0, d0
0101de4c  00000000          ori.b    #$0, d0
0101de50  00000000          ori.b    #$0, d0
0101de54  00000000          ori.b    #$0, d0
0101de58  00000000          ori.b    #$0, d0
0101de5c  00000000          ori.b    #$0, d0
0101de60  00000000          ori.b    #$0, d0
0101de64  00000000          ori.b    #$0, d0
0101de68  00000000          ori.b    #$0, d0
0101de6c  00000000          ori.b    #$0, d0
0101de70  00000000          ori.b    #$0, d0
0101de74  00000000          ori.b    #$0, d0
0101de78  00000000          ori.b    #$0, d0
0101de7c  00000000          ori.b    #$0, d0
0101de80  00000000          ori.b    #$0, d0
0101de84  00000000          ori.b    #$0, d0
0101de88  00000000          ori.b    #$0, d0
0101de8c  00000000          ori.b    #$0, d0
0101de90  00000000          ori.b    #$0, d0
0101de94  00000000          ori.b    #$0, d0
0101de98  00000000          ori.b    #$0, d0
0101de9c  00000000          ori.b    #$0, d0
0101dea0  00000000          ori.b    #$0, d0
0101dea4  00000000          ori.b    #$0, d0
0101dea8  00000000          ori.b    #$0, d0
0101deac  00000000          ori.b    #$0, d0
0101deb0  00000000          ori.b    #$0, d0
0101deb4  00000000          ori.b    #$0, d0
0101deb8  00000000          ori.b    #$0, d0
0101debc  00000000          ori.b    #$0, d0
0101dec0  00000000          ori.b    #$0, d0
0101dec4  00000000          ori.b    #$0, d0
0101dec8  00000000          ori.b    #$0, d0
0101decc  00000000          ori.b    #$0, d0
0101ded0  00000000          ori.b    #$0, d0
0101ded4  00000000          ori.b    #$0, d0
0101ded8  00000000          ori.b    #$0, d0
0101dedc  00000000          ori.b    #$0, d0
0101dee0  00000000          ori.b    #$0, d0
0101dee4  00000000          ori.b    #$0, d0
0101dee8  00000000          ori.b    #$0, d0
0101deec  00000000          ori.b    #$0, d0
0101def0  00000000          ori.b    #$0, d0
0101def4  00000000          ori.b    #$0, d0
0101def8  00000000          ori.b    #$0, d0
0101defc  00000000          ori.b    #$0, d0
0101df00  00000000          ori.b    #$0, d0
0101df04  00000000          ori.b    #$0, d0
0101df08  00000000          ori.b    #$0, d0
0101df0c  00000000          ori.b    #$0, d0
0101df10  00000000          ori.b    #$0, d0
0101df14  00000000          ori.b    #$0, d0
0101df18  00000000          ori.b    #$0, d0
0101df1c  00000000          ori.b    #$0, d0
0101df20  00000000          ori.b    #$0, d0
0101df24  00000000          ori.b    #$0, d0
0101df28  00000000          ori.b    #$0, d0
0101df2c  00000000          ori.b    #$0, d0
0101df30  00000000          ori.b    #$0, d0
0101df34  00000000          ori.b    #$0, d0
0101df38  00000000          ori.b    #$0, d0
0101df3c  00000000          ori.b    #$0, d0
0101df40  00000000          ori.b    #$0, d0
0101df44  00000000          ori.b    #$0, d0
0101df48  00000000          ori.b    #$0, d0
0101df4c  00000000          ori.b    #$0, d0
0101df50  00000000          ori.b    #$0, d0
0101df54  00000000          ori.b    #$0, d0
0101df58  00000000          ori.b    #$0, d0
0101df5c  00000000          ori.b    #$0, d0
0101df60  00000000          ori.b    #$0, d0
0101df64  00000000          ori.b    #$0, d0
0101df68  00000000          ori.b    #$0, d0
0101df6c  00000000          ori.b    #$0, d0
0101df70  00000000          ori.b    #$0, d0
0101df74  00000000          ori.b    #$0, d0
0101df78  00000000          ori.b    #$0, d0
0101df7c  00000000          ori.b    #$0, d0
0101df80  00000000          ori.b    #$0, d0
0101df84  00000000          ori.b    #$0, d0
0101df88  00000000          ori.b    #$0, d0
0101df8c  00000000          ori.b    #$0, d0
0101df90  00000000          ori.b    #$0, d0
0101df94  00000000          ori.b    #$0, d0
0101df98  00000000          ori.b    #$0, d0
0101df9c  00000000          ori.b    #$0, d0
0101dfa0  00000000          ori.b    #$0, d0
0101dfa4  00000000          ori.b    #$0, d0
0101dfa8  00000000          ori.b    #$0, d0
0101dfac  00000000          ori.b    #$0, d0
0101dfb0  00000000          ori.b    #$0, d0
0101dfb4  00000000          ori.b    #$0, d0
0101dfb8  00000000          ori.b    #$0, d0
0101dfbc  00000000          ori.b    #$0, d0
0101dfc0  00000000          ori.b    #$0, d0
0101dfc4  00000000          ori.b    #$0, d0
0101dfc8  00000000          ori.b    #$0, d0
0101dfcc  00000000          ori.b    #$0, d0
0101dfd0  00000000          ori.b    #$0, d0
0101dfd4  00000000          ori.b    #$0, d0
0101dfd8  00000000          ori.b    #$0, d0
0101dfdc  00000000          ori.b    #$0, d0
0101dfe0  00000000          ori.b    #$0, d0
0101dfe4  00000000          ori.b    #$0, d0
0101dfe8  00000000          ori.b    #$0, d0
0101dfec  00000000          ori.b    #$0, d0
0101dff0  00000000          ori.b    #$0, d0
0101dff4  00000000          ori.b    #$0, d0
0101dff8  00000000          ori.b    #$0, d0
0101dffc  00000000          ori.b    #$0, d0
0101e000  00000000          ori.b    #$0, d0
0101e004  00000000          ori.b    #$0, d0
0101e008  00000000          ori.b    #$0, d0
0101e00c  00000000          ori.b    #$0, d0
0101e010  00000000          ori.b    #$0, d0
0101e014  00000000          ori.b    #$0, d0
0101e018  00000000          ori.b    #$0, d0
0101e01c  00000000          ori.b    #$0, d0
0101e020  00000000          ori.b    #$0, d0
0101e024  00000000          ori.b    #$0, d0
0101e028  00000000          ori.b    #$0, d0
0101e02c  00000000          ori.b    #$0, d0
0101e030  00000000          ori.b    #$0, d0
0101e034  00000000          ori.b    #$0, d0
0101e038  00000000          ori.b    #$0, d0
0101e03c  00000000          ori.b    #$0, d0
0101e040  00000000          ori.b    #$0, d0
0101e044  00000000          ori.b    #$0, d0
0101e048  00000000          ori.b    #$0, d0
0101e04c  00000000          ori.b    #$0, d0
0101e050  00000000          ori.b    #$0, d0
0101e054  00000000          ori.b    #$0, d0
0101e058  00000000          ori.b    #$0, d0
0101e05c  00000000          ori.b    #$0, d0
0101e060  00000000          ori.b    #$0, d0
0101e064  00000000          ori.b    #$0, d0
0101e068  00000000          ori.b    #$0, d0
0101e06c  00000000          ori.b    #$0, d0
0101e070  00000000          ori.b    #$0, d0
0101e074  00000000          ori.b    #$0, d0
0101e078  00000000          ori.b    #$0, d0
0101e07c  00000000          ori.b    #$0, d0
0101e080  00000000          ori.b    #$0, d0
0101e084  00000000          ori.b    #$0, d0
0101e088  00000000          ori.b    #$0, d0
0101e08c  00000000          ori.b    #$0, d0
0101e090  00000000          ori.b    #$0, d0
0101e094  00000000          ori.b    #$0, d0
0101e098  00000000          ori.b    #$0, d0
0101e09c  00000000          ori.b    #$0, d0
0101e0a0  00000000          ori.b    #$0, d0
0101e0a4  00000000          ori.b    #$0, d0
0101e0a8  00000000          ori.b    #$0, d0
0101e0ac  00000000          ori.b    #$0, d0
0101e0b0  00000000          ori.b    #$0, d0
0101e0b4  00000000          ori.b    #$0, d0
0101e0b8  00000000          ori.b    #$0, d0
0101e0bc  00000000          ori.b    #$0, d0
0101e0c0  00000000          ori.b    #$0, d0
0101e0c4  00000000          ori.b    #$0, d0
0101e0c8  00000000          ori.b    #$0, d0
0101e0cc  00000000          ori.b    #$0, d0
0101e0d0  00000000          ori.b    #$0, d0
0101e0d4  00000000          ori.b    #$0, d0
0101e0d8  00000000          ori.b    #$0, d0
0101e0dc  00000000          ori.b    #$0, d0
0101e0e0  00000000          ori.b    #$0, d0
0101e0e4  00000000          ori.b    #$0, d0
0101e0e8  00000000          ori.b    #$0, d0
0101e0ec  00000000          ori.b    #$0, d0
0101e0f0  00000000          ori.b    #$0, d0
0101e0f4  00000000          ori.b    #$0, d0
0101e0f8  00000000          ori.b    #$0, d0
0101e0fc  00000000          ori.b    #$0, d0
0101e100  00000000          ori.b    #$0, d0
0101e104  00000000          ori.b    #$0, d0
0101e108  00000000          ori.b    #$0, d0
0101e10c  00000000          ori.b    #$0, d0
0101e110  00000000          ori.b    #$0, d0
0101e114  00000000          ori.b    #$0, d0
0101e118  00000000          ori.b    #$0, d0
0101e11c  00000000          ori.b    #$0, d0
0101e120  00000000          ori.b    #$0, d0
0101e124  00000000          ori.b    #$0, d0
0101e128  00000000          ori.b    #$0, d0
0101e12c  00000000          ori.b    #$0, d0
0101e130  00000000          ori.b    #$0, d0
0101e134  00000000          ori.b    #$0, d0
0101e138  00000000          ori.b    #$0, d0
0101e13c  00000000          ori.b    #$0, d0
0101e140  00000000          ori.b    #$0, d0
0101e144  00000000          ori.b    #$0, d0
0101e148  00000000          ori.b    #$0, d0
0101e14c  00000000          ori.b    #$0, d0
0101e150  00000000          ori.b    #$0, d0
0101e154  00000000          ori.b    #$0, d0
0101e158  00000000          ori.b    #$0, d0
0101e15c  00000000          ori.b    #$0, d0
0101e160  00000000          ori.b    #$0, d0
0101e164  00000000          ori.b    #$0, d0
0101e168  00000000          ori.b    #$0, d0
0101e16c  00000000          ori.b    #$0, d0
0101e170  00000000          ori.b    #$0, d0
0101e174  00000000          ori.b    #$0, d0
0101e178  00000000          ori.b    #$0, d0
0101e17c  00000000          ori.b    #$0, d0
0101e180  00000000          ori.b    #$0, d0
0101e184  00000000          ori.b    #$0, d0
0101e188  00000000          ori.b    #$0, d0
0101e18c  00000000          ori.b    #$0, d0
0101e190  00000000          ori.b    #$0, d0
0101e194  00000000          ori.b    #$0, d0
0101e198  00000000          ori.b    #$0, d0
0101e19c  00000000          ori.b    #$0, d0
0101e1a0  00000000          ori.b    #$0, d0
0101e1a4  00000000          ori.b    #$0, d0
0101e1a8  00000000          ori.b    #$0, d0
0101e1ac  00000000          ori.b    #$0, d0
0101e1b0  00000000          ori.b    #$0, d0
0101e1b4  00000000          ori.b    #$0, d0
0101e1b8  00000000          ori.b    #$0, d0
0101e1bc  00000000          ori.b    #$0, d0
0101e1c0  00000000          ori.b    #$0, d0
0101e1c4  00000000          ori.b    #$0, d0
0101e1c8  00000000          ori.b    #$0, d0
0101e1cc  00000000          ori.b    #$0, d0
0101e1d0  00000000          ori.b    #$0, d0
0101e1d4  00000000          ori.b    #$0, d0
0101e1d8  00000000          ori.b    #$0, d0
0101e1dc  00000000          ori.b    #$0, d0
0101e1e0  00000000          ori.b    #$0, d0
0101e1e4  00000000          ori.b    #$0, d0
0101e1e8  00000000          ori.b    #$0, d0
0101e1ec  00000000          ori.b    #$0, d0
0101e1f0  00000000          ori.b    #$0, d0
0101e1f4  00000000          ori.b    #$0, d0
0101e1f8  00000000          ori.b    #$0, d0
0101e1fc  00000000          ori.b    #$0, d0
0101e200  00000000          ori.b    #$0, d0
0101e204  00000000          ori.b    #$0, d0
0101e208  00000000          ori.b    #$0, d0
0101e20c  00000000          ori.b    #$0, d0
0101e210  00000000          ori.b    #$0, d0
0101e214  00000000          ori.b    #$0, d0
0101e218  00000000          ori.b    #$0, d0
0101e21c  00000000          ori.b    #$0, d0
0101e220  00000000          ori.b    #$0, d0
0101e224  00000000          ori.b    #$0, d0
0101e228  00000000          ori.b    #$0, d0
0101e22c  00000000          ori.b    #$0, d0
0101e230  00000000          ori.b    #$0, d0
0101e234  00000000          ori.b    #$0, d0
0101e238  00000000          ori.b    #$0, d0
0101e23c  00000000          ori.b    #$0, d0
0101e240  00000000          ori.b    #$0, d0
0101e244  00000000          ori.b    #$0, d0
0101e248  00000000          ori.b    #$0, d0
0101e24c  00000000          ori.b    #$0, d0
0101e250  00000000          ori.b    #$0, d0
0101e254  00000000          ori.b    #$0, d0
0101e258  00000000          ori.b    #$0, d0
0101e25c  00000000          ori.b    #$0, d0
0101e260  00000000          ori.b    #$0, d0
0101e264  00000000          ori.b    #$0, d0
0101e268  00000000          ori.b    #$0, d0
0101e26c  00000000          ori.b    #$0, d0
0101e270  00000000          ori.b    #$0, d0
0101e274  00000000          ori.b    #$0, d0
0101e278  00000000          ori.b    #$0, d0
0101e27c  00000000          ori.b    #$0, d0
0101e280  00000000          ori.b    #$0, d0
0101e284  00000000          ori.b    #$0, d0
0101e288  00000000          ori.b    #$0, d0
0101e28c  00000000          ori.b    #$0, d0
0101e290  00000000          ori.b    #$0, d0
0101e294  00000000          ori.b    #$0, d0
0101e298  00000000          ori.b    #$0, d0
0101e29c  00000000          ori.b    #$0, d0
0101e2a0  00000000          ori.b    #$0, d0
0101e2a4  00000000          ori.b    #$0, d0
0101e2a8  00000000          ori.b    #$0, d0
0101e2ac  00000000          ori.b    #$0, d0
0101e2b0  00000000          ori.b    #$0, d0
0101e2b4  00000000          ori.b    #$0, d0
0101e2b8  00000000          ori.b    #$0, d0
0101e2bc  00000000          ori.b    #$0, d0
0101e2c0  00000000          ori.b    #$0, d0
0101e2c4  00000000          ori.b    #$0, d0
0101e2c8  00000000          ori.b    #$0, d0
0101e2cc  00000000          ori.b    #$0, d0
0101e2d0  00000000          ori.b    #$0, d0
0101e2d4  00000000          ori.b    #$0, d0
0101e2d8  00000000          ori.b    #$0, d0
0101e2dc  00000000          ori.b    #$0, d0
0101e2e0  00000000          ori.b    #$0, d0
0101e2e4  00000000          ori.b    #$0, d0
0101e2e8  00000000          ori.b    #$0, d0
0101e2ec  00000000          ori.b    #$0, d0
0101e2f0  00000000          ori.b    #$0, d0
0101e2f4  00000000          ori.b    #$0, d0
0101e2f8  00000000          ori.b    #$0, d0
0101e2fc  00000000          ori.b    #$0, d0
0101e300  00000000          ori.b    #$0, d0
0101e304  00000000          ori.b    #$0, d0
0101e308  00000000          ori.b    #$0, d0
0101e30c  00000000          ori.b    #$0, d0
0101e310  00000000          ori.b    #$0, d0
0101e314  00000000          ori.b    #$0, d0
0101e318  00000000          ori.b    #$0, d0
0101e31c  00000000          ori.b    #$0, d0
0101e320  00000000          ori.b    #$0, d0
0101e324  00000000          ori.b    #$0, d0
0101e328  00000000          ori.b    #$0, d0
0101e32c  00000000          ori.b    #$0, d0
0101e330  00000000          ori.b    #$0, d0
0101e334  00000000          ori.b    #$0, d0
0101e338  00000000          ori.b    #$0, d0
0101e33c  00000000          ori.b    #$0, d0
0101e340  00000000          ori.b    #$0, d0
0101e344  00000000          ori.b    #$0, d0
0101e348  00000000          ori.b    #$0, d0
0101e34c  00000000          ori.b    #$0, d0
0101e350  00000000          ori.b    #$0, d0
0101e354  00000000          ori.b    #$0, d0
0101e358  00000000          ori.b    #$0, d0
0101e35c  00000000          ori.b    #$0, d0
0101e360  00000000          ori.b    #$0, d0
0101e364  00000000          ori.b    #$0, d0
0101e368  00000000          ori.b    #$0, d0
0101e36c  00000000          ori.b    #$0, d0
0101e370  00000000          ori.b    #$0, d0
0101e374  00000000          ori.b    #$0, d0
0101e378  00000000          ori.b    #$0, d0
0101e37c  00000000          ori.b    #$0, d0
0101e380  00000000          ori.b    #$0, d0
0101e384  00000000          ori.b    #$0, d0
0101e388  00000000          ori.b    #$0, d0
0101e38c  00000000          ori.b    #$0, d0
0101e390  00000000          ori.b    #$0, d0
0101e394  00000000          ori.b    #$0, d0
0101e398  00000000          ori.b    #$0, d0
0101e39c  00000000          ori.b    #$0, d0
0101e3a0  00000000          ori.b    #$0, d0
0101e3a4  00000000          ori.b    #$0, d0
0101e3a8  00000000          ori.b    #$0, d0
0101e3ac  00000000          ori.b    #$0, d0
0101e3b0  00000000          ori.b    #$0, d0
0101e3b4  00000000          ori.b    #$0, d0
0101e3b8  00000000          ori.b    #$0, d0
0101e3bc  00000000          ori.b    #$0, d0
0101e3c0  00000000          ori.b    #$0, d0
0101e3c4  00000000          ori.b    #$0, d0
0101e3c8  00000000          ori.b    #$0, d0
0101e3cc  00000000          ori.b    #$0, d0
0101e3d0  00000000          ori.b    #$0, d0
0101e3d4  00000000          ori.b    #$0, d0
0101e3d8  00000000          ori.b    #$0, d0
0101e3dc  00000000          ori.b    #$0, d0
0101e3e0  00000000          ori.b    #$0, d0
0101e3e4  00000000          ori.b    #$0, d0
0101e3e8  00000000          ori.b    #$0, d0
0101e3ec  00000000          ori.b    #$0, d0
0101e3f0  00000000          ori.b    #$0, d0
0101e3f4  00000000          ori.b    #$0, d0
0101e3f8  00000000          ori.b    #$0, d0
0101e3fc  00000000          ori.b    #$0, d0
0101e400  00000000          ori.b    #$0, d0
0101e404  00000000          ori.b    #$0, d0
0101e408  00000000          ori.b    #$0, d0
0101e40c  00000000          ori.b    #$0, d0
0101e410  00000000          ori.b    #$0, d0
0101e414  00000000          ori.b    #$0, d0
0101e418  00000000          ori.b    #$0, d0
0101e41c  00000000          ori.b    #$0, d0
0101e420  00000000          ori.b    #$0, d0
0101e424  00000000          ori.b    #$0, d0
0101e428  00000000          ori.b    #$0, d0
0101e42c  00000000          ori.b    #$0, d0
0101e430  00000000          ori.b    #$0, d0
0101e434  00000000          ori.b    #$0, d0
0101e438  00000000          ori.b    #$0, d0
0101e43c  00000000          ori.b    #$0, d0
0101e440  00000000          ori.b    #$0, d0
0101e444  00000000          ori.b    #$0, d0
0101e448  00000000          ori.b    #$0, d0
0101e44c  00000000          ori.b    #$0, d0
0101e450  00000000          ori.b    #$0, d0
0101e454  00000000          ori.b    #$0, d0
0101e458  00000000          ori.b    #$0, d0
0101e45c  00000000          ori.b    #$0, d0
0101e460  00000000          ori.b    #$0, d0
0101e464  00000000          ori.b    #$0, d0
0101e468  00000000          ori.b    #$0, d0
0101e46c  00000000          ori.b    #$0, d0
0101e470  00000000          ori.b    #$0, d0
0101e474  00000000          ori.b    #$0, d0
0101e478  00000000          ori.b    #$0, d0
0101e47c  00000000          ori.b    #$0, d0
0101e480  00000000          ori.b    #$0, d0
0101e484  00000000          ori.b    #$0, d0
0101e488  00000000          ori.b    #$0, d0
0101e48c  00000000          ori.b    #$0, d0
0101e490  00000000          ori.b    #$0, d0
0101e494  00000000          ori.b    #$0, d0
0101e498  00000000          ori.b    #$0, d0
0101e49c  00000000          ori.b    #$0, d0
0101e4a0  00000000          ori.b    #$0, d0
0101e4a4  00000000          ori.b    #$0, d0
0101e4a8  00000000          ori.b    #$0, d0
0101e4ac  00000000          ori.b    #$0, d0
0101e4b0  00000000          ori.b    #$0, d0
0101e4b4  00000000          ori.b    #$0, d0
0101e4b8  00000000          ori.b    #$0, d0
0101e4bc  00000000          ori.b    #$0, d0
0101e4c0  00000000          ori.b    #$0, d0
0101e4c4  00000000          ori.b    #$0, d0
0101e4c8  00000000          ori.b    #$0, d0
0101e4cc  00000000          ori.b    #$0, d0
0101e4d0  00000000          ori.b    #$0, d0
0101e4d4  00000000          ori.b    #$0, d0
0101e4d8  00000000          ori.b    #$0, d0
0101e4dc  00000000          ori.b    #$0, d0
0101e4e0  00000000          ori.b    #$0, d0
0101e4e4  00000000          ori.b    #$0, d0
0101e4e8  00000000          ori.b    #$0, d0
0101e4ec  00000000          ori.b    #$0, d0
0101e4f0  00000000          ori.b    #$0, d0
0101e4f4  00000000          ori.b    #$0, d0
0101e4f8  00000000          ori.b    #$0, d0
0101e4fc  00000000          ori.b    #$0, d0
0101e500  00000000          ori.b    #$0, d0
0101e504  00000000          ori.b    #$0, d0
0101e508  00000000          ori.b    #$0, d0
0101e50c  00000000          ori.b    #$0, d0
0101e510  00000000          ori.b    #$0, d0
0101e514  00000000          ori.b    #$0, d0
0101e518  00000000          ori.b    #$0, d0
0101e51c  00000000          ori.b    #$0, d0
0101e520  00000000          ori.b    #$0, d0
0101e524  00000000          ori.b    #$0, d0
0101e528  00000000          ori.b    #$0, d0
0101e52c  00000000          ori.b    #$0, d0
0101e530  00000000          ori.b    #$0, d0
0101e534  00000000          ori.b    #$0, d0
0101e538  00000000          ori.b    #$0, d0
0101e53c  00000000          ori.b    #$0, d0
0101e540  00000000          ori.b    #$0, d0
0101e544  00000000          ori.b    #$0, d0
0101e548  00000000          ori.b    #$0, d0
0101e54c  00000000          ori.b    #$0, d0
0101e550  00000000          ori.b    #$0, d0
0101e554  00000000          ori.b    #$0, d0
0101e558  00000000          ori.b    #$0, d0
0101e55c  00000000          ori.b    #$0, d0
0101e560  00000000          ori.b    #$0, d0
0101e564  00000000          ori.b    #$0, d0
0101e568  00000000          ori.b    #$0, d0
0101e56c  00000000          ori.b    #$0, d0
0101e570  00000000          ori.b    #$0, d0
0101e574  00000000          ori.b    #$0, d0
0101e578  00000000          ori.b    #$0, d0
0101e57c  00000000          ori.b    #$0, d0
0101e580  00000000          ori.b    #$0, d0
0101e584  00000000          ori.b    #$0, d0
0101e588  00000000          ori.b    #$0, d0
0101e58c  00000000          ori.b    #$0, d0
0101e590  00000000          ori.b    #$0, d0
0101e594  00000000          ori.b    #$0, d0
0101e598  00000000          ori.b    #$0, d0
0101e59c  00000000          ori.b    #$0, d0
0101e5a0  00000000          ori.b    #$0, d0
0101e5a4  00000000          ori.b    #$0, d0
0101e5a8  00000000          ori.b    #$0, d0
0101e5ac  00000000          ori.b    #$0, d0
0101e5b0  00000000          ori.b    #$0, d0
0101e5b4  00000000          ori.b    #$0, d0
0101e5b8  00000000          ori.b    #$0, d0
0101e5bc  00000000          ori.b    #$0, d0
0101e5c0  00000000          ori.b    #$0, d0
0101e5c4  00000000          ori.b    #$0, d0
0101e5c8  00000000          ori.b    #$0, d0
0101e5cc  00000000          ori.b    #$0, d0
0101e5d0  00000000          ori.b    #$0, d0
0101e5d4  00000000          ori.b    #$0, d0
0101e5d8  00000000          ori.b    #$0, d0
0101e5dc  00000000          ori.b    #$0, d0
0101e5e0  00000000          ori.b    #$0, d0
0101e5e4  00000000          ori.b    #$0, d0
0101e5e8  00000000          ori.b    #$0, d0
0101e5ec  00000000          ori.b    #$0, d0
0101e5f0  00000000          ori.b    #$0, d0
0101e5f4  00000000          ori.b    #$0, d0
0101e5f8  00000000          ori.b    #$0, d0
0101e5fc  00000000          ori.b    #$0, d0
0101e600  00000000          ori.b    #$0, d0
0101e604  00000000          ori.b    #$0, d0
0101e608  00000000          ori.b    #$0, d0
0101e60c  00000000          ori.b    #$0, d0
0101e610  00000000          ori.b    #$0, d0
0101e614  00000000          ori.b    #$0, d0
0101e618  00000000          ori.b    #$0, d0
0101e61c  00000000          ori.b    #$0, d0
0101e620  00000000          ori.b    #$0, d0
0101e624  00000000          ori.b    #$0, d0
0101e628  00000000          ori.b    #$0, d0
0101e62c  00000000          ori.b    #$0, d0
0101e630  00000000          ori.b    #$0, d0
0101e634  00000000          ori.b    #$0, d0
0101e638  00000000          ori.b    #$0, d0
0101e63c  00000000          ori.b    #$0, d0
0101e640  00000000          ori.b    #$0, d0
0101e644  00000000          ori.b    #$0, d0
0101e648  00000000          ori.b    #$0, d0
0101e64c  00000000          ori.b    #$0, d0
0101e650  00000000          ori.b    #$0, d0
0101e654  00000000          ori.b    #$0, d0
0101e658  00000000          ori.b    #$0, d0
0101e65c  00000000          ori.b    #$0, d0
0101e660  00000000          ori.b    #$0, d0
0101e664  00000000          ori.b    #$0, d0
0101e668  00000000          ori.b    #$0, d0
0101e66c  00000000          ori.b    #$0, d0
0101e670  00000000          ori.b    #$0, d0
0101e674  00000000          ori.b    #$0, d0
0101e678  00000000          ori.b    #$0, d0
0101e67c  00000000          ori.b    #$0, d0
0101e680  00000000          ori.b    #$0, d0
0101e684  00000000          ori.b    #$0, d0
0101e688  00000000          ori.b    #$0, d0
0101e68c  00000000          ori.b    #$0, d0
0101e690  00000000          ori.b    #$0, d0
0101e694  00000000          ori.b    #$0, d0
0101e698  00000000          ori.b    #$0, d0
0101e69c  00000000          ori.b    #$0, d0
0101e6a0  00000000          ori.b    #$0, d0
0101e6a4  00000000          ori.b    #$0, d0
0101e6a8  00000000          ori.b    #$0, d0
0101e6ac  00000000          ori.b    #$0, d0
0101e6b0  00000000          ori.b    #$0, d0
0101e6b4  00000000          ori.b    #$0, d0
0101e6b8  00000000          ori.b    #$0, d0
0101e6bc  00000000          ori.b    #$0, d0
0101e6c0  00000000          ori.b    #$0, d0
0101e6c4  00000000          ori.b    #$0, d0
0101e6c8  00000000          ori.b    #$0, d0
0101e6cc  00000000          ori.b    #$0, d0
0101e6d0  00000000          ori.b    #$0, d0
0101e6d4  00000000          ori.b    #$0, d0
0101e6d8  00000000          ori.b    #$0, d0
0101e6dc  00000000          ori.b    #$0, d0
0101e6e0  00000000          ori.b    #$0, d0
0101e6e4  00000000          ori.b    #$0, d0
0101e6e8  00000000          ori.b    #$0, d0
0101e6ec  00000000          ori.b    #$0, d0
0101e6f0  00000000          ori.b    #$0, d0
0101e6f4  00000000          ori.b    #$0, d0
0101e6f8  00000000          ori.b    #$0, d0
0101e6fc  00000000          ori.b    #$0, d0
0101e700  00000000          ori.b    #$0, d0
0101e704  00000000          ori.b    #$0, d0
0101e708  00000000          ori.b    #$0, d0
0101e70c  00000000          ori.b    #$0, d0
0101e710  00000000          ori.b    #$0, d0
0101e714  00000000          ori.b    #$0, d0
0101e718  00000000          ori.b    #$0, d0
0101e71c  00000000          ori.b    #$0, d0
0101e720  00000000          ori.b    #$0, d0
0101e724  00000000          ori.b    #$0, d0
0101e728  00000000          ori.b    #$0, d0
0101e72c  00000000          ori.b    #$0, d0
0101e730  00000000          ori.b    #$0, d0
0101e734  00000000          ori.b    #$0, d0
0101e738  00000000          ori.b    #$0, d0
0101e73c  00000000          ori.b    #$0, d0
0101e740  00000000          ori.b    #$0, d0
0101e744  00000000          ori.b    #$0, d0
0101e748  00000000          ori.b    #$0, d0
0101e74c  00000000          ori.b    #$0, d0
0101e750  00000000          ori.b    #$0, d0
0101e754  00000000          ori.b    #$0, d0
0101e758  00000000          ori.b    #$0, d0
0101e75c  00000000          ori.b    #$0, d0
0101e760  00000000          ori.b    #$0, d0
0101e764  00000000          ori.b    #$0, d0
0101e768  00000000          ori.b    #$0, d0
0101e76c  00000000          ori.b    #$0, d0
0101e770  00000000          ori.b    #$0, d0
0101e774  00000000          ori.b    #$0, d0
0101e778  00000000          ori.b    #$0, d0
0101e77c  00000000          ori.b    #$0, d0
0101e780  00000000          ori.b    #$0, d0
0101e784  00000000          ori.b    #$0, d0
0101e788  00000000          ori.b    #$0, d0
0101e78c  00000000          ori.b    #$0, d0
0101e790  00000000          ori.b    #$0, d0
0101e794  00000000          ori.b    #$0, d0
0101e798  00000000          ori.b    #$0, d0
0101e79c  00000000          ori.b    #$0, d0
0101e7a0  00000000          ori.b    #$0, d0
0101e7a4  00000000          ori.b    #$0, d0
0101e7a8  00000000          ori.b    #$0, d0
0101e7ac  00000000          ori.b    #$0, d0
0101e7b0  00000000          ori.b    #$0, d0
0101e7b4  00000000          ori.b    #$0, d0
0101e7b8  00000000          ori.b    #$0, d0
0101e7bc  00000000          ori.b    #$0, d0
0101e7c0  00000000          ori.b    #$0, d0
0101e7c4  00000000          ori.b    #$0, d0
0101e7c8  00000000          ori.b    #$0, d0
0101e7cc  00000000          ori.b    #$0, d0
0101e7d0  00000000          ori.b    #$0, d0
0101e7d4  00000000          ori.b    #$0, d0
0101e7d8  00000000          ori.b    #$0, d0
0101e7dc  00000000          ori.b    #$0, d0
0101e7e0  00000000          ori.b    #$0, d0
0101e7e4  00000000          ori.b    #$0, d0
0101e7e8  00000000          ori.b    #$0, d0
0101e7ec  00000000          ori.b    #$0, d0
0101e7f0  00000000          ori.b    #$0, d0
0101e7f4  00000000          ori.b    #$0, d0
0101e7f8  00000000          ori.b    #$0, d0
0101e7fc  00000000          ori.b    #$0, d0
0101e800  00000000          ori.b    #$0, d0
0101e804  00000000          ori.b    #$0, d0
0101e808  00000000          ori.b    #$0, d0
0101e80c  00000000          ori.b    #$0, d0
0101e810  00000000          ori.b    #$0, d0
0101e814  00000000          ori.b    #$0, d0
0101e818  00000000          ori.b    #$0, d0
0101e81c  00000000          ori.b    #$0, d0
0101e820  00000000          ori.b    #$0, d0
0101e824  00000000          ori.b    #$0, d0
0101e828  00000000          ori.b    #$0, d0
0101e82c  00000000          ori.b    #$0, d0
0101e830  00000000          ori.b    #$0, d0
0101e834  00000000          ori.b    #$0, d0
0101e838  00000000          ori.b    #$0, d0
0101e83c  00000000          ori.b    #$0, d0
0101e840  00000000          ori.b    #$0, d0
0101e844  00000000          ori.b    #$0, d0
0101e848  00000000          ori.b    #$0, d0
0101e84c  00000000          ori.b    #$0, d0
0101e850  00000000          ori.b    #$0, d0
0101e854  00000000          ori.b    #$0, d0
0101e858  00000000          ori.b    #$0, d0
0101e85c  00000000          ori.b    #$0, d0
0101e860  00000000          ori.b    #$0, d0
0101e864  00000000          ori.b    #$0, d0
0101e868  00000000          ori.b    #$0, d0
0101e86c  00000000          ori.b    #$0, d0
0101e870  00000000          ori.b    #$0, d0
0101e874  00000000          ori.b    #$0, d0
0101e878  00000000          ori.b    #$0, d0
0101e87c  00000000          ori.b    #$0, d0
0101e880  00000000          ori.b    #$0, d0
0101e884  00000000          ori.b    #$0, d0
0101e888  00000000          ori.b    #$0, d0
0101e88c  00000000          ori.b    #$0, d0
0101e890  00000000          ori.b    #$0, d0
0101e894  00000000          ori.b    #$0, d0
0101e898  00000000          ori.b    #$0, d0
0101e89c  00000000          ori.b    #$0, d0
0101e8a0  00000000          ori.b    #$0, d0
0101e8a4  00000000          ori.b    #$0, d0
0101e8a8  00000000          ori.b    #$0, d0
0101e8ac  00000000          ori.b    #$0, d0
0101e8b0  00000000          ori.b    #$0, d0
0101e8b4  00000000          ori.b    #$0, d0
0101e8b8  00000000          ori.b    #$0, d0
0101e8bc  00000000          ori.b    #$0, d0
0101e8c0  00000000          ori.b    #$0, d0
0101e8c4  00000000          ori.b    #$0, d0
0101e8c8  00000000          ori.b    #$0, d0
0101e8cc  00000000          ori.b    #$0, d0
0101e8d0  00000000          ori.b    #$0, d0
0101e8d4  00000000          ori.b    #$0, d0
0101e8d8  00000000          ori.b    #$0, d0
0101e8dc  00000000          ori.b    #$0, d0
0101e8e0  00000000          ori.b    #$0, d0
0101e8e4  00000000          ori.b    #$0, d0
0101e8e8  00000000          ori.b    #$0, d0
0101e8ec  00000000          ori.b    #$0, d0
0101e8f0  00000000          ori.b    #$0, d0
0101e8f4  00000000          ori.b    #$0, d0
0101e8f8  00000000          ori.b    #$0, d0
0101e8fc  00000000          ori.b    #$0, d0
0101e900  00000000          ori.b    #$0, d0
0101e904  00000000          ori.b    #$0, d0
0101e908  00000000          ori.b    #$0, d0
0101e90c  00000000          ori.b    #$0, d0
0101e910  00000000          ori.b    #$0, d0
0101e914  00000000          ori.b    #$0, d0
0101e918  00000000          ori.b    #$0, d0
0101e91c  00000000          ori.b    #$0, d0
0101e920  00000000          ori.b    #$0, d0
0101e924  00000000          ori.b    #$0, d0
0101e928  00000000          ori.b    #$0, d0
0101e92c  00000000          ori.b    #$0, d0
0101e930  00000000          ori.b    #$0, d0
0101e934  00000000          ori.b    #$0, d0
0101e938  00000000          ori.b    #$0, d0
0101e93c  00000000          ori.b    #$0, d0
0101e940  00000000          ori.b    #$0, d0
0101e944  00000000          ori.b    #$0, d0
0101e948  00000000          ori.b    #$0, d0
0101e94c  00000000          ori.b    #$0, d0
0101e950  00000000          ori.b    #$0, d0
0101e954  00000000          ori.b    #$0, d0
0101e958  00000000          ori.b    #$0, d0
0101e95c  00000000          ori.b    #$0, d0
0101e960  00000000          ori.b    #$0, d0
0101e964  00000000          ori.b    #$0, d0
0101e968  00000000          ori.b    #$0, d0
0101e96c  00000000          ori.b    #$0, d0
0101e970  00000000          ori.b    #$0, d0
0101e974  00000000          ori.b    #$0, d0
0101e978  00000000          ori.b    #$0, d0
0101e97c  00000000          ori.b    #$0, d0
0101e980  00000000          ori.b    #$0, d0
0101e984  00000000          ori.b    #$0, d0
0101e988  00000000          ori.b    #$0, d0
0101e98c  00000000          ori.b    #$0, d0
0101e990  00000000          ori.b    #$0, d0
0101e994  00000000          ori.b    #$0, d0
0101e998  00000000          ori.b    #$0, d0
0101e99c  00000000          ori.b    #$0, d0
0101e9a0  00000000          ori.b    #$0, d0
0101e9a4  00000000          ori.b    #$0, d0
0101e9a8  00000000          ori.b    #$0, d0
0101e9ac  00000000          ori.b    #$0, d0
0101e9b0  00000000          ori.b    #$0, d0
0101e9b4  00000000          ori.b    #$0, d0
0101e9b8  00000000          ori.b    #$0, d0
0101e9bc  00000000          ori.b    #$0, d0
0101e9c0  00000000          ori.b    #$0, d0
0101e9c4  00000000          ori.b    #$0, d0
0101e9c8  00000000          ori.b    #$0, d0
0101e9cc  00000000          ori.b    #$0, d0
0101e9d0  00000000          ori.b    #$0, d0
0101e9d4  00000000          ori.b    #$0, d0
0101e9d8  00000000          ori.b    #$0, d0
0101e9dc  00000000          ori.b    #$0, d0
0101e9e0  00000000          ori.b    #$0, d0
0101e9e4  00000000          ori.b    #$0, d0
0101e9e8  00000000          ori.b    #$0, d0
0101e9ec  00000000          ori.b    #$0, d0
0101e9f0  00000000          ori.b    #$0, d0
0101e9f4  00000000          ori.b    #$0, d0
0101e9f8  00000000          ori.b    #$0, d0
0101e9fc  00000000          ori.b    #$0, d0
0101ea00  00000000          ori.b    #$0, d0
0101ea04  00000000          ori.b    #$0, d0
0101ea08  00000000          ori.b    #$0, d0
0101ea0c  00000000          ori.b    #$0, d0
0101ea10  00000000          ori.b    #$0, d0
0101ea14  00000000          ori.b    #$0, d0
0101ea18  00000000          ori.b    #$0, d0
0101ea1c  00000000          ori.b    #$0, d0
0101ea20  00000000          ori.b    #$0, d0
0101ea24  00000000          ori.b    #$0, d0
0101ea28  00000000          ori.b    #$0, d0
0101ea2c  00000000          ori.b    #$0, d0
0101ea30  00000000          ori.b    #$0, d0
0101ea34  00000000          ori.b    #$0, d0
0101ea38  00000000          ori.b    #$0, d0
0101ea3c  00000000          ori.b    #$0, d0
0101ea40  00000000          ori.b    #$0, d0
0101ea44  00000000          ori.b    #$0, d0
0101ea48  00000000          ori.b    #$0, d0
0101ea4c  00000000          ori.b    #$0, d0
0101ea50  00000000          ori.b    #$0, d0
0101ea54  00000000          ori.b    #$0, d0
0101ea58  00000000          ori.b    #$0, d0
0101ea5c  00000000          ori.b    #$0, d0
0101ea60  00000000          ori.b    #$0, d0
0101ea64  00000000          ori.b    #$0, d0
0101ea68  00000000          ori.b    #$0, d0
0101ea6c  00000000          ori.b    #$0, d0
0101ea70  00000000          ori.b    #$0, d0
0101ea74  00000000          ori.b    #$0, d0
0101ea78  00000000          ori.b    #$0, d0
0101ea7c  00000000          ori.b    #$0, d0
0101ea80  00000000          ori.b    #$0, d0
0101ea84  00000000          ori.b    #$0, d0
0101ea88  00000000          ori.b    #$0, d0
0101ea8c  00000000          ori.b    #$0, d0
0101ea90  00000000          ori.b    #$0, d0
0101ea94  00000000          ori.b    #$0, d0
0101ea98  00000000          ori.b    #$0, d0
0101ea9c  00000000          ori.b    #$0, d0
0101eaa0  00000000          ori.b    #$0, d0
0101eaa4  00000000          ori.b    #$0, d0
0101eaa8  00000000          ori.b    #$0, d0
0101eaac  00000000          ori.b    #$0, d0
0101eab0  00000000          ori.b    #$0, d0
0101eab4  00000000          ori.b    #$0, d0
0101eab8  00000000          ori.b    #$0, d0
0101eabc  00000000          ori.b    #$0, d0
0101eac0  00000000          ori.b    #$0, d0
0101eac4  00000000          ori.b    #$0, d0
0101eac8  00000000          ori.b    #$0, d0
0101eacc  00000000          ori.b    #$0, d0
0101ead0  00000000          ori.b    #$0, d0
0101ead4  00000000          ori.b    #$0, d0
0101ead8  00000000          ori.b    #$0, d0
0101eadc  00000000          ori.b    #$0, d0
0101eae0  00000000          ori.b    #$0, d0
0101eae4  00000000          ori.b    #$0, d0
0101eae8  00000000          ori.b    #$0, d0
0101eaec  00000000          ori.b    #$0, d0
0101eaf0  00000000          ori.b    #$0, d0
0101eaf4  00000000          ori.b    #$0, d0
0101eaf8  00000000          ori.b    #$0, d0
0101eafc  00000000          ori.b    #$0, d0
0101eb00  00000000          ori.b    #$0, d0
0101eb04  00000000          ori.b    #$0, d0
0101eb08  00000000          ori.b    #$0, d0
0101eb0c  00000000          ori.b    #$0, d0
0101eb10  00000000          ori.b    #$0, d0
0101eb14  00000000          ori.b    #$0, d0
0101eb18  00000000          ori.b    #$0, d0
0101eb1c  00000000          ori.b    #$0, d0
0101eb20  00000000          ori.b    #$0, d0
0101eb24  00000000          ori.b    #$0, d0
0101eb28  00000000          ori.b    #$0, d0
0101eb2c  00000000          ori.b    #$0, d0
0101eb30  00000000          ori.b    #$0, d0
0101eb34  00000000          ori.b    #$0, d0
0101eb38  00000000          ori.b    #$0, d0
0101eb3c  00000000          ori.b    #$0, d0
0101eb40  00000000          ori.b    #$0, d0
0101eb44  00000000          ori.b    #$0, d0
0101eb48  00000000          ori.b    #$0, d0
0101eb4c  00000000          ori.b    #$0, d0
0101eb50  00000000          ori.b    #$0, d0
0101eb54  00000000          ori.b    #$0, d0
0101eb58  00000000          ori.b    #$0, d0
0101eb5c  00000000          ori.b    #$0, d0
0101eb60  00000000          ori.b    #$0, d0
0101eb64  00000000          ori.b    #$0, d0
0101eb68  00000000          ori.b    #$0, d0
0101eb6c  00000000          ori.b    #$0, d0
0101eb70  00000000          ori.b    #$0, d0
0101eb74  00000000          ori.b    #$0, d0
0101eb78  00000000          ori.b    #$0, d0
0101eb7c  00000000          ori.b    #$0, d0
0101eb80  00000000          ori.b    #$0, d0
0101eb84  00000000          ori.b    #$0, d0
0101eb88  00000000          ori.b    #$0, d0
0101eb8c  00000000          ori.b    #$0, d0
0101eb90  00000000          ori.b    #$0, d0
0101eb94  00000000          ori.b    #$0, d0
0101eb98  00000000          ori.b    #$0, d0
0101eb9c  00000000          ori.b    #$0, d0
0101eba0  00000000          ori.b    #$0, d0
0101eba4  00000000          ori.b    #$0, d0
0101eba8  00000000          ori.b    #$0, d0
0101ebac  00000000          ori.b    #$0, d0
0101ebb0  00000000          ori.b    #$0, d0
0101ebb4  00000000          ori.b    #$0, d0
0101ebb8  00000000          ori.b    #$0, d0
0101ebbc  00000000          ori.b    #$0, d0
0101ebc0  00000000          ori.b    #$0, d0
0101ebc4  00000000          ori.b    #$0, d0
0101ebc8  00000000          ori.b    #$0, d0
0101ebcc  00000000          ori.b    #$0, d0
0101ebd0  00000000          ori.b    #$0, d0
0101ebd4  00000000          ori.b    #$0, d0
0101ebd8  00000000          ori.b    #$0, d0
0101ebdc  00000000          ori.b    #$0, d0
0101ebe0  00000000          ori.b    #$0, d0
0101ebe4  00000000          ori.b    #$0, d0
0101ebe8  00000000          ori.b    #$0, d0
0101ebec  00000000          ori.b    #$0, d0
0101ebf0  00000000          ori.b    #$0, d0
0101ebf4  00000000          ori.b    #$0, d0
0101ebf8  00000000          ori.b    #$0, d0
0101ebfc  00000000          ori.b    #$0, d0
0101ec00  00000000          ori.b    #$0, d0
0101ec04  00000000          ori.b    #$0, d0
0101ec08  00000000          ori.b    #$0, d0
0101ec0c  00000000          ori.b    #$0, d0
0101ec10  00000000          ori.b    #$0, d0
0101ec14  00000000          ori.b    #$0, d0
0101ec18  00000000          ori.b    #$0, d0
0101ec1c  00000000          ori.b    #$0, d0
0101ec20  00000000          ori.b    #$0, d0
0101ec24  00000000          ori.b    #$0, d0
0101ec28  00000000          ori.b    #$0, d0
0101ec2c  00000000          ori.b    #$0, d0
0101ec30  00000000          ori.b    #$0, d0
0101ec34  00000000          ori.b    #$0, d0
0101ec38  00000000          ori.b    #$0, d0
0101ec3c  00000000          ori.b    #$0, d0
0101ec40  00000000          ori.b    #$0, d0
0101ec44  00000000          ori.b    #$0, d0
0101ec48  00000000          ori.b    #$0, d0
0101ec4c  00000000          ori.b    #$0, d0
0101ec50  00000000          ori.b    #$0, d0
0101ec54  00000000          ori.b    #$0, d0
0101ec58  00000000          ori.b    #$0, d0
0101ec5c  00000000          ori.b    #$0, d0
0101ec60  00000000          ori.b    #$0, d0
0101ec64  00000000          ori.b    #$0, d0
0101ec68  00000000          ori.b    #$0, d0
0101ec6c  00000000          ori.b    #$0, d0
0101ec70  00000000          ori.b    #$0, d0
0101ec74  00000000          ori.b    #$0, d0
0101ec78  00000000          ori.b    #$0, d0
0101ec7c  00000000          ori.b    #$0, d0
0101ec80  00000000          ori.b    #$0, d0
0101ec84  00000000          ori.b    #$0, d0
0101ec88  00000000          ori.b    #$0, d0
0101ec8c  00000000          ori.b    #$0, d0
0101ec90  00000000          ori.b    #$0, d0
0101ec94  00000000          ori.b    #$0, d0
0101ec98  00000000          ori.b    #$0, d0
0101ec9c  00000000          ori.b    #$0, d0
0101eca0  00000000          ori.b    #$0, d0
0101eca4  00000000          ori.b    #$0, d0
0101eca8  00000000          ori.b    #$0, d0
0101ecac  00000000          ori.b    #$0, d0
0101ecb0  00000000          ori.b    #$0, d0
0101ecb4  00000000          ori.b    #$0, d0
0101ecb8  00000000          ori.b    #$0, d0
0101ecbc  00000000          ori.b    #$0, d0
0101ecc0  00000000          ori.b    #$0, d0
0101ecc4  00000000          ori.b    #$0, d0
0101ecc8  00000000          ori.b    #$0, d0
0101eccc  00000000          ori.b    #$0, d0
0101ecd0  00000000          ori.b    #$0, d0
0101ecd4  00000000          ori.b    #$0, d0
0101ecd8  00000000          ori.b    #$0, d0
0101ecdc  00000000          ori.b    #$0, d0
0101ece0  00000000          ori.b    #$0, d0
0101ece4  00000000          ori.b    #$0, d0
0101ece8  00000000          ori.b    #$0, d0
0101ecec  00000000          ori.b    #$0, d0
0101ecf0  00000000          ori.b    #$0, d0
0101ecf4  00000000          ori.b    #$0, d0
0101ecf8  00000000          ori.b    #$0, d0
0101ecfc  00000000          ori.b    #$0, d0
0101ed00  00000000          ori.b    #$0, d0
0101ed04  00000000          ori.b    #$0, d0
0101ed08  00000000          ori.b    #$0, d0
0101ed0c  00000000          ori.b    #$0, d0
0101ed10  00000000          ori.b    #$0, d0
0101ed14  00000000          ori.b    #$0, d0
0101ed18  00000000          ori.b    #$0, d0
0101ed1c  00000000          ori.b    #$0, d0
0101ed20  00000000          ori.b    #$0, d0
0101ed24  00000000          ori.b    #$0, d0
0101ed28  00000000          ori.b    #$0, d0
0101ed2c  00000000          ori.b    #$0, d0
0101ed30  00000000          ori.b    #$0, d0
0101ed34  00000000          ori.b    #$0, d0
0101ed38  00000000          ori.b    #$0, d0
0101ed3c  00000000          ori.b    #$0, d0
0101ed40  00000000          ori.b    #$0, d0
0101ed44  00000000          ori.b    #$0, d0
0101ed48  00000000          ori.b    #$0, d0
0101ed4c  00000000          ori.b    #$0, d0
0101ed50  00000000          ori.b    #$0, d0
0101ed54  00000000          ori.b    #$0, d0
0101ed58  00000000          ori.b    #$0, d0
0101ed5c  00000000          ori.b    #$0, d0
0101ed60  00000000          ori.b    #$0, d0
0101ed64  00000000          ori.b    #$0, d0
0101ed68  00000000          ori.b    #$0, d0
0101ed6c  00000000          ori.b    #$0, d0
0101ed70  00000000          ori.b    #$0, d0
0101ed74  00000000          ori.b    #$0, d0
0101ed78  00000000          ori.b    #$0, d0
0101ed7c  00000000          ori.b    #$0, d0
0101ed80  00000000          ori.b    #$0, d0
0101ed84  00000000          ori.b    #$0, d0
0101ed88  00000000          ori.b    #$0, d0
0101ed8c  00000000          ori.b    #$0, d0
0101ed90  00000000          ori.b    #$0, d0
0101ed94  00000000          ori.b    #$0, d0
0101ed98  00000000          ori.b    #$0, d0
0101ed9c  00000000          ori.b    #$0, d0
0101eda0  00000000          ori.b    #$0, d0
0101eda4  00000000          ori.b    #$0, d0
0101eda8  00000000          ori.b    #$0, d0
0101edac  00000000          ori.b    #$0, d0
0101edb0  00000000          ori.b    #$0, d0
0101edb4  00000000          ori.b    #$0, d0
0101edb8  00000000          ori.b    #$0, d0
0101edbc  00000000          ori.b    #$0, d0
0101edc0  00000000          ori.b    #$0, d0
0101edc4  00000000          ori.b    #$0, d0
0101edc8  00000000          ori.b    #$0, d0
0101edcc  00000000          ori.b    #$0, d0
0101edd0  00000000          ori.b    #$0, d0
0101edd4  00000000          ori.b    #$0, d0
0101edd8  00000000          ori.b    #$0, d0
0101eddc  00000000          ori.b    #$0, d0
0101ede0  00000000          ori.b    #$0, d0
0101ede4  00000000          ori.b    #$0, d0
0101ede8  00000000          ori.b    #$0, d0
0101edec  00000000          ori.b    #$0, d0
0101edf0  00000000          ori.b    #$0, d0
0101edf4  00000000          ori.b    #$0, d0
0101edf8  00000000          ori.b    #$0, d0
0101edfc  00000000          ori.b    #$0, d0
0101ee00  00000000          ori.b    #$0, d0
0101ee04  00000000          ori.b    #$0, d0
0101ee08  00000000          ori.b    #$0, d0
0101ee0c  00000000          ori.b    #$0, d0
0101ee10  00000000          ori.b    #$0, d0
0101ee14  00000000          ori.b    #$0, d0
0101ee18  00000000          ori.b    #$0, d0
0101ee1c  00000000          ori.b    #$0, d0
0101ee20  00000000          ori.b    #$0, d0
0101ee24  00000000          ori.b    #$0, d0
0101ee28  00000000          ori.b    #$0, d0
0101ee2c  00000000          ori.b    #$0, d0
0101ee30  00000000          ori.b    #$0, d0
0101ee34  00000000          ori.b    #$0, d0
0101ee38  00000000          ori.b    #$0, d0
0101ee3c  00000000          ori.b    #$0, d0
0101ee40  00000000          ori.b    #$0, d0
0101ee44  00000000          ori.b    #$0, d0
0101ee48  00000000          ori.b    #$0, d0
0101ee4c  00000000          ori.b    #$0, d0
0101ee50  00000000          ori.b    #$0, d0
0101ee54  00000000          ori.b    #$0, d0
0101ee58  00000000          ori.b    #$0, d0
0101ee5c  00000000          ori.b    #$0, d0
0101ee60  00000000          ori.b    #$0, d0
0101ee64  00000000          ori.b    #$0, d0
0101ee68  00000000          ori.b    #$0, d0
0101ee6c  00000000          ori.b    #$0, d0
0101ee70  00000000          ori.b    #$0, d0
0101ee74  00000000          ori.b    #$0, d0
0101ee78  00000000          ori.b    #$0, d0
0101ee7c  00000000          ori.b    #$0, d0
0101ee80  00000000          ori.b    #$0, d0
0101ee84  00000000          ori.b    #$0, d0
0101ee88  00000000          ori.b    #$0, d0
0101ee8c  00000000          ori.b    #$0, d0
0101ee90  00000000          ori.b    #$0, d0
0101ee94  00000000          ori.b    #$0, d0
0101ee98  00000000          ori.b    #$0, d0
0101ee9c  00000000          ori.b    #$0, d0
0101eea0  00000000          ori.b    #$0, d0
0101eea4  00000000          ori.b    #$0, d0
0101eea8  00000000          ori.b    #$0, d0
0101eeac  00000000          ori.b    #$0, d0
0101eeb0  00000000          ori.b    #$0, d0
0101eeb4  00000000          ori.b    #$0, d0
0101eeb8  00000000          ori.b    #$0, d0
0101eebc  00000000          ori.b    #$0, d0
0101eec0  00000000          ori.b    #$0, d0
0101eec4  00000000          ori.b    #$0, d0
0101eec8  00000000          ori.b    #$0, d0
0101eecc  00000000          ori.b    #$0, d0
0101eed0  00000000          ori.b    #$0, d0
0101eed4  00000000          ori.b    #$0, d0
0101eed8  00000000          ori.b    #$0, d0
0101eedc  00000000          ori.b    #$0, d0
0101eee0  00000000          ori.b    #$0, d0
0101eee4  00000000          ori.b    #$0, d0
0101eee8  00000000          ori.b    #$0, d0
0101eeec  00000000          ori.b    #$0, d0
0101eef0  00000000          ori.b    #$0, d0
0101eef4  00000000          ori.b    #$0, d0
0101eef8  00000000          ori.b    #$0, d0
0101eefc  00000000          ori.b    #$0, d0
0101ef00  00000000          ori.b    #$0, d0
0101ef04  00000000          ori.b    #$0, d0
0101ef08  00000000          ori.b    #$0, d0
0101ef0c  00000000          ori.b    #$0, d0
0101ef10  00000000          ori.b    #$0, d0
0101ef14  00000000          ori.b    #$0, d0
0101ef18  00000000          ori.b    #$0, d0
0101ef1c  00000000          ori.b    #$0, d0
0101ef20  00000000          ori.b    #$0, d0
0101ef24  00000000          ori.b    #$0, d0
0101ef28  00000000          ori.b    #$0, d0
0101ef2c  00000000          ori.b    #$0, d0
0101ef30  00000000          ori.b    #$0, d0
0101ef34  00000000          ori.b    #$0, d0
0101ef38  00000000          ori.b    #$0, d0
0101ef3c  00000000          ori.b    #$0, d0
0101ef40  00000000          ori.b    #$0, d0
0101ef44  00000000          ori.b    #$0, d0
0101ef48  00000000          ori.b    #$0, d0
0101ef4c  00000000          ori.b    #$0, d0
0101ef50  00000000          ori.b    #$0, d0
0101ef54  00000000          ori.b    #$0, d0
0101ef58  00000000          ori.b    #$0, d0
0101ef5c  00000000          ori.b    #$0, d0
0101ef60  00000000          ori.b    #$0, d0
0101ef64  00000000          ori.b    #$0, d0
0101ef68  00000000          ori.b    #$0, d0
0101ef6c  00000000          ori.b    #$0, d0
0101ef70  00000000          ori.b    #$0, d0
0101ef74  00000000          ori.b    #$0, d0
0101ef78  00000000          ori.b    #$0, d0
0101ef7c  00000000          ori.b    #$0, d0
0101ef80  00000000          ori.b    #$0, d0
0101ef84  00000000          ori.b    #$0, d0
0101ef88  00000000          ori.b    #$0, d0
0101ef8c  00000000          ori.b    #$0, d0
0101ef90  00000000          ori.b    #$0, d0
0101ef94  00000000          ori.b    #$0, d0
0101ef98  00000000          ori.b    #$0, d0
0101ef9c  00000000          ori.b    #$0, d0
0101efa0  00000000          ori.b    #$0, d0
0101efa4  00000000          ori.b    #$0, d0
0101efa8  00000000          ori.b    #$0, d0
0101efac  00000000          ori.b    #$0, d0
0101efb0  00000000          ori.b    #$0, d0
0101efb4  00000000          ori.b    #$0, d0
0101efb8  00000000          ori.b    #$0, d0
0101efbc  00000000          ori.b    #$0, d0
0101efc0  00000000          ori.b    #$0, d0
0101efc4  00000000          ori.b    #$0, d0
0101efc8  00000000          ori.b    #$0, d0
0101efcc  00000000          ori.b    #$0, d0
0101efd0  00000000          ori.b    #$0, d0
0101efd4  00000000          ori.b    #$0, d0
0101efd8  00000000          ori.b    #$0, d0
0101efdc  00000000          ori.b    #$0, d0
0101efe0  00000000          ori.b    #$0, d0
0101efe4  00000000          ori.b    #$0, d0
0101efe8  00000000          ori.b    #$0, d0
0101efec  00000000          ori.b    #$0, d0
0101eff0  00000000          ori.b    #$0, d0
0101eff4  00000000          ori.b    #$0, d0
0101eff8  00000000          ori.b    #$0, d0
0101effc  00000000          ori.b    #$0, d0
0101f000  00000000          ori.b    #$0, d0
0101f004  00000000          ori.b    #$0, d0
0101f008  00000000          ori.b    #$0, d0
0101f00c  00000000          ori.b    #$0, d0
0101f010  00000000          ori.b    #$0, d0
0101f014  00000000          ori.b    #$0, d0
0101f018  00000000          ori.b    #$0, d0
0101f01c  00000000          ori.b    #$0, d0
0101f020  00000000          ori.b    #$0, d0
0101f024  00000000          ori.b    #$0, d0
0101f028  00000000          ori.b    #$0, d0
0101f02c  00000000          ori.b    #$0, d0
0101f030  00000000          ori.b    #$0, d0
0101f034  00000000          ori.b    #$0, d0
0101f038  00000000          ori.b    #$0, d0
0101f03c  00000000          ori.b    #$0, d0
0101f040  00000000          ori.b    #$0, d0
0101f044  00000000          ori.b    #$0, d0
0101f048  00000000          ori.b    #$0, d0
0101f04c  00000000          ori.b    #$0, d0
0101f050  00000000          ori.b    #$0, d0
0101f054  00000000          ori.b    #$0, d0
0101f058  00000000          ori.b    #$0, d0
0101f05c  00000000          ori.b    #$0, d0
0101f060  00000000          ori.b    #$0, d0
0101f064  00000000          ori.b    #$0, d0
0101f068  00000000          ori.b    #$0, d0
0101f06c  00000000          ori.b    #$0, d0
0101f070  00000000          ori.b    #$0, d0
0101f074  00000000          ori.b    #$0, d0
0101f078  00000000          ori.b    #$0, d0
0101f07c  00000000          ori.b    #$0, d0
0101f080  00000000          ori.b    #$0, d0
0101f084  00000000          ori.b    #$0, d0
0101f088  00000000          ori.b    #$0, d0
0101f08c  00000000          ori.b    #$0, d0
0101f090  00000000          ori.b    #$0, d0
0101f094  00000000          ori.b    #$0, d0
0101f098  00000000          ori.b    #$0, d0
0101f09c  00000000          ori.b    #$0, d0
0101f0a0  00000000          ori.b    #$0, d0
0101f0a4  00000000          ori.b    #$0, d0
0101f0a8  00000000          ori.b    #$0, d0
0101f0ac  00000000          ori.b    #$0, d0
0101f0b0  00000000          ori.b    #$0, d0
0101f0b4  00000000          ori.b    #$0, d0
0101f0b8  00000000          ori.b    #$0, d0
0101f0bc  00000000          ori.b    #$0, d0
0101f0c0  00000000          ori.b    #$0, d0
0101f0c4  00000000          ori.b    #$0, d0
0101f0c8  00000000          ori.b    #$0, d0
0101f0cc  00000000          ori.b    #$0, d0
0101f0d0  00000000          ori.b    #$0, d0
0101f0d4  00000000          ori.b    #$0, d0
0101f0d8  00000000          ori.b    #$0, d0
0101f0dc  00000000          ori.b    #$0, d0
0101f0e0  00000000          ori.b    #$0, d0
0101f0e4  00000000          ori.b    #$0, d0
0101f0e8  00000000          ori.b    #$0, d0
0101f0ec  00000000          ori.b    #$0, d0
0101f0f0  00000000          ori.b    #$0, d0
0101f0f4  00000000          ori.b    #$0, d0
0101f0f8  00000000          ori.b    #$0, d0
0101f0fc  00000000          ori.b    #$0, d0
0101f100  00000000          ori.b    #$0, d0
0101f104  00000000          ori.b    #$0, d0
0101f108  00000000          ori.b    #$0, d0
0101f10c  00000000          ori.b    #$0, d0
0101f110  00000000          ori.b    #$0, d0
0101f114  00000000          ori.b    #$0, d0
0101f118  00000000          ori.b    #$0, d0
0101f11c  00000000          ori.b    #$0, d0
0101f120  00000000          ori.b    #$0, d0
0101f124  00000000          ori.b    #$0, d0
0101f128  00000000          ori.b    #$0, d0
0101f12c  00000000          ori.b    #$0, d0
0101f130  00000000          ori.b    #$0, d0
0101f134  00000000          ori.b    #$0, d0
0101f138  00000000          ori.b    #$0, d0
0101f13c  00000000          ori.b    #$0, d0
0101f140  00000000          ori.b    #$0, d0
0101f144  00000000          ori.b    #$0, d0
0101f148  00000000          ori.b    #$0, d0
0101f14c  00000000          ori.b    #$0, d0
0101f150  00000000          ori.b    #$0, d0
0101f154  00000000          ori.b    #$0, d0
0101f158  00000000          ori.b    #$0, d0
0101f15c  00000000          ori.b    #$0, d0
0101f160  00000000          ori.b    #$0, d0
0101f164  00000000          ori.b    #$0, d0
0101f168  00000000          ori.b    #$0, d0
0101f16c  00000000          ori.b    #$0, d0
0101f170  00000000          ori.b    #$0, d0
0101f174  00000000          ori.b    #$0, d0
0101f178  00000000          ori.b    #$0, d0
0101f17c  00000000          ori.b    #$0, d0
0101f180  00000000          ori.b    #$0, d0
0101f184  00000000          ori.b    #$0, d0
0101f188  00000000          ori.b    #$0, d0
0101f18c  00000000          ori.b    #$0, d0
0101f190  00000000          ori.b    #$0, d0
0101f194  00000000          ori.b    #$0, d0
0101f198  00000000          ori.b    #$0, d0
0101f19c  00000000          ori.b    #$0, d0
0101f1a0  00000000          ori.b    #$0, d0
0101f1a4  00000000          ori.b    #$0, d0
0101f1a8  00000000          ori.b    #$0, d0
0101f1ac  00000000          ori.b    #$0, d0
0101f1b0  00000000          ori.b    #$0, d0
0101f1b4  00000000          ori.b    #$0, d0
0101f1b8  00000000          ori.b    #$0, d0
0101f1bc  00000000          ori.b    #$0, d0
0101f1c0  00000000          ori.b    #$0, d0
0101f1c4  00000000          ori.b    #$0, d0
0101f1c8  00000000          ori.b    #$0, d0
0101f1cc  00000000          ori.b    #$0, d0
0101f1d0  00000000          ori.b    #$0, d0
0101f1d4  00000000          ori.b    #$0, d0
0101f1d8  00000000          ori.b    #$0, d0
0101f1dc  00000000          ori.b    #$0, d0
0101f1e0  00000000          ori.b    #$0, d0
0101f1e4  00000000          ori.b    #$0, d0
0101f1e8  00000000          ori.b    #$0, d0
0101f1ec  00000000          ori.b    #$0, d0
0101f1f0  00000000          ori.b    #$0, d0
0101f1f4  00000000          ori.b    #$0, d0
0101f1f8  00000000          ori.b    #$0, d0
0101f1fc  00000000          ori.b    #$0, d0
0101f200  00000000          ori.b    #$0, d0
0101f204  00000000          ori.b    #$0, d0
0101f208  00000000          ori.b    #$0, d0
0101f20c  00000000          ori.b    #$0, d0
0101f210  00000000          ori.b    #$0, d0
0101f214  00000000          ori.b    #$0, d0
0101f218  00000000          ori.b    #$0, d0
0101f21c  00000000          ori.b    #$0, d0
0101f220  00000000          ori.b    #$0, d0
0101f224  00000000          ori.b    #$0, d0
0101f228  00000000          ori.b    #$0, d0
0101f22c  00000000          ori.b    #$0, d0
0101f230  00000000          ori.b    #$0, d0
0101f234  00000000          ori.b    #$0, d0
0101f238  00000000          ori.b    #$0, d0
0101f23c  00000000          ori.b    #$0, d0
0101f240  00000000          ori.b    #$0, d0
0101f244  00000000          ori.b    #$0, d0
0101f248  00000000          ori.b    #$0, d0
0101f24c  00000000          ori.b    #$0, d0
0101f250  00000000          ori.b    #$0, d0
0101f254  00000000          ori.b    #$0, d0
0101f258  00000000          ori.b    #$0, d0
0101f25c  00000000          ori.b    #$0, d0
0101f260  00000000          ori.b    #$0, d0
0101f264  00000000          ori.b    #$0, d0
0101f268  00000000          ori.b    #$0, d0
0101f26c  00000000          ori.b    #$0, d0
0101f270  00000000          ori.b    #$0, d0
0101f274  00000000          ori.b    #$0, d0
0101f278  00000000          ori.b    #$0, d0
0101f27c  00000000          ori.b    #$0, d0
0101f280  00000000          ori.b    #$0, d0
0101f284  00000000          ori.b    #$0, d0
0101f288  00000000          ori.b    #$0, d0
0101f28c  00000000          ori.b    #$0, d0
0101f290  00000000          ori.b    #$0, d0
0101f294  00000000          ori.b    #$0, d0
0101f298  00000000          ori.b    #$0, d0
0101f29c  00000000          ori.b    #$0, d0
0101f2a0  00000000          ori.b    #$0, d0
0101f2a4  00000000          ori.b    #$0, d0
0101f2a8  00000000          ori.b    #$0, d0
0101f2ac  00000000          ori.b    #$0, d0
0101f2b0  00000000          ori.b    #$0, d0
0101f2b4  00000000          ori.b    #$0, d0
0101f2b8  00000000          ori.b    #$0, d0
0101f2bc  00000000          ori.b    #$0, d0
0101f2c0  00000000          ori.b    #$0, d0
0101f2c4  00000000          ori.b    #$0, d0
0101f2c8  00000000          ori.b    #$0, d0
0101f2cc  00000000          ori.b    #$0, d0
0101f2d0  00000000          ori.b    #$0, d0
0101f2d4  00000000          ori.b    #$0, d0
0101f2d8  00000000          ori.b    #$0, d0
0101f2dc  00000000          ori.b    #$0, d0
0101f2e0  00000000          ori.b    #$0, d0
0101f2e4  00000000          ori.b    #$0, d0
0101f2e8  00000000          ori.b    #$0, d0
0101f2ec  00000000          ori.b    #$0, d0
0101f2f0  00000000          ori.b    #$0, d0
0101f2f4  00000000          ori.b    #$0, d0
0101f2f8  00000000          ori.b    #$0, d0
0101f2fc  00000000          ori.b    #$0, d0
0101f300  00000000          ori.b    #$0, d0
0101f304  00000000          ori.b    #$0, d0
0101f308  00000000          ori.b    #$0, d0
0101f30c  00000000          ori.b    #$0, d0
0101f310  00000000          ori.b    #$0, d0
0101f314  00000000          ori.b    #$0, d0
0101f318  00000000          ori.b    #$0, d0
0101f31c  00000000          ori.b    #$0, d0
0101f320  00000000          ori.b    #$0, d0
0101f324  00000000          ori.b    #$0, d0
0101f328  00000000          ori.b    #$0, d0
0101f32c  00000000          ori.b    #$0, d0
0101f330  00000000          ori.b    #$0, d0
0101f334  00000000          ori.b    #$0, d0
0101f338  00000000          ori.b    #$0, d0
0101f33c  00000000          ori.b    #$0, d0
0101f340  00000000          ori.b    #$0, d0
0101f344  00000000          ori.b    #$0, d0
0101f348  00000000          ori.b    #$0, d0
0101f34c  00000000          ori.b    #$0, d0
0101f350  00000000          ori.b    #$0, d0
0101f354  00000000          ori.b    #$0, d0
0101f358  00000000          ori.b    #$0, d0
0101f35c  00000000          ori.b    #$0, d0
0101f360  00000000          ori.b    #$0, d0
0101f364  00000000          ori.b    #$0, d0
0101f368  00000000          ori.b    #$0, d0
0101f36c  00000000          ori.b    #$0, d0
0101f370  00000000          ori.b    #$0, d0
0101f374  00000000          ori.b    #$0, d0
0101f378  00000000          ori.b    #$0, d0
0101f37c  00000000          ori.b    #$0, d0
0101f380  00000000          ori.b    #$0, d0
0101f384  00000000          ori.b    #$0, d0
0101f388  00000000          ori.b    #$0, d0
0101f38c  00000000          ori.b    #$0, d0
0101f390  00000000          ori.b    #$0, d0
0101f394  00000000          ori.b    #$0, d0
0101f398  00000000          ori.b    #$0, d0
0101f39c  00000000          ori.b    #$0, d0
0101f3a0  00000000          ori.b    #$0, d0
0101f3a4  00000000          ori.b    #$0, d0
0101f3a8  00000000          ori.b    #$0, d0
0101f3ac  00000000          ori.b    #$0, d0
0101f3b0  00000000          ori.b    #$0, d0
0101f3b4  00000000          ori.b    #$0, d0
0101f3b8  00000000          ori.b    #$0, d0
0101f3bc  00000000          ori.b    #$0, d0
0101f3c0  00000000          ori.b    #$0, d0
0101f3c4  00000000          ori.b    #$0, d0
0101f3c8  00000000          ori.b    #$0, d0
0101f3cc  00000000          ori.b    #$0, d0
0101f3d0  00000000          ori.b    #$0, d0
0101f3d4  00000000          ori.b    #$0, d0
0101f3d8  00000000          ori.b    #$0, d0
0101f3dc  00000000          ori.b    #$0, d0
0101f3e0  00000000          ori.b    #$0, d0
0101f3e4  00000000          ori.b    #$0, d0
0101f3e8  00000000          ori.b    #$0, d0
0101f3ec  00000000          ori.b    #$0, d0
0101f3f0  00000000          ori.b    #$0, d0
0101f3f4  00000000          ori.b    #$0, d0
0101f3f8  00000000          ori.b    #$0, d0
0101f3fc  00000000          ori.b    #$0, d0
0101f400  00000000          ori.b    #$0, d0
0101f404  00000000          ori.b    #$0, d0
0101f408  00000000          ori.b    #$0, d0
0101f40c  00000000          ori.b    #$0, d0
0101f410  00000000          ori.b    #$0, d0
0101f414  00000000          ori.b    #$0, d0
0101f418  00000000          ori.b    #$0, d0
0101f41c  00000000          ori.b    #$0, d0
0101f420  00000000          ori.b    #$0, d0
0101f424  00000000          ori.b    #$0, d0
0101f428  00000000          ori.b    #$0, d0
0101f42c  00000000          ori.b    #$0, d0
0101f430  00000000          ori.b    #$0, d0
0101f434  00000000          ori.b    #$0, d0
0101f438  00000000          ori.b    #$0, d0
0101f43c  00000000          ori.b    #$0, d0
0101f440  00000000          ori.b    #$0, d0
0101f444  00000000          ori.b    #$0, d0
0101f448  00000000          ori.b    #$0, d0
0101f44c  00000000          ori.b    #$0, d0
0101f450  00000000          ori.b    #$0, d0
0101f454  00000000          ori.b    #$0, d0
0101f458  00000000          ori.b    #$0, d0
0101f45c  00000000          ori.b    #$0, d0
0101f460  00000000          ori.b    #$0, d0
0101f464  00000000          ori.b    #$0, d0
0101f468  00000000          ori.b    #$0, d0
0101f46c  00000000          ori.b    #$0, d0
0101f470  00000000          ori.b    #$0, d0
0101f474  00000000          ori.b    #$0, d0
0101f478  00000000          ori.b    #$0, d0
0101f47c  00000000          ori.b    #$0, d0
0101f480  00000000          ori.b    #$0, d0
0101f484  00000000          ori.b    #$0, d0
0101f488  00000000          ori.b    #$0, d0
0101f48c  00000000          ori.b    #$0, d0
0101f490  00000000          ori.b    #$0, d0
0101f494  00000000          ori.b    #$0, d0
0101f498  00000000          ori.b    #$0, d0
0101f49c  00000000          ori.b    #$0, d0
0101f4a0  00000000          ori.b    #$0, d0
0101f4a4  00000000          ori.b    #$0, d0
0101f4a8  00000000          ori.b    #$0, d0
0101f4ac  00000000          ori.b    #$0, d0
0101f4b0  00000000          ori.b    #$0, d0
0101f4b4  00000000          ori.b    #$0, d0
0101f4b8  00000000          ori.b    #$0, d0
0101f4bc  00000000          ori.b    #$0, d0
0101f4c0  00000000          ori.b    #$0, d0
0101f4c4  00000000          ori.b    #$0, d0
0101f4c8  00000000          ori.b    #$0, d0
0101f4cc  00000000          ori.b    #$0, d0
0101f4d0  00000000          ori.b    #$0, d0
0101f4d4  00000000          ori.b    #$0, d0
0101f4d8  00000000          ori.b    #$0, d0
0101f4dc  00000000          ori.b    #$0, d0
0101f4e0  00000000          ori.b    #$0, d0
0101f4e4  00000000          ori.b    #$0, d0
0101f4e8  00000000          ori.b    #$0, d0
0101f4ec  00000000          ori.b    #$0, d0
0101f4f0  00000000          ori.b    #$0, d0
0101f4f4  00000000          ori.b    #$0, d0
0101f4f8  00000000          ori.b    #$0, d0
0101f4fc  00000000          ori.b    #$0, d0
0101f500  00000000          ori.b    #$0, d0
0101f504  00000000          ori.b    #$0, d0
0101f508  00000000          ori.b    #$0, d0
0101f50c  00000000          ori.b    #$0, d0
0101f510  00000000          ori.b    #$0, d0
0101f514  00000000          ori.b    #$0, d0
0101f518  00000000          ori.b    #$0, d0
0101f51c  00000000          ori.b    #$0, d0
0101f520  00000000          ori.b    #$0, d0
0101f524  00000000          ori.b    #$0, d0
0101f528  00000000          ori.b    #$0, d0
0101f52c  00000000          ori.b    #$0, d0
0101f530  00000000          ori.b    #$0, d0
0101f534  00000000          ori.b    #$0, d0
0101f538  00000000          ori.b    #$0, d0
0101f53c  00000000          ori.b    #$0, d0
0101f540  00000000          ori.b    #$0, d0
0101f544  00000000          ori.b    #$0, d0
0101f548  00000000          ori.b    #$0, d0
0101f54c  00000000          ori.b    #$0, d0
0101f550  00000000          ori.b    #$0, d0
0101f554  00000000          ori.b    #$0, d0
0101f558  00000000          ori.b    #$0, d0
0101f55c  00000000          ori.b    #$0, d0
0101f560  00000000          ori.b    #$0, d0
0101f564  00000000          ori.b    #$0, d0
0101f568  00000000          ori.b    #$0, d0
0101f56c  00000000          ori.b    #$0, d0
0101f570  00000000          ori.b    #$0, d0
0101f574  00000000          ori.b    #$0, d0
0101f578  00000000          ori.b    #$0, d0
0101f57c  00000000          ori.b    #$0, d0
0101f580  00000000          ori.b    #$0, d0
0101f584  00000000          ori.b    #$0, d0
0101f588  00000000          ori.b    #$0, d0
0101f58c  00000000          ori.b    #$0, d0
0101f590  00000000          ori.b    #$0, d0
0101f594  00000000          ori.b    #$0, d0
0101f598  00000000          ori.b    #$0, d0
0101f59c  00000000          ori.b    #$0, d0
0101f5a0  00000000          ori.b    #$0, d0
0101f5a4  00000000          ori.b    #$0, d0
0101f5a8  00000000          ori.b    #$0, d0
0101f5ac  00000000          ori.b    #$0, d0
0101f5b0  00000000          ori.b    #$0, d0
0101f5b4  00000000          ori.b    #$0, d0
0101f5b8  00000000          ori.b    #$0, d0
0101f5bc  00000000          ori.b    #$0, d0
0101f5c0  00000000          ori.b    #$0, d0
0101f5c4  00000000          ori.b    #$0, d0
0101f5c8  00000000          ori.b    #$0, d0
0101f5cc  00000000          ori.b    #$0, d0
0101f5d0  00000000          ori.b    #$0, d0
0101f5d4  00000000          ori.b    #$0, d0
0101f5d8  00000000          ori.b    #$0, d0
0101f5dc  00000000          ori.b    #$0, d0
0101f5e0  00000000          ori.b    #$0, d0
0101f5e4  00000000          ori.b    #$0, d0
0101f5e8  00000000          ori.b    #$0, d0
0101f5ec  00000000          ori.b    #$0, d0
0101f5f0  00000000          ori.b    #$0, d0
0101f5f4  00000000          ori.b    #$0, d0
0101f5f8  00000000          ori.b    #$0, d0
0101f5fc  00000000          ori.b    #$0, d0
0101f600  00000000          ori.b    #$0, d0
0101f604  00000000          ori.b    #$0, d0
0101f608  00000000          ori.b    #$0, d0
0101f60c  00000000          ori.b    #$0, d0
0101f610  00000000          ori.b    #$0, d0
0101f614  00000000          ori.b    #$0, d0
0101f618  00000000          ori.b    #$0, d0
0101f61c  00000000          ori.b    #$0, d0
0101f620  00000000          ori.b    #$0, d0
0101f624  00000000          ori.b    #$0, d0
0101f628  00000000          ori.b    #$0, d0
0101f62c  00000000          ori.b    #$0, d0
0101f630  00000000          ori.b    #$0, d0
0101f634  00000000          ori.b    #$0, d0
0101f638  00000000          ori.b    #$0, d0
0101f63c  00000000          ori.b    #$0, d0
0101f640  00000000          ori.b    #$0, d0
0101f644  00000000          ori.b    #$0, d0
0101f648  00000000          ori.b    #$0, d0
0101f64c  00000000          ori.b    #$0, d0
0101f650  00000000          ori.b    #$0, d0
0101f654  00000000          ori.b    #$0, d0
0101f658  00000000          ori.b    #$0, d0
0101f65c  00000000          ori.b    #$0, d0
0101f660  00000000          ori.b    #$0, d0
0101f664  00000000          ori.b    #$0, d0
0101f668  00000000          ori.b    #$0, d0
0101f66c  00000000          ori.b    #$0, d0
0101f670  00000000          ori.b    #$0, d0
0101f674  00000000          ori.b    #$0, d0
0101f678  00000000          ori.b    #$0, d0
0101f67c  00000000          ori.b    #$0, d0
0101f680  00000000          ori.b    #$0, d0
0101f684  00000000          ori.b    #$0, d0
0101f688  00000000          ori.b    #$0, d0
0101f68c  00000000          ori.b    #$0, d0
0101f690  00000000          ori.b    #$0, d0
0101f694  00000000          ori.b    #$0, d0
0101f698  00000000          ori.b    #$0, d0
0101f69c  00000000          ori.b    #$0, d0
0101f6a0  00000000          ori.b    #$0, d0
0101f6a4  00000000          ori.b    #$0, d0
0101f6a8  00000000          ori.b    #$0, d0
0101f6ac  00000000          ori.b    #$0, d0
0101f6b0  00000000          ori.b    #$0, d0
0101f6b4  00000000          ori.b    #$0, d0
0101f6b8  00000000          ori.b    #$0, d0
0101f6bc  00000000          ori.b    #$0, d0
0101f6c0  00000000          ori.b    #$0, d0
0101f6c4  00000000          ori.b    #$0, d0
0101f6c8  00000000          ori.b    #$0, d0
0101f6cc  00000000          ori.b    #$0, d0
0101f6d0  00000000          ori.b    #$0, d0
0101f6d4  00000000          ori.b    #$0, d0
0101f6d8  00000000          ori.b    #$0, d0
0101f6dc  00000000          ori.b    #$0, d0
0101f6e0  00000000          ori.b    #$0, d0
0101f6e4  00000000          ori.b    #$0, d0
0101f6e8  00000000          ori.b    #$0, d0
0101f6ec  00000000          ori.b    #$0, d0
0101f6f0  00000000          ori.b    #$0, d0
0101f6f4  00000000          ori.b    #$0, d0
0101f6f8  00000000          ori.b    #$0, d0
0101f6fc  00000000          ori.b    #$0, d0
0101f700  00000000          ori.b    #$0, d0
0101f704  00000000          ori.b    #$0, d0
0101f708  00000000          ori.b    #$0, d0
0101f70c  00000000          ori.b    #$0, d0
0101f710  00000000          ori.b    #$0, d0
0101f714  00000000          ori.b    #$0, d0
0101f718  00000000          ori.b    #$0, d0
0101f71c  00000000          ori.b    #$0, d0
0101f720  00000000          ori.b    #$0, d0
0101f724  00000000          ori.b    #$0, d0
0101f728  00000000          ori.b    #$0, d0
0101f72c  00000000          ori.b    #$0, d0
0101f730  00000000          ori.b    #$0, d0
0101f734  00000000          ori.b    #$0, d0
0101f738  00000000          ori.b    #$0, d0
0101f73c  00000000          ori.b    #$0, d0
0101f740  00000000          ori.b    #$0, d0
0101f744  00000000          ori.b    #$0, d0
0101f748  00000000          ori.b    #$0, d0
0101f74c  00000000          ori.b    #$0, d0
0101f750  00000000          ori.b    #$0, d0
0101f754  00000000          ori.b    #$0, d0
0101f758  00000000          ori.b    #$0, d0
0101f75c  00000000          ori.b    #$0, d0
0101f760  00000000          ori.b    #$0, d0
0101f764  00000000          ori.b    #$0, d0
0101f768  00000000          ori.b    #$0, d0
0101f76c  00000000          ori.b    #$0, d0
0101f770  00000000          ori.b    #$0, d0
0101f774  00000000          ori.b    #$0, d0
0101f778  00000000          ori.b    #$0, d0
0101f77c  00000000          ori.b    #$0, d0
0101f780  00000000          ori.b    #$0, d0
0101f784  00000000          ori.b    #$0, d0
0101f788  00000000          ori.b    #$0, d0
0101f78c  00000000          ori.b    #$0, d0
0101f790  00000000          ori.b    #$0, d0
0101f794  00000000          ori.b    #$0, d0
0101f798  00000000          ori.b    #$0, d0
0101f79c  00000000          ori.b    #$0, d0
0101f7a0  00000000          ori.b    #$0, d0
0101f7a4  00000000          ori.b    #$0, d0
0101f7a8  00000000          ori.b    #$0, d0
0101f7ac  00000000          ori.b    #$0, d0
0101f7b0  00000000          ori.b    #$0, d0
0101f7b4  00000000          ori.b    #$0, d0
0101f7b8  00000000          ori.b    #$0, d0
0101f7bc  00000000          ori.b    #$0, d0
0101f7c0  00000000          ori.b    #$0, d0
0101f7c4  00000000          ori.b    #$0, d0
0101f7c8  00000000          ori.b    #$0, d0
0101f7cc  00000000          ori.b    #$0, d0
0101f7d0  00000000          ori.b    #$0, d0
0101f7d4  00000000          ori.b    #$0, d0
0101f7d8  00000000          ori.b    #$0, d0
0101f7dc  00000000          ori.b    #$0, d0
0101f7e0  00000000          ori.b    #$0, d0
0101f7e4  00000000          ori.b    #$0, d0
0101f7e8  00000000          ori.b    #$0, d0
0101f7ec  00000000          ori.b    #$0, d0
0101f7f0  00000000          ori.b    #$0, d0
0101f7f4  00000000          ori.b    #$0, d0
0101f7f8  00000000          ori.b    #$0, d0
0101f7fc  00000000          ori.b    #$0, d0
0101f800  00000000          ori.b    #$0, d0
0101f804  00000000          ori.b    #$0, d0
0101f808  00000000          ori.b    #$0, d0
0101f80c  00000000          ori.b    #$0, d0
0101f810  00000000          ori.b    #$0, d0
0101f814  00000000          ori.b    #$0, d0
0101f818  00000000          ori.b    #$0, d0
0101f81c  00000000          ori.b    #$0, d0
0101f820  00000000          ori.b    #$0, d0
0101f824  00000000          ori.b    #$0, d0
0101f828  00000000          ori.b    #$0, d0
0101f82c  00000000          ori.b    #$0, d0
0101f830  00000000          ori.b    #$0, d0
0101f834  00000000          ori.b    #$0, d0
0101f838  00000000          ori.b    #$0, d0
0101f83c  00000000          ori.b    #$0, d0
0101f840  00000000          ori.b    #$0, d0
0101f844  00000000          ori.b    #$0, d0
0101f848  00000000          ori.b    #$0, d0
0101f84c  00000000          ori.b    #$0, d0
0101f850  00000000          ori.b    #$0, d0
0101f854  00000000          ori.b    #$0, d0
0101f858  00000000          ori.b    #$0, d0
0101f85c  00000000          ori.b    #$0, d0
0101f860  00000000          ori.b    #$0, d0
0101f864  00000000          ori.b    #$0, d0
0101f868  00000000          ori.b    #$0, d0
0101f86c  00000000          ori.b    #$0, d0
0101f870  00000000          ori.b    #$0, d0
0101f874  00000000          ori.b    #$0, d0
0101f878  00000000          ori.b    #$0, d0
0101f87c  00000000          ori.b    #$0, d0
0101f880  00000000          ori.b    #$0, d0
0101f884  00000000          ori.b    #$0, d0
0101f888  00000000          ori.b    #$0, d0
0101f88c  00000000          ori.b    #$0, d0
0101f890  00000000          ori.b    #$0, d0
0101f894  00000000          ori.b    #$0, d0
0101f898  00000000          ori.b    #$0, d0
0101f89c  00000000          ori.b    #$0, d0
0101f8a0  00000000          ori.b    #$0, d0
0101f8a4  00000000          ori.b    #$0, d0
0101f8a8  00000000          ori.b    #$0, d0
0101f8ac  00000000          ori.b    #$0, d0
0101f8b0  00000000          ori.b    #$0, d0
0101f8b4  00000000          ori.b    #$0, d0
0101f8b8  00000000          ori.b    #$0, d0
0101f8bc  00000000          ori.b    #$0, d0
0101f8c0  00000000          ori.b    #$0, d0
0101f8c4  00000000          ori.b    #$0, d0
0101f8c8  00000000          ori.b    #$0, d0
0101f8cc  00000000          ori.b    #$0, d0
0101f8d0  00000000          ori.b    #$0, d0
0101f8d4  00000000          ori.b    #$0, d0
0101f8d8  00000000          ori.b    #$0, d0
0101f8dc  00000000          ori.b    #$0, d0
0101f8e0  00000000          ori.b    #$0, d0
0101f8e4  00000000          ori.b    #$0, d0
0101f8e8  00000000          ori.b    #$0, d0
0101f8ec  00000000          ori.b    #$0, d0
0101f8f0  00000000          ori.b    #$0, d0
0101f8f4  00000000          ori.b    #$0, d0
0101f8f8  00000000          ori.b    #$0, d0
0101f8fc  00000000          ori.b    #$0, d0
0101f900  00000000          ori.b    #$0, d0
0101f904  00000000          ori.b    #$0, d0
0101f908  00000000          ori.b    #$0, d0
0101f90c  00000000          ori.b    #$0, d0
0101f910  00000000          ori.b    #$0, d0
0101f914  00000000          ori.b    #$0, d0
0101f918  00000000          ori.b    #$0, d0
0101f91c  00000000          ori.b    #$0, d0
0101f920  00000000          ori.b    #$0, d0
0101f924  00000000          ori.b    #$0, d0
0101f928  00000000          ori.b    #$0, d0
0101f92c  00000000          ori.b    #$0, d0
0101f930  00000000          ori.b    #$0, d0
0101f934  00000000          ori.b    #$0, d0
0101f938  00000000          ori.b    #$0, d0
0101f93c  00000000          ori.b    #$0, d0
0101f940  00000000          ori.b    #$0, d0
0101f944  00000000          ori.b    #$0, d0
0101f948  00000000          ori.b    #$0, d0
0101f94c  00000000          ori.b    #$0, d0
0101f950  00000000          ori.b    #$0, d0
0101f954  00000000          ori.b    #$0, d0
0101f958  00000000          ori.b    #$0, d0
0101f95c  00000000          ori.b    #$0, d0
0101f960  00000000          ori.b    #$0, d0
0101f964  00000000          ori.b    #$0, d0
0101f968  00000000          ori.b    #$0, d0
0101f96c  00000000          ori.b    #$0, d0
0101f970  00000000          ori.b    #$0, d0
0101f974  00000000          ori.b    #$0, d0
0101f978  00000000          ori.b    #$0, d0
0101f97c  00000000          ori.b    #$0, d0
0101f980  00000000          ori.b    #$0, d0
0101f984  00000000          ori.b    #$0, d0
0101f988  00000000          ori.b    #$0, d0
0101f98c  00000000          ori.b    #$0, d0
0101f990  00000000          ori.b    #$0, d0
0101f994  00000000          ori.b    #$0, d0
0101f998  00000000          ori.b    #$0, d0
0101f99c  00000000          ori.b    #$0, d0
0101f9a0  00000000          ori.b    #$0, d0
0101f9a4  00000000          ori.b    #$0, d0
0101f9a8  00000000          ori.b    #$0, d0
0101f9ac  00000000          ori.b    #$0, d0
0101f9b0  00000000          ori.b    #$0, d0
0101f9b4  00000000          ori.b    #$0, d0
0101f9b8  00000000          ori.b    #$0, d0
0101f9bc  00000000          ori.b    #$0, d0
0101f9c0  00000000          ori.b    #$0, d0
0101f9c4  00000000          ori.b    #$0, d0
0101f9c8  00000000          ori.b    #$0, d0
0101f9cc  00000000          ori.b    #$0, d0
0101f9d0  00000000          ori.b    #$0, d0
0101f9d4  00000000          ori.b    #$0, d0
0101f9d8  00000000          ori.b    #$0, d0
0101f9dc  00000000          ori.b    #$0, d0
0101f9e0  00000000          ori.b    #$0, d0
0101f9e4  00000000          ori.b    #$0, d0
0101f9e8  00000000          ori.b    #$0, d0
0101f9ec  00000000          ori.b    #$0, d0
0101f9f0  00000000          ori.b    #$0, d0
0101f9f4  00000000          ori.b    #$0, d0
0101f9f8  00000000          ori.b    #$0, d0
0101f9fc  00000000          ori.b    #$0, d0
0101fa00  00000000          ori.b    #$0, d0
0101fa04  00000000          ori.b    #$0, d0
0101fa08  00000000          ori.b    #$0, d0
0101fa0c  00000000          ori.b    #$0, d0
0101fa10  00000000          ori.b    #$0, d0
0101fa14  00000000          ori.b    #$0, d0
0101fa18  00000000          ori.b    #$0, d0
0101fa1c  00000000          ori.b    #$0, d0
0101fa20  00000000          ori.b    #$0, d0
0101fa24  00000000          ori.b    #$0, d0
0101fa28  00000000          ori.b    #$0, d0
0101fa2c  00000000          ori.b    #$0, d0
0101fa30  00000000          ori.b    #$0, d0
0101fa34  00000000          ori.b    #$0, d0
0101fa38  00000000          ori.b    #$0, d0
0101fa3c  00000000          ori.b    #$0, d0
0101fa40  00000000          ori.b    #$0, d0
0101fa44  00000000          ori.b    #$0, d0
0101fa48  00000000          ori.b    #$0, d0
0101fa4c  00000000          ori.b    #$0, d0
0101fa50  00000000          ori.b    #$0, d0
0101fa54  00000000          ori.b    #$0, d0
0101fa58  00000000          ori.b    #$0, d0
0101fa5c  00000000          ori.b    #$0, d0
0101fa60  00000000          ori.b    #$0, d0
0101fa64  00000000          ori.b    #$0, d0
0101fa68  00000000          ori.b    #$0, d0
0101fa6c  00000000          ori.b    #$0, d0
0101fa70  00000000          ori.b    #$0, d0
0101fa74  00000000          ori.b    #$0, d0
0101fa78  00000000          ori.b    #$0, d0
0101fa7c  00000000          ori.b    #$0, d0
0101fa80  00000000          ori.b    #$0, d0
0101fa84  00000000          ori.b    #$0, d0
0101fa88  00000000          ori.b    #$0, d0
0101fa8c  00000000          ori.b    #$0, d0
0101fa90  00000000          ori.b    #$0, d0
0101fa94  00000000          ori.b    #$0, d0
0101fa98  00000000          ori.b    #$0, d0
0101fa9c  00000000          ori.b    #$0, d0
0101faa0  00000000          ori.b    #$0, d0
0101faa4  00000000          ori.b    #$0, d0
0101faa8  00000000          ori.b    #$0, d0
0101faac  00000000          ori.b    #$0, d0
0101fab0  00000000          ori.b    #$0, d0
0101fab4  00000000          ori.b    #$0, d0
0101fab8  00000000          ori.b    #$0, d0
0101fabc  00000000          ori.b    #$0, d0
0101fac0  00000000          ori.b    #$0, d0
0101fac4  00000000          ori.b    #$0, d0
0101fac8  00000000          ori.b    #$0, d0
0101facc  00000000          ori.b    #$0, d0
0101fad0  00000000          ori.b    #$0, d0
0101fad4  00000000          ori.b    #$0, d0
0101fad8  00000000          ori.b    #$0, d0
0101fadc  00000000          ori.b    #$0, d0
0101fae0  00000000          ori.b    #$0, d0
0101fae4  00000000          ori.b    #$0, d0
0101fae8  00000000          ori.b    #$0, d0
0101faec  00000000          ori.b    #$0, d0
0101faf0  00000000          ori.b    #$0, d0
0101faf4  00000000          ori.b    #$0, d0
0101faf8  00000000          ori.b    #$0, d0
0101fafc  00000000          ori.b    #$0, d0
0101fb00  00000000          ori.b    #$0, d0
0101fb04  00000000          ori.b    #$0, d0
0101fb08  00000000          ori.b    #$0, d0
0101fb0c  00000000          ori.b    #$0, d0
0101fb10  00000000          ori.b    #$0, d0
0101fb14  00000000          ori.b    #$0, d0
0101fb18  00000000          ori.b    #$0, d0
0101fb1c  00000000          ori.b    #$0, d0
0101fb20  00000000          ori.b    #$0, d0
0101fb24  00000000          ori.b    #$0, d0
0101fb28  00000000          ori.b    #$0, d0
0101fb2c  00000000          ori.b    #$0, d0
0101fb30  00000000          ori.b    #$0, d0
0101fb34  00000000          ori.b    #$0, d0
0101fb38  00000000          ori.b    #$0, d0
0101fb3c  00000000          ori.b    #$0, d0
0101fb40  00000000          ori.b    #$0, d0
0101fb44  00000000          ori.b    #$0, d0
0101fb48  00000000          ori.b    #$0, d0
0101fb4c  00000000          ori.b    #$0, d0
0101fb50  00000000          ori.b    #$0, d0
0101fb54  00000000          ori.b    #$0, d0
0101fb58  00000000          ori.b    #$0, d0
0101fb5c  00000000          ori.b    #$0, d0
0101fb60  00000000          ori.b    #$0, d0
0101fb64  00000000          ori.b    #$0, d0
0101fb68  00000000          ori.b    #$0, d0
0101fb6c  00000000          ori.b    #$0, d0
0101fb70  00000000          ori.b    #$0, d0
0101fb74  00000000          ori.b    #$0, d0
0101fb78  00000000          ori.b    #$0, d0
0101fb7c  00000000          ori.b    #$0, d0
0101fb80  00000000          ori.b    #$0, d0
0101fb84  00000000          ori.b    #$0, d0
0101fb88  00000000          ori.b    #$0, d0
0101fb8c  00000000          ori.b    #$0, d0
0101fb90  00000000          ori.b    #$0, d0
0101fb94  00000000          ori.b    #$0, d0
0101fb98  00000000          ori.b    #$0, d0
0101fb9c  00000000          ori.b    #$0, d0
0101fba0  00000000          ori.b    #$0, d0
0101fba4  00000000          ori.b    #$0, d0
0101fba8  00000000          ori.b    #$0, d0
0101fbac  00000000          ori.b    #$0, d0
0101fbb0  00000000          ori.b    #$0, d0
0101fbb4  00000000          ori.b    #$0, d0
0101fbb8  00000000          ori.b    #$0, d0
0101fbbc  00000000          ori.b    #$0, d0
0101fbc0  00000000          ori.b    #$0, d0
0101fbc4  00000000          ori.b    #$0, d0
0101fbc8  00000000          ori.b    #$0, d0
0101fbcc  00000000          ori.b    #$0, d0
0101fbd0  00000000          ori.b    #$0, d0
0101fbd4  00000000          ori.b    #$0, d0
0101fbd8  00000000          ori.b    #$0, d0
0101fbdc  00000000          ori.b    #$0, d0
0101fbe0  00000000          ori.b    #$0, d0
0101fbe4  00000000          ori.b    #$0, d0
0101fbe8  00000000          ori.b    #$0, d0
0101fbec  00000000          ori.b    #$0, d0
0101fbf0  00000000          ori.b    #$0, d0
0101fbf4  00000000          ori.b    #$0, d0
0101fbf8  00000000          ori.b    #$0, d0
0101fbfc  00000000          ori.b    #$0, d0
0101fc00  00000000          ori.b    #$0, d0
0101fc04  00000000          ori.b    #$0, d0
0101fc08  00000000          ori.b    #$0, d0
0101fc0c  00000000          ori.b    #$0, d0
0101fc10  00000000          ori.b    #$0, d0
0101fc14  00000000          ori.b    #$0, d0
0101fc18  00000000          ori.b    #$0, d0
0101fc1c  00000000          ori.b    #$0, d0
0101fc20  00000000          ori.b    #$0, d0
0101fc24  00000000          ori.b    #$0, d0
0101fc28  00000000          ori.b    #$0, d0
0101fc2c  00000000          ori.b    #$0, d0
0101fc30  00000000          ori.b    #$0, d0
0101fc34  00000000          ori.b    #$0, d0
0101fc38  00000000          ori.b    #$0, d0
0101fc3c  00000000          ori.b    #$0, d0
0101fc40  00000000          ori.b    #$0, d0
0101fc44  00000000          ori.b    #$0, d0
0101fc48  00000000          ori.b    #$0, d0
0101fc4c  00000000          ori.b    #$0, d0
0101fc50  00000000          ori.b    #$0, d0
0101fc54  00000000          ori.b    #$0, d0
0101fc58  00000000          ori.b    #$0, d0
0101fc5c  00000000          ori.b    #$0, d0
0101fc60  00000000          ori.b    #$0, d0
0101fc64  00000000          ori.b    #$0, d0
0101fc68  00000000          ori.b    #$0, d0
0101fc6c  00000000          ori.b    #$0, d0
0101fc70  00000000          ori.b    #$0, d0
0101fc74  00000000          ori.b    #$0, d0
0101fc78  00000000          ori.b    #$0, d0
0101fc7c  00000000          ori.b    #$0, d0
0101fc80  00000000          ori.b    #$0, d0
0101fc84  00000000          ori.b    #$0, d0
0101fc88  00000000          ori.b    #$0, d0
0101fc8c  00000000          ori.b    #$0, d0
0101fc90  00000000          ori.b    #$0, d0
0101fc94  00000000          ori.b    #$0, d0
0101fc98  00000000          ori.b    #$0, d0
0101fc9c  00000000          ori.b    #$0, d0
0101fca0  00000000          ori.b    #$0, d0
0101fca4  00000000          ori.b    #$0, d0
0101fca8  00000000          ori.b    #$0, d0
0101fcac  00000000          ori.b    #$0, d0
0101fcb0  00000000          ori.b    #$0, d0
0101fcb4  00000000          ori.b    #$0, d0
0101fcb8  00000000          ori.b    #$0, d0
0101fcbc  00000000          ori.b    #$0, d0
0101fcc0  00000000          ori.b    #$0, d0
0101fcc4  00000000          ori.b    #$0, d0
0101fcc8  00000000          ori.b    #$0, d0
0101fccc  00000000          ori.b    #$0, d0
0101fcd0  00000000          ori.b    #$0, d0
0101fcd4  00000000          ori.b    #$0, d0
0101fcd8  00000000          ori.b    #$0, d0
0101fcdc  00000000          ori.b    #$0, d0
0101fce0  00000000          ori.b    #$0, d0
0101fce4  00000000          ori.b    #$0, d0
0101fce8  00000000          ori.b    #$0, d0
0101fcec  00000000          ori.b    #$0, d0
0101fcf0  00000000          ori.b    #$0, d0
0101fcf4  00000000          ori.b    #$0, d0
0101fcf8  00000000          ori.b    #$0, d0
0101fcfc  00000000          ori.b    #$0, d0
0101fd00  00000000          ori.b    #$0, d0
0101fd04  00000000          ori.b    #$0, d0
0101fd08  00000000          ori.b    #$0, d0
0101fd0c  00000000          ori.b    #$0, d0
0101fd10  00000000          ori.b    #$0, d0
0101fd14  00000000          ori.b    #$0, d0
0101fd18  00000000          ori.b    #$0, d0
0101fd1c  00000000          ori.b    #$0, d0
0101fd20  00000000          ori.b    #$0, d0
0101fd24  00000000          ori.b    #$0, d0
0101fd28  00000000          ori.b    #$0, d0
0101fd2c  00000000          ori.b    #$0, d0
0101fd30  00000000          ori.b    #$0, d0
0101fd34  00000000          ori.b    #$0, d0
0101fd38  00000000          ori.b    #$0, d0
0101fd3c  00000000          ori.b    #$0, d0
0101fd40  00000000          ori.b    #$0, d0
0101fd44  00000000          ori.b    #$0, d0
0101fd48  00000000          ori.b    #$0, d0
0101fd4c  00000000          ori.b    #$0, d0
0101fd50  00000000          ori.b    #$0, d0
0101fd54  00000000          ori.b    #$0, d0
0101fd58  00000000          ori.b    #$0, d0
0101fd5c  00000000          ori.b    #$0, d0
0101fd60  00000000          ori.b    #$0, d0
0101fd64  00000000          ori.b    #$0, d0
0101fd68  00000000          ori.b    #$0, d0
0101fd6c  00000000          ori.b    #$0, d0
0101fd70  00000000          ori.b    #$0, d0
0101fd74  00000000          ori.b    #$0, d0
0101fd78  00000000          ori.b    #$0, d0
0101fd7c  00000000          ori.b    #$0, d0
0101fd80  00000000          ori.b    #$0, d0
0101fd84  00000000          ori.b    #$0, d0
0101fd88  00000000          ori.b    #$0, d0
0101fd8c  00000000          ori.b    #$0, d0
0101fd90  00000000          ori.b    #$0, d0
0101fd94  00000000          ori.b    #$0, d0
0101fd98  00000000          ori.b    #$0, d0
0101fd9c  00000000          ori.b    #$0, d0
0101fda0  00000000          ori.b    #$0, d0
0101fda4  00000000          ori.b    #$0, d0
0101fda8  00000000          ori.b    #$0, d0
0101fdac  00000000          ori.b    #$0, d0
0101fdb0  00000000          ori.b    #$0, d0
0101fdb4  00000000          ori.b    #$0, d0
0101fdb8  00000000          ori.b    #$0, d0
0101fdbc  00000000          ori.b    #$0, d0
0101fdc0  00000000          ori.b    #$0, d0
0101fdc4  00000000          ori.b    #$0, d0
0101fdc8  00000000          ori.b    #$0, d0
0101fdcc  00000000          ori.b    #$0, d0
0101fdd0  00000000          ori.b    #$0, d0
0101fdd4  00000000          ori.b    #$0, d0
0101fdd8  00000000          ori.b    #$0, d0
0101fddc  00000000          ori.b    #$0, d0
0101fde0  00000000          ori.b    #$0, d0
0101fde4  00000000          ori.b    #$0, d0
0101fde8  00000000          ori.b    #$0, d0
0101fdec  00000000          ori.b    #$0, d0
0101fdf0  00000000          ori.b    #$0, d0
0101fdf4  00000000          ori.b    #$0, d0
0101fdf8  00000000          ori.b    #$0, d0
0101fdfc  00000000          ori.b    #$0, d0
0101fe00  00000000          ori.b    #$0, d0
0101fe04  00000000          ori.b    #$0, d0
0101fe08  00000000          ori.b    #$0, d0
0101fe0c  00000000          ori.b    #$0, d0
0101fe10  00000000          ori.b    #$0, d0
0101fe14  00000000          ori.b    #$0, d0
0101fe18  00000000          ori.b    #$0, d0
0101fe1c  00000000          ori.b    #$0, d0
0101fe20  00000000          ori.b    #$0, d0
0101fe24  00000000          ori.b    #$0, d0
0101fe28  00000000          ori.b    #$0, d0
0101fe2c  00000000          ori.b    #$0, d0
0101fe30  00000000          ori.b    #$0, d0
0101fe34  00000000          ori.b    #$0, d0
0101fe38  00000000          ori.b    #$0, d0
0101fe3c  00000000          ori.b    #$0, d0
0101fe40  00000000          ori.b    #$0, d0
0101fe44  00000000          ori.b    #$0, d0
0101fe48  00000000          ori.b    #$0, d0
0101fe4c  00000000          ori.b    #$0, d0
0101fe50  00000000          ori.b    #$0, d0
0101fe54  00000000          ori.b    #$0, d0
0101fe58  00000000          ori.b    #$0, d0
0101fe5c  00000000          ori.b    #$0, d0
0101fe60  00000000          ori.b    #$0, d0
0101fe64  00000000          ori.b    #$0, d0
0101fe68  00000000          ori.b    #$0, d0
0101fe6c  00000000          ori.b    #$0, d0
0101fe70  00000000          ori.b    #$0, d0
0101fe74  00000000          ori.b    #$0, d0
0101fe78  00000000          ori.b    #$0, d0
0101fe7c  00000000          ori.b    #$0, d0
0101fe80  00000000          ori.b    #$0, d0
0101fe84  00000000          ori.b    #$0, d0
0101fe88  00000000          ori.b    #$0, d0
0101fe8c  00000000          ori.b    #$0, d0
0101fe90  00000000          ori.b    #$0, d0
0101fe94  00000000          ori.b    #$0, d0
0101fe98  00000000          ori.b    #$0, d0
0101fe9c  00000000          ori.b    #$0, d0
0101fea0  00000000          ori.b    #$0, d0
0101fea4  00000000          ori.b    #$0, d0
0101fea8  00000000          ori.b    #$0, d0
0101feac  00000000          ori.b    #$0, d0
0101feb0  00000000          ori.b    #$0, d0
0101feb4  00000000          ori.b    #$0, d0
0101feb8  00000000          ori.b    #$0, d0
0101febc  00000000          ori.b    #$0, d0
0101fec0  00000000          ori.b    #$0, d0
0101fec4  00000000          ori.b    #$0, d0
0101fec8  00000000          ori.b    #$0, d0
0101fecc  00000000          ori.b    #$0, d0
0101fed0  00000000          ori.b    #$0, d0
0101fed4  00000000          ori.b    #$0, d0
0101fed8  00000000          ori.b    #$0, d0
0101fedc  00000000          ori.b    #$0, d0
0101fee0  00000000          ori.b    #$0, d0
0101fee4  00000000          ori.b    #$0, d0
0101fee8  00000000          ori.b    #$0, d0
0101feec  00000000          ori.b    #$0, d0
0101fef0  00000000          ori.b    #$0, d0
0101fef4  00000000          ori.b    #$0, d0
0101fef8  00000000          ori.b    #$0, d0
0101fefc  00000000          ori.b    #$0, d0
0101ff00  00000000          ori.b    #$0, d0
0101ff04  00000000          ori.b    #$0, d0
0101ff08  00000000          ori.b    #$0, d0
0101ff0c  00000000          ori.b    #$0, d0
0101ff10  00000000          ori.b    #$0, d0
0101ff14  00000000          ori.b    #$0, d0
0101ff18  00000000          ori.b    #$0, d0
0101ff1c  00000000          ori.b    #$0, d0
0101ff20  00000000          ori.b    #$0, d0
0101ff24  00000000          ori.b    #$0, d0
0101ff28  00000000          ori.b    #$0, d0
0101ff2c  00000000          ori.b    #$0, d0
0101ff30  00000000          ori.b    #$0, d0
0101ff34  00000000          ori.b    #$0, d0
0101ff38  00000000          ori.b    #$0, d0
0101ff3c  00000000          ori.b    #$0, d0
0101ff40  00000000          ori.b    #$0, d0
0101ff44  00000000          ori.b    #$0, d0
0101ff48  00000000          ori.b    #$0, d0
0101ff4c  00000000          ori.b    #$0, d0
0101ff50  00000000          ori.b    #$0, d0
0101ff54  00000000          ori.b    #$0, d0
0101ff58  00000000          ori.b    #$0, d0
0101ff5c  00000000          ori.b    #$0, d0
0101ff60  00000000          ori.b    #$0, d0
0101ff64  00000000          ori.b    #$0, d0
0101ff68  00000000          ori.b    #$0, d0
0101ff6c  00000000          ori.b    #$0, d0
0101ff70  00000000          ori.b    #$0, d0
0101ff74  00000000          ori.b    #$0, d0
0101ff78  00000000          ori.b    #$0, d0
0101ff7c  00000000          ori.b    #$0, d0
0101ff80  00000000          ori.b    #$0, d0
0101ff84  00000000          ori.b    #$0, d0
0101ff88  00000000          ori.b    #$0, d0
0101ff8c  00000000          ori.b    #$0, d0
0101ff90  00000000          ori.b    #$0, d0
0101ff94  00000000          ori.b    #$0, d0
0101ff98  00000000          ori.b    #$0, d0
0101ff9c  00000000          ori.b    #$0, d0
0101ffa0  00000000          ori.b    #$0, d0
0101ffa4  00000000          ori.b    #$0, d0
0101ffa8  00000000          ori.b    #$0, d0
0101ffac  00000000          ori.b    #$0, d0
0101ffb0  00000000          ori.b    #$0, d0
0101ffb4  00000000          ori.b    #$0, d0
0101ffb8  00000000          ori.b    #$0, d0
0101ffbc  00000000          ori.b    #$0, d0
0101ffc0  00000000          ori.b    #$0, d0
0101ffc4  00000000          ori.b    #$0, d0
0101ffc8  00000000          ori.b    #$0, d0
0101ffcc  00000000          ori.b    #$0, d0
0101ffd0  00000000          ori.b    #$0, d0
0101ffd4  00000000          ori.b    #$0, d0
0101ffd8  00000000          ori.b    #$0, d0
0101ffdc  00000000          ori.b    #$0, d0
0101ffe0  00000000          ori.b    #$0, d0
0101ffe4  00000000          ori.b    #$0, d0
0101ffe8  00000000          ori.b    #$0, d0
0101ffec  00000000          ori.b    #$0, d0
0101fff0  00000000          ori.b    #$0, d0
0101fff4  00000000          ori.b    #$0, d0
0101fff8  00000000          ori.b    #$0, d0
0101fffc  00000000          ori.b    #$0, d0
