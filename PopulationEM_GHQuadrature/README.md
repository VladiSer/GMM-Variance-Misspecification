# PopulationEM_GHQuadrature

Population-level analysis of EM under variance misspecification.
Computes the one-step population EM update from ground truth, integrating
over the true data distribution via Gauss-Hermite quadrature, and sweeps
over a grid of SNR × misspecification ratio τ/σ to produce the paper's
MSE heat-maps.

## Quick start

```matlab
cd PopulationEM_GHQuadrature
SetPaths
run ExampleRun    % ~5 min with useParallel=true, 31 SNR x 1000 ratio points
```

## Directory layout

```
PopulationEM_GHQuadrature/
├── ExampleRun.m                  canonical entry point
├── SetPaths.m                    addpath helper — call before anything else
├── RunMismatchedEmExperiment.m   main experiment: setup + sweep + plot
├── RunPopulationEmSweep.m        core sweep over (sigmaTrue, tau/sigma) grid
├── CentroidMatchedMse.m          permutation-invariant centroid MSE (Hungarian)
└── crameri.m                     Crameri scientific colourmap loader

GetScientistImageData is in ../Shared/ and added to the path by SetPaths.
```

## Key parameters

| Variable | Default | Meaning |
|---|---|---|
| `K` | 2 | number of mixture components |
| `imageSize` | 2 | image side length; data dimension D = `imageSize²` |
| `opts.ngh` | 20 | Gauss-Hermite nodes per dimension |
| `opts.useParallel` | false | parfor over the ratio grid |
| `vSnrDb` | `linspace(-30,30,31)` | SNR sweep in dB |
| `vRatioVec` | `logspace(-2,0,1000)` | τ/σ ratio sweep (excludes 1) |

## Output

`RunPopulationEmSweep` returns a `res` struct:

| Field | Size | Meaning |
|---|---|---|
| `res.mMeanNorm2` | nSig × nRat | normalised centroid MSE at each grid point |
| `res.mEstCenters` | K × D × nSig × nRat | one-step EM centroid estimates |
| `res.vSigmaTrue` | nSig × 1 | sigma values used |

## Method

For each `(sigmaTrue, sigmaFit)` pair, one population EM step is applied
starting from the ground-truth centroids.  The population expectation integral

> μ_new(l) = E[r_l(Y; μ) · Y] / E[r_l(Y; μ)]

is evaluated exactly using a d-dimensional Gauss-Hermite tensor grid
(ngh^d nodes), avoiding any Monte Carlo noise.  The misspecification ratio
τ/σ = `sigmaFit/sigmaTrue` controls the degree of model mismatch.

## Dependencies

- MATLAB R2021b or later (`matchpairs`)
- Parallel Computing Toolbox (optional; set `opts.useParallel = false`)
- `CrameriColourMaps7.0.mat` on the MATLAB path (for `crameri.m`)
