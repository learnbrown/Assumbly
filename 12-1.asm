assume cs:code

data segment
    db 10h dup(0)
data ends

time segment
    db 10h dup(0)
time ends

code segment

    main:
        mov ax,data
        mov ds,ax
        mov bx,0

        ;year
        mov al,9
        out 70h,al
        in al,71h
        mov si,0
        call bcdtostr

        ;month
        mov al,8
        out 70h,al
        in al,71h
        add si,3
        call bcdtostr

        ;day
        mov al,7
        out 70h,al
        in al,71h
        add si,3
        call bcdtostr

        ;hour
        mov al,4
        out 70h,al
        in al,71h
        add si,3
        call bcdtostr

        ;minute
        mov al,2
        out 70h,al
        in al,71h
        add si,3
        call bcdtostr

        ;seconds
        mov al,0
        out 70h,al
        in al,71h
        add si,3
        call bcdtostr

        mov ax,4c00h
        int 21h
    
    ;功能：将一个字节中的两个BCD码转为字符
    ;参数：(al)=两个BCD码，ds:si指向字符位置
    ;返回：无
    bcdtostr:
        push ax
        push si
        push cx

        mov ah,al
        mov cl,4
        shr ah,cl
        and al,00001111b

        add al,30h
        add ah,30h

        mov [si],ah
        mov [si+1],al
        mov byte ptr [si+2],0    

        pop cx
        pop si
        pop ax

        ret

code ends

end main