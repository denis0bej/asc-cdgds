.data
str_spacer: .asciz "---\n"
str_one: .asciz "%d \n"
str_two: .asciz "%d, %d \n"
str_three: .asciz "%d, %d, %d \n"
readstring: .asciz "%d"
str_full: .asciz "%d: ((0,0),(0,0))\n"
str_el: .asciz "%d: ((%d,%d),(%d,%d))\n"
str_get: .asciz "((%d,%d),(%d,%d))\n"
k24: .long 1024
s: .space 0x100000
blocksize: .space 4
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
.text
.global main
get_next: #line ra ebp
    pushl %ebp
    movl %esp, %ebp
    pushl %ecx
    pushl %edx
    pushl %edi

    movl 8(%esp), %ecx
    incl %ecx
    imull k24, %ecx
    lea s, %edi

    movl $-1, %eax
    get_next_loop:
        cmpl $266240, %ecx
        jge get_next_loop_exit

        cmpb $0, (%edi, %ecx, 1)
            jne found_desc
            jmp found_desc_exit
        found_desc:
            xorl %eax, %eax
            movb (%edi, %ecx, 1), %al
            jmp get_next_loop_exit
        found_desc_exit:

        incl %ecx
        jmp get_next_loop
        get_next_loop_exit:

    popl %edi
    popl %edx
    popl %ecx
    popl %ebp
    ret
get_line: #index = eax
    pushl %ecx
    pushl %edx

    xorl %edx, %edx
    divl k24
    #eax = linia si edx = coloana

    popl %edx
    popl %ecx
    ret
get_col: #index 
    pushl %ecx
    pushl %edx

    xorl %edx, %edx
    divl k24
    #eax = linia si edx = coloana
    movl %edx, %eax

    popl %edx
    popl %ecx
    ret
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
print3:
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %esi

    pushl 8(%ebp)
    pushl 12(%ebp)
    pushl 16(%ebp)
    pushl $str_three
    call printf
    addl $16, %esp

    popl %esi
    popl %edi
    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret
print2:
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %esi

    pushl 8(%ebp)
    pushl 12(%ebp)
    pushl $str_two
    call printf
    addl $12, %esp

    popl %esi
    popl %edi
    popl %edx
    popl %ecx
    popl %eax
    popl %ebp
    ret
print1:
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ecx
    pushl %edx

    pushl 8(%ebp)
    pushl $str_one
    call printf
    addl $8, %esp

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
        cmp $0x100000, %ecx
        jge FIT_loop_exit
        xorl %edx, %edx
        movb (%edi, %ecx, 1), %dl #dl=s[i]

        cmpb fid, %dl       #cmp fid cu s[i]
        je FIT_return_m1    #fid == s[i]
        
        cmpb $0, %dl    #cmp 0 cu s[i]
        jne FIT_else
        incl %ebx       #s[i]==0 >> ebx++ (c0++)
        jmp FIT_else_exit
        FIT_else:       #s[i]!=0
            xorl %ebx, %ebx #c0=0
            incl %ecx
            movl %ecx, %eax #i0=i+1
            decl %ecx
            FIT_else_exit:
        inc %ecx

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %esi
        pushl %edi
        decl %ebx

        xorl %edx, %edx
        movl %eax, %edi #eax este i0, facem copie in edi
        divl k24 # => edx = col a lui i0
        movl %edx, %esi

        addl %ebx, %esi
         #esi este pos ultimului 0
        
        cmpl $1024, %esi
        jl GUCCI
            movl $-1, %edx
        GUCCI:
        popl %edi
        popl %esi
        popl %ecx
        popl %ebx
        popl %eax

        cmpl $-1, %edx
        jne ALL_GOOD_AGAIN
            decl %ecx
            jmp FIT_else
        ALL_GOOD_AGAIN:
        cmpl blocksize, %ebx
        je FIT_return_i0
        jmp FIT_loop

        FIT_return_m1:
            movl $-1, %eax
            jmp FIT_loop_exit
        FIT_return_i0:
            pushl %eax
            xorl %edx, %edx
            divl k24
            popl %eax

            cmpl $1, %edx
            jne FIT_keepeax
            decl %eax
            FIT_keepeax:
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
    movl $-1, %edx
    pushl %ebx
    movl 8(%ebp), %ebx  #ebx = fid
    pushl %edi
    movl $s, %edi       #edi = $s
    pushl %ecx
    xorl %ecx, %ecx     #ecx = 0

    GET_loop:
        cmpl $0x100000, %ecx
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

    movl %eax, blocksize
    pushl blocksize 
    pushl %edi
    call FIT
    addl $8, %esp
    cmpl $-1, %eax #cmp poz cu -1
    je d_ADD_error
    addl blocksize, %eax
    cmpl $0x100000, %eax
    jg d_ADD_error
    subl blocksize, %eax

    pushl %eax
    pushl %ecx
    pushl %edx

    movl %eax, %ecx
    addl blocksize, %ecx
    subl $1, %ecx

    popl %edx
    popl %ecx
    popl %eax

    movl %eax, %ecx #i=startpos

    addl blocksize, %eax #end

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
    addl blocksize, %ecx
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
Defrag_line: #line ra ebp
    pushl %ebp
    movl %esp, %ebp
    pushl %ecx
    pushl %edi
    pushl %esi
    pushl %eax
    pushl %edx

    movl $s, %edi
    movl 8(%ebp), %ecx
    imul k24, %ecx
    addl k24, %ecx
    movl %ecx, d_end
    subl k24, %ecx
    xorl %edx, %edx
    movl %ecx, %esi #esi = j (se misca doar cand != 0)

    D_loop:
        cmpl d_end, %ecx
        je D_loop_exit

        movb (%edi, %esi, 1), %dl #v[j]
        movb (%edi, %ecx, 1), %dh #v[i]

        cmpb $0, %dl
        jne D_not0

        D_is0:
        movb %dh, (%edi, %esi, 1)
        cmpb $0, %dh
        je noInc
            incl %esi
        noInc:
        movb $0, (%edi, %ecx, 1)
        decl %esi
        D_not0:
        incl %esi

        incl %ecx
        jmp D_loop
        D_loop_exit:
        
    movl d_end, %edx
    subl %esi, %edx #edx numarul de 0
    movl %esi, %eax #eax primul 0

    popl %edx
    popl %eax
    popl %esi
    popl %edi
    popl %ecx
    popl %ebp
    ret
get_zero: #line ra ebp #eax=i0 %edx=c0
    pushl %ebp
    movl %esp, %ebp
    pushl %ecx
    pushl %edi
    pushl %esi
    pushl %edx

    movl $-1, %esi
    lea s, %edi
    movl 8(%ebp), %ecx
    imull k24, %ecx
    movl %ecx, %eax
    addl k24, %eax

    zero_loop:
        cmpl %eax, %ecx
        jge zero_loop_exit

        cmpb $0, (%edi, %ecx, 1)
        jne not_0
        movl %ecx, %esi
        jmp zero_loop_exit
        not_0: #esi = first 0 index

        incl %ecx
        jmp zero_loop
        zero_loop_exit:
    cmpl $-1, %esi
    je zeronotfound
    zeronotfound:
    movl %eax, %edx
    subl %esi, %edx
    movl %esi, %eax
    movl %edx, %eax

    popl %edx
    popl %esi
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
    xorl %ecx, %ecx
    D_Defrag_init:
        cmpl $260, %ecx
        jge D_Defrag_init_exit
        
        pushl %ecx
        call Defrag_line
        popl %ecx

        incl %ecx
        jmp D_Defrag_init
        D_Defrag_init_exit:
    xorl %ecx, %ecx
    Defrag_loop:
        cmpl $259, %ecx
        jge Defrag_loop_exit

        pushl %ecx
        call Defrag_line
        popl %ecx

        pushl %ecx
        call get_next
        popl %ecx

        movl %eax, %esi
 
        cmpl $-1, %esi
        je Defrag_loop_exit #daca nu am gasit next id atunci nu mai are sens sa continui, e gata

        pushl %ecx
        call get_zero
        popl %ecx
        movl %eax, %edi

        pushl %esi
        call GET
        popl %esi

        subl %eax, %edx
        incl %edx

        cmpl %edi, %edx
        jg doesnt_fit

        pushl %eax
        pushl %edx
        pushl %esi
        call DELETE
        popl %esi
        popl %edx
        popl %eax

        pushl %esi
        imull $8, %edx
        pushl %edx
        call dADD
        popl %edx
        popl %esi

        jmp Defrag_loop

        doesnt_fit:
        incl %ecx
        jmp Defrag_loop
        Defrag_loop_exit:
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

    xorl %ecx, %ecx
    lea s, %edi

    pushl $0
    call get_next
    addl $4, %esp

et_exit:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
