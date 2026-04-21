function ShowStatsFromMultipleRecordings(vRecordingNumber, b_plotAdditionalStats, b_plotOneOverNLine, parameterForLegend)

if nargin < 2, b_plotAdditionalStats = false; end
if nargin < 3, b_plotOneOverNLine    = false; end

vsItemsInResults = dir("Results");
vsResultFileNames = arrayfun(@(x) string(x.name), vsItemsInResults(~[vsItemsInResults.isdir]));
caNumberAfterE = arrayfun(@(x) regexp(x, '(?<=E)(\d+)', 'tokens', 'once'), vsResultFileNames, 'UniformOutput', false);
vIdx2RecNumber = zeros(size(vsResultFileNames));
for iFile = 1:length(caNumberAfterE)
    if ~isempty(caNumberAfterE{iFile})
        vIdx2RecNumber(iFile) = ceil(str2double(caNumberAfterE{iFile}));
    end
end

vFileNum = zeros(1, length(vRecordingNumber));
for recIndex = 1:length(vRecordingNumber)
    vFileNum(recIndex) = find(vIdx2RecNumber == vRecordingNumber(recIndex));
    if isempty(vFileNum(recIndex))
        error("Could not find recording number %d", vRecordingNumber(recIndex))
    end
end

assert(length(vFileNum) == length(vRecordingNumber) && ~isempty(vFileNum), ...
    "No such recording exists, last recording SN is %d", length(vsResultFileNames)-1);

caRecordings = cell(1, length(vFileNum));

caRecordings{1} = load(vsResultFileNames(vFileNum(1)));
strWithoutMat = regexprep(vsResultFileNames(vFileNum(1)), '\.mat$', '');
vStringParts = split(strWithoutMat, '_');
vVaryingParameter = vStringParts(end);

for recordingIndex = 2:length(vFileNum)
    strWithoutMat = regexprep(vsResultFileNames(vFileNum(recordingIndex)), '\.mat$', '');
    vStringParts = split(strWithoutMat, '_');
    assert(vStringParts(end) == vVaryingParameter, "The recordings have different varying parameters");
    caRecordings{recordingIndex} = load(vsResultFileNames(vFileNum(recordingIndex)));
end

switch vVaryingParameter
    case "varyingN"
        varParameter = E_Parameter.ObservationNumber;
        if nargin < 4
            parameterForLegend = E_Parameter.Sigma;
        end
    case "varyingSIG"
        varParameter = E_Parameter.Sigma;
        if nargin < 4
            parameterForLegend = E_Parameter.ObservationNumber;
        end
    otherwise
        error("Unsupported varying parameter: %s", vVaryingParameter);
end

PlotMultipleVaryingStatsGraphs(caRecordings, varParameter, parameterForLegend, b_plotAdditionalStats, b_plotOneOverNLine);

end
