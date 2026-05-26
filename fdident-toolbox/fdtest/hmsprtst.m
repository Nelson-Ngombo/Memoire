%HMSPRTST Test msinprep

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, hold off
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
echo on
%Check msinprep
%Example of Manual, with less cycles
fvect=[1:15]'; fvl=length(fvect);
[cx,crx,crxmax]=msinclip(fvect,ones(fvl,1),[],'',15);
xtim=msinprep(fvect,cx,256);
clf, hold off
plot(xtim)
title('Generated time function')
echo off
graphnumber=grapause('hmsprtst',graphnumber,testsavegraphst);
%
clc, echo on
freqv=[0:15]'; fl=length(freqv);
cx=ones(fl,1);
cx=msinclip(freqv,cx,[],'nograph',0,1);
N=32;
fs=32;
[xtim,df]=msinprep(freqv,cx,N,fs,'screen');
ck=fft(xtim);
if any(abs(cx-ck(1:16))>N*eps), error('cx and ck differ'), end
[xtim,df]=msinprep(freqv,cx,N,fs,'DAC');
ck=fft(xtim);
echo off
fprintf('Press a key to continue...'), pause, disp(' ')
clf, hold off
plot(freqv,abs(ck(1:16)),'*'), title('1/sinc(pi*f/fs),  fs=32')
axv=axis; axv(1)=0; axv(3)=0; axis(axv);
graphnumber=grapause('hmsprtst',graphnumber,testsavegraphst);
%
clear fvect fvl fl cx crx crxmax ck xtim N fs freqv df graphnumber
%%%%% End of hmsprtst %%%%%%%
