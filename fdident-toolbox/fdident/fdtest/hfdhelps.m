function hfdhelps
%HFDHELPS Helps and whatsnew results of the fdident toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

disp('Display help messages ...')
%
disp('Toolbox directories:')
help fdident
help fddemos
help fdtest
%
disp('Toolbox whatsnew''s:')
whatsnew('fdident')
whatsnew('fddemos')
whatsnew('fdtest')
%
disp('Individual help messages:')
fnames=hfdfiles;
for ii=1:length(fnames)
  if ~any(strmatch(fnames{ii},{'private/elisrmt','private/elisdrmt','private/elisfiti'}))
    help(fnames{ii})
    oldhelp(fnames{ii})
    if exist('corrtest.m')
      help(fnames{ii})
      if strcmp(fnames{ii},'elis')
        disp('Helps of elis')
        elis
        fdhelp('elis','runmod')
        fdhelp('elis','devrunmod')
        fdhelp('elis','fitinfo')
        elis runmod
        elis devrunmod
        elis fitinfo
      end
    end
  end
end
%
%End of hfdhelps
