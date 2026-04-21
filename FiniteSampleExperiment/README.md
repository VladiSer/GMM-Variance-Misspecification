# FiniteSampleExperiment

Empirical finite-sample simulation of K-means and EM on a Gaussian Mixture
Model whose centroids are real images (scientist portraits), sweeping SNR and
recording classification accuracy and normalised MSE.

Contrasts with `PopulationEM_GHQuadrature`, which computes the exact
population-level fixed point.

## Quick start

```matlab
cd FiniteSampleExperiment
SetPaths          % adds Main/, Interface/, Results/ to path; Shared/ for images
run ExampleRun    % ~40 min with parallel pool: sigma sweep + N sweep + plots
```

To visualise saved results:

```matlab
ShowStatsFromMultipleRecordings(vRecordingNumber)
GetSigmaNPlots(vRecordingNumber)        % load from disk by E-number
GetSigmaNPlots(caRecordings)           % or pass an in-memory cell array
```

## Directory layout

```
FiniteSampleExperiment/
├── ExampleRun.m               canonical entry point
├── SetPaths.m                 addpath helper — call before anything else
├── GetSigmaNPlots.m           sigma-vs-N sweep plots
├── Interface/
│   ├── RunType.m              enum: KMeans | EM | KMeanAndEm | …
│   ├── E_AlgType.m            enum passed to RunGmmEstimation
│   ├── E_Parameter.m          enum for the swept parameter
│   ├── CreateExperimentResults.m
│   ├── CreateIterationOutput.m
│   └── CreateEstimationOutput.m
└── Main/
    ├── RunSingleExperiment.m  outer loop: sweeps one parameter, saves to disk
    ├── RunSingleIteration.m   draws N samples, calls RunGmmEstimation
    ├── RunGmmEstimation.m     dispatches to MismatchedEM / fitgmdist / kmeans
    ├── MismatchedEM.m         EM with misspecified sigma (log-sum-exp stable)
    ├── MatchModelIndices.m    Hungarian matching of estimated vs GT centroids
    ├── CalcStatisticsAndPopulateExpOutput.m
    ├── ArrayOfStructsToStructOfArrays.m
    ├── ReadRecordedData.m     loads saved .mat experiment files
    ├── ShowStatsFromMultipleRecordings.m   loads + plots a set of recordings
    ├── PlotKMeansResults.m
    ├── PlotStatisticsFigure.m
    ├── PlotStatisticsFigureForModelIndex.m
    └── PlotMultipleVaryingStatsGraphs.m

GetScientistImageData is in ../Shared/ and added to the path by SetPaths.
```

## Key parameters

| Variable | Default | Meaning |
|---|---|---|
| `K` | 2 | number of mixture components |
| `imageSize` | 50 | image side length (pixels); data dimension = `imageSize²` |
| `nObservations` | 1e6 | samples drawn per SNR point |
| `vSnrDb` | -25:2.5:25 | SNR sweep in dB |
| `nAveragingSteps` | 100 | Monte Carlo repeats per SNR point |
| `runType` | `KMeanAndEm` | which algorithms to run |

## Output structure

`RunSingleExperiment` returns a vector of `vsExperimentResults` structs and,
when `b_saveResults = true`, writes incremental `.mat` files to `Results/`
(the folder is created automatically if it does not exist).
Each entry contains `sKmeansStatistics` and (optionally) `sEmStatistics`
with fields `meanNormalized2Norm`, `meanPercentMatched`, and per-model
breakdowns.

## Dependencies

- MATLAB R2021b or later (uses `matchpairs`, `fitgmdist`)
- Statistics and Machine Learning Toolbox (for `fitgmdist`)
- Image Processing Toolbox (for `rgb2lightness` in `GetScientistImageData`)
- Parallel Computing Toolbox (optional; set `b_parallel = false` to disable)
