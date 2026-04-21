function mse = CentroidMatchedMse(mTrueCenters, mEstCenters)
% CentroidMatchedMse  Permutation-invariant total squared centroid error.
%
% Finds the optimal assignment between true and estimated centroids via the
% Hungarian algorithm, then returns the sum of matched squared distances.
%
% Inputs:
%   mTrueCenters : K x D ground-truth centroids
%   mEstCenters  : K x D estimated centroids
%
% Output:
%   mse : scalar — sum of ||true_k - est_sigma(k)||^2 under optimal matching

    K = size(mTrueCenters, 1);
    mCrossErr = zeros(K, K);

    for i = 1:K
        for j = 1:K
            mCrossErr(i, j) = norm(mTrueCenters(i,:) - mEstCenters(j,:), 'fro').^2;
        end
    end

    mMatchPairs = matchpairs(mCrossErr, 1e9);
    vLinIdx     = sub2ind(size(mCrossErr), mMatchPairs(:,1), mMatchPairs(:,2));
    mse         = sum(mCrossErr(vLinIdx), 'all');
end
