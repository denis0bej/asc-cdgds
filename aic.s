    .data
path:   .asciz "/home/denis0/ASC/location"   # Directory path
fmt:    .asciz "%s\n"                       # Format string for printf
errmsg: .asciz "Error: Unable to open directory\n"

    .text
    .global main

    .extern opendir, readdir, printf, closedir, perror, exit

main:
    # Open directory using opendir
    pushl $path                # Push path onto stack
    call opendir               # Call opendir
    addl $4, %esp              # Clean up stack (4 bytes for path)

    test %eax, %eax            # Check if opendir failed (NULL)
    je handle_error            # Exit if directory could not be opened
    movl %eax, %ebx            # Save DIR* pointer in EBX

read_directory:
    # Read directory entry using readdir
    pushl %ebx                 # Push DIR* onto stack
    call readdir               # Call readdir
    addl $4, %esp              # Clean up stack (4 bytes for DIR*)

    test %eax, %eax            # Check if readdir returned NULL (end of directory)
    je close_directory         # Exit loop if no more entries

    # Access d_name field (offset 0x10 in struct dirent)
    movl 0x10(%eax), %ecx      # Load address of d_name into ECX

    # Print filename using printf
    pushl %ecx                 # Push d_name as argument
    pushl $fmt                 # Push format string as argument
    call printf                # Call printf
    addl $8, %esp              # Clean up stack (2 arguments, 8 bytes total)

    jmp read_directory         # Repeat for next directory entry

close_directory:
    # Close directory using closedir
    pushl %ebx                 # Push DIR* onto stack
    call closedir              # Call closedir
    addl $4, %esp              # Clean up stack (4 bytes for DIR*)

et_exit:
    # Exit program
    pushl $0                   # Push exit code 0
    call exit                  # Call exit

handle_error:
    # Print error message using perror
    pushl $errmsg              # Push error message onto stack
    call perror                # Call perror
    addl $4, %esp              # Clean up stack (4 bytes for errmsg)

    pushl $1                   # Push exit code 1
    call exit                  # Call exi
