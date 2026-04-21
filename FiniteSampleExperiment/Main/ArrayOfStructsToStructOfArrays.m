function sStructOfArrays = ArrayOfStructsToStructOfArrays(vsArrayOfStructs)

if ~isstruct(vsArrayOfStructs)
    error('Input must be an array of structs.');
end

caFields = fieldnames(vsArrayOfStructs);

for i = 1:numel(caFields)
    fieldName = caFields{i};

    % Extract field values
    caFieldValues = {vsArrayOfStructs.(fieldName)};

    % Check if the field contains nested structs
    if isstruct(caFieldValues{1})
        % Handle nested structs recursively
        vsNested = [caFieldValues{:}];
        sStructOfArrays.(fieldName) = ArrayOfStructsToStructOfArrays(vsNested);
    else
        % Store as a regular array or cell array
        if isnumeric(caFieldValues{1}) || islogical(caFieldValues{1})
            sStructOfArrays.(fieldName) = cell2mat(caFieldValues);
        else
            sStructOfArrays.(fieldName) = caFieldValues;
        end
    end
end
end

