assume cs:code,ds:data,ss:stack

data segment
    ; db 'conversation', 0
    db 'word', 0
    db 'unix', 0
    db 'wind', 0
    db 'good', 0
data ends

stack segment
    db 16 dup(0)
stack ends

code segment

    main:
        mov ax,data
        mov ds,ax

        mov ax,stack
        mov ss,ax
        mov sp,16
        
        mov bx,0
        mov cx,4
        a:
            push cx
            call toupper
            pop cx
            add bx,5
            loop a

        mov ax,4c00h
        int 21h

    ;将一段以零结尾的字符转为全大写
    ;段 = ds，偏移 = bx
    ;无返回
    ;面对寄存器冲突时，应在子程序内把寄存器入栈，返回前出栈
    toupper:
        mov di,0
        mov cx,0
        s:
            mov cl,[bx+di]
            jcxz return
            and byte ptr [bx+di],11011111b
            inc di
            jmp s
        return:
            ret

code ends

end main