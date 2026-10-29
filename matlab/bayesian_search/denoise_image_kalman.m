%% denoise_image_kalman.m
% Denoise image using Kalman filter row-by-row.
% Use Bayesian optimization to find q.
% Metrics: NMSE, PSNR, SSIM

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

r = var(double(ImagNoisy(:))-double(ImagClean(:)));
paramVar = optimizableVariable('q',[1e-5,1e-1],'Type','real','Transform','log');
objFun = @(params) kalmanImageObjFun(params, ImagClean, ImagNoisy, r);

results = bayesopt(objFun,paramVar,...
    'AcquisitionFunctionName','expected-improvement-plus',...
    'PlotFcn','all',...
    'Verbose',1,...
    'MaxObjectiveEvaluations',20);

bestQ = results.XAtMinObjective.q;

imgClean = double(ImagClean);
imgNoisy = double(ImagNoisy);
[M,N] = size(imgNoisy);
ImagRecovered = zeros(M,N);

for row=1:M
    x_hat = imgNoisy(row,1);
    P=1;
    for col=1:N
        P=P+bestQ;
        K=P/(P+r);
        x_hat = x_hat + K*(imgNoisy(row,col)-x_hat);
        P=(1-K)*P;
        ImagRecovered(row,col)=x_hat;
    end
end

ImagRecovered_uint8 = uint8(ImagRecovered);

clean_vec = imgClean(:);
rec_vec = ImagRecovered(:);
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered_uint8,ImagClean);
[ssimval,~] = ssim(ImagRecovered_uint8,ImagClean);

disp('--- Kalman Filter (Image) Results After Optimization ---');
disp(['Chosen q: ' num2str(bestQ)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered_uint8,[]); title('Recovered (Kalman)');


%% Local Objective Function
function val = kalmanImageObjFun(params, ImagClean, ImagNoisy, r)
    q = params.q;
    imgClean = double(ImagClean);
    imgNoisy = double(ImagNoisy);
    [M,N] = size(imgNoisy);
    ImagTemp = zeros(M,N);

    for row=1:M
        x_hat = imgNoisy(row,1);
        P=1;
        for col=1:N
            P=P+q;
            K=P/(P+r);
            x_hat=x_hat+K*(imgNoisy(row,col)-x_hat);
            P=(1-K)*P;
            ImagTemp(row,col)=x_hat;
        end
    end

    clean_vec = imgClean(:);
    rec_vec = ImagTemp(:);
    NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
    val = NMSE;
end
