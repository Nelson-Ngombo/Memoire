function [Fdatm,vdatm]=modifyfv(varargin)
%MODIFYFV Modify Fourier and variance data by given transfer function.
%
%       Fdatm=MODIFYFV(Fdat,pdat,plotmode)
%
%       'Remove' the effect of a given transfer function (fix poles/zeros
%       or calibration data) from Fourier amplitudes and variances.
%
%       Output arguments:
%       Fdatm = modified fiddata object
%
%       Input arguments:
%       Fdat = fiddata object with variance
%       pdat = fidmodel (or maybe fiddata) object
%       plotmode = frequency axis on plot: 'lin' or 'log', maybe extended by
%           pb (not to plot the zeros of the transfer function).
%           Default: 'linpb'.
%           If plotmode has any other value, no plot will be shown.
%
%       Usage: Fdatm=modifyfv(Fdat,pdat,plotmode);
%       Example: Fdatm=modifyfv('inpchan','inpchmod(inpchanz)');

%Old fdident help
%MODIFYFV Modify Fourier (maybe also variance) data by given transfer function.
%
%       [Fdatm,vdatm]=MODIFYFV(pdat,Fdat,vdat,plotmode)
%
%       'Remove' the effect of a given transfer function (fix poles/zeros) from
%       Fourier amplitudes and variances.
%
%       Output arguments:
%       Fdatm = modified 'Fourier' vector (see expfou), or
%           array: [freqv,x,y], if Fdat is also an array
%       vdatm = modified 'variance' vector (see expvar), or array:
%           [varx,vary,covxy] or [varx,vary], if vdat is also an array
%
%       Input arguments:
%       pdat = 'parameter' vector, or name of the parameter file (see exppar)
%       Fdat = 'Fourier' vector, or name of the input Fourier file,
%           or array: [freqv,x,y]
%       vdat = 'variance' vector, or name of the input variance file,
%           or array: [varx,vary,covxy] or [varx,vary]
%           (may be omitted, if only a Fourier file is to be modified)
%       plotmode = frequency axis on plot: 'lin' or 'log', maybe extended by
%           pb (not to plot the zeros of the transfer function).
%           Default: 'linpb'.
%           If plotmode has any other value, no plot will be shown.
%
%       Usage: [Fdatm,vdatm]=modifyfv(pdat,Fdat,vdat,plotmode);
%       Example: Fdatm=modifyfv('inpchmod(inpchanz)','inpchan');

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 28-Nov-2000

Fdat=getobjf(varargin{1},'fiddata');
if isa(Fdat,'fiddata')
  %new call
  newcall=1;
  error(nargchk(2,3,nargin))
  vdat=Fdat.OldTBSisoVariance;
  pdat=getobjf(varargin{2},'fidmodel');
  if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
  if isstr(pdat), pdat=getobjf(varargin{2},'fiddata'); end
  if nargin<3, plotmode=''; else plotmode=varargin{3}; end
  if isempty(plotmode), plotmode='linpb'; end
else
  %old call
  newcall=0;
  pdat=varargin{1};
  Fdat=varargin{2};
  if nargin<3, vdat=''; else vdat=varargin{3}; end
  if nargin<4, plotmode='linpb'; else plotmode=varargin{4}; end
end
if length(plotmode)<3, plotmode='noplot'; end
%
if ~isempty(Fdat)
  if isa(Fdat,'fiddata')|isstr(Fdat)|(length(Fdat(1,:))==1)
    [freq,x,y,expno]=impfou(Fdat); Fvectform=1;
    x=x(:,1); y=y(:,1);
  else
    expno=1; freq=Fdat(:,1); x=Fdat(:,2); y=Fdat(:,3); Fvectform=0;
  end
  F=length(freq);
  shind=1:F;
  indpb=find((y(1:F)~=0)|(x(1:F)~=0)); %passband indices
  if length(plotmode)>=5
    if strcmp(plotmode(4:5),'pb'), shind=indpb; end
  end
end
%
if any(strncmp('lin',plotmode,3))|any(strncmp('log',plotmode,3))
  if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
  if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
  else blue='b'; red='r'; green='g';
  end
end
%
if ~isa(pdat,'fiddata')
  [domain,num,denom,delay,fs]=imppar(pdat);
  if domain=='s'
    tfp=exp(-sqrt(-1)*2*pi*freq/fs*delay).*polyval(num,sqrt(-1)*2*pi*freq)...
          ./polyval(denom,sqrt(-1)*2*pi*freq);
  else
    tfp=exp(-sqrt(-1)*2*pi*freq*delay/fs)...
        .*polyval(num(length(num):-1:1),exp(-sqrt(-1)*freq*2*pi/fs))...
        ./polyval(denom(length(denom):-1:1),exp(-sqrt(-1)*freq*2*pi/fs));
  end
  if isstr(pdat)
    comments=['Modified by parameter file ',pdat];
  else
    comments='Modified by parameter vector';
  end
else %fiddata
  yf=pdat.output; xf=pdat.input;
  freqp=pdat.freqpoints;
  tfp=yf./xf;
  if ~isequal(freqp,freq)
    df=diff(freqp);
    freqp=[freqp(1)-df(1);freqp(:),freqp(end)+df(end)];
    if any(freq<min(freqp))|any(freq>max(freqp))
      error('Extrapolation outside the calibrated range')
    end
    dtf=diff(tfp);
    tfp=[tfp(1)-dtf(1);tfp(:);tfp(end)-dtf(end)];
    tfp=interp1(freqp,tfp,freq);
  end
end
%
tfpF=tfp;
if ~isempty(Fdat)
  for i=1:expno-1
    tfpF=[tfpF;tfp];
  end
  ym=y./tfpF;
  %
  %Plot
  tf=zeros(F,1); tfm=tf;
  tf(indpb)=y(indpb)./x(indpb); tfm(indpb)=ym(indpb)./x(indpb);
  tfi=find(tf==0);
  if length(tfi)>0, tf(tfi)=1e-5*ones(length(tfi),1); end
  tfmi=find(tfm==0);
  if length(tfmi)>0
    tfm(tfmi)=1e-5*ones(length(tfmi),1);
  end
  mag=20*log10(abs(tf)); ph=unwrap(angle(tf))/2/pi*360;;
  magm=20*log10(abs(tfm)); phm=unwrap(angle(tfm))/2/pi*360;
  %
  %Delete all axes objects in current figure
  %Use get because findobj may be missing (Matlab 4.1 or earlier)
  %delete(findobj(gcf,'Type','axes'));
  %
  if any(strncmp('lin',plotmode,3))|any(strncmp('log',plotmode,3))
    hax=get(gcf,'Children');
    if ~isempty(hax), for i=1:length(hax)
        if strcmp(get(hax(i),'Type'),'axes'), delete(hax(i)), end
      end, end
    %
    if ~isempty(vdat), subplot(2,2,1), else subplot(1,2,1), end
    hold off
  end
  if strcmp(plotmode(1:3),'lin')
    plot(freq(shind),mag(shind),['.',green],'markersize',1)
    hold on
    plot(freq(shind),magm(shind),['+',red])
    hold off
    title('Amplitude')
    xlabel('Frequency (Hz)'), ylabel('dB')
    if ~isempty(vdat), subplot(2,2,2), else subplot(1,2,2), end
    plot(freq(shind),ph(shind),['.',green],'markersize',1)
    hold on
    plot(freq(shind),phm(shind),['+',red])
    hold off
    title('Phase')
    xlabel('Frequency (Hz)'), ylabel('degrees')
  elseif strcmp(plotmode(1:3),'log')
    if (freq(1)==0)&(shind(1)==1), shind(1)=[]; end
    semilogx(freq(shind),mag(shind),['.',green],'markersize',1)
    hold on
    plot(freq(shind),magm(shind),['+',red])
    hold off
    title('Amplitude')
    xlabel('Frequency (Hz)'), ylabel('dB')
    subplot(1,2,2)
    semilogx(freq(shind),ph(shind),['.',green],'markersize',1)
    hold on
    plot(freq(shind),phm(shind),['+',red])
    hold off
    title('Phase')
    xlabel('Frequency (Hz)'), ylabel('degrees')
  end
  %
  if nargout>=1
    if newcall==1
      Fdatm=fiddata(ym,x,freq);
    else
      if Fvectform==1
        Fdatm=expfou(freq,x,ym);
      else
        Fdatm=[freq,x,ym];
      end
    end
  end
end %Modification of Fourier file
%
if ~isempty(vdat)
  covxy=[];
  if isstr(vdat)|(length(vdat(1,:))==1)
    [varx,vary,covxy]=impvar(vdat); vvectform=1;
    varx=varx(:,1); vary=vary(:,1); if ~isempty(covxy), covxy=covxy(:,1); end
  elseif (length(vdat(1,:))==2)|(length(vdat(1,:))==3)
    vvectform=0;
    if any(any(imag(vdat(:,1:2))))
      error('Complex value in variance array')
    elseif any(isnan(vdat(:)))
      error('NaN value in variance array')
    elseif any(any(vdat(:,1:2)<0))
      error('Negative value in variance array')
    end
    if length(vdat(:,1))>1
      varx=vdat(:,1); vary=vdat(:,2);
      if length(vdat(1,:))==3, covxy=vdat(:,3); end
    else %constant variances
      varx=vdat(1)*ones(F,1); vary=vdat(2)*ones(F,1);
      if length(vdat)==3, covxy=vdat(3)*ones(F,1); end
    end
  else
    error('vdat is not allowed')
  end
  varym=vary./abs(tfp).^2;
  if ~isempty(covxy), covxy=covxy./tfp; end
  if vvectform==1
    vdatm=expvar(varx,varym,covxy);
    if newcall==1, error('expvect form with new call'), end
  else
    vdatm=[varx,varym,covxy];
    if newcall==1, Fdatm.SisoVariance=2*vdatm; end
  end
  %
  %plot
  if isempty(Fdat), shind=1:F; end
  varxsh=varx; varysh=vary; varymsh=varym;
  ind0=find(varxsh==0); varxsh(ind0)=1e-10*ones(length(ind0),1);
  ind0=find(varysh==0); varysh(ind0)=1e-10*ones(length(ind0),1);
  ind0=find(varymsh==0); varymsh(ind0)=1e-10*ones(length(ind0),1);
  subplot(2,2,3)
  hold off
  if strcmp(plotmode(1:3),'lin')
    plot(freq(shind),10*log10(varxsh(shind)),['+',red])
    title('Input variance')
    xlabel('Frequency (Hz)'), ylabel('dB')
    subplot(2,2,4)
    plot(freq(shind),10*log10(varysh(shind)),['.',green],'markersize',1)
    hold on
    plot(freq(shind),10*log10(varymsh(shind)),['+',red])
    hold off
    title('Output variance')
    xlabel('Frequency (Hz)'), ylabel('dB')
  elseif strcmp(plotmode(1:3),'log')
    if (freq(1)==0)&(shind(1)==1), shind(1)=[]; end
    semilogx(freq(shind),10*log10(varxsh(shind)),['+',red])
    title('Input variance')
    xlabel('Frequency (Hz)'), ylabel('dB')
    subplot(2,2,4)
    semilogy(freq(shind),10*log10(varysh(shind)),['.',green],'markersize',1)
    hold on
    plot(freq(shind),10*log10(varymsh(shind)),['+',red])
    hold off
    title('Output variance')
    xlabel('Frequency (Hz)'), ylabel('dB')
  end
end %isempty(vdat)
%%%%%%%%%%%%%%%%%%%%%%%% end of modifyfv %%%%%%%%%%%%%%%%%%%%%%%%
