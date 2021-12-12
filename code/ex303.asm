assume cs:code,ds:data
data  segment 
counter db  62 dup(0) 

sentence	label	byte
    max1    db	150
    act1    db	?
    sen     db  150 dup(?)

keyword		label	byte
	max2	db	150
	act2	db	?
	kw		db	150 dup(?)

kwmess		db	'Enter keyword:$'
sentmess	db	13, 10, 'Enter sentence:$'
matched		db  13, 10, 'Match at location:',?,?,'H of the sentence.$'
unmatched	db	13, 10, 'No match.$'
number		db	'0123456789ABCDEF'
data  ends

code  segment para
main    proc    far
	mov ax,	data
    mov ds, ax
    mov es,	ax
    lea dx, kwmess
    mov ah, 09
    int 21h
    lea dx, keyword
    mov ah, 0ah
    int 21h
    cmp act2,0
    je	exit

restart:
	lea dx, sentmess
    mov ah, 09
    int 21h
    lea dx, sentence
    mov ah, 0ah
    int 21h
    cmp	act1, 0
    je	exit

	mov cl, act1
	mov ch, 0
	mov bx, 0
	cmp cl, act2
	jl	unmatch

s1: push	cx
	push	bx
	mov		cl,act2
	mov		bp,0
s2:	mov		al,kw[bp]
	cmp		al,sen[bx]
	jne		s3
	inc		bp
	inc		bx
	loop	s2
	jmp		match
s3:	pop		bx
	pop		cx
	inc		bx
	loop	s1
unmatch: 
	lea dx, unmatched
    mov ah, 09
    int 21h
	jmp	restart
match:
	pop ax
	mov	bx, 16
	div	bl
	sub bx, bx
	mov bl, al
	mov al, number[bx]
	mov bl, ah
	mov ah, number[bx]
	mov matched[20],al
	mov matched[21],ah
	lea dx, matched
    mov ah, 09
    int 21h
	jmp restart
exit:
    mov ax,4c00h
    int 21h
main    endp
code  ends
end  main
