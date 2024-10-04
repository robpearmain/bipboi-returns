
    device  ZXSPECTRUM48

    include "./constants.asm"
    
    org $8000
init:

  ;
; Print the string TEXT2 using my zero-terminated string print routine
;
  ;
; Change border to black
;

    ; Clear Border
    LD A, 0x00              ; Load 0 into A (black color)
    OUT (0xFE), A           ; Set border to black

    ; Clear Attribute Memory
    LD HL, $5800            ; Start of attribute memory
    LD DE, $5801            ; Next byte in attribute memory
    LD BC, 511           ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), 7            ; Bright white on black background
    LDIR                    ; Fill the attribute memory

  ; Clear Attribute Memory
    LD HL, $5800+512            ; Start of attribute memory
    LD DE, $5801+512            ; Next byte in attribute memory
    LD BC, 255           ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), %01101111            ; Bright white on black background
    LDIR    

    ; Clear screen memory
    LD HL, $4000            ; Start of screen memory
    LD DE, $4001            ; Next byte in screen memory
    LD BC, 6143         ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), 0x00            ; Load 0 into A (black color)
    LDIR                    ; Fill the screen memory

main:

    EI
    HALT
    DI

      ; Clear Border
    LD A, 0x00              ; Load 0 into A (black color)
    OUT (0xFE), A           ; Set border to black


    ; Pause until 3rd part of screen
    LD BC, 565           
PauseLoop:
    DEC BC
    LD A, B
    OR C
    JR NZ, PauseLoop

    CALL ClearScreen

    ; Change border to green
    LD A, 0x02             ; Load 2 into A (green color)
    OUT (0xFE), A          ; Set border to green

    LD DE, BBLOGO
    LD HL, 0x4088
    LD B, 10

LP1:
    PUSH BC

    LD B,16
LP2:
    LD A,(DE)
    LD (HL),A
    INC L
    INC DE
    DJNZ LP2

    DEC L
    INC H

    LD B,16

LP3:
    LD A,(DE)
    LD (HL),A
    INC DE
    DEC L

   

    DJNZ LP3

    INC L

    CALL DOWN_HL
   
  






    POP BC

    DJNZ LP1

    ; Change border to black
    LD A, 0x00              ; Load 0 into A (black color)
    OUT (0xFE), A           ; Set border to black
   

    jr main
;
DOWN_HL:        inc h : ld a,h : and 7 : ret nz
                ld a,l : add a,32 : ld l,a
                ret c
                ld a,h : sub 8 : ld h,a : ret

ClearScreen:
	LD   (SP_Store),SP
	LD   DE,$0101
	LD   HL,$401E			; start screen address of play area to clear
	LD   C,$10
NextRow:
	LD   B,$08

ClearCharacter:
	LD   SP,HL
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	PUSH DE
	INC  H
	DJNZ ClearCharacter

	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,InSegment

	LD   A,H
	SUB  $08
	LD   H,A

InSegment:
	DEC  C
	JR   NZ,NextRow

	LD   SP,(SP_Store)
	RET 

SP_Store: defw 0

BBLOGO:

    include "./assets/bblogo.asm"


    
    savesna "./src/main.sna",init
    savetap "./src/main.tap",init