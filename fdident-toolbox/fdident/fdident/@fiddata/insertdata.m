function datamodel=insertdata(model,data)
%INSERTDATA  Insert data and fill in fitinfo properties for model

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Feb-2000

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if no>1
  error('Only one output argument is allowed');
end
try
  model=fidmodel(model);
catch
  error('First input argument model cannot be converted to fidmodel')  
end
datamodel=insertdata(model,data);
%
% end ../@fiddata/insertdata.m