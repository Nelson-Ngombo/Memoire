function Out = tcat(varargin)
%TCAT  Unify two experiments by direct continuation
%       The first object dominates (e.g. Name)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Mar-2001

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end

Out=varargin{1};
if ~strcmp(class(Out),'tiddata')
  error('Class is not tiddata')
end
if length(varargin)==1, return, end
%
for ii=2:length(varargin)
  dat2=varargin{ii};
  
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments should be objects of the same class')
  end
  
  %Now add children properties
  ts1=Out.Ts; ts2=dat2.Ts;
  if isempty(ts1)&~isempty(ts2)
    Out.Ts=ts2;
    warning('Empty Ts in obj1, value taken from obj2 in @tiddata/horzcat') 
  elseif ~isempty(ts1)&isempty(ts2)
    warning('Empty Ts in obj2, value taken from obj1 in @tiddata/horzcat') 
  elseif ~isempty(ts2)
    if ~isequal(ts1,ts2), error('Sampling times differ in objects'), end
  end
  %
  tst1=Out.TStart; tst2=dat2.TStart;
  if isempty(tst1)&~isempty(tst2)
    Out.TStart=tst2;
    warning('Empty TStart in obj1, values taken from obj2 in @tiddata/horzcat') 
  elseif iscell(tst1)&iscell(tst2)
    Out.TStart=[tst1,tst2];
  elseif ~isempty(tst2)&~isequal(tst1,tst2)
    error('Starting times differ in objects')
  end
  %
  st1=Out.SampleTimes; st2=dat2.SampleTimes;
  if isempty(st1)
    if ~isempty(st2)
      Out.SampleTimes=st2;
      warning('Empty SamplingInstants in obj1, values taken from obj2 in @tiddata/horzcat') 
    end
  elseif ~isempty(st2)&~isequal(st1,st2)
    error('Sampling times differ in objects')
  end 
  %
  in1=get(Out,'input'); in2=get(dat2,'input');
  if isnumeric(in1)&isnumeric(in2)
    in=[in1;in2];
  else
    error('Non-numeric input')
  end
  out1=get(Out,'output'); out2=get(dat2,'output');
  if isnumeric(out1)&isnumeric(out2)
    out=[out1;out2];
  else
    error('Non-numeric input')
  end
  set(Out,'input',in,'output',out)
end %for ii
set(Out,'frequencies',[],'noconsistency')
%
if ~get(Out,'consistency')
  error('Inconsistent object is generated: see the warning message above for the reason')
end
%
% end of function @tiddata/tcat
