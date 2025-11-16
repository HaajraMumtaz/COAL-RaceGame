;24L-0698 Haajra Mumtaz
;24L-0522 Adeena Fatima
[org 0x0100]
jmp start

; ========== DATA ==========
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
carD_col: dw 15
carD_row:  db 18
   
road_corners: dw 16, 26
apparent_road_corners: dw 16, 26
temp_row db 1         ; Temporary storage for calculations
temp_col db 1
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
    ;ideally at row 20-22 i.e center 
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
    mov bl, 0x49            ; Light blue on red
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



; draw_opponent_car: Draw opponent car in left lane
; draw_opponent_car: Draw opponent car in left lane
draw_opponent_car:
    pusha
    ;ideally at row 20-22 i.e center 
    ; Load car position from memory
    mov dh, [carD_row]       ; Get car row position
    mov dl, [carD_col]       ; Get car column position
    
    ; Save base position
    mov [temp_row], dh
    mov [temp_col], dl
    
    ; Roof (top row, 2 blocks wide, centered)
    mov dh, [temp_row]
    mov dl, [temp_col]
    inc dl                  ; Center the roof (offset +1)
    mov al, 0xDF            ; ▀
    mov bl, 0x6e          ; yellow
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
    mov bl, 0x6E            ; Black on red
    call write_char
    inc dl
    mov al, 0xDC
    mov bl, 0x6e
    call write_char
    inc dl
    call write_char
    inc dl
    mov al, 0xDC
    mov bl, 0x60
    call write_char
    
    ; Windshield (middle row, 2 blocks centered)
    mov dh, [temp_row]
    inc dh
    mov dl, [temp_col]
    inc dl                  ; Offset +1
    mov al, 0xB1            ; ▒
    mov bl, 0x69        ; Light blue on red
    call write_char
    inc dl
    call write_char
    
    ; Headlights (top row, corners)
    mov dh, [temp_row]
    mov dl, [temp_col]
    mov al, 0xFE            ; ■
    mov bl, 0x6f        ; White on red
    call write_char
    add dl, 3               ; Right side
    call write_char
    
    popa
    ret
	; move_car: Animate player car moving from bottom to top continuously

delay:
    pusha
    mov cx, 0x02            ; Outer loop count (adjust for speed)
    
outer_delay:
    push cx
    mov cx, 0xFFFF          ; Inner loop count
    
inner_delay:
    nop
    nop
    loop inner_delay
    
    pop cx
    loop outer_delay
    
    popa
    ret
print_text:
		push bp
		pusha
		push es
		; Count string length
		push si
		xor cx, cx
	.count:
		lodsb
		test al, al
		jz .counted
		inc cx
		jmp .count
	.counted:
		pop si
		; Setup for INT 10h
		push ds
		pop es              ; ES:BP = string pointer
		mov bp, si
		
		mov ah, 0x13        ; Write string function
		mov al, 0x01        ; Mode: move cursor, use BL for color
		mov bh, 0           ; Page 0
		; DH, DL already set (row, col)
		; BL already set (color)
		; CX = string length
		int 0x10
		
		pop es
		popa
		pop bp
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
		call print_text
		mov dl,70
		mov si,score_text
		call print_text
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
draw_speed_fuel_bars:
		pusha
		push si
		
		; Speed bar: columns 57-59, rows 17-21
		; Fuel bar: columns 70-72, rows 17-21
		
		; Draw top border for speed bar 
		; Top-left corner (row 16, col 56)
		tophalf:
			 mov dh, 16
			mov dl, 56
			mov al, 0xDA            ; ┌ top-left corner
			mov bl, 0x06            ; Brown
			call write_char
			mov dl,69
			call write_char
			; Top horizontal line (row 16, cols 57-59)
			
			mov dl, 57
			mov al, 0xC4            ; ─ horizontal line
			mov cx, 3
			top_line:
			call write_char
			inc dl
			loop top_line
			cmp dl,60
			jne .next
			mov dl,70
			mov cx,3
			jmp top_line
			; Top-right corner (row 16, col 60)
			.next:
			mov dl, 60
			mov al, 0xBF            ; ┐ rounded top-right corner
			mov bl, 0x06
			call write_char
			mov dl,73
			call write_char
			mov dh,17
			mov dl, 56
			mov al, 0xB3            ; │ vertical line
			mov bl, 0x06  
			mov cx,5
		left_border:
			call write_char
			inc dh
			loop left_border
			cmp dl,56
			jne right_border
			mov dl,69
			mov dh,17
			mov cx,5
			jmp left_border

		 
		right_border:
			mov dh, 17
			mov dl, 60
			mov al, 0xB3            ; │ vertical line
			mov bl, 0x06  
			mov cx,5
			rbloop:
			call write_char
			inc dh
			loop rbloop
			cmp dl,60
			jne bottomhalf
			mov dh,17
			mov dl,73
			mov cx,5
			jmp rbloop
		bottomhalf:
			mov dl, 57
			mov al, 0xC4            ; ─ horizontal line
			mov cx, 3
			speed_bottom_line:
			call write_char
			inc dl
			loop speed_bottom_line
			cmp dl,60
			jne corners
			mov dl,70
			mov cx,3
			jmp speed_bottom_line	
		corners:
			mov dl, 60
			mov al, 0xD9            ; ┘ rounded bottom-right corner
			mov bl, 0x06
			call write_char
			mov dl,73
			call write_char
			
			mov dh, 22
			mov dl, 69
			mov al, 0xC0            ; └ rounded bottom-left corner
			mov bl, 0x06
			call write_char
			mov dl,56
			call write_char
		
			
		mov dh, 23
		mov dl,56
		mov bl,0x0f
		mov si,fuel_text
		call print_text
		mov dl,69
		mov si,speed_text
		call print_text
		
		pop si
		popa
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
    call draw_speed_fuel_bars
    
    ; Draw opponent car (draw first so player appears in front)
    call draw_opponent_car
    
	
	ret
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
;will be used to randomize the cols of danger car on road
randomize_danger_car:
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push di
	
	push 0
	mov ax, 8
	push ax
	call RANDNUM
	pop ax
	mov dx, [apparent_road_corners]
	add ax, dx
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
; scrollbg: Animate road scrolling continuously
scrollbg:
    pusha
    
    ; Draw static background elements once
    call draw_black_after_road
    call draw_brown_rectangle
    call draw_score_boxes
    call draw_speed_fuel_bars
	call randomize_danger_car
    call draw_opponent_car
    
    mov byte [divider_offset], 0    ; Initialize offset
    
scrollLoop:
    ; Draw road surface
    call draw_road
    
    ; Draw dividers with current offset
    mov al, [divider_offset]
    call draw_lane_dividers_scroll
    
    ; Draw player car (stays static at fixed position)
	
    call draw_player_car
	call draw_opponent_car
    ; Small delay for animation
    call delay
    
    ; Update offset for next frame
    mov al, [divider_offset]
    inc al
    cmp al, 4               ; Reset after 4 (divider pattern repeats every 4 rows)
    jb .no_reset
    xor al, al
.no_reset:
    mov [divider_offset], al
    
    ; Check for keypress to exit
    mov ah, 0x01
    int 0x16
    jz scrollLoop
    
    ; Clear keyboard buffer
    mov ah, 0x00
    int 0x16
    
    popa
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

; delay_short: Short delay for smooth animation
delay_short:
    pusha
    mov cx, 0x01            ; Outer loop (reduce for faster scrolling)
    
outer_delay_short:
    push cx
    mov cx, 0x4000          ; Inner loop
    
inner_delay_short:
    nop
    loop inner_delay_short
    
    pop cx
    loop outer_delay_short
    
    popa
    ret
; ========== MAIN PROGRAM ==========
start:
    ; Set text mode 80x25
    mov ax, 0x0003
    int 0x10
    
    ; Start scrolling animation (road moves, car stays static)
    call scrollbg
    
    ; After user presses key, redraw final static scene
    call drawBg
    call draw_player_car
    
    ; Terminate
    mov ax, 0x4c00
    int 0x21