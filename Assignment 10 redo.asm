;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F690. This file contains the basic code               *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F690.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f690		; list directive to define processor
	#include	<P16F690.inc>		; processor specific variable definitions
	
	__CONFIG    _CP_OFF & _CPD_OFF & _BOR_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.






;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D			; variable used for context saving
status_temp	EQU	0x7E			; variable used for context saving
pclath_temp	EQU	0x7F			; variable used for context saving

portc		EQU	0x20
count		EQU	0x21
setinal		EQU	0x22
xorgate		EQU	0x23


;**********************************************************************
	ORG		0x000			; processor reset vector
  	goto		main			; go to beginning of program


	ORG		0x004			; interrupt vector location
	movwf		w_temp			; save off current W register contents
	movf		STATUS,w		; move status register into W register
	movwf		status_temp		; save off contents of STATUS register
	movf		PCLATH,w		; move pclath register into W register
	movwf		pclath_temp		; save off contents of PCLATH register


; isr code can go here or be located as a call subroutine elsewhere
nop 

The_isr
	incf		count,1
	banksel		PIR1
	bcf			PIR1, TMR2IF
	btfss		count,4

	goto		again
	goto		rest_counter

	movf		pclath_temp,w		; retrieve copy of PCLATH register
	movwf		PCLATH			; restore pre-isr PCLATH register contents	
	movf		status_temp,w		; retrieve copy of STATUS register
	movwf		STATUS			; restore pre-isr STATUS register contents
	swapf		w_temp,f
	swapf		w_temp,w		; restore pre-isr W register contents
	retfie					; return from interrupt


main
; housekeeping
	banksel		T2CON
	movlw		0x7E			;post scale, prescale
	movwf		T2CON
	banksel		INTCON
	movlw		0xC0
	movwf		INTCON
	banksel		PR2
	movwf		.255
	movfw		PR2
	banksel		PIE1
	bsf			PIE1,TMR2IE
	banksel 	ANSEL
	clrf		ANSEL
	banksel		ANSELH
	clrf		ANSELH
	banksel		TRISC
	clrf		TRISC
	banksel		PORTC
	movlw		0x80
	movwf		portc
	movf		portc,w
	movlw		0x00
	movwf		xorgate

again
	btfss		PIR1,TMR2IF
	goto		again
	goto		The_isr

rest_counter
	clrf		count
	rrf			portc
	movf		portc,w
	xorwf		xorgate,1
	movf		xorgate,w
	movwf		PORTC
	movlw		.255
	movwf		xorgate
	goto		again


	




	ORG	0x2100				; data EEPROM location
	DE	1,2,3,4				; define first four EEPROM locations as 1, 2, 3, and 4




	END                       ; directive 'end of program'