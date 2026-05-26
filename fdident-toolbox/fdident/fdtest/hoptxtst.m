%HOPTXTST Test optexcit

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
%Check optexcit
domain='s'; delay=0; fs=1;
num=[3.2010e-17,5.5155e-12,8.973e-10,0,0];
denom=[1.0131e-21,2.5351e-18,3.6031e-14,5.5550e-11,3.5869e-7,2.5017e-4,1];
freqv=20*[1:50]'; fl=length(freqv); fixpar=[4;5;12;13]; np=9;
pdat=exppar(domain,num,denom,delay,fs);
Xold=ones(fl,1)/sqrt(length(freqv)); N=1;
echo off
disp('[X,CP,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xold,1);')
fprintf('Press a key to continue...'), pause, disp(' ')
[X,CP,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xold,1);
graphnumber=grapause('hoptxtst',graphnumber,testsavegraphst);
%
fprintf('Press a key to continue...'), pause, disp(' ')
%
echo on
[X,CP,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,X,2,Fiw,3);
echo off
fprintf('Press a key to continue...'), pause, disp(' ')
echo on
%
fixpar=[];
echo off
disp('[X,CP,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xold,1);')
fprintf('Press a key to continue...'), pause, disp(' ')
[X,CP,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xold,1);
graphnumber=grapause('hoptxtst',graphnumber,testsavegraphst);
fprintf('Press a key to continue...'), pause, disp(' ')
%
disp('X=optexcit(pdat,freqv,[1,1],fixpar,X,50,Fiw,50);')
fprintf('Press a key to continue...'), pause, disp(' ')
X=optexcit(pdat,freqv,[1,1],fixpar,X,50,Fiw,50);
graphnumber=grapause('hoptxtst',graphnumber,testsavegraphst);
fprintf('Press a key to continue...'), pause, disp(' ')
%
clear X Xold num denom freqv fixpar np pdat CP fsv vXwdev Fiw delay domain
clear fs fl N graphnumber
%%%%% End of hoptxtst %%%%%%%
