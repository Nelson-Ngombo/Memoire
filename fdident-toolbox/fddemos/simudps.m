function slide=simudps
% This is a slideshow file for use with playshow.m and makeshow.m
% Too see it run, type 'playshow simudps',

% Copyright (c) 1984-96 by The MathWorks, Inc.
if nargout<1,
  playshow simudps
else
  %========== Slide 1 ==========

  slide(1).code={
   '%Color settings                                                                                                       if mean(get(gcf,''Color''))<=0.5, white=''w''; invis=''k''; else white=''k''; invis=''w''; end     blue=''b''; red=''r''; green=''g'';',
   '',
   '',
   '',
   '' };
  slide(1).text={
   'Simulation of frequency domain data from user-defined s-domain system parameters and noise variances, followed by identification (using elis).',
   'The usage of a few functions of the Frequency Domain System Identification Toolbox is illustrated in a generated simple m-file.',
   '',
   ''};

  %========== Slide 2 ==========

  slide(2).code={
   'sys={''[1,1]'',''[1,-1]''}; sysdef=0;',
   ' while any(real(roots(sys{2}))>0),                                                                             if sysdef==1, disp(''Unstable system!''), end',
   'Quest={''Numerator coefficients'',''Denominator coefficients''};',
   'sys=fdinpdlg(Quest,''System definition'',1,{''[1,1]'',''[1,2,3,4]''},{[-inf,inf],[-inf,inf]});         sysdef=1;',
   'if isempty(sys), error(''Empty system''), end',
   '',
   'end,',
   'num=sys{1}; denom=sys{2};',
   '                                                                                                                               nord=length(num)-1; dord=length(denom)-1;',
   'pvect=exppar(''s'',num,denom);',
   'h=findobj(gcf,''type'',''axes'') ;',
   '[ha,dummy,fsc]=ploteltf(pvect,'''','''',''log'',''+'','''','''','''','''','''',''nomesg'',h(1));',
   'title(''Magnitude response'',''parent'',h(1))',
   '',
   '' };
  slide(2).text={
};

  %========== Slide 3 ==========

  slide(3).code={
   'freqv=fdinpdlg(''Frequency vector'','''',1,{''[0.021:0.021:0.65]''},{[0,inf]});                                   freqv=freqv{1};',
   'freqv=sort(freqv(:)''); fl=length(freqv);ax1=axis;',
   'pxv=(ax1(4)*0.005+ax1(3)*0.995)*ones(3,fl);',
   'pxv(2,1:fl)=(ax1(4)*0.8+ax1(3)*0.2)*ones(1,fl);                                                         pfv=[freqv(:),freqv(:),freqv(:)]''; pfv=pfv(:);',
   '',
   'hold on, semilogx(pfv*fsc,pxv(:),[''-'',''g'']); hold off, grid off',
   'axis(ax1)',
   '' };
  slide(3).text={
   'For sake of simplicity, uniform input amplitudes of value 1  will be used, with Schroeder phases. However, the frequencies of the multisine still have to be chosen.'};

  %========== Slide 4 ==========

  slide(4).code={
   'x0=msinclip(freqv,ones(fl,1),[],''nograph'',0);',
   '[x,y]=simfou(pvect,freqv,x0,vdat);',
   'figure(10), set(10,''name'',''ELiS illustration window'')',
   'Fdat=[freqv(:),x,y];',
   '[pvecte,fit,Cp]=elis(Fdat,vdat,[''s'',nord,dord]);',
   '' };
  slide(4).text={
   'In this demonstration the noise is chosen to be white, that is, the variances of the input and output frequency domain amplitudes are constant along the frequency axis. You may choose now the values of the input and output variances in the frequency domain.'};

  %========== Slide 5 ==========

  slide(5).code={
   'x0=msinclip(freqv,ones(fl,1),[],''nograph'',0);',
   '[x,y]=simfou(pvect,freqv,x0,vdat);',
   'figure(10), set(10,''name'',''ELiS illustration window'')',
   'Fdat=[freqv(:),x,y];',
   '[pvecte,fit,Cp]=elis(Fdat,[varx,vary],[''s'',nord,dord]);',
   '' };
  slide(5).text={
   ''};
end
