function test = tfdfiles(emode, point)
%TFDFILES is the test function for FDIDENT tbx file existence.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Nov-1996

disp('File tfdfiles')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test Setup

if (nargin < 1)
        test = testinit(mfilename,'FDFILES');
else
        test = testinit(mfilename,'FDFILES',emode);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function & Expected Function matrix

% obtain cell array of FDIDENT tbx files
fdident_files = hfdfiles;

for k = 1:length(fdident_files),

   exist_state = exist(fdident_files{k});

% performing test checking and bookkeeping
% if exist state equals 2 then we know the M file exists.

   test = testpt(test,k,['exist(''',fdident_files{k},''')'],'');
   [test, breakflag] = feval('tvalchk',test, exist_state, 2);
   errstat{k,1} = test;
   if breakflag, return; end

end % for

% Indicate success
test = tstrip(errstat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% End of unit test for FDIDENT files %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
