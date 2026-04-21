function SetPaths(removePaths)
% SetPaths  Add (or remove) all required folders for FiniteSampleExperiment.
%
% Call this once from the FiniteSampleExperiment/ directory before running
% any other script in this module.
%
% Usage:
%   SetPaths          % add paths
%   SetPaths(true)    % remove paths

    if nargin < 1, removePaths = false; end

    moduleDir = fileparts(mfilename('fullpath'));
    sharedDir = fullfile(moduleDir, '..', 'Shared');

    vModuleFolders = ["Main", "Results", "Interface"];

    for folder = vModuleFolders
        fullPath = fullfile(moduleDir, folder);
        if exist(fullPath, 'dir')
            subPaths = genpath(fullPath);
            if removePaths, rmpath(subPaths); else, addpath(subPaths); end
        end
    end

    if removePaths, rmpath(sharedDir); else, addpath(sharedDir); end
end
