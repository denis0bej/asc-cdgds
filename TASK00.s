.data
spacerstring: .asciz "--\n"
fstring: .asciz "%d \n"
readstring: .asciz "%d"
ADDstring: .asciz "%d: (%d, %d)\n"
ADDfull: .asciz "%d: (0, 0)\n"
GETstring: .asciz "(%d, %d)\n"
s: .space 1025
blocksize: .space 4
fid: .space 1
input: .long 0
n: .long 0
addn: .long 0
x1: .long 0
x2: .long 0
buffer: .space 16 # Buffer to hold the input (ajust size as needed) 
buffer_len: .long 16
.text
.global main
_read:
    pushl %ecx
    pushl %edx

    pushl $input
    pushl $readstring
    call scanf
    addl $8, %esp
    movl input, %eax

    popl %edx
    popl %ecx
    ret
    
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
ADD: #push fid; push kbsize
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    pushl %ecx
    pushl %eax
    pushl %edx
    movl 8(%ebp), %eax # eax = kbsize
    movl 12(%ebp), %edi
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
    cmpl $-1, %eax #cmp poz cu -1
    je ADD_error
    addl blocksize, %eax
    cmpl $1024, %eax
    jg ADD_error
    subl blocksize, %eax

    pushl %eax
    pushl %ecx
    pushl %edx

    movl %eax, %ecx
    addl blocksize, %ecx
    subl $1, %ecx
    
    pushl %ecx
    pushl %eax
    pushl %edi
    pushl $ADDstring
    call printf
    addl $16, %esp

    popl %edx
    popl %ecx
    popl %eax


    movl %eax, %ecx #i=startpos

    addl blocksize, %eax #end
    cmp $1024, %eax
    jg ADD_error

    movl 12(%ebp), %edx #edx = fid
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
    
    ADD_error:

    movl %eax, %ecx
    addl blocksize, %ecx
    subl $1, %ecx
    
    pushl 12(%ebp)
    pushl $ADDfull
    call printf
    addl $8, %esp

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

    cmpl $0, %edx
    je DELETE_loop_exit

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
        movl $1, %esi   #esi(sorted) = true !!!!
        DEFRAGMENTATION_fori_loop:
            cmpl $1024, %ecx
            je DEFRAGMENTATION_fori_loop_end

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
                    cmp $1024, %ebx
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
        cmp $0, %esi
        jne if_end
        subl $2, %ecx
        if_end:
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
ADD_while:
    pushl %ecx
    call _read
    movl %eax, addn
    
    xorl %ecx, %ecx
    ADD_repeater:
    cmpl addn, %ecx
    jge ADD_repeater_exit

    call _read
    movl %eax, x1
    call _read
    movl %eax, x2

    pushl %ecx
    pushl x1
    pushl x2
    call ADD
    addl $8, %esp
    popl %ecx

    incl %ecx
    jmp ADD_repeater
    ADD_repeater_exit:

    popl %ecx
    ret
GET_call:
    pushl %eax
    call _read

    pushl %eax
    call GET
    add $4, %esp

    pushl %edx
    pushl %eax
    pushl $GETstring
    call printf
    popl %eax
    popl %edx
    addl $4, %esp

    popl %eax
    ret
PRINT_storage:
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %ebp

    movl $s, %edi
    xorl %ecx, %ecx
    xorl %edx, %edx
    xorl %ebx, %ebx #%ebx = 0, el va fi fid

    PRINT_loop:
        cmpl $1023, %ecx
        jge PRINT_loop_exit

        movb (%edi, %ecx, 1), %dl #dl = v[i]
        incl %ecx
        movb (%edi, %ecx, 1), %dh #dh = v[i+1]
        subl $1, %ecx

        cmpb %bl, %dl
        je PRINT_if_exit

        movl %ecx, %ebp #pastram prima locatie in ebp
        movb %dl, %bl

        PRINT_if_exit:
       
        cmpl $1022, %ecx
        je notdldh
        cmpb %dl, %dh
        je PRINT_if2_exit
        notdldh:
        cmpb %dl, %dh
        jne notincecx
        incl %ecx
        notincecx:

        cmpb $0, %dl
        je DONT_PRINT

        cmpl $1022, %ecx
        

        pushl %eax
        pushl %edx
        pushl %ecx
        pushl %ebp
        xorl %eax, %eax
        movb %dl, %al
        pushl %eax
        pushl $ADDstring #addstring ecx ebp
        call printf
        addl $4, %esp
        popl %eax
        popl %ebp
        popl %ecx
        popl %edx
        popl %eax
        DONT_PRINT:

        PRINT_if2_exit:

        incl %ecx
        jmp PRINT_loop
        PRINT_loop_exit:

    popl %ebp
    popl %edi
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
    ret
DELETE_call:
    pushl %eax

    call _read
    pushl %eax
    call DELETE
    popl %eax

    call PRINT_storage

    popl %eax
    ret
DEFRAGMENTATION_call:
    pushl %eax
    pushl %ecx
    pushl %edx

    call DEFRAGMENTATION

    call PRINT_storage

    popl %edx
    popl %ecx
    popl %eax
    ret
main:
    call _read
    movl %eax, n

    xorl %ecx, %ecx
    main_loop:
    cmp n, %ecx
    jge main_loop_exit
    
    pushl %ecx

    call _read

    cmpl $1, %eax
    jne not_1
    call ADD_while
    not_1:
    cmpl $2, %eax
    jne not_2
    call GET_call
    not_2:
    cmpl $3, %eax
    jne not_3
    call DELETE_call
    not_3:
    cmpl $4, %eax
    jne not_4
    call DEFRAGMENTATION_call
    not_4:
    popl %ecx

    inc %ecx
    jmp main_loop
    main_loop_exit:
    
et_exit:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
