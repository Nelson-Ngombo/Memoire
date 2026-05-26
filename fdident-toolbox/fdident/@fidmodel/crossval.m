function objm=crossval(obj,data)
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

domain=get(obj,'variable');
if strcmp(domain,'z^-1'), domain='z'; end
if strcmp(domain,'z'), runmod.fs=get(obj,'fs'); end
numord=length(get(obj,'num'))-1;
denomord=length(get(obj,'denom'))-1;
runmod.itmax=0;
runmod.initset='object';
runmod.initmodel=obj;
runmod.plotdens=inf;
runmod.plot0='off';
devrunmod.displaymessages='off';
objm=elis(data,domain,numord,denomord,runmod,devrunmod);
% end ../@fidmodel/crossval.m