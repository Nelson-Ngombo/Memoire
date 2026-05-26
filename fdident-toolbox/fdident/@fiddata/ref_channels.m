function Out=ref_channels(Fdat)
%REF_CHANNELS  Return number of single all-ones reference channel among inputs for each experiment
%
%       The output is a row vector - an element for each experiment, the serial number
%       of the channel, designed for excitation in the reference, among the input channels.
%       NaN is returned for multi-channel (full MIMO), -1 if the reference is empty.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

expno=get(Fdat,'expnumber');
Out=-ones(1,expno);
idat=get(Fdat,'inputdata');
rdat=get(Fdat,'Reference');
if isempty(rdat)|(isnumeric(rdat)&all([rdat;1]==1)), return, end
for ii=1:expno
  if isnumeric(rdat), rdat={rdat}; end
  ref=rdat(:,min(ii,end));
  if isnumeric(ref), ref={ref}; end
  issingle=0;
  for iii=1:size(ref,1)
    refi=ref{iii};
    if ~isempty(refi)&all([refi;1]==1)
      if isfinite(issingle)
        if issingle, issingle=NaN; else issingle=iii; end
      end
    elseif ~isempty(refi)&~all([refi;0]==0)
      issingle=NaN;
    end
  end %for iii
  Out(ii)=issingle;
end %for ii
%End of @fiddata/issingleref
