.data
spacerstring: .asciz "--\n"
fstring: .asciz "%d \n"
s: .space 1024
blocksize: .space 4
fid: .space 1
.text
.global main
_print: #push element
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    movl 8(%ebp), %eax
    pushl %ecx
    pushl %edx

    push %eax
    movl $fstring, %edx
    pushl %edx
    call printf
    addl $8, %esp
    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret
_spacer:
    pushl %eax
    pushl %ecx
    pushl %edx
    pushl $spacerstring
    call printf
    addl $4, %esp
    popl %edx
    popl %ecx
    popl %eax
    ret
PRINT:  #push size
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx
    pushl %edi
    movl 8(%ebp), %eax
    movl $s, %edi
    xorl %ecx, %ecx
    et_print_loop:
        cmp %eax, %ecx
        je et_print_loop_exit 
        xorl %edx, %edx
        movb (%edi, %ecx, 1),%dl
        push %edx
        call _print
        addl $4, %esp
        incl %ecx
        jmp et_print_loop
        et_print_loop_exit:
    popl %edi
    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret
FIT: #push blocksize; push fid
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %ecx
    pushl %edi
    pushl %edx
    movl $s, %edi #edi = vector(s)
    movl 8(%ebp), %ecx
    movb %cl, fid
    movl 12(%ebp), %ecx
    movl %ecx, blocksize
    xorl %ecx, %ecx #i=0
    xorl %ebx, %ebx #c0=0
    xorl %eax, %eax #i0=0
    #INIT ^^^
    
    FIT_loop:
            
        cmp $1024, %ecx
        je FIT_loop_exit
        xorl %edx, %edx
        movb (%edi, %ecx, 1), %dl #dl=s[i]

        cmpb fid, %dl   #cmp fid cu s[i]
        je FIT_return_m1    #fid == s[i]
        
        cmpb $0, %dl    #cmp 0 cu s[i]
        jne FIT_else
        incl %ebx       #s[i]==0 >> ebx++ (c0++)
        jmp FIT_else_exit
        FIT_else:       #s[i]!=0
            xorl %ebx, %ebx #c0=0
            incl %ecx
            movl %ecx, %eax #i0=i+1
            subl $1, %ecx
            FIT_else_exit:
        inc %ecx
        jmp FIT_loop

        cmp blocksize, %ebx
        je FIT_return_i0

        FIT_return_m1:
            movl $-1, %eax
            jmp FIT_loop_exit
        FIT_return_i0:
            jmp FIT_loop_exit
        FIT_loop_exit:
    popl %edx
    popl %edi
    popl %ecx
    popl %ebx
    popl %ebp
    ret
ADD: #push kbsize; push fid
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    pushl %ecx
    pushl %eax
    pushl %edx
    movl 12(%ebp), %eax # eax = kbsize
    movl 8(%ebp), %edi
    xorl %edx, %edx
    movl $8, %ecx
    divl %ecx #eax = blocksize(kbsize/8)

    cmpl $0, %edx   #daca kbsize nu e mult de 8
    je ADD_rotund_end
    incl %eax       #ceil %eax
    ADD_rotund_end:

    cmp $2, %eax #eax < 1
    jnl ADD_min_2
    mov $2, %eax
    ADD_min_2:

    movl %eax, blocksize
    pushl blocksize 
    pushl %edi
    call FIT
    addl $8, %esp
    cmp $-1, %eax #cmp poz cu -1
    je ADD_exit

    movl %eax, %ecx #i=startpos
    addl blocksize, %eax #end
    movl 8(%ebp), %edx #edx = fid
    movl $s, %edi
    #ecx=i0(start) eax=i0+blocksize(end) edi=$s dl=fid
    ADD_loop:

        cmp %eax, %ecx
        je ADD_exit
        movb %dl, (%edi, %ecx, 1)
        inc %ecx
        jmp ADD_loop

    ADD_exit:
    popl %edx
    popl %eax
    popl %ecx
    popl %edi
    popl %ebp
    ret
GET:#push fid
    pushl %ebp
    movl %esp, %ebp
    movl $-1, %eax
    movl $-1, %edx
    pushl %ebx
    movl 8(%ebp), %ebx  #ebx = fid
    pushl %edi
    movl $s, %edi       #edi = $s
    pushl %ecx
    xorl %ecx, %ecx     #ecx = 0

    GET_loop:
        cmpl $1024, %ecx
        je GET_loop_exit
        
        cmpl $-1, %eax
        jne GET_cmp1_end
        cmpb (%edi, %ecx, 1), %bl #cmp v[i] cu fid
        jne GET_cmp1_end
        movl %ecx, %eax
        GET_cmp1_end:

        cmpb (%edi, %ecx, 1), %bl #cmp v[i] cu fid
        jne GET_cmp2_end
        movl %ecx, %edx
        GET_cmp2_end:

        cmpb (%edi, %ecx, 1), %bl #cmp v[i] cu fid



        incl %ecx
        jmp GET_loop
        GET_loop_exit:

    cmp $-1, %eax
    jne GET_exit
    movl $0, %eax
    movl $0, %edx

    GET_exit:
    popl %ecx
    popl %edi
    popl %ebx
    popl %ebp
    ret
DELETE:# push fid
    
    pushl %ebp
    movl %esp, %ebp
    pushl %ecx
    pushl %edi
    pushl %ebx
    movl $s, %edi
    movl 8(%ebp), %ebx

    pushl %ebx
    call GET        #[eax edx]
    add $4, %esp

    movl %eax, %ecx
    DELETE_loop:
        cmpl %edx, %ecx
        jg DELETE_loop_exit

        movb $0, (%edi, %ecx, 1)

        incl %ecx
        jmp DELETE_loop
        DELETE_loop_exit:

    popl %ebx
    popl %edi
    popl %ecx
    popl %ebp
    ret
DEFRAGMENTATION:
    pushl %ebp
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %esi

    movl $s, %edi   #edi = $s
    movl $0, %esi   #esi(sorted) = false
    DEFRAGMENTATION_while_loop:
        cmpl $0, %esi
        jne DEFRAGMENTATION_while_loop_end

        xorl %ecx, %ecx
        DEFRAGMENTATION_fori_loop:
            cmpl $1023, %ecx
            je DEFRAGMENTATION_fori_loop_end

            movl $1, %esi   #esi(sorted) = true
            xorl %edx, %edx
            movb (%edi,%ecx,1),%dl #dl=s[i]
            incl %ecx
            movb (%edi,%ecx,1),%dh #dh=s[i+1]
            subl $1, %ecx

            xorl %eax, %eax
            cmpb $0, %dl
            jne if1_end
            incl %eax
            if1_end:
                cmpb $0, %dh
                je if2_end
                incl %eax
                if2_end:
                cmpl $2,%eax
                jne DEFRAGMENTATION_if_end
                xorl %esi, %esi   #esi(sorted) = false

                movl %ecx, %ebx
                DEFRAGMENTATION_forj_loop:
                    cmp $1023, %ebx
                    je DEFRAGMENTATION_forj_loop_end

                    xorl %edx, %edx
                    incl %ebx

                    movb (%edi,%ebx,1), %dh

                    subl $1, %ebx
                    movb %dh, (%edi,%ebx,1)

                    inc %ebx
                    jmp DEFRAGMENTATION_forj_loop
                    DEFRAGMENTATION_forj_loop_end:

                DEFRAGMENTATION_if_end:

            incl %ecx
            jmp DEFRAGMENTATION_fori_loop
            DEFRAGMENTATION_fori_loop_end:

        jmp DEFRAGMENTATION_while_loop
        DEFRAGMENTATION_while_loop_end:

    popl %esi
    popl %edi
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
    popl %ebp
    ret

main:
    pushl $64
    pushl $25
    call ADD
    addl $8, %esp

    pushl $16
    pushl $211
    call ADD
    addl $8, %esp



    pushl $16
    call PRINT
    addl $4, %esp

    call _spacer

    pushl $25
    call DELETE
    addl $4, %esp
    
    pushl $1
    pushl $2
    call ADD
    addl $8, %esp


    pushl $16
    call PRINT
    addl $4, %esp

    call _spacer

    call DEFRAGMENTATION

    pushl $16
    call PRINT
    addl $4, %esp
et_exit:
movl $1, %eax
xorl %ebx, %ebx
int $0x80
