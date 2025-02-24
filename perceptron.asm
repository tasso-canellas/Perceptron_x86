    ; perceptron.asm - Perceptron simples para classificação binária e regressão linear.
    ; Os pesos iniciais e finais são salvos em "pesos.txt".
    ; 
    ; Para regressão, a predição é calculada como:
    ;     predição = (x * weight_x)/1000 + bias
    ; A rotina de treinamento para regressão foi modificada para acumular os
    ; ajustes durante cada época e aplicá-los apenas ao final da época.
    ;
    ; Compile com: nasm -felf64 perceptron.asm && ld -o perceptron perceptron.o

    ; ------------------------- DADOS -------------------------
    section .data
    urandom_file    db "/dev/urandom", 0

    prompt_msg      db "Digite a tarefa (C para Classificacao, R para Regressao): ",0
    prompt_len      equ $ - prompt_msg

    epocas_prompt_msg db 10, "Digite o numero de epocas: ",0
    epocas_prompt_len equ $ - epocas_prompt_msg

    reading_msg     db 10, "Lendo arquivo...",10,0
    reading_len     equ $ - reading_msg

    error_msg       db 10, "Tarefa invalida ou erro de arquivo!",10,0
    error_len       equ $ - error_msg

    class_file      db "classificacao.txt",0
    reg_file        db "regressao.txt",0

    classe_str      db "Classe",0

    final_params_msg db 10, "Parametros (W_x, W_y; B): ",0
    final_params_len equ $ - final_params_msg

    newline         db 10,0

    byte_comma      db ',',0
    byte_semic      db ";",0

    pesos_file      db "pesos.txt",0

    init_label      db "Inicial: ",0
    init_label_len  equ $ - init_label

    mid_label       db " ",0
    mid_label_len   equ $ - mid_label

    bias_label      db " ",0
    bias_label_len  equ $ - bias_label

    final_label     db "Final: ",0
    final_label_len equ $ - final_label

    prompt          db "Digite valores de x e y (ex: 5 3): ", 0
    prompt_len_f    equ $ - prompt

    prompt_r        db "Digite valor de x (ex: 5): ", 0
    prompt_len_f_r  equ $ - prompt_r

    parar           db "Digite 1 para parar, e 0 para continuar: ",10, 0
    parar_len       equ $ - parar

    result_msg      db "Predicao: ", 0
    result_msg_len  equ $ - result_msg

    class0_msg      db "Classe 0", 10, 0
    class1_msg      db "Classe 1", 10, 0

    dot_string      db ".", 0

    ; ------------------------- BSS -------------------------
    section .bss
    parar_buffer    resq 1
    best_weight_x   resq 1
    best_weight_y   resq 1
    best_bias       resq 1

    input_buffer    resb 64

    task_mode       resb 1         ; 'C' ou 'R'
    filename        resb 20        ; Nome do arquivo
    file_handle     resq 1
    buffer          resb 1024      ; Buffer para leitura
    number_buffer   resb 20         ; Para conversão de inteiros

    class1_x      resq 1000
    class1_y      resq 1000
    class2_x      resq 1000
    class2_y      resq 1000

    class1_count  resq 10
    class2_count  resq 10
    current_class resb 1         ; '1' ou '2'

    weight_x      resq 1         ; Para classificação e regressão
    weight_y      resq 1         ; Usado apenas na classificação
    bias          resq 1         ; Bias

    pesos_fd      resq 1         ; File descriptor para pesos.txt

    random_buf    resq 1         

    epocas_input  resb 10         ; Entrada de épocas
    epoch_counter resq 1          ; Contador de épocas

    dummy         resb 1          ; Descarte

    ; ------------------------- CÓDIGO -------------------------
    section .text
    global _start

    _start:
        ; Inicializa os contadores e define a classe padrão como 1
        mov qword [class1_count], 0
        mov qword [class2_count], 0
        mov byte [current_class], '1'

        ; Define os pesos iniciais: 
        ; Para classificação: weight_x = 1, weight_y = 1 e bias = 0
        ; Para regressao, weight_x será ajustado para 1000 (ponto fixo para 1.000)
        mov qword [weight_x], 1
        mov qword [weight_y], 1
        mov qword [bias], 0

        ; Abre "pesos.txt" para salvar os parâmetros iniciais
        mov rax, 2                 
        mov rdi, pesos_file        
        mov rsi, 577               ; O_WRONLY | O_CREAT | O_TRUNC
        mov rdx, 420               ; Permissão 0644
        syscall
        mov [pesos_fd], rax

        ; Salva os parâmetros iniciais no arquivo
        call write_initial_params

        ; Exibe os parâmetros iniciais na tela
        mov rax, 1
        mov rdi, 1
        mov rsi, final_params_msg
        mov rdx, final_params_len
        syscall
        mov rax, [weight_x]
        call print_int
        mov rax, 1
        mov rdi, 1
        mov rsi, byte_comma
        mov rdx, 1
        syscall
        mov rax, [weight_y]
        call print_int
        mov rax, 1
        mov rdi, 1
        mov rsi, byte_semic
        mov rdx, 1
        syscall
        mov rax, [bias]
        call print_int
        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall

        ; Solicita a tarefa
        mov rax, 1
        mov rdi, 1
        mov rsi, prompt_msg
        mov rdx, prompt_len
        syscall

        ; Lê a opção (C ou R)
        mov rax, 0
        mov rdi, 0
        mov rsi, task_mode
        mov rdx, 1
        syscall

        mov al, [task_mode]
        cmp al, 'C'
        je setup_class
        cmp al, 'R'
        je setup_reg
        mov rax, 1
        mov rdi, 1
        mov rsi, error_msg
        mov rdx, error_len
        syscall
        jmp _start

    setup_class:
        mov rsi, class_file
        mov rdi, filename
        call copy_string
        jmp open_file

    setup_reg:
        ; Para regressão, ajusta weight_x para 1.000 (em ponto fixo)
        mov qword [weight_x], 1000
        mov rsi, reg_file
        mov rdi, filename
        call copy_string
        jmp open_file

    open_file:
        ; Informa que o arquivo está sendo lido
        mov rax, 1
        mov rdi, 1
        mov rsi, reading_msg
        mov rdx, reading_len
        syscall

        ; Abre o arquivo com os dados
        mov rax, 2
        mov rdi, filename
        mov rsi, 0         ; Apenas leitura
        mov rdx, 0
        syscall
        cmp rax, 0
        jl file_error
        mov [file_handle], rax

        ; Lê o arquivo para o buffer
        mov rax, 0         ; sys_read
        mov rdi, [file_handle]
        mov rsi, buffer
        mov rdx, 1024
        syscall
        mov byte [buffer + rax], 0

        ; (Opcional) Mostra o conteúdo lido
        mov rbx, rax
        mov rax, 1
        mov rdi, 1
        mov rsi, buffer
        mov rdx, rbx
        syscall

        ; Separa os dados lidos
        mov rsi, buffer
        call process_data

        ; Fecha o arquivo de dados
        mov rax, 3
        mov rdi, [file_handle]
        syscall

        ; Limpa entrada extra
        call flush_input

        ; Pede o número de épocas
        mov rax, 1
        mov rdi, 1
        mov rsi, epocas_prompt_msg
        mov rdx, epocas_prompt_len
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, epocas_input
        mov rdx, 10
        syscall
        mov byte [epocas_input + rax], 0
        mov rsi, epocas_input
        call string_to_int
        cmp rax, 0
        jne .save_epochs
        mov rax, 10
    .save_epochs:
        mov r12, rax         ; total de épocas
        mov [epoch_counter], rax

        ; Escolhe a rotina de treinamento de acordo com a opção
        mov al, [task_mode]
        cmp al, 'C'
        je .do_classificacao
        cmp al, 'R'
        je .do_regressao
        mov rax, 1
        mov rdi, 1
        mov rsi, error_msg
        mov rdx, error_len
        syscall
        jmp _start

    .do_classificacao:
        call train_classification
        jmp .apos_treinamento

    .do_regressao:
        call train_regressao

    .apos_treinamento:
        ; Salva os parâmetros finais em "pesos.txt"
        call write_final_params

        ; Fecha o arquivo de pesos
        mov rax, 3
        mov rdi, [pesos_fd]
        syscall

        ; Mostra os parâmetros finais na tela
        mov rax, 1
        mov rdi, 1
        mov rsi, final_params_msg
        mov rdx, final_params_len
        syscall

        ; Se tarefa for regressão, imprime W_x como float com 3 casas decimais
        mov al, [task_mode]
        cmp al, 'R'
        je .print_weight_x_float
        mov rax, [weight_x]
        call print_int
        jmp .after_weight_x
    .print_weight_x_float:
        mov rax, [weight_x]
        call print_float
    .after_weight_x:

        mov rax, 1
        mov rdi, 1
        mov rsi, byte_comma
        mov rdx, 1
        syscall

        mov rax, [weight_y]
        call print_int
        mov rax, 1
        mov rdi, 1
        mov rsi, byte_semic
        mov rdx, 1
        syscall

        mov rax, [bias]
        call print_int
        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall

        call fim_de_papo

    file_error:
        mov rax, 1
        mov rdi, 1
        mov rsi, error_msg
        mov rdx, error_len
        syscall
        mov rax, 60
        xor rdi, rdi
        syscall

    ; ------------------------- ROTINAS AUXILIARES -------------------------
    flush_input:
        mov rax, 0
        mov rdi, 0
        mov rsi, dummy
        mov rdx, 1
        syscall
        ret

    init_random_value_range:
        push rbx
        mov rax, 2
        mov rdi, urandom_file
        mov rsi, 0
        mov rdx, 0
        syscall
        mov rbx, rax
        mov rax, 0
        mov rdi, rbx
        mov rsi, random_buf
        mov rdx, 8
        syscall
        mov rax, 3
        mov rdi, rbx
        syscall
        mov rax, [random_buf]
        xor rdx, rdx
        mov rcx, 201
        div rcx
        sub rdx, 100
        mov rax, rdx
        pop rbx
        ret

    copy_string:
    .copy_loop:
        mov al, [rsi]
        mov [rdi], al
        test al, al
        jz .done_copy
        inc rsi
        inc rdi
        jmp .copy_loop
    .done_copy:
        ret

    string_to_int:
        xor rax, rax
    .str_loop:
        movzx rcx, byte [rsi]
        cmp rcx, 0
        je .done_str
        cmp rcx, 10
        je .done_str
        cmp rcx, 13
        je .done_str
        cmp rcx, '0'
        jb .done_str
        cmp rcx, '9'
        ja .done_str
        sub rcx, '0'
        imul rax, 10
        add rax, rcx
        inc rsi
        jmp .str_loop
    .done_str:
        ret

    process_data:
    .proc_loop:
        cmp byte [rsi], 0
        je .done_proc
        mov rax, 6
        push rsi
        push rdi
        mov rdi, rsi
        mov rsi, classe_str
        mov rcx, rax
        repe cmpsb
        pop rdi
        pop rsi
        je .change_class
        mov al, [rsi]
        cmp al, '0'
        jb .skip_line
        cmp al, '9'
        ja .skip_line
        call read_int       ; lê x
        mov r8, rax
        cmp byte [rsi], ',' 
        jne .skip_line
        inc rsi            ; pula vírgula
        call read_int       ; lê y
        mov r9, rax
        cmp byte [current_class], '1'
        je .store_class1
        cmp byte [current_class], '2'
        je .store_class2
        jmp .skip_line
    .store_class1:
        mov rbx, [class1_count]
        mov rdi, class1_x
        mov [rdi + rbx*8], r8
        mov rdi, class1_y
        mov [rdi + rbx*8], r9
        inc qword [class1_count]
        jmp .skip_line
    .store_class2:
        mov rbx, [class2_count]
        mov rdi, class2_x
        mov [rdi + rbx*8], r8
        mov rdi, class2_y
        mov [rdi + rbx*8], r9
        inc qword [class2_count]
        jmp .skip_line
    .change_class:
        add rsi, 7
        mov al, [rsi]
        cmp al, '1'
        je .set_class1
        cmp al, '2'
        je .set_class2
        jmp .skip_line
    .set_class1:
        mov byte [current_class], '1'
        jmp .skip_line
    .set_class2:
        mov byte [current_class], '2'
        jmp .skip_line
    .skip_line:
    .skip_loop:
        cmp byte [rsi], 10
        je .advance_line
        cmp byte [rsi], 0
        je .advance_line
        inc rsi
        jmp .skip_loop
    .advance_line:
        inc rsi
        jmp .proc_loop
    .done_proc:
        ret

    read_int:
        xor rax, rax
    .r_loop:
        movzx rbx, byte [rsi]
        cmp rbx, '0'
        jb .end_r
        cmp rbx, '9'
        ja .end_r
        imul rax, 10
        sub rbx, '0'
        add rax, rbx
        inc rsi
        jmp .r_loop
    .end_r:
        ret

    ; ----------------------------------------------------------------
    ; forward_pass – Calcula: (x * weight_x) + (y * weight_y) + bias.
    ; Usado para classificação.
    ; Entrada: x em rdi e y em rsi.
    ; Saída: resultado em rax.
    forward_pass:
        push rbx
        push rcx
        mov rax, rdi
        mov rbx, [weight_x]
        imul rax, rbx
        mov rcx, rsi
        mov rbx, [weight_y]
        imul rcx, rbx
        add rax, rcx
        add rax, [bias]
        pop rcx
        pop rbx
        ret

    ; ----------------------------------------------------------------
    ; forward_pass_reg – Calcula a predição para regressão:
    ; predição = (x * weight_x)/1000 + bias.
    ; Entrada: x em rdi.
    ; Saída: predição em rax.
    forward_pass_reg:
        push rbx
        mov rax, rdi
        mov rbx, [weight_x]
        imul rax, rbx
        mov rbx, 1000        ; divisor para ponto fixo
        cqo
        idiv rbx
        add rax, [bias]
        pop rbx
        ret

    ; ----------------------------------------------------------------
    ; train_classification – Treina o perceptron para classificação.
    train_classification:
    .loop_start:
        mov rax, [epoch_counter]
        cmp rax, 0
        je .end_train_class

        ; Processa os exemplos da Classe 1 (target = 0)
        mov rcx, [class1_count]
        mov rbx, 0
    .cls1_loop:
        cmp rbx, rcx
        jge .cls1_done
        mov r10, qword [class1_x + rbx*8]   
        mov r11, qword [class1_y + rbx*8]   
        mov rdi, r10
        mov rsi, r11
        call forward_pass    
        cmp rax, 50
        jl .pred0_cls1
        mov rdx, 1
        jmp .pred_done_cls1
    .pred0_cls1:
        xor rdx, rdx
    .pred_done_cls1:
        cmp rdx, 0
        je .cls1_next
        mov rax, [weight_x]
        sub rax, r10
        mov [weight_x], rax
        mov rax, [weight_y]
        sub rax, r11
        mov [weight_y], rax
        mov rax, [bias]
        dec rax
        mov [bias], rax
    .cls1_next:
        inc rbx
        jmp .cls1_loop
    .cls1_done:

        ; Processa os exemplos da Classe 2 (target = 1)
        mov rcx, [class2_count]
        mov rbx, 0
    .cls2_loop:
        cmp rbx, rcx
        jge .cls2_done
        mov r10, qword [class2_x + rbx*8]
        mov r11, qword [class2_y + rbx*8]
        mov rdi, r10
        mov rsi, r11
        call forward_pass
        cmp rax, 50
        jl .pred0_cls2
        mov rdx, 1
        jmp .pred_done_cls2
    .pred0_cls2:
        xor rdx, rdx
    .pred_done_cls2:
        cmp rdx, 1
        je .cls2_next
        mov rax, [weight_x]
        add rax, r10
        mov [weight_x], rax
        mov rax, [weight_y]
        add rax, r11
        mov [weight_y], rax
        mov rax, [bias]
        inc rax
        mov [bias], rax
    .cls2_next:
        inc rbx
        jmp .cls2_loop
    .cls2_done:

        dec qword [epoch_counter]
        jmp .loop_start
    .end_train_class:
        ret

    ; ----------------------------------------------------------------
    ; train_regressao – Treina o modelo para regressão.
    ; Nesta versão, o código acumula as atualizações de weight_x e bias
    ; para todos os exemplos e só as aplica ao final de cada época.
    train_regressao:
    .loop_start_reg:
        mov rax, [epoch_counter]
        cmp rax, 0
        je .end_train_reg

        ; Inicializa acumuladores para os ajustes
        xor r14, r14   ; acumulador para weight_x (ajuste acumulado em ponto fixo)
        xor r15, r15   ; acumulador para bias (soma de +1 ou -1)

        mov rcx, [class1_count]   ; Número de exemplos
        xor rbx, rbx              ; Índice inicia em 0

    .reg_loop:
        cmp rbx, rcx
        jge .update_params
        mov r10, qword [class1_x + rbx*8]   ; x
        mov r11, qword [class1_y + rbx*8]     ; alvo
        mov rdi, r10
        call forward_pass_reg                 ; predição = (x * weight_x)/1000 + bias
        mov r9, rax                         ; guarda predição
        mov r8, r11                         ; alvo
        sub r8, r9                          ; erro = alvo - predição

        ; Acumula ajuste para weight_x: (erro * x)/1000
        mov rax, r8
        imul rax, r10
        mov r13, 1000
        cqo
        idiv r13
        add r14, rax

        ; Acumula ajuste para bias: se erro > 0 soma +1; se erro < 0, -1
        cmp r8, 0
        jg .bias_positive_accum
        jl .bias_negative_accum
        jmp .next_example
    .bias_positive_accum:
        inc r15
        jmp .next_example
    .bias_negative_accum:
        dec r15
        jmp .next_example
    .next_example:
        inc rbx
        jmp .reg_loop

    .update_params:
        ; Aplica os ajustes acumulados aos parâmetros
        mov rax, [weight_x]
        add rax, r14
        mov [weight_x], rax

        mov rax, [bias]
        add rax, r15
        mov [bias], rax

        ; Encerra a época e reinicia o loop de treinamento
        dec qword [epoch_counter]
        jmp .loop_start_reg

    .end_train_reg:
        ret

    ; ----------------------------------------------------------------
    ; int_to_string – Converte o inteiro em RAX para uma string.
    int_to_string:
        push rbx
        push rcx
        push rdx
        mov rdi, number_buffer
        cmp rax, 0
        jge .positive
        mov byte [rdi], '-'
        inc rdi
        neg rax
    .positive:
        cmp rax, 0
        jne .convert_nonzero
        mov byte [rdi], '0'
        mov byte [rdi+1], 0
        jmp .done_int_to_str
    .convert_nonzero:
        xor rcx, rcx
    .convert_loop:
        xor rdx, rdx
        mov rbx, 10
        div rbx
        push rdx
        inc rcx
        cmp rax, 0
        jne .convert_loop
    .reverse_loop:
        pop rdx
        add dl, '0'
        mov [rdi], dl
        inc rdi
        dec rcx
        jnz .reverse_loop
        mov byte [rdi], 0
    .done_int_to_str:
        pop rdx
        pop rcx
        pop rbx
        ret

    ; ----------------------------------------------------------------
    ; print_int – Converte o número em RAX para string e imprime na tela.
    print_int:
        push rax
        call int_to_string
        mov rsi, number_buffer
        xor rcx, rcx
    .find_len:
        cmp byte [number_buffer+rcx], 0
        je .do_print_int
        inc rcx
        jmp .find_len
    .do_print_int:
        mov rax, 1
        mov rdi, 1
        mov rdx, rcx
        syscall
        pop rax
        ret

    ; ----------------------------------------------------------------
    ; print_float – Imprime um número em ponto fixo (3 casas decimais).
    ; Recebe em RAX o valor em ponto fixo (valor*1000)
    print_float:
        push rbx
        push rcx
        push rdx
        push rsi
        mov rsi, rax
        mov rbx, 1000
        xor rdx, rdx
        mov rax, rsi
        div rbx           ; rax = parte inteira, rdx = parte fracionária
        push rdx         ; salva parte fracionária
        mov rdi, number_buffer
        call int_to_string
        mov rsi, number_buffer
        xor rcx, rcx
    .find_len_float:
        cmp byte [number_buffer+rcx], 0
        je .print_int_part
        inc rcx
        jmp .find_len_float
    .print_int_part:
        mov rax, 1
        mov rdi, 1
        mov rdx, rcx
        syscall
        mov rax, 1
        mov rdi, 1
        mov rsi, dot_string
        mov rdx, 1
        syscall
        pop rdx         ; restaura parte fracionária
        mov rax, rdx
        mov rbx, 100
        xor rdx, rdx
        div rbx         ; rax = dígito1, rdx = resto
        add al, '0'
        mov byte [number_buffer], al
        mov rax, rdx
        mov rbx, 10
        xor rdx, rdx
        div rbx         ; rax = dígito2, rdx = dígito3
        add al, '0'
        mov byte [number_buffer+1], al
        add dl, '0'
        mov byte [number_buffer+2], dl
        mov byte [number_buffer+3], 0
        mov rax, 1
        mov rdi, 1
        mov rsi, number_buffer
        mov rdx, 3
        syscall
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        ret

    ; ----------------------------------------------------------------
    ; write_string_to_fd – Escreve uma string no arquivo de pesos.
    write_string_to_fd:
        mov rax, 1
        mov rdi, [pesos_fd]
        syscall
        ret

    ; ----------------------------------------------------------------
    ; write_int_to_fd – Converte o inteiro em RAX para string e escreve no arquivo.
    write_int_to_fd:
        push rax
        call int_to_string
        xor rcx, rcx
    .write_int_loop:
        cmp byte [number_buffer+rcx], 0
        je .write_int_done
        inc rcx
        jmp .write_int_loop
    .write_int_done:
        mov rax, 1
        mov rdi, [pesos_fd]
        mov rsi, number_buffer
        mov rdx, rcx
        syscall
        pop rax
        ret

    ; ----------------------------------------------------------------
    ; write_initial_params – Salva os parâmetros iniciais em "pesos.txt".
    write_initial_params:
        mov rsi, init_label
        mov rdx, init_label_len
        call write_string_to_fd
        mov rax, [weight_x]
        call write_int_to_fd
        mov rsi, mid_label
        mov rdx, mid_label_len
        call write_string_to_fd
        mov rax, [weight_y]
        call write_int_to_fd
        mov rsi, bias_label
        mov rdx, bias_label_len
        call write_string_to_fd
        mov rax, [bias]
        call write_int_to_fd
        mov rsi, newline
        mov rdx, 1
        call write_string_to_fd
        ret

    ; ----------------------------------------------------------------
    ; write_final_params – Salva os parâmetros finais em "pesos.txt".
    write_final_params:
        mov rsi, final_label
        mov rdx, final_label_len
        call write_string_to_fd
        mov rax, [weight_x]
        call write_int_to_fd
        mov rsi, mid_label
        mov rdx, mid_label_len
        call write_string_to_fd
        mov rax, [weight_y]
        call write_int_to_fd
        mov rsi, bias_label
        mov rdx, bias_label_len
        call write_string_to_fd
        mov rax, [bias]
        call write_int_to_fd
        mov rsi, newline
        mov rdx, 1
        call write_string_to_fd
        ret

    fim_de_papo:
        mov al, [task_mode]
        cmp al, 'C'
        je .input_class
        cmp al, 'R'
        je .input_reg
        jmp end

    .input_reg:
        ; Modo regressão: exibe prompt e lê um único valor (x)
        mov rax, 1
        mov rdi, 1
        mov rsi, prompt_r
        mov rdx, prompt_len_f_r
        syscall
        mov rax, 0
        mov rdi, 0
        mov rsi, input_buffer
        mov rdx, 64
        syscall
        mov rsi, input_buffer
        call atoi           ; converte para inteiro
        mov r10, rax        ; salva x
        mov rdi, r10
        call forward_pass_reg
        mov r15, rax
        mov rax, 1
        mov rdi, 1
        mov rsi, result_msg
        mov rdx, result_msg_len
        syscall
        mov rax, r15
        call print_int      ; imprime predição
        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall
        jmp .pare

    .input_class:
        ; Modo classificação: exibe prompt e lê dois valores (x e y)
        mov rax, 1
        mov rdi, 1
        mov rsi, prompt
        mov rdx, prompt_len_f
        syscall
    .read_input:
        mov rax, 0
        mov rdi, 0
        mov rsi, input_buffer
        mov rdx, 64
        syscall
        mov rsi, input_buffer
        call atoi           ; converte o primeiro número -> x
        mov r10, rax        ; salva x
        call atoi           ; converte o segundo número -> y
        mov r11, rax        ; salva y
        mov rdi, r10
        mov rsi, r11
        call forward_pass   ; calcula predição
        mov r15, rax
        mov rax, 1
        mov rdi, 1
        mov rsi, result_msg
        mov rdx, result_msg_len
        syscall
        cmp r15, 50
        jl .print_class0
        mov rsi, class1_msg
        jmp .print_class
    .print_class0:
        mov rsi, class0_msg
    .print_class:
        mov rax, 1
        mov rdi, 1
        mov rdx, 9          ; tamanho da string ("Classe X")
        syscall
    .pare:
        mov rax, 1
        mov rdi, 1
        mov rsi, parar
        mov rdx, parar_len
        syscall
        mov byte [parar_buffer], 0
        mov rax, 0
        mov rdi, 0
        mov rsi, parar_buffer
        mov rdx, 2
        syscall
        cmp byte [parar_buffer], '1'
        je end
        jmp fim_de_papo

    atoi:
        xor rax, rax
        xor rcx, rcx
    .skip_spaces:
        movzx rdx, byte [rsi]
        cmp   rdx, ' '
        je    .skip_spaces_inc
        cmp   rdx, 9       ; Tabulação
        je    .skip_spaces_inc
        jmp   .convert
    .skip_spaces_inc:
        inc   rsi
        jmp   .skip_spaces
    .convert:
        movzx rdx, byte [rsi]
        test  rdx, rdx
        je    .done
        cmp   rdx, '0'
        jl    .done
        cmp   rdx, '9'
        jg    .done
        sub   rdx, '0'
        imul  rax, rax, 10
        add   rax, rdx
        inc   rsi
        jmp   .convert
    .done:
        ret

    end:
        mov rax, 60
        xor rdi, rdi
        syscall
