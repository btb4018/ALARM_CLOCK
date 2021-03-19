#include <xc.inc>
	
extrn	Write_Decimal_LCD, LCD_Clear, LCD_Write_Character, LCD_Write_Hex, operation_check
extrn	LCD_Set_Position, LCD_Write_Time, LCD_Write_Temp, Keypad, LCD_Send_Byte_I, LCD_Send_Byte_D, keypad_val, keypad_ascii
extrn	LCD_Write_Low_Nibble, LCD_Write_High_Nibble
global	Clock, Clock_Setup, operation
    
psect	udata_acs
clock_sec:	ds  1	;reserving byte to store second time in hex
clock_min:	ds  1	;reserving byte to store minute time in hex
clock_hrs:	ds  1	;reserving byte to store hour time in hex
check_60:	ds  1	;reserving byte to store decimal 60 in hex
check_24:	ds  1	;reserving byte to store decimal 24 in hex
    
LCD_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1	; reserve 1 byte for ms counter
    
clock_flag:	ds  1
hour_1:	ds 1
hour_2: ds 1
min_1: ds 1
min_2: ds 1
hex_A: ds 1
hex_B: ds 1
hex_C: ds 1
hex_D: ds 1
hex_E: ds 1
hex_F: ds 1
hex_null: ds 1
set_time_hrs1: ds 1
set_time_hrs2: ds 1  
set_time_hrsint: ds 1  
set_time_min1: ds 1
set_time_min2: ds 1
set_time_minint: ds 1  
set_time_sec1: ds 1
set_time_sec2: ds 1
set_time_secint: ds 1  
temporary_hrs: ds 1
temporary_min: ds 1
temporary_sec: ds 1
skip_byte: ds 1
timer_start_value_1: ds 1
timer_start_value_2: ds 1
    
	
    
psect	Operations_code, class=CODE


operation:
	call	delay
	call	Keypad
	movf	keypad_val, W
	CPFSEQ hex_null	
	bra	check_alarm
	bra  operation ;might get stuck
check_alarm:	
	CPFSEQ	hex_A
	bra check_set_time
	;bra set_alarm
check_set_time:
	CPFSEQ	hex_B
	bra check_cancel
	bra set_time
check_cancel:
	CPFSEQ	hex_C
	bra operation
	return

	
	
set_time: 
	movlw	00001111B
	call    LCD_Send_Byte_I
    
	movlw	10000000B	    ;set cursor to first line
	call	LCD_Set_Position
	
	movlw	0x0
	movwf	set_time_hrs1
	movwf	set_time_hrs2
	movwf	set_time_min1
	movwf	set_time_min2
	movwf	set_time_sec1
	movwf	set_time_sec2
	call write_set_time
	
	movlw	10000000B	    ;set cursor to first line
	call	LCD_Set_Position
	
	
	call	LCD_Write_Time	    ;write 'Time: ' to LCD
set_time1:	
    
	call input_check	  
	
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	
	call	set_time_write
	movff	keypad_val, set_time_hrs1
	call delay
set_time2:
	call input_check	  
	
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	
	call set_time_write
	movlw	0x3A		    ;write ':' to LCD
	call	LCD_Write_Character 
	
	movff	keypad_val, set_time_hrs2
	call delay
set_time3:
	call input_check	  
	
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	
	call set_time_write
	movff	keypad_val, set_time_min1
	call delay
set_time4:
	call input_check	  
	
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	
	call	set_time_write
	movlw	0x3A		    ;write ':' to LCD
	call	LCD_Write_Character 
	
	movff	keypad_val, set_time_min2
	call delay
set_time5:
	call input_check	  
	
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	
	call set_time_write
	movff	keypad_val, set_time_sec1
	call delay
set_time6:
	call input_check	  
	
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	
	call set_time_write
	movff	keypad_val, set_time_sec2
	call delay

check_enter:
	call input_check
	CPFSEQ	hex_C
	btfsc	skip_byte, 0
	return
	CPFSEQ	hex_E
	btfsc	skip_byte, 0
	bra	enter_time
	bra	check_enter
	
enter_time:
	call input_into_clock
	
	
cancel:
	movlw	00001100B
	call    LCD_Send_Byte_I
	
	return
  
  input_check:
	call Keypad
	movf	keypad_val, W
	CPFSEQ	hex_null
	bra keypad_input_A
	bra input_check
keypad_input_A:
	CPFSEQ	hex_A
	bra keypad_input_B
	bra input_check
keypad_input_B:
	CPFSEQ	hex_B
	bra keypad_input_D
	bra input_check
keypad_input_D:
	CPFSEQ	hex_D
	bra keypad_input_F
	bra input_check
keypad_input_F:
	CPFSEQ	hex_F
	return
	bra input_check
	
	
write_set_time:
    	movlw	10000000B	    ;set cursor to first line
	call	LCD_Set_Position
	call	LCD_Write_Time	    ;write 'Time: ' to LCD
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x3A		    ;write ':' to LCD
	call	LCD_Write_Character 
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x3A		    ;write ':' to LCD
	call	LCD_Write_Character
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	11000000B	    ;set cursor to first line
	call	LCD_Set_Position
	call	LCD_Write_Temp	    ;write 'Temp: ' to LCD
				    ;Here will write temperature to LCD
	return
	
set_time_write:
	movf	keypad_ascii, W
	call	LCD_Write_Character
	return
    
input_into_clock:
	
	clrf	PRODL
	clrf	PRODH
	
	movlw	0x01
	movwf	set_time_hrs1
	movlw	0x02
	movwf	set_time_hrs2
    
	;movlw	0x03
	;movwf	set_time_hrs1
	movlw	0x0A
	mulwf	set_time_hrs1
	movff	PRODL, temporary_hrs
	movf	set_time_hrs2
	;movf	set_time_hrs2, W
	addwf	temporary_hrs, W
	movwf	temporary_hrs, W
	
	
	;movff	PRODL, set_time_hrsint
	;movlw	set_time_hrsint
	;addwf	set_time_hrs2, W
	;movwf	temporary_hrs
	CPFSLT	check_24
	;call	output_error
	
	movlw	0x0A
	mulwf	set_time_min1
	movff	PRODL, set_time_minint
	movlw	set_time_minint
	;addwf	set_time_min2, W
	movwf	temporary_min
	CPFSLT	check_60
	;call	output_error
	
	movlw	0x0A
	mulwf	set_time_sec1
	movff	PRODL, set_time_secint
	movlw	set_time_secint
	;addwf	set_time_sec2, W
	movwf	temporary_sec
	CPFSLT	check_60
	;call	output_error
	
	movff	temporary_hrs, clock_hrs
	movff	temporary_min, clock_min
	movff	temporary_sec, clock_sec
	
	;movlw	0x01
	;movwf	keypad_val, A	
	;movf	keypad_val, A
	;movwf	clock_hrs
	;movwf	clock_min
	;movwf	clock_sec
	return
	
output_error:
    call	LCD_Clear
    movlw	10000000B
    call	LCD_Set_Position	    ;set position in LCD to first line, first character
    movlw	0x45
    call	LCD_Write_Character	;write 'E'
    movlw	0x72
    call	LCD_Write_Character	;write 'r'
    movlw	0x72
    call	LCD_Write_Character	;write 'r'
    movlw	0x6F
    call	LCD_Write_Character	;write 'o'
    movlw	0x72
    call	LCD_Write_Character	;write 'r'  
    movlw	0x0A
    call	LCD_delay_x4us    ;WRITE THIS SUBROUTINE FOR A 3SEC DELAY LATER
    return
    
    
delay:	
	movlw	0x64
	call	LCD_delay_ms
	movlw	0x64
	call	LCD_delay_ms
	movlw	0x64
	call	LCD_delay_ms
	movlw	0x64
	call	LCD_delay_ms
	return
	
	

    
    end

