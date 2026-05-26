function slide=fdcoursh
% This is a slideshow file for use with playshow.m and makeshow.m
% To see it run, type 'playshow fdcoursh',

% Copyright (c) 1984-98 by The MathWorks, Inc.

if nargout<1,
  playshow fdcoursh
else
  %========== Slide 1 ==========

  slide(1).code={
   'if ~exist(''mode''), mode=''''; end' };
  slide(1).text={
   'This is an interactive introduction to some of the basic commands of the fdident toolbox.'};

  %========== Slide 2 ==========

  slide(2).code={
   '[freqvect,u,y]=impfou(''bandpass(bandpass)''); Fdat=expfou(freqvect,u,y); F=length(freqvect);',
   'fvl=freqvect(kron(ones(1,25),1:F)); plot(fvl,20*log10(abs(y./u)),''+g'')',
   'ylabel(''dB''), title(''Magnitudes'')' };
  slide(2).text={
   'The transfer function of a bandpass filter has been measured repeatedly, using a multisine excitation consisting of 16 frequencies. The results of 25 experiments have been captured, the collected data have been preprocessed, and the input and output Fourier coefficients have been put into variable ''bandpass_synch'' in the file ''bandpass.mat''.',
   '',
   'How can you directly plot this file using ploteltf? Type your command into the dialog window of the next slide. Typing a space, then pushing OK will show a suggestion. Typing ''keyboard'', then pushing OK allows to use Matlab''s helps. Pushing Cancel makes the show proceed further.'};

  %========== Slide 3 ==========

  slide(3).code={
   'cla, fdcoursdef=''ploteltf(''''bandpass(bandpass_synch)'''');''; fdgetcsh',
   'if ishandle(hf), delete(hf), end, figure(hps)' };
  slide(3).text={
   'Command has been executed... press ''Next'' to continue...'};

  %========== Slide 4 ==========

  slide(4).code={
   'plot(fvl,20*log10(abs(y./u)),''+g'')' };
  slide(4).text={
   'In the plot slight noise can be seen: the results of different experiments, plotted upon each other, are scattered a little bit. This is observable rather in the transition band than in the passband. In order to be able to perform identification of the transfer function, the values of the noise variances are required. It is also advisable to check the values of the input-output covariances: these may provide an indication of excitation signal instability, bad synchronization, noisy excitation etc. These can be obtained via noise analysis.',
   'How can you directly calculate this? The file(variable) name is ''bandpass(bandpass_synch)''. Type your command into the dialog window of the next slide. Typing a space, then pushing OK will show a suggestion. Typing ''keyboard'', then pushing OK allows to use Matlab''s helps. Pushing Cancel makes the show proceed further.'};

  %========== Slide 5 ==========

  slide(5).code={
   'fdcoursdef=''[aobj,avd]=varanal(''''bandpass(bandpass_synch)'''');''; fdgetcsh',
   'if ishandle(hf), delete(hf), end, figure(hps)' };
  slide(5).text={
   'Command has been executed... press ''Next'' to continue...'};

  %========== Slide 6 ==========

  slide(6).code={
   '' };
  slide(6).text={
   'Now a quick check can show whether the noise is small indeed when compared to the Fourier amplitudes. Let us load the amplitudes of the 1st experiment and compare them to the standard deviations (sqrt(variance))'
   'How can you illustrate this this? The variables are: F (frequencies), vu, vy, cxy (input and output variances, Fx1), Na (number of averaged experiments), mu, my (veraged input/output amplitudes, Fx1).'
   'Type your command into the dialog window of the next slide. Typing a space, then pushing OK will show a suggestion. Typing ''keyboard'', then pushing OK allows to use Matlab''s helps. Pushing Cancel makes the show proceed further.'};

  %========== Slide ==========

  slide(7).code={
     'fdcoursdef=''v=aobj.OldTBSisoVariance; mu=aobj.input; my=aobj.output; vu=v(:,1); vy=v(:,2); plot(freqvect,10*log10(abs((vu*2./mu.^2))),''''+'''',freqvect,10*log10(abs(vy*2./my.^2)),''''x'''');''; fdgetcsh',
     'figure(hps)' };
  slide(7).text={
     'These are the input and output NSR''s in deciBels.'};

  %========== Slide ==========

  slide(8).code={
   '' };
  slide(8).text={
   'Now, since we have the variance values, identification may begin. elis can be invoked, with the Fourier and variance data, and with the selection of the orders. Looking to the transfer function, the number of peaks gives a quick estimation of the denominator order: each resonance peak will correspond to a complex pole pair. The number of zeros is more difficult to guess; from the bandpass nature of the transfer function it is reasonable to choose it as smaller by 1-2 than the number of poles.'
   'How can you perform identification? The variables are: freqvect (frequencies), vu, vy, cuy (input and output variances and covariances, Fx1), Na (number of averaged experiments), mu, my (averaged input/output amplitudes, 25*Fx1).'
   'Type your command into the dialog window of the next slide. Typing a space, then pushing OK will show a suggestion. Typing ''keyboard'', then pushing OK allows to use Matlab''s helps. Pushing Cancel makes the show proceed further.'};

  %========== Slide ==========

  slide(9).code={
     'fdcoursdef=''elis(aobj,[],[''''s'''',4,6]);''; fdgetcsh',
     'set(hf,''Name'',''ELiS plot''), figure(hps)' };
  slide(9).text={
     'The quality of the fit can be studied in the elis plot.'};

  %========== Slide ==========

  slide(10).code={
   'if ishandle(hf), delete(hf), end' };
  slide(10).text={
   'In order to examine the uncertainties, the parameter vector and the covariance matrix has to be obtained as output arguments of elis. Let''s plot the confidence ellipses for a probably high order of your choice. The running of elis will be much quicker if the plots are made in every 5th or 10th cycle (give the input argument rppl of elis as 5 or 10).'
   'How can you obtain data from the identification? The variables are: fvl (frequencies repeated 25 times), vu, vy, cuy (input variances and covariances, Fx1), u, y (input/output amplitudes, 25*Fx1).'
   'Type your command into the dialog window of the next slide. Typing a space, then pushing OK will show a suggestion. Typing ''keyboard'', then pushing OK allows to use Matlab''s helps. Pushing Cancel makes the show proceed further.'};

  %========== Slide ==========

  slide(11).code={
     'fdcoursdef=''[pv,fit,Cp]=elis(aobj,[],[''''s'''',5,7],[],[],10);''; fdgetcsh',
     'set(hf,''Name'',''ELiS plot''), figure(hps)' };
  slide(11).text={
     'The quality of the fit can be studied in the elis plot.'};

  %========== Slide ==========

  slide(12).code={
   'if ishandle(hf), delete(hf), end' };
  slide(12).text={
   'The poles/zeros, along with the uncertainties can be plotted by a simple command.'
   'How can you do this? Your variables are pv (parameter vector), and Cp (covariance matrix).'
   'Type your command into the dialog window of the next slide. Typing a space, then pushing OK will show a suggestion. Typing ''keyboard'', then pushing OK allows to use Matlab''s helps. Pushing Cancel makes the show proceed further.'};

  %========== Slide ==========

  slide(13).code={
     'fdcoursdef=''plotelpz(pv,Cp)''; fdgetcsh',
     'figure(hps)' };
  slide(13).text={
     'The uncertainties of poles and zeros can be studied in the plot.'};

  %========== Slide iii ==========
  islide=length(slide)+1;
  slide(islide).code={
     'if ishandle(hf), delete(hf), end' };
  slide(islide).text={
     'This is the end of the demonstration.'};

end
%
%End of file
