%HLDVTEST Test loadvar and savevar

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
echo on
%Check loadvar and savevar
%
echo off
x=1; y=[1,2];
save hldvtest.bin x y
xs=x; clear x
if exist('x')==1, error('Cannot clear variable ''x'''), end
xf=loadvar('hldvtest.bin','x');
if any(xs-xf), error('variable not retrieved correctly from file'), end
savevar('hldvtest.bin','x');
clear y
load hldvtest.bin -mat
if exist('x')==1
  error('Variable was not successfully cleared from mat-file')
end
if exist('y')~=1, error('Variable disappeared from mat-file'), end
savevar('hldvtest.bin','x',2);
load hldvtest.bin -mat
if x~=2, error('Saved variable is not loaded correctly'), end
echo on
loadvar('hldvtest.bin','who');
loadvar('hldvtest.bin','whos');
echo off
disp('loadvar, savevar seem to be OK')
delete hldvtest.bin
fprintf('Press a key to continue...'), pause
%%%%% End of hldvtest %%%%%%%
