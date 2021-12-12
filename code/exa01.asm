data    segment 
	Pgsize          dw  ?

	buf_size        db  80
	s_buf           db  ?
	buf             db  200 dup(?)

	cur             dw  ?
	handle          dw  ?
	read		dw	?	;
	mess_getname    db  0dh, 0ah, "    Please input filename: $"
	mess_err1       db  0ah, 0dh, "    Illegal filename ! $"
	mess_err2       db  0ah, 0dh, "    File not found !$"
	mess_err3       db  0ah, 0dh, "    File read error !$"
	mess_psize      db  0ah, 0dh, "    Page Size : $"
	crlf            db  0ah, 0dh, "$"
	mess_star       db  0ah, 0dh, "*********************************************"
    	            db  0ah, 0dh, "$"
data    ends

code	segment
	assume ds:data, cs:code
main	proc	far
start:
	push	ds
	sub		ax, ax
	push	ax
	mov		ax, data
	mov		ds, ax
	
	mov		Pgsize, 12
	mov		cur, 200
	mov		read, 200
	call	getline
	call	openf
	or		ax, ax
	jnz		display
	mov		dx, offset mess_err2
	mov		ah, 09h
	int		21h
	
	jmp		file__end
display:
	mov		cx, Pgsize
show_page:
	call	read_block
	or		ax, ax
	jnz		next2
	
	mov		dx, offset mess_err3
	mov		ah, 09h
	int		21h
	jmp		file__end
next2:
	call	show_block
	or		bx, bx
	jz		file__end
	or		cx, cx
	jnz		show_page
	mov		dx, offset mess_star
	mov		ah, 09h
	int		21h
wait_space:
	mov		ah, 1
	int		21h
	cmp		al, " "
	jnz		psize
	jmp		display
psize:
	cmp		al, "p"
	jnz		wait_space
	call	change_psize
here:
	mov		ah, 1
	int		21h
	cmp		al, " "
	jnz		here
	jmp		display
file__end:
	ret
main	endp

change_psize	proc	near
	push	ax
	push	bx
	push	cx
	push	dx
	mov		dx, offset mess_psize
	mov		ah, 09h
	int		21h
	
	mov		ah, 01
	int		21h
	cmp		al, 0dh
	jz		illeg
	sub		al, "0"
	mov		cl, al
getp:
	mov		ah, 1
	int		21h
	cmp		al, 0dh
	jz		pgot
	sub		al, "0"
	mov		dl, al
	mov		al, cl
	mov		cl, dl
	
	mov		bl, 10
	mul		bl
	add		cl, al
	jmp		getp
pgot:
	mov		dl, 0ah
	mov		ah, 2
	int		21h
	
	cmp		cx, 0
	jle		illeg
	cmp		cx, 24
	jg		illeg
	mov		Pgsize, cx
illeg:
	mov		dl, 0ah
	mov		ah, 2
	int		21h
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret
change_psize	endp

openf	proc	near
	push	bx
	push	cx
	push	dx
	mov		dx, offset	buf
	mov		al, 0
	mov		ah, 3dh
	int		21h
	mov		handle, ax
	mov		ax, 1
	jnc		ok
	mov		ax, 0
ok:
	pop		dx
	pop		cx
	pop		bx
	ret
openf	endp

getline	proc	near
	push	ax
	push	bx
	push	cx
	push	dx
	mov		dx, offset mess_getname
	mov		ah, 09h
	int		21h
	
	mov		dx, offset buf_size
	mov		ah, 0ah
	int		21h
	
	mov		dx, offset crlf
	mov		ah, 09h
	int		21h
	
	mov		bl, s_buf
	mov		bh, 0
	mov		[buf+bx], 0
	
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret
getline	endp

read_block	proc	near
	push	bx
	push	cx
	push	dx
	mov		cx, read
	cmp		cx, cur
	jnz		back
	mov		cx, 200
	mov		bx, handle
	mov		dx, offset buf
	mov		ah, 3fh
	int		21h
	mov		read, ax
	mov		cur, 0
	mov		ax, 1
	jnc		back
	mov		cur, 0
	mov		ax, 0
back:
	pop		dx
	pop		cx
	pop		bx
	ret
read_block	endp

show_block	proc	near
	push	ax
	push	dx
	mov		bx, cur
loop1:
	cmp		bx, read
	jl		lp
	jmp		exit_
lp:
	mov		dl, buf[bx]
	cmp		dl, 1ah
	jz		exit_eof
	inc		bx
	inc		cur
	mov		ah, 02
	int		21h
	cmp		dl, 0ah
	jz		exit_ln
	
	jmp		loop1
exit_eof:
	mov		bx, 0
exit_ln:
	dec		cx
exit_:
	pop		dx
	pop		ax
	ret
show_block	endp

code	ends
end		start