function results = tbDeployToolboxes(varargin)
% Fetch toolboxes and add them to the Matlab path.
%
% The goal here is to make it a one-liner to fetch toolboxes and add them
% to the Matlab path.  This should automate several steps that we usually
% do by hand, which is good for consistency and convenience.
%
% results = tbDeployToolboxes() fetches each toolbox from the default
% toolbox configuration adds each to the Matlab path.  Returns a struct of
% results about what happened for each toolbox.
%
% tbReadConfig( ... 'configPath', configPath) specify where to look for the
% config file.  The default location is '~/toolbox-config.json'.
%
% tbReadConfig( ... 'config', config) specify an explicit config struct to
% use instead of reading config from file.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default is '~/toolboxes/'.
%
% tbDeployToolboxes(... 'restorePath', restorePath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just append to the existing path.
%
% tbDeployToolboxes(... 'name', name) specify the name of a single toolbox
% to deploy if found.  Other toolboxes will be ignored.
%
% As an optimization for shares systems, toolboxes may be pre-deployed
% (probably by an admin) to a common toolbox root folder.  Toolboxes found
% here will be added to the path instead of toolboxes in the given
% toolboxRoot.
%
% tbFetchToolboxes( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes.  The default location is
% '/srv/toolbox-toolbox/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('configPath', '~/toolbox-config.json', @ischar);
parser.addParameter('config', [], @(c) isempty(c) || isstruct(c));
parser.addParameter('toolboxRoot', '~/toolboxes', @ischar);
parser.addParameter('toolboxCommonRoot', '/srv/toolbox-toolbox/toolboxes', @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.addParameter('name', '', @ischar);
parser.parse(varargin{:});
configPath = parser.Results.configPath;
config = parser.Results.config;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
restorePath = parser.Results.restorePath;
name = parser.Results.name;

%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig('configPath', configPath);
    
    if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
        results = config;
        return;
    end
end

%% Single out one toolbox?
if ~isempty(name)
    isName = strcmp(name, {config.name});
    if ~any(isName)
        results = config;
        return;
    end
    config = config(isName);
end

%% Obtain or update the toolboxes.
results = tbFetchToolboxes(config, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot);

%% Add each toolbox to the path.
if restorePath
    tbResetMatlabPath();
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
    if 7 == exist(toolboxSharedPath, 'dir')
        tbSetToolboxPath('toolboxPath', toolboxSharedPath, 'restorePath', false);
    elseif 7 == exist(toolboxPath, 'dir')
        tbSetToolboxPath('toolboxPath', toolboxPath, 'restorePath', false);
    end
end

