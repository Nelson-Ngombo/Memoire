%PLOTRARM  Plot time domain data from file robotarm.mat

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

%OLd call
%load robotarm.mat %xt yt ascale fs N freqind
%fnam='robotarm';
%xt=xt*ascale; yt=yt*ascale;
%
%New call
rarmobj=loadvar('robotarm','robotarm_rawdata');
xt=rarmobj.input; yt=rarmobj.output;
fs=1/rarmobj.ts;
freqind=round(fs/rarmobj.frequencies);
N=length(xt);
%
dt=1/fs;
Nl=length(xt);
timevect=[1:Nl]'*dt;
clf, hold off
subplot(211)
plot(timevect,xt,'-')
title(sprintf('Input data (torque), number of points: %.0f',Nl))
xlabel('Time, s')
subplot(212)
plot(timevect,yt,'-')
title(sprintf('Output data (acceleration), number of points: %.0f',Nl))
xlabel('Time, s')
%
%eval(['print -deps ',fnam,'.eps'])
%
%%%%%%%%% End of plotrarm %%%%%%%%%%%
