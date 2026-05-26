function [df,fi]=dfcalc(obj,digits,Nfs)
%DFCALC Calculates maximum common divisor in frequency vector
%
%       [df,fi]=DFCALC(freqvect,digits,Nfs)
%
%       Output arguments:
%       df = maximum common divisor (reciprocal of period length)
%       fi = frequency indices
%
%       Input arguments:
%       obj = fiddata or tiddata object
%       digits = number of exact digits in the data
%       Nfs = maximum harmonic number associated to the sampling frequency
%             (which is larger than two times the maximum frequency)
%             The algorithm only makes an attempt, but does not guarantee to
%             fulfill the prescription
%
%       Usage: [df,fi]=dfcalc(obj,digits,Nfs);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Aug-2004

if nargin<3, Nfs=[]; end, if isempty(Nfs), Nfs=inf; end
if Nfs<=2, error('Nfs<=2'), end
if nargin<2, digits=[]; end, if isempty(digits), digits=17; end
%
%Get freqvect
fr=obj.Frequencies;
if isempty(fr)&isa(obj,'fiddata'), fr=get(obj,'allfreqpoints'); end
freqvect=[];
if isnumeric(fr)
  freqvect=fr(:);
elseif iscell(fr)
  for ii=1:length(fr)
    freqvect=[freqvect;fr{ii}(:)];
  end
end
%
if isempty(freqvect)
  Tp=get(obj,'Periodlength');
  if isempty(Tp)
    if isa(obj,'tiddata'), df=1/get(obj,'ts')/get(obj,'samplen');
    else df=[];
    end
    fi=[];
    return
  else
    df=1/Tp;
    if isa(obj,'tiddata')
      Ts=get(obj,'Ts'); Np=round(Tp/Ts);
      fi=[0:Np/2];
    else
      fi=[];
    end
    return
  end
end
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
if isempty(dfreqvect), dfreqvect=0; end
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
if all(freqvect==0), fi=zeros(size(freqvect)); df=0;
else
  fi=round(freqvect/df); %harmonic numbers
  df=mean(freqvect./fi);
end
if max(fi)>=1e5
  disp(sprintf('Warning! the maximum harmonic number is %.0f.',max(fi)))
  disp('Large indexes are often due to inaccurately given frequency values.')
  disp('If this is the case, before invoking dfcalc round the frequencies:')
  disp('   freqvect = round(freqvect*T)/T;')
  disp('where T is the desired period length.')
  disp(' ')
end
devii=fi*df-freqvect; ddf=fi\devii;
%%%%%%%%%%%%%%%%%%%%%%%% end of dfcalc %%%%%%%%%%%%%%%%%%%%%%%%