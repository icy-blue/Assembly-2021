dataseg		segment
	freq	dw 262,294,330,262,262,294,330,262			;do re mi do do re mi do
			dw 330,349,392,330,349,392					;mi fa sol mi fa sol
			dw 392,440,392,349,330,262					;sol la sol fa mi do
			dw 392,440,392,349,330,262					;sol la sol fa mi do
			dw 294,196,262,294,196,262					;re so do re so do
	time	dw 2,2,2,2,2,2,2,2		;do re mi do do re mi do
			dw 2,2,4,2,2,4			;mi fa sol mi fa sol
			dw 1,1,1,1,2,2			;sol la sol fa mi do
			dw 1,1,1,1,2,2			;sol la sol fa mi do
			dw 2,2,4,2,2,4			;re so do re so do
dataseg		ends
;
prog	segment
main 	proc 	far
	assume cs:prog, ds:dataseg
start:
	push 	ds
	mov 	ax, 0
	push 	ax
	mov 	ax, dataseg
	mov 	ds, ax	
	lea 	di, freq		
	lea 	si, time		
	mov 	cx, 32d			
new_one:
	push	cx;���ڴ˴�����		
	call 	sound			
	add		di, 2;���ڴ˴�����	
	add		si, 2;���ڴ˴�����	
	pop		cx;���ڴ˴�����
	loop	new_one			
	mov		al, 48h;���ڴ˴�����	
	out		61h, al;���ڴ˴�����	
	mov		ah, 4ch
	ret
main 	endp
;
sound	proc	near
	in 		al, 61h
	mov 	bx, word ptr [si]	
	push 	ax
	mov 	ax, word ptr [di]
	mul		bx
	;;;
	;���ڴ˴���������Ϊ��ȷ�Ĵ���
	;;;
	mov		bx, 4
	div		bx
	mov		bx, ax
	pop		ax
	and 	al, 11111100b
sing:
	xor		al, 2;���ڴ˴�����	
	out 	61h, al			
	push	ax;���ڴ˴�����		
	;���ڴ˴�����	
	call 	widt			
	pop		ax;���ڴ˴�����	
	;���ڴ˴�����	
	mov 	cx, dx			; the number of loop instruction
waits:
	loop 	waits
	dec 	bx;���ڴ˴�����	
	jnz 	sing
	and 	al, 11111100b
	out 	61h, al
	ret
sound	endp
;
widt	proc	near
	mov 	ax, 2801
	;;;
	;���ڴ˴���������Ϊ��ȷ�Ĵ���
	;;;
	push	bx
	mov		bx, 50
	mul		bx
	div		WORD ptr[di]
	mov		dx, ax
	pop		bx
	ret
widt	endp
prog	ends
	end 	start