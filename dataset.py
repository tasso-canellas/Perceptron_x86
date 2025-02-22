import matplotlib.pyplot as plt
import os
from pathlib import Path

# Listas para armazenar as coordenadas
class_1 = []
class_2 = []

# Diretório específico do WSL (usando o caminho completo)
wsl_dir = Path(r"\\wsl.localhost\Ubuntu\home\felip")  # Caminho raw string para evitar problemas com barras

# Garante que o diretório existe
try:
    wsl_dir.mkdir(parents=True, exist_ok=True)
except PermissionError:
    print(f"ERRO: Sem permissão para criar o diretório {wsl_dir}")
    exit(1)
except Exception as e:
    print(f"Erro ao acessar o diretório: {str(e)}")
    exit(1)

# Configuração do gráfico
fig, ax = plt.subplots()
ax.set_title('Esquerdo: Classe 1 (vermelho) | Direito: Classe 2 (azul) | Meio: Salvar e Fechar')
ax.set_xlim(0, 100)
ax.set_ylim(0, 100)

def salvar_pontos():
    if not class_1 and not class_2:
        print("Nenhum ponto foi adicionado. Arquivo não será criado.")
        plt.close(fig)
        return
    
    filename = 'classificacao.txt' if class_1 and class_2 else 'regressao.txt'
    filepath = wsl_dir / filename  # Combina diretório e arquivo

    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            if class_1:
                f.write('Classe 1:\n')
                for x, y in class_1:
                    f.write(f'{x},{y}\n')
            if class_2:
                f.write('\nClasse 2:\n')
                for x, y in class_2:
                    f.write(f'{x},{y}\n')
        print(f"Arquivo salvo com sucesso em: {filepath}")
    except PermissionError:
        print(f"ERRO: Permissão negada para salvar em {filepath}")
    except Exception as e:
        print(f"Erro ao salvar: {str(e)}")
    
    plt.close(fig)

def on_click(event):
    if event.inaxes:
        x = int(round(event.xdata))
        y = int(round(event.ydata))
        
        if event.button == 1:  # Botão esquerdo
            class_1.append((x, y))
            ax.plot(x, y, 'ro', markersize=5)
        elif event.button == 3:  # Botão direito
            class_2.append((x, y))
            ax.plot(x, y, 'bo', markersize=5)
        elif event.button == 2:  # Botão do meio
            salvar_pontos()
        fig.canvas.draw()

# Configuração final
fig.canvas.mpl_connect('button_press_event', on_click)
plt.show()