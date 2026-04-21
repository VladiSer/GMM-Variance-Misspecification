function TheoreticalMse(mu, vSigma)
% TheoreticalMse  Closed-form MSE and P_err for K=2 symmetric GMM.
%
% Computes the analytical MSE and classification error probability for a
% symmetric 2-component GMM under hard (Voronoi) assignment as sigma varies.
% The MSE formula follows from computing the conditional expectation of each
% centroid given assignment to its Voronoi region.
%
% Inputs (both optional):
%   mu     : centroid magnitude — centroids are at +mu and -mu  (default 1)
%   vSigma : vector of sigma values to sweep                    (default logspace(-1,2,30))

if nargin < 1, mu     = 1; end
if nargin < 2, vSigma = logspace(-1, 2, 30); end

muNorm        = norm(mu, 'fro');
muNormSquared = muNorm^2;
vMuOverSigma  = muNorm ./ vSigma;

vErrorProb = 0.5 * erfc(vMuOverSigma / sqrt(2));

vMse = (1/muNormSquared) * ...
    (sqrt(2/pi) .* vSigma .* exp(-vMuOverSigma.^2 / 2) ...
     - muNorm .* erfc(vMuOverSigma / sqrt(2))).^2;

% --- MSE vs sigma^2 ---
figure;
loglog(vSigma.^2, vMse, '*');
hold on;
loglog(vSigma.^2, vSigma.^2, 'o');
grid on; grid minor;
% vertical marker at sigma^2 = mu^2, i.e. SNR = 0 dB
xl = xline(mu^2, ':', '$\frac{\mu}{\sigma}=1$', 'Interpreter', 'latex');
xl.LabelVerticalAlignment   = 'middle';
xl.LabelHorizontalAlignment = 'center';
xl.FontSize         = 12;
xl.LabelOrientation = 'horizontal';
ylim([1e-15, 1e5]);
xlabel('\sigma^2');
ylabel('MSE');

% --- P_err vs sigma^2 ---
figure;
semilogx(vSigma.^2, vErrorProb, '*');
grid on; grid minor;
title('$P_{err}$ for $K=2$ Hard assignment', 'Interpreter', 'latex');
xlabel('$\sigma^2$', 'Interpreter', 'latex');
ylabel('$P_{err}$', 'Interpreter', 'latex');

end
