function sExperimentResults = CreateExperimentResults(K)

sKmeansStatistics = struct();
sEmStatistics = struct();

sMatchPercentage = struct();
sMatchPercentage.mean = 0;
sMatchPercentage.median = 0;
sMatchPercentage.max = 0;
sMatchPercentage.min = 0;
sMatchPercentage.var = 0;
sKmeansStatistics.sMatchPercentage = sMatchPercentage;
sEmStatistics.sMatchPercentage = sMatchPercentage;

sNormalizedL2Norm = struct();
sNormalizedL2Norm.mean = 0;
sNormalizedL2Norm.median = 0;
sNormalizedL2Norm.max = 0;
sNormalizedL2Norm.min = 0;
sNormalizedL2Norm.var = 0;
sKmeansStatistics.sNormalizedL2Norm = sNormalizedL2Norm;
sEmStatistics.sNormalizedL2Norm = sNormalizedL2Norm;

sMatchPercentagePerModel = struct();
sMatchPercentagePerModel.vMean = zeros(K,1);
sMatchPercentagePerModel.vMax = zeros(K,1);
sMatchPercentagePerModel.vMin = zeros(K,1);
sMatchPercentagePerModel.vVar = zeros(K,1);
sKmeansStatistics.sMatchPercentagePerModel = sMatchPercentagePerModel;
sEmStatistics.sMatchPercentagePerModel = sMatchPercentagePerModel;

sNormalizedL2NormPerModel = struct();
sNormalizedL2NormPerModel.vMean = zeros(K,1);
sNormalizedL2NormPerModel.vMax = zeros(K,1);
sNormalizedL2NormPerModel.vMin = zeros(K,1);
sNormalizedL2NormPerModel.vVar = zeros(K,1);
sKmeansStatistics.sNormalizedL2NormPerModel = sNormalizedL2NormPerModel;
sEmStatistics.sNormalizedL2NormPerModel = sNormalizedL2NormPerModel;

sExperimentResults = struct();
sExperimentResults.sKmeansStatistics = sKmeansStatistics;
sExperimentResults.sEmStatistics = sEmStatistics;

end

