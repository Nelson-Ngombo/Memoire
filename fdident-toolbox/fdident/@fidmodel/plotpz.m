function plotpz(mod)
%PLOTPZ  Plot pole/zero pattern, with conficence ellipses if available
%
%       Usage: plotpz(mod)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-Jun-1999

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
plotelpz(mod,mod.covariance)

% end ../@fidmodel/plotpz.m