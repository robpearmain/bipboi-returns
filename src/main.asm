
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
    LD (HL), BRIGHT+INK_WHITE+PAPER_BLACK            ; Bright white on black background
    LDIR                    ; Fill the attribute memory




  ; Clear Attribute Memory
    LD HL, $5800+512            ; Start of attribute memory
    LD DE, $5801+512            ; Next byte in attribute memory
    LD BC, 255           ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), BRIGHT+PAPER_YELLOW+INK_BLACK           ; Bright white on black background
    LDIR    

    LD HL,$5800
    LD DE,31
    LD B,24
.lp1:
    ld (hl),0
    add hl,de
    ld (hl),0
    inc hl
    djnz .lp1


    ; Clear screen memory
    LD HL, $4000            ; Start of screen memory
    LD DE, $4001            ; Next byte in screen memory
    LD BC, 6143         ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), 0x00            ; Load 0 into A (black color)
    LDIR                    ; Fill the screen memory

  ld hl, BBLOGO
    ld de, $5208
    call BLIT_SPRITE_16_64
    
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


    ; Draw the baddie

   
    ld a,(baddie_y_pos)
    ld d,a
    ld a,(baddie_x_pos)
    ld e,a
    call PixAddr

     ld de, block
    ex de,hl
    call BLIT_SPRITE_32_24


    call DRAW_BUFFER


    xor a

    ld a,(frame_pause)
    inc a
    and 7
    ld (frame_pause),a



    jr nz,.go

    ld a,(current_frame)
  
    inc a
    cp 6
    jr nz, .skip

    xor a

.skip:
    ld (current_frame),a

    ; Clear the Carry flag so it doesn't affect the next operation
    and 7
   
    ; multiply by 4
    rl a
    rl a


    ld hl, BBTABLE
    ld l,a

    ; Graphics address

    ld a,(hl)
    ld (DRAW_BUFFER+1),a
    inc l
    ld a,(hl)
    ld (DRAW_BUFFER+2),a
    inc l

    
    ld a,(player_x_pos)
    ld e,a

    ld a,(player_y_pos)
    add a,(hl)
    ld d,a

    call PixAddr

    ; HL now has screen position

   
 
   ld a,l
   ld (DRAW_BUFFER+4),a
   ld a,h
   ld (DRAW_BUFFER+5),a
    
  
.go

  ; ld a,(player_y_pos)
  ;   inc a
  ;   inc a
  ;   and 127
  ;   ld (player_y_pos),a
    
    ld a,(baddie_y_pos)
    dec a
    and 127
    ld (baddie_y_pos),a

    ld a,(baddie_x_pos)
    ;add a,-4
    ld (baddie_x_pos),a
    ; Change border to black
    LD A, 0x00              ; Load 0 into A (black color)
    OUT (0xFE), A           ; Set border to black
   

    jp main
;
DOWN_HL:        inc h : ld a,h : and 7 : ret nz
                ld a,l : add a,32 : ld l,a
                ret c
                ld a,h : sub 8 : ld h,a : ret

ClearPlayScreen:
	LD   (SP_Store),SP
	LD   DE,$0000      ; Blank character
	LD   HL,$401F			; start screen address of play area to clear
	LD   C,$10            ; 16 rows
.NextRow:
	LD   B,$08    ; 8 Rows at a time

.ClearRow:       ; Clear a row of 32 characters allow 2 either side for border
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

  ld b,62

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

; hl = gfx address
; de = screen address
; b = height

; only works if moving 2 rows up and down
BLIT_SPRITE_40_24

  ld b,12

  ld (.savedsp),sp
  ld sp,hl
  ex de,hl
  ld a,h
  and $F8
  ld c,a
  jr .mainloop

.nextthird:
  
  ; $40 is 01000000
  ; $48 is 01001000
  ; $50 is 01010000
  ld c,h
 
  djnz .mainloop

  jr .theend

.nextrow:
  ld a,l
  add 32
  ld l,a
  jr c,.nextthird

  ld h,c

  dec b
  jr z,.theend

.mainloop:
  ld a,l
  ex af,af

  ld a,h
  and %11001111   ; Remove if you dont want to restrict to top 2/3
  ld h,a    

  DUP 2
  pop de
  ld a,e
  or (hl)
  ld (hl),a
  inc l
  ld a,d
  or (hl)
  ld (hl),a
  inc l
  EDUP

  pop de

  ld a,e
  or (hl)
  ld (hl),a

  inc h   ; next row

  ld a,d
  or (hl)
  ld (hl),a
  dec l

  DUP 2
  pop de
  ld a,e
  or (hl)
  ld (hl),a
  dec l
  ld a,d
  or (hl)
  ld (hl),a
  dec l
  EDUP

  org $-1   ;Remove last dec l

  ex af,af
  ld l,a
  
  ; Restrict to top 2 thirds
  inc h
  ld a,h
       ; Remove if you dont want to restrict to top 2/3

  and 7

  jr z,.nextrow

  djnz .mainloop

.theend:
  ld sp,0
.savedsp equ $-2
  ret

; hl = gfx address
; de = screen address
; b = height

; only works if moving 2 rows up and down
BLIT_SPRITE_32_24

  ld b,24

  ld (.savedsp),sp
  ld sp,hl
  ex de,hl
  ld a,h
  and $F8
  ld c,a
  jr .mainloop

.nextthird:
  
  ; $40 is 01000000
  ; $48 is 01001000
  ; $50 is 01010000
  ld c,h
 
  djnz .mainloop

  jr .theend

.nextrow:
  ld a,l
  add 32
  ld l,a
  jr c,.nextthird

  ld h,c

  dec b
  jr z,.theend

.mainloop:
  ld a,l
  ex af,af

  ld a,h
  and %11001111   ; Remove if you dont want to restrict to top 2/3
  ld h,a           ; Remove if you dont want to restrict to top 2/3

 
  
 
  pop de
  
  ld a,e
  or (hl)
  ld (hl),a

  ld a,l
  and %11100000
  ld e,a

  inc l
  
  ld a,l
  and 31
  or e
  
  ld l,a

  ld a,d
  or (hl)
  ld (hl),a

   ld a,l
  and %11100000
  ld e,a

  inc l
  
  ld a,l
  and 31
  or e
  
  ld l,a
  
  
  pop de
  ld a,e
  or (hl)
  ld (hl),a
  
   ld a,l
  and %11100000
  ld e,a

  inc l
  
  ld a,l
  and 31
  or e
  
  ld l,a


  ld a,d
  or (hl)
  ld (hl),a

  
  

  ex af,af
  ld l,a
  
  ; Restrict to top 2 thirds
  inc h
  ld a,h
 
  and 7

  jr z,.nextrow

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

PixAddr:			; DE = Y,X pixel positions, returns HL screen address
              ; Y=(0-192),X=(0-255)
	LD   A,D
	AND  $C0
	SRL  A
	SRL  A
	SRL  A
	OR   $40
	LD   H,A
	LD   A,D
	AND  $38
	ADD  A,A
	ADD  A,A
	LD   L,A
	LD   A,D
	AND  $07
	OR   H
	LD   H,A
	LD   A,E
	AND  $F8
	SRL  A
	SRL  A
	SRL  A
	OR   L
	LD   L,A
	RET

  align 256
DRAW_BUFFER:
    LD hl, bb01
    LD de, $4408
    call BLIT_SPRITE_40_24
    ret

current_frame: defb 0
frame_pause: defb 0


player_y_pos: defb 48

player_x_pos: defb 104

baddie_y_pos: defb 64

baddie_x_pos: defb 64

  align 256
; gfx address, screen address
BBTABLE:
 ; Frame 1 is 5 chars wide, 3 high but drawn 4 pixels down
  defw bb01
  defb $04    ; 4 pixels down
  defb 24     ; 24 height

  ; Frame 2 is 5 chars wide 3 high but drawn 2 pixel down
  defw bb02
   defb $02    ; 2 pixels down
  defb 24     ; 24 height
  ; Frame 3 is 5 chars wide 3 high but draw 2 pixels down
  defw bb03
   defb $02    ; 2 pixels down
  defb 24     ; 24 height
  ; Frame 4 is 5 chars wide, 3 high and 1 and draw 0 pixel down
  defw bb04
  defb $00    ; 0 pixels down
  defb 24     ; 24 height
  ; Frame 5 is 5 chars wide, 3 hight and drawn 2 pixels down
  defw bb05
   defb $02    ; 42 pixels down
  defb 24     ; 24 height
  ; Frame 6 is 5 chars wide, 3 high and drawn 4 pixels down
  defw bb06
   defb $04    ; 4 pixels down
  defb 24     ; 24 height



BBLOGO:

  include "./assets/bblogo.asm"

; Bibpoi facing right frames
  include "./assets/bipboi/bb01.asm"
  include "./assets/bipboi/bb02.asm"
  include "./assets/bipboi/bb03.asm"
  include "./assets/bipboi/bb04.asm"
  include "./assets/bipboi/bb05.asm"
  include "./assets/bipboi/bb06.asm"

  include "./assets/baddie01/block.asm"

	org $fd00
data_FD00:
  DEFS 0x101,0xFF
    
    savesna "./src/main.sna",init
    savetap "./src/main.tap",init


  ; Notes

