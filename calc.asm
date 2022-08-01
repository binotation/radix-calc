; syscall table:
; https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md
; nasm -f elf64 calc.asm && ld calc.o -o calc.out

%define count r12

section	.bss
input	DB 70 DUP(?)

global	_start
section .text

_start:
	call	read

	mov	bl, [input]
	cmp	bl, 113			; exit if input buffer begins with 'q'
	je	exit

	mov	rsi, input
	mov	rdx, count
	call	write

	jmp	_start			; loop

exit:					; sys_exit(0)
	mov	rax, 60			; syscall #60
	xor	rdi, rdi		; exit code 0
	syscall

read:					; sys_read(0, input, 70)
	xor	rax, rax		; syscall #0
	xor	rdi, rdi		; stdin fd = 0
	mov	rsi, input		; input buffer
	mov	rdx, 70			; read <=70 bytes
	syscall
	mov	count, rax		; save # bytes read into r12
	ret

write:					; sys_write(1, rsi, rdx)
	mov	rax, 1			; syscall #1
	mov	rdi, 1			; stdout fd = 1
	syscall
	ret
