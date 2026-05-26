%OPTEXDE1 Demonstration of optexcit: Book, Sect. 4.3.5, bandpass filter

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-1997

if ~exist('demosavegraphst'), demosavegraphst=''; end
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
echo on, clc
%An optimized excitation signal will be designed for a bandpass filter.
%First let us define the filter and the frequency points.
%
domain='s'; delay=0; fs=1;
num=[3.2010e-17,5.5155e-12,8.973e-10,0,0];
denom=[1.0131e-21,2.5351e-18,3.6031e-14,5.5550e-11,3.5869e-7,2.5017e-4,1];
freqv=20*[1:50]'; fixpar=[4;5;12;13]; np=9;
echo off
pdat=exppar(domain,num,denom,delay,fs);
fprintf('Press any key to continue ...'), pause, disp(' ')
%
fprintf('\nAfter the optimization of the power spectrum, the crest factor\n')
fprintf('has to be minimized, too. This may take considerable time.\n')
crm=yesinput('Minimize crest factor after power optimization, y/n','n','y|n');
Fiw=[];
if crm=='y'
  disp(' ')
  disp('A small problem: optexcit calculates the PREVIOUS Cramer-Rao bound,')
  disp('and the NEW set of amplitudes in each cycle. Thus, always the')
  disp('previous amplitudes have to be combined with the actually calculated')
  disp('covariance matrix, in order to properly calculate the scaled value')
  disp('of the determinant.')
end
disp(' ')
disp('The design will be done by successive calls of OPTEXCIT, always using')
disp('the results of the previous fit. Therefore, the messages')
disp('       ''cycle ... in this call''')
disp('are not relevant to the total performed number of iterations;')
disp('this number is indicated when the iteration is paused.')
fprintf('Press a key ...'), pause, disp(' ')
%
dCRv=[]; crxv=[]; dCRsv=[];
Xold=ones(length(freqv),1)/sqrt(length(freqv)); Nold=0;
for N=[1,2,3,4,10,11,100,101] %cycles
  if N>1
    stxt='s';
    fprintf('\n*********************')
    fprintf('\n%.0f iteration(s) have already been performed.\n',Nold)
    fprintf('%.0f more iteration(s) will be performed in this cycle.\n',N-Nold)
    %fdidpaus(textpause)
  else
    stxt='';
  end
  if N-Nold<=3, pd=1; elseif N-Nold<15, pd=2; else pd=10; end
  [X,CR,fsv,vXwdev,Fiw]=optexcit(pdat,freqv,[1,1],fixpar,Xold,N-Nold,Fiw,pd);
  if any(N==[1,2,3,4,10,11,100,101])
    txth=axes('Position',[0,0,1,1]); axis('off')
    text(0.5,0.038,sprintf(['%.0f iteration',stxt,...
              ' performed...'],N),'VerticalAlignment','bottom')
    text(1,0,sprintf('Press a key...'),'VerticalAlignment','bottom',...
           'Horizontalalignment','right')
    graphnumber=grapause('optexde1',graphnumber,demosavegraphst,1,1);
  end
  dCR=det(CR.*(fsv*fsv'))/prod(fsv)^2; dCRv=[dCRv;dCR];
  %fprintf('\nDEMO: det(CR)=%4.2e in cycle %.0f\n\n',dCR,N-1)
  figure(gcf)
  %crest factor minimization follows
  if strcmp(crm,'y')&any(N==[1,2,3,4,11,101])
    tf=polyval(num,sqrt(-1)*freqv*2*pi)./polyval(denom,sqrt(-1)*freqv*2*pi);
    %1. optimize input signal only
    disp(' ')
    disp('********************')
    disp('First the crest factor of the input signal alone will be minimized.')
    fprintf('Expected number of iterations in msinclip: about 200.\n\n')
    fdidpaus(textpause)
    [cx,crx,crxmax]=msinclip(freqv,Xold,[],'lastgraph');
    graphnumber=grapause('optexde1',graphnumber,demosavegraphst);
    %2. continue: optimize input and output signals
    disp(' ')
    disp('********************')
    disp('Now the crest factors of both the input and output signals are')
    disp('jointly minimized, using the result of input minimization.')
    fdidpaus(textpause)
    [cx,crx,crxmax,cry,crymax]=msinclip(freqv,cx,tf,'lastgraph');
    graphnumber=grapause('optexde1',graphnumber,demosavegraphst);
    dCRs=dCR*crx^(2*np);
    fprintf(['\nDEMO: Crest factor=%4.2f in cycle %.0f,'...
           ' scaled det=%4.2e\n\n'],crx,N-1,dCRs )
    %fprintf('Press any key to continue ...'), pause, disp(' ')
    crxv=[crxv;crx]; dCRsv=[dCRsv;dCRs];
  end
  Xold=X; Nold=N;
end
if strcmp(crm,'y')
  disp('Vector of scaled determinants:')
  dCRsv
  fdidpaus(textpause)
end
echo off, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of optexde1 %%%%%%%%%%%%%%%%%%%%%%%%
