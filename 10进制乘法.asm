.386
data segment

num1 dw 1 dup(0);����1��
num2 dw 1 dup(0);����2��
mul_result dd 1 dup(0);

out_10 db 11 dup(0) ;ʮ�������
out_16 db 9 dup(0) ;ʮ���������
out_2 db 4 dup(0) ;���������

data ends

code segment use16
assume cs:code, ds:data

clear:  ;�����������У�����Ĵ���
   mov dl , 0Dh
   mov ah, 2
   int 21h ;�������
   mov dl , 0Ah
   mov ah, 2
   int 21h ;�������
   mov eax, 0
   mov ebx, 0
   mov ecx, 0
   mov edx, 0

   ret


main:
   mov ax, data
   mov ds, ax
   mov si, 0Ah  ;����ʮ���Ƴ���10����input_done��ʱ����ɹ���

inputnum1:  ;��������1
   mov ah, 1
   int 21h      ;  AL=getchar()��ѭ������
   cmp al, 0Dh  ;����ǻس���ȥ������һ������
   je inputnum2_pre
   sub al, '0'  ;��ax��Ϊ����ֵ
   mov ah, 0
   mov bx, ax   ;������ֵ����bx
   
   mov ax, num1 ;ax�����Ѿ��ۼƵ�ֵ
   mul si       ;ԭ����ֵ�Ŵ�10���������������ֵ
   add ax, bx
   mov num1, ax ;��Ϊ����

   jmp inputnum1

inputnum2_pre:
   mov dl, 0Ah   ;����21h/2�����
   mov ah, 2
   int 21h

inputnum2:   ;��������2
   mov ah, 1
   int 21h      ;  AL=getchar()��ѭ������
   cmp al, 0Dh  ;����ǻس���ȥ������һ������
   je do_mul
   sub al, '0'  ;��ax��Ϊ����ֵ
   mov ah, 0
   mov bx, ax   ;������ֵ����bx
   
   mov ax, num2 ;ax�����Ѿ��ۼƵ�ֵ
   mul si       ;ԭ����ֵ�Ŵ�10���������������ֵ
   add ax, bx
   mov num2, ax

   jmp inputnum2

do_mul:   ;���г˷�
   mov dl, 0Ah   ;����21h/2������С�
   mov ah, 2
   int 21h

   mov ax, num1  ;���г˷�
   mov bx, num2
   mul bx
   mov ebx, edx  ;����ĸ�λ������λebx������16λ��
   shl ebx, 10h
   add ebx, eax  ;�õ�������
   mov mul_result , ebx


;�����￪ʼ��ӡʮ���ƽ��

print_10_start:  ;׼����ӡʮ����
;eax��ų˷��Ľ����ebx�зŽ�����10��si�������±꣬��1��ʼ

   mov edx, 0
   mov ebx, 0Ah
   mov eax, mul_result  ;eax�д���˷��Ľ��ֵ
   mov esi, 1

transform_10:   ;ʮ����ת���������������10_out
   cmp eax, 0   ;����������0����ʼ��ӡ
   je print_10_pre
   div ebx      ;����10������������׼����������飬ʣ�����ֽ���ѭ����
   add dl, '0'
   mov out_10[esi],dl
   add esi, 1
   mov edx , 0   ; ����edx����
   jmp transform_10

print_10_pre:
   sub esi, 1  ;��ȥ�����siֵ��

print_10:  ;��ӡ10���ƽ��
   cmp esi ,0
   je print_10_done
   mov dl , out_10[esi]
   mov ah, 2
   int 21h ;���
   sub esi, 1
   jmp print_10

print_10_done:
   call clear




;�������ݴ�ӡ16���ƽ��


print_16_start:  ;׼����ӡʮ������
;eax��ų˷��Ľ����ebx�зŽ�����16��si�������±꣬��1��ʼ
   mov dx, 10h  ;�ȴ���10h��Ϊ֮��2���ƴ�ӡֹͣ�ı����
   push dx
   mov edx, 0
   mov ebx, 10h
   mov eax, mul_result
   mov esi, 1

transform_16:   ;ʮ����ת���������������10_out
   cmp eax, 0   ;����������0����ʼ��ӡ
   je print_16_pre
   div ebx      ;����10������������׼����������飬ʣ�����ֽ���ѭ����

   push dx    ;�ѽ�������ջΪ2������׼����
   cmp dl, 10  ;ת��Ϊ����
   jb isnum
   jmp isword

isnum:  ;0-9
   add dl, '0'
   mov out_16[esi],dl
   add esi, 1
   mov edx , 0   ; ����edx����
   jmp transform_16

isword:  ;A-F
   sub dl, 10
   add dl, 'A'
   mov out_16[esi],dl
   add esi, 1
   mov edx , 0   ; ����edx����
   jmp transform_16

print_16_pre:
   mov esi, 8  ;��ΪҪ�����λ��ֱ�Ӹ�ֵesiΪ8

print_16:   ;��ӡ16����
   cmp esi ,0
   je print_16_done
   mov dl , out_16[esi]
   cmp dl , 0  ;�����0,���0,
   jne print_16_2
print_16_1:
   add dl , '0'
print_16_2:
   mov ah, 2
   int 21h ;���
   sub esi, 1
   jmp print_16

print_16_done: 
   mov dl , 'h'  ;�ڽ�β���һ��h��ʾ16���ơ�
   mov ah, 2
   int 21h ;���
   call clear


;�������ݴ�ӡ2���ƽ��
;������ͨ�������ջ��16���ƽ������ã��Ա�֤4λ4λ�����
;һ��16����������Ҫ���Ĵ�2���õ������Ƕ�Ӧ�Ķ�����ֵ
;����si���2�Ĵ�����ͬʱ��Ϊ�洢�����ƽ�����±ֱ꣬�ӵ�����뷽���������
;bl��Ҫ���Ľ���2


print_2_start:  ;׼����ӡ2����
   mov si, 3  
   mov bl, 2
   pop ax     ;�����ջ�е�ʮ�����ƽ����
   cmp ax,10h  ;���������־����������ӡ
   je print_2_done

transform_2:
   div bl
   mov out_2[esi],ah   
   mov ah, 0
   sub si, 1
   cmp si, 0FFFFh ;����4�������һ��16�������ļ���
   je print_2
   jmp transform_2

print_2:  ;��ӡһ��16��������2���ƽ��
   add si, 1
   cmp esi, 4
   je print_2_tail
   mov dl, out_2[esi]
   add dl, '0'
   mov ah, 2
   int 21h ;���
   jmp print_2

print_2_tail:  ;�ڽ�β��ӡһ���ո�
   mov dl, ' '
   mov ah, 2
   int 21h ;���
   jmp print_2_start


print_2_done:  ;����������ӡ�������Ƚ���һ���˸�ɾ����β�Ŀո��ڴ�ӡһ����ĸB��ʾ�����ơ�
   mov dl, 08h
   mov ah, 2
   int 21h   
   mov dl, 'B'
   mov ah, 2
   int 21h
   call clear


exit:          ;�˳�
   mov ah, 4Ch
   int 21h

code ends
end main