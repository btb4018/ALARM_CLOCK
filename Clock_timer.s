#include <xc.inc>
	
extrn	LCD_Write_Time, LCD_Write_Temp
extrn	LCD_Set_Position, LCD_Write_Character
extrn	Write_Decimal_LCD  
extrn	keypad_val, keypad_ascii

global	Clock, Clock_Setup
    
psect	udata_acs
clock_sec:	ds  1	;reserving byte to store second time in hex
clock_min:	ds  1	;reserving byte to store minute time in hex
clock_hrs:	ds  1	;reserving byte to store hour time in hex

check_60:	ds  1	;reserving byte to store decimal 60 in hex
check_24:	ds  1	;reserving byte to store decimal 24 in hex

timer_start_value_1:	ds 1
timer_start_value_2:	ds 1

hex_A:	ds 1
hex_B:	ds 1
hex_C:	ds 1
hex_D:	ds 1
hex_E:	ds 1
hex_F:	ds 1
hex_null:   	ds  1

skip_byte:	ds 1

psect	Clock_timer_code, class=CODE

Clock_Setup: 
	movlw	0x00		;setting start time to 00:00:00
	movwf   clock_sec
	movwf   clock_min
	movwf   clock_hrs
	call	rewrite_clock
	
	movlw	0x3C		;setting hex values for decimal 24 and 60 for comparison
	movwf	check_60
	movlw	0x18
	movwf	check_24
	
	movlw	0x0A		;storing keypad character hex values
	movwf	hex_A
	movlw	0x0B
	movwf	hex_B
	movlw	0x0C
	movwf	hex_C
	movlw	0x0D
	movwf	hex_D
	movlw	0x0E
	movwf	hex_E
	movlw	0x0F
	movwf	hex_F
	movlw	0xff
	movwf	hex_null
	
	movlw	0x0B
	movwf	timer_start_value_1
	movlw	0xDB
	movwf	timer_start_value_2
	
	clrf	skip_byte	;set skip byte to zero to be used to skip lines later
	
	movlw	10000111B	; Set timer1 to 16-bit, Fosc/4/256
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return
    
Clock:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	call	clock_inc	; increment clock time
	btfss	operation_check, 0 ;skip rewrite clock if = 1
	call	rewrite_clock	;write and display clock time as decimal on LCD  
	movff	timer_start_value_1, TMR0H	;setting upper byte timer start value
	movff	timer_start_value_2, TMR0L		;setting lower byte timer start value
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt	
	
rewrite_clock:
	movlw	10000000B	    ;set cursor to first line
	call	LCD_Set_Position
	call	LCD_Write_Time	    ;write 'Time: ' to LCD
	movf	clock_hrs, W	    ;write hours time to LCD as decimal
	call	Write_Decimal_LCD  
	movlw	0x3A		    ;write ':' to LCD
	call	LCD_Write_Character 
	movf	clock_min, W	    ;write minutes time to LCD as decimal
	call	Write_Decimal_LCD
	movlw	0x3A		    ;write ':' to LCD
	call	LCD_Write_Character
	movf	clock_sec, W	    ;write seconds time to LCD as decimal
	call	Write_Decimal_LCD
	movlw	11000000B	    ;set cursor to first line
	call	LCD_Set_Position
	call	LCD_Write_Temp	    ;write 'Temp: ' to LCD
				    ;Here will write temperature to LCD
	return

clock_inc:	
	incf	clock_sec	    ;increase seconds time by one
	movf	clock_sec, W	   
	cpfseq	check_60	    ;check clock seconds is equal than 60
	return			    ;return if not equal to 60
	clrf	clock_sec	    ;set second time to 0 if was equal to 60
	incf	clock_min	    ;increase minute time by one
	movf	clock_min, W
	cpfseq	check_60	    ;check if minute time equal to 60
	return
	clrf	clock_min	    ;set minute time to 0 if = 60
	incf	clock_hrs	    ;increase hour time by one
	movf	clock_hrs, W	
	cpfseq	check_24	    ;check if hour time equal to 24
	return	
	clrf	clock_hrs	    ;set hour time to 0 if = 24
	return
