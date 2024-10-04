
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
    LD BC, 767           ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), 7            ; Bright white on black background
    LDIR                    ; Fill the attribute memory

    ; Clear screen memory
    LD HL, $4000            ; Start of screen memory
    LD DE, $4001            ; Next byte in screen memory
    LD BC, 6143         ; 6912 bytes to fill (32 columns * 24 rows)
    LD (HL), 0x00            ; Load 0 into A (black color)
    LDIR                    ; Fill the screen memory

main:

    LD DE, BBLOGO
    LD HL, 0x4808
    LD B, 32

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


    HALT

    jr main
;
DOWN_HL:        inc h : ld a,h : and 7 : ret nz
                ld a,l : add a,32 : ld l,a
                ret c
                ld a,h : sub 8 : ld h,a : ret
BBLOGO:

    include "./assets/bblogo.asm"


    
    savesna "./src/main.sna",init
    savetap "./src/main.tap",init