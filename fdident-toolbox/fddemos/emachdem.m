%EMACHDEM Demonstration - system identification: electrical machine

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end
graphnumber=0;
echo on, clc
%The transfer function of an electrical machine is to be identified.
%(Book, Section 8.5, p. 274)
%The stator impedance of an synchronous electrical machine was measured,
%in standstill frequency response measurement arrangement. This means that
%the rotor was kept mechanically at the same position during the whole
%measurement. The data file corresponds to the so-called d-axis characteristics
%of the machine. A current waveform was applied as excitation signal to the
%stator, and the voltage was measured in the stator windings.
%The measurements were carried out with three signals: a low-frequency
%multisine in the band (10 mHz, 990 mHz), a medium frequency multisine in
%the band (1 Hz, 99 Hz), and a high-frequency one in the band (20 Hz, 240 Hz).
%A total of 88 frequencies were picked out of the 3 frequency bands.
%By this, a wide frequency range (more than 4 decades) can be used in
%frequency domain identification, without the need of sampling, storing and
%processing very long time records.
%
%First the measured data will be shown in the plot.
echo off
if ~strcmp(textpause,'off')
  fprintf('Press any key to continue ...'), pause, disp(' ')
end
disp('Some function m-files are being loaded ...')
load emachine
Fdat=emachine; freqvect=emachine.freqpoints;
%ploteltf('','',Fdat,'logF')
ploteltf('','',emachine,'logF')
graphnumber=grapause('emachdem',graphnumber,demosavegraphst);
%
echo on, clc
%The transfer function will be identified in the s-domain.
%The input signal is the current, and the output signal is the voltage;
%Because of the basically inductive nature of the impedance, it is
%reasonable to choose the numerator order higher than that of the
%denominator. Models of order 1/0, 2/1, 3/2 will be tried in ELiS.
%The 1/0 system corresponds to a physically reasonable serial R-L model,
%the 2/1 one includes a further serial R-L branch, in parallel with the
%inductance, while the 3/2 model includes a second R-L branch, in parallel
%with the main inductance again. The physical parameters can be directly
%calculated from the parameters of the identified system.
%
echo off
fdidpaus(textpause)
if strcmp(computer,setstr('pc'-32))|strcmp(computer,setstr('mac'-32))
  save emachdem.mat, clear, load emachdem, delete emachdem.mat  %simulate pack
end
for numo=1:3
  NaNv=NaN; %bypass Vax problem with NaN*
  if numo>1, clf, drawnow, end
  iterctrl
  if isnumeric(freqvect), mfv=min(freqvect);
  else mfv=min(cat(1,freqvect{:}));
  end
  pv=elis(Fdat,[],['s',numo,numo-1],'0','',[5,mfv,NaNv(1,ones(1,3)),'o'+0]);
  graphnumber=grapause('emachdem',graphnumber,demosavegraphst);
  %
  if numo<3
    clc, disp('The fit is seemingly not good enough at low frequencies.')
    disp('The order will be increased by one.')
    fdidpaus(textpause)
  end
end
clc, disp('The fit is quite good, the order will not be further increased.')
fdidpaus(textpause)
%%%%%%%%%%%%%%%%%%%%%%%% end of emachdem %%%%%%%%%%%%%%%%%%%%%%%%
