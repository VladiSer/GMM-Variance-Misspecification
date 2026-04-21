% ExampleRun  -- FiniteSampleExperiment module
%
% Runs K-means and EM estimation on a synthetic GMM whose centers are taken
% from scientist portrait images, sweeping SNR from -25 dB to +25 dB.
% Results are written to disk by RunSingleExperiment and can be visualised
% afterwards with ShowStatsFromMultipleRecordings or GetSigmaNPlots.
%
% Typical wall-clock time: ~10 min with b_parallel = true (100 averages,
% 21 SNR points, K=2, 50x50 images, 1e6 observations per point).

%% --- Parameters ---
K               = 2;
imageSize       = 50;
nObservations   = 1e6;
vSnrDb          = -25:2.5:25;       % 21 SNR points
vSigma          = 10.^(-vSnrDb/20);
nAveragingSteps = 100;
runType         = RunType.KMeanAndEm;
b_saveResults   = true;
b_parallel      = true;
b_debug         = false;
b_gtInit        = false;

%% --- Run experiment ---
vsExperimentResults = RunSingleExperiment( ...
    runType, K, imageSize, nObservations, vSigma, nAveragingSteps, ...
    b_saveResults, b_parallel, b_debug, b_gtInit);

%% --- Plot sigma sweep results ---
% Build the caRecordings struct directly from in-memory results so the
% plot test works regardless of whether b_saveResults is true.
sRecording.vsExperimentResults = vsExperimentResults;
sRecording.vSigma              = vSigma(:);
sRecording.vObservationNumber  = repmat(nObservations, numel(vsExperimentResults), 1);
sRecording.vModelDim           = repmat(K,             numel(vsExperimentResults), 1);
sRecording.vImageDim           = repmat(imageSize,     numel(vsExperimentResults), 1);

PlotMultipleVaryingStatsGraphs( ...
    {sRecording}, E_Parameter.Sigma, E_Parameter.ObservationNumber);

%% --- N sweep experiment (feeds GetSigmaNPlots) ---
% Three recordings at low / mid / high noise, each sweeping N.
% Runs after the sigma sweep above; adds roughly 25-30 min with b_parallel=true.
vSigmaForNSweep       = 10.^(-[-10, 0, 10]/20);  % SNR = +10, 0, -10 dB
vNSweep               = round(logspace(4, 6, 6)); % 6 N values: 1e4 … 1e6
nAveragingStepsNSweep = 20;

caRecordingsNSweep = cell(1, numel(vSigmaForNSweep));
for iSig = 1:numel(vSigmaForNSweep)
    vsResultsNSweep = RunSingleExperiment( ...
        runType, K, imageSize, vNSweep, vSigmaForNSweep(iSig), ...
        nAveragingStepsNSweep, b_saveResults, b_parallel, b_debug, b_gtInit);
    sRec.vsExperimentResults = vsResultsNSweep;
    sRec.vSigma              = vSigmaForNSweep(iSig);
    sRec.vObservationNumber  = vNSweep(:);
    sRec.vModelDim           = repmat(K,         numel(vsResultsNSweep), 1);
    sRec.vImageDim           = repmat(imageSize, numel(vsResultsNSweep), 1);
    caRecordingsNSweep{iSig} = sRec;
end

%% --- Plot N sweep results ---
GetSigmaNPlots(caRecordingsNSweep);
