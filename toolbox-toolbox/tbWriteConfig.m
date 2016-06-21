function filePath = tbWriteConfig(config, varargin)
% Write the given toolbox config struct to a file.
%
% The idea is to take the toolbox configuration struct we're working with
% and write it to a file for later.  When we write, we massage the given
% configuration into well-formed records.
%
% filePath = tbWriteConfig(config) write the given config struct to a file
% at the default location, and returns the full, absolute path to the
% written file.
%
% tbWriteConfig( ... 'filePath', filePath) specify where to
% write the config file.  The default location is
% '~/toolbox-config.json'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.addParameter('filePath', '~/toolbox-config.json', @ischar);
parser.parse(config, varargin{:});
config = parser.Results.config;
filePath = parser.Results.filePath;

%% Massage the given config into well-formed records.
nToolboxes = numel(config);
wellFormedRecords = cell(1, nToolboxes);
for tt = 1:nToolboxes
    record = config(tt);
    if ~isfield(record, 'name') || isempty(record.name)
        continue;
    end
    wellFormedRecords{tt} = tbToolboxRecord(record);
end
records = [wellFormedRecords{:}];

%% Write out to disk.
savejson('', records, filePath);
