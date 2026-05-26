%OPTEXDEM Demonstration of optexcit

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
echo on
%The power spectrum of the excitation signal can be optimized in order to
%obtain maximum information in a measurement. The first demonstration shows
%the design of an optimal power spectrum, the second one illustrates the
%correctness of the routine OPTEXCIT on an analytically calculable example.
echo off
disp(' ')
disp(['     1) Book, Subsect. 4.3.5: Optimize excit. signal',...
              ' for bandpass filter, p. 179'])
disp(['     2) Book, Sect. 4.1, Ex. 2: a 1st-order system, p. 147'])
odno=yesinput('Your choice','1',['1|2']);
eval(['optexde',odno]) %
