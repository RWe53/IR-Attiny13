
/*
 * ASM.S
 *
 * Created: 01.01.2020 13:11:04
 *  Author: Ryszard Weber (rwe53.pl@outlook.com)
 */ 
 #include <avr/io.h>						
						
						
						.global IR_RAM

						.data

IR_RAM:     .byte		0										//0   ->Status  b7 IRQ IR_RAM  |b3 repeat    |b2 Pilot ready ANY |b1 Pilot ready Address 0x00FF |b0 bit start
            .byte		0										//1   ->Index
            .word		0										//2/3 ->Factory Code1/Code2 corelate with RC_Code
            .byte		0										//4   ->Factory Function
            .byte		0										//5   ->Factory Function
            .byte		0										//6   ->Timer
            

						.text



//** Interrup IR_RAM timer **
            .global TIM0_COMPB_vect
TIM0_COMPB_vect:  
            push  r0
            in		r0,0x3f							
            push  r0
						lds		r0,(OCR0B)								//Setup next time Interrupt  
						inc		r0												//add 1			
						sts		(OCR0B),r0                              
            lds		r0,(IR_RAM+6)
            inc		r0	
						sts		(IR_RAM+6),r0 					
            pop		r0                  
            out		0x3f,r0							
            pop		r0
						reti


            .global INT0_vect
INT0_vect:
						sei
						push  r0
            in		r0,0x3f							
            push  r0						
            push	r16
						push  r30
						push	r31
						ldi		r30,lo8(IR_RAM)
						ldi		r31,hi8(IR_RAM)						
						ld		r16,Z									//IR_RAMStatus b0 ready
            ori		r16,0x80
            st		Z,r16
            andi	r16,1
            breq	Not_0				
            ldd		r16,Z+6								//Controling 2,25ms     
            cpi		r16,38								
            brlo	Not_1									//branch if Lower
            cpi		r16,44
            brsh	Not_1								
            SEC													// bit C '1'
            rjmp	common         
Not_1:      ldd		r16,Z+6								//Controling 1,125ms 
            cpi		r16,16								
            brlo	Not_0									//branch if Lower
            cpi		r16,24
            brsh	Not_0										
            CLC													//bit C '0'    
common:     ldd		r16,Z+5
            ror		r16
            std		Z+5,r16
            ldd		r16,Z+4
            ror		r16
            std		Z+4,r16
            ldd		r16,Z+3
            ror		r16  
            std		Z+3,r16
            ldd		r16,Z+2
            ror		r16   
            std		Z+2,r16
            ldd		r16,Z+1
            inc		r16
            std		Z+1,r16
            cpi		r16,33
            brsh	Not_0
            rjmp	Not1    
Not_0:			ldd		r16,Z+6								//Controling 9 + 4,5 = 13,5ms (Start)
            cpi		r16,220	
            brlo	Not1									//branch if Lower
			      cpi		r16,250	
            brsh	Not1														 			
            ld		r16,Z									//IR_RAMStatus b0 ready
            sbr		r16,1
            cbr		r16,2
            cbr		r16,4
            st		Z,r16
            clr		r16
            std		Z+1,r16								//IR_RAMIndex
Not1:       ldd		r16,Z+6								//Controling  9 + 2,25 = 11,25ms (Repeat)
            cpi		r16,180          
            brlo	Not1y				
            cpi		r16,215              
						brsh	Not1y												
            ld		r16,Z  
            sbr		r16,8									//set bit3 Repeat
            st		Z,r16   
Not1y:      ld		r16,Z									//IR_RAMStatus b1 ready
            andi	r16,1
            breq	Not2
            ldd		r16,Z+1    
            cpi		r16,32								//32 counter remotecontrol code
            brne	Not2				
            clr		r16
            std		Z+1,r16
            ld		r16,Z									//IR_RAMStatus b0 ready
            sbr		r16,4
            st		Z,r16					
            ldd		r0,Z+2								//IR_RAMStatus b1 ready
           	ldi   r16,0x0								//Adress1   Factory remote controler lower byte
            cp		r0,r16								
            brne	Not2						
            ldd		r0,Z+3								//IR_RAMStatus b1 is ready
						ldi		r16,0xFF  						//Address2 Factory remote controler higer byte
            cp		r0,r16								
            brne	Not2									//not correct brand remote controler							
            ld		r16,Z									//IR_RAMStatus b0 ready
            sbr		r16,2
            st		Z,r16
Not2:       clr		r16         
            std		Z+6,r16	        
						pop		r31
						pop		r30
						pop		r16
            pop		r0                  
            out		0x3f,r0							
            pop		r0
						reti

 