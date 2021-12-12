read_c	equ 0h
key_rom	equ 16h
up      equ 48h
down    equ 50h
right   equ 4dh
left    equ 4bh
block   equ 0dbh
esc1	equ 1bh

video segment at 0b800h ;��ɫͼ������������ʾ������
	wd_buff label word
	v_buff  db    25 * 80 * 2 dup(?) ;���ֺ��ֽ����ֵ�λ����ͬһ���洢��
	;�ַ���ʾ��25*80�ķ�ʽ��ÿ���ַ��ֱ��������ַ�����ʾ��ASCII�������	
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
	mov  	es:[wd_buff+bx], 0700h ;07 ���������Դ��� 00��ASCII��
	inc  	bx
	inc  	bx			;��Ϊÿһ�������ֵ�Ԫ������bx+2
	loop 	clear
	;����ʼλ��
	mov  	ch, 12d 	;��ʼ��ֵ
	mov  	cl, 40d 	;��ʼ��ֵ
get_char:
	mov  	ah, read_c
	int  	key_rom   ;int 16h �жϵ�0�Ź��ܵ���
	;�������I/Oģ��,�Ӽ��̶����ַ���AL�Ĵ���
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
	mul  	ch		;�к� * 80 * 2
	mov  	bl, cl
	rol  	bl, 1
	mov  	bh, 0	;�к� * 2
	add  	bx, ax ;���кź��к�ת���ɶ�Ӧ���Դ�����
	mov  	al, block
	mov  	es:[v_buff+bx], al		;����Ļ����ʾ�������Եķ���
	jmp  	get_char
exit:
	ret
main endp
pro_nam ends
	end start
