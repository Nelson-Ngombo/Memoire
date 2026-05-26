function Out = neq(obj1,obj2)
%EQ  Returns 0 if all properties (beside some strings, etc) are equal.
%       Properties not considered: Name, Date, Notes, History, Instrumentation
%       See also  @IDDAT/GET, @IDDAT/SET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Sep-1998

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end

Out=~eq(obj1,obj2);
%
% end @iddat/neq.m
