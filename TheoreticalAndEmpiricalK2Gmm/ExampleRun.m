% ExampleRun  -- GmmMockup module
%
% Canonical parameters used in the paper (symmetric centroids at +-1).

mu     = 1;
vSigma = logspace(-1, 2, 30);

TheoreticalMse(mu, vSigma);

CentroidTrajectory( ...
    mu, -mu,   ...   % centroids at +1 and -1
    vSigma,    ...   % sigma sweep
    1e3,       ...   % samples per averaging step
    10,       ...   % averaging steps
    false);           % use parfor
