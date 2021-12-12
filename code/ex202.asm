assume cs:code,ds:data
data segment
	grade	dw 88,75,95,63,98,78,87,73,90,60
	rank 	dw 10 dup(?)
data ends

code segment
main	proc	far
start:
	push	ds
	sub 	ax,ax
	push	ax
	mov 	ax,data
	mov 	ds,ax
	mov 	di,10
	mov 	bx,0
loopa:
	mov		ax,grade[bx]
	mov		dx,0
	mov		cx,10
	lea		si,grade
next:
	cmp		ax,[si]
	jg 		no_count
	inc		dx
no_count:
	add 	si,2
	loop	next
	mov 	rank[bx],dx
	add 	bx,2
	dec 	di
	jne 	loopa
	ret
main endp
code ends
end start
