data segment
    mess1	db		'Input name:', '$'
    mess2	db		'Input a telephone number:', '$'
    mess3	db		'Do you want a telephone number?(Y/N):', '$'
    mess4	db		'name', 17 dup(' '), 'tel.', 13, 10, '$' 
    mess5	db		'Not Found', 13, 10, '$'
    tel_tab	db		50 dup(29 dup(' '), '$')  ; 20+1+8+1
    tel_cnt db		0
    strinp	label	BYTE
    strmax	db		21
    strlen	db		?
    strdata	db		21 dup(?)
    endline db      13, 10, '$'
data ends
code segment
main proc far
    assume cs:code, ds:data, es:data
start:
    mov     ax, data
    mov     ds, ax
    mov     es, ax
m1:
    lea     dx, mess1
    mov     ah, 09h
    int     21h
    call    input_name
    call	stor_name
    lea     dx, mess2
    mov     ah, 09h
    int     21h
    call	inphone
m3:
    lea     dx, mess3
    mov     ah, 09h
    int     21h
    mov     ah, 01h
    int     21h
    lea     dx, endline
    mov     ah, 09h
    int     21h
    cmp     al, 'Y'
    je      yes
    cmp     al, 'N'
    jne     m3
	lea		dx, mess4
	mov		ah, 09h
	int		21h
	mov		ch, 0
	mov		cl, tel_cnt
	mov		bx, 0
print:	
	lea		dx, tel_tab
	add		dx, bx
	mov		ah, 09h
	int		21h
	add		bx, 30
    lea     dx, endline
    mov     ah, 09h
    int     21h
	loop	print
    mov     ax, 4c00h
    int     21h
yes:
    lea     dx, mess1
    mov     ah, 09h
    int     21h
    call    input_name
    mov     al, strlen
    cmp     al, 0
    jne     going
    jmp     m3
going:
    call    name_search
    jmp     yes
    ret
main endp

input_name proc near
	lea		dx, strinp
	mov		ah, 0ah
	int		21h
    lea     dx, endline
    mov     ah, 09h
    int     21h
    ret
input_name endp

stor_name proc near
    mov     ax, 0
    cmp     strlen, 0
;    je      m3
    je		sort_start
    mov     bx, data
    mov     ds, bx
    mov     al, tel_cnt
    mov     ah, 30
    mul     ah
    lea     di, tel_tab
    add     di, ax
    mov     es, bx
    lea     si, strdata
    mov     cl, strlen
    mov     ch, 0
    rep     movsb
    ret
stor_name endp

inphone proc near
    mov     bx, data
    mov     ds, bx
    mov     es, bx
	lea		dx, strinp
	mov		ah, 0ah
	int		21h
    lea     dx, endline
    mov     ah, 09h
    int     21h
    mov     al, tel_cnt
    mov     ah, 30
    mul     ah
    add     ax, 21
    lea     di, tel_tab
    add     di, ax
    lea     si, strdata
    mov     cl, strlen
    mov     ch, 0
    rep     movsb
    inc		tel_cnt
    jmp     m1
inphone endp

sort proc near
sort_start:
    mov     ax, data
    mov     ds, ax
    mov     es, ax
    mov     ax, 0
s1:
    mov     bx, ax
    inc		bx
    cmp     bl, tel_cnt
    jge		add_ax
    lea     si, tel_tab
    mov     cx, ax
	jcxz	s4

s2: add     si, 30
    loop    s2

s4:
    mov     cx, bx
    lea     di, tel_tab
    jcxz	s5

s3: add     di, 30
    loop    s3

s5:
    mov     cx, 20
    repe    cmpsb
    dec		si
    dec		di
    add		cx, 10
    mov     dl, byte ptr [si]
    cmp     dl, byte ptr [di]
    jle     swap_end
swap:
    mov     dl, [si]
    mov     dh, [di]
    mov     [si], dh
    mov     [di], dl
    inc		si
    inc		di
    loop    swap
swap_end:
    inc     bx
    cmp     bl, tel_cnt
    jb      s4
add_ax:
    inc     ax
    cmp     al, tel_cnt
    jb      s1
    jmp     m3
sort endp

name_search proc far
    mov     bx, data
    mov     ds, bx
    mov     es, bx
    mov     bx, 0
    mov     al, tel_cnt
    mov     ah, 0
next:
    lea     si, tel_tab
    add     si, bx
    lea     di, strdata
    mov     cl, strlen
    mov     ch, 0
    repe    cmpsb
    cmp     cx, 0
;    jne     bad
;    cmp     [si], ' '
    je      success
bad:
    add     bx, 30
    dec     ax
    jz      failed     
    jmp     next
success:
	lea		dx, mess4
	mov		ah, 09h
	int		21h
    lea     dx, tel_tab
    add     dx, bx
    mov     ah, 09h
    int     21h
    lea     dx, endline
    mov     ah, 09h
    int     21h
    ret
failed:
	lea		dx, mess5
	mov		ah, 09h
	int		21h
    ret
name_search endp
code ends
end start