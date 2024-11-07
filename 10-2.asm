assume cs:code,ds:data

data segment
    db 'conversation'
data ends

code segment

main:
    mov ax,data
    mov ds,ax
    mov bx,0
    mov cx,12

    call capital

    mov ax,4c00h
    int 21h

;小转大
;段 = ds, 偏移 = bx， 长度 = cx
;无返回值
capital:
    and byte ptr [bx],11011111b
    inc bx
    loop capital
ret

code ends

end main