; KnightOS graphical demo
; Portions of the color demo provided by Christopher Mitchell
.nolist
#include "kernel.inc"
#include "applib.inc"
#include "gfxdemo.lang"
.list
    .db 0, 100 ; Stack size
.org 0
    jr start
    .db 'K'
    .db 0b00000010
    .db lang_description, 0
start:
    ; Load dependencies
    kld(de, applibPath)
    pcall(loadLibrary)
    
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(colorSupported)
    kjp(nz, noColor)
    
    ; Short intro message in legacy mode
    pcall(allocScreenBuffer)
    pcall(clearBuffer)
    kld(hl, introString)
    ld de, 0
    ld b, 0
    pcall(drawStr)
    pcall(fastCopy)
    pcall(flushKeys)
    pcall(waitKey)
    pcall(resetLegacyLcdMode)

_:  ld iy, 0b1111100000000000 ; Red
    pcall(clearColorLcd)
    pcall(flushKeys)
    applib(appWaitKey)
    jr nz, -_

_:  ld iy, 0b0000011111100000 ; Green
    pcall(clearColorLcd)
    pcall(flushKeys)
    applib(appWaitKey)
    jr nz, -_

_:  ld iy, 0b0000000000011111 ; Blue
    pcall(clearColorLcd)
    pcall(flushKeys)
    applib(appWaitKey)
    jr nz, -_
    
_:  pcall(flushKeys)
    ld h, 0
    ld d, 0
    pcall(randA)
    ld l, a
    pcall(randA)
    ld e, a
    pcall(randA)
    ld b, a
    pcall(randA)
    ld c, a
    pcall(randA)
    ld iyl, a
    pcall(randA)
    ld iyh, a
    pcall(colorRectangle)
    applib(appGetKey)
    jr nz, .handleRedraw
    or a
    jr z, -_
    
    kjp(ballDemo)
    
.handleRedraw:
    ld iy, 0b0000000000011111
    pcall(clearColorLcd)
    jr -_

noColor:
    pcall(allocScreenBuffer)

.macro div64()
    ; sra h
    .db 0xCB, 0x2C
    rr l
    .db 0xCB, 0x2C
    rr l
    .db 0xCB, 0x2C
    rr l
    .db 0xCB, 0x2C
    rr l
    .db 0xCB, 0x2C
    rr l
    .db 0xCB, 0x2C
    rr l
.endmacro
    
    xor a
    kld((angle), a)
.demoLoop:
    kld(a, (angle))
    pcall(isin)
    kld((curSin), a)
    kld(a, (angle))
    pcall(icos)
    kld((curCos), a)
    
    kld(hl, windowTitle)
    xor a
    applib(drawWindow)
    kld(hl, exitString)
    ld de, 0x0208
    pcall(drawStr)
    
    ; first rotate and projects the vertices
    xor a
    kld((vertexNb), a)
    kld(hl, vertices)
    
.renderLoop:
    push hl
        kld(de, currentVertex)
        ld bc, 6
        ldir
        
        ; rx = x * cos(a) + z * sin(a)
        kld(a, (curCos))
        kld(de, (currentVertex))
        pcall(sDEMulA)
        push hl
            kld(a, (curSin))
            kld(de, (currentVertex + 4))
            pcall(sDEMulA)
        pop de
        add hl, de
        div64()
        kld((currentRVertex), hl)
        
        ; ry = x * (cos(0) - cos(2a))/2 + y * cos(a) + z * -sin(2a)/2
        kld(a, (angle))
        add a, a
        pcall(icos)
        ld b, a
        xor a
        pcall(icos)
        sub b
        ; sra a
        .db 0xCB, 0x2F
        kld(de, (currentVertex))
        pcall(sDEMulA)
        push hl
            kld(a, (curCos))
            kld(de, (currentVertex + 2))
            pcall(sDEMulA)
            push hl
                kld(a, (angle))
                add a, a
                pcall(isin)
                neg
                ; sra a
                .db 0xCB, 0x2F
                kld(de, (currentVertex + 4))
                pcall(sDEMulA)
            pop de
            add hl, de
        pop de
        add hl, de
        div64()
        kld((currentRVertex + 2), hl)
        
        ; rz = x * -sin(2a)/2 + y * sin(a) + z * (cos(0) + cos(2a))/2
        ; camera offset for the sake of visibility : rz += 150
        kld(a, (angle))
        add a, a
        pcall(isin)
        neg
        ; sra a
        .db 0xCB, 0x2F
        kld(de, (currentVertex))
        pcall(sDEMulA)
        push hl
            kld(a, (curSin))
            kld(de, (currentVertex + 2))
            pcall(sDEMulA)
            push hl
                xor a
                pcall(icos)
                ld b, a
                kld(a, (angle))
                add a, a
                pcall(icos)
                add a, b
                ; sra a
                .db 0xCB, 0x2F
                kld(de, (currentVertex + 4))
                pcall(sDEMulA)
            pop de
            add hl, de
        pop de
        add hl, de
        div64()
        ld de, 150
        add hl, de
        ; kld((currentRVertex + 4), hl)
        
        ; px = rx * fov / rz + 48
        ld d, h
        ld e, l
        ; 42 * 64 = 0x0A80
        ld a, 0x0A
        ld c, 0x80
        pcall(divACbyDE)
        ld h, a
        ld l, c
        push hl
            ld b, h
            kld(de, (currentRVertex))
            pcall(DEMulBC)
            div64()
            ld de, 48
            add hl, de
            ld c, l
            kld(hl, projected)
            kld(a, (vertexNb))
            add a, a
            ld e, a
            ld d, 0
            add hl, de
            ld (hl), c
            inc hl
            ex (sp), hl
            
            ; py = ry * fov / rz + 32
            ld c, l
            ld b, h
            kld(de, (currentRVertex + 2))
            pcall(DEMulBC)
            div64()
            ld de, 32
            add hl, de
            ex (sp), hl
        pop de
        ld (hl), e
    pop hl
    ld de, 6
    add hl, de
    kld(a, (vertexNb))
    inc a
    kld((vertexNb), a)
    cp 8
    kjp(c, .renderLoop)
    
    ; then, draw lines between the vertices
    kld(de, indicies)
    ld b, 12 ; 12 sides for a cube
.linesLoop:
    push bc
        push de
            ld a, (de)
            kld(hl, projected)
            add a, a
            ld c, a
            ld b, 0
            add hl, bc
            ld d, (hl)
            inc hl
            ld e, (hl)
        pop bc \ inc bc \ push bc
            ld a, (bc)
            kld(hl, projected)
            add a, a
            ld c, a
            ld b, 0
            add hl, bc
            ld a, (hl)
            inc hl
            ld l, (hl)
            ld h, a
            pcall(drawLine)
        pop de
        inc de
    pop bc
    djnz .linesLoop
    
    ; we're done rendering
    pcall(fastCopy)
    pcall(clearBuffer)
    applib(appGetKey)
    kjp(nz, .demoLoop)
    cp kClear
    ret z
    kld(hl, angle)
    inc (hl)
    kjp(.demoLoop)

curSin:
    .db 0
curCos:
    .db 0
angle:
    .db 0
    
vertexNb:
    .db 0
currentVertex:
    .dw 0, 0, 0
currentRVertex:
    .dw 0, 0, 0
vertices:
    .dw -40, 40, 40
    .dw 40, 40, 40
    .dw 40, -40, 40
    .dw -40, -40, 40
    .dw -40, 40, -40
    .dw 40, 40, -40
    .dw 40, -40, -40
    .dw -40, -40, -40
projected:
    .block 8 * 2
indicies:
    .db 0, 1, 1, 2, 2, 3, 3, 0
    .db 4, 5, 5, 6, 6, 7, 7, 4
    .db 0, 4, 1, 5, 2, 6, 3, 7
    
exitString:
    .db lang_exitString, 0
windowTitle:
    .db lang_windowTitle, 0
applibPath:
    .db "/lib/applib", 0
introString:
    .db "Graphical demo for KnightOS\n\n"
    .db "Portions of this demo by\nChristopher Mitchell\n\n"
    .db "Press any key to begin.", 0

.equ nballs 10
ballDemo:
    pcall(flushKeys)
    ld iy, 0xFFFF
    pcall(clearColorLcd)
    ld bc, nballs * 5 + 1
    pcall(malloc)
    inc ix
    ld a, r
    ld (ix + -1), a
    ld a, 1
    ld b, nballs
    push ix \ pop hl
    ld de, 8 ;starting x
    ;ld c,5  ;starting y
InitSetupLoop:
    ld (hl), e ;x
    inc hl
    ld (hl), d ;x
    inc hl
    pcall(randA)
    and 0x02
    dec a
    ld (hl), a ;x velocity
    inc hl
    pcall(randA)
    cp 240 - 16
    jr c,InitSetupLoop_XOK
    and 0x7F
InitSetupLoop_XOK:
    ld (hl), a ;y
    inc hl
    pcall(randA)
    and 0x02
    dec a
    ld (hl), a ;y velocity
    inc hl
    push hl
        ld hl, 20
        add hl, de
    pop de
    ex de, hl
    ld a, 10
    add a, c
    ld c, a
    djnz initSetupLoop
    
ballTime:
    ld b, nballs
    push ix \ pop hl
ballTimeLoop:
    push hl
        ld e, (hl)
        inc hl
        ld d, (hl)
        inc hl
        push hl
            ex de, hl
            ld a, 0x52 ;"Vertical" = X for us
            pcall(writeLcdRegister)
            ld a, 0x21 ;"Vertical" = X for us
            pcall(writeLcdRegister)
            push hl
                ld de, 15
                add hl, de
                ld a, 0x53 ;"Vertical" = X for us
                pcall(writeLcdRegister)
                pop hl
            pop de
        ld a, (de)
        ld e, a
        ld d, 0
        cp 0xFF
        jr nz, ballTimeLoop_CheckReverse
        ld d, 0xFF
ballTimeLoop_CheckReverse:
        add hl, de
        pop de
    ex de, hl
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    push hl
        ld hl, 320 - 16
        or a
        sbc hl, de
        add hl, de ; cpHLDE
        jr z, ballTimeLoop_DoXFlip
        ld a, e
        or d
        jr nz, ballTimeLoop_NoXFlip
ballTimeLoop_DoXFlip:
        pop hl
    ld c, (hl)
    xor a
    sub c
    ld (hl), a
    push hl
ballTimeLoop_NoXFlip:
        pop hl
    inc hl
    push hl
        ld e, (hl)
        inc hl
        push hl
            ex de, hl
            ld h, 0
            ld a, 0x50 ;"Horizontal" = Y for us
            pcall(writeLcdRegister)
            ld h, 0
            ld a, 0x20 ;"Horizontal" = Y for us
            pcall(writeLcdRegister)
        pop de
        ld a, (de)
        add a, l
        pop de
    ex de, hl
    ld (hl), a
    inc hl
    push hl
        cp 240 - 16
        jr z,BallTimeLoop_DoYFlip
        or a
        jr nz, ballTimeLoop_NoYFlip
ballTimeLoop_DoYFlip:
        pop hl
    ld c, (hl)
    xor a
    sub c
    ld (hl), a
    push hl
ballTimeLoop_NoYFlip:
        pop hl
    inc hl

    push hl
        ld a, 0x22 \ ld c, 0x10 \ out (c),0 \ out (c),a

        push bc
            ld bc, 0x0011 ; 16*16
            kld(hl, redBall)
ballRender1:
            outi
            jr nz, ballRender1
ballRender2:
            outi
            jr nz, ballRender2
            pop bc
        pop hl
    dec b
    ld a, b
    kjp(nz, BallTimeLoop)
    
    applib(appGetKey)
    pcall(nz, clearColorLcd)
    or a
    kjp(z, ballTime)

    pcall(fullScreenWindow)
    ret
    
redBall:
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xff, 0xff, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xff, 0xff, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff
    .db 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xe8, 0xe4, 0xe8, 0xe4, 0xe8, 0xe4, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x88, 0x02, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
