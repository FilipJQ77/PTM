ljmp start
p6 EQU 0FAH
org 050h
znaki: db 254,253,251,247,239,223,191,127,191,223,239,247,251,253,0
delaye: db 10,30,50,70,80,90,100,110,100,90,80,70,50,30;

delay: mov r0, #0FFH
	tam: mov r1, #0FFH
	tu:
	acall delay2
	djnz r1, tu
	djnz r0, tam
	ret

;r2 odpowiada za czestotliwosc
delay2: 
	cpl p3.2
	mov a, r2
	mov r3, a
	tam1: djnz r3, tam1
	ret

delayszesc: mov r0, #0FFH
	tamsz: mov r1, #0FFH
	tusz:
	djnz r1, tusz
	djnz r0, tamsz
	ret

pszesc: mov a, p6
	xrl a, #01010001B
	mov p6, a
	ret

swiec_graj: 
	mov dptr, #znaki
	next: 
	mov a, #15
	movc a, @a+dptr
	mov r2, a
	clr a
	movc a, @a+dptr
	jz koniec
	mov p1, a
	acall delay
	inc dptr
	jmp next
	koniec: ret

org 0100h
start: acall swiec_graj
;cpl p3.2
;mov p1, a
acall pszesc
acall delayszesc
;cpl p3.2
;mov p1, a
acall pszesc
acall delayszesc
jmp start
nop
jmp $
end start
	
	;1. Zrobic "cos ciekawego" na diodach
;2. Brzeczyk ze zmieniajaca sie czestotliwoscia
;3. Napisac swoja wersje funkcji zmieniajaca wartosc portu P6 (z
;wykorzystaniem operacji logicznej)
