;P188实验9
assume cs:code,ds:data

data segment
    db 'welcome to masm!'
data ends

code segment
start:
    mov ax,data
    mov ds,ax
    mov ax,0b800h
    mov es,ax
    mov bx,1760 ;160*11

    ;第一行
    mov cx,16
    mov di,0
    mov si,64
    mov ah,00000010b
    s:
        mov al,[di]
        mov es:[bx][si],ax
        inc di
        add si,2
        loop s

    ;第二行
    mov cx,16
    mov di,0
    mov si,64
    add bx,160
    mov ah,00100100b
    s1:
        mov al,[di]
        mov es:[bx][si],ax   
        inc di
        add si,2
        loop s1
    
    ;第三行
    mov cx,16
    mov di,0
    mov si,64
    add bx,160
    mov ah,01110001b
    s2:
        mov al,[di]
        mov es:[bx][si],ax
        inc di
        add si,2
        loop s2
    
    mov cx,0ffffh
    s3:
    nop
    loop s3
    mov ax,4c00h
    int 21h
code ends

end start