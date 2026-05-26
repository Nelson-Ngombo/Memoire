%LOWPDEMO Demonstration - system identification: active lowpass filter

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
%The transfer function of an active lowpass filter is to be identified.
%(Book, Section 3.9, Experiment 2, p. 130)
%
%First the measured data will be shown in the plot.
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
disp('Some function m-files are being loaded ...')
%
[freqvect,x,y]=impfou('lowpass(lowpass)');
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
xm=x; clear x, ym=y; clear y;
Fvect=expfou(freqvect,xm,ym);
F=length(freqvect);
ploteltf('','',Fvect)
graphnumber=grapause('lowpdemo',graphnumber,demosavegraphst);
%
echo on
clc
%The data file contains the results of 30 experiments. This is not a large
%number, but an impression can be gained about the variances. The transfer
%function estimates, obtained by the division of the output and input
%complex amplitudes seem to scatter only slightly.
%The variances can be calculated using the varanal function. Let us calculate
%these variances for each frequency point, and have a look at the averages:
echo off
[varx,vary,cxy,mx,my,Na,Np,cfl]=varanal(Fvect);
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
fprintf('\nmean(abs(X))=%.4g, mean(abs(Y))=%.4g\n',...
        mean(abs(xm)),mean(abs(ym)))
fprintf('mean(varx)=%.4g, mean(vary)=%.4g\n',mean(varx),mean(vary))
fprintf('sqrt(mean(varx))=%.4g, sqrt(mean(vary))=%.4g\n',...
      sqrt(mean(varx)),sqrt(mean(vary)))
fprintf(['Coefficients of the confidence limits of the variances:\n',...
         '     %.3f, %.3f\n\n'],cfl(1),cfl(2))
disp('The obtained variances are quite reasonable.')
disp(['The experiments in the file may be considered as synchronized ',...
        'to each other.'])
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
echo on, clc
%The transfer function will now be identified in the z-domain.
%A 5/6 order model is used in ELiS, with sampling frequency 80 kHz.
%The measured frequency range (97.7 Hz - 1.03 kHz) is much narrower than the
%sampling frequency, therefore the normal equations may become badly
%conditioned, and the minimum of the cost function may be difficult to find.
%The Levenberg-Marquardt algorithm will be used with singular value
%decomposition, and the condition number will be checked after the fit.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
varx=4.97e-10; vary=6.55e-10;
Fdat=[freqvect,xm(1:F),ym(1:F)];
if strcmp(computer,'PC')
  save lowpdemo.mat, clear, load lowpdemo.mat, delete lowpdemo.mat
end
[pv,fit,Cp,CR,cv]=elis(Fdat,[varx,vary],['z'+0,5,6,8e4],'f',...
                ['ms'+0,15,NaN,0,5,0.001]);
graphnumber=grapause('lowpdemo',graphnumber,demosavegraphst);
%
fprintf('\n********************')
fprintf('\nThe condition number of J is %.3g, a large number indeed.\n',fit(14))
cvim=min([length(cv);find(cv<310)]);
if any(diff(cv([cvim:length(cv),length(cv)])))>0
  fprintf(['Even some increases of the cost function occurred ',...
        'around the minimum.\n'])
end
fprintf(['It was reasonable to use the Levenberg-Marquardt algorithm with'...
        '\nsingular value decomposition\n\n'])
echo on
%This was just one single fit. To have an impression about the behaviour
%of the estimates, the fit can be calculated for each of the 30 experiments,
%and the mean values and the standard deviations of the estimates can be
%determined. The standard deviations can be compared with the ones calculated
%from the approximate covariance matrix, produced by elis.
%elis will not make any plots, in order to increase the calculation speed.
%
echo off
if ~exist('lowpansw'), lowpansw='y'; end
lowpansw=yesinput('Do you want to see these calculations?',lowpansw,...
                'y|yes|n|no');
if strcmp(lowpansw(1),'y')
  pvset=pv'; Cpav=Cp; CRav=CR; cfv=fit(1);
  disp(' ')
  %expno=3, disp('For testing only'), disp(' ')
  for i=2:expno
    fprintf(['\nExperiment %.0f of the variable lowpass(lowpass) is being ',...
                'processed\n'],i)
    Fdat=[freqvect,xm(F*(i-1)+[1:F]),ym(F*(i-1)+[1:F])];
    %rppl(1)=inf; %plotdens=inf
    %[pv,fit,Cp,CR,cfser]=elis(Fdat,[varx,vary],rppar,fixp,rpalg,rppl,initp);
    [pv,fit,Cp,CR,cfser]=elis(Fdat,[varx,vary],['z'+0,5,6,8e4],'f',...
                ['ms'+0,15,NaN,0,5,0.001],inf);
    pvset=[pvset;pv']; Cpav=Cpav+Cp; CRav=CRav+CR; cfv=[cfv;fit(1)];
  end
  disp('The values of the cost function in each experiment:')
  cfv
  clf
  plot(cfv,['-',white]), title('Cost function'), xlabel('Experiments')
  xp=0.82; yp=0;
  txth=axes('Position',[0,0,1,1]); axis('off')
  text(xp,yp,'Press a key...','VerticalAlignment','bottom')
  fprintf('Press any key to continue ...'), figure(gcf), pause
  delete(txth), disp(' ')
  vCp=diag(Cpav)/expno; vCR=diag(CRav)/expno;
  meanpv=mean(pvset);
  varpv=diag(cov(pvset));
  clc, fprintf('The results of the estimations are as follows:\n\n')
  disp(['Parameter   Average   Empirical std   Approx. CR   ',...
        'Approx. std   Estd/CR'])
  on=5; od=6;
  fprintf('\n')
  for i=1:on+1
    fprintf('alpha%.0f    %+.2e     %.1e',i,meanpv(4+(on+1-i)*2+2),...
            sqrt(varpv(4+(on+1-i)*2+2)))
    fprintf('       %.1e       %.1e      %.2f\n',sqrt(vCR(on+2-i)),...
            sqrt(vCp(on+2-i)),sqrt(varpv(4+(on+1-i)*2+2))/sqrt(vCR(on+2-i)))
  end
  fprintf('\n')
  for i=0:od-1
    fprintf('beta%.0f     %+.4e   %.1e',...
                i,meanpv(4+2*(on+1)+(od-i)*2+2),...
                sqrt(varpv(4+2*(on+1)+(od+1-i)*2)))
    fprintf('       %.1e       %.1e      %.2f\n',...
                sqrt(vCR(on+1+(od+1-i))),sqrt(vCp(on+1+(od+1-i))),...
                sqrt(varpv(4+2*(on+1)+(od+1-i)*2))/sqrt(vCR(on+1+(od+1-i))))
  end
  disp(' ')
  echo on
%Though not the same, the results are similar to those presented in Table 3.12
%(page 130) in the Book.
%It should be noted that the approximate Cramer-Rao bounds, given in the
%book, and also in the above table, were calculated from the theoretical
%expression (3.36), by using the noisy amplitude values and the estimated
%parameters, while for the calculation of the approximate standard deviations
%elis uses the expression based on small-perturbation approximations of the
%cost function (2nd order Taylor series expansions around the true values);
%these two variance values are different most probably because of modelling
%errors, and maybe because in both expressions the noisy complex amplitudes
%are used.
%
echo off
%
end
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of lowpdemo %%%%%%%%%%%%%%%%%%%%%%%%
