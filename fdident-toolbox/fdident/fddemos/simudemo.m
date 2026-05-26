%SIMUDEMO Demonstration: usage of FDIDENT Toolbox with simulated data
%       Simulation of frequency domain data from user-defined s-domain system
%       parameters and noise variances, followed by identification (using
%       elis). The usage of a few functions of the Frequency Domain System
%       Identification Toolbox is illustrated in a generated simple m-file.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
clf
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
graphnumber=0;
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if mean(get(gcf,'Color'))<=0.5, invis='k'; else invis='w'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
echo on, hold off, clc
%This demo provides a brief introduction to the usage of some of the basic
%functions of the Frequency Domain System Identification Toolbox.
%A linear system may be given by yourself, simulated data will be generated
%with the selected variance values, and the basic identification routine (elis)
%will be used for the determination of the parameters of the system.
%When the identification is accomplished, a file may be generated with a short
%script m-file that can be used for re-running the demonstration with the same
%data or with a modified data set.
echo off
fprintf(['\nFirst, let us define an s-domain system by its numerator',...
        ' and denominator.\n\n'])
fprintf(['The coefficients have to be given in Matlab-format',...
        ' (in descending powers of s).\n'])
fprintf('Type a row vector, or accept default values by pressing Enter.\n')
if exist('numstr')~=1, numstr='1,1'; end
numstr=yesinput('Numerator coefficients',numstr);
eval(['num=[',numstr,'];'])
%
if exist('denomstr')~=1, denomstr='1,2,3,4'; end
rd=1;
while any(real(rd)>=0)
  denomstrsave=denomstr;
  denomstr=yesinput('Denominator coefficients',denomstr);
  eval(['denom=[',denomstr,'];'])
  rd=roots(denom);
  if any(real(rd)>=0)
    fprintf('You are kidding me! This would not be a stable system!\n')
    denomstr=denomstrsave;
  end
end
%
nord=length(num)-1; dord=length(denom)-1;
pvect=exppar('s',num,denom);
[h1,h2,fsc]=ploteltf(pvect,'','','log');
axes(h1), ax1=axis;
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
%
disp('********************')
fprintf(['For sake of simplicity, uniform input amplitudes of value 1',...
        ' will be used,\nwith Schroeder phases. However,',...
        ' the frequencies of the multisine still have \nto be chosen.\n'])
[domain,numsc,denomsc,d1,fs]=imppar(pvect,[]);
fs=fs/2/pi; maxi=64; mf=floor(sqrt(maxi));
freqvstr=sprintf('%.2g:%.2g:%.2g',fs/mf,fs/mf,fs/mf*(maxi/2-1));
freqvstr=yesinput('Frequency vector',freqvstr);
eval(['freqv=[',freqvstr,'];']); freqv=sort(freqv(:)'); fl=length(freqv);
pfv=[freqv(:),freqv(:),freqv(:)]'; pfv=pfv(:);
hold on
clf, subplot(2,1,1)
axis(ax1)
pxv=(ax1(4)*0.005+ax1(3)*0.995)*ones(3,fl);
pxv(2,1:fl)=(ax1(4)*0.8+ax1(3)*0.2)*ones(1,fl);
semilogx(pfv*fsc,pxv(:),['-',green]); hold off, grid off
axis(ax1)
txth=axes('Position',[0,0,1,1]); axis('off')
text(0.5,0.45,'This is the frequency set',...
        'HorizontalAlignment','center','VerticalAlignment','bottom')
figure(gcf)
graphnumber=grapause('simudemo',graphnumber,demosavegraphst);
%
tf=polyval(num,sqrt(-1)*2*pi*freqv)./polyval(denom,sqrt(-1)*2*pi*freqv);
PX=2*fl; PY=2*sum(abs(tf).^2);
SNRdes=20; %dB
N=1024;
varxm=PX/fl/2/10^(SNRdes/10)/2; varym=PY/fl/2/10^(SNRdes/10)/2;
%The variance of the complex noise is 2*varx or 2*vary at each point.
varx=varxm/1e4; vary=varym/1e4;
clc
fprintf('In this demonstration the noise is chosen to be white, that is,')
fprintf(' the variances\nof the input and output frequency domain amplitudes')
fprintf(' are constant along the\nfrequency axis. ')
fprintf('You may choose now the values of the input and output\nvariances.')
fprintf(' In order not to request something impossible from elis, ')
fprintf('we recommend\nto choose varx <= %.2g and vary <= %.2g .',varxm,varym)
fprintf([' These maximum values correspond\nto an average',...
        ' signal-to-noise ratio of %.1f dB in '],SNRdes)
fprintf('the frequency domain for\nthe input and the output, respectively,')
fprintf([' which is equivalent to SNR = %.1f dB\nin the time domain, if an',...
        ' %.0f-point FFT was used.'],SNRdes-10*log10(N/2/fl),N)
fprintf(' These SNR values are\nrather small: for accurate modelling the ')
fprintf('SNR should be larger, something like\n50 - 60 dB. However, the ')
fprintf('results of the estimation from data with these maximum\nvariances')
fprintf(' will be still reasonable, but with a quite high uncertainty.\n')
fprintf('Smaller variances are not only more realistic, but will even ')
fprintf('increase\nconvergence speed.')
fprintf(' Warning! varx and vary must not be chosen to be zero at the\nsame ')
fprintf('time (''noiseless'' case). Though the simulation could be ')
fprintf('performed, these\nvalues would result a division by zero in elis.')
fprintf(' This could be avoided by giving\nnonzero variances to elis, but')
fprintf(' then the cost function would be unrealistically\nsmall.\n')
varx=yesinput('varx',varx,[0,1.01*varxm]);
vary=yesinput('vary',vary,[0,1.01*varym]);
disp(' ')
x0=msinclip(freqv,ones(fl,1),[],'nograph',0); clc
[x,y]=simfou(pvect,freqv,x0,[varx,vary]);
minx=min(20*log10(abs(x))); maxx=max(20*log10(abs(x)));
clf, subplot(2,1,1), hold off
semilogx(freqv,20*log10(abs(x)),['+',green],...
        freqv,20*log10(abs(x0)),[':',white],...
        freqv([1,1]),[minx,maxx].*(maxx/minx).^[-1,1],['.',invis],...
            'markersize',1)
title('Input amplitudes'), ylabel('dB')
subplot(2,1,2)
semilogx(freqv,20*log10(abs(y)),['+',green],...
        freqv,20*log10(abs(x0.*tf')),[':',white])
ax=axis; ax(3)=min(20*log10(abs([y;x0.*tf'])/3));
ax(4)=max(20*log10(abs([y;x0.*tf'])*3));
axis(ax)
title('Output amplitudes'), ylabel('dB')
graphnumber=grapause('simudemo',graphnumber,demosavegraphst);
clc
fprintf('Now the coefficients of the transfer function will be estimated.\n')
fdidpaus(textpause)
if strcmp(computer,setstr('pc'-32))|strcmp(computer,setstr('mac'-32))
  save simudemo.mat, clear, load simudemo.mat, delete simudemo.mat, clc
  fprintf('Now the coefficients of the transfer function will be estimated.\n')
  fprintf('Press a key to continue ...'), disp(' ')
end
Fdat=[freqv(:),x,y];
[pvecte,fit,Cp]=elis(Fdat,[varx,vary],['s',nord,dord]);
graphnumber=grapause('simudemo',graphnumber,demosavegraphst);
[dom,nume,denome]=imppar(pvecte);
scalefac=norm(denom)/norm(denome)*sign(denom(1)/denome(1));
nume=nume*scalefac;
denome=denome*scalefac;
Vp=diag(Cp)*(scalefac)^2;
Vn=Vp(1:nord+1); Vd=Vp(nord+1+[1:dord+1]);
clc
fprintf('The estimated coefficients are as follows:\n')
fprintf('\nNumerator:\n')
fprintf('exact          estimated      error      standard deviation\n')
for i=1:nord+1
  fprintf('%.4e    %.4e    %+.4e',num(i),nume(i),nume(i)-num(i))
  fprintf('    %.4e\n',sqrt(Vn(i)))
end
fprintf('\nDenominator:\n')
fprintf('exact          estimated      error      standard deviation\n')
for i=1:dord+1
  fprintf('%.4e    %.4e    %+.4e',denom(i),denome(i),denome(i)-denom(i))
  fprintf('    %.4e\n',sqrt(Vd(i)))
end
fdidpaus(textpause)
%
fprintf('This demonstration file can create a simple script m-file which')
fprintf(' generates the\nabove data, and repeats the demonstration.')
fprintf(' The m-file illustrates the usage of\nkey functions of the toolbox,')
fprintf(' and can be easily modified for runs with other\nvariance values')
fprintf(' or for different transfer functions.\n')
gf=yesinput('Would you like to create the script m-file','n','y|n');
if strcmp(gf,'y')
  fn=yesinput('Name of m-file','simudtmp.m');
  indp=find(fn=='.');
  if isempty(indp), fn=[fn,'.m']; end
  if exist(fn)==2
    eval(['delete ',fn])
    if exist(fn)==2
      disp(['WARNING! Cannot delete existing file ''',fu,''''])
      error('You have to delete it by hand from the Matlab search path')
    end
  end
  ind=find((fn>='a')&(fn<='z')); fu=fn; fu(ind)=fu(ind)-'a'+'A'; fu=setstr(fu);
  fprintf(fn,['%%',fu,'\n'])
  fprintf(fn,['%%Sample script m-file to illustrate the usage of the\n',...
        '%% Frequency Domain System Identification Toolbox\n'])
  fprintf(fn,' %%\necho on\n%%Definition of the system:\n')
  fprintf(fn,['num=[',numstr,'];\n'])
  fprintf(fn,['denom=[',denomstr,'];\n'])
  fprintf(fn,'nord=length(num)-1; dord=length(denom)-1;\n')
  fprintf(fn,['pvect=exppar(''s'',num,denom);',...
        ' %%generate parameter vector\n'])
  fprintf(fn,'%%\n%%Excitation frequencies:\n')
  fprintf(fn,['freqv=[',freqvstr,'];\n'])
  fprintf(fn,'freqv=sort(freqv(:)''); fl=length(freqv);\n')
  fprintf(fn,'%%\n%%Calculation of transfer function:\n')
  fprintf(fn,['tf=polyval(num,sqrt(-1)*2*pi*freqv)./',...
        'polyval(denom,sqrt(-1)*2*pi*freqv);\n'])
  fprintf(fn,'echo off\n')
  fprintf(fn,['clf, semilogx(freqv,20*log10(abs(tf)),''-'')',...
        '\nylabel(''dB''), title(''Magnitude'')\n'])
  fprintf(fn,'txth=axes(''Position'',[0,0,1,1],''Visible'',''off'');\n')
  fprintf(fn,['text(0.82,0,''Press a key...'',',...
                '''VerticalAlignment'',''bottom'');\n'])
  fprintf(fn,['fprintf(''Press any key to continue ...''), figure(gcf)\n',...
         'pause, delete(txth), disp('' '')\n'])
  fprintf(fn,'echo on\n')
  fprintf(fn,'%%\n%%Simulation:\n')
  fprintf(fn,'varx=%.4g;\n',varx)
  fprintf(fn,'vary=%.4g;\n',vary)
  fprintf(fn,['x0=msinclip(freqv,ones(fl,1),[],''nograph'',0);',...
        ' %%Schroeder multisine\n'])
  fprintf(fn,'[x,y]=simfou(pvect,freqv,x0,[varx,vary]);\n')
  fprintf(fn,'hold on, semilogx(freqv,20*log10(abs(y./x)),''+''), hold off\n')
  fprintf(fn,'echo off\n')
  fprintf(fn,'txth=axes(''Position'',[0,0,1,1],''Visible'',''off'');\n')
  fprintf(fn,['text(0.82,0,''Press a key...'',',...
                '''VerticalAlignment'',''bottom'');\n'])
  fprintf(fn,['fprintf(''Press any key to continue ...''), figure(gcf)\n',...
                'pause, delete(txth), disp('' '')\n'])
  fprintf(fn,'echo on\n')
  fprintf(fn,'%%\n%%Estimation:\n')
  fprintf(fn,'Fdat=[freqv(:),x,y];\n')
  fprintf(fn,'[pvecte,fit,Cp]=elis(Fdat,[varx,vary],[''s'',nord,dord]);\n')
  fprintf(fn,'echo off\n')
  fprintf(fn,'txth=axes(''Position'',[0,0,1,1],''Visible'',''off'');\n')
  fprintf(fn,['text(0.82,0,''Press a key...'',',...
                '''VerticalAlignment'',''bottom'');\n'])
  fprintf(fn,['fprintf(''Press any key to continue ...''), figure(gcf)\n',...
                'pause, delete(txth), disp('' '')\n'])
  fprintf(fn,'echo on\n')
  fprintf(fn,['[dom,nume,denome]=imppar(pvecte);\n'])
  fprintf(fn,...
        'scalefact=norm(denom)/norm(denome)*sign(denom(1)/denome(1));\n')
  fprintf(fn,['nume=scalefact*nume; denome=scalefact*denome;',...
        ' %%Restore original scaling\n'])
  fprintf(fn,['%%Without rescaling it would be difficult to compare ',...
        'the estimated parameters\n%%with the original values.\n'])
  fprintf(fn,'%%\n%%Variance vectors from covariance matrix:\n')
  fprintf(fn,'Vp=diag(Cp)*(scalefact)^2;\n')
  fprintf(fn,'Vn=Vp(1:nord+1); Vd=Vp(nord+1+[1:dord+1]);\n')
  fprintf(fn,'%%\n%%Show results with errors and standard deviations:\n')
  fprintf(fn,'Numresults=[num'',nume'',nume''-num'',sqrt(Vn)]\n')
  fprintf(fn,'Denomresults=[denom'',denome'',denome''-denom'',sqrt(Vd)]\n')
  fprintf(fn,['echo off\n%%\n%% End of file ',fu])
%  fprintf(fn,'\n')
end
echo off
fprintf('Press a key ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of simudemo %%%%%%%%%%%%%%%%%%%%%%%%
