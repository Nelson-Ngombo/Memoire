function C=colcov(Cxx,Cyy,Cxy,W,NumPoly,DenPoly,mode)
%COLCOV Complex Column Covariance Matrix calculation
%
%       Usage: C = colcov(Cxx,Cyy,Cxy,W,NumPoly,DenPoly,mode)
%
%       C=E{J_noise' * J_noise}
%
%       Input arguments:
%       Cxx, Cyy, Cxy = Variance and covariance vectors of X and Y, vs. freq
%       W = Weigths of the cost fcn, vs. freq, vector
%       NumPoly, DenPoly: Polynomials of the numerator and denominator, 
%                           Size: #frequencies x (1 + #order)
%                           (may be s-power or orthogonal polynomials)
%       mode: mode of computation [optional]
%             if J=[X/W*N, -Y/W*D], then mode = 1 (default)
%             this is the form used in case of power- and Forsythe-polinomials
%             if J=[X/W*N-Y/W*D], then mode = 2 
%             this is the form used in case of MVB's orthogonal polinomials 

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001
%       All rights reserved.
%       Written by Gy. Simon
%       $Revision: $
%       Last modified: 11-Oct-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(6,7); %Matlab 2016a or later
else ni=nargin; error(nargchk(6,7,ni)), %earlier
end
if nargin<7, mode=1; end
if isempty(Cxx), Cxx=zeros(size(Cyy)); end
if isempty(Cyy), Cyy=zeros(size(Cxx)); end
if isempty(Cxy), Cxy=zeros(size(Cxx)); end
if isempty(W), W=ones(size(Cxx)); end
  
% Upper left submatrix:
J11=diag(sqrt(Cxx)./W)*NumPoly;
C11=J11'*J11;

% Lower right submatrix:
J22=diag(sqrt(Cyy)./W)*DenPoly;
C22=J22'*J22;

if ~isempty(Cxy)
  J12x=   diag(conj(sqrt(Cxy))./W)*NumPoly;
  J12y= - diag(     sqrt(Cxy) ./W)*DenPoly;
  % Upper right submatrix:
  C12=J12x'*J12y;
  % Lower left submatrix:
  C21=J12y'*J12x; %=C12'
else % if the covariance is zero 
  % Upper right submatrix:
  C12=zeros(size(C11,1),size(C22,2));
  % Lower left submatrix:
  C21=zeros(size(C22,1),size(C11,2));   
end %if

if mode==1 % old form
   C=[C11 C12; C21 C22];
else % new form for Marc Van Barrel's polinomials:
   C=C11+C22+C12+C21;
end

%End of colcov
