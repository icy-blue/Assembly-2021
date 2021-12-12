assume cs:code,ds:data,es:data
data segment
	string1 db 'Hello, world!'
	string2 db 'Hello, world!'
	message1 db 'match!',13,10,'$'
	message2 db 'not match!',13,10,'$'
data ends
code segment
main	proc	far
start:
	push	ds
	sub		ax, ax
	push	ax
	mov		ax, data
	mov		ds, ax
	mov		es, ax
	lea		si, string1
	lea 	di, string2
	cld
	mov		cx, 13
	repz	cmpsb
	jz		match
	lea		dx, message2
	jmp		short disp
match:
	lea		dx, message1
disp:
	mov		ah, 09
	int 	21h
	ret
main	endp
code	ends
end		main