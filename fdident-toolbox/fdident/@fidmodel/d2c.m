function modc = c2d(modd,method)
%D2C  Convert discrete-time model to continuous-time via ZOH-transform
%
%       This conversion assumes the existence of the control toolbox.
%       method is either empty, or 'zoh'
%
%       Usage: modc = d2c(modd)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jan-1999

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
if nargin<2, method=''; end
if isempty(method), method='zoh'; end
if ~strcmp(method,'zoh'), error('method is not ''zoh'''), end

if ~strcmp(modd.variable,'z^-1')
  error(['Conversion d2c is not defined for variable ''',modd.variable,''''])
end
if isempty(which('@tf/d2c','-all'))&isempty(which('@tfdata/d2c','-all'))
	error('LTI method d2c is missing - cannot convert')
end
if length(modd.num)>length(modd.denom)
  error('nord>dord: cannot convert system')
end
modc=fidmodel(d2c(ss(modd),method));
%modc.type=modd.type;

% end ../@fidmodel/d2c.m