function res = RunMismatchedEmExperiment(K, imageSize, vSnrDb, vRatioVec, opts)
% RunMismatchedEmExperiment  Population EM misspecification experiment.
%
% Loads scientist portrait images as GMM centroids, converts the SNR grid
% to true sigma values, sweeps population EM over all (sigmaTrue, tau/sigma)
% pairs via Gauss-Hermite quadrature, and plots the MSE heat-map.
%
% Inputs (all optional):
%   K          : number of mixture components              (default 2)
%   imageSize  : image side length in pixels               (default 2)
%   vSnrDb     : SNR sweep in dB                           (default linspace(-30,30,31))
%   vRatioVec  : tau/sigma ratio sweep (exclude rho=1)     (default logspace(-2,0,1000))
%   opts       : struct forwarded to RunPopulationEmSweep  (default struct())
%
% Output:
%   res : result struct from RunPopulationEmSweep

    if nargin < 1, K         = 2; end
    if nargin < 2, imageSize = 2; end
    if nargin < 3, vSnrDb    = linspace(-30, 30, 31); end
    if nargin < 4 || isempty(vRatioVec)
        vRatioVec = logspace(-2, 0, 1001);
        vRatioVec = vRatioVec(1:end-1);   % exclude rho == 1
    end
    if nargin < 5, opts = struct(); end

    % --- Load and normalise scientist portrait images as centroids ---
    caProcessedImages = GetScientistImageData(K, imageSize);
    muGT = zeros(K, imageSize^2);
    for i = 1:K
        temp       = caProcessedImages{i}(1:imageSize^2);
        muGT(i, :) = temp(:).';
    end

    % --- Convert SNR to sigma ---
    % SNR defined as: SNR = ||muGT - mean(muGT)||_F^2 / (K * D * sigma^2)
    normMuOverK  = norm(muGT - mean(muGT), 'fro')^2 / K;
    vSnrLin      = 10.^(-vSnrDb / 10);
    vSigmaTrue   = sqrt(normMuOverK ./ (imageSize^2 .* vSnrLin));

    % --- Run sweep ---
    res = RunPopulationEmSweep(muGT, vSigmaTrue, vRatioVec, opts);

    % --- Plot MSE heat-map ---
    figure;
    imagesc(vSnrDb, vRatioVec, 10*log10(res.mMeanNorm2));
    colorbar;
    set(gca, 'YDir', 'normal');
    xlabel('SNR (dB)');
    ylabel('\tau/\sigma  (misspecification ratio)');
    title('Population EM — normalised centroid MSE [dB]');
end
