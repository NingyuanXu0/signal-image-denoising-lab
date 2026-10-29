%% denoise_signal_lowpass.m
% Denoise using a low-pass FIR filter.
% Parameter optimization over cutoff frequency.
% Figures as per the new requirement.

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

candidateCutoffs = [500, 1000, 2000]; % Hz
bestNMSE = Inf;
bestCutoff = candidateCutoffs(1);

for c = candidateCutoffs
    normCutoff = c/(fs/2);
    filterOrder = 64;
    lpFilt = fir1(filterOrder, normCutoff, 'low', hamming(filterOrder+1));
    fTemp = filtfilt(lpFilt,1,fNoisy);
    err = fClean - fTemp;
    NMSE = sum(err.^2)/sum(fClean.^2);
    if NMSE < bestNMSE
        bestNMSE = NMSE;
        bestCutoff = c;
    end
end

cutoff = bestCutoff;
normCutoff = cutoff/(fs/2);
filterOrder = 64;
lpFilt = fir1(filterOrder, normCutoff, 'low', hamming(filterOrder+1));
fRecovered = filtfilt(lpFilt,1,fNoisy);

err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Low-Pass Filter Results ---');
disp(['Chosen cutoff frequency (Hz): ' num2str(cutoff)]);
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
