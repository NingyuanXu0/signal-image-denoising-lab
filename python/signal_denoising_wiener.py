from pathlib import Path

# Signal Denoising using Wiener Filter

# Import necessary libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
from scipy.signal import welch
from scipy.fft import fft, ifft, fftfreq

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

# Compute the power spectrum using Welch's method
freqs, Pxx_noisy = welch(fNoisy, fs, nperseg=1024)
freqs, Pxx_clean = welch(fClean, fs, nperseg=1024)

# Plot the power spectrum
plt.figure(figsize=(12, 4))
plt.semilogy(freqs, Pxx_noisy, label='Noisy Signal')
plt.semilogy(freqs, Pxx_clean, label='Clean Signal', alpha=0.7)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Power Spectral Density')
plt.title('Power Spectrum')
plt.legend()
plt.show()

# Estimate the noise (assuming additive noise)
noise_estimate = fNoisy - fClean

# Compute the Fourier Transforms
F_noisy = fft(fNoisy)
F_clean = fft(fClean)
F_noise = fft(noise_estimate)
frequencies = fftfreq(N, d=1/fs)

# Estimate the Power Spectral Densities (PSDs)
Sxx_noisy = np.abs(F_noisy) ** 2
Sxx_noise = np.abs(F_noise) ** 2
Sxx_clean = np.abs(F_clean) ** 2

# Estimate the signal PSD (assuming noise is additive)
Sxx_signal = np.maximum(Sxx_noisy - Sxx_noise, 0)

# Compute the Wiener filter transfer function
H_wiener = Sxx_signal / (Sxx_signal + Sxx_noise + 1e-15)  # Add small constant to avoid division by zero

# Apply the Wiener filter
F_recovered = H_wiener * F_noisy

# Inverse Fourier Transform to get the time-domain signal
fRecovered = np.real(ifft(F_recovered))

# Calculate the NMSE
nmse = np.sum((fClean - fRecovered) ** 2) / np.sum(fClean ** 2)
print(f'Normalized Mean Square Error (NMSE): {nmse:.6f}')

# Plot the recovered signal
plt.figure(figsize=(12, 4))
plt.plot(t, fClean, label='Clean Signal')
plt.plot(t, fRecovered, label='Recovered Signal', alpha=0.7)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Recovered vs Clean Signal')
plt.legend()
plt.show()

# Plot the power spectrum of the recovered signal
F_recovered = fft(fRecovered)
Sxx_recovered = np.abs(F_recovered) ** 2

plt.figure(figsize=(12, 4))
plt.semilogy(frequencies[:N//2], Sxx_recovered[:N//2], label='Recovered Signal')
plt.semilogy(frequencies[:N//2], Sxx_clean[:N//2], label='Clean Signal', alpha=0.7)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Power Spectral Density')
plt.title('Power Spectrum of Recovered Signal')
plt.legend()
plt.show()
