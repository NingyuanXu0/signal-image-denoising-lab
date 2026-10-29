%% denoise_signal_kalman.m
% Denoise a noisy signal using a simple 1D Kalman filter.
% Compute MSE, NMSE, SNR for evaluation.

clear; close all; clc;

% Load signal data
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

% Setup a simple Kalman filter model:
% State equation: x_k = x_{k-1} + w, w ~ N(0,q)
% Measurement: y_k = x_k + v, v ~ N(0,r)
% We'll guess q and r based on noise level. Adjust as needed.
q = 1e-3; 
r = var(fNoisy - fClean); 
x_hat = 0;   % initial estimate
P = 1;       % initial error covariance

fRecovered = zeros(N,1);
for k=1:N
    % Time update
    x_hat = x_hat;      % x_{k|k-1} = x_{k-1|k-1}
    P = P + q;          % P_{k|k-1} = P_{k-1|k-1} + q

    % Measurement update
    K = P/(P + r);         % Kalman gain
    x_hat = x_hat + K*(fNoisy(k) - x_hat);
    P = (1 - K)*P;

    fRecovered(k) = x_hat;
end

% Compute metrics
err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp(['MSE (Kalman): ' num2str(MSE)]);
disp(['NMSE (Kalman): ' num2str(NMSE)]);
disp(['SNR (Kalman) in dB: ' num2str(SNR_val)]);

% Plot recovered signal
figure;
plot(t, fClean, 'b', 'LineWidth', 1.5); hold on;
plot(t, fRecovered, 'r', 'LineWidth', 1.5);
title('Recovered Signal using Kalman Filter');
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
title('Power Spectrum: Recovered (Kalman)');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
