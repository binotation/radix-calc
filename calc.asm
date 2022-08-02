; syscall table:
; https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md
; nasm -f elf64 calc.asm && gcc calc.o -o calc.out

%define	arg0	rax
%define	arg1	rdi
%define	arg2	rsi
%define	arg3	rdx
%define	in0	bl

section	.bss
input	db 70 DUP(?)

global	main
extern	printf
extern	strtol

section	.text
fmtdec	db "%d", 10, 0

main:
	; sys_read(0, input, 70)
	xor	arg0, arg0		; syscall #0
	xor	arg1, arg1		; stdin fd = 0
	mov	arg2, input
	mov	arg3, 70		; read <=70 bytes
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

	; printf
	mov	arg1, fmtdec
	mov	arg2, arg0
	xor	arg0, arg0
	call	printf

	jmp	main			; loop

exit:					; return from main
	xor	arg0, arg0		; zero out exit code
	ret

isposint:				; check in0 is a positive int - jbe if so
	sub	in0, 49
	cmp	in0, 8
	ret
