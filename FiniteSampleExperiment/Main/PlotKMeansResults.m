function PlotKMeansResults(vRecordingNumber)

[caRecordings] = ReadRecordedData(vRecordingNumber, "KMeansResults");

% For now looking at only changing sigma cases
for recordingNumber = 1:length(caRecordings)
    observations = caRecordings{recordingNumber}.vObservationNumber(1);
    vSigma = caRecordings{recordingNumber}.vSigma;
    vsExpResults = caRecordings{recordingNumber}.vsExperimentResults;
    vMse = arrayfun(@(x)x.sKmeansStatistics.sNormalizedL2Norm.mean, vsExpResults);
    vPAssign = arrayfun(@(x)x.sKmeansStatistics.sMatchPercentage.mean/100, vsExpResults);

    % MSE
    figure;
    title(sprintf("KMeans for %d observations of ps/neg Einstein", observations));
    loglog(vSigma, vMse, "DisplayName", "\sigma^2");
    hold on;
    grid on;
    grid minor;
    loglog(vSigma, vSigma.^2, '--', "DisplayName", "\sigma^2");
    xlabel("\sigma^2");
    ylabel("MSE");
    legend("Location","bestoutside");

    % P assignment
    figure;
    title(sprintf("KMeans for %d observations of ps/neg Einstein", observations));
    semilogx(vSigma, vPAssign, "DisplayName", "\sigma^2");
    xlabel("\sigma^2");
    ylabel("P Assignment");
    grid on;
    grid minor;
end

end

