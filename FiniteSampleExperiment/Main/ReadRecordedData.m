function [caRecordings] = ReadRecordedData(vRecordingNumber, ~)
vsItemsInResults = dir("Results");
vsResultFileNames = arrayfun(@(x) string(x.name), vsItemsInResults(~[vsItemsInResults.isdir]));
caNumberAfterE = arrayfun(@(x) regexp(x, '(?<=E)(\d+)', 'tokens', 'once'), vsResultFileNames, 'UniformOutput', false);
vIdx2RecNumber = zeros(size(vsResultFileNames));
for iFile=1:length(caNumberAfterE)
    if ~isempty(caNumberAfterE{iFile})
        vIdx2RecNumber(iFile) = ceil(str2double(caNumberAfterE{iFile}));
    end
end

vFileNum = zeros(1, length(vRecordingNumber));
for iRec = 1:length(vRecordingNumber)
    vFileNum(iRec) = find(vIdx2RecNumber==vRecordingNumber(iRec));
    if isempty(vFileNum(iRec))
        error("Could not find recording number %d", vRecordingNumber(iRec))
    end
end

assert(length(vFileNum) == length(vRecordingNumber) && ~isempty(vFileNum), "No such recording exists, last recording SN is %d", length(vsResultFileNames)-1);

caRecordings = cell(1, length(vFileNum));

caRecordings{1} = load(vsResultFileNames(vFileNum(1)));
strWithoutMat = regexprep(vsResultFileNames(vFileNum(1)), '\.mat$', '');
vStringParts = split(strWithoutMat, '_');
vVaryingParameter = vStringParts(end);

for iRecording = 2:length(vFileNum)
   strWithoutMat = regexprep(vsResultFileNames(vFileNum(iRecording)), '\.mat$', '');
   vStringParts = split(strWithoutMat, '_');
   assert(vStringParts(end) == vVaryingParameter, "The recordings have different varying parameter");
   caRecordings{iRecording} = load(vsResultFileNames(vFileNum(iRecording)));
end
end

