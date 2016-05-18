%% Startup script for use with jupyter-hub-oauth-matlab Docker environment.
%
% For now, we just call /usr/local/MATLAB/setToolboxPath.m, in order to to
% set the Matlab path for whatever toolboxes are found in
% /usr/local/MATLAB/toolboxes.
%
% We might add more here later, if we find we need to.
%
% 2016 benjamin.heasly@gmail.com

run /usr/local/MATLAB/setToolboxPath.m
