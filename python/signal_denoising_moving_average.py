from pathlib import Path

# Signal Denoising using Moving Average Filter

# Import necessary libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat

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

# Implement Moving Average Filter
window_size = 5  # You can adjust the window size
cumsum_vec = np.cumsum(np.insert(fNoisy, 0, 0)) 
fRecovered = (cumsum_vec[window_size:] - cumsum_vec[:-window_size]) / window_size

# Adjust the length of the recovered signal to match the original
pad_size = N - len(fRecovered)
fRecovered = np.pad(fRecovered, (pad_size//2, pad_size - pad_size//2), 'edge')

# Calculate the NMSE
nmse = np.sum((fClean - fRecovered) ** 2) / np.sum(fClean ** 2)
print(f'Normalized Mean Square Error (NMSE): {nmse:.6f}')

# Plot the recovered signal
plt.figure(figsize=(12, 4))
plt.plot(t, fClean, label='Clean Signal')
plt.plot(t, fRecovered, label='Recovered Signal (Moving Average)', alpha=0.7)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Recovered Signal using Moving Average Filter')
plt.legend()
plt.show()
