function costf=eliscost(varargin)
%ELISCOST Calculate value of elis cost function
%
%       costf=ELISCOST(model,data)
%
%       Output arguments:
%       costf = value of cost function
%
%       Input arguments:
%       model = fidmodel object (usually with Fourier data)
%       data = fiddata object (optional)
%
%       See also: ELIS.
%
%       Usage: costf=eliscost(model);

%Old fdident help
%ELISCOST Calculate value of elis cost function
%
%       costf=ELISCOST(pdat,Fdat,vdat)
%
%       Output arguments:
%       costf = value of cost function
%
%       Input arguments:
%       pdat = parameters of model (see exppar)
%       Fdat = Fourier data (see expfou)
%       vdat = variance data (see expvar)
%
%       See also: ELIS.
%
%       Usage: costf=eliscost(pdat,Fdat,vdat);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Jun-2001

pdat=getobjf(varargin{1},'fidmodel');
if isnumeric(pdat), pdat=fidmodel(pdat); end
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end

if nargin<2, Fdat=[]; else Fdat=varargin{2}; end
if isstr(Fdat), Fdat=getobjf(Fdat,'fiddata'); end
if nargin<3, vdat=[]; else vdat=varargin{3}; end
if isempty(Fdat), Fdat=pdat.data; end
if isempty(Fdat), error('Cannot find the data'), end
if isnumeric(Fdat), Fdat=fiddata(Fdat); end
if isempty(vdat)
  vdat=Fdat.OldTBSisoVariance;
  if isempty(vdat), error('Cannot find variance data'), end
else
  if size(vdat,2)==1, [vx,vy,covxy]=impvar(vdat); vdat=[vy,vx,covxy]; end
  set(Fdat,'SisoVariance',vdat*2,'noconsistency');
end
%
fs=[];
if (pdat.variable(1)~='z')&~strcmp(pdat.representation,'orthopol')
  freqv=Fdat.freqpoints;
  if iscell(freqv), freqv=cat(1,freqv{:}); end
  fs=pi*(min(freqv)+max(freqv));
  fscale=pdat.fscale;
  if (fscale<1e10*fs)&(fs<1e10*fscale), fs=fscale; end
end
%
type='elis'; %this is slower: for reference only
type='tfcalc'; %this is much quicker
if strcmp(type,'elis')
  warning('elis cost calculation calls ''elis'' (slow execution)')
  [domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr]=imppar(pdat,fs);
  runmod.initset='o';
  runmod.itmax=0;
  runmod.initmodel=pdat;
  if ~isempty(pdat.ntr), runmod.transients='on'; end
  runmod.plotdens=inf;
  devrunmod.displaymessages='off';
  if domain(1)=='z', runmod.fs=fs; else runmod.fscale=fs; end
  pv=elis(Fdat,domain,length(num)-1,length(denom)-1,runmod,devrunmod);
  costf=pv.fitinfo.cf;
elseif strcmp(type,'tfcalc')
  if size(Fdat,2)>1, Fdat=collapse(Fdat); end
  freqv=Fdat.freqpoints;
  if iscell(freqv)
    if all(size(freqv)==[2,1])
      freqv=cat(1,freqv{:});
    else
      error('freqv is too large a cell array')
    end
  end
  [tf,Nf,Df,Nft]=tfcalc(pdat,freqv);
  if size(vdat,1)==1, vdat=ones(size(freqv))*vdat; end
  varx=vdat(:,2); vary=vdat(:,1);
  covxy=[]; if size(vdat,2)==3, covxy=vdat(:,3); end
  if all(isnan(covxy(:))), covxy=[]; end
  Emd=varx.*abs(Nf).^2+vary.*abs(Df).^2;
  if ~isempty(covxy)
    Emd=Emd-2*real(covxy.*conj(Nf).*Df);
  end
  %
  Uf=Fdat.input; Yf=Fdat.output;
  Esm=Uf.*Nf-Yf.*Df;
  if ~isempty(Nft), Esm=Esm+Nft; end
  Esm=Esm./sqrt(2*Emd);
  costf=real(Esm'*Esm);
else
  error('Invalid type')
end
%
%End of eliscost
