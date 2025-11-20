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
oldisr: dd 0
; Random car generation variables
seed dw 10
carD_col dw 0, 0, 0     ; Three column positions for obstacle car
coin_car_col dw 0, 0, 0 ; Three column positions for coin car
apparent_road_corners dw 13  ; Left edge of road (column 13)
obstacle_car_row dw -5   ; Current row of obstacle car (starts at top)
coin_car_row dw -5      ; Current row of coin car (starts at middle)
blink_counter db 0      ; Counter for blinking effect (0-15)
blink_state db 1        ; 1 = visible, 0 = invisible

temp_row db 1           ; Temporary storage for calculations
temp_col db 1
road_col:db 12,39
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
; Uses carD_col array for column positions and obstacle_car_row for row
draw_obstacle_car:
    pusha
    push si
    
    ; Check if car is visible on screen (rows 0-22, need 3 rows for car)
    mov ax, [obstacle_car_row]
    cmp ax, 0
    jge .check_upper
    jmp .not_visible
.check_upper:
    cmp ax, 22
    jle .draw_car
    jmp .not_visible
    
.draw_car:
    ; Get random column positions from carD_col array
    mov si, carD_col
    mov ax, [si]        ; First column
    mov bx, [si+2]      ; Second column
    mov cx, [si+4]      ; Third column
    
    ; Roof (row = obstacle_car_row)
    mov dh, byte [obstacle_car_row]
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
    
    ; Body (row = obstacle_car_row+1)
    inc dh
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
    
    ; Bottom (row = obstacle_car_row+2)
    inc dh
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
    
    ; Windshield (row = obstacle_car_row+1) - Regular light blue
    dec dh
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
    
    ; Headlights (row = obstacle_car_row)
    dec dh
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
    
.not_visible:
    pop si
    popa
    ret

; draw_coin_car: Draw coin car with BLINKING purple windshield
; Uses coin_car_col array for column positions and coin_car_row for row
draw_coin_car:
    pusha
    push si
    
    ; Check if car is visible on screen (rows 0-22, need 3 rows for car)
    mov ax, [coin_car_row]
    cmp ax, 0
    jge .check_upper
    jmp .not_visible
.check_upper:
    cmp ax, 22
    jle .draw_car
    jmp .not_visible
    
.draw_car:
    ; Get random column positions from coin_car_col array
    mov si, coin_car_col
    mov ax, [si]        ; First column
    mov bx, [si+2]      ; Second column
    mov cx, [si+4]      ; Third column
    
    ; Roof (row = coin_car_row)
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
    
    ; Body (row = coin_car_row+1)
    inc dh
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
    
    ; Bottom (row = coin_car_row+2)
    inc dh
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
    
    ; BLINKING Windshield (row = coin_car_row+1) - Purple when visible
    dec dh
    
    ; Check blink state
    mov al, [blink_state]
    cmp al, 1
    je .draw_purple_windshield
    
    ; If blink state is 0, draw normal yellow (invisible blink)
    mov dl, bl          ; Second column
    mov al, 0xDB        ; █ (same as body)
    push bx
    mov bl, 0x6E        ; Yellow (blend with body)
    call write_char
    pop bx
    mov dl, cl          ; Third column
    mov al, 0xDB
    push bx
    mov bl, 0x6E
    call write_char
    pop bx
    jmp .draw_headlights
    
.draw_purple_windshield:
    ; Draw visible purple windshield
    mov dl, bl          ; Second column
    mov al, 0xB1        ; ▒
    push bx
    mov bl, 0x65        ; Purple on yellow (5 = purple, 6 = brown/yellow bg)
    call write_char
    pop bx
    mov dl, cl          ; Third column
    mov al, 0xB1
    push bx
    mov bl, 0x65        ; Purple on yellow
    call write_char
    pop bx
    
.draw_headlights:
    ; Headlights (row = coin_car_row)
    dec dh
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
    
.not_visible:
    pop si
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
randomize_coin_car_lane:
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
	je .left_lane_coin
	cmp ax, 1
	je .middle_lane_coin
	
.right_lane_coin:
	mov ax, 33
	jmp .set_columns_coin
	
.middle_lane_coin:
	mov ax, 24
	jmp .set_columns_coin
	
.left_lane_coin:
	mov ax, 15
	
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
    call draw_speed_fuel_bars
    
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

; delay: Create delay for animation
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

; update_blink: Update blinking state for coin car

; scrollbg: Animate road scrolling continuously with obstacle car and coin car
hookkbisr:
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di
	push bx
	push dx
	push ds
	
	xor ax, ax
	mov es, ax ; point es to IVT base
	mov ax, [es:9*4]
	mov [oldisr], ax ; save offset of old routine
	mov ax, [es:9*4+2]
	mov [oldisr+2], ax ; save segment of old routine
	cli ; disable interrupts
	mov word [es:9*4], kbisr ; store offset at n*4
	mov [es:9*4+2], cs ; store segment at n*4+2
	sti ; enable interrupts
	
	pop ds
	pop dx
	pop bx
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret
kbisr:
	push ax
	push es
	mov ax, 0xb800
	mov es, ax 
	in al, 0x60 
		cmp al, 0x4B
		je mov_left
		cmp al, 0x4D
		je mov_right
	nomatch: 
	mov al, 0x20         ; EOI command
    out 0x20, al
	pop es
	pop ax
	iret
	mov_left:
		mov al,[road_col]
		add al,1
		cmp byte[car_col],al
		jbe nomatch
		sub byte[car_col],1
		jmp nomatch
	mov_right:
		mov al,[road_col+1]
		sub al,4;car width
		cmp byte[car_col],al
		jae nomatch
		add byte[car_col],1
		jmp nomatch
		
	
unhook_kbisr:
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di
	push bx
	push dx
	push ds
	
	xor ax, ax
	mov es, ax
	mov ax,[oldisr]
	mov bx,[oldisr+2]
	cli
	mov [es:9*4],ax
	mov [es:9*4+2], bx
	sti
	
	pop ds
	pop dx
	pop bx
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret

scrollbg:
    pusha
 
    ; Draw static background elements once
    call draw_black_after_road
    call draw_brown_rectangle
    call draw_score_boxes
    call draw_speed_fuel_bars
    

    call randomize_obstacle_car_lane
    mov word [obstacle_car_row], -3   ; Start off-screen (3 rows above)
    
    ; Initialize coin car at middle with random lane
    call randomize_coin_car_lane
    mov word [coin_car_row], -3      ; Start at middle of screen
    
    mov byte [divider_offset], 0      ; Initialize offset
    mov byte [blink_counter], 0       ; Initialize blink counter
    mov byte [blink_state], 1         ; Start with visible purple
	

	
scrollLoop:
    ; Draw road surface
    call draw_road
	    
    mov al, [divider_offset]
    call draw_lane_dividers_scroll
    
    ; Draw obstacle car at current position (only if visible)
    call draw_obstacle_car
    
    ; Draw coin car at current position (with blinking purple windshield)
    call draw_coin_car
    
    ; Draw player car (stays static at fixed position)
    call draw_player_car
   
    
    ; Toggle blink state
    xor byte [blink_state], 1
    
    ; Small delay for animation
    call delay
    
    ; Move obstacle car down (scrolling illusion)
    mov ax, [obstacle_car_row]
    inc ax                      ; Move down by 1 row
    mov [obstacle_car_row], ax
    
    ; Check if obstacle car went completely off screen (past row 25)
    cmp ax, 29
    jl .obstacle_still_visible
    
    ; Obstacle car went off screen - spawn new car at top with random lane
    call randomize_obstacle_car_lane
    mov word [obstacle_car_row], -3   
    
.obstacle_still_visible:
    ; Move coin car down (scrolling illusion)
    mov ax, [coin_car_row]
    inc ax                      ; Move down by 1 row
    mov [coin_car_row], ax
    
    ; Check if coin car went completely off screen (past row 25)
    cmp ax, 25
    jl .coin_still_visible
    
    ; Coin car went off screen - spawn new car at top with random lane
    call randomize_coin_car_lane
    mov word [coin_car_row], -3        ; Start 3 rows above screen for smooth entry
    
.coin_still_visible:
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
; ========== MAIN PROGRAM ==========
start:
    ; Set text mode 80x25
    mov ax, 0x0003
    int 0x10
    call hookkbisr
    ; Start scrolling animation with obstacle and coin cars
    call scrollbg
    call unhook_kbisr

    
    ; Terminate
    mov ax, 0x4c00
    int 0x21