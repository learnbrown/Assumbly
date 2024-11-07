;大写变小写，小写变大写
assume cs:code,ds:data

data segment
    db 'BaSiC'
    db 'iNfOrMaTiOn'
data ends

code segment

start:
    mov ax,data
    mov ds,ax

    mov al,00100000b

    mov bx,0
    mov cx,16

s:  xor [bx],al
    inc bx
    loop s

    mov ax,4c00h
    int 21h

code ends

end start