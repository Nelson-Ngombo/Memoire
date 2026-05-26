function dignum=digitnum(x)
%DIGITNUM Number of mantissa digits necessary to exactly represent numbers
%
%       Usage: dignum=digitnum(x)
%       Example: digitnum(5.62)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

if isempty(x), dignum=[]; return, end
if any(any(imag(x)~=0)), error('x is not real'), end
if any(any(~isfinite(x))), error('x contains infinite or NaN element(s)'), end
ind=find(x~=0); dignum=ones(size(x));
x=abs(x);
ex=10.^floor(log10(x(ind))+1);
x(ind)=x(ind)./ex;
dn=0;
while ~isempty(ind)
  x(ind)=x(ind)*10;
  ind2=find(abs(rem(x(ind)+0.5,1)-0.5)<(dn+1)*x(ind)*eps);
  dn=dn+1;
  if ~isempty(ind2), dignum(ind(ind2))=dn*ones(size(ind2)); end
  ind(ind2)=[];
end %while
%%%%%%%%%%%%%%%%%%%%%%%% end of digitnum %%%%%%%%%%%%%%%%%%%%%%%%
