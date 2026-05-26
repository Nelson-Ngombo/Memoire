function Out = getconsy(dat)
%GETCONSY  Check consistency of special tiddata properties

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Aug-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if ~isa(dat,'tiddata'), error('class is not ''tiddata'''), end
%
if (dat.Version~=1.3)
  if (dat.Version<1.3)
    Out=0; warning(sprintf('Old version of tiddata: %.4g',dat.Version)), return
  else
    Out=0; warning(sprintf('Too new version of tiddata: %.4g',dat.Version)), return
  end
end
%
Out=1;
%
ts=dat.Ts;
tst=dat.TStart;
st=dat.SampleTimes;
%
%Starting times: check sizes
if ~isempty(tst)
  if iscell(tst)
    [s1,s2]=size(tst);
    if all(s1~=[1,get(dat,'ChN')]), Out=0; warning('TStart size 1 mismatch'), return, end
    if all(s2~=[1,get(dat,'ExpN')]), Out=0; warning('TStart size 2 mismatch'), return, end
    for i1=1:s1
      for i2=length(s2)
        if isempty(tst{s1,s2}), Out=0; warning('An element of TStart is empty'), return, end
      end
    end
  elseif isnumeric(tst)
    if length(tst)>1, Out=0; warning('tst is not a scalar'), return, end  
  else
    Out=0; warning('Wrong type of TStart'), return
  end
end
%
%SamplingInstants
if ~isempty(st)
  N=get(dat,'SampleNumber');
  if isnumeric(N)
    if isnumeric(st)
      if length(st)~=N, Out=0; warning('SamplingInstants is wrong'), return, end
    elseif iscell(st)
      for ii=1:prod(size(st))
        if length(st{ii})~=N
          Out=0; warning('SamplingInstants is wrong'), return
        end
      end %for ii
    end
  end
end
%compare to ts
if ~isempty(ts)&~isempty(st)
  if isnumeric(ts), i11=1; i12=1;
  elseif iscell(ts), [i11,i12]=size(ts); 
  end
  if isnumeric(st), i21=1; i22=1;
  elseif iscell(st), [i21,i22]=size(st); 
  end
  for ii=1:max(i11,i21)
    for iii=1:max(i12,i22)
      if isnumeric(ts), tsi=ts;
      else tsi=ts{max(i11,ii),max(i12,iii)};
      end
      %tsi=ts{ii,iii};
      if isnumeric(st), sti=st;
      else sti=st{max(i21,ii),max(i22,iii)};
      end
      if ~isempty(tsi)&~isempty(sti)
        if any(abs(diff(sti)-tsi)>length(sti)*eps*tsi)
          Out=0; warning('Ts-SamplingInstants mismatch'), return
        end
      end
    end %for iii
  end %for ii
end
%
%Compare Ts and frequencies
if ~isempty(st)&isempty(ts)
  %generate ts from SamplingInstants
  if isnumeric(st), st={st}; end
  if length(st{1})>1, ts=mean(diff(st{1})); end
end
ifr=get(dat,'InputFrequencies'); if ~iscell(ifr), ifr={ifr}; end
ofr=get(dat,'OutputFrequencies'); if ~iscell(ofr), ofr={ofr}; end
fr=[ifr;ofr];
if size(fr,2)>1
  warning('Not yet ready if freq''s are different for different experiments')
elseif ~isempty(ts)
  if isnumeric(ts)
    for ii=1:length(fr)
      if any(fr{ii}>1/ts/2*(1+100*eps))
        Out=0; warning('Too large frequency component compared sampling'), return
      end
    end %for ii
  elseif iscell(ts)
    warning('getconsy not yet ready for cell ts')
  else
    error('ts is not a scalar or a cell array')
  end
end
%Compare Tp and frequencies
%fr=[ifr;ofr];
Tp=get(dat,'periodlength'); N=get(dat,'samplenumber');
if ~isempty(Tp)&~isempty(fr{1})
  for ii=1:length(fr)
    ind=Tp*fr{ii};
    Ni=N;
    for iii=1:size(N,2)
      if iscell(N), Ni=N{iii}; end  
      if any(abs(ind-round(ind))>Ni*10*eps)
        Out=0; warning('frequencies - PeriodLength mismatch'), return    
      end
    end
  end
end
% end @tiddata/getconsy.m
