;*
;**
;***
;****

assume cs:code

code segment

start:
    mov ax,20h
    mov ds,ax

    mov cx,10h
    mov bx,0
    mov di,1
    mov dx,2ah

s1: 
    mov si,0
    push cx
    mov cx,di
    s2: 
        mov [bx+si],dx
        inc si
        loop s2
    pop cx
    inc di
    add bx,10h
    loop s1 

    mov ax,4c00h
    int 21h

code ends

end start