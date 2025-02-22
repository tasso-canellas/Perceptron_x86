import os
import matplotlib.pyplot as plt

# Função para limpar caracteres NUL
def limpar_caracteres_nul(texto):
    return texto.replace('\x00', '').strip()

# Função para ler os pesos iniciais e finais do arquivo pesos.txt
def ler_pesos(arquivo):
    if not os.path.exists(arquivo):
        print(f"Erro: O arquivo '{arquivo}' não foi encontrado.")
        return None, None
    
    W_inicial, W_final = None, None

    try:
        with open(arquivo, 'r', encoding='utf-8') as f:
            for line in f:
                line = limpar_caracteres_nul(line)  # Limpa caracteres NUL
                if line.startswith("Inicial:"):
                    partes = line.replace("Inicial:", "").split()
                    W_x_inicial = float(partes[0])
                    W_y_inicial = float(partes[1])
                    bias_inicial = float(partes[2])
                    W_inicial = (W_x_inicial, W_y_inicial, bias_inicial)
                elif line.startswith("Final:"):
                    partes = line.replace("Final:", "").split()
                    W_x_final = float(partes[0])
                    W_y_final = float(partes[1])
                    bias_final = float(partes[2])
                    W_final = (W_x_final, W_y_final, bias_final)
    except Exception as e:
        print(f"Erro ao ler os pesos: {e}")
    
    return W_inicial, W_final

# Função para ler os dados do arquivo
def ler_dados(arquivo):
    if not os.path.exists(arquivo):
        print(f"Erro: O arquivo '{arquivo}' não foi encontrado.")
        return [], [], []
    
    x_vals, y_vals, labels = [], [], []
    try:
        with open(arquivo, 'r') as f:
            current_class = None
            for line in f:
                line = line.strip()
                if line.endswith(':'):
                    current_class = line[:-1]  # Nome da classe
                elif line:
                    try:
                        x, y = map(float, line.split(','))
                        x_vals.append(x)
                        y_vals.append(y)
                        labels.append(current_class)
                    except ValueError:
                        print(f"Erro ao processar a linha: {line}")
    except Exception as e:
        print(f"Erro ao ler o arquivo: {e}")
    return x_vals, y_vals, labels

# Função para calcular a acurácia considerando ambos os casos
def calcular_acuracia(x_vals, y_vals, labels, W_x, W_y, bias):
    # Calcula as previsões para ambos os casos
    predicoes_caso1 = [(W_x * x + W_y * y + bias) >= 0 for x, y in zip(x_vals, y_vals)]
    predicoes_caso2 = [(W_x * x + W_y * y + bias) < 0 for x, y in zip(x_vals, y_vals)]

    classes = list(set(labels))
    if len(classes) != 2:
        print("Erro: O arquivo deve conter exatamente duas classes.")
        return 0, 0

    classe0, classe1 = classes
    acertos_caso1 = 0
    acertos_caso2 = 0

    # Calcula acertos para o caso 1
    for i, pred in enumerate(predicoes_caso1):
        if (labels[i] == classe0 and not pred) or (labels[i] == classe1 and pred):
            acertos_caso1 += 1

    # Calcula acertos para o caso 2
    for i, pred in enumerate(predicoes_caso2):
        if (labels[i] == classe0 and not pred) or (labels[i] == classe1 and pred):
            acertos_caso2 += 1

    # Escolhe o caso com maior acurácia
    if acertos_caso1 >= acertos_caso2:
        acuracia = (acertos_caso1 / len(labels)) * 100
        return acuracia, acertos_caso1
    else:
        acuracia = (acertos_caso2 / len(labels)) * 100
        return acuracia, acertos_caso2

# Função para plotar os dados com duas retas de decisão
def plotar_dados_duas_retas(x_vals, y_vals, labels, pesos_inicial, pesos_final):
    plt.figure(figsize=(10, 8))
    cores = {}
    for x, y, label in zip(x_vals, y_vals, labels):
        if label not in cores:
            cores[label] = 'red' if len(cores) == 0 else 'blue'
        plt.scatter(x, y, color=cores[label], label=label)

    # Plotar a primeira reta de decisão
    W_x_inicial, W_y_inicial, bias_inicial = pesos_inicial
    acuracia_inicial, acertos_inicial = calcular_acuracia(x_vals, y_vals, labels, W_x_inicial, W_y_inicial, bias_inicial)
    if W_y_inicial != 0:
        x_range = [min(x_vals) - 50, max(x_vals) + 50]
        y_range = [-(W_x_inicial / W_y_inicial) * x - (bias_inicial / W_y_inicial) for x in x_range]
        plt.plot(x_range, y_range, color='green', linestyle='--', 
                 label=f"Fronteira Inicial: {W_x_inicial:.1f}x + {W_y_inicial:.1f}y + {bias_inicial:.1f} = 0\n(Acurácia: {acuracia_inicial:.2f}%, Acertos: {acertos_inicial})")
    else:
        x_line = -bias_inicial / W_x_inicial
        plt.axvline(x=x_line, color='green', linestyle='--',
                    label=f"Fronteira Inicial: x = {x_line:.1f} (Acurácia: {acuracia_inicial:.2f}%, Acertos: {acertos_inicial})")

    # Plotar a segunda reta de decisão
    W_x_final, W_y_final, bias_final = pesos_final
    acuracia_final, acertos_final = calcular_acuracia(x_vals, y_vals, labels, W_x_final, W_y_final, bias_final)
    if W_y_final != 0:
        y_range = [-(W_x_final / W_y_final) * x - (bias_final / W_y_final) for x in x_range]
        plt.plot(x_range, y_range, color='purple', linestyle='--', 
                 label=f"Fronteira Final: {W_x_final:.1f}x + {W_y_final:.1f}y + {bias_final:.1f} = 0\n(Acurácia: {acuracia_final:.2f}%, Acertos: {acertos_final})")
    else:
        x_line = -bias_final / W_x_final
        plt.axvline(x=x_line, color='purple', linestyle='--',
                    label=f"Fronteira Final: x = {x_line:.1f} (Acurácia: {acuracia_final:.2f}%, Acertos: {acertos_final})")

    # Coletar handles e labels após plotar tudo
        # Limitar os eixos
    plt.xlim(-10, 110)
    plt.ylim(-10, 110)
    
    handles, labels_plot = plt.gca().get_legend_handles_labels()
    by_label = dict(zip(labels_plot, handles))  # Remove duplicatas

    plt.legend(by_label.values(), by_label.keys(), fontsize=9)
    plt.title("Dados e Fronteiras de Decisão (Inicial e Final)")
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.grid(True)
    plt.show()

# Função principal
def main():
    arquivo_pesos = 'pesos.txt'
    entrada = input("Digite o nome do arquivo de dados (classificacao.txt = 0 ou regressao.txt = 1): ")
    if entrada == "0":
        arquivo_dados = 'classificacao.txt'
        is_regression = False
    else:
        arquivo_dados = 'regressao.txt'
        is_regression = True

    # Lê os pesos iniciais e finais
    pesos_inicial, pesos_final = ler_pesos(arquivo_pesos)
    if not pesos_inicial or not pesos_final:
        print("Erro ao ler os pesos iniciais e finais.")
        return

    # Ajustar o bias se for regressão
    if is_regression:
        # Ajustar bias inicial
        Wx_ini, Wy_ini, bias_ini = pesos_inicial
        pesos_inicial = (-Wx_ini, Wy_ini, -bias_ini)
        # Ajustar bias final
        Wx_fin, Wy_fin, bias_fin = pesos_final
        pesos_final = (-Wx_fin/1000, Wy_fin, -bias_fin)

    # Lê os dados do arquivo
    x_vals, y_vals, labels = ler_dados(arquivo_dados)
    if not x_vals:
        return

    # Plotar os dados com as duas retas de decisão
    plotar_dados_duas_retas(x_vals, y_vals, labels, pesos_inicial, pesos_final)

if __name__ == "__main__":
    main()