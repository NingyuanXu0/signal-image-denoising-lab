function generate_demo_data(outputDir)
%GENERATE_DEMO_DATA Create synthetic inputs for the MATLAB and Python entries.
if nargin < 1
    outputDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
rng(42, 'twister');
fs = 10000;
t = (0:4095)' / fs;
fClean = 0.9*sin(2*pi*180*t) + 0.4*sin(2*pi*600*t) + 0.25*cos(2*pi*1200*t);
fNoisy = fClean + 0.4*randn(size(fClean));
save(fullfile(outputDir, 'fdata.mat'), 'fClean', 'fNoisy', 'fs');

[x,y] = meshgrid(linspace(0,1,256), linspace(0,1,256));
image = 0.15 + 0.25*x + 0.2*y;
image = image + 0.3*((x>0.1) & (x<0.4) & (y>0.15) & (y<0.7));
image = image + 0.25*((x-0.7).^2 + (y-0.55).^2 < 0.16^2);
ImagClean = uint8(round(255*min(max(image,0),1)));
ImagNoisy = uint8(round(min(max(double(ImagClean) + 20*randn(size(image)),0),255)));
save(fullfile(outputDir, 'image_data.mat'), 'ImagClean', 'ImagNoisy');
fprintf('Synthetic inputs written to %s\n', outputDir);
end
