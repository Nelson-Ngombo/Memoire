function [test] = tfdhelp(emode, point)
%TFDFILES is the test function for FDIDENT tbx help screens.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       $Revision: 1.2 $
%       Last edited: 18-Mar-2000

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test Setup

if (nargin < 1)
        test = testinit(mfilename,'FDHELP');
else
        test = testinit(mfilename,'FDHELP',emode);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function & Expected Function matrix

% obtain cell array of FDIDENT tbx files
fdident_files = hfdfiles;

cyclen=length(fdident_files);

if strncmp(version,'6.0',3)&any(findstr(version,'Beta 4')), v6beta4=1;
else v6beta4=0;
end
%In R12 beta4, helps would slow down the tests
if v6beta4, cyclen=1; end

for k = 1:cyclen,

% obtain and display help screen
   help_scr = help(fdident_files{k})

% only check for function name in H1 line of help screen
   help_chk = length(findstr(upper(fdident_files{k}), help_scr(1:30)));

% performing test checking and bookkeeping
   test = testpt(test,k,['help(''',fdident_files{k},''')'],'');
   [test, breakflag] = feval('tvalchk',test, help_chk, 1);
   errstat{k,1} = test;
   if breakflag, return; end

end % for

% Indicate success
test = tstrip(errstat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% End of unit test for FDIDENT files %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
