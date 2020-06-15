ljmp start

P5 equ 0F8H
P7 equ 0DBH
p6 equ 0FAH
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f	// 0111 1111
#define LINE_2		0xbf	// 1011 1111
#define	LINE_3		0xdf	// 1101 1111
#define LINE_4		0xef	// 1110 1111
#define ALL_LINES	0x0f	// 0000 1111

// procedura obslugi przerwania od portu szeregowego
org 0023H
			PUSH ACC		 ; by nie zniszczyc czegos co jest wazne w A
			JBC TI, wyslac	 ; odbieramy czy wysylamy dana
			MOV A, SBUF      ; czytanie z z portu szeregowego
			MOV R7, A		 ; zamiana odczytanego dziwolaga na ASCII
			ANL 07H, #0FH	 ; przyklad 1 - 71H zamiast 31H
			CLR C			 ; jest 0111 0001 a ma byc 0011 0001
			RRC A
			ANL A, #0F0H
			ORL A, R7
			MOV P1, A		 ; kod ASCII kontrolnie na diody
			ACALL putcharLCD ; odczytany znak z portu szeregowego na LCD
			CLR RI			 ; przerwanie powodowane odczytem z portu szeregowego obsluzone
			JMP final
	wyslac: MOV A, R5		   ; czy wazan dana do wysylki jest w buforze
			JNZ final		   ; jesli nie - to nic nie r�b
			MOV A, R6		   ; dana do wyslania z bufora
			MOV SBUF, A        ; zapis do bufora portu szeregowego
			MOV R5, #0FFH      ; wyzerowanie flagi wyslania
	final:	POP ACC  
			RETI

// program gl�wny
org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x � parametr wywolania macra � bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powt�rzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra�bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD � zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powt�rzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD � znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza � bez parametr�w
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR � inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR � czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR � konfiguracja kursora
         ENDM

// funkcja op�znienia

	delay:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			ret
			
// funkcja wypisania znaku
putcharLCD:	
			push acc;		kopia akumulatora
			mov a, #07EH;	kod litery A
			clr c
			subb a, dpl
			jz literaA;		acc=0 -> nacisnieto A
			mov a, #0BEH;	kod litery B
			clr c
			subb a, dpl
			jz literaB;		acc=0 -> nacisnieto B
			mov a, #0DEH;	kod litery C
			clr c
			subb a, dpl
			jz literaC;		acc=0 -> nacisnieto C
			jmp koniecput1;	nacisnieto inny klawisz niz A, B, C
			literaA:
			acall keyasciiA;zmiana znakow odpowiadajacych klawiszom 0-9
			jmp koniecput2
			literaB:
			acall keyasciiB;jw.
			jmp koniecput2
			literaC:
			acall keyasciiC;jw.
			jmp koniecput2
			koniecput1:
			pop acc
			LCDcharWR
			koniecput2:
			ret
			
// wylaczenie piszczyka 1kHz
BEEPOFF:	MOV A, P6
			CLR ACC.4
			MOV P6, A
			RET

// tablica przekodowania klawisze - ASCII w XRAM

keyasciiA:	mov dptr, #80EBH
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"E"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"F"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"G"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"H"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"I"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"J"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #""
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #""
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #""
			movx @dptr, a
			
			ret

keyasciiB:	mov dptr, #80EBH
			mov a, #"a"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"b"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"c"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"d"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"e"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"f"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"g"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"h"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"i"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"j"
			movx @dptr, a
			
			ret
			
keyasciiC:	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"2"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"3"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"4"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"5"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"6"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"7"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"8"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"9"
			movx @dptr, a
			
			ret
 
// program gl�wny
    start:  init_LCD
	
			acall keyasciiA
		
			ACALL BEEPOFF	 ; wylaczenie piszczyka
			mov R5, #0FFH
			mov R6, #20H

// ustawienie portu szeregowego i timera			
			MOV SCON, #50H	 ; tryb 1, 8 bit�w danych, brak bitu parzystosci
			MOV TMOD, #20H   ; konfiguracja Timera 1, tryb 2
			MOV TH1, #0FDH   ; konfiguracja szybkosci transmisji szeregowej
			MOV TL1, #0FDH   ; 9600 bit/s 
			SETB TR1		 ; timer rusza
			MOV IE, #90H	 ; wlaczenie przerwan od portu szeregowego

		
// obsluga klawiatury i wysylki do portu szeregowego			
	
	key_1:	mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_2
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a			; bufor dla znaku ASCII do wysylki
			mov r5, #00H		; ustawienie znacznika ze wazna dana w buforze R6
			setb TI				; wymuszamy przerwanie do wysylki znaku
			acall putcharLCD
			acall delay
			
	key_2:	mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_3
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a
			mov r5, #00H
			setb TI			
			acall putcharLCD
			acall delay
			
	key_3:	mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_4
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a
			mov r5, #00H
			setb TI
			acall putcharLCD
			acall delay
			
	key_4:	mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_1
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a
			mov r5, #00H
			setb TI
		    acall putcharLCD
			acall delay
			
			jmp key_1    
 
    nop
    nop
    nop
    jmp $
    end start
