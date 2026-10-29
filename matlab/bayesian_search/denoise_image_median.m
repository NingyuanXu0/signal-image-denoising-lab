%% denoise_image_median.m
% Denoise image using median filter.
% Use Bayesian optimization to find optimal window size.
% Metrics: NMSE, PSNR, SSIM

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

paramVar = optimizableVariable('s',[3,15],'Type','integer');
objFun = @(params) medianImageObjFun(params, ImagClean, ImagNoisy);

results = bayesopt(objFun,paramVar,...
    'AcquisitionFunctionName','expected-improvement-plus',...
    'PlotFcn','all', ...
    'Verbose',1,...
    'MaxObjectiveEvaluations',20);

bestSize = results.XAtMinObjective.s;

ImagRecovered = medfilt2(ImagNoisy,[bestSize bestSize]);

clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered,ImagClean);
[ssimval,~] = ssim(ImagRecovered,ImagClean);

disp('--- Median Filter (Image) Results After Optimization ---');
disp(['Chosen window size: ' num2str(bestSize)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered,[]); title('Recovered (Median)');


%% Local Objective Function
function val = medianImageObjFun(params, ImagClean, ImagNoisy)
    s = params.s;
    ImagTemp = medfilt2(ImagNoisy,[s s]);
    clean_vec = double(ImagClean(:));
    rec_vec = double(ImagTemp(:));
    NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
    val = NMSE;
end
