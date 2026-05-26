function pv=orthr2p(domain,rp,gain,Z,freqv,w,fs)
%ORTHR2P Calculate Forsythe parameters from roots
%
%       pv=orthr2p(domain,rp,gain,Z,freqv,w)
%
%       Output argument:
%       pv = polynomial vector
%
%       Input arguments:
%       domain = domain of the basis ('s' or 'p' means the same)
%       rp = vector of roots
%       gain = gain for the transfer function
%       Z = the weighting used in the recursion in orthopol
%       freqv = frequency vector
%       w = vector of linear weights (presumably 'best' weight to approximate ML)
%       fs = sampling frequency (for z-domain)
%
%       See also: ORTHOPOL, ORTROOTS, ORTHPVAL, ORTHZ.
%
%       Usage: pv=orthr2p(domain,rp,gain,Z,freqv,w);

%       Algorithm:
%       Calculate noiseless transfer function, then make a weighted fit

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Oct-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(5,7); %Matlab 2016a or later
else ni=nargin; error(nargchk(5,7,ni)), %earlier
end
if nargin<7, fs=[]; end, if isempty(fs), fs=1; end
%
if ~isstr(domain), error('domain is not a string'), end
if ~any(domain=='psz'), error(['domain ''',domain,''' is not allowed']), end
if nargin<6, w=[]; end
if nargin<5, freqv=[]; end
if (min(size(w))>1)
  error(sprintf('Size of w is %.0f x %.0f, not a vector',size(w,1),size(w,2)))
end
w=abs(w(:));
freqv=freqv(:);
if isempty(w), w=ones(size(freqv)); end
F=length(freqv);
if any(imag(freqv)~=0)|any(freqv<0)
  error('freqv is complex or negative')
end
Fdiff=sum(diff([sort(freqv);inf])~=0);
ord=length(rp);
if (ord+1>2*Fdiff)  %&(1==2)
  error(sprintf(['Number of different frequencies, %.0f of F=%.0f,',...
        ' is not enough for order %.0f'],Fdiff,F,ord))
end
%
if any(domain=='sp')
  if ord==1
    TF=gain*(j*2*pi*(ones(ord,1)*freqv')-(rp(:)*ones(1,F))).';
  else
    TF=gain*prod(j*2*pi*(ones(ord,1)*freqv')-(rp(:)*ones(1,F))).';
  end
else %'z'
  if ord==1
    TF=gain*exp(j*2*pi*(ones(ord,1)*freqv'/fs)-(rp(:)*ones(1,F)))';
  else
    TF=gain*prod(exp(j*2*pi*(ones(ord,1)*freqv'/fs)-(rp(:)*ones(1,F))))';
  end
end
pvalarr=orthopol(ord,domain,freqv,[],Z,fs);
%pvalarr*p'=TF;
w2=[w;w];
A=w2(:,ones(1,ord+1)).*[real(pvalarr);imag(pvalarr)];
B=w2.*[real(TF);imag(TF)];
pv=(A\B)';
%
%End of orthr2p
