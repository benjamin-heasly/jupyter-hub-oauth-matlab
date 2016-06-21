function results = tbFetchToolboxes(config, varargin)
% Read toolbox configuration from a file.
%
% The idea is to work through elements of the given toolbox configuration
% struct, and for each element fetch or update the toolbox.
%
% results = tbFetchToolboxes(config) fetches or updates each of the
% toolboxes named in the given config struct (see tbReadConfig).  Each
% toolbox will be located in a subfolder of the default toolbox root
% folder.
%
% tbReadConfig( ... 'toolboxRoot', toolboxRoot) specify where to fetch
% toolboxes.  The default location is '~/automatic-toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.addParameter('toolboxRoot', '~/automatic-toolboxes', @ischar);
parser.parse(config, varargin{:});
toolboxRoot = parser.Results.toolboxRoot;

results = config;
[results.command] = deal('');
[results.status] = deal([]);
[results.result] = deal('skipped');

%% Make sure we have a place to put toolboxes.
if 7 ~= exist(toolboxRoot, 'dir')
    mkdir(toolboxRoot);
end

%% Fetch or update each toolbox.
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = tbToolboxRecord(config(tt));
    if isempty(record.name)
        results(tt).status = -1;
        results(tt).command = '';
        results(tt).result = 'no toolbox name given';
        continue;
    end
    
    toolboxFolder = fullfile(toolboxRoot, record.name);
    if 7 == exist(toolboxFolder, 'dir')
        fprintf('Updating toolbox "%s" at "%s\n', record.name, toolboxFolder);
        
        % update the toolbox with git
        if isempty(record.ref)
            pullCommand = sprintf('git -C "%s" pull', toolboxFolder);
        else
            pullCommand = sprintf('git -C "%s" pull origin %s', toolboxFolder, record.ref);
        end
        [pullStatus, pullResult] = system(pullCommand);
        results(tt).status = pullStatus;
        results(tt).command = pullCommand;
        results(tt).result = pullResult;
        if 0 ~= pullStatus
            continue;
        end
        
    else
        fprintf('Fetching toolbox "%s" into "%s\n', record.name, toolboxFolder);
        
        % obtain the toolbox with git
        cloneCommand = sprintf('git clone "%s" "%s"', record.url, toolboxFolder);
        [cloneStatus, cloneResult] = system(cloneCommand);
        results(tt).status = cloneStatus;
        results(tt).command = cloneCommand;
        results(tt).result = cloneResult;
        if 0 ~= cloneStatus
            continue;
        end
        
        % switch to optional git branch or tag
        if ~isempty(record.ref)
            fetchCommand = sprintf('git -C "%s" fetch origin +%s:%s', toolboxFolder, record.ref, record.ref);
            [fetchStatus, fetchResult] = system(fetchCommand);
            results(tt).status = fetchStatus;
            results(tt).command = fetchCommand;
            results(tt).result = fetchResult;
            if 0 ~= fetchStatus
                continue;
            end
            
            checkoutCommand = sprintf('git -C "%s" checkout %s', toolboxFolder, record.ref);
            [checkoutStatus, checkoutResult] = system(checkoutCommand);
            results(tt).status = checkoutStatus;
            results(tt).command = checkoutCommand;
            results(tt).result = checkoutResult;
            if 0 ~= checkoutStatus
                continue;
            end
        end
    end
end

