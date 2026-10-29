%% denoise_image_gaussian.m
% Denoise image using Gaussian filter with parameter search.

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

candidateSigmas = [0.5,1,1.5,2];
bestNMSE = Inf;
bestSigma = candidateSigmas(1);

for s = candidateSigmas
    ImagTemp = imgaussfilt(ImagNoisy,s);
    nmseVal = sum((double(ImagClean(:))-double(ImagTemp(:))).^2)/sum(double(ImagClean(:)).^2);
    if nmseVal<bestNMSE
        bestNMSE = nmseVal;
        bestSigma = s;
    end
end

ImagRecovered = imgaussfilt(ImagNoisy,bestSigma);

clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered,ImagClean);
[ssimval,~] = ssim(ImagRecovered,ImagClean);

disp('--- Gaussian Filter (Image) Results ---');
disp(['Chosen sigma: ' num2str(bestSigma)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered,[]); title('Recovered (Gaussian)');
