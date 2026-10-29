%% denoise_image_butterworth.m
% Denoise a noisy grayscale image using a 2D Butterworth low-pass filter.
% Compute NMSE, PSNR, and SSIM.

clear; close all; clc;

% Load image data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

% Display original & noisy
figure;
subplot(1,2,1); imshow(ImagClean, []); title('Clean Image');
subplot(1,2,2); imshow(ImagNoisy, []); title('Noisy Image');

% Convert to double
imgNoisy = double(ImagNoisy);
[M, N] = size(imgNoisy);

% Frequency domain representation
F_noisy = fftshift(fft2(imgNoisy));

% Design a Butterworth filter
% Cutoff frequency
D0 = 20; % adjust as needed
order = 2; 
u = (-floor(N/2):ceil(N/2)-1);
v = (-floor(M/2):ceil(M/2)-1);
[U,V] = meshgrid(u,v);
D = sqrt(U.^2 + V.^2);
H = 1./(1+(D./D0).^(2*order));

% Apply filter
F_filt = F_noisy .* H;
ImagRecovered = real(ifft2(ifftshift(F_filt)));

% Display recovered
figure;
imshow(ImagRecovered, []); title('Recovered Image (Butterworth)');

% Compute metrics
clean_vec = double(ImagClean(:));
rec_vec = ImagRecovered(:);

NMSE = sum((clean_vec - rec_vec).^2) / sum(clean_vec.^2);
[peaksnr, ~] = psnr(uint8(ImagRecovered), ImagClean);
[ssimval, ~] = ssim(uint8(ImagRecovered), ImagClean);

disp(['NMSE (Butterworth): ' num2str(NMSE)]);
disp(['PSNR (Butterworth) in dB: ' num2str(peaksnr)]);
disp(['SSIM (Butterworth): ' num2str(ssimval)]);

% Compare side by side
figure;
subplot(1,3,1); imshow(ImagClean, []); title('Clean Image');
subplot(1,3,2); imshow(ImagNoisy, []); title('Noisy Image');
subplot(1,3,3); imshow(ImagRecovered, []); title('Recovered (Butterworth)');
