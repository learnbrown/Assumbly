;P154
assume cs:code,ds:data

data segment
    db 'ibm             '
    db 'dec             '
    db 'dos             '
    db 'vax             '
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
    mov cx,3
    s:  and [bx][si],al
        inc si
        loop s

    add bx,10h
    pop cx
    loop s0

    mov ax,4c00h
    int 21h

code ends

end start