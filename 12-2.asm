; 编写int 9
assume cs:code,ds:data,ss:stack

stack segment
    db 128 dup(0)
stack ends

data segment
    ; 保存int 9中断例程的地址
    nine dw 0,0

    ; 放置日期时间字符串
    year db '2000/'
    month db '00/'
    day db '00 '
    hour db '00:'
    minute db '00:'
    second db '00',0

    ; 放置提示语字符串
    tip db 'Press "Esc" to quit.',0
data ends

code segment
    main:
        mov ax,stack
        mov ss,ax
        mov sp,128

        mov ax,data
        mov ds,ax

        mov ax,0
        mov es,ax

        call cls
    
        ; 将原来的int 9中断例程的入口地址保存在ds:0、ds:2
        mov bx,offset nine
        push es:[9*4]
        pop [bx]
        push es:[9*4+2]
        pop [bx+2]

        ; 安装int9
        mov word ptr es:[9*4],offset int9
        mov es:[9*4+2],cs

        ; tip
        mov dh,24
        mov dl,60
        mov cl,7
        mov si,offset tip
        call show_str

        ; year
        mov al,9
        out 70h,al
        in al,71h
        mov si,offset year + 2
        call bcdtostr

        ; month
        mov al,8
        out 70h,al
        in al,71h
        mov si,offset month
        call bcdtostr

        ; day
        mov al,7
        out 70h,al
        in al,71h
        mov si,offset day
        call bcdtostr

        ; hour
        mov al,4
        out 70h,al
        in al,71h
        mov si,offset hour
        call bcdtostr

        t:
            ; minute
            mov al,2
            out 70h,al
            in al,71h
            mov si,offset minute
            call bcdtostr

            ; second
            mov al,0
            out 70h,al
            in al,71h
            mov si,offset second
            call bcdtostr

            mov dh,12
            mov dl,30
            mov cl,7
            push si
            mov si,offset year
            call show_str
            pop si

            jmp short t

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; 子程序部分

    int9:
        push ax
        push bx
        push es

        mov ax,0
        mov es,ax

        in al,60h

        pushf

        pushf
        pop bx
        and bh,11111100b
        push bx
        popf

        mov bx,offset nine
        call dword ptr [bx]

        cmp al,1
        jne int9ret
        
        push [bx]
        pop es:[9*4]
        push [bx+2]
        pop es:[9*4+2]
        mov ax,4c00h
        int 21h
    
    int9ret:
        pop es
        pop bx
        pop ax
        iret
        
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
        ; mov byte ptr [si+2],0    

        pop cx
        pop si
        pop ax

        ret

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
        push si
        push di
        push bx
        push dx
        push cx

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
            jcxz return_a
            mov al,[si]
            mov es:[bx+di],ax
            inc si
            add di,2
            jmp short s

        return_a:
            pop cx
            pop dx
            pop bx
            pop di
            pop si
            pop es
            pop ax

            ret

    ; cls
    ; 功能：清空屏幕显示
    ; 参数：无
    ; 返回：无
    cls:
        push ax
        push ds
        push si
        push cx

        mov ax,00b800h
        mov ds,ax
        mov si,0
        mov cx,4000h
        cc:
            mov word ptr [si],0
            add si,2
            loop cc

        pop cx
        pop si
        pop ds
        pop ax

        ret

        
code ends

end main