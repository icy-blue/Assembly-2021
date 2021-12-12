; 字处理演示程序wspp
; 支持光标插入和左右移动

dseg	segment
kbd_buf	db	96	dup(' ') ; 输入缓冲
cntl	db	16	dup(0)   ; 每一行的字符数
bufpt	dw	0            ; buffer 头指针
buftl	dw	0            ; buffer 尾指针
colpt	db	0            ; 光标所在列
rowpt	db	0            ; 光标所在行
rowmx	dw	0            ; 一个字的最大输入行
dseg	ends

; 移动光标
curs	macro	row,col
	mov		dh,	row
    mov		dl,	col
    mov		bh,	0
    mov		ah,	2
    int		10h
endm

cseg	segment
main	proc	far
		assume	cs:cseg,ds:dseg,es:dseg
start:
	; 设置extra segment 为 dseg段
    mov		ax, dseg
    mov		ds, ax
    mov		es, ax
    ; 初始化光标位置
    mov		buftl, 0
    mov		colpt, 0
    mov		rowpt, 0
    mov		bufpt, 0
    mov		rowmx, 0
    ; 初始化控制区域
    mov		cx, length cntl; 设置控制区域长度
    xor		al, al         ; al清零
    lea		di, cntl
    cld
    rep		stosb
    ; 清屏
    mov		ah, 6      
    mov		al, 0
    mov		cx, 0
    mov		dh, 24       
    mov		dl, 79    
    mov		bh, 07
    int		10h
    ; 光标归零
    curs    0,0          
read_k:
	; 读入字符
    mov		ah, 0
    int		16h        
    cmp		al, 1bh  ; 判断是否为空格
    jnz		arrow
    ; 程序结束
    mov		ah, 4ch
    int		21h
arrow:
	; 判断左右箭头，并跳转
    cmp		ah, 4bh    
    jz		left
    cmp		ah, 4dh    
    jz		right
inst:  
	jmp		ins_k
left:  
	jmp		left_k
right:
	jmp		right_k
ins_k: 
	; 插入字符
    mov		bx, bufpt
    mov		cx, buftl
    cmp		bx, cx
    je		km
    ; 移动buff
    lea		di, kbd_buf
    add		di, cx
    mov		si, di
    dec		si
    sub		cx, bx
    std
    rep		movsb
km:
    ; 将字符放入buff
    mov		kbd_buf[bx], al
    inc		bufpt       ; 头指针++
    inc		buftl       ; 尾指针++
    ; 判断回车
    cmp		al, 0dh
    jnz		kn
    ; 将后面的字符行向下移动
    lea		si, cntl
    add		si, rowmx
    inc		si
    mov		di, si
    inc		di
    mov		cx, rowmx
    sub		cl, rowpt
    std
    rep		movsb
    ; 调整行计数器
    mov		bl, rowpt    
    xor		bh, bh     
    mov		cl, colpt  
    mov		ch, cntl[bx]
    sub		ch, colpt
    mov		cntl[bx], cl
    mov		cntl[bx+1], ch
    ; “上卷”
    mov		ax, rowmx   ; 移动行数
    mov		bh, 7       ; 填充单元属性
    mov		ch, rowpt   ; 矩形最上行数
    mov		dh, 24      ; 矩阵最下行数
    mov		cl, 0       ; 矩阵最左列数
    mov		dl, 79      ; 矩阵最有列数
    mov		ah, 6
    int		10h
    ; 调整坐标信息
    inc		rowpt      
    inc		rowmx      
    mov		colpt, 0   
    jmp		short kp
kn:
	; 进行输入
    mov		bl, rowpt
    xor		bh, bh
    inc		cntl[bx]  ; 当前行数字符增加
    inc		colpt     ; 当前列++
kp:  
    ; 显示buff 移动光标 跳转到readk
	call	dispbf 
    curs	rowpt, colpt
    jmp		read_k
left_k:
; 处理按下左键的情况
	; 在第0列吗
    cmp		colpt,0   
    jnz		k2    
    cmp		rowpt,0     
    jz		lret      ; 光标不能再向左了
    ; 回到上一行末尾
    dec		rowpt
    mov		al, rowpt
    lea		bx, cntl
    xlat	cntl
    mov		colpt, al
    jmp		k3
k2: 
	; 直接向左移
	dec		colpt
k3:  
	; buff弹出元素 定位光标
	dec		bufpt
    curs	rowpt,colpt
lret:  
	jmp		read_k      ; 读下一个字符
right_k:
; 处理按下右键的情况（换行、结尾）
    ; 判断是否结尾
    mov		bx, bufpt 
    cmp		bx, buftl
    je		rret       
    ; 回车？
    inc		colpt
    cmp		kbd_buf[bx], 0dh       
    jnz		k4        
    ; 进入下一行
    inc		rowpt       
    mov		colpt,0    
k4:  
	; 向右调整光标
	inc		bufpt       
    curs	rowpt,colpt 
rret:  
	jmp		read_k      ; 读字符

dispbf  proc      near
    mov		bx, 0
    mov		cx, 96
    curs	0, 0
disp:  
	; 从buff中显示字符
	mov		al, kbd_buf[bx] ; 把显示字符放入al
    push	bx          
    mov		bx, 0700        ; 前景色
    mov		ah, 0eh
    int		10h
    pop		bx
    ; 回车要显示换行符
    cmp		al, 0dh
    jnz		kk
    mov		al, 0ah
    mov		ah, 0eh
    int		10h
kk:
	inc		bx
    loop	disp
    ret
dispbf	endp

main	endp
cseg	ends
    	end	start