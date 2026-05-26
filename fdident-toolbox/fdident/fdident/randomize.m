function [fvrandomized,selind,fvind]=randomize(freqv,fs,order)
%RANDOMIZE Randomized odd subset of a frequency vector.
%
%       [fvrandomized,selind,fvind]=randomize(freqv,fs,order)
%
%       The routine makes a randomized subset (randomly chosen ORDER-1 lines of
%       of each group of ORDER odd frequencies) of the given frequency vector.
%       Default for ORDER: 3. Frequencies will be rounded in necessary to the 
%       nearest odd index, if their index is within 0.1 from it.
%
%       FREQV is the input frequency vector, FS is the (optionally given) sampling
%       frequency.
%
%       Output arguments: FVRANDOMIZED is the column vector of the selected 
%       subset of the frequencies, SELIND is the index vector into freqv,
%       FVIND is the vector of frequency indices.
%
%       Usage: [fvrandomized,fvind]=randomize(freqv,fs,order);
%       Example: fvr=randomize([1:0.01:2],5.2);
%
%       See also: ODDGRID

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Apr-2005

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if min(size(freqv))>1, error('freqv is not a vector'), end
freqv=freqv(:); %column vector
if any(imag(freqv)), error('freqv is complex'), end
if any(freqv<0), error('freqv contains negative elements'), end
if any(diff(freqv)<=0), error('freqv is not strictly increasing'), end
if nargin<2, fs=[]; end
if nargin<3, order=[]; end, if isempty(order), order=3; end
df=dfcalc([freqv;fs]);
if isempty(fs), fsind=2*ceil(max(freqv)/df)+1; fs=fsind*df;
else fsind=round(fs/df);
end
if fsind>1e6
  warning(sprintf('The calculated harmonic number of fs is too large, %.0f',fsind))
end
if length(fs)~=1, error('fs is not scalar'), end
if fs<=0, error('fs is not positive'), end

%inde=(rem(freqv/df,2)==0);
%fvindin=sort(round([freqv/df+0.49;freqv/df-0.49;freqv(inde)/df+round(2*rand(size(inde)))-1]));
fvindin=sort(round([freqv/df]));
fdi0=find(diff(fvindin)==0); if ~isempty(fdi0), fvindin(fdi0)=[]; end
fdie=find((rem(fvindin,2)==0)|(fvindin>=fsind/2)); if ~isempty(fdie), fvindin(fdie)=[]; end
fdiall=[min(fvindin):2:max(fvindin)];
fvind=[];
for ig=min(fdiall):order*2:max(fdiall)
  group=ig+[0:2:(order-1)*2]';
  if ~all(ismember(group,fvindin))
    ind=find(ismember(fvindin,group));
    fvind=[fvind;fvindin(ind)];
  else
    ind0=floor(length(group)*rand(1,1))+1;
    if ind0==length(group)+1, ind0=length(group); end
    group(ind0)=[];
    fvind=[fvind;group];
  end
end %for ig
fvrandomized=fvind*df;
if nargout>1
  selind=zeros(size(fvrandomized));
  for ii=1:length(selind)
    [minv,ind]=min(abs(fvrandomized(ii)-freqv));
    selind(ii)=ind;
  end
end
%
%%%%%%%%%%%%%%%%%%%%%%%% end of randomize %%%%%%%%%%%%%%%%%%%%%%%%
