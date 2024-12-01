; 预计实现将数字字符显示为图形样式
assume cs:code,ds:data,ds:signal

data segment
    a db '2024/12/01',0
    b db '21:09:32',0
data ends

signal segment 
    num0 db ' #### '
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db '      '
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db ' #### '

    num1 db '   #  '
         db '  ##  '
         db '   #  '
         db '   #  '
         db '   #  '
         db '   #  '
         db '   #  '
         db '   #  '
         db '   #  '
         db '   #  '
         db '  ### '

    num2 db ' #### '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db ' #### '
         db '#     '
         db '#     '
         db '#     '
         db '#     '
         db ' #### '

    num3 db ' #### '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db ' #### '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db ' #### '

    num4 db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db ' #### '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db '     #'

    num5 db ' #### '
         db '#     '
         db '#     '
         db '#     '
         db '#     '
         db ' #### '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db ' #### '

    num6 db ' #### '
         db '#     '
         db '#     '
         db '#     '
         db '#     '
         db ' #### '
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db ' #### '

    num7 db ' #### '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db '      '
         db '     #'
         db '     #'
         db '     #'
         db '     #'
         db '     #'

    num8 db ' #### '
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db ' #### '
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db ' #### '

    num9 db ' #### '
         db '#    #'
         db '#    #'
         db '#    #'
         db '#    #'
         db ' #### '
         db '     #'    
         db '     #'
         db '     #'
         db '     #'
         db ' #### '

    colon db '      '
          db '  ##  '
          db '  ##  '
          db '      '
          db '      '
          db '  ##  '
          db '  ##  '
          db '      '
          db '      '
          db '      '
          db '      '


    slash db '     #'
          db '    # '
          db '    # '
          db '   #  '
          db '   #  '
          db '  #   '
          db '  #   '
          db ' #    '
          db ' #    '
          db '#     '
          db '#     '


signal ends

code segment

    main:
        mov ax,data
        mov ds,ax
        mov si,offset a
        
        mov dh,1
        mov dl,4
        call display

        mov dh,14
        mov dl,10
        mov si,offset b
        call display

        mov ax,4c00h
        int 21h
    
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
            push ds
            push di
            mov dx,signal
            mov ds,dx
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
            pop ds
            inc si
            add di,14
            ; 每打印完一个字，都要再次循环
            jmp loop_dis

code ends



end main