function help(obj,prop)
%HELP  Type out detailed help for fiddata objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Nov-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end

if nargin==1
  type @fiddata/fiddatah.m
else
  if ~isstr(prop)|(size(prop,1)~=1)
    error('prop is illegal')
  end
  prop=idpropch(fiddata,prop);
  propi=idpropch(iddat,prop,'noerror');
  if ~isempty(propi)
    %prop=propi;
    %[fid,errmess]=fopen('@iddat/iddath.m','r');
    help(iddat,propi)
    return
  else
    [fid,errmess]=fopen('@fiddata/fiddatah.m','r');
  end
  if ~isempty(errmess), error(errmess), end
  if fid==-1, error('Cannot open help file'), end
  filestr=setstr(fread(fid)');
  fclose(fid);
  ind=findstr(lower(filestr),[sprintf('\n'),'.',lower(prop),' ']);
  if length(ind)~=1, error(['Cannot determine help for property ''',prop,'''']), end
  ind2=findstr(filestr,[sprintf('\n'),'.']);
  ind22=min(find(ind2>ind+length(prop)+1));
  if isempty(ind22)
    ind2=findstr(filestr,sprintf('\n\n'));
    if isempty(ind2), ind2=findstr(filestr,setstr([13,10,13,10])); end
    if isempty(ind2), ind2=findstr(filestr,setstr([10,10])); end
    if isempty(ind2), ind2=findstr(filestr,setstr([13,13])); end
    ind22=min(find(ind2>ind+length(prop)+1));
  end
  if length(ind22)==1
    inde=ind2(ind22);
  else
    inde=length(filestr);
  end
  eol=sprintf('\n');
  disp(filestr(ind:inde-length(eol))) 
end
%
%end @fiddata/help.m