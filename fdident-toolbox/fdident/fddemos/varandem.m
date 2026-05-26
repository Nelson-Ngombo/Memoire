%VARANDEM Demonstration of varanal

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
echo on, clc
%Varanal is a data preprocessing routine, for averaging and variance analysis
%of a series of measurements.
%Averaging can be properly performed only if the measurements are synchronized
%to each other: the measurements were performed at the very same phase of the
%excitation signal. This requirement cannot always be met, because a multisine
%has several zero crossings, thus the arbitrary waveform generator should
%provide an appropriate trigger signal, and the digitizer should start sampling
%in a very short time after the trigger.
%Variance analysis is usually performed with no excitation. However, some
%noises like quantization noise will not be present without excitation signal.
%Therefore, it is desirable to perform variance analysis on the basis of actual
%measurements. This can be performed again on synchronized measurements only.
%With periodic excitation, it is possible to 'synchronize' the results of
%non-synchronized measurements by appropriate (e.g. maximum likelihood)
%estimation of the delay between measured records, supposed that the
%signal-to-noise ratio is not too bad. The details are described in the
%following paper: I. Kollar, "Signal Enhancement Using Non-Synchronized
%Measurements", IEEE Trans. on Instrumentation and Measurement, Vol. 41, No. 1,
%pp. 156-159. Feb. 1992.
%In this demonstration non-synchronised measurements are simulated, assuring
%that the record length covers an integer number of periods of the excitation.
%Synchronization, averaging and noise analysis will be performed using varanal.
echo off
rand('seed',0), randn('seed',0)
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
%
fprintf('Press a key to continue...'), pause, disp(' ')
%
num=[4,4]; denom=[1,2,3,4];
pdat=exppar('s',num,denom,0);
N=32; freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(j*2*pi*rand(fl,1));
vdat=1e-2*[1,1];
expno=20;
x=zeros(fl*expno,1); y=x; fv=x;
fprintf('Simulation of %.0f experiments is being performed...\n',expno)
tauv=N*(rand(expno-1,1)-0.5);
fprintf('experiment =')
for k=0:expno-1
  fprintf(' %.0f',k+1)
  if k==0, tau=0; else tau=tauv(k); end
  [xk,yk]=simfou(pdat,freqv,cx.*exp(-j*2*pi*freqv*tau),vdat);
  x(k*fl+[1:fl])=xk; y(k*fl+[1:fl])=yk; fv(k*fl+[1:fl])=freqv;
end
disp(' ')
Fdat=expfou(freqv,x,y);
echo off
disp('Synchronization and averaging follow...')
[varx,vary,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',N);
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
clc
disp('The estimated delays are quite reasonable.')
disp('True and estimated delays (-16<tau<16):')
for k=1:length(tauv), fprintf('%6.3f    %6.3f\n',tauv(k),dv(k)), end
fdidpaus(textpause)
%fprintf('Press a key to continue...'), pause, disp(' ')
clf, hold off
spl=['subplot(2,2,1)';'subplot(2,2,2)';'subplot(2,2,3)';'subplot(2,2,4)'];
eval(spl(1,:))
plot(freqv,varx,['x',white],freqv([1,fl]),vdat,['-',red],...
        freqv,cfl(1)*varx,[':',green],freqv,cfl(2)*varx,[':',green])
axv=axis;
axv(1)=0; axv(2)=0.5; axv(3)=0; axv(4)=0.04; axis(axv);
title('    Estimated and true varx')
xlabel('(:) - 68% confidence bounds')
eval(spl(2,:))
plot(freqv,vary,['x',white],freqv([1,fl]),vdat,['-',red],...
        freqv,cfl(1)*vary,[':',green],freqv,cfl(2)*vary,[':',green])
axv=axis;
axv(1)=0; axv(2)=0.5; axv(3)=0; axv(4)=0.04; axis(axv);
title('    Estimated and true vary')
xlabel('(:) - 68% confidence bounds')
eval(spl(3,:))
plot(fv,abs(x),['x',white],freqv,abs(cx),['-',green])
title('Measured input amplitudes')
axv=axis;
axv(1)=0; axv(2)=0.5;
daxv=diff(axv(3:4)); axv(3:4)=axv(3:4)+0.05*[-1,1]*daxv; clear daxv
axis(axv);
eval(spl(4,:))
axis(axv); plot(freqv,abs(mx),['x',white],freqv,abs(cx),['-',green])
axis(axv)
title('Averaged input amplitudes')
clear x y fv
graphnumber=grapause('varandem',graphnumber,demosavegraphst);
%
clc, disp('Now let us check the fit of the transfer function of the system')
disp('and the ratio of the averaged complex output and input amplitudes.')
fdidpaus(textpause)
%fprintf('Press a key to continue...'), pause, disp(' ')
ploteltf(pdat,'',[freqv,mx,my]);
graphnumber=grapause('varandem',graphnumber,demosavegraphst);
rand('seed',0), randn('seed',0)
%%%%%%%%%%%%%%%%%%%%%%%% End of varandem %%%%%%%%%%%%%%%%%%%%%%%%%
