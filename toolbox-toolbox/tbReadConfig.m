function [config, filePath] = tbReadConfig(varargin)
% Read toolbox configuration from a file.
%
% The idea is to locate a toolbox configuration file on disk, and load it
% into Matlab so we can work with it.  When we read, we massage the
% configuration into well-formed records.
%
% [config, filePath] = tbReadConfig() reads a config struct from file at
% the default location.  Returns the config struct as well as the full,
% absolute path to the file that was read.
%
% tbReadConfig( ... 'filePath', filePath) specify where to look for the
% config file.  The default location is '~/toolbox-toolbox-config.json'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('filePath', '~/toolbox-config.json', @ischar);
parser.parse(varargin{:});
filePath = parser.Results.filePath;

config = struct();

%% Read from disk.
if 2 ~= exist(filePath, 'file')
    return;
end

rawConfig = loadjson(filePath);
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

