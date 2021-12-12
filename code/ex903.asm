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
; ��������ж�����
	; ��������ж�����
	mov		ah, 35h ; ȡ���ж���������
	mov		al, 09h ; ����
	int		21h
	; ����ڣ�
	mov		oldcs9,  es
	mov		oldip9,  bx

	; kbint�ж�����
	push    ds
	mov		dx, seg kbint
	mov		ds, dx
	mov		dx, offset kbint
	mov		al, 09h
	mov		ah, 25h
	int		21h
	pop		ds
; ʱ���ж�
	; ����ʱ���ж�
	mov		ah, 35h ; ȡ���ж���������
	mov		al, 1ch ; ʱ��
	int		21h
	; �������
	mov		save_lc, bx
	mov		save_lc+2, es

	; clint�ж�
	push    ds
	mov		dx, seg clint;
	mov		ds, dx
	mov		dx, offset clint
	mov		al, 1ch
	mov		ah, 25h
	int		21h
	pop		ds
	
	; ��ռ�����ʱ��
	in		al, 21h
	and		al, 11111100b
	out		21h, al        
	
first:   
    ; Videoģʽ
	mov     ah, 0
	mov     al, 3
	int     10h
	; ��ʾ�����ַ�
	mov     dx, offset prompt
	mov     ah, 9
	int     21h
	
	mov     si, 0
next:   
	mov     dx, saddr[si]
	mov     ah, 09h
	int     21h
	; ����ֵ
	mov     count, 0			 
	mov     sec, 0
	mov     min, 0
	mov     hours, 0
	sti
forever:
    ; �ȴ�����
	call    kbget
	; �ж��ַ�����
	test    kbflag, 80h
	jnz     endint
; ���ַ�������ʾ�ַ�������س�
	; ����ax
	push    ax
	call    dispchar
	pop     ax
	; �жϻس�
	cmp     al, 0dh
	jnz     forever
	mov     al, 0ah ; ���ûس�
	call    dispchar; ��ʾ�س�
	call    disptime; ��ʾʱ��
	; �س�
	lea     dx, crlf
	mov     ah, 09h
	int     21h
	; ������ɣ�
	add     si, 2
	cmp     si, 5*2
	jne     next
	jmp     first
endint: 
    cli
    ; ����ʱ���ж�����
	push    ds
	mov     dx, save_lc
	mov     ax, save_lc+2
	mov     ds, ax
	mov     al, 1ch
	mov     ah, 25h
	int     21h
	pop     ds
	; ���ü����ж�����
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

; ��ʱ���ӳ���
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

; ����ʱ��
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
; ��ʾ����ʱ��
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

; �����ж�
kbget	proc	near
	push   bx
	; ���ж�
	cli             
	; �жϻ������Ƿ����ַ�
	mov		bx, bufpt1 ; ָ���ƶ���������ͷ
	cmp		bx, bufpt2 ; �жϻ������Ƿ�Ϊ��
	jnz		kbget2
; �ж��Ƿ�������
	cmp		kbflag, 0 
	jnz		kbget3     ; �洢������
	; �ڿ��жϣ�����ѭ��
	sti                ; ���ж�
	pop     bx
	jmp     kbget
kbget2: 
	mov		al, [buffer+bx] ; ����ַ�ascii
	; �ж��Ƿ�buff��β
	inc		bx         
	cmp		bx, 16h          
	jc		kbget3   
	mov		bx, 0      ; ������buffͷ
kbget3: 
	mov		bufpt1, bx ; �洢������
	pop		bx
	sti               ; ����ʵ������û�У�����Ҳ��Ӱ�칦�ܣ����˸������ڿɶ��԰�
	ret 
kbget endp

; �����жϴ���
kbint  proc    far 
	push    bx  ; ����bx
	push    ax

	; �����ַ�
	in		al, 60h       
	push    ax          
	; ���ý����ӿ�
	in      al, 61h             
	or      al, 80h
	out     61h, al
	and     al, 7fh
	out     61h, al
	pop		ax      ; �ָ�ɨ����

    ; �ж���pressing or releasing
	test	al, 80h
	jnz		kbint2
	; ��� ���ַ�����al
	mov		bx, offset scantab
	xlat	scantab ;
	cmp		al, 0   
	jnz     kbint4
	mov		kbflag, 80h
	jmp		kbint2
kbint4: 
	; ��buffд���ַ�
	mov		bx, bufpt2   
	mov		[buffer+bx], al
	inc		bx
	cmp 	bx, 16h  ; ʵ�����ϵ�һ�� bug��û�м� h
	jc		kbint3               
	mov		bx, 0                  
kbint3: 
	cmp		bx, bufpt1                
	jz		kbint2                    
	mov		bufpt2, bx
kbint2:
	; �����жϣ�����
	cli
	mov		al, 20h ; �����ж�
	out		20h, al
	; �ָ�������
	pop		ax 
	pop		bx
	sti
	iret
kbint	endp

; ��ʾal���ַ�
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