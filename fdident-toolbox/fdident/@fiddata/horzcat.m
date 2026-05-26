function Out = horzcat(varargin)
%HORZCAT  Unify two experiment sets
%       [dat1 dat2] ...
%       The first object dominates (e.g. Name)
%
%       See also: @iddat/horzcat, @fiddata/vertcat

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Aug-2001

%warning('fiddata/[] has been called (horzcat)')
error('This call is obsolete now. Use merge(obj1,obj2) instead.')

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
if length(varargin)==1, Out=varargin{1}; return, end

Out=varargin{1};
for iivn=2:length(varargin)
  dat2=varargin{iivn};
  
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments should be objects of the same class')
  end
  if strcmp(class(Out),'fiddata')
    if iivn==2
      Out=fiddata(struct(Out));
      tmp=fiddata; Out.Version=tmp.Version;
    end
  else
    error('Class is not fiddata')
  end
  
  %Now add children properties
  if Out.Version~=dat2.Version
    error('Versions of fiddata objects differ')
  end
  chno=get(Out,'ChNumber'); chno2=get(dat2,'ChNumber');
  if chno~=chno2, error('Channel numbers differ'), end
  expno1=get(Out,'ExpNumber'); expno2=get(dat2,'ExpNumber');
  %
  Out.iddat=horzcat(Out.iddat,dat2.iddat);
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
  if isequal(afp1,afp2)
    %AllFreqPoints is OK
    if isequal(fi1,fi2)&...
        ( ~iscell(fi1)|((size(fi1,1)==1)&(size(fi2,1)==1)) )
      %FreqIndices is also OK
    else
      %Concatenate FreqIndices
      fi=cell(chno,expno1+expno2);
      %
      if ~iscell(fi1), fi1={fi1}; end
      for ii=size(fi1,1)+1:chno, fi1=[fi1;fi1(1,:)]; end
      for ii=size(fi1,2)+1:expno1, fi1=[fi1,fi1(:,1)]; end
      fi(1:chno,1:expno1)=fi1;
      if ~iscell(fi2), fi2={fi2}; end
      for ii=size(fi2,1)+1:chno, fi2=[fi2;fi2(1,:)]; end
      for ii=size(fi2,2)+1:expno2, fi2=[fi2,fi2(:,1)]; end
      fi(1:chno,expno1+[1:expno2])=fi2;
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
    Out.AllFreqPoints=[afp1,afp2]; Out.FreqIndices=[fi1,fi2];
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
  end
  %
  for ivh=1:2
    if ivh==1, cov1=Out.Covariance; cov2=dat2.Covariance;
    elseif ivh==2, cov1=Out.Coherence; cov2=dat2.Coherence;
    end
    if isequal(cov1,cov2) %do nothing
    elseif isequalnan(cov1,cov2) %do nothing
    elseif isempty(cov2) %do nothing
    elseif isempty(cov1)
      if ivh==1, Out.Covariance=cov2;
        warning('Covariance taken from object2')
      elseif ivh==2, Out.Coherence=cov2;
        warning('Coherence taken from object2')
      end
    else %Complicated setting
      if ~iscell(cov1), cov1={cov1}; end
      if ~iscell(cov2), cov2={cov2}; end
      cov1=[cov1,cov2];
      if ivh==1, Out.Covariance=cov1;
      elseif ivh==2, Out.Coherence=cov1;
      end
    end
  end %for 1:2
  %
end %for iivn
%
if ~get(Out,'consistency')
  error('Inconsistent object is generated: see the warning message above for the reason')
end
%
% end of function @fiddata/horzcat

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
% end of file @fiddata/horzcat