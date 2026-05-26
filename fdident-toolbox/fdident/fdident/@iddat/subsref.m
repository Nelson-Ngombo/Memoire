function result = subsref(dat,Struct,noconsy)
%SUBSREF Referencing for iddat, tiddata, fiddata objects.
%
%          dat(samples)
%          dat{channels}
%          dat.fieldname
%          dat.fieldname(indices) 
%          dat(indices1).fieldname(indices2) 
%          dat.fieldname{indices}
%          dat.input{3,2}(5)
%
%       See also:  GET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Aug-2001

ni = nargin;
if ni==1 %no referencing
   result = dat;
   return
end

if nargin<3, noconsy=''; end
switch Struct(1).type
case '.' 
   % At least dat.fieldname
   % Output will be a (piece of) one of the system fields
   result = get(dat,Struct(1).subs);
   if length(Struct)==1
     %if iscell(result)&(length(result)==1), result=result{1}; end
     return %ready with obj.field
   elseif length(Struct)>3
     error('Cannot handle references over level 3')
   end
   %
   %Here handle calls like obj.input(1) or obj.input{1} or obj.input{2,1}(3)
   if strcmp(Struct(2).type,'{}')
     if ~iscell(result);
       %not cell array, but {} reference: probably simplified result
       %Subsref has probably still to be fixed: not all fields can be cells,
       %and sometimes a vector is given if all cell elements would be equal.
       %If the index is larger than 1, it will anyway break down.
       result={result};
     end
   end
   index=Struct(2).subs; indempty=1;
   if ~iscell(index)&~isempty(index), indempty=0;
   elseif iscell(index)
     for ii=1:length(index)
       if ~isempty(index{ii}), indempty=0; end
     end
   end
   if indempty==1, result=[];
   else result=subsref(result,Struct(2:end));
   end
   return
case '{}' %Struct(1).type
  if length(Struct)>1
    switch Struct(2).type
    case '{}'
      error('Subscript {} of an iddat object cannot have another subscript {}')
    case '()'
      if length(Struct(2).subs)>1
        error('After subscript {} there may be only one index in ()')
      end
      %recursion will follow
    case '.' %Struct(2).type
      %nothing to check, recursion follows
    otherwise
      error(['Unknown subscript: ''',Struct(2).type,''''])   
    end
  end
  % dat{something}
  % Code below follows
case '()' %Struct(1).type
  if isstr(Struct(1).subs) %string, like '1:end'
    Ss=Struct(1).subs; ind=findstr(Ss,'end');
    if ~isempty(ind)
      Ss=[Ss(1:ind(1)-1),'N',Ss(ind(1)+3:end)];
      N=get(dat,'samplenumber'); 
      Struct(1).subs=eval(Ss);
    end
  end
  if length(Struct(1).subs)>=2
    %Sysid compatible call
    ss=Struct(1).subs;
    str=struct('type',{'{}','()'});
    strch=[];
    typ=get(dat,'chtype');
    %
    ind=find(typ=='o'+0);
    if (length(ss)>=2)&~isempty(ss{2})
      if isnumeric(ss{2})
        if (max(ss{2})>length(ind))
          error('Not enough output channels')
        end
        strch=[strch;ind(ss{2})];  
      elseif iscell(ss{2})|isstr(ss{2})
        strch=[strch;findchnumber(dat,ss{2},'output')];  
      end
    end
    %
    ind=find(typ=='i'+0);
    if (length(ss)>=3)&~isempty(ss{3})
      if isnumeric(ss{3})
        if (max(ss{3})>length(ind))
          error('Not enough input channels')
        end
        strch=[strch;ind(ss{3})];  
      elseif iscell(ss{3})|isstr(ss{3})
        strch=[strch;findchnumber(dat,ss{3},'input')];  
      end
    end
    %
    stre=':';
    if length(ss)>=4, stre=ss{4}; end
    str(1).subs={strch,stre};
    str(2).subs=ss(1);
    for ii=2:length(Struct)
      str=[str,Struct(ii)];
    end
    result=subsref(dat,str);
    return
  else %regular subscript: obj(1)
    s=Struct(1).subs{1};
    if ~( isstr(s) & (strcmp(':',s)|strcmp(s,'1:end')) )
      Data=dat.Data; Ref=get(dat,'ReferenceData');
      if ~iscell(Data), Data={Data}; end
      if ~iscell(Ref), Ref={Ref}; end
      if isempty(s)
        for ii=1:prod(size(Data)), Data{ii}=[]; end
        for ii=1:prod(size(Ref)), Ref{ii}=[]; end
      else
        %
        if isstr(s)&any(findstr('end',s)), endi=1; else endi=0; end
        for ii=1:size(Data,1)
          for iii=1:size(Data,2)
            Datai=Data{ii,iii};
            if endi %'end' in s
              l=length(Datai);
              s=indvgen(s,l);
            end
            Data{ii,iii}=Datai(s); %subscript one by one
          end %for iii
        end %for ii
        for ii=1:size(Ref,1)
          for iii=1:size(Ref,2)
            Refi=Ref{ii,iii};
            if endi %'end' in s
              l=length(Refi);
              s=indvgen(s,l);
            end
            Ref{ii,iii}=Refi(s); %subscript one by one
          end %for iii
        end %for ii
      end
      if length(Data)==1, Data=Data{1}; end
      if length(Ref)==1, Ref=Ref{1}; end
      dat.Data=Data;
      dat.NewProperties.ReferenceData=Ref;
      result=subsrloc(dat,':',':',s); %here call subscripting to local properties
    else
      result=dat; %:
    end
    if length(Struct)>1, result=subsref(result,Struct(2:end),noconsy); end
    if isa(result,'iddat')&~strcmp(noconsy,'noconsistency'), get(result,'consistency'); end
    return
  end
otherwise
   error(['Unknown subscript: ' Struct(1).type])
end

%Handling of dat{something}
indexc=Struct(1).subs;
if length(indexc)>2, error('Maximum two indices are allowed')
elseif length(indexc)==2, e=indexc{2};
else e=':';
end
c=indexc{1};
%
data=dat.Data;
if iscell(data), eo=size(data,2); co=size(data,1);
elseif isempty(data), eo=0; co=0;
else eo=1; co=1;
end

%Here handle the case when e is a string
if isstr(e)
  stringref=1; estr=e;
  e=getexpnos(dat,e);  
else
  stringref=0; estr='.,/';
end

cr=indvgen(c,co);
er=indvgen(e,eo);
if ~isstr(cr)&(max(cr)>co)
  error('Channel index surpasses number of channels')
end
if ~isstr(er)&(max(er)>eo)
  error('Experiment index surpasses number of experiments')
end

%Add value to fields
result=dat; %the new object will be generated here  
result.Date=datestr(now);
hist=sprintf('Object subscripted from ch x exp: %.0f x %.0f object',co,eo);
addhist(result,hist)

if ~isempty(data)
  if ~iscell(data)&~isempty(data), data={data}; end
  if iscell(data), data=data(cr,er);  end
  result.Data=data;
end

cht=result.ChTypes;
chi=find(cht=='i'+0); cir=find(ismember(cr,chi)); ci=find(ismember(cir,chi));
if ~isempty(cht)
  cht=cht(cr);
  result.ChTypes=cht;
end

names=result.Names;
if ~isempty(names)
  if iscell(names), names=names(cr);
  elseif isempty(cr), names={};
  end
  result.Names=names; 
end

ename=get(result,'ExperimentName');
if ~isempty(ename)
  if iscell(ename)
    ename=ename(er); if length(ename)==1, ename=ename{1}; end 
    %set(result,'ExperimentName',ename,'noconsistency');
    idd=get(result,'iddat');
    idd.NewProperties.ExperimentName=ename;
    set(result,'iddat',idd,'noconsistency');
  end
end

chc=result.Characters;
if ~isempty(chc)
  if iscell(chc), chc=chc(cr);
  elseif isempty(cr), chc={};
  end
  result.Characters=chc; 
end

chu=result.Units;
if ~isempty(chu)
  if iscell(chu), chu=chu(cr);
  elseif isempty(cr), chu={};
  end    
  result.Units=chu;
end

chs=result.Scales;
if ~isempty(chs)
  if iscell(chs), chs=chs(cr); 
  elseif isempty(cr), chs={};
  end    
  result.Scales=chs;
end

chf=result.Frequencies;
if ~isempty(chf)
  if iscell(chf), chf=chf(cr); 
  elseif isempty(cr), chf={};
  end    
  result.Frequencies=chf;
end

Ref=get(result,'ReferenceData');
if ~isempty(Ref)
  if iscell(Ref), Ref=Ref(ci,er); 
  elseif isempty(ci), Ref=[];
  end
  set(result,'ReferenceData',Ref,'noconsistency');
end

%children:
if isa(result,'tiddata')|isa(result,'fiddata')
  result=subsrloc(result,cr,er,':'); %subscript children properties
end

%groups=get(dat,'groups');
remname=get(dat,'experimentname')';
if isempty(remname), remname=cell(get(dat,'expnumber'),1); end
remname2=cell(get(dat,'expnumber'),1);
r2=[];
for ii=size(remname2,1):-1:1
  if ismember(ii,er)
    remname(ii,:)=[]; remname2(ii,:)=[];
    r2=[r2;ii,find(ii==er)];
  else
    remname2{ii}=['e(',num2str(ii),')'];
  end
end %for ii
if ~isempty(r2)
  if isequal(r2(:,1),r2(:,2)), r2=[]; end
end
if ~isempty(r2)
  remname=[remname;{'ExperimentName'}];
  remname2=[remname2;{r2}];
end
fixgroups(result,[remname,remname2])

if 0
for sc=1:2
  for vn='fpds'
    if strcmp(vn,'f'), grp='Groups_FullMIMO'; 
    elseif strcmp(vn,'p'), grp='Groups_SamePower'; 
    elseif strcmp(vn,'d'), grp='Groups_Delayed'; 
    elseif strcmp(vn,'s'), grp='Groups_Synchronized'; 
    end
    var=get(dat,grp);
    if sc==1
      for ii=1:size(var,1)
        m=var{ii,1}; subs=1;
        if isnumeric(m), mv=m;
        elseif ischar(m)&any(findstr('e(',m)), mv=getexpno(dat,m);
        else subs=0;
        end
        if subs
          %[im,loc]=ismember(mv,er);
          %ind=find(im==1);
          %m=loc(ind);
          im=ismember(er,mv);
          m=find(im==1);
        end
        var{ii,1}=m;
      end %for ii
      set(result,grp,var,'noconsistency');
    else %sc=2
      var=get(result,grp);
      fullname=0;
      if stringref&~isempty(var)
        if any(strmatch(estr,var(:,2),'exact')); fullname=1; end
      end
      for ii=size(var,1):-1:1
        if fullname %an experiment was selected
          if isempty(var{ii,1})
            try, var(ii,:)=[]; set(result,grp,var); catch, end
          end
        end
      end
    end %if sc
  end %for vn
end %for sc
end

if ~get(result,'consistency')
  error(sprintf(['Inconsistent result:\n  ',lastwarn]))
  %'see the warning message above for the reason'
end

if length(Struct)>1
  result=subsref(result,Struct(2:end));
end


function iv=indvgen(index,maxi)
%INDVGEN Calculate index vector from incoming index
if isstr(index)&strcmp(index,':')
  %iv=index; %':' may be kept in 5.3
  iv=[1:maxi];  
elseif isstr(index)
  ind=findstr(index,'end');
  if length(ind)==0
  elseif length(ind)==1, index=[index(1:ind-1),'maxi',index(ind+3:end)];
  else error('Two end''s in first index')
  end
  iv=eval(index);
else
  iv=index;
end
%end of indvgen

% end file @iddat/subsref.m
