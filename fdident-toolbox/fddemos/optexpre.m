%OPTEXPRE Prepare data for optimal excitation design, design reference signal
%Uses routines of the Frequency Domain System Identification Toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Sep-1997

clear
%
%First let us define the filter and the frequency points.
domain='s'; delay=0; fs=1;
num=[3.2010e-17,5.5155e-12,8.973e-10,0,0];
denom=[1.0131e-21,2.5351e-18,3.6031e-14,5.5550e-11,3.5869e-7,2.5017e-4,1];
ftype=yesinput('Frequency distribution, uniform or multiband, u/m','u','u|m');
if ftype=='u'
  freqv=20*[1:50]'; Ncyc=1500;
elseif ftype=='m'
  freqv=[340:2:360,390:2:410,490:2:520,620:2:640,700:2:720];
  Ncyc=20000;
end
F=length(freqv);
%
%Now let us specify the settings for the estimation procedure
%Fixed parameters: the two zeros, the value 1 in te denominator, and the delay
fixpar=[4;5;12;13];
fsi=11-2; %index of fsc, the internal scaling frequency of optexcit
np=length(num)+length(denom)+1-length(fixpar); %number of free parameters
%This is a data structure for the filter:
pdat=exppar(domain,num,denom,delay,fs);
%
%This is the starting amplitude distribution. X contains the absolute values of
%the complex Fourier coefficients. The total signal power is 1.
%Therefore, if all frequencies differ from zero, 2*X'*X=1
Xstart=ones(length(freqv),1)/sqrt(2*length(freqv));
%
%Now let us specify the cycle number
disp('If the cycle number is 0, the partial information matrices will be')
disp('returned, but no iteration will be done.')
disp('Iteration cycle number 1500 is suggested for the given filter and ')
disp('frequency vector.')
Ncyc=yesinput('Number of iteration cycles, 0 to view file',Ncyc);
%
%Fiw consists of the scaled Fi matrices for each frequency beside each other.
%Fiwk=Fiw(1:np,(k-1)*np+[1:np]);
%Fws=sum(2*X(k)^2*Fiwk); Fi=Fis.*(fsv*fsv'); CR=inv(Fi)=inv(Fis)./(fsv*fsv')
%
if Ncyc==0
  if ftype=='u', load optxunif.mat
  elseif ftype=='m', load optxmbd.mat
  end
  optexcit(pdat,freqv,[1,1],fixpar,X,1);
  hc=gca;
  ha=axes('Position',[0,0,1,1],'visible','off');
  text(0,1,sprintf('Ncyc=%.0f',Ncyc),'verticalalignment','top')
  axes(hc)
else
  if Ncyc<0
    Ncycnew=-Ncyc;
    if ftype=='u', load optxunif.mat
    elseif ftype=='m', load optxmbd.mat
    end
    Xstart=X; Ncycold=Ncyc; Ncyc=Ncycnew;
  else
    Ncycold=0;
  end
  disp('Running optexcit ...')
  if Ncyc>=100, fprintf('%.0f cycles will take a while ...\n',Ncyc), end
  [X,CR,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xstart,Ncyc,[],50);
  if Ncycold>0 %Old run was continued
    Ncyc=Ncyc+Ncycold;
    hc=gca;
    ha=axes('Position',[0,0,1,1],'visible','off');
    text(0,1,sprintf('Ncyc=%.0f',Ncyc),'verticalalignment','top')
    axes(hc)
  end
  dCRs=det(CR.*(fsv*fsv'));
  dCR=dCRs/prod(fsv)^2;
  fprintf('\nScaled determinant: %.6e, determinant: %.6e\n\n',dCRs,dCR)
  fsc=fsv(fsi);
  Fws=0;
  for k=1:size(Fiw,2)/size(Fiw,1)
    Fws=Fws+2*X(k)^2*Fiw(1:np,(k-1)*np+[1:np]);
  end
  %
  %Save results to file
  if Ncyc>10
    if ftype=='u'
      save optxunif.mat pdat freqv X CR dCR dCRs fsv Fiw fsc Fws Ncyc
    elseif ftype=='m'
      save optxmbd.mat pdat freqv X CR dCR dCRs fsv Fiw fsc Fws Ncyc
    end
  end
end
%[X,CR,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xstart,2,[],50,50,1000);
%
%end of optexpre
