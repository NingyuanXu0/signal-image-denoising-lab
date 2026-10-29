%% denoise_signal_wiener.m
% Denoise using Wiener filtering. Evaluate MSE, NMSE, SNR.

clear; close all; clc;

% Load data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);

N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

% Plot original & noisy
figure;
subplot(2,1,1)
plot(t, fClean, 'LineWidth', 1.5);
title('Original Clean Signal');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(2,1,2)
plot(t, fNoisy, 'r', 'LineWidth', 1);
title('Noisy Signal');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Wiener filtering (treat 1D signal as a single-row image)
fNoisy_2D = reshape(fNoisy, [1, N]);
neighborhood = [1 31];
fRec_2D = wiener2(fNoisy_2D, neighborhood);
fRecovered = reshape(fRec_2D, [N, 1]);

% Metrics
err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2) / sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp(['MSE (Wiener): ' num2str(MSE)]);
disp(['NMSE (Wiener): ' num2str(NMSE)]);
disp(['SNR (Wiener) in dB: ' num2str(SNR_val)]);

% Plot recovered
figure;
plot(t, fClean, 'b', 'LineWidth', 1.5); hold on;
plot(t, fRecovered, 'r', 'LineWidth', 1.5);
title('Recovered Signal using Wiener Filter');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Clean', 'Recovered'); grid on;

% Power spectra
F = (-N/2:N/2-1)*(fs/N);
fClean_fft = fftshift(abs(fft(fClean)));
fNoisy_fft = fftshift(abs(fft(fNoisy)));
fRec_fft = fftshift(abs(fft(fRecovered)));

figure;
subplot(3,1,1)
plot(F, fClean_fft);
title('Power Spectrum: Clean Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(3,1,2)
plot(F, fNoisy_fft, 'r');
title('Power Spectrum: Noisy Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(3,1,3)
plot(F, fRec_fft, 'g');
title('Power Spectrum: Recovered (Wiener)');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
