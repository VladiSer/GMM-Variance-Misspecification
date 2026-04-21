function [sEstimationOutput] = RunGmmEstimation(mObservationData, algType, K, vObservationGtIndices, mInitialCenters, b_debug, b_gtInit)

nObservations = numel(vObservationGtIndices);

if b_debug
    emDisplayState = 'iter';
else
    emDisplayState = 'off';
end

switch algType
    case E_AlgType.EMpy
        pyObservationData = py.numpy.array(mObservationData);
        sklearn_mixture = py.importlib.import_module('sklearn.mixture');
        pyGmmModel = sklearn_mixture.GaussianMixture(pyargs('n_components', int32(K),'covariance_type', 'diag', 'reg_covar', 0.1, 'max_iter', int32(20), 'init_params', 'k-means++', 'tol', 1e-8));
        pyGmmModel = pyGmmModel.fit(pyObservationData);
        mEstimatedCenters = double(pyGmmModel.means_);
        vEstimationIndices = double(pyGmmModel.predict(pyObservationData));
    case E_AlgType.EM
        sOptions = statset( 'Display', emDisplayState, 'MaxIter', 300, 'UseParallel', true);
        if b_gtInit
            sGmModel = fitgmdist(mObservationData,K, 'RegularizationValue',1e-4, 'Options',sOptions, 'CovarianceType' , 'diagonal', 'SharedCovariance', true, "Start", vObservationGtIndices);
        else
            sGmModel = fitgmdist(mObservationData,K, 'RegularizationValue',1e-4, 'Options',sOptions, 'CovarianceType' , 'diagonal', 'SharedCovariance', true);
        end
        mEstimatedCenters = sGmModel.mu;
        vEstimationIndices = cluster(sGmModel, mObservationData);
    case E_AlgType.KMeans
        if b_gtInit
            [vEstimationIndices,mEstimatedCenters] = kmeans(mObservationData, K, 'Start', mInitialCenters, 'MaxIter', 300);
        else
            [vEstimationIndices,mEstimatedCenters] = kmeans(mObservationData, K, 'MaxIter', 300);
        end
    otherwise
        error("Not supported algorithm");
end

[percentMatched, vPercentMatchedPerModel, vMatchIndices ,vMissMatchedIndices, mMatchMatrix] = MatchModelIndices(K, vObservationGtIndices, vEstimationIndices, nObservations);

vNormalized2NormPerModel = zeros(K, 1);
for modelIndex = 1:K
    vNormalized2NormPerModel(modelIndex) = norm(mEstimatedCenters(mMatchMatrix(modelIndex, 2),:) - mInitialCenters(mMatchMatrix(modelIndex, 1),:), 2).^2;
end

mCrossModelMse = zeros(K,K);

for initialCenterIndex = 1:K
    for estimatedCenterIndex = 1:K
        mCrossModelMse(initialCenterIndex, estimatedCenterIndex) = (norm(mInitialCenters(initialCenterIndex,:)- mEstimatedCenters(estimatedCenterIndex,:), 'fro')).^2;
    end
end

[mMseMatchMatrix, ~] = matchpairs(mCrossModelMse, 1e9);
vLinIndices = sub2ind(size(mCrossModelMse), mMseMatchMatrix(:,1), mMseMatchMatrix(:,2));
normalized2Norm = sum(mCrossModelMse(vLinIndices),'all');

nDataSize = size(mObservationData, 2);
sEstimationOutput = CreateEstimationOutput(K ,nDataSize);
sEstimationOutput.mEstimatedCenters = mEstimatedCenters;
sEstimationOutput.mCrossModelMse = mCrossModelMse;
sEstimationOutput.percentMatched = percentMatched;
sEstimationOutput.normalized2Norm = normalized2Norm;
sEstimationOutput.vMatchIndices = vMatchIndices;
sEstimationOutput.vMissMatchedIndices = vMissMatchedIndices;
sEstimationOutput.vPercentMatchedPerModel = vPercentMatchedPerModel;
sEstimationOutput.vNormalized2NormPerModel = vNormalized2NormPerModel;
end

