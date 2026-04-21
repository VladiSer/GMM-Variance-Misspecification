function SetPaths(removePaths)
% SetPaths  Add (or remove) all required folders for PopulationEM_GHQuadrature.
%
% Call this once from the PopulationEM_GHQuadrature/ directory before running
% any other script in this module.
%
% Usage:
%   SetPaths          % add paths
%   SetPaths(true)    % remove paths

    if nargin < 1, removePaths = false; end

    moduleDir = fileparts(mfilename('fullpath'));
    sharedDir = fullfile(moduleDir, '..', 'Shared');

    if removePaths
        rmpath(moduleDir);
        rmpath(sharedDir);
    else
        addpath(moduleDir);
        addpath(sharedDir);
    end
end
