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
	; 保存ds
    push	ds
    sub		ax, ax
    ; 传入ds
    push	ax
    mov		ax, data
    mov		ds, ax
    ; 设置读入长度页大小等
    mov		mark, 0
    mov		PgSize, 12
    mov		cur, 0
    mov		read, 0
    ; get filename
    call	getline      
    ; open a file
    call	openf
    or		ax, ax ; 把ax的非零情况放入标志位上，ZR->NZ方便接下来jnz
    ; 显示字符
    jnz		display
    ; 输出err mess2
    mov		dx, offset mess_err2
    mov		ah, 09h
    int		21h
    jmp		file_end
display:
    mov		cx, Pgsize ; 每行执行一次
    mov		cur_tmp, 0
show_page:
    call	read_block ; 从文件读200字符到buf
    or		ax, ax
    jnz		next2
    ; 读不进来
    mov		dx, offset mess_err3
    mov		ah, 09h
    int		21h; 输出err mess
    jmp		file_end
next2:
	; 显示buf的一行
    call	show_and_reserve
    ; 判断文档是否结束
    or		bx, bx
    jz		file_end
    ; 这一页显示完了吗
    or		cx, cx
    jnz		show_page
    mov		dx, offset mess_star
    mov		ah, 09h
    int		21h
 	; 等待翻页
wait_space:
    mov		ah, 1
    int		21h
    ; 判断是否是空格
    cmp		al, " "
    jnz		psize
    call	write_buf_tmp
    jmp		display
psize:
	; 改变页大小
    cmp		al,"p"
    jnz		delete
    call	write_buf_tmp
    call	change_psize
    jmp		stick
delete:
    cmp		al, "d"
    jnz		wait_space
    mov		mark, 1    ; 有临时文件，保存要写入
    ; 输出mess del
    mov		dx, offset mess_dele
    mov		ah, 09h
    int		21h
; 判断空格
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
    call	write_tmp_back ; 写回
ok:
    ret
main	endp

; 修改页大小
change_psize proc near
    push	ax
    push	bx
    push	cx
    push	dx
    ; 输出mess psize
    mov		dx, offset mess_psize
    mov		ah, 09h
    int		21h
    ; 等待输入字符
    mov		ah, 01
    int		21h
    ; 判断合法
    cmp		al, 0dh
    jz		illeg
    ; 计算数字大小
    sub		al, "0"
    mov		cl, al
getp:
    ; 等待输入字符
    mov		ah, 1
    int		21h
    ; 判断数字是否输入完毕
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
	; 输出0ah
    mov		dl, 0ah
    mov		ah, 2
    int		21h  
	; 判断输入合法性
    cmp		cx, 0
    jle		illeg
    cmp		cx, 24
    jg		illeg
    mov		PgSize, cx
illeg:
	; 不合法
    mov		dl, 0ah
    mov		ah, 2         ; 实验书pdf 和 实体书不一样的地方
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
    ; 打开filename的文件
    mov		dx, offset names ; 打开文件名为filename
    mov		al, 2            ; R&W
    mov		ah, 3dh  
    int		21h
    ; 暂存文件描述符
    mov		handle, ax
    mov		ax, 0
    jc		quit        ; 访问失败
    ; 设置暂存文件
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

; 读入文件名
getline  proc near
    push	ax
    push	bx
    push	cx
    push	dx
    ;输出messgetname
    mov		dx, offset mess_getname
    mov		ah, 09h
    int		21h
    ;读入文件名
    mov		dx, offset buf_size
    mov		ah, 0ah
    int		21h
	; 输出换行
    mov		dx, offset crlf
    mov		ah, 09h
    int		21h
 	; 名字后面补0
    mov		bl, s_buf
    mov		bh, 0
    mov		names[bx],0
    ; 移动到name去
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

; 从文件读200字符到buf
read_block	proc	near
	push	bx
	push	cx
	push	dx
	mov		ax, 1
	mov		cx, read
	cmp		cx, cur
	jnz		back  
	; 再读200字符到buf
	mov		cx, 200        ; 200字符
	mov		bx, handle     ; 文件描述符
	mov		dx, offset buf ; 存到buf
	mov		ah, 3fh
	int		21h
	; 读入成功了吗
	mov		cur, 0
	mov		read, ax
	mov		ax, 1
	jnc		back           ; 成功了
	mov		cur, 0 
	mov		ax, 0
back:
	pop		dx
	pop		cx
	pop		bx
	ret
read_block endp

; 显示一行&保存到buf
show_and_reserve proc near
    push	ax
    push	dx
    mov		bx, cur
    mov		bp, cur_tmp
loop1:
	cmp		bx, read
    jl		lp
    jmp		exit            ; buf都显示了
lp:
    mov		dl, buf[bx]
    mov		ds:buf_tmp[bp], dl; 将buf搬到tmp
    ; 更新下标
    inc		bx
    inc		cur
    inc		bp
    inc  	cur_tmp
	; 是否为结尾（dosbox不适用）
    cmp		dl, 1ah
    jz		exit_eof
	; 输出dl
    mov		ah, 02     
    int		21h
    ; 判断是否为换行
    cmp		dl, 0ah
    jz		exit_ln
    jmp		loop1
exit_eof:
    mov		bx,0
exit_ln:
    dec		cx ; 还要输出的行数--
exit:
    pop		dx
    pop		ax
    ret
show_and_reserve endp

; 将buf tmp的内容写入临时文件
write_buf_tmp proc near
    push	ax
    push	bx
    push	cx
    push	dx
    ; 写入文件
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
; 将临时文件内容写入原来文件
	; 关闭临时文件
    mov		bx, handle_tmp
    mov		ah, 3eh
    int		21h
    ; 关闭正式文件
    mov		bx, handle
    mov		ah, 3eh
    int		21h
    ; 打开临时文件（可读）
    mov		dx, offset name_tmp
    mov		al, 0
    mov		ah, 3dh
    int		21h 
    mov		handle_tmp, ax
    ; 打开正式文件（可写）
    mov		dx, offset names
    mov		al, 1
    mov		ah, 3dh
    int		21h
    mov		handle,ax
    
    mov		si, 1
wrt_back:
	; 从tmp读200字符
    mov		bx, handle_tmp
    mov		ah, 3fh
    mov		cx, 200
    mov		dx, offset buf
    int		21h
    jc		wrt_end        ; 读完了

    mov		si, ax          ; 设置下标
   	; 写入字符
    mov		bx, handle
    mov		ah, 40h
    mov		cx, si           ; 实验书pdf 和 实体书不一样的地方  
    mov		dx, offset buf
    int		21h
    ; 看看buf里都写回了吗	
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