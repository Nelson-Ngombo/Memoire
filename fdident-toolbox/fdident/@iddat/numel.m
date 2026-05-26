function nel = numel(dat,varargin)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Aug-2001

nel=1;
return

if nargin>1
    % DAT{IDX} syntax disabled
    error('Syntax DATA{...} is no longer supported. Use GETEXP or MERGE instead.')
else
    nel = 1;
end