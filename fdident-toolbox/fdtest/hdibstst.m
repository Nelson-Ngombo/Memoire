%HDIBSTST test of dibs and dibsimpr

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
%Check dibs and dibsimpr
%
%Example in Manual
rand('seed',0)
nf=10; N=64;
freqv=(1:nf);
ampv=ones(1,length(freqv));
dt=1/N;
echo off
disp('[bits0,Aopt,ampopt]=dibs(N,dt,freqv,ampv,1,''graph'');')
fprintf('Press a key to continue...'), pause, disp(' ')
[bits0,Aopt,ampopt]=dibs(N,dt,freqv,ampv,1,'graph');
graphnumber=grapause('hdibstst',graphnumber,testsavegraphst);
%
disp('[bitser,ampopt,Puf,Ptot]=dibsimpr(bits0,dt,freqv,ampv,1,''graph'');')
fprintf('Press a key to continue...'), pause, disp(' ')
[bitser,ampopt,Puf,Ptot]=dibsimpr(bits0,dt,freqv,ampv,1,'graph');
graphnumber=grapause('hdibstst',graphnumber,testsavegraphst);
echo off
if (nf==10)&(N==64)
  if ~all(bits0==...
        [1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,...
         1,1,1,1,-1,-1,-1,1,1,-1,-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,-1,1,1,1,1,1,...
         -1,-1,1,1,1,1,1,-1,-1,-1,1]')
    fprintf(['Warning! The result of dibs is different from that of',...
        ' obtained using a PC.\n'])
    fprintf(['The reason may be different working of ''rand'',\n',...
        'used for the generation of the starting values of iteration.\n'])
    pause
  end
end
clear freqv bitser bits0 ampv ampopt Puf Ptot Aopt N dt nf graphnumber
rand('seed',0)
%%%%%%%%%%%%% End of hdibstst %%%%%%%%%%%%%
