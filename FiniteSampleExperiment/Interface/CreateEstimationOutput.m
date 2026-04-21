function sEstimationOutput = CreateEstimationOutput(numOfModels ,nDataSize)

sEstimationOutput = struct();
sEstimationOutput.mEstimatedCenters = zeros(numOfModels, nDataSize);
sEstimationOutput.mCrossModelMse = zeros(numOfModels, numOfModels);
sEstimationOutput.percentMatched = 0;
sEstimationOutput.normalized2Norm = 0;
sEstimationOutput.vMatchIndices = [];
sEstimationOutput.vMissMatchedIndices = [];
sEstimationOutput.vPercentMatchedPerModel = zeros(numOfModels, 1);
sEstimationOutput.vNormalized2NormPerModel = zeros(numOfModels, 1);

end

