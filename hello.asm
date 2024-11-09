assume cs:code

code segment

start:
    call cls

    mov ax,4c00h
    int 21h


cls:
    mov ax,00b800h
    mov ds,ax
    mov si,0
    mov cx,4000h
    s:
        mov word ptr [si],0
        add si,2
        loop s
    ret
    
code ends

end start