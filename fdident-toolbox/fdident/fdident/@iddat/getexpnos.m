function gpn=getexpnos(dat,group)
%GETEXPNOS  Return number of experiments from group description
%
%       gpn=getexpnos(dat,group)
%
%       group is the contents of the group

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Sep-2003

gpn=[]; %output: numbers of experiments
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if isempty(group), return, end
if isnumeric(group), gpn=group; return, end
if isstr(group)&strcmp(group,':'), gpn=[1:get(dat,'expnumber')]; return, end
groups=get(dat,'groups'); %all groups as structure
if ischar(group), group={group}; end
for ii=1:length(group)
  gpni=group{ii}; if ~iscell(gpni), gpni={gpni}; end
  gpniall=gpni;
  for ig=1:length(gpniall)
    gpni=gpniall{ig};
    if isnumeric(gpni), gpn=[gpn,gpni(:)'];
    elseif ischar(gpni)
      while ~isempty(gpni)
        gpnstart=gpn;
        for vn='pmdse'
          if strcmp(vn,'p'), var=get(dat,'Groups_SamePower'); 
          elseif strcmp(vn,'m'), var=get(dat,'Groups_FullMIMO'); 
          elseif strcmp(vn,'d'), var=get(dat,'Groups_Delayed'); 
          elseif strcmp(vn,'s'), var=get(dat,'Groups_Synchronized'); 
          elseif strcmp(vn,'e'), var=[];
          end
          if ~isempty(var)
            %set names as mn, pn, dn, sn, or en
            eval([vn,'=var(:,1);']); %needed for the evaluation commands
            eval([vn,'n=var(:,2);']); %needed for the search commands
          else 
            eval([vn,'={};']); %needed for the evaluation commands
            eval([vn,'n={};']); %needed for the search commands
          end
        end
        e=[1:get(dat,'expnumber')]; 
        for vn='pmdse'
          if strcmp(vn,'p'), var=get(dat,'Groups_SamePower'); 
          elseif strcmp(vn,'m'), var=get(dat,'Groups_FullMIMO'); 
          elseif strcmp(vn,'d'), var=get(dat,'Groups_Delayed'); 
          elseif strcmp(vn,'s'), var=get(dat,'Groups_Synchronized'); 
          elseif strcmp(vn,'e'), var=[];
          end
          if ~isempty(var)
            expcell=var(:,1); %groups of experiments in type
            if size(var,2)==2, groupnamecell=var(:,2); else groupnamecell=cell(size(var,1),1); end
          else 
            groupnamecell={}; expcell={};
          end
          ind=[];
          if ~isempty(gpni)
            %Eliminate surrounding [ and ]:
            if strcmp(gpni(1),'[')&strcmp(gpni(end),']'), gpni=gpni(2:end-1); end
            ind=findstr([vn,'('],gpni);
            indv=findstr(')',gpni);
          end
          if ~isempty(ind) %parenthesis in name
            str=gpni(ind(1):indv(1)); gpni(ind(1):indv(1))='';
          else %name of group
            if ~isempty(gpni), ind=strmatch(gpni,groupnamecell,'exact'); end
            if length(ind)>1, error('Repeated group name')
            elseif ~isempty(ind)
              str=var{ind,1}; gpni=''; 
            else
              str=''; 
            end
          end
          if ~isempty(str)
            try, if ischar(str), gpnii=eval(str); else gpnii=str; end
            catch, error(['Cannot evaluate string ''',str,''' - nonexistent group or experiment?'])
            end
            if isnumeric(gpnii), gpn=[gpn,gpnii];
            else gpn=[gpn,getexpnos(dat,gpnii)];
            end
            while ~isempty(gpni)
              if strcmp(gpni(1),' '), gpni(1)='';
              elseif strcmp(gpni(1),','), gpni(1)='';
              else break
              end
            end %while
          end %~isempty(str)
        end %for vn
        %
        if ~isempty(gpni)
          ind=1; 
          if length(gpni)>1
            s=gpni(ind+1);
            while isletter(s)|(('0'<=s)&(s<='9'))
              ind=ind+1; 
              if ind==length(gpni), break, end
              s=gpni(ind+1);
            end
          end
          name=gpni(1:ind);
          if ~isempty(name)
            indn=strmatch(name,eval([vn,'n']),'exact');
            if length(indn)==1
              gpn=[gpn,getexpnos(dat,f{indn})]; gpni(1:ind)='';
            end
            indn=strmatch(name,pn,'exact');
            if length(indn)==1
              gpn=[gpn,getexpnos(dat,p{indn})]; gpni(1:ind)='';
            end
            indn=strmatch(name,dn,'exact');
            if length(indn)==1
              gpn=[gpn,getexpnos(dat,d{indn})]; gpni(1:ind)='';
            end
            indn=strmatch(name,eval([vn,'n']),'exact');
            if length(indn)==1
              gpn=[gpn,getexpnos(dat,eval([vn,'n{indn}']))]; gpni(1:ind)='';
            end
          end
        end
        if isequal(gpnstart,gpn)&(~isempty(gpni)|~isempty(str))
          if any(('0'<=gpni)&(gpni<='9')), str=sprintf('\n  Default group names: f(n), p(n), d(n), s(n), e(n)');
          else str='';
          end
          error(['Cannot identify group ''',gpni,'''',str])
        end
      end %while
    else 
      error('gpni is not valid')
    end
  end %for ig
end %for ii
