# Signal and Image Denoising Lab

Compare classical denoising methods on paired clean and noisy signals or grayscale images. The repository collects Python demonstrations and three MATLAB collections: fixed parameters, grid search and Bayesian parameter search. Synthetic-data generators provide inputs in the format expected by the original coursework code.

## Methods

| Collection | Signal methods | Image methods |
| --- | --- | --- |
| `python/` | Frequency-domain Wiener, Butterworth low-pass, moving average, wavelet thresholding | Non-local means |
| `matlab/fixed_parameters/` | Butterworth, scalar Kalman, FIR low-pass, smoothing, local Wiener | Butterworth, Gaussian, row-wise Kalman, median, Wiener |
| `matlab/grid_search/` | The same five methods, with candidate parameter lists | The same five methods, with candidate parameter lists |
| `matlab/bayesian_search/` | The same five methods plus wavelet denoising | The same five image methods |

Scripts display signal traces, spectra or image comparisons and print error metrics. Signal entries report NMSE, with MSE and reconstruction SNR in MATLAB. MATLAB image entries report NMSE, PSNR and SSIM; the Python image entry reports NMSE.

## Experiment design

The grid and Bayesian searches choose parameters by minimizing error against the clean reference on the same example. Kalman entries estimate noise variance from the clean/noisy difference, and the Python Wiener entry uses that difference to estimate noise power. These are experiments with a known reference. Their reported errors describe reconstruction on that example, rather than a held-out estimate of deployment performance.

## Python setup and usage

Use Python 3.10 or later.

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt

# Create the two synthetic MAT inputs.
python scripts/generate_demo_data.py

# Run individual methods.
python python/signal_denoising_butterworth.py
python python/signal_denoising_moving_average.py
python python/signal_denoising_wavelet.py
python python/signal_denoising_wiener.py
python python/image_denoising.py
```

The Python examples locate `data/` relative to their source files. Figures open through matplotlib. The non-local means example uses the current scikit-image `channel_axis` API for grayscale input.

## MATLAB setup and usage

MATLAB entries use Signal Processing Toolbox for filtering and Image Processing Toolbox for image methods and local Wiener filtering. Bayesian search additionally uses Statistics and Machine Learning Toolbox (`bayesopt`, `optimizableVariable`). The Bayesian wavelet entry also uses Wavelet Toolbox (`wdenoise`, `wmaxlev`). Use a MATLAB release that provides these functions and local functions in scripts.

From the repository root, generate inputs in MATLAB or use the Python generator above:

```matlab
addpath('scripts')
generate_demo_data

run('matlab/fixed_parameters/denoise_signal_butterworth.m')
run('matlab/grid_search/denoise_image_gaussian.m')
run('matlab/bayesian_search/denoise_signal_wavelet.m')
```

Run each script by its path to select its parameter strategy. Several collections intentionally share filenames. Bayesian entries allow 20 objective evaluations by default. Their objective functions and search bounds are defined in the entry files.

## Input format

| File under `data/` | Fields | Format |
| --- | --- | --- |
| `fdata.mat` | `fClean`, `fNoisy` | Matching, nonzero real signal vectors sampled at 10,000 Hz; the demo has 4,096 samples |
| `image_data.mat` | `ImagClean`, `ImagNoisy` | Matching two-dimensional `uint8` grayscale images; the demo is 256 × 256 |

The generators create a sum of three sinusoids with additive Gaussian noise and an analytic grayscale pattern with additive clipped Gaussian noise. Each generator uses a fixed seed within its own language; Python and MATLAB random sequences differ. Generate the files once and share those files across implementations when comparing methods. MATLAB entries normalize signal vectors to columns. Keep custom signals long enough for filter padding and wavelet decomposition; the supplied 4,096-sample format matches the example settings.

## Source and publication

The code comes from the author's stochastic signal analysis project. `fixed_parameters` is selected from the original `no AI` snapshot, `grid_search` from the main MATLAB directory, and `bayesian_search` from `AI Test`. Those directory names describe the implemented parameter strategies. The Python Wiener entry is selected from `signal_denoising.py` and given a method-specific filename.

Publication changes make input paths relative to the repository, normalize MATLAB vector orientation, add the missing Python `freqz` import, update scikit-image arguments, correct the fixed Kalman sample-rate label and the rectangular Butterworth frequency-grid shape, and bound wavelet search levels by the input length. Synthetic input generators are new source files.

Existing notices govern the files that carry them; repository-wide reuse terms remain unspecified.

Publication preparation used source review. Local data generation, denoising, optimization and tests were not run.
