function idobj=idpoly(obj)
%IDPOLY  Transform fidmodel object to idpoly object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Feb-2001

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

if ~exist('@idpoly/idpoly.m')
  error('Cannot transform to idmodel object without @idpoly directory')
else
  %Conversion
  try
    idobj=elis2tha(obj,obj.covariance,NaN);
  catch
    idobj=elis2tha(obj,obj.covariance,[]);
  end
  if strcmp(obj.representation,'orthopol')
    error('Conversion from orthogonal representation is not yet implemented')
  elseif strcmp(obj.representation,'polynomial')
  else error('unknown representation')
  end
end

% end ../@fidmodel/idpoly.m