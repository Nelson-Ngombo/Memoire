function [pvalarr,Z]=orthopol(ord,domain,freqv,w,Zold,fs)
%ORTHOPOL Forsythe orthogonal polynomials
%
%       [pvalarr,Z]=ORTHOPOL(ord,domain,freqv,w,Zold,fs)
%
%       Output arguments:
%       pvalarr = array of values of polynomials at the given frequencies 
%                 dimension: F x ord+1
%       Z = column vector (s-domain) or lower triangular array (z-domain) 
%           of recursion coefficients
%
%       Input arguments:
%       ord = order of the polynomial set
%       domain = domain of the basis ('s' or 'p' means the same), maybe 'z' or 'q'
%       freqv = frequency vector
%       w = vector of linear weights (multiplying weight when forming scalar product)
%       Zold = old Z: if w is empty, and Zold is given, Zold is used
%              in the recursion instead of Z
%       fs = sampling frequency (z-domain)
%
%       See also: ORTROOTS, ORTHPVAL, ORTHZ.
%
%       Usage: [pvalarr,Z]=orthopol(ord,domain,freqv,w,Zold,fs);

%       Algorithm:
%       Y. Rolain, R. Pintelon, K. Q. Xu and H. Vold, "Best Conditioned
%         Parametric Identification of Transfer Function Models in the
%         Frequency Domain," IEEE Trans. on Automatic Control, Vol. 40, No. 11,
%         pp. 1954-60, Nov. 1995. 
%       Y. Rolain, J. Schoukens and R. Pintelon, "Order Estimation for Linear
%         Time-Invariant Systems Using Frequency Domain Identification Methods,"
%         Proc. 34th IEEE Conference on Decision and Control, New Orleans,
%         pp. 3588-3593, Dec. 1995.
%       R. Pintelon and J. Schoukens, System Identification, a Frequency Domain 
%         Approach. IEEE Press, 2001.
%
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-2001

if any(domain=='ps')
  %if nargin>=6, error('fs given for s-domain'), end
elseif any(findstr(domain,'z'))|any(domain=='q')
  if nargin<6, fs=[]; end, if isempty(fs), fs=1; end
  if length(fs)~=1, error('fs is not a scalar'), end
  if imag(fs)|~isfinite(fs)|(fs<=0), error('fs is not positive'), end
else
  error(['domain ''',domain,''' is not allowed'])
end
if isstr(ord), error('ord is a string'), end
if length(ord)~=1, error('ord is not a scalar'), end
if nargin<5, Zold=[]; end
if (min(size(w))>1)|(isempty(w)&isempty(Zold))
  error(sprintf('Size of w is %.0f x %.0f, not a vector, Zold is also empty',...
    size(w,1),size(w,2)))
end
if any(domain=='sp')
  if isempty(w)&~isempty(Zold)
    Z=Zold; Zoldused=1;
    if length(Zold)~=ord+1, error('length(Zold)~=ord+1'), end
    if any(imag(Zold)~=0)|any(Zold<=0)
      error('Complex or nonpositive Zold')
    end
  else
    %if both w and Zold are given, w will be used
    w=abs(w(:)); Z=zeros(ord+1,1); Zoldused=0;
  end
  freqv=freqv(:);
  if ~Zoldused&(any(size(freqv)~=size(w)))
    error('freqv and w do not match')
  end
  F=length(freqv);
  if any(imag(freqv)~=0), error('freqv is complex'), end
  Fdiff=sum(diff([sort(freqv);inf])~=0);
  if (ord+1>2*Fdiff-1)  %&(1==2)
    error(sprintf(['Number of different frequencies, %.0f of F=%.0f,',...
        ' is not enough for order %.0f'],Fdiff,F,ord))
  end
  %
  if ~Zoldused, Z(1)=sqrt(2)*sqrt(w'*w); end
  if nargout>0, pvw=ord+1; else pvw=3; end %with no output, 3 columns are enough
  pvalarr=[ones(F,1)/Z(1),j*realmin*ones(F,pvw-1)];
  %
  for r=1:ord
    if r==1
      pvalarr(:,r+1)=j*2*pi*freqv.*pvalarr(:,r);
    else %r>1
      pvalarr(:,r+1)=j*2*pi*freqv.*pvalarr(:,r)+Z(r)*pvalarr(:,r-1);
    end
    if ~Zoldused, Z(r+1)=sqrt(2)*norm(pvalarr(:,r+1).*abs(w)); end
    if Z(r+1)==0
      error(sprintf(['Z%.0f equals 0, number of different',...
          ' frequencies, Fd=%.0f is too small for order=%.0f']',r,Fdiff,ord))
    end
    %Normalize
    pvalarr(:,r+1)=pvalarr(:,r+1)/Z(r+1);
  end %for r
else %z-domain
  if isempty(w)&~isempty(Zold)
    Z=Zold; Zoldused=1;
    if any(size(Zold)~=ord+1), error('length(Zold)~=ord+1'), end
    if any(imag(Zold)~=0), error('Complex Zold'), end
  else
    %if both w and Zold are given, w will be used
    w=abs(w(:)); Z=zeros(ord+1,ord+1); Zoldused=0;
  end
  freqv=freqv(:);
  if ~Zoldused&(any(size(freqv)~=size(w)))
    error('freqv and w do not match')
  end
  F=length(freqv);
  if any(imag(freqv)~=0), error('freqv is complex'), end
  Fdiff=sum(diff([sort(freqv);inf])~=0);
  if (ord+1>2*Fdiff-1)  %&(1==2)
    error(sprintf(['Number of different frequencies, %.0f of F=%.0f,',...
        ' is not enough for order %.0f'],Fdiff,F,ord))
  end
  %
  pvalarr=[ones(F,1),j*realmin*ones(F,ord)];
  %Xzp=pvalarr;
  %
  if ~Zoldused
    Z(1)=norm(pvalarr(:,1).*w)*sqrt(2);
  end
  pvalarr(:,1)=pvalarr(:,1)/Z(1);
  xv=exp(-j*2*pi*freqv/fs);
  for r=1:ord
    zmrv=xv.*pvalarr(:,r); nz=norm(zmrv);
    if ~Zoldused
      scp=real((zmrv.*w)'*(pvalarr(:,1:r).*w(:,ones(1,r))))'; %column vector
      zmrv=zmrv-2*pvalarr(:,1:r)*scp;
      if norm(zmrv)<10*r*eps*nz
        error(sprintf(['Z%.0f equals 0, number of different',...
            ' frequencies, Fd=%.0f is too small for order=%.0f']',r,Fdiff,ord))
      end
      Z(r+1,r+1)=norm(zmrv.*w)*sqrt(2);
      if nargout>=2
        Zp=-2*scp;
        Z(r+1,1:r)=Zp';
      end
    else
      zmrv=zmrv+pvalarr(:,1:r)*Z(r+1,1:r)';
    end
    pvalarr(:,r+1)=zmrv/Z(r+1,r+1);
    %Normalize
  end %for r
  %if exist('Xzp'), pvalarr2=Xzp*Z; pvalarr-pvalarr2, end
end
if 0 %test of orthogonality
  if ~isempty(w)
    pvalarrm=pvalarr.*kron(ones(1,size(pvalarr,2)),w(:));
    scp=2*real(pvalarrm'*pvalarrm); %This should be identity
    if any(any(abs(scp-eye(ord+1))>prod(size(Z))*5e4*eps)),
      d=max(max(abs(scp-eye(ord+1)))); lim=prod(size(Z))*11e4*eps;
      error(['Orthopol base generation error in ',domain,'-domain'])
    end
  end
end
%
%End of orthopol
