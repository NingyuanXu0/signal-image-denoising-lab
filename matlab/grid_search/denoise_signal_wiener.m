%% denoise_signal_wiener.m
% Denoise using Wiener filter.
% Parameter optimization over neighborhood sizes.
% Figures as requested.

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

candidateSizes = [11, 21, 31, 41];
bestNMSE = Inf;
bestSize = candidateSizes(1);

for s = candidateSizes
    fNoisy_2D = reshape(fNoisy,[1,N]);
    fTemp_2D = wiener2(fNoisy_2D,[1 s]);
    fTemp = reshape(fTemp_2D,[N,1]);
    err = fClean - fTemp;
    NMSE = sum(err.^2)/sum(fClean.^2);
    if NMSE < bestNMSE
        bestNMSE = NMSE;
        bestSize = s;
    end
end

fNoisy_2D = reshape(fNoisy,[1,N]);
fRec_2D = wiener2(fNoisy_2D,[1 bestSize]);
fRecovered = reshape(fRec_2D,[N,1]);

err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Wiener Filter Results ---');
disp(['Chosen neighborhood size: ' num2str(bestSize)]);
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
X_noisy = fft(fNoisy);
f_axis = (0:N/2)*fs/N;
P_clean = (abs(X_clean(1:N/2+1)).^2)/N;
P_noisy = (abs(X_noisy(1:N/2+1)).^2)/N;
P_clean_dB = 10*log10(P_clean);
P_noisy_dB = 10*log10(P_noisy);
figure(4);
plot(f_axis/1e3,P_clean_dB,'b','LineWidth',1.5); hold on;
plot(f_axis/1e3,P_noisy_dB,'r','LineWidth',1.5);
title('Power Spectrum (Figure 4)');
xlabel('Frequency (kHz)');
ylabel('Power Spectrum (dB)');
legend('Clean','Noisy');
grid on; hold off;
