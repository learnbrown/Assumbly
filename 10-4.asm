assume cs:code,ds:data

data segment
    db 'Welcome to masm!', 0
data ends

code segment

    main:

        ;测试show_str
        mov ax,data
        mov ds,ax

        mov dh,12
        mov dl,32
        mov cl,7
        mov si,0
        call show_str

        mov ax,4c00h
        int 21h




    ; show_str
    ; 功能：在指定位置，用指定颜色，显示一个用0结束的字符串
    ; 参数：(dh)=行号(0~24), (dl)=列号(0~79), (cl)=颜色, ds:si指向字符串首地址
    ; 返回：无
    ;   7  6   5   4   3   2   1   0
    ;  BL  R   G   B   I   R   G   B
    ;  闪烁     背景   高亮    前景
    show_str:
        ; 将用到的寄存器压入栈中
        push ax
        push es
        push si     ; 虽然si用作传参，但show_str中也用到了它，也将它压入栈中
        push di

        ; 设置显存位置
        mov ax,0b800h
        mov es,ax

        ; 计算行的首地址，行号X160，结果存放在ax中
        ; 用bx来表示行偏移量
        mov al,dh
        mov dh,160
        mul dh
        mov bx,ax

        ; di来表示列偏移量，列数乘2
        mov dh,0
        mov di,dx
        add di,di

        ; 用ax来保存每一个字符，ah为颜色，al为字符
        mov ah,cl
        mov cx,0
        s:
            mov cl,[si]
            jcxz return
            mov al,[si]
            mov es:[bx+di],ax
            inc si
            add di,2
            jmp short s

        return:
            pop di
            pop si
            pop es
            pop ax
            ret
code ends

end main