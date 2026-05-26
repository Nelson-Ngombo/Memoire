%HLQLGTST Test lin2qlog, log2qlog

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, hold off
echo on
%Check lin2qlog, log2qlog
%
freqv=[5:100];
fqid=[5,12,30,75]';
[fqlog,df]=lin2qlog(freqv,2.5);
echo off
if any(abs(fqlog-fqid)>0)
  fqid', fqlog'
  error('Incorrect quasilogarithmic grid from lin2qlog')
else
  fprintf('lin2qlog seems to be OK\n\n')
end
%
echo on
freqvl=logspace(1,2,10)/100*15;
fqidl=[2,3,4,5,7,9,12,15]';
[fqlogl,df]=log2qlog(freqvl,15);
[fqlogl2,df2]=log2qlog(freqvl,15,1);
echo off
if any(fqlogl~=fqlogl2)|any(df~=df2)
  error('different results with and without df0')
end
if any(abs(fqlogl-fqidl)>0)
  fqidl', fqlogl'
  error('Incorrect quasilogarithmic grid from log2qlog')
else
  fprintf('log2qlog seems to be OK\n\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
clear freqv freqvl fqidl fqid fqlog fqlogl df
clear lin2qlog log2qlog
%%%%% End of hlqlgtst %%%%%%%
