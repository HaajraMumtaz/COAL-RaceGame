;24L-0698 Haajra Mumtaz
;24L-0522 Adeena Fatima
[org 0x0100]
jmp start

temp_char db 0
temp_color db 0
temp_start_col db 0
temp_end_col db 0
highscore_text db 'HighScore', 0
score_text db 'Score', 0
score_value db '4420', 0
speed_text db 'Speed', 0
fuel_text db 'Fuel', 0
divider_offset db 0
car_row db 20           ; Default car row position
car_col db 24           ; Default car column position
default_row:db 20
default_col: db 24
; Random car generation variables
seed dw 10
carD_col dw 0, 0, 0     ; Three column positions for obstacle car
coin_car_col dw 0, 0, 0 ; Three column positions for coin car
apparent_road_corners dw 13  ; Left edge of road (column 13)
carD_row dw -2   ; Current row of obstacle car (starts at top)
coin_car_row dw -2      ; Current row of coin car (starts at middle)
blink_counter db 0      ; Counter for blinking effect (0-15)
blink_state db 1        ; 1 = visible, 0 = invisible
not_visible_row: db -2
temp_row db 1           ; Temporary storage for calculations
temp_col db 1

;TIMER VARIABLES
countdown dw 0
lane_switch_cooldown dw 0        ; Counter in timer ticks
COOLDOWN_TIME equ 48      ; 2 seconds worth of ticks
;flags + car movement
car_move_left: db 0
car_move_right: db 0
car_move_up:db 0
car_move_down:db 0
car_speed: db 9       ; Pixels to move per frame (adjust for smoothness);HORIZONTALLY
car_vert_speed: db 2
replay:db 0
terminate: db 0  
coin_consumed:db 0
;-------------------------------------------ASCII Art for GAME OVER (using text characters)-----------------------------------------------------
line1:  db '  ####      #     #     # #####      ####  #     # ##### ####   ', 0
line2:  db ' #    #    # #    ##   ## #         #    # #     # #     #   #  ', 0
line3:  db ' #        #   #   # # # # #         #    # #     # #     #   #  ', 0
line4:  db '     #  ###  #     #  #  #  # #####     #    # #     # ####  ####   ', 0
line5:  db ' #    #  #######  #     # #         #    #  #   #  #     #   #  ', 0
line6:  db ' #    #  #     #  #     # #         #    #  #   #  #     #    # ', 0
line7:  db '  ####   #     #  #     # #####      ####    ###   ##### #    # ', 0

; Simple trophy/decoration
trophy1: db '        *****           ', 0
trophy2: db '       *******          ', 0
trophy3: db '      *********         ', 0
trophy4: db '     ***********        ', 0
trophy5: db '    *************       ', 0
trophy6: db '   ***************      ', 0
trophy7: db '      |||||||||         ', 0
trophy8: db '      |||||||||         ', 0
trophy9: db '     ===========        ', 0

; Text strings
score_label: db 'YOUR SCORE: ', 0
play_again: db 'P - Play Again', 0
exit_game: db 'ESC - Exit Game', 0
decoration: db '================================', 0
; Sample score
totalscore: dw 1234
; Keyboard status
; Old ISR storag
oldisr: dd 0
old_timer: dd 0
; Current row for curtain effect
current_row: db 0
restart_msg: db 'Restarting game...', 0
road_col:db 13,37
game_paused db 0        ; 0 = not paused, 1 = paused
exit_question db 'Do you want to exit?', 0
yes_option db 'Yes', 0
no_option db 'No', 0
[org 0x0100]
jmp start

; ============================================
; DATA SECTION - START SCREEN
; ============================================
game_title: db '', 0
loading_label: db 'LOADING...', 0
percent_text: db '50%', 0
comment_text: db 'Preparing the track...', 0

; Border decoration
border_top: db '==================================================================================',0

; ASCII Art Title "ESCAPE"
title_line1: db '  _____ ____   ____    _    ____  _____',0
title_line2: db ' | ____/ ___| / ___|  / \  |  _ \| ____|',0
title_line3: db ' |  _| \___ \| |     / _ \ | |_) |  _|',0
title_line4: db ' | |___ ___) | |___ / ___ \|  __/| |___',0
title_line5: db ' |_____|____/ \____/_/   \_\_|   |_____|',0


; Car ASCII Art Data
car_line1: db '       ________                    ', 0
car_line2: db '   ___/|_||_||_\__.                ', 0
car_line3: db '  (    _    _     )                 ', 0
car_line4: db '   =', 39, '--( )--( )--', 39, '                ', 0

; Menu options
menu_line1: db '                        [P] - START YOUR ENGINES!',0
menu_line2: db '                        [ESC] - EXIT TO DOS',0

; Movement variables
car_x: dw 0           ; Current X position (start from leftmost)
car_y: dw 12          ; Fixed Y position
car_width: dw 36      ; Car width in columns

; DATA SECTION - INSTRUCTIONS SCREEN
Instructions: db'Game Instructions:'
Instructions_len: dw 18
Instructions_atrb: dw 0x07

RightKey: db'1. Press Right Arrow Key (->)'
RightKey_len:dw 29
RightKey_atrb: dw 0x07
RightKey2: db'to move right'
RightKey_len2:dw 13
RightKey_atrb2: dw 0x07

LeftKey: db'2. Press Left Arrow Key (<-)'
LeftKey_len:dw 28
LeftKey_atrb: dw 0x07
LeftKey2: db'to move left'
LeftKey_len2:dw 12
LeftKey_atrb2: dw 0x07

Crashstr: db'3. Donot let other cars'
Crashstr_len:dw 23
Crashstr_atrb: dw 0x07
Crashstr2: db'to collide with your car'
Crashstr_len2:dw 24
Crashstr_atrb2: dw 0x07

Holestr: db'4. Donot let your car to'
Holestr_len:dw 24
Holestr_atrb: dw 0x07
Holestr2: db'hit the spikes on road'
Holestr_len2:dw 22
Holestr_atrb2: dw 0x07

Fuelstr: db'5. Your fuel is limited!'
Fuelstr_len:dw 24
Fuelstr_atrb: dw 0x07

Bonusstr: db'6. Blinking car is your ally.'
Bonusstr_len:dw 29
Bonusstr_atrb: dw 0x07
Bonusstr2: db'Hit it!'
Bonusstr_len2:dw 7
Bonusstr_atrb2: dw 0x07

UpKey: db'7. Press Up Arrow Key to'
UpKey_len:dw 24
UpKey_atrb: dw 0x07
UpKey2: db'to increase speed'
UpKey_len2:dw 17
UpKey_atrb2: dw 0x07

DownKey: db'8. Press Down Arrow Key to'
DownKey_len:dw 26
DownKey_atrb: dw 0x07
DownKey2: db'to decrease speed'
DownKey_len2:dw 17
DownKey_atrb2: dw 0x07

Instructions_pause: db 'Game will start in: '
Instructions_pause_len: dw 20
Instructions_pause_atrb: dw 0x0C
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------Helpers---------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------

; RANDNUM: Generate random number in range [0-n]
; Push n (max of range), then call
; Returns result on stack
RANDNUM:
   push bp
   mov bp,sp
   push ax
   push cx
   push dx
   push bx
   
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   mov bx, 25173          
   mul bx
   add ax, 13849                    
   xor  dx, dx
   mov  cx, [bp+4]
   shr  ax,5 
   inc cx   
   div  cx
   mov [bp+6], dx
   pop bx
   pop dx
   pop cx
   pop ax
   pop bp   
   ret 2
; write_char: Write a character at (x,y) with color
; Input: AL = character, BL = color, DH = row, DL = column
write_char:
    pusha
    push es
    push di
    
    mov ah, bl              ; Color in AH
    mov bx, 0xB800
    mov es, bx
    
    ; Calculate position: (row * 80 + col) * 2
    xor bh, bh
    mov bl, dh              ; Row
    mov cx, 80
    push ax
    mov al, bl
    mul cl
    mov di, ax              ; DI = row * 80
    pop ax
    
    xor dh, dh              ; Column in DX
    add di, dx
    shl di, 1               ; * 2 for attribute byte
    
    stosw                   ; Write char + attribute
    
    pop di
    pop es
    popa
    ret

; fill_region: Fill rectangular region with character
; Input: DH=start_row, DL=start_col, CH=end_row, CL=end_col, AL=char, BL=color
fill_region:
	pusha
    push si
    
    mov byte [temp_char], al
    mov byte [temp_color], bl
    mov byte [temp_start_col], dl
    mov byte [temp_end_col], cl
    
	fr_row_loop:
		cmp dh, ch
		ja fr_done
		
		mov dl, [temp_start_col]
    
	fr_col_loop:
		cmp dl, [temp_end_col]
		ja fr_row_done
		
		mov al, [temp_char]
		mov bl, [temp_color]
		call write_char
		
		inc dl
		jmp fr_col_loop
    
	fr_row_done:
		inc dh
		jmp fr_row_loop
    
	fr_done:
		pop si
		popa
		ret
print_string_color:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push si
    push di
    
    mov ax, 0xb800
    mov es, ax
    
    ; Calculate position
    mov ax, [bp+10]     ; row
    mov cx, 80
    mul cx
    add ax, [bp+8]      ; col
    shl ax, 1
    mov di, ax
    
    mov si, [bp+4]      ; string address
    mov ah, [bp+6]      ; color attribute
    
    print_loop2:
        lodsb
        cmp al, 0
        je print_done2
        stosw
        jmp print_loop2
    
    print_done2:
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 8

; Print number at position
; Input: row @8, col @6, number @4
print_number_at:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov ax, 0xb800
    mov es, ax
    
    ; Calculate position
    mov ax, [bp+8]      ; row
    mov bx, 80
    mul bx
    add ax, [bp+6]      ; col
    shl ax, 1
    mov di, ax
    
    mov ax, [bp+4]      ; number
    mov bx, 10
    mov cx, 0
    
    nextdigit:
        mov dx, 0
        div bx
        add dl, 0x30
        push dx
        inc cx
        cmp ax, 0
        jnz nextdigit
    
    nextpos: 
        pop dx
        mov dh, 0x0E    ; yellow on black
        mov [es:di], dx
        add di, 2
        loop nextpos
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 6
	; delay: Create delay for animation
	delay:
		pusha
		mov cx, 0x02            ; Outer loop count (adjust for speed)
		
	outer_delay:
		push cx
		mov cx, 0xFFF0          ; Inner loop count
		
	inner_delay:
		nop
		nop
		nop
		loop inner_delay
		
		pop cx
		loop outer_delay
		
		popa
		ret
		
	medium_delay:
		push cx
		push ax
		mov cx, 0x7FFF
	outer:
		mov ax, 0x7FFF
	inner:
		dec ax
		jnz inner
		loop outer
		pop ax
		pop cx
		ret
		;------------------------------------------------------interrupt handling----------------------------------------------------------------------

; KEYBOARD ISR 

kbisr:
    push ax
    
    in al, 0x60 
  
    test al, 0x80
    jnz key_release
    
key_press:
    ; Check each key individually - cooldown only for left/right
    cmp al, 0x4B        ; Left arrow pressed
    je check_cooldown_left
    cmp al, 0x4D        ; Right arrow pressed
    je check_cooldown_right
    
    ; Up/Down have NO cooldown (can spam freely)
    cmp al, 0x48        ; Up arrow
    je set_up
    cmp al, 0x50        ; Down arrow
    je set_down
    
    ; Other keys have NO cooldown
    cmp al, 0x01        ; ESC key
    je handle_esc
    cmp al, 0x19        ; P key scancode
    je handle_p
    jmp kb_done

; COOLDOWN CHECKS - Only for left/right arrows

check_cooldown_left:
    cmp word [cs:lane_switch_cooldown], 0
    jne kb_done         ; Cooldown active, IGNORE this keypress
    jmp set_left        ; Cooldown expired, allow movement

check_cooldown_right:
    cmp word [cs:lane_switch_cooldown], 0
    jne kb_done         ; Cooldown active, IGNORE this keypress
    jmp set_right       ; Cooldown expired, allow movement
    
key_release:
    and al, 0x7F        ; Remove release bit    
    cmp al, 0x4B        ; Left arrow released
    je clear_left
    cmp al, 0x4D        ; Right arrow released
    je clear_right
    cmp al, 0x48        ; Up arrow released
    je clear_up
    cmp al, 0x50        ; Down arrow released
    je clear_down
    jmp kb_done

set_up:
    mov byte [car_move_up], 1
    jmp kb_done

set_down:
    mov byte [car_move_down], 1
    jmp kb_done

set_left:
    mov byte [car_move_left], 1
    mov word [cs:lane_switch_cooldown], 36  ; Start cooldown
    jmp kb_done
    
set_right:
    mov byte [car_move_right], 1
    mov word [cs:lane_switch_cooldown], 36  ; Start cooldown
    jmp kb_done
    
clear_left:
    mov byte [car_move_left], 0
    jmp kb_done
    
clear_right:
    mov byte [car_move_right], 0
    jmp kb_done

clear_up:
    mov byte [car_move_up], 0
    jmp kb_done

clear_down:
    mov byte [car_move_down], 0
    jmp kb_done

handle_esc:
    mov byte [game_paused], 1
    jmp kb_done

handle_p:
    mov byte [replay], 1
    jmp kb_done
    
kb_done:
    mov al, 0x20
    out 0x20, al
    
    pop ax
    jmp far [cs:oldisr]

; HOOK KEYBOARD INTERRUPT

hook_kbisr:
    push es
    push ax
    
    xor ax, ax
    mov es, ax
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax
    
    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    sti
    
    pop ax
    pop es
    ret

; UNHOOK KEYBOARD INTERRUPT

unhook_kbisr:
    push es
    push ax
    push bx
    
    xor ax, ax
    mov es, ax
    mov ax, [oldisr]
    mov bx, [oldisr+2]
    
    cli
    mov [es:9*4], ax
    mov [es:9*4+2], bx
    sti
    
    pop bx
    pop ax
    pop es
    ret

; CLEAR KEYBOARD BUFFER

clear_keyboard_buffer:
    push ax
clear_kb_loop:
    in al, 0x64         ; Read keyboard controller status port
    test al, 1          ; Check if output buffer has data (bit 0)
    jz clear_done       ; If no data, buffer is clear
    in al, 0x60         ; Read and discard the keystroke from data port
    jmp clear_kb_loop   ; Check again
clear_done:
    pop ax
    ret

; TIMER ISR

new_timer_isr:
    push ax
   
    cmp word [cs:lane_switch_cooldown], 0
    je .no_cooldown     ; Already zero, don't decrement
    dec word [cs:lane_switch_cooldown]
    
.no_cooldown:
    pop ax
    jmp far [cs:old_timer]  ; Chain to BIOS


; HOOK TIMER INTERRUPT

hook_timer:
    push es
    push ax
    
    xor ax, ax
    mov es, ax
    
    ; Save old timer ISR
    mov ax, [es:8*4]
    mov [old_timer], ax
    mov ax, [es:8*4+2]
    mov [old_timer+2], ax
    
    ; Install new timer ISR
    cli
    mov word [es:8*4], new_timer_isr
    mov [es:8*4+2], cs
    sti
    
    pop ax
    pop es
    ret

; UNHOOK TIMER INTERRUPT
unhook_timer:
    push es
    push ax
    push bx
    
    xor ax, ax
    mov es, ax
    mov ax, [old_timer]
    mov bx, [old_timer+2]
    
    cli
    mov [es:8*4], ax
    mov [es:8*4+2], bx
    sti
    
    pop bx
    pop ax
    pop es
    ret
; ============================================
; SUBROUTINE: Print String
; Input: DH=row, DL=column, SI=string, BL=attribute
; ============================================
print_string:
    push ax
    push bx
    push cx
    push di
    push si
    
    mov al, dh
    mov cl, 160
    mul cl
    mov di, ax
    
    xor ch, ch
    mov cl, dl
    shl cx, 1
    add di, cx
    
.loop:
    lodsb
    cmp al, 0
    je .done
    
    mov ah, bl
    mov [es:di], ax
    add di, 2
    jmp .loop
    
.done:
    pop si
    pop di
    pop cx
    pop bx
    pop ax
    ret
;-----------------------------------------game reset-------------------------------------------------------------------
set_game:
	mov byte[replay],1
	mov byte[game_paused],0
	mov al,[default_row]
	mov byte[car_row],al
	mov al,[default_col]
	mov byte[car_col],al
	mov word[carD_row], -2
	mov word[coin_car_row], -2
	mov byte[terminate],0
	ret
	;----------------------------------------------------------------------------------First Screen----------------------------------------------------------------------------------------------------------
;------------maun func-------------

screen1:
			mov ax, 0xb800
		mov es, ax
		; Clear screen (WHITE BACKGROUND)
		push 0x0720
		call clrscr
		
		; Draw top border (row 0)
		mov dh, 0
		mov dl, 0
		mov si, border_top
		mov bl, 0x0E        ; yellow
		call print_string
		
		; Draw bottom border (row 24)
		mov dh, 24
		mov dl, 0
		mov si, border_top
		mov bl, 0x0E        ; yellow
		call print_string
		
		; Draw title at row 1
		mov dh, 1
		mov dl, 34
		mov si, game_title
		mov bl, 0x0F
		call print_string
		
		; Draw ESCAPE ASCII art title
		call draw_escape_title
		
		; Draw menu options
		call draw_menu_options
		
		; Draw static loading bar section
		call draw_loading_section
		
		; Animation loop
	animation_loop:
		; Clear car at current position
		call clear_car
		
		; Move car right by 1
		mov ax, [car_x]
		inc ax
		
		; Check wrap-around (allow car to go completely off-screen)
		cmp ax, 80
		jl .no_wrap
		
		; Wrap to left edge (start completely off-screen to the left)
		mov ax, 0
		
	.no_wrap:
		mov [car_x], ax
		
		; Draw car at new position
		call draw_car
		
		; Delay for smooth movement
		mov cx, 0x02
	.delay_outer:
		push cx
		mov cx, 0xFFFF
	.delay_inner:
		nop
		loop .delay_inner
		pop cx
		loop .delay_outer
		
		; Check for keypress (non-blocking)
		mov ah, 01h
		int 16h
		jz animation_loop
		
		; Key pressed - read it
		mov ah, 00h
		int 16h
		
		
		; Check if 'P' or 'p' key
		cmp al, 'P'
		je go_to_instructions
		cmp al, 'p'
		je go_to_instructions
		
		; Any other key - ignore and continue animation
		jmp animation_loop
		
		go_to_instructions:
			ret

; ===========================================
; SUBROUTINE: Draw ESCAPE ASCII Art Title
; ============================================
draw_escape_title:
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Draw title line 1 (row 3)
    mov dh, 3
    mov dl, 20
    mov si, title_line1
    mov bl, 0x0C        ; bright red on white
    call print_string
    
    ; Draw title line 2 (row 4)
    mov dh, 4
    mov si, title_line2
    call print_string
    
    ; Draw title line 3 (row 5)
    mov dh, 5
    mov dl, 20
    mov si, title_line3
    mov bl, 0x0E        ; yellow on whit
    call print_string
    
    ; Draw title line 4 (row 6)
    mov dh, 6
    mov dl, 20
    mov si, title_line4
    mov bl, 0x0E
    call print_string
    
    ; Draw title line 5 (row 7)
    mov dh, 7
    mov dl, 20
    mov si, title_line5
    mov bl, 0x0A        ; green on white
    call print_string
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; SUBROUTINE: Draw Menu Options
; ============================================
draw_menu_options:
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Draw menu line 1 (row 18)
    mov dh, 18
    mov dl, 0
    mov si, menu_line1
    mov bl, 0x0A        ; bright green on white
    call print_string
    
    ; Draw menu line 2 (row 19)
    mov dh, 19
    mov dl, 0
    mov si, menu_line2
    mov bl, 0x0C        ; bright red on white
    call print_string
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; SUBROUTINE: Draw Loading Section (WHITE BG)
; ============================================
draw_loading_section:
    push ax
    push bx
    push cx
    push dx
    
    ; Draw "LOADING..." label - WHITE BACKGROUND
    mov dh, 21
    mov dl, 35
    mov si, loading_label
    mov bl, 0x0E        ; yellow on white
    call print_string
    
    ; Draw loading bar at row 22
    mov dh, 22
    
    ; Filled portion (20 chars)
    mov dl, 20
    mov cx, 20
.filled:
    mov al, 219
    mov bl, 0x0A
    call write_char
    inc dl
    loop .filled
    
    ; Empty portion (20 chars)
    mov cx, 20
.empty:
    mov al, 176
    mov bl, 0x07
    call write_char
    inc dl
    loop .empty
    
    ; Draw "50%" - WHITE BACKGROUND
    mov dh, 22
    mov dl, 62
    mov si, percent_text
    mov bl, 0x0E        ; yellow on white
    call print_string
    
    ; Draw comment (BLACK TEXT)
    mov dh, 23
    mov dl, 20
    mov si, comment_text
    mov bl, 0x07       ; black on white
    call print_string
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; SUBROUTINE: Draw mini Car at Position (BLACK COLOR)
; ============================================
draw_car:
    push ax
    push bx
    push dx
    push si
    
    mov ax, [car_y]
    mov dh, al
    
    ; Draw car line 1 (BLACK)
    mov ax, [car_x]
    mov dl, al
    mov si, car_line1
    mov bl, 0x07       ; black on white
    call print_string
    
    ; Draw car line 2 (BLACK)
    inc dh
    mov ax, [car_x]
    mov dl, al
    mov si, car_line2
    mov bl, 0x07
    call print_string
    
    ; Draw car line 3 (BLACK)
    inc dh
    mov ax, [car_x]
    mov dl, al
    mov si, car_line3
    mov bl, 0x07
    call print_string
    
    ; Draw car line 4 (BLACK)
    inc dh
    mov ax, [car_x]
    mov dl, al
    mov si, car_line4
    mov bl, 0x07
    call print_string
    
    pop si
    pop dx
    pop bx
    pop ax
    ret

; ============================================
; SUBROUTINE: Clear mini Car Area
; ============================================
clear_car:
    push ax
    push bx
    push cx
    push dx
    
    mov ax, [car_y]
    mov dh, al
    mov cx, 4
    
.clear_line:
    push cx
    mov ax, [car_x]
    mov dl, al
    mov cx, 36
    
.clear_col:
    mov al, ' '
    mov bl, 0x07      ; white background
    call write_char
    inc dl
    loop .clear_col
    
    inc dh
    pop cx
    loop .clear_line
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

clrscr:
	push bp
	mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax 
    mov di, 0 
nextloc:
	mov ax,[bp+4]
    mov word [es:di], ax
    add di, 2 
    cmp di, 4000 
    jne nextloc 
    pop di
    pop ax
    pop es
	pop bp
    ret 2

; Get pixel position (row, col to memory offset)
get_pixel:  ; push col@6, push row@4, push 0@8 (output)
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    
    mov ax, [bp+4]  ; row
    mov cx, 80 
    mul word cx
    mov bx, [bp+6]  ; col
    add ax, bx 	
    shl ax, 1
    
    mov [bp+8], ax  ; output

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4

; Print string function for instructions
print_string_ins: ; push len@10, push address@8, push attribute@6, push position@4
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push si
    push di

    mov ax, 0xb800
    mov es, ax
    
    mov si, [bp+8]   ; string address
    mov di, [bp+4]   ; position
    mov ah, [bp+6]   ; attribute
    mov cx, [bp+10]  ; length
    
print_string_ins_loop:
    mov al,[si]
    mov word[es:di],ax
    add di,2
    add si,1
    loop print_string_ins_loop
    
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 8

; Print number function
print_number: ; push num@6, push pos@4
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov ax, [bp+6]   ; number
    mov bx, 10
    mov cx, 0
    
nextdigitx:
    mov dx, 0
    div bx
    add dl, 0x30
    push dx
    inc cx
    cmp ax, 0
    jnz nextdigitx
    
    mov di, [bp+4]   ; position
    
nextposx: 
    pop dx
    mov dh, 0xf
    mov [es:di], dx
    add di, 2
    loop nextposx
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 4
;------------------------------------------------------------------------------------------instruction screen-----------------------------------------------------------------------------------------------------------------
; ============ INSTRUCTIONS PRINTING FUNCTION ============
instructions_printing:
    push bp
    mov bp, sp
    push ax
    push di
    push bx
    push dx
    
    ; Print "Game Instructions:" at row 5
    push 0
    mov ax, 25
    push ax
    mov ax, 5
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Instructions_len]
    push bx
    mov bx, Instructions
    push bx
    mov bx, [Instructions_atrb]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 1: Right Arrow Key (row 7-8)
    push 0
    mov ax, 25
    push ax
    mov ax, 7
    push ax
    call get_pixel
    pop dx
    
    mov bx, [RightKey_len]
    push bx
    mov bx, RightKey
    push bx
    mov bx, [RightKey_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 8
    push ax
    call get_pixel
    pop dx
    
    mov bx, [RightKey_len2]
    push bx
    mov bx, RightKey2
    push bx
    mov bx, [RightKey_atrb2]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 2: Left Arrow Key (row 9-10)
    push 0
    mov ax, 25
    push ax
    mov ax, 9
    push ax
    call get_pixel
    pop dx
    
    mov bx, [LeftKey_len]
    push bx
    mov bx, LeftKey
    push bx
    mov bx, [LeftKey_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 10
    push ax
    call get_pixel
    pop dx
    
    mov bx, [LeftKey_len2]
    push bx
    mov bx, LeftKey2
    push bx
    mov bx, [LeftKey_atrb2]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 3: Crash warning (row 11-12)
    push 0
    mov ax, 25
    push ax
    mov ax, 11
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Crashstr_len]
    push bx
    mov bx, Crashstr
    push bx
    mov bx, [Crashstr_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 12
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Crashstr_len2]
    push bx
    mov bx, Crashstr2
    push bx
    mov bx, [Crashstr_atrb2]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 4: Spikes warning (row 13-14)
    push 0
    mov ax, 25
    push ax
    mov ax, 13
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Holestr_len]
    push bx
    mov bx, Holestr
    push bx
    mov bx, [Holestr_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 14
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Holestr_len2]
    push bx
    mov bx, Holestr2
    push bx
    mov bx, [Holestr_atrb2]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 5: Fuel warning (row 15)
    push 0
    mov ax, 25
    push ax
    mov ax, 15
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Fuelstr_len]
    push bx
    mov bx, Fuelstr
    push bx
    mov bx, [Fuelstr_atrb]
    push bx
    push dx
    call print_string_ins

    ; Instruction 6: Bonus car (row 16-17)
    push 0
    mov ax, 25
    push ax
    mov ax, 16
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Bonusstr_len]
    push bx
    mov bx, Bonusstr
    push bx
    mov bx, [Bonusstr_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 17
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Bonusstr_len2]
    push bx
    mov bx, Bonusstr2
    push bx
    mov bx, [Bonusstr_atrb2]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 7: Up Arrow Key (row 18-19)
    push 0
    mov ax, 25
    push ax
    mov ax, 18
    push ax
    call get_pixel
    pop dx
    
    mov bx, [UpKey_len]
    push bx
    mov bx, UpKey
    push bx
    mov bx, [UpKey_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 19
    push ax
    call get_pixel
    pop dx
    
    mov bx, [UpKey_len2]
    push bx
    mov bx, UpKey2
    push bx
    mov bx, [UpKey_atrb2]
    push bx
    push dx
    call print_string_ins
    
    ; Instruction 8: Down Arrow Key (row 20-21)
    push 0
    mov ax, 25
    push ax
    mov ax, 20
    push ax
    call get_pixel
    pop dx
    
    mov bx, [DownKey_len]
    push bx
    mov bx, DownKey
    push bx
    mov bx, [DownKey_atrb]
    push bx
    push dx
    call print_string_ins
    
    push 0
    mov ax, 25
    push ax
    mov ax, 21
    push ax
    call get_pixel
    pop dx
    
    mov bx, [DownKey_len2]
    push bx
    mov bx, DownKey2
    push bx
    mov bx, [DownKey_atrb2]
    push bx
    push dx
    call print_string_ins
    
    pop dx
    pop bx
    pop di
    pop ax
    pop bp
    ret

; ============ COUNTDOWN TIMER DISPLAY ============
print_ins_delay_timer: ; push value@4
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov ax, 0xb800
    mov es, ax 
    
    ; Get position for timer (row 2, col 24)
    push 0
    mov ax, 24
    push ax
    mov ax, 2
    push ax
    call get_pixel
    pop dx
    mov di, dx
    
    ; Clear placeholder (3 characters)
    mov cx, 3
clr_placeholder:
    mov word [es:di], 0x0720 
    add di, 2
    loop clr_placeholder
    
    ; Print countdown number
    mov ax, [bp+4]
    push ax
    push dx
    call print_number
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 2

; ============ MAIN INSTRUCTIONS PAGE FUNCTION ============
instructions_page:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    push 0x0720
    call clrscr
    call instructions_printing

    ; Print "Game will start in: " message
    push 0
    mov ax, 5
    push ax
    mov ax, 2
    push ax
    call get_pixel
    pop dx
    
    mov bx, [Instructions_pause_len]
    push bx
    mov bx, Instructions_pause
    push bx
    mov bx, [Instructions_pause_atrb]
    push bx
    push dx
    call print_string_ins

    ; Countdown loop (10 seconds)
    mov cx, 400
    
delay_loopx:
    push cx
    mov cx, 0xFFFF
delay_loopy:
    loop delay_loopy
    pop cx
    
    cmp cx, 400
    je print_4
    cmp cx, 300
    je print_3
    cmp cx, 200
    je print_2
    cmp cx, 100
    je print_1
    jmp cont_delay_loop
    

print_4:
    mov ax, 4
    push ax
    call print_ins_delay_timer
    jmp cont_delay_loop
print_3:
    mov ax, 3
    push ax
    call print_ins_delay_timer
    jmp cont_delay_loop
print_2:
    mov ax, 2
    push ax
    call print_ins_delay_timer
    jmp cont_delay_loop
print_1:
    mov ax, 1
    push ax
    call print_ins_delay_timer
    jmp cont_delay_loop
    
cont_delay_loop:
    sub cx, 1
    cmp cx, 0
    ja delay_loopx

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret
	
;-------------------------------------------------------------------------------------------Game logic, collission detection -------------------------------------------------------------------------------------
check_collisions:
    pusha
    call check_obstacle_collision
    cmp byte [terminate], 1
    je .collision_detected      ; If crashed, exit immediately
    call check_coin_collision
    
.collision_detected:
    popa
    ret

; ============================================================================
; CHECK OBSTACLE CAR COLLISION
; ============================================================================
; Checks if player car overlaps with obstacle car
; Sets terminate flag if collision detected

check_obstacle_collision:
    push ax
    push bx
    push cx
    
    ; ─────────────────────────────────────────────────────────────
    ; STEP 1: Check vertical overlap (row collision)
    ; ─────────────────────────────────────────────────────────────
    ; Player car is at [car_row] and is 4 rows tall
    ; Obstacle car is at [carD_row] and is 4 rows tall
    
    movzx ax, byte [car_row]        ; Player car top row
    mov cx, ax
    add cx, 3                       ; Player car bottom row (top + 3)
    
    mov bx, [carD_row]              ; Obstacle car top row
    
    ; Check if obstacle car is off-screen (negative or too far down)
    cmp bx, -4
    jl .no_obstacle_collision       ; Too far above screen
    cmp bx, 29
    jg .no_obstacle_collision       ; Too far below screen
    
    ; Check vertical overlap
    ; Overlap exists if:
    ; (obstacle_top <= player_bottom) AND (obstacle_bottom >= player_top)
    mov dx, bx
    add dx, 3                       ; Obstacle car bottom row
    
    cmp bx, cx                      ; Is obstacle_top > player_bottom?
    jg .no_obstacle_collision       ; No overlap
    
    cmp dx, ax                      ; Is obstacle_bottom < player_top?
    jl .no_obstacle_collision       ; No overlap
    
    ; ─────────────────────────────────────────────────────────────
    ; STEP 2: Vertical overlap exists, now check horizontal overlap
    ; ─────────────────────────────────────────────────────────────
    ; Car columns are stored in carD_col (obstacle) and car_col (player)
    ; Each car is 5 columns wide
    
    movzx ax, byte [car_col]        ; Player car left column
    mov bx, [carD_col]              ; Obstacle car left column
    
    ; Calculate horizontal difference (signed)
    sub bx, ax                      ; bx = obstacle_left - player_left
    
    ; Check if within collision range
    ; Cars collide if their left edges are within 4 columns of each other
    ; (since each car is 5 columns wide)
    cmp bx, -4
    jl .no_obstacle_collision       ; Obstacle too far left
    cmp bx, 4
    jg .no_obstacle_collision       ; Obstacle too far right
    
    ; ─────────────────────────────────────────────────────────────
    ; COLLISION DETECTED!
    ; ─────────────────────────────────────────────────────────────
    mov byte [terminate], 1
    
    ; Optional: Play crash sound or show explosion
    ; call play_crash_sound
    
    jmp .obstacle_done
    
.no_obstacle_collision:
    ; No collision with obstacle car
    
.obstacle_done:
    pop cx
    pop bx
    pop ax
    ret

; ============================================================================
; CHECK COIN CAR COLLISION
; ============================================================================
; Checks if player car overlaps with coin car (bonus car)
; Adds score and respawns coin car if collision detected

check_coin_collision:
    push ax
    push bx
    push cx
    push dx
    
    ; ─────────────────────────────────────────────────────────────
    ; STEP 1: Check vertical overlap
    ; ─────────────────────────────────────────────────────────────
    movzx ax, byte [car_row]        ; Player car top row
    mov cx, ax
    add cx, 3                       ; Player car bottom row
    
    mov bx, [coin_car_row]          ; Coin car top row
    
    ; Check if coin car is off-screen
    cmp bx, -4
    jl .no_coin_collision
    cmp bx, 29
    jg .no_coin_collision
    
    ; Check vertical overlap
    mov dx, bx
    add dx, 3                       ; Coin car bottom row
    
    cmp bx, cx                      ; Is coin_top > player_bottom?
    jg .no_coin_collision
    
    cmp dx, ax                      ; Is coin_bottom < player_top?
    jl .no_coin_collision
    
    ; ─────────────────────────────────────────────────────────────
    ; STEP 2: Check horizontal overlap
    ; ─────────────────────────────────────────────────────────────
    movzx ax, byte [car_col]        ; Player car left column
    mov bx, [coin_car_col]          ; Coin car left column
    
    sub bx, ax                      ; Difference
    
    cmp bx, -4
    jl .no_coin_collision
    cmp bx, 4
    jg .no_coin_collision
    
    ; ─────────────────────────────────────────────────────────────
    ; COIN COLLECTED!
    ; ─────────────────────────────────────────────────────────────
    
    ; Add score (example: +100 points)
    mov ax, [totalscore]
    add ax, 100
    mov [totalscore], ax
	mov byte[coin_consumed],1
    ; Optional: Update displayed score
    call display_fuel_score_bars
    
.no_coin_collision:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
;--------------------------------------------------------------------------------------------Game screen----------------------------------------------------------------------------------------------------------
; draw_road: Draw straight road from top to bottom (full screen vertically)
draw_road:
		pusha
		push si
		
		; Road now extends from row 0 to row 24 (full screen)
		; Road columns: 12-39
		mov dh, 0
		
	road_main_loop:
		cmp dh, 24
		ja road_done
		
		; Left border at column 12
		mov dl, 12
		mov al, 0xDB            ; █
		mov bl, 0x0F            ; White
		call write_char
		
		; Road surface from column 13-38
		mov dl, 13
		mov cl, 38
		
	road_surface:
		cmp dl, cl
		ja road_right_border
		mov al, 0xB0            ; ░
		mov bl, 0x08            ; Dark gray
		call write_char
		inc dl
		jmp road_surface
		
	road_right_border:
		; Right border at column 39
		mov dl, 39
		mov al, 0xDB
		mov bl, 0x0F
		call write_char
		
		inc dh
		jmp road_main_loop
		
	road_done:
		pop si
		popa
		ret

; draw_lane_dividers: Draw yellow dashed center lines
draw_lane_dividers:
		pusha
		
		mov dh, 0               ; Start from top
    
	lane_loop:
		cmp dh, 24
		ja lane_done
		
		; Check if this row should have a dash (every 3 rows)
		mov al, dh
		and al, 3
		cmp al, 0
		je draw_dash
		cmp al, 1
		je draw_dash
		jmp skip_dash
		
	draw_dash:
		; Left lane divider at column 21
		mov dl, 21
		mov al, 0xB3            ; │ vertical line
		mov bl, 0x0E            ; Yellow
		call write_char
		
		; Right lane divider at column 30
		mov dl, 30
		mov al, 0xB3
		mov bl, 0x0E
		call write_char
		
	skip_dash:
		inc dh
		jmp lane_loop
		
	lane_done:
		popa
		ret

; draw_player_car: Draw player's car at bottom center
draw_player_car:
    pusha
    
    ; Load car position from memory
    mov dh, [car_row]       ; Get car row position
    mov dl, [car_col]       ; Get car column position
    
    ; Save base position
    mov [temp_row], dh
    mov [temp_col], dl
    
    ; Roof (top row, 2 blocks wide, centered)
    mov dh, [temp_row]
    mov dl, [temp_col]
    inc dl                  ; Center the roof (offset +1)
    mov al, 0xDF            ; ▀
    mov bl, 0x4C            ; Red
    call write_char
    inc dl
    call write_char
    
    ; Body (middle row, 4 blocks wide)
    mov dh, [temp_row]
    inc dh                  ; Next row
    mov dl, [temp_col]
    mov al, 0xDB            ; █
    mov bl, 0x4C            ; Red
    call write_char
    inc dl
    call write_char
    inc dl
    call write_char
    inc dl
    call write_char
    
    ; Bottom (bottom row, 4 blocks wide)
    mov dh, [temp_row]
    add dh, 2               ; Bottom row
    mov dl, [temp_col]
    mov al, 0xDC            ; ▄
    mov bl, 0x40            ; Black on red
    call write_char
    inc dl
    mov al, 0xDC
    mov bl, 0x4C
    call write_char
    inc dl
    call write_char
    inc dl
    mov al, 0xDC
    mov bl, 0x40
    call write_char
    
    ; Windshield (middle row, 2 blocks centered)
    mov dh, [temp_row]
    inc dh
    mov dl, [temp_col]
    inc dl                  ; Offset +1
    mov al, 0xB1            ; ▒
    mov bl, 0x46            ; Brown on red
    call write_char
    inc dl
    call write_char
    
    ; Headlights (top row, corners)
    mov dh, [temp_row]
    mov dl, [temp_col]
    mov al, 0xFE            ; ■
    mov bl, 0x4F            ; White on red
    call write_char
    add dl, 3               ; Right side
    call write_char
    
    popa
    ret

; draw_obstacle_car: Draw regular obstacle car at current position
; Uses carD_col array for column positions and carD_row for row
draw_obstacle_car:
    pusha
    push si
    
    ; Get column positions from carD_col array
    mov si, carD_col
    mov ax, [si]        ; First column
    mov bx, [si+2]      ; Second column
    mov cx, [si+4]      ; Third column
    
    ; Calculate actual screen rows for each part of the car
    mov di, [carD_row]  ; DI = base row (roof row)
    
    ; ===== DRAW ROOF (if visible) =====
    ; Roof is at carD_row, only draw if between 0-24
    cmp di, 0
    jl .skip_roof       ; Skip if above screen
    cmp di, 24
    jg .skip_roof       ; Skip if below screen
    
    ; Draw roof
    mov dh, byte [carD_row]
    mov dl, bl          ; Middle column for roof start
    mov al, 0xDF        ; ▀
    push bx
    mov bl, 0x1E        ; Blue
    call write_char
    pop bx
    mov dl, cl          ; Third column for roof end
    push bx
    mov bl, 0x1E
    call write_char
    pop bx
    
    ; Headlights on roof row
    mov dl, byte [carD_col]
    mov al, 0xFE        ; ■
    push bx
    mov bl, 0x1F        ; White on blue
    call write_char
    pop bx
    mov dl, cl
    inc dl              ; Fourth column
    mov al, 0xFE
    push bx
    mov bl, 0x1F
    call write_char
    pop bx
    
.skip_roof:
    
    ; ===== DRAW BODY (if visible) =====
    ; Body is at carD_row+1
    mov di, [carD_row]
    inc di              ; Body row
    cmp di, 0
    jl .skip_body       ; Skip if above screen
    cmp di, 24
    jg .skip_body       ; Skip if below screen
    
    ; Draw body
    mov dh, byte [carD_row]
    inc dh              ; Body row
    
    ; Four body blocks
    mov dl, byte [carD_col]
    mov al, 0xDB        ; █
    push bx
    mov bl, 0x1E        ; Blue
    call write_char
    pop bx
    
    mov dl, bl          ; Second column
    mov al, 0xDB
    push bx
    mov bl, 0x1E
    call write_char
    pop bx
    
    mov dl, cl          ; Third column
    mov al, 0xDB
    push bx
    mov bl, 0x1E
    call write_char
    pop bx
    
    mov dl, cl
    inc dl              ; Fourth column
    mov al, 0xDB
    push bx
    mov bl, 0x1E
    call write_char
    pop bx
    
    ; Windshield on body (middle two blocks)
    mov dh, byte [carD_row]
    inc dh
    mov dl, bl          ; Second column
    mov al, 0xB1        ; ▒
    push bx
    mov bl, 0x19        ; Light blue on blue
    call write_char
    pop bx
    
    mov dl, cl          ; Third column
    mov al, 0xB1
    push bx
    mov bl, 0x19
    call write_char
    pop bx
    
.skip_body:
    
    ; ===== DRAW BOTTOM (if visible) =====
    ; Bottom is at carD_row+2
    mov di, [carD_row]
    add di, 2           ; Bottom row
    cmp di, 0
    jl .skip_bottom     ; Skip if above screen
    cmp di, 24
    jg .skip_bottom     ; Skip if below screen
    
    ; Draw bottom
    mov dh, byte [carD_row]
    add dh, 2           ; Bottom row
    
    mov dl, byte [carD_col]
    mov al, 0xDC        ; ▄
    push bx
    mov bl, 0x10        ; Black on blue
    call write_char
    pop bx
    
    mov dl, bl          ; Second column
    mov al, 0xDC
    push bx
    mov bl, 0x1E
    call write_char
    pop bx
    
    mov dl, cl          ; Third column
    mov al, 0xDC
    push bx
    mov bl, 0x1E
    call write_char
    pop bx
    
    mov dl, cl
    inc dl              ; Fourth column
    mov al, 0xDC
    push bx
    mov bl, 0x10
    call write_char
    pop bx
    
.skip_bottom:
    
    pop si
    popa
    ret
draw_coin_car:
    pusha
    push si
    
    ; Get column positions from coin_car_col array
    mov si, coin_car_col
    mov ax, [si]        ; First column
    mov bx, [si+2]      ; Second column
    mov cx, [si+4]      ; Third column
    
    ; Calculate actual screen rows for each part of the car
    mov di, [coin_car_row]  ; DI = base row (roof row)
    
    ; ===== DRAW ROOF (if visible) =====
    cmp di, 0
    jl .skip_roof
    cmp di, 24
    jg .skip_roof
    
    ; Draw roof
    mov dh, byte [coin_car_row]
    mov dl, bl          ; Middle column for roof start
    mov al, 0xDF        ; ▀
    push bx
    mov bl, 0x6E        ; Yellow
    call write_char
    pop bx
    mov dl, cl          ; Third column for roof end
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    
    ; Headlights on roof row
    mov dl, byte [coin_car_col]
    mov al, 0xFE        ; ■
    push bx
    mov bl, 0x6F        ; White on yellow
    call write_char
    pop bx
    mov dl, cl
    inc dl              ; Fourth column
    mov al, 0xFE
    push bx
    mov bl, 0x6F
    call write_char
    pop bx
    
.skip_roof:
    
    ; ===== DRAW BODY (if visible) =====
    mov di, [coin_car_row]
    inc di
    cmp di, 0
    jl .skip_body
    cmp di, 24
    jg .skip_body
    
    ; Draw body
    mov dh, byte [coin_car_row]
    inc dh              ; Body row
    
    ; Four body blocks
    mov dl, byte [coin_car_col]
    mov al, 0xDB        ; █
    push bx
    mov bl, 0x6E        ; Yellow
    call write_char
    pop bx
    
    mov dl, bl          ; Second column
    mov al, 0xDB
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    
    mov dl, cl          ; Third column
    mov al, 0xDB
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    
    mov dl, cl
    inc dl              ; Fourth column
    mov al, 0xDB
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    
    ; BLINKING Windshield on body
    mov dh, byte [coin_car_row]
    inc dh
    
    ; Check blink state
    mov al, [blink_state]
    cmp al, 1
    je .draw_purple_windshield
    
    ; If blink state is 0, draw normal yellow
    mov dl, bl          ; Second column
    mov al, 0xDB        ; █ (same as body)
    push bx
    mov bl, 0x6E        ; Yellow
    call write_char
    pop bx
    mov dl, cl          ; Third column
    mov al, 0xDB
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    jmp .skip_body
    
.draw_purple_windshield:
    ; Draw visible purple windshield
    mov dl, bl          ; Second column
    mov al, 0xB1        ; ▒
    push bx
    mov bl, 0x65        ; Purple on yellow
    call write_char
    pop bx
    mov dl, cl          ; Third column
    mov al, 0xB1
    push bx
    mov bl, 0x65
    call write_char
    pop bx
    
.skip_body:
    
    ; ===== DRAW BOTTOM (if visible) =====
    mov di, [coin_car_row]
    add di, 2
    cmp di, 0
    jl .skip_bottom
    cmp di, 24
    jg .skip_bottom
    
    ; Draw bottom
    mov dh, byte [coin_car_row]
    add dh, 2           ; Bottom row
    
    mov dl, byte [coin_car_col]
    mov al, 0xDC        ; ▄
    push bx
    mov bl, 0x60        ; Black on yellow
    call write_char
    pop bx
    
    mov dl, bl          ; Second column
    mov al, 0xDC
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    
    mov dl, cl          ; Third column
    mov al, 0xDC
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    
    mov dl, cl
    inc dl              ; Fourth column
    mov al, 0xDC
    push bx
    mov bl, 0x60
    call write_char
    pop bx
    
.skip_bottom:
    
    pop si
    popa
    ret

; draw_black_after_road: Draw black area after road (right side of road)
draw_black_after_road:
		pusha
		; Black area from column 40-51, all rows (matches left black area width of 12 columns)
		mov dh, 0               ; Start row
		mov dl, 40              ; Start col (right after road border)
		mov ch, 24              ; End row
		mov cl, 51              ; End col
		mov al, ' '
		mov bl, 0x00            ; Black on black
		call fill_region
		
		; Draw thin brownish border on right side at column 51
		mov dh, 0
	border_loop_black:
		cmp dh, 24
		ja border_done_black
		mov dl, 51
		mov al, 0xB3            ; │ thin vertical line
		mov bl, 0x06            ; Brown
		call write_char
		inc dh
		jmp short border_loop_black
		
	border_done_black:
		popa
		ret

; draw_brown_rectangle: Draw brown rectangle on right side with wood texture
draw_brown_rectangle:
		pusha 
		; Brown textured rectangle from row 0-24, column 52-79
		mov dh, 0               ; Start row
		mov dl,52
		mov ch,24
		mov cl,79
		mov al, 0xB0            ; ░ light shade
		mov bl, 0x66            ; Brown
		call fill_region
	wood_done:
		popa
		ret

; draw_score_boxes: Draw two score boxes on brown rectangle
draw_score_boxes:
		pusha
		push si
		push di
		
		mov dh, 1
		mov dl, 52
		mov ch, 6
		mov cl, 65
		mov al, ' '
		mov bl, 0x00
		call fill_region
		
		; Fill right box with black
		mov dh, 1
		mov dl, 66
		mov ch, 6
		mov cl, 79
		mov al, ' '
		mov bl, 0x00
		call fill_region
		
		; Draw borders for left box
		mov dh, 1
		mov dl, 65
		mov al, 0xB3
		mov bl, 0x06
		mov cx, 6
	lb_border:
		call write_char
		inc dh
		loop lb_border
		
		mov dh, 1
		mov dl, 66
		mov al, 0xB3
		mov bl, 0x06
		mov cx, 6
	rb_border:
		call write_char
		inc dh
		loop rb_border
		
		; Write "HighScore" in left box (row 2, starting col 53)
		mov dh, 2
		mov dl, 53
		mov bl,0x0F
		mov si,highscore_text
		call print_string
		mov dl,70
		mov si,score_text
		call print_string
	s_done:
		mov dh, 3
		mov dl, 53
		mov al, 0xC4
		mov bl, 0x0F
		mov cx, 12
	hs_div:
		call write_char
		inc dl
		loop hs_div
		; Draw white divider line in right box (row 3, cols 67-78)
		mov dh, 3
		mov dl, 67
		mov al, 0xC4
		mov bl, 0x0F
		mov cx, 12
	s_div:
		call write_char
		inc dl
		loop s_div
		mov dh, 4
		mov dl, 56
		mov si, score_value
		mov bl, 0x00f
		pop di
		pop si
		popa
		ret

; draw_speed_fuel_bars: Draw speed and fuel bars at bottom of brown rectangle
; Vertical Fuel and Score Bars with Horizontal Cell Design
; Each bar has 6 horizontal cells stacked vertically
; Uses underscore '___' style horizontal blocks with spacing

display_fuel_score_bars:
    pusha
    push si
    
    ; ===== DRAW FUEL BAR (Left Bar) =====
    ; Position: Columns 57-59, starting at Row 17
    ; 6 cells with spacing between them
    
    mov dh, 17                  ; Starting row
    mov cx, 6                   ; Number of cells
    
.fuel_cell_loop:
    push cx
    
    ; Draw one horizontal cell at current row
    mov dl, 57                  ; Column 57
    mov bl, 0x0A                ; Green color
    mov al, 0x5F                ; Underscore '_'
    
    call write_char             ; Column 57
    inc dl
    call write_char             ; Column 58
    inc dl
    call write_char             ; Column 59
    
    ; Skip one row for spacing between cells
    inc dh
    
    pop cx
    loop .fuel_cell_loop
    
    ; ===== DRAW SCORE BAR (Right Bar) =====
    ; Position: Columns 70-72, starting at Row 17
    
    mov dh, 17                  ; Reset to starting row
    mov cx, 6                   ; Number of cells
    
.score_cell_loop:
    push cx
    
    ; Draw one horizontal cell at current row
    mov dl, 70                  ; Column 70
    mov bl, 0x0A                ; Green color
    mov al, 0x5F                ; Underscore '_'
    
    call write_char             ; Column 70
    inc dl
    call write_char             ; Column 71
    inc dl
    call write_char             ; Column 72
    
    ; Skip one row for spacing between cells
    inc dh
    
    pop cx
    loop .score_cell_loop
    
    ; ===== DRAW LABELS BELOW BARS =====
    mov dh, 23                  ; Row below bars
    mov dl, 56                  ; FUEL label position
    mov bl, 0x0F                ; White color
    mov si, text_fuel
    call print_string
    
    mov dl, 69                  ; SCORE label position
    mov si, text_score
    call print_string
    
    pop si
    popa
    ret

; ===== UPDATE BAR FILL LEVEL =====
; Parameters: bar_type (0=fuel, 1=score), fill_level (0-6)
; Call: push 0 or 1, push level, call refresh_bar_fill
refresh_bar_fill:
    push bp
    mov bp, sp
    pusha
    
    mov ax, [bp+4]              ; Bar type
    mov cx, [bp+6]              ; Fill level (0-6)
    
    ; Determine starting column
    cmp ax, 0
    je .use_fuel_col
    
    mov dl, 70                  ; Score bar column
    jmp .start_drawing
    
.use_fuel_col:
    mov dl, 57                  ; Fuel bar column
    
.start_drawing:
    ; Start from bottom (row 22) and fill upward
    mov dh, 22                  ; Bottom-most cell
    mov bx, cx                  ; Save fill count
    
    ; ===== FILL CELLS FROM BOTTOM UP =====
    mov cx, bx                  ; Restore fill count
    
.draw_filled_cells:
    cmp cx, 0
    je .draw_empty_cells
    
    push cx
    push dx
    
    ; Draw filled horizontal cell (solid block)
    mov bl, 0x0A                ; Bright green
    mov al, 0xDB                ; Full block '█'
    
    call write_char
    inc dl
    call write_char
    inc dl
    call write_char
    
    pop dx
    pop cx
    
    dec dh                      ; Move up one row
    dec cx
    jmp .draw_filled_cells
    
    ; ===== DRAW EMPTY CELLS AT TOP =====
.draw_empty_cells:
    cmp dh, 16                  ; Above bar area?
    jl .done_updating
    
    push dx
    
    ; Draw empty horizontal cell (underscores)
    mov bl, 0x0A                ; Green
    mov al, 0x5F                ; Underscore '_'
    
    call write_char
    inc dl
    call write_char
    inc dl
    call write_char
    
    pop dx
    
    dec dh                      ; Move up one row
    jmp .draw_empty_cells
    
.done_updating:
    popa
    pop bp
    ret 4

; ===== DATA SECTION =====
text_fuel:  db 'FUEL', 0
text_score: db 'SCORE', 0

; ===== USAGE EXAMPLES =====
; To draw initial bars:
;   call display_fuel_score_bars
;
; To update fuel bar to 4/6:
;   push 0          ; 0 = fuel bar
;   push 4          ; 4 cells filled
;   call refresh_bar_fill
;
; To update score bar to 6/6:
;   push 1          ; 1 = score bar
;   push 6          ; 6 cells filled (full)
;   call refresh_bar_fill
; randomize_obstacle_car_lane: Randomize the obstacle car's lane
randomize_obstacle_car_lane:
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push di
	
	; Generate random lane: 0, 1, or 2 (left, middle, right)
	push 0
	mov ax, 2          ; Random range: 0-2 for three lanes
	push ax
	call RANDNUM
	pop ax
	
	; Calculate starting column based on lane
	; Left lane: column 15, Middle lane: column 24, Right lane: column 33
	cmp ax, 0
	je .left_lane
	cmp ax, 1
	je .middle_lane
	
.right_lane:
	mov ax, 33
	jmp .set_columns
	
.middle_lane:
	mov ax, 24
	jmp .set_columns
	
.left_lane:
	mov ax, 15
	
.set_columns:
	mov [carD_col], ax
	add ax, 1
	mov [carD_col+2], ax
	add ax, 1 
	mov [carD_col+4], ax
	
	pop di
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	
	ret

; randomize_coin_car_lane: Randomize the coin car's lane (must be different from obstacle)
; randomize_coin_car_lane: Randomize the coin car's lane (must be different from obstacle if they're close)
randomize_coin_car_lane:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push di
    
.try_again:
    ; Generate random lane: 0, 1, or 2 (left, middle, right)
    push 0
    mov ax, 2          ; Random range: 0-2 for three lanes
    push ax
    call RANDNUM
    pop ax
    
    ; Calculate starting column based on lane
    cmp ax, 0
    je .left_lane_coin
    cmp ax, 1
    je .middle_lane_coin
    
.right_lane_coin:
    mov ax, 33
    jmp .check_conflict
    
.middle_lane_coin:
    mov ax, 24
    jmp .check_conflict
    
.left_lane_coin:
    mov ax, 15
    
.check_conflict:
    ; Check vertical distance first
    push ax                 ; Save our chosen column
    
    mov ax, [carD_row]
    mov bx, [coin_car_row]
    sub ax, bx
    
    ; Make distance positive
    cmp ax, 0
    jge .positive
    neg ax
.positive:
    
    ; If more than 6 rows apart, no conflict possible
    cmp ax, 6
    pop ax                  ; Restore our chosen column
    jg .set_columns_coin    ; Far apart = safe to use this lane
    
    ; They're close - check if same lane as obstacle car
    cmp ax, [carD_col]
    je .try_again           ; Same lane AND close = try different lane
    
.set_columns_coin:
    mov [coin_car_col], ax
    add ax, 1
    mov [coin_car_col+2], ax
    add ax, 1 
    mov [coin_car_col+4], ax
    
    pop di
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    
    ret
drawBg:
	 call draw_road
    
    ; Draw lane dividers
    call draw_lane_dividers
    
    ; Draw black area after road
    call draw_black_after_road
    
    ; Draw brown rectangle on right
    call draw_brown_rectangle
    
    ; Draw score boxes
    call draw_score_boxes
    
    ; Draw speed and fuel bars
call display_fuel_score_bars    
    ; Randomize and draw obstacle car
    call randomize_obstacle_car_lane
    call draw_obstacle_car
    
    ; Randomize and draw coin car
    call randomize_coin_car_lane
    call draw_coin_car
    
    ; Draw player car
    call draw_player_car
	
	ret

; draw_lane_dividers_scroll: Draw dividers with scrolling offset
; Input: AL = offset (0-3)
draw_lane_dividers_scroll:
    pusha
    
    mov bl, al              ; Save offset in BL
    mov dh, 0               ; Start from top row
    
lane_scroll_loop:
    cmp dh, 24
    ja lane_scroll_done
    
    ; Calculate if this row should have a dash
    ; Add current row to offset, then check pattern
    mov al, dh
    add al, bl              ; Add offset
    and al, 3               ; Modulo 4
    cmp al, 0
    je draw_scroll_dash
    cmp al, 1
    je draw_scroll_dash
    jmp skip_scroll_dash
    
draw_scroll_dash:
    ; Left lane divider at column 21
    mov dl, 21
    mov al, 0xB3            ; │ vertical line
    push bx
    mov bl, 0x0E            ; Yellow
    call write_char
    pop bx
    
    ; Right lane divider at column 30
    mov dl, 30
    mov al, 0xB3
    push bx
    mov bl, 0x0E
    call write_char
    pop bx
    
skip_scroll_dash:
    inc dh
    jmp lane_scroll_loop
    
lane_scroll_done:
    popa
    ret

update_car_position:
    push ax
    
    ; Handle left movement
    cmp byte [car_move_right], 1
    je check_right
	cmp byte[car_move_up],1
	je check_up
	cmp byte[car_move_down],1
	je check_down
	cmp byte[car_move_left],1
	jne move_done
    cmp byte [car_col], 19
    jbe check_right
    mov al, [car_speed]
    sub byte [car_col], al
check_up:
	cmp byte [car_move_up], 1
    jne move_done
    cmp byte [car_row], 0
    jbe move_done
    mov al, [car_vert_speed]
    sub byte [car_row],al
check_down:
	cmp byte [car_move_down], 1
    jne move_done
    cmp byte [car_row], 22
    jae move_done
    mov al, [car_vert_speed]
    add byte [car_row], al
	
check_right:
    ; Handle right movement
    cmp byte [car_move_right], 1
    jne move_done
    cmp byte [car_col], 29
    jae move_done
    mov al, [car_speed]
    add byte [car_col], al
    
move_done:
    pop ax
    ret
	
scrollbg:
    push ax
    push bx
    push cx
    push dx
    ; Draw static background elements once
    call draw_black_after_road
    call draw_brown_rectangle
    call draw_score_boxes
   call display_fuel_score_bars
    

    call randomize_obstacle_car_lane
    mov word [carD_row], -3  ; Start off-screen (3 rows above)
    
    ; Initialize coin car at middle with random lane
    call randomize_coin_car_lane
    mov word [coin_car_row], -2     ; Start at middle of screen
    
    mov byte [divider_offset], 0      ; Initialize offset
    mov byte [blink_counter], 0       ; Initialize blink counter
    mov byte [blink_state], 1         ; Start with visible purple
	mov ah,0
    int 16h
    
    call hook_kbisr
    
scrollLoop:
    ; Check if game is paused
    cmp byte [game_paused], 1
    je pause_loop
    
    call draw_road
    mov al, [divider_offset]
    call draw_lane_dividers_scroll
    call draw_obstacle_car
	cmp byte[coin_consumed],1
	je dont_show_coin
    call draw_coin_car
	
	dont_show_coin:
	call update_car_position
    call draw_player_car
    call check_collisions
    
    ; Check if game over (crashed into obstacle)
    cmp byte [terminate], 1
    je exit
    xor byte [blink_state], 1
    
    call delay
    
    mov ax, [carD_row]
    inc ax
    mov [carD_row], ax
    
    cmp ax, 29
    jl .obstacle_still_visible
    
    call randomize_obstacle_car_lane
    mov word [carD_row], -2
    
.obstacle_still_visible:
    mov ax, [coin_car_row]
    inc ax
    mov [coin_car_row], ax
    
    cmp ax, 25
    jl .coin_still_visible
    mov byte[coin_consumed],0
    call randomize_coin_car_lane
    mov word [coin_car_row], -2
    
.coin_still_visible:
    mov al, [divider_offset]
    inc al
    cmp al, 4
    jb .no_reset
    xor al, al
.no_reset:
    mov [divider_offset], al
    
   cmp byte [game_paused], 1
    je toggle_pause
    jmp scrollLoop
    
toggle_pause:
    ; Toggle pause state
    
    ; If now paused, draw popup
    cmp byte [game_paused], 1
    jne scrollLoop
    
    ; Draw the pause popup
    call draw_pause_popup
    
pause_loop:
    ; Wait for keypress while paused
    
    
    ; Get the key
    mov ah, 0x00
    int 0x16
    
    ; Check if 'y' or 'Y' was pressed to resume
    cmp al, 'n'
    je resume_game
    cmp al, 'N'
    je resume_game
    
    ; Check if 'n' or 'N' was pressed to exit
    cmp al, 'y'
    je exit
    cmp al, 'Y'
    je exit
    
    ; Any other key, keep waiting
    jmp pause_loop
exit:
	call unhook_kbisr
	call clear_keyboard_buffer
    mov byte [game_paused], 0
	mov byte[replay],0
	mov byte[terminate],1
	pop dx
    pop cx
    pop bx
    pop ax
	ret
resume_game:
    ; Unpause - set flag to 0
    mov byte [game_paused], 0
    
    ; Redraw background to remove popup
    call draw_black_after_road
    call draw_brown_rectangle
    call draw_score_boxes
   call display_fuel_score_bars
    
    jmp scrollLoop
;-----------------------------------------------------------------------------Pause pop up-----------------------------------------------------
; draw_pause_popup: Draw brown pause popup in center of screen
draw_pause_popup:
    pusha
    
    ; Draw brown rectangle in center (rows 7-17, cols 12-39)
    mov dh, 7               ; Start row
    mov dl, 12              ; Start col
    mov ch, 17              ; End row
    mov cl, 39              ; End col
    mov al, ' '             ; Space character
    mov bl, 0x66            ; Brown on brown
    call fill_region
    
    ; Draw border - top edge
    mov dh, 7
    mov dl, 12
    mov al, 0xC9            ; ╔ double top-left corner
    mov bl, 0x06            ; Black on brown
    call write_char
    
    mov dl, 13
    mov cx, 26              ; Width of top line
draw_top_border:
    mov al, 0xCD            ; ═ double horizontal
    call write_char
    inc dl
    loop draw_top_border
    
    mov dl, 39
    mov al, 0xBB            ; ╗ double top-right corner
    call write_char
    
    ; Draw border - bottom edge
    mov dh, 17
    mov dl, 12
    mov al, 0xC8            ; ╚ double bottom-left corner
    call write_char
    
    mov dl, 13
    mov cx, 26
draw_bottom_border:
    mov al, 0xCD            ; ═ double horizontal
    call write_char
    inc dl
    loop draw_bottom_border
    
    mov dl, 39
    mov al, 0xBC            ; ╝ double bottom-right corner
    call write_char
    
    ; Draw border - left and right edges
    mov dh, 8
    mov cx, 9               ; Height of side borders
draw_side_borders:
    mov dl, 12
    mov al, 0xBA            ; ║ double vertical
    call write_char
    mov dl, 39
    call write_char
    inc dh
    loop draw_side_borders
    
    ; Print "Do you want to exit?" text in black
    mov dh, 10
    mov dl, 16
    mov bl, 0x60            ; Black on brown
    mov si, exit_question
    call print_string
    
    ; Print "Yes" option in black
    mov dh, 13
    mov dl, 20
    mov bl, 0x60            ; Black on brown
    mov si, yes_option
    call print_string
    
    ; Print "No" option in black
    mov dh, 13
    mov dl, 30
    mov bl, 0x60            ; Black on brown
    mov si, no_option
    call print_string
    
    popa
    ret
;--------------------------------------------------------------------------end Screen----------------------------------------------------------------------------------------------------------
curtain_delay:
    push cx
    push ax
    mov cx, 0x00FF
    delay_outer:
        mov ax, 0x00FF
        delay_inner:
            dec ax
            jnz delay_inner
        loop delay_outer
    pop ax
    pop cx
    ret

; Fill a single row with spaces (for curtain effect)
; Input: row number in AL
fill_row:
    push es
    push ax
    push bx
    push cx
    push di
    
    push 0
	push 0
	mov ax,0
	push ax
	call get_pixel
    pop di
    mov ax, 0xb800
    mov es, ax
    
    mov cx, 80
    mov ax, 0x0720      ; space with white on black
    fill_row_loop:
        mov [es:di], ax
        add di, 2
        loop fill_row_loop
    
    pop di
    pop cx
    pop bx
    pop ax
    pop es
    ret
	
screenEndprep:
    push bp
    mov bp, sp
    push ax
    
    ; Row 0-2: empty rows with curtain effect
    mov al, 0
    call fill_row
    call curtain_delay
    mov al, 1
    call fill_row
    call curtain_delay
    mov al, 2
    call fill_row
    call curtain_delay
    
    ; Row 3: line1
    mov al, 3
    call fill_row
	mov dh,3
    mov dl,8
    mov si, line1
    call print_string
    call curtain_delay
    
    ; Row 4: line2
    mov al, 4
    call fill_row
    mov dh, 4
    mov dl, 8
    mov si, line2
    call print_string
    call curtain_delay
    
    ; Row 5: line3
    mov al, 5
    call fill_row
    mov dh,5
    mov dl, 8
    mov si,line3
    call print_string
    call curtain_delay
    
    ; Row 6: line4
    mov al, 6
    call fill_row
    mov dh,6
    mov dl,4
    mov si,line4
    call print_string
    call curtain_delay
    
    ; Row 7: line5
    mov al, 7
    call fill_row
    mov dh,7
    mov dl, 8
    mov si, line5
    call print_string
    call curtain_delay
    
    ; Row 8: line6
    mov al, 8
    call fill_row
    mov dh, 8
    mov dl, 8
    mov si, line6
    call print_string
    call curtain_delay
    
    ; Row 9: line7
    mov al, 9
    call fill_row
    mov dh, 9
    mov dl, 8
    mov si,line7
    call print_string
    call curtain_delay
    
    ; Row 10: empty
    mov al, 10
    call fill_row
    call curtain_delay
    
    ; Row 11: decoration
    mov al, 11
    call fill_row
    mov dh,11
    mov dl,24
    mov si, decoration
    call print_string
    call curtain_delay
    
    ; Row 12: empty
    mov al, 12
    call fill_row
    call curtain_delay
    
    ; Row 13: score
    mov al, 13
    call fill_row
    push 13
    push 34
    push 0x0E
    push score_label
    call print_string_color
    push 13
    push 46
    push word [totalscore]
    call print_number_at
    call curtain_delay
    
    ; Row 14: empty
    mov al, 14
    call fill_row
    call curtain_delay
    
    ; Row 15: decoration
    mov al, 15
    call fill_row
    mov dh, 15
    mov dl,24
    mov si, decoration
    call print_string
    call curtain_delay
    
    ; Rows 16-20: empty
    mov al, 16
    call fill_row
    call curtain_delay
    mov al, 17
    call fill_row
    call curtain_delay
    mov al, 18
    call fill_row
    call curtain_delay
    mov al, 19
    call fill_row
    call curtain_delay
    mov al, 20
    call fill_row
    call curtain_delay
    
    ; Row 21: play again
    mov al, 21
    call fill_row
    push 21
    push 28
    push 0x0A
    push play_again
    call print_string_color
    call curtain_delay
    
    ; Row 22: exit game
    mov al, 22
    call fill_row
    push 22
    push 28
    push 0x0C
    push exit_game
    call print_string_color
    call curtain_delay
    
    ; Rows 23-24: empty (complete the screen)
    mov al, 23
    call fill_row
    call curtain_delay
    mov al, 24
    call fill_row
    call curtain_delay
    
    pop ax
    pop bp
    ret
screenEnd:
    ; Ensure ES is set at start
    mov ax, 0xB800
    mov es, ax
	call clear_keyboard_buffer
	push 0x0720
	call clrscr
    call screenEndprep
    
    ; Clear buffer and hook ISR BEFORE waiting
	mov ah, 00h
		int 16h
	; Check if 'P' or 'p' key
	wait_key:
	cmp al, 'P'
	je play_again_msg
	cmp al, 'p'
	je play_again_msg
	cmp al,0x1b
	je no_replay
	call clear_keyboard_buffer
	jmp wait_key
	no_replay:
		mov byte[replay],0
		jmp terminateL
	play_again_msg:
		mov byte[replay],1
		 ; Display restart message
		push 0x0720
		call clrscr
		push 12
		push 30
		push 0x0A       ; green
		mov ax, restart_msg
		push ax
		call print_string_color
		call delay
		call delay
		
	terminateL:
		ret

; ========== MAIN PROGRAM ==========
start:

    call screen1

	call hook_timer
game:
	
	push 0x0720
    call clrscr
    call drawBg
    call scrollbg  
    call screenEnd
	cmp byte[replay],1
	jne endGame
	call set_game
	jmp game
endGame:
	call unhook_timer
	push 0x0720
	call clrscr
	
    mov ax, 0x4c00
    int 0x21