%HELMLTST Test elisml

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

disp('File helmltst')
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
rand('seed',0), randn('seed',0)
echo on
%
%Check of basic run
if exist('corrtest.m')
  [freqv,x,y]=impfou('bandpass(bandpass)',1);
else
  [freqv,x,y]=impfou('bandpass.fbn',1);
end
Fdat=[freqv,x,y]; vdat=[3e-4,3e-4];
[pv,fit,Cp]=elisml(Fdat,vdat,4,6);
graphnumber=grapause('helmltst',graphnumber,testsavegraphst);
rpalg=['ma'+0,NaN,NaN,NaN,0];
[pv0,fit0,Cp0]=elis(Fdat,vdat,['s',4,6],'f',rpalg);
echo off
if any(pv~=pv0), error('pv and pv0 differ in basic run'), end
i=find(~isnan(fit0-fit)); ind=find(i==18); if ~isempty(ind), i(ind)=[]; end
if any(fit(i)~=fit0(i)), error('fit and fit0 differ in basic run'), end
if any(any(Cp~=Cp0)), error('Cp and Cp0 differ in basic run'), end
echo on
%
%With only 1 output argument in elisml
pv1=elisml(Fdat,vdat,4,6);
graphnumber=grapause('helmltst',graphnumber,testsavegraphst);
echo off
if any(pv1~=pv0)
  error('pv1 and pv0 differ (one output argument in elisml)')
end
echo on
%
%1 output argument in both
pv=elisml(Fdat,vdat,4,6);
graphnumber=grapause('helmltst',graphnumber,testsavegraphst);
pv0=elis(Fdat,vdat,['s',4,6],'f', rpalg);
echo off
if any(pv~=pv0), error('pv and pv0 differ with 1 output argument'), end
rand('seed',0), randn('seed',0)
clear graphnumber vdat Cp Cp0 Fdat fit fit0 freqv i pv pv0 pv1 vdat x y rpalg
%%%%% End of helmltst %%%%%%%
