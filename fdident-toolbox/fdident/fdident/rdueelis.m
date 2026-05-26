function varargout = rdueelis(varargin)
%RDUEELIS Complex residuals of an estimation, made by ELIS.
%
%       rdat=RDUEELIS(model);
%
%       Output argument:
%       rdat = fiddata object of complex residuals and their variances
%
%       Input argument:
%       model = fidmodel object with fitted data
%
%       Usage: rdat=rdueelis(model);
%       Example: rdat=rdueelis('inpchmod(inpchans)');
%
%       See also: ELIS.

%Old fdident help
%RDUEELIS Residuals of an estimation, made by ELIS.
%
%       [rx,ry,ryx,vryx,xe,ye]=RDUEELIS(pdat,cdat,Fdat,vdat,expi,inp,outp)
%
%       Output arguments:
%       rx = complex residuals of the input amplitude vector
%       ry = complex residuals of the output amplitude vector
%       ryx = complex residuals of ym./xm vs. the estimated tf
%       vryx = variance vector of the real (and of the imaginary) parts
%           of ryx
%       xe = estimate of the complex input vector
%       ye = estimate of the complex output vector
%
%       Input arguments:
%       pdat = parameter vector (see EXPPAR) or the name of the parameter
%           file
%       cdat = covariance array or vector or file name; covariance matrix
%           of pdat. If empty, the uncertainty of pdat will not be
%           considered in vryx.
%       Fdat = Fx3 array: [freqv,x,y], or Fourier vector (see EXPFOU), or
%           the name of the Fourier file
%       vdat = variances: if this is a string or a column vector, the
%           variances will be obtained via IMPVAR; if this is an array
%           (Nx2 or N=3, N>1), this is supposed to consist of the output and
%           input variance vectors and maybe the covariance vector; in the
%           case of an 1x2 or 1x3 vector, these values mean the constant
%           output and input variances and maybe the covariances.
%       expi = number(s) of the experiment(s) in Fdat for which the residuals
%           are to be calculated; if Fdat is an array, expi=[1]
%       inp = (optional) number of the input port, default: 1
%       outp = (optional) number of the output port, default: 1
%
%       Usage:
%         [rx,ry,ryx,vryx,xe,ye]=rdueelis(pdat,cdat,Fdat,vdat,expi,inp,outp)
%       Example:
%         [rx,ry,ryx,vryx]=rdueelis('inpchmod(inpchans)',NaN,...
%                       'inpchan',[9.61e-10,9.61e-12]);
%
%       See also: ELIS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jul-2002

if nargin<1, error('No input argument'), end
model=getobjf(varargin{1},'fidmodel');
if isa(model,'idmodel'), model=fidmodel(model); end
if isa(model,'fidmodel')
  %New call
  if nargout>1
    error('More than one output variables are requested in new call')
  end
  if nargin>1
    error('More than one input arguments are given in new call')
  end
  pdat=model;
  cdat=model.covariance;
  Fdat=model.data;
  vdat=model.data.OldTbSisoVariance;
  expi=[]; inp=1; outp=1;
else
  %Old call
  if nargin<4, error('Less than 4 input arguments'), end
  model=[];
  pdat=varargin{1};
  cdat=varargin{2};
  Fdat=varargin{3};
  vdat=varargin{4};
  if nargin>=5, expi=varargin{5}; else expi=[]; end
  if nargin>=6, inp=varargin{6}; else inp=1; end
  if nargin>=7, outp=varargin{6}; else outp=1; end
end
%
neglvali=realmin;
%
%[domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr]=imppar(pdat,[]);
%
Fdat=getobjf(Fdat);
[freqv,xm,ym,expno]=impfou(Fdat,expi);
xm=xm(:,inp); ym=ym(:,outp);
F=length(freqv);
if isempty(expi), expi=[1:expno]'; end
n=length(expi);
%
if isstr(vdat)|(length(vdat(1,:))==1)
  [varx,vary,covxy]=impvar(vdat);
  varx=varx(:,inp); vary=vary(:,outp);
  if ~isempty(covxy), covxy=covxy(:,inp*outp); end
elseif (length(vdat(1,:))==2)|(length(vdat(1,:))==3)
  if any(any(imag(vdat(:,1:inp+outp))))
    error('Complex value in variance array')
  elseif any(isnan(vdat(:)))
    error('NaN value in variance array')
  elseif any(any(vdat(:,inp+outp)<0))
    error('Negative value in variance array')
  end
  if length(vdat(:,1))>1
    varx=vdat(:,2); vary=vdat(:,1);
    if length(vdat(1,:))==3, covxy=vdat(:,3); else covxy=[]; end
  else %constant variances
    varx=vdat(1)*ones(F,1); vary=vdat(2)*ones(F,1);
    if length(vdat)==3, covxy=vdat(3)*ones(F,1); else covxy=[]; end
  end
else
  error('vdat is not allowed')
end
if isempty(covxy), covxy=zeros(F,1);
elseif any(abs(covxy)>sqrt(varx.*vary)*(1+3*eps))
  error('abs(covxy) is larger than sqrt(varx.*vary)')
end
if length(freqv)~=length(varx)
  error('Lengths of the frequency vector and the variances are different')
end
%eliminate degenerate cases: both variances 0 or inf
ind2inf=find((varx==vary)&((varx==0)|(varx==inf)));
varx(ind2inf)=ones(length(ind2inf),1);
vary(ind2inf)=ones(length(ind2inf),1);
covxy(ind2inf)=zeros(length(ind2inf),1);
sdx=sqrt(varx(:,1)); sdy=sqrt(vary(:,1));
%
pdat=getobjf(pdat,'fidmodel');
if isnan(cdat)
  if isa(pdat,'fidmodel'), cdat=pdat.covariance;
  else error('cdat is NaN, but pdat is not fidmodel')
  end
end
tf=tfcalc(pdat,freqv);
%
[domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr]=imppar(pdat);
if ~any(findstr(domain,'z'))&~any(findstr(domain,'p')), fs=1; end
if ~isempty(ntr) %try to eliminate transients
  if ~any(domain=='pq')
    Df=tfcalc(exppar(domain,denom,1,0,1),freqv);
    Nft=tfcalc(exppar(domain,ntr,1,0,1),freqv);
  else %orthopol
    Df=orthpval(denom,Zdenom,freqv/fs,fs);
    Nft=orthpval(ntr,Zntr,freqv/fs,fs);
  end
  Nft=exp(-j*2*pi*delay*fs*freqv).*Nft;
  ym=ym-Nft./Df;
end
%
xe=zeros(F,1); ye=zeros(F,1);
for k=1:F %cycle to determine xe(k) and ye(k) from all experiments
  if (varx(k)==0)|(vary(k)>=inf)
    xe(k)=mean(xm(k+[0:F:(n-1)*F])); ye(k)=xe(k)*tf(k);
    if (abs(xe(k)-xm(k+[0:F:(n-1)*F]))>eps*10*abs(xe(k)))&(varx(k)==0)
      warning(sprintf(['For k = %.0f the input amplitudes in different ',...
                'experiments\n differ significantly in rdueelis, ',...
                'although varx(%.0f) = 0\n'],k,k))
    end
  elseif (vary(k)==0)|(varx(k)>=inf)
    ye(k)=mean(ym(k+[0:F:(n-1)*F])); xe(k)=ye(k)/(tf(k)+neglvali);
    if (abs(ye(k)-ym(k+[0:F:(n-1)*F]))>eps*10*abs(ye(k)))&(vary(k)==0)
      warning(sprintf(['For k = %.0f the output amplitudes in different ',...
                'experiments\n differ significantly in rdueelis, ',...
                'although vary(%.0f) = 0\n'],k,k))
    end
  else %regular case
    b=[]; A=[]; if any(abs(covxy)), W=eye(4*n); end
    for i=0:n-1
      %solve LS problem for real and imaginary part of xe
      %A*rix=b
      b=[b;
         real(xm(i*F+k))/sdx(k);...
         imag(xm(i*F+k))/sdx(k);...
         real(ym(i*F+k))/sdy(k);...
         imag(ym(i*F+k))/sdy(k)];
      A=[A;
         1/sdx(k),0;...
         0,1/sdx(k);...
         [real(tf(k)),-imag(tf(k))]/sdy(k)+neglvali;...
         [imag(tf(k)), real(tf(k))]/sdy(k)+neglvali];
      if covxy(k)~=0
        Wi=eye(4);
        Wp=[real(covxy(k)),imag(covxy(k));...
           -imag(covxy(k)),real(covxy(k))]/sdx(k)/sdy(k);
        Wi(1:2,3:4)=Wp; W(3:4,1:2)=Wp';
        W(i*4+[1:4],i*4+[1:4])=Wi;
      end %covxy
    end %for i
    if covxy(k)~=0
      rix=(inv(W)*A)\(inv(W)*b);
      %rix=inv(A'*inv(W)*A)*A'*(inv(W)*b);
    else
      rix=A\b;
    end
    xe(k)=rix(1)+sqrt(-1)*rix(2);
    ye(k)=xe(k)*tf(k);
  end %(varx(k)==0)|(vary(k)>=inf)
end %for k
%
rx=zeros(n*F,1); ry=zeros(n*F,1);
ryx=zeros(n*F,1);
for i=0:n-1 %cycle to determine residuals for each experiment
  rx(i*F+[1:F])=xm(i*F+[1:F])-xe;
  ry(i*F+[1:F])=ym(i*F+[1:F])-ye;
  if (nargout>2)|isa(model,'fidmodel')
    ryx(i*F+[1:F])=ym(i*F+[1:F])./xm(i*F+[1:F])-tf;
    if i==0 %first cycle
      vryx=(varx.*abs(tf).^2 + vary - 2*real(covxy.*conj(tf)))./abs(xm([1:F])).^2;
      if ~isempty(cdat)
        [tfs,stda,stdph,stdri]=stdtf(freqv,pdat,cdat);
        vsav=vryx;
        %%vryx=vryx-0.5*(stda.^2 + (abs(tfs).*stdph).^2);
        %vryx=vryx-0.5*(abs(stdri(:,1)).^2 + abs(stdri(:,2)).^2);
        if any(vryx<-10*eps*abs(vsav))
          warning('Negative vryx in rdueelis')
        end
        %ind=find( (vryx<0) );
        ind=find( (vryx<0) & (vryx>=-10*eps*abs(vsav)) );
        if ~isempty(ind), vryx(ind)=zeros(length(ind),1); end
      end %cdat
    end %i==0
  end %nargout>2
end %for i
%
varargout=cell(1,nargout);
varargout=cell(1,6);
if isa(model,'fidmodel')
  if isnumeric(vryx)&(length(vryx)==1), vryx=vryx*ones(size(ryx)); end
  varargout{1}=fiddata(ryx,ones(size(ryx)),model.data.freqpoints,...
    2*vryx,zeros(size(vryx)),'frequencies','neg');
else
  varargout{1}=rx;
  varargout{2}=ry;
  varargout{3}=ryx;
  varargout{4}=vryx;
  varargout{5}=xe;
  varargout{6}=ye;
end
%%%%%%%%%%%%%%%%%%%%%%%% end of rdueelis %%%%%%%%%%%%%%%%%%%%%%%%
