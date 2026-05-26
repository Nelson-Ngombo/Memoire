function Out = plus(varargin)
%PLUS  Unify two object by putting the time data after each other
%       dat1 + dat2 ...
%       The first object dominates (e.g. Name)
%
%       See also: @iddat/plus

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Dec-1998

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end

if length(varargin)==1, Out=varargin{1}; return, end

Out=varargin{1};
for ii=2:length(varargin)
  dat2=varargin{ii};
  
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments must be objects of the same class')
  end
  if strcmp(class(Out),'tiddata')
    if ii==2
      Out=tiddata(struct(Out));
      tmp=tiddata; Out.Version=tmp.Version;
    end
  else
    error('Class is not tiddata')
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
  if ~isempty(tst1)&~isempty(tst2)
    error('Cannot handle two tstart''s yet')
  elseif isempty(tst1)&~isempty(tst2)
    Out.TStart=tst2;
    warning('Empty TStart in obj1, values taken from obj2 in @tiddata/plus') 
  end
  %
  st1=Out.SampleTimes; st2=dat2.SampleTimes;
  if ~isempty(st1)&~isempty(st2)
    if isnumeric(st1)&isnumeric(st2)
      Out.SampleTimes=[st1;st2];
    else
      error('Not ready yet')
    end
  elseif isempty(st1)&~isempty(st2)
    Out.SampleTimes=st2;
    warning('Empty SampleTimes in obj1, values taken from obj2 in @tiddata/plus') 
  elseif ~isempty(st2)&~isequal(st1,st2)
    error('Sampling times differ in objects')
  end 
  %
  Out.iddat=plus(Out.iddat,dat2.iddat);
end %for ii
%
if ~get(Out,'consistency')
  error('Inconsistent object is generated: see the warning message above for the reason')
end
%
% end of function @tiddata/plus
