function segmdata = segment(tdata,ovl)
%Segment  Segment data given in tiddata object into periods
%
%       Input arguments:
%       tdata = object to be segmented
%       ovl = overlap (fraction or period length), optional

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Aug-2003

ni = nargin;
no = nargout;
if nargin<2, ovl=''; end, if isempty(ovl), ovl=0; end

segmdata=tdata;
expno=get(tdata,'expnumber');
if expno>1
  for ii=expno:-1:1
    Struc.type='{}'; Struc.subs={':',ii};
    tdatas=segment(subsref(tdata,Struc),ovl);
    if get(tdatas,'expnumber')>1
      set(tdatas,'synchronization','on')
    end
    segmdata=subsasgn(segmdata,Struc,tdatas);
  end
  return
end
pl=get(tdata,'periodlength');
ts=get(tdata,'ts');
if isempty(ts), warning('ts is empty'), return, end
st=get(tdata,'SamplingInstants');
if ~isempty(st)
  if any(abs(ts-diff(st))>1000*eps*ts)
    error('SamplingInstants contradicts to Ts')
  else
    set(segmdata,'SamplingInstants',[])
  end
end
N=get(tdata,'samplen');
if iscell(N), warning('Different sample numbers in data cells'), return, end
tr=ts*N;
if isempty(pl)|any(~isfinite(pl))
  freqv=get(tdata,'frequencies');
  pl=1/dfcalc([0;freqv(:)]);
end
if isempty(pl)|any(~isfinite(pl))
  warning('Cannot determine period length'), return
end
if abs(pl/ts-round(pl/ts))>100*eps
  warning('Period length covers noninteger number of samples')
  pli=pl;
  while (abs(pli/ts-round(pli/ts))>100*eps)&(pli<tr)
    pli=pli+pl;
  end
  if abs(pli/ts-round(pli/ts))>100*eps
    error('Cannot segment signal to integer number of samples')
  else
    pl=pli;
  end
end
if pl+pl*(1-ovl)>tr*(1+100*eps)
  warning('Less than 2 periods can be generated')
  return
end
segmno=floor( (tr-pl+ts/2)/((1-ovl)*pl) )+1;
Ns=round(pl/ts);
if ovl>1-1/Ns/2, error('ovl is too large'), end
Novl=round(Ns*ovl);
%
data=get(tdata,'data');
tstart=get(tdata,'tstart');
if ~isempty(tstart)
  if isnumeric(tstart), 
    tst0=tstart; tstart=cell(chno,1);
    for ii=1:length(tstart), tstart(ii)={tst0}; end
  end
end
if isempty(data), return, end
if ~iscell(data), data={data}; end
Ref=get(tdata,'Reference');
if ~isempty(Ref)&~iscell(Ref), Ref={Ref}; end
%
chno=size(data,1); expno=get(tdata,'expn');
datas=cell(chno,segmno*expno);
Refs=cell(1,segmno*expno);
for ii=1:chno %channels
  for iv=1:size(data,2) %experiments
    datasiv={}; Refsiv={};
    for iii=1:segmno %segments
      if (ii==1)&~isempty(tstart)
        if (iv>1)|(iii>1), tstart=[tstart,tstart(:,1)]; end
      end
      datasiv=[datasiv,{data{ii,iv}((iii-1)*(Ns-Novl)+[1:Ns])}];
      if ~isempty(Ref)&(ii==1), Refsiv=[Refsiv,{Ref{iv}((iii-1)*(Ns-Novl)+[1:Ns])}]; end
    end %for iii
    datas(ii,(iv-1)*segmno+[1:segmno])=datasiv;
    if ~isempty(Ref)&(ii==1), Refs(1,(iv-1)*segmno+[1:segmno])=Refsiv; end
  end %for iv
end %for ii
set(segmdata,'data',datas,'noconsistency')
if ~isempty(Ref), set(segmdata,'Reference',Refs,'noconsistency'), end
%
if ~isempty(tstart), set(segmdata,'tstart',tstart,'noconsistency'), end
if (expno==1)|strcmp(get(tdata,'synchronization'),'on')
  if get(segmdata,'expnumber')>1
    set(segmdata,'synchronization','on','noconsistency')
  end
end
get(segmdata,'consistency');
%
% end of function @tiddata/segment
