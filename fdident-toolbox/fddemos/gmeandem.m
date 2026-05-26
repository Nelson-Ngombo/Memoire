%GMEANDEM Demonstration of gmean (geometric mean of complex numbers)

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
if (mean(get(gcf,'Color'))>=0.5), yellow=blue; %white bg
elseif (get(0,'ScreenDepth')>=8), yellow='y';
else yellow=green;
end
echo on, clc
%GMEAN is advantageous first of all if ratios of noisy complex numbers
%are to be averaged.
%The theoretical background is described in
%Guillaume, P., R. Pintelon and J. Schoukens, "Nonparametric Frequency
%Response Function Estimators Based on Nonlinear Averaging Techniques",
%IEEE Trans. IM, Vol. 41, No. 6, Dec. 1992, pp. 739-746.
%
%Let us take two complex numbers, Y0 = -1+j and X0 = j, and generate a set of
%noisy samples (add independent Gaussian variables to both the real and the
%imaginary parts of both numbers). Let us calculate the ratios Y./X
%(as it used to be done by nonparametric transfer function estimation),
%and form the following mean values:
%
%1. Arithmetic mean of Y./X
%2. Geometric mean of Y./X with the usual definition
%3. Geometric mean of Y./X with gmean
%
echo off
%
[c,maxsize]=computer;
Y0=-1+j; X0=j;
%
sigmay0=sqrt(2/2)/2; sigmax0=sqrt(1/2)/2; %6-6 dB
%sigmay0=sqrt(2/2)/sqrt(2); sigmax0=sqrt(1/2)/2; %3-6 dB
%sigmay0=sqrt(2/2)/2; sigmax0=sqrt(1/2)/sqrt(2); %6-3 dB
%sigmay0=sqrt(2/2)/sqrt(2); sigmax0=sqrt(1/2)/sqrt(2); %3-3 dB
%
%sigmay=yesinput('Standard deviations of Re/Im parts of numerator (Y) ',...
%       'noises'],sigmay0,[sigmay0*0,sigmay0*2]);
%sigmax=yesinput(['Standard deviations of Re/Im parts of denominator (X) ',...
%       'noises'],sigmax0,[sigmax0*0,sigmax0*2]);
%SNRy=10*log10(2/(2*sigmay^2+eps)); SNRx=10*log10(1/(2*sigmax^2+eps));
%fprintf('\nSNRy = %.2f dB, SNRx = %.2f dB\n',SNRy,SNRx)
SNRy=8; SNRx=6;
SNRy=yesinput('SNR of the numerator (Y), dB',SNRy,[0,inf]);
SNRx=yesinput('SNR of the denominator (X), dB',SNRx,[0,inf]);
if SNRx<100, sigmax=sqrt(1/10^(SNRx/10)/2); else sigmax=0; end
if SNRy<100, sigmay=sqrt(2/10^(SNRy/10)/2); else sigmay=0; end
fprintf('\nStandard deviations of the real and imaginary parts of Y and X:\n')
fprintf('sigmay = %.3f,  sigmax = %.3f\n',sigmay,sigmax)
sigma=sqrt(1*sigmax^2+sigmay^2);
%
N0=5e4;
delta_ari_th=20*log10(1-exp( -(10^(SNRx/10)) ));
if exist('expint')
  if SNRx<100, d1=real( -expint(10^(SNRx/10)) ); else d1=0; end
  if SNRy<100, d2=real( -expint(10^(SNRy/10)) ); else d2=0; end
  delta_log_th=10/log(10)*(d1-d2);
else %"fake" values set (no expint in Matlab 3.5 and some Matlab 4.0's)
  fprintf(['WARNING! expint is not contained in this Matlab version, ',...
        'the theoretical\nvalues given are incorrect'])
  delta_log_th=0;
end
deltamax=max([abs(delta_ari_th),abs(delta_log_th),eps]);
errmax=10^(deltamax/20)-1;
N0=max(1000,ceil((8*sigma/errmax)^2));
ordm=floor(log10(N0));
N0=10^(ordm-1)*ceil(N0/10^(ordm-1));
if N0>2e5
  fprintf(['\nIn order to clearly see the bias, N = %.2e ratios have to be ',...
        'averaged.\nThis is a large number; the demo will offer a smaller',...
        ' one,\nbut if you want, you may set it to a higher value.\n'],N0)
else
  fprintf(['\nThe offered number of points is chosen to have an uncertainty',...
        ' small enough\n',...
        'to illustrate the difference between the biases of the arithmetic',...
        ' and\nthe complex geometric means.\nYou may, however, choose',...
        ' another number if you wish.\n'])
end
N=yesinput('Number of points',min(1e5,N0),[2,maxsize]);
sigmaav=sigma/sqrt(N);
%
tfvn=Y0+sigmay*randn(N,1)+j*sigmay*randn(N,1);
tfvn=tfvn./(X0+j*sigmax*randn(N,1)+sigmax*randn(N,1));
tf=Y0/X0;
in=find(~isfinite(tfvn));
if ~isempty(in), tfvn(in)=tf*ones(length(in),1); end
axl=6*(sigmay+sigmax+eps);
axv=1+axl*[-1,1,-1,1];
clf, axis('off')
hold off
axis('square')
axis(axv)
Np=min(N,1000);
plot(axv(1:2),[1,1],[':',white],[1,1],axv(3:4),[':',white],...
        axv(1:2),[0,0],['-',white],[0,0],axv(3:4),['-',white])
hold on
ptsh=plot(real(tfvn(1:Np)),imag(tfvn(1:Np)),['.',white],'markersize',1);
plh=gca; axis(axv), axis('square'), axis('on'), grid off, drawnow
title('Complex ratios to be averaged')
xlabel(sprintf('Number of points: %.0f',N))
graphnumber=grapause('gmeandem',graphnumber,demosavegraphst);
%
clc
amean=mean(tfvn);
tfvnnorm=10^mean(log10(abs(tfvn)+eps));
ugmean=prod(tfvn/tfvnnorm)^(1/N)*tfvnnorm;
cgmean=gmean(tfvn);
mvd=[tf;amean;ugmean;cgmean]-(1+j);
%
axv=1+1.1*max(abs([real(mvd);imag(mvd)]))*[-1,1,-1,1];
axis(axv)
title('Mean values of complex ratios')
hold on, grid off
plot(real(tf),imag(tf),['o',white])
plot(real(amean),imag(amean),['+',green])
plot(real(ugmean),imag(ugmean),['x',red])
plot(real(cgmean),imag(cgmean),['*',red])
t=0:0.02:pi/2;
circh=plot(abs(cgmean)*cos(t),abs(cgmean)*sin(t),[':',white]);
txth1=axes('Position',[0,0,1,1]); axis('off')
if strcmp(red,'r')
  text(0.01,0.95,'ow = theor. value')
  text(0.01,0.90,'+g = mean(Y./X)')
  text(0.01,0.85,'*r = gmean(Y./X)')
  txtg=text(0.01,0.80,'xr = geom. mean');
else
  text(0.01,0.95,'o = theor. value')
  text(0.01,0.90,'+ = mean(Y./X)')
  text(0.01,0.85,'* = gmean(Y./X)')
  txtg=text(0.01,0.80,'x = geom. mean');
end
graphnumber=grapause('gmeandem',graphnumber,demosavegraphst);
hold off
%
echo on
clc
%It is obvious that the usual geometric mean suffers from serious errors
%because of phase wrapping, although its absolute value is the same as that of
%the complex geometric mean.
%This is illustrated by the dotted circle around the point (0,0).
%In order to compare the arithmetic and the complex geometric mean,
%a closer look is desirable.
%In order to provide some information concerning the uncertainties, the
%2*sqrt(sigmay^2+1*sigmax^2)/sqrt(N)) contours will be also shown as dotted
%circles around the arithmetic mean and the complex geometric mean.
%The dotted lines that are also shown are fractions of the equal absolute value
%circles through the estimates.
echo off
fdidpaus(textpause)
%
nc=50; tp=[0:nc]/nc*2*pi;
axes(plh)
hold on
plot(real(amean)+2*sigmaav*cos(tp),imag(amean)+2*sigmaav*sin(tp),...
    ['.',yellow],'markersize',1)
plot(real(cgmean)+2*sigmaav*cos(tp),imag(cgmean)+2*sigmaav*sin(tp),...
    ['.',yellow],'markersize',1)
%
mvd(3)=[]; %exclude standard geometric mean from scaling
axsc=1.1*(max(abs([real(mvd);imag(mvd)]))+2*sigmaav);
axv=1+axsc*[-1,1,-1,1];
a1=angle(axv(2)+j*axv(3)); a2=angle(axv(1)+j*axv(4));
t=a1:(a2-a1)/5:a2; a=abs(amean); c=abs(cgmean);
plot(a*cos(t),a*sin(t),[':',white],c*cos(t),c*sin(t),[':',white])
if N>Np
  ind=find(abs(tfvn-tf)<axsc);
  plot(real(tfvn(ind)),imag(tfvn(ind)),['.',white],'markersize',1)
end
axes(plh),
delete(ptsh), delete(circh), delete(txtg)
axis(axv), grid off
title('Mean values of complex ratios')
xlabel(sprintf('SNRy = %.2f dB, SNRx = %.2f dB, number of points: %.0f',...
        SNRy,SNRx,N))
drawnow
graphnumber=grapause('gmeandem',graphnumber,demosavegraphst,0.82,0.04);
hold off
%
clc
fprintf('Y0 = -1+j,  X0 = j,  Y0/X0 = 1+j')
fprintf(',  N = %.0f\n',N)
fprintf('Standard deviations of the real and imaginary parts of Y and X:\n')
fprintf('sigmay = %.3f,  sigmax = %.3f\n',sigmay,sigmax)
fprintf('SNRy = %.2f dB,  SNRx = %.2f dB\n\n',SNRy,SNRx)
fprintf('sigma = sqrt(sigmay^2+1*sigmax^2) = %.2g',sigma)
fprintf(',  sigmaav = sigma/sqrt(N) = %.2g\n',sigmaav)
fprintf('     2*sigmaav corresponds to %.3g dB\n',...
        20*log10( (sqrt(2)+2*sigmaav)/sqrt(2) ) )
%2-sigma: 86% for symmetric complex Gaussian: 2=sqrt(-2*log(1-0.86))
%fprintf('abs(ameanerr) = %.4f = %.2f*sigmaav\n',abs(amean-tf),...
%       abs(amean-tf)/(sigmaav+eps))
%fprintf('abs(gmeanerr) = %.4f = %.2f*sigmaav\n',abs(cgmean-tf),...
%       abs(cgmean-tf)/(sigmaav+eps))
ameanerr=20*log10(amean/tf);
fprintf('ameanerr = %+.3f %+.3f*j dB',real(ameanerr),imag(ameanerr))
gmeanerr=20*log10(cgmean/tf);
fprintf(',   gmeanerr = %+.3f %+.3f*j dB\n',real(gmeanerr),imag(gmeanerr))
disp('Theoretical bias values:')
fprintf('ameanerr = %.3f dB',delta_ari_th)
if exist('expint')
  fprintf(',            gmeanerr = %.3f dB\n',delta_log_th)
else disp(' ')
end
fprintf(['\nThe phase errors are the same, because in the present ',...
        'realization',...
        ' of gmean,\nthe phase of the arithmetic mean is assigned to the',...
        ' complex geometric mean.\n'])
disp(' ')
%
if abs(cgmean-(1+j))<0.9*abs(amean-(1+j)), echo on, end
%The complex geometric mean of the ratios of random complex numbers is
%usually closer to the ratio of the true mean values than the arithmetic
%one. This is due to the smaller bias. Make repeated runs to check this
%with a new simulated data set.
%
echo off
%
if abs(cgmean-(1+j))>=0.9*abs(amean-(1+j)), echo on, end
%The complex geometric mean of the ratios of random complex numbers is
%usually closer to the ratio of the true mean values than the arithmetic
%mean. This is due to the smaller bias. However, in this case this was not
%demonstrated, because of randomness of the simulation. Make repeated runs
%to get convinced by other simulated data, eventually use larger data numbers.
%
echo off
clear tfvn
%
fdidpaus(textpause,0.04)
%%%%%%%%%%%%%%%%%%%%%%%% end of gmeandem %%%%%%%%%%%%%%%%%%%%%%%%
