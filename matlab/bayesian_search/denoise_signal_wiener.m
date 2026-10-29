%% denoise_signal_wiener.m
% Denoise using Wiener filter for a 1D signal.
% Use Bayesian optimization to find the best neighborhood size.
%
% Figures:
%   Figure(1): Clean & Noisy signals
%   Figure(2): Recovered signal only
%   Figure(3): Clean & Recovered signals
%   Figure(4): Power spectrum in dB
%
% Metrics:
%   MSE, NMSE, SNR

clear; close all; clc;

% Load the data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

% Define the optimization variable: windowSize for Wiener filter in one dimension
paramVar = optimizableVariable('windowSize',[5,50],'Type','integer');

% Define the objective function for bayesopt
objFun = @(params) wienerObjFun(params, fClean, fNoisy);

% Run Bayesian optimization with 'PlotFcn','all' to avoid the error
results = bayesopt(objFun, paramVar, ...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'Verbose',1, ...
    'PlotFcn','all', ...        % Use 'all' instead of listing strings
    'MaxObjectiveEvaluations',20); 

% Extract the best window size
bestWindowSize = results.XAtMinObjective.windowSize;

% Now apply Wiener filter with bestWindowSize
fNoisy_2D = reshape(fNoisy,[1,N]);
fRec_2D = wiener2(fNoisy_2D,[1 bestWindowSize]);
fRecovered = reshape(fRec_2D,[N,1]);

% Compute final metrics
err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Wiener Filter (Signal) Results After Optimization ---');
disp(['Chosen neighborhood size: ' num2str(bestWindowSize)]);
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
plot(f_axis/1e3,P_clean_dB,'b','LineWidth',1.5); hold on;
plot(f_axis/1e3,P_rec_dB,'r','LineWidth',1.5);
title('Power Spectrum (Figure 4)');
xlabel('Frequency (kHz)');
ylabel('Power Spectrum (dB)');
legend('Clean','Recovered');
grid on; hold off;


%% Local Objective Function
function val = wienerObjFun(params, fClean, fNoisy)
    % wienerObjFun: Given a windowSize parameter, apply wiener2 filter and compute NMSE.

    N = length(fClean);
    fNoisy_2D = reshape(fNoisy,[1,N]);
    fRec_2D = wiener2(fNoisy_2D,[1 params.windowSize]);
    fRec = reshape(fRec_2D,[N,1]);

    err = fClean - fRec;
    NMSE = sum(err.^2)/sum(fClean.^2);
    val = NMSE; % We want to minimize NMSE.
end
