%INPCHDEM Demonstration - compensation of an input channel

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
clf, hold off, echo on, clc
%The transfer function of the input channel of a signal analyzer has been
%measured in the band (400 Hz - 19600 Hz). The transfer function is to be
%identified, and an equalizer filter is to be designed for the passband.
%(Book, Section 8.6: Equalization of a data acquisition channel, p. 280)
%
%The anti-aliasing filter is a lowpass Cauer filter. The transfer function
%is shown in the next plot.
echo off
fprintf('Press a key to continue ...'), pause, disp(' ')
disp('Some function m-files are being loaded ...')
%
[freqvect,x,y]=impfou('inpchan');
Fdat=[freqvect,x,y];
inpchans=loadvar('inpchmod','inpchans');
%
%inpchans=exppar(domain,num,denom,delay);
ploteltf(inpchans,'','',['lin',0,2.1e4])
ax=axis; ax(4)=ax(4)+3; axis(ax)
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
echo on
%*******************
%The passband was measured at 49 frequency points, as illustrated in the
%next plot.
echo off
fdidpaus(textpause)
%fprintf('Press a key to continue ...'), pause, disp(' ')
ploteltf(Fdat)
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
%
echo on, clc
%First, the transfer function will be identified in the s-domain.
%A 12/12 order model is used in ELiS.
echo off
fdidpaus(textpause)
%fprintf('Press a key to continue ...'), pause, disp(' ')
%[pvs,fits,Cps,CR]=elis(Fdat,[9.61e-12,9.61e-10],['s',12,12]+0,'0','',9);
NaNv=NaN; %bypass Vax problem with NaN*
[pvs,fits,Cps,CR]=elis(Fdat,[9.61e-12,9.61e-10],['s'+0,12,12,2*pi*1.6e4]+0,...
        [27,0],'',[9,NaNv(1,ones(1,7)),[-1.5,2,-1.75,1.75]*1e5]);
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
echo on
%
%********************
%The fit is good, though the cost function is larger than expected.
%In order to get a better insight, the confidence bounds can be calculated.
%This may take some time.
%
echo off
[domain,nums,denoms]=imppar(pvs);
tfv=polyval(nums,sqrt(-1)*freqvect*2*pi)...
                ./polyval(denoms,sqrt(-1)*freqvect*2*pi);
%
confpl=yesinput('Do you want to see the confidence bounds?','y','y|n');
if strcmp(confpl,'y')
clc, disp('Please wait a little while ...')
ploteltf(pvs,'',Fdat,'linF','full=',Cps)
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
clc
disp('It can be observed that the error is really small, and the confidence')
disp('bounds are accordingly narrow (the 100*sigma bounds were plotted).')
disp('It is also interesting to observe that the uncertainty becomes larger')
disp('at the end of the passband.')
disp(' ')
end
%
disp(' ')
disp('Let us have a look now at the complex error.')
fdidpaus(textpause)
%fprintf('Press a key ...'), pause, disp(' ')
clf, subplot(2,1,1)
hold off
plot(freqvect,20*log10(abs(tfv-y./x)))
title('Abs. v. of complex error'), ylabel('dB')
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
echo on, clc
%The complex error is small indeed.
%The obtained transfer function can be used as a reference for compensation
%filter design. However, a quicker way will be chosen: the original data will
%be fitted directly by a digital IIR filter.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
clf, hold off
[pvz,fitz,Cpz]=elis(Fdat,[9.61e-12,9.61e-10],['z',14,14,51200]+0,'','',4);
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
echo on, clc
%The fit is almost as good as in the s-domain. Thus, the inverse of this filter
%can be used for the compensation. However, there is one small difficulty:
%the just determined filter is not minimal-phase, thus its inverse is
%unstable. The unstable poles can be inverted, this leaves the magnitude
%untouched, but spoils the phase response. A solution is to design an
%allpass filter to restore the phase response.
%First we are going to find the unstable poles, and determine the phase
%distortion introduced by stabilization. The allpass sections will have to
%linearize this phase distortion, at the cost of additional delay.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
[domain,num,denom,delay,fs]=imppar(pvz);
rnum=roots(num); ind=find(abs(rnum)>1);
numdist=real(poly(rnum(ind)));
denomdist=fliplr(numdist);
tfdist=fft([numdist,zeros(1,256-length(numdist))]')...
        ./fft([denomdist,zeros(1,256-length(denomdist))]');
tfdist=tfdist(1:length(tfdist)/2);
f=[0:127]'/256*fs; w=2*pi*f/fs;
pbind=find( (0<f)&(f<=19600*(1+eps)) );
phif=unwrap(angle(tfdist.'))'; %phase error
phifpb=phif(pbind); fpb=f(pbind); wpb=w(pbind);
clf, subplot(2,1,1)
hold off
plot(fpb,phifpb/2/pi*360,'x')
title('Phase error introduced by reflections'), ylabel('degrees')
tauf=-diff(phifpb)./diff(wpb);
subplot(2,1,2)
plot(fpb(2:length(fpb)),tauf,'x')
title('Normalized group delay'), ylabel('Ts')
hold off
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
clc
fprintf('\n%%The minimum order of the allpass correction filter is %.0f\n',...
      ceil(2*19600/51200*(max(tauf)-mean(tauf))) )
echo on
%(see equation (7.9), page 236 in the Book; fs = 51200 Hz, the band of
%interest is from dc to 19600 Hz).
%Starting from this, a rather long experimentation procedure follows,
%gradually increasing the order to obtain the desired accuracy.
%We will skip here this experimentation, and start immediately with
%order 20, which will prove to be sufficient.
%(7.8) gives the allowable range of the resulting delay:
echo off
fprintf('\n    %.3f <= tau <=%.3f\n\n',mean(tauf),mean(tauf)+20/2*51200/19600)
echo on
%It needs a lengthy experimentation again to find the optimum value of the
%delay. What can be done, is to gradually increase the starting value from
%the lower limit towards the upper one, e.g. in steps 2. We will not do all
%this, instead, let us choose the value 27, and make a run with elis,
%requiring an allpass fit of the inverse of the above phase error,
%and allowing the above delay. The `output variance' is given as the
%square of the desired limit of the error, thus with a good fit the cost
%function will have a reasonable value. The error will be studied separately.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
echo on
tfdes=[fpb,tfdist(pbind),ones(length(pbind),1)];
echo off
%rppar(2)=20; rppar(3)=20; rppl(9:12)=1.5*[-1,1,-1,1]; fixp='f';
%allpv=elis(tfdes,[0,0.001^2],rppar,fixp,rpalg,rppl,-27,rpfs);
echo on
NaNv=NaN;
allpv=elis(tfdes,[0,0.001^2],['z',20,20,51200,'a']+0,[],'',...
        [10,NaNv(1,ones(1,5)),'cc'+0,1.7*[-1,1,-1,1]],-27);
echo off
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
echo on, clc
%The fit is stable, and the cost function is quite small. To improve the
%quality of the fit, let the delay be free.
echo off
fdidpaus(textpause)
%fprintf('Press a key to continue ...'), pause, disp(' ')
%fixpvd='v';
%allpv=elis(tfdes,[0,0.001^2],rppar,fixpvd,rpalg,rppl,allpv,rpfs);
echo on
NaNv=NaN;
allpv=elis(tfdes,[0,0.001^2],['z',20,20,51200,'a']+0,'v','sf',...
        [1,NaNv(1,[1,1,1,1,1]),'cc'+0,1.7*[-1,1,-1,1]],allpv);
echo off
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
echo on
%*******************
%To check the performance, let us plot the phase error of the fit.
echo off
fdidpaus(textpause,[],5)
%fprintf('Press a key to continue ...'), pause, disp(' ')
[domain,allpnum,allpdenom,allpdelay]=imppar(allpv);
tfallp=exp(-j*2*pi*[0:255]'/256*allpdelay)...
        .*fft([allpnum,zeros(1,256-length(allpnum))]')...
        ./fft([allpdenom,zeros(1,256-length(allpdenom))]');
tfallp=tfallp(1:length(tfallp)/2);
tfallpb=tfallp(pbind);
phierror=unwrap(angle(tfdist(pbind).*tfallpb))'/2/pi*360;
clf
subplot(2,1,2)
plot(fpb,phierror)
title('Phase error'), ylabel('degrees')
graphnumber=grapause('inpchdem',graphnumber,demosavegraphst);
clc
echo on
%The error is small indeed, the phase compensation is successful.
echo off
fdidpaus(textpause,[],5)
%fprintf('Press a key ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of inpchdem %%%%%%%%%%%%%%%%%%%%%%%%
