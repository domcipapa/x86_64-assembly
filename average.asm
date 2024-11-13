; include some standard c functions
extern printf
extern scanf
extern getchar

section .bss
    ; reserve a quadword (64bits) of space for buffer
    buffer resq 1

section .data
    prompt_message db "Give a number: ", 0
    output_format db "%ld numbers given with sum of %ld, and average of: %.2lf", 10, 0
    error_message db "NaNi?", 10, 0
    exit_format db "Terminated by '%ld', exiting..", 10, 0
    overflow_message db "The result cannot be handled, please enter a smaller number!", 10, 0

    string_format db "%s", 0
    decimal_format db "%ld", 0

    max_value dq 9223372036854775807
    exit_value dq 0

section .text
    ; entry point for the linker (gcc in this case)
    global main

main:
    ; r12 = count, r13 = sum
    mov r12, 1
    mov r13, 0

_loop:
    ; print prompt message
    push rbp
    mov rdi, string_format
    mov rsi, prompt_message
    call printf
    pop rbp

    ; _invalid if _read == 0
    call _read
    cmp rax, 0
    je _invalid

    ; exit if input == exit_value
    mov rax, [buffer]
    cmp rax, [exit_value]
    je _exit

    ; _overflow if buffer > max_value
    mov rax, [buffer]
    cmp rax, [max_value]
    jg _overflow

    ; _overflow if sum > (max_value - buffer)
    mov rax, [max_value]
    sub rax, [buffer]
    cmp r13, rax
    jg _overflow

    ; sum += buffer
    add r13, [buffer]

    ; convert integer to double and divide sum (r13) by count (r12)
    cvtsi2sd xmm0, r13
    cvtsi2sd xmm1, r12
    divsd xmm0, xmm1

    ; print output message
    push rbp
    mov rdi, output_format
    mov rsi, r12
    mov rdx, r13
    call printf
    pop rbp

    ; increment count
    inc r12
    jmp _loop

_invalid:
    ; print error message
    push rbp
    mov rdi, string_format
    mov rsi, error_message
    call printf
    pop rbp

    ; clear buffer
    call _clear_buffer
    jmp _loop

_overflow:
    ; print overflow message
    push rbp
    mov rdi, string_format
    mov rsi, overflow_message
    call printf
    pop rbp

    ; clear buffer
    call _clear_buffer
    jmp _loop

_clear_buffer:
    mov rbx, 0

_clear_buffer_loop:
    call getchar

    cmp rbx, 10
    je _clear_buffer_done

    cmp rbx, 0
    je _clear_buffer_done

    jmp _clear_buffer_loop

_clear_buffer_done:
    ret

_read:
    ; read into buffer
    lea rdi, [decimal_format]
    lea rsi, [buffer]
    call scanf
    ret

_exit:
    ; print exit message
    pop rbp
    mov rdi, exit_format
    mov rsi, [exit_value]
    call printf
    pop rbp

    ; syscall for exit
    mov rax, 60
    xor rdi, rdi
    syscall
