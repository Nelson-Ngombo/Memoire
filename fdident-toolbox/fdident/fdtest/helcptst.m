%HELCPTST Test of approximate covariance matrix of elis

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

disp('File helcptst')
echo off
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
clf, randn('seed',0)
clc
disp('The transfer function of a filter is to be identified, on the basis')
disp('of simulated data')
disp('First the transfer function will be chosen, then shown in the plot.')
if ~exist('fty'), fty='s'; end
disp('Filter types: basic s- or z-domain, Rik''s lowpass, identified lowpass')
fty=yesinput('Filter type, s, z ,r or l',fty,'s|z|r|l');
if strcmp(fty,'r')
  num=[2.34e-4,4.89e-5,-2.24e-4,-1.93e-3,3.17e-3,-1.30e-3];
  denom=[1,-5.61627,13.3286,-17.1023,12.5125,-4.9499,0.82756];
  fs=80e3; domain='z';
  freqvect=[2:20]'*48.828;
  %freqvect=freqvect*10;
elseif strcmp(fty,'l')
  num=[  5.106128473511030e-005
        -2.592463181648773e-004
         5.268525806251208e-004
        -5.357084351600972e-004
         2.725586908762671e-004
        -5.550794078971966e-005]';
  denom=[1.000000000000000e+000
        -5.946073813607351e+000
         1.474085054397134e+001
        -1.950228750408602e+001
         1.452252426941943e+001
        -5.771218635008322e+000
         9.562051492881295e-001]';
  fs=80e3; domain='z';
  freqvect=[2:20]'*48.828;
elseif strcmp(fty,'s')
  num=[5,5]; denom=[4,3,2,1];, fs=1; domain='s';
  freqvect=[0.01:0.04:1]';
elseif strcmp(fty,'z')
  num=[5,5]; denom=[4,3,2,1];, fs=1; domain='z';
  freqvect=[0.01:0.018:0.45]';
end
if ~exist('delaytr'), delaytr='f'; end
delaytr=yesinput('Delay, variable or fix, v or f',delaytr,'v|f');
echo off
on=length(num)-1; od=length(denom)-1; fl=length(freqvect);
%
disp(' ')
disp('The input excitation level will be 1.')
if ~exist('varx'), varx=[]; end, if isempty(varx), varx=(1.3e-4)^2; end
sx=yesinput('Standard deviation of the input and output noises',...
        sqrt(varx),[0,0.5]);
varx=sx^2; vary=varx;
covtr=yesinput('Consider input-output covariance','n','y|n');
if strcmp(covtr,'y')
  if ~exist('covxy'), covxy=0; end
  if isempty(covxy), covxy=0; end
  while (abs(covxy)>sqrt(varx)*sqrt(vary))|strcmp(covtr,'y')
    covtr='n';
    if abs(covxy)>sqrt(varx)*sqrt(vary)
      covxy=sqrt(varx)*sqrt(vary)*.99;
    end
    covxy=yesinput('Input-output covariance',covxy);
  end
else
  covxy=[];
end
if ~exist('covxy'), covxy=[]; end
fixp=round(yesinput('Fixed parameters',1,[0,1]));
if ~exist('expno'), expno=30; end
expno=yesinput('Number of experiments',expno,[2,100]);
%
pdat=exppar(domain,num,denom,0,fs);
%
if 1==1
  ploteltf(pdat,'','')
  graphnumber=grapause('helcptst',graphnumber,testsavegraphst);
end
%
[xm,ym]=simfou(pdat,freqvect,ones(fl,1),[varx,vary,covxy],expno);
Fvect=expfou(freqvect,xm,ym);
F=length(freqvect);
if 1==2
  ploteltf(pdat,'',Fvect)
  graphnumber=grapause('helcptst',graphnumber,testsavegraphst);
end
%
Fdat=[freqvect,xm(1:F),ym(1:F)];
if strcmp(computer,'PC')
  save helcptst.mat, clear, load helcptst.mat, delete helcptst.mat
end
if strcmp(fty,'r')|strcmp(fty,'l')
  rppar=['z',5,6,8e4]; rpalg=['ms',15,NaN,0,5,0.001]; rppl=inf;
  %rppl=1;
elseif strcmp(domain,'s')
  rppar=['s',1,3]; rpalg=''; rppl=inf;
elseif strcmp(domain,'z')
  rppar=['z',1,3]; rpalg=[]; rppl=inf;
end
%
if fixp==1
  if (fty=='s')|(fty=='z'), fixv=[on+od+2,denom(length(denom))];
  else fixv=[on+2,denom(1)];
  end
else fixv=[];
end
if delaytr=='f', fixv=[fixv;on+od+3,0]; end
%[rppar,fixp,rpalg,rppl,initp,rpfiles]=elrpf2v(elisrpar);
[pv,fit,Cp,CR,cv]=elis(Fdat,[varx,vary,covxy],rppar+0,fixv,rpalg,rppl);
if 1==2
  ploteltf(pv,pdat,Fdat)
  graphnumber=grapause('helcptst',graphnumber,testsavegraphst);
end
%
fprintf('\n********************\n')
echo on
%This was just one single fit. To have an impression about the behaviour
%of the estimates, the fit can be calculated for each of the experiments,
%and the mean values and the standard deviations of the estimates can be
%determined. The standard deviations can be compared with the ones calculated
%from the approximate covariance matrix, produced by elis.
%
echo off
%answ=yesinput('Do you want to see these calculations?','n','y|yes|n|no');
answ='y';
if strcmp(answ(1),'y')
  pvset=pv'; Cpav=Cp; CRav=CR; cfv=fit(1);
  disp(' ')
  %expno=3, disp('For testing only'), disp(' ')
  for i=2:expno
    fprintf(['\nExperiment %.0f is being ',...
                'processed\n'],i)
    Fdat=[freqvect,xm(F*(i-1)+[1:F]),ym(F*(i-1)+[1:F])];
    [pv,fit,Cp,CR,cfser]=elis(Fdat,[varx,vary,covxy],rppar+0,fixv,rpalg,rppl);
    pvset=[pvset;pv']; Cpav=Cpav+Cp; CRav=CRav+CR; cfv=[cfv;fit(1)];
  end
  disp('The values of the cost function in each experiment:')
  cfv
  clf
  plot(cfv'), title('Cost function'), xlabel('Experiments')
  graphnumber=grapause('helcptst',graphnumber,testsavegraphst);
  vCp=diag(Cpav)/expno; vCR=diag(CRav)/expno;
  meanpv=mean(pvset);
  varpv=diag(cov(pvset))';
  [domain,numm,denomm,delaym]=imppar(meanpv);
  numv=varpv(4:2:4+2*on); denomv=varpv(4+2*on+2:2:4+2*on+2+2*od);
  if domain=='s', numv=fliplr(numv); denomv=fliplr(denomv); end
  clc, fprintf('The results of the estimations are as follows:\n\n')
  disp(['Parameter   Average   Empirical std   Approx. CR   ',...
        'Approx. std   Estd/Astd'])
  fprintf('\n')
  for i=1:on+1
    if strcmp(fty,'l')|strcmp(fty,'s')|strcmp(fty,'r')
      ind=on+1-i; else ind=i-1;
    end
    if vCp(i)==0, vCmod=inf; else vCmod=0; end
    fprintf('alpha%.0f    %+.2e     %.1e',ind,numm(i),...
            sqrt(numv(i)))
    fprintf('       %.1e       %.1e      %.2f\n',sqrt(vCR(i)),...
            sqrt(vCp(i)),sqrt(numv(i))/sqrt(vCp(i)+vCmod))
  end
  fprintf('\n')
  for i=1:od+1
    if strcmp(fty,'l')|strcmp(fty,'s')|strcmp(fty,'r')
      ind=od+1-i; else ind=i-1;
    end
    iC=i+on+1;
    if vCp(iC)==0, vCmod=inf; else vCmod=0; end
    fprintf('beta%.0f     %+.4e   %.1e',...
                ind,denomm(i),sqrt(denomv(i)))
    fprintf('       %.1e       %.1e      %.2f\n',...
                sqrt(vCR(iC)),sqrt(vCp(iC)),...
                sqrt(denomv(i))/sqrt(vCp(iC)+vCmod))
  end
  if delaytr=='v', end
  disp(' ')
%
end
%fprintf('Press any key to continue ...'), pause, disp(' ')
clear CR CRav Cp Cpav F Fdat Fvect answ cfser cfv cv delaym denom
clear denomm denomv domain fit fixv fl freqvect fs i iC
clear graphnumber ind meanpv num numm numv od on pdat pv pvset rpalg rppar
clear rppl vCR vCmod vCp varpv varx vary xm ym
clear sx delaytr fty fixp expno covxy covtr
%%%%%%%%%%%%%%%%%%%%%%%% end of helcptst %%%%%%%%%%%%%%%%%%%%%%%%
