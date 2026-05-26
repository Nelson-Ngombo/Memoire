function [pval,pcoeffarr,coeffs]=orthpval(ortcoeffs,Z,freqv,fsc,domain)
%ORTHPVAL Evaluate polynomial given by orthogonal set of polynomials
%
%       [pval,pcoeffarr,coeffs]=ORTHPVAL(ortcoeffs,Z,freqv,fsc,domain)
%
%       Output arguments:
%       pval = vector of polynomial values
%       WARNING! The following numbers are usually unreliable!
%       pcoeffarr = orthogonal polynomials in terms of powers of s or z^(-1). 
%                   first row: first OP in terms of s^ord ... s^1 s^0
%                          or in terms of z^-0 z^(-1) ... z^(-ord)
%       coeffs = polynomial in terms of powers of s or z
%
%       Input arguments:
%       ortcoeffs = vector of coefficients of polynomials
%       Z = recursion coefficients (see orthopol)
%       freqv = scaled frequency vector
%       fsc = scaling (sampling) frequency (optional, default: 1)
%       domain = 's', 'p', 'z' or 'q'(optional, default 's')
%
%       See also: ORTHOPOL, ORTROOTS, ORTHZ.
%
%       Usage: [pval,pcoeffarr,coeffs]=orthpval(ortcoeffs,Z,freqv,fsc,domain);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Aug-2002

if nargout>=3
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(5,5); %Matlab 2016a or later
  else ni=nargin; error(nargchk(5,5,ni)), %earlier
  end
end
if nargin<5, domain=''; end
if nargin<3, error('Not enough input arguments'), end
if min(size(ortcoeffs))~=1, error('ortcoeffs is not a vector'), end
ortcoeffs=ortcoeffs(:)'; ord=length(ortcoeffs)-1;
if min(size(Z))~=1
  if isempty(domain), domain='z'; end
  if ~any([findstr(domain,'z'),findstr(domain,'q')]), error('Z is not a vector'), end
elseif isempty(domain)
  domain='s';
end
if any(domain=='sp')
  Z=Z(:);
else %'zq'
  if diff(size(Z)), error('Z is not quadratic'), end
end
if length(Z)~=length(ortcoeffs), error('ortcoeffs and Z are incompatible'), end
if any(imag(Z(:))~=0)|(any(domain=='zq')&any(diag(Z)<=0)), error('Z is complex or nonpositive'), end
if isa(freqv,'fiddata'), freqv=freqv.freqpoints; end
if min(size(freqv))>1, error('freqv is not a vector'), end
if any(imag(freqv)~=0), error('freqv is not real'), end
freqv=freqv(:); F=length(freqv);
%if any(imag(freqv)~=0), error('freqv is complex'), end
%
if any(domain=='sp')
  pvalarr=[ones(F,1)/Z(1),j*realmin*ones(F,2)];
  pval=ortcoeffs(1)*pvalarr(:,1);
  if nargout>1, pcoeffarr=zeros(ord+1,ord+1); pcoeffarr(1,ord+1)=1/Z(1); end %R0
  %
  for r=1:ord
    if r==1
      pvalarr(:,r+1)=j*2*pi*freqv.*pvalarr(:,r);
      if nargout>1, pcoeffarr(2,ord)=pcoeffarr(1,ord+1); end %R1
    else %r>1
      pvalarr(:,r+1)=j*2*pi*freqv.*pvalarr(:,r)+Z(r)*pvalarr(:,r-1);
      if nargout>1
        pcoeffarr(r+1,[ord+1-r:ord+1])=[pcoeffarr(r,ord+2-r:ord+1),0]...
          +Z(r)*pcoeffarr(r-1,[ord+1-r:ord+1]);
      end
    end
    %Normalize
    pvalarr(:,r+1)=pvalarr(:,r+1)/Z(r+1);
    pval=pval+ortcoeffs(r+1)*pvalarr(:,r+1);
    if nargout>1, pcoeffarr(r+1,:)=pcoeffarr(r+1,:)/Z(r+1); end
  end %for r
  if nargout>=3
    coeffs=ortcoeffs*pcoeffarr;
    fsv=fsc.^[length(coeffs)-1:-1:0]; 
    coeffs=coeffs./fsv;
  end
else %'z'
  pval=orthopol(length(ortcoeffs)-1,domain,freqv,[],Z);
  pval=pval*ortcoeffs(:);
  if nargout>=2
    pcoeffarr=zeros(size(Z));
    pcoeffarr(1,1)=1/Z(1,1);
    for r=1:size(Z,1)-1
      pcoeffarr(r+1,1+[1:r])=pcoeffarr(r,1:r);
      pcoeffarr(r+1,1:r+1)=pcoeffarr(r+1,1:r+1)+Z(r+1,1:r)*pcoeffarr(1:r,1:r+1);
      pcoeffarr(r+1,1:r+1)=pcoeffarr(r+1,1:r+1)/Z(r+1,r+1);
    end %for ii
  end
  if nargout>=3
    coeffs=ortcoeffs*pcoeffarr;
  end
end
%
%End of orthpval
