datarea segment
	message1	db	'N=? ','$'
	message2	db	'What is the name of spindle X ? '
				db	'$'
	message3	db	'What is the name of spindle Y ? '
				db	'$'
	message4	db	'What is the name of spindle Z ? '
				db	'$'
	flag		dw	0
	constant	dw	10000,1000,100,10,1
datarea ends

prognam	segment
main	proc	far
	assume	cs:prognam,ds:datarea
start:
	push	ds
	sub		ax,ax
	push	ax
	
	mov		ax,datarea
	mov		ds,ax
	
	lea		dx,message1
	mov		ah,09h
	int		21h
	call	decibin	;读入n到bx
	;call	crlf
	
	cmp		bx,0	;n=0 退出
	jz		exit
	
	lea		dx,message2
	mov		ah,09h
	int		21h
	mov		ah,01h	;读入x的名字到cx
	int		21h
	mov		ah,0
	mov		cx,ax
	call	crlf
	
	lea		dx,message3
	mov		ah,09h
	int		21h
	mov		ah,01h	;读入y的名字到si
	int		21h
	mov		ah,0
	mov		si,ax
	call	crlf
	
	lea		dx,message4
	mov		ah,09h
	int		21h
	mov		ah,01h	;读入z的名字到di
	int		21h
	mov		ah,0
	mov		di,ax
	call	crlf
	
	call	hanoi
	
exit:	ret
main	endp

hanoi	proc	near
	cmp		bx,1	;n=1
	je		basis
	call	save	;存储n,x,y,z
	dec		bx
	xchg	si,di
	call	hanoi	;call hanoi(n-1,x,y,z)
	call	restor	;恢复(n,x,y,z)
	call	print	;打印xnz
	dec		bx
	xchg	cx,si
	call	hanoi
	jmp		return
basis:
	call	print
return:
	ret
hanoi	endp

print	proc	near
	mov		dx,cx	;打印x
	mov		ah,02h
	int		21h
	call	binidec	;打印n
	mov		dx,di	;打印z
	mov		ah,02h
	int		21h
	call	crlf	;跳转下一行
	ret
print endp

save	proc	near
	pop		bp
	push	bx
	push	cx
		push	si
		push	di
		push	bp
		ret
	save	endp
	
	restor	proc	near
		pop		bp
		pop		di
		pop		si
		pop		cx
		pop		bx
		push	bp
		ret
	restor	endp
	
	decibin	proc	near	;从键盘读入值存成ascll
		mov		bx,0	;清除bx的数值
	newchar:
		mov		ah,1	;键盘输入
		int 	21h
		sub		al,30h	;ascll to binary
		jl		exit1
		cmp		al,9d
		jg		exit1
		cbw				;al中的byte变成ax中的byte
		xchg	ax,bx
		mov		cx,10d
		mul		cx		;乘10
		xchg	ax,bx
		add		bx,ax	;add digit to number
		jmp		newchar	;下一个数字
	exit1:
		ret
	decibin	endp
	
	binidec	proc	near	;将bx中的二进制数转化为十进制
		push	bx
		push	cx
		push	si
		push	di
		mov		flag,0
		mov		cx,5
		lea		si,constant
	dec_div:
		mov		ax,bx
		mov		dx,0
		div		WORD ptr[si]
		mov		bx,dx
		mov		dl,al
		cmp		flag,0
		jnz		print1
		cmp		dl,0
		je		skip
		mov		flag,1
	print1:
		add		dl,30h	;转ascll
		mov		ah,02h
		int		21h
	skip:
		add		si,2
		loop	dec_div
		pop		di
		pop		si
		pop		cx
		pop		bx
		ret
	binidec	endp
	
	crlf	proc	near
		mov		dl,0ah	;填充新的行
		mov		ah,02h
		int		21h
		mov		dl,0dh	;carriage return
		mov		ah,02h
		int		21h
		ret
	crlf	endp
prognam	ends
end	start