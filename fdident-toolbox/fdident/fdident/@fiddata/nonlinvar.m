function [avdat,avinfo]=nonlinvar(dat)
%NONLINVAR  Nonlinear averaging above experiments
%       We assume that all experiments are 'samepower'
%
%       See also VARANAL, @FIDDATA/INTERPVAR

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

if ~strcmp(get(dat,'synchron'),'samepower')
  error(['obj.synchronization is ''',get(dat,'synchron'),''', and not ''samepower'''])
end
covs=get(dat,'CovarianceMatrix');
M=get(dat,'M');
set(dat,'CovarianceMatrix',[],'M',[])
expno=get(dat,'expnumber');
%synchronize
Ref=get(dat,'Reference');
%for test only
%  u=get(dat,'u');
%
if ~isempty(Ref)&~iscell(Ref), Ref={Ref}; end
data=get(dat,'data');
if ~isempty(Ref)
  for ii=1:size(data,2)
    for iii=1:size(data,1)
      data{iii,ii}=data{iii,ii}./(Ref{min(ii,end)});
    end %for iii
    if ~isempty(covs)&iscell(covs)
      covs{ii}(1,1,:)=covs{ii}(1,1,:)./abs(permute(Ref{min(ii,end)},[2,3,1])).^2;
      covs{ii}(1,2,:)=covs{ii}(1,2,:)./abs(permute(Ref{min(ii,end)},[2,3,1])).^2;
      covs{ii}(2,1,:)=covs{ii}(2,1,:)./abs(permute(Ref{min(ii,end)},[2,3,1])).^2;
      covs{ii}(2,2,:)=covs{ii}(2,2,:)./abs(permute(Ref{min(ii,end)},[2,3,1])).^2;
    end
  end
  set(dat,'data',data,'Reference',[])
else %no reference given
  inp=get(dat,'inputdata');
  outp=get(dat,'outputdata');
  if iscell(inp)
    for ii=1:prod(size(inp))
      outp{ii}=outp{ii}./inp{ii}; inpii=inp{ii}; inp{ii}=ones(size(inp{ii}));
      if ~isempty(covs)&iscell(covs)
        covs{ii}(1,1,:)=( covs{ii}(1,1,:) ...
          + covs{ii}(2,2,:).*abs(permute(outp{ii},[2,3,1])).^2 ...
          -2*real(covs{ii}(1,2,:).*conj(permute(outp{ii},[2,3,1]))) )...
          ./abs(permute(inpii,[2,3,1])).^2;
        covs{ii}(2,2,:)=zeros(size(covs{ii}(1,1,:)));
        covs{ii}(1,2,:)=NaN*zeros(size(covs{ii}(1,1,:)));
        covs{ii}(2,1,:)=NaN*zeros(size(covs{ii}(1,1,:)));
      end
    end %for ii
  end
  set(dat,'inputdata',inp,'outputdata',outp);
end %no reference
set(dat,'synchronization','on')
avdat=varanal(dat);
%covnllin=get(avdat,'covariancematrix');
avdat=var2nonlinvar(avdat);
Na=get(dat,'expn');
if ~isempty(covs)
  if iscell(covs)
    %Na=length(covs);
    covs=mean(cat(4,covs{:})/Na,4);
  else
    covs=covs/Na;
  end
  if all(all(isnan(covs))), covs=[]; end
  Mnew=(M-1)*Na+1;
  set(avdat,'CovarianceMatrix',covs,'M',Mnew)
end
%
if nargout>=2
  Na=get(avdat,'nonlinM');
  avinfo.Na=Na;
  avinfo.Np=Na;
  if Na==2 %m=2*(Na-1)=2
    cfl(1)=2/(5/6*7.824+1/6*5.991);
    cfl(2)=2/(5/6*0.0404+1/6*0.103);
  else %approximation is acceptable
    cfl(1)=1/(1-2/(9*(2*(Na-1)))+1.96*sqrt(2/(9*(2*(Na-1)))))^3;
    cfl(2)=1/(1-2/(9*(2*(Na-1)))-1.96*sqrt(2/(9*(2*(Na-1)))))^3;
  end
  avinfo.cfl=cfl;
  avinfo.dv=[];
  %a long calculation for dv, with no purpose
  avinfo.stddelay=[];
  %varargout(1)={avinfo};
end
%
%end @fiddata/nonlinvar.m