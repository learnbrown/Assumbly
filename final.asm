assume cs:code,ds:data,ds:signal,ss:stack

stack segment
    db 128 dup(0)
stack ends

data segment
    ; 保存int 9中断例程的地址
    nine dw 0,0

    ; 放置日期时间字符串
    year db '2000/'
    month db '00/'
    day db '00',0

    hour db '00:'
    minute db '00:'
    second db '00',0

    ; 放置提示语字符串
    tip db 'Press "Esc" to quit.',0

    num0 db ' **** '
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db '      '
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db ' **** '

    num1 db '   *  '
         db '  **  '
         db ' * *  '
         db '   *  '
         db '   *  '
         db '   *  '
         db '   *  '
         db '   *  '
         db '   *  '
         db '   *  '
         db ' *****'

    num2 db ' **** '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db ' **** '
         db '*     '
         db '*     '
         db '*     '
         db '*     '
         db ' **** '

    num3 db ' **** '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db ' **** '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db ' **** '

    num4 db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db ' **** '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db '     *'

    num5 db ' **** '
         db '*     '
         db '*     '
         db '*     '
         db '*     '
         db ' **** '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db ' **** '

    num6 db ' **** '
         db '*     '
         db '*     '
         db '*     '
         db '*     '
         db ' **** '
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db ' **** '

    num7 db ' **** '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db '      '
         db '     *'
         db '     *'
         db '     *'
         db '     *'
         db '     *'

    num8 db ' **** '
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db ' **** '
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db ' **** '

    num9 db ' **** '
         db '*    *'
         db '*    *'
         db '*    *'
         db '*    *'
         db ' **** '
         db '     *'    
         db '     *'
         db '     *'
         db '     *'
         db ' **** '

    colon db '      '
          db '  **  '
          db '  **  '
          db '      '
          db '      '
          db '  **  '
          db '  **  '
          db '      '
          db '      '
          db '      '
          db '      '


    slash db '     *'
          db '    * '
          db '    * '
          db '   *  '
          db '   *  '
          db '  *   '
          db '  *   '
          db ' *    '
          db ' *    '
          db '*     '
          db '*     '
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

        ; 在上半部分显示年月日
        mov si,offset year
        mov dh,1
        mov dl,4
        call display

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

            mov dh,13
            mov dl,10
            push si
            mov si,offset hour
            call display
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

    ; 名称：display
    ; 功能：将一段表示数字的字符串，以图形的样式显示到屏幕上
    ; ds:si指向字符串起始位置，dh为起始行，dl为起始列，

    return_dis:
        pop bp
        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret

    display:
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        push es
        push bp

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

        loop_dis:
            mov al,[si] ; 将当前显示字符存入al
            
            ; 若为结尾符0，则直接返回
            cmp al,0
            je return_dis

            cmp al,'0'
            jne j1
            mov bp,offset num0
            jmp print_dis

        j1: cmp al,'1'
            jne j2
            mov bp,offset num1
            jmp print_dis
            
        j2: cmp al,'2'
            jne j3
            mov bp,offset num2
            jmp print_dis
            
        j3: cmp al,'3'
            jne j4
            mov bp,offset num3
            jmp print_dis
            
        j4: cmp al,'4'
            jne j5
            mov bp,offset num4
            jmp print_dis
            
        j5: cmp al,'5'
            jne j6
            mov bp,offset num5
            jmp print_dis
            
        j6: cmp al,'6'
            jne j7
            mov bp,offset num6
            jmp print_dis
            
        j7: cmp al,'7'
            jne j8
            mov bp,offset num7
            jmp print_dis
            
        j8: cmp al,'8'
            jne j9
            mov bp,offset num8
            jmp print_dis
            
        j9: cmp al,'9'
            jne j10
            mov bp,offset num9
            jmp print_dis

        j10: cmp al,':'
            jne j11
            mov bp,offset colon
            jmp print_dis

        j11: cmp al,'/'
            jne err
            mov bp,offset slash
            jmp print_dis
            
        err: jmp return_dis

        print_dis:
            push di
            mov cx,11
            dis00:
                push cx
                mov cx,6
                mov ah,7
                dis01:
                    mov al,ds:[bp]
                    mov es:[bx+di],ax
                    inc bp
                    add di,2
                    loop dis01
                pop cx
                add di,160-12
                loop dis00
    
            pop di
            inc si
            add di,14
            ; 每打印完一个字，都要再次循环
            jmp loop_dis

code ends

signal segment 


signal ends

end main