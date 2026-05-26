function Out = setchio(dat,chn,typ)
%SETCHIO  Set input/output property of channel of TIDDATA or FIDDATA objects.
%
%       Output argument:
%       Out = resulting object
%
%       Input arguments:
%       dat = tiddata or fiddata object
%       chn = channel number(s), scalar or vector
%       typ = 'input' or 'output'

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Sep-2001

ni = nargin;
no = nargout;
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(3,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(3,3,ni)), %earlier
end
if isstr(typ)&(strcmpi(typ,'input')|strcmpi(typ,'output'))
else
  if isstr(typ), error(['typ is not allowed as ''',typ,''''])
  else error(['typ is not allowed as class ''',class(typ),''''])
  end
end
otyp=get(dat,'chtype');
ochar=get(dat,'character');
typn=lower(typ(1))+0;
for ii=1:length(chn)
  if chn(ii)>get(dat,'chn')
    error('Not enough channels in object')
  end
  chari=ochar{chn(ii)};
  if any(strmatch(chari,{'ZOH','FOH'}))
    ochar{chn(ii)}='Samples';
  elseif strcmp(chari,'BL')
  end
  otyp(chn(ii))=typn;
end %for ii
Out=dat;
set(Out,'chtype',otyp,'character',ochar);
%
%End of setchio