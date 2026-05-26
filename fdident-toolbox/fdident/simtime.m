function varargout=simtime(varargin)
%SIMTIME Generate simulated input and output time series.
%
%       simdata=SIMTIME(pdat,excsig,expno,noisefilters,mode,delay)
%
%       Output argument:
%       simdata = simulated tiddata object
%
%       Input arguments:
%       pdat = fidmodel object; the delay must not be negative, and if mode
%           is 'transient', it will be rounded to the nearest integer.
%       excsig = excitation signal (tiddata object). dt must correspond
%           to ts in pdat if it is discrete.
%       expno = number of experiments (not yet implemented)
%       noisefilters = output and input noise filters: array of two fidmodels,
%           or row vector of two scalars which multiply unity white noise
%           The sampling frequency for the noise shaping filters is the same as
%           that of the parameter vector. The noise applied to the noise
%           shaping filters is assumed to have unity standard deviation (std).
%           This means that the variances of the complex Fourier amplitudes
%           (required by elis) are N*|num(f_k)/denom(f_k)|^2
%       mode = simulation mode: if the system given in pdat is a z-domain
%           one, 'transient' means response to transient input,
%           starting with energyless filter; 'periodic' means periodic
%           excitation, u is just one period. Default: 'periodic'
%           if the string 'ZOH' is added to the periodic mode, the ZOH tf is applied. 
%       delay = delay from energyless state of the system in s (not yet implemented)
%
%       Usage: simdata=simtime(pdat,excsig,expno,noisefilters,mode,delay);
%       Example: f=400*[1:49];
%                u=tiddata([],msinprep(f,msinclip(f,[],[],'',0),256,51200),151200);
%                simdata=simtime('inpchmod(inpchanz)',u,1,[3e-5,3e-5]);
%                simdatatr=simtime('inpchmod(inpchanz)',u,1,[3e-5,3e-5],'transient');
%
%       See also: SIMFOU.

%Old fdident help
%SIMTIME Generate simulated input and output time series.
%
%       [xt,yt]=SIMTIME(pdat,u,numi,denomi,numo,denomo,mode,fs,expno,delay)
%
%       Output arguments:
%       xt = input column vector
%       yt = output column vector
%
%       Input arguments:
%       pdat = parameter vector (see EXPPAR) or the name of the
%           parameter file; the delay must not be negative, and if mode is
%           'transient', it will be rounded to the nearest integer.
%       u = vector of input time series. dt=1/fs, where fs is the sampling
%           frequency, defined in pdat or by mode; it is the responsibility of
%           the user, to sample the desired excitation signal properly.
%       numi = numerator of the input observation noise shaping filter
%       denomi = denominator of the input observation noise shaping filter
%       numo = numerator of the output observation noise shaping filter
%       denomo = denominator of the output observation noise shaping filter
%           The sampling frequency for the noise shaping filters is the same as
%           that of the parameter vector. The noise applied to the noise
%           shaping filters is assumed to have unity standard deviation (std).
%           This means that the variances of the real and imaginary parts of
%           the Fourier amplitudes (required by elis) are
%           (N/2)*|num(f_k)/denom(f_k)|^2
%       mode = simulation mode: if the system given in pdat is a z-domain
%           one, 'transient' means response to transient input,
%           starting with energyless filter; 'periodic' means periodic
%           excitation, u is just one period. Default: 'periodic'
%           if the string 'ZOH' is added to the periodic mode, the ZOH tf is applied. 
%       fs = sampling frequency in u
%           For compatibility with earlier versions, fs may also be given
%           in place of mode if mode has default value.
%       expno = number of experiments to be generated (not yet implemented)
%       delay = delay from energyless state of the system in s (not yet implemented)
%
%       Usage: [xt,yt]=simtime(pdat,u,numi,denomi,numo,denomo,mode,fs);
%       Example: f=400*[1:49];
%                u=msinprep(f,msinclip(f,[],[],'',0),256,51200);
%                [xt,yt]=simtime('inpchmod(inpchanz)',u,3e-5,1,3e-5,1);
%                [xtr,ytr]=simtime('inpchmod(inpchanz)',u,3e-5,1,3e-5,1,'transient');
%
%       See also: SIMFOU.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,10); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,10,ni)), %earlier
end
pdat=getobjf(varargin{1},'fidmodel');
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
fsp=NaN;
[domain,num,denom,delayp,fspi]=imppar(pdat);
if any(findstr(lower(domain),'z'))
  fsp=fspi;
end
excsig=getobjf(varargin{2},'tiddata');
if isa(pdat,'fidmodel')&~isa(excsig,'tiddata')
  %warning('pdat is fidmodel, but u (excsig) is not tiddata')
end
expno=[]; mode='periodic'; delay=inf; fs=[];
numi=1; denomi=1; numo=1; denomo=1;
if isa(pdat,'fidmodel')&isa(excsig,'tiddata')
  %new call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,6); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,6,ni)), %earlier
  end
  if nargout>1, error('To many output arguments'), end
  u=excsig.input; fs=1/excsig.ts;
  if ~isnan(fsp)
    if abs(fsp-fs)>1000*eps*fs
      error('Sampling frequencies of system and of excitation signal differ')
    end
  end
  if nargin>=3, expno=varargin{3}; end
  if nargin>=4
    noisefilters=varargin{3};
    if isa(noisefilters,'fidmodel')
      for ii=1:length(noisefilters)
        if ii==1
          numo=noisefilters(1).num;
          denomo=noisefilters(1).denom;
          fso=noisefilters.fs;
          if ~isnan(fsp)
            if abs(fsp-fso)>1000*eps*fsp
              error('Sampling frequencies of system and of output noise filter differ')
            end
          end
          if abs(fs-fso)>1000*eps*fs
            error('Sampling frequencies of excitation signal and of output noise filter differ')
          end
        elseif ii==2
          numi=noisefilters(2).num;
          denomi=noisefilters(2).denom;
          fsi=noisefilters.fs;
          if ~isnan(fsp)
            if abs(fsp-fsi)>1000*eps*fsp
              error('Sampling frequencies of system and of input noise filter differ')
            end
          end
          if abs(fs-fsi)>1000*eps*fs
            error('Sampling frequencies of excitation signal and of input noise filter differ')
          end
          if abs(fso-fsi)>1000*eps*fso
            error('Sampling frequencies of input and output noise filter differ')
          end
        end
      end %for ii
    elseif isnumeric(noisefilters)&all(size(noisefilters)==[1,2])
      numo=noisefilters(1); numi=noisefilters(2);
    else
      error('Illegal noisefilters')
    end
  end
  if nargin>=5, mode=varargin{5}; end
  if nargin>=6, delay=varargin{6}; end
else
  %old call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(6,10); %Matlab 2016a or later
  else ni=nargin; error(nargchk(6,10,ni)), %earlier
  end
  if nargout>2, error('To many output arguments'), end
  u=excsig;
  numi=varargin{3};
  denomi=varargin{4};
  numo=varargin{5};
  denomo=varargin{6};
  if nargin>=7, mode=varargin{7}; end
  if isnumeric(mode)&(length(mode)==1), fs=mode; mode=''; end
  if nargin>=8, fs=varargin{8}; end
  if ~isnan(fsp)&~isempty(fs)&~isnan(fs)
    if abs(fs-fsp)>1000*eps*fsp
      error('Sampling frequencies of system and of excitation signal differ')
    end
  end
  if nargin>=9, expno=varargin{9}; end
  if nargin>=10, delay=varargin{10}; end
end
if isempty(expno), expno=1; end
if isempty(mode), mode='periodic'; end
if isempty(delay), delay=inf; end
if strcmp(mode,'periodicZOH'), mode='periodic'; isZOH=1; else isZOH=0; end

%delay, expno
if ~strcmp(domain,'z')&~strcmp(domain,'s')
  error('The domain must be ''z'' or ''s''')
end
if isempty(fs)|isnan(fs)
  mode='periodic';
  if strcmp(domain,'s')
    error('For s-domain the sampling frequency must be explicitly given')
  else
    fs=fsp;
  end
elseif strcmp(domain,'s')
  if isempty(fs)|any(imag(fs)~=0)|any(~isfinite(fs))|any(fs<=0)
    error('fs is not a positive real number')
  end
  mode='periodic';
end
if strcmp(domain,'z')&(max(abs(denom)/denom(1))>1e10)
  fprintf(['WARNING: the leading coefficient of the denominator',...
      '  is very small in simtime (maxdenom/denom(1)=%.5e)'],...
       max(abs(denom)/denom(1)))
end
if delayp<0
  error('The system delay must not be negative (predictor cannot be simulated)')
end
if ( strcmp(domain,'z')&(any(abs(roots(denom))>=1)) ) |...
        ( strcmp(domain,'s')&(any(real(roots(denom))>=0)) )
  error('System is not stable')
end
%
%1. response to excitation signal
if isnumeric(u)
  xt=u(:); N=length(xt);
else
  xt=cell(size(u));
  for ii=1:length(u), xt{ii}=u{ii}(:); end
  N=length(xt{1}); 
end
if N==0
  xt=[]; yt=[];
else
  if strcmp(mode,'transient')
    if isnumeric(xt)
      yt=filter(num,denom,xt);
      if round(delayp)~=delayp
        delayp=round(delayp);
        disp('WARNING: the system delay has been rounded in simtime')
      end
      yt=[zeros(delayp,1);yt(1:length(yt)-delayp)];
    else
      for ii=1:length(xt)
        yt{ii}=filter(num,denom,xt{ii});
        if round(delayp)~=delayp
          delayp=round(delayp);
          disp('WARNING: the system delay has been rounded in simtime')
        end
        yt{ii}=[zeros(delayp,1);yt{ii}(1:length(yt{ii})-delayp)];
      end
    end
  elseif strcmp(mode,'periodic')
    freqv=[0:N-1]'/N*fs;
    if strcmp(domain,'z')
      tf=exp(-sqrt(-1)*2*pi*delayp*freqv/fs)...
        .*fft([num,zeros(1,N-length(num))]')...
        ./fft([denom,zeros(1,N-length(denom))]');
    else %s-domain
      freqv2=freqv(1:floor((N+1)/2));
      tf2=exp(-sqrt(-1)*2*pi*delayp*freqv2)...
        .*polyval(num,sqrt(-1)*2*pi*freqv2)...
        ./polyval(denom,sqrt(-1)*2*pi*freqv2);
      tf=zeros(N,1);
      tf(1:floor(N/2))=tf2(1:floor(N/2)); tf(N:-1:ceil((N-1)/2)+2)=conj(tf2(2:end));
      %if rem(N,2)==0, tf(N/2+1)=mean(tf(N/2+[0,2])); end
    end
    if isZOH
      tfZOH=zeros(length(freqv),1);
      ind=find(freqv2>0); ind0=find(freqv2==0);
      if ~isempty(ind0), tfZOH(ind0)=ones(size(ind0)); end
      indtf=1:floor((N+1)/2);
      tfZOH(indtf(ind))=exp(-j*pi*freqv2(ind)/fs).*sin(pi*freqv2(ind)/fs)./(pi*freqv2(ind)/fs);
      tfZOH(N:-1:ceil((N-1)/2)+2)=conj(tfZOH(2:floor((N+1)/2)));
      %if rem(N,2)==0, tfZOH(N/2+1)=mean(tfZOH(N/2+[0,2])); end
      if isnumeric(xt), xt=real(ifft(tfZOH.*fft(xt)));
      else for ii=1:prod(size(xt)), xt{ii}=real(ifft(tfZOH.*fft(xt{ii}))); end
      end
    end
    if isnumeric(xt)
      yt=real(ifft(tf.*fft(xt)));
    else
      yt=cell(size(xt));
      for ii=1:length(xt)
        yt{ii}=real(ifft(tf.*fft(xt{ii})));
      end
    end
  else
    error(['type ''',mode,''' not allowed'])
  end
  %
  %2. Noise generation
  %
  if ~isempty(numi)&any(numi~=0) %input noise to be generated
    if length(denomi)>1
      poles=roots(denomi);
      if any(abs(poles)>=1-(1e-10))
        error('input noise shaping filter is not sufficiently stable')
      end
      if ~isempty(poles)&any(poles~=0)
        ntr=log(.01)/log(max(abs(poles)))+length(numi); %length of transients
      else
        ntr=length(numi);
      end
    else %zero order denominator
      ntr=length(numi);
    end
    if ~iscell(xt), xt={xt}; end
    for ii=1:length(xt)
      [noise,Zi]=filter(numi,denomi,randn(rem(ntr,N)+1,1));
      for k=1:ntr/N+1
        randnN1=randn(N,1);
        if isempty(Zi)
          noise=filter(numi,denomi,randnN1);
        else
          [noise,Zi]=filter(numi,denomi,randnN1,Zi);
        end
      end
      xt{ii}=xt{ii}+noise;
    end
  end %input noise generation
  %
  if ~isempty(numo)&any(numo~=0) %output noise to be generated
    if length(denomo)>1
      poles=roots(denomo);
      if any(abs(poles)>=1-(1e-10))
        error('output noise shaping filter is not sufficiently stable')
      end
      if ~isempty(poles)&any(poles~=0)
        ntr=log(.01)/log(max(abs(poles)))+length(numo); %length of transients
      else
        ntr=length(numo);
      end
    else %zero order denominator
      ntr=length(numo);
    end
    if ~iscell(yt), yt={yt}; end
    for ii=1:length(yt)
      [noise,Zi]=filter(numo,denomo,randn(rem(ntr,N)+1,1));
      for k=1:ntr/N+1
        randnN1=randn(N,1);
        if isempty(Zi)
          noise=filter(numo,denomo,randnN1);
        else
          [noise,Zi]=filter(numo,denomo,randnN1,Zi);
        end
      end
      yt{ii}=yt{ii}+noise;
    end
  end %output noise generation
end
%
if iscell(xt)&(length(xt)==1), xt=xt{1}; yt=yt{1}; end

if isnumeric(u)&(length(u(:,1))==1), xt=xt'; yt=yt'; end
if isa(pdat,'fidmodel')&isa(excsig,'tiddata')
  %new call
  varargout={tiddata(yt,xt,1/fs)};
else
  %old call
  varargout={xt,yt};
end
%%%%%%%%%%%%%%%%%%%%%%%% end of simtime %%%%%%%%%%%%%%%%%%%%%%%%
