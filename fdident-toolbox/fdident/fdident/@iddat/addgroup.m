function addgroup(obj,grouptype,group,groupname)
%ADDGROUP  Add group to existing ones
%
%       addgroup(obj,grouptype,group,groupname)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jan-2004

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(3,4); %Matlab 2016a or later
else ni=nargin; error(nargchk(3,4,ni)), %earlier
end
if nargin<4, groupname=''; end
if strncmpi(grouptype,'Synchronized',2), grouptype='Groups_Synchronized'; 
elseif strncmpi(grouptype,'Delayed',3), grouptype='Groups_Delayed'; 
elseif strncmpi(grouptype,'FullMIMO',5), grouptype='Groups_FullMIMO'; 
elseif strncmpi(grouptype,'MIMO',4), grouptype='Groups_FullMIMO'; 
elseif strncmpi(grouptype,'SamePower',5), grouptype='Groups_Synchronized'; 
end
if strncmpi(grouptype,'Groups_Synchronized',9)|...
    strncmpi(grouptype,'Groups_Delayed',9)|...
    strncmpi(grouptype,'Groups_FullMIMO',9)|...
    strncmpi(grouptype,'Groups_SamePower',9)
else
  fprintf(['Possible group types:\n',...
    '  Groups_Synchronized\n',...
    '  Groups_Delayed\n',...
    '  Groups_FullMIMO\n',...
    '  Groups_SamePower\n'])
  error(['grouptype is not allowed as ''',grouptype,''''])
end
groups=get(obj,grouptype);
if isempty(groups), groups={}; end
if isnumeric(group)|ischar(group)
  group={group};
end
if iscell(group)
  if ~iscell(groupname), groupname={groupname}; end
  while size(group,1)>size(groupname,1), groupname=[groupname;groupname(1)]; end
  if size(group,2)>1
    for ii=1:size(group,1)
      group{ii,1}=group(ii,1:end);
    end
    group(:,2:end)=[];
  end
  if length(getexpnos(obj,group{1}))<=1
    error(sprintf('Adding a group with %.0f element makes no sense',length(group{1})))
  else
    groups=[groups;group,groupname];
  end
else
  error('Cannot handle group')
end
set(obj,grouptype,groups);
assignin('caller',inputname(1),obj)