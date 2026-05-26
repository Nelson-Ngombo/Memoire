function Out = check(obj)
%CHECK  List fields and types
%
%   See also  @CLASS/GET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Sep-1998

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end

if no, Out=diff(obj,'ListAllObjectProperties');
else diff(obj,'ListAllObjectProperties');
end

% end @iddat/check.m
