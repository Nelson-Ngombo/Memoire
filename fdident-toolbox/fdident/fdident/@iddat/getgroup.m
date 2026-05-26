function grpdef=getgroup(obj,grpname)
%GETGROUP Get the value of an existing group 
%
%       grpdef=getgroup(obj,grpname)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Jan-2004

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
grpnames=groupnames(obj);
ind=strmatch(grpname,grpnames,'exact');
if isempty(ind), error(['Group ''',grpname,''' not found'])
elseif length(ind)>1, error(['Group ''',grpname,''' is repeated'])
end
ind=rem(ind-1,size(grpnames,1))+1;
gv=grpnames{ind,2}(1);
if strcmp(gv,'p'), grp='Groups_SamePower';
elseif strcmp(gv,'m'), grp='Groups_FullMIMO';
elseif strcmp(gv,'d'), grp='Groups_Delayed';
elseif strcmp(gv,'s'), grp='Groups_Synchronized';
else error(['Cannot identify group ''',grpname,''''])
end
inda=strmatch([gv,'('],grpnames(:,2));
ind=ind-min(inda)+1;
grpprop=get(obj,grp);
grpdef=grpprop(ind,1);
%
%End of setgroup