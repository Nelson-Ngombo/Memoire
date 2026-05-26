%HFDRSUIT Run MathWorks test suite

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Nov-1996

home_path=pwd;
mode.test=1;
mode.error=1;
test_path=which('hfdrsuit.m');
test_path=test_path(1:length(test_path)-11)
runsuite(mode,test_path)
cd(home_path)
