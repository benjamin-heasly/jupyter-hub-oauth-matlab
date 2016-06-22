%% Startup script for use with jupyter-hub-oauth-matlab Docker environment.
%
% We find the "toolbox-toolbox" which helps us obtain and deploy other
% toolboxes via Git.
%
% We look for a file that tells us what toolboxes the current user
% wants to deploy.  If not found, we copy in a default.  Then we deploy all
% those toolboxes.
%
% 2016 benjamin.heasly@gmail.com

%% Add the toolbox-toolbox to the path.
toolboxToolboxPath = '/srv/toolbox-toolbox/';
if 7 == exist(toolboxToolboxPath, 'dir')
    addpath(genpath(toolboxToolboxPath));
end

%% Locate or create the user's toolbox config file.
userConfigPath = '~/toolbox-config.json';
if 2 ~= exist(userConfigPath, 'file');
    % copy from standard, shared location
    standardConfigPath = '/srv/toolbox-toolbox/toolbox-config.json';
    copyfile(standardConfigPath, userConfigPath);
end

%% Load the config and deploy the toolboxes that were caled for.
config = tbReadConfig(userConfigPath);
tbDeployToolboxes(config);
