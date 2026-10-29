%% denoise_image_kalman.m
% Denoise a noisy grayscale image using a Kalman filter applied row-by-row.
% Compute NMSE, PSNR, and SSIM.

clear; close all; clc;

% Load image data
load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

% Display original & noisy
figure;
subplot(1,2,1); imshow(ImagClean, []); title('Clean Image');
subplot(1,2,2); imshow(ImagNoisy, []); title('Noisy Image');

imgClean = double(ImagClean);
imgNoisy = double(ImagNoisy);

[M, N] = size(imgNoisy);

% Kalman filter parameters (adjust as needed)
q = 1e-3; 
r = var(imgNoisy(:)-imgClean(:));
ImagRecovered = zeros(M,N);

for row = 1:M
    x_hat = imgNoisy(row,1); % initial guess
    P = 1;
    for col = 1:N
        % Predict
        x_hat = x_hat; 
        P = P + q;

        % Update
        K = P/(P + r);
        x_hat = x_hat + K*(imgNoisy(row,col) - x_hat);
        P = (1 - K)*P;

        ImagRecovered(row,col) = x_hat;
    end
end

ImagRecovered_uint8 = uint8(ImagRecovered);

% Display recovered
figure;
imshow(ImagRecovered_uint8, []);
title('Recovered Image (Kalman Filter)');

% Compute metrics
clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));

NMSE = sum((clean_vec - rec_vec).^2) / sum(clean_vec.^2);
[peaksnr, ~] = psnr(ImagRecovered_uint8, ImagClean);
[ssimval, ~] = ssim(ImagRecovered_uint8, ImagClean);

disp(['NMSE (Kalman): ' num2str(NMSE)]);
disp(['PSNR (Kalman) in dB: ' num2str(peaksnr)]);
disp(['SSIM (Kalman): ' num2str(ssimval)]);

% Compare side by side
figure;
subplot(1,3,1); imshow(ImagClean, []); title('Clean Image');
subplot(1,3,2); imshow(ImagNoisy, []); title('Noisy Image');
subplot(1,3,3); imshow(ImagRecovered_uint8, []); title('Recovered (Kalman)');
