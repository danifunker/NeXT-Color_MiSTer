; NeXT-Color directed CPU test: an instruction in the last word of a page.
; Assembled with vasmm68k_mot -Fbin -m68040; run by run_pageend.sh on the
; AP68040 tree's own program bench (rtl/ap68040/tb/tb_ap040_program.v).
;
; Why (docs/OPEN-QUESTIONS.md 39): under NeXTSTEP 3.3 every `cc` spins at a
; `jsr (a3)` at $5FFE -- the last word of a page -- taking ~4,000 translation
; faults a second with no page-ins: the kernel repairs a fault and the CPU
; takes it again.  Each case below puts the same instruction at the end of a
; page and checks every access error against a real 68040:
;   1  super: jsr (a3) at $5FFE, target valid, NEXT page ($6000) invalid.  The
;      jsr completes and the target runs; the only fault is the fetch at $6000
;      after the rts (FA $6000, TM super code).
;   2  super: next page valid, TARGET page ($7000) invalid: one fetch fault at
;      the target (FA $7000).
;   3  user: case 1 from user mode (TM user code).
;   4  user: the push of the return address faults (USP page $C000 invalid):
;      one data write fault at USP-4, then the jsr restarts once.
;   5-8: cases 1-4 with the caches on (CACR $80008000) and copyback pages,
;      as NeXTSTEP runs.
; The access error handler maps whatever page the fault address names (like
; a pager) and counts; more than 8 faults in one case is the loop: fail
; 90 + case.  Every fault prints "STAMP tag=" lines: $FA00 + case, then the
; fault address high/low, the SSW and the stacked PC low word.
;
; Memory: $0000 vectors, $0400 code, $3400 ISP top, $3C00 USP top (page 3),
; $4000 root, $4200 pointer table, $4400 page table (64 x 4K pages),
; $5FFE the jsr, $6000 `jmp (a4)`, $7000 the target, $C000 a user stack page.

FAILREG		equ	$F100
DONEREG		equ	$F102
STAMP		equ	$F108

cnt_aerr	equ	$3600
cnt_tgt		equ	$3602
last_fa		equ	$3604
last_ssw	equ	$3608
last_pc		equ	$360C
curcase		equ	$3610
pte_attr	equ	$3614
uret		equ	$3618

PT		equ	$4400		; page table: entry i at PT + 4*i

failt	macro
	move.w	#\1,d7
	bra	fail_all
	endm

chkl	macro
	cmp.l	#\2,\1
	beq.s	ok\@
	failt	\3
ok\@:
	endm

chkw	macro
	move.w	\1,d0
	and.l	#$FFFF,d0
	cmp.l	#\2,d0
	beq.s	okw\@
	failt	\3
okw\@:
	endm

	org	0
	dc.l	$3400
	dc.l	start
	dc.l	h_aerr		; 2 access error
	rept	30
	dc.l	unexp		; 3-32
	endr
	dc.l	h_utrap		; 33 TRAP #1
	rept	222
	dc.l	unexp		; 34-255
	endr

	org	$400
start:
;----------------------------------------------------------------- tables
	lea	(PT).l,a0
	moveq	#0,d0
	moveq	#63,d1
tloop:
	move.l	d0,d2
	lsl.l	#8,d2
	lsl.l	#4,d2		; i << 12
	addq.l	#3,d2		; resident, cacheable write-through
	move.l	d2,(a0)+
	addq.l	#1,d0
	dbra	d1,tloop
	move.l	#$00004203,($4000).l	; root entry 0 -> pointer table
	move.l	#$00004403,($4200).l	; pointer entry 0 -> page table
	move.l	#$4043,(PT+4*4).l	; the table page itself: cache-inhibited

	move.l	#$4000,d0
	movec	d0,urp
	movec	d0,srp
	move.l	#$8000,d0		; E=1, 4K pages
	movec	d0,tc
	pflusha

	move.l	#3,(pte_attr).l
	moveq	#0,d6			; case offset: 0 caches off, 4 caches on

phase:
;------------------------------------------ 1: super, next page invalid
	move.w	d6,d0
	addq.w	#1,d0
	move.w	d0,(curcase).l
	bsr	reset_pages
	move.l	#0,(PT+4*6).l		; $6000 invalid
	pflusha
	lea	($7000).l,a3
	lea	back1(pc),a4
	jmp	($5FFE).l
back1:
	chkw	(cnt_tgt).l,1,11
	chkw	(cnt_aerr).l,1,12
	move.l	(last_fa).l,d0
	chkl	d0,$6000,13
	move.w	(last_ssw).l,d0
	and.l	#7,d0
	chkl	d0,6,14			; TM: supervisor code

;------------------------------------------ 2: super, target page invalid
	move.w	d6,d0
	addq.w	#2,d0
	move.w	d0,(curcase).l
	bsr	reset_pages
	move.l	#0,(PT+4*7).l		; $7000 invalid
	pflusha
	lea	($7000).l,a3
	lea	back2(pc),a4
	jmp	($5FFE).l
back2:
	chkw	(cnt_tgt).l,1,21
	chkw	(cnt_aerr).l,1,22
	move.l	(last_fa).l,d0
	chkl	d0,$7000,23

;------------------------------------------ 3: user, next page invalid
	move.w	d6,d0
	addq.w	#3,d0
	move.w	d0,(curcase).l
	bsr	reset_pages
	move.l	#0,(PT+4*6).l		; $6000 invalid
	pflusha
	movea.l	#$3C00,a0
	movec	a0,usp
	move.l	#back3,(uret).l
	lea	($7000).l,a3
	lea	u_trap(pc),a4
	move.w	#$0000,-(sp)		; format 0 frame into user mode at $5FFE
	move.l	#$5FFE,-(sp)
	move.w	#$0000,-(sp)
	rte
back3:
	chkw	(cnt_tgt).l,1,31
	chkw	(cnt_aerr).l,1,32
	move.l	(last_fa).l,d0
	chkl	d0,$6000,33
	move.w	(last_ssw).l,d0
	and.l	#7,d0
	chkl	d0,2,34			; TM: user code

;------------------------------------------ 4: user, the push faults
	move.w	d6,d0
	addq.w	#4,d0
	move.w	d0,(curcase).l
	bsr	reset_pages
	move.l	#0,(PT+4*12).l		; $C000 (the user stack page) invalid
	pflusha
	movea.l	#$C800,a0
	movec	a0,usp
	move.l	#back4,(uret).l
	lea	($7000).l,a3
	lea	u_trap(pc),a4
	move.w	#$0000,-(sp)
	move.l	#$5FFE,-(sp)
	move.w	#$0000,-(sp)
	rte
back4:
	chkw	(cnt_tgt).l,1,41
	chkw	(cnt_aerr).l,1,42
	move.l	(last_fa).l,d0
	chkl	d0,$C7FC,43
	move.w	(last_ssw).l,d0
	and.l	#7,d0
	chkl	d0,1,44			; TM: user data

;------------------------------------------ again with the caches on
	tst.w	d6
	bne.s	all_done
	moveq	#4,d6
	move.l	#$23,(pte_attr).l	; copyback pages from now on
	cpusha	bc
	move.l	#$80008000,d0
	movec	d0,cacr
	bra	phase

all_done:
	move.w	#$600D,(DONEREG).l
halt0:
	bra.s	halt0

; every test page back to present with the phase's cache mode; counters 0
reset_pages:
	clr.w	(cnt_aerr).l
	clr.w	(cnt_tgt).l
	clr.l	(last_fa).l
	moveq	#5,d0
rp_loop:
	move.l	d0,d1
	lsl.l	#8,d1
	lsl.l	#4,d1
	or.l	(pte_attr).l,d1
	lea	(PT).l,a0
	move.l	d0,d2
	lsl.l	#2,d2
	move.l	d1,(a0,d2.l)
	addq.l	#1,d0
	cmp.l	#13,d0
	bne.s	rp_loop
	cpusha	dc
	pflusha
	rts

u_trap:
	trap	#1

;----------------------------------------------------------------- handlers
; access error: log the fault, map the page the FA names, restart
h_aerr:
	cmpi.w	#$7008,6(sp)		; format $7, vector 2
	bne	hfail
	movem.l	d0-d2/a0,-(sp)		; frame fields at +16 from here
	addq.w	#1,(cnt_aerr).l
	move.l	$24(sp),(last_fa).l	; FA (frame $14)
	move.w	$1C(sp),(last_ssw).l	; SSW (frame $0C)
	move.l	$12(sp),(last_pc).l	; stacked PC (frame $02)
	move.w	(curcase).l,d0
	add.w	#$FA00,d0
	move.w	d0,(STAMP).l
	move.w	$24(sp),(STAMP).l	; FA high
	move.w	$26(sp),(STAMP).l	; FA low
	move.w	$1C(sp),(STAMP).l	; SSW
	move.w	$14(sp),(STAMP).l	; PC low
	cmpi.w	#8,(cnt_aerr).l
	bls.s	ha_fix
	move.w	(curcase).l,d7		; the loop: fail 90 + case
	add.w	#90,d7
	bra	fail_all
ha_fix:
	move.l	$24(sp),d0
	lsr.l	#8,d0
	lsr.l	#4,d0			; page index
	cmp.l	#64,d0
	bhs	hfail
	move.l	d0,d1
	lsl.l	#8,d1
	lsl.l	#4,d1
	or.l	(pte_attr).l,d1
	lea	(PT).l,a0
	lsl.l	#2,d0
	move.l	d1,(a0,d0.l)
	cpusha	dc
	pflusha
	movem.l	(sp)+,d0-d2/a0
	rte

h_utrap:
	ori.w	#$2000,(sp)		; back to supervisor
	move.l	(uret).l,2(sp)
	rte

hfail:
	failt	98

fail_all:
	move.w	d7,(FAILREG).l
	move.w	#$BAD0,(DONEREG).l
halt1:
	bra.s	halt1

unexp:
	move.w	#$0099,(FAILREG).l
	move.w	#$BAD0,(DONEREG).l
halt2:
	bra.s	halt2

;------------------------------------------------------ the page-end code
	org	$5FFE
	jsr	(a3)			; the last word of page 5

	org	$6000
	jmp	(a4)			; after the target's rts

	org	$7000
	addq.w	#1,(cnt_tgt).l
	rts
