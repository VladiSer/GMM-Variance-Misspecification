function [percentMatched, vPercentMatchedPerModel, vMatchIndices ,vMissMatchedIndices, mMatchMatrix] = MatchModelIndices(K, vObservationGtIndices, vEstimationIndices, nObservations)
mOverlapMatrix = zeros(K, K);
cmOverlapIndices = cell(K,K);
for i = 1:K
    vIndices1 = find(vObservationGtIndices == i);
    for j = 1:K
        vIndices2 = find(vEstimationIndices == j);
        vIntersectionIndices = intersect(vIndices1, vIndices2);
        mOverlapMatrix(i, j) = length(vIntersectionIndices);
        cmOverlapIndices{i,j} = vIntersectionIndices;
    end
end
mMatchMatrix = matchpairs(mOverlapMatrix,-1e9,'max');

vLinIndices = sub2ind(size(mOverlapMatrix), mMatchMatrix(:,1), mMatchMatrix(:,2));
matchesScore = sum(mOverlapMatrix(vLinIndices),'all');
percentMatched = matchesScore/nObservations*100;

vMatchIndices = zeros(matchesScore, 1);
vPercentMatchedPerModel = zeros(K, 1);
iMatches = 0;
for modelIndex = 1:K
    vCurrentModelIndices = cmOverlapIndices{mMatchMatrix(modelIndex,1), mMatchMatrix(modelIndex,2)};
    vMatchIndices(iMatches + 1:iMatches + length(vCurrentModelIndices)) = vCurrentModelIndices;
    iMatches = iMatches + length(vCurrentModelIndices);
    vPercentMatchedPerModel(modelIndex) = length(vCurrentModelIndices)/sum(mOverlapMatrix(mMatchMatrix(modelIndex,1), :))*100;
end
vMissMatchedIndices = setdiff(1:nObservations, vMatchIndices);
end