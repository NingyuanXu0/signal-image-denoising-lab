%% denoise_image_butterworth.m
% Denoise image using a Butterworth filter (frequency domain).
% Parameter search over D0.

clear; close all; clc;

load(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'image_data.mat'), 'ImagClean', 'ImagNoisy');

figure(1);
imshow(ImagClean,[]); title('Clean Image (Figure 1)');

figure(2);
imshow(ImagNoisy,[]); title('Noisy Image (Figure 2)');

imgNoisy = double(ImagNoisy);
[M,N] = size(imgNoisy);
F_noisy = fftshift(fft2(imgNoisy));

candidateD0 = [10,20,30];
order = 2;
bestNMSE = Inf;
bestD0 = candidateD0(1);

for D0 = candidateD0
    [u,v] = meshgrid(-floor(N/2):ceil(N/2)-1,-floor(M/2):ceil(M/2)-1);
    D = sqrt(u.^2 + v.^2);
    H = 1./(1+(D/D0).^(2*order));
    F_filt = F_noisy.*H;
    ImagTemp = real(ifft2(ifftshift(F_filt)));
    nmseVal = sum((double(ImagClean(:))-ImagTemp(:)).^2)/sum(double(ImagClean(:)).^2);
    if nmseVal<bestNMSE
        bestNMSE = nmseVal;
        bestD0 = D0;
    end
end

D0 = bestD0;
[u,v] = meshgrid(-floor(N/2):ceil(N/2)-1,-floor(M/2):ceil(M/2)-1);
D = sqrt(u.^2+v.^2);
H = 1./(1+(D/D0).^(2*order));
F_filt = F_noisy.*H;
ImagRecovered = real(ifft2(ifftshift(F_filt)));
ImagRecovered_uint8 = uint8(ImagRecovered);

clean_vec = double(ImagClean(:));
rec_vec = double(ImagRecovered(:));
NMSE = sum((clean_vec - rec_vec).^2)/sum(clean_vec.^2);
[peaksnr,~] = psnr(ImagRecovered_uint8,ImagClean);
[ssimval,~] = ssim(ImagRecovered_uint8,ImagClean);

disp('--- Butterworth Filter (Image) Results ---');
disp(['Chosen D0: ' num2str(bestD0)]);
disp(['NMSE: ' num2str(NMSE)]);
disp(['PSNR (dB): ' num2str(peaksnr)]);
disp(['SSIM: ' num2str(ssimval)]);

figure(3);
subplot(1,3,1); imshow(ImagClean,[]); title('Clean');
subplot(1,3,2); imshow(ImagNoisy,[]); title('Noisy');
subplot(1,3,3); imshow(ImagRecovered_uint8,[]); title('Recovered (Butterworth)');
