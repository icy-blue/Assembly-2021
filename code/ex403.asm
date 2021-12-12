assume cs:code,ds:data
data  segment 
counter db  62 dup(0) 

sentence  label  byte
    max1    db  150
    act1    db  ? 
    sen     db  150 dup(?)
data  ends

code  segment para

main    proc    far

    mov ax,data
    mov ds,ax
    lea dx,sentence
    mov ax,0a00h
    int 21h
    mov al, act1 
    sub al,1;
    sub ah,ah
    mov bp,ax

loopa:
    mov al,sen[bp]
    sub bh,bh
    mov bl,al
    dec bp
    cmp bx,97;a
    jae is_lower_letter
    cmp bx,65;A
    jae is_upper_letter
    cmp bx,48;0
    jae is_digit
    jmp loopb

is_lower_letter:
    cmp bx,122
    jg  loopb
    sub bx,97
    inc counter[bx]
    jmp loopb

is_upper_letter:
    cmp bx,90
    jg  loopb
    sub bx,65
    add bx,26
    inc counter[bx]
    jmp loopb

is_digit:
    cmp bx,57
    jg  loopb
    sub bx,48
    add bx,52
    inc counter[bx]
    jmp loopb

loopb:
    cmp bp,0
    jge loopa
    
exit:
    mov ax, 4c00h
    int 21h
main    endp
code  ends
end  main
