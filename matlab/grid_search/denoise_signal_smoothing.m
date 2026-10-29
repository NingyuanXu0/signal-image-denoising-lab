%% denoise_signal_smoothing.m
% Denoise using a moving average (smoothing) filter.
% Parameter optimization over window size.
% Figures:
%   Figure(1): Clean & Noisy signals
%   Figure(2): Recovered signal only
%   Figure(3): Clean & Recovered signals
%   Figure(4): Power spectrum in dB

clear; close all; clc;

% Load data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

% Parameter Optimization
candidateWindowSizes = [5, 10, 15, 20, 25];
bestNMSE = Inf;
bestWindowSize = candidateWindowSizes(1);

for w = candidateWindowSizes
    b = (1/w)*ones(1,w);
    a = 1;
    fTemp = filtfilt(b,a,fNoisy);
    err = fClean - fTemp;
    NMSE = sum(err.^2)/sum(fClean.^2);
    if NMSE < bestNMSE
        bestNMSE = NMSE;
        bestWindowSize = w;
    end
end

% Use best parameter
windowSize = bestWindowSize;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
fRecovered = filtfilt(b,a,fNoisy);

% Compute metrics
err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Smoothing Filter Results ---');
disp(['Chosen window size: ' num2str(windowSize)]);
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

% Figure 2: Recovered only
figure(2);
plot(t,fRecovered,'g','LineWidth',1.5);
title('Recovered Signal (Figure 2)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Figure 3: Clean & Recovered
figure(3);
plot(t,fClean,'b','LineWidth',1.5); hold on;
plot(t,fRecovered,'r','LineWidth',1.5);
title('Clean & Recovered Signals (Figure 3)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;
legend('Clean','Recovered'); hold off;

% Figure 4: Spectrum in dB
X_clean = fft(fClean);
X_rec = fft(fRecovered);
f_axis = (0:N/2)*fs/N;
P_clean = (abs(X_clean(1:N/2+1)).^2)/N;
P_rec = (abs(X_rec(1:N/2+1)).^2)/N;

P_clean_dB = 10*log10(P_clean);
P_rec_dB = 10*log10(P_rec);

figure(4);
plot(f_axis/1e3, P_clean_dB,'b','LineWidth',1.5); hold on;
plot(f_axis/1e3, P_rec_dB,'r','LineWidth',1.5);
title('Power Spectrum (Figure 4)');
xlabel('Frequency (kHz)');
ylabel('Power Spectrum (dB)');
legend('Clean','Recovered');
grid on; hold off;
