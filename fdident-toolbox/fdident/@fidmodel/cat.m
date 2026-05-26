function sys = cat(dim,varargin)
%CAT  Concatenation of fidmodel objects.
%
%   SYS = CAT(DIM,SYS1,SYS2,...) concatenates the models
%   along the dimension DIM.  The values DIM=1,2 correspond
%   to the output and input dimensions, respectively, and the values 
%   DIM=3,4,... correspond to the fidmodel array dimensions 1,2,...
%
%   For example,
%     * CAT(1,SYS1,SYS2) is equivalent to [SYS1 ; SYS2]
%     * CAT(2,SYS1,SYS2) is equivalent to [SYS1 , SYS2]
%     * CAT(4,SYS1,SYS2) is equivalent to STACK(2,SYS1,SYS2).
%
%   See also HORZCAT, VERTCAT, STACK.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 23-Feb-2000

switch dim
case 1
   sys = vertcat(varargin{:});
case 2
   sys = horzcat(varargin{:});
otherwise
   sys = stack(dim-2,varargin{:});
end
