function gm=gmean(X)
%GMEAN  Geometric mean value of complex vectors/matrices.
%
%       For vectors, GMEAN(X) is the geometric mean value of the elements in
%       vector X.  For matrices, GMEAN(X) is a row vector containing the mean
%       value of each column.
%       Attention is paid to avoid phase wrapping for complex elements.
%
%       Example: x=-ones(100,2)+0.1*randn(100,2)+j*0.01*randn(100,2);
%                mx=gmean(x)
%                mfalse1=prod(x).^(1/100), mfalse2=prod(x.^(1/100))

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-May-1996

if any(any(~isfinite(X))), error('Infinite or NaN element in X'), end
phi=angle(mean(X));
ampl=exp(mean(log(abs(X))));
gm=ampl.*exp(sqrt(-1)*phi);
%%%%%%%%%%%%%%%%%%%%%%%% end of gmean %%%%%%%%%%%%%%%%%%%%%%%%
