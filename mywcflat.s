	.arch armv8-a
	.file	"mywcflat.c"
	.text
	.local	lLineCount
	.comm	lLineCount,8,8
	.local	lWordCount
	.comm	lWordCount,8,8
	.local	lCharCount
	.comm	lCharCount,8,8
	.local	iChar
	.comm	iChar,4,4
	.local	iInWord
	.comm	iInWord,4,4
	.section	.rodata
	.align	3
.LC0:
	.string	"%7ld %7ld %7ld\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
.L2:
	bl	getchar
	mov	w1, w0
	adrp	x0, iChar
	add	x0, x0, :lo12:iChar
	str	w1, [x0]
	adrp	x0, iChar
	add	x0, x0, :lo12:iChar
	ldr	w0, [x0]
	cmn	w0, #1
	beq	.L17
	adrp	x0, lCharCount
	add	x0, x0, :lo12:lCharCount
	ldr	x0, [x0]
	add	x1, x0, 1
	adrp	x0, lCharCount
	add	x0, x0, :lo12:lCharCount
	str	x1, [x0]
	bl	__ctype_b_loc
	ldr	x1, [x0]
	adrp	x0, iChar
	add	x0, x0, :lo12:iChar
	ldr	w0, [x0]
	sxtw	x0, w0
	lsl	x0, x0, 1
	add	x0, x1, x0
	ldrh	w0, [x0]
	and	w0, w0, 8192
	cmp	w0, 0
	beq	.L18
	adrp	x0, iInWord
	add	x0, x0, :lo12:iInWord
	ldr	w0, [x0]
	cmp	w0, 0
	beq	.L19
	adrp	x0, lWordCount
	add	x0, x0, :lo12:lWordCount
	ldr	x0, [x0]
	add	x1, x0, 1
	adrp	x0, lWordCount
	add	x0, x0, :lo12:lWordCount
	str	x1, [x0]
	adrp	x0, iInWord
	add	x0, x0, :lo12:iInWord
	str	wzr, [x0]
	b	.L8
.L18:
	nop
.L6:
	adrp	x0, iInWord
	add	x0, x0, :lo12:iInWord
	ldr	w0, [x0]
	cmp	w0, 0
	bne	.L20
	adrp	x0, iInWord
	add	x0, x0, :lo12:iInWord
	mov	w1, 1
	str	w1, [x0]
	b	.L8
.L19:
	nop
	b	.L8
.L20:
	nop
.L8:
	adrp	x0, iChar
	add	x0, x0, :lo12:iChar
	ldr	w0, [x0]
	cmp	w0, 10
	bne	.L21
	adrp	x0, lLineCount
	add	x0, x0, :lo12:lLineCount
	ldr	x0, [x0]
	add	x1, x0, 1
	adrp	x0, lLineCount
	add	x0, x0, :lo12:lLineCount
	str	x1, [x0]
	b	.L2
.L21:
	nop
.L11:
	b	.L2
.L17:
	nop
.L4:
	adrp	x0, iInWord
	add	x0, x0, :lo12:iInWord
	ldr	w0, [x0]
	cmp	w0, 0
	beq	.L22
	adrp	x0, lWordCount
	add	x0, x0, :lo12:lWordCount
	ldr	x0, [x0]
	add	x1, x0, 1
	adrp	x0, lWordCount
	add	x0, x0, :lo12:lWordCount
	str	x1, [x0]
	b	.L13
.L22:
	nop
.L13:
	adrp	x0, lLineCount
	add	x0, x0, :lo12:lLineCount
	ldr	x1, [x0]
	adrp	x0, lWordCount
	add	x0, x0, :lo12:lWordCount
	ldr	x2, [x0]
	adrp	x0, lCharCount
	add	x0, x0, :lo12:lCharCount
	ldr	x0, [x0]
	mov	x3, x0
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	printf
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 8.5.0 20210514 (Red Hat 8.5.0-10)"
	.section	.note.GNU-stack,"",@progbits
