from pathlib import Path

# Image Denoising using Non-Local Means

# Import necessary libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
from skimage import img_as_float
from skimage.restoration import denoise_nl_means, estimate_sigma

# Load the data from 'image_data.mat'
data = loadmat(Path(__file__).resolve().parents[1] / 'data' / 'image_data.mat')
ImagClean = data['ImagClean']
ImagNoisy = data['ImagNoisy']

# Convert images to floating point representation
ImagClean = img_as_float(ImagClean)
ImagNoisy = img_as_float(ImagNoisy)

# Display the noisy and clean images
plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
plt.imshow(ImagNoisy, cmap='gray')
plt.title('Noisy Image')
plt.axis('off')

plt.subplot(1, 2, 2)
plt.imshow(ImagClean, cmap='gray')
plt.title('Clean Image')
plt.axis('off')
plt.show()

# Estimate the noise standard deviation from the noisy image
sigma_est = np.mean(estimate_sigma(ImagNoisy, channel_axis=None))
print(f'Estimated Noise Standard Deviation: {sigma_est:.6f}')

# Set the parameters for Non-Local Means denoising
patch_kw = dict(patch_size=5,      # 5x5 patches
                patch_distance=6,  # Search in a 13x13 neighborhood
                channel_axis=None)

# Apply Non-Local Means Denoising
h = 1.15 * sigma_est  # Filtering parameter
ImagRecovered = denoise_nl_means(ImagNoisy, h=h, fast_mode=True, **patch_kw)

# Calculate the NMSE
nmse = np.sum((ImagClean - ImagRecovered) ** 2) / np.sum(ImagClean ** 2)
print(f'Normalized Mean Square Error (NMSE): {nmse:.6f}')

# Display the recovered and clean images
plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
plt.imshow(ImagRecovered, cmap='gray')
plt.title('Recovered Image')
plt.axis('off')

plt.subplot(1, 2, 2)
plt.imshow(ImagClean, cmap='gray')
plt.title('Clean Image')
plt.axis('off')
plt.show()

# Display the difference between the clean and recovered images
plt.figure(figsize=(6, 6))
plt.imshow(ImagClean - ImagRecovered, cmap='gray')
plt.title('Difference Image')
plt.axis('off')
plt.show()
