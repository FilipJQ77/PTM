ljmp start; od tej linii zaczynamy program
org 0100h; dyrektywa lokujaca nasz program od adresu 0100h





//PIERWSZY PUNKT

mov a, #1; do akumulatora ladujemy wartosc 1
mov r0, #3; do rejestru r0 ladujemy wartosc 2
add a, r0; dodajemy zawartosc akumulatora i rejestru r0 – wynik jest w akumulatorze
mov r0, a; przenosimy wynik z akumulatora do r0

mov a, #0ffh;
mov b, #1;
add a, b;
clr ac;
clr c;
start:
mov a, #4;
mov r1, #2;
subb a, r1; a-r1 - wynik w akumulatorze
mov r1, a; przenosimy wynik do r1

mov a, #0;
mov r2, #1;
subb a, r2;
mov r2, a;
clr ac;
clr c;

mov a, #2;
mov b, #2;
mul ab;
mov r3, a;

mov a, #0ffh;
mov b, #2;
mul ab;

mov a, #6;
mov b, #2;
div ab;
mov r3, a;

mov a, #8;
mov b, #3;
div ab;

// DRUGI PUNKT

mov r0, #0ffh; 1 liczba nizsze bity
mov r1, #0; 1 liczba wyzsze
mov r2, #0ffh; 2 liczba nizsze
mov r3, #0; 2 liczba wyzsze

mov r4, #0; wynik nizsze bity
mov r5, #0; wynik wyzsze bity

mov a, r0;
add a, r2;
mov r4, a;

mov a, r1;
addc a, r3;
mov r5, a;


mov r0, #0f0h; 1 liczba nizsze bity
mov r1, #0ch; 1 liczba wyzsze
mov r2, #0ffh; 2 liczba nizsze
mov r3, #3; 2 liczba wyzsze

mov r4, #0; wynik nizsze bity
mov r5, #0; wynik wyzsze bity

mov a, r0;
clr c;
subb a, r2;  r0 - r2
mov r4, a;

mov a, r1;
subb a, r3; r1 - r3
mov r5, a;

// TRZECI PUNKT
mov a, #10010000b;
mov r0, #10110000b;

orl a, r0;
mov a, #10010000b;

xrl a, r0;
mov a, #10010000b;

anl a, r0;
mov a, #10010000b;

cpl a;

// CZWARTY PUNKT
mov a, #3;
mov dptr, #8000h;
movx @dptr, a;
mov a, #2;
movx a, @dptr;


// PIATY PUNKT
mov a, #3;
tab: db 5,0,6,7;
mov dptr, #tab;
mov a, #0;
movc a, @a+dptr;
mov a, #1;
movc a, @a+dptr;
mov a, #2;
movc a, @a+dptr;

// SZÓSTY PUNKT
//zaladowanie kolejnych danych do pamieci zewnetrznej
mov dptr, #8000h;
mov a, #13;
movx @dptr, a;
inc dptr;
mov a, #5;
movx @dptr, a;
inc dptr;
mov a, #2;
movx @dptr, a;
inc dptr;
mov a, #6;
movx @dptr, a;
inc dptr;
mov a, #7;
movx @dptr, a;
inc dptr;
mov a, #9;
movx @dptr, a;
inc dptr;
mov a, #8;
movx @dptr, a;
inc dptr;
mov a, #6;
movx @dptr, a;
inc dptr;
mov a, #2;
movx @dptr, a;
inc dptr;
mov a, #78;
movx @dptr, a;
inc dptr;
mov a, #80;
movx @dptr, a;
inc dptr;
mov a, #7;
movx @dptr, a;
inc dptr;
mov a, #9;
movx @dptr, a;
inc dptr;
mov a, #1;
movx @dptr, a;

mov r0, #13; dlugosc "tablicy" - 1
mov dptr, #8000h;

movx a, @dptr;
mov r1, a; minimum
mov r2, a; maksimum


loop:

	inc dptr;
	dec r0;
	movx a, @dptr;
	clr c;
	subb a, r1;
	jc minimum;

	movx a, @dptr;
	clr c;
	subb a, r2;
	jnc maximum;
	
	koniec:
	mov a, r0;
	jnz loop;

ljmp koniec2;

minimum:
	movx a, @dptr;
	mov r1, a;
	ljmp koniec;
	
maximum:
	movx a, @dptr;
	mov r2, a;
	ljmp koniec;
	
koniec2:

nop;
nop;
nop;
jmp $; skok “do samego siebie”
end start;