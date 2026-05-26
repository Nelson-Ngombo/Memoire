function [bitser,ampopt,Puf,Ptot]=dibsimpr(varargin)
%DIBSIMPR Improve discrete interval binary sequence.
%
%       [bitser,Puf,Ptot]=DIBSIMPR(bits0,runmod)
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
%       bits0 = tiddata, containing the previously designed bit sequence
%          the frequency points must be integer multiples of 1/(N*dt),
%          0 <= freqv <= 0.5*fs, minimum length: 1.
%          userdata contains the absolute values of the desired complex amplitudes
%           (coefficients of the complex Fourier series)
%           at the corresponding frequencies. Default: all ones
%       runmod = structure of run modifiers. Fields:
%         itno = number of iteration cycles, default: 1.
%         graphmod = if this is given with the value 'nograph', iteration
%           results will not be plotted, otherwise they will be plotted.
%         reconstr = 'discr' or 'd' for discrete-time, 'cont' or 'c' for
%           continuous-time modeling. In the latter case, the amplitudes
%           are predistorted by reciprocal of the transfer function of the
%           zero-order hold, nothing special is done for discrete time.
%           Default: 'c'.  tf_ZOH = sin(pi*freqv*dt)./(pi*freqv*dt).
%
%       Usage:
%        [bitser,Puf,Ptot]=dibsimpr(bits0,runmod);
%       Example: bits0=dibs(fiddata([],[1,1,1,.5]',[2:5]/1e-3/64),64,1e3);
%                bitser=dibsimpr(bits0);
%
%       See also: DIBS, MLBS.
%
%         Remark: the old-form command line call (backward compatible with the earlier
%         versions of the toolbox) is still usable, type 'oldhelp dibsimpr' to see this.
%         The easier-to-use new form is recommended, and will be supported in the future.

%Old fdident help:
%DIBSIMPR Improve discrete interval binary sequence.
%
%       bitser=DIBSIMPR(bits0,dt,freqv,ampv)
%       [bitser,ampopt,Puf,Ptot]=DIBSIMPR(bits0,dt,freqv,ampv,itno,graphmod,reconstr)
%
%       Output arguments:
%       bitser = generated bit series (values +1,-1)
%       ampopt = complex amplitudes of the optimal series (coefficients of the
%           complex Fourier series) at frequencies in freqv).
%           The amplitudes are scaled in such a way that the total
%           power of the designed signal is set to be equal to the total
%           desired power, prescribed by ampv.
%       Puf = useful power (as a fraction of the total power)
%       Ptot = total desired signal power
%
%       Input arguments:
%       bits0 = previously designed bit sequence
%       dt = time interval between successive bits (seconds)
%       freqv = vector of frequencies where the amplitudes are given:
%               the elements must be integer multiples of 1/(N*dt),
%               0 <= freqv <= 0.5/dt, minimum length: 1.
%       ampv = absolute values of the desired complex amplitudes
%           (coefficients of the complex Fourier series)
%           at the corresponding frequencies.
%           Default: ampv=ones(length(freqv),1)
%       itno = maximum number of iteration loops, default: 1
%       graphmod = if this is given with the value 'nograph', iteration
%           results will not be plotted, otherwise they will be plotted.
%       reconstr = 'discr' or 'd' for discrete-time, 'cont' or 'c' for
%           continuous-time modeling. In the latter case, the amplitudes
%           are predistorted by reciprocal of the transfer function of the
%           zero-order hold, nothing special is done for discrete time.
%           Default: 'c'.  tf_ZOH = sin(pi*freqv*dt)./(pi*freqv*dt).
%
%       Usage:
%        bitser=dibsimpr(bits0,dt,freqv,ampv)
%        [bitser,ampopt,Puf,Ptot]=dibsimpr(bits0,dt,freqv,ampv,itno,graphmod,reconstr);
%       Example: bits0=dibs(16,1e-3,[2:5]/1e-3/16,[1,1,1,.5]);
%                [bitser,ampopt]=dibsimpr(bits0,1e-3,[2:5]/1e-3/16,[1,1,1,.5]);
%
%       See also: DIBS, MLBS.

%       Algorithm: K.-D. Paehlike and H. Rake, "Binary Multifrequency Signals -
%         Synthesis and Application", Proc. 5th IFAC Symp. on Ident. and System
%         Param. Est. Darmstadt, FRG, Sept. 24-28, 1979. Vol. 1, pp. 589-596.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

c=computer; isPC=strcmp(c(1:2),'PC'); MatlV=version;
if strcmp(MatlV(1:3),'4.0')|(exist('iterctrl.m')~=2)
  %iterctrl does not work for versions lower than Matlab 4.1
  calldrawnow=0; calliterctrl=0;
  if strcmp(MatlV(1:3),'4.0')
    %disp('WARNING: In Matlab 4.0 iterctrl cannot be used')
  else
    disp('WARNING: iterctrl does not exist')
  end
elseif strcmp(MatlV(1),'4')&isPC
  %strange bug in Matlab4, let us call drawnow often to get mouse clicks
  calldrawnow=1; calliterctrl=1;
elseif isPC %Matlab5 under Win95 still greys out
  calldrawnow=1; calliterctrl=1;
else %regular case, e.g. Matlab5 on any platform, still may grey out
  calldrawnow=1; calliterctrl=1;
end
%calldrawnow=0; calliterctrl=0; %Force to eliminate drawnows
%calldrawnow=1; calliterctrl=1; %Force to call drawnows
%
itctrllastchecked='Continue';
if calldrawnow, drawnow, end
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,7); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,7,ni)), %earlier
end
tdat=varargin{1};
if isa(tdat,'tiddata')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,2,ni)), %earlier
  end
  if nargout>3, error('Too many output arguments'), end
  dt=[]; itno=[]; graphmod=''; reconstr='';
  freqv=tdat.frequencies;
  ampv=tdat.userdata;
  bits0=tdat.input;
  dt=tdat.ts;
  if nargin>=2
    runmod=varargin{2};
    if isfield(runmod,'itno'), itno=runmod.itno; end
    if isfield(runmod,'graphmod'), graphmod=runmod.graphmod; end
    if isfield(runmod,'reconstr'), reconstr=runmod.reconstr; end
  end
else
  if nargin<7, reconstr=''; else reconstr=varargin{7}; end
  if nargin<6, graphmod=''; else graphmod=varargin{6}; end
  if nargin<5, itno=[]; else itno=varargin{5}; end
  if nargin<4, ampv=[]; else ampv=varargin{4}; end
  freqv=varargin{3};
  dt=varargin{2};
  bits0=varargin{1};
end
%
if isempty(reconstr), reconstr='c'; end
if strcmp(reconstr,'c')|strcmp(reconstr,'cont'), reconstr='c';
elseif strcmp(reconstr,'d')|strcmp(reconstr,'discr'), reconstr='d';
else error(['model=''',reconstr,''' is not valid'])
end
if isempty(itno), itno=1; end
if itno<0, error('itno is negative'), end
bits0=bits0(:); N=length(bits0);
if (N<2)|(min(size(bits0))>1), error('bits0 is not a vector'), end
if min(size(freqv))>1, error('freqv is not a vector'), end
if isempty(ampv), ampv=ones(length(freqv),1); freqv=freqv(:); end
if any(size(freqv)~=size(ampv))
  error('freqv and ampv must have the same size')
end
[freqv,ind]=sort(freqv(:)); ampv=ampv(:); ampv=ampv(ind); %set to column vect
fi=freqv*(N*dt); %harmonic numbers
if any(abs(rem(fi+0.5,1)-0.5)>N*eps)
  error('freqv*(N*dt) is not integer')
end
fi=round(fi);
if any(diff(fi)<=0), error('a df value in freqv is smaller than 1/(N*dt)'), end
if any(fi<0)|any(fi>N/2), error('freqv is out of range'), end
ampv=abs(ampv);
fiN=sort([fi;N-fi]);
Ptot=2*sum(ampv.^2);
if fi(1)==0,
  Ptot=Ptot-ampv(1)^2;
  fiN(length(fiN))=[];
end
if any(fiN==N/2)
  disp('WARNING! Amplitude defined at half of the sampling frequency')
  Ptot=Ptot-ampv(length(ampv));
  indN2=find(fiN==N/2);
  fiN(indN2(1))=[];
end
ampvsc=ampv/sqrt(Ptot);
%
sincNarg=[0:(N-1)/2,floor(N/2+0.1):-1:1]'*pi/N+eps;
if strcmp(reconstr,'c')
  sincN=sin(sincNarg)./sincNarg;
  sincfi=sincN(fi+1);
  sincfiN=sincN(fiN+1);
else %no predistortion
  sincN=ones(size(sincNarg));
  sincfi=ones(size(fi));
  sincfiN=ones(size(fiN));
end
ampvscc=ampvsc./sincfi; %target of design in discrete design algorithm
%
bitser=bits0;
cexptab=exp(-sqrt(-1)*2*pi*[0:N-1]'/N)/N;
campl0=fft(bitser)/N; camplfi=campl0(fi+1);
worstq0=min(abs(camplfi)./ampvscc);
%
worstq=worstq0; axv=[0,1,0,1];
if calldrawnow, drawnow, end
%
for i=0:itno
  imprtxt='';
  optb12=[];
  if i>0 %for i=0, only plot
    mpos=0; %marker position counter
    for b1=1:N-1
      campl1=camplfi-2*bitser(b1)*cexptab(rem((b1-1)*fi,N)+1);
      for b2=b1+1:N
        if bitser(b1)*bitser(b2)<0 %opposite signs
          campl2=campl1-2*bitser(b2)*cexptab(rem((b2-1)*fi,N)+1);
          worstq12=min(abs(campl2)./ampvscc);
          if worstq12>worstq*1.001
            worstq=worstq12; optb12=[b1,b2];
          end
        end
      end %for b2
      if ~strcmp(graphmod,'nograph')
        subplot(2,1,1), axis(axv)
        if rem(mpos,ceil((N-1)/20))==0
          %text(mpos,0.96*axv(3)+0.04*axv(4),'.','VerticalAlignment','bottom')
          %drawnow %sign of life...
        end
        if b1==1, fprintf('Cycles (%.0f):\n',N-1), end
        if rem(b1,10)~=0, fprintf('.'), else fprintf(':'), end %sign of life
        if (rem(b1,50)==0)|(b1==N-1), disp(' '), end
        mpos=mpos+1;
      end
      if calldrawnow, drawnow, end
    end %for b1
    if ~isempty(optb12) %improvement found
      bitser(optb12)=-bitser(optb12); b1=optb12(1); b2=optb12(2);
      camplfi=camplfi+2*bitser(b1)*cexptab(rem((b1-1)*fi,N)+1)...
                     +2*bitser(b2)*cexptab(rem((b2-1)*fi,N)+1);
      imprtxt=sprintf(' (+%.1f%%)',100*(worstq-worstq0));
    end
  end %i>0
  %
  if calldrawnow, drawnow, end
  %
  if ~strcmp(graphmod,'nograph')&( (i==0)|~isempty(optb12) )
    %plot actual results
    hold off
    %
    if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
    if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
    else blue='b'; red='r'; green='g';
    end
    %
    %Delete all axes objects in current figure
    %Use get because findobj may be missing (Matlab 4.1 or earlier)
    %delete(findobj(gcf,'Type','axes'));
    hax=get(gcf,'Children');
    if ~isempty(hax), for ih=1:length(hax)
      if strcmp(get(hax(ih),'Type'),'axes'), delete(hax(ih)), end
    end, end
    %
    subplot(2,1,1)
    time=[[0:N-1];[1:N]]; time=time(:);
    bitsplot=[bitser';bitser']; bitsplot=bitsplot(:);
    axv=[min(time),max(time),-2,2];
    axis(axv), plot(time,bitsplot,['-',red]), axis(axv)
    hold on, plot([min(time),max(time)],[0,0],[':',white]), grid off
    hold off
    if ~isempty(optb12) %improvement found
      hold on
      plot(optb12(1)+[-1,-1,0,0],bitser(optb12(1))*[1,-1,-1,1],[':',white],...
             optb12(2)+[-1,-1,0,0],bitser(optb12(2))*[1,-1,-1,1],[':',white])
      %plot(time,bitsplot,['-',red]) %bring result to front
      hold off
    end
    xlabel(sprintf('Bit numbers, N=%.0f, dt = %.3g s',N,dt))
    titltxt=sprintf('Bit series, completed cycles: %.0f, eq. cr: %.2f',...
                i,1/worstq0);
    if worstq>worstq0, titltxt=[titltxt,sprintf('->%.2f',1/worstq)]; end
    title(titltxt)
    %
    subplot(2,1,2)
    fsh=[fi';fi';fi']; fsh=fsh(:);
    fNsh=[0:N/2;0:N/2;0:N/2]; fNsh=fNsh(:);
    campact=abs(fft(bitser))/N; Np2=floor(N/2)+1;
    ampsh=[zeros(1,Np2);sqrt(Ptot)*(campact(1:N/2+1).*sincN(1:N/2+1))';...
           zeros(1,Np2)];
    ampsh=ampsh(:);
    ampvsh=[zeros(1,length(fi));(abs(ampv)');zeros(1,length(fi))];
    ampvsh=ampvsh(:);
    plot(fNsh,ampsh,['-',red],fsh+min(.01*N/2,.25),ampvsh,[':',green])
    grid off
    axis([-0.1,floor(N/2)+1.1,0,1.3*max([ampvsh])])
    Puf=sum((campact(fiN+1).*sincfiN).^2);
    title([sprintf(['Amplitudes, Puf: %4.1f%%',...
          ', worst in-band ampl.: %4.1f%%'],100*Puf,100*worstq),imprtxt])
    xlabel(sprintf('Frequency indices,  df = 1/(N*dt) = %.3g Hz',1/N/dt))
    hold on
    subplot(2,1,1), figure(gcf)
    hold off
    %
    if calliterctrl
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
  if ( (i==0)|~isempty(optb12) )
    fprintf('dibsimpr cycle %.0f, worst amplitude: %4.1f%%',i,100*worstq)
    disp(imprtxt)
    fprintf('   useful power: %4.1f%%\n',100*Puf)
  end
  %stop if no improvement found:
  if isempty(optb12)&(i>0)
    fprintf('Cycle %.0f finished, dibsimpr cannot further improve signal\n',i)
    break
  end
  if ~strcmp(graphmod,'nograph'), figure(gcf), end
  %
  if calliterctrl&~isempty(get(0,'Children'))
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
      cycleend=1;
      itctrllastchecked='Finish'; iterctrl('Continue');
      disp('Finish of dibsimpr requested through GUI')
      break
    elseif strcmp(itctrlchecked,'Cancel')
      iterctrl('Continue');
      disp('dibsimpr run canceled through GUI')
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
end %i, main cycle
ampopt=fft(bitser)/N; ampopt=sqrt(Ptot)*ampopt(fi+1).*sincfi;
indr=sort(ind); ampopt=ampopt(indr);
if calliterctrl, iterctrl('Continue'); end
if isa(tdat,'tiddata')
  bitser=tiddata([],bitser,dt);
  bitser.userdata=ampopt;
  ampopt=Puf; Puf=Ptot;
end
%%%%%%%%%%%%%%%%%%%%%%%%%% end of dibsimpr %%%%%%%%%%%%%%%%%%%%%%%%%%
