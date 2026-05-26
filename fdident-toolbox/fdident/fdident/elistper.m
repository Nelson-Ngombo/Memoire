function varargout=elistper(varargin)
%ELISTPER Identify H(s), starting from time domain periodic input-output data.
%
%       pvect=ELISTPER(tdat,numord,denomord,delay,dfix,mr,pd)
%
%       Output arguments:
%       pvect = parameters in vector form (for imppar)
%       fit = informative column vector about the fit (see elis for details)
%       Cp = approximate covariance matrix of the parameters
%       Fdat = calculated Fourier data
%              (for new identification runs, see elisml or elis)
%       vdat = calculated variance data (for new identification runs):
%              [vy,vx,covxy]
%
%       Input arguments:
%       tdat = time domain data: tiddata object
%       numord = order of numerator
%       denomord = order of denominator
%       delay = delay in seconds (optional, default: 0)
%           for dfix=='v', delay is the starting value for the iterations
%       dfix = 'f' for fixed delay, 'v' for variable delay (default: 'f')
%       mr = (optional) run modifier for different nonideal situations
%          (only the default meaning and 'leak' are implemented at this moment)
%          - the default is when generator and sampling clocks are well
%            synchronized, and exactly N periods were measured.
%            This is set if mr is not given, or if it is empty.
%          Warning! The options below may only be used if anti-alias filters
%          were used in both data acquisition channels.
%          - 'leak' means that fs and fv are exact, but fs is not an
%            integer multiple of the elements of fv.
%          Not yet implemented:
%          - 'slip' means that fs and/or fv may slightly differ from the
%            given values (the two clocks slowly slip with respect to each
%            other), and correction for this is requested.
%          - 'approx' means that fs and/or fv is only approximate, and
%            their ratio is to be estimated from the data.
%       pd = plot density, default: only last one (100)
%
%       Algorithm: tim2fou, varanal and elis are invoked with appropriately
%       prepared data.
%
%       Usage: pvect=elistper(tdat,numord,denomord,delay,dfix,mr,pd);
%       Example: pvect=elistper('robotarm(robotarm_rawdata)',4,6);
%
%       See also: TIM2FOU, VARANAL, ELISML, ELIS.

%Old fdident help
%ELISTPER Identify H(s), starting from time domain periodic input-output data.
%
%       [pvect,fit,Cp,Fdat,vdat]=
%               ELISTPER(xt,yt,fs,fv,numord,denomord,delay,dfix,mr,pd)
%
%       Output arguments:
%       pvect = parameters in vector form (for imppar)
%       fit = informative column vector about the fit (see elis for details)
%       Cp = approximate covariance matrix of the parameters
%       Fdat = calculated Fourier data
%              (for new identification runs, see elisml or elis)
%       vdat = calculated variance data (for new identification runs)
%
%       Input arguments:
%       xt = vector of samples of the time domain input signal
%       yt = vector of samples of the time domain output signal
%       fs = sampling frequency in signal acquisition
%       fv = vector of frequencies of harmonic components
%       numord = order of numerator
%       denomord = order of denominator
%       delay = delay in seconds (optional, default: 0)
%           for dfix=='v', delay is the starting value for the iterations
%       dfix = 'f' for fixed delay, 'v' for variable delay (default: 'f')
%       mr = (optional) run modifier for different nonideal situations
%          (only the default meaning and 'leak' are implemented at this moment)
%          - the default is when generator and sampling clocks are well
%            synchronized, and exactly N periods were measured.
%            This is set if mr is not given, or if it is empty.
%          Warning! The options below may only be used if anti-alias filters
%          were used in both data acquisition channels.
%          - 'leak' means that fs and fv are exact, but fs is not an
%            integer multiple of the elements of fv.
%          Not yet implemented:
%          - 'slip' means that fs and/or fv may slightly differ from the
%            given values (the two clocks slowly slip with respect to each
%            other), and correction for this is requested.
%          - 'approx' means that fs and/or fv is only approximate, and
%            their ratio is to be estimated from the data.
%       pd = plot density, default: only last one (100)
%
%       Algorithm: tim2fou, varanal and elis are invoked with appropriately
%       prepared data.
%
%       Usage:
%       [pvect,fit,Cp,Fdat,vdat]=...
%              elistper(xt,yt,fs,fv,numord,denomord,delay,dfix,mr,pd);
%
%       See also: TIM2FOU, VARANAL, ELISML, ELIS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Jun-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,10); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,10,ni)), %earlier
end
tdat=getobjf(varargin{1},'tiddata');
delay=[]; dfix=''; mr=''; pd=[];
if isa(tdat,'tiddata')
  %new call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,6); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,6,ni)), %earlier
  end
  numord=varargin{2};
  denomord=varargin{3};
  if nargin>=4, delay=varargin{4}; end
  if nargin>=5, dfix=varargin{5}; end
  if nargin>=6, mr=varargin{6}; end
  if nargin>=7, pd=varargin{7}; end
  fv=tdat.frequencies; fs=1/tdat.ts;
  Nt=tdat.samplen; Tm=Nt/fs;
else
  %old call
  tdat=[];
  xt=varargin{1};
  yt=varargin{2};
  fs=varargin{3};
  fv=varargin{4};
  numord=varargin{5};
  denomord=varargin{6};
  if nargin>=7, delay=varargin{7}; end
  if nargin>=8, dfix=varargin{8}; end
  if nargin>=9, mr=varargin{9}; end
  if nargin>=10, pd=varargin{10}; end
  Nt=length(xt); Tm=Nt/fs;
end
domain='s'; fsm=NaN; %dummy scaling frequency in model estimation
if isempty(pd), pd=100; end
if strcmp(mr,'slip')|strcmp(mr,'approx')
  error(['mr = ''',mr,''' is not yet implemented'])
end
if ~isempty(mr)&~strcmp(mr,'leak')&...
        ~strcmp(mr,'slip')&~strcmp(mr,'approx')
  error(['mr = ''',mr,''' is not allowed'])
end
%
if isempty(dfix), dfix='f'; end
if ~isstr(dfix), error('dfix is not a string'), end
if ~strcmp(dfix,'f')&~strcmp(dfix,'v')
  error(['dfix = ''',dfix,''' is not allowed'])
end
if isempty(delay), delay=0; end
if isnan(delay), delay=0; end
if isstr(delay), error('delay is a string'), end
if length(delay)>1, error('delay is not a scalar'), end
if ~isfinite(delay), error('Infinite delay'), end
%
if length(numord)>1, error('numord is not a scalar'), end
if isstr(numord), error('numord is a string'), end
if round(numord)~=numord, error('numord is not an integer'), end
if numord<0, error('numord is negative'), end
if length(denomord)>1, error('denomord is not a scalar'), end
if round(denomord)~=denomord, error('denomord is not an integer'), end
if denomord<0, error('denomord is negative'), end
if length(fs)>1, error('fs is not a scalar'), end
fv=sort(fv(:)); F=length(fv);
%
if isempty(mr)|strcmp(mr,'leak')
  Npf=fv*Tm; %numbers of periods for each frequency
  ind=find(fv==0); Npf(ind)=[];
  if isempty(mr) %default
    if any(abs(Npf-round(Npf))>Nt*eps)
      error('Noninteger number of periods is found')
    end
    Npf=round(Npf);
    dNpfm=diff([0;Npf;Nt]);
    while any(dNpfm~=0)
      ind=find(dNpfm==0); if ~isempty(ind), dNpfm(ind)=[]; end
      Np=min(dNpfm);
      dNpfm=rem(dNpfm,Np);
      if any(dNpfm~=0), dNpfm=diff(sort([0;dNpfm;Np])); end
    end %while
    fprintf('elistper found Np = %.2g periods in the given data\n',Np)
  elseif strcmp(mr,'leak')
    Np=min(Npf);
    fprintf(['elistper found Np >= %.2g periods of each frequency ',...
        'in the given data\n'],Np)
  end
  if Np<3, error('Np is too small for variance analysis'), end
  if Np<5, disp('Warning! Np is quite small for reasonable variance analysis')
  end
  disp(['Transformation to frequency domain and variance analysis ',...
      'are being performed...'])
  if isa(tdat,'tiddata')
    Fdat=tim2fou(segment(tdat),mr);
    Fdat=varanal(Fdat);
  elseif isempty(mr) %default
    Fdat=tim2fou(exptim([1:Nt/Np]'/fs,xt,yt),fv);
    [vx,vy,cxy,mx,my,Na]=varanal(Fdat);
    Fdat=[fv,mx,my];
    vdat=[vy,vx,cxy]/Na;
  elseif strcmp(mr,'leak')
    expno=floor(Np+.01); lp=ceil(Nt/Np);
    x=zeros(expno*F,1)+j; y=x;
    for i=0:expno-1
      ei=1+round(i*Nt/Np); if ei>Nt-lp+1, ei=Nt-lp+1; end %starting index
      Fdati=tim2fou([[1:lp]'/fs,xt(ei:ei+lp-1),yt(ei:ei+lp-1)],fv,[],'leak');
      %set phases to same value in each exp:
      [fvi,xi,yi]=impfou(Fdati);
      xi=exp(-j*2*pi*fv*(ei-1)/fs).*xi;
      yi=exp(-j*2*pi*fv*(ei-1)/fs).*yi;
      x(i*expno+[1:F])=xi; y(i*expno+[1:F])=yi;
    end %for
    Fdat=expfou(fv,x,y);
    [vx,vy,cxy,mx,my,Na]=varanal(Fdat);
    Fdat=[fv,mx,my];
    vdat=[vy,vx,cxy]/Na;
  end
  disp('Parameter estimation follows ...')
  %Levenberg-Marquardt with svd, lambda=0; init: approximate ML
  rpalg=['ma'+0,NaN,NaN,NaN,0];
  rppl=pd; %only last plot
  if isa(tdat,'tiddata')
    pvect=elis(Fdat,[],[domain+0,numord,denomord,fsm],dfix,rpalg,rppl,delay);
    varargout={pvect};
  elseif nargout>=3
    [pvect,fit,Cp]=elis(Fdat,vdat,[domain+0,numord,denomord,fsm],dfix,rpalg,rppl,delay);
    varargout=cell(1,3);
    varargout{1}=pvect;
    varargout{2}=fit;
    varargout{3}=Cp;
    if nargout>=4, varargout{4}=Fdat; end
    if nargout>=5, varargout{5}=vdat; end
  else
    [pvect,fit]=elis(Fdat,vdat,[domain+0,numord,denomord,fsm],dfix,rpalg,rppl,delay);
    varargout=cell(1,2);
    varargout{1}=pvect;
    varargout{2}=fit;
  end
else
  error('mr is unknown')
end %mr
%
%%%%%%%%%%%%%%%%%%%%%%%% end of elistper %%%%%%%%%%%%%%%%%%%%%%%%
