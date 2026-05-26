function [Out,chind2] = merge(varargin)
%MERGE  Unify two experiment sets
%
%       [Out,chind2] = merge(obj1,obj2)
%
%       The first object dominates (e.g. Name)
%       Either the channel numbers and types should match, or the channel names
%       should be given. Non-names channels beside names ones will be
%       separate.
%       chind2 gives the new positions of the channels of obj2

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Sep-2003

ni = nargin;
no = nargout;
chind2={}; %positions of the channels of obj2 in the merged object
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
Out=varargin{1}; chno=get(Out,'chnumber');
if length(varargin)==1, return, end

for ii=1:length(varargin)-1
  dat2=varargin{ii+1};
  remname={}; remname2={};
  de=get(Out,'expnumber');
  de2=get(dat2,'expnumber');
  if (de>0)&(de2>0)
    remname=[remname;{'ExperimentName'}];
    remname2=[remname2;{[[1:de2]',de+[1:de2]']}];
  end
  %
  groups=get(Out,'groups'); groups2=get(dat2,'groups');
  ds=size(groups.Groups_Synchronized,1);
  ds2=size(groups2.Groups_Synchronized,1);
  if (ds>0)&(ds2>0)
    remname=[remname;{'Groups_Synchronized'}];
    remname2=[remname2;{[[1:ds2]',ds+[1:ds2]']}];
  end
  dd=size(groups.Groups_Delayed,1);
  dd2=size(groups2.Groups_Delayed,1);
  if (dd>0)&(dd2>0)
    remname=[remname;{'Groups_Delayed'}];
    remname2=[remname2;{[[1:dd2]',dd+[1:dd2]']}];
  end
  dm=size(groups.Groups_FullMIMO,1);
  dm2=size(groups2.Groups_FullMIMO,1);
  if (dm>0)&(dm2>0)
    remname=[remname;{'Groups_FullMIMO'}];
    remname2=[remname2;{[[1:dm2]',dm+[1:dm2]']}];
  end
  dp=size(groups.Groups_SamePower,1);
  dp2=size(groups2.Groups_SamePower,1);
  if (dp>0)&(dp2>0)
    remname=[remname;{'Groups_SamePower'}];
    remname2=[remname2;{[[1:dp2]',dp+[1:dp2]']}];
  end
  fixgroups(dat2,[remname,remname2],'renumber')
  groups2=get(dat2,'groups');
  groups.Groups_Synchronized=[groups.Groups_Synchronized;groups2.Groups_Synchronized];
  groups.Groups_Delayed=[groups.Groups_Delayed;groups2.Groups_Delayed];
  groups.Groups_FullMIMO=[groups.Groups_FullMIMO;groups2.Groups_FullMIMO];
  groups.Groups_SamePower=[groups.Groups_SamePower;groups2.Groups_SamePower];
  %
  gn=groupnames(Out,'ExperimentName'); gn=gn(:,1);
  gn2=groupnames(dat2,'ExperimentName'); gn2=gn2(:,1);
  for ig=1:size(gn,1)
    if ~isempty(gn{ig})
      if any(findstr(gn{ig},gn2))
        error(['Repeated experiment name ''',gn{ig},''''])
      end
    end
  end
  gn=groupnames(Out); if ~isempty(gn), gn=gn(:,1); end
  gn2=groupnames(dat2); if ~isempty(gn2), gn2=gn2(:,1); end
  for ig=1:size(gn,1)
    if ~isempty(gn{ig})
      if any(findstr(gn{ig},gn2))
        error(['Repeated group name ''',gn{ig},''''])
      end
    end
  end
  %
  if ii==1, chind2=cell(1,length(varargin)-1); end
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments must be objects of the same class')
  end
  if strcmp(class(Out),'iddat')
    if ii==1, Out=iddat(struct(Out)); end
  else
    error('Class is not iddat')
  end
  %Name, UserData stays that of Out
  dtmp=iddat; Out.Date=dtmp.Date; Out.Version=dtmp.Version;
  Out.Notes=''; Out.Instrumentation=[];
  addhist(Out,'Addition of different experiments in two objects')
  %
  en1=get(Out,'ExperimentName'); EN1=get(Out,'Expn');
  en2=get(dat2,'ExperimentName'); EN2=get(dat2,'Expn');
  if isempty(en1)&isempty(en2) %nothing to do
  else
    en1s=cell(1,EN1);
    if iscell(en1), en1s=en1; 
    elseif isstr(en1)&(EN1==1), en1s={en1};
    end
    en2s=cell(1,EN2);
    if iscell(en2), en2s=en2; 
    elseif isstr(en2)&(EN2==1), en2s={en2};
    end
    set(Out,'ExperimentName',[en1s,en2s],'noconsistency')
  end
  %
  cn1=Out.Names; cn2=dat2.Names;
  cht1=Out.ChTypes; cht2=dat2.ChTypes;
  if isempty(cht1)&isempty(cht2)
    warning('Addition of two empty objects')
  end
  if (isempty(cat(2,cn1{:}))&isempty(cat(2,cn2{:}))) | ...
      isequal(cn1,cn2)
    %channel names are the same
    if (isempty(cht1)&~isempty(cht2)) | (isempty(cht2)&~isempty(cht1))
      error('Incompatible channel numbers')
    elseif ~isempty(cht1)&~isempty(cht2)&~isequal(cht1,cht2)
      error('Channel types are not the same in the two objects')
    end
    %Now this is OK
    chind2{ii}=1:get(Out,'chnumber');
  else %channel names need housekeeping
    chind1=[1:size(cn1,1)]';
    for iich=1:size(cn2,1)
      chni=cn2{iich}; ind=[];
      if ~isempty(chni)
        ind=strmatch(chni,cn1,'exact');
        for iii=length(ind):-1:1
          if ~isequal(cht1(ind(iii)),cht2(iich)), ind(iii)=[]; end
        end
      end
      if isempty(ind), ind=max(length(chind1),max([chind2{ii};[1:chno]';0]))+1; end
      chind2{1,ii}=[chind2{1,ii};ind];
    end
    %
    %Now generate empty channels in obj1 if necessary
    for iiemp=1+length(chind1):max([chind2{ii};[1:chno]';0])
      i2=find(chind2{ii}==iiemp);
      if isequal(cht2(i2),'o'+0)
        obj=fiddata({zeros(0,1)},[],[],[],[],[],cn2(i2));
        objs=struct(obj); objid=objs.iddat;  
      elseif isequal(cht2(i2),'i'+0)
        obj=fiddata([],{zeros(0,1)},[],[],[],[],'',cn2(i2));
        objs=struct(obj); objid=objs.iddat;  
      else
        error('Invalid chtype')
      end
      Out=[Out;objid]; chind1=[chind1;max(chind1)+1];
    end %for iiemp
    %
    %Now generate empty channels in obj2 if necessary
    ind2=chind2{ii}; %positions where obj2 has channels
    i2all=find(~ismember(chind1,chind2{ii}));
    for iiemp2=1:(length(chind1)-length(chind2{ii}))
      i2=i2all(iiemp2);
      if isequal(cht1(i2),'o'+0)
        obj=fiddata({zeros(0,1)},[],[],[],[],[],cn1(i2));
        objs=struct(obj); objid=objs.iddat;  
      elseif isequal(cht2(i2),'i'+0)
        obj=fiddata([],{zeros(0,1)},[],[],[],[],'',cn1(i2));
        objs=struct(obj); objid=objs.iddat;  
      else
        error('Invalid chtype')
      end
      dat2=[dat2;objid];
      chind2{ii}=[chind2{ii};i2];
    end %for iiemp2
    if any(diff(chind2{ii})<0)
      Struct.type='{}';
      [dummy,chind2r]=sort(chind2{ii});
      Struct.subs={chind2r,':'};
      dat2=subsref(dat2,Struct);
    end
  end %channel names given
  %
  
  %if compcell(cn1,cn2), error('Different channel names'), end
  %Out.Names=cn1;
  %
  Data1=Out.Data; Data2=dat2.Data;
  if ~iscell(Data1)&~isempty(Data1), Data1={Data1}; end
  if ~iscell(Data2)&~isempty(Data2), Data2={Data2}; end
  if iscell(Data1)&iscell(Data2)
    if size(Data1,1)~=size(Data2,1)
      %error('Different numbers of channels')
    end
  end
  %
  chn1=length(Out.ChTypes); chn2=length(dat2.ChTypes);
  %
  sc1=Out.Scales; sc2=dat2.Scales;
  if isempty(sc1)&(chn1>0)&~isempty(sc2), sc1=ones(chn1,1); end
  if isempty(sc2)&(chn2>0)&~isempty(sc1), sc2=ones(chn2,1); end
  if isempty(sc1) %done
  elseif isequal(sc1,sc2)
    if iscell(sc1)&(size(sc1,2)>1)
      alleq=1;
      for iitmp=2:size(sc1,2)
        if ~isequal(sc1{:,1},sc1{:,iitmp}), alleq=0; break, end
      end
      if alleq==1, sc1=sc1(:,1); end
      if length(sc1)==1, sc1=sc1{1}; end
    end
    Out.Scales=sc1;
  else %no other way than to multiply data by scales
    for iitmp=1:size(Data1,1)
      for iii=1:size(Data1,2)
        Data1{iitmp,iii}=sc1*Data1{iitmp,iii};
      end
    end
    for iitmp=1:size(Data2,1)
      for iii=1:size(Data2,2)
        Data2{iitmp,iii}=sc2*Data2{iitmp,iii};
      end
    end
  end
  %
  Data=[Data1,cell(size(Data1,1),EN2)];
  Data(:,size(Data1,2)+1:end)=Data2;
  %
  if length(Data)==1, Data=Data{1}; end
  Out.Data=Data;
  cu1=Out.Units; cu2=dat2.Units;
  if ~isempty(cu1)
    if compcell(cu1(chind2{ii}),cu2), error('Different channel units'), end
  end
  %
  Ref1=get(Out,'Reference'); Ref2=get(dat2,'Reference'); 
  if isempty(Ref1)&isempty(Ref2), Ref=[];
  else
    if isnumeric(Ref1)&isnumeric(Ref2)&isequal(Ref1,Ref2), Ref=[];
    elseif iscell(Ref1)&iscell(Ref2)&(size(Ref1,2)==1)&isequal(Ref1,Ref2), Ref=[];
    else
      if ~iscell(Ref1), Ref1={Ref1}; end
      while size(Ref1,1)<get(Out,'inputchnumber'), Ref1=[Ref1;Ref1(1,:)]; end
      while size(Ref1,2)<size(Data1,2), Ref1=[Ref1,Ref1(:,1)]; end
      if ~iscell(Ref2), Ref2={Ref2}; end
      while size(Ref2,1)<get(dat2,'inputchnumber'), Ref2=[Ref2;Ref2(1,:)]; end
      while size(Ref2,2)<size(Data2,2), Ref2=[Ref2,Ref2(:,1)]; end
      set(Out,'Reference',[Ref1,Ref2],'noconsistency')  
    end
  end
  %
  cch1=Out.Characters; if ~iscell(cch1), cch1={cch1}; end
  cch2=dat2.Characters; if ~iscell(cch2), cch2={cch2}; end
  for iitmp=1:length(cch1)
    if strcmpi(cch1{iitmp},'AASamples'), cch1{iitmp}='BL'; end
  end
  for iitmp=1:length(cch2)
    if strcmpi(cch2{iitmp},'AASamples'), cch2{iitmp}='BL'; end
  end
  if compcell(cch1(chind2{ii}),cch2), error('Different channel characters'), end
  %set(Out,'Characters',cch1,'noconsistency');
  Out.Characters=cch1;
  %
  pl1=Out.PeriodLength; pl2=dat2.PeriodLength;
  fr1=Out.Frequencies; fr2=dat2.Frequencies; 
  if isempty(pl1)|isempty(pl2), pl=[]; 
  elseif any([isnan(pl1),isnan(pl2)]), pl=NaN;
  elseif any(~isfinite([pl1,pl2])), pl=inf;
  elseif pl1==pl2, pl=pl1;
  elseif any([1:100]*pl1==pl2), pl=pl2;
  elseif any([1:100]*pl2==pl1), pl=pl1;  
  elseif ~isempty(fr1)&~isempty(fr2), pl=NaN;
  else pl=Inf;
  end
  %set(Out,'PeriodLength',pl,'noconsistency');
  Out.PeriodLength=pl;
  %
  %Frequencies still to be checked
  %set(Out,'Frequencies',fr1,'noconsistency');
  Out.Frequencies=fr1;
  %
  st1=Out.State; st2=dat2.State;
  if isempty(st1)|isempty(st2), st='';
  elseif strcmp(st1,'transient')|strcmp(st2,'transient'), st='transient';
  else st='steady-state';
  end
  %set(Out,'State',st,'noconsistency');
  Out.State=st;
  sy1=Out.Synchronization; sy2=dat2.Synchronization;
  if isempty(sy1)|isempty(sy2), sy='';
  elseif strcmp(st1,'off')|strcmp(st2,'off'), st='off';
  else sy='on';
  end
  set(Out,'Synchronization',sy,'noconsistency');
  set(Out,'groups',groups,'noconsistency')
end %for ii
%
if length(chind2)==1, chind2=chind2{1}; end
%
%Consistency is checked in children functions
%if ~get(Out,'consistency')
%  error('Something is wrong with merge')
%end
%
% end of function @iddat/merge


function cdiff=compcell(c1,c2)
if nargin<3, chno=length(c1); end
cdiff=0;
for ii=1:chno
  if ~isempty(c1)&~isempty(c2)
    if iscell(c1)&iscell(c2)
      if ~strcmp(c1{ii},c2{ii})&~isempty(c1{ii})&~isempty(c2{ii}), cdiff=1; end
    elseif isstr(c1)&isstr(c2)
      if ~strcmp(c1,c2)&~isempty(c1)&~isempty(c2), cdiff=1; end
    elseif ~strcmp(class(c1),class(c2))
      cdiff=1;
    end
  end
end %for ii
%
%end @iddat/merge.m
