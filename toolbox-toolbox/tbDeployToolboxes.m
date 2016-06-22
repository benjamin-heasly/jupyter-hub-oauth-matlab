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
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.addParameter('toolboxRoot', '~/automatic-toolboxes', @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(config, varargin{:});
toolboxRoot = parser.Results.toolboxRoot;
restorePath = parser.Results.restorePath;

%% Obtain or update the toolboxes.
results = tbFetchToolboxes(config, 'toolboxRoot', toolboxRoot);

%% Add each toolbox to the path.
if restorePath
    restoredefaultpath();
end

% add toolboxes one at a time so that we can check for errors
% and so we don't add extra cruft in the toolboxRoog folder
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = config(tt);
    toolboxPath = fullfile(toolboxRoot, record.name);
    tbSetToolboxPath('toolboxPath', toolboxPath, 'restorePath', false);
end

