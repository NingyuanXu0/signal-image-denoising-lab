"""Write synthetic signal and grayscale image pairs in the expected MAT format."""

import argparse
from pathlib import Path
import numpy as np
from scipy.io import savemat


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=Path(__file__).resolve().parents[1] / 'data')
    parser.add_argument('--seed', type=int, default=42)
    args = parser.parse_args()
    output_dir = args.output_dir.expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    rng = np.random.default_rng(args.seed)

    fs = 10000
    time = np.arange(4096) / fs
    clean = (0.9 * np.sin(2 * np.pi * 180 * time)
             + 0.4 * np.sin(2 * np.pi * 600 * time)
             + 0.25 * np.cos(2 * np.pi * 1200 * time))
    noisy = clean + rng.normal(0.0, 0.4, clean.shape)
    savemat(output_dir / 'fdata.mat', {'fClean': clean[:, None], 'fNoisy': noisy[:, None], 'fs': fs})

    x, y = np.meshgrid(np.linspace(0, 1, 256), np.linspace(0, 1, 256))
    image = 0.15 + 0.25 * x + 0.2 * y
    image += 0.3 * ((x > 0.1) & (x < 0.4) & (y > 0.15) & (y < 0.7))
    image += 0.25 * ((x - 0.7) ** 2 + (y - 0.55) ** 2 < 0.16 ** 2)
    clean_image = np.rint(255 * np.clip(image, 0, 1)).astype(np.uint8)
    noisy_image = np.rint(np.clip(clean_image.astype(float) + rng.normal(0.0, 20.0, image.shape), 0, 255)).astype(np.uint8)
    savemat(output_dir / 'image_data.mat', {'ImagClean': clean_image, 'ImagNoisy': noisy_image})
    print(f'Synthetic inputs written to {output_dir}')


if __name__ == '__main__':
    main()
