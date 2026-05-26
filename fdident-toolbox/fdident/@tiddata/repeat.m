function Out = repeat(tdat,No)
%REPEAT  Repeat time series
%
%       Out = repeat(tdat,No) repeats the time series No times

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Apr-2000

ni = nargin;
no = nargout;
if nargin<2, No=[]; end, if isempty(No), No=2; end
Out=tdat;
%
in1=get(Out,'input'); out1=get(Out,'output');
in=in1; out=out1;
for ii=2:No
  %Now add children properties
  ts1=Out.Ts;
  %
  st1=Out.SampleTimes; st2=tdat.SampleTimes;
  %
  if isnumeric(in1)
    in=[in;in1];
  else
    error('Non-numeric input')
  end
  out2=get(tdat,'output');
  if isnumeric(out1)
    out=[out;out1];
  else
    error('Non-numeric input')
  end
end %for ii
set(Out,'input',in,'output',out)
%
if ~get(Out,'consistency')
  error('Inconsistent object is generated: see the warning message above for the reason')
end
%
% end of function @tiddata/repeat
