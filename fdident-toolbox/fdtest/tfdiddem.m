function test=tfdiddem
%TFDIDDEM Test demonstrations of the FDIDENT Toolbox: call fdiddemo

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Nov-1996

disp('File tfdiddem')
lasterr('');
errortrap on
testtime=clock;
%
clc, fdiddemono=1; lowpansw='n';
hyiad
fdiddemo  %run demonstrations
%
%Build and test finish
testtime=etime(clock,testtime);
close all
errortrap off
%
test = testinit('tfdiddem','tfdiddem');
eval('test = testpt(test,1,'''','''');')
%On the pc, there is no TerminalProtocol property for the root object.
%One of Istvan's files uses the eval-catch method to determine this.
%The problem is that it places a string into the lasterr value and thus
%produces a false failure for the test.
lasterr_str = lower(lasterr);
if length(findstr(lasterr_str,'terminal')),
  lasterr_str = '';
end
[test, breakflag] = feval('tvalchk',test,isempty(lasterr_str), 1);
errstat{1,1} = test;
test = tstrip(errstat);
%%%%%%%%%%%%%%%%%%%%%%%% End of tfdiddem %%%%%%%%%%%%%%%%%%%%%%%%%%%%
