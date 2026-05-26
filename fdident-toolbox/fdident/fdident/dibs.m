function [bitser,ampopt,Puf,Ptot]=dibs(varargin)
%DIBS   Discrete interval binary sequence with given amplitude distribution.
%
%       bitser=DIBS(Fdat,N,fs);
%       [bitser,Puf,Ptot]=DIBS(Fdat,N,fs,runmod);
%
%       The iterations are based on signum operations in the time domain. The
%       output is the generated series for which the minimum ratio of designed
%       and desired amplitudes is maximal.
%
%       Output arguments:
%       bitser = tiddata, containing the generated bit series (values +1,-1)
%         bitser.userdata contains the complex amplitudes of the optimal series
%         (coefficients of the complex Fourier series) at the given frequencies.
%           The amplitudes are scaled in such a way that the total
%           power of the designed signal is set to be equal to the total
%           desired power prescribed.
%       Puf = useful power (as a fraction of the total power)
%       Ptot = total desired signal power
%
%       Input arguments:
%       Fdat = fiddata object (see 'help fiddata' and 'help(fiddata)',
%          e.g. the output of msinclip, containing the
%          frequency points and the complex Fourier amplitudes as input.
%          the frequency points must be integer multiples of 1/(N*dt),
%          0 <= freqv <= 0.5*fs, minimum length: 1.
%          If any of the amplitudes is complex, one trial will be made using
%          the phases as starting value.
%          Default: all ones at the given frequenc points
%       N = length of the bit series to be generated, minimum: 2
%       fs = repetition frequency of successive bits (Hz)
%       runmod = structure of run modifiers. Fields:
%         trialno = number of iteration loops, default: 25.
%           Each loop starts from a random phase multisine.
%         state = value of the state of the uniform random generator for 
%           generating the starting phases. If this is not given, the
%           state will be continuously modified as new phase sets are generated.
%           Possible values: an integer, or a 35-element vector (see 'help rand').
%         cyclemax = maximum number of iterations for a trial, default: inf.
%         graphmod = if this is given with the value 'nograph', iteration
%           results will not be plotted, otherwise they will be plotted.
%           'raregraph' allows plots at every 10 seconds (fast execution).
%         reconstr = 'discr' or 'd' for discrete-time, 'cont' or 'c' for
%           continuous-time modeling. In the latter case, the amplitudes
%           are predistorted by reciprocal of the transfer function of the
%           zero-order hold, nothing special is done for discrete time.
%           Default: 'c'.  tf_ZOH = sin(pi*freqv*dt)./(pi*freqv*dt).
%         type = if given as 'odd', then an odd dibs is designed (no even harmonics,
%           the second half of the signal is a repetition of the first one) 
%         mean = mean value imposed on the signal (between +-1).
%
%       Usage:
%         [bitser,Puf,Ptot]=dibs(Fdat,N,fs,runmod);
%       Example: bits0=dibs(fiddata([],[1,1,1,.5]',[2:5]/1e-3/64),64,1e3);
%
%       See also: DIBSIMPR, MLBS.
%
%       Remark: the old-form command line call (backward compatible with the earlier
%         versions of the toolbox) is still usable, type 'dibs oldhelp' to see this.
%         The easier-to-use new form is recommended, and will be supported in the future.

%       runmod fields to run dits:
%         levels = number of levels (2 or 3)
%         neglevel = value of negative level (if different from -1)
%         type  may also contain 'odd' and/or 'nothird'

%Old fdident help:
%DIBS   Discrete interval binary sequence with given amplitude distribution.
%
%       bitser=DIBS(N,dt,freqv,ampv);
%       [bitser,ampopt,Puf,Ptot]=DIBS(N,dt,freqv,ampv,trialno,graphmod,reconstr);
%
%       The iterations are based on signum operations in the time domain. The
%       output is the generated series for which the minimum ratio of designed
%       and desired amplitudes is maximal.
%
%       Output arguments:
%       bitser = generated bit series (values +1,-1)
%       ampopt = complex amplitudes of the optimal series (coefficients of the
%           complex Fourier series) at frequencies in freqv.
%           The amplitudes are scaled in such a way that the total
%           power of the designed signal is set to be equal to the total
%           desired power, prescribed by ampv.
%       Puf = useful power (as a fraction of the total power)
%       Ptot = total desired signal power
%
%       Input arguments:
%       N = length of the bit series to be generated, minimum: 2
%       dt = time interval between successive bits (seconds)
%       freqv = vector of frequencies where the amplitudes are given:
%           the elements must be integer multiples of 1/(N*dt),
%           0 <= freqv <= 0.5/dt, minimum length: 1.
%       ampv = absolute values of the desired complex amplitudes
%           (coefficients of the complex Fourier series)
%           at the corresponding frequencies.
%           If any element of ampv is complex, one trial will be made using
%           the phases of ampv as starting value.
%           Default: ampv=ones(length(freqv),1)
%       trialno = number of iteration loops, default: 25.
%           Each loop starts from a random phase multisine.
%       graphmod = if this is given with the value 'nograph', iteration
%           results will not be plotted, otherwise they will be plotted.
%       reconstr = 'discr' or 'd' for discrete-time, 'cont' or 'c' for
%           continuous-time modeling. In the latter case, the amplitudes
%           are predistorted by reciprocal of the transfer function of the
%           zero-order hold, nothing special is done for discrete time.
%           Default: 'c'.  tf_ZOH = sin(pi*freqv*dt)./(pi*freqv*dt).
%
%       Usage:
%         bitser=dibs(N,dt,freqv,ampv);
%         [bitser,ampopt,Puf,Ptot]=dibs(N,dt,freqv,ampv,trialno,graphmod,reconstr);
%       Example: bits0=dibs(16,1e-3,[2:5]/1e-3/16,[1,1,1,.5]);
%
%       See also: DIBSIMPR, MLBS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 17-Jan-2004

%       Algorithm: A. van den Bos and R. G. Krol, "Synthesis of Discrete-
%       Interval Binary Signals with Specified Fourier Amplitude Spectra", Int.
%       J. of Control, 1979, 30/5, pp. 871-884.
%       Modified to have zero mean, and to pick signal with smallest negative
%       relative deviation from desired amplitudes.

if (nargin==1)&isstr(varargin{1})
  if strcmp(varargin{1},'secret')
    fprintf(['  ''Secret'' way of setting the number of trials:\n',...
        '    global dibs_trialno\n    dibs_trialno=<trials>;\n'])
    return
  elseif strcmp(varargin{1},'oldhelp')
    oldhelp dibs
    return
  end
end
global dibs_trialno
c=computer; isPC=strcmp(c(1:2),'PC'); MatlV=version;
levels=2; %dibs/dits
neglevel=-1; %ternary neg. level
if isPC %Matlab5 under Win95 still greys out
  calldrawnow=1; calliterctrl=1;
else %regular case, e.g. Matlab5 on any platform, still may grey out
  calldrawnow=1; calliterctrl=1;
end
if ~exist('iterctrl'), calliterctrl=0; end
%calldrawnow=0; calliterctrl=0; %Force to eliminate drawnows
%calldrawnow=1; calliterctrl=1; %Force to call drawnows
%
itctrllastchecked='Continue';
if calldrawnow, drawnow, end
%
showmsgs=0;
if exist('fdguidev.mat'), showmsgs=1; end %messages for development
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,7); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,7,ni)), %earlier
end
Fdat=varargin{1};
meanv=[]; dibsodd=0; dibsnothird=0; state=[];
if isa(Fdat,'fiddata')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(3,4); %Matlab 2016a or later
  else ni=nargin; error(nargchk(3,4,ni)), %earlier
  end
  if nargout>3, error('Too many output arguments'), end
  dt=[]; ampv=[]; trialno=[]; itmax=inf; graphmod=''; reconstr='';
  freqv=Fdat.freqpoints;
  if nargin>=2, N=varargin{2}; end
  if nargin>=3, dt=1/varargin{3}; end
  ampv=Fdat.input;
  if nargin>=4
    runmod=varargin{4};
    fn=fieldnames(runmod);
    for ii=1:length(fn)
      if strncmp(fn{ii},'trialno',5), trialno=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'cyclemax',6), itmax=getfield(runmod,fn{ii});
      elseif strcmp(fn{ii},'state'), state=getfield(runmod,fn{ii});
        if length(state)==1
          if ~isequal(rem(state,1),0), error('state is not an integer'), end
        elseif length(state)==35
        else error('invalid state given (not an integer or a 35-element vector)')
        end
      elseif strncmp(fn{ii},'graphmod',5), graphmod=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'reconstr',5), reconstr=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'showmsgs',5), showmsgs=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'mean',4), meanv=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'type',4), oddnothird=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'levels',5), levels=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'neglevel',4), neglevel=getfield(runmod,fn{ii});
        if (length(neglevel)~=1)|(neglevel>=0)|~isfinite(neglevel)
          error(sprintf('neglevel = %.4g is not allowed in dits',neglevel))
        end
      else
        error(['Unrecognized field ''',fn{ii},''''])
      end
    end
  end
else
  itmax=inf;
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(3,7); %Matlab 2016a or later
  else ni=nargin; error(nargchk(3,7,ni)), %earlier
  end
  if nargin<7, reconstr=''; else reconstr=varargin{7}; end
  if nargin<6, graphmod=''; else graphmod=varargin{6}; end
  if nargin<5, trialno=[]; else trialno=varargin{5}; end
  if nargin<4, ampv=[]; else ampv=varargin{4}; end
  freqv=varargin{3};
  dt=varargin{2};
  N=varargin{1};
end
if ~isequal(levels,2)&~isequal(levels,3)
  error(sprintf('levels=%.4g is not allowed',levels))
end
if isempty(reconstr), reconstr='c'; end
if strcmp(reconstr,'c')|strcmp(reconstr,'cont'), reconstr='c';
elseif strcmp(reconstr,'d')|strcmp(reconstr,'discr'), reconstr='d';
else error(['reconstr=''',reconstr,''' is not valid'])
end
if ~isempty(meanv)
  if ~isnumeric(meanv)|(length(meanv)~=1)
    error('meanv is not a scalar')
  elseif ~isfinite(meanv)|(meanv>=1)|(meanv<=neglevel)
    error(sprintf('mean = *.3g is out of range [%.3g,%.3g]',meanv,neglevel,1))
  end
end
if exist('oddnothird')
  indo=findstr(oddnothird,'odd');
  if ~isempty(indo), oddnothird(indo+[0:2])=[]; dibsodd=1; end
  indn=findstr(oddnothird,'nothird');
  if ~isempty(indn), oddnothird(indn+[0:6])=[]; dibsnothird=1; end
  if ~isempty(oddnothird), error('string ''type'' is invalid'), end
end
if dibsnothird&((neglevel~=-1)|(levels==2))
  error('''No third harmonic'' property is not provided for asymmetric or binary signals')
end
if dibsodd
  if ~isempty(meanv)
    error('Cannot set mean for odd multisine')
  elseif rem(N,2)~=0
    error('Odd sequence can be designed for N even only')
  end
end
if dibsnothird
  if ~isempty(meanv)
    error('Cannot set mean for ''no third harmonic'' multisine')
  elseif rem(N,3)~=0
    error('No third harmonic property is reasonable only if N can be divided by 3')
  end
end
if isempty(trialno)|isnan(trialno)
  if (length(dibs_trialno)==1)&(dibs_trialno>0)
    trialno=dibs_trialno;
  else
    trialno=25;
  end
end
if trialno<1, error('At least one trial must be allowed'), end
if (N<2)|(rem(N,1)~=0), error(sprintf('N=.2g is not allowed',N)), end
if rem(N,2)==1
  if dibsodd
    error('Odd N is not allowed for odd dibs')    
  elseif isequal(meanv,0)
    warning('N is odd in dibs, the mean value will not be exactly zero')
  end
end
if (min(size(freqv))>1)|(length(freqv)<1), error('freqv is not a vector'), end
%
if levels==2 %binary
  itmax=min(N,itmax); %maximum number of iterations in each trial (never to be reached)
else %ternary
  itmax=min(25,itmax);
end
if isempty(ampv), ampv=ones(length(freqv),1); freqv=freqv(:); end
if any(size(freqv)~=size(ampv))
  error('freqv and ampv must have the same size')
end
[freqv,indf]=sort(freqv(:)); ampv=ampv(:); ampv=ampv(indf); %set to column vect
fi=freqv*(N*dt); %harmonic numbers
if dibsodd
  if any(abs(rem(fi+0.5,2)-0.5)<max(fi)*10*eps)
    error('freqv*(N*dt) is not odd integer')
  end
end
if dibsnothird
  if any(abs(rem(fi+0.5,3)-0.5)<max(fi)*10*eps)
    error('freqv*(N*dt) falls somewhere on third harmonic')
  end
end
if any(abs(rem(fi+0.5,1)-0.5)>max(fi)*10*eps)
  error('freqv*(N*dt) is not integer')
end
fi=round(fi);
if any(diff(fi)<=0), error('a df value in freqv is smaller than 1/(N*dt)'), end
if any(fi<0)|any(fi>N/2), error('freqv is out of range'), end
%
fiN=sort([fi;N-fi])+1; fiv=[[1:length(fi)]';[length(fi):-1:1]'];
if fiN(length(fiN))-1==N, fiN(length(fiN))=[]; fiv(length(fiv))=[]; end
indN2=find(fiN==N/2+1);
if ~isempty(indN2)
  warning('Amplitude defined at half of the sampling frequency')
  fiN(indN2(1))=[]; fiv(indN2(1))=[];
end
%fiN is the pointer selecting the frequencies we are interested in
%fiv is a similar pointer for ampv
%
sincNarg=[0:(N-1)/2,floor(N/2+0.1):-1:1]'*pi/N+eps;
if strcmp(reconstr,'c')
  sincN=sin(sincNarg)./sincNarg;
  sincfiN=sincN(fiN);
else %no predistortion
  sincN=ones(size(sincNarg));
  sincfiN=ones(size(fiN));
end
ampdb=zeros(N,1); ampdb(fiN)=abs(ampv(fiv))./sincfiN;
%ampdb is the target of the DFT-based iteration algorithm
%  (the sinc correction is used because of the zero-order hold)
Ptot=sum(abs(ampv(fiv)).^2); %total desired power
%
Amax=1.3; %Maximum amplitude plotted
if calldrawnow, drawnow, end
plotoptprep=0;
creqv=[];
clock0=clock;
for trial=1:trialno+1 %the last cycle is only to plot best trial
  if strcmp(itctrllastchecked, 'Finish')&(trial>1), trial=trialno+1; end
  ph=zeros(N+1,1);
  if (trial==1)&any(imag(ampv)) %start from given phases
    ph(fi+1)=angle(ampv);
    if any(fi==N/2)&(imag(ampv(length(ampv)))~=0)
      error('Nonzero phase at half of the sampling frequency')
    end
  else
    if ~isempty(state), state0=rand('state'); rand('state',state); end
    ph(fi+1)=2*pi*rand(length(fi),1);
    if ~isempty(state), state=rand('state'); rand('state',state0); end
    if fi(1)==0, ph(1)=angle(ampv(1)); end
    if any(fi==N/2), ph(N/2+1)=pi*round(ph(N/2+1)/2/pi); end
  end
  ph(N-fi+1)=-ph(fi+1); ph(N+1)=[];
  amp=ampdb;
  if trial<=trialno, kmax=itmax; else kmax=1; end %administration of last cycle
  itcdone=0;
  for k=1:kmax
    if trial<=trialno %normal iteration procedure
      if calldrawnow, drawnow, end
      ampc=ampdb.*exp(sqrt(-1)*ph);
      csignal=real(ifft(ampc))*N;
      %now eliminate zeros
      ind0=find(csignal==0);
      while ~isempty(ind0)
        if ~isempty(state), state0=rand('state'); rand('state',state); end
        csignal(ind0)=eps*sign(rand(size(ind0))-0.5);
        if ~isempty(state), state=rand('state'); rand('state',state0); end
        ind0=find(csignal==0);        
      end
      if dibsodd, csignal(end/2+1:end)=-csignal(1:end/2); end
      mdc=0;
      if levels==2
        bits=sign(csignal);
        if ~isempty(meanv)
          %Set mean
          css=sort(csignal); indlev=N-(N-1)*(meanv-neglevel)/(1-neglevel);
          mdc=mean([css(floor(indlev)),css(ceil(indlev))]);
          bits=sign(csignal-mdc);
        %elseif (fi(1)~=0) & (abs(mean(bits))>1.5/N) %dc component to be eliminated
        %  mdc=median(csignal);
        %  bits=sign(csignal-mdc);
        end
        zi=find(bits==0); %eliminate zeros
        for in=zi(:)'
          if mean(bits)>0, bits(in)=-1; else bits(in)=1; end
        end
      else %ternary
        runmodfb.meanv=meanv;
        runmodfb.dibsodd=dibsodd;
        runmodfb.dibsnothird=dibsnothird;
        runmodfb.neglevel=neglevel;
        runmodfb.fiN=fiN;
        runmodfb.fiv=fiv;
        runmodfb.sincfiN=sincfiN;
        runmodfb.ampv=ampv;
        runmodfb.Ptot=Ptot;
        if (trial==1)&(k==1) %select q
          cxms=msinclip(Fdat,struct('initset','Schroeder','itno',0,...
            'graphs','nograph','showmsgs','no'));
          xtmsobj=msinprep(cxms,N,1/dt); xtms=N*xtmsobj.input; bits=xtms; %preassign
          B2=1/3*max(abs(xtms)); qv=[0.5:.25:3];
          if ~dibsnothird, qv=[qv,inf]; end %allow binary signal, too
          clim=NaN; bestclim=NaN; bestrel=NaN;
          for q=qv %search for best q (best clim)
            clim=B2/q;
            [bestclim,bestrel]=findbest(xtms,clim,runmodfb,bestclim,bestrel);  
          end %for q
          clim=bestclim; nclim=neglevel*clim;
          if dibsnothird, ntxt=sprintf('\n  (quantized result is modified by condition ''no third'')');
          else ntxt='';
          end
          fprintf(['Selected quantization level in dits: %.3g',ntxt,'\n'],clim)
        end %select q
        bestrel=0;
        [bestclim,bestrel,bestmdc,bits]=findbest(csignal,clim,runmodfb,bestclim,bestrel);
        if ~isempty(bestmdc)&~isnan(bestmdc)
          mdc=bestmdc; bestbits=bits; %bestk=k; besttrial=trial;
        end
      end
      if dibsodd, bits(end/2+1:end)=-bits(1:end/2); end %to be sure
      ampcb=fft(bits)/N;
      phb=angle(ampcb); ampb=abs(ampcb); A=ampb'*ampdb;
      if (k==1)&(trial==1) %very first iteration, initialize optimum
        ampopt=ampb; phopt=phb; Aopt=A; bitser=bits; besttrial=1; bestk=1; 
      end
      if ~exist('cycleend'), cycleend=0; end
      if all(phb==ph)|(cycleend==1) %phase did not change: solution converged
        k=k-1; break %exit loop k with last used k value
        %values in phb, ampb, bits, csignal, k, A
      else %phases were still changed
        ph=phb; %prepare next iteration
      end
    else %prepare plot of optimum
      plotoptprep=1;
      bits=bitser; trial=besttrial; k=bestk; ampb=abs(fft(bits)/N); A=Aopt;
      ampc=ampdb.*exp(sqrt(-1)*phopt); csignal=real(ifft(ampc))*N;
    end %if trial<=trialno
    %
    etim=etime(clock,clock0);
    if strcmp(graphmod,'nograph') | (strcmp(graphmod,'lastgraph')&(plotoptprep==0)) | ...
        (strcmp(graphmod,'raregraph') & (etim<10) & ~(((trial==1)&(k==1))|(plotoptprep==1)) )
    else %plots to be made
      %plot actual results
      if etim>=10, clock0=clock; end
      if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
      if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
      else blue='b'; red='r'; green='g';
      end
      %
      if itcdone==0 %try to put up iterctrl
        if isempty(findall(0,'type','uimenu','tag','iteration_menu'))&exist('iterctrl')
          iterctrl;
        end
        itcdone==1;
      end
      %Delete all axes objects in current figure
      %Use get because findobj may be missing (Matlab 4.1 or earlier)
      %delete(findobj(gcf,'Type','axes'));
      hax=get(gcf,'Children');
      if ~isempty(hax), for ih=1:length(hax)
        if strcmp(get(hax(ih),'Type'),'axes'), delete(hax(ih)), end
      end, end
      ithf=findobj('tag','msinclip_iterating'); delete(ithf)
      ithf=findobj('tag','fdident_dismiss'); delete(ithf)
      %
      hold off
      time=[[0:N-1];[1:N]]; time=time(:);
      bitsplot=[bits';bits']; bitsplot=bitsplot(:);
      tph=subplot(2,1,1);
      plot(time,bitsplot,['-',red],...
        [time(1);time(1:2:length(time))+0.5;time(length(time))],...
        [(csignal(1)+csignal(N))/2;csignal;(csignal(1)+csignal(N))/2]/A,...
        [':',green]), grid off
      axis([min(time),max(time),-2,2])
      hold on
      if levels==2
        plot([min(time),max(time)],[mdc,mdc],[':',red])
      else
        plot([min(time),max(time)],clim*[1,1],[':',red])
        plot([min(time),max(time)],nclim*[1,1],[':',red])
      end
      hold off
      hold on, plot([min(time),max(time)],[0,0],[':',white]), hold off
      ndig=ceil(log10(N));
      %findbest criterion:
      %    min( (ampb(fiN).*sincfiN)./(abs(ampv(fiv))/sqrt(Ptot))*sqrt(mean(bits.^2)) );
      mind=min( (ampb(fiN).*sincfiN)./(abs(ampv(fiv))/sqrt(Ptot)) );
      maxd=max( (ampb(fiN).*sincfiN)./(abs(ampv(fiv))/sqrt(Ptot)) );
      xlabel(sprintf('Bit numbers, N = %.0f, dt = %.3g s',N,dt))
      if levels==2, bstxt='Bit series'; else bstxt='Ternary signal'; end
      creq=1/mind;
      if levels==3 %ternary
        creq=creq*max(1,-neglevel);
        creq=creq/sqrt(mean(bits.^2));
      end
      %
      %creqv=[creqv;creq];
      %if length(creqv)==2, save, end
      %if length(creqv)==3, iterctrl('Finish'), creqv, end
      %
      title([sprintf([bstxt,', trial: %.0f/%.0f, iter: %.0f'],...
            trial,trialno,k),sprintf(', eq. cr: %.2f',creq)])
      %
      fph=subplot(2,1,2);
      fsh=[fi';fi';fi']; fsh=fsh(:);
      fNsh=[0:N/2;0:N/2;0:N/2]; fNsh=fNsh(:); Np2=floor(N/2)+1;
      ampbsh=[zeros(1,Np2);(sqrt(Ptot)*ampb(1:Np2).*sincN(1:Np2))';...
              zeros(1,Np2)];
      ampbsh=ampbsh(:);
      ampvsh=[zeros(1,length(fi));(abs(ampv)');zeros(1,length(fi))];
      ampvsh=ampvsh(:);
      plot(fNsh,ampbsh,['-',red],fsh+min(.01*N/2,.25),ampvsh,[':',green])
      grid off
      while (Amax<max(max(ampbsh)))&(Amax<2)
        Amax=Amax+0.1;
      end;
      axis([-0.1,floor(N/2)+1.1,0,Amax*max([ampvsh])])
      Puf=sum((ampb(fiN).*sincfiN).^2);
      if strncmp(computer,'MAC',3), extrasp=' '; else extrasp=''; end
      title(sprintf(['Amplitudes, Puf: %4.1f%%',...
          ', rel. in-band ampl.: %4.1f%% ... %4.1f%%'],...
        100*Puf,100*mind,100*maxd))
      tstr='';
      if dibsodd, tstr=' odd,'; end
      if dibsnothird, tstr=[tstr,' nothird,']; end
      xlabel(sprintf(['Frequency ',extrasp,'indices,',tstr,'  df = 1/(N*dt) = %.3g Hz'],...
         1/N/dt))
       if exist('fixsubplotlabels')
         fixsubplotlabels %make sure that title does not coincide with xlabel of other subplot
       end
       drawnow, figure(gcf), pause(0)
      hold off
      %
      if calliterctrl&~isempty(get(0,'Children'))&~strcmp(itctrllastchecked,'Finish')
        if calldrawnow==1, drawnow, end
        itctrlchecked=iterctrl('checked');
        if strcmp(itctrlchecked,'Hold graph')
          disp('Last graph of elis held by GUI')
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
    end
    %
    %this would be the condition if the LS criterion is used:
    %if sum(((ampb-ampdb).*sincN).^2)<sum(((ampopt-ampdb).*sincN).^2)
    %
    %this is the condition if the minimax measurement time criterion is used:
    if min((ampb(fiN).*sincfiN)./(abs(ampv(fiv))/sqrt(Ptot)))*sqrt(mean(bits.^2)) >...
        min((ampopt(fiN).*sincfiN)./(abs(ampv(fiv))/sqrt(Ptot)))*sqrt(mean(bitser.^2))
      %better than before
      ampopt=ampb; phopt=phb; Aopt=A; bitser=bits; besttrial=trial; bestk=k;
      %save best
    end
    %
    if calliterctrl&~isempty(get(0,'Children'))&~strcmp(itctrllastchecked,'Finish')
      if calldrawnow==1, drawnow, end
      %Store value to minimize iterctrl calls, to bypass bug on PC:
      itctrlchecked=iterctrl('checked');
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
        disp('You may now enter commands within the workspace of elis')
        disp('Modify GUI selection and type ''return'' to continue')
        keyboard
        itctrlchecked=iterctrl('checked');
      end
      if strcmp(itctrlchecked,'Finish')
        cycleend=1; if ~exist('termcond'), termcond=0; end, termcond=max([termcond,4]);
        itctrllastchecked='Finish'; iterctrl('Continue');
        if levels==2, fn='dibs'; else fn='dits'; end
        disp(['Finish of ',fn,' requested through GUI'])
        break
      elseif strcmp(itctrlchecked,'Cancel')
        iterctrl('Continue');
        disp('dibs run canceled through GUI')
        bitser=[]; ampopt=[]; Puf=[]; Ptot=[];
        return
      elseif strcmp(itctrlchecked,'Abort')
        iterctrl('Continue'); error('Abort requested through GUI')
      end
      isPlot=strcmp(itctrlchecked,'Plot');
    else
      isPlot=0;
    end
    %
  end %for k=1:kmax
  if plotoptprep|(trial==trialno+1), break, end
  %
end %trial=1:trialno+1
%save finish
%
ampopt=sqrt(Ptot)*ampopt.*sincN;
ampopt=ampopt(fi+1).*exp(sqrt(-1)*phopt(fi+1)); %realised amplitudes
indr=sort(indf); ampopt=ampopt(indr);
if calliterctrl, iterctrl('Continue'); end
%
ithf=findobj('tag','dibs_iterating');
if ~isempty(ithf)
  hp=get(ithf,'parent'); delete(ithf)
elseif exist('hax')
  hp=axes('position',[0,0,1,0.05],'visible','off');
end
if exist('hp')
  set(hp,'units','pixels');
  pos=get(hp,'Position');
  p(4)=20; p(3)=50; p(2)=pos(2); p(1)=pos(1)+pos(3)-p(3);
  uicontrol('position',p,'string','Close','tag','fdident_dismiss',...
    'callback','delete(get(findobj(''tag'',''fdident_dismiss''),''parent'')'')')
end
%if exist('tph')&ishandle(tph), axes(tph); end
%if exist('fph')&ishandle(fph), axes(fph); end
if isa(Fdat,'fiddata')
  bitser=tiddata([],bitser,dt);
  bitser.inputcharacter='ZOH';
  bitser.userdata=ampopt;
  bitser.frequencies=freqv;
  if ~exist('Puf'), Puf=sum((ampb(fiN).*sincfiN).^2); end
  ampopt=Puf; %set Puf
  Puf=Ptot; %Set Ptot
end
%%%%%%%%%%%%%%%%%%%%%%%%%% end of dibs %%%%%%%%%%%%%%%%%%%%%%%%%%
function [bestclim,bestrel,mdc,bits]=findbest(csignal,clim,runmodfb,bestclimprev,bestrelprev)
%Determine which clim or which signal is the best
meanv=runmodfb.meanv;
neglevel=runmodfb.neglevel;
dibsodd=runmodfb.dibsodd;
dibsnothird=runmodfb.dibsnothird;
fiN=runmodfb.fiN;
fiv=runmodfb.fiv;
sincfiN=runmodfb.sincfiN;
ampv=runmodfb.ampv;
Ptot=runmodfb.Ptot;
mdc=0;
%
nclim=neglevel*clim; bits=csignal; N=length(bits);
indp=find(csignal>clim); indn=find(csignal<nclim);
ind0=[1:length(bits)]; ind0([indp;indn])=[];
if ~isempty(indp), bits(indp)=ones(size(indp)); end
if ~isempty(indn), bits(indn)=neglevel*ones(size(indn)); end
if ~isempty(ind0), bits(ind0)=zeros(size(ind0)); end
if dibsnothird
  for ii=1:N/3/(1+dibsodd)
    inds=ii+[0,N/3,2*N/3];
    csi=csignal(inds); NaNv=NaN;
    s=sum(bits(inds));
    while s~=0 %correction is necessary
      csio=csi; sp=0; sn=0; stot=0;
      if s>0 %try to bring signal lower
        inn=find(csi<nclim);
        if ~isempty(inn), csi(inn)=NaNv(ones(size(inn))); end
        mc=clim*min(csi/clim-min(1,floor(csi/clim)));
        if mc==0, mc=clim*eps; end
        sp=sp+1; sn=0; stot=stot+1;
      elseif s<0
        inp=find(csi>clim);
        if ~isempty(inp), csi(inp)=NaNv(ones(size(inp))); end
        mc=-clim*min(max(-1,ceil(csi/clim))-csi/clim);
        if mc==0, mc=-clim*eps; end
        sn=sn+1; sp=0; stot=stot+1;
      end
      csi=csio-(1+10*eps)*mc;
      for iii=1:3
        if csi(iii)>clim, bits(inds(iii))=1;
        elseif csi(iii)<nclim, bits(inds(iii))=neglevel;
        else bits(inds(iii))=0;
        end
      end %for
      s=sum(bits(inds));
      if ((s>0)&(sp>3))|((s<0)&(sn>3))|(stot>10)
        bits(inds)=zeros(3,1); s=0;
        warning('Artificial adjustment of values')
      end
    end %while
    if dibsodd, bits(rem(inds+N/2-1,N)+1)=-bits(inds); end
  end %for ii
end
if ~isempty(meanv)
  mdcb=mean(bits); mdc=0; mdcmax=max(abs(csignal)); mdcmax0=mdcmax;
  dmlim=1.5/N/(1+(clim>0))*max(1,-neglevel);
  while abs(mdcb-meanv) > dmlim
    mdcmax=0.9*mdcmax;
    mdcmod=mdcb-meanv;
    if abs(mdcmod)>mdcmax, mdcmod=sign(mdcmod)*mdcmax; end
    mdc=mdc+mdcmod;
    indp=find(csignal-mdc>clim); indn=find(csignal-mdc<nclim);
    ind0=[1:length(bits)]; ind0([indp;indn])=[];
    if ~isempty(indp), bits(indp)=ones(size(indp)); end
    if ~isempty(indn), bits(indn)=neglevel*ones(size(indn)); end
    if ~isempty(ind0), bits(ind0)=zeros(size(ind0)); end
    mdcb=mean(bits);
    if (mdcmax<0.1/N*mdcmax0) & abs(mdcb-meanv)>dmlim
      warning(sprintf(['Cannot set exact mean value: ',...
          'mean = %.4g, meandes = %.4g, 1/N = %.4g'],mdcb,meanv,1/N))
      break
    end
  end
end
%
ampb=abs(fft(bits))/N;
mindi=min( (ampb(fiN).*sincfiN)./(abs(ampv(fiv))/sqrt(Ptot))*sqrt(mean(bits.^2)) );
creqfb=1/mindi;
if isempty(bestrelprev)|isnan(bestrelprev)|(mindi>bestrelprev)
  %new design better than old
  bestrel=mindi; bestclim=clim;
else
  bestrel=bestrelprev; bestclim=bestclimprev;
  mdc=NaN;   
end

function message = oldhelp(mfile,opt)
%OLDHELP MFILE  displays the help on the old call form of fdident functions

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1996-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Dec-2000

if nargin==0, mfile=''; end
if nargin<2, opt=''; end
if isempty(mfile)
  help oldhelp
  return
elseif isempty(opt)&any(strmatch(mfile,...
    {'crestmin'}))
  %Just <funcname> oldhelp
  feval(mfile,'oldhelp')
  return
end
if isstr(mfile)&(length(mfile)>0)&isstr(opt)&(length(opt)>0)&~strcmpi(opt,'date')
  %help with option
  eval([mfile,' ',opt])
  return
end
mfilein=mfile;
perpos=find(mfile=='.');
if isempty(perpos), mfile=[mfile,'.m']; end
perpos=find(mfile=='.');
mfname=mfile(1:perpos(1)-1);
clear perpos
%
mfline=which(mfile);
if isempty(mfline)&isdir(mfilein)
  if strcmp(mfilein(end),filesep)|strcmp(mfilein(end),'\')|...
      strcmp(mfilein(end),'/')
    %mfilein(end)='';
  else
    mfilein=[mfilein,filsesep];
  end
  type([mfilein,'Contents.m'])
  return
end
if isempty(findstr(['fdident',filesep,'fdident',filesep,lower(mfile)],lower(mfline))) &...
    isempty(findstr(['fdident',filesep,'fddemos',filesep,lower(mfile)],lower(mfline))) &...
    isempty(findstr([filesep,'fd',filesep,lower(mfile)],lower(mfline))) &...
    isempty(findstr([filesep,'fdd',filesep,lower(mfile)],lower(mfline))) & ...
    ~strcmpi(opt,'date')
  %if isempty(mfline), error(['Not fdident M-file: ',mfile]), end
  %error(['Not fdident M-file: ',mfline])
end
%
[fid,errmess]=fopen(mfile,'r');
if fid==-1
  if exist(mfname)==5
    messagei=[mfname,' is a built-in function, no M-file available'];
    disp(messagei)
    if nargout>0, message=messagei; end
    help(mfile)
    return
  elseif exist(mfname)==1
    if strcmp(mfname,'mfile')|strcmp(mfname,'mfname')|...
        strcmp(mfname,'nargin')|strcmp(mfname,'nargout')|...
        strcmp(mfname,'fid')|strcmp(mfname,'errmess')
      messagei=['File ',mfile,': ',errmess];
    else
      messagei=[mfname,' is a built-in variable, no help M-file available'];
    end
    disp(messagei)
    if nargout>0, message=messagei; end
    return
  elseif exist(mfname)==0
    c=computer;
    pathsep = ':'; %Unixpath separator character
    dirsep = '/'; %Unix directory separator character
    if strcmp(c(1:2),'PC')
      pathsep = ';'; dirsep = '\';
    elseif strcmp(c(1:2),'MA')
      pathsep = ';'; dirsep = ':';
    elseif strncmp(version,'5.',2)
      if isvms pathsep = ','; dirsep='.'; end
    end
    ps=[pathsep,path,pathsep];
    ind=find(ps==pathsep);
    dirfound=0;
    for i=2:length(ind)
      if ind(i)>length(mfname)
        if strcmp(ps(ind(i)-[length(mfname):-1:1]),mfname)
          dirfound=1;
          break
        end
      end
    end %for i
    if dirfound==1
      messagei=[mfname,' is not an M-file, it is a directory:',sprintf('\n'),...
          ps(ind(i-1)+1:ind(i)-1)];
    else
      messagei=[mfname,' does not exist in workspace of function OLDHELP'];
    end
    disp(messagei)
    if nargout>0, message=messagei; end
    return
  end
  disp(errmess)
  if nargout>0, message=str2mat(message,errmess); end
  return
end
%
filestr=fread(fid); fclose(fid);
filestr=setstr(filestr');
lfstr=length(filestr);
if lfstr==0, error(['File ',mfile,' is empty']), end
if strcmpi(mfname,'elis'), scanlen=14000;
else scanlen=7000;
end
filestrsh=filestr(1:min(scanlen,length(filestr)));
indcr=[find((filestrsh==13)|(filestrsh==10)),length(filestrsh)+1]; %cr or lf
helpbegind=1; %index of first character of help to scan for call forms
helpendind=0; %index of last character of help to scan for call forms
if strcmpi(opt,'date')
  %Look for the file 'Last modified:'
  ind=findstr('last modified:',lower(filestrsh)); fmod=15;
  if length(ind)>1, ind=ind(1); end
  if isempty(ind), ind=findstr('modified:',lower(filestrsh)); fmod=10; end
  if length(ind)>1, ind=ind(1); end
  if isempty(ind), ind=findstr('date:',lower(filestrsh)); fmod=6; end
  if length(ind)>1, ind=ind(1); end
  if ~isempty(ind)
    %ind=ind+fmod;
    indind=min(find(indcr>ind));
    inde=indcr(indind)-1;
    dstr=filestrsh(ind:inde);
    indd=find(dstr=='$'); if ~isempty(indd), dstr(indd)=''; end
    disp(dstr);
  end
  return
end
%
%We will look for the word '%' and 'function' or 'Old fdident help' as string
%We will also explore here the beginning and end of the help text
firstchar=findstr(filestrsh,['%','function']); %Different old version definition
if isempty(firstchar), firstchar=findstr(filestrsh,['%','Old fdident help']); end
nfdstr=['%','Old fdident help: same as now'];
if ~isempty(firstchar)&strcmp(filestrsh(firstchar(1)+[0:length(nfdstr)-1]),nfdstr)
  help(mfile), return
elseif ~isempty(firstchar)
  firstchar=firstchar(1);
else
  %disp(' ')
  %disp('Warning: Modified fdident help not found, regular help is invoked')
  help(mfile), return
end
%
fhc=min(find(filestrsh(firstchar+2:length(filestrsh))=='%'));
nextchi=firstchar+1+fhc; %first 'hidden' help character: % sign
fhc=nextchi;
%
nch=filestrsh(nextchi); cri=1; stopsig=0; inhelp=1; funfound=-1;
commentline=1;
while stopsig==0
  if ( (nch==' ') | ((nch>=9)&(nch<=13)) ) %blank character
    commentline=commentline-1;
    if (inhelp==1)&(commentline<=0), inhelp=0; helpendind=nextchi-1; end
    nextchi=nextchi+1;
    if nextchi<=lfstr
      if (nch==13)&(filestrsh(nextchi)==10) %cr-lf on PC
        nextchi=nextchi+1;
      end
    end
  elseif nch=='%'
    if helpbegind==1, helpbegind=nextchi+1; inhelp=1; end
    nextchi=indcr(min(find(indcr>nextchi)));
    commentline=2;
  else %general character, cycle has to stop
    stopsig=1;
  end
  %Prepare next cycle
  if (nextchi>length(filestrsh)-400)&(length(filestrsh)<length(filestr))
    filestrsh=filestr;
    indcr=[find((filestrsh==13)|(filestrsh==10)),length(filestrsh)+1]; %cr or lf
  end
  if nextchi<=lfstr
    nch=filestrsh(nextchi);
  else
    stopsig=1;
  end
end %while
if inhelp==1, helpendind=nextchi-1; end
%
helptext=filestrsh(fhc+1:helpendind);
if length(helptext)>1;
  ind=findstr(helptext,setstr([13,10]));
  for ii=length(ind):-1:1, helptext(ind(ii))=''; end
end
ind=[findstr(helptext,[setstr(13),'%']),findstr(helptext,[setstr(10),'%'])];
for ii=length(ind):-1:1, helptext(ind(ii)+[0,1])='\n'; end
ind=findstr(helptext,'%');
for ii=length(ind):-1:1
  helptext=[helptext(1:ind(ii)),helptext(ind(ii):length(helptext))];
end
fprintf(['\n',helptext,'\n'])
%
ci=findstr('Copyright',filestrsh);
bci=max(find(filestrsh(1:ci(1))=='%')); %begin index of copyright string
yi=min(findstr('odified',filestrsh(bci+1:length(filestrsh))))+bci;
if isempty(bci), return, end
eci=min([find(filestrsh(yi+[0:min(length(filestrsh)-yi,80)])==setstr(13)),...
    find(filestrsh(yi+[0:min(length(filestrsh)-yi,80)])==setstr(10))])+yi-2;
ctext=filestrsh(bci:eci);
%
ctextm=ctext;
%Fix strange bug
eol=find((ctext==setstr(13))|(ctext==setstr(10)));
for ii=1:length(eol)
  if ii==1, ctextm=ctext(1:eol(1)-1); cti=eol(1)+1;
  else
    if eol(ii)>eol(ii-1)+1
      ctextm=[ctextm,sprintf('\n'),ctext(cti:eol(ii)-1)]; cti=eol(ii)+1;
    else
      cti=cti+1;
    end
  end
end %for
if cti<=length(ctext), ctextm=[ctextm,sprintf('\n'),ctext(cti:length(ctext))]; end
ind=find(ctextm=='%');
ctextm(ind)='';
%disp(ctextm) %display copyright info
%
%End of oldhelp

%%%%%%%%%%%%%%%%%%%%%%%% end of file dibs.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
