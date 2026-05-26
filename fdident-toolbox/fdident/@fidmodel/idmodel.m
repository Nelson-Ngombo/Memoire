function idobj=idmodel(obj)
%IDMODEL  Transform fidmodel object to idmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Apr-2000

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if no>1
  error('Only one output argument is allowed');
end
if strcmp(obj.variable,'w')
  error('Variable w does not allow idmodel object representation')
end

if exist('@idpoly/idpoly.m'), idobj=idpoly(obj);
else error('Cannot transform to idmodel object without @idpoly directory')
end

% end ../@fidmodel/idmodel.m