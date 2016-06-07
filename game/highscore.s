	include "includes.i"

	xdef AddHighScore
	xdef ShowHighScore
	
SPLASH_COLOR_DEPTH		equ 5
SPLASH_SCREEN_WIDTH_BYTES	equ 40

PLAY_COPPER_WORD		equ $aad1

MENU_TITLE_TOP_COLOR		equ $7ef
MENU_TITLE_BOTTOM_COLOR		equ $5cd	
MENU_SELECTED_TOP_COLOR		equ $4d2
MENU_SELECTED_BOTTOM_COLOR	equ $3e1
MENU_TEXT_COLOR			equ $7ef
MENU_TEXT_BOTTOM_COLOR		equ $5cd
MENU_FIRE_TOP_COLOR		equ $be0 ;$e71
MENU_FIRE_BOTTOM_COLOR		equ $9d4 ;$fe7		

MENU_BOTTOM_OFFSET		equ (firstBottomColor-firstTopColor)
MENU_OFFSET			equ (secondTopColor-firstTopColor)
	
ShowHighScore:
	lea 	CUSTOM,a6
	jsr	ReloadSplashScreen	
	bsr	HighlightScore
	
	jsr	WaitVerticalBlank	
	;; set up default palette
	include "out/menu-palette.s"
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SPLASH_COLOR_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#0,BPLCON1(a6)	
	move.w	#SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES,BPL2MOD(a6)

	;; poke bitplane pointers
	lea	splash,a1
	lea     splashCopperListBplPtr(pc),a2
	moveq	#SPLASH_COLOR_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	SPLASH_SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop

	;; install copper list, then enable dma
	lea	splashCopperList(pc),a0
	move.l	a0,COP1LC(a6)
	
	;; 	jsr	WaitVerticalBlank			
	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)		
	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	

	bsr	RenderHighScore
	jsr	WaitForJoystick
	PlaySound Menu
	jmp	ShowMenu


RenderHighScore:
	lea	splash,a0	
	lea	pressFire,a1
	move.l	#(320/2)-(6*8),d0	
	move.w	#150-16,d1
	jsr	DrawMaskedText85	
	lea	splash,a0
	lea	highScore,a1
	move.w	#(320/2)-(6*8)+4,d0
	add.w	#16,d1
	jsr	DrawMaskedText85
	lea	highScores,a2
.loop:
	move.w	#9,d2
	move.l	(a2)+,d0
	jsr	ToAscii
	move.w	#(320/2)-(6*8)+12,d0	
	add.w	#16,d1
	move.l	a0,a1
	lea	splash,a0
	jsr	DrawMaskedText85
	cmp.l	#endHighScores,a2
	bne	.loop

	RenderVersion
	
	rts

AddHighScore:
	move.l	#endHighScores-4,a0
.loop1:
	cmp.l	(a0),d0
	beq	.skip
	sub.l	#4,a0
	cmp.l	#highScores,a0
	blt	.next
	bra	.loop1
.next:
	move.l	#endHighScores-4,a0
.loop:
	cmp.l	(a0),d0
	blt	.done
	move.l	(a0),4(a0)
	sub.l	#4,a0
	cmp.l	#highScores,a0
	blt	.done
	bra	.loop
	
.done:
	move.l	d0,4(a0)
.skip:
	rts

HighlightScore:
	lea	firstTopColor,a0
	lea	highScores,a1
	move.l	__score,d0
.loop:
	cmp.l	#endHighScores,a1
	beq	.done
	cmp.l	(a1),d0
	beq	.match
	move.w 	#MENU_TEXT_COLOR,(a0)
	move.w	#MENU_TEXT_BOTTOM_COLOR,MENU_BOTTOM_OFFSET(a0)
	bra	.notMatch
.match:
	move.w  #MENU_SELECTED_TOP_COLOR,(a0)
	move.w  #MENU_SELECTED_BOTTOM_COLOR,MENU_BOTTOM_OFFSET(a0)
.notMatch:
	add.l	#MENU_OFFSET,a0	
	add.l	#4,a1	
	bra	.loop	
.done:
	rts

highScore:
	dc.b	" HI SCORES  "
	dc.b	0

pressFire:
	dc.b	" PRESS FIRE "
	dc.b	0	

	align 4
highScores:
	dc.l	10000
	dc.l	5000
	dc.l	2000
	dc.l	1000
	dc.l	500
endHighScores:
	dc.l	0 		; saves an extra check when propagating scores down


splashCopperList:
splashCopperListBplPtr:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w	PLAY_COPPER_WORD,$fffe
	dc.w	COLOR31
	dc.w	MENU_FIRE_TOP_COLOR
	dc.w	PLAY_COPPER_WORD+(($1000/4)*3),$fffe
	dc.w	COLOR31
	dc.w	MENU_FIRE_BOTTOM_COLOR
	dc.w	PLAY_COPPER_WORD+$1000,$fffe

	dc.w	COLOR31
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$1000+(($1000/4)*3),$fffe	
	dc.w	COLOR31
	dc.w	MENU_TEXT_BOTTOM_COLOR

	dc.w	PLAY_COPPER_WORD+$2000,$fffe
	dc.w	COLOR31	
firstTopColor:
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$2000+(($1000/4)*3),$fffe
	dc.w	PLAY_COPPER_WORD+$2000+(($1000/4)*3),$fffe	
	dc.w	COLOR31
firstBottomColor:	
	dc.w	MENU_TEXT_BOTTOM_COLOR
	dc.w	PLAY_COPPER_WORD+$3000,$fffe
	dc.w	COLOR31
secondTopColor:	
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$3000+(($1000/4)*3),$fffe
	dc.w	PLAY_COPPER_WORD+$3000+(($1000/4)*3),$fffe	
	dc.w	COLOR31
secondBottomColor:
	dc.w	MENU_TEXT_BOTTOM_COLOR
	dc.w	PLAY_COPPER_WORD+$4000,$fffe
	dc.w	COLOR31
thirdTopColor:	
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$4000+(($1000/4)*3),$fffe
	dc.w	PLAY_COPPER_WORD+$4000+(($1000/4)*3),$fffe	
	dc.w	COLOR31
thirdBottomColor:
	dc.w	MENU_TEXT_BOTTOM_COLOR		
	dc.w	PLAY_COPPER_WORD+$5000,$fffe
	dc.w	COLOR31
fourthTopColor:	
	dc.w	MENU_TEXT_COLOR
	dc.w	$ffdf,$fffe
	dc.w	$06df,$fffe
	dc.w	COLOR31
fourthBottomColor:
	dc.w	MENU_TEXT_BOTTOM_COLOR
	dc.w	$9df,$fffe
	dc.w	COLOR31
fifthTopColor:	
	dc.w	MENU_TEXT_COLOR
	dc.w	$16df,$fffe
	dc.w	$16df,$fffe	
	dc.w	COLOR31
fifthBottoMColor:	
	dc.w	MENU_TEXT_BOTTOM_COLOR	

	dc.w	$22df,$fffe
	dc.w	COLOR31,$bbb
	dc.w	$26df,$fffe
	dc.w	COLOR31,$999
	
	dc.l	$fffffffe
	
