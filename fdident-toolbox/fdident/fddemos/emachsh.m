function slide=emachsh
% This is a slideshow file for use with playshow.m and makeshow.m
% To see it run, type 'playshow emachsh',

% Copyright (c) 1984-2000 by The MathWorks, Inc.
if nargout<1,
  playshow emachsh
else
  %========== Slide 1 ==========

  slide(1).code={
   '' };
  slide(1).text={
   'The transfer function of an electrical machine is to be identified (Book of Schoukens and Pintelon, Section 8.5, p. 274). The stator impedance of an synchronous electrical machine was measured, in standstill frequency response measurement arrangement. This means that the rotor was kept mechanically at the same position during the whole measurement. The data file corresponds to the so-called d-axis characteristics of the machine. A current waveform was applied as excitation signal to the stator, and the current and the voltage were measured in the stator windings. The input signal is the current, and the output signal is the voltage.'};

  %========== Slide 2 ==========

  slide(2).code={
   'load emachine, emachine=collapse(emachine); [freqvect,x,y]=impfou(emachine);',
   'Fdat=[freqvect,x,y];',
   'semilogx(freqvect,20*log10(abs(y./x)),''+g''),ylabel(''dB''),title(''Magnitudes'')' };
  slide(2).text={
   'The measurements were carried out with three signals: a low-frequency multisine in the band (10 mHz, 990 mHz), a medium frequency multisine in the band (1 Hz, 99 Hz), and a high-frequency one in the band (20 Hz, 240 Hz). A total of 88 frequencies were picked out of the 3 frequency bands. By this, a wide frequency range (more than 4 decades) can be used in frequency domain identification, without the need of sampling, storing and processing very long time records.',
   ''};

  %========== Slide 3 ==========

  slide(3).code={
     'cla, playshowh=gcf; he=fdmkwps(''ELiS Run'',''Your plots'');'
     'pv=elis(emachine,[],[''s'',2,1],''0'','''',[5,min(freqvect),NaN,NaN,NaN,''o''+0]);',
     'figure(playshowh)' };
  slide(3).text={
     'We identify the transfer function in the s-domain. Because of the basically inductive nature of the impedance, it is reasonable to choose the numerator order higher than that of the denominator. Models of orders 2/1 and 3/2 will be tried in ELiS. A 1/0 system would correspond to a physically reasonable serial R-L model, the 2/1 one includes a further serial R-L branch, in parallel with the inductance, while the 3/2 model includes a second R-L branch, in parallel with the main inductance again. The physical parameters can be directly calculated from the parameters of the identified system. Observing the two cornerpoints, let us start with orders 2/1.'
     ''
  'The results can be examined in the ELiS run window. The fit is not perfect: we may want to increase the orders to 3/2.'};

  %========== Slide 4 ==========

  slide(4).code={
   'playshowh=gcf; cla, he=fdmkwps(''ELiS Run'',''Your plots'');'
   'pv=elis(emachine,[],[''s'',3,2],''0'','''',[5,min(freqvect),NaN,NaN,NaN,''o''+0]);',
   'figure(playshowh)'};
  slide(4).text={
     'The fit with orders 3/2 is much better: see the ELiS run window.'
     'We can study it in an error plot.'};

  %========== Slide 5 ==========

  slide(5).code={
   'if ishandle(he), delete(he), end'
   'frf=tfcalc(pv,freqvect);'
   ['semilogx(freqvect,20*log10(abs(y./x)),''+g'',',...
         'freqvect,20*log10(abs(frf)),''-r'','...
         'freqvect,20*log10(abs(frf-y./x)),''xc'')'],
   'ylabel(''dB''),title(''Magnitudes and Errors of the 3/2 Model'')' };
  slide(5).text={
     'The fit with orders 3/2 is much better.'
     'The green ''+'' marks denote the measured amplitudes, the red line the fitted model, and the ''x'' marks in cyan illustrate the errors.'};

end
