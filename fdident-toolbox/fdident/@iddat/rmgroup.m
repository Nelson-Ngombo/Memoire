function rmgroup(obj,groupname)
%RMGROUP  Remove group from object
%
%       rmgroup(obj,groupname)
%         groupname is the name of the group or experiment

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Dec-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
gi=0; remname={}; remname2={};
if strncmpi(groupname,'Groups_Synchronized',9)|strncmpi(groupname,'Synchronized',3)
  grpsi=groupnames(obj,'Groups_Synchronized');
  groupname=grpsi(:,2);
  disp(['All groups of type Groups_Synchronized will be removed'])
elseif strncmpi(groupname,'Groups_Delayed',9)|strncmpi(groupname,'Delayed',7)
  grpsi=groupnames(obj,'Groups_Delayed');
  groupname=grpsi(:,2);
  disp(['All groups of type Groups_Delayed will be removed'])
elseif strncmpi(groupname,'Groups_FullMIMO',9)|strncmpi(groupname,'FullMIMO',5)|strcmpi(groupname,'MIMO')
  grpsi=groupnames(obj,'Groups_FullMIMO');
  groupname=grpsi(:,2);
  disp(['All groups of type Groups_FullMIMO will be removed'])
elseif strncmpi(groupname,'Groups_SamePower',9)|strncmpi(groupname,'SamePower',9)
  grpsi=groupnames(obj,'Groups_SamePower');
  groupname=grpsi(:,2);
  disp(['All groups of type Groups_SamePower will be removed'])
end
if ~iscell(groupname), groupname={groupname}; end
for ii=1:length(groupname)
  for grp={'Groups_SamePower','Groups_FullMIMO','Groups_Delayed','Groups_Synchronized','ExperimentName'}
    grp=grp{1};
    gi=gi+1;
    if any(gi==[1,2]), vn=lower(grp(12)); 
    else vn=lower(grp(8));
    end
    var=get(obj,grp);
    if strcmp(vn,'e')
      %For experiments, the variables are somewhat different
      if isempty(var), var=cell(get(obj,'expnumber'),2); end
      if ~iscell(var), var={var}; end
      if size(var,2)==1, var=[cell(size(var,1),1),var]; end
      for ii=1:size(var,1)
        var{ii,1}=ii; 
        if isempty(var{ii,2}), var{ii,2}=''; end
      end
    end
    eval(['endnum',vn,'=size(var,1);'])
    if ~isempty(var) %this type of groups defined
      ind=strmatch(groupname{1},var(:,2),'exact');
      if isempty(ind)&strncmp(groupname{ii},[vn,'('],2)
        %name not found, but generic name yes
        indv=findstr(groupname{ii},')');
        ind=str2num(groupname{ii}(3:indv-1));
        if ~isempty(ind)
          %there are element defined
          if any(ind>size(var,1)), error('Index exceeds group number'), end
          if ~isempty(var{ind,2}), groupname{ii}=var{ind,2}; else groupname{ii}=''; end
        end
      end
      if ~isempty(ind) %either name or generic name was found
        if ind<size(var,1)
          %request that numbers are changed
          remname=[remname;{grp}];
          remname2=[remname2;{[[ind+1:size(var,1)]',[ind:size(var,1)-1]']}];
        end
        if strcmp(vn,'e')
          expi=[1:get(obj,'expnumber')]'; expi(ind)=[];
          Struct.type='{}'; Struct.subs={':',expi};
          obj=subsref(obj,Struct);
        else
          var(ind,:)=[];
          set(obj,grp,var,'noconsistency');
        end
        groupname2=[vn,'(',num2str(ind),')'];
        %group was identified
        break
      end
    end
    if gi==5 %group was not found
      error(['Group ''',groupname{ii},''' not found'])
    end
  end %for vn
  %
  remname=[{groupname{ii}};remname]; remname2=[{groupname2};remname2];
  fixgroups(obj,[remname,remname2]) %make order in numbering
end
%
assignin('caller',inputname(1),obj)
%End of rmgroup