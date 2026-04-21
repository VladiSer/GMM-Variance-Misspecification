function res = RunPopulationEmSweep(muGT, vSigmaTrue, vRatioVec, opts)
% RunPopulationEmSweep  Population-level mismatched EM sweep via GH quadrature.
%
% Sweeps an (nSig x nRat) grid of (sigmaTrue, sigmaFit/sigmaTrue) values.
% For each grid point, applies one population EM step starting from the
% ground-truth centroids and evaluates the resulting centroid error.
% The population integral is computed exactly using Gauss-Hermite quadrature.
%
% Inputs:
%   muGT       : K x D ground-truth centroids
%   vSigmaTrue : nSig x 1 vector of true sigma values
%   vRatioVec  : nRat x 1 vector of sigmaFit/sigmaTrue ratios (exclude rho=1)
%   opts (optional struct):
%       .ngh         (default 20)     GH nodes per dimension
%       .useParallel (default false)  parfor over the ratio grid
%       .verbose     (default true)   print sigma progress
%
% Output:
%   res.mMeanNorm2   : nSig x nRat  normalised centroid MSE
%   res.mEstCenters  : K x D x nSig x nRat  one-step EM estimates
%   res.vSigmaTrue   : nSig x 1
%   res.opts         : opts struct used

    if nargin < 4, opts = struct(); end
    opts = SetDefaultOpts(opts);

    [K, D]  = size(muGT);
    muGT_DK = muGT.';   % internal column format: D x K

    vSigmaTrue = vSigmaTrue(:);
    vRatioVec  = vRatioVec(:);
    nSig = numel(vSigmaTrue);
    nRat = numel(vRatioVec);

    mAllNorm2      = zeros(nSig, nRat);
    mAllEstCenters = zeros(K, D, nSig, nRat);

    if opts.useParallel && isempty(gcp('nocreate'))
        try
            parpool;
        catch
            warning('Parallel pool not available; running serial.');
            opts.useParallel = false;
        end
    end

    for iS = 1:nSig
        sigmaTrue = vSigmaTrue(iS);
        if opts.verbose
            fprintf('sigmaTrue = %.6g  (%d / %d)\n', sigmaTrue, iS, nSig);
        end

        vNorm2Tmp   = zeros(1, nRat);
        mCentersTmp = zeros(D, K, nRat);

        if opts.useParallel
            parfor jF = 1:nRat
                sigmaFit    = sigmaTrue * vRatioVec(jF);
                mEstCenters = GhEmStep(muGT_DK, muGT_DK, sigmaTrue, sigmaFit, opts.ngh);
                vNorm2Tmp(jF)       = CentroidMatchedMse(muGT_DK.', mEstCenters.');
                mCentersTmp(:,:,jF) = mEstCenters;
            end
        else
            for jF = 1:nRat
                sigmaFit    = sigmaTrue * vRatioVec(jF);
                mEstCenters = GhEmStep(muGT_DK, muGT_DK, sigmaTrue, sigmaFit, opts.ngh);
                vNorm2Tmp(jF)       = CentroidMatchedMse(muGT_DK.', mEstCenters.');
                mCentersTmp(:,:,jF) = mEstCenters;
            end
        end

        mAllNorm2(iS, :)           = vNorm2Tmp;
        mAllEstCenters(:, :, iS, :) = permute(mCentersTmp, [2, 1, 3]);  % K x D x nRat
    end

    res.mMeanNorm2  = mAllNorm2;
    res.mEstCenters = mAllEstCenters;
    res.vSigmaTrue  = vSigmaTrue;
    res.opts        = opts;
end

% -------------------------------------------------------------------------

function opts = SetDefaultOpts(opts)
    if ~isfield(opts, 'ngh'),         opts.ngh         = 20;    end
    if ~isfield(opts, 'useParallel'), opts.useParallel = false;  end
    if ~isfield(opts, 'verbose'),     opts.verbose     = true;   end
end

% -------------------------------------------------------------------------

function mMuNew = GhEmStep(mMu, mMuTrue, sigmaTrue, sigmaFit, ngh)
% GhEmStep  One population EM mean update via Gauss-Hermite quadrature.
%
% Evaluates the population M-step update for all K centroids simultaneously:
%   mu_new(:,l) = E[r_l(Y; mu) * Y] / E[r_l(Y; mu)]
% where Y is drawn from the true mixture and r_l is the soft responsibility
% under the fitted (possibly misspecified) sigma.
%
% The expectation is computed by a d-dimensional GH tensor grid:
%   E[f(Z)] ≈ (1/pi^(d/2)) * sum_i (prod w) * f(sqrt(2) * x_i)   for Z~N(0,I)
%
% Inputs (all D x K column format):
%   mMu, mMuTrue : D x K current and true centroids
%   sigmaTrue    : true noise std (used for the data distribution)
%   sigmaFit     : fitted noise std (used for the responsibility computation)
%   ngh          : number of GH nodes per dimension

    [d, K] = size(mMu);

    [x1, w1] = GhNodes1d(ngh);
    [X, W]   = GhTensorGrid(x1, w1, d);   % X: d x M,  W: 1 x M
    M        = size(X, 2);

    quadW    = W / (pi^(d/2));             % quadrature weights for Z ~ N(0,I)
    Z        = sqrt(2) * X;               % GH nodes mapped to N(0,I) scale

    mNumer   = zeros(d, K);
    vDenom   = zeros(1, K);
    inv2sig2 = 1 / (2 * sigmaFit^2);
    wComp    = 1 / K;                     % equal component weights

    for m = 1:K
        Y = mMuTrue(:, m) + sigmaTrue * Z;   % d x M  — samples from component m

        % Log-responsibilities under sigmaFit (equal priors cancel in softmax)
        mLogP = zeros(K, M);
        for l = 1:K
            vDiff      = Y - mMu(:, l);
            mLogP(l,:) = -inv2sig2 * sum(vDiff.^2, 1);
        end

        % Numerically stable softmax
        vLogMax     = max(mLogP, [], 1);
        mExpShifted = exp(mLogP - vLogMax);
        mResp       = mExpShifted ./ sum(mExpShifted, 1);   % K x M

        vWm = wComp * quadW;   % combined component weight and quadrature weight

        for l = 1:K
            vWResp      = vWm .* mResp(l, :);
            vDenom(l)   = vDenom(l)   + sum(vWResp);
            mNumer(:,l) = mNumer(:,l) + Y * vWResp';
        end
    end

    mMuNew = zeros(d, K);
    for l = 1:K
        mMuNew(:, l) = mNumer(:, l) / max(vDenom(l), realmin);
    end
end

% -------------------------------------------------------------------------

function [x, w] = GhNodes1d(n)
% GhNodes1d  1-D Gauss-Hermite nodes and weights via Golub-Welsch.
% Computes nodes x and weights w for: integral exp(-x^2) f(x) dx ≈ sum w_i f(x_i)
    i = (1:n-1)';
    a = sqrt(i / 2);
    J = diag(a, 1) + diag(a, -1);

    [V, D]  = eig(J);
    x       = diag(D);
    [x, vIdx] = sort(x);
    V       = V(:, vIdx);

    w = sqrt(pi) * (V(1,:).^2);
end

% -------------------------------------------------------------------------

function [X, W] = GhTensorGrid(x1, w1, d)
% GhTensorGrid  d-dimensional tensor product of 1-D GH nodes and weights.
% Returns X (d x M) node matrix and W (1 x M) weight vector.
    grids  = repmat({x1(:)}, 1, d);
    wgrids = repmat({w1(:)}, 1, d);

    [G{1:d}]  = ndgrid(grids{:});
    [WG{1:d}] = ndgrid(wgrids{:});

    M = numel(G{1});
    X = zeros(d, M);
    W = ones(1, M);

    for j = 1:d
        X(j,:) = reshape(G{j}, 1, M);
        W      = W .* reshape(WG{j}, 1, M);
    end
end
