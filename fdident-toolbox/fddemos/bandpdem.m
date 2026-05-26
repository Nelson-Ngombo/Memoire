%BANDPDEM: Demonstration - system identification: passive bandpass filter

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
echo on, clc, clf
%The transfer function of a passive bandpass filter is to be identified.
%(Book, Section 3.9, Experiment 1, p. 128)
%The data are not exactly the same as those used in the book, though they
%were obtained under similar circumstances, on the same filter.
%
%First the measured data will be shown in the plot.
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
%
disp('Some function m-files are being loaded ...')
[freqvect,x,y,expno,vdat,comments,fdate]=impfou('bandpass(bandpass)');
Fdat=expfou(freqvect,x,y);
%
F=length(freqvect);
graphnumber=grapause('bandpdem',graphnumber,demosavegraphst);
echo on
%
%*******************
%The data file contains the results of 25 experiments. This is not a large
%number, but an impression can be gained about the variances. The transfer
%function estimates, obtained by the division of the output and input
%complex amplitudes seem to scatter only slightly.
%The variances can be calculated using the varanal function. Let us calculate
%these variances for each frequency point, and have a look at the averages:
[varx,vary,cxy,mx,my,Na,Np,cfl]=varanal(Fdat);
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
fprintf('\nmean(abs(X))=%.4g, mean(abs(Y))=%.4g\n',mean(abs(x)),mean(abs(y)))
fprintf('mean(varx)=%.4g, mean(vary)=%.4g\n',mean(varx),mean(vary))
fprintf('sqrt(mean(varx))=%.4g, sqrt(mean(vary))=%.4g\n',...
      sqrt(mean(varx)),sqrt(mean(vary)))
fprintf(['Coefficients of the confidence limits of the variances:\n',...
         '     %.3f, %.3f\n\n'],cfl(1),cfl(2))
echo on
%The obtained variances are very large. An obvious cause may be that the
%measurements were not synchronized to each other. Let us check this by
%plotting the input and output amplitudes on the complex plane.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
clf, subplot(1,2,1)
axis('square'), axis([-40,40,-40,40])
plot(real(x),imag(x),'x'), title('Input amplitudes')
axis([-40,40,-40,40]), axis('square'), grid off
subplot(1,2,2)
plot(real(y),imag(y),'x'), title('Output amplitudes')
axis([-40,40,-40,40]), axis('square'), grid off
hold off
graphnumber=grapause('bandpdem',graphnumber,demosavegraphst);
echo on, clc
%Indeed, the complex amplitudes turn around the origo. Consequently, in
%order to properly calculate the variances, the synchronization possibility
%of varanal has to be used. The variance analysis has already been done in
%advance, thus it is not necessary to calculate them right now. However,
%to see how varanal synchronizes, you may request this.
echo off
answ=yesinput('Do you want to perform the synchronization','n','y|yes|n|no');
if strcmp(answ(1),'y')
  fprintf('\nThe period length is %.4g s (1/48.828 Hz)\n',1024/50000)
  [varx,vary,cxy,mx,my,Na,Np,cfl]=varanal(Fdat,[],'delayed',1024/50000);
  fdidpaus(textpause)
  %fprintf('Press any key to continue ...'), pause, disp(' ')
  fprintf('\nmean(abs(X))=%.4g, mean(abs(Y))=%.4g\n',mean(abs(x)),mean(abs(y)))
  fprintf('mean(varx)=%.4g, mean(vary)=%.4g\n',mean(varx),mean(vary))
  fprintf('sqrt(mean(varx))=%.4g, sqrt(mean(vary))=%.4g\n',...
      sqrt(mean(varx)),sqrt(mean(vary)))
  fprintf(['Coefficients of the confidence limits of the variances:\n',...
         '     %.3f, %.3f\n\n'],cfl(1),cfl(2))
  disp('The obtained variances are quite reasonable.')
  disp('We are going to use these values in ELiS, along with the covariances.')
  varxc=varx; varyc=vary;
  vdat=[varx,vary,cxy];
  fdidpaus(textpause)
  %fprintf('Press any key to continue ...'), pause, disp(' ')
else %synchronization not requested, synchronized data set is used
  disp('The variances will be calculated from a pre-synchronized file.')
  %load bp1.fbn -mat
  %Fdat=expfou(freqvect,x,y);
  [freqvect,x,y]=impfou('bandpass(bandpass_synch)');
  avobj=varanal('bandpass(bandpass_synch)');
  vdat=avobj.OldTBSisoVariance; %internally, the real variances are used
end
%varx=3.4e-4; vary=varx;
%
echo on
%
%The transfer function will now be identified in the s-domain.
%A 4/6 order model is used in ELiS.
echo off
Fdat=[freqvect,x(1:F),y(1:F)];
axis('normal')
[pv,fit,Cp]= elis(Fdat,vdat,['s',4,6],[4,0;5,0;12,1;13,0],'',3);
graphnumber=grapause('bandpdem',graphnumber,demosavegraphst);
%
echo on
%*******************
%The cost function is close to the theoretically expected value: there
%is no need for increasing the order.
%This was just one single fit. To have an impression about the behaviour
%of the estimates, the fit can be calculated for each of the 25 experiments,
%and the mean values and the standard deviations of the estimates can be
%determined. The standard deviations can be compared with the ones calculated
%from the Cramer-Rao lower bounds.
echo off
answ=yesinput('Do you want to perform these calculations?','n','y|yes|n|no');
if strcmp(answ(1),'y')
  pvset=pv'; Cpav=Cp;
  %expno=3, disp('For testing only')
  for i=2:expno
    fprintf(['\nExperiment %.0f of variable bandpass in the file bandpass ',...
             'is being processed\n'],i)
    Fdat=[freqvect,x(F*(i-1)+[1:F]),y(F*(i-1)+[1:F])];
    [pv,fit,Cp]= elis(Fdat,vdat,['s',4,6],[4,0;5,0;12,1;13,0],'',inf);
    pvset=[pvset;pv'];
    Cpav=Cpav+Cp;
  end
  vCp=diag(Cpav)/expno;
  meanpv=mean(pvset);
  varpv=diag(cov(pvset));
  clc, fprintf('The results are as follows:\n\n')
  disp('Parameter    Average    Empirical std   Approx. std   Estd/Astd')
  on=4; od=6;
  fprintf('\n')
  for i=2:on
    fprintf('alpha%.0f      %.2e        %.1e',i,meanpv(4+i*2+2),...
           sqrt(varpv(4+i*2+2)))
    fprintf('        %.1e      %.2f\n',sqrt(vCp(1+on-i)),...
             sqrt(varpv(4+i*2+2))/sqrt(vCp(1+on-i)))
  end
  fprintf('\n')
  for i=1:od
    fprintf('beta%.0f       %.4e      %.1e',i,meanpv(4+2*(on+1)+i*2+2),...
           sqrt(varpv(4+2*(on+1)+i*2+2)))
    fprintf('        %.1e      %.2f\n',sqrt(vCp(on+1+(1+od-i))),...
             sqrt(varpv(4+2*(on+1)+i*2+2))/sqrt(vCp(on+1+(1+od-i))))
  end
  disp(' ')
  disp('The table is quite similar to Table 3.11 (page 129) in the Book.')
  disp('The variances are somewhat overestimated by elis in our case.')
  fdidpaus(textpause)
  %fprintf('Press any key to continue ...'), pause, disp(' ')
end
disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of bandpdem %%%%%%%%%%%%%%%%%%%%%%%%
