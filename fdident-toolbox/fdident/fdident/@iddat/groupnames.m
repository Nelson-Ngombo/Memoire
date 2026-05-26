function gnames=groupnames(obj,grp)
%GROUPNAMES  Get all group names in a cell array
%
%       groupnames(obj,grp)
%         if grp is empty or 'all', all group names will be returned, 
%         for 'exptoo', also including experiments

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Jan-2004

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
if nargin<2, grp=''; end
if isempty(grp)|strcmpi(grp,'all')|strcmpi(grp,'exptoo')
  if strcmpi(grp,'exptoo'), gnames=groupnames(obj,'Experiments');
  else gnames={};
  end
  gnames=[gnames;
    groupnames(obj,'Groups_Synchronized');
    groupnames(obj,'Groups_Delayed');
    groupnames(obj,'Groups_SamePower');
    groupnames(obj,'Groups_FullMIMO')];
elseif strncmpi(grp,'Experiments',3)
  var=get(obj,'ExperimentName');
  if isempty(var), var=cell(get(obj,'expnumber'),2); end
  if ~iscell(var), var={var}; end
  if size(var,2)==1, var=[var,cell(size(var,1),1)]; end
  for ii=1:size(var,1)
    if isempty(var{ii,1}), var{ii,1}=''; end
    var{ii,2}=['e(',num2str(ii),')'];
  end
  gnames=var;
elseif strncmpi(grp,'Groups_Synchronized',9)|...
    strncmpi(grp,'Groups_Delayed',8)|...
    strncmpi(grp,'Groups_SamePower',9)|...
    strncmpi(grp,'Groups_FullMIMO',8)
  if strncmpi(grp,'Groups_SamePower',9)|strncmpi(grp,'Groups_FullMIMO',9)
    gv=lower(grp(12));
  else
    gv=lower(grp(8));
  end
  var=get(obj,grp);
  if ~isempty(var)
    var=[var(:,2),cell(size(var,1),1)];
    for ii=1:size(var,1)
      if isempty(var{ii,1}), var{ii,1}=''; end
      var{ii,2}=[gv,'(',num2str(ii),')'];
    end
  end
  gnames=var;
else
  error(['Group ''',grp,''' is not understandable'])
end
%End of groupnames
