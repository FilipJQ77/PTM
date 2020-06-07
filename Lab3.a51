ljmp start

LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF3DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	
// deklaracje tekstów
	wyjscie: db "Przyciski",00
	wyjscie2: db "1+2 = wyjscie",00
	textt0: db "Wcisnieto",00
	textt1: db "przycisk 1",00
	textt2:	db "Przycisk  2",00
	textt3: db "Przycisk   3",00
	textt4:	db "Przycisk    4",00
	zap: db "Wcisnij",00
	wiad: db "Milego dnia :)",00
	texttext: db "0123456789ABCDEF0123456789ABCDEF",00
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra–bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
	  mov  83h, 06h			; DPH - 83h, r6 - 06h czyli MOV DPH, R6
	  mov  82h, 07h			; DPL - 82h, r7 - 07h czyli MOV DPL, R7
      ;MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM

show_string MACRO x
		mov dptr, x
		acall putstrLCD
		ENDM
		

// funkcja opóznienia
	delay:	mov r0, #15H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret
			
// funkcja wypisania znaku
;putcharLCD:	LCDcharWR
;			ret

putcharLCD:	mov a, #16
			clr c
			subb a, r1;			sprawdzenie czy w pierwszej linijce jest miejsce na znak
			jz zmien_na_2;		jesli skonczylo sie miejsce w pierwszej linijce, zmien linijke na druga
			jc druga;			jesli zaczelismy juz pisac w drugiej linijce, skocz do inkrementacji licznika znakow drugiej linii
			jmp pierwsza;		jesli zadna z powyzszych sytuacji sie nie stala, to znaczy ze piszemy znak w pierwszej linii, skocz do inkrementacji licznika znakow pierwszej linii
			zmien_na_2:
				LCDcntrlWR #HOM2;	zmiana linijki na druga
				inc r1;				aby zaznaczyc ze piszemy w drugiej linijce			
			druga:
				mov a, #16
				subb a, r3;		sprawdzenie czy w drugiej linijce jest miejsce na znak
				jnz jestmiejsce2;	jesli jest miejsce, inkrementacja licznika 2 linijki, i wyswietl znak
				LCDcntrlWR #CLEAR;	jesli skonczylo sie miejsce, wyczysc wyswietlacz
				LCDcntrlWR #HOME;	oraz przejdz do pierwszej linijki
				jmp pierwsza
				jestmiejsce2:
				inc r3
				jmp print_char
			pierwsza:
				inc r1
			print_char:
			LCDcharWR
			ret

//funkcja wypisania lancucha znaków		
putstrLCD:  mov r7, #30h	; DPL ustawiony tak by byl w DPRT adres FF30H
nextchar:	clr a
			movc a, @a+dptr
			jz koniec
			push dph
			push dpl
			acall putcharLCD
			pop dpl
			pop dph
			inc r7			; dzieki temu mozliwa inkrementacja DPTR
			inc dptr
			sjmp nextchar
	koniec: ret


// program glówny
	start:	init_LCD
			
			mov r6, #0FFH	; adres LCDdataWR  equ 0FF3DH jest w parze R6-R7
			mov r7, #30H
			
			LCDcntrlWR #CLEAR
			show_string #texttext
			show_string #wyjscie
			LCDcntrlWR #HOM2
			show_string #wyjscie2
			jmp looperino
			
			tt1:
				LCDcntrlWR #CLEAR
				show_string #textt0
				LCDcntrlWR #HOM2
				show_string #textt1
				jmp looperino
			tt2:
				LCDcntrlWR #CLEAR
				show_string #textt0
				LCDcntrlWR #HOM2
				show_string #textt2
				jmp looperino
			
			looperino:
			clr c
			orl c, p3.5 
			orl c, p3.4
			jnc exit
			mov a, p3
			jnb acc.5, tt1
			jnb acc.4, tt2
			jnb acc.3, tt3
			jnb acc.2, tt4
			jmp looperino
			
			tt3:
				LCDcntrlWR #CLEAR
				show_string #textt0
				LCDcntrlWR #HOM2
				show_string #textt3
				jmp looperino
			tt4:
				LCDcntrlWR #CLEAR
				show_string #textt0
				LCDcntrlWR #HOM2
				show_string #textt4
				jmp looperino
			
			exit:	
			z1:
				LCDcntrlWR #CLEAR
				show_string #zap
				LCDcntrlWR #HOM2
				show_string #textt4
				mov a, p3
				jb acc.2, z1
			z2:
				LCDcntrlWR #CLEAR
				show_string #zap
				LCDcntrlWR #HOM2
				show_string #textt2
				mov a, p3
				jb acc.4, z2
			z3:
				LCDcntrlWR #CLEAR
				show_string #zap
				LCDcntrlWR #HOM2
				show_string #textt3
				mov a, p3
				jb acc.3, z3
			LCDcntrlWR #CLEAR
			show_string #wiad
			
			
	nop
	nop
	nop
	jmp $
	end start