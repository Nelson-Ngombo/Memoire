function Out = vertcat(varargin)
%VERTCAT  Unify data by adding channels
%       [dat1 ; dat2] ...
%       The first object dominates (e.g. Name)
%
%       See also: @iddat/vertcat, @fiddata/horzcat

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Aug-2001

%warning('fiddata/[] has been called (vertcat)')
error('This call is obsolete now. Use addchannels(obj1,obj2) instead.')

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
  chno1=get(Out,'ChNumber'); chno2=get(dat2,'ChNumber');
  freqno1=get(Out,'FreqNumber'); freqno2=get(dat2,'FreqNumber');
  expno=get(Out,'ExpNumber'); expno2=get(dat2,'ExpNumber');
  if expno~=expno2, error('Experiment numbers differ'), end
  %
  Out.iddat=vertcat(Out.iddat,dat2.iddat);
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
    afpOK=1;
    %AllFreqPoints is OK
    if isequal(fi1,fi2)&(size(fi1,1)==1)&(size(fi2,1)==1)&~iscell(fi1)
      %FreqIndices is also OK
    else
      %Concatenate FreqIndices
      fi=cell(chno1+chno2,expno);
      %
      if ~iscell(fi1), fi1={fi1}; end
      for ii=size(fi1,1)+1:chno1, fi1=[fi1;fi1(1,:)]; end
      for ii=size(fi1,2)+1:expno, fi1=[fi1,fi1(:,1)]; end
      fi(1:chno1,1:expno)=fi1;
      if ~iscell(fi2), fi2={fi2}; end
      for ii=size(fi2,1)+1:chno2, fi2=[fi2;fi2(1,:)]; end
      for ii=size(fi2,2)+1:expno, fi2=[fi2,fi2(:,1)]; end
      fi(chno1+[1:chno2],1:expno)=fi2;
      %
      Out.FreqIndices=fi;
    end
  else %different frequencies
    afpOK=0;
    error('Concatenation with different frequencies is not yet ready')
    %Probably set frequencies again
  end
  %
  delays1=Out.Delays; delays2=dat2.Delays;
  if isempty(delays1)&isempty(delays2) %nothing to do
  else
    delays=cell(chno1+chno2,expno);
    if ~iscell(delays1), delays1={delays1}; end
    for ii=size(delays1,1)+1:chno1, delays1=[delays1;delays1(1,:)]; end
    for ii=size(delays1,2)+1:expno, delays1=[delays1,delays1(:,1)]; end
    delays(1:chno1,1:expno)=delays1;
    if ~iscell(delays2), delays2={delays2}; end
    for ii=size(delays2,1)+1:chno2, delays2=[delays2;delays2(1,:)]; end
    for ii=size(delays2,2)+1:expno, delays2=[delays2,delays2(:,1)]; end
    delays(chno1+[1:chno2],1:expno)=delays2;
  end
  %
  for ivh=1:2
    if ivh==1, cov1=Out.Covariance; cov2=dat2.Covariance;
    elseif ivh==2, cov1=Out.Coherence; cov2=dat2.Coherence;
    end
    if afpOK==1
      if isempty(cov1)&isempty(cov2) %do nothing
      else %something is given
        NaNv=NaN;
        if isempty(cov1)
          %fix cov1
          cov1=NaNv(ones(chno1,chno1,freqno1));
        elseif isempty(cov2)
          %fix cov2
          cov2=NaNv(ones(chno2,chno2,freqno2));
        end
        cov12=NaNv(ones(chno1+chno2,chno1+chno2,freqno1));
        cov12(1:chno1,1:chno1,1:freqno1)=cov1;
        cov12(chno1+[1:chno2],chno1+[1:chno2],1:freqno2)=cov2;
        if ivh==1, Out.Covariance=cov12;
        elseif ivh==2, Out.Coherence=cov12;
        end
      end
    else %Complicated setting: different excitation frequencies
      error('Complicated combination of cov''s not yet ready')
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
% end of function @fiddata/vertcat

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
% end of file @fiddata/vertcat