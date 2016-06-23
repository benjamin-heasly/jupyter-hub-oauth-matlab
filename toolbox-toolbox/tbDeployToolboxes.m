function results = tbDeployToolboxes(config, varargin)
% Fetch toolboxes and add them to the Matlab path.
%
% The goal here is to make it a one-liner to fetch toolboxes and add them
% to the Matlab path.  This should automate several steps that we usually
% do by hand, which is good for consistency and convenience.
%
% results = tbDeployToolboxes(config) fetches each toolbox in the given
% config struct and adds it to the Matlab path.  Returns a struct of
% results about what happened for each toolbox.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default is '~/toolboxes/'.
%
% tbDeployToolboxes(... 'restorePath', restorePath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just append to the existing path.
%
% As an optimization for shares systems, toolboxes may be pre-deployed
% (probably by an admin) to a common toolbox root folder.  Toolboxes found
% here will be added to the path instead of toolboxes in the given
% toolboxRoot.
%
% tbFetchToolboxes( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes.  The default location is
% '/srv/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.addParameter('toolboxRoot', '~/toolboxes', @ischar);
parser.addParameter('toolboxCommonRoot', '/srv/toolboxes', @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(config, varargin{:});
config = parser.Results.config;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
restorePath = parser.Results.restorePath;

if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    results = config;
    return;
end

%% Obtain or update the toolboxes.
results = tbFetchToolboxes(config, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot);

%% Add each toolbox to the path.
if restorePath
    restoredefaultpath();
end

% add toolboxes one at a time so that we can check for errors
% and so we don't add extra cruft that might be in the toolboxRoog folder
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = results(tt);
    if record.status ~= 0
        continue;
    end
    
    toolboxSharedPath = fullfile(toolboxCommonRoot, record.name);
    toolboxPath = fullfile(toolboxRoot, record.name);
    if 7 == exist(toolboxCommonRoot, 'dir')
        tbSetToolboxPath('toolboxPath', toolboxSharedPath, 'restorePath', false);
    elseif 7 == exist(toolboxPath, 'dir')
        tbSetToolboxPath('toolboxPath', toolboxPath, 'restorePath', false);
    end
end

