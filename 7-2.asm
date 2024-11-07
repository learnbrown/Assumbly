;P150 问题7.4
;ax=00beh bx=1000h cx=0606h
assume cs:code

code segment

start:
    mov ax,2000h
    mov ds,ax
    mov bx,1000h
    mov si,0

    mov ax,[bx+si]  ;ax=00be
    inc si
    mov cx,[bx+si]  ;cx=0600h
    inc si
    mov di,si
    add cx,[bx+di]  ;cx=0606h

    mov ax,4c00h
    int 21h
    
code ends

end start