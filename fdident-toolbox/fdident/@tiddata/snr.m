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
  u=get(v,'input');
  eff=sqrt(mean(u.*u));
  snrdbin=20*log10(eff/sqrt(inputvar));
end
if isempty(outputvar'), snrdbout=[];
else
  u=get(v,'output');
  eff=sqrt(mean(u.*u));
  snrdbout=20*log10(eff/sqrt(outputvar));
end

if nargout==0
  if ~isempty(snrdbout)
    fprintf('SNRy = %.4g dB',snrdbout)
  else
    fprintf('SNRy = [ ] dB')
  end
  if ~isempty(snrdbin)
    fprintf(', SNRu = %.4g dB\n',snrdbin)
  else
    fprintf(', SNRu = [ ] dB\n')
  end
else
  snrout=snrdbout;
  snrin=snrdbin;
end

%End of @tiddata/snr