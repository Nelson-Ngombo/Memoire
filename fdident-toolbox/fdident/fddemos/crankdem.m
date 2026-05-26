%CRANKDEM Demonstration - system identification: crankcase

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
%The transfer function of a crankcase is to be identified.
%(Book, Section 8.2: Modal analysis, Example 1, p. 253)
%
%First the measured data will be shown in the plot.
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
disp('Some function m-files are being loaded ...')
%
load crankcas
[freqvect,x,y]=impfou(crankcas);
ploteltf(crankcas)
%
fl=length(freqvect);
graphnumber=grapause('crankdem',graphnumber,demosavegraphst);
%
echo on, clc
%This is a large amount of data. For the demonstration we are going
%to use the first experiment only.
%The transfer function will be identified in the s-domain, a 6/6 order model
%is used in ELiS.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
fvl=freqvect(:);
expi=1; xyind=(expi-1)*length(fvl)+[1:length(fvl)];
Fdat=[fvl,x(xyind),y(xyind)];
pv=elis(Fdat,[4.9e-9,4.41e-8],['s',6,6],'0','l',[15]);
graphnumber=grapause('crankdem',graphnumber,demosavegraphst);
echo on
%*******************
%The fit is quite good, however, there is an unstable pole pair. As explained
%in the Book (p. 254), this is because the measurements do not provide
%sufficient information concerning the frequencies around f = 800 Hz
%(omega = 5 kHz), where the pole pair is found.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of crankdem %%%%%%%%%%%%%%%%%%%%%%%%
