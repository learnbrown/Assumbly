;P152
assume cs:code,ds:data

data segment
    db '1. file         '
    db '2. edit         '
    db '3. search       '
    db '4. view         '
    db '5. options      '
    db '6. help         '
data ends

code segment

start:
    mov ax,data
    mov ds,ax

    mov bx,0
    mov cx,6

    mov al,11011111b

s:  and 3[bx],al
    add bx,10h
    loop s

    mov ax,4c00h
    int 21h
code ends

end start