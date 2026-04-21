function sIterationOutput = CreateIterationOutput(numOfModels, nDataSize)

sIterationOutput = struct();
sIterationOutput.sKmeansEstimationOutput = CreateEstimationOutput(numOfModels, nDataSize);
sIterationOutput.sEmEstimationOutput = CreateEstimationOutput(numOfModels, nDataSize);
end

