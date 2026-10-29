%% denoise_image_median.m
% Denoise a noisy grayscale image using a median filter.
% Compute NMSE, PSNR, and SSIM for quantitative evaluation.

clear; close all; clc;

% Load image data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

% Display original & noisy
figure;
subplot(1,2,1); imshow(ImagClean, []); title('Clean Image');
subplot(1,2,2); imshow(ImagNoisy, []); title('Noisy Image');

% Apply Median filtering
windowSize = [3 3]; % Adjust as needed
ImagRecovered = medfilt2(ImagNoisy, windowSize);

% Display recovered
figure;
imshow(ImagRecovered, []); title('Recovered Image (Median Filter)');

% Compute metrics
clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));

NMSE = sum((clean_vec - rec_vec).^2) / sum(clean_vec.^2);
[peaksnr, ~] = psnr(ImagRecovered, ImagClean);
[ssimval, ~] = ssim(ImagRecovered, ImagClean);

disp(['NMSE (Median): ' num2str(NMSE)]);
disp(['PSNR (Median) in dB: ' num2str(peaksnr)]);
disp(['SSIM (Median): ' num2str(ssimval)]);

% Compare all three images side by side
figure;
subplot(1,3,1); imshow(ImagClean, []); title('Clean Image');
subplot(1,3,2); imshow(ImagNoisy, []); title('Noisy Image');
subplot(1,3,3); imshow(ImagRecovered, []); title('Recovered (Median)');
