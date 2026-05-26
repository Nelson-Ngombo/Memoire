function modd = c2d(modc,ts,method)
%C2D  Convert continuous-time model to discrete-time via ZOH-transform
%
%       This conversion assumes the existence of the control toolbox.
%       ts is the sampling interval, method is either empty, or 'zoh'
%
%       Usage: modd = c2d(modc,ts)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-May-1999

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if nargin<2, error('Sampling time ts is not given'), end
if ~isnumeric(ts)|(length(ts)~=1)
  error('Invalid ts')
end
if nargin<3, method=''; end
if isempty(method), method='zoh'; end
if ~strcmp(method,'zoh'), error('method is not ''zoh'''), end

if ~strcmp(modc.variable,'s')
  error(['Conversion c2d is not defined for variable ''',modc.variable,''''])
end
if isempty(which('@tf/c2d','-all'))&isempty(which('@tfdata/c2d','-all'))
	error('Control toolbox method c2d is missing - cannot convert')
end
if length(modc.num)>length(modc.denom)
  error('Improper system (nord>dord), cannot be converted')
end
modd=fidmodel(c2d(ss(modc),ts,method));

% end ../@fidmodel/c2d.m