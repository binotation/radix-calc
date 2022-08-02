; nasm -f elf64 calc.asm && gcc calc.o -o calc.out

%define	arg0	rax
%define	arg1	rdi
%define	arg2	rsi
%define	arg3	rdx
%define	in0	bl

section	.bss
	input:	resb 67			; length("0b") + 64 + length("\0")
	i:	resq 1
	halves:	resq 65			; n, n/2, n/4, ..., n/2^64
	rem:	resb 65			; n % 2, n/2 % 2, ..., n/2^64 % 2, "\0"

global	main
extern	printf
extern	strtol

section	.text
	fmtoct	db "oct: 0%o", 10, 0
	fmtdec	db "dec: %d", 10, 0
	fmthex	db "hex: 0x%x", 10, 0
	fmtbin	db "bin: 0b%s", 10, 0

main:
	; sys_read(0, input, 67)
	xor	arg0, arg0		; syscall #0
	xor	arg1, arg1		; stdin fd = 0
	mov	arg2, input
	mov	arg3, 67		; read <=67 bytes
	syscall
	mov	in0, [input]		; load first input byte

	; exit if input begins with 'q'
	cmp	in0, 113
	je	exit

	; strtol(input, NULL, 0)
	xor	arg0, arg0
	mov	arg1, input
	xor	arg2, arg2
	xor	arg3, arg3
	call	strtol
	mov	[halves], arg0
	mov	qword [i], 0

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
	jz	print
	cmp	r8, 65
	jb	construct_binary_loop

print:
	mov	byte [rem + r8], 0	; terminate remainder string
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
