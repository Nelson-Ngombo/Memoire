%DIBSDEMO Demonstration of dibs and dibsimpr

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
%Let us design discrete interval binary sequences, which approximate
%the same spectra as in the crest factor minimization demonstration
%(m-file mscldemo; Book, Subsection 4.2.2/3: Multisine)
%
%Possibilities:
%     1) Uniform lines 1-15
%     2) Uniform lines 1-255
%     3) Uniform lines 15-31
%     4) Linearly increasing lines 1-36
%     5) Logtone: 100 lines 20-511
%
echo off
rand('seed',0)
itdibs=3; itdibsimpr=1;
if ~exist('dibsno'), dibsno=1; end
if isempty(dibsno), dibsno=1; end
dibsno=yesinput('Your choice',dibsno,[1,5]);
disp(' ')
if dibsno==1
  fv=[1:15]; fl=length(fv); ampv=ones(1,fl);
elseif dibsno==2
  fv=[1:255]; fl=length(fv); ampv=ones(1,fl);
elseif dibsno==3
  fv=[15:31]; fl=length(fv); ampv=ones(1,fl);
elseif dibsno==4
  fv=[1:36]; ampv=fv;
elseif dibsno==5
  fv=lin2qlog([20:511],1.0333); fl=length(fv); ampv=ones(1,fl);
else
  error('Wrong choice')
end
echo on, clc
%First DIBS is used, then the result can be improved by DIBSIMPR.
%We will calculate the "equivalent crest factor", to see the difference
%between binary signals and multisines: the peak value will be divided
%by the worst relative amplitude: the minimum absolute value of the actual
%amplitudes, divided by the desired ones.
%
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
N=max(256,2^(ceil(log(max(fv)+0.99)/log(2))+2));
df=1; dt=1/(N*df); fv=fv(:); ampv=ampv(:);
[bitser1,ampopt1,Puf1,Ptot1]=dibs(N,dt,fv,ampv,itdibs);
maerr1=min(abs(ampopt1./ampv));
crx1=1/maerr1; %crx1=1/sqrt(Puf1);
%txth=axes('Position',[0,0,1,1]); axis('off')
graphnumber=grapause('dibsdemo',graphnumber,demosavegraphst);
%
echo on, clc
%The first cycle has been finished. We can now try to improve the result,
%using DIBSIMPR. This algorithm is much slower than the previous one.
%Interrupt the program if your patience is lost.
echo off
if ~exist('dibsi'), eval('dibsi=''y'';'), end %run dibsimpr
if isempty(dibsi), dibsi='y'; end
fdidpaus(textpause)
dibsi=yesinput('Do you want to run DIBSIMPR, y/n',dibsi,'y|n');
if strcmp(dibsi,'y')
  [bitser2,ampopt2,Puf2,Ptot2]=dibsimpr(bitser1,dt,fv,ampv,itdibsimpr);
  maerr2=min(abs(ampopt2./ampv));
  crx2=1/maerr2; %crx2=1/sqrt(Puf2);
  %txth=axes('Position',[0,0,1,1]); axis('off')
  graphnumber=grapause('dibsdemo',graphnumber,demosavegraphst);
end
if exist('yesinpacceptdef'), clear bitser1 bitser2, end
rand('seed',0)
%%%%%%%%%%%%%%%%%%%%%%%% end of dibsdemo %%%%%%%%%%%%%%%%%%%%%%%%
