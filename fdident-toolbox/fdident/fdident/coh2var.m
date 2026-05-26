function vartf=coh2var(coh,tf)
%COH2VAR Variance of transfer function from coherence values
%
%       vartf=COH2VAR(coh,tf)
%
%       Output arguments:
%       vartf = variance of transfer function
%
%       Input arguments:
%       coh = magnitude squared coherence values (0<coh<1)
%             e.g. coh=|Gxy|^2/(Gxx*Gyy) 
%       tf = transfer function (complex values or absolute values)
%            e.g. abstf=sqrt(Gyy/Gxx) or tf=Gxy/Gxx
%
%       Usage: vartf=coh2var(coh,tf);
%       Example:
%         %mag (dB), phase (degrees), freqv, and coh are given  
%         %come from transfer function measurements
%         abstf=10.^(mag/20);
%         vartf=coh2var(coh,abstf);
%         Fdata=fiddata(abstf.*exp(j*2*pi*phase),ones(size(mag)),freqv,vartf);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Jan-2003

if nargin<2, error('tf is not given'), end
if any(size(coh)~=size(tf)), error('coh and tf are incompatible'), end
if any(imag(coh)~=0), error('Complex value in coherence vector'), end
if min(size(coh))~=1, error('coh is not a vector'), end
if any((coh<0)|(coh>1)), error('coh out of range'), end
if any(coh==1), error('Cannot handle coherence values which equal 1 (zero variance)'), end
if any(coh==0), warning('Cannot handle coherence values which equal 0 (infinite variance)'), end
%
vartf=inf*ones(size(coh));
ind=find(coh~=0);
vartf(ind)=abs(tf(ind)).^2.*(1./coh(ind)-1);
%
%%%%%%%%%%%%%%%%%%%%%% End of coh2var %%%%%%%%%%%%%%%%%%%%%%%%%%%%%