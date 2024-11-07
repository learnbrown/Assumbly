; .model small                  ; 指定内存模型（小内存模型）
; .stack 100h                   ; 定义堆栈段大小

; .data
;     msg db 'Hello, World!$', 0  ; 定义字符串，$ 作为结束符

; .code
; main PROC
;     ; 输出字符串
;     mov dx, OFFSET msg        ; 将字符串地址加载到 DX
;     mov ah, 9                 ; DOS 中断 21h 功能号 9：输出字符串
;     int 21h                   ; 调用 DOS 中断

;     ; 退出程序
;     mov ah, 4Ch               ; DOS 中断 21h 功能号 4Ch：退出
;     int 21h
; main ENDP
; END main

assume cs:code,ds:data

data segment
    msg db 'Hello World!$', 0
data ends

code segment

start:
    mov dx,offset msg
    mov ah,9
    int 21h

    mov ax,4c00h
    int 21h
code ends

end start