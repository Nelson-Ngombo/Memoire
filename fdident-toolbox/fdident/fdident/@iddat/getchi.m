function chi = getchi(dat,chstring,cno,names)
%GETCHI  Get channel numbers for reference 'ch:...'
%
%       dat = object
%       cno = number of channels (for speed only)
%       names = Names block (for speed only)
%
%       See also  @CLASS/SET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Sep-1998

if iscell(names)
  for ii=1:length(names);
    namesii=names{ii};
    if ~isempty(namesii)
      if all(namesii>='0'+0)&all(namesii<='9'+0) %name formed of numbers only
        error('Reference ''ch:...'' is used while a channel name consists of digits only')
      end
    end
  end    
end
nstr=chstring(4:end); commai=findstr(nstr,',');
if isempty(commai), commai=findstr(nstr,';'); end
if isempty(commai), commai=length(nstr)+1; end
chstrc={nstr(1:commai-1)}; chstrc{2}=nstr(commai+1:end);
for ii=1:2
  if (ii==2)&(commai>length(chstring(4:end))), break, end %only one channel
  chi(ii)=0;
  nstr=chstrc{ii};
  if ~isempty(nstr)
    if all((nstr>='0'+0)&(nstr<='9'+0)) %presumably an integer number
      chi(ii)=str2num(nstr);
      if chi(ii)<1, error(['Illegal channel number: ',num2str(chi(ii))]), end
    else %maybe channel name
      chi(ii)=0;
      if iscell(names)
        for iii=1:length(names)
          if strcmp(nstr,names{iii}), chi(ii)=iii; end, break
        end %for iii
      end
      if chi(ii)==0
        error(['Cannot find channel with name ',nstr]),
      end          
    end %channel number or name
    if length(chi)==1
      if chi(1)>min(cno+1,100)
        error(['Too large channel number: ',num2str(chi)])
      end
    elseif length(chi)==2
      if chi(ii)>min(cno,100)
        error(['Too large channel number: ',num2str(chi)])
      end        
    end
  elseif ii==2 %empty nstr, but cycle 2
    error('Empty channel number or name') %empty nstr
  end
end %for ii=1:2
%
%end of @iddat/getchi
