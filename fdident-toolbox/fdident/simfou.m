function varargout=simfou(varargin)
%SIMFOU Generate simulated Fourier amplitudes.
%
%       outdata=SIMFOU(pdat,Fdat,expno)
%
%       Output argument:
%       simdata = fiddata object
%
%       Input arguments:
%       pdat = fidmodel object (or maybe fiddata object)
%       Fdat = fiddata object
%          Fdat.input = complex input amplitude vector
%          Fdat.output = arbitrary, with proper length
%          Fdat.SisoVariance must be filled in.
%          if Fdat is empty or missing, and
%            - if pdat is fidmodel, pdat.data is taken, and must not be empty
%            - if pdat is fiddata, pdat itself is taken, and must not be empty
%       expno = (optional) number of experiments to be generated;
%           if omitted or empty, the default is 1.
%
%       Usage: outdata=simfou(pdat,Fdat,expno);
%       Example: simdata=simfou('inpchmod(inpchans)',...
%             fiddata(NaN*ones(49,1),ones(49,1),400*[1:49],1e-9,1e-9));
%             sf=simfou('bandpmod(bkfit)',[],10);
%             load inpchan
%             sf2=simfou(inpchan,{10;2}*inpchan); %add large noise
%
%       See also: SIMTIME.

%Old fdident help
%SIMFOU Generate simulated Fourier amplitudes.
%
%       [x,y]=SIMFOU(pdat,freqv,x0,vdat,expno)
%
%       Output arguments:
%       x = complex input column vector
%       y = complex output column vector
%
%       Input arguments:
%       pdat = the parameter vector (see EXPPAR) or the name of the parameter
%           file
%       freqv = frequency vector
%       x0 = input complex amplitude vector; if it is empty, the input
%           amplitudes will be all chosen equal to 1.
%       vdat = variance: if this is a string or a column vector, the
%           variances will be obtained via IMPVAR; if this is an array
%           (Nx2 or Nx3, N>1), this is supposed to consist of the input and
%           output variance vectors (and maybe the input/output covariance
%           vector; in the case of an 1x2 or 1x3 vector, these values mean
%           the constant input and output variances and maybe the covariance.
%       expno = (optional) number of experiments to be generated;
%           if omitted or empty, the default is 1.
%
%       Usage: [x,y]=simfou(pdat,freqv,x0,vdat,expno);
%       Example: load inpchold
%                [x,y]=simfou(pvect,400*[1:49],[],1e-9*[1,1]);
%
%       See also: SIMTIME.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 17-Jun-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,5); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,5,ni)), %earlier
end
pdat=getobjf(varargin{1},'fidmodel');
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
if isstr(pdat), pdat=getobjf(varargin{1},'fiddata'); end
%
if isa(pdat,'fidmodel')
  %new call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,3,ni)), %earlier
  end
  if nargout>1, error('More than one output argument'), end
  if nargin>=2, Fdat=varargin{2}; else Fdat=[]; end
  if isempty(Fdat), Fdat=pdat.data; end
  if ~isa(Fdat,'fiddata'), error('Fdat is not fiddata'), end
  freqv=Fdat.freqpoints;
  x0=Fdat.input;
  vdat=Fdat.OldTBSisoVariance;
  if isempty(vdat), error('Variance is not given')
  elseif size(vdat,2)<2
    vary=Fdat.outputvariance/2;
    varx=Fdat.inputvariance/2;
    covxy=Fdat.covvect/2;
    if length(varx)<length(freqv), varx=varx(ones(length(freqv),1)); end
    if isempty(vary), vary=0*varx; end
    vdat=[];
  end
  if nargin<3, expno=1; else expno=varargin{3}; end
elseif isa(pdat,'fiddata')
  %new call, simulate from fiddata
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,3,ni)), %earlier
  end
  Fdat=pdat;
  if nargout>1, error('More than one output argument'), end
  if nargin>=2, Fdat2=varargin{2}; else Fdat2=[]; end
  if isempty(Fdat2), Fdat2=pdat; Fp=1; else Fp=0; end
  if ~isa(Fdat2,'fiddata'), error('Fdat is given, but not as fiddata'), end
  freqv=Fdat.freqpoints;
  fexc=get(Fdat,'frequencies');
  x0=Fdat.input;
  vdat=Fdat2.OldTBSisoVariance;
  if isempty(vdat), error('Variance is not given'), end
  if nargin<3, expno=1; else expno=varargin{3}; end
  if isempty(expno), expno=pdat.expn; end
else
  %old call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(4,5); %Matlab 2016a or later
  else ni=nargin; error(nargchk(4,5,ni)), %earlier
  end
  freqv=varargin{2};
  x0=varargin{3};
  if isempty(x0), x0=ones(size(freqv)); end
  vdat=varargin{4};
  if nargin>=5, expno=varargin{5}; else expno=1; end
end
freqv=freqv(:); %column vector
fl=length(freqv);
%
if isempty(x0), x0=ones(fl,1); end
x0=x0(:); if isnumeric(x0), xl=length(x0); else xl=length(x0{1}); end
if xl~=fl
  error('Numbers of frequencies and amplitudes are different')
end
%
if ~isa(pdat,'fiddata')
  [domain,num,denom,delay,fs,Znum,Zdenom,dummy8,dummy9,dummy10,dummy11,tauR]=imppar(pdat);
  if ~any(findstr(domain,'z')), fs=1; end
  if any(domain=='swp') %Check stability
    if domain~='p'
      %attempt to find ideal scaling freq
      pdattmp=exppar(domain,num,denom,delay);
      %[domain,num,denom,delay,fs]=imppar(pdattmp,[]);
    end
    if strcmp(domain,'s')
      unst=any(real(roots(denom))>=0);
    elseif strcmp(domain,'w')
      unst=any(real(roots(denom).^2)>=0);
    elseif strcmp(domain,'p')
      unst=any(real(ortroots(denom,Zdenom))>=0);
    end
  else %z-domain
    unst=any(abs(roots(denom))>=1);
  end
  if unst==1, disp('WARNING! The given system is unstable in simfou'), end
  %
  tf=tfcalc(exppar(domain,num,denom,delay,fs,Znum,Zdenom,[],[],[],[],[],[],tauR),freqv);
  if iscell(x0), y0=x0; for ii=1:length(x0), y{ii}=tf.*x0{ii}; end
  else y0=tf.*x0;
  end
else %fiddata
  y0=pdat.output;
end
if fl<2, error('Frequency vector has to have at least two elements'), end
%
if isempty(vdat)
elseif isstr(vdat)|(length(vdat(1,:))==1)
  [varx,vary,covxy]=impvar(vdat);
  varx=varx(:,1); vary=vary(:,1);
  if ~isempty(covxy), covxy=covxy(:,1); end
elseif (length(vdat(1,:))==2)|(length(vdat(1,:))==3)
  if any(any(imag(vdat(:,1:2))))
    error('Imaginary value in variance array')
  elseif any(isnan(vdat(:)))
    error('NaN value in variance array')
  elseif any(any(vdat(:,1:2)<0))
    error('Negative value in variance array')
  end
  if length(vdat(:,1))>1
    varx=vdat(:,2); vary=vdat(:,1);
    if length(vdat(1,:))==3, covxy=vdat(:,3); else covxy=[]; end
  else %constant variances
    varx=vdat(2)*ones(fl,1); vary=vdat(1)*ones(fl,1);
    if length(vdat(1,:))==3, covxy=vdat(3)*ones(fl,1); else covxy=[]; end
  end
else
  error('vdat is not allowed')
end
sdx=sqrt(varx(:,1)); sdy=sqrt(vary(:,1));
if length(freqv)~=length(sdx)
  error('Lengths of the frequency vector and the variances are different')
end
%
if isstr(vdat)
  vtxt=[' and ''',vdat,''''];
elseif size(vdat,1)>1
  vtxt=' with given variance vectors';
else
  vtxt=sprintf(' with variances %.3g and %.3g',vary,varx);
end
for ii=1:expno
  Nx=sdx.*randn(fl,1)+sqrt(-1)*sdx.*randn(fl,1);
  Ny=sdy.*randn(fl,1)+sqrt(-1)*sdy.*randn(fl,1);
  ind=find((sdx~=0)&(sdy~=0));
  if ~isempty(covxy)&any(ind)
    mf=covxy(ind)./sdx(ind);
    Ny(ind)=sqrt(1-(abs(mf)./sdy(ind)).^2).*Ny(ind) + mf.*Nx(ind)./sdx(ind);
  end
  if iscell(x0), xii=x0{ii}+Nx; yii=y0{ii}+Ny;
  else xii=x0+Nx; yii=y0+Ny;
  end
  if isstr(pdat), commentF=['Simulated from file ''',pdat,'''',vtxt];
  else commentF=['Simulated from given params',vtxt];
  end
  if ii==1, x=xii; y=yii;
  else
    if isa(pdat,'fidmodel')
      if ii==2, x={x}; y={y}; end
      x=[x,{xii}]; y=[y,{yii}];
    else
      x=[x;xii]; y=[y;yii];
    end
  end
end %for ii
if isa(pdat,'fidmodel')|isa(pdat,'fiddata')
  if (expno>1)&isnumeric(y)
    yl=length(y);
    y=reshape(y,yl/expno,expno);
    y=num2cell(y,1);
    xl=length(x);
    x=reshape(x,xl/expno,expno);
    x=num2cell(x,1);
  end
  Fdat=fiddata(y,x,freqv);
  Fdat.Reference=x0;
  if isa(pdat,'fidmodel')
    Fdat.SisoVariance=vdat*2;
    varargout={Fdat};
  elseif isa(pdat,'fiddata')
    pv=pdat.OldTBSisoVariance;
    if ~isempty(pv)&any(any(pv))
      if Fp==0
        if ((size(pv,2)==3)&(any(~isnan(pv(:,3)))|any(pv(:,3)))) | ...
            ((size(pdat,2)==3)&(any(~isnan(pdat(:,3)))|any(pdat(:,3))))
          warning('Covariances are given in the file, but not used in simulation.')
        end
      end
      if (size(pv,1)==1)&(size(vdat,1)>1), pv=pv(ones(size(vdat,1),1),:); end
      if (size(pv,1)>1)&(size(vdat,1)==1), vdat=vdat(ones(size(pv,1),1),:); end
      if (size(pv,2)==2)&(size(vdat,2)==3), pv=[pv,zeros(size(pv,1),1)]; end
      if (size(pv,2)==3)&(size(vdat,2)==2), vdat=[vdat,zeros(size(vdat,1),1)]; end
      vdat=vdat+pv;
      if (expno>1)&any(isfinite(pv(:))&(pv(:)~=0))
        %warning(sprintf(['The initial variance given in the first argument (fiddata)',...
        %    '\n   will disappear when averaging several experiments']))
      end
    end
    Fdat.SisoVariance=vdat*2;
    if ~isempty(fexc), set(Fdat,'frequencies',fexc'), end
    varargout={Fdat};
  end %fiddata
else
  varargout={x,y};
end
%%%%%%%%%%%%%%%%%%%%%%%% end of simfou %%%%%%%%%%%%%%%%%%%%%%%%
