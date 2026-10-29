%% denoise_signal_kalman.m
% Denoise using a simple Kalman filter.
% Parameter optimization over q values.
% Figures as requested.

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

r = var(fNoisy - fClean);
candidateQ = [1e-4, 1e-3, 1e-2];
bestNMSE = Inf;
bestQ = candidateQ(1);

for q = candidateQ
    x_hat = fNoisy(1);
    P = 1;
    fTemp = zeros(N,1);
    for k=1:N
        P = P + q;
        K = P/(P + r);
        x_hat = x_hat + K*(fNoisy(k)-x_hat);
        P = (1-K)*P;
        fTemp(k) = x_hat;
    end
    err = fClean - fTemp;
    NMSE = sum(err.^2)/sum(fClean.^2);
    if NMSE<bestNMSE
        bestNMSE = NMSE;
        bestQ = q;
    end
end

q = bestQ;
x_hat = fNoisy(1);
P = 1;
fRecovered = zeros(N,1);
for k=1:N
    P = P + q;
    K = P/(P + r);
    x_hat = x_hat + K*(fNoisy(k)-x_hat);
    P = (1-K)*P;
    fRecovered(k) = x_hat;
end

err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Kalman Filter Results ---');
disp(['Chosen q: ' num2str(bestQ)]);
disp(['MSE: ' num2str(MSE)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['SNR (dB): ' num2str(SNR_val)]);

% Figure 1: Clean & Noisy
figure(1);
plot(t,fClean,'b','LineWidth',1.5); hold on;
plot(t,fNoisy,'r','LineWidth',1);
title('Clean & Noisy Signals (Figure 1)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;
legend('Clean','Noisy'); hold off;

% Figure 2: Recovered
figure(2);
plot(t,fRecovered,'g','LineWidth',1.5);
title('Recovered Signal (Figure 2)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Figure 3: Clean & Recovered
figure(3);
plot(t,fClean,'b','LineWidth',1.5); hold on;
plot(t,fRecovered,'r','LineWidth',1.5);
title('Clean & Recovered Signals (Figure 3)');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Clean','Recovered'); grid on; hold off;

% Figure 4: Spectrum
X_clean = fft(fClean);
X_rec = fft(fRecovered);
f_axis = (0:N/2)*fs/N;
P_clean = (abs(X_clean(1:N/2+1)).^2)/N;
P_rec = (abs(X_rec(1:N/2+1)).^2)/N;
P_clean_dB = 10*log10(P_clean);
P_rec_dB = 10*log10(P_rec);

figure(4);
plot(f_axis/1e3,P_clean_dB,'b','LineWidth',1.5); hold on;
plot(f_axis/1e3,P_rec_dB,'r','LineWidth',1.5);
title('Power Spectrum (Figure 4)');
xlabel('Frequency (kHz)');
ylabel('Power Spectrum (dB)');
legend('Clean','Recovered');
grid on; hold off;
