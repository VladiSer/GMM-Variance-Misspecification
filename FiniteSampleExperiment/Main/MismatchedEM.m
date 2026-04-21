function [vMuEst, vPiEst, vLl] = MismatchedEM(mX, K, sigmaFit, tol, maxIter, vGtMu, vGtPi)

    [N, D] = size(mX);
    s2 = sigmaFit^2;

    % init
    b_useGT = (nargin >= 6);
    if b_useGT
        vMu = vGtMu;
        vPi = vGtPi(:)'; 
        vPi = vPi/sum(vPi);
    else
        [vIdx, vMu] = kmeans(mX, K, 'Replicates', 3, 'MaxIter', 100);
        vPi = zeros(1,K);
        for k = 1:K, vPi(k) = mean(vIdx==k); end
        vPi = vPi / sum(vPi);
    end

    vLl = zeros(maxIter,1);

    for t = 1:maxIter
        % ---------- E-step ----------
        X2   = sum(mX.^2, 2);
        MU2  = sum(vMu.^2, 2)';
        XM   = mX * vMu';
        dist2 = X2 + MU2 - 2*XM;

        mLogGauss = -0.5 * ( D*log(2*pi*s2) + dist2./s2 );
        mLogR = mLogGauss + log(max(vPi, realmin));

        vMaxLogR = max(mLogR, [], 2);
        vLogSum  = vMaxLogR + log(sum(exp(mLogR - vMaxLogR), 2));
        mGamma = exp(mLogR - vLogSum);

        vLl(t) = sum(vLogSum);

        % ---------- M-step ----------
        vNk = sum(mGamma, 1);
        vPi = vNk / N;

        for k = 1:K
            vMu(k,:) = (mGamma(:,k)' * mX) / max(vNk(k), eps);
        end

        % ---------- stop ----------
        if t > 1
            rel = abs(vLl(t) - vLl(t-1)) / (abs(vLl(t-1)) + 1e-12);
            if rel < tol
                vLl = vLl(1:t);
                break;
            end
        end
    end

    vMuEst = vMu;
    vPiEst = vPi;
end