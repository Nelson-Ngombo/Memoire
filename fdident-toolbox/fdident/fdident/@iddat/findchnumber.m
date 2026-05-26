function chn = findchnumber(dat,names,mod)
%FINDCHNUMBER  Find channel numbers from channel names
%
%       Output argument:
%       chn = vector of channel numbers
%
%       Input arguments:
%       dat = tiddata or fiddata object
%       names = string or cell array of names
%       mod = if 'exp', then look for experiment numbers
%             'input' or 'output': look for special channels only

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Sep-2001

ni = nargin;
no = nargout;
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,3,ni)), %earlier
end
if ni<3, mod=''; end

chn=[];
if isstr(names)
  if strcmp(names,':'); 
    if strncmpi(mod,'exp',3)
      chn=[1:get(dat,'expn')]';
    else
      if strcmpi(mod,'input')|strcmpi(mod,'output')
        chtyp=setstr(get(dat,'chtype'));
        if ~isempty(chtyp), chn=find(chtyp==mod(1)); end
      else
        chn=[1:get(dat,'chn')]';
      end
    end
    return
  end
  names={names};
elseif iscell(names), names=names(:);
else error('Names not allowed')
end
chn=[];
if strncmpi(mod,'Experiment',3), chnames=get(dat,'experimentname');
else
  chnames=get(dat,'names');
  chtype=setstr(get(dat,'chtype'));
  if strcmpi(mod,'input')|strcmpi(mod,'output')
    for ii=1:length(chtype)
      if strcmp(chtype(ii),'i')&strcmpi(mod,'output'), chnames{ii}=''; 
      elseif strcmp(chtype(ii),'o')&strcmpi(mod,'input'), chnames{ii}=''; 
      end
    end %for ii
  end
end
for ii=1:length(names)
  ind=strmatch(names{ii},chnames,'exact');
  if isempty(ind), error(['Name ''',names{ii},''' not found'])
  else
    for iii=1:length(ind)
      if any([chn;NaN]==ind(iii))
        if strncmpi(mod,'Experiment',3), 
          error(sprintf('Experiment %.0f repeatedly found',ind(iii)))
        else
          error(sprintf('Channel %.0f repeatedly found',ind(iii)))
        end
      end
    end
    chn=[chn;ind(:)];
  end
end
%
%End of findchnumber