assume cs:code,ds:data

data segment
    db 'Welcome to masm!'
    db 16 dup(0)
data ends

code segment
main:
    mov ax,data
    mov ds,ax
    inc ax
    mov es,ax

    mov si,0
    mov di,0

    mov cx,8
    cld
    rep movsw

    mov ax,4c00h
    int 21h

code ends

end main