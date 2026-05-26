function [rvect,gain]=ortroots(pvect,Z)
%ORTROOTS Roots of polynomial given by orthogonal set of polynomials
%
%       rvect=ORTROOTS(pvect,Z)
%
%       Output arguments:
%       rvect = vector of roots
%       gain = gain necessary to scale prod(jw-root_i)
%
%       Input arguments:
%       pvect = vector of coefficients of polynomials
%       Z = column vector (s-domain) or array (z-domain) of recursion coefficients
%
%       See also: ORTHOPOL, ORTHPVAL, ORTHZ.
%
%       Usage: rvect=ortroots(pvect,Z);

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
 
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Oct-2001

if nargin<2, error('Not enough input arguments'), end
if min(size(pvect))>1, error('pvect is not a vector'), end
if length(pvect)<=1, rvect=[]; gain=pvect; return, end
pvect=pvect(:)'; ord=length(pvect)-1;
if min(size(Z))==1, domain='s'; Z=Z(:);
else domain='z';
end
if length(Z)~=length(pvect), error('pvect and Z are incompatible'), end
%
while pvect(1)==0 %degenerate case
  if ord<=1, rvect=[]; gain=pvect; return, end
  pvect(1)=[]; Z(1)=[];
  ord=ord-1;
end
%
if domain=='s'
  %Reference [1-2]
  A1=[fliplr(-pvect(1:ord))/pvect(ord+1);
    eye(ord-1),zeros(ord-1,1)];
  A2i=diag(flipud(Z(2:ord+1)));
  A3=[zeros(ord-1,1),diag(flipud(Z(2:ord)./Z(3:ord+1)));
    zeros(1,ord)];
  rvect=eig(A2i*(A1-A3));
else %'z'
  %Reference [3]
  Zd=diag(Z); %/sqrt(2);
  A1i=diag(flipud(Zd(2:ord+1)));
  A2=[fliplr(-pvect(1:ord))/pvect(ord+1);
    eye(ord-1),zeros(ord-1,1)];
  A3=zeros(size(A2));
  for ii=1:ord
    A3(ord+1-ii,sort(ord+1-[1:ii]))=fliplr(Z(ii+1,1:ii))/Z(ii+1,ii+1); %/sqrt(2);
  end %for ii
  rvect=1./eig(A1i*(A2-A3));  
end
if nargout>=2 %gain
  ord=length(rvect);
  while length(rvect)<ord, rvect=[rvect;0]; end
  if ~isempty(rvect)
    maxr=max(imag(rvect));
    if maxr==0, maxr=max(abs(rvect)); end
    if maxr==0, maxr=1; end
    freqv=[0:ord]/ord*maxr; F=length(freqv);
    if ord==1, 
      TFr=j*2*pi*ones(ord,1)*freqv-rvect(:)*ones(1,F);
    else
      TFr=prod(j*2*pi*ones(ord,1)*freqv-rvect(:)*ones(1,F));
    end
    TF=orthpval(pvect,Z,freqv);
    %gain=[real(TFr.');imag(TFr.')]\[real(TF);imag(TF)];
    gain=TFr.'\TF;
    gain=abs(gain)*sign(sign(angle(gain))+eps);
  else  
    gain=pvect(end);  
  end
end
%
%End of ortroots
