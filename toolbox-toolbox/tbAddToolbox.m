function results = tbAddToolbox(varargin)
% Add a toolbox to the toolbox configuration, fetch it, add it to the path.
%
% The goal here is to make it a one-liner to add a new toolbox to the
% working configuration.  So this is just a utility wrapper on other
% toolbox functions.
%
% results = tbAddToolbox( ... name, value) creates a new toolbox record
% based on the given name-value pairs and adds it to the toolbox
% configuration.  The recognized names are:
%   - 'name' unique name to identify the toolbox and the folder that
%   contains it.
%   - 'url' the url where the toolbox can be obtained, like a GitHub clone
%   url.
%   - 'type' the type of repository that contains the toolbox, currently
%   only 'git' is allowed
%   - 'ref' optional branch/tag to git fetch and checkout after clonging
%   the toolbox
%
% If a toolbox with the same 'name" already exists in the configuration, it
% will be replaced with the new one.
%
% tbAddToolbox( ... 'configPath', configPath) specify where to look for the
% toolbox config file.  The default location is '~/toolbox-config.json'.
%
% tbReadConfig( ... 'toolboxRoot', toolboxRoot) specify where to fetch
% toolboxes.  The default location is '~/automatic-toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addParameter('configPath', '~/toolbox-config.json', @ischar);
parser.addParameter('toolboxRoot', '~/automatic-toolboxes', @ischar);
parser.parse(varargin{:});
configPath = parser.Results.configPath;
toolboxRoot = parser.Results.toolboxRoot;

%% Make a new toolbox record.
newRecord = tbToolboxRecord(varargin{:});

%% Deploy just the new toolbox.
results = tbDeployToolboxes(newRecord, ...
    'toolboxRoot', toolboxRoot, ...
    'restorePath', false);

if 0 ~= results.status
    error('AddToolbox:deployError', 'Could not deploy toolbox with name "%s": %s', ...
        results.name, results.result);
end

%% Add new toolbox to the existing config.
config = tbReadConfig('configPath', configPath);
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = newRecord;
else
    isExisting = strcmp({config.name}, newRecord.name);
    if any(isExisting)
        insertIndex = find(isExisting, 1, 'first');
    else
        insertIndex = numel(config) + 1;
    end
    config(insertIndex) = newRecord;
end

%% Write back the new config. after success.
tbWriteConfig(config, 'configPath', configPath);

