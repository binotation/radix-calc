; nasm -f elf64 calc.asm && gcc calc.o -o calc.out

%define	arg0	rax
%define	arg1	rdi
%define	arg2	rsi
%define	arg3	rdx

section	.bss
	input:	resb 35			; length("0b") + 32 + length("\0")
	i:	resq 1
	halves:	resq 33			; max 32 divisions + original value
	rem:	resb 33			; max 32 remainders + null byte

global	main
extern	printf
extern	strtol

section	.text
	fmtoct	db "oct: 0%o", 10, 0
	fmtdec	db "dec: %d", 10, 0
	fmthex	db "hex: 0x%x", 10, 10, 0
	fmtbin	db "bin: 0b%s", 10, 0

main:
	; sys_read(0, input, 35)
	xor	arg0, arg0		; syscall #0
	xor	arg1, arg1		; stdin fd = 0
	mov	arg2, input
	mov	arg3, 35		; read <=35 bytes
	syscall
	mov	rcx, arg0		; store # bytes read
	mov	bl, [input]		; load first and second input bytes
	mov	bh, [input + 1]

	; exit if input begins with 'q'
	cmp	bl, 113
	je	exit

	; if input is binary, parse
	cmp	rcx, 3
	jb	parse_not_binary
	cmp	bh, 98			; skip if second byte is not 'b'
	jne	parse_not_binary
	cmp	bl, 48			; skip if first byte is not '0'
	jne	parse_not_binary
	xor	arg0, arg0		; strtol(input + 2, NULL, 2)
	mov	arg1, input + 2
	xor	arg2, arg2
	mov	arg3, 2
	call	strtol
	mov	[halves], arg0		; store result

	mov	qword [i], 0		; reset loop variable
	jmp	construct_binary_loop

parse_not_binary:
	; strtol(input, NULL, 0)
	xor	arg0, arg0
	mov	arg1, input
	xor	arg2, arg2
	xor	arg3, arg3
	call	strtol
	mov	[halves], arg0		; store result

	mov	qword [i], 0		; reset loop variable

construct_binary_loop:			; construct binary representation
	mov	r8, [i]			; r8 = i
	mov	r9, [halves + 8 * r8]	; r9 = halves[i]
	mov	r10, r9
	shr	r10, 1			; r10 = halves[i] // 2
	mov	r11, r10
	shl	r11, 1			; r11 = halves[i] // 2 * 2
	mov	r12, r9
	sub	r12, r11		; r12 = halves[i] - halves[i] // 2 * 2 = remainder
	add	r12, 48			; convert to ascii
	mov	[rem + r8], r12		; store remainder ascii
	inc	r8			; r8++
	mov	[i], r8			; i++
	mov	[halves + 8 * r8], r10	; halves[i + 1] = halves[i] / 2

	test	r10, r10		; if halves[i] / 2 == 0, end loop
	jz	reverse_rem_init
	jmp	construct_binary_loop

reverse_rem_init:
	mov	byte [rem + r8], 0	; terminate remainder string
	dec	r8			; r8 = right index = i - 1
	test	r8, r8			; skip if only 1 bit
	jz	print
	xor	r13, r13		; r13 = left index = 0

reverse_rem_loop:			; reverse rem in-place excluding null terminator
	mov	cl, byte [rem + r13]	; temp left value
	mov	r11b, byte [rem + r8]	; temp right value
	mov	byte [rem + r13], r11b
	mov	byte [rem + r8], cl

	inc	r13
	dec	r8
	cmp	r13, r8
	jb	reverse_rem_loop

print:
	; printf(fmtbin, rem)
	xor	arg0, arg0
	mov	arg1, fmtbin
	mov	arg2, rem
	call	printf

	; printf(fmtoct, *halves)
	xor	arg0, arg0
	mov	arg1, fmtoct
	mov	arg2, [halves]
	call	printf

	; printf(fmtdec, *halves)
	xor	arg0, arg0
	mov	arg1, fmtdec
	mov	arg2, [halves]
	call	printf

	; printf(fmthex, *halves)
	xor	arg0, arg0
	mov	arg1, fmthex
	mov	arg2, [halves]
	call	printf

	jmp	main			; loop

exit:					; return from main
	xor	arg0, arg0		; zero out exit code
	ret
