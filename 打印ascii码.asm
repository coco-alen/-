.386
data segment use16
hex db 3 dup(0)   ;���ڴ洢ascii���16�������֣�1�Ǹ�λ 0�ǵ�λ��
ascii db 0        ;��ǰ������ascii��ֵ
data ends

code segment use16
assume cs:code, ds:data
;ax�����ַ���ʾ�ļĴ�
;bx����������ʾ�ļĴ�
;di��ƫ�Ƶ�ַ
;cl���ascii��
;ch���пո������ѭ��
;dl���ڼ�������
;si���ڼǵ�һ�е�n�������Ӧ��ƫ�Ƶ�ַ

main:
   mov ax, 0B800h
   mov es, ax   ;���ִ�ε�ַ����es
   mov ax, data ;����data�е�����
   mov ds, ax   

   mov dx, 0  ;  ��ʼ��dx
   mov ah, 0CH ; ��ɫ������������ɫǰ��
   mov bh, 0AH ; ��ɫ������������ɫǰ��
   mov si, 0  ;  ��ʼ��dlΪ0����ʾ�ڵ�0�е�ƫ�Ƶ�ֵַ

again:  ;��ѭ��
   mov dl, 19h   ; dl��ֵΪ19h�����������ļ��������ܹ�19h�У�
   mov di, si    ; ��ƫ�Ƶ�ַ�ƶ�����һ�е�n�У������n����һ���б���ӡ�������

a_line:  ;��ӡһ��
   mov cl, ascii
   mov al, cl               ; ���뵽��Ӧ��ascii�롣
   mov word ptr es:[di], ax ; ��ӡascii���µ��ַ�
                            ;mov byte ptr es:[di], al
                            ;mov byte ptr es:[di+1], ah
   add di, 2                ;��x�������ƶ�һ��
   and cx, 0000000000001111B ; 000Fh  ;ȡ��ascii��ĵ�4λ
   cmp cx, 10        ;�Ƚ����һλ16�������Ƿ�С��10
   jb is_digit0      ;���С��10

is_alpha0:     ;�����С��10
   sub cl, 10
   add cl, 'A'     ;ת��Ϊ���������ĸ
   jmp deal_hex0
is_digit0:     ;���С��10
   add cl, '0'       ;ת��Ϊ�����������
   jmp deal_hex0
   
deal_hex0:         ;�����ݴ���hex[0]
   mov hex[0], cl  ;��������cx�������λ����16���Ƶĵ�λ
   mov cl, ascii   ;���°�ascii����cl��׼���洢16���Ƶĵ�λ
   rol cl, 4       ;ѭ��������λ
   and cx, 0000000000001111B; 000Fh;ȡ��ascii��ĵ�4λ�����������ˣ������ǵͰ�λ�ĸ���λ����16���Ƶĸ�λ
   cmp cx, 10     ;�Ƚ����һλ16�������Ƿ�С��10
   jb is_digit1   ;���С��10

is_alpha1:   ;ͬ��is_alpha0
   sub cl, 10
   add cl, 'A'
   jmp deal_hex1
is_digit1:   ;ͬ��is_digit0
   add cl, '0'

deal_hex1:     ;�Ѵ���õ����ִ���hex[1]
   mov hex[1], cl
   mov cl, ascii   ;���°�ascii����cl��׼����������

printnum:         ;��ӡ��Ӧ��ascii������

   mov bl, hex[1]  ;��ӡ��Ӧ��ascii��16���Ƹ�λ����
   mov word ptr es:[di], bx  
   add di, 2

   mov bl, hex[0]   ;��ӡ��Ӧ��ascii��16���Ƶ�λ����
   mov word ptr es:[di], bx  
   add di, 2

   mov ch, 4       ;��ʼ��chΪ4������ѭ������ո�
   jmp add_block 

add_block:   ;����ո�
   mov bl, 20h      ;�ո��ASCII��
   mov word ptr es:[di], bx  ;����ո�
   add di, 2h

   sub ch, 1   ;����ѭ��4��
   jnz add_block  

   add di, 92h  ;��ƫ�Ƶ�ַ��λ���ƶ�����n�� ��һ�еĿ�ͷ
   add ascii, word ptr 1     ;������ASCII���1
   cmp ascii, word ptr 0     ;����Ƚ�ascii�룬�����0˵��ѭ����0-255�ˣ�ȫ����ʾ��ɣ������˳�
   je exit

   sub dl, 1       ;���ڼ�¼��ѭ����dl��һ
   jnz a_line      ;����0˵����ӡ��19h��
   add si, 0Eh     ; si�ƶ�����һ����һ�ж�Ӧ��ƫ�Ƶ�ַ
   cmp si, 8Ch     ;�������������10��������ӡ
   jbe again       ;����ȥ��ӡ��һ��


exit:          ;�˳�
   mov ah, 1
   int 21h; �������룬�𵽵ȴ��ü�������
   mov ah, 4Ch
   int 21h

code ends
end main

