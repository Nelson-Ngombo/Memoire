function fixgroups(obj,groupnames,mod)
%FIXGROUP  Fix group references (eliminate empty groups, renumber groups, etc.)
%
%       fixgroups(obj,groupnames)
%       groupnames: n x 2 cell array, if empty then look for empty groups
%            name  defaultname like 's(1)'
%         or 
%            grouptype  [presentnumbers desirednumbers]
%            grouptype is any of the four groups or ExperimentName
%       mod: if 'renumber', checks will not be performed

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Jan-2004

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if nargin<3, mod=''; end
if nargin>=2
  if ~isempty(groupnames)
    remname=groupnames(:,1); remname2=groupnames(:,2);
  end
else
  groupnames={}; 
end
if isempty(groupnames)
  %look for empty groups
  remname={}; remname2={};
  gi=0;
  for grp={'Groups_SamePower','Groups_FullMIMO','Groups_Delayed','Groups_Synchronized'}
    grp=grp{1};
    gi=gi+1;
    if any(gi==[1,2]), vn=lower(grp(12)); else vn=lower(grp(8)); end
    var=get(obj,grp);
    if ~isempty(var)
      %eval([vn,'=[1:size(var,1)]'';'])
      for ii=1:size(var,1)
        gm=getexpnos(obj,var(ii,1));
        if isempty(gm)
          remname=[remname;var(ii,2)]; remname2=[remname2;{[vn,'(',num2str(ii),')']}];
        end
      end %for ii
    end
  end %for grp
  %e=[1:get(obj,'expnumber')';
end
%
while length(remname2)>0
  gi=0;
  for grp={'Groups_SamePower','Groups_FullMIMO','Groups_Delayed','Groups_Synchronized',...
      'ExperimentName'}
    grp=grp{1};
    gi=gi+1;
    if any(gi==[1,2]), vn=lower(grp(12)); else vn=lower(grp(8)); end
    var=get(obj,grp);
    if strcmp(vn,'e')
      %For experiments, the variables are somewhat different
      if isempty(var), var=cell(get(obj,'expnumber'),2); end
      if ~iscell(var), var={var}; end
      if size(var,2)==1, var=[cell(size(var,1),1),var]; end
      for ii=1:size(var,1), var{ii,1}=ii; end
    end
    varsave=var;
    if ~isempty(var)
      for ii=size(var,1):-1:1
        %for ir=size(var,2):-1:1
          vari=var{ii,1}; if ~iscell(vari), vari={vari}; end
          for iii=size(vari,2):-1:1 %go through all subdefinitions
            if ischar(remname2{1})
              %called for excluding superfluous groups
              if ischar(vari{iii})
                if strcmp(remname{1},vari{iii})
                  vari(iii)=[];
                elseif ~isempty(remname2{1})
                  ind=findstr([remname2{1}(1),'('],vari{iii});
                  if ~isempty(ind)
                    inde=findstr(')',vari{iii});
                    vstr=vari{iii}(3:inde-1);
                    if (length(vstr)>=3)&strcmp(vstr(end+[-2:0]),'end'), vstr=[vstr,'num',vn]; end
                    grpind=str2num(['[',vstr,']']);
                    indm=find(ismember(str2num(remname2{1}(3:end-1)),grpind));
                    if ~isempty(indm)
                      grpind(indm)=[];
                      if isempty(grpind), vari(iii)='';
                      else vari{iii}=[remname2{1}(1),'(',num2str(grpind),')'];
                      end
                    end
                  end
                end
              else %numeric vari{iii}
                if ~isempty(remname2{1})
                  if ischar(remname2{1})
                    inde=findstr('e(',remname2{1});
                    if any(inde), remname2_1=str2num(remname2{1}(3:end-1));
                    else remname2_1=[];
                    end
                  elseif isnumeric(remname2{1})
                    remname2_1=remname2{1};
                  else
                    error('Do not know what to do with remname2{1}')
                  end
                  grpind=vari{iii};
                  indm=find(ismember(grpind,remname2_1));
                  if ~isempty(indm)
                    grpind(indm)=[];
                    if isempty(grpind), vari(iii)=[];
                    else vari{iii}=grpind;
                    end
                  end
                end
              end %ischar(remname2{1})
            else %remname2{1} is numeric: called for renumbering
              if strcmp(remname{1},'Groups_SamePower')|strcmp(remname{1},'Groups_FullMIMO')
                gv=lower(remname{1}(12));
              elseif strcmp(remname{1},'Groups_Delayed')|...
                  strcmp(remname{1},'Groups_Synchronized')|...
                  strcmp(remname{1},'ExperimentName')
                gv=lower(remname{1}(8));
              else
                error(['remname is invalid as ''',remname{1},''''])
              end
              if ischar(vari) %default name is only possible if string
                ind=findstr([gv,'('],vari);
                if ~isempty(ind) %default name found
                  ginds=vari(3:end-1);
                  if ~isempty(ginds),
                    if (length(ginds)>=3)&strcmp(ginds(end+[-2:0]),'end'), ginds=[ginds,'num',gn]; end
                    eval(['endnum',gn,'=size(get(obj,remname{1}),1);'])
                    gind=eval(ginds);
                    ism=ismember(gind,remname2{1}(:,1));
                    if any(ism)
                      indn=find(ism);
                      for ii=1:length(indn)
                        indr=find(gind(indn)==remname2{1}(:,1)); gind(indn)=remname2{1}(indr,2);
                      end %for ii
                    end
                    vari=[vari(1:2),num2str(gind),vari(end)];
                  else
                    %error('Group reference is empty')
                  end
                end
              elseif strcmp(remname{1},'ExperimentName')
                %vari numeric: group members
                gind=vari; if iscell(gind), gind=gind{1}; end
                ism=ismember(gind,remname2{1}(:,1));
                if any(ism)
                  indn=find(ism);
                  %for ii=1:length(indn)
                  indr=find(ismember(remname2{1}(:,1),gind(indn))); gind(indn)=remname2{1}(indr,2);
                  %end %for ii
                end
                vari=gind;
              end
            end
          end %for iii
          if ~strcmp(grp,'ExperimentName')
            if isempty(vari)
              remname=[remname;var(ii,2)]; remname2=[remname2;{[vn,'(',num2str(ii),')']}];
              var(ii,:)=[];
            elseif iscell(vari)&(length(vari)==1)
              var{ii,1}=vari{1};
            else
              var{ii,1}=vari;
            end
          end
        %end %for ir
      end %for ii
    end
    if ~isequal(varsave,var)&~strcmp(grp,'ExperimentName')
      if isequal(size(var),[1,2])&isequal(var{1},1), var={}; end
      set(obj,grp,var,'noconsistency');
    end 
  end %for grp
  %
  remname(1,:)=[]; remname2(1,:)=[];
end %while
%
if strcmp(mod,'renumber')|get(obj,'consistency')
  assignin('caller',inputname(1),obj)
else
  error(sprintf(['Cannot fix cross-references in groups:\n  ',lastwarn]))
end
%End of fixgroup