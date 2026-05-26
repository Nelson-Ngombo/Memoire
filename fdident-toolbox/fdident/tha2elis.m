function [num,denom,delay,fs,vary,ccovar,domain]=tha2elis(theta,N,freqv)
%THA2ELIS Use fidmodel instead.

%Old fdident help
%THA2ELIS Generates ELiS-format from a model of the System Identification Toolbox.
%
%       [num,denom,delay,fs,vary,ccovar,domain]=THA2ELIS(theta,N,freqv)
%
%       Output arguments:
%       num = numerator of the transfer function
%       denom = denominator of the transfer function
%       delay = additional delay in the model
%       fs = sampling frequency
%       vary = frequency domain variances at the frequencies in freqv
%       ccovar = covariance matrix of the vector [num,denom,delay]
%       domain = 's' or 'z'
%
%       Input arguments:
%       theta = SITB model to be converted.
%       N = length of the data record (number of FFT points)
%       freqv = vector of frequencies where the variance is to be calculated
%           If vary is not required, freqv is not necessary
%
%       Usage: [num,denom,delay,fs,vary,ccovar,domain]=tha2elis(theta,N,freqv);
%       Example:
%            theta=elis2tha('inpchmod(inpchanz',NaN,2/256*1e-9);
%
%       See also: ELIS2THA; System Identification Toolbox.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 

if isa(theta,'idss')&exist('idpoly'), theta=idpoly(theta); end
if isa(theta,'idpoly')
  A=theta.a; B=theta.b;
  C=theta.c; D=theta.d;
  F=theta.f;
elseif isa(theta,'idarx')
  A=theta.a; B=theta.b;
  C=1; D=1;
  F=1;
elseif exist('th2poly')
  [A,B,C,D,F]=feval('th2poly',theta);
elseif exist('polyform')
  [A,B,C,D,F]=feval('polyform',theta);
else
  error(sprintf(['The function m-file ''idpoly'', ''th2poly'', or ''polyform'' of the ',...
        'System Identification Toolbox\n      is required for the ',...
        'execution of this routine']))
end
%Correction for Matlab 7.3, 17-Sep-2006
if length(size(A))==3, A=permute(A,[1,3,2]); end
if length(size(B))==3, B=permute(B,[1,3,2]); end
if length(size(C))==3, C=permute(C,[1,3,2]); end
if length(size(D))==3, D=permute(D,[1,3,2]); end
num=B;
denom=conv(A,F);
if isa(theta,'idpoly')|isa(theta,'idarx')
  if theta.Ts==0, fs=inf; else fs=1/theta.Ts; end
else
  fs=1/theta(1,2);
end
if (fs<0)|~isfinite(fs)
  disp('Warning! Converting a continuous-time model from theta-format')
  domain='s';
  fs=[];
else
  domain='z';
end
if strcmp(domain,'z')
  if isa(theta,'idpoly')|isa(theta,'idarx')
    delay=0; numd=num;
    while ~isempty(numd)
      if numd(1)==0
        delay=delay+1; numd(1)=[];
      else
        break
      end
    end
  else
    delay=theta(1,9);
  end
  num(1:delay)=[];
else
  delay=0;
end
na=length(A)-1; nb=length(num); nc=length(C)-1; nd=length(D)-1; nf=length(F)-1;
np=na+nb+nc+nd+nf;
if strcmp(domain,'s')
  if isa(theta,'idpoly')|isa(theta,'idarx')
    delay=theta.inputdelay;
  elseif length(theta(:,1))>3+np, delay=theta(4+np,1);
  end
end
%
if nargout>=5 %vary needed
  if nargin<2, error('N is not given although vary is requested'), end
  if length(N)>1, error('N is not a scalar'), end
  if (nc==0)&(nd==0)&(na==0) %white noise
    if isa(theta,'idpoly')|isa(theta,'idarx')
      vary=N/2*theta.NoiseVariance;
    else
      vary=N/2*theta(1,1);
    end
  else
    if nargin<3, error('freqv is not given'), end
    cAD=conv(A,D);
    tfn=polyval(C(length(C):-1:1),exp(-sqrt(-1)*freqv/fs*2*pi))...
                ./polyval(cAD(length(cAD):-1:1),exp(-sqrt(-1)*freqv/fs*2*pi));
    if isa(theta,'idpoly')|isa(theta,'idarx')
      vary=N/2*theta.NoiseVariance*abs(tfn).^2;
    else
      vary=N/2*theta(1,1)*abs(tfn).^2;
    end
  end
end
%
if nargout>=6 %ccovar needed
  ccovar=[]; cABF=[];
  npe=length(num)+length(denom)+1; %number of elis parameters
  if isa(theta,'idpoly')|isa(theta,'idarx')
    cABF=theta.CovarianceMatrix;
  else
    [lv,lh]=size(theta);
    if lv>=3+np %covariances given
      cABF=theta(3+[1:np],1:np);
    end
  end
  if ~isempty(cABF)
    ccovar=zeros(npe,npe);
    CDind=na+nb+[1:nc+nd];
    if ~isempty(CDind), cABF(:,CDind)=[]; cABF(CDind,:)=[]; end
    map=[1:npe-1]; %pointer to polynomial coefficients
    map(length(num)+1)=[]; %exclude denom(1)
    if na==0 %A=1, B->num, F->denom
      ccovar(map,map)=cABF;
    elseif nf==0 %F=1, B->num, A->denom
      BAind=[na+[1:nb],1:na];
      ccovar(map,map)=cABF(BAind,BAind);
    else %A and F were unfortunately both estimated, approximation follows
      disp('WARNING: ccovar will be approximated in tha2elis')
      %extend cABF by appropriate zeros
      lcABF=length(cABF);
      cABFt=zeros(lcABF,lcABF); clear lcABF
      cti=[2:na+1+nb,na+1+nb+1+[1:nf]];
      cABFt(cti,cti)=cABF;
      %cABFt is ready, approximation follows for dp=TR*dABF
      %dxy ~ y*dx+x*dy
      TR=zeros(npe,length(cABFt));
      ln=length(num);
      TR(1:ln,na+1+[1:ln])=eye(ln,ln); %B->num
      for nAi=1:length(A)
        for nFi=1:length(F)
          TR(ln+nAi+nFi-1,nAi)=TR(ln+nAi+nFi-1,nAi)+F(nFi);
          TR(ln+nAi+nFi-1,na+1+ln+nFi)=TR(ln+nAi+nFi-1,na+1+ln+nFi)+A(nAi);
        end
      end
      ccovar=TR*cABFt*TR';
      if any(sqrt(diag(ccovar))>0.5*abs([num,denom,delay]'))
        disp('WARNING: In tha2elis the approximated covariances are too large')
      end
    end %approximation
  end %~isempty(cABF)
end %nargout>6
%%%%%%%%%%%%%%%%%%%%%%%% end of tha2elis %%%%%%%%%%%%%%%%%%%%%%%%
