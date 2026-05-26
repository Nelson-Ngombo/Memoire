function slide=bandpsh
% This is a slideshow file for use with playshow.m and makeshow.m
% To see it run, type 'playshow bandpsh',

% Copyright (c) 1984-2000 by The MathWorks, Inc.
if nargout<1,
  playshow bandpsh
else
  %========== Slide 1 ==========

  slide(1).code={
   '' };
  slide(1).text={
   'The transfer function of a passive bandpass filter is to be identified (Book of Schoukens and Pintelon, Section 3.9, Experiment 1, p. 128). The data are not exactly the same as those used in the book, but they were obtained under similar circumstances, on the same filter.',
   ''};

  %========== Slide 2 ==========

  slide(2).code={
   '[freqvect,x,y]=impfou(''bandpass(bandpass)''); Fdat=expfou(freqvect,x,y); F=length(freqvect);',
   'fvl=freqvect(kron(ones(1,25),1:F)); plot(fvl,20*log10(abs(y./x)),''+g''),',
   'ylabel(''dB''),title(''Magnitudes'')' };
  slide(2).text={
   'The data file contains the results of 25 experiments. This allows to gain an impression about the variances. The transfer function estimates, obtained by the division of the output and input complex amplitudes seem to scatter only slightly.',
   ''};

  %========== Slide 3 ==========

  slide(3).code={
     'pause(0)',
     '[freqvect,x,y]=impfou(''bandpass(bandpass_synch)''); Fdat=expfou(freqvect,x,y);',
     '[varx,vary,cxy,mx,my,Na]=varanal(Fdat); vdat=[varx,vary,cxy]/Na;',
     'playshowh=gcf; he=fdmkwps(''ELiS Run'',''Your plots'');'
     '[pv,fit,Cp]= elis([freqvect,mx,my],vdat,[''s'',4,6],[4,0;5,0;12,1;13,0],'''',3);',
     'figure(playshowh), pause(1)'};
  slide(3).text={
     'We identify a 4/6 model for the bandpass filter.',
     '',
     'Look for the results in the ELiS Run window.'};

  %========== Slide 4 ==========

  slide(4).code={
   'if ishandle(he), delete(he), end'
   'frf=tfcalc(pv,freqvect);'
   ['plot(freqvect,20*log10(abs(my./mx)),''+g'',',...
         'freqvect,20*log10(abs(frf)),''-r'','...
         'freqvect,20*log10(abs(frf-my./mx)),''xc'')'],
   'ylabel(''dB''),title(''Magnitudes and Errors of the Model'')' };
  slide(4).text={
     'The fit is very good.'
     'The green ''+'' marks denote the measured amplitudes, the red line the fitted model, and the ''x'' marks in cyan illustrate the errors.'};

end
