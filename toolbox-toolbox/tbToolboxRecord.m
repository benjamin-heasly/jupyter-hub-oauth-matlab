function record = tbToolboxRecord(varargin)
% Make a well-formed struct to represent a toolbox.
%
% The idea is to represent a toolbox that we want, using a consistent
% struct format.  Making the struct format consistent is useful because we
% can check for required fields and, and put lots of records together into
% a struct array, which is easier to work with than a cell array.
%
% record = tbToolboxRecord() creates a placeholder record with the correct
% fields.
%
% record = tbToolboxRecord( ... name, value) fills in the record with
% fields based on the given names-value pairs.  Unrecognized names
% will be ignored.  The recognized names are:
%   - 'name' unique name to identify the toolbox and the folder that
%   contains it.
%   - 'url' the url where the toolbox can be obtained, like a GitHub clone
%   url.
%   - 'type' the type of repository that contains the toolbox, currently
%   only 'git' is allowed
%   - 'ref' optional branch/tag to git fetch and checkout after clonging
%   the toolbox
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addParameter('name', '', @ischar);
parser.addParameter('url', '', @ischar);
parser.addParameter('type', 'git', @ischar);
parser.addParameter('ref', '', @ischar);
parser.parse(varargin{:});

% let the parser do all the work
record =  parser.Results;
