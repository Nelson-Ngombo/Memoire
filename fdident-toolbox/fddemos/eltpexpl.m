%ELTPEXPL An example for the use of elistper

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
echo on, clc
%This demonstration script M-file illustrates the ease of identification
%with the Frequency Domain System Identification Toolbox.
%
%First let us simulate an experiment. This takes a couple of lines.
%We assume that periodic excitation is applied, and exactly 10 periods
%of the time domain input and output signals are measured.
%The data acquisition channels are band-limited, the sampling frequency
%is chosen properly, above the Nyquist rate.
%
echo off
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
fdidpaus(textpause)
echo on
%
%The system is defined as follows.
num=[1,1]; denom=[4,3,2,1]; pdat=exppar('s',num,denom);
%The excitation signal is generated next.
freqv=[0.05:0.05:1.0]'; F=length(freqv);
lp=1024; fs=lp*0.05; pno=10;
cx=msinclip(freqv,ones(size(freqv)),[],'nograph',0);
xt0=msinprep(freqv,cx,lp*pno,fs,'screen')*pno; %rescale by pno to assure mx~1.0
%Now the measurement is simulated:
vmx=2e-5; vmy=1e-6; %Variance of mx and my
[xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,fs);
%
echo off
fprintf('Press a key to continue ...'), pause, disp(' '), clc, echo on
%Given xt,yt,fs and freqv (data available from the experiment),
%the numerator and denominator orders have to be
%chosen, and identification consists from just one line:
%
%[pv,fit,Cp,Fdat,vdat]=elistper(xt,yt,fs,freqv,1,3);
%
%If the model order has to be changed, fits with new orders can be easily
%obtained like
%elisml(Fdat,vdat,2,3);
%
echo off
fprintf('Press a key to continue ...'), pause, disp(' '), clc
echo on
[pv,fit,Cp,Fdat,vdat]=elistper(xt,yt,fs,freqv,1,3);
echo off
graphnumber=grapause('eltpexpl',graphnumber,demosavegraphst);
echo on
%
elisml(Fdat,vdat,2,3);
echo off
graphnumber=grapause('eltpexpl',graphnumber,demosavegraphst);
%
clear xt yt xt0
%%%%% End of eltpexpl %%%%%%%
