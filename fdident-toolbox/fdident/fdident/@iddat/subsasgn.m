function result = subsasgn(dat,Struct,rhs)
%SUBSASGN  Assignment for iddat, tiddata, fiddata objects.
%
%            dat(indices) = []
%            dat.fieldname = rhs
%            dat.fieldname(indices) = rhs
%            dat{:,i} = rhs
%            dat.input{i,j}(k) = rhs
%
%       Input arguments:
%       dat = object
%       Struct = structure of indices etc.
%       rhs = value assigned

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Aug-2001
%
%       See also  SET.

%Return object if only one argument is given
if nargin==1,
  result = dat;
  return
end

StructL = length(Struct);
switch Struct(1).type %determine which operand is used
case '.' %Struct(1).type, subfield, data.name etc.
  % At least dat.fieldname=rhs
  fieldname = Struct(1).subs;
  if StructL==0 %this is impossible if ni>1
  elseif StructL==1,
    %Just dat.fieldname=rhs
    Value = rhs;
  else %StructL>1
    %Here we give value to a subscripted field.
    Value = get(dat,fieldname);
    %Now Value is the field value, and rhs is not empty
    Struct=Struct(2:end); StructL = StructL-1;
    %now Struct refers to subscripting the field value
    if (StructL==1)|((StructL==2)&strncmpi(fieldname,'InterExpC',9))
      switch Struct(1).type
      case '.'
        %this will be used when the field value is a struct (e.g. instrumentation)
        eval(['Value.' Struct.subs '=rhs;']);
      case '()'
        Value(Struct.subs{:}) = rhs;
      case '{}' %dat.field{i}
        if any(findstr(['|',lower(fieldname)],'|input'))|...
            any(findstr(['|',lower(fieldname)],'|output'))
          if strcmp(class(dat),'iddat'), chtypes=dat.ChTypes;
          else s=struct(dat); sid=s.iddat; chtypes=sid.ChTypes;
          end
          if ~isempty(chtypes)
            chno=sum(chtypes==lower(fieldname(1))+0);
          else chno=0;
          end
        else
          chno=get(dat,'ChNumber');
        end
        if iscell(rhs)
          expno=1;
          chno=min(chno,size(rhs,1));
          if any(findstr(['|',lower(fieldname),'|'],...
              '|input|output|inputfreqpoints|outputfreqpoints|freqpoints|')) | ...
              strncmpi(fieldname,'InterExpC',9)
            expno=min(get(dat,'ExpNumber'),size(rhs,2));
          else
            error(['The value may not be a cell for {} subscripting of field ''',...
                fieldname,''''])
          end
        else
          expno=get(dat,'ExpNumber');
        end
        if strncmpi(fieldname,'InterExpC',9)
          if isempty(Value)&~isempty(rhs)
            Value=cell(expno,expno);
            for ii=1:prod(size(Value)), Value{ii}=cell(chno,chno); end
          end
        end
        [dummy,propposs]=idpropch(dat,fieldname);
        if ~iscell(Value)&any(findstr(propposs,'cell'))
          %simplified contents
          Valuesave=Value; Value=cell(chno,expno);
          for ii=1:chno
            for iii=1:expno
              Value{ii,iii}=Valuesave;
            end
          end              
        end
        if isnumeric(Struct(1).subs{1})&any(Struct(1).subs{1}>chno)
          error('Index exceeds channel number')
        end
        if strncmpi(fieldname,'InterExpC',9) %don't compare 2nd index to expnumber
          if (length(Struct)==1)
            if isempty(rhs), rhs=cell(chno,chno); end
            if iscell(rhs)
              Value{Struct.subs{:}} = rhs; %obj.interexpc{1,2}=cell;
            else
              error('For cell assignment, rhs must be a cell array')
            end
          elseif (length(Struct)==2)&strcmp(Struct(2).type,'{}')&isnumeric(rhs)
            Value=subsasgn(Value,Struct,rhs); %obj.interexpc{1,2}{1}=vector;
          else
            error('Cannot resolve indexing and assignment')
          end
        elseif (length(Struct.subs)>1)&isnumeric(Struct.subs{2})&...
            any(Struct.subs{2}>expno)
          error('Index exceeds experiment number')
        else
          Value{Struct.subs{:}} = rhs;
        end
      otherwise
        error('Invalid type field in Struct (internal error)')
      end
    elseif (StructL==2)&...
        (strcmp(lower(fieldname),'input')|strcmp(lower(fieldname),'output'))
      if ~strcmp(Struct(1).type,'{}')|~strcmp(Struct(2).type,'()')
        error('Reference is not dat.input{i1}(i2) or similar')
      end
      data=dat.Data;
      if iscell(data)
        [co,eo]=size(data); so=length(data{1});
      else %double
        [co,so]=size(data); eo=1;
        if ~isempty(data), data={data}; end
      end
      c=Struct(1).subs{1};
      if length(Struct(1).subs)>1, e=Struct(1).subs{2};
      else e=':';
      end
      if length(Struct)==2, s=Struct(2).subs{1};
      else s=':';
      end
      ev=indvgen(e,eo);
      if (length(ev)~=1)|(strcmp(ev,':')&(eo>1))
        error('Subscript {i,j} does not refer to single experiment')
      end
      cv=indvgen(c,co);
      sv=indvgen(s,so);
      if ~iscell(Value), Value={Value}; end
      if ~strcmp(class(Value{cv,ev}(sv)),class(rhs))
        error('Class of right size is not proper')
      end
      Value{cv,ev}(sv)=rhs;
    else
      error('Cannot handle so many subscripts')
    end %Inner length of StructL
  end %length of StructL
  %set will check at the end if valid iddat is generated
  result = dat;
  if strcmp(fieldname,'u'), fieldname='Input';
  elseif strcmp(fieldname,'y'), fieldname='Output';
  end
  if any(findstr('groups',fieldname))&iscell(Value)&(size(Value,1)==1)
    if (size(Value,2)>2)|((size(Value,2)==2)&~ischar(Value{1,2})), Value=Value'; end
  end
  if isa(result,'iddat')
    set(result,fieldname,Value,'noconsistency')
  else
    set(result,fieldname,Value)
  end
  return
  %End of dat.fieldname... referencing
case '()' %Struct(1).type
  s1=Struct(1).subs;
  if length(s1)>1 
    %Sysid compatible call, redirect to {}
    Struct0.type='{}';
    cht=get(dat,'chtypes');
    iind=find(cht=='i'+0);
    oind=find(cht=='o'+0);
    if isnumeric(s1{2})&any(s1{2}>length(oind))
      error('Nonexistent output channel is referred to')
    end
    s0c=oind(s1{2});
    if length(s1)>=3
      if isnumeric(s1{3})&any(s1{3}>length(iind))
        error('Nonexistent input channel is referred to')
      end
      s0c=[s0c;iind(s1{3})];
    end
    Struct0.subs={s0c};
    if length(s1)>=4, Struct0.subs=[Struct0.subs,s1(4)]; end 
    if ~strcmp(s1{1},':')
      Struct00.type='()';
      Struct00.subs=s1(1);
      Struct0=[Struct0,Struct00];
    end
    result=subsasgn(dat,[Struct0,Struct(2:end)],rhs);
  elseif isempty(rhs) %clear samples
    if strcmp(class(dat),'fiddata'), so=get(dat,'freqn');
    else so=get(dat,'samplen');
    end
    s=Struct(1).subs{1};
    if length(Struct(1).subs)>1
      error('Cannot handle more than one indices in obj(ind)=rhs')
    end
    sr=indvgen(s,so);
    if ~isstr(sr)&(max(sr)>so)
      error('Sample index surpasses number of channels')
    end
    %
    %Now calculate complements, and execute subscripting
    if strcmp(sr,':'), src=sr; 
    elseif length(sr)<so, src=[1:so]; src(sr)=[];
    else src=[1:so];
    end
    data=get(dat,'data');
    if isnumeric(data), data(sr)=[];
    else for ii=1:prod(size(data)), data{ii}(sr)=[]; end
    end
    set(dat,'data',data,'noconsistency')
    Ref=get(dat,'Reference');
    if isnumeric(Ref), Ref(sr)=[];
    else for ii=1:prod(size(Ref)), Ref{ii}(sr)=[]; end
    end
    set(dat,'Reference',Ref,'noconsistency')
    if strcmp(class(dat),'fiddata')|strcmp(class(dat),'tiddata')
      dat=subsrloc(dat,':',':',src);
    end
    result=dat;
    if ~get(result,'consistency')
      error(sprintf(['Inconsistent result:\n  ',lastwarn]))
      %'see the warning message above for the reason'
    end
  else %subscript: obj(i)=rhs is not implemented
    error('Cannot handle subsasgn obj(i)=rhs')
  end
  return
case '{}' %Struct(1).type
  %Examples: dat{:,i2}=obj; dat{:,i2}=[]; dat{i}=[]; dat{i}.input=[1:5];
  if length(Struct)>1 %field reference follows
    if ~strcmp(Struct(2).type,'.')
      error('Second reference in object assignment is not a field')
    end
    prop=Struct(2).subs;
    prop=idpropch(dat,prop);
    if strncmpi(prop,'CovVector',6)|strncmpi(prop,'InputVariance',6)|...
        strncmpi(prop,'OutputVariance',7)|...
        strncmpi(prop,'AllVariances',4)|strncmpi(prop,'CovarianceMatrix',4)|...
        strncmpi(prop,'CohVector',6)|...
        strncmpi(prop,'NonlinCovVector',6)|strncmpi(prop,'InputNonlinError',6)|...
        strncmpi(prop,'OutputNonlinError',7)
      %Special handling of covariance data
      if length(Struct(1).subs)>=2, inde=Struct(1).subs{2}; else inde=[]; end
      result=dat;
      setloc(result,prop,rhs,Struct(1).subs{1},inde);
      cy=get(result,'consistency');
      if ~cy
        error(sprintf(['Inconsistent result:\n  ',lastwarn]))
        %'see the warning message above for the reason'
      end
      return
    end
    dati=subsref(dat,Struct(1));
    dati=subsasgn(dati,Struct(2:end),rhs);
    %This would be the key action, but it is not yet implemented
    result=subsasgn(dat,Struct(1),dati);
    return
  elseif ~strcmp(class(dat),class(rhs))&~isempty(rhs)
    error('The right side must be empty or an object of the same type')
  end
  %
  indexc=Struct(1).subs{1};
  %
  %Now execute 'delete channel' operations: dat{i}=[];
  if ~(isstr(indexc)&strcmp(indexc,':'))
    if ~isempty(rhs)
      error('When channel reference is given, the right-hand side of the assignment must be empty')
    end
    chno=get(dat,'ChNumber'); chv=1:chno;
    chin=indvgen(indexc,chno); chv(chin)=[];
    %result=dat{chv};
    Structc.subs={chv}; Structc.type='{}';
    result=subsref(dat,Structc);
    return
  end
  %
  indexe=Struct(1).subs{2};
  %Here handle the case when e is a string
  if isstr(indexe)
    indexe=getexpnos(dat,indexe);  
  end
  %
  %Now execute 'delete experiment' operations: dat{:,i}=[];
  %Number of indices is now 2
  if isempty(rhs)
    expno=get(dat,'ExpNumber'); expv=1:expno;
    expin=indvgen(indexe,expno); expv(expin)=[];
    %result=dat{:,expv};
    Structc.subs={':',expv}; Structc.type='{}';
    result=subsref(dat,Structc);
    return
  end
  %
  %Now object assignments follow: dat{:,i2}=obj; with i2 scalar
  if isempty(indexe)
    error('Experiment index is empty')
  elseif length(indexe)>1
    %error('The second index is not a scalar')
    indexe=sort(indexe);
    if any(diff(indexe)>1)
      error('Experiment subscript index does not select neighbouring experiment only')
    end
  end
  if ~isnumeric(indexe), error('The second index is not a number'), end
  if get(rhs,'ExpN')>1
    %error('The right side may contain only one experiment')
  end
  if get(dat,'chnumber')~=get(rhs,'chnumber')
    error('Channel numbers differ on the left and right hand sides')
  end
  %
  expno=get(dat,'ExpN'); expno2=get(rhs,'expnumber');
  groups=get(dat,'groups'); set(dat,'groups',[]);
  if min(indexe)>1 %insert experiment
    %result=[dat{:,1:indexe-1},rhs];
    Structc.type='{}'; Structc.subs={':',1:min(indexe)-1};
    result=merge(subsref(dat,Structc),rhs);
    if expno>max(indexe) %now add the rest of the old experiments
      %result=[result,dat{:,indexe+1:expno}];
      Structc.type='{}'; Structc.subs={':',max(indexe)+1:expno};
      result=merge(result,subsref(dat,Structc));
    end
  else %new experiment put first
    result=merge(dat,rhs); %keep fields
    Structc.type='{}'; Structc.subs={':',[expno+[1:expno2],length(indexe)+1:expno]};
    result=subsref(result,Structc);
  end
  %set(result,'groups',groups,'noconsistency') %error 
  result.NewProperties.Groups_Synchronized=groups.Groups_Synchronized;
  result.NewProperties.Groups_Delayed=groups.Groups_Delayed;
  result.NewProperties.Groups_SamePower=groups.Groups_SamePower;
  result.NewProperties.Groups_FullMIMO=groups.Groups_FullMIMO;
  gnames=groupnames(dat,'ExperimentName'); gnames=gnames(indexe,:);
  inde=[max(indexe)+1:expno]';
  fixgroups(result,[gnames;{'ExperimentName',[[inde],[expno2-length(indexe)+inde]]}]);
  fixgroups(rhs,{'ExperimentName',[[1:expno2]',min(indexe)-1+[1:expno2]']},'renumber');
  groups2=get(rhs,'Groups_Synchronized');
  for ii=1:size(groups2,1)
    addgroup(result,'Groups_Synchronized',groups2{ii,1},groups2{ii,2})
  end %for ii
  return
otherwise
  error(['Unknown type: ' Struct(1).type])
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
if ~isstr(iv)&(any(iv>maxi)), error('Too large index generated'), end
%end of indvgen

% end of file @iddat/subsasgn.m
