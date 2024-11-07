;1ef0001000h + 2010001ef0h
;003e1000h - 00202000h
assume cs:code,ds:data

data segment
    db 12H, 34H, 56H, 78H, 9AH, 0BCH, 0DEH, 0F0H, 11H, 22H, 33H, 44H, 55H, 66H, 77H, 88H
    db 0AAH, 0BBH, 0CCH, 0DDH, 0EEH, 0FFH, 00H, 11H, 22H, 33H, 44H, 55H, 66H, 77H, 88H, 99H
    ;  bc ef 22 56 89 bc df
    ; 结果：0x 1 21 FF DD BB 99 77 55 34 01 DF BC 89 56 22 EF BC
data ends

code segment

main:

    mov ax,data
    mov ds,ax
    mov si,0

    add ax,1
    mov es,ax
    mov di,0

    call high_add


    ; mov ax,001eh
    ; mov bx,0f000h
    ; mov cx,1000h

    ; add cx,1ef0h
    ; adc bx,1000h
    ; adc ax,0020h

    ; mov ax,003eh
    ; mov bx,1000h
    ; sub bx,2000h
    ; sbb ax,0020h

    mov ax,4c00h
    int 21h

; 计算128位(16B)的数相加
; ds:si指向第一个加数及结果
; es:di指向第二个加数
; ds:si指向结果
high_add:
    push ax
    push si
    push cx

    add ax,0
    mov cx,8
    s:
        mov ax,[si]
        adc ax,es:[di]
        mov [si],ax

        ;不能用add si,2 这样会影响CF的值
        inc si
        inc si
        inc di
        inc di
        ; add si,2
        ; add di,2 
        loop s
    
    pop cx
    pop si
    pop ax
    ret

code ends

end main