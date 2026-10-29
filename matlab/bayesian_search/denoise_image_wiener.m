%% denoise_image_wiener.m
% Denoise image using Wiener filter.
% Use Bayesian optimization to find optimal neighborhood size.
% Metrics: NMSE, PSNR, SSIM

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

% Define optimizable variable
paramVar = optimizableVariable('s',[3,15],'Type','integer');

% Objective function (returns NMSE)
objFun = @(params) wienerImageObjFun(params, ImagClean, ImagNoisy);

results = bayesopt(objFun, paramVar, ...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'PlotFcn','all',...
    'Verbose',1, ...
    'MaxObjectiveEvaluations',20);

bestSize = results.XAtMinObjective.s;

% Apply Wiener filter with bestSize
ImagRecovered = wiener2(ImagNoisy,[bestSize bestSize]);

% Compute metrics
clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered,ImagClean);
[ssimval,~] = ssim(ImagRecovered,ImagClean);

disp('--- Wiener Filter (Image) Results After Optimization ---');
disp(['Chosen neighborhood size: ' num2str(bestSize)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered,[]); title('Recovered (Wiener)');


%% Local Objective Function
function val = wienerImageObjFun(params, ImagClean, ImagNoisy)
    s = params.s;
    ImagTemp = wiener2(ImagNoisy,[s s]);
    clean_vec = double(ImagClean(:));
    rec_vec = double(ImagTemp(:));
    NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
    val = NMSE;
end
