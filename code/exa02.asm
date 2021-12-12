; samp4_2
data	segment 
Pgsize			dw	?

buf_size    	db	80
s_buf			db	?
buf   			db	200 dup(?)

names			db	20 dup(?)
cur    	 		dw	?
read			dw	?
handle  		dw	?
buf_tmp			db  24*80 dup(?)
cur_tmp			dw	?
name_tmp		db  "t0m1p",0
handle_tmp		dw	?
mark			db  ?
mess_getname	db  0dh,0ah,"    Please input filename: $"
mess_err1		db  0ah,0dh,"    Illegal filename ! $"
mess_err2		db  0ah,0dh,"    File not found !$"
mess_err3		db  0ah,0dh,"    File read error !$"
mess_psize		db  0ah,0dh,"    Page Size : $"
mess_dele		db  0dh,0ah,"    The last page is deleted !"
crlf			db  0ah,0dh,"$"
mess_star		db  0ah,0dh,"*********************************************"
              	db  0ah,0dh,"$"
data	ends

code	segment
		assume ds:data, cs:code
main proc far
start:
	; ����ds
    push	ds
    sub		ax, ax
    ; ����ds
    push	ax
    mov		ax, data
    mov		ds, ax
    ; ���ö��볤��ҳ��С��
    mov		mark, 0
    mov		PgSize, 12
    mov		cur, 0
    mov		read, 0
    ; get filename
    call	getline      
    ; open a file
    call	openf
    or		ax, ax ; ��ax�ķ�����������־λ�ϣ�ZR->NZ���������jnz
    ; ��ʾ�ַ�
    jnz		display
    ; ���err mess2
    mov		dx, offset mess_err2
    mov		ah, 09h
    int		21h
    jmp		file_end
display:
    mov		cx, Pgsize ; ÿ��ִ��һ��
    mov		cur_tmp, 0
show_page:
    call	read_block ; ���ļ���200�ַ���buf
    or		ax, ax
    jnz		next2
    ; ��������
    mov		dx, offset mess_err3
    mov		ah, 09h
    int		21h; ���err mess
    jmp		file_end
next2:
	; ��ʾbuf��һ��
    call	show_and_reserve
    ; �ж��ĵ��Ƿ����
    or		bx, bx
    jz		file_end
    ; ��һҳ��ʾ������
    or		cx, cx
    jnz		show_page
    mov		dx, offset mess_star
    mov		ah, 09h
    int		21h
 	; �ȴ���ҳ
wait_space:
    mov		ah, 1
    int		21h
    ; �ж��Ƿ��ǿո�
    cmp		al, " "
    jnz		psize
    call	write_buf_tmp
    jmp		display
psize:
	; �ı�ҳ��С
    cmp		al,"p"
    jnz		delete
    call	write_buf_tmp
    call	change_psize
    jmp		stick
delete:
    cmp		al, "d"
    jnz		wait_space
    mov		mark, 1    ; ����ʱ�ļ�������Ҫд��
    ; ���mess del
    mov		dx, offset mess_dele
    mov		ah, 09h
    int		21h
; �жϿո�
stick:
    mov		ah, 1
    int		21h
    cmp		al, " "
    jnz		stick
    jmp		display
file_end:
    call	write_buf_tmp
    cmp		mark,0
    jz		ok
    call	write_tmp_back ; д��
ok:
    ret
main	endp

; �޸�ҳ��С
change_psize proc near
    push	ax
    push	bx
    push	cx
    push	dx
    ; ���mess psize
    mov		dx, offset mess_psize
    mov		ah, 09h
    int		21h
    ; �ȴ������ַ�
    mov		ah, 01
    int		21h
    ; �жϺϷ�
    cmp		al, 0dh
    jz		illeg
    ; �������ִ�С
    sub		al, "0"
    mov		cl, al
getp:
    ; �ȴ������ַ�
    mov		ah, 1
    int		21h
    ; �ж������Ƿ��������
    cmp		al, 0dh
    jz		pgot
    ; x=x*10+ch-'0'
    sub		al, "0"
    mov		dl, al
    mov		al, cl
    mov		cl, dl
    mov		bl, 10
    mul		bl
    add		cl, al
    jmp		getp
pgot:
	; ���0ah
    mov		dl, 0ah
    mov		ah, 2
    int		21h  
	; �ж�����Ϸ���
    cmp		cx, 0
    jle		illeg
    cmp		cx, 24
    jg		illeg
    mov		PgSize, cx
illeg:
	; ���Ϸ�
    mov		dl, 0ah
    mov		ah, 2         ; ʵ����pdf �� ʵ���鲻һ���ĵط�
    int		21h   
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    ret
change_psize endp

; open a file
openf proc near
    push	bx
    push	cx
    push	dx
    ; ��filename���ļ�
    mov		dx, offset names ; ���ļ���Ϊfilename
    mov		al, 2            ; R&W
    mov		ah, 3dh  
    int		21h
    ; �ݴ��ļ�������
    mov		handle, ax
    mov		ax, 0
    jc		quit        ; ����ʧ��
    ; �����ݴ��ļ�
    mov		dx, offset name_tmp
    mov		cx, 0
    mov		ah, 3ch
    int		21h
    mov		handle_tmp, ax
    jc		quit
    mov		ax, 1
quit:
    pop		dx
    pop		cx
    pop		bx
    ret
openf  endp

; �����ļ���
getline  proc near
    push	ax
    push	bx
    push	cx
    push	dx
    ;���messgetname
    mov		dx, offset mess_getname
    mov		ah, 09h
    int		21h
    ;�����ļ���
    mov		dx, offset buf_size
    mov		ah, 0ah
    int		21h
	; �������
    mov		dx, offset crlf
    mov		ah, 09h
    int		21h
 	; ���ֺ��油0
    mov		bl, s_buf
    mov		bh, 0
    mov		names[bx],0
    ; �ƶ���nameȥ
name_move:
	dec		bx
	mov		al, buf[bx]
	mov		names[bx], al
	jnz		name_move
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    ret
getline  endp

; ���ļ���200�ַ���buf
read_block	proc	near
	push	bx
	push	cx
	push	dx
	mov		ax, 1
	mov		cx, read
	cmp		cx, cur
	jnz		back  
	; �ٶ�200�ַ���buf
	mov		cx, 200        ; 200�ַ�
	mov		bx, handle     ; �ļ�������
	mov		dx, offset buf ; �浽buf
	mov		ah, 3fh
	int		21h
	; ����ɹ�����
	mov		cur, 0
	mov		read, ax
	mov		ax, 1
	jnc		back           ; �ɹ���
	mov		cur, 0 
	mov		ax, 0
back:
	pop		dx
	pop		cx
	pop		bx
	ret
read_block endp

; ��ʾһ��&���浽buf
show_and_reserve proc near
    push	ax
    push	dx
    mov		bx, cur
    mov		bp, cur_tmp
loop1:
	cmp		bx, read
    jl		lp
    jmp		exit            ; buf����ʾ��
lp:
    mov		dl, buf[bx]
    mov		ds:buf_tmp[bp], dl; ��buf�ᵽtmp
    ; �����±�
    inc		bx
    inc		cur
    inc		bp
    inc  	cur_tmp
	; �Ƿ�Ϊ��β��dosbox�����ã�
    cmp		dl, 1ah
    jz		exit_eof
	; ���dl
    mov		ah, 02     
    int		21h
    ; �ж��Ƿ�Ϊ����
    cmp		dl, 0ah
    jz		exit_ln
    jmp		loop1
exit_eof:
    mov		bx,0
exit_ln:
    dec		cx ; ��Ҫ���������--
exit:
    pop		dx
    pop		ax
    ret
show_and_reserve endp

; ��buf tmp������д����ʱ�ļ�
write_buf_tmp proc near
    push	ax
    push	bx
    push	cx
    push	dx
    ; д���ļ�
    mov		dx, offset buf_tmp
    mov		cx, cur_tmp
    mov		bx, handle_tmp
    mov		ah, 40h
    int		21h
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    ret
write_buf_tmp endp


write_tmp_back  proc near
    push	ax
    push	bx
    push	cx
    push	dx
; ����ʱ�ļ�����д��ԭ���ļ�
	; �ر���ʱ�ļ�
    mov		bx, handle_tmp
    mov		ah, 3eh
    int		21h
    ; �ر���ʽ�ļ�
    mov		bx, handle
    mov		ah, 3eh
    int		21h
    ; ����ʱ�ļ����ɶ���
    mov		dx, offset name_tmp
    mov		al, 0
    mov		ah, 3dh
    int		21h 
    mov		handle_tmp, ax
    ; ����ʽ�ļ�����д��
    mov		dx, offset names
    mov		al, 1
    mov		ah, 3dh
    int		21h
    mov		handle,ax
    
    mov		si, 1
wrt_back:
	; ��tmp��200�ַ�
    mov		bx, handle_tmp
    mov		ah, 3fh
    mov		cx, 200
    mov		dx, offset buf
    int		21h
    jc		wrt_end        ; ������

    mov		si, ax          ; �����±�
   	; д���ַ�
    mov		bx, handle
    mov		ah, 40h
    mov		cx, si           ; ʵ����pdf �� ʵ���鲻һ���ĵط�  
    mov		dx, offset buf
    int		21h
    ; ����buf�ﶼд������	
    or		si, si
    jnz		wrt_back 
    mov		ah, 3eh
    mov		bx, handle
    int		21h
wrt_end:
    pop		dx
    pop		cx
    pop		bx
    pop		ax
    ret
write_tmp_back endp

code	ends
		end	start