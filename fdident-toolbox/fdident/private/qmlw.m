function W=qmlw(fdata,NumOrd,DenOrd,errorweighting)
%QMLW initial weight calculation (make not yet implemented elis fit)
%       Helper function of autoorder
%
%       W=qmlw(fdata,NumOrd,DenOrd,errorweighting);
%
%       Output arguments:
%         W = generated weights
%       Input arguments:
%         fdata = frequency data (fiddata object)
%         NumOrd = order of the numerator
%         DenOrd = order of the denominator

%       Written by Gyula Simon, 1998
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Oct-2001

X=fdata.input;  % measured input data
Y=fdata.output; % measured output data
fv=fdata.freqpoints; % frequencies, where measurements were performed

if strncmpi(errorweighting,'linear',3)
  Cxx=fdata.inputvariance;
  Cyy=fdata.outputvariance;
  Cxy=fdata.covvector;
else
  Cxx=fdata.inputNonlinError;
  Cyy=fdata.outputNonlinError;
  Cxy=fdata.nonlincovvector;
end
fi=angle(Y./X);
w=  2*fv /(max(fv)+min(fv));  % normalize frequencies
% ^^^^^^^^^ ???? Not consistent with Elis !

W2=Cyy.*abs(X./Y);
if ~isempty(Cxx), W2=Cxx.*abs(Y./X)+W2; end
if ~isempty(Cxy), W2=W2-2*real(Cxy.*exp(-j*fi)); end
W2=W2.*T(NumOrd, w).*T(DenOrd, w);
W=sqrt(W2);

function T=T(p, w)
%
ix1=find(w==1);
w(ix1)=w(ix1)+1e-5; % avoid zero div, calculate precise value later

T=(w.^(p+1)-1)./(w-1);
if ~isempty(ix1)
   T(ix1)=p+1;
end

