function Out = anyisnan(dat)
%ANYISNAN Return 1 is any of the data in the object is NaN

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 30-Aug-1998

Out=0;
data=dat.Data;
if ~iscell(data), data={data}; end
for ii=1:length(data)
  if any(isnan(data{ii}(:))), Out=1; end
end %for
% end of file @iddat/anyisnan
