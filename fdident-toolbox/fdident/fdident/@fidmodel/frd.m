function sys=frd(varargin)
%FRD  Make frd object from fidmodel

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Oct-1998

no=nargout; ni=nargin;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,5); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,5,ni)), %earlier
end

model=varargin{1};
if any(findstr(['|',model.variable,'|'],'|z|z^-1|s|'))
  ltiobj=tf(model);
  if ni==2, sys=frd(ltiobj,varargin{2});
  elseif ni==3, sys=frd(ltiobj,varargin{2},varargin{3});
  elseif ni==4, sys=frd(ltiobj,varargin{2},varargin{3},varargin{4});
  elseif ni==5, sys=frd(ltiobj,varargin{2},varargin{3},varargin{4},varargin{5});
  end
else
  error(['frd not yet ready for objects with variable ''',model.variable,''''])
end
%
%End of @fidmodel/frd