function CentroidTrajectory(vWantedMean1, vWantedMean2, vWantedSigma, n, nAveraging, b_runParallel)
% CentroidTrajectory  Monte Carlo centroid trajectory for a symmetric K=2 GMM.
%
% Simulates the hard-assignment centroid estimator as sigma varies.
% Samples are assigned by Voronoi partition (projection onto the separation
% axis) and the conditional mean of each partition is taken as the estimate.
%
% Inputs (all optional):
%   vWantedMean1  : first centroid  (default  1)
%   vWantedMean2  : second centroid (default -1)
%   vWantedSigma  : sigma sweep vector (default logspace(-1,2,30))
%   n             : Monte Carlo samples per averaging step (default 1e6)
%   nAveraging    : independent runs averaged per sigma point (default 100)
%   b_runParallel : use parfor over averaging steps (default true)
%
% Produces:
%   Figure 1 — MSE vs sigma^2 with sigma^2 and 4*sigma^2*d/N reference lines
%   Figure 2 — P_err vs sigma^2
%   Figure 3 — Projected centroid scatter (sigma colour-coded)
%   Figure 4 — Projected centroid value vs sigma (line plot)

if nargin < 1, vWantedMean1  = 1;  end
if nargin < 2, vWantedMean2  = -1; end
if nargin < 3, vWantedSigma  = logspace(-1, 2, 30); end
if nargin < 4, n             = 1e6; end
if nargin < 5, nAveraging    = 100; end
if nargin < 6, b_runParallel = true; end

vWantedSigma = vWantedSigma(:)';   % ensure row vector
numSigmas    = numel(vWantedSigma);
vectorLength = numel(vWantedMean1);

vNormalVec      = vWantedMean1 - vWantedMean2;
vNormalVec      = vNormalVec / norm(vNormalVec, 2);
meanNormSquared = norm([vWantedMean1, vWantedMean2], 'fro').^2;
vMid            = 0.5 * (vWantedMean1 + vWantedMean2);

vProbCross = zeros(1, numSigmas);
vMseTot    = zeros(1, numSigmas);
vMu1Est    = zeros(vectorLength, numSigmas);
vMu2Est    = zeros(vectorLength, numSigmas);

if b_runParallel && isempty(gcp('nocreate'))
    parpool;
end

for iSigma = 1:numSigmas
    wantedSigma = vWantedSigma(iSigma);
    vProbCross(iSigma) = CalcProbCross(vWantedMean1, vWantedMean2, wantedSigma, n);

    vMseTotAvg = zeros(1, nAveraging);
    vMu1EstAvg = zeros(vectorLength, nAveraging);
    vMu2EstAvg = zeros(vectorLength, nAveraging);

    if b_runParallel
        parfor iAvg = 1:nAveraging
            [vMu1EstAvg(:,iAvg), vMu2EstAvg(:,iAvg), vMseTotAvg(iAvg)] = ...
                RunOneAverage(vWantedMean1, vWantedMean2, vNormalVec, vMid, meanNormSquared, vectorLength, n, wantedSigma);
        end
    else
        for iAvg = 1:nAveraging
            [vMu1EstAvg(:,iAvg), vMu2EstAvg(:,iAvg), vMseTotAvg(iAvg)] = ...
                RunOneAverage(vWantedMean1, vWantedMean2, vNormalVec, vMid, meanNormSquared, vectorLength, n, wantedSigma);
        end
    end

    vMseTot(iSigma)    = mean(vMseTotAvg);
    vMu1Est(:, iSigma) = mean(vMu1EstAvg, 2);
    vMu2Est(:, iSigma) = mean(vMu2EstAvg, 2);
end

dim = vectorLength;

% --- Figure 1: MSE vs sigma^2 ---
figure;
loglog(vWantedSigma.^2, vMseTot, '*');
hold on;
loglog(vWantedSigma.^2, vWantedSigma.^2);
loglog(vWantedSigma.^2, vWantedSigma.^2 .* 4 * dim / (n * meanNormSquared));
grid on; grid minor;
title('$\mathrm{MSE}(\widehat{\mathbf{\mu}},\mathbf{\mu}^\star)$ for $K=2$ Hard assignment', 'Interpreter', 'latex');
xlabel('$\sigma^2$', 'Interpreter', 'latex');
ylabel('$\mathrm{MSE}(\widehat{\mathbf{\mu}},\mathbf{\mu}^\star)$', 'Interpreter', 'latex');
legend('$\mathrm{MSE}(\widehat{\mathbf{\mu}},\mathbf{\mu}^\star)$', '$\sigma^2$', '$\frac{4\sigma^2 d}{N}$', 'Interpreter', 'latex');

% --- Figure 2: P_err vs sigma^2 ---
figure;
semilogx(vWantedSigma.^2, vProbCross, '*');
grid on; grid minor;
title('$P_{err}$ for $K=2$ Hard assignment', 'Interpreter', 'latex');
xlabel('$\sigma^2$', 'Interpreter', 'latex');
ylabel('$P_{err}$', 'Interpreter', 'latex');

Plot1DSharedAxisSigmaColor(vMu1Est, vMu2Est, vNormalVec, vWantedMean1, vWantedMean2, vWantedSigma);

end

% -------------------------------------------------------------------------

function [vEstMean1, vEstMean2, mse] = RunOneAverage(vMean1, vMean2, vNormalVec, vMid, meanNormSquared, vectorLength, n, sigma)
    mSamples1   = randn(vectorLength, n) .* sigma + vMean1;
    mSamples2   = randn(vectorLength, n) .* sigma + vMean2;
    vSampleMask = randi([0, 1], 1, n);
    mAllSamples = vSampleMask .* mSamples1 + (1 - vSampleMask) .* mSamples2;

    % Voronoi hard assignment via projection onto the separation axis
    vIndicator = (vNormalVec.' * (mAllSamples - vMid)) > 0;

    vEstMean1 = mean(mAllSamples(:,  vIndicator), 2);
    vEstMean2 = mean(mAllSamples(:, ~vIndicator), 2);
    mse       = norm([vEstMean1 - vMean1, vEstMean2 - vMean2], 'fro').^2 / meanNormSquared;
end

% -------------------------------------------------------------------------

function probCross = CalcProbCross(mu1, mu2, sigma, n)
% Probability that a draw from the 2nd Gaussian crosses the Voronoi boundary.
% Assumes spherical covariance: Sigma = sigma^2 * I.
    muProj    = -norm(mu2 - mu1) / 2;
    sig2      = sigma^2;
    vY        = muProj + linspace(-5*sigma, +5*sigma, n);
    dy        = abs(vY(2) - vY(1));
    vFx       = 1/sqrt(2*pi*sig2) * exp(-(vY - muProj).^2 / (2*sig2));
    probCross = sum(vFx(vY > 0)) * dy;
end

% -------------------------------------------------------------------------

function Plot1DSharedAxisSigmaColor(mMu1Est, mMu2Est, vNormal, vMu1Ref, vMu2Ref, vSigmas)
% Plots the estimated centroids projected onto the separation axis with
% sigma encoded as colour, and ground-truth centroids marked.
%
% Inputs:
%   mMu1Est, mMu2Est : d×M estimated centroids (one column per sigma value)
%   vNormal          : d×1 unit normal to the separation plane
%   vMu1Ref, vMu2Ref : d×1 ground-truth centroids
%   vSigmas          : 1×M sigma values

    [d, M] = size(mMu1Est);
    assert(all(size(mMu2Est) == [d M]), 'mMu2Est must be d×M');
    assert(numel(vSigmas) == M,         'vSigmas must have length M');

    vNormal  = vNormal(:) / norm(vNormal);
    vMu1Ref  = vMu1Ref(:);
    vMu2Ref  = vMu2Ref(:);
    vMid     = 0.5 * (vMu1Ref + vMu2Ref);
    dB       = vNormal' * vMid;

    % Project onto separation axis, subtract midpoint offset
    s1          = (vNormal' * mMu1Est) - dB;   % 1×M
    s2          = (vNormal' * mMu2Est) - dB;   % 1×M
    vS          = [s1, s2];
    vY          = zeros(1, 2*M);
    vSigmasScat = [vSigmas, vSigmas];

    % --- Figure 3: scatter of projected centroids ---
    f = figure; hold on; grid on;
    scatter(vS, vY, 240, vSigmasScat, 'filled');
    xline(0, ':k', 'LineWidth', 1.5);

    s1Gt = vNormal' * vMu1Ref - dB;
    s2Gt = vNormal' * vMu2Ref - dB;
    plot([s1Gt, s2Gt], [0, 0], 'kp', 'MarkerSize', 40, 'MarkerFaceColor', 'none');

    colormap(parula);
    cb = colorbar;
    cb.Label.String = '\sigma';
    if vSigmas(1) > vSigmas(end), cb.Ticks = fliplr(vSigmas);
    else,                          cb.Ticks = vSigmas;
    end

    ylim([-0.04 0.04]);
    yticks([]);
    ylabel('');
    xlabel('Projection onto separation axis $u$: $\langle u,\, \mu^{\star} - m \rangle$', 'Interpreter', 'LaTeX');
    title('1D projected centroid estimates along separation normal');

    xl = xlim;
    text(xl(1) + range(xl)/4, 0.02, 'Centroid 2 region', ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 25);
    text(xl(2) - range(xl)/4, 0.02, 'Centroid 1 region', ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 25);
    legend('$u^{T}(\hat{\mu_{\ell}}-m)$', 'Partition plane', '$u^{T}(\mu_{\ell}^{\star}-m)$', 'Interpreter', 'LaTeX');
    f.Children(1).set('FontSize', 25);
    f.Children(2).set('FontSize', 25);
    f.Children(3).set('FontSize', 25);

    % --- Figure 4: projected value vs sigma ---
    f2 = figure; grid on; grid minor;
    plot(vS(1:M),     vSigmasScat(1:M),     '-*');
    hold on;
    plot(vS(M+1:end), vSigmasScat(M+1:end), '-*');
    xlabel('Projection onto separation axis $u$: $\langle u,\, \mu^{\star} - m \rangle$', 'Interpreter', 'LaTeX');
    title('1D projected centroid estimates along separation normal');
    ylabel('$\sigma$', 'Interpreter', 'LaTeX');
    legend('$u^{T}(\hat{\mu_{1}}-m)$', '$u^{T}(\hat{\mu_{2}}-m)$', 'Interpreter', 'LaTeX');
    f2.Children(1).set('FontSize', 20);
    f2.Children(2).set('FontSize', 20);
end
