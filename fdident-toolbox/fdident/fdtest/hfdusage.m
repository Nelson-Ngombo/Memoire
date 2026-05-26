function hfdusage
%HFDUSAGE Usage info on the fdident toolbox functions

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-1998

if exist('usage')
  disp('Usage information on the fdident toolbox functions ...')
  %
  fnames=hfdfiles;
  for ii=1:length(fnames)
    disp(['usage ',fnames{ii}])
    usage(fnames{ii})
  end
else
  disp('Warning! usage.m is not present')
end
%
%End of hfdusage
