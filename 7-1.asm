;p145 大小写转换

assume cs:code,ds:data

data segment  
    db 'BaSiC'
    db 'MinIX'
data ends

code segment

start:
    mov ax,data
    mov ds,ax
    mov bx,0

    mov al,11011111b
    mov dl,00100000b
    mov cx,5

s:  and [bx],al
    or [bx+5],dl
    inc bx
    loop s

    mov ax,4c00h
    int 21h
code ends

end start