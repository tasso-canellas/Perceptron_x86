# Perceptron Simples para Classificação Binária e Regressão Linear em Assembly x86_64

Este projeto implementa um perceptron simples em Assembly (x86-64) que pode realizar tanto a classificação binária quanto a regressão linear. O código é escrito em NASM e utiliza chamadas de sistema (syscalls) do Linux para realizar operações de entrada/saída e processamento.

## Sumário

- [Visão Geral](#visão-geral)
- [Recursos](#recursos)
- [Requisitos](#requisitos)
- [Compilação](#compilação)
- [Uso](#uso)
- [Estrutura do Código](#estrutura-do-código)
- [Arquivos](#arquivos)
- [Notas Adicionais](#notas-adicionais)
- [Autores](#autores)

## Visão Geral

Este programa implementa um perceptron capaz de executar duas tarefas:
- **Classificação Binária:** Recebe dados com duas características (x e y) e classifica os exemplos em duas classes.
- **Regressão Linear:** Utiliza um único valor (x) para prever uma saída contínua, utilizando uma representação de ponto fixo (multiplicação por 1000) para maior precisão.

Os pesos iniciais e finais do modelo são salvos no arquivo `pesos.txt`.

## Recursos

- **Interface Interativa:** O programa solicita ao usuário a escolha entre classificação (`C`) e regressão (`R`).
- **Processamento de Arquivos:** Lê os dados de entrada dos arquivos `classificacao.txt` ou `regressao.txt`, dependendo da tarefa selecionada.
- **Treinamento do Modelo:** 
  - Na **classificação**, o perceptron ajusta os pesos de acordo com os erros de predição.
  - Na **regressão**, os ajustes são acumulados durante cada época e aplicados ao final da época.
- **Exibição de Resultados:** Mostra os parâmetros iniciais e finais (pesos e bias) na tela e os salva em `pesos.txt`.
- **Entrada de Previsão:** Após o treinamento, o usuário pode inserir novos valores para obter a predição:
  - Para regressão: insere um único valor (x).
  - Para classificação: insere dois valores (x e y).

## Requisitos

- **NASM:** Netwide Assembler para compilar o código.
- **Linux (x86-64):** O código foi desenvolvido para sistemas Linux de 64 bits.
- **Linker (ld):** Para linkar o objeto gerado e produzir o executável.

## Compilação

Para compilar o código, execute o comando abaixo no terminal:

```bash
nasm -felf64 lab3.asm && ld -o lab3 lab3.o
```

## Uso

  Executando o Programa:
  Rode o executável gerado:

  ```./lab3```

## Fluxo de Execução:
  - **Exibição dos Parâmetros Iniciais:**
    
      O programa inicia exibindo os parâmetros (pesos e bias) iniciais.
  - **Seleção da Tarefa:**
    
      O usuário é solicitado a digitar:
          C para Classificação
          R para Regressão
 - **Leitura dos Dados:**
   
      Dependendo da tarefa, o programa lê os dados do arquivo:
          classificacao.txt para classificação.
          regressao.txt para regressão.
 - **Definição do Número de Épocas:**
   
      O usuário informa quantas épocas de treinamento serão executadas.
 - **Treinamento do Modelo:**
   
      Para classificação, os ajustes dos pesos são realizados conforme o erro de predição para cada exemplo.
      Para regressão, os ajustes são acumulados durante a época e aplicados ao final.
  - **Armazenamento dos Parâmetros Finais:**
    
      Os parâmetros finais são salvos no arquivo pesos.txt e também exibidos na tela.
 - **Predição:**
   
      Após o treinamento, o programa solicita:
          Em regressão: um valor x para calcular a predição usando a fórmula (x * weight_x) / 1000 + bias.
          Em classificação: dois valores (x e y) para determinar a classe (0 ou 1).
  - **Encerramento ou Continuação:**
    
      O usuário pode optar por encerrar o programa ou continuar realizando novas predições.

## Estrutura do Código

O código está organizado em três seções principais:
1. **Seção .data**

    - **Definição de Strings:**
   
      Contém mensagens de prompt, de erro e nomes de arquivos.
   
   - **Parâmetros Iniciais:**
   
      Define os valores iniciais para weight_x, weight_y e bias.

3. **Seção .bss**

   - **Alocação de Buffers:**
     
      Reservam espaço para a entrada do usuário, buffers para leitura, contadores e arrays para armazenar os dados das classes.
   - **Contadores e Flags:**
     
      Variáveis para o número de exemplos, classe atual e contador de épocas.

4. **Seção .text**

   - **Função Principal (_start):**
     
      Inicializa o programa, configura os parâmetros, solicita a escolha da tarefa e gerencia o fluxo de execução.

   - **Rotinas de Treinamento:**
     - train_classification: Treina o perceptron para classificação.
    
     - train_regressao: Treina o modelo para regressão acumulando os ajustes ao longo das épocas.
    - **Funções de Forward Pass:**
      
      - forward_pass: Calcula a predição para classificação usando duas entradas.
    
      - forward_pass_reg: Calcula a predição para regressão utilizando ponto fixo.
    - **Rotinas Auxiliares:**
      
        Funções para conversão de strings para inteiros, impressão de números (inteiros e em ponto fixo) e manipulação de arquivos.
   - **Entrada e Saída:**
     
        Procedimentos para ler a entrada do usuário e escrever saídas tanto no terminal quanto em arquivos.

## Arquivos

  **lab3.asm:** Código fonte principal escrito em Assembly.
  
  **classificacao.txt:** Arquivo de entrada para os dados de classificação.
  
  **regressao.txt:** Arquivo de entrada para os dados de regressão.
  
  **pesos.txt:** Arquivo de saída onde os parâmetros iniciais e finais do modelo são salvos.

  **dataset.py:** Esses arquivos são utilizados para criar o dataset e retas, respecitvamente.
  
  - **Classificação:** Pressione os botões direito e esquerdo para marcar pontos de classes diferentes.
    
  - **Regressão:** Pressione apenas um botão para registrar os pontos. O script irá salvar os dados nos arquivos classificacao.txt ou regressao.txt conforme o modo escolhido.
  
  **reta.py:**
    O script lerá os parâmetros salvos em pesos.txt e exibirá a reta de classificação ou regressão com base nos valores treinados.
## Notas Adicionais

- **Tratamento de Erros:**
   O programa verifica a validade da opção selecionada e trata erros na leitura de arquivos, exibindo mensagens de erro apropriadas.
- **Ponto Fixo na Regressão:**
   Para a regressão, o valor de weight_x é ajustado para 1000 (representação em ponto fixo), garantindo maior precisão no cálculo da predição.
- **Interface Interativa:**
   O usuário é guiado por mensagens de prompt que indicam a tarefa, o número de épocas e os valores para predição.
- **Comentários no Código:**
   O código contém comentários detalhados que explicam a funcionalidade de cada parte, facilitando a compreensão e a manutenção.



## Autores
  
  Tasso Eliézer Canellas
  
  Felipe Silvestre
  
  João Moura



