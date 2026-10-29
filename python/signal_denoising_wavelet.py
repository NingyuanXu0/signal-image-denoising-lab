from pathlib import Path

# Signal Denoising using Wavelet Denoising

# Import necessary libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
import pywt

# Load the data from 'fdata.mat'
data = loadmat(Path(__file__).resolve().parents[1] / 'data' / 'fdata.mat')
fClean = data['fClean'].flatten()
fNoisy = data['fNoisy'].flatten()

# Sampling parameters
N = len(fClean)       # Number of input samples
fs = 10000            # Sampling frequency in Hz
t = np.arange(N) / fs # Time vector

# Plot the time-domain signals
plt.figure(figsize=(12, 4))
plt.plot(t, fNoisy, label='Noisy Signal')
plt.plot(t, fClean, label='Clean Signal', alpha=0.7)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Time-Domain Signals')
plt.legend()
plt.show()

# Perform Wavelet Denoising
wavelet = 'db8'  # You can choose different wavelets
max_level = pywt.dwt_max_level(len(fNoisy), pywt.Wavelet(wavelet).dec_len)
coeffs = pywt.wavedec(fNoisy, wavelet, level=max_level)

# Estimate the universal threshold
sigma = np.median(np.abs(coeffs[-1])) / 0.6745
uthresh = sigma * np.sqrt(2 * np.log(len(fNoisy)))

# Apply thresholding
denoised_coeffs = coeffs[:]
denoised_coeffs[1:] = (pywt.threshold(i, value=uthresh, mode='soft') for i in denoised_coeffs[1:])

# Reconstruct the signal
fRecovered = pywt.waverec(denoised_coeffs, wavelet)

# Adjust the length if necessary
fRecovered = fRecovered[:N]

# Calculate the NMSE
nmse = np.sum((fClean - fRecovered) ** 2) / np.sum(fClean ** 2)
print(f'Normalized Mean Square Error (NMSE): {nmse:.6f}')

# Plot the recovered signal
plt.figure(figsize=(12, 4))
plt.plot(t, fClean, label='Clean Signal')
plt.plot(t, fRecovered, label='Recovered Signal (Wavelet Denoising)', alpha=0.7)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Recovered Signal using Wavelet Denoising')
plt.legend()
plt.show()
