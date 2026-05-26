%HMODFVTS Test modifyfv

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
graphnumber=1;
rand('seed',0), randn('seed',0)
echo on
%Check modifyfv
%
num=[5,5]; denom=[4,3,2,1];
no=length(num)-1; nd=length(denom)-1;
delay=0.5;
pdat=exppar('z',num,denom,delay,1);
freqv=[0.01:0.015:0.491]'; fl=length(freqv);
x0=ones(fl,1);
varx=1e-5*ones(length(freqv),1); vary=varx;
covxy=j*vary;
vdat=expvar(varx,vary); varr=[vary,varx,covxy];
[x,y]=simfou(pdat,freqv,x0,vdat);
Fdat=expfou(freqv,x,y); Farr=[freqv,x,y];
clf, hold off
[Farrm,varrm]=modifyfv(pdat,Farr,varr);
echo off
if any(abs(sqrt(varrm(:,1).*varrm(:,2))-abs(varrm(:,3)))>10*eps)
  error('covxy is too large compared to varx.*vary')
end
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','Verticalalignment','bottom',...
        'HorizontalAlignment','center')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
echo on
[Fdatm,vdatm]=modifyfv(pdat,Fdat,vdat);
echo off
graphnumber=grapause('hmodfvts',graphnumber,testsavegraphst);
clear Fdatm vdatm Fdat vdat varx vary x0 pdat num denom no nd x y
clear Farr Farrm varr varrm graphnumber
rand('seed',0), randn('seed',0)
%%%%% End of hmodfvts %%%%%%%
