function GetSigmaNPlots(vRecordingNumberOrRecordings)
% GetSigmaNPlots  Plot normalised MSE and assignment accuracy vs sigma^2,
%                 across a set of varyingN recordings (one per sigma value).
%
% Each recording must be a varyingN experiment: fixed sigma, varying N.
%
% Usage:
%   GetSigmaNPlots([54 55 56 ...])   % E-numbers to load from Results/
%   GetSigmaNPlots(caRecordings)     % already-loaded cell array of structs

if isnumeric(vRecordingNumberOrRecordings)
    caRecordings = ReadRecordedData(vRecordingNumberOrRecordings);
else
    caRecordings = vRecordingNumberOrRecordings;
end
nRec  = numel(caRecordings);
nNPts = numel(caRecordings{1}.vObservationNumber);

vSigma             = zeros(nRec, 1);
mObservationNumber = zeros(nRec, nNPts);

mMeanTotalMseKmeans         = zeros(nRec, nNPts);
mMeanModel1MseKmeans        = zeros(nRec, nNPts);
mMeanModel2MseKmeans        = zeros(nRec, nNPts);
mMeanTotalAssignmentKmeans  = zeros(nRec, nNPts);
mMeanModel1AssignmentKmeans = zeros(nRec, nNPts);
mMeanModel2AssignmentKmeans = zeros(nRec, nNPts);

mMeanTotalMseEm             = zeros(nRec, nNPts);
mMeanModel1MseEm            = zeros(nRec, nNPts);
mMeanModel2MseEm            = zeros(nRec, nNPts);
mMeanTotalAssignmentEm      = zeros(nRec, nNPts);
mMeanModel1AssignmentEm     = zeros(nRec, nNPts);
mMeanModel2AssignmentEm     = zeros(nRec, nNPts);

for recIndex = 1:nRec
    vSigma(recIndex)               = caRecordings{recIndex}.vSigma(1);
    mObservationNumber(recIndex,:) = caRecordings{recIndex}.vObservationNumber;
    vsExpResults                   = caRecordings{recIndex}.vsExperimentResults;

    mMeanTotalMseKmeans(recIndex,:)         = arrayfun(@(x) x.sKmeansStatistics.sNormalizedL2Norm.mean,              vsExpResults);
    mMeanModel1MseKmeans(recIndex,:)        = arrayfun(@(x) x.sKmeansStatistics.sNormalizedL2NormPerModel.vMean(1),  vsExpResults);
    mMeanModel2MseKmeans(recIndex,:)        = arrayfun(@(x) x.sKmeansStatistics.sNormalizedL2NormPerModel.vMean(2),  vsExpResults);
    mMeanTotalAssignmentKmeans(recIndex,:)  = arrayfun(@(x) x.sKmeansStatistics.sMatchPercentage.mean,               vsExpResults);
    mMeanModel1AssignmentKmeans(recIndex,:) = arrayfun(@(x) x.sKmeansStatistics.sMatchPercentagePerModel.vMean(1),   vsExpResults);
    mMeanModel2AssignmentKmeans(recIndex,:) = arrayfun(@(x) x.sKmeansStatistics.sMatchPercentagePerModel.vMean(2),   vsExpResults);

    mMeanTotalMseEm(recIndex,:)         = arrayfun(@(x) x.sEmStatistics.sNormalizedL2Norm.mean,             vsExpResults);
    mMeanModel1MseEm(recIndex,:)        = arrayfun(@(x) x.sEmStatistics.sNormalizedL2NormPerModel.vMean(1), vsExpResults);
    mMeanModel2MseEm(recIndex,:)        = arrayfun(@(x) x.sEmStatistics.sNormalizedL2NormPerModel.vMean(2), vsExpResults);
    mMeanTotalAssignmentEm(recIndex,:)  = arrayfun(@(x) x.sEmStatistics.sMatchPercentage.mean,              vsExpResults);
    mMeanModel1AssignmentEm(recIndex,:) = arrayfun(@(x) x.sEmStatistics.sMatchPercentagePerModel.vMean(1),  vsExpResults);
    mMeanModel2AssignmentEm(recIndex,:) = arrayfun(@(x) x.sEmStatistics.sMatchPercentagePerModel.vMean(2),  vsExpResults);
end

PlotSigmaVsData(vSigma, mMeanTotalMseKmeans,        mObservationNumber, "K-Means total MSE vs $\sigma^2$",        "Normalised MSE");
PlotSigmaVsData(vSigma, mMeanTotalMseEm,            mObservationNumber, "EM total MSE vs $\sigma^2$",             "Normalised MSE");
PlotSigmaVsData(vSigma, mMeanTotalAssignmentKmeans, mObservationNumber, "K-Means total assignment vs $\sigma^2$", "Assignment [%]");
PlotSigmaVsData(vSigma, mMeanTotalAssignmentEm,     mObservationNumber, "EM total assignment vs $\sigma^2$",      "Assignment [%]");
end

% -------------------------------------------------------------------------

function PlotSigmaVsData(vSigma, mData, mObservationNumber, titleStr, yLabelStr)
    figure;
    for iObs = 1:size(mData, 2)
        semilogx(vSigma.^2, mData(:,iObs), ...
            "DisplayName", sprintf("N = %d", mObservationNumber(1, iObs)));
        hold on;
    end
    hold off;
    grid minor;
    title(titleStr, 'Interpreter', 'latex');
    xlabel("$\sigma^2$", 'Interpreter', 'latex');
    ylabel(yLabelStr);
    legend("Location", "bestoutside");
end
