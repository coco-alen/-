.386
data segment use16

;�ļ��ж���ı���
t db '0','1','2','3','4','5','6','7'
  db '8','9','A','B','C','D','E','F'
pattern db "00000000:            |           |           |                             "

filename db 100  ;�������100���ַ�
         db ?    ;ʵ�����벻֪��
	 db 100 dup(0)  ;�洢������ַ�

s db "00000000:            |           |           |                             "
openerror db "Cannot open file!"
input_tip db "Please input filename:"

handle dw 0
key dw 0

file_size dd 0

;char2hex�����õ�����
	char2hex_xx db 0
	;s db 75 dup(0)

;char2hex�����õ�����
	;the_offset dd 0
	;s db 75 dup(0)

;show_this_row�����õ�����
	row dw 0  ;�к�
	bytes_on_row dw 0 ;��ǰ���ֽ���
	the_offset dd 0
	buf db '0000000000000000'  

;show_this_page�����õ�����
	rows dw 0       ;һҳ�м���
	bytes_in_buf dw 0  ;��ǰҳ�ֽ���
	the_offset_page dd 0
	buf_page db 256 dup(0)
	;the_offset dd 0

data ends


code segment use16
assume cs:code, ds:data

;---------------------------------------
clear:  ;������п�ʹ�õļĴ�����ֵ
   mov eax, 0
   mov ebx, 0
   mov ecx, 0
   mov edx, 0
   mov esi, 0
   mov edi, 0 
ret

;---------------------------------------
char2hex:  ;��8λ��ת����16���Ƹ�ʽ
           ;����:char2hex_xx db ��Ҫת������
	   ;     di ��ʾҪ���ǵ�s��ʼ�±꣬�������di=di+2��
	   ;���:��s�Ķ�Ӧdiλ�������16���ƽ��2���ַ�

   push ax
   push si

   mov al ,char2hex_xx  ;�����λ����������ȡ��λ
   shr al ,4
   and al ,0Fh
   mov ah ,0
   mov si,ax
   mov al,t[si]  ;ת��Ϊ16���Ʒ���
   mov s[di],al
   inc di

   mov al ,char2hex_xx  ;�����λ��ȡ����λ
   and al ,0Fh
   mov ah ,0
   mov si,ax
   mov al,t[si]  ;ת��Ϊ16���Ʒ���
   mov s[di],al
   inc di
   
   pop si
   pop ax
ret

;---------------------------------------

long2hex: ;��32λ��ת����16���Ƹ�ʽ
          ;����:the_offset ��Ҫ�����32λ����
	  ;     di ��ʾҪ���ǵ�s��ʼ�±꣬�������di=di+8��
	  ;���:��s�Ķ�Ӧdiλ�������16���ƽ��8���ַ�
   push si
   push eax
   push bx

   mov si, 4
   mov eax,the_offset   ;ȡoffsetֵΪ��������Ϊ16��������׼��

char_by_char:
   cmp si, 0   ;for(i=0; i<4; i++)
   je long2hex_end
   rol eax, 8    ;���ư�λ������ȡ8λ
   push eax
   and eax, 000000FFh ;ȡ8λ
   mov char2hex_xx, al   ;ȡ�õ���8λ����תΪ16������������
   pop eax
   call char2hex

   dec si
   jmp char_by_char

long2hex_end:

   pop bx
   pop eax
   pop si

   ret

;---------------------------------------

show_this_row:  ;��ʾ��ǰһ��
                ;����: row,�к�
	        ;      bytes_on_row,dw ��ǰ���ֽ���
	        ;      the_offset,ƫ��
	        ;      buf�����������׵�ַ
		;�������ʾһ��ֵ

   push bx  ;����
   push si
   push di
   push ax
   push cx

   mov cx, 75  ;��pattern�е�ֵȫ�����Ƶ�s��
   push es
   push ds
   pop es
   mov si, offset pattern
   mov di, offset s
   cld
   rep movsb
   pop es



   mov si, 0  ;����ѭ��
   mov di, 0
   call long2hex 

fill_xx:
   mov al, buf[si]  ;����Ҫ�����ֵ��char2hex_xx
   mov char2hex_xx, al

   mov di,si   ;��ֵҪ������±�λ��
   add di,si
   add di,si
   add di,10

   call char2hex

   inc si
   cmp si, bytes_on_row  ;�����һ���Ƿ������
   jb fill_xx

   ;������һ��ѭ����Ԥ����
   mov si, 0

fill_tile:  ;���ASCII���Ӧ�Ľ��ֵ
   mov al, buf[si]
   mov s[59+si],al
   inc si
   cmp si, bytes_on_row
   jb fill_tile


find_position:  ;����vp = vp + row*80*2
   mov bl, 160
   mov ax, row
   mul bl
   mov bx, ax  ;bx�洢�˶�Ӧ�е���ʼƫ����
   mov si, 0 ;ѭ��Ԥ����

show_row:
   mov al, s[si]    ;��Ӧvp[i*2] = s[i]��ʾ���ݴ���al
   push di
   mov di, si
   shl di, 1  ;di = 2*si
   add di, bx  ;di = 2*si  ��vp = vp + row*80*2 
   
   cmp si,59
   jb row_might_true
   jmp row_is_false

row_might_true:  ;����Ƿ��ǡ�|��
   mov ah, s[si]
   cmp ah, '|'
   je row_is_true
   jmp row_is_false

row_is_true:   ;�ǡ�|��
   mov ah, 0Fh  ;�趨������ɫ

   mov word ptr es:[di], ax  ;������ʾ
   pop di

   jmp row_continue

row_is_false:
   mov ah, 07h  ;�趨��ɫ

   mov word ptr es:[di], ax   ;������ʾ
   pop di

row_continue:
   inc si
   cmp si, 75
   jb show_row

show_this_row_end:
   pop cx
   pop ax
   pop di
   pop si
   pop bx

ret

;---------------------------------------

clear_this_page:  ;�����Ļ0~15��
                  ;������
		  ;�����80*16��20h��
   push eax
   push cx
   push di
   
   cld
   mov di, 0
   mov cx, 80*16/2  ;����80*16��0020h
   mov eax, 00200020h
   rep stosd

   pop di
   pop cx
   pop eax

ret
;---------------------------------------


show_this_page: ;��ʾ��ǰҳ
		;bytes_in_buf dw 0  ;��ǰҳ�ֽ���
		;buf_page db 256 dup(0)  buf�ַ�������
		;the_offset_page dd 0 ƫ����
   push eax
   push bx
   push cx
   push si
   push di


   call clear_this_page

   mov ax , bytes_in_buf  ;rows = (bytes_in_buf + 15) / 16
   add ax ,15
   mov bl ,16
   div bl
   mov ah ,0
   mov rows, ax

   mov si, 0

show_this_page_begin:

   inc si      ;ȷ��i == rows-1
   cmp si, rows
   je last_line
   jmp not_last_line

last_line:
   dec si
   mov ax ,si ;����si*16��Ҳ����i*16�Ĵ���
   mov bl, 16
   mul bl
   mov cx ,ax  ;cx�洢��si*16��Ҳ����i*16��ֵ
   mov ax ,bytes_in_buf
   sub ax, cx
   mov bytes_on_row, ax  ;bytes_in_buf - i*16
   jmp show_this_page_continue

not_last_line:
   dec si
   mov ax ,si
   mov bl, 16
   mul bl
   mov cx ,ax  ;cx�洢��si*16��Ҳ����i*16��ֵ
   mov bx, 16
   mov bytes_on_row, bx


show_this_page_continue:
   mov row, si  ;���� row = i
   mov eax, the_offset_page
   add eax, ecx
   mov the_offset, eax  ;���� offset+i*16

   push es   ;����&buf[i*16]
   push ds
   pop es
   push si
   mov si, offset buf_page  ;��buf_page���൱��Դ�����buf��
   add si, cx               ;��i*16��ʼ�����ݸ��Ƶ�buf��
   mov di, offset buf
   mov cx, bytes_on_row
   cld
   rep movsb

   pop si
   pop es

   call show_this_row  ;��ʾһ��

   inc si
   cmp si, rows
   je show_this_page_end
   jmp show_this_page_begin


show_this_page_end:

   pop di
   pop si
   pop cx
   pop bx
   pop eax

ret

;---------------------------------------




main:
   mov ax, data
   mov ds, ax   ;���ݶε�ַ��
   mov ax, 0B800h
   mov es, ax   ;�Դ�ε�ַ����es

   mov si, 0 ;ȡֵѭ��
   mov ah, 2

input_tips_role: ;�����ʾ��Please input filename:��
   cmp si, 22
   je input_tips_end
   mov dl, input_tip[si]
   int 21h
   inc si
   jmp input_tips_role

input_tips_end:  ;������кͻس�
   mov dl, 0Ah
   int 21h
   mov dl, 0Dh
   int 21h

;---------------------------------------
;�����ļ������ļ�

input_filename:  ;�����ļ���
   mov dx, offset filename
   mov ah, 0Ah
   int 21h
   mov al, filename[1]  ;��ȡʵ��������ַ���
   mov si, 2
   mov ah, 0
   add si, ax          ;��λ�������ַ����Ľ�β
   mov filename[si] , byte ptr 0   ;�����س��ͻ���
   mov filename[si+1] , byte ptr 0


open_file: ;���ļ������ض�Ӧ�ļ����
   mov ah, 2  ;����
   mov dl, 0Ah
   int 21h
   mov dl, 0Dh
   int 21h

   mov ah, 3Dh
   mov al, 0; ��Ӧ_open()�ĵ�2������, ��ʾֻ����ʽ
   mov dx, offset filename
   add dx, 2
   int 21h
   mov handle, ax
   
   jc open_error  ;���CF == 1 �򿪴���
   jmp open_success


;---------------------------------------
;����ļ��򿪴���
open_error:

   mov si, 0 ;ȡֵѭ��
   mov ah, 2

open_error_role:  ;�����ʾ"Cannot open file!"
   cmp si, 17
   je open_error_end
   mov dl, openerror[si]
   int 21h
   inc si
   jmp open_error_role

open_error_end:

   mov dl, 0Ah  ;���У��˳�
   int 21h
   mov dl, 0Dh
   int 21h
   jmp exit

;---------------------------------------
;����ļ�����ȷ

open_success:
              ;�ƶ��ļ�ָ��
   mov ah, 42h
   mov al, 2; ��Ӧlseek()�ĵ�3������,
            ; ��ʾ��EOFΪ���յ�����ƶ�
   mov bx, handle
   mov cx, 0; \ ��Ӧlseek()�ĵ�2������
   mov dx, 0; /
   int 21h
   mov word ptr file_size[2], dx
   mov word ptr file_size[0], ax
   mov the_offset_page, dword ptr 0
   call clear


;����ѭ������ʼ��ʾ����
show_begin:
   mov eax, the_offset_page
   mov ebx, file_size
   sub ebx, eax ;n = file_size - offset,
   cmp ebx, 256 ;�����ebx�洢�����˱���n
   jae byte_256
   jmp byte_not_256

byte_256:
   mov bytes_in_buf, word ptr 256
   jmp show_continue

byte_not_256:
   mov bytes_in_buf, bx
   
show_continue:  ;�ƶ��ļ�ָ��lseek(handle, offset, 0)
   mov ah, 42h
   mov al, 0; ��Ӧlseek()�ĵ�3������,
            ; ��ʾ��ƫ��0��Ϊ���յ�����ƶ�
   mov bx, handle
   mov cx, word ptr the_offset_page[2]; \cx:dx��һ�𹹳�
   mov dx, word ptr the_offset_page[0]; /32λֵ=offset
   int 21h
   
   ;��ȡ�ļ��е�bytes_in_buf���ֽڵ�buf��
   mov ah, 3Fh  ;_read(handle, buf, bytes_in_buf)
   mov bx, handle
   mov cx, bytes_in_buf
   mov dx, data
   mov ds, dx
   mov dx, offset buf_page
   int 21h

   call show_this_page  
   
   mov ah, 0 ;�������룬�����ASCII������AL��BIOS scan code��AH
   int 16h 

;---------------------------------------
;�����ж�

;define PageUp   0x4900
;define PageDown 0x5100
;define Home     0x4700
;define End      0x4F00
;define Esc      0x011B

   cmp ax, 4900h   ;switch(key)
   je pageup
   cmp ax, 5100h
   je pagedown
   cmp ax, 4700h
   je home
   cmp ax, 4F00h
   je the_end
   cmp ax, 011Bh
   jne show_begin
   jmp the_esc

pageup:
   mov eax, the_offset_page
   sub eax, 256
   mov the_offset_page, eax
   cmp eax, 0
   jl pageup_offset0
   jmp show_begin

pageup_offset0:
   mov the_offset_page, dword ptr 0
   jmp show_begin


pagedown:
   mov eax, the_offset_page
   add eax, 256
   cmp eax, file_size
   jb PageDown_true
   jmp show_begin

PageDown_true:
   mov the_offset_page, eax
   jmp show_begin


home:
   mov the_offset_page, dword ptr 0
   jmp show_begin

the_end:
   mov edx, 0    ;offset = file_size - file_size % 256;
   mov eax, file_size
   mov ebx, 256
   div ebx
   mov eax, file_size
   sub eax, edx
   mov the_offset_page, eax

   cmp eax, file_size
   je End_true
   jmp show_begin

End_true:
   mov eax, file_size
   sub eax, 256
   mov the_offset_page, eax
   jmp show_begin


the_esc:



close:
   mov ah, 3Eh  ;�ر��ļ�
   mov bx, handle
   int 21h

exit:          ;�˳�
   mov ah, 4Ch
   mov al, 0
   int 21h

code ends
end main