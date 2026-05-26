function Out = addchannels(varargin)
%ADDCHANNELS concatenation of tiddata objects: bypass non-inheritance from iddat

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Aug-2001

ni = nargin;
no = nargout;
if length(varargin)==1, Out=varargin{1}; return, end

Out=varargin{1};
for ii=2:length(varargin)
  dat2=varargin{ii};
  
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments should be objects of the same class')
  end
  
  %Now add children properties
  ts1=Out.Ts; ts2=dat2.Ts;
  if isempty(ts1)&~isempty(ts2)
    Out.Ts=ts2;
    warning('Empty Ts in obj1, value taken from obj2 in @tiddata/plus') 
  elseif ~isempty(ts1)&isempty(ts2)
    warning('Empty Ts in obj2, value taken from obj1 in @tiddata/plus') 
  elseif ~isempty(ts2)
    if ~isequal(ts1,ts2), error('Sampling times differ in objects'), end
  end
  %
  tst1=Out.TStart; tst2=dat2.TStart;
  if isempty(tst1)&~isempty(tst2)
    Out.TStart=tst2;
    warning('Empty TStart in obj1, values taken from obj2 in @tiddata/plus') 
  elseif iscell(tst1)&iscell(tst2)
    if (size(tst1,1)==1)&isequal(tst1,tst2)
      Out.TStart=tst1;
    else
      while get(Out,'chn')>size(tst1,1), tst1=[tst1;tst1]; end
      while get(dat2,'chn')>size(tst2,1), tst2=[tst2;tst2]; end
      Out.TStart=[tst1;tst2];
    end
  elseif ~isempty(tst2)
    Out.TStart=[tst1;tst2]; %add start times by channel
  end
  %
  st1=Out.SampleTimes; st2=dat2.SampleTimes;
  if isempty(st1)&isempty(st2) %nothing to do
  elseif isempty(st1)&~isempty(st2)
    Out.SampleTimes=st2;
    warning('Empty SamplingInstants in obj1, values taken from obj2 in @tiddata/plus') 
  elseif ~isempty(st2)&isnumeric(st1)&isnumeric(st2)
    %two nonempty numeric vectors
    if ~isequal(st1,st2)
      error('SamplingInstants differ in objects')
    end
  else
    error('Something is wrong with SamplingInstants in the two objects')
  end 
  %
  chn1=get(Out,'chnumber'); chn2=get(dat2,'chnumber');
  Out.iddat=addchannels(Out.iddat,dat2.iddat);
  chn3=get(Out,'chnumber');
  if chn3<chn1+chn2
    if ~isequal(get(Out,'Ts'),get(dat2,'Ts'))
      error('Different Ts: not the same inputs')
    end
  end
  %

end %for ii
%
if ~get(Out,'consistency')
  error('Something is wrong with addchannels')
end
%
%end of @tiddata/addchannels
