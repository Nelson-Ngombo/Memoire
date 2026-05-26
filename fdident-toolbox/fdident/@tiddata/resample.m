function outdata=resample(indata,M,offs)
%RESAMPLE  Subsample time sequence by integer number M (every Mth sample)
%
%       Usage:
%         outdata=resample(indata,M,offs)
%
%       Example:
%         load robotarm, d=resample(robotarm_rawdata,4);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-May-2002

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,3,ni)), %earlier
end
if nargin<3, offs=0; end
d=get(indata,'data');
ts=get(indata,'ts');
if (M==1)&(offs==0)
  outdata=indata; return
end
if isnumeric(ts)&(length(ts)==1)
  if ~isnumeric(M)|(length(M)~=1), error('M is not a scalar'), end
  if (M<=0)|(rem(M,1)~=0), error('M is not a positive integer'), end
  if ~isnumeric(offs)|(length(offs)~=1), error('offs is not a scalar'), end
  if (offs<0)|(rem(offs,1)~=0), error('offs is not a non-negative integer'), end
  if isnumeric(d), d={d}; dnum=1; else dnum=0; end
  for ii=1:prod(size(d))
    dii=d{ii};
    if ~isempty(dii), d{ii}=dii(1+offs:M:end); end
  end
  if dnum, d=d{1}; end
  ts=ts*M;
  outdata=indata;
  set(outdata,'data',d,'ts',ts);
else
  error('Resample is not implemented is Ts is not a scalar')
end  
%End of @tiddata/resample