assume cs:code,ds:data,es:data
data segment para	'data'
	mess1	db	'stock number?',13,10,'$'
stoknin	label	byte
	max	db	3
	act	db	?
	stokn	db	3 dup (?)
	
	stoktab	db	'05','  Excavators'
			db	'08','  Lifters   '
			db  '09','  Presses   '
			db  '12','  Valves    '
			db  '23','  Processors'
			db	'27','  Pumps     '
			
	descrn 	db	14	dup (20h),13,10,'$'
	mess	db	'not in table','$'
data ends
code segment para 'code'
main	proc	far
	push	ds
	sub		ax, ax
	push	ax
	mov		ax, data
	mov		ds, ax
	mov		es, ax
start:
	lea		dx,mess1
	mov		ah,09
	int		21h
	lea		dx,stoknin
	mov		ah,0ah
	int		21h
	cmp		act,0
	je		exit
	mov		al,stokn
	mov		ah,stokn+1
	mov		cx,06
	lea		si,stoktab
a20:
	cmp		ax,WORD ptr[si]
	je		a30
	add		si, 14
	loop	a20
	lea		dx,mess
	mov		ah, 09
	int		21h
	jmp		exit
a30:
	mov		cx,07
	lea		di,descrn
	rep		movsw
	lea		dx,descrn
	mov		ah,09
	int		21h
	jmp		start
exit:
	ret
main	endp
code	ends
end		main