function theta=elis2tha(varargin)
%ELIS2THA In Matlab 6.x, use idmodel(fidmod) instead
%         In Matlab 5.x, type 'oldhelp elis2tha'

%Old fdident help
%ELIS2THA Convert model to the System Identification Toolbox.
%
%       theta=ELIS2THA(pdat,cdat,varet,numn,denomn)
%
%       Output argument:
%       theta = idpoly object (earlier SITB versions: theta matrix)
%             entries filled in with zeros:
%             Final Prediction Error, covariances of the coefficients of C and D
%
%       Input arguments:
%       pdat = the parameter vector (see EXPPAR) or the name of the parameter
%           file; the delay must not be negative, and it will be rounded to the
%           nearest integer.
%       cdat = the covariance matrix as an array, or in vector form (see
%           EXPCOV) or the name of the covariance file: it may be empty, if the
%           covariances are not available.
%       varet = variance of the time domain noise (before noise shaping).
%           If the variance of the real and of the imaginary parts of the
%           complex amplitudes is uniformly vary in the N-point spectrum,
%           calculate varet as follows:  varet=2/N*vary
%       numn = numerator of the observation noise shaping filter
%       denomn = denominator of the observation noise shaping filter
%           The sampling frequency for the noise shaping filters is the
%           same as that of the parameter vector.
%       Default values: numn=1, denomn=1
%
%       Usage: theta=elis2tha(pdat,cdat,varet,numn,denomn);
%       Example:
%            theta=elis2tha('inpchmod(inpchanz)','',2/256*1e-9);
%
%       See also: THA2ELIS; System Identification Toolbox.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

if ~exist('poly2th')&~exist('mktheta')
  error(sprintf(['The function m-file ''poly2th'' or ''mktheta'' of the ',...
        'System Identification Toolbox\n      is required for the ',...
        'execution of this routine']))
end
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,5); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,5,ni)), %earlier
end
numn=1; denomn=1;
pdat=getobjf(varargin{1},'fidmodel');
try
  if ~isa(pdat,'fidmodel')&~isa(pdat,'idmodel')
    pdat=fidmodel(pdat);
  end
catch
end
if ~isa(pdat,'fidmodel')
  error('First input argument is not fidmodel object')
end
if nargin>=5, denomn=varargin{5}; end
if nargin>=4, numn=varargin{4}; end
varet=varargin{3};
cdat=varargin{2};
%
maxdyn=1e10; %maximal allowed dynamics of coefficients
if max(abs(numn)/numn(1))>maxdyn
  warning(sprintf(['The leading coefficient of the numerator',...
      '  is very small in elis2tha\n  (maxnumn/numn(1)=%.5e)'],...
       max(abs(numn)/numn(1))))
end
if max(abs(denomn)/denomn(1))>maxdyn
  warning(sprintf(['The leading coefficient of the denominator',...
      '  is very small in elis2tha\n  (maxdenomn/denomn(1)=%.5e)'],...
       max(abs(denomn)/denomn(1))))
end
if length(varet)>1, error('varet is not scalar'), end
varet=varet*numn(1)^2/denomn(1)^2;
numn=numn/numn(1); denomn=denomn/denomn(1);
%
[domain,num,denom,delay,fs]=imppar(pdat);
if ~strcmp(domain,'z'), disp('Warning! s-domain model is converted'), end
if max(abs(denom)/denom(1))>maxdyn
  warning(sprintf(['The leading coefficient of the denominator',...
      '  is very small in elis2tha\n  (maxdenom/denom(1)=%.5e)'],...
       max(abs(denom)/denom(1))))
end
psc=1/denom(1); B=num/denom(1); F=denom/denom(1);
if delay<0, error('The delay must not be negative'), end
if strcmp(domain,'z')
  if round(delay)~=delay
    warning(sprintf('delay=%.3g is not integer in elis2tha',delay))
  end
  delay=round(delay); B=[zeros(1,delay),B];
else
  if exist('@idpoly/idpoly.m'), fs=inf;
  else fs=-1;
  end
end
%
if exist('idarx')&isequal(numn,1)&isequal(denomn,1)&isequal(F,1)
  theta=feval('idarx',1,B,1/fs,'NoiseVariance',varet);
elseif exist('poly2th')
  theta=feval('poly2th',1,B,numn,denomn,F,varet,1/fs);
  if isa(theta,'idpoly')
    if ~isequal(theta.Ts,1/fs)
      warning(sprintf('Ts is improperly set in poly2th: %.3g instead of %.3g',...
          theta.Ts,1/fs))
      theta.Ts=1/fs;
    end
    %theta.estimationinfo.Status='Estimated by ELiS';
    %theta.estimationinfo.Method='ELiS (fdident toolbox)';
    if isa(pdat,'fidmodel')
      if isfield(pdat.fitinfo,'cf'), cf=pdat.fitinfo.cf;
      elseif ~isempty(pdat.fitinfo), cf=pdat.fitinfo(1);
      else cf=NaN;
      end
    else cf=NaN;
    end
    %theta.estimationinfo.LossFcn=cf;
    %theta.estimationinfo.FPE=NaN;
  end
elseif exist('mktheta')
  theta=feval('mktheta',1,B,numn,denomn,F,varet,1/fs);
end
if isempty(cdat)&isa(pdat,'fidmodel'), cdat=pdat.covariance; end
if ~isempty(cdat)|(strcmp(domain,'s')&(delay~=0))
  nb=length(num); nc=length(numn)-1; nd=length(denomn)-1; nf=length(F)-1;
  np=nb+nc+nd+nf;
  thetasav=theta; [thv,thh]=size(theta);
  thv=3+np; thh=max(thh,np);
  if strcmp(domain,'s')&(delay~=0), thv=thv+1; end
  if isnumeric(thetasav)
    theta=zeros(thv,thh); theta(1:3,1:thh)=thetasav;
  end
end
if strcmp(domain,'s')&(delay~=0)
  if isnumeric(theta), theta(4+np,1)=delay;
  else theta.inputdelay=delay;
  end
end
if ~isempty(cdat)
  if min(size(cdat))==length(cdat) %square array is given
    ccovar=cdat;
  else
    ccovar=impcov(cdat);
  end
  N=length(ccovar(:,1));
  ccovar(N,:)=[]; ccovar(:,N)=[]; %delete covariances of delay
  varb=ccovar(nb+1,nb+1);
  if varb==0
    %delete zero variance of leading coefficient of denom:
    ccovar(nb+1,:)=[]; ccovar(:,nb+1)=[];
    ccovar=psc^2*ccovar;
  else
    %variance of leading coefficient is not zero; approximation follows:
    warning('Variance of denom(1) is not zero in elis2tha')
    if varb>0.2*abs(denom(1)^2)
      error('var(denom(1)) is too large')
    end
    %(a+da)/(b+db) ~ (a/b)*(1+da/a-db/b) = a/b+da/b-db*a/b^2
    b=denom(1); a=[num,denom(2:length(denom))];
    %find TR for d(a/b)=TR*dpvect
    lpv=length(num)+length(denom);
    TR=eye(lpv,lpv)/b; TR(nb+1,:)=[];
    TR(:,nb+1)=TR(:,nb+1)-a'/b^2;
    ccovar=TR*ccovar*TR';
  end
  if isa(theta,'idpoly')
    theta.CovarianceMatrix=ccovar;
  else
    theta(3+[1:nb,nb+nc+nd+[1:nf]],[1:nb,nb+nc+nd+[1:nf]])=ccovar;
  end
end %~isempty(cdat)
%%%%%%%%%%%%%%%%%%%%%%%% end of elis2tha %%%%%%%%%%%%%%%%%%%%%%%%
