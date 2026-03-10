;
; L_01.asm

.include "m328pdef.inc" ; Define qué dirección tiene DDRB, PORTB, etc.

;init code segment
.equ n = 100
.dseg
.org 0x177
	table_of_unsorted_numbers: 
		.byte 100
.dseg
.org 0x399
	table_of_sorted_numbers_alg1:
		.byte 100
.dseg 
.org 0x599
table_of_sorted_numbers_alg2:
		.byte 100
;define alias for GPIO
.cseg 
.org 0x000
rjmp main 
.def tierra = r16
.def agua = r17
.def fresa = r18
.def counter = r19
.def temp1   = r20
.def temp2   = r21
.def swapped = r22
.def i       = r23
.def limit   = r24
.def  ji =   r25

; segmento de memoria 
main: 
	ldi tierra, 0x00
	out TCCR0A, tierra      ; Modo normal (WGM00=0, WGM01=0)

	ldi tierra, (1<<CS01) | (1<<CS00)
	out TCCR0B, tierra      ; Prescaler = 64

	ldi tierra, 0x00
	out TCNT0, tierra       ; Inicializar contador en 0


	 ldi agua, 77          ; rango 0–76
    ldi counter, 100       ; 32 elementos

    ldi ZH, high(table_of_unsorted_numbers)
    ldi ZL, low(table_of_unsorted_numbers)
	ldi YH, high(table_of_sorted_numbers_alg1)
    ldi YL, low(table_of_sorted_numbers_alg1)
	ldi XH, high (table_of_sorted_numbers_alg2)
	ldi XL, low (table_of_sorted_numbers_alg2)

loop:

    in tierra, TCNT0      ; usar timer como fuente "aleatoria"

mod_loop:
    cp tierra, agua
    brlo done_mod
    sub tierra, agua
    rjmp mod_loop

done_mod:
    mov fresa, tierra
    st Z+, fresa          ; guardar en tabla
	st Y+, fresa
	st X+, fresa  
    dec counter
    brne loop

end:
    rjmp end


Burbuja:

    ldi limit, n
    dec limit

do_loop:
    clr swapped
    clr i

for_loop:
    cp i, limit
    brge fin_for

    ; Z = base + i
    ldi ZH, high(table_of_sorted_numbers_alg1)
    ldi ZL, low(table_of_sorted_numbers_alg1)

    mov temp1, i
    add ZL, temp1
    adc ZH, r1

    ; cargar V[i]
    ld temp1, Z
    ldd temp2, Z+1

    cp temp1, temp2
    brlo fin_if

    ; swap
    st Z, temp2
    std Z+1, temp1

    ldi swapped, 1

fin_if:
    inc i
    rjmp for_loop

fin_for:
    tst swapped
    brne do_loop

    ret



insercion:
	
    ldi swapped, 1          ; step = 1

outer_loop:
    cpi swapped, n
    brge end_insertion

    ; Z = base + swapped
    ldi ZH, high(table_of_sorted_numbers_alg2)
    ldi ZL, low(table_of_sorted_numbers_alg2)

    mov temp1, swapped
    add ZL, temp1
    adc ZH, r1

    ld fresa, Z          ; key = array[step]

    mov ji, swapped
    dec ji               ; j = step - 1

inner_loop:

    cpi ji, 255          ; si ji < 0 (underflow)
    breq place_key

    ; Z = base + j
    ldi ZH, high(table_of_sorted_numbers_alg2)
    ldi ZL, low(table_of_sorted_numbers_alg2)

    mov temp1, ji
    add ZL, temp1
    adc ZH, r1

    ld temp2, Z          ; array[j]

    cp fresa, temp2
    brsh place_key       ; si key >= array[j], salir

    ; array[j+1] = array[j]
    std Z+1, temp2

    dec ji
    rjmp inner_loop

place_key:

    ; Z = base + j + 1
    ldi ZH, high(table_of_sorted_numbers_alg2)
    ldi ZL, low(table_of_sorted_numbers_alg2)

    mov temp1, ji
    inc temp1
    add ZL, temp1
    adc ZH, r1

    st Z, fresa

    inc swapped
    rjmp outer_loop

end_insertion:
    ret

