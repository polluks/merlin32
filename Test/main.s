*
*  main.s
*  Merlin32 Test
*
*  Created by Lane Roathe on 8/26/19.
*  Copyright © 2019 Ideas From the Deep. All rights reserved.
*

]XCODESTART     ; Keep this at the start and put your code after this

*==========================================================
* monitor addresses


TEXT	=	$FB39		;Reset text window
TABV	=	$FB5B		;Complete vtab, using contents of 'A'
FIXVEC	=	$FB6F		;fix vector's powerup byte
MONBELL	=	$FBE4		;random bell noise!
HOME    =	$FC58		;Clear text window
WAIT	=	$FCA8		;delay routine
GETLN1	=	$FD6F		;input routine
CROUT	=	$FD8E		;Print a CR
PRBYTE	=	$FDDA		;Print 'A' as a hex number
PRHEX	=	$FDE3		;as above, but bits 0-3 only
COUT	=	$FDED		;Monitor char out
MOVE	=	$FE2C		;memory move routine
INVERSE	=	$FE80		;Print in inverse
NORMAL	=	$FE84		;Normal print

* Jump Vectors
CONNECT	=	$3EA		;Connect DOS
DOSWARM	=	$3D0		;exit to DOS prompt
RSTVEC	=	$3F2		;reset vector

TSTADDR	=	$1000		;absolute address for testing

*==========================================================
* Data Index DUM section test

		DUM	0
dum0	ds	1			;fractional byte
dum1	ds	1
qdSize	=	*
		DEND

*==========================================================
* zero page (all zp var names are prefixed with _)

		DUM	0

_ptr	ds	2
_tmp	ds	2

_num1	ds	qdSize		;first and second operand values

_menPtr	ds	2			;ptr to current menu's table
_curmen	ds	1			;current menu and item selected (item is 1..max-1)
_maxitm	ds	1			;max # of items in current menu
_curitm	ds	1
_prvitm	ds	1			;previous item selected (menus are 1 deep max, so this is always for the main menu)

; test ORG with DUM section

		ORG	$20

_LFT	ds	1			;Window edge   0..39
_WDTH	ds	1			;  ''   widht  1..40/80
_TOP	ds  1			;  ''   top    0..23
_BTM	ds  1			;  ''   bottom 1..24
_CH		ds  1			;Cursor htab
_CV		ds  1			;  ''   vtab

		DEND

*==========================================================
* Program Entry

		org $800

START

; PUT current issue here, so it's the first thing assembled. The rest below are unit tests to make sure future changes don't break existing code!

;make sure zp values after ORG have right values
        lda _LFT
        ldx #_LFT


; START OF TESTS KNOWN TO HAVE PASSED IN PREVIOUS BUILDS

;adc (ZP,x)
		adc (0,x)
        adc ($80,x)
        adc	(_tmp,x)
        adc	(_tmp+0,x)
        adc	(_tmp+$10,x)
        adc	($10+_tmp,x)
        adc	(_tmp+dum0,x)
        adc	(_tmp+dum1,x)
        adc	(_tmp+dum1+1,x)
        adc	(_tmp+dum0+dum1,x)

        adc 0
        adc $80
		adc _tmp
        adc #0
        adc #$1111
        adc $1111

        sta TSTADDR+dum0
        sta TSTADDR+_num1+dum0
        sta TSTADDR+_num1+dum0,x

        lda _num1+dum0
        adc _num1+dum1
        sbc _num1+dum1
        bit _num1+dum0
        sta _num1+dum0    ;(FIXED): can't use sta _num1+dum0
		stz _num1+dum0

		lda _num1+dum0,x
		adc _num1+dum0,x
		sbc _num1+dum0,x
		bit _num1+dum0,x
		sta _num1+dum0,x
		stz _num1+dum0,x

        lda _num1+dum0,y	;these assemble to abs accesses: lda $00C0,y
		adc _num1+dum0,y
		sbc _num1+dum0,y
		sta _num1+dum0,y

;Issue #16 (fadden)
        lda	<$fff0			;zp
        lda	>$fff0			;ABS (lo word)
        lda ^$fff0			;ABS (hi word)
        lda |$fff0			;ABS (long in 65816 mode)

        lda	#<$fff0			;byte
        lda	#>$fff0			;page
        lda #^$fff0			;bank

        lda	<$fff0+24       ;zp
        lda	>$fff0+24       ;ABS (lo word)
        lda ^$fff0+24		;ABS (hi word)
        lda |$fff0+24		;ABS (long in 65816 mode)

        lda	#<$fff0+24		;byte
        lda	#>$fff0+24		;page
        lda #^$fff0+24		;bank

        lda	#<$fff0+24		;byte
        lda	#>$fff0+24		;page
        lda #^$fff0+24		;bank

        lda	$0008           ;ZP
        lda	$08             ;ZP
        lda	$ffff-$fff7     ;ZP
        lda	$fff0+24        ;ABS (long in 65816 mode)

; Label & branching tests
GetKey	ldx  $C000
		bpl  GetKey

]loop
        dex
        bne ]loop

		tya
        and #1
        beq :err

        tya
        and #1
        bne	:good
:err
        lda #0
:good
		bne myQuit
		nop
        hex 2C		;bit
        lda #1
myQuit
		jmp DOSWARM

]XCODEEND       ; Keep this at the end and put your code above this
