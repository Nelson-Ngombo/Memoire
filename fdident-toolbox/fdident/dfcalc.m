function [df,fi]=dfcalc(freqvect,digits,Nfs)
%DFCALC Calculates maximum common divisor in frequency vector
%
%       [df,fi]=DFCALC(freqvect,digits,Nfs)
%
%       Output arguments:
%       df = maximum common divisor (reciprocal of period length)
%       fi = frequency indices
%
%       Input arguments:
%       freqvect = vector of frequencies
%       digits = number of exact digits in the data
%       Nfs = maximum harmonic number associated to the sampling frequency
%             (which is larger than two times the maximum frequency)
%             The algorithm only makes an attempt, but does not guarantee to
%             fulfill the prescription
%
%       Usage: [df,fi]=dfcalc(freqvect,digits,Nfs);
%       Example:
%         df=dfcalc([5.1:2:16]);
%
%       See also: MSINCLIP.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Jul-2001

if nargin<3, Nfs=[]; end, if isempty(Nfs), Nfs=inf; end
if Nfs<=2, error('Nfs<=2'), end
if nargin<2, digits=[]; end, if isempty(digits), digits=17; end
if iscell(freqvect)
  fsave=freqvect; freqvect=[];
  for ii=1:prod(size(fsave))
    freqvect=[freqvect;fsave{ii}];
  end
end
if isempty(freqvect), df=[]; return, end
if min(size(freqvect))~=1, error('freqvect is not a vector'), end
if length(freqvect)==1, df=freqvect; fi=1; return, end
freqvect=sort(freqvect);

%find common divider df, not smaller than 2*fmax/(Nfs-2) if Nfs is given.
%remfnegl is the remainder which is negligible in the frequency vector
emax=10^(-digits)*max(freqvect);
[mfv,mfvind]=min(freqvect);
if mfv==0, freqvect(mfvind)=[]; end
dfreqvect=diff(sort([0;freqvect(:)]));
ind=find(dfreqvect==0); if ~isempty(ind), dfreqvect(ind)=[]; end
df=min(dfreqvect);
if (Nfs==2)|~isfinite(Nfs),
  remfnegl=max(freqvect)/df*eps*max(freqvect)*length(freqvect);
else
  remfnegl=2*max(freqvect)/(Nfs-2)/2;
end
while any(dfreqvect>remfnegl)
  df0=df; df=min([df0;dfreqvect]);
  if (Nfs==2)|~isfinite(Nfs),
    remfnegl=max(freqvect)/df*eps*max(freqvect)*length(freqvect);
  end
  remfnegl=max(remfnegl,emax);
  dfreqvect=sort(abs(rem([df0;dfreqvect]+df/2,df)-df/2));
  ind=find(dfreqvect<=remfnegl); dfreqvect(ind)=[];
end
%
fi=round(freqvect/df); %harmonic numbers
ind=find(fi~=0);
df=mean(freqvect(ind)./fi(ind));
if max(fi)>=1e5
  disp(sprintf('Warning! the maximum harmonic number is %.0f.',max(fi)))
  disp('Large indexes are often due to inaccurately given frequency values.')
  disp('If this is the case, before invoking dfcalc round the frequencies:')
  disp('   freqvect = round(freqvect*T)/T;')
  disp('where T is the desired period length.')
  disp(' ')
end
%devii=fi*df-freqvect; ddf=fi(ind)\devii(ind);
%if max(abs(fi*df-freqvect))>max(abs(fi*(df+ddf)-freqvect)), df=df+ddf; end
%maxdev=max(abs(fi*df-freqvect));
%if maxdev>eps*max(freqvect)*max(fi)
%  fprintf('WARNING! Maximum deviation of i*df from fi is %.2e in dfcalc\n',...
%                maxdev)
%end
%%%%%%%%%%%%%%%%%%%%%%%% end of dfcalc %%%%%%%%%%%%%%%%%%%%%%%%
