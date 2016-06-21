function toolboxRoot = tbSetToolboxPath(varargin)
% Set up the Matlab path for the system's toolbox folder.
%
% The idea is to run this script whenever you make your Matlab path
% consistent.  For example, this might be tue at the top of a Jupyter
% notebook.  It expects toolboxes to have been installed by you or an
% administrator in an agreed-upon folder, like
% '/usr/local/MATLAB/toolboxes', '~/toolboxes', or similar.
%
% toolboxRoot = tbSetToolboxPath() sets the Matlab path for the default
% toolbox folder and its subfolders and cleans up path cruft like hidden
% folders used by Git and Svn.
%
% tbSetToolboxPath(... 'toolboxRoot', toolboxRoot) specifies a toolboxRoot
% folder to set the path for.  The default is '~/toolboxes/'.
%
% tbSetToolboxPath(... 'restorePath', restorePath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just append to the existing path.
%
% Returns the toolboxRoot from which the path was set.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('toolboxRoot', '~/toolboxes', @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(varargin{:});
toolboxRoot = parser.Results.toolboxRoot;
restorePath = parser.Results.restorePath;

%% Start fresh?
if restorePath
    fprintf('Restoring Matlab default path.\n');
    restoredefaultpath();
end

fprintf('Adding toolbox paths:\n%s\n', ls(toolboxRoot));

%% Compute a new path.
toolboxPath = genpath(toolboxRoot);

%% Clean up the path.
scanResults = textscan(toolboxPath, '%s', 'delimiter', pathsep());
pathElements = scanResults{1};

% svn, git, mercurial
isCleanFun = @(s) isempty(regexp(s, '\.svn|\.git|\.hg', 'once'));
isClean = cellfun(isCleanFun, pathElements);

cleanElements = pathElements(isClean);
cleanPath = sprintf(['%s' pathsep()], cleanElements{:});

%% Put the new path in place.
addpath(cleanPath);
