function Out = collapse(dat,expi)
%COLLAPSE  Reduce size of fiddata object by combining experiments
%       The reduced result is in place of the first selected experiment
%
%       See also: varanal

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Apr-2004

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
expno=get(dat,'ExpNumber');
if ni<2, expi=[]; end
if isstr(expi) %handle ':' or 'end'
  if strcmp(expi,':')
    expi=[];
  else
    ind=findstr(expi,'end');
    if length(ind)~=1, error('Illegal expi'), end
    expi=[expi(1:ind+2),'val',expi(ind+3:end)]; endval=expno;
    expi=eval(expi);
  end
end
if isempty(expi), expi=1:expno;
else expi=expi(:);
end
combine=1;
if (length(expi)>1)&~strcmp(get(dat,'Synchronization'),'on')
  %warning('Nonsynchronized case: simply unify experiments')
  combine=0;  
elseif isempty(expi)
  error('No experiment is selected')
end
%
fp=get(dat,'FreqPoints');
if iscell(fp)&(combine==1)
  alleq=1;
  for ii=1:size(fp,1)
    for iii=1:size(fp,2)
      if iii==1, fp1=fp{ii,iii};
      elseif ~isequal(fp1,fp{ii,iii})
        alleq=0; break
      end
    end %for iii
  end %for ii
  if alleq==0
    error('Frequency vectors are not equal in all experiments')
  end
end
%
cov=dat.Covariance;
if combine==1 %call varanal
  if ~isempty(cov)
    warning('cov is given, but varanal will be used')
  end
  if iscell(fp)&(length(fp)>1)
    OK=1; fp1=fp{1};
    for ii=1:length(fpi)
      if ~isequal(fp1,fp{ii}), OK=0; break, end
    end
    if OK==0
      error('Cannot use varanal on different frequency grids')
    end
  end
  if (length(expi)==expno)&(expno>1)
    Out=varanal(dat);
    return
  elseif length(expi)>1
    datr=varanal(dat{:,expi});
    Out=dat;
    Out(expi(2:end))=[];
    Out(expi(1))=datr;
    return
  else
    error('Cannot call varanal on just one experiment')
  end
end
%
%Now covariance is given: 'real' reduction with variance weighting follows
%combine=1 means combination; combine=0 means simple copying
%
if ( (iscell(fp)&(size(fp,1)==1))|~iscell(fp) ) & (combine==1)
  %same frequencies for each experiment: combine
  %warning('Not yet ready')
  %Result in datr
  Out=dat;
  Out{:,expi(2:end)}=[];
  Out{:,expi(1)}=datr;
  return
end
%
if combine==1
  error('Cannot combine experiments: programming error')
else %combine=0: collect experiments together
  u=get(dat,'input');
  y=get(dat,'output');
  r=get(dat,'referencedata');
  fv=get(dat,'freqpoints'); if ~iscell(fv), fv={fv}; end
  expno=get(dat,'expn');
  while size(fv,2)<expno, fv=[fv,fv(:,1)]; end
  for ii=2:expno
    for iii=1:min(get(dat,'chn'),size(fv,1))
      fv{iii,1}=[fv{iii,1};fv{iii,ii}];
    end
  end
  fv=fv(:,1); if length(fv)==1, fv=fv{1}; end
  covs=get(dat,'covariance');
  if isnumeric(covs)&~isempty(covs)&(expno>1)
    covs={covs};
    for ii=2:expno
      covs=[covs,covs(1)];  
    end %ii
  end
  if iscell(covs), covs=cat(3,covs{:}); end
  Out=dat;
  set(Out,'input',cat(1,u{:}),'output',cat(1,y{:}),'freqpoints',fv,...
    'noconsistency')
  if ~isequal(Out.Covariance,covs)
    %covs=cat(3,Out.Covariance,covs);
    if ~isempty(r), set(Out,'referencedata',cat(1,r{:}),'Covariance',covs)
    else Out.Covariance=covs;
    end
  else 
    if ~isempty(r), set(Out,'referencedata',cat(1,r{:}),'noconsistency'), end
    get(Out,'consistency');
  end
end
%
% end of function @fiddata/collapse
