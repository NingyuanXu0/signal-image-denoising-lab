%% denoise_signal_smoothing.m
% Denoise using a moving average (smoothing) filter.
% Use Bayesian optimization to find optimal windowSize.
% Figures:
%  (1) Clean & Noisy
%  (2) Recovered only
%  (3) Clean & Recovered
%  (4) Spectrum

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

% Define optimization variable
paramVar = optimizableVariable('windowSize',[3,50],'Type','integer');

% Objective function
objFun = @(params) smoothingObjFun(params, fClean, fNoisy);

% Bayesian optimization
results = bayesopt(objFun, paramVar, ...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'Verbose',1, ...
    'PlotFcn','all', ...
    'MaxObjectiveEvaluations',20);

bestWindowSize = results.XAtMinObjective.windowSize;

% Apply smoothing with bestWindowSize
b = (1/bestWindowSize)*ones(1,bestWindowSize);
a = 1;
fRecovered = filtfilt(b,a,fNoisy);

% Metrics
err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Smoothing Filter Results After Optimization ---');
disp(['Chosen window size: ' num2str(bestWindowSize)]);
disp(['MSE: ' num2str(MSE)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['SNR (dB): ' num2str(SNR_val)]);

% Figures
figure(1); % Clean & Noisy
plot(t,fClean,'b','LineWidth',1.5); hold on;
plot(t,fNoisy,'r','LineWidth',1);
title('Clean & Noisy (Figure 1)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; legend('Clean','Noisy'); hold off;

figure(2); % Recovered
plot(t,fRecovered,'g','LineWidth',1.5);
title('Recovered (Figure 2)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

figure(3); % Clean & Recovered
plot(t,fClean,'b','LineWidth',1.5); hold on;
plot(t,fRecovered,'r','LineWidth',1.5);
title('Clean & Recovered (Figure 3)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; legend('Clean','Recovered'); hold off;

% Spectrum
X_clean = fft(fClean);
X_rec = fft(fRecovered);
f_axis = (0:N/2)*fs/N;
P_clean = abs(X_clean(1:N/2+1)).^2/N;
P_rec = abs(X_rec(1:N/2+1)).^2/N;
P_clean_dB = 10*log10(P_clean);
P_rec_dB = 10*log10(P_rec);

figure(4);
plot(f_axis/1e3,P_clean_dB,'b','LineWidth',1.5); hold on;
plot(f_axis/1e3,P_rec_dB,'r','LineWidth',1.5);
title('Power Spectrum (Figure 4)');
xlabel('Frequency (kHz)'); ylabel('Power (dB)');
legend('Clean','Recovered'); grid on; hold off;


%% Local Objective Function
function val = smoothingObjFun(params, fClean, fNoisy)
    N = length(fClean);
    w = params.windowSize;
    b = (1/w)*ones(1,w);
    a = 1;
    fRec = filtfilt(b,a,fNoisy);
    err = fClean - fRec;
    NMSE = sum(err.^2)/sum(fClean.^2);
    val = NMSE;
end
