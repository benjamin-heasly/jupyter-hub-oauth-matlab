function [config, configPath] = tbReadConfig(varargin)
% Read toolbox configuration from a file.
%
% The idea is to locate a toolbox configuration file on disk, and load it
% into Matlab so we can work with it.  When we read, we massage the
% configuration into well-formed records.
%
% [config, configPath] = tbReadConfig() reads a config struct from file at
% the default location.  Returns the config struct as well as the full,
% absolute path to the file that was read.
%
% tbReadConfig( ... 'configPath', configPath) specify where to look for the
% config file.  The default location is '~/toolbox-config.json'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('configPath', '~/toolbox-config.json', @ischar);
parser.parse(varargin{:});
configPath = parser.Results.configPath;

config = struct();

%% Read from disk.
if 2 ~= exist(configPath, 'file')
    return;
end

rawConfig = loadjson(configPath);
if ~isstruct(rawConfig) && ~iscell(rawConfig)
    return;
end

%% Massage the config into well-formed records.
nToolboxes = numel(rawConfig);
wellFormedRecords = cell(1, nToolboxes);
for tt = 1:nToolboxes
    if iscell(rawConfig)
        record = rawConfig{tt};
    else
        record = rawConfig(tt);
    end
    
    if ~isstruct(record) || ~isfield(record, 'name') || isempty(record.name)
        continue;
    end
    wellFormedRecords{tt} = tbToolboxRecord(record);
end
config = [wellFormedRecords{:}];

