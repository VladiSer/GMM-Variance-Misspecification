% ExampleRun  -- PopulationEM_GHQuadrature module
%
% Canonical parameters for the paper figures.
% Requires CrameriColourMaps7.0.mat on the path for the crameri() colourmap.

opts.ngh         = 20;
opts.useParallel = true;
opts.verbose     = true;

RunMismatchedEmExperiment( ...
    2,                   ...  % K  — number of components
    2,                   ...  % imageSize
    linspace(-30,30,31), ...  % SNR sweep (dB)
    [],                  ...  % ratio sweep (uses default logspace(-2,0,1000))
    opts);
