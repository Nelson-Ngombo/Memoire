%HEVCTTST Test expvect

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
echo on
%Check expvect
%
a=[1:11]';
b=pi*ones(11,1);
expvect('hevcttst.asc',a,b)
ab=loadasc('hevcttst.asc','flat');
echo off
if any(any(abs(ab-[a,b])>1e-4))
  echo on, [ab,a,b], echo off
  error('Data not retrieved correctly from file written by expvect')
else
  disp('expvect seems to be OK')
end
delete hevcttst.asc
fprintf('Press a key to continue...'), pause, disp(' ')
clear a b ab
%%%%% End of hevcttst %%%%%%%
