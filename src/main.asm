
    device  ZXSPECTRUM48

    include "./constants.asm"

Stack_Top:              EQU 0x0000                              ; Stack at top of RAM
IM2_Table:              EQU 0xFE00                              ; 256 byte page (+ 1 byte) for IM2
IM2_JP:                 EQU 0xFDFD                              ; 3 bytes for JP routine under IM2 table
 
    
    org $8000
init:

  CALL InitIM2

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
    LD (HL), %01000111            ; Bright white on black background
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



    call VSync

    

      ; Clear Border
    LD A, 0x00              ; Load 0 into A (black color)
    OUT (0xFE), A           ; Set border to black


    ; Pause until 3rd part of screen
    LD BC, 550        
PauseLoop:
    DEC BC
    LD A, B
    OR C
    JR NZ, PauseLoop

    CALL ClearPlayScreen  ; Top 2 thirds of screen, 28 columns, 16 rows

    ; Change border to red
    LD A, 0x02             ; Load 2 into A (red color)
    OUT (0xFE), A          ; Set border to red

    call DRAW_BUFFER

    ; Change border to black
    LD A, 0x00              ; Load 0 into A (black color)
    OUT (0xFE), A           ; Set border to black
   

    jr main
;
DOWN_HL:        inc h : ld a,h : and 7 : ret nz
                ld a,l : add a,32 : ld l,a
                ret c
                ld a,h : sub 8 : ld h,a : ret

ClearPlayScreen:
	LD   (SP_Store),SP
	LD   DE,$0000      ; Blank character
	LD   HL,$401E			; start screen address of play area to clear
	LD   C,$10            ; 16 rows
.NextRow:
	LD   B,$08    ; 8 Rows at a time

.ClearRow:       ; Clear a row of 28 characters allow 2 either side for border
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
	DJNZ .ClearRow

	LD   A,L
	ADD  A,$20
	LD   L,A
	JR   C,.inThird

	LD   A,H        ; Move to next third of screen
	SUB  $08        
	LD   H,A

.inThird:
	DEC  C
	JR   NZ,.NextRow

	LD   SP,(SP_Store)
	RET 

; hl = gfx address
; de = screen address
; b = height
BLIT_SPRITE_16_64

  ld b,64

  ld (.savedsp),sp
  ld sp,hl
  ex de,hl
  ld a,h
  and $F8
  ld c,a
  jr .mainloop

.nextthird:
  ld c,h
  djnz .mainloop

  jr .theend

.nextchar:
  ld a,l
  add 32
  ld l,a
  jr c,.nextthird

  ld h,c
  dec b
  jr z,.theend

.mainloop:
  ld a,l

  DUP 8
  pop de
  ld (hl),e
  inc l
  ld (hl),d
  inc l
  EDUP

  org $-1   ;Remove last inc l

  ld l,a
  
  inc h
  ld a,h
  and 7

  jr z,.nextchar

  djnz .mainloop

.theend:
  ld sp,0
.savedsp equ $-2
  ret



SP_Store: defw 0

VSync:
        ; Important, reset the R register
    xor a
    ld r,a
.lp1
    ld a,r
    ret m
    jr .lp1


InitIM2:

  DI
  LD DE, IM2_Table                        ; The IM2 vector table (on page boundary)
  LD HL, IM2_JP                           ; Pointer for 3-byte interrupt handler
  LD A, D                                 ; Interrupt table page high address
  LD I, A                                 ; Set the interrupt register to that page
  LD A, L                                 ; Fill page with values
.lp1                     
  LD (DE), A 
  INC E
  JR NZ,.lp1

  INC D                                   ; In case data bus bit 0 is not 0, we
  LD (DE), A                              ; put an extra byte in here
  LD (HL), 0xC3                           ; Write out the interrupt handler, a JP instruction
  INC L
  LD (HL), low Interrupt                  ; Store the address of the interrupt routine in
  INC L
  LD (HL), high Interrupt
  IM 2                                    ; Set the interrupt mode
  EI                                      ; Enable interrupts
  RET


Interrupt:
	  EI  
    PUSH AF
    LD   A,$FF
    LD   R,A
    POP  AF
    RETI


DRAW_BUFFER:
    LD hl, BBLOGO
    LD de, $4088
    call BLIT_SPRITE_16_64
    ret


BBLOGO:

    include "./assets/bblogo.asm"

	org $fd00
data_FD00:
  DEFS 0x101,0xFF
    
    savesna "./src/main.sna",init
    savetap "./src/main.tap",init