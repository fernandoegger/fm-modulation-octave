# Simulação de Sistema de Comunicação FM (Modulação em Frequência)

> **Projeto acadêmico - Engenharia de computação**
>
> **Objetivo:** Projetar e simular um sistema de transmissão de sinal analógico de áudio com alta robustez contra ruído impulsivo e interferências eletromagnéticas, utilizando modulação FM.

## 📋 Descrição do Projeto

Este repositório contém a implementação em **Octave/MATLAB** de um modulador e demodulador FM completo. O projeto foi desenvolvido para atender aos requisitos de um estudo de caso onde é necessário transmitir um sinal de áudio garantindo a integridade da informação mesmo sob presença de ruído aditivo.

A implementação foca especificamente no método de demodulação via **Discriminador de Frequência** (Derivada + Detecção de Envoltória), sem o uso de funções prontas de "caixa preta" (como `fmdemod`), para demonstrar o domínio da teoria matemática por trás do processo.

## ⚙️ Especificações Técnicas

Os parâmetros utilizados na simulação foram definidos conforme projeto de engenharia:

| Parâmetro | Símbolo | Valor | Unidade |
| :--- | :---: | :---: | :--- |
| **Portadora** | $A_c$ | 4 | V |
| **Frequência da Portadora** | $f_c$ | 100 | kHz |
| **Sensibilidade de Frequência** | $K_f$ | 6000 | rad/s/V |
| **Sinal Modulante (Mensagem)** | $m(t)$ | $2\sin(2\pi \cdot 2k \cdot t)$ | V |
| **Frequência do Sinal Modulante** | $f_m$ | 2 | kHz |
| **Ruído Aditivo** | $r(t)$ | $0.05\sin(2\pi \cdot 40k \cdot t)$ | V |

---

## 🚀 Metodologia Implementada

### 1. Modulação FM
A modulação FM consiste em variar a frequência instantânea da portadora proporcionalmente à amplitude da mensagem. Matematicamente, a fase do sinal é a integral da mensagem:

$$s(t) = A_c \cos\left(2\pi f_c t + K_f \int_{-\infty}^{t} m(\tau) d\tau\right)$$

No código, a integral foi realizada numericamente usando a função `cumsum` (soma cumulativa).

### 2. Adição de Ruído
Para testar a robustez do FM (uma das principais vantagens sobre o AM), foi injetado um sinal de ruído de alta frequência (40 kHz) somado à portadora modulada.

### 3. Demodulação (Slope Detector)
A recuperação do sinal original foi feita através de um processo de duas etapas:

1.  **Diferenciação (Derivada):** Ao derivar o sinal FM, a variação de frequência é convertida em variação de amplitude. O sinal resultante torna-se um sinal híbrido AM+FM.
2.  **Detecção de Envoltória:** Utilizamos um retificador (valor absoluto) seguido de um **Filtro Passa-Baixa (Butterworth)**.
    * *Ajuste do Filtro:* Foi utilizado um filtro de **2ª ordem** com frequência de corte em **4 kHz**. Isso foi necessário para remover os componentes da portadora (100 kHz) e o ruído de alta frequência, preservando apenas o áudio original (2 kHz).

---

## 💻 Estrutura do Código

O script `projeto_fm.m` realiza as seguintes etapas:

1.  **Definição de Parâmetros:** Configuração das variáveis de tempo e frequência (respeitando o Teorema de Nyquist com $F_s = 1 \text{ MHz}$).
2.  **Geração de Sinais:** Criação dos vetores de tempo, mensagem $m(t)$ e sinal modulado $s(t)$.
3.  **Injeção de Ruído:** Soma linear do ruído ao sinal modulado.
4.  **Processamento (Demodulação):**
    * Cálculo da derivada discreta (`diff`).
    * Aplicação do valor absoluto (`abs`).
    * Filtragem digital (`butter` + `filter`).
    * Remoção de *offset* DC e corte de transiente inicial.
5.  **Visualização:** Geração de 4 figuras para análise (Domínio do Tempo, Espectro de Frequência, Validação da Demodulação e Comparativo de Ruído).

---

## 📊 Resultados e Análise

O código gera saídas gráficas que respondem às questões teóricas do projeto:

### Análise Espectral (Regra de Carson)
O espectro gerado (FFT) demonstra que a energia do sinal se espalha ao redor da portadora ($f_c = 100 \text{ kHz}$). A largura de banda teórica calculada pela Regra de Carson é:
$$B_T \approx 2(\Delta f + f_m)$$
Onde o desvio de frequência $\Delta f \approx 1.91 \text{ kHz}$. A simulação confirma a ocupação espectral prevista.

### Robustez ao Ruído
A simulação comprova que o FM é robusto. Mesmo com a adição de ruído de amplitude ($r(t)$), o sinal demodulado (áudio recuperado) permaneceu limpo e fiel ao original. Isso ocorre porque a informação no FM reside na **frequência** (cruzamentos por zero), e não na amplitude, permitindo que o limitador/discriminador ignore as flutuações de voltagem causadas pelo ruído.

---

## 🛠️ Como Executar

1.  Certifique-se de ter o **Octave** ou **MATLAB** instalado.
2.  Se usar Octave, instale o pacote de sinais: `pkg install -forge signal`.
3.  Clone este repositório.
4.  Abra o arquivo `projeto_fm.m`.
5.  Execute o script.

---
