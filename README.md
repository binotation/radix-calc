# Calculator for radix conversion of numerals
## Build
Assemble with the *Netwide Assembler* (NASM) and link with gcc.
```
nasm -f elf64 calc.asm && gcc calc.o -o calc.out
```

## Run
```
./calc.out
```

Enter a number of radix 2, 8, 10 or 16, i.e. binary, octal, decimal or hexdecimal. The acceptable range is [0, 2^32-1], i.e. 32-bit unsigned integers.

Format for each radix:
- binary: 0bddd...
- octal: 0ddd...
- decimal: ddd...
- hexdecimal: 0xddd... (case insensitive)

"ddd..." represents digits. Example for each:
- binary: 0b1011011110011011010
- octal: 01336332
- decimal: 376026
- hex: 0x5bcda or 0x5BCDA

Enter "q" to quit.

## Example output

```
[radix-convert] $ ./calc.out
123835
bin: 0b11110001110111011
oct: 0361673
dec: 123835
hex: 0x1e3bb

0b10110000001011000001
bin: 0b10110000001011000001
oct: 02601301
dec: 721601
hex: 0xb02c1

01422332
bin: 0b1100010010011011010
oct: 01422332
dec: 402650
hex: 0x624da

0x1761f
bin: 0b10111011000011111
oct: 0273037
dec: 95775
hex: 0x1761f

0xBA0DF
bin: 0b10111010000011011111
oct: 02720337
dec: 762079
hex: 0xba0df

q
[radix-convert] $ 
```
