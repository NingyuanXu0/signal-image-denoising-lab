from pathlib import Path

# Signal Denoising using Low-Pass Butterworth Filter

# Import necessary libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
from scipy.signal import butter, filtfilt, freqz

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

# Design a low-pass Butterworth filter
order = 4          # Filter order
cutoff_freq = 1500 # Cutoff frequency in Hz (adjust as needed)

# Normalize the frequency
normal_cutoff = cutoff_freq / (0.5 * fs)

# Get the filter coefficients
b, a = butter(order, normal_cutoff, btype='low', analog=False)

# Apply the filter using filtfilt for zero-phase distortion
fRecovered = filtfilt(b, a, fNoisy)

# Calculate the NMSE
nmse = np.sum((fClean - fRecovered) ** 2) / np.sum(fClean ** 2)
print(f'Normalized Mean Square Error (NMSE): {nmse:.6f}')

# Plot the recovered signal
plt.figure(figsize=(12, 4))
plt.plot(t, fClean, label='Clean Signal')
plt.plot(t, fRecovered, label='Recovered Signal (Butterworth Filter)', alpha=0.7)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Recovered Signal using Low-Pass Butterworth Filter')
plt.legend()
plt.show()

# Plot the frequency response of the filter
w, h = freqz(b, a, worN=8000)
plt.figure(figsize=(12, 4))
plt.plot(0.5*fs*w/np.pi, np.abs(h), 'b')
plt.title('Butterworth Filter Frequency Response')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Gain')
plt.grid()
plt.show()
