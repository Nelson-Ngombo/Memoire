function [cx,crinfo]=crestmin(Fdat,runmod)
%CRESTMIN Multisine design for mimimum crest factor, using Polya's algorithm.
%
%       [cx,crinfo]=crestmin(Fdat,runmod)
%
%       Algorithm: sequentially minimize 2p-norms with increasing p.
%       The output is an object (structure) containing the complex Fourier
%       amplitudes; use MSINPREP to generate a tiime domain signal from these.
%
%       Output arguments:
%       cx = fiddata object of the designed multisine. In the property 'input'
%           it contains the coefficients of the complex Fourier series:
%           the absolute values are equal to halves of the real amplitudes.
%           For the ZOH case (see below for crestmode), precompensation
%           with the inverse of the ZOH transfer function is applied, and the
%           calculated coefficients are those of the ZOH-generated excitation
%           signal.
%           In stand-alone applications, cx is a structure with the same fields:
%           input, output, freqpoints and inputcharacter (outputcharacter).
%       crinfo = information about the crest factors. Fields of this structure:
%         crx = crest factor of the generated multisine, calculated with the
%           given oversampling factor.
%         crxmax = worst case crest factor of the multisine
%         cry = crest factor of the multisine at the output of the linear
%           system, calculated with the given oversampling factor.
%         crymax = worst case output crest factor of the multisine
%
%       Input arguments:
%       Fdat = fiddata object, with the basic quantities (in stand-alone
%           applications Fdat may be a structure with the same fields):
%         freqpoints = vector of frequencies where the nonzero amplitudes are
%           given: the elements must be integer multiples of a df value, minimum
%           number of sines: 2. The frequency vector must be strictly
%           monotonously increasing.
%         input = absolute values of the desired nonzero complex amplitudes
%           (coefficients of the complex Fourier series at the corresponding
%           frequencies: halves of the real coefficients).
%           If any element is complex, the phases of the input vector will be
%           used as starting values, otherwise the Schroeder multisine is used.
%           For elements given with value NaN, auxiliary sine amplitudes are
%           returned ("snowing"): these are not included into the
%           calculation of the effective value of the useful excitation
%           signal, only help to decrease the peak value.
%           Default for these amplitudes: ones(length(fv),1)
%           Initial values for the snowing case can also be given in the
%           input: in this case a special field of runmod, 'snowinginput'
%           contains the NaN's at the snowing amplitudes, and its non-NaN elements
%           are simply neglected.
%         output = (optional) outputs: input amplitudes multiplied by the
%           complex transfer function values at the given frequencies.
%           If the output is given, input-output optimization will be performed.
%       runmod = structure of run modifiers. Usually not necessary.
%         For the details, execute 'crestmin runmod'.
%
%       Usage: [cx,crinfo]=crestmin(Fdat,runmod);
%       Examples:
%         [cx,crestx]=crestmin(fiddata([],[],[1:15]'/256));
%         crestmin(fiddata([],ones(15,1),[1:15]),struct('itmax',50,'N',4096,'pmin',64,...
%            'initset','schroeder'))
%         %
%         load crestmin
%         crestmin(vdo15,struct('itmax',50,'pmin',256,'pmax',1024,'N',4096))
%         %Random starting phases:
%         cx=crestmin(fiddata([],ones(12,1),4:15),struct('initset','rand'));
%         %ZOH design:
%         cx=crestmin(fiddata([],ones(21,1)/sqrt(42),[0.2:0.01:0.4]),...
%              struct('crestmode','ZOH','N',100));
%         %Optimize input channel data:
%         load inpchan, inpchan.output=[]; crestmin(inpchan);
%
%       See also: MSINCLIP, DIBS, MSINPREP.

%       Algorithm:
%         Guillaume, P., J. Schoukens, R. Pintelon and I. Kollar, "Crest-Factor
%         Minimization Using Nonlinear Chebyshev Approximation Methods",
%         IEEE Trans. IM, Vol. 40, No. 6, pp. 982-9, Dec. 1991.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Oct-2001

%Old fdident help:
%  'crestmin oldhelp' is automatically called

if nargin==0, error('No input argument'), end
if (nargin==1)&isstr(Fdat)
  if strncmpi(Fdat,'preload',4), return, end %preload only
  if strcmp(Fdat,'runmod')|strcmp(Fdat,'runpar')
    crestrmt, return
  elseif strcmp(Fdat,'oldhelp')
    oldhelp, return %call internal help displaying
  end
  error(['First argument ''',Fdat,''' is not allowed'])
end
isPC=strncmp(computer,'PCWIN',5);
isPlot=0; %set to 1 when plot is requested from GUI
calldrawnow=1; %call drawnow commands regularly, to see if iterctrl stops the run
calliterctrl=1; %call iterctrl regularly to see if the run is stopped
%calldrawnow=0; calliterctrl=0; %Force to eliminate drawnows
%calldrawnow=1; calliterctrl=1; %Force to call drawnows
%
itctrllastchecked='Continue'; %last value of iterctrl
termcond=0; %cause of termination
if calldrawnow, drawnow, end
%
crdef=1; %crdef=1: cr=max(abs(multisine))/effval, %crdef=2:multisinepp/2/effval
%
showmsgs=0;
if exist('fdguidev.mat'), showmsgs=1; end %messages for development
global halffigincrestmin
if ~exist('halffigincrestmin'), halffigincrestmin=''; end
if ~isempty(halffigincrestmin)
  halffig=halffigincrestmin; halffigincrestmin='';
else halffig='n';
end
%for halffigcrestmin='y', the plot of input minimization is subplot(1,2,1)
%
if nargout>2, error('Too many output arguments'), end
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)); %earlier
end
OK=1;
if isa(Fdat,'fiddata')
elseif isstruct(Fdat)
  if ~isfield(Fdat,'freqpoints'), OK=0; fprintf(['Fdat field ''freqpoints'' is missing'])
  elseif ~isfield(Fdat,'input'), OK=0; fprintf(['Fdat field ''input'' is missing'])
  elseif ~isfield(Fdat,'output'), Fdat.output='';
  end
else
  error('Fdat is not fiddata or structure')
end
if OK==0, error('First input argument is an improper structure'), end
fv=Fdat.freqpoints;
ampv=Fdat.input;
tf=Fdat.output;
if ~isempty(tf) %set transfer function from output
  ind=find(~isnan(Fdat.input));
  tf(ind)=tf(ind)./Fdat.input(ind);
end
graphs=''; itmax=[]; ovs=[]; N=[]; pld=[]; crestmode='BL';
if any(imag(ampv)), initset='input'; else initset='random'; end
pmin=2; %Default minimum value if p 
pmax=256; %default maximum value of p (2,4,8,...)
relvarmax=1e-6; %maximum relative variation of cost function to continue
Ntmax=2^13; %maximum of time domain points
Nrp=[]; %minimum N required
ovsrp=[]; %oversampling required
isnow=[];
if nargin>=2
  fn=fieldnames(runmod);
  for ii=1:length(fn)
    if strncmp(fn{ii},'initset',5)
      initset=getfield(runmod,fn{ii});
      if strncmpi(initset,'Schroeder',3)
      elseif strncmpi(initset,'random',4)
      elseif strncmpi(initset,'input',2)
      elseif isempty(initset)
      else error(['initset ''',initset,''' is invalid'])
      end
    elseif strncmp(fn{ii},'graphs',5), graphs=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'showmsgs',5)
      showmsgs=getfield(runmod,fn{ii});
      showmsgs=~strncmp(showmsgs,'n',1);
    elseif strncmp(fn{ii},'crestmode',6)
      crestmode=getfield(runmod,fn{ii});
      if strcmpi(crestmode,'discrete'), crestmode='Discrete';
      elseif strcmpi(crestmode,'ZOH')
      elseif strcmpi(crestmode,'BL'), crestmode='BL'; %default
      else error(['runmod field crestmode is not allowed: ''',crestmode,''''])
      end
    elseif strncmp(fn{ii},'itmax',2), itmax=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'pmin',4), pmin=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'pmax',4), pmax=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'relvarmax',4), relvarmax=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'oversampling',5)|strncmp(fn{ii},'ovs',3)
      ovsrp=getfield(runmod,fn{ii});
    elseif strcmpi(fn{ii},'N'), Nrp=getfield(runmod,fn{ii});
    elseif strcmpi(fn{ii},'Nmax'), Ntmax=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'cliplevel',5) %for msinclip only
      warning('cliplevel is ineffective in crestmin')
    elseif strncmp(fn{ii},'slewratemax',5) %for msinclip only
      warning('crestmin cannot minimize slew rate')
    elseif strncmp(fn{ii},'plottime',5), pld=getfield(runmod,fn{ii});
    elseif strncmp(fn{ii},'snowinginput',4)
      snowinp=getfield(runmod,fn{ii});
      if ~isempty(snowinp)
        if any(size(ampv)~=size(snowinp))
          error('snowinginput is inconsistent with the amplitudes')
        end
        ind=find(isnan(snowinp))
        if ~isempty(snowinp), isnow=ind; end
      end
    else
      error(['Unrecognized field ''',fn{ii},''''])
    end
  end %for ii
end %if nargin>=2
if isempty(pmin)|isnan(pmin)|(pmin<2), pmin=2; end
if isempty(pmax)|isnan(pmax), pmax=256; end
if isempty(relvarmax)|~isfinite(relvarmax)|(relvarmax<=0), relvarmax=1e-6; end
if isempty(isnow)&any(isnan(ampv))
  isnow=find(isnan(ampv));
end
cry=[]; crymax=[]; crdevy=[];
if isempty(pld), pld=0; end
if isempty(Nrp)|(Nrp<2), N=2; else N=Nrp; end
if rem(N,2)~=0, error('N is not an even number'), end
if isempty(itmax)|isnan(itmax), itmax=50; end
if isempty(graphs), graphs='graph'; end
%
if strcmpi(crestmode,'ZOH'), crestmodey='Discrete';
else crestmodey=crestmode;
end
if ~strcmp(graphs,'nograph')&~strcmp(graphs,'graph')&~strcmp(graphs,'graph10')&...
        ~strcmp(graphs,'graph100')&~strcmp(graphs,'lastgraph')
  error(['runmod.graphs=''',graphs,''' is not a valid option'])
end
if isempty(ampv), ampv=ones(length(fv),1); end
%
if isempty(ovsrp)
  ovs=1;
else
  if ovsrp<1, error('ovs must be at least 1'), else ovs=ovsrp; end
end

if min(size(fv))>1, error('fv is not a vector'), end
cx=[];

if min(size(ampv))>1, error('ampv is not a vector'), end
if length(fv)~=length(ampv)
  error('fv and ampv must have the same size')
end
fv=fv(:); ampv=ampv(:); tf=tf(:); %set to column vectors
if any(fv<0), error('fv has negative element(s)'), end
snow0=0; freq0=0;
if fv(1)<10*realmin
  if ~isnan(ampv(1))
    dcx=real(ampv(1));
    if dcx==0, error('To define a zero dc value makes no sense'), end
  else %dc is NaN
    dcx=0; dcy=0; snow0=1; isnow(1)=[]; 
  end
  isnow=isnow-1;
  fv(1)=[]; ampv(1)=[]; if ~isempty(cx), cx(1)=[]; end
  if ~isempty(tf), dcy=dcx*tf(1); tfdc=tf(1); tf(1)=[]; end
  freq0=1;
else
  dcx=0; dcy=0;
end
%
ireg=[1:length(ampv)]';
if ~isempty(isnow), ireg(isnow)=[]; end
if isempty(ireg), error('No amplitude to optimize'), end
if sum(ampv(ireg)~=0)<1, error('No nonzero amplitude to optimize'), end
%
%find common divider df, not smaller than ovs*2*fmax/N if N is given.
dfv=diff([0;fv]); df=min(dfv);
if any(dfv<=0), error('fv is not scrictly monotonously increasing'), end
if N==2, remfnegl=max(fv)/df*eps*max(fv);
else remfnegl=ovs*2*max(fv)/N;
end
while any(dfv>remfnegl)
  df0=df; df=min([df0;dfv]);
  dfv=sort(rem([df0;dfv],df));
  if N==2, remfnegl=max(fv)/df*eps*max(fv); end
  ind=find(dfv<=remfnegl); dfv(ind)=[];
end
fi=round(fv/df); %harmonic numbers
if max(fi)>1023,
  disp(sprintf(['WARNING: maximum harmonic index found in ''crestmin''\n',...
            '   is %.0f, with df = %.3g Hz, T = %.3g s'],max(fi),df,1/df))
  if max(fi)>1e4
    disp('Large indexes are often due to inaccurately given frequency values.')
    disp('If this is the case, before invoking crestmin do')
    disp('   fv = round(fv*T)/T;')
    disp('where T is the desired period length.')
    disp(' ')
  end
end
devii=fi*df-fv; ddf=fi\devii;
if max(abs(fi*df-fv))>max(abs(fi*(df+ddf)-fv)), df=df+ddf; end
maxdev=max(abs(fi*df-fv));
if maxdev>eps*max(fv)*max(fi)
  fprintf('WARNING! Maximum deviation of i*df from fi is %.2e in crestmin\n',maxdev)
end
if length(fi)<2, itmax=0; end
if strcmp(crestmode,'ZOH')|strcmp(crestmode,'Discrete') %Zero-order hold or discrete
  if ovs==1, fsmod=1000*eps; else fsmod=0; end
  Nov=2*ceil(ovs*max(fi)*(1+fsmod));
else %Bandlimited multisine design
  Nov=2*ceil(ovs*max([fi(ireg)+1;fi(isnow)]));
end
if ~isempty(Nrp)&(N<Nov)
  if N==Nmax
    warning(sprintf('N=%.0f is smaller than required by Nyquist theorem, %.0f',N,Nov))
  else
    error(sprintf('N=%.0f is smaller than required by Nyquist theorem, %.0f',N,Nov))
  end
end
%Nov=2*Nov; %temporary fix: some oversampling is better
if isempty(Nrp), Ntreq=2^nextpow2(max(N,Nov)); else Ntreq=N; end
Nt=min(Ntreq,Ntmax);
if showmsgs==1
  if strcmp(crestmode,'ZOH')
    disp('Continuous-time zero-order hold multisine design')
  elseif strcmp(crestmode,'Discrete')
    disp('Discrete-time zero-order hold multisine design')
  elseif strcmp(crestmode,'BL')
    disp('Bandlimited multisine design')
  end
end
ovs=Nt/(2*max(fv)/df);
if showmsgs==1
  fprintf('df=%.5g, fmax=%.0f*df',df,max(fi(ireg)))
  if ~isempty(isnow), fprintf(', fmax(snow)=%.0f*df',max(fi(isnow))), end
  fprintf(', fsmin=%.0f*df\n',2*max([fi(ireg)+1;fi(isnow)]))
  if ~isempty(ovsrp), fprintf('Prescribed minimum oversampling: %.4g\n',ovs), end
end
dt=1/(Nt*df);
%
xeff=sqrt(2*sum(abs(ampv(ireg)).^2)+dcx^2);
%fiN is the pointer selecting the frequency points we are interested in
%fiv is a similar pointer for ampv
%fiN=sort([fi;Nt-fi])+1;
%fiNreg=sort([fi(ireg);Nt-fi(ireg)])+1;
%fiNsnow=sort([fi(isnow);Nt-fi(isnow)])+1;
fiv=[[1:length(fi)]';[length(fi):-1:1]'];
fivreg=ireg([[1:length(fi(ireg))]';[length(fi(ireg)):-1:1]']);
fivsnow=isnow([[1:length(fi(isnow))]';[length(fi(isnow)):-1:1]']);
%
if isempty(cx) %initial values for snowing are not defined
  cx=zeros(size(ampv));
  if strncmpi(initset,'input',3) |...
      (isempty(initset) & (any(imag(ampv(ireg)))|any(real(ampv(ireg)))<0) )
    %starting phases are taken from input
    cx(ireg)=ampv(ireg);
  elseif strncmpi(initset,'random',4) %|isempty(initset)
    cx=abs(ampv).*exp(j*2*pi*rand(size(ampv)));
  else %definition of the Schroeder multisine
    pk=abs(ampv(ireg).^2)/sum(abs(ampv(ireg).^2));
    phi=zeros(length(fv(ireg)),1); %phi(1)=0
    for ni=2:length(fv(ireg))
      indl=find(ireg<ireg(ni));
      phi(ni)=phi(1)-...
        2*pi*sum(((fv(ireg(ni))-fv(ireg(1:ni-1)))/df).*pk(1:ni-1));
    end
    cx(ireg)=ampv(ireg).*exp(sqrt(-1)*phi);
  end
end
if strcmp(crestmode,'ZOH') %ZOH precompensation
  cx(ireg)=cx(ireg)./(exp(-j*pi*fv(ireg)*dt)...
        .*sin(pi*fv(ireg)*dt)./(pi*fv(ireg)*dt));
end
%
if calldrawnow, drawnow, end
if ~strcmp(graphs,'nograph')
  %First initialize plots
  if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
  if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
  else blue='b'; red='r'; green='g';
  end
  %
  fsh=[fv';fv';fv']; fsh=fsh(:);
  ash=[zeros(1,length(fv));abs(ampv');zeros(1,length(fv))]; ash=ash(:);
  %Delete all axes objects in current figure
  %Use get because findobj may be missing (Matlab 4.1 or earlier)
  %delete(findobj(gcf,'Type','axes'));
  hax=get(gcf,'Children');
  if ~isempty(hax), for ih=1:length(hax)
    if strcmp(get(hax(ih),'Type'),'axes'), delete(hax(ih)), end
  end, end
  ithf=findobj('tag','crestmin_iterating'); delete(ithf)
  ithf=findobj('tag','fdident_dismiss'); delete(ithf)
  if ~isempty(tf)
    subplot(2,1,1)
  end
end
randtrial=0; %counter of random trials
randdone=0; %randomization just done
if itmax>0, stopiter=0; else stopiter=1; end %flag to terminate iteration
iopt=0; %number of optimal iteration cycle
im1=0; %-1 during stop by finish
lplt=clock; lplt(6)=lplt(6)-pld;
%initializations for the compiler:
txth=inf;
recalcN=1;
%
%MAIN CYCLE
%Variables used:
%Nt = required length of time domain series
%fsh-ash = variables to plot amplitudes
%fv = frequency vector
%cx = actual amplitude vector
%ireg = indices on designed amplitudes
%isnow = indices of snow amplitudes
%crdevx, crdevy = maximum possible underestimations of crest factors
%dcx, dcy = dc values
%freq0 = 1 if dc is given, 0 if not (DC is NOT included in cx or fi or fv)
%snow0 = 1 if dc for snowing is selected
%fi = harmonic frequency indices
%df = frequency step (fv=fi*df)
%dt = time step (Nt*dt=1/df=T)
%crx, crxold = present and past crest factors

if ~isempty(isnow)
  ind=find(isnan(cx));
  cx(ind)=zeros(size(ind));
end
F=length(fv);
P=2*abs(cx(ireg)'*cx(ireg))+dcx^2;
scale=sqrt(P); %normalize power to 1
cx=cx/scale; dcx=dcx/scale;
cxinit=cx; cxold=cx; lc=length(cx);
if ~isempty(tf)
  cy=tf.*cx; if exist('tfdc')&~isempty(tfdc), dcy=tfdc*dcx; end
  Py=2*abs(cy(ireg)'*cy(ireg))+dcy^2;
  scaley=sqrt(Py); %normalize power to 1
  cy=cy/scaley; dcy=dcy/scaley;
end
%argc=tvpi*fv';
pcrx=inf; %norm which is minimized
crx=inf; cry=inf;
pn=inf; %2p-norm
cxbest=cx; crbest=inf; %best of all
%
mrd=int2str(ceil(-log10(relvarmax)+0.5)+1); %digits of stop variation to display 
lambda0=0.01; %initial value
lambdamax=1e30; %maximum reasonable value of lambda
lambdadmax=10; %maximum of decreases before try with lambda=0
itctot=0; %total number of iteration cycles already performed
itctotok=0; %%total number of sucessful iteration cycles
stopiter=0; %indicator to stop all iterations
itcdone=0; %if 0, try to automatically put up iterctrl
lastplotfollows=0;
for p=pow2([floor(log2(pmin)):ceil(log2(pmax))]) %gradually increase p from pmin
  if isempty(Nrp)|(~isempty(ovsrp)&(Nt<Nov*p))
    Ntreq=Ntreq*2;
    Nt=Nt*2;
    Nt=min(Nt,Ntmax);
    dt=1/(Nt*df);
    recalcN=1;
  else
    ovs=ovs/2;
  end
  if (recalcN==1)|~isempty(isnow)
    %Maximum overshoot between calculated values
    if strcmp(crestmode,'BL') %band-limited multisine design
      crdevx=sum(2*abs(cx).*(2*pi*fv).^2*(dt/2)^2/2)/sqrt(2*sum(abs(cx).^2));
      ge=' <= ';
    else %zero-order hold
      crdevx=0; ge=': ';
    end
    if ~isempty(tf)
      yeff=sqrt(2*sum(abs(ampv(ireg).*tf(ireg)).^2)+dcy^2);
      crdevy=sum(2*abs(cx.*tf).*(2*pi*fv).^2*(dt/2)^2/2)/sqrt(2*sum(abs(cx.*tf).^2));
    end
  end
    %
  if recalcN==1
    tvpi=[0:Nt-1]'*dt*2*pi;
    %F is the length of the frequency vector
    Sl=length(isnow);
    inda=fi(:,ones(1,F));
    ipl=inda+inda'+1;
    imi=inda-inda'+1;
    ind=find(imi<1); if ~isempty(ind), imi(ind)=imi(ind)+Nt; end
    if ~isempty(isnow)
      ipami=imi(:,F-Sl+[1:Sl]);
      ipapl=ipl(:,F-Sl+[1:Sl]);
      iaami=imi(F-Sl+[1:Sl],F-Sl+[1:Sl]);
      iaapl=ipl(F-Sl+[1:Sl],F-Sl+[1:Sl]);
    end
    recalcN=0;
  end
  Xc=zeros(Nt,1);
  if ~isempty(tf), Yc=Xc; end
  if (itctot>1)&isequal(cx,cxinit)
    %Shake cx if iteration got stucked at the starting value
    cx=cx.*exp(j*0.01*rand(size(cx)));
    warning('Iteration is stuck, phases are slightly randomized...')
  end
  itcp=-1; %number of cycles for given p, first for norm calculation only
  itcpok=0; %number of improving cycles for given p
  if ~isfinite(pn), pn=(realmax/100)^(1/2/p); end %large value of norm
  %
  relerr=inf; %initial value of the relative error
  if strcmp(graphs,'nograph'), lastplotdone=1;
  else lastplotdone=0; %plot of best data is required but has not been executed
  end
  lambda=lambda0; %initial value
  lambdaprev=NaN;
  lambdadecr=0; %counter of successive decreases of lambda
  itclam=0; %lambda adjustment cycles
  finishwhile=0; %1: command to finish while cycle
  while ( ( (finishwhile==0) | ((stopiter==1)&(lastplotdone==0)) ) &...
      (pn^p < realmax/1e3) ) | (lastplotfollows==1)
    %Inner cycle (seeking lambda to make one good step)
    %stop if criterion is met, or cannot iterate further because of numerics
    %first make an attempt to evaluate initial model
    if lastplotfollows==0
      if itcp<0 %norm was not yet calculated (initial cycle)
        Xc(fi+1)=cx; Xc(Nt-fi+1)=conj(cx);
        if freq0, Xc(1)=dcx; end
        xt=Nt*real(ifft(Xc));
        pnold=pn; pn=pnorm(xt,crdef,2*p);
        crxold=crx; crx=peak(xt,crdef)/sqrt(mean(xt.*xt));
        if~isempty(tf)
          Yc(fi+1)=cy; Yc(Nt-fi+1)=conj(cy);
          if freq0, Yc(1)=dcy; end
          yt=Nt*real(ifft(Yc));
          pn=pn+pnorm(yt,crdef,2*p);
          cry=peak(yt,crdef)/sqrt(mean(yt.*yt));
        end
        itcp=itcp+1;
      elseif itcp>=0 %otherwise first cycle for each p, for initial norm evaluation only
        Xc(fi+1)=cx; Xc(Nt-fi+1)=conj(cx);
        x=Nt*real(ifft(Xc));
        Xp2=fft(x.^(2*p-2));
        ccx=4*conj(cx);
        Psi_pl=ccx*cx';
        Psi_pl=Psi_pl.*Xp2(ipl);
        Psi_mi=ccx*cx.';
        Psi_mi=Psi_mi.*Xp2(imi);
        JTJ=p/2*real(Psi_mi-Psi_pl);
        JTe=sum(imag(Psi_mi+Psi_pl),2);
        if ~isempty(isnow)
          vsnow=exp(j*angle(cx(isnow)));
          %Calculate JTJa and JaTe
          Psi_pl=conj(2*cx*vsnow.');
          Psi_pl=Psi_pl.*Xp2(ipapl);
          Psi_mi=conj(2*cx*vsnow');
          Psi_mi=Psi_mi.*Xp2(ipami);          
          JTJa=p/2*imag(Psi_mi+Psi_pl);
          JaTe=sum(real(Psi_mi+Psi_pl))';
          %Calculate JaTJa
          Psi_pl=conj(vsnow*vsnow.');
          Psi_pl=Psi_pl.*Xp2(iaapl);
          Psi_mi=conj(vsnow*vsnow');
          Psi_mi=Psi_mi.*Xp2(iaami);          
          JaTJa=p*real(Psi_mi+Psi_pl);  
          %
          JTJ=[JTJ,JTJa;JTJa',JaTJa];
          JTe=[JTe;JaTe];
        end %if ~isempty(isnow)
        %
        if ~isempty(tf)
          Yc(fi+1)=cy; Yc(Nt-fi+1)=conj(cy);
          y=Nt*real(ifft(Yc));
          Yp2=fft(y.^(2*p-2));
          ccy=4*conj(cy);
          Psi_ply=ccy*cy';
          Psi_ply=Psi_ply.*Yp2(ipl);
          Psi_miy=ccy*cy.';
          Psi_miy=Psi_miy.*Yp2(imi);
          JTJy=p/2*real(Psi_miy-Psi_ply);
          JTey=sum(imag(Psi_miy+Psi_ply),2);
          if ~isempty(isnow)
            %snowing
            vsnow=exp(j*angle(cy(isnow)));
            %Calculate JTJay and JaTey
            Psi_ply=conj(2*cy*vsnow.');
            Psi_ply=Psi_ply.*Yp2(ipapl);
            Psi_miy=conj(2*cy*vsnow');
            Psi_miy=Psi_miy.*Yp2(ipami);          
            JTJay=p/2*imag(Psi_miy+Psi_ply);
            JaTey=sum(real(Psi_miy+Psi_ply))';
            %Calculate JaTJay
            Psi_ply=conj(vsnow*vsnow.');
            Psi_ply=Psi_ply.*Yp2(iaapl);
            Psi_miy=conj(vsnow*vsnow');
            Psi_miy=Psi_miy.*Yp2(iaami);          
            JaTJay=p*real(Psi_miy+Psi_ply);  
            %
            JTJy=[JTJy,JTJay;JTJay',JaTJay];
            JTey=[JTey;JaTey];
          end
          JTJ=[JTJ+JTJy];
          JTe=[JTe+JTey];
        end %~isempty(tf)
        %
        d=diag(JTJ); dd=d+300*max(abs(d))*eps;
        pnold=pn;
        itclam=0; %innermost cycle counter: for lambda increase only
        worsepn=0; %worsening happened in this inner cycle
        update=0;
        %cx is the present set
        cxold=cx; cxbest=cxold; dcxbest=dcx; crxbest=crx; crybest=cry;
        while (pn>=pnold*(1-relvarmax))&(lambda<lambdamax)
          %Lambda is not yet good: experiment with lambda until it is good
          cx=cxold;
          itclam=itclam+1;
          itcp=itcp+1;
          itctot=itctot+1; JTJm=JTJ+lambda*diag(dd);
          dph=-JTJm\JTe;
          %
          if any(~isfinite(dph))
            %illegal solution, switch to svd: improve numerical stability
            [U,S,V]=svd(JTJ,0); %U*S*V'
            maxsvd=max(diag(S));
            dS=diag(S);
            fro=1e4*eps*norm(JTJ,'fro');
            dS2=dS.^2;
            if lambda>0
              dS2=dS2+1.2^p*lambda*fro;
              ind=find(dS2<100*eps*max(dS)*dS);
              for ii=1:length(ind), dS2(ind(ii))=inf; end
            else
              ind=find(dS<100*eps*max(dS));
              for ii=1:length(ind), dS2(ind(ii))=inf; end
            end
            %if showmsgs==1, fprintf('Deficiency: %.0f\n',length(ind)), end
            invS=diag(dS./dS2);
            dph=-V*invS*U'*JTe;
            %still can be improved by caculating svd(J); however, run time explodes
          end %if any(~isfinite(dph))
          if ~isempty(isnow)
            da=dph(F+[1:Sl]);
            dph=dph(1:F);
          end
          %
          if ~isempty(isnow)
            cx(isnow)=cx(isnow)+da;
            cx(isnow)=cx(isnow).*exp(j*dph(isnow));
          end
          cx(ireg)=cx(ireg).*exp(j*dph(ireg));
          %
          Xc(fi+1)=cx; Xc(Nt-fi+1)=conj(cx);
          xt=Nt*real(ifft(Xc));
          if freq0 %dc needs special treatment
            if snow0 %arbitrary dc
              dcx=-median(xt); 
            else %fixed dc
              medxt=median(xt);
              if medxt~=0
                dcx=abs(dcx)*sign(-medxt);
              end
            end
            xt=xt+dcx;
          end
          if ~isempty(tf), cy=cx.*tf/scaley; end
          pnold=pn; pn=pnorm(xt,crdef,2*p);
          if ~isempty(tf)
            Yc(fi+1)=cy; Yc(Nt-fi+1)=conj(cy);
            if freq0, dcy=dcx*tfdc; Yc(1)=dcy; end
            yt=Nt*real(ifft(Yc));
            pn=pn+pnorm(yt,crdef,2*p);
          end
          %
          if pn<pnold*(1+relvarmax) %improvement or at least no worsening
            lambdaprev=lambda;
            lambdadecr=lambdadecr+1;
            if lambda>0
              if (lambdadecr>=lambdadmax)
                %Make try with lambda==0
                lambdaold=lambda; lambda=0; %try lambda=0
              else
                lambdaold=lambda; lambda=lambda/2;
              end
            end
            %if pn<pnold
              relerr=(pn-pnold)/pn;
              crxold=crx; crx=peak(xt,crdef)/sqrt(mean(xt.*xt));
              if ~isempty(tf), cry=peak(yt,crdef)/sqrt(mean(yt.*yt)); end
              pcrxold=pcrx; pcrx=pn;
              itctotok=itctotok+1; itcpok=itcpok+1;
              cxbest=cx; dcxbest=dcx; crxbest=crx; crybest=cry;
            %end
          else %worsening
            worsepn=worsepn+1;
            if lambda==0, lambda=lambdaold;
            else
              lambdaold=lambda;
              if lambdadecr, lambda=lambda*2.5;
              else lambda=lambda*10;
              end
            end
            lambdadecr=0;
            pn=pnold;
            %cx=cxold; if ~isempty(tf), cy=cx.*tf/scaley; end
          end
          if (showmsgs==1)&0
            if (itclam>0)&0
              fprintf('Maximum of the phase adjustment is %.4g degrees',...
                max(abs(dph))/2/pi*360)
              if ~lambdadecr, fprintf(', not accepted\n')
              else fprintf(', accepted\n')
              end
            end
            %
            if lambdadecr
              if lambdaprev==0
                fprintf('Lambda is kept zero\n')
              else
                fprintf('Lambda was decreased from %.3g to %.3g\n',lambdaprev,lambda)
              end
            else
              if lambda==lambdaold
                fprintf('Lambda was increased from %.3g to %.3g\n',0,lambda)
              else
                fprintf('Lambda was increased from %.3g to %.3g\n',lambdaold,lambda)
              end
            end
          end %showmsgs
          if ~lambdadecr&(showmsgs==1)&0
            if strcmp(crestmode,'BL') %BL multisine
              crdtxt=sprintf(' (<=%.5g)',crx+crdevx);
              crdytxt=sprintf(' (<=%.5g)',cry+crdevy);
            else%ZOH or discrete
              crdtxt='';
              crdytxt='';
            end
            crdtxt=''; crdytxt='';
            ltxt=sprintf(',lambda=%.4g',lambdaold);
            rtxt=',not accepted';
            itxt='';
            if lambda==0, l0txt=' (try la=0)'; else l0txt=''; end
            fprintf([itxt,'p=%.0f,cf=%.4f',crdtxt,',pn=%.',mrd,'g',rtxt,...
                ',it=%.0f',ltxt,l0txt,'\n'],...
              p,crx,pn,itcp)
            if ~isempty(tf)
              fprintf(['  cry=%.5g',crdytxt,'\n'],cry)
            end
          end
          if lambdadecr&worsepn, lambda=1.5*lambda; break, end
          if itcp>=itmax, break, end
        end %inner while (lambda)
        cx=cxbest; dcx=dcxbest; crx=crxbest; cry=crybest;
        if lambda>lambdamax, break, end
      end %if itcp
      cr=min([crx,cry]);
      %
      if cr<crbest, crbest=cr; cxbest=cx; end
      %
      if calliterctrl
        if strcmp(itctrllastchecked,'Finish')
          stopiter=1; %correct last cycle
        end
      end
      %
      %save best solution
      if stopiter==1
        cx=cxbest;
        Xc(fi+1)=cx; Xc(Nt-fi+1)=conj(cx);
        if freq0, Xc(1)=dcx; end
        xt=Nt*real(ifft(Xc));
        pnold=pn; pn=pnorm(xt,crdef,2*p);
        crx=peak(xt,crdef)/sqrt(mean(xt.*xt));
        if ~isempty(tf)
          Yc(fi+1)=cy; Yc(Nt-fi+1)=conj(cy);
          if freq0, Yc(1)=dcy; end
          yt=Nt*real(ifft(Yc));
          pn=pn+pnorm(yt,crdef,2*p);
          cry=peak(yt,crdef)/sqrt(mean(yt.*yt));
        end
      end
      %
      if showmsgs==1
        if strcmp(crestmode,'BL') %BL multisine
          crdtxt=sprintf(' (<=%.5g)',crx+crdevx);
          crdytxt=sprintf(' (<=%.5g)',cry+crdevy);
        else%ZOH or discrete
          crdtxt='';
          crdytxt='';
        end
        crdtxt=''; crdytxt='';
        if isnan(lambdaprev)
          ltxt=''; rtxt='';
          itxt=sprintf(['Initialize for p=%.0f, N=2^%.0f=%.0f, ',...
            'oversampling=%.3g (for p-power): \n'],p,log2(Nt),Nt,ovs*Nt/Ntreq);
        else
          ltxt=sprintf(',lambda=%.4g',lambdaprev);
          rtxt=sprintf(',relerr=%.2e',relerr);
          itxt='';
        end
        if (lambda==0)&(lambdaprev~=0), l0txt=' (try la=0)'; else l0txt=''; end
        fprintf([itxt,'p=%.0f,cf=%.4f',crdtxt,',pn=%.',mrd,'g',rtxt,',it=%.0f',...
            ltxt,l0txt,'\n'],p,crx,pn,itcp)
        if ~isempty(tf)
          fprintf(['  cry=%.5g',crdytxt,'\n'],cry)
        end
      end
    end %~lastplotfollows
    %
    %PLOT
    if ~strcmp(graphs,'nograph') & (pld<=etime(clock,lplt)) & ...
        ( strcmp(graphs,'graph')|...
        (strcmp(graphs,'graph10')&((rem(itclam,10)==0)|(stopiter==1))) |...
        (strcmp(graphs,'graph100')&((rem(itclam,100)==0)|(stopiter==1))) ) |...
        (strcmp(graphs,'lastgraph')&(lastplotfollows==1)&(lastplotdone==0)) |...
        isPlot
      if finishwhile==1, lastplotdone=1; end
      lplt=clock;
      if strcmp(crestmode,'ZOH') %Zero-order hold
        tv=[0:Nt-1;1:Nt]/Nt/df; tv=tv(:);
        mv=[xt';xt']; mv=mv(:);
      else
        tv=[0:Nt]'/Nt/df; mv=[xt;xt(1)];
      end
      %
      if 1 %plot x
        xlab=sprintf(['Eff. val.: %.4g, peak val.',ge,'%.4g'],...
          xeff,xeff*(crx+crdevx) );
        if isempty(tf)
          xlab=[xlab,sprintf(';  N=%.0f, ovsampl=%.2f',Nt,ovs)];
        end
        if ~isempty(tf)|strcmp(halffig,'y')|~isempty(isnow)|snow0, subplot(2,1,1), end
        ha1=gca;
        hmscl=gcf;
        if itcdone==0 %try to put up iterctrl
          if ~isempty(findall(0,'type','uimenu','tag','iteration_menu'))&exist('iterctrl')
            iterctrl;
          end
          itcdone==1;
        end
        if exist('txth')&ishandle(txth), delete(txth), end
        txth=axes('Position',[0.5,0,0.5,0.1],'parent',hmscl,'visible','off');
        ith=text(1,0,'Iterating...','parent',txth,'tag','crestmin_iterating',...
          'Verticalalignment','bottom','horizontalalignment', 'right');
        axes(ha1)
        %axes('Position',[0.13,0.5825,0.81,0.3175]); %upper subplot
        if ~strncmpi(crestmode,'Discrete',4), plot(tv,mv,['-',red])
        else plot(tv(1:length(tv)-1),mv(1:length(tv)-1),['+',red],...
            tv,mv,[':',red]) %discrete ZOH
        end
        grid off
        axv=axis; axv(2)=1/df;
        minms=min(xt+dcx); maxms=max(xt+dcx);
        axv(4)=1.05*max(abs([minms,maxms]));
        axv(4)=max(axv(4),1); axv(3)=-axv(4);
        axis(axv);
        xlabel(xlab)
        crdtxt=sprintf(' (<=%.5g)',crx+crdevx);
        title(sprintf(['Crfx: %.4f',crdtxt,', p=%.0f, pn=%.',mrd,'g, it=%.0f'],...
          crx,p,pn,itcp))
        ylabel('Normalized x(t)')
        if (~isempty(isnow)|snow0) & isempty(tf) %plot snow amplitudes
          subplot(2,1,2)
          %plot([0;fsh;max(fsh)+df],[0;ash;0],['-',green])
          maxa=max(abs(cx));
          if ~exist('minlog'), minlog=[]; end
          if isempty(minlog), minlog=maxa/100; end
          if any(cx(isnow)~=0)
            minlog=min(minlog,max(abs(cx(isnow)))/10);
            minlog=max(minlog,maxa/10^5);
          end
          minlog=10^(floor(log10(minlog*1.001)));
          ind=find(ash<minlog); ash2=ash; ash2(ind)=minlog*ones(size(ind));
          fshv=[0;fsh;max(fsh)+df];
          if freq0
            fshv=[0;0;fshv];
            ash2=[abs(dcx);minlog;ash2];
          end
          semilogy(fshv,[minlog;ash2;minlog],['-',green]), grid off
          axv=axis;
          if freq0, axv(1)=axv(1)-df/4; end
          axv(2)=max(fsh)+df;
          axv(3)=minlog;
          axv(4)=max(axv(4),(axv(4)/axv(3))^0.1*max(abs(ampv(ireg))));
          axis(axv);
          hold on
          if ~exist('fv2'), fv2=[]; end
          if isempty(fv2)
            fv2=[fv(isnow)';fv(isnow)';fv(isnow)';fv(isnow)']; fv2=fv2(:);
            if snow0, fv2=[0;0;0;0;fv2]; end  
          end
          NaNv=NaN;
          asn2=[NaNv(:,ones(size(isnow')));minlog*ones(size(isnow'));...
              abs(cx(isnow))';NaNv(:,ones(size(isnow')))];
          asn2=asn2(:);
          if snow0, asn2=[NaN;minlog;abs(dcx);NaN;asn2]; end
          semilogy(fv2,asn2,['-',red])
          hold off
          title(sprintf('Desired amplitudes: %.0f, snowing: %.0f',...
            length(ireg),length(isnow)+snow0))
          xlabel('Hz')
        end
        if exist('fixsubplotlabels')
          fixsubplotlabels %make sure that title does not coincide with xlabel of other subplot
        end
      end
      %
      if ~isempty(tf) %plot y
        if strcmp(crestmodey,'ZOH') %Zero-order hold
          tv=[0:Nt-1;1:Nt]/Nt/df; tv=tv(:);
          if ~isempty(tf), mvy=[yt';yt']; mvy=mvy(:); end
        else
          tv=[0:Nt]'/Nt/df;
          if ~isempty(tf), mvy=[yt;yt(1)]; mvy=mvy(:); end
        end
        xlaby=sprintf(['Eff. val.: %.4g, peak val.',ge,'%.4g'],...
          yeff,yeff*(crx+crdevy) );
        %if isempty(tf)
        %  xlab=[xlab,sprintf(';  N=%.0f, ovsampl=%.2f',Nt,ovs)];
        %end
        subplot(2,1,2)
        ha2=gca;
        hmscl=gcf;
        if exist('txth')&ishandle(txth), delete(txth), end
        txth=axes('Position',[0.5,0,0.5,0.1],'parent',hmscl,'visible','off');
        ith=text(1,0,'Iterating...','parent',txth,'tag','crestmin_iterating',...
          'Verticalalignment','bottom','horizontalalignment', 'right');
        axes(ha2)
        %axes('Position',[0.13,0.5825,0.81,0.3175]); %upper subplot
        if ~strncmpi(crestmodey,'Discrete',4), plot(tv,mvy,['-',red])
        else plot(tv(1:length(tv)-1),mvy(1:length(tv)-1),['+',red],...
            tv,mvy,[':',red]) %discrete ZOH
        end
        grid off
        axv=axis; axv(2)=1/df;
        minms=min(yt); maxms=max(yt);
        axv(4)=1.05*max(abs([minms,maxms]))+dcx;
        axv(4)=max(axv(4),1); axv(3)=-axv(4);
        axis(axv);
        xlabel(xlaby)
        crdytxt=sprintf(' (<=%.5g)',cry+crdevy);
        title(sprintf(['Crfy: %.5g',crdytxt,', p=%.0f, pn=%.',mrd,'g, it=%.0f'],...
          cry,p,pn,itcp))
        ylabel('Normalized y(t)')
      end %plot y
      %
      drawnow, figure(gcf), pause(0)
    end %plots
    %
    if calliterctrl&~isempty(get(0,'Children'))
      if calldrawnow==1, drawnow, end
      %Store value to minimize iterctrl calls, to bypass bug on PC:
      if exist('iterctrl'), itctrlchecked=iterctrl('checked');
      else itctrlchecked='';
      end
      if strcmp(itctrlchecked,'Pause')|...
          strcmp(itctrlchecked,'Matlab prompt')
        if strcmp(itctrlchecked,'Pause'),
          disp('Iteration paused by GUI')
        else
          fprintf('Type your commands in the mini-window\n\n')
        end
        while strcmp(itctrlchecked,'Pause')|...
            strcmp(itctrlchecked,'Matlab prompt')
          drawnow %wait and draw
          if isPC
            %Such commands that allow to accept Enter in mini-window,
            %to bypass bug on PC
            clv=clock; drawnow, pause(0)
            while etime(clock,clv)<0.1, drawnow, pause(0), end
          end
          itctrlchecked=iterctrl('checked'); drawnow
        end %while
        disp('Continue...')
      end
      if strcmp(itctrlchecked,'Keyboard')
        disp('You may now enter commands within the workspace of crestmin')
        disp('Modify GUI selection and type ''return'' to continue')
        keyboard
        itctrlchecked=iterctrl('checked');
      end
      if strcmp(itctrlchecked,'Finish')
        %stopiter=1;
        randtrial=1; termcond=max(termcond,2);
        clx=0.99; cly=0.99; if itclam==0, itmax=0; else itmax=itclam; end
        itctrllastchecked='Finish'; iterctrl('Continue');
      elseif strcmp(itctrlchecked,'Cancel')
        iterctrl('Continue');
        disp('crestmin run canceled through GUI')
        cx=[]; crx=[]; crxmax=[]; cry=[]; crymax=[];
        if isa(Fdat,'fiddata')|isstruct(Fdat)
          crinfo.crx=crx; crinfo.crxmax=crxmax; crinfo.cry=cry; crinfo.crymax=crymax;
        else
          error('Programming error')
          if nargout>1, crinfo=crx; end
          if nargout>2, varargout{1}=crxmax; end
          if nargout>3, varargout{2}=cry; end
          if nargout>4, varargout{3}=crymax; end
        end
        return
      elseif strcmp(itctrlchecked,'Abort')
        iterctrl('Continue'); error('Abort requested through GUI')
      end
      isPlot=strcmp(itctrlchecked,'Plot');
    else
      isPlot=0;
    end
    %
    if calliterctrl&~isempty(get(0,'Children'))
      if calldrawnow==1, drawnow, end
      if strcmp(itctrlchecked,'Hold graph')
        disp('Last graph of crestmin held by GUI')
        while strcmp(itctrlchecked,'Hold graph')
          drawnow
          itctrlchecked=iterctrl('checked');
        end %Wait
        disp('Continue...')
      end
      if strcmp(itctrlchecked,'Keyboard')
        disp('You may now enter commands within the workspace of elis')
        disp('Modify GUI selection and type ''return'' to continue')
        keyboard
        itctrlchecked=iterctrl('checked');
      end
      if strcmp(itctrlchecked,'Abort')
        iterctrl('Continue'); error('Abort requested through GUI')
      end
    end
    %
    if itmax==0
      if termcond==2, fprintf('Finish of crestmin requested through GUI\n'), end
      break
    end %exit if only plot was requested
    lambdaend=0; %proper stopping: require lambda=0
    %lambdaend=inf; %improper but effective stopping, arbitrary lambda (Patrick's solution)
    if ( (abs(relerr)<relvarmax) & (lambda<=lambdaend) ) | (itcp>=itmax)
      finishwhile=1;
      if (p==pmax)&strcmp(graphs,'lastgraph')&(lastplotdone==0)
        lastplotfollows=1;
      else
        lastplotfollows=0;
      end
    end
    if stopiter==1, finishwhile=1; end
    %pause(2)
  end %while
  if stopiter==1 break, end
  if itmax==0, break, end %exit if only plot was requested
end %for p
%
if strcmp(crestmode,'ZOH') %remove ZOH precompensation
  cx=cx.*(exp(-j*pi*fv*dt).*sin(pi*fv*dt)./(pi*fv*dt));
  %if ~isempty(cy), cy=cy.*(exp(-j*pi*fv*dt).*sin(pi*fv*dt)./(pi*fv*dt)); end
end
if freq0, cx=[dcx;cx]*scale; fv=[0;fv]; end
if calliterctrl
   hit=findobj(0,'tag','iteration_menu');
   if ~isempty(hit)&exist('iterctrl.m'), iterctrl('Continue'), end
end
%
if exist('ith') %Text 'Iterating' is shown
  if any(ishandle(ith))
    hp=get(ith,'parent'); delete(ith)
    set(hp,'units','pixels');
    pos=get(hp,'Position');
    p(4)=20; p(3)=50; p(2)=pos(2); p(1)=pos(1)+pos(3)-p(3);
    uicontrol('position',p,'string','Close','tag','fdident_dismiss',...
    'callback',...
    'delete(get(findobj(''tag'',''fdident_dismiss''),''parent'')'')')
  end
end
%
cx=cx/sqrt(mean(abs(cx).^2)./mean(abs(ampv).^2)); %restore amplitudes
if isa(Fdat,'fiddata')|isstruct(Fdat)
  if ~isempty(tf), cy=cx.*tf; else cy=[]; end
  if isstruct(Fdat),
    cx.Input=cx; cx.Output=cy; cx.FreqPoints=fv;
    cx.InputCharacter=''; cx.OutputCharacter='';
  else
    cx=fiddata(cy,cx,fv);
  end
  if strcmp(crestmode,'ZOH'), ich='ZOH';
  elseif strcmp(crestmode,'discrete'), ich='Discrete';
  else ich='BL';
  end
  cx.InputCharacter=ich;
  if ~isempty(tf)
    if strcmp(ich,'AASamples')|strcmp(ich,'BL'), och='BL';
    elseif strcmp(ich,'ZOH'), och='Samples';
    elseif strcmp(ich,'Discrete'), och='Discrete';
    end
    cx.OutputCharacter=och;
  end
  crinfo.crx=crx; crinfo.crxmax=crx+crdevx;
  crinfo.cry=cry; crinfo.crymax=cry+crdevy;
  crx=crinfo;
else
  error('Programming error')
  if nargout>1, crinfo=crx; end
  if nargout>2, varargout{1}=crxmax; end
  if nargout>3, varargout{2}=cry; end
  if nargout>4, varargout{3}=crymax; end
end
%%%%%%%%%%%%%%%%%%%%%%%% end of crestmin %%%%%%%%%%%%%%%%%%%%%%%%

function px=peak(xt,crdef)
%Calculate peak value
%crdef=1: cr=max(abs(multisine))/effval, %crdef=2: multisinepp/2/effval
if crdef==1, px=max(abs(xt));
elseif crdef==2, px=(max(xt)-min(xt))/2;
else error('illegal crdef')
end
%%%%%%%%%%%%%%
function pn=pnorm(xt,crdef,p);
if crdef==1, pn=norm(xt,p);
elseif crdef==2, pn=norm(xt,p);
else error('illegal crdef')
end
if isfinite(p), pn=pn/(length(xt)^(1/p)); end
%%%%%%%%%%%%%%
function crestrmt
txt=str2mat('',...
'Possible fields and their values of the crestmin run modifier structure runmod',...
'==============================================================================',...
'initset = way of setting the inital values (overrides the real/complex',...
'  nature of the amplitudes).',...
'  Values: ''Schroeder'', ''random'' (default), ''input''  ',...
'graphs = if this is given with the value ''nograph'',',...
'  iteration results will not be plotted, if with the value',...
'  ''lastgraph'', the result of the last iteration only, if with',...
'  ''graph10'', of every 10th iteration, if with ''graph100'', every 100th ',...
'  iteration, if with ''graph'', a graph in every iteration will be',...
'  plotted. Default: ''graph''',...
'showmsgs = show messages (''yes'' or ''no''), default: ''no''',...
'crestmode = way of crest factor minimization.',...
'  ''BL'': By default, a band-limited design is done.',...
'    We assume that the time domain signal will be generated from the',...
'    calculated amplitudes with very high clock frequency or with a',...
'    reconstruction filter assuming exact samples of a band-limited',...
'    signal. Thus, we assume that between the samples calculated in',...
'    crestmin the signal may be somewhat larger than the neighbouring',...
'    samples - this gives a limit for the crest factor - and no',...
'    predistortion is necessary.',...
'  ''ZOH'': we assume that a ZOH signal',...
'    will be generated from the samples, calculated with the same',...
'    clock frequency used in crestmin. In this case, no "overshoot"',...
'    can happen between the samples, but the amplitudes will be',...
'    distorted by the ZOH, so precompensation is introduced for this,',...
'    using the reciprocal of  tf_ZOH = sin(pi*fv*dt)./(pi*fv*dt).',...
'  ''discrete'': we deal with a discrete signal.',...
'    No predistortion is necessary, and no overshoot may happen.',...
'itmax = maximum number of iteration cycles, default: 50. If itmax=0,',...
'  the starting values will be returned ',...
'pmin = minimum value of p in the series 2,4,8,... default: 2',...
'pmax = maximum value of p in the series 2,4,8,... default: 256',...
'relvarmax = maximum relative variation of cost function during iteration,',...
'  default: 1e-6',...
'N = number of points in the time series (even number)',...
'  If N is given and oversampling is not, N is just the number of points',...
'    for any value of p; the sampling theorem needs to be fulfilled for',...
'    the signal itself only',...
'  If both N and oversampling are given, N is the minimum number of samples;',...
'    internally it will be increased with p, by factors of 2',...
'  By default (neither N, nor oversampling is given), N is selected as the',...
'    first power of 2, for which the sampling theorem is fulfilled for the',...
'    actual value of p (band-limited design), or for the signal itself (for',...
'    ZOH or discrete)',...
'  If only oversampling is given, N is chosen as the first power of 2, for',...
'    which the oversampling is true',...
'Nmax = maximum number of points in the time series (even number)',...
'  Deafult: 2^13.',...
'  Warning! Limiting N means that the sampling theorem is not any more',...
'    fulfilled in the calculation of the 2p-norm. While theoretically',...
'    this may be of concern, the practical results are usually good.',...
'oversampling = minimal oversampling factor',...
'  the sampling frequency will be for each p  fs>ovs*2*p*fmax, N being a',...
'    power of 2',...
'  if it is not given, the rules given for N apply',...
'plottime = minimum time between plots',...
'snowinginput = a vector of the same size as the input, it contains ',...
'  the snowing amplitudes as NaN''s');
disp(txt)

function oldhelp
txt=str2mat('',...
'CRESTMIN Multisine design for mimimum crest factor, using Polya''s algorithm.',...
'',...
'       [cx,crinfo]=crestmin(Fdat,runmod)',...
'',...
'       Algorithm: sequentially minimize 2p-norms with increasing p.',...
'',...
'       cx = structure of the designed multisine. In the field ''input''',...
'           it contains the coefficients of the complex Fourier series:',...
'           the absolute values are equal to halves of the real amplitudes.',...
'           For the ZOH case (see below for crestmode), precompensation',...
'           with the inverse of the ZOH transfer function is applied, and the',...
'           calculated coefficients are those of the ZOH-generated excitation',...
'           signal.',...
'           Further fields: input, output, freqpoints, inputcharacter, and',...
'              outputcharacter.',...
'       crinfo = information about the crest factors. Fields of this structure:',...
'         crx = crest factor of the generated multisine, calculated with the',...
'           given oversampling factor.',...
'         crxmax = worst case crest factor of the multisine',...
'         cry = crest factor of the multisine at the output of the linear',...
'           system, calculated with the given oversampling factor.',...
'         crymax = worst case output crest factor of the multisine',...
'',...
'       Input arguments:',...
'       Fdat = structure, with the basic fields:',...
'         freqpoints = vector of frequencies where the nonzero amplitudes are',...
'           given: the elements must be integer multiples of a df value. Minimum',...
'           number of sines: 2. The frequency vector must be strictly',...
'           monotonously increasing.',...
'         input = absolute values of the desired nonzero complex amplitudes',...
'           (coefficients of the complex Fourier series at the corresponding',...
'           frequencies: halves of the real coefficients).',...
'           If any element is complex, the phases of the input vector will be',...
'           used as starting values, otherwise the Schroeder multisine is used.',...
'           For elements given with value NaN, auxiliary sine amplitudes are',...
'           returned ("snowing"): these are not included into the',...
'           calculation of the effective value of the useful excitation',...
'           signal, only help to decrease the peak value.',...
'           Default for these amplitudes: ones(length(fv),1)',...
'           Initial values for the snowing case can also be given in the',...
'           input field of Fdat: in this case a special field of runmod,',...
'           ''snowinginput'' contains the NaN''s at the snowing amplitudes,',...
'           its real elements are simply neglected.',...
'         output = (optional) outputs: input amplitudes multiplied by the',...
'           complex transfer function values at the given frequencies.',...
'           If the output is given, input-output optimization will be performed.',...
'       runmod = structure of run modifiers. Usually not necessary.',...
'         For the details, execute ''crestmin runmod''.',...
'',...
'       Usage: [cx,crinfo]=crestmin(Fdat,runmod);',...
'       Examples:',...
'         [cx,crestx]=crestmin(struct(''freqpoints'',[1:15]''/256,''input'',[],...',...
'           ''output'',[]));',...
'         %Random starting phases:',...
'         cx=crestmin(struct(''freqpoints'',4:15,''input'',ones(12,1),...',...
'            ''output'',[]),struct(''initset'',''rand''));',...
'         %ZOH design:',...
'         cx=crestmin(struct(''freqpoints'',[0.2:0.01:0.4],''output'',[]),...',...
'            ''input'',ones(21,1)/sqrt(42),struct(''crestmode'',''ZOH'',''N'',100));',...
'',...
'       See also: MSINCLIP, DIBS, MSINPREP.');
disp(txt)

%%%%%%%%%%%%%%%%%%%%% end of file crestmin.m %%%%%%%%%%%%%%%%%%%%%%%%
