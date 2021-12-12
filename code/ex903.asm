; samp3.9

stack    segment  para  stack  'stack'
db       256	dup(0)
top      label    word  
stack    ends

data     segment  para  public  'data'
buffer     db     16h dup(0)
bufpt1     dw     0
bufpt2     dw     0
kbflag     db     0
prompt     db     '     * PLEASE PRACTISE TYPING *',0dh,0ah,'$'
scantab    db     0,0,'1234567890-=',8,0
		   db     'qwertyuiop[]',0dh,0
		   db     'asdfghjkl;',0,0,0,0
		   db     'zxcvbnm,./',0,0,0
		   db     ' ',0,0,0,0,0,0,0,0,0,0,0,0,0
		   db     '789-456+1230.'
even
oldcs9     dw     ?
oldip9     dw     ?
str1       db     'abcd efgh ijkl mnop qrst uvwx yz.'
 		   db     0dh,0ah,'$'
str2       db     'christmas is a time of joy and love.'
 		   db     0dh,0ah,'$'
str3       db     'store windows hold togs and gifts.'
 		   db     0dh,0ah,'$'
str4       db     'people send christmas cards and gifts.'
 		   db     0dh,0ah,'$'
str5       db     'santa wish all people peace on earth.'
crlf       db     0dh,0ah,'$'
colon      db     ':','$'
even
saddr      dw     str1,str2,str3,str4,str5
count      dw     0
sec        dw     0
min        dw     0
hours      dw     0
save_lc    dw  2  dup(?)
data       ends

code       segment
		   assume     cs:code,ds:data,es:data,ss:stack
main       proc    far
start:
	; stack pointer
	mov		ax, stack			 
	mov     ss, ax
	mov     sp, offset top
    ; save data segment
	push    ds			       
	sub     ax, ax
	push    ax
	; renew data segment and extra segment
	mov		ax, data				
	mov		ds, ax
	mov		es, ax
; 保存键盘中断向量
	; 保存键盘中断向量
	mov		ah, 35h ; 取出中断向量命令
	mov		al, 09h ; 键盘
	int		21h
	; 存入口？
	mov		oldcs9,  es
	mov		oldip9,  bx

	; kbint中断向量
	push    ds
	mov		dx, seg kbint
	mov		ds, dx
	mov		dx, offset kbint
	mov		al, 09h
	mov		ah, 25h
	int		21h
	pop		ds
; 时钟中断
	; 保存时钟中断
	mov		ah, 35h ; 取出中断向量命令
	mov		al, 1ch ; 时钟
	int		21h
	; 设置入口
	mov		save_lc, bx
	mov		save_lc+2, es

	; clint中断
	push    ds
	mov		dx, seg clint;
	mov		ds, dx
	mov		dx, offset clint
	mov		al, 1ch
	mov		ah, 25h
	int		21h
	pop		ds
	
	; 清空键盘与时钟
	in		al, 21h
	and		al, 11111100b
	out		21h, al        
	
first:   
    ; Video模式
	mov     ah, 0
	mov     al, 3
	int     10h
	; 显示键盘字符
	mov     dx, offset prompt
	mov     ah, 9
	int     21h
	
	mov     si, 0
next:   
	mov     dx, saddr[si]
	mov     ah, 09h
	int     21h
	; 赋初值
	mov     count, 0			 
	mov     sec, 0
	mov     min, 0
	mov     hours, 0
	sti
forever:
    ; 等待输入
	call    kbget
	; 判断字符输入
	test    kbflag, 80h
	jnz     endint
; 有字符输入显示字符，处理回车
	; 保存ax
	push    ax
	call    dispchar
	pop     ax
	; 判断回车
	cmp     al, 0dh
	jnz     forever
	mov     al, 0ah ; 设置回车
	call    dispchar; 显示回车
	call    disptime; 显示时间
	; 回车
	lea     dx, crlf
	mov     ah, 09h
	int     21h
	; 输入完成？
	add     si, 2
	cmp     si, 5*2
	jne     next
	jmp     first
endint: 
    cli
    ; 重置时钟中断向量
	push    ds
	mov     dx, save_lc
	mov     ax, save_lc+2
	mov     ds, ax
	mov     al, 1ch
	mov     ah, 25h
	int     21h
	pop     ds
	; 重置键盘中断向量
	push    ds
	mov     dx, oldip9
	mov     ax, oldcs9
	mov     ds, ax
	mov     al, 09h
	mov     ah, 25h
	int     21h
	pop     ds
	
	sti
	ret
main   endp

; 计时器子程序
clint  proc    near
	push    ds
	mov     bx, data
	mov     ds, bx
	lea     bx, count
	inc     word ptr[bx]
	cmp     word ptr[bx], 18
	jne     return
	call    inct
adj:  
	cmp     hours, 12
	jle     return
	sub     hours, 12
return:
	pop     ds
	sti
	iret
clint  endp

; 更新时间
inct   proc    near
	mov     word ptr[bx], 0
	add		bx, 2
	inc     word ptr[bx]
	cmp     word ptr[bx], 60
	jne     exit
	call    inct
exit:  
	ret
inct   endp

disptime	proc     near
; 显示打字时间
	mov     ax, min
	call    bindec
	
	mov     bx, 0
	mov     al, ':'
	mov     ah, 0eh
	int     10h
	
	mov     ax, sec
	call    bindec
	
	mov     bx, 0
	mov     al, ':'
	mov     ah, 0eh
	int     10h
	
	mov     bx, count
	mov     al, 55d
	mul     bl
	call    bindec
	
	ret
disptime	endp     

; binary to decimal
bindec     proc   near
	mov    cx, 100d
	call   decdiv
	mov    cx, 10d
	call   decdiv
	mov    cx, 1
	call   decdiv
	ret
bindec     endp

; subprog for binary to decimal
decdiv     proc   near
	mov    dx, 0
	div    cx
	mov    bx, 0
	add    al, 30h
	mov    ah, 0eh
	int    10h
	mov    ax, dx
	ret
decdiv    endp

; 键盘中断
kbget	proc	near
	push   bx
	; 关中断
	cli             
	; 判断缓冲区是否有字符
	mov		bx, bufpt1 ; 指针移动至缓冲区头
	cmp		bx, bufpt2 ; 判断缓冲区是否为空
	jnz		kbget2
; 判断是否有输入
	cmp		kbflag, 0 
	jnz		kbget3     ; 存储到变量
	; 在开中断，继续循环
	sti                ; 开中断
	pop     bx
	jmp     kbget
kbget2: 
	mov		al, [buffer+bx] ; 获得字符ascii
	; 判断是否到buff队尾
	inc		bx         
	cmp		bx, 16h          
	jc		kbget3   
	mov		bx, 0      ; 重置至buff头
kbget3: 
	mov		bufpt1, bx ; 存储到变量
	pop		bx
	sti               ; 这行实验书里没有，不加也不影响功能，加了更有助于可读性吧
	ret 
kbget endp

; 键盘中断处理
kbint  proc    far 
	push    bx  ; 保存bx
	push    ax

	; 读入字符
	in		al, 60h       
	push    ax          
	; 设置交互接口
	in      al, 61h             
	or      al, 80h
	out     61h, al
	and     al, 7fh
	out     61h, al
	pop		ax      ; 恢复扫描码

    ; 判断是pressing or releasing
	test	al, 80h
	jnz		kbint2
	; 查表 把字符放入al
	mov		bx, offset scantab
	xlat	scantab ;
	cmp		al, 0   
	jnz     kbint4
	mov		kbflag, 80h
	jmp		kbint2
kbint4: 
	; 向buff写入字符
	mov		bx, bufpt2   
	mov		[buffer+bx], al
	inc		bx
	cmp 	bx, 16h  ; 实验书上的一个 bug，没有加 h
	jc		kbint3               
	mov		bx, 0                  
kbint3: 
	cmp		bx, bufpt1                
	jz		kbint2                    
	mov		bufpt2, bx
kbint2:
	; 结束中断，返回
	cli
	mov		al, 20h ; 结束中断
	out		20h, al
	; 恢复上下文
	pop		ax 
	pop		bx
	sti
	iret
kbint	endp

; 显示al的字符
dispchar	proc	near	 
	push	bx				
	mov		bx, 0
	mov		ah, 0eh
	int		10h
	pop		bx
	ret
dispchar	endp

code	ends
		end	 start