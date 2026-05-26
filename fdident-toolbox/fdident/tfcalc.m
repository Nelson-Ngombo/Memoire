function [tf,Nf,Df,Nft]=tfcalc(pdat,freqv)
%TFCALC Calculate transfer function values from parameters
%
%       [tf,Nf,Df,Nft]=TFCALC(pdat,freqv)
%
%       Output arguments:
%       tf = transfer function values
%       Nf = numerator values
%       Df = denominator function values
%       Nft = transient numerator values
%
%       Input arguments:
%       pdat = fidmodel object
%       freqv = frequency vector
%
%       Usage: [tf,Nf,Df,Nft]=tfcalc(pdat,freqv);

%Old fdident help
%TFCALC Calculate transfer function values from parameters
%
%       [tf,Nf,Df,Nft]=TFCALC(pdat,freqv)
%
%       Output arguments:
%       tf = transfer function values
%       Nf = numerator values
%       Df = denominator function values
%       Nft = transient numerator values
%
%       Input arguments:
%       pdat = fidmodel object or parameter vector (see exppar)
%       freqv = frequency vector
%
%       Usage: tf=tfcalc(pdat,freqv);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Aug-2002

Nft=[];
pdat=getobjf(pdat,'fidmodel');
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
if nargin<2, freqv=[]; end
if isempty(freqv)
  if isa(pdat,'fidmodel')
    Fdat=pdat.data;
    if ~isempty(Fdat), freqv=Fdat.freqpoints; end
  end
end
if isempty(freqv), error('freqv is not given'), end
if isa(freqv,'fiddata'), freqv=freqv.freqpoints; end
if min(size(freqv))~=1, error('freqv is not a vector'), end
freqv=freqv(:);
[domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,numt,Znumt,tauR]=imppar(pdat);
if ~any(findstr(domain,'z'))&~any(findstr(domain,'p'))&~any(findstr(domain,'q'))
  fs=1;
end
if strcmp(domain,'z')
  Nf=polyval(num(length(num):-1:1),exp(-j*freqv*2*pi/fs));
  Df=polyval(denom(length(denom):-1:1),exp(-j*freqv*2*pi/fs));
  if ~isempty(numt)&(nargout>=4)
    Nft=polyval(numt(length(numt):-1:1),exp(-j*freqv*2*pi/fs));
  end
elseif strcmp(domain,'s')
  Nf=polyval(num,j*2*pi*freqv/fs);
  Df=polyval(denom,j*2*pi*freqv/fs);
  if ~isempty(numt)&(nargout>=4)
    Nft=polyval(numt,j*2*pi*freqv/fs);
  end
elseif strcmp(domain,'p')
  Nf=orthpval(num,Znum,freqv/fs);
  Df=orthpval(denom,Zdenom,freqv/fs);
  if ~isempty(numt)&(nargout>=4)
    Nft=orthpval(numt,Znumt,freqv/fs);
  end
elseif strcmp(domain,'q')
  Nf=orthpval(num,Znum,freqv/fs,fs,'z');
  Df=orthpval(denom,Zdenom,freqv/fs,fs,'z');
  if ~isempty(numt)&(nargout>=4)
    Nft=orthpval(numt,Znumt,freqv/fs,'z');
  end
elseif strcmp(domain,'w')
  Nf=polyval(num,sqrt(j*2*pi*freqv/fs));
  Df=polyval(denom,sqrt(j*2*pi*freqv/fs));
  if ~isempty(numt)&(nargout>=4)
    Nft=polyval(numt,sqrt(j*2*pi*freqv/fs));
  end
elseif strcmp(domain,'r')
  Nf=polyval(num,tanh(j*2*pi*freqv*tauR));
  Df=polyval(denom,tanh(j*2*pi*freqv*tauR));
  if ~isempty(numt)&(nargout>=4)
    Nft=polyval(numt,tanh(j*2*pi*freqv*tauR));
  end
else
  error(['Domain ''',domain,''' not defined'])
end
Nf=exp(-j*freqv(:)*pi*delay/fs).*Nf(:);
Df=exp(j*freqv(:)*pi*delay/fs).*Df(:);
if ~isempty(numt)&(nargout>=4)
  Nft=exp(-j*freqv(:)*pi*delay/fs).*Nft(:);
end
tf=Nf./Df;
%%%%%%%%%%%%%%%%%%%%%%%% end of tfcalc %%%%%%%%%%%%%%%%%%%%%%%%
