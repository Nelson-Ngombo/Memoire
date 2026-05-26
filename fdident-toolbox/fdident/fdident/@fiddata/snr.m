function [snrout,snrin]=snr(v)
%SNR  Calculate SNR values in dB from the variances given.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Jan-2000

inputvar=get(v,'inputvar');
outputvar=get(v,'outputvar');

if isempty(inputvar'), snrdbin=[];
else
  U=get(v,'input');
  if length(inputvar)==1, r=abs(U)/sqrt(inputvar);
  else r=abs(U)./sqrt(inputvar);
  end
  snrdbin=20*log10(r);
end
if isempty(outputvar'), snrdbout=[];
else
  Y=get(v,'output');
  if length(inputvar)==1, r=abs(Y)/sqrt(outputvar);
  else r=abs(Y)./sqrt(outputvar);
  end
  snrdbout=20*log10(r);
end

if nargout==0
  if ~isempty(snrdbout)
    fprintf('SNRy_mean = %.4g dB',mean(snrdbout))
  else
    fprintf('SNRy = [ ] dB')
  end
  if ~isempty(snrdbin)
    fprintf(', SNRu_mean = %.4g dB\n',mean(snrdbin))
  else
    fprintf(', SNRu = [ ] dB\n')
  end
else
  snrout=snrdbout;
  snrin=snrdbin;
end

%End of @tiddata/snr