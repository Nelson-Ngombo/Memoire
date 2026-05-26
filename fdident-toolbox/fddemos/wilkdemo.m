%WILKDEMO Orthopol solving the Wilkinson problem (after van Vold).
%Idea developed by Yves Rolain and Johan Schoukens

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
graphnumber=0;
randseeds=randn('seed'); randn('seed',0)
MatlV=version;
if ~strcmp(MatlV(1:3),'4.0')
  %iterctrl does not work for versions below Matlab 4.1
  iterctrl
end
%
echo on
%First we will define a very badly conditioned Wilkinson-type system,
%and we will attempt a fit with orthopol.
%With the standard setting it finds a reasonable solution, but on given
%computers you can experiment with other settings.
echo off
%
if ~exist('order'), order=[]; end, if isempty(order), order=40; end
cycle=0;
while (cycle==0)|rem(order,2)~=0
  cycle=1;
  order=yesinput('Order, even number, at least 10',2*round(order/2),[10,1000]);
end
%
if ~exist('damping'), damping=[]; end
if isempty(damping), damping=0.001; end
damping=yesinput('Damping factor of the system',damping,[0,inf]);
%
if ~exist('stdnoise'), stdnoise=[]; end
if isempty(stdnoise), stdnoise=1e-10; end
stdnoise=yesinput('Standard deviation of the noise',stdnoise,[0,inf]);
%
if ~exist('insetw'), insetw=''; end, if isempty(insetw), insetw='a'; end
fprintf(['\nFor proper setting of the initial conditions,\n   the ',...
      'approximate maximum likelihood setting method (a) is recommended.'])
insetw=yesinput('Setting of initial values, l/a/s/v/w/y/e',insetw,...
          'l|a|s|v|w|y|e');
if ~exist('domain'), domain=''; end, if isempty(domain), domain='p'; end
domain=yesinput('Domain, p/s',domain,'p|s');
%
if ~exist('itmax'), itmax=[]; end, if isempty(itmax), itmax=5; end
itmax=yesinput('Maximum number of iterations',itmax,[0,inf]);
disp(' ')
%
%definition of the transfer function follows
%
disp('Calculation of data ...')
pvect=[1:order/2]; zvect=pvect+0.2;
%
k=0;
wvect=0.5:0.05:order/2+0.5;
N=length(wvect);
trans=(0+j*realmin)*ones(N,1);
for w=wvect
  k=k+1;
  calcnum=zvect.^2-w^2+2*j*zvect*w*damping;
  calcdenom=pvect.^2-w^2+2*j*pvect*w*damping;
  trans(k,1)=exp(sum(log(calcnum)))/exp(sum(log(calcdenom)));
end %for w
freq=wvect/(2*pi); freq=freq(:); F=length(freq);
trans=trans+stdnoise*(randn(N,1)+j*randn(N,1));
%
X=ones(N,1);
fixp='f';
%vdat=[1 1];
vdat=(stdnoise^2+(10^3*eps)^2*order/2)*[0 1];
rppar=[domain+0,order,order];
rpalg=['g'+0,insetw+0,itmax,2e-10,2e-10];
Fvect=[freq X trans];
%
if ~exist('wilkdfn'), wilkdfn=''; end
%wilkdfn='wilkdemo.rep';
%wilkdfn=['wilkd',int2str(order),'.rep'];
if ~strcmp(MatlV(1:3),'4.0')
  disp('You may properly finish calculations of elis in the')
  disp('   ''Iteration'' menu of the graphics window by selecting ''Finish''')
end
disp('loading elis ...')
[pvect,fit]=elis(Fvect,vdat,rppar,fixp,rpalg,'','',wilkdfn);
fprintf('Condition number for covariance calculation: %.3e\n',fit(13))
%
wilkdfn='';
%
thth=axes('Position',[0,0,1,1]); axis('off')
text(0,0,sprintf('Std of noise: %.3g',stdnoise),'Verticalalignment','bottom')
%pause
graphnumber=grapause('wilkdemo',graphnumber,demosavegraphst);
%
freqd=[];
res=2^10; df=max(freq)/(res-1); freqd=[0:res-1]*df;
freqd=sort([freqd(:);freq(:)]);
tf=tfcalc(pvect,freqd);
if isempty(tf), error('tf is empty after tfcalc'), end
clf, figure(gcf), subplot(1,2,1), plot(freqd,20*log10(abs(tf)))
ylabel('dB')
xlabel('Frequency')
title('Magnitude of transfer function')
ax1=axis; ax1(2)=max(freq); ax1(3:4)=60*[-1,1]; axis(ax1)
%
[rx,ry,rtfxy]=rdueelis(pvect,[],Fvect,vdat);
subplot(2,2,2)
plot(freq,abs(rtfxy))
title('Abs. value of complex error')
xlabel('Frequency')
ax3=axis; axis([ax1(1:2),ax3(3:4)])
%
subplot(2,2,4)
plot(freq,20*log10(abs(rtfxy./trans)))
title('Relative complex error')
ylabel('dB')
xlabel('Frequency')
ax2=axis; axis([ax1(1:2),ax2(3:4)])
thth=axes('Position',[0,0,1,1]); axis('off')
text(0,0,...
    [sprintf('Std of noise: %.3g, orders:%.0f/%.0f',stdnoise,order,order),...
     sprintf(', cf: %.5g',fit(1))],...
    'Verticalalignment','bottom');
%
graphnumber=grapause('wilkdemo',graphnumber,demosavegraphst);
%
randn('seed',randseeds)
%End of wilkdemo.m
