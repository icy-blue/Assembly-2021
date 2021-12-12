read_c	equ 0h
key_rom	equ 16h
up      equ 48h
down    equ 50h
right   equ 4dh
left    equ 4bh
block   equ 0dbh
esc1	equ 1bh

video segment at 0b800h ;彩色图形适配器的显示缓冲区
	wd_buff label word
	v_buff  db    25 * 80 * 2 dup(?) ;以字和字节两种单位定义同一个存储区
	;字符显示以25*80的方式，每个字符分别由两个字符来表示其ASCII码和属性	
video ends

pro_nam segment
main proc far
	assume cs:pro_nam, es:video
start:
	push	ds
	sub  	ax, ax
	push 	ax
	mov  	ax, video
	mov  	es, ax
	mov  	cx, 80 * 25
	mov  	bx, 0
clear:
	mov  	es:[wd_buff+bx], 0700h ;07 是正常属性代码 00是ASCII码
	inc  	bx
	inc  	bx			;因为每一个都是字单元，所以bx+2
	loop 	clear
	;光标初始位置
	mov  	ch, 12d 	;初始行值
	mov  	cl, 40d 	;初始列值
get_char:
	mov  	ah, read_c
	int  	key_rom   ;int 16h 中断的0号功能调用
	;唤起键盘I/O模块,从键盘读入字符送AL寄存器
	cmp  	al, esc1
	jz  	exit
	mov		al, ah
	cmp		al, up
	jnz		not_up
	dec		ch
not_up:
	cmp		al, down
	jnz		not_down
	inc  	ch
not_down:
	cmp  	al, right
	jnz  	not_right
	inc  	cl
not_right:
	cmp  	al, left
	jnz  	lite_it
	dec  	cl
lite_it:
	mov  	al, 160d
	mul  	ch		;行号 * 80 * 2
	mov  	bl, cl
	rol  	bl, 1
	mov  	bh, 0	;列号 * 2
	add  	bx, ax ;将行号和列号转换成对应的显存坐标
	mov  	al, block
	mov  	es:[v_buff+bx], al		;在屏幕上显示正常属性的方块
	jmp  	get_char
exit:
	ret
main endp
pro_nam ends
	end start
