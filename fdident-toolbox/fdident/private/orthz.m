function Z=orthz(parr,domain)
%ORTHZ Determine Z vector (array) from array of orthogonal polynomials
%
%       Z=ORTHZ(parr,domain)
%
%       Output arguments:
%       Z = vector of recursion coefficients
%
%       Input arguments:
%       parr = array of orthogonal polynomials
%       domain = domain we use
%
%       See also: ORTHOPOL.
%
%       Usage: Z=orthz(parr,domain);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Oct-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if diff(size(parr))~=0, error('parr is not quadratic'), end
ord=size(parr,1)-1;
if any(domain=='sp')
  Z=zeros(ord+1,1);
  for r=ord:-1:1
    Z(r+1)=parr(r,ord+2-r)/parr(r+1,ord+1-r);
  end
  Z(1)=1/parr(1,ord+1);
else %'z'
  Z=zeros(ord+1,ord+1);
  error('not yet ready')
end
%
%End of orthz
