function [sIterationOutput] = RunSingleIteration(caProcessedInputImages, sigma, nObservations, runType, b_debug, b_gtInit)

if nargin < 5, b_debug  = false; end
if nargin < 6, b_gtInit = false; end

K = length(caProcessedInputImages);
imageSize = size(caProcessedInputImages{1});
sIterationOutput = CreateIterationOutput(K, imageSize(1)^2);
% Initialize guess
mInitialCenters = zeros(K, imageSize(1)^2);
for i = 1:K
    mInitialCenters(i, :) = caProcessedInputImages{i}(:)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the data according to a GMM (Gaussian Mixture model), where the
% center is one of the scientists.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mObservationData = sigma*randn(nObservations, imageSize(1)^2);
vObservationGtIndices = uint32(zeros(nObservations,1));

for i = 1:nObservations
    centerGtIndex = randi([1,K]);
    mObservationData(i,:) = mInitialCenters(centerGtIndex, :) + mObservationData(i,:);
    vObservationGtIndices(i) = centerGtIndex;
end

if any(runType == [RunType.KMeans, RunType.KMeanAndEm, RunType.KMeanAndEmPy])
    [sKmeansEstimationOutput] = RunGmmEstimation(mObservationData, E_AlgType.KMeans, K, vObservationGtIndices, mInitialCenters, b_debug, b_gtInit);
    sIterationOutput.sKmeansEstimationOutput = sKmeansEstimationOutput;
end

if any(runType == [RunType.KMeanAndEm, RunType.EM])
    [sEmEstimationOutput] = RunGmmEstimation(mObservationData, E_AlgType.EM, K, vObservationGtIndices, mInitialCenters, b_debug, b_gtInit);
    sIterationOutput.sEmEstimationOutput = sEmEstimationOutput;
end

if any(runType == [RunType.KMeanAndEmPy, RunType.EMpy])
    [sEmEstimationOutput] = RunGmmEstimation(mObservationData, E_AlgType.EMpy, K, vObservationGtIndices, mInitialCenters, b_debug, b_gtInit);
    sIterationOutput.sEmEstimationOutput = sEmEstimationOutput;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: Add logic to observe the matched and miss-matched centroids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if b_debug
    secondSubPlotDim = ceil(sqrt(K));
    firstSubPlotDim = K/secondSubPlotDim;

    vScreenSize = get(0, "Screensize");
    vScreenSize(1:2) = vScreenSize(3:4).*0.1;
    vScreenSize(3:4) = vScreenSize(3:4).*0.8;

    f = figure("Name","Debug graphs","Position", vScreenSize);
    uiTabGroup = uitabgroup(f);
    tabIndex = 1;
    tab(tabIndex) = uitab(uiTabGroup, "Title", 'Original Images');
    for i = 1:K
        tempAxes = axes('Parent', tab(tabIndex));
        subplot(firstSubPlotDim, secondSubPlotDim, i, tempAxes);
        imshow(reshape(mInitialCenters(i,:), imageSize), []);
    end

    if any(runType==[RunType.KMeans, RunType.KMeanAndEm, RunType.KMeanAndEmPy])
        tabIndex = tabIndex + 1;
        tab(tabIndex) = uitab(uiTabGroup, "Title", 'K-Means estimated Images');
        for i = 1:K
            tempAxes = axes('Parent', tab(tabIndex));
            subplot(firstSubPlotDim, secondSubPlotDim, i, tempAxes);
            imshow(reshape(sIterationOutput.sKmeansEstimationOutput.mEstimatedCenters(i,:), imageSize), []);
        end
    end

    if any(runType==[RunType.EM, RunType.EMpy, RunType.KMeanAndEm, RunType.KMeanAndEmPy])
        tabIndex = tabIndex + 1;
        tab(tabIndex) = uitab(uiTabGroup, "Title", 'Expectation maximization estimated Images');
        for i = 1:K
            tempAxes = axes('Parent', tab(tabIndex));
            subplot(firstSubPlotDim, secondSubPlotDim, i, tempAxes);
            x = reshape(sIterationOutput.sEmEstimationOutput.mEstimatedCenters(i,:), imageSize);
            imshow(x(1:imageSize(1), 1:imageSize(1)), []);
        end
    end
    fprintf("GMM with %d calsses and %d observations, Sigma squared: %.2f\n", K, nObservations, sigma^2);
    if any(runType==[RunType.KMeans, RunType.KMeanAndEm, RunType.KMeanAndEmPy])
        fprintf("Classification percentage for the best match, K-Means classified %.2f%% of the observations right\n", sIterationOutput.sKmeansEstimationOutput.percentMatched);
        fprintf("Normalized L2 center error for K-Means error: %.5f\n", sIterationOutput.sKmeansEstimationOutput.normalized2Norm);
    end
    if any(runType==[RunType.EM, RunType.EMpy, RunType.KMeanAndEm, RunType.KMeanAndEmPy])
        fprintf("Classification percentage for the best match, EM classified %.2f%% of the observations right\n", sIterationOutput.sEmEstimationOutput.percentMatched);
        fprintf("Normalized L2 center error for EM error: %.5f\n", sIterationOutput.sEmEstimationOutput.normalized2Norm);
    end
end

end