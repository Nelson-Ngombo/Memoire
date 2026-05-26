%HELTTEST Test run times of elis

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-200
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Mar-2000, I. Kollar

randn('seed',pi*exp(1))
Nlength=256; Nfreq=Nlength/2-2;
freqv=[1:Nfreq]/Nlength*2*pi;
%Test for signal toolbox:
eval('[Gb,Ga]=cheby1(2,15,0.7); signaltb=1;','signaltb=0;')
if signaltb
  Gb(3)=Gb(3)-0.01;
  tf=feval('freqz',Gb,Ga,freqv);
else
  Gb=[0.1085    0.2171    0.0985];
  Ga=[1.0000    0.5969    0.8442];
  tf=polyval(Gb,exp(j*freqv))./polyval(Ga,exp(j*freqv));
end
X=ones(size(freqv));
U=X+(randn(size(X))+sqrt(-1)*randn(size(X)))*0.01;
Y=tf.*X+(randn(size(X))+sqrt(-1)*randn(size(X)))*0.01;
%
rppar=['z'+0, 2,2,1,'n'+0];
fixp='f';
fdat=[freqv'/pi/2 U' Y'];
rpalg=['sl'+0,5,1e-20,1e-20];
NaNv=NaN;
if exist('corrtest.m'), rppl=NaNv(:,ones(1,17));
else rppl=NaNv(:,ones(1,15));
end
rpplsav=rppl;
%
%Now test sequence follows
%
if ~exist('eliscall')
  eliscall='';
elseif strcmp(eliscall,'demo')|isnan(eliscall)
  %eliscall='[pv,fit]=elis(''inpchan'',[],[''s'',12,12],fixp,[],rppl);';
  %eliscall='[pv,fit]=elis(''inpchan'',[],[''z'',14,14],fixp,[],rppl);';
  %eliscall='[pv,fit]=elis(''lowpass(lowpass)'',[],[''s'',5,6],fixp,''ms'',rppl);';
  eliscall='[pv,fit]=elis(''emachine'',[],[''s'',3,2],[],[''la''+0,20],rppl);';
end
disp(['eliscall:  ',eliscall])
if isempty(eliscall)
disp('Evaluate  [pvectz,fit]=elis(fdat,[1 1],rppar,fixp,rpalg,rppl);')
end
%
mesgv='qtmncsbidBNx';
timev=zeros(size(mesgv));
i=0; timespent=0;
t0=zeros(1,6); t1=zeros(1,6);
pv=zeros(19,1); fit=zeros(17,1); CR=zeros(8,8);
c=computer;
%
%Reset runs
disp('Preparations ...')
clf, drawnow, figure(gcf)
clear functions
%pack %set defaults
if exist('corrtest.m')
  elis('preload'); %reset disk cache
else
  elis(-1)
end
rpplsav=rppl; rppl(14)='c'+0; rppl(1)=100;
if exist('corrtest.m'), rppl(16)=1; end
tl0=clock;
if ~isempty(eliscall)
  eval(eliscall);
else
  [pvectz,fit]=elis(fdat,[1 1],rppar,fixp,rpalg,rppl);
end
tl1=clock;
rppl=rpplsav;
%
%Measurements
disp(' ')
disp('Measurements follow ...')
rpplcsav=rppl;
for mesg=mesgv
  rppl=rpplcsav;
  clf, drawnow
  disp(' ' ), disp(['mesg = ''',mesg,''''])
  if any(mesg=='qtmncsb'), rppl(14)=mesg+0; end
  rppl(1)=1;
  if mesg=='q', rppl(14)='n'; rppl(1)=-inf;
  elseif mesg=='t', rppl(14)='m'; rppl(1)=-inf;
  elseif any(mesg=='id')&exist('corrtest.m'), rppl(17)=mesg;
  elseif mesg=='B'
  elseif mesg=='N', rppl(14)='n'; rppl(1)=-inf;
  elseif (mesg=='x')&exist('corrtest.m'), rppl(17)='n';
  end
  i=i+1;
  t0=clock; preptime=etime(t0,tl0);
  if strcmp(c(1:3),'MAC')
    if preptime<0, disp('Start time measurement error in elis'); end
    while preptime<0
      t0=clock; preptime=etime(t0,tl0);
    end
  end
  if ~isempty(eliscall), eval(eliscall);
  else
    [pvectz,fit]=elis(fdat,[1 1],rppar,fixp,rpalg,rppl);
  end
  t1=clock;
  timespent=etime(t1,t0);
  if strcmp(c(1:3),'MAC')
    if timespent<0, disp('Run time mesurement error after elis'), end
    while timespent<0
      t1=clock;
      timespent=etime(t1,t0);
    end
  end
  timev(i)=timespent;
  fprintf('  Run time: %.1f\n',timespent)
  if exist('fit'), cfn=fit(1); cyclen=fit(6); else cfn=NaN; cyclen=NaN; end
end
%
disp(' '), disp('Elis run time test')
disp(['Computer: ',computer,', Matlab version: ',version])
for i=1:length(mesgv)
  if mesgv(i)=='m',     fprintf('Messages displayed immediately, plots on')
  elseif mesgv(i)=='q', fprintf('Messages not displayed, no plots')
  elseif mesgv(i)=='t', fprintf('Messages displayed but no plots')
  elseif mesgv(i)=='n', fprintf('Messages not displayed, plots on')
  elseif mesgv(i)=='c', fprintf('Messages only collected, plots on')
  elseif mesgv(i)=='s', fprintf('Only short messages are displayed, plots on')
  elseif mesgv(i)=='b', fprintf('Messages displayed in each cycle in bursts, plots on')
  elseif mesgv(i)=='d', fprintf('Call drawnow''s, no iterctrl, plots on')
  elseif mesgv(i)=='i', fprintf('Check iterctrl, no drawnow''s, plots on')
  elseif mesgv(i)=='N', fprintf('No messages, no iterctrl, no drawnow, plots off')
  elseif mesgv(i)=='B', fprintf('Iterctrl, drawnow, messages, plots on')
  elseif mesgv(i)=='x', fprintf('No drawnow, no iterctrl, plots on')
  end
  disp([' (mesg = ''',mesgv(i),''')'])
  fprintf('  Run time: %.1f s\n',timev(i))
end
%
%End of helttest
