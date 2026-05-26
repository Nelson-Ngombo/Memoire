function Out=exc_channels(Fdat)
%EXC_CHANNELS  Return number of single excited channel among inputs for each experiment
%
%       The output is a row vector - an element for each experiment, the serial number
%       of the excited channel among the input channels.
%       NaN is returned for multi-channel excitation.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

expno=get(Fdat,'expnumber');
Out=ones(1,expno);
idat=get(Fdat,'inputdata');
if isempty(idat)|isnumeric(idat), return, end
for ii=1:expno
  if isnumeric(idat), idat={idat}; end
  dat=idat(:,ii); isexc=0;
  if isnumeric(dat), dat={dat}; end
  for iii=1:size(dat,1)
    dati=dat{iii};
    if ~isempty(dati)&any(dati)&isfinite(isexc)
      if isexc, isexc=NaN; else isexc=iii; end, 
    end
  end %for iii
  Out(ii)=isexc;
end %for ii
%End of @fiddata/issingleexc
