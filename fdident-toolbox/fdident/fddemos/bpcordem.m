%BPCORDEM Demonstration - phase correction of a bandpass filter

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
%The transfer function of a bandpass filter is to be identified, and a phase
%equalization filter is to be designed for the passband.
%(Book, Section 7.7: Experimental results, p. 245)
%
%First the measured data will be shown in the plot. The first experiment
%of 30 in the file will be used.
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
disp('Some function m-files are being loaded ...')
[freqvect,x,y]=impfou('bandp8k.mat');
ploteltf('','',expfou(freqvect,x,y))
F=length(freqvect);
expi=1;
graphnumber=grapause('bpcordem',graphnumber,demosavegraphst);
%
echo on, clc
%The transfer function will be identified in the s-domain.
%A 4/6 order model is used in ELiS.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
Fdat=[freqvect,x((expi-1)*F+[1:F]),y((expi-1)*F+[1:F])];
varx=3e-6^2; vary=varx;
pv=elis(Fdat,[varx,vary],['s',4,6],[4,0;5,0;12,1;13,0]);
graphnumber=grapause('bpcordem',graphnumber,demosavegraphst);
%
fprintf('The phase compensation is not yet implemented.')
fdidpaus(textpause)
%disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of bpcordem %%%%%%%%%%%%%%%%%%%%%%%%
