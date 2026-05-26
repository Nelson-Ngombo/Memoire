%RARMDEMO Demonstration - system identification: flexible robot arm

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
clear xt
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
clf
%
%Code for automatic generation of all plots in rarm??.eps files:
%    w=0; pause off, yiad
%    demosavegraphst=['w=w+1;wtx=sprintf(''%02.0f'',w);',...
%       ', eval([''print -deps rarm'',wtx,''.eps''])',...
%       ', disp([''SAVE GRAPH TO FILE rarm'',wtx,''.eps ...''])'];
%End of code for automatic postscript file generation
%
echo on, clc
%The behavior of a flexible robot arm was measured by applying controlled
%torque to the vertical axis at one end of the arm, and measuring the
%tangential acceleration of the other end. The excitation signal was a
%multisine, generated with frequency components at [1:2:199]*df, with
%df = 500/4096 = 0.122 Hz, that is, in the frequency range 0.122 Hz - 24.3 Hz.
%The originally flat multisine was distorted by the nonlinear behavior of
%the actuator. The odd harmonic frequencies provided that components produced
%by a squaring nonlinearity would not disturb the identification. The input and
%output signals were sampled with sampling frequency fs = 500 Hz. Sampling was
%synchronized to the excitation signal so that 4096 samples were taken from
%each period. The data records contain 40960 points, that is, 10 periods were
%measured.
%With floating-point storage, the 2*4e4 data points had to be stored in
%8*2*4e4 = 640 kBytes. Therefore, the time domain data are scaled to 16-bit
%integers: the file size is reduced by a factor of 4.
%    Note: This measurement was made at the Department of Mechanical
%Engineering, Catholic University of Leuven (KUL), in cooperation with
%Department ELEC, Vrije Universiteit Brussel (VUB), as a part of the Belgian
%program "Interuniversity Attraction Poles (IUAP50: Robotics and Industrial
%Automation)" initiated by the Belgian State, Prime Minister's Office,
%Science Policy Programming. These data belong to the public domain and can
%be freely used by anyone.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
if ~exist('showxt')
  if strcmp(version,'4.0'), showxt='n';
    if strcmp(get(0,'diary'),'on'), diary off, diary on, end
  else showxt='y';
  end
end
fprintf(['\nFirst the time domain data and the autocorrelation function ',...
        'can be investigated.\nThis involves plotting of large data sets.\n'])
showxt=yesinput('Do you want to see time domain data and correlation, y/n',...
        showxt,'y|n');
disp(' ')
if strcmp(showxt,'y'), disp('Let us have a look at the time domain data.')
%else disp('The transformation to the frequency domain will take some time...')
end
if ~exist('filesep')
  p=path; ind=findstr(p,'fddemos');
  if length(ind)==1, filesep=p(ind)-1;
  else filesep=='';
  end
end

v=version;
if v(1)=='4', load robotarm.mat
  error('Unfortunately, this demo cannot be run in Matlab4')
else load('robotarm.mat')
end
%xt = scaled input time record, 40960x1
%yt = scaled output time record, 40960x1
%fs = sampling frequency, 500 Hz
%ascale = scaling factor of the time records
%N = number of points in a period (4096)
%freqind = index numbers of sine waves in DFT of a period, [1:2:199]'
if ~exist('xt')|~exist('ascale')
  eval('xt=robotarm_rawdata.input; yt=robotarm_rawdata.output;')
  eval('fs=1/robotarm_rawdata.ts; ascale=1; N=4096; freqind=[1:2:199]'';')
end
%
N=4096; %For casesen off, otherwise N is not accessible
xt=xt*ascale; yt=yt*ascale;
dt=1/fs; df=fs/N;
Nl=length(xt); expno=Nl/N;
T=Nl*dt;
timevtot=[1:Nl]'*dt;
freqindtot=freqind*expno;
clf, hold off
if strcmp(showxt,'y')
  subplot(2,1,1)
  plot(timevtot,xt,'-')
  title(sprintf('Input data (torque), number of points: %.0f',Nl))
  xlabel('Time, s')
  subplot(2,1,2)
  plot(timevtot,yt,'-')
  title(sprintf('Output data (acceleration), number of points: %.0f',Nl))
  xlabel('Time, s')
  %
  graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
  %
  echo on
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Not much can be stated on basis of the time functions, not even the period
%length can be read off. The input signal has apparently a smaller crest
%factor than the output one, but that's about all we can see.
%More can be determined from the autocovariance function.
%We will evaluate the so-called circular correlation, which is the inverse
%Fourier transform of the periodogram, (1/Nl)*abs(X).^2.
%We will suppress the dc component to get the autocovariance.
%In order to have an immediate information about the periodicity,
%we will connect every 4096th point by a dotted line.
%
echo off
if strcmp(showxt,'y')
  fdidpaus(textpause)
  %fprintf('Press any key to continue ...'), pause, disp(' ')
end
%
X=fft(xt); dcx=X(1); X(1)=0; Sx=(1/Nl)*abs(X).^2;
echo off
if strcmp(showxt,'y')
  Cx=real(ifft(Sx));
  clf
  subplot(2,1,1)
  axv=[0,max(timevtot),1.1*min(Cx),1.1*max(Cx)];
  plot(timevtot,Cx,'-',timevtot([1:4096:Nl,Nl]),Cx([1:4096:Nl,Nl]),':')
  axis(axv), grid off
  title('Circular autocovariance function'), xlabel('time, s')
  %
  graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
  %
  echo on
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%From the autocovariance function several conclusions can be drawn.
%First of all, there is indeed a periodicity of 4096*dt = 8.192 s.
%The autocovariance function corresponds to a bandlimited white spectrum,
%the negative peaks verify the use of odd harmonics at [1:2:199]*df.
%The signal was oversampled by a factor of 2048/199=10, that is, from the
%sin(x)/x shaped main lobes of the autocovariance function about 20 points
%are sampled.
%Let us have a look at them.
echo off
if strcmp(showxt,'y')
  p1h=axes('Position',[0.1300,0.1100,0.3175,0.3375]);
  pv=1*4096+1+[-15:15];
  axv=[min(timevtot(pv))-dt,max(timevtot(pv))+dt,...
                1.2*min(Cx(pv)),1.1*max(Cx(pv))];
  plot(timevtot(pv),Cx(pv),'o',timevtot(pv),Cx(pv),':')
  axis(axv), grid off
  mpv=median(pv); hold on
  plot(axv(1:2),[0,0],':',timevtot(mpv)*[1,1],[0,Cx(mpv)],':')
  title('Lag No. 1')
  hold off
  p2h=axes('Position',[0.5825,0.1100,0.3175,0.3375]);
  pv=5*4096+1+[-15:15];
  axv=[min(timevtot(pv))-dt,max(timevtot(pv))+dt,...
                1.2*min(Cx(pv)),1.1*max(Cx(pv))];
  plot(timevtot(pv),Cx(pv),'o',timevtot(pv),Cx(pv),':')
  axis(axv), grid off
  mpv=median(pv); hold on
  plot(axv(1:2),[0,0],':',timevtot(mpv)*[1,1],[0,Cx(mpv)],':')
  title('Lag No. 5')
  hold off
  clear timevtot
  %
  graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
  %
  echo on
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%It is obvious from the enlarged peaks that synchronization is very good
%between the excitation signal and the sampling clock.
%This can be also verified in the frequency domain, as we will see later.
%If there was a slip, it could not be more than about 0.003%
%(dt/2 in a time of 4*4096*dt).
%The autocovariance function can be used for approximate determination
%of the signal-to-noise ratio: the power of the periodic components is
%approximately given by one of the peaks at nonzero lag, the total power is
%given by the covariance value at zero.
echo off
if strcmp(showxt,'y')
  PtotxC=Cx(1); PperxC=mean(Cx([1:9]*N+1));
  fprintf('Cx(0) = %.3g, Cx(k*Tp) = %.3g, SNRx = %.1f dB\n',Cx(1),Cx(N+1),...
                10*log10(PperxC/(PtotxC-PperxC)) )
  if exist('yesinpacceptdef'), clear Cx, end
  echo on
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%However, this not exactly what we need: the useful signal has power at the
%given frequencies only, the rest is spurious components, produced by the
%nonlinearities.
%
echo off
if strcmp(showxt,'y')
  fdidpaus(textpause)
  %fprintf('Press any key to continue ...'), pause, disp(' ')
end
%
freqvtot=[0:Nl/2-1]'/Nl*fs;
Y=fft(yt); dcy=Y(1); Y(1)=0;
Sy=(1/Nl)*abs(Y).^2;
clf, hold off
subplot(2,1,1)
plot(freqvtot,abs(X(1:Nl/2)) )
clear X
title('Input amplitudes'), xlabel('Frequency, Hz')
subplot(2,1,2)
plot(freqvtot,abs(Y(1:Nl/2)) )
title('Output amplitudes'), xlabel('Frequency, Hz')
clear freqvtot Y
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The input amplitude spectrum is not really flat. The cause is most probably
%the non-flat transfer function of the system composed of the actuator and
%the device under test. The two dips at 7.2 Hz and 15.7 Hz in the input
%spectrum correspond probably two resonance points of the system, where
%the actuator is not capable to maintain the signal level.
%This is not a serious problem since the frequency range of interest is
%sufficiently covered by nonzero excitation amplitudes.
%The powers of the useful signal, of the harmonic components, and of the noise
%can be calculated for both the input and the output signals.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pux=2*sum(Sx(freqindtot+1))/Nl; Ptotx=sum(Sx)/Nl;
Pperx=sum(Sx(Nl/N+1:Nl/N:length(Sx)))/Nl; %sum periodic components
Puy=2*sum(Sy(freqindtot+1))/Nl; Ptoty=sum(Sy)/Nl;
Ppery=sum(Sy(Nl/N+1:Nl/N:length(Sx)))/Nl; %sum periodic components
echo off
%Pperx=real(exp(j*2*pi*N*[0:Nl-1]/Nl)*Sx)/Nl; %old statement
%Ppery=real(exp(j*2*pi*N*[0:Nl-1]/Nl)*Sy)/Nl; %old statement
clear Sx Sy
%
fprintf('  Input signal:\n')
fprintf('    Total power: %.3g, useful power: %.3g, noise power: %.3g\n',...
                Ptotx,Pux,Ptotx-Pperx)
fprintf('    Power of spurious periodic components: %.3g\n',Pperx-Pux)
fprintf('    SNR: %.1f dB, for useful components only: %.1f dB\n',...
                10*log10(Pperx/(Ptotx-Pperx)),10*log10(Pux/(Ptotx-Pux)) )
%
fprintf('  Output signal:\n')
fprintf('    Total power: %.3g, useful power: %.3g, noise power: %.3g\n',...
                Ptoty,Puy,Ptoty-Ppery)
fprintf('    Power of spurious periodic components: %.3g\n',Ppery-Puy)
fprintf('    SNR: %.1f dB, for useful components only: %.1f dB\n',...
                10*log10(Ppery/(Ptoty-Ppery)),10*log10(Puy/(Ptoty-Puy)) )
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The signal-to noise ratios are quite good, although the nonlinearities
%produce significant components.
%Since the noise is larger than the nonlinearity products, these will
%hopefully not deteriorate the identification significantly.
%Let us notice moreover that we are going to select the excitation lines
%[1:2:199] only, so the SNR will be improved by a factor of about 20 (13 dB).
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now periodwise transformation to frequency domain and noise analysis follows.
%10 periods were measured. We will treat each period as a separate experiment,
%thus noise analysis can be performed. The time vector of a period
%(one experiment) is shorter than the measurement data vectors xt and yt.
%Therefore, the easiest way for passing the data to tim2fou is to use exptim.
timevect=[1:N]'*dt; freqv=freqind*df; F=length(freqind);
Fdat=tim2fou(exptim(timevect,xt,yt),freqv);
clear xt yt timevect
%
%Frequency domain noise analysis can be performed using varanal.
%We already know that the measurements are well synchronized to the
%excitation signal, but a last test can be performed, making use of
%the post-measurement synchronization possibility.
%This may take considerable time.
echo off
synch=yesinput('Do you want to check synchronization, y/n','n','y|n');
if strcmp(synch,'y'), synch='delayed'; disp('synch=''delayed'';'),
else synch=''; disp('synch='''';')
end
echo on
[vx,vy,cxy,mx,my,Na,Np,cfl,dv,sd]=varanal(Fdat,[],synch);
echo off
if strncmp(synch,'delayed',3)
  fprintf('Sampling interval: dt = %.3g s, sd/dt = %.3g\n',dt,sd/dt)
end
%
PNx=0; Px=0; PNy=0; Py=0;
%mxl=mx(:,ones(1,10)); PNxl=2*sum(abs(x-mxl(:)).^2/N)/N/9; clear mxl
%myl=my(:,ones(1,10)); PNy=2*sum(abs(y-myl(:)).^2/N)/N/9; clear myl
Px=2*sum(abs(mx).^2/N)/N; Py=2*sum(abs(my).^2/N)/N;
PNx=2*sum(2*vx/N)/N; PNy=2*sum(2*vy/N)/N;
subplot(2,2,1)
plot(freqv,vx,'+'), title('Input variances'), xlabel('Frequency, Hz')
ylabel(sprintf('SNR = %.1f dB',10*log10(Px/PNx)))
subplot(2,2,2)
plot(freqv,vy,'+'), title('Output variances'), xlabel('Frequency, Hz')
ylabel(sprintf('SNR = %.1f dB',10*log10(Py/PNy)))
subplot(2,2,3)
plot(freqv,abs(cxy),'+'), title('I/O covariances'), xlabel('Frequency, Hz')
subplot(2,2,4)
plot(freqv,abs(cxy)./sqrt(vx.*vy),'+')
title('I/O corr. coefficients'), xlabel('Frequency, Hz')
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The total SNR is indeed increased by the selection of the points of interest:
echo off
fprintf('SNRinp = %.1f dB, SNRoutp = %.1f dB\n',...
        10*log10(Px/PNx),10*log10(Py/PNy))
echo on
%The increase of about 5-6 dB is due to the oversampling and selection of
%points of interest only. It is less than expected, probably because the
%noise has less power at higher frequencies than at in the lower frequency band.
%The input-output covariances are quite large, so they may not be neglected.
%This could mean that a part of the noise goes through the system, that is,
%the estimation is corrupted by less noise than calculated above.
%This can be verified by plotting cxy./vx: if an important part of the
%noise goes through the system, this plot will have a shape similar to
%the transfer function. We will make this plot when the approximate
%shape of the transfer function will already be plotted.
%
%A rough guess about the gain in SNR can be obtained by calculation of the
%SNR of the nonparametric estimate of the transfer function.
%The SNR of this nonparametric estimate is smaller than those above, because
%the division ym./xm amplifies the noise significantly where xm is small.
%In elis, this division is not used, as it can be seen from the cost function.
echo off
[tfm,stdAm]=stdtfm([freqv,mx,my],[vx,vy]);
[tfmc,stdAmc]=stdtfm([freqv,mx,my],[vx,vy,cxy]);
SNRtfm=10*log10(sum(abs(tfm).^2)/sum(2*stdAm.^2));
SNRtfmc=10*log10(sum(abs(tfmc).^2)/sum(2*stdAmc.^2));
fprintf('SNRtfm without covariance: %.1f dB, with covariance: %.1f dB\n',...
                SNRtfm,SNRtfmc)
echo on
%
%The SNR can also be studied at the selected points, by calculating it
%both for the input and the output. However, it is much quicker to plot
%the nonparameteric transfer function estimates with uncertainties
%using ploteltf.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
[fv,x,y]=impfou(Fdat); clear Fdat
ploteltf('','',[freqv,x(1:F),y(1:F)],'','',[vx,vy,cxy])
echo off
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The SNR is quite good indeed.
%Now cxy./vx will be plotted to check the assumption that a significant
%part of the noise goes through the system.
ploteltf('','',[freqv,ones(100,1),cxy./vx])
echo off
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Indeed, cxy./vx has a shape very similar to the transfer function.
%
%We can now proceed with identification.
%Since the experiments are very well synchronized, the average of the
%complex amplitudes, mx and my can be used.
%Since these averaged quantities have smaller variances, vx, vy and cxy
%have to be divided by the number of averaged experiments, Na.
%For the run of elis, the numerator and denominator orders of the transfer
%function have to be given. From the nonparametric plot it is obvious that
%at least two complex pole pairs and two complex zero pairs will be
%necessary.
%So, let us start with a system 4/4.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
Fdat=[freqv,mx,my]; vdat=[vx,vy,cxy]/Na;
[pv,fit,Cp]=elis(Fdat,vdat,['s',4,4],[],'',10);
%
echo off
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The fit is quite good, but the cost function is still large, and there
%is an apparent mismatch at the higher frequency band.
%It seems to be reasonable to increase the orders.
%Let us try a 6/6 system.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
[pv66,fit66,Cp66]=elis(Fdat,vdat,['s',6,6],[],'',10);
%
echo off
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The fit is much better. The cost function got quite close to the
%theoretical value, however, it is still larger than the theoretical
%value by a factor of 2.5, so there are probably still small modeling
%errors. A model of order 8/8 can still be tried.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
[pv,fit88,Cp]=elis(Fdat,vdat,['s',8,8],[],[NaN,NaN,100],30);
%
echo off
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo off
%
disp('%The 8/8 model is not much better than the 6/6 one, the cost')
fprintf('%%function decreased from %.1f to %.1f only, the theoretical\n',...
                fit66(1),fit88(1))
fprintf('%%values are 91 and 93, respectively.\n')
echo on
%The large number of necessary iterations is also an indicator
%of probable overmodeling.
%Now other attempts can be made with different numerator and denominator
%orders, but none of them is successful finding a better fitting stable
%model than the 6/6 one. The modeling error is probably due to
%nonlinearities. The order need not be further increased.
%However, still there is a chance that a lower-order system can
%be as good as the 6/6 one.
%Let us make a pole-zero uncertainty plot of the 6/6 model.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
plotelpz(pv66,Cp66,2)
echo off
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The confidence ellipses are quite small, so they are of no use
%in this case. What can be seen is that the one zero pair and one pole pair
%have larger variance than the rest.
%However, we can speculate that the real zero pair far from the imaginary
%axis plays no important role, so it is reasonable to decrease the numerator
%order by 2. This will also allow that the transfer function decreases for
%higher frequencies, the usual behavior of physical systems.
%The two poles may correspond to the resonance around 42 Hz,
%shown in the complex output amplitude plot. At this frequency
%there was no excitation applied, however, the nonlinearities
%produced enough overharmonics to show this resonance.
%For a proper identification of it, the complex input/output amplitudes
%around this frequency should also be used, and a broader excitations
%signal should have been applied.
%We are not going to specifically deal with this resonance, but will
%proceed with the above used data.
%But before making the 4/6 fit, let us have a closer look at
%the uncertainties of the important poles and zeros.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on
plotelpz(pv66,Cp66,[],[-0.8,0.05,-200,200])
echo off
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The dominant error is in the damping of the poles and zeros:
%their frequencies are well determined.
%Let us do now a 4/6 fit.
%For a thorough study of this fit, a report file can be generated.
%Type in the desired name of the report file, or accept the - for no
%report file generation.
echo off
rpf=yesinput('Name of the report file','-');
if strcmp(rpf,'-'), rpf='';
else
  indp=find(rpf=='.');
  if isempty(indp), rpf=[rpf,'.m']; end
end
%
echo on
[pv46,fit46,Cp46]=elis(Fdat,vdat,['s',4,6],[],'',10,[],rpf);
if ~isempty(rpf), more on, type(rpf), more off, end
%
echo off
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The fit seems to be very reasonable. We have a good identified model.
%
%The  4/6 model can be verified using the standard techniques of the
%toolbox. We will not do all the possible tests, but will do
%some of the typical ones.
%One of the most important indicators of the quality of the fit is the
%value of the cost function, already discussed above.
%It is also important to examine visually the quality of the fit on the
%plot of elis. In this case the error is too small to be easily detected
%on the plots. The phase errors at the zeros are not really important,
%since here the phase information of the measurements is small.
%The confidence interval plots using ploteltf could also be used, but
%the confidence intervals would have to be magnified for visual checking.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
%Errorbar: 100*sigma
echo on
ploteltf(pv46,[],expfou(freqv,x(1:F),y(1:F)),'','',Cp46)
echo off
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Even with a bound of 100*sigma, not much can be seen.
%It is better to look for other tests.
%We think that there are modeling errors, so let us check the approximate
%mean model error.
echo off
fprintf('Approximate mean model errors:\n')
fprintf('4/6 model   6/6 model   8/8 model\n')
fprintf('  %.2f        %.2f        %.2f\n',fit46(10),fit66(10),fit88(10))
fprintf('Mean absolute value of the transfer function:\n')
fprintf('  %.2f        %.2f        %.2f\n',fit46(11),fit66(11),fit88(11))
echo on
%These values illustrate that the modeling error is not negligible,
%and is in the same order of magnitude for all three fits.
%Because of the modeling error, the Akaike criterion cannot be used.
%For closer investigation of the quality of the fit, the residuals
%can be calculated.
[rx,ry,ryx,vryx,xe,ye]=rdueelis(pv46,Cp46,expfou(freqv,x,y),[vx,vy,cxy]);
echo off
if exist('yesinpacceptdef'), clear x y freqv, end
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
if exist('yesinpacceptdef'), clear ry rx, end
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rx, ry and ryx can be studied for normal distribution and whiteness.
%We will do a few tests for ryx.
%First, it has to be standardized, dividing the residuals at each frequency
%point by the standard deviation.
il=[1:F]'; il=il(:,ones(1,expno)); il=il(:);
ryxn=ryx./sqrt(vryx(il));
%If the fit is good, the standardized residuals have to exhibit circular
%standard normal distribution at each point, and they have to be
%independent. These properties will be checked by simple tests.
%First, let us draw the histograms of the real and of the imaginary parts.
%The dotted lines show the standard normal probability density function,
%scaled up to the histogram which is  made of 1000 points, with dx = 0.2.
dx=0.2; X=[-3.8:dx:3.8];
Nhr=hist(real(ryxn),X); Nhi=hist(imag(ryxn),X);
fX=1/sqrt(2*pi)*exp(-X.^2/2);
echo off
np=F*expno;
clf
subplot(121), bar(X,Nhr), hold on, plot(X,fX*np*dx,':g'), hold off
title('Histogram of real part'), xlabel('real(ryxn)')
subplot(122), bar(X,Nhi), hold on, plot(X,fX*np*dx,':g'), hold off
title('Histogram of imaginary part'), xlabel('imag(ryxn)')
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The fit is good. The chi-squared value can also be evaluated
%for both histograms.
echo off
i=find((X >= -2)&(X <= 2));
%simple approximate calculation:
NPiv=fX(i)*dx*np;
%More involved, exact calculation:
%NPiv=np*0.5*( erf((X(i)+dx/2)/sqrt(2)) - erf((X(i)-dx/2)/sqrt(2)) );
chir=sum(((Nhr(i)-NPiv).^2)./NPiv); chii=sum(((Nhi(i)-NPiv).^2)./NPiv);
fprintf('E{chi^2} = %.0f, chi^2_real: %.1f,  chi^2_imag: %.1f\n',...
                length(i)-1,chir,chii)
echo on
%The test shows no significant deviation from the standard normal
%distribution.
%
%As a last test, let us plot the so-called Function of Dependency, the
%autocorrelation function of the frequency domain residual series.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
echo off
%
%Cf=real(fft(1/np*abs(ifft(ryxn)).^2));
%clf, plot(Cf), title('Frequency domain autocorrelation of ryxn')
%xlabel('Indices (through all experiments)')
%echo off
%if exist('yesinpacceptdef'), clear ryxn Cf, end
%
CR=impcov(Cp46,'nofixp'); parno=size(CR,1); clear CR
clf
corrtest(ryx(1:F),vryx,parno)
xlabel('Indices (through all experments)')
%
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The deviation of the correlation from the theoretical value is small,
%an indication of the approximate uncorrelatedness of the residuals.
%The repeated smaller peaks are at lag distances of experiment lengths
%each, which indicates a small modeling error again, since
%it corresponds to a repetitive pattern in the residuals.
%
%A last thing we will try in this demonstration is to make a fit
%using the input and output variances, but not the covariances,
%in order to explore what happens in this case.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
echo on
%
[pv,fit,Cp]=elis(Fdat,[vx,vy]/Na,['s',4,6],[],'',10);
%
echo off
graphnumber=grapause('rarmdemo',graphnumber,demosavegraphst);
%
MatlV=version;
if strcmp(MatlV,'4.0')
  if strcmp(get(0,'diary'),'on'), diary off, diary on, end
end
echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The fit seems to be as good as with the covariances, the cost function is
%even much smaller. But this small cost function is wrong, and has to
%be avoided. This is one reason why it is advisable to use the covariance
%values whenever possible: the cost function will only have a reasonable
%value by application of a correct noise model.
%But the most important reason for using the covariances is to utilize the
%available information correctly, with more emphasis to the bands
%where the amplitudes are measured with smaller error.
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
%ploteltf(pv,[],Fdat,[],[],vdat)
%%%%%%%%%%%%%%%%%%%%%%%% end of rarmdemo %%%%%%%%%%%%%%%%%%%%%%%%
