function [tfm,stdAm,stdphm]=stdtfm(varargin)
%STDTFM Empirical standard deviations of transfer function values.
%
%       tfdat=STDTFM(Fdat)
%
%       Output arguments:
%       tfdat = nonparametric transfer function estimate with variance
%
%       Input arguments:
%       Fdat = fiddata object with variance
%
%       Usage: tfdat=stdtfm(Fdat);
%       Example:  tfdat=stdtfm('emachine(emachine)');
%
%       See also: PLOTELTF, STDTF.

%Old fdident help
%STDTFM Empirical standard deviations of transfer function values.
%
%       [tfm,stdAm,stdphm]=STDTFM(Fdat,vdat)
%
%       Output arguments:
%       tfm = nonparametric transfer function estimate
%       stdAm = standard deviations of the absolute values of the transfer
%           function points (that is, standard deviations of the real and
%           imaginary parts)
%       stdph = standard deviations of the phases of the transfer
%           function points, in radians
%
%       Input arguments:
%       Fdat = Fourier data ([freq,x,y]), or Fourier vector (see EXPFOU),
%           or name of Fourier file
%       vdat = variance data: Nx2 variance array or Nx3 covariance array
%           ([vary,varx,covxy]), or row vector of variances (and maybe
%           covariance), or variance vector (see EXPVAR) or variance file name
%
%       Usage: [tfm,stdAm,stdphm]=stdtfm(Fdat,vdat);
%       Example:  [tfm,stdAm,stdphm]=stdtfm('emachine');
%
%       See also: PLOTELTF, STDTF.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 20-Jun-2002

Fdat=getobjf(varargin{1},'fiddata');
if isa(Fdat,'fiddata')
  %new call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,1,ni)), %earlier
  end
  if nargout>1, error('More than 1 output arguments'), end
  vdat=Fdat.OldTbSisoVariance;
  varx=Fdat.inputvariance;
  vary=Fdat.outputvariance;
  if isnumeric(varx), varx=varx/2;
  else
    for ii=1:length(varx), varx{ii}=varx{ii}/2; end
  end
  if isnumeric(vary), vary=vary/2;
  else
    for ii=1:length(vary), vary{ii}=vary{ii}/2; end
  end
  covxy=Fdat.covvect;
  if isnumeric(covxy), covxy=covxy/2;
  else
    F=Fdat.freqn;
    for ii=1:length(covxy)
      if isempty(covxy{ii}), covxy{ii}=zeros(F{ii},1);
      else covxy{ii}=covxy{ii}/2;
      end
    end
  end
else
  %old call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,2,ni)), %earlier
  end
  vdat=varargin{2};
end
%
if isstr(Fdat)
  [Fdat,Ffnam,ext]=fnamanal(Fdat,'fbn');
  if strcmp(ext,'m'), error('Extention of Fdat is ''.m'''), end
  [freqv,xm,ym,expno]=impfou(Fdat); F=length(freqv);
elseif isa(Fdat,'fiddata')
  [freqv,xm,ym,expno]=impfou(Fdat);
  if isnumeric(freqv), F=length(freqv); else F=Fdat.FreqNumber; end
else %Vector or array
  if length(Fdat(1,:))==3 %array
    freqvl=Fdat(:,1); fl=length(freqvl); xm=Fdat(:,2); ym=Fdat(:,3);
    ind=find([freqvl;freqvl(1)]==freqvl(1));
    for ii=2:length(ind)
			F=ind(ii)-1;
			if rem(fl/F,1)==0
				fvlrsh=reshape(freqvl,F,fl/F);
				if ~any(any(diff(fvlrsh))), break, end
			end
		end
		expno=length(freqvl)/F;
    freqv=freqvl(1:F);
    for i=1:expno-1
      if any(abs(freqv-freqvl(i*F+[1:F]))>100*eps)
        error(sprintf('freqvl is not periodic with length %.0f',F))
      end
    end
  elseif min(size(Fdat))>1
    error('Fdat is an illegal array')
  else %Fourier vector
    [freqv,xm,ym,expno]=impfou(Fdat); F=length(freqv);
  end
end
%
if isstr(vdat)|(isnumeric(vdat)&(size(vdat,2)==1))
  [varx,vary,covxy]=impvar(vdat);
  varx=varx(:,1); vary=vary(:,1);
  if ~isempty(covxy), covxy=covxy(:,1); end
elseif isnumeric(vdat)&any(size(vdat,2)==[2,3])
  if any(any(imag(vdat(:,1:2))))
    error('Imaginary value in variance array')
  elseif any(isnan(vdat(:)))
    disp('WARNING! NaN value in variance array in stdtfm')
  elseif any(any(vdat(:,1:2)<0))
    error('Negative value in variance array')
  end
  if length(vdat(:,1))>1
    varx=vdat(:,2); if all(isnan(varx)), varx=zeros(size(varx)); end
    vary=vdat(:,1);
    if length(vdat(1,:))==3, covxy=vdat(:,3); else covxy=[]; end
  else %constant variances
    varx=vdat(2)*ones(F,1); if all(isnan(varx)), varx=zeros(size(varx)); end
    vary=vdat(1)*ones(F,1);
    if length(vdat(1,:))==3, covxy=vdat(3)*ones(F,1); else covxy=[]; end
  end
elseif isa(Fdat,'fiddata')&iscell(vdat)
  %Nothing to do
elseif isempty(vdat)
else
  error('vdat is not allowed')
end
if isempty(covxy)&isnumeric(varx)&~isempty(varx), covxy=zeros(F,1); end
%
if isnumeric(xm)
  xm={xm}; ym={ym}; F={F}; varx={varx}; vary={vary}; covxy={covxy};
  cellout=0;
else
  cellout=1;
end
tfm=cell(size(xm)); vartf1=tfm; stdtf1=vartf1; stdAm=stdtf1; stdphm=stdtf1;
for ii=1:size(xm,2)
  tfm{ii}=ym{ii}./xm{ii};
  tfm1=tfm{ii}(1:F{ii});
  if ~isempty(varx{ii})&~isempty(vary{ii})
    vartf1{ii}=(varx{ii}.*abs(tfm1).^2 + vary{ii} - 2*real(covxy{ii}.*conj(tfm1)))...
      ./abs(xm{ii}([1:F{ii}]')).^2;
  elseif ~isempty(varx{ii})
    vartf1{ii}=(varx{ii}.*abs(tfm1).^2)...
      ./abs(xm{ii}([1:F{ii}]')).^2;
  elseif ~isempty(vary{ii})
    vartf1{ii}=(vary{ii})...
      ./abs(xm{ii}([1:F{ii}]')).^2;
  end
  if ~isempty(vartf1{ii})
    indeps=find( vartf1{ii}.*abs(xm{ii}(1:F{ii}).^2)<-eps*10*max(varx{ii}.*abs(tfm1).^2 + ...
      vary{ii}) );
    if ~isempty(indeps)
      error(['Negative var(tfm) obtained in stdtfm: Fdat and vdat may be ',...
        'incompatible'])
    end
    ind0=find(vartf1{ii}<0);
    if ~isempty(ind0), vartf1{ii}(ind0)=zeros(length(ind0),1); end
  end
  stdtf1{ii}=sqrt(vartf1{ii});
  if length(stdAm{ii})==1
    stdAm{ii}=zeros(expno*F{ii},1);
    for i=0:expno-1, stdAm{ii}(i*F{ii}+[1:F{ii}])=stdtf1{ii}; end
  else
    if ~isempty(stdtf1{ii}), stdAm{ii}=stdtf1{ii}; %new Mar 23
    else stdAm{ii}=zeros(F{ii},1);
    end
  end
  stdphm{ii}=stdAm{ii}./abs(tfm{ii});
end %for ii
if cellout==0
  tfm=tfm{1}; stdAm=stdAm{1}; stdphm=stdphm{1};
end
if isa(Fdat,'fiddata')
  if ~iscell(tfm)
    inp=ones(size(tfm));
    if iscell(vartf1)&(length(vartf1)==1), vartf1=vartf1{1}; end
    vinp=2*vartf1;
    voutp=zeros(size(vartf1));
  else
    inp=cell(size(tfm)); vinp=inp; voutp=inp;
    for ii=1:length(tfm)
      inp{ii}=ones(size(tfm{ii}));
      vinp{ii}=2*vartf1{ii};
      voutp{ii}=zeros(size(vartf1{ii}));
    end %for ii
  end
  if isnumeric(inp)&(size(inp,1)>length(Fdat.freqpoints))
    inp=num2cell(inp.',1); tfm=num2cell(tfm.',1);
  end
  tfm=fiddata(tfm,inp,Fdat.freqpoints,vinp,voutp);
end
%%%%%%%%%%%%%%%%%%%%%%%% end of stdtfm %%%%%%%%%%%%%%%%%%%%%%%%
