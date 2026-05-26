function Out = invrepeat(tdat)
%INVREPEAT  Inverse repeat time series

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Mar-2001

ni = nargin;
no = nargout;

Out=tdat;
%
dat2=tdat;
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
    warning('Empty SampleInstants in obj1, values taken from obj2 in @tiddata/horzcat') 
  end
elseif ~isempty(st2)&~isequal(st1,st2)
  error('Sampling times differ in objects')
end 
%
in1=get(Out,'input'); in2=get(dat2,'input');
if isnumeric(in1)&isnumeric(in2)
  in=[in1;-in2];
  if ~isempty(in), N=length(in); end  
else
  error('Non-numeric input')
end
out1=get(Out,'output'); out2=get(dat2,'output');
if isnumeric(out1)&isnumeric(out2)
  out=[out1;-out2];
  if ~isempty(out), N=length(out); end  
else
  error('Non-numeric input')
end
set(Out,'frequencies',[1:2:N/2-1]'/N/ts1,'noconsistency')
set(Out,'input',in,'output',out)
%
if ~get(Out,'consistency')
  error('Inconsistent object is generated: see the warning message above for the reason')
end
%
% end of function @tiddata/invrepeat
