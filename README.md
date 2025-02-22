# Perceptron_x86

Visão Geral
O projeto é composto pelos seguintes componentes:

dataset.py: Script para gerar o conjunto de dados.

Classificação: Gere o dataset pressionando os botões direito e esquerdo em pontos diferentes para marcar classes distintas.
Regressão: Gere o dataset pressionando apenas um botão para registrar os pontos.
lab3.asm: Código em Assembly que implementa o perceptron.

Ao executar, você escolhe a tarefa desejada:
C para Classificação
R para Regressão
O programa lê os dados do arquivo correspondente (por exemplo, classificacao.txt ou regressao.txt), treina o modelo e salva os parâmetros finais em pesos.txt.
reta.py: Script para visualização.

Utiliza o arquivo pesos.txt gerado pelo Assembly para desenhar a reta de regressão e visualizar os resultados.
Pré-Requisitos
NASM e ld para compilar o código Assembly.
Python 3 para executar os scripts dataset.py e reta.py.
Ambiente Linux.
Instruções
1. Gerar o Dataset
Antes de executar o código em Assembly, gere o dataset com o script dataset.py:

Abra o terminal e execute:
bash
Copiar
Editar
python3 dataset.py
Selecione o modo de criação:
Classificação: Pressione os botões direito e esquerdo para marcar pontos de classes diferentes.
Regressão: Pressione apenas um botão para registrar os pontos.
O script irá salvar os dados nos arquivos classificacao.txt ou regressao.txt conforme o modo escolhido.
2. Compilar e Executar o Código em Assembly
Após gerar o dataset, compile e execute o código Assembly:

Compilação:
bash
Copiar
Editar
nasm -felf64 lab3.asm && ld -o lab3 lab3.o
Execução:
bash
Copiar
Editar
./lab3
Ao executar, digite C se deseja realizar classificação ou R para regressão.
O programa irá ler o dataset, treinar o perceptron e salvar os pesos finais em pesos.txt.
3. Visualizar o Resultado com reta.py
Após o treinamento, visualize o resultado da regressão (reta) com o script reta.py:

Execute:
bash
Copiar
Editar
python3 reta.py
O script lerá os parâmetros salvos em pesos.txt e exibirá a reta de regressão com base nos valores treinados.
Fluxo do Projeto
Gerar Dataset:
Execute dataset.py e selecione o modo desejado (classificação ou regressão).

Treinamento em Assembly:
Compile e execute lab3.asm para treinar o modelo e gerar o arquivo pesos.txt.

Visualização:
Execute reta.py para visualizar a reta de regressão.

Considerações Finais
Normalização: Caso os valores do dataset sejam muito grandes, considere normalizá-los para evitar problemas com escalas de gradiente.
Ajuste de Hiperparâmetros: Se necessário, ajuste a taxa de aprendizado (a escala dos gradientes) no código Assembly.
