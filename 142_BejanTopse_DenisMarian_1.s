.data
str_spacer: .asciz "---\n"
str_one: .asciz "%d \n"
str_two: .asciz "%d, %d \n"
str_three: .asciz "%d, %d, %d \n"
readstring: .asciz "%d"
pathformat: .asciz "%s"
str_full: .asciz "%d: ((0, 0), (0, 0))\n"
str_el: .asciz "%d: ((%d, %d), (%d, %d))\n"
str_get: .asciz "((%d, %d), (%d, %d))\n"
path: .space 1000
k24: .long 1024
s: .space 0x100000
blocksize: .space 4
dblocksize: .long 0
fid: .space 1
input: .long 0
n: .long 0
addn: .long 0
x1: .long 0
x2: .long 0
d_end: .long 0
start0: .long 0
count0: .long 0
end0: .long 0
i0: .long 0
index: .long 0
buffer: .space 4096
buffer_propr: .space 128
.text
.global main
print_el: #fid index1 index2
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx

    xorl %edx, %edx
    movl 8(%ebp), %eax
    divl k24 #line = eax col = edx
    movl 16(%ebp), %ecx #ecx = fid

    pushl %edx
    pushl %eax

    xorl %edx, %edx
    movl 12(%ebp), %eax
    divl k24 #line = eax col = edx

    pushl %edx
    pushl %eax
    pushl %ecx
    pushl $str_el
    call printf
    addl $24, %esp

    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret
print_get: #index1 index2 ra ebp
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx

    xorl %edx, %edx
    movl 8(%ebp), %eax
    divl k24 #line = eax col = edx

    pushl %edx
    pushl %eax

    xorl %edx, %edx
    movl 12(%ebp), %eax
    divl k24 #line = eax col = edx

    pushl %edx
    pushl %eax
    pushl $str_get
    call printf
    addl $20, %esp

    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret
spacer:
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx

    pushl $str_spacer
    call printf
    addl $4, %esp

    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret

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

FIT: #push blocksize; push fid
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
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
    movl $-1, %esi #i0=esi, presupunem ca nu incape
    #INIT ^^^
    xorl %edx, %edx #dl = v[i]
    FIT_loop:
        cmpl $0x100000, %ecx
        jge FIT_loop_exit

        xorl %edx, %edx
        movb (%edi, %ecx, 1), %dl # dl = v[i]
        cmpl fid, %edx
        je element_is_already_present

        cmpl $-1, %esi
        jne location_found

        pushl %edx
        ##
        movl %ecx, %eax
        xorl %edx, %edx
        divl k24
        cmpl $0, %edx
        jne not_new_line
        xorl %ebx, %ebx #resetam numaratoarea 0-urilor pe new line
        not_new_line:
        popl %edx

        cmpl $0, %edx
        jne el_not0
        el_is0:
            incl %ebx #inc 0 counter
            jmp check0_exit
        el_not0:
            xorl %ebx, %ebx #resetam 0 counter
        check0_exit:

        cmpl blocksize, %ebx
        jne doesnt_fit
        fits:
            movl %ecx, %esi
            incl %esi
            subl %ebx, %esi
        doesnt_fit:
        ##
        location_found:

        incl %ecx
        jmp FIT_loop
        FIT_loop_exit:
    movl %esi, %eax
    popl %edx
    popl %edi
    popl %ecx
    popl %ebx
    popl %esi
    popl %ebp
    ret
    element_is_already_present:
    movl %esi, %eax
    popl %edx
    popl %edi
    popl %ecx
    popl %ebx
    popl %esi
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
    cmpl $0x100000, %eax
    jg ADD_error
    subl blocksize, %eax

    pushl %eax
    pushl %ecx
    pushl %edx

    movl %eax, %ecx
    addl blocksize, %ecx
    subl $1, %ecx
    
    pushl %edi
    pushl %eax
    pushl %ecx
    call print_el
    addl $12, %esp

    popl %edx
    popl %ecx
    popl %eax

    movl %eax, %ecx #i=startpos

    addl blocksize, %eax #end
    #cmp $1024, %eax
    #jg ADD_error

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
    pushl $str_full
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
    pushl %ebx
    movl 8(%ebp), %ebx  #ebx = fid
    pushl %edi
    movl $s, %edi       #edi = $s
    pushl %ecx
    xorl %ecx, %ecx     #ecx = 0
    GET_loop:
        cmpl $0x100000, %ecx
        jge GET_loop_exit
        
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

        incl %ecx
        jmp GET_loop
        GET_loop_exit:

    cmpl $-1, %eax
    jne GET_exit
    movl $0, %eax
    movl $0, %edx

    GET_exit:

    popl %ecx
    popl %edi
    popl %ebx
    popl %ebp
    ret

dFIT: #push blocksize; push fid
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %ebx
    pushl %ecx
    pushl %edi
    pushl %edx
    movl $s, %edi #edi = vector(s)
    movl 8(%ebp), %ecx
    movb %cl, fid
    movl 12(%ebp), %ecx
    movl %ecx, dblocksize

    xorl %ebx, %ebx #c0=0
    movl $-1, %esi #i0=esi, presupunem ca nu incape
    #INIT ^^^
    xorl %edx, %edx #dl = v[i]

    movl index, %ecx

    dFIT_loop:
        cmpl $0x100000, %ecx
        jge dFIT_loop_exit

        xorl %edx, %edx
        movb (%edi, %ecx, 1), %dl # dl = v[i]
        cmpl fid, %edx
        je delement_is_already_present

        cmpl $-1, %esi
        jne dlocation_found

        pushl %edx
        ##
        movl %ecx, %eax
        xorl %edx, %edx
        divl k24
        cmpl $0, %edx
        jne dnot_new_line
        xorl %ebx, %ebx #resetam numaratoarea 0-urilor pe new line
        dnot_new_line:
        popl %edx

        cmpl $0, %edx
        jne del_not0
        del_is0:
            incl %ebx #inc 0 counter
            jmp dcheck0_exit
        del_not0:
            xorl %ebx, %ebx #resetam 0 counter
        dcheck0_exit:

        cmpl dblocksize, %ebx
        jne ddoesnt_fit
        dfits:
            movl %ecx, %esi
            incl %esi
            subl %ebx, %esi
        ddoesnt_fit:
        ##
        dlocation_found:

        incl %ecx
        jmp dFIT_loop
        dFIT_loop_exit:
    movl %esi, %eax
    popl %edx
    popl %edi
    popl %ecx
    popl %ebx
    popl %esi
    popl %ebp
    ret
    delement_is_already_present:
    movl %esi, %eax
    popl %edx
    popl %edi
    popl %ecx
    popl %ebx
    popl %esi
    popl %ebp
    ret

dADD: #push fid; push kbsize
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
    je d_ADD_rotund_end
    incl %eax       #ceil %eax
    d_ADD_rotund_end:

    cmp $2, %eax #eax < 1
    jnl d_ADD_min_2
    mov $2, %eax
    d_ADD_min_2:

    movl %eax, dblocksize
    pushl dblocksize 
    pushl %edi
    call dFIT
    addl $8, %esp
    cmpl $-1, %eax #cmp poz cu -1
    je d_ADD_error
    addl dblocksize, %eax
    cmpl $0x100000, %eax
    jg d_ADD_error
    subl dblocksize, %eax

    pushl %eax
    pushl %ecx
    pushl %edx

    movl %eax, %ecx
    addl dblocksize, %ecx
    subl $1, %ecx

    popl %edx
    popl %ecx
    popl %eax

    movl %eax, %ecx #i=startpos

    addl dblocksize, %eax #end
    movl %eax, index
    decl index

    movl 12(%ebp), %edx #edx = fid
    movl $s, %edi
        #ecx=i0(start) eax=i0+blocksize(end) edi=$s dl=fid
    d_ADD_loop:

        cmp %eax, %ecx
        je d_ADD_exit
        movb %dl, (%edi, %ecx, 1)
        inc %ecx
        jmp d_ADD_loop

    d_ADD_exit:
    popl %edx
    popl %eax
    popl %ecx
    popl %edi
    popl %ebp
    ret
    
    d_ADD_error:

    movl %eax, %ecx
    addl dblocksize, %ecx
    subl $1, %ecx

    popl %edx
    popl %eax
    popl %ecx
    popl %edi
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

    xorl %ecx, %ecx
    DELETE_loop:
        cmpl $0x100000, %ecx
        jge DELETE_loop_exit

        cmpb (%edi, %ecx, 1), %bl
        jne not_equal
            movb $0, (%edi, %ecx, 1)
        not_equal:

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

    leal s, %edi

    xorl %ecx, %ecx
    xorl %ebx, %ebx
    Defrag_loop:
        cmpl $0x100000, %ecx
        jge Defrag_loop_exit

        movb (%edi, %ecx, 1), %bl

        cmpb $0, %bl
        je def_skip
            pushl %ebx
            call GET
            call DELETE
            popl %ebx
            #eax = first index of desc
            #edx = last index of desc
            subl %eax, %edx
            incl %edx
            #eax = lungime desc
            addl %edx, %ecx
            decl %ecx
            imull $8, %edx
            #eax = kb size desc
            pushl %ebx
            pushl %edx
            call dADD
            popl %edx
            popl %ebx
            def_skip:

        incl %ecx
        jmp Defrag_loop
        Defrag_loop_exit:

    movl $0, %esi
    movl %esi, index
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

    pushl %eax
    pushl %edx
    call print_get
    popl %edx
    popl %eax

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
        cmpl $0xFFFFF, %ecx
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
       
        cmpl $0xFFFFE, %ecx
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
        pushl %eax

        xorl %eax, %eax
        movb %dl, %al
        pushl %eax
        push %ebp
        pushl %ecx
        call print_el
        addl $12, %esp
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
CONCRETE:
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %esi
    pushl %ebp

    movl $5, %eax
    leal path, %ebx
    movl $0x10000, %ecx
    xorl %edx, %edx
    int $0x80

    movl %eax, %edi #edi = descriptorul folderului deschis
    
    movl $141, %eax
    movl %edi, %ebx
    movl $buffer, %ecx
    movl $4096, %edx
    int $0x80

    movl %eax, %esi #esi = cati bytes am citit

    leal buffer, %ecx
    movl (%ecx), %ebx #lungimea segmentului de la file
    addl %ecx, %ebx
    addl 10(%ecx), %ecx #ignoram partile irelevante

    movl $5, %eax
    leal (%ecx), %ebx
    xorl %ecx, %ecx
    xorl %edx, %edx
    int $0x80

    movl %eax, %ebp

    movl $108, %eax 
    movl %edi, %ebx
    leal buffer_propr, %ecx
    int $0x80

    movl buffer_propr+28, %eax #ecx = file size in bytes
    xorl %edx, %edx
    divl k24

    pushl %ebp
    pushl %eax
    call ADD
    addl $8 ,%esp

    popl %ebp
    popl %edi
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
    ret

CONCRETE_call:
    pushl %eax
    pushl %ecx
    pushl %edx

    pushl $path
    pushl $pathformat
    call scanf
    addl $8, %esp

    call CONCRETE

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
    cmpl $5, %eax
    jne not_5
    call CONCRETE_call
    not_5:
    popl %ecx

    inc %ecx
    jmp main_loop
    main_loop_exit:

    xorl %ecx, %ecx
    lea s, %edi

et_exit:
    pushl $0
    call fflush
    popl %ebx

    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
