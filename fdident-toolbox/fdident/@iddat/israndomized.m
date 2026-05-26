function Out=israndomized(obj)
%ISRANDOMIZED  Check if data come from randomized experiment

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Dec-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if ~isa(obj,'fiddata')&~isa(obj,'tiddata')
  error('class is not ''fiddata'' or ''tiddata''')
end
%
Out=0; if length(obj)==0, return, end
expno=get(obj,'expnumber'); 
if ((expno>1)&strcmp(get(obj,'synchronization'),'samepower'))|...
  ((expno==1)&~isempty(get(obj,'nonlincovariancematrix')))
  return
end
%
expi=[1:expno]';
fv=get(obj,'frequencies'); df=dfcalc(obj);
if isa(obj,'fiddata')
  ipf=get(obj,'inputfreqpoints');
  if isempty(ipf), ipf=get(obj,'freqpoints'); end
else ipf=[];
end
if isnumeric(fv)&isnumeric(df)&isnumeric(ipf), 
  expi=1; %not necessary to scan all experiments
end
for ei=1:expi
  if length(expi)>1
    Struct=[]; Struct.type='{}'; Struct.subs={':',ei};
    %avoid warnings in nonlinear analysis:
    if isa(obj,'fiddata'), set(obj,'covariancematrix',[]); end
    obji=subsref(obj,Struct);
  else
    obji=obj; 
  end
  fv=get(obji,'frequencies');
  if iscell(fv), 
    for ii=length(fv):-1:2, 
      if isequal(fv{ii},fv{1}), fv(ii)=[]; else break, end
    end
    if length(fv)==1, fv=fv{1}; end
  end
  df=dfcalc(obji);
  if isempty(fv)&exist('ipf')&~isempty(ipf), fv=ipf; end
  if isnumeric(fv)&~isempty(fv)&~isempty(df)&any(df>0)
    findmin=round(min(fv)/df); findmax=round(max(fv)/df);
    F=length(fv);
    if isa(obji,'fiddata')
      if length(expi)>1
        Struct=[]; Struct.type='{}'; Struct.subs={':',1};
        Struct(2).type='.'; Struct(2).subs='inputfreqpoints';
        ipf=subsref(obji,Struct);
      end
      fvind=round(fv/df);
      if any(rem(fvind,2)~=1), Out=0; return, end
      %Fi=find((fvind>=findmin)&(fvind<=findmax));
      Fi=findmin:2:findmax;
    else %tiddata
      fvind=round(fv/df);
      if any(rem(fvind,2)~=1), Out=0; return, end
      Fi=findmin:2:findmax;
    end
    Filposs=length(Fi);
    runlength=0; maxrunlength=0;
    dfvind=diff(fvind);
    for ii=1:length(dfvind)
      if dfvind(ii)==2, runlength=runlength+1; else runlength=0; end
      maxrunlength=max(runlength, maxrunlength);
    end
    longrun=(maxrunlength>6); 
    longrun=any(0); %no test for this
    existnonexc=any(F<Filposs);
    if (F>1)&...
        all(rem(round(fv/df),2)==1)&...
        (Filposs>=max(5/4*(F-1)-2,2))&...
        ~longrun&existnonexc
      Out=1; return
    end
  end
end %for ei
%
% end @iddat/israndomized.m