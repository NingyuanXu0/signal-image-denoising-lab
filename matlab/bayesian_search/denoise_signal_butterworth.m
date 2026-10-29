%% denoise_signal_butterworth.m
% Denoise using a Butterworth low-pass filter.
% Optimize cutoff frequency using Bayesian optimization.

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'fdata.mat'), 'fClean', 'fNoisy');
fClean = fClean(:);
fNoisy = fNoisy(:);
N = length(fClean);
fs = 10e3;
t = (0:N-1)/fs;

paramVar = optimizableVariable('cutoff',[100,4000],'Type','real');
objFun = @(params) butterworthObjFun(params, fClean, fNoisy, fs);

results = bayesopt(objFun, paramVar, ...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'Verbose',1, ...
    'PlotFcn','all', ...
    'MaxObjectiveEvaluations',20);

bestCutoff = results.XAtMinObjective.cutoff;

Wn = bestCutoff/(fs/2);
[b,a] = butter(4,Wn,'low');
fRecovered = filtfilt(b,a,fNoisy);

err = fClean - fRecovered;
MSE = mean(err.^2);
NMSE = sum(err.^2)/sum(fClean.^2);
SNR_val = 10*log10(sum(fClean.^2)/sum(err.^2));

disp('--- Butterworth Filter Results After Optimization ---');
disp(['Chosen cutoff (Hz): ' num2str(bestCutoff)]);
disp(['MSE: ' num2str(MSE)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['SNR (dB): ' num2str(SNR_val)]);

% Figures
figure(1);
plot(t,fClean,'b',t,fNoisy,'r','LineWidth',1.5);
title('Clean & Noisy (Figure 1)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; legend('Clean','Noisy');

figure(2);
plot(t,fRecovered,'g','LineWidth',1.5);
title('Recovered (Figure 2)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

figure(3);
plot(t,fClean,'b','LineWidth',1.5); hold on;
plot(t,fRecovered,'r','LineWidth',1.5);
title('Clean & Recovered (Figure 3)');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Clean','Recovered'); grid on; hold off;

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
xlabel('Frequency (kHz)');
ylabel('Power (dB)');
legend('Clean','Recovered'); grid on; hold off;


%% Local Objective Function
function val = butterworthObjFun(params, fClean, fNoisy, fs)
    cutoff = params.cutoff;
    Wn = cutoff/(fs/2);
    [b,a] = butter(4,Wn,'low');
    fRec = filtfilt(b,a,fNoisy);
    err = fClean - fRec;
    NMSE = sum(err.^2)/sum(fClean.^2);
    val = NMSE;
end
