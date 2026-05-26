%HDIGNTST  Test digitnum

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-May-1996

disp('File dgnumtst')
%
if digitnum(3)~=1, error('digitnum is wrong for x=3'), end
if digitnum(3.22)~=3, error('digitnum is wrong for x=3.22'), end
if ~isempty(digitnum([])), error('digitnum is wrong for x=[]'), end
digitnum([eps,pi,1,1.22,eps]);
