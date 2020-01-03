/*
 * IR-Attiny13.c
 *
 * Created: 01.01.2020 14:32:22
 * Author : RWe
 */ 


#include <avr/io.h>
#include <avr/common.h>
#include <avr/interrupt.h>
extern uint8_t IR_RAM[];


int main(void)
{
	OSCCAL =0x7F;						// CPU 2*9,6mHz in my Attiny13A 2*8,9mHz
	CLKPR=_BV(CLKPCE);
	CLKPR=0;	
	DDRB		= _BV(PB4) ;				//LED to test
	PORTB		=  _BV(PB1) ;				// addisional pull up PB1
	TCCR0B	=  _BV(CS02) | _BV(CS00);			//1024	
	TCNT0=0;
	OCR0B=1;
	TIMSK0	=_BV(OCIE0B);
	GIMSK =  _BV(INT0);
	MCUCR = _BV(ISC01);
	sei();
	IR_RAM[0]=0;
	
    while (1) 
    {
			if (IR_RAM[0] & (1<<1) && IR_RAM[4]==0x40)	PORTB		|= _BV(PB4); else PORTB &=~(1<<PB4);
	    //IR_RAM[4] kode remote controler
    
    }
}

