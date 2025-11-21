% =========================================================================
% PROJETO FM - VERSÃO FINAL COMPLETA (COM ESPECTRO E RUÍDO)
% =========================================================================
pkg load signal;
clc; clear; close all;

% --- 1. PARÂMETROS GERAIS ---
Ac = 4;            % Amplitude portadora
fc = 100e3;        % Freq portadora (100 kHz)
Kf = 6000;         % Sensibilidade
Am = 2;            % Amplitude moduladora
fm = 2e3;          % Freq moduladora (2 kHz)

% --- 2. TEMPO E FREQUÊNCIA ---
Fs = 10 * fc;      % 1 MHz (Amostragem alta para boa resolução)
Ts = 1/Fs;
t_final = 10/fm;   % Aumentei o tempo para o espectro ficar mais bonito
t = 0:Ts:t_final;

% --- 3. GERAÇÃO DOS SINAIS ---
mt = Am * sin(2*pi*fm*t);                    % Mensagem (Áudio)
integral_mt = cumsum(mt) * Ts;
st = Ac * cos(2*pi*fc*t + integral_mt * Kf); % Sinal FM Puro

% --- 4. ADICIONANDO O RUÍDO (PERGUNTA 6) ---
% r(t) = 0.05 * sen(2pi * 40k * t)
ruido = 0.05 * sin(2*pi*40e3*t);
st_ruidoso = st + ruido; % Sinal que chega no receptor

% --- 5. DEMODULAÇÃO DO SINAL RUIDOSO ---
% Derivada
diff_st = diff([st_ruidoso(1), st_ruidoso]) / Ts;
diff_st = abs(diff_st);

% Filtro Passa-Baixa (Ajustado: Ordem 2, 4kHz)
freq_corte = 4000;
[b, a] = butter(2, freq_corte/(Fs/2));
sinal_recuperado = filter(b, a, diff_st);

% Corte de Transiente (Primeiros 20%)
idx_corte = round(length(t) * 0.2);
t_plot = t(idx_corte:end);
mt_plot = mt(idx_corte:end);
recup_plot = sinal_recuperado(idx_corte:end);
recup_plot = recup_plot - mean(recup_plot); % Remove DC

% =========================================================================
% VISUALIZAÇÃO (5 FIGURAS PARA O SLIDE)
% =========================================================================

% FIG 1: Sinais no Tempo (Zoom curto)
figure(1);
subplot(2,1,1); plot(t*1000, mt, 'b'); title('Mensagem Original'); grid on; xlim([0 2]);
subplot(2,1,2); plot(t*1000, st, 'k'); title('Sinal FM Modulado'); grid on; xlim([0 0.5]);

% FIG 2: ESPECTRO DE FREQUÊNCIA (IMPORTANTE PARA PERGUNTA 3)
figure(2);
L = length(st);
Y = fft(st);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f/1000, P1, 'b', 'LineWidth', 1.5);
title('Espectro de Magnitude do Sinal FM');
xlabel('Frequência (kHz)'); ylabel('|P1(f)|');
xlim([90 110]); % Zoom entre 90k e 110k para ver as bandas laterais
grid on;
% Dica para o slide: Mostre que a energia se espalha ao redor de 100kHz

% FIG 3: VALIDAÇÃO DA DEMODULAÇÃO (COM RUÍDO)
figure(3);
plot(t_plot*1000, recup_plot, 'r', 'LineWidth', 2); hold on;
fator = max(abs(recup_plot))/max(abs(mt_plot));
plot(t_plot*1000, mt_plot * fator, 'b--', 'LineWidth', 1);
title('Demodulação sob Presença de Ruído');
legend('Recuperado', 'Original');
grid on; xlim([t_plot(1)*1000, t_plot(1)*1000 + 2]);

% FIG 4: PROVA DE ROBUSTEZ (Zoom no ruído)
figure(4);
plot(t*1000, st, 'k'); hold on;
plot(t*1000, st_ruidoso, 'r--');
title('Comparação: Sinal Limpo (Preto) vs Ruidoso (Vermelho)');
xlim([0 0.1]); % Zoom extremo
legend('FM Puro', 'FM + Ruído');
% Explicação: O ruído afeta a AMPLITUDE, mas a informação está na FREQUÊNCIA.
