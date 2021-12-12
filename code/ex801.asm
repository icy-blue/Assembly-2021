read_c	equ 0h
key_rom	equ 16h
right   equ 4dh
left    equ 4bh
esc1	equ 1bh
left1	equ	5
left2	equ 10
left3	equ	15
left4	equ 30
right1	equ 5
right2	equ	50
right3	equ	15
right4	equ 70
bottom1	equ	18
bottom2	equ	15
bottom3	equ 22
bottom4	equ 65

data segment
	leftdata	dw 0f0ah
	rightdata	dw 0f32h
	bottomdata	dw 160fh
	state		db 0; 0: left, 1: right
data ends 

scroll macro ulrow, ulcol, lrrow, lrcol, att
	push	ax
	push	bx
	push	cx
	push	dx
	mov		ah, 6
	mov		al, 1
	mov		ch, ulrow
	mov		cl, ulcol
	mov		dh, lrrow
	mov		dl, lrcol
	mov		bh, att
	int		10h
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	endm

clear macro
	mov		ah, 6
	mov		al, 0
	mov		bh, 7
	mov		ch, 0
	mov		cl, 0
	mov		dh, 24
	mov		dl, 79
	int		10h
	endm

get_char macro
	push	ax
	mov		ah, read_c
	int		key_rom
	cmp		al, esc1
	jz		exit
	cmp		ah, left
	jz		changeleft
	cmp		ah, right
	jz		changeright

	cmp		state, 0
	jne		afterleft
	mov		cx, leftdata
	display	ch, cl, al
	inc		cx
	mov		leftdata, cx
	cmp		cl, left4
	jng		overall
	scroll	left1, left2, left3, left4, 70h
	mov		cl, left2
	mov		ch, left3
	mov		leftdata, cx
	jmp		overall
	endm

display macro x, y, w
	pos_curse	x, y
	push	ax
	push	bx
	push	cx
	mov		ah, 0ah
	mov		bh, 0
	mov		cx, 1
	int		10h
	pop		cx
	pop		bx
	pop		ax
	endm

pos_curse macro x, y
	push	ax
	push	bx
	push	dx
	mov		bh, 0
	mov		dh, x
	mov		dl, y
	mov		ah, 2
	int		10h
	pop		dx
	pop		bx
	pop		ax
	endm
	
video segment at 0b800h ;彩色图形适配器的显示缓冲区
	wd_buff label word
	v_buff  db    25 * 80 * 2 dup(?) ;以字和字节两种单位定义同一个存储区
	;字符显示以25*80的方式，每个字符分别由两个字符来表示其ASCII码和属性	
video ends

pro_nam segment
main proc far
	assume cs:pro_nam, es:video, ds:data
start:
	push	ds
	mov		ax, data
	mov		ds, ax
	push 	ax
	mov  	ax, video
	mov  	es, ax
	mov  	cx, 80 * 25
	clear
	pos_curse	18d, 15d
getchartag:
	get_char
afterleft:
	mov		cx, rightdata
	display	ch, cl, al
	inc		cx
	mov		rightdata, cx
	cmp		cl, right4
	jng		overall
	scroll	right1, right2, right3, right4, 70h
	mov		cl, right2
	mov		ch, right3
	mov		rightdata, cx
overall:
	mov		cx, bottomdata
	display ch, cl, al
	inc		cx
	mov		bottomdata, cx
	cmp		cl, bottom4
	jng		endtag
	scroll	bottom1, bottom2, bottom3, bottom4, 70h
	mov		cl, bottom2
	mov		ch, bottom3
	mov		bottomdata, cx
	jmp 	endtag
changeleft:
	mov		state, 0
	jmp		endtag
changeright:
	mov		state, 1
endtag:
	jmp		getchartag

exit:
    mov 	ax, 4c00h
    int 	21h
main endp
pro_nam ends
	end start
