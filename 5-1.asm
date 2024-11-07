;P121
assume cs:code

code segment

start:	mov ax,20h
		mov ds,ax
		
		mov bx,0
		mov cx,40h

s:		mov [bx],bl
		inc bx
		loop s
		
		mov ax,4c00h
		int 21h

code ends

end start