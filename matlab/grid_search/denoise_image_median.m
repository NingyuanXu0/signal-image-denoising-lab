%% denoise_image_median.m
% Denoise image using median filter with parameter search.
clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

candidateSizes = [3,5,7];
bestNMSE = Inf;
bestSize = candidateSizes(1);

for s = candidateSizes
    ImagTemp = medfilt2(ImagNoisy,[s s]);
    nmseVal = sum((double(ImagClean(:))-double(ImagTemp(:))).^2)/sum(double(ImagClean(:)).^2);
    if nmseVal<bestNMSE
        bestNMSE = nmseVal;
        bestSize = s;
    end
end

ImagRecovered = medfilt2(ImagNoisy,[bestSize bestSize]);

clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered,ImagClean);
[ssimval,~] = ssim(ImagRecovered,ImagClean);

disp('--- Median Filter (Image) Results ---');
disp(['Chosen window size: ' num2str(bestSize)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered,[]); title('Recovered (Median)');
