.data
fstring: .asciz "%f\n"
v: .float 0.2,0.3,0.1,0.4
log: .space 4
n: .long 4
s: .space 4
unu: .float -1.0
.text
.global main
main:
xorl %ecx,%ecx
xorps %xmm2,%xmm2 #aici bag suma
loop:

cmpl n,%ecx
je loop_exit

mov $v, %edi
push %ecx
push (%edi,%ecx,4) #%xmm1
call logf
fstps s #log v[i]
add $4,%esp
pop %ecx

movss s,%xmm0

movss (%edi,%ecx,4), %xmm1

mulss %xmm0,%xmm1
addss %xmm1,%xmm2
movss %xmm2,s
incl %ecx
jmp loop
loop_exit:
movss %xmm2,s
#movss unu,%xmm3
et_exit:
mov $1,%eax
xor %ebx,%ebx
int $0x80
