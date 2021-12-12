assume cs: code
code segment 
main proc far
start:
    org     100h
    push	ds
    sub  	ax, ax
    push 	ax
    mov     cx,50d
new_shot:
    push    cx
    call    shoot
    mov     cx,4000h
silent:
    loop    silent
    pop     cx
    loop    new_shot
    mov     al,48h
    out     61h,al
    ret
main endp

shoot proc near
    mov     dx,140h;000101000000
    mov     bx,200h
    in      al,61h
    and     al,11111100b
sound:
    xor     al,2
    out     61h,al
    mov 	ax, 1fffh
    mov 	dx, 41H
    out 	dx, ax
    in  	ax, dx   
    add 	dx,3974h
    mov 	dx,ax
    mov 	cl,3
    ror 	dx,cl
    mov 	cx,dx
    and     cx,1ffh
    or      cx,10
waitt:   
    loop    waitt
    dec     bx
    jnz     sound
    and     al,11111100b
    out     61h,al
    ret
shoot endp
code ends
end start
