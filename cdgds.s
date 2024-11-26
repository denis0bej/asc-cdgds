.data
    bin: .asciz "%s\n"
    dec: .asciz "%d\n"
    s: .space 1024
    fid: .long 25
    blocksize: .long 4
    kbsize: .long 32
.text
.global main

#FITSTART
FIT: #returneaza poz prin eax
    pushl %ebp
    movl %esp, %ebp
    movl $0, %eax #c0
    movl $0, %ecx
    pushl %ebx
    pushl %edi
    pushl %esi
    movl $0, %esi
    movl 8(%ebp), %ebx   #ebx=blocksize
    movl 12(%ebp), %edx  #edx=fid
    movl $s, %edi  #edi=$s
    et_FIT_loop:        #for ecx=0 ecx<1024
        cmpl $1024, %ecx
        je et_FIT_loop_exit
        cmpb %dl, (%edi,%ecx,1) #POATE E ERAORE cmp 4B cu 1B
        
        je et_FIT_loop_ret1

        cmpb $0, (%edi,%ecx,1) #if s[i]==0
        jne et_FIT_else #daca !=0 jmp FIT_else
        incl %eax #c0++
        jmp et_FIT_loop_fin
        et_FIT_else:
            xorl %eax, %eax #c0=0
            incl %ecx
            movl %ecx, %esi #i0=ecx+1
            subl $1, %ecx
        et_FIT_loop_fin:
        cmpl %eax, %ebx #if c0 == blocksize
        je et_FIT_loop_ret2 #return i0

        incl %ecx
        jmp et_FIT_loop
    et_FIT_loop_ret1:
        movl $-1, %eax
        jmp et_FIT_loop_exit
    et_FIT_loop_ret2:
        movl %esi , %eax
        jmp et_FIT_loop_exit
    et_FIT_loop_exit:

    popl %esi
    popl %edi
    popl %ebx
    popl %ebp
    ret
#FITEND



#ADDSTART 
ADD: # fid kbsize <r.a> 
    pushl %ebp
    movl %esp, %ebp
    movl $0, %ecx
    pushl %ebx
    pushl %edi

    movl 8(%ebp), %eax   #eax=kbsize
    movl 12(%ebp), %ebx  #ebx=fid
    movl $8, %edi  #edi=$8
    xorl %edx, %edx #edx=0

    div %edi #eax = eax(kbsize)/edi(8)
    cmp $0, %edx
    je et_ADD_if1
    inc %eax
    et_ADD_if1:
    mov %eax, %edi  #edi=blocksize

    pushl %ebx #fid
    pushl %edi #blocksize
    call FIT   #rez in %eax
    addl $8, %esp
    
    cmpl $-1, %eax #verif daca poz e valida
    je et_ADD_exit
    #for i=poz(%eax); i<poz+blocksize(eax+edi) i++
    movl %eax, %ecx 
    movl %eax, %edx
    addl %edi, %edx #edx = poz + blocksize
    mov $s, %edi #edi = adresa vector
    et_ADD_loop:
        cmp %edx, %ecx #i<poz+blocksize(eax+edi)
        je et_ADD_loop_exit
        mov %ebx, (%edi, %ecx, 1) #s[i]=fID;
        inc %ecx    #i++
        jmp et_ADD_loop
        et_ADD_loop_exit:
    et_ADD_exit:
    popl %ebx
    popl %edi
    popl %ebp
    ret
#ADDEND



main:   

    movl $0, %ecx
    movl $s, %edi
    et_init:
        cmpl $1025, %ecx
        je et_init_exit
        movb $0,(%edi, %ecx, 1)
        incl %ecx
        jmp et_init
        et_init_exit:


    push fid
    push kbsize
    call ADD
    add $8, %esp

    movl $0, %ecx
    movl $s, %edi
    et_print_loop:
        cmpl $8, %ecx
        je et_print_loop_exit

        pushl %ecx

        pushl (%edi, %ecx, 1)
        pushl $dec
        call printf
        addl $8, %esp

        popl %ecx

        incl %ecx
        jmp et_print_loop
        et_print_loop_exit:

et_exit:
    movl $1, %eax           
    xorl %ebx, %ebx           
    int $0x80                  

#########
push %eax
push %ecx
push %edx

push %edx
push $dec
call printf
add $8, %esp

popl %eax
popl %ecx
popl %edx
