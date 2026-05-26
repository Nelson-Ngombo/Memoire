function Out = merge(varargin)
%MERGE  Unify two experiment sets
%       The first object dominates (e.g. Name)
%       The channels are concatenated if they have the same (maybe empty) names,
%       and they are assumed to be different of their names are different.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Dec-2003

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
Out=varargin{1};
if length(varargin)==1, return, end
if length(varargin)==2
  if isempty(varargin{2}), return, end
  if isempty(varargin{1}), Out=varargin{2}; return, end
end
%
for iivn=2:length(varargin)
  dat2=varargin{iivn};
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments should be objects of the same class')
  end
  if strcmp(class(Out),'fiddata')
    if iivn==2
      Out=fiddata(struct(Out));
      tmp=fiddata; 
      %set(Out,'Version',tmp.Version,'noconsistency');
      Out.Version=tmp.Version;
    end
  else
    error('Class is not fiddata')
  end
  
  %Now add children properties
  if Out.Version~=dat2.Version
    error('Versions of fiddata objects differ')
  end
  chno=get(Out,'ChNumber'); chno2=get(dat2,'ChNumber');
  %if chno~=chno2, error('Channel numbers differ'), end
  expno1=get(Out,'ExpNumber'); expno2=get(dat2,'ExpNumber');
  %
  [Out.iddat,chind2]=merge(Out.iddat,dat2.iddat);
  %
  fs1=Out.Fs; fs2=dat2.Fs;
  if isempty(fs1), Out.Fs=fs2;
    if ~isempty(fs2), warning('Fs taken from object2'), end
  elseif ~isempty(fs2)
    if fs1~=fs2, error('Sampling frequencies differ in objects'), end
  end
  %
  afp1=Out.AllFreqPoints; afp2=dat2.AllFreqPoints;
  fi1=Out.FreqIndices; fi2=dat2.FreqIndices;
  if isequal(afp1,afp2)&~iscell(afp1)
    %AllFreqPoints is OK
    if isequal(fi1,fi2)&isnumeric(fi1)
      %OK, nothing to do
    else
      %Concatenate FreqIndices
      if ~iscell(fi1), fi1={fi1}; end
      if ~iscell(fi2), fi2={fi2}; end  
      fi=cell(get(Out,'chnumber'),expno1+expno2);
      %
      for ii=size(fi1,1)+1:chno, fi1=[fi1;fi1(1,:)]; end
      for ii=size(fi1,2)+1:expno1, fi1=[fi1,fi1(:,1)]; end
      fi(1:chno,1:expno1)=fi1;
      if ~iscell(fi2), fi2={fi2}; end
      for ii=size(fi2,1)+1:chno, fi2=[fi2;fi2(1,:)]; end
      for ii=size(fi2,2)+1:expno2, fi2=[fi2,fi2(:,1)]; end
      while size(fi2,1)<size(fi,1), fi2=[fi2;cell(1,size(fi2,2))]; end
      fi(chind2,expno1+[1:expno2])=fi2;
      %
      Out.FreqIndices=fi;
    end
    afpOK=1;
  else %different frequencies
    if ~iscell(afp1), afp1={afp1}; end
    if ~iscell(fi1), fi1={fi1}; end      
    if ~iscell(afp2), afp2={afp2}; end
    if ~iscell(fi2), fi2={fi2}; end      
    if (size(fi1,1)==1)&(size(fi2,1)>1)
      fi1s=fi1;
      for ii=2:size(fi2,1), fi1=[fi1;fi1s]; end
    end
    if (size(fi2,1)==1)&(size(fi1,1)>1)
      fi2s=fi2;
      for ii=2:size(fi1,1), fi2=[fi2;fi2s]; end
    end
    while get(Out,'chnumber')>size(fi1,1), fi1=[fi1;cell(1,size(fi1,2))]; end
    while get(Out,'chnumber')>size(fi2,1), fi2=[fi2;cell(1,size(fi2,2))]; end, fi2=fi2(chind2,:);
    if (size(fi1,2)==1)&(expno1>1)
      fi1s=fi1;
      for ii=2:expno1, fi1=[fi1,fi1s]; end
    end
    if (size(fi2,2)==1)&(expno2>1)
      fi2s=fi2;
      for ii=2:expno2, fi2=[fi2,fi2s]; end
    end
    if (size(afp1,2)==1)&(expno1>1)
      afp1s=afp1;
      for ii=2:expno1, afp1=[afp1,afp1s]; end
    end
    if (size(afp2,2)==1)&(expno2>1)
      afp2s=afp2;
      for ii=2:expno2, afp2=[afp2,afp2s]; end
    end
    Out.AllFreqPoints=[afp1,afp2];
    Out.FreqIndices=[fi1,fi2];
    afpOK=1;
  end
  %
  delays1=Out.Delays; delays2=dat2.Delays;
  if isempty(delays1)&isempty(delays2) %nothing to do
  else
    delays=cell(chno,expno1+expno2);
    if ~iscell(delays1), delays1={delays1}; end
    for ii=size(delays1,1)+1:chno, delays1=[delays1;delays1(1,:)]; end
    for ii=size(delays1,2)+1:expno1, delays1=[delays1,delays1(:,1)]; end
    delays(1:chno,1:expno1)=delays1;
    if ~iscell(delays2), delays2={delays2}; end
    for ii=size(delays2,1)+1:chno, delays2=[delays2;delays2(1,:)]; end
    for ii=size(delays2,2)+1:expno2, delays2=[delays2,delays2(:,1)]; end
    delays(1:chno,expno1+[1:expno2])=delays2;
    %set(Out,'Delays',delays,'noconsistency')
    Out.Delays=delays;
  end
  %
  %Covariance, Coherence
  lc2=max(chind2); 
  for ivh=1:2
    if ivh==1, cov1=Out.Covariance; cov2=dat2.Covariance;
    elseif ivh==2, cov1=Out.Coherence; cov2=dat2.Coherence;
    end
    if isnumeric(cov1)&isequal(cov1,cov2) %nothing to do
    else
      if ~isempty(cov1)
        if isnumeric(cov1), cov1={cov1}; end
        lc=size(cov1{1},1);
        if lc2>lc
          for ii=1:length(cov1)
            cov1{ii}(lc2,lc2,1)=NaN;
            cov1{ii}(lc+1:lc2,:,:)=NaN*cov1{ii}(lc+1:lc2,:,:);
            cov1{ii}(:,lc+1:lc2,:)=NaN*cov1{ii}(:,lc+1:lc2,:);
          end
        end
        %if length(cov1)==1, cov1=cov1{1}; end
      end
      if ~isempty(cov2)
        if isnumeric(cov2), cov2={cov2}; end
        for ii=1:length(cov2)
          cov2ii=NaN*ones(lc2,lc2,size(cov2{ii},3));
        cov2ii(chind2(1:size(cov2{ii},1)),chind2(1:size(cov2{ii},1)),:)=cov2{ii};
        cov2{ii}=cov2ii;
        end
        %if length(cov2)==1, cov2=cov2{1}; end
      end
      if isequal(cov1,cov2)&(length(cov1)<=1) %do nothing else
      elseif isequalnan(cov1,cov2)&(length(cov1)<=1) %do nothing else
      elseif isempty(cov2)&~isempty(cov1)
        if ~iscell(cov1), cov1={cov1}; end
        cove={NaN*zeros(size(cov1{1}))};
        while length(cov1)<expno1, cov1=[cov1,cove]; end
        if ~iscell(cov2), cov2={cov2}; end
        %cove={[]};
        while length(cov2)<expno2, cov2=[cov2,cove]; end
        cov1=[cov1,cov2];
      elseif isempty(cov1)&~isempty(cov2)
        if ~iscell(cov2), cov2={cov2}; end
        cove={zeros(size(cov2{1}))};
        while length(cov2)<expno2, cov2=[cov2,cove]; end
        if ~iscell(cov1), cov1={cov1}; end
        %cove={[]};
        while length(cov1)<expno1, cov1=[cov1,cove]; end
        cov1=[cov1,cov2];
      else %Complicated setting
        if ~iscell(cov1), cov1={cov1}; end
        while get(varargin{1},'expnumber')>length(cov1), cov1=[cov1,cov1(1)]; end
        if ~iscell(cov2), cov2={cov2}; end
        while get(dat2,'expnumber')>length(cov2), cov2=[cov2,cov2(1)]; end
        cov1=[cov1,cov2];
      end
    end
    if ivh==1
      M1=get(Out,'M'); M2=get(dat2,'M');
      if isempty(M1)&isempty(M2), MM=[];
      elseif isequal(M1,M2), MM=M1;
      else
        if length(M1)==1, M1=M1*ones(1,expno1); end
        if length(M2)==1, M2=M2*ones(1,expno2); end
        MM=[M1,M2];
      end
    end  
    if ivh==1, set(Out,'Covariance',cov1,'M',MM,'noconsistency');
    elseif ivh==2, set(Out,'Coherence',cov1,'noconsistency');
    end
  end %for 1:2
  %Ref1=get(Out,'Reference'); Ref2=get(dat2,'Reference');
  %if isempty(Ref1)&isempty(Ref2)
  %  Ref=[];
  %elseif isnumeric(Ref1)&isnumeric(Ref2)&isequal(Ref1,Ref2)
  %  Ref={Ref1,Ref2};
  %else
  %  if ~iscell(Ref1), Ref1={Ref1}; end
  %  if ~iscell(Ref2), Ref2={Ref2}; end
  %  Ref=[Ref1,Ref2];
  %end
  %set(Out,'Reference',Ref,'noconsistency')
  %
end %for iivn
%
if ~get(Out,'consistency')
  error('Inconsistent object is generated: see the warning message above for the reason')
end
%
% end of function @fiddata/merge

function Out=isequalnan(d1,d2)
%isequal, but discard NaN's
if ~strcmp(class(d1),class(d2)), Out=0; return, end
if ~isequal(size(d1),size(d2)), Out=0; return, end
if isnumeric(d1), d1={d1}; d2={d2}; end
for ii=1:length(d1(:))
  d1d=d1{ii}; d2d=d2{ii};
  ind1=find(isnan(d1d)); ind2=find(isnan(d2d));
  if ~isequal(ind1,ind2), Out=0; return, end
  if ~isempty(ind1)
    d1d(ind1)=zeros(size(ind1)); d2d(ind2)=zeros(size(ind2)); 
  end
  if ~isequal(d1d,d2d), Out=0; return, end
end
Out=1;
% end of file @fiddata/merge