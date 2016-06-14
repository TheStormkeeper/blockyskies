	include "includes.i"

	xdef	PlayNextSound
	xdef	ResetSound	
	xdef	fadeMusic
	
ResetSound:
	if SFX=1
	move.l	#0,blackoutFrame
	endif
	rts
	
PlayNextSound:
	cmp.w	#0,fadeMusic
	beq	.dontFadeOutMusic
	move.w	fadeMusic,d0
	add.w	d0,P61_Master
	cmp.w	#0,P61_Master
	beq	.fadeComplete
	cmp.w	#64,P61_Master
	beq	.fadeComplete	
	bra	.dontFadeOutMusic
.fadeComplete:
	move.w	#0,fadeMusic
.dontFadeOutMusic:
	
	
	if SFX=1	
	move.w  #2,AUD3LEN(a6) ; set the empty sound for the next sample to be played	
	move.l	#emptySound,AUD3LCH(a6)
	endif
	rts	

	if SFX=1
	xdef	PlayMenuSound
	xdef	PlayJumpSound
	xdef	PlayFallingSound
	xdef    PlayChachingSound
	xdef    PlayWhooshSound
	xdef    PlayYaySound
	xdef	PlayBonusSound
	
PlayJumpSound:
	move.l	d0,-(sp)
	move.l	blackoutFrame,d0
	cmp.l	frameCount,d0
	bgt	.skip	
	move.w	#0,dontKillSound	
	lea     jump(pc),a1
	KillSound
        move.l  a1,AUD3LCH(a6)
        move.w  #123,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6)
	move.w  #(endJump-jump)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
.skip:
	move.l	(sp)+,d0
	rts


PlayMenuSound:
	move.l	d0,-(sp)
	KillSound
	move.w	#0,dontKillSound
	lea     jump(pc),a1
        move.l  a1,AUD3LCH(a6)
        move.w  #123,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6)
	move.w  #(endJump-jump)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
	move.l	(sp)+,d0
	rts


PlayWhooshSound:
	move.l	d0,-(sp)
	move.l	blackoutFrame,d0
	cmp.l	frameCount,d0
	bgt	.skip	
	BlackoutSound 15
	KillSound
	move.w	#0,dontKillSound	
	lea     whoosh,a1
        move.l  a1,AUD3LCH(a6)
        move.w  #256,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6)
	move.w  #(endWhoosh-whoosh)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
.skip:
	move.l	(sp)+,d0	
	rts	


PlayFallingSound:
	KillSound
	move.w	#1,dontKillSound	
	lea     falling(pc),a1
        move.l  a1,AUD3LCH(a6)
        move.w  #256,AUD3PER(a6)
        move.w  #25,AUD3VOL(a6) 
	move.w  #(endFalling-falling)/4,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
	rts

PlayChachingSound:
	move.l	d0,-(sp)
	move.l	blackoutFrame,d0
	cmp.l	frameCount,d0
	bgt	.skip
	KillSound
	BlackoutSound 25
	move.w	#0,dontKillSound
	lea     chaching,a1
        move.l  a1,AUD3LCH(a6)
        move.w  #256,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6) 
	move.w  #(endChaching-chaching)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
.skip:
	move.l	(sp)+,d0
	rts

PlayYaySound:
	KillSound
	BlackoutSound 49
	move.w	#1,dontKillSound
	lea     yay,a1
        move.l  a1,AUD3LCH(a6)
        move.w  #423,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6) 
	move.w  #(endYay-yay)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
	rts

PlayBonusSound:
	KillSound
	BlackoutSound 41
	move.w	#0,dontKillSound
	lea     yay,a1
        move.l  a1,AUD3LCH(a6)
        move.w  #423,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6) 
	move.w  #(endYay-yay)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
	rts


	align	4
jump:
	incbin	"out/jump.raw"
endJump:	
	align	4
falling:
	incbin	"out/falling.raw"
endFalling:
	align 4
chaching:
	incbin	"out/chaching.raw"
endChaching:
	align 4
whoosh:
	incbin	"out/whoosh.raw"
endWhoosh:
	align 4
yay:
	incbin	"out/yay.raw"
endYay:

	align	2
blackoutFrame:
	dc.l	0
emptySound:
	dc.l	0
dontKillSound:
	dc.w	0
	endif

fadeMusic: 			; 0 - no fade, 1 - fade out 2, fade in
	dc.w	0
