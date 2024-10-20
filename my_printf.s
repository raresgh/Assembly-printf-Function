# as -no-pie -g -o printf.o my_printf.s && ld --fatal-warnings --entry main -o printf printf.o
.bss
    variables: .skip 8
    format_string: .skip 64
    signed: .skip 64
    notsigned: .skip 64
    strings: .skip 64
    copy_rax: .skip 8
    copy_rdi: .skip 8
    copy_rsi: .skip 8
    copy_rdx: .skip 8
    copy_rcx: .skip 8
    copy_r8: .skip 8
    copy_r9: .skip 8
    
    #.equ length, hello_end - hello #calculates and saves length as helloend memory - hello which is the length of the input

.data
    percent: .asciz "%" 
    u_param: .quad 10
    counter: .quad 0
    counter2: .quad 0

.global main
.text
    string: .asciz "This %r does nothing. This project has been coded by %s and %s. Everything works %d%%.\n We will take a %u on %s. Here is a negative number %d, positive %d, negative %d.\n"
    string_param: .asciz "and here as well"
    string_param2: .asciz "Assaf"
    string_param3: .asciz "Rares"
    string_param4: .asciz "CO CSE1400"
    minus: .asciz "-------"

main:
	pushq   %rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer


    movq $string, %rdi      #move string into first parameter
    movq $string_param3, %rsi
    movq $string_param2, %rdx
    movq $100, %rcx
    movq $10, %r8
    movq $string_param4, %r9

    pushq $-324
    pushq $120
    pushq $-4234
    call my_printf

    movq	%rbp, %rsp		            # clear local variables from stack
	popq	%rbp			            # restore base pointer location 

    jmp exit

my_printf:
    pushq	%rbp 			            # push the base pointer (and align the stack)
	movq	%rsp, %rbp		            # copy stack pointer value to base pointer

    #pushing callee-saved registers
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movq %rdi, %rbx                     #in rbx we have the string which we get as the first parameter

    while:
        movzbq (%rbx), %rax             #get string that starts at address of rbx in rax
        testb %al, %al                  #compare only one byte(one char)
        je end_string                   #if we reached the end exit the while loop
        
        cmpb $'%', %al                  #check whether the character is a %
        je format_specifier             #we go on the format_specifier to handle the different types of formats

        movq %rbx, %rdi                 #if it is not we move the char into rdi aka the parameter and we call the print_char function

        ################################these are just copies so we don't lose our registers when calling################################
        movq %rsi, copy_rsi 
        movq %rdx, copy_rdx
        movq %rcx, copy_rcx
        movq %r8, copy_r8
        movq %r9, copy_r9
        ################################these are just copies so we don't lose our registers when calling################################
        pushq $0                        #we push 0 on the stack to keep the stack aligned because we call the the funtcion
        call print_char
        popq %r9                        #we pop that 0 of the stack after returning from the function
        ################################these are just copies so we don't lose our registers when calling################################
        movq copy_rsi, %rsi
        movq copy_rdx, %rdx
        movq copy_rcx, %rcx
        movq copy_r8, %r8
        movq copy_r9, %r9
        ################################these are just copies so we don't lose our registers when calling################################

    next:
        incq %rbx                       #increases to the next character in the format string
        jmp while                       #jumps to the next iteration of the loop

end_string:

    #pop callee saved registers
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    movq	%rbp, %rsp		            # clear local variables from stack
	popq	%rbp			            # restore base pointer location 
    ret

print_char:
    pushq   %rbp 			            # push the base pointer (and align the stack)
	movq	%rsp, %rbp		            # copy stack pointer value to base pointer

    movq    $1, %rdx                    # moving the second paramter (length) into the register for how many bytes to write
    movq    %rdi, %rsi                  # moving the first parameter (String) into the register for the data to print
    movq    $1, %rdi                    # moving the value 1 (where to start writing) into the register
    movq    $1, %rax                    # moving the value 1 (syscall print) into the register
    syscall
    
    movq    %rbp, %rsp #epilogue
    popq    %rbp #...
    ret


format_specifier:
    incq %rbx                           #increase to the next character after the percentage                       
    movzbq (%rbx), %rax                 #get the char into rax to compare only one byte of it
 
    cmpb $'%', %al                      
    je percent_case

    cmpb $'d', %al
    je signed_case

    cmpb $'u', %al
    je unsigned_case

    cmpb $'s', %al
    je string_case

    cmpb $0, %al
    je end_string

    decq %rbx                           #this happens if there is nothing following the percent we go back and print it
    movq %rbx, %rdi                     #parameter for the print_char function

    ################################these are just copies so we don't lose our registers when calling################################
    movq %rsi, copy_rsi
    movq %rdx, copy_rdx
    movq %rcx, copy_rcx
    movq %r8, copy_r8
    movq %r9, copy_r9
    ################################these are just copies so we don't lose our registers when calling################################
    pushq $0
    call print_char
    popq %r9
    ################################these are just copies so we don't lose our registers when calling################################
    movq copy_rsi, %rsi
    movq copy_rdx, %rdx
    movq copy_rcx, %rcx
    movq copy_r8, %r8
    movq copy_r9, %r9
    ################################these are just copies so we don't lose our registers when calling################################   
    
    jmp next                            #jump to next iteration of the while loop, basically the next char in the string


percent_case:
    movq %rbx, %rdi                     #we only print the second percentage and load it into rdi

    ################################these are just copies so we don't lose our registers when calling################################
    movq %rsi, copy_rsi             
    movq %rdx, copy_rdx
    movq %rcx, copy_rcx
    movq %r8, copy_r8
    movq %r9, copy_r9
    ################################these are just copies so we don't lose our registers when calling################################
    pushq $0
    call print_char
    popq %r9
    ################################these are just copies so we don't lose our registers when calling################################
    movq copy_rsi, %rsi
    movq copy_rdx, %rdx
    movq copy_rcx, %rcx
    movq copy_r8, %r8
    movq copy_r9, %r9    
    ################################these are just copies so we don't lose our registers when calling################################
       
    jmp next                            #jump to next iteration of the while loop, basically the next char in the string


string_case:
    incq counter                        #counter for the number of parameters so we know when to take from the stack

    #cases which take paran from different registers depending on the counter
    cmpq $5, counter
    jg stackcases
    je register5

    cmpq $3, counter
    jg register4
    je register3

    cmpq $2, counter
    je register2

    jmp register1

    register1:
        movq %rsi, %r14
        jmp loop1
    register2:
        movq %rdx, %r14
        jmp loop1
    register3:
        movq %rcx, %r14
        jmp loop1
    register4:
        movq %r8, %r14
        jmp loop1
    register5:
        movq %r9, %r14
        jmp loop1
    stackcases:
        movq counter, %r13              #copy counter in r13
        subq $4, %r13                   #we substract the number of the parameters(5), but one less because of the call of my_printf function that gets pushed on the stack(-5+1=4)
        movq %rsp, %rcx                 #copy rsp to rcxs
        addq $40, %rcx                  #add 40 to skip over the callee saved registers we pushed in the beggining(8*5)
        movq (%rcx, %r13 , 8), %r14     #gets the desired paramter into r14 to use it later
        
        #this just loops the string and prints it out char by char
        loop1:
            movzbq (%r14), %rax
            testb %al, %al
            je next

            movq %r14, %rdi
            ################################these are just copies so we don't lose our registers when calling################################
            movq %rsi, copy_rsi
            movq %rdx, copy_rdx
            movq %rcx, copy_rcx
            movq %r8, copy_r8
            movq %r9, copy_r9
            ################################these are just copies so we don't lose our registers when calling################################
            pushq $0
            call print_char
            popq %r9
            ################################these are just copies so we don't lose our registers when calling################################
            movq copy_rsi, %rsi
            movq copy_rdx, %rdx
            movq copy_rcx, %rcx
            movq copy_r8, %r8
            movq copy_r9, %r9
            ################################these are just copies so we don't lose our registers when calling################################

            incq %r14
            jmp loop1

unsigned_case:
    incq counter

    cmpq $5, counter
    jg stackcasesu
    je register5u

    cmpq $3, counter
    jg register4u
    je register3u

    cmpq $1, counter
    jg register2u
    je register1u


    register1u:
        movq %rsi, %r14
        jmp unsigned_number
    register2u:
        movq %rdx, %r14
        jmp unsigned_number
    register3u:
        movq %rcx, %r14
        jmp unsigned_number
    register4u:
        movq %r8, %r14
        jmp unsigned_number
    register5u:
        movq %r9, %r14
        jmp unsigned_number
    stackcasesu:
        movq counter, %r13              #copy counter in r13
        subq $4, %r13                   #we substract the number of the parameters(5), but one less because of the call of my_printf function that gets pushed on the stack(-5+1=4)
        movq %rsp, %rcx                 #copy rsp to rcxs
        addq $40, %rcx                  #add 40 to skip over the callee saved registers we pushed in the beggining(8*5)
        movq (%rcx, %r13 , 8), %r14     #gets the desired paramter into r14 to use it later
    
    unsigned_number:
        movq %r14, %rax                 #move the number to rax because we will later divided it by 10
        leaq notsigned+30, %r12         #load buffer address to r12 and start from the end of the buffer(we build the number in reverse order)
        movb $0, (%r12)                 #null terminator at the end of the buffer
        movq %rdx, copy_rdx             #copy of rdx because we are going to use it on division
        while_unsigned:
            
            decq %r12                   #move to the next address in the buffer
            movq $0, %rdx               #here we will store the remainder on the division
            movq $10, %r13              #move 10 to r13 to perform the division
            divq %r13                   #division by 10
            
            addb $48, %dl               #add 48 to what we get because that is the offset from ASCII table for numbers
            movb %dl, (%r12)            #remainder is saved in rdx and we put it in the buffer


            cmpq $0, %rax               #know when to stop and print the number
            je print_number
            jmp while_unsigned

        print_number:
            movq copy_rdx, %rdx         #retrieve the copy of rdx
            cmpb $0, (%r12)             #when it reaches null that is the end
            je next                     #and we jump to the next iteration of the big format string
            
            movq %r12, %rdi             #load character to print

            ################################these are just copies so we don't lose our registers when calling################################
            movq %rsi, copy_rsi
            movq %rdx, copy_rdx
            movq %rcx, copy_rcx
            movq %r8, copy_r8
            movq %r9, copy_r9
            ################################these are just copies so we don't lose our registers when calling################################
            pushq $0
            call print_char
            popq %r9
            ################################these are just copies so we don't lose our registers when calling################################
            movq copy_rsi, %rsi
            movq copy_rdx, %rdx
            movq copy_rcx, %rcx
            movq copy_r8, %r8
            movq copy_r9, %r9 
            ################################these are just copies so we don't lose our registers when calling################################

            incq %r12                   #go to the next digit in the buffer


            jmp print_number


signed_case:
    incq counter

    cmpq $5, counter
    jg stackcasess
    je register5s

    cmpq $3, counter
    jg register4s
    je register3s

    cmpq $1, counter
    jg register2s
    je register1s

    register1s:
        movq %rsi, %r14
        jmp signed_number
    register2s:
        movq %rdx, %r14
        jmp signed_number
    register3s:
        movq %rcx, %r14
        jmp signed_number
    register4s:
        movq %r8, %r14
        jmp signed_number
    register5s:
        movq %r9, %r14
        jmp signed_number
    stackcasess:
        movq counter, %r13              #copy counter in r13
        subq $4, %r13                   #we substract the number of the parameters(5), but one less because of the call of my_printf function that gets pushed on the stack(-5+1=4)
        movq %rsp, %rcx                 #copy rsp to rcxs
        addq $40, %rcx                  #add 40 to skip over the callee saved registers we pushed in the beggining(8*5)
        movq (%rcx, %r13 , 8), %r14     #gets the desired paramter into r14 to use it later
    
    signed_number:
        movq %r14, %rax                 #move the number to rax because we will later divided it by 10
        leaq notsigned+30, %r12         #load buffer address to r12 and start from the end of the buffer(we build the number in reverse order)
        movb $0, (%r12)                 #null terminator at the end of the buffer
        movq %rdx, copy_rdx             #copy of rdx because we are going to use it on division
        cmpq $0, %r14                   #if the number is positive we treat it the same way as in the case of unsigned numbers
        jge while_unsigned              
    negative:                           #this is if it is negative
        movq $-1, %r13                  #we just multiply it with -1 to make it positive
        mulq %r13                       
        movq $minus, %rdi               #and we print a minus before it
        ################################these are just copies so we don't lose our registers when calling################################
        movq %rax, copy_rax
        movq %rsi, copy_rsi
        movq %rdx, copy_rdx
        movq %rcx, copy_rcx
        movq %r8, copy_r8
        movq %r9, copy_r9
        ################################these are just copies so we don't lose our registers when calling################################
        pushq $0
        call print_char
        popq %r9
        ################################these are just copies so we don't lose our registers when calling################################
        movq copy_rsi, %rsi
        movq copy_rdx, %rdx
        movq copy_rcx, %rcx
        movq copy_r8, %r8
        movq copy_r9, %r9 
        movq copy_rax, %rax
        ################################these are just copies so we don't lose our registers when calling################################
        
        jmp while_unsigned              #jump to the unsigned while 

exit:
    movq    $60 , %rax # systemcall code for exit
    movq    $0 , %rdi # normal exit code is 0
    syscall 