assume cs:code,ds:data,ss:stack

data segment
    time db 30 dup(0)
data ends

stack segment
    db 100h dup(0)
stack ends

code segment

main:
    mov ax,data
    mov ds,ax

    mov ax,stack
    mov ss,ax
    mov sp,100H

    mov ah,2ch
    int 21h

    mov bx,offset time
    mov [bx],dl
    inc bx
    mov [bx],ah
    inc bx
    mov [bx],al

    mov ax,4c00h
    int 21h

code ends

end main