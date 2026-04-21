function sExperimentResults = CalcStatisticsAndPopulateExpOutput(vsIterationOutput, numOfModels)

nSubSteps = length(vsIterationOutput);

vMatchPercentagesKMeans = arrayfun(@(x) x.sKmeansEstimationOutput.percentMatched, vsIterationOutput);
vNormalized2NormKMeans = arrayfun(@(x) x.sKmeansEstimationOutput.normalized2Norm, vsIterationOutput);
caMatchPercentagesPerModelKMeans = arrayfun(@(x) x.sKmeansEstimationOutput.vPercentMatchedPerModel, vsIterationOutput, 'UniformOutput', false);
caNormalized2NormKPerModelMeans = arrayfun(@(x) x.sKmeansEstimationOutput.vNormalized2NormPerModel, vsIterationOutput, 'UniformOutput', false);

mMatchPercentagesPerModelKMeans = zeros(numOfModels, nSubSteps);
mNormalized2NormKPerModelMeans = zeros(numOfModels, nSubSteps);

vMatchPercentagesEm = arrayfun(@(x) x.sEmEstimationOutput.percentMatched, vsIterationOutput);
vNormalized2NormEm = arrayfun(@(x) x.sEmEstimationOutput.normalized2Norm, vsIterationOutput);
caMatchPercentagesPerModelEm = arrayfun(@(x) x.sEmEstimationOutput.vPercentMatchedPerModel, vsIterationOutput, 'UniformOutput', false);
caNormalized2NormKPerModelEm = arrayfun(@(x) x.sEmEstimationOutput.vNormalized2NormPerModel, vsIterationOutput, 'UniformOutput', false);

mMatchPercentagesPerModelEm = zeros(numOfModels, nSubSteps);
mNormalized2NormKPerModelEm = zeros(numOfModels, nSubSteps);

for iStep = 1:nSubSteps
    mMatchPercentagesPerModelKMeans(:, iStep) = caMatchPercentagesPerModelKMeans{iStep};
    mNormalized2NormKPerModelMeans(:, iStep) = caNormalized2NormKPerModelMeans{iStep};

    mMatchPercentagesPerModelEm(:, iStep) = caMatchPercentagesPerModelEm{iStep};
    mNormalized2NormKPerModelEm(:, iStep) = caNormalized2NormKPerModelEm{iStep};
end

sExperimentResults.sKmeansStatistics.sMatchPercentage.max = max(vMatchPercentagesKMeans);
sExperimentResults.sKmeansStatistics.sMatchPercentage.min = min(vMatchPercentagesKMeans);
sExperimentResults.sKmeansStatistics.sMatchPercentage.mean = mean(vMatchPercentagesKMeans);
sExperimentResults.sKmeansStatistics.sMatchPercentage.median = median(vMatchPercentagesKMeans);
sExperimentResults.sKmeansStatistics.sMatchPercentage.var = var(vMatchPercentagesKMeans);

sExperimentResults.sKmeansStatistics.sMatchPercentagePerModel.vMax = max(mMatchPercentagesPerModelKMeans,[],2);
sExperimentResults.sKmeansStatistics.sMatchPercentagePerModel.vMin = min(mMatchPercentagesPerModelKMeans,[],2);
sExperimentResults.sKmeansStatistics.sMatchPercentagePerModel.vMean = mean(mMatchPercentagesPerModelKMeans, 2);
sExperimentResults.sKmeansStatistics.sMatchPercentagePerModel.vVar = var(mMatchPercentagesPerModelKMeans, 0, 2);

sExperimentResults.sKmeansStatistics.sNormalizedL2Norm.max = max(vNormalized2NormKMeans);
sExperimentResults.sKmeansStatistics.sNormalizedL2Norm.min = min(vNormalized2NormKMeans);
sExperimentResults.sKmeansStatistics.sNormalizedL2Norm.mean = mean(vNormalized2NormKMeans);
sExperimentResults.sKmeansStatistics.sNormalizedL2Norm.median = median(vNormalized2NormKMeans);
sExperimentResults.sKmeansStatistics.sNormalizedL2Norm.var = var(vNormalized2NormKMeans);

sExperimentResults.sKmeansStatistics.sNormalizedL2NormPerModel.vMax = max(mNormalized2NormKPerModelMeans,[],2);
sExperimentResults.sKmeansStatistics.sNormalizedL2NormPerModel.vMin = min(mNormalized2NormKPerModelMeans,[],2);
sExperimentResults.sKmeansStatistics.sNormalizedL2NormPerModel.vMean = mean(mNormalized2NormKPerModelMeans, 2);
sExperimentResults.sKmeansStatistics.sNormalizedL2NormPerModel.vVar = var(mNormalized2NormKPerModelMeans, 0, 2);

sExperimentResults.sEmStatistics.sMatchPercentage.max = max(vMatchPercentagesEm);
sExperimentResults.sEmStatistics.sMatchPercentage.min = min(vMatchPercentagesEm);
sExperimentResults.sEmStatistics.sMatchPercentage.mean = mean(vMatchPercentagesEm);
sExperimentResults.sEmStatistics.sMatchPercentage.median = median(vMatchPercentagesEm);
sExperimentResults.sEmStatistics.sMatchPercentage.var = var(vMatchPercentagesEm);

sExperimentResults.sEmStatistics.sMatchPercentagePerModel.vMax = max(mMatchPercentagesPerModelEm,[],2);
sExperimentResults.sEmStatistics.sMatchPercentagePerModel.vMin = min(mMatchPercentagesPerModelEm,[],2);
sExperimentResults.sEmStatistics.sMatchPercentagePerModel.vMean = mean(mMatchPercentagesPerModelEm, 2);
sExperimentResults.sEmStatistics.sMatchPercentagePerModel.vVar = var(mMatchPercentagesPerModelEm, 0, 2);

sExperimentResults.sEmStatistics.sNormalizedL2Norm.max = max(vNormalized2NormEm);
sExperimentResults.sEmStatistics.sNormalizedL2Norm.min = min(vNormalized2NormEm);
sExperimentResults.sEmStatistics.sNormalizedL2Norm.mean = mean(vNormalized2NormEm);
sExperimentResults.sEmStatistics.sNormalizedL2Norm.median = median(vNormalized2NormEm);
sExperimentResults.sEmStatistics.sNormalizedL2Norm.var = var(vNormalized2NormEm);

sExperimentResults.sEmStatistics.sNormalizedL2NormPerModel.vMax = max(mNormalized2NormKPerModelEm,[],2);
sExperimentResults.sEmStatistics.sNormalizedL2NormPerModel.vMin = min(mNormalized2NormKPerModelEm,[],2);
sExperimentResults.sEmStatistics.sNormalizedL2NormPerModel.vMean = mean(mNormalized2NormKPerModelEm, 2);
sExperimentResults.sEmStatistics.sNormalizedL2NormPerModel.vVar = var(mNormalized2NormKPerModelEm, 0, 2);
end

