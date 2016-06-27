%% Startup script for use with jupyter-hub-oauth-matlab Docker environment.
%
% We find the "toolbox-toolbox" which helps us obtain and deploy other
% toolboxes via Git.
%
% We look for a file that tells us what toolboxes the current user
% wants to deploy.  If not found, we copy in a default.
%
% This will allow the user to deploy toolboxes with tbDeployToolboxes().
%
% 2016 benjamin.heasly@gmail.com

%% Start with default path to prevent funky behavior.
restoredefaultpath();

%% Add the toolbox-toolbox to the path.
toolboxToolboxSharedPath = '/srv/toolbox-toolbox/';
if 7 == exist(toolboxToolboxSharedPath, 'dir')
    addpath(genpath(toolboxToolboxSharedPath));
end

