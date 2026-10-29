%% denoise_image_gaussian.m
% Denoise image using Gaussian filter.
% Use Bayesian optimization to find optimal sigma.
% Metrics: NMSE, PSNR, SSIM

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

paramVar = optimizableVariable('sigma',[0.1,3],'Type','real');
objFun = @(params) gaussianImageObjFun(params, ImagClean, ImagNoisy);

results = bayesopt(objFun,paramVar,...
    'AcquisitionFunctionName','expected-improvement-plus',...
    'PlotFcn','all',...
    'Verbose',1,...
    'MaxObjectiveEvaluations',20);

bestSigma = results.XAtMinObjective.sigma;
ImagRecovered = imgaussfilt(ImagNoisy,bestSigma);

clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered,ImagClean);
[ssimval,~] = ssim(ImagRecovered,ImagClean);

disp('--- Gaussian Filter (Image) Results After Optimization ---');
disp(['Chosen sigma: ' num2str(bestSigma)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered,[]); title('Recovered (Gaussian)');


%% Local Objective Function
function val = gaussianImageObjFun(params, ImagClean, ImagNoisy)
    sigma = params.sigma;
    ImagTemp = imgaussfilt(ImagNoisy,sigma);
    clean_vec = double(ImagClean(:));
    rec_vec = double(ImagTemp(:));
    NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
    val = NMSE;
end
