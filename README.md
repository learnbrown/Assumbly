# Assumbler
汇编学习记录

## 实验十
源文件[10-4.asm](/10-4.asm) <br />


### 1.显示字符串
`show_str` <br />
功能：在指定位置，用指定颜色，显示一个用0结束的字符串 <br /><br />
参数：`(dh)`=行号(0~24), `(dl)`=列号(0~79), `(cl)`=颜色, `ds:si`指向字符串首地址 <br /><br />
返回：无 <br /><br />

属性字节的格式<br />
|7|6|5|4|3|2|1|0|
|-|-|-|-|-|-|-|-|
|BL||RGB||I||RGB|
|闪烁||背景||高亮||前景|

```asm
show_str:
        ; 将用到的寄存器压入栈中
        push ax
        push es
        push si     ; 虽然si用作传参，但show_str中也用到了它，也将它压入栈中
        push di
        push bx

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
            pop bx
            pop di
            pop si
            pop es
            pop ax

            ret
```
### 2.解决除法溢出的问题
`divdw` <br />
功能：进行不会产生溢出的除法运算，被除数为dword型，除数为word型，结果为dword型 <br /><br />
参数：`(ax)` = dword型数据的低16位 <br />
      `(dx)` = dword型数据的高16位 <br />
      `(cx)` = 除数 <br /><br />
返回：`(dx)` = 结果的高16位，`(ax)` = 结果的低16位 <br />
      `(cx)` = 余数 <br /><br />
解决此问题可以使用如下公式：
```
X ÷ N = H / N * 10000H + (H % N * 10000H + L) ÷ N
X:被除数    N:除数    H:X的高16位    L:X的低16位
```
等式的右边分为加号左右两个部分：<br />
从整体上看，左边是一个数整除一个16位的数，结果为16位数，再乘以10000H，相当于位运算左移16位，变成了一个低16位全为0的32位数；右边为一个数除以16位的数，结果肯定为16位的数。左右相加，相当于将左边的结果放在高16位上，右边的结果放在低16位上。由此可知，加号左右两边分别为商的高16位和低16位。
```asm
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

        mov dx,di

        pop di
        pop si

        ret
```
### 3.数值显示
`dtoc` <br />