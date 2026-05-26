function objm=crossval(data,obj)
%CROSSVAL  Perform cross validation calculation on model with given data.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Apr-2000

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if no>1
  error('Only one output argument is allowed');
end

objm=crossval(obj,data);
;
% end ../@fidmodel/crossval.m