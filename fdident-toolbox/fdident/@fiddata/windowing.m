function outpval=windowing(inpval,window)
%WINDOWING  Apply frequency domain windowing

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 28-Apr-2009

outpval=inpval;
if (nargin==1)|strncmp(window,'rect',4), return, end
fv=get(outpval,'freqpoints');
if strncmp(window,'sine',4)
  fv2=conv(fv,[0.5;0.5]);
  fv2(1)=[]; fv2(end)=[];
end
data=get(outpval,'data');
for id=1:prod(size(data))
  datai=data{id};
  if strncmpi(window,'Hanning',4)
    if fv(1)==0, datai=[conj(datai(2));datai]; end
    datai=conv(datai,[-025;0.5;-0.25]);
    datai(1)=[]; datai([end])=[];
    if fv(1)==0, datai(1)=[]; end
  elseif strncmpi(window,'Hamming',7)
    if fv(1)==0, datai=[conj(datai(2));datai]; end
    datai=conv(datai,[-023;0.54;-0.23]);
    datai(1)=[]; datai([end])=[];
    if fv(1)==0, datai(1)=[]; end
  elseif strncmp(window,'sine',4)
    datai=conv(datai,[0.5;-0.5]);
    datai(1)=[]; datai([end])=[];
    %warning('Window ''sine'' is not yet implemented')
  else
    error(['Window ''',window,''' is not implemented'])
  end
  data{id}=datai;
end %for id
if strncmp(window,'sine',4)
  set(outpval,'freqpoints',fv2,'data',data);
else
  set(outpval,'data',data);
end
% end ../@fiddata/windowing.m