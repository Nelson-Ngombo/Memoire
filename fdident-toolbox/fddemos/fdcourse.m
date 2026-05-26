%FDCOURSE Course sequence for self-study
%       of the Frequency Domain System Identification Toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
hold off
global yesinpacceptdef
if ~exist('yesinpacceptdef'), eval('yesinpacceptdef='''';'), end
if ~exist('demosavegraphst'), demosavegraphst=''; end
graphnumber=0;
echo on
clc
%The transfer function of a bandpass filter has been measured repeatedly,
%using a multisine excitation consisting of 16 frequencies.
%The results of 25 experiments have been captured, the collected
%data have been preprocessed, and the input and output Fourier coefficients
%have been put into object 'bandpass_synch' in the file 'bandpass.mat'.
%First, let us have a look to the measured transfer function at the
%frequencies where the Fourier coefficients are given.
%TYPE IN YOUR OWN COMMAND(S) - or type just the word 'return' to see a solution
echo off
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
ploteltf('bandpass(bandpass_synch)')
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
echo on
%------------------------------------
%On the plot slight noise can be seen: the results of different experiments,
%plotted upon each other, are scattered a little bit. This is observable
%rather in the transition band than in the passband.
%In order to be able to perform identification of the transfer
%function, the values of the noise variances are required.
%It is also advisable to check the value of the input-output covariance:
%it may provide an indication of synchronization imperfections, excitation
%signal instability, noisy excitation etc.
%These can be obtained via noise analysis.
%TYPE IN YOUR OWN COMMAND(S) - or type just the word 'return' to see a solution
echo off
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
avobj=varanal('bandpass(bandpass_synch)');
var=avobj.OldTBSisoVariance; %internally the real variances are usd
vx=var(:,1); vy=var(:,2); cxy=var(:,3);
save fdcourse.mat vx vy cxy
%------------------------------------
%Now a quick check will show whether the noise is small indeed
%when compared to the Fourier amplitudes.
%Let us load the amplitudes of the 1st experiment and compare
%them to the standard deviations (sqrt(variance))
%TYPE IN YOUR OWN COMMAND(S) - or type just the word 'return' to see a solution
echo off
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
load fdcourse.mat
[freqv,x,y]=impfou('bandpass(bandpass_synch)',1);
save fdcourse.mat vx vy cxy freqv x y
clf
%The commands below are for plotting only; they may be omitted.
%The relative standard deviations can be simply listed by:
%[sqrt(vx)./abs(x),sqrt(vy)./abs(y)]
subplot(221), plot(freqv,abs(x),'x'), title('Input amplitudes')
axv=axis; axv(3)=0; axis(axv); hold off
subplot(222), plot(freqv,abs(y),'x'), title('Output amplitudes')
axv=axis; axv(3)=0; axis(axv); hold off
subplot(223), plot(freqv,sqrt(vx),'x'), title('Input std''s')
axv=axis; axv(3)=0; axis(axv); hold off
subplot(224), plot(freqv,sqrt(vy),'x'), title('Output std''s')
axv=axis; axv(3)=0; axis(axv); hold off
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
echo on
%------------------------------------
%The SNR is large enough.
%The amount of input-output correlation can be checked by looking to
%the correlation coefficients:
%rio=(cxy./sqrt(vx.*vy))
pause
rio=(cxy./sqrt(vx.*vy))
pause
%------------------------------------
%The covariance values are quite small. Estimated from 25 experiments only, the
%exact values could be equal to zero. It would not make any harm to use the
%obtained values in elis, but they can equally be omitted.
%
%Now, since we have the variance values, identification may begin.
%elis can be invoked, with the Fourier and variance data,
%and with the selection of the orders.
%Looking to the transfer function, the number of peaks gives
%a quick estimation of the denominator order: each resonance peak
%will correspond to a complex pole pair. The number of zeros
%is more difficult to guess; from the bandpass nature of the
%transfer function it is reasonable to choose it as smaller
%by 1-2 than the number of poles.
%TYPE IN YOUR OWN COMMAND(S) - or type just the word 'return' to see a solution
echo off
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
load fdcourse.mat
elis([freqv,x,y],[vx,vy],['s',4,6]);
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
echo on
%------------------------------------
%Whether the model is good enough, can be determined from
%the actual and theoretical values of the cost function.
%It should be close to the theoretical value.
%However, the model orders can still be too large, so it is
%worth trying smaller orders.
%A too large order can also be discovered from the large
%uncertainties of some of the poles/zeros, slow convergence etc.
%Try out different order combinations to find one
%that you consider as being optimal.
%TYPE IN YOUR OWN COMMAND(S) - or type just the word 'return' to see a solution
echo off
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
load fdcourse.mat
%------------------------------------
elis([freqv,x,y],[vx,vy],['s',0,6]);
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
showex=yesinput('Show more examples of fits with elis (y/n)','y','y|n');
if strcmp(showex,'y')
echo on
%------------------------------------
elis([freqv,x,y],[vx,vy],['s',2,6]);
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
%------------------------------------
elis([freqv,x,y],[vx,vy],['s',3,6]);
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
%------------------------------------
elis([freqv,x,y],[vx,vy],['s',4,4]);
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
end %showex
%
echo on
%------------------------------------
%In order to examine the uncertainties, the parameter vector
%and the covariance matrix has to be obtained as output
%arguments of elis. Let's plot the confidence ellipses
%for a probably high order of your choice.
%The running of elis will be much quicker if the plots are
%made in every 5th or 10th cycle (give the input argument rppl
%of elis as 5 or 10)
%TYPE IN YOUR OWN COMMAND(S) - or type just the word 'return' to see a solution
echo off
if ~strcmp(yesinpacceptdef,'yes'), keyboard, else disp('K>> return'), end
echo on
load fdcourse.mat
[pv,fit,Cp]=elis([freqv,x,y],[vx,vy],['s',5,7],[],[],10);
clf, plotelpz(pv,Cp)
echo off
graphnumber=grapause('fdcourse',graphnumber,demosavegraphst);
%save fdcourse.mat vx vy cxy freqv x y fit pv Cp
delete fdcourse.mat
%
%%%%%%%%%%%%%%%%%%%%%% End of fdcourse %%%%%%%%%%%%%%%%%%%%%%%%
