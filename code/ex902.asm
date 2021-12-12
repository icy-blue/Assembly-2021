; �ִ�����ʾ����wspp
; ֧�ֹ�����������ƶ�

dseg	segment
kbd_buf	db	96	dup(' ') ; ���뻺��
cntl	db	16	dup(0)   ; ÿһ�е��ַ���
bufpt	dw	0            ; buffer ͷָ��
buftl	dw	0            ; buffer βָ��
colpt	db	0            ; ���������
rowpt	db	0            ; ���������
rowmx	dw	0            ; һ���ֵ����������
dseg	ends

; �ƶ����
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
	; ����extra segment Ϊ dseg��
    mov		ax, dseg
    mov		ds, ax
    mov		es, ax
    ; ��ʼ�����λ��
    mov		buftl, 0
    mov		colpt, 0
    mov		rowpt, 0
    mov		bufpt, 0
    mov		rowmx, 0
    ; ��ʼ����������
    mov		cx, length cntl; ���ÿ������򳤶�
    xor		al, al         ; al����
    lea		di, cntl
    cld
    rep		stosb
    ; ����
    mov		ah, 6      
    mov		al, 0
    mov		cx, 0
    mov		dh, 24       
    mov		dl, 79    
    mov		bh, 07
    int		10h
    ; ������
    curs    0,0          
read_k:
	; �����ַ�
    mov		ah, 0
    int		16h        
    cmp		al, 1bh  ; �ж��Ƿ�Ϊ�ո�
    jnz		arrow
    ; �������
    mov		ah, 4ch
    int		21h
arrow:
	; �ж����Ҽ�ͷ������ת
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
	; �����ַ�
    mov		bx, bufpt
    mov		cx, buftl
    cmp		bx, cx
    je		km
    ; �ƶ�buff
    lea		di, kbd_buf
    add		di, cx
    mov		si, di
    dec		si
    sub		cx, bx
    std
    rep		movsb
km:
    ; ���ַ�����buff
    mov		kbd_buf[bx], al
    inc		bufpt       ; ͷָ��++
    inc		buftl       ; βָ��++
    ; �жϻس�
    cmp		al, 0dh
    jnz		kn
    ; ��������ַ��������ƶ�
    lea		si, cntl
    add		si, rowmx
    inc		si
    mov		di, si
    inc		di
    mov		cx, rowmx
    sub		cl, rowpt
    std
    rep		movsb
    ; �����м�����
    mov		bl, rowpt    
    xor		bh, bh     
    mov		cl, colpt  
    mov		ch, cntl[bx]
    sub		ch, colpt
    mov		cntl[bx], cl
    mov		cntl[bx+1], ch
    ; ���Ͼ�
    mov		ax, rowmx   ; �ƶ�����
    mov		bh, 7       ; ��䵥Ԫ����
    mov		ch, rowpt   ; ������������
    mov		dh, 24      ; ������������
    mov		cl, 0       ; ������������
    mov		dl, 79      ; ������������
    mov		ah, 6
    int		10h
    ; ����������Ϣ
    inc		rowpt      
    inc		rowmx      
    mov		colpt, 0   
    jmp		short kp
kn:
	; ��������
    mov		bl, rowpt
    xor		bh, bh
    inc		cntl[bx]  ; ��ǰ�����ַ�����
    inc		colpt     ; ��ǰ��++
kp:  
    ; ��ʾbuff �ƶ���� ��ת��readk
	call	dispbf 
    curs	rowpt, colpt
    jmp		read_k
left_k:
; ��������������
	; �ڵ�0����
    cmp		colpt,0   
    jnz		k2    
    cmp		rowpt,0     
    jz		lret      ; ��겻����������
    ; �ص���һ��ĩβ
    dec		rowpt
    mov		al, rowpt
    lea		bx, cntl
    xlat	cntl
    mov		colpt, al
    jmp		k3
k2: 
	; ֱ��������
	dec		colpt
k3:  
	; buff����Ԫ�� ��λ���
	dec		bufpt
    curs	rowpt,colpt
lret:  
	jmp		read_k      ; ����һ���ַ�
right_k:
; �������Ҽ�����������С���β��
    ; �ж��Ƿ��β
    mov		bx, bufpt 
    cmp		bx, buftl
    je		rret       
    ; �س���
    inc		colpt
    cmp		kbd_buf[bx], 0dh       
    jnz		k4        
    ; ������һ��
    inc		rowpt       
    mov		colpt,0    
k4:  
	; ���ҵ������
	inc		bufpt       
    curs	rowpt,colpt 
rret:  
	jmp		read_k      ; ���ַ�

dispbf  proc      near
    mov		bx, 0
    mov		cx, 96
    curs	0, 0
disp:  
	; ��buff����ʾ�ַ�
	mov		al, kbd_buf[bx] ; ����ʾ�ַ�����al
    push	bx          
    mov		bx, 0700        ; ǰ��ɫ
    mov		ah, 0eh
    int		10h
    pop		bx
    ; �س�Ҫ��ʾ���з�
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