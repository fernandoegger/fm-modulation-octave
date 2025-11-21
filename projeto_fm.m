pkg load signal;       % Carrega o pacote de processamento de sinais (necessário para o Octave)
clc; clear; close all; % Limpa o terminal, apaga variáveis da memória e fecha gráficos abertos

% 1. DEFINIÇÃO DOS PARÂMETROS (DADOS DO PROJETO)
Ac = 4;                % Define a amplitude da portadora como 4 Volts
fc = 100e3;            % Define a frequência da portadora como 100 kHz
Kf = 6000;             % Define a sensibilidade de frequência como 6000 rad/s/V
Am = 2;                % Define a amplitude do sinal modulante (áudio) como 2 Volts
fm = 2e3;              % Define a frequência do sinal modulante como 2 kHz

% 2. CONFIGURAÇÃO DE TEMPO E AMOSTRAGEM
Fs = 10 * fc;          % Define a frequência de amostragem como 1 MHz (10x a portadora para alta resolução)
Ts = 1/Fs;             % Calcula o período de amostragem (tempo entre cada ponto)
t_final = 10/fm;       % Define o tempo total de simulação (duração de 10 ciclos do áudio)
t = 0:Ts:t_final;      % Cria o vetor de tempo indo de 0 até o final com passos de Ts

% 3. GERAÇÃO DOS SINAIS (MODULAÇÃO)
mt = Am * sin(2*pi*fm*t);                    % Cria o sinal de mensagem m(t) (senoide pura)
integral_mt = cumsum(mt) * Ts;               % Calcula a integral da mensagem numérica (soma acumulada)
st = Ac * cos(2*pi*fc*t + integral_mt * Kf); % Gera o sinal FM usando a fórmula: cos(wt + Kf*integral)

% 4. ADICIONANDO O RUÍDO (QUESTÃO 6)
ruido = 0.05 * sin(2*pi*40e3*t);             % Gera o sinal de ruído especificado: 0.05V em 40kHz
st_ruidoso = st + ruido;                     % Soma o ruído ao sinal FM (simula o canal de transmissão)

% 5. DEMODULAÇÃO (DISCRIMINADOR DE FREQUÊNCIA)
% Passo A: Derivada
diff_st = diff([st_ruidoso(1), st_ruidoso]) / Ts; % Deriva o sinal para converter variação de freq. em amplitude
diff_st = abs(diff_st);                           % Aplica o valor absoluto (retificador) para pegar a envoltória

% Passo B: Filtragem
freq_corte = 4000;                                % Define corte do filtro em 4kHz (acima do áudio, abaixo da portadora)
[b, a] = butter(2, freq_corte/(Fs/2));            % Cria um filtro Butterworth Passa-Baixa de 2ª ordem
sinal_recuperado = filter(b, a, diff_st);         % Aplica o filtro no sinal derivado para recuperar o áudio

% Passo C: Limpeza do Sinal (Remover Transiente e DC)
idx_corte = round(length(t) * 0.2);               % Calcula o índice que representa os primeiros 20% dos dados
t_plot = t(idx_corte:end);                        % Cria vetor de tempo cortado (sem o início)
mt_plot = mt(idx_corte:end);                      % Cria vetor da mensagem original cortado
recup_plot = sinal_recuperado(idx_corte:end);     % Cria vetor do sinal recuperado cortado (ignora o transiente inicial)
recup_plot = recup_plot - mean(recup_plot);       % Subtrai a média para remover o nível DC (centraliza no zero)

% VISUALIZAÇÃO DOS RESULTADOS (GERAÇÃO DAS FIGURAS)

% FIGURA 1: SINAIS NO DOMÍNIO DO TEMPO
figure(1);                                        % Abre a janela da Figura 1
subplot(2,1,1);                                   % Divide a janela em 2 linhas, seleciona a 1ª
plot(t*1000, mt, 'b');                            % Plota a mensagem original em azul (tempo em ms)
title('Mensagem Original'); grid on;              % Adiciona título e grade
xlim([0 2]);                                      % Limita o eixo X para mostrar apenas 2ms (zoom)

subplot(2,1,2);                                   % Seleciona a 2ª parte da janela
plot(t*1000, st, 'k');                            % Plota o sinal FM modulado em preto
title('Sinal FM Modulado'); grid on;              % Adiciona título e grade
xlim([0 0.5]);                                    % Limita o eixo X para 0.5ms (zoom maior para ver a onda)

% FIGURA 2: ANÁLISE ESPECTRAL (FFT)
figure(2);                                        % Abre a janela da Figura 2
L = length(st);                                   % Armazena o tamanho do vetor do sinal
Y = fft(st);                                      % Calcula a Transformada Rápida de Fourier (FFT)
P2 = abs(Y/L);                                    % Calcula a magnitude bilateral normalizada
P1 = P2(1:L/2+1);                                 % Seleciona apenas a parte positiva do espectro (unilateral)
P1(2:end-1) = 2*P1(2:end-1);                      % Compensa a energia dobrando os valores (exceto DC e Nyquist)
f = Fs*(0:(L/2))/L;                               % Cria o eixo de frequências em Hz
plot(f/1000, P1, 'b', 'LineWidth', 1.5);          % Plota o espectro (frequência em kHz)
title('Espectro de Magnitude do Sinal FM');       % Adiciona título
xlabel('Frequência (kHz)'); ylabel('|P1(f)|');    % Rotula os eixos
xlim([90 110]); grid on;                          % Foca o gráfico entre 90k e 110k para ver as bandas laterais

% FIGURA 3: VALIDAÇÃO (COMPARAÇÃO ENTRADA vs SAÍDA)
figure(3);                                        % Abre a janela da Figura 3
plot(t_plot*1000, recup_plot, 'r', 'LineWidth', 2); % Plota o sinal recuperado em vermelho (linha grossa)
hold on;                                          % Mantém o gráfico para plotar o próximo em cima
fator = max(abs(recup_plot))/max(abs(mt_plot));   % Calcula fator de escala para igualar amplitudes visualmente
plot(t_plot*1000, mt_plot * fator, 'b--', 'LineWidth', 1); % Plota original em azul pontilhado para comparar
title('Demodulação sob Presença de Ruído');       % Adiciona título
legend('Recuperado', 'Original');                 % Adiciona legenda
grid on; xlim([t_plot(1)*1000, t_plot(1)*1000 + 2]); % Ativa grade e define zoom de 2ms

% FIGURA 4: TESTE DE ROBUSTEZ AO RUÍDO
figure(4);                                        % Abre a janela da Figura 4
plot(t*1000, st, 'k');                            % Plota o sinal FM limpo em preto
hold on;                                          % Mantém o gráfico
plot(t*1000, st_ruidoso, 'r--');                  % Plota o sinal com ruído em vermelho tracejado por cima
title('Comparação: Sinal Limpo (Preto) vs Ruidoso (Vermelho)'); % Adiciona título
xlim([0 0.1]);                                    % Aplica zoom extremo (0.1ms) para tentar ver detalhes
legend('FM Puro', 'FM + Ruído');                  % Adiciona legenda explicativa
