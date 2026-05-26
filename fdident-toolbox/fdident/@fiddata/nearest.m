function [outdata,ranks]=nearest(Fdat,fv)
%NEAREST  Select frequencies closest to elements of given frequency vector
%
%       [outdata,ranks]=nearest(Fdat,fv)
%
%       ranks gives the input SNR rank of the lines

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-May-2002

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if isempty(fv), error('fv is empty'); end
if ~isnumeric(fv)|((size(fv,1)>1)&(size(fv,2)>1)), error('fv is not a vector'), end
outdata=Fdat;
fvout=get(Fdat,'freqpoints');
if isequal(fvout,fv), outdata=Fdat; ranks=1:length(fv); return, end
if nargout>=2
  U=get(Fdat,'input'); v=get(Fdat,'inputvariance');
  if isempty(U)|isempty(v)|(iscell(v)&~any(cell2mat(v)))
    warning('Cannot determine input SNR values')
    inds=[];
  else
    if iscell(U), SNR1=20*log10(abs(cat(1,U{:})));
    else SNR1=20*log10(abs(U)); 
    end
    SNR2=10*log10(abs(v));
    [SNR,inds]=sort(SNR1-SNR2);
  end
end
ind=[]; ranks=[];
for ii=1:length(fv)
  [dummy,indii]=min(abs(fv(ii)-fvout));
  for iii=1:length(indii)
    if isempty(ind)|~any(indii(iii)==ind)
      ind=[ind;indii(iii)];
      if (nargout>=2)&~isempty(inds)
        ranks=[ranks;length(SNR)+1-find(indii(iii)==inds)];
      end
    end
  end %for iii
end %for ii
if length(ind)<length(fvout)
  Str.type='()';
  Str.subs={ind};
  outdata=subsref(outdata,Str);
end
%End of @tiddata/nearest