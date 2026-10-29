%% denoise_signal_wavelet.m
% Denoise using Wavelet-based denoising.
% Use Bayesian optimization to find the optimal wavelet decomposition level.
% Figures:
%   (1): Clean & Noisy
%   (2): Recovered only
%   (3): Clean & Recovered
%   (4): Spectrum in dB
%
% Metrics: MSE, NMSE, SNR

clear; close all; clc;

% Load the data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

% Bound decomposition level by the input length and wavelet support
maxLevel = min(10, wmaxlev(N, 'sym4'));
paramVar = optimizableVariable('level',[1,maxLevel],'Type','integer');

% Objective function for Bayesian optimization
objFun = @(params) waveletObjFun(params, fClean, fNoisy);

% Run Bayesian optimization
results = bayesopt(objFun, paramVar, ...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'Verbose',1, ...
    'PlotFcn','all', ...
    'MaxObjectiveEvaluations',20);

% Extract the best level
bestLevel = results.XAtMinObjective.level;

% Apply wavelet denoising with bestLevel
% Choose a fixed wavelet, for example 'sym4'
fRecovered = wdenoise(fNoisy, bestLevel, 'Wavelet', 'sym4');

% Compute final metrics
err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Wavelet Denoising Results After Optimization ---');
disp(['Chosen decomposition level: ' num2str(bestLevel)]);
disp(['MSE: ' num2str(MSE)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['SNR (dB): ' num2str(SNR_val)]);

% Figure(1): Clean & Noisy
figure(1);
plot(t, fClean, 'b', 'LineWidth', 1.5); hold on;
plot(t, fNoisy, 'r', 'LineWidth', 1);
title('Clean & Noisy Signals (Figure 1)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on; legend('Clean','Noisy'); hold off;

% Figure(2): Recovered only
figure(2);
plot(t, fRecovered, 'g', 'LineWidth', 1.5);
title('Recovered Signal (Figure 2)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Figure(3): Clean & Recovered
figure(3);
plot(t, fClean, 'b', 'LineWidth', 1.5); hold on;
plot(t, fRecovered, 'r', 'LineWidth', 1.5);
title('Clean & Recovered Signals (Figure 3)');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Clean','Recovered'); grid on; hold off;

% Figure(4): Power spectrum in dB
X_clean = fft(fClean);
X_rec = fft(fRecovered);
f_axis = (0:N/2)*fs/N;
P_clean = (abs(X_clean(1:N/2+1)).^2)/N;
P_rec = (abs(X_rec(1:N/2+1)).^2)/N;
P_clean_dB = 10*log10(P_clean);
P_rec_dB = 10*log10(P_rec);

figure(4);
plot(f_axis/1e3, P_clean_dB, 'b', 'LineWidth', 1.5); hold on;
plot(f_axis/1e3, P_rec_dB, 'r', 'LineWidth', 1.5);
title('Power Spectrum (Figure 4)');
xlabel('Frequency (kHz)'); ylabel('Power Spectrum (dB)');
legend('Clean','Recovered'); grid on; hold off;


%% Local Objective Function
function val = waveletObjFun(params, fClean, fNoisy)
    level = params.level;
    % Fixed wavelet type
    wavName = 'sym4';
    fRec = wdenoise(fNoisy, level, 'Wavelet', wavName);
    err = fClean - fRec;
    NMSE = sum(err.^2)/sum(fClean.^2);
    val = NMSE;  % Minimizing NMSE
end
