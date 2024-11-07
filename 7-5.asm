;P158 问题7.9
assume cs:code,ds:data

data segment 
    db '1. display      '
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
data ends

code segment

start:
    mov ax,data
    mov ds,ax

    mov bx,0
    mov al,11011111b
    mov cx,4

s0: mov si,0
    push cx
    mov cx,4
    s:  and [bx][si].3,al
        inc si
        loop s
    add bx,10h
    pop cx
    loop s0

    mov ax,4c00h
    int 21h

code ends

end start