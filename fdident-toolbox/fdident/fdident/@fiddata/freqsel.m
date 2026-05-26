function Out = freqsel(dat,freqmin,freqmax)
%FREQSEL  Select frequencies of interest
%

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Jun-2001

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if ni<2, freqmin=[]; end; if isempty(freqmin), freqmin=-inf; end 
if ni<3, freqmax=[]; end; if isempty(freqmax), freqmax=inf; end 
fv=get(dat,'freqpoints');
ind=find((fv>=freqmin)&(fv<=freqmax));
if length(ind)<length(fv)
  Out=subsref(dat,struct('type','()','subs',{{ind}})); 
else
  Out=dat;
end
% end of function @fiddata/freqsel
