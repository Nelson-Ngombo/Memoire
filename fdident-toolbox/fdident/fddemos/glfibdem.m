%GLFIBDEM Demonstration - system identification: rectangular glass fiber plate

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
%The dynamic behavior of a glass fiber plate is to be identified.
%(Book, Section 8.2: Modal analysis, Example 3, p. 250)
%The plate was hung on two nylon threads, to assure freedom for movement.
%The shaker was glued by beeswax to the plate surface. The excitation force
%was measured as input signal, and the acceleration at another point of the
%plate surface was measured as output signal. The excitation signal was a
%flat multisine composed of 200 frequencies in the band between 195.31 Hz
%and 389.6 Hz.
%
%First the measured data will be shown in the plot.
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
disp('some m-files are being loaded...')
%
[freqvect,x,y]=impfou('glassfib.mat');
Fdat=[freqvect,x,y];
ploteltf('glassfib.mat')
%
graphnumber=grapause('glfibdem',graphnumber,demosavegraphst);
%
echo on, clc
%The transfer function will be identified in the s-domain.
%A 8/10 order model is used in ELiS.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
[pv,fit]=elis(Fdat,[9.61e-10,9.216e-9],['s',8,10],'0','l',10);
graphnumber=grapause('glfibdem',graphnumber,demosavegraphst);
%
clc
fprintf('The value of the cost function is %.2f,\n',fit(1))
fprintf('the theoretical value is %.0f, with standard deviation %.2f.\n',...
     fit(2),sqrt(2*fit(2)))
disp('The fit is quite good, however, the errors are quite large around')
disp('230 Hz. The cause of deviations is probably the nonlinear nature')
disp('of the phenomenon: the linear transfer function is a good')
disp('approximation for small displacements only.')
disp(' ')
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of glfibdem %%%%%%%%%%%%%%%%%%%%%%%%
