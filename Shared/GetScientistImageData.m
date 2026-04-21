function caProcessedImages = GetScientistImageData(numImages, imageSize)
% GetScientistImageData  Load and normalise scientist portrait images.
%
% Reads the first numImages images from the Scientists/ subfolder (located
% next to this function file), resizes them to imageSize x imageSize,
% converts to lightness, and normalises each image to zero mean and unit
% Frobenius norm.
%
% Inputs:
%   numImages : number of images to load
%   imageSize : target side length in pixels (images are resized to square)
%
% Output:
%   caProcessedImages : 1 x numImages cell array of imageSize x imageSize matrices

    % Locate Scientists/ relative to this function file, not the CWD
    sharedDir = fileparts(mfilename('fullpath'));
    scientistsDir = fullfile(sharedDir, 'Scientists');

    vsItems      = dir(scientistsDir);
    vsImageFiles = arrayfun(@(x) fullfile(scientistsDir, x.name), ...
                            vsItems(~[vsItems.isdir]), 'UniformOutput', false);
    assert(numImages <= numel(vsImageFiles), ...
        'Not enough images in Scientists/ — add more images to the folder.');

    processImage  = @(path) NormalizeImage( ...
        imresize(double(rgb2lightness(imread(path))), [imageSize, imageSize]));
    caProcessedImages = cellfun(processImage, vsImageFiles(1:numImages), ...
                                'UniformOutput', false);
end

function img = NormalizeImage(img)
    img = img - mean(img, 'all');
    img = img / norm(img, 'fro');
end
