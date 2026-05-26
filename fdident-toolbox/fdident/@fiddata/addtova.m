function [v2obj,avinfo]=addtova(vobj,obj,sync)
%ADDTOVA  Add experiment to variance analysis results
%
%       [v2obj,avinfo]=addtova(vobj,obj,sync)
%
%       This is the recursive way of variance analysis: if vobj is the result of
%       variance analysis of M experiments, and obj is one experiment, v2obj
%       is the analysis result of M+1 experiments.
%       In the case of full MIMO experiments, v2obj, vobj and obj are full MIMO
%       groups of experiments.
%       if sync='nonlinear', variance analysis is performed into the nonlinear 
%       properties. 

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-Jan-2004

if isempty(vobj)
  v2obj=obj;
  avinfo.Na=1; avinfo.Np=1; avinfo.cfl=[NaN,NaN]; avinfo.dv=[];
  return
elseif isempty(obj)
  v2obj=vobj;
  avinfo.Na=1; avinfo.Np=1; avinfo.cfl=[NaN,NaN]; avinfo.dv=[];
  return
end
if nargin<3, sync=''; end
if strncmpi(sync,'nonlinear',6)|isempty(sync)
else error(['sync is illegal as ''',sync,''''])
end
if ~isequal(class(vobj),class(obj)), error('Classes of objects differ'), end
if ~isequal(get(vobj,'chnumber'),get(obj,'chnumber'))
  error('Channel numbers differ')
end
if ~isequal(get(vobj,'expnumber'),get(obj,'expnumber'))
  error('Experiment numbers differ')
end
%
if strcmpi(get(obj,'synchronization'),'MIMO')
  %Decouple if necessary
  if ~issingleref(obj), obj=decouple(obj); end
end
if strncmpi(sync,'nonlinear',6)
  M=get(vobj,'nonlinM');
  cov=get(vobj,'nonlincovariancematrix');
  lincov=get(vobj,'covariancematrix');
else
  M=get(vobj,'M');
  cov=get(vobj,'covariancematrix');
end
if isempty(M), M=1; end
if ~isempty(cov)&~iscell(cov), cov={cov}; end
Data=get(vobj,'Data'); Datai=get(obj,'Data');
expno=get(vobj,'expnumber');
chno=get(vobj,'chnumber');
fi=get(vobj,'freqind');
fpi=get(vobj,'allfreqpoints'); if ~iscell(fpi), fpi={fpi}; end
fpiN=size(fpi{1},1);
if isempty(cov), 
  cov={zeros(chno,chno,fpiN)}; 
  while size(cov,2)<expno, cov=[cov,cov{1}]; end
end
if isnumeric(fi), fi={fi}; end
if ~iscell(Data), Data={Data}; end, if ~iscell(Datai), Datai={Datai}; end
iecov=get(vobj,'InterExpNonlinCovariance');
for ie=1:expno
  for ic=1:chno
    if isempty(Data{ic,ie}), Data{ic,ie}=zeros(size(Datai{ic,ie})); end 
    Data{ic,ie}=M/(M+1)*Data{ic,ie}+1/(M+1)*Datai{ic,ie};
    fic=fi{min(ic,end),min(ie,end)};
    if M==1
      cov{ie}(ic,ic,fic)=...
      permute((M+1)/M^2*abs(Datai{ic,ie}-Data{ic,ie}).^2,[2,3,1]);
    else
      cov{ie}(ic,ic,fic)=(M-2)/(M-1)*cov{ie}(ic,ic,fic)+...
        permute((M+1)/M^2*abs(Datai{ic,ie}-Data{ic,ie}).^2,[2,3,1]);
    end
  end
  for ic2=1:ic-1
      fic2=fi{min(ic2,end),min(ie,end)};
      if M==1
        cov{ie}(ic,ic2,fic)=...
        permute((M+1)/M^2*conj(Datai{ic,ie}-Data{ic,ie})...
        .*(Datai{ic2,ie}-Data{ic2,ie}),[2,3,1]);
      else
        cov{ie}(ic,ic2,fic)=(M-2)/(M-1)*cov{ie}(ic,ic2,fic)+...
        permute((M+1)/M^2*conj(Datai{ic,ie}-Data{ic,ie})...
        .*(Datai{ic2,ie}-Data{ic2,ie}),[2,3,1]);
    end
    cov{ie}(ic2,ic,fic)=conj(cov{ie}(ic,ic2,fic));
    end
  end %for ic
  if (ie==1)&(expno>1)
    iecov=cell(expno,expno); ce=cell(chno,chno);
    for iec=1:prod(size(ce)), ce{iec}=zeros(fpiN,1); end
    for iec=1:prod(size(iecov)), iecov{iec}=ce; end  
  end
  for ie2=1:ie-1
    for ic1=1:chno
      for ic2=1:chno
        if M==1
          iecov{ie2,ie}(ic1,ic2)=...
            permute((M+1)/M^2*conj(Datai{ic1,ie2}-Data{ic1,ie2})...
            .*(Datai{ic2,ie}-Data{ic2,ie}),[2,3,1]);
        else
          iecov{ie2,ie}(ic1,ic2)=(M-2)/(M-1)*iecov{ie2,ie}(ic1,ic2)+...
            permute((M+1)/M^2*conj(Datai{ic1,ie2}-Data{ic1,ie2})...
            .*(Datai{ic2,ie}-Data{ic2,ie}),[2,3,1]);
      end %for ic2
    end %for ic1
  end %for ie2
  if exist('lincov')
    lincovi=get(obj,'covariancematrix');
    warning('Handling of lincov is not yet ready')
  end
end %for ie
%
set(vobj,'Data',Data,'noconsistency');
if length(cov)==1, cov=cov{1}; end
M=M+1;
if strncmpi(sync,'nonlinear',6)
  set(vobj,'nonlincovariancematrix',cov,'nonlinM',M,'noconsistency');
else
  set(vobj,'covariancematrix',cov,'M',M,'noconsistency');
end
if ~isempty(iecov), set(vobj,'InterExpNonlinCovariance',iecov,'noconsistency'), end
get(vobj,'consistency');
v2obj=vobj;
avinfo.Na=M;
avinfo.Np=M;
if M==1, cfl=[NaN,NaN]'
elseif M==2 %m=2*(M-1)=2
  cfl(1)=2/(5/6*7.824+1/6*5.991);
  cfl(2)=2/(5/6*0.0404+1/6*0.103);
else %approximation is acceptable
  cfl(1)=1/(1-2/(9*(2*(M-1)))+1.96*sqrt(2/(9*(2*(M-1)))))^3;
  cfl(2)=1/(1-2/(9*(2*(M-1)))-1.96*sqrt(2/(9*(2*(M-1)))))^3;
end
avinfo.cfl=cfl;
avinfo.dv=[]; avinfo.stddelay=[];
%End of addtova