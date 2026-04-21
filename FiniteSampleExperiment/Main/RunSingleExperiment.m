function [vsExperimentResults] = RunSingleExperiment(runType, vModelDim, vImageDim, vObservationNumber, vSigma, vAveragingSteps, b_saveResults, b_parallel, b_debug, b_gtInit)

if nargin < 9
    b_debug = false;
end
if nargin < 10
    b_gtInit = false;
end

% Check for input validity and for the varying parameter
vb_VaryingParameter = [numel(vModelDim)>1, numel(vImageDim)>1, numel(vObservationNumber)>1, numel(vSigma)>1, numel(vAveragingSteps)>1];
b_variableModelCreation = false;

if sum(vb_VaryingParameter) == 0
    error('Invalid input - no varying parameter');
elseif sum(vb_VaryingParameter) > 2
    error('Invalid input - more than 1 varying parameter');
elseif vb_VaryingParameter(1)
    vVaryingParameter = vModelDim;
    b_variableModelCreation = true;
elseif vb_VaryingParameter(2)
    vVaryingParameter = vImageDim;
    b_variableModelCreation = true;
elseif vb_VaryingParameter(3)
    vVaryingParameter = vObservationNumber;
elseif vb_VaryingParameter(4)
    vVaryingParameter = vSigma;
elseif vb_VaryingParameter(5)
    vVaryingParameter = vAveragingSteps;
else
    error('Unexpected error');
end

nExp = numel(vVaryingParameter);
vModelDim = padarray(vModelDim, [0,nExp - numel(vModelDim)], 'replicate', 'post').';
vImageDim = padarray(vImageDim, [0,nExp - numel(vImageDim)], 'replicate', 'post').';
vObservationNumber = padarray(vObservationNumber, [0,nExp - numel(vObservationNumber)], 'replicate', 'post').';
vSigma = padarray(vSigma, [0,nExp - numel(vSigma)], 'replicate', 'post').';
vAveragingSteps = padarray(vAveragingSteps, [0,nExp - numel(vAveragingSteps)], 'replicate', 'post').';

assert(all(vObservationNumber > vImageDim.^2), "Make sure you have more observations than the data - otherwise fitgmdist won't work");

if b_saveResults && ~exist('Results', 'dir')
    mkdir('Results');
end

vsExperimentResults = repmat(CreateExperimentResults(vModelDim(1)), nExp, 1);

if b_parallel
    if b_saveResults
        vsItemsInResults = dir("Results");
        vsFilesInResults = vsItemsInResults(~[vsItemsInResults.isdir]);
        nLastSaved = length(vsFilesInResults) - 1;

        % up to here this has to be valid
        sigmaStr = strrep(num2str(min(vSigma(1))), '.', '_');
        if vb_VaryingParameter(1) % Model Dim
            newRecordString = sprintf("E%d_S%d_SIG%s_AVG%d_N%d_D%d_varyingK_partial.mat",nLastSaved+1, nExp, sigmaStr, vAveragingSteps(1), vObservationNumber(1), vImageDim(1));
        elseif vb_VaryingParameter(2) % Image Dim
            newRecordString = sprintf("E%d_S%d_SIG%s_AVG%d_K%d_N%d_varyingD_partial.mat",nLastSaved+1, nExp, sigmaStr, vAveragingSteps(1), vModelDim(1), vObservationNumber(1));
        elseif vb_VaryingParameter(3) % Observation Number
            newRecordString = sprintf("E%d_S%d_SIG%s_AVG%d_K%d_D%d_varyingN_partial.mat", nLastSaved+1, nExp, sigmaStr, vAveragingSteps(1), vModelDim(1), vImageDim(1));
        elseif vb_VaryingParameter(4) % Sigma
            newRecordString = sprintf("E%d_S%d_AVG%d_K%d_N%d_D%d_varyingSIG_partial.mat",nLastSaved+1, nExp, vAveragingSteps(1), vModelDim(1), vObservationNumber(1), vImageDim(1));
        else % vb_VaryingParameter(5) == 1 % Averaging Steps
            newRecordString = sprintf("E%d_S%d_SIG%s_K%d_N%d_D%d_varyingAVG_partial.mat",nLastSaved+1, nExp, sigmaStr, vModelDim(1), vObservationNumber(1), vImageDim(1));
        end

        q = parallel.pool.DataQueue;
        mf = matfile(fullfile('Results', newRecordString), 'Writable', true);
        mf.vsExperimentResults = vsExperimentResults;
        mf.vModelDim = vModelDim;
        mf.vObservationNumber = vObservationNumber;
        mf.vSigma = vSigma;
        mf.vAveragingSteps = vAveragingSteps;
        mf.vImageDim = vImageDim;
        afterEach(q, @onResult);
    end
    if ~b_variableModelCreation
        caData = GetScientistImageData(vModelDim(1), vImageDim(1));
    end
    for iMain=1:nExp
        if b_variableModelCreation 
            caCurrentData = GetScientistImageData(vModelDim(iMain), vImageDim(iMain));
        else % copy needed only for the parallel case
            caCurrentData = caData;
        end
        
        vsIterationOutput = repmat(CreateIterationOutput(vModelDim(iMain), vImageDim(iMain)^2), vAveragingSteps(iMain), 1);

        parfor iStep =1:vAveragingSteps(iMain)
            [sIterationOutput] = RunSingleIteration(caCurrentData, vSigma(iMain), vObservationNumber(iMain), runType, b_debug, b_gtInit);
            vsIterationOutput(iStep) = sIterationOutput;
        end
        sResults = CalcStatisticsAndPopulateExpOutput(vsIterationOutput, vModelDim(iMain));
        vsExperimentResults(iMain) = sResults;
        if b_saveResults
            send(q, struct('i', iMain, 'res', sResults, 'matFile', mf));
        end
        dateTime = datetime('now','Format','dd-HH:mm:ss');
        fprintf("Finished test number %d out of total %d tests at %s\n", iMain, nExp, string(dateTime));
    end
else
    if ~b_variableModelCreation
        caData = GetScientistImageData(vModelDim(1), vImageDim(1));
    end
    for iMain=1:nExp
        if b_variableModelCreation
            caData = GetScientistImageData(vModelDim(iMain), vImageDim(iMain));
        end

        vsIterationOutput = repmat(CreateIterationOutput(vModelDim(iMain), vImageDim(iMain)^2), vAveragingSteps(iMain), 1);

        for iStep = 1:vAveragingSteps(iMain)
            [sIterationOutput] = RunSingleIteration(caData, vSigma(iMain), vObservationNumber(iMain), runType, b_debug, b_gtInit);
            vsIterationOutput(iStep) = sIterationOutput;
        end

        vsExperimentResults(iMain) = CalcStatisticsAndPopulateExpOutput(vsIterationOutput, vModelDim(iMain));
        fprintf("Finished test number %d out of total %d tests\n", iMain, nExp);
    end
end

if b_saveResults && ~b_parallel
    vsItemsInResults = dir("Results");
    vsFilesInResults = vsItemsInResults(~[vsItemsInResults.isdir]);
    nLastSaved = length(vsFilesInResults) - 1;

    % up to here this has to be valid
    sigmaStr = strrep(num2str(min(vSigma(1))), '.', '_');
    if vb_VaryingParameter(1) % Model Dim
        newRecordString = sprintf("E%d_S%d_SIG%s_AVG%d_N%d_D%d_varyingK.mat",nLastSaved+1, nExp, sigmaStr, vAveragingSteps(1), vObservationNumber(1), vImageDim(1));
    elseif vb_VaryingParameter(2) % Image Dim
        newRecordString = sprintf("E%d_S%d_SIG%s_AVG%d_K%d_N%d_varyingD.mat",nLastSaved+1, nExp, sigmaStr, vAveragingSteps(1), vModelDim(1), vObservationNumber(1));
    elseif vb_VaryingParameter(3) % Observation Number
        newRecordString = sprintf("E%d_S%d_SIG%s_AVG%d_K%d_D%d_varyingN.mat", nLastSaved+1, nExp, sigmaStr, vAveragingSteps(1), vModelDim(1), vImageDim(1));
    elseif vb_VaryingParameter(4) % Sigma
        newRecordString = sprintf("E%d_S%d_AVG%d_K%d_N%d_D%d_varyingSIG.mat",nLastSaved+1, nExp, vAveragingSteps(1), vModelDim(1), vObservationNumber(1), vImageDim(1));
    else % vb_VaryingParameter(5) == 1 % Averaging Steps
        newRecordString = sprintf("E%d_S%d_SIG%s_K%d_N%d_D%d_varyingAVG.mat",nLastSaved+1, nExp, sigmaStr, vModelDim(1), vObservationNumber(1), vImageDim(1));
    end

    save(fullfile('Results', newRecordString), "vsExperimentResults", "vModelDim", "vImageDim", "vObservationNumber", "vSigma" ,"vAveragingSteps");
end
end

function onResult(msg)
    msg.matFile.vsExperimentResults(msg.i, 1) = msg.res;
    fprintf("Saved step %d\n", msg.i);
end