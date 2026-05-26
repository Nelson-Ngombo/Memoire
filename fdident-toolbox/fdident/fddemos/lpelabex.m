%LPELABEX Demonstration - an elaborated example of transfer function estimation

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
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
echo on
hold off, clc
%The complete frequency domain modelling procedure is illustrated
%on the example of an active Chebyshev lowpass filter.
%(Book, Chapter 9: A Guideline for Transfer Function Estimation, pp. 305-313).
%
%First, general information about the overall behavior of the transfer
%function is required. For this, a measurement is performed with a
%61-component Schroeder multisine from 48.8 Hz to 3 kHz, peak value of 2 V.
%The result is shown in the first plot.
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
disp('Some function m-files are being loaded ...')
[freqvect,x,y]=impfou('lowpass(lowpass_wideband)');
Fdat=[freqvect,x,y];
ploteltf('','',Fdat,['lin',0,3000])
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
echo on, clc
%The lowpass nature of the DUT is obvious. The passband is between dc and
%1 kHz, thus a new excitation signal is designed, containing 20 components,
%from 2*48.83 Hz = 97.7 Hz to 21*48.83 Hz = 1025.4 Hz.
%The peak value is again 2 V.
%
%To evaluate the measurement results, and to obtain a good fit, the noise
%has to be analyzed. This can be done by processing at least 50-100
%measurements. An already reasonable noise analysis using the 30
%measurements in these data is presented in the lowpdemo.m
%demonstration file (Identification of a system: active lowpass filter).
%Let us accept here that in the band of interest the power spectrum of the
%noise is constant, with sigmax=22.3 uV, sigmay=25.6 uV.
%
%The next step is fitting the measurements using ELiS. The best way to
%extract the maximum amount of information from the measurements is to fit
%the result of each measurement (all the 30), and average the resulting
%parameters. This can be done in a cycle, however, in order to spare time
%in the demonstration, the very first one will only be fitted.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
[freqvect,x,y]=impfou('lowpass(lowpass)',1);
Fdat=[freqvect,x,y];
[pv,fit]=elis(Fdat,[4.97e-10,6.55e-10],['s',0,6]',[1,1;9,0],'',2);
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
disp('********************')
disp('The theoretical value of the cost function is (2*20-7)/2=16.5, with a')
disp('standard deviation of sqrt(16.5)=4.06. Since the obtained value')
fprintf('(%.2f) is rather large, systematic errors are present\n',fit(1))
fprintf('in the model. The relative mean model error is %.4g.\n',fit(10)/fit(11))
disp('A possibility is to try to increase the model order.')
disp('Three possibilities will be checked: models 0/7, 0/8 and 2/8.')
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
NaNv=NaN; %bypass Vax problem with NaN*
[pv,fit]=elis(Fdat,[4.97e-10,6.55e-10],['s',0,7]',[1,1;10,0],'',...
                [2,NaNv(1,ones(1,7)),20*[1,1,1,1]]);
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
echo on
%********************
%A new stable pole appeared on the real axis, but the cost function is not
%decreased significantly.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
echo on
%
clc
%Let us increase the order of the denominator to 8.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause
[pv,fit]=elis(Fdat,[4.97e-10,6.55e-10],['s',0,8]',[1,1;11,0],'',2);
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
echo on
%*******************
%The cost function is in practically the same as above. Let us increase the
%numerator order as well, to 2.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
[pvect,fit,Cp]=elis(Fdat,[4.97e-10,6.55e-10],['s',2,8]',...
                [1,1;13,0],'ll',10);
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
echo on
%*******************
%There are two pole/zero pairs, apparently almost cancelling each other.
%This can be checked by plotting the confidence ellipses.
%First, the pole/zero pattern will be shown again, then the confidence
%ellipses of the zeros and poles will be shown, those of the zeros at the
%left side of the screen, those of the poles at the right side.
echo off
fdidpaus(textpause)
clf, subplot(1,2,1)
hold off
%
%Plot only zeros and covariance ellipses
[domain,num,denom]=imppar(pvect);
pvectz=exppar(domain,num,1);
Cpz=zeros(5,5); Cpz(1:3,1:3)=Cp(1:3,1:3); %The rest: denominator + delay
plotelpz(pvectz,Cpz,30,8e3*[-1,1,-1,1],'text')
subplot(1,2,2)
pvectp=exppar(domain,1,denom);
Cpp=zeros(11,11); Cpp(2:10,2:10)=Cp(4:12,4:12);
plotelpz(pvectp,Cpp,30,8e3*[-1,1,-1,1],'text')
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst,0.82,0.04);
echo on
clc
%The confidence ellipses of the pole/zero pairs are quite large, and
%practically coincide. The cross covariances between the real parts of a
%pair, and between the imaginary parts of a  pair provide the proof that
%they indeed move together.
echo off
[zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pvect,Cp);
izp=pairs(zv,pv);
fprintf('c_real = %.5f, c_imag = %.5f\n',rzp(1,3+2*izp(1)),rzp(2,4+2*izp(1)))
echo on
%It is reasonable to assume that these pole/zero pairs do not contain
%useful information about the model structure.
%
%The attempt to increase the model order did not lead to a better model.
%However, the cost function is still too large. Another cause may be that the
%assumptions are not valid, e.g. there are slight nonlinearities in the DUT.
%This can be checked the best by decreasing the amplitude of the excitation
%signal (let us say, to 150 mV). However, by small signal amplitudes the
%influence of the mains (50 Hz) may not be negligible. Fortunately, in the
%frequency domain this can be rather easily overcome: an excitation signal can
%be used with components at odd harmonics of 25 Hz, and these spectral lines
%will be processed only. Thus, there will be no leakage from the 50 Hz and
%its harmonics.
%When making the new measurements, the noise analysis has to be done again.
%The variable lowpass_lowlevel contains the result of 120 experiments, but
%since synchronization is necessary, the variance analysis of these data may
%take significant time.
echo off
fdidpaus(textpause,0.04)
disp(' ')
answ=yesinput('Do you want to execute noise analysis','n','y|n|yes|no');
disp(' ')
if exist('yesinpacceptdef'), clear rzp, end
if exist('varx')==1, clear varx, end
if exist('vary')==1, clear vary, end
if strcmp(answ(1),'y')
  disp('First let us check whether synchronization is indeed necessary.')
  fdidpaus(textpause)
  %fprintf('Press any key to continue ...'), pause, disp(' ')
  [freqvect,x,y,expno]=impfou('lowpass(lowpass_lowlevel)');
  Fvect=expfou(freqvect,x,y);
  clf, hold off, subplot(1,2,1)
  axis('square')
  plot(real(x),imag(x),['x',red]), title('Input amplitudes')
  axis('square'), axis('equal')
  subplot(1,2,2)
  plot(real(y),imag(y),['x',red]), title('Output amplitudes')
  axis('square'), axis('equal')
  graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
  clc
  disp('Indeed, the complex amplitudes turn around the origo. Consequently,')
  disp('in order to properly calculate the variances, the synchronization')
  disp('possibility of varanal has to be used.')
  fprintf('\nThe period length is %.4g s (1/25 Hz)\n',1/25)
  [varx,vary]=varanal(Fvect,[],'delayed',1/25);
  clf, subplot(1,2,1)
  plot(freqvect,varx,['+',green]), title('varx')
  plot(freqvect,vary,['+',green]), title('vary')
  xp=0; yp=0;
  txth=axes('Position',[0,0,1,1]); axis('off')
  text(xp,yp,'Calculated variances','VerticalAlignment','bottom')
  graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
  x=x(1:length(freqvect)); y=y(1:length(freqvect));
else
  [freqvect,x,y]=impfou('lowpass(lowpass_lowlevel)',1); %First experiment
end %check synchronization
echo off
Fvect=[freqvect,x,y]; %First experiment only
disp('The noise spectrum is no more flat.')
if ~strcmp(answ(1),'y')
  disp(['For the fit the variance vectors will be taken from the variable',...
      ' lowpass_exp1'])
  lowpass_exp1=loadvar('lowpass','lowpass_exp1');
  var=lowpass_exp1.OldTBSisoVariance;
  varx=var(:,1); vary=var(:,2);
  %[varx,vary]=impvar('lowpass2.vbn');
  fdidpaus(textpause,0.04)
else %'y'
  disp('For the fit the calculated variance vectors will be used.')
  fdidpaus(textpause)
end
%fprintf('Press any key to continue ...'), pause, disp(' ')
[pv,fit]=elis(Fvect,[varx,vary],['s',0,6],[1,1;9,0],'',3);
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
disp('********************')
fprintf(['The cost function (%.2f) is much closer to the theoretical',...
     ' value\n'],fit(1))
disp('than above. However, the modelling error is still not negligible.')
disp('Let us make an attempt with a model 0/7.')
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
[pv,fit]=elis(Fvect,[varx,vary],['s',0,7],[1,1;10,0],'',3);
graphnumber=grapause('lpelabex',graphnumber,demosavegraphst);
echo on
%********************
%The fit is seemingly better than before. However, this result may be
%surprizing, since the DUT is a 6th order filter. As explained in the Book,
%the 7th (real) pole at about 500 kHz may originate from the operational
%amplifiers of the active filter.
echo off
fdidpaus(textpause)
%fprintf('Press a key ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of lpelabex %%%%%%%%%%%%%%%%%%%%%%%%
