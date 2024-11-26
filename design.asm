assume cs:code,ds:data,ds:table,ss:stack

data segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
data ends

; 所有要显示的内容都转为字符串后放入table段中
table segment
    db 21 dup('year', 0, 'sum-----', 0, 'num-----', 0, '----', 0, 0, 0, 0, 0)
table ends

stack segment
    db 100h dup(0)
stack ends

code segment

main:
    call cls

    mov ax,stack
    mov ss,ax
    mov sp,100h
    
    mov ax,table
    mov ds,ax

    mov ax,data
    mov es,ax



    ; 将年份复制到table段，收入处理后也放入table段
    mov si,0
    mov di,0
    mov cx,21
    year:
        ; 年份
        mov ax,es:[di]
        mov [si],ax
        mov ax,es:[di+2]
        mov [si+2],ax


        ; 处理收入
        mov ax,es:84[di]
        mov dx,es:84[di+2]

        ; ds段中用si来指向每一行数据起始位置，但是传入参数需要指向收入的起始位置，就先将其入栈，返回后恢复
        push si
        add si,5
        call dwtostr
        pop si

        add di,4
        add si,20h
        loop year
    


    ; 将人数处理后放入table段
    mov si,14   ; 指向人数的起始位置
    mov di,168  ; 指向原数据中人数的起始位置
    mov cx,21
    num:
        ; 人数
        mov ax,es:[di]
        mov dx,0

        call dwtostr

        add si,20h
        add di,2
        loop num
    


    ; 计算人均收入并放入table段
    mov si,23   ; 指向人均收入起始位置
    mov bx,84   ; 指向收入
    mov di,168  ; 指向人数
    mov cx,21
    per:
        ; 设置被除数
        mov ax,es:[bx]
        mov dx,es:[bx+2]
        ; 设置除数
        push cx
        mov cx,es:[di]
        call divdw
        pop cx

        call dwtostr

        add si,20h
        add bx,4
        add di,2

        loop per



    ; 从第3行开始进行显示
    mov dh,3
    mov bx,0
    mov si,0
    mov cx,21
    display:
        push cx
        mov cl,7
        ; bx指向每行首位
        mov si,bx

        ; 第10列显示年份
        mov dl,2
        call show_str

        ; 第30列显示收入
        mov dl,25
        add si,5
        call show_str

        ; 第50列显示人数
        mov dl,50
        add si,9
        call show_str

        ; 第70列显示人均收入
        mov dl,70
        add si,9
        call show_str

        add bx,20h
        inc dh
        pop cx
        loop display

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


    ; divdw
    ; 功能：进行不会产生溢出的除法运算，被除数为dword型，除数为word型，结果为dword型
    ; 参数：(ax) = dword型数据的低16位
    ;      (dx) = dword型数据的高16位
    ;      (cx) = 除数
    ; 返回：(dx) = 结果的高16位，(ax) = 结果的低16位
    ;       (cx) = 余数
    ;
    ; 例：计算 1000000/10(0F4240H/0AH)
    ;
    ; 公式：X ÷ N = H / N * 10000H + (H % N * 10000H + L) ÷ N
    ;   X:被除数    N:除数    H:X的高16位    L:X的低16位

    divdw:
        push si
        push di

        mov si,ax ; 暂存低位
        mov di,dx ; 暂存高位
        
        mov ax,di
        mov dx,0
        div cx

        mov di,ax ; 结果的高16位
        mov ax,si 
        div cx
        
        ; 余数存入cx
        mov cx,dx
        mov dx,di

        pop di
        pop si

        ret
    

    ; dtoc
    ; 功能：将word型数据转变为表示十进制数的字符串，字符串以0为结尾符
    ; 参数：(ax) = word型数据
    ;       ds:si指向字符串首地址
    ; 返回：无
    ; 例：将数据12666以十进制的形式在屏幕的8行3列，用绿色显示出来
    
    dtoc:
        push cx
        push bx
        push si
        push dx
        push di

        mov cx,0
        mov bx,10

        ; 先将一个‘0’压入栈中
        mov di,0
        push di
        inc di

        t:  
            div bx
            mov cx,ax

            ; 除10取余得到的是倒序的数，所以用到栈
            add dx,30h
            push dx
            inc di  ; 记录位数

            jcxz return_b
            mov dx,0
            
            jmp short t

        return_b:
            ; 将数字出栈到内存
            mov cx,di
            m:
                pop dx
                mov [si],dl
                inc si
                loop m

            pop di
            pop dx
            pop si
            pop bx
            pop cx

            ret

    ; dwtostr
    ; 功能：将dword型数据转变为表示十进制数的字符串，字符串以0为结尾符
    ; 参数：(ax) = dword型数据的低16位
    ;     (dx) = dword型数据的高16位
    ;     ds:si指向字符串首地址
    ; 返回：无
    
    dwtostr:
        push di
        push cx
        push dx
        push ax
        push si

        ; 先将一个‘0’压入栈中
        mov di,0
        push di
        inc di

        n:
            mov cx,10
            call divdw

            add cx,30h
            push cx
            inc di
            
            ; 判断商是否为零，即dx，ax是否均为零
            mov cx,0
            or cx,dx
            or cx,ax
            jcxz return_c

            jmp short n

        return_c:
            mov cx,di ; 出栈次数
            
            p:
                pop dx
                mov [si],dl
                inc si
                loop p

            pop si
            pop ax
            pop dx
            pop cx
            pop di

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