function [avdata,varargout]=varanal(rawdata,varargin)
%VARANAL Estimate input/output variances from several experiments.
%
%       [avdata,avinfo]=varanal(rawdata,synch,T,runmod);
%
%       VARANAL(rawdata) calculates the means and the corresponding variances
%       of the complex Fourier amplitudes given in the fiddata object rawdata
%       (see help fiddata, and help(fiddata)). The covariances are defined as
%       av{conj(U_k)*Y_k}.
%       The number of experiments is at least 2. If less than 4 experiments are
%       averaged, the calculated variance is reduced to the output to maintain
%       consistency of the estimates.
%          If a second argument is given as 'delayed', or the experiments are not
%       given as synchronized (obj.synchronized='on'), an attempt is made to 
%       sychronize the experiments to each other. 
%          A third argument T defines the interval [-T/2,T/2], where the initial  
%       value of the deviation in time of the excitation signals from each other
%       is sought (e.g. the period length for periodic signals).
%       If T is not given, it will be calculated from the frequency vector. If
%       the elements of the frequency vector are not harmonically related, the
%       resulting period lenght will be too small, and a warning is sent.
%          A special call is varanal(mfile,expi) or varanal(mfile,expi,synch,T,runmod).
%       Here it is assumed that the call obj=mfile(i) returns objects of
%       individual experiments (maybe full MIMO groups of experiments), 
%       where i is a number from vector expi.
%          runmod can have the value 'novariance', in this case no variance is
%       returned, only average, or value 'noreduce': do not reduce variances 
%       to the output even if M<4.
%
%       A second output argument, structure avinfo can be returned. This
%       contains the following fields:
%         avinfo.Na = number of averaged experiments
%         avinfo.Np = number of processed experiments
%         avinfo.cfl = confidence limits of the variances: multipliers of the
%           variances to obtain 95% upper and lower bounds
%           For the covariances, (cfl(1)-1)*sqrt(vx(k)*vy(k)) can be used as
%           additive error bound for the real and imaginary parts.
%         avinfo.dv = calculated delays of experiments, relative to the first
%           one (in 'delayed' mode only). The delays for the non-synchronizable
%           experiments will be equal to NaN.
%           The amplitude vector can be turned back to in-phase position by
%           executing   exp(j*2*pi*freqv*tau(i)).*Ui
%         avinfo.stddelay = Cramer-Rao bound (approximate standard deviation)
%           of the estimated delays in dv (empty if inapplicable)
%
%       Usage: [avdata,avinfo]=varanal(rawdata,synch,T);
%       Examples: load bandpass, bp6=bandpass{:,1:6};
%                 avdata=varanal(bp6,'delayed');
%                 avdata=varanal('bandpass(bandpass_synch)');
%
%       See also: TIM2FOU, @FIDDATA/NONLINVAR, @FIDDATA/INTERPVAR.

%Old fdident help
%VARANAL Estimate input/output variances from several experiments.
%
%       [vx,vy,cxy,mx,my,Na,Np,cfl,dv,sd]=VARANAL(Fdat,expi,synch,T,inp,outp)
%
%       Output arguments:
%       vx = estimated variances of the real (and also of the imaginary)
%           parts of the complex input amplitudes in x
%           The variances of mx can be obtained by vx/Na
%       vy = estimated variances of the real (and also of the imaginary)
%           parts of the complex output amplitudes in y
%           The variances of my can be obtained by vy/Na
%       cxy = estimated input/output covariances: 0.5*E{conj(nx)*ny}
%           For MIMO data, the cxy is an array: chn x chn x F
%           The covariances between mx and my can be obtained by cxy/Na
%       mx = mean value of the input amplitudes
%       my = mean value of the output amplitudes
%       Na = number of averaged experiments
%           (those not counted for which the synchronization attempt failed)
%       Np = total number of processed experiments
%       cfl = 1x2 vector, multiplicative constants to obtain lower and higher
%           bounds of 95% confidence intervals of variances in the Gaussian
%           case. For the covariances, (cfl(1)-1)*sqrt(vx(k)*vy(k)) can be used
%           as additive error bound for the real and imaginary parts.
%       dv = calculated delays of experiments, relative to the first one
%           (in 'delayed' mode only). The delays for the non-synchronizable
%           experiments will be equal to NaN.
%           The amplitude vector can be turned back to in-phase position by
%           executing   exp(j*2*pi*freqv*tau(i)).*Xi
%       sd = CR bound of the standard deviation of the estimated delay values,
%           calculated using the empirical variances vx, and the averaged input
%           amplitudes mx.
%
%       Input arguments:
%       Fdat = a Fourier vector or an (N*F)x3 array [freqvl,x,y], with the
%           frequency vector repeated N times in freqvl, or the name of the
%           Fourier file (an extension is obligatory, in order to distinguish
%           it from a function name), or a string with the name of the
%           function which produces for every call the data of an experiment.
%           If the frequency vector is repeated in an array, the smallest
%           frequency may be present only once in each repetition.
%       expi = vector of serial numbers of the experiments to be processed:
%           if i is an element of expi, and Fdat is a function name 'getfou',
%           then  [freqv,x,y]=getfou(i);  must produce the results of
%           experiment i, where the vertical sizes of all the the vectors
%           (arrays) are all F. If Fdat is a Fourier vector of the name of
%           a Fourier file, the experiments selected by expi will only be used.
%       synch = (optional) if this is given with value 'delayed', varanal
%           will try to 'synchronize' the input vectors (assuming that they
%           resulted from FFT-s of the same length), minimising the phase
%           differences by using a delay.
%       T = if synchronization is requested, [-T/2,T/2] is the interval where
%           the initial value of the deviation in time of the excitation
%           signals from each other is sought (e.g. the period length for
%           periodic signals)
%           If T is not given, it will be calculated from freqv
%       inp = (optional) number(s) of the input port(s),
%           default: all ports in the Fourier file(s)
%       outp = (optional) number(s) of the output port(s),
%             default: all ports in the Fourier file(s)
%
%       Usage:
%         [vx,vy,cxy,mx,my,Na,Np,cfl,dv,sd]=varanal(Fdat,expi,synch,T,inp,outp);
%       Examples: [fv,x,y]=impfou('bandpass(bandpass)'); Fdat=expfou(fv,x,y);
%                 [vx,vy,cxy,mx,my]=varanal(Fdat,[1:6],'delayed');
%                 [vx,vy,cxy]=varanal(Fdat,[],'delayed');
%
%       See also: TIM2FOU.

%       Algorithm of synchronization: I. Kollar, "Signal Enhancement Using
%         Non-Synchronized Measurements," IEEE Trans. Instrum. Meas., Vol. 41,
%         No. 1, pp. 156-59, Feb. 1992.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Jan-2004

if (nargin==1)&isstr(rawdata)&strcmp(rawdata,'preload')
  return %loading only for one argument 'preload'
end
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,6); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,6,ni)), %earlier
end 
fname='';
if isstr(rawdata)&(nargin>=2)
  if isempty(rawdata), error('rawdata is empty'), end
  expi=varargin{1};
  if isempty(expi)|(~iscell(expi)&~isnumeric(expi))
    error('expi is not allowed')
  end
  try
    obj1=feval(rawdata,expi(1));
    if isa(obj1,'fiddata')
      if strcmp(obj1.synchronization,'fullMIMO')
        fname=rawdata; rawdata=obj1;
      end
    end
  catch
  end
end
rawdata=getobjf(rawdata,'fiddata');
if isa(rawdata,'tiddata'), error('First argument is a tiddata object'), end
runmod=''; avinfo=[];
if isa(rawdata,'fiddata') %call with object
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,5); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,5,ni)), %earlier
  end
  if isempty(fname)
    if nargin>=4, runmod=varargin{3}; else runmod=''; end
    if nargin>=3, T=varargin{2}; else T=[]; end
    if nargin>=2, synch=varargin{1}; else synch=''; end
  else
    if nargin>=5, runmod=varargin{4}; else runmod=''; end
    if nargin>=4, T=varargin{3}; else T=[]; end
    if nargin>=3, synch=varargin{2}; else synch=''; end
  end
  if isempty(runmod), runmod=''; end
  if ~isstr(runmod), error('runmod is not a string'), end
  if ~isempty(runmod)&~strcmp(runmod,'novariance')&~strcmp(runmod,'noreduce')
    error(['runmod is invalid as ''',runmod,''''])
  end
  if isempty(synch), synch=''; end
  if ~isstr(synch), error('synch is not a string'), end
  if ~isempty(synch)&~strncmpi(synch,'delayed',3)&~strncmpi(synch,'synchronized',10)
    disp(['Warning! synch is not valid as ''',synch,'''. Allowed values: '''', ''delayed'''])
    disp('The value ''synch'' must be relaced by ''delayed'' in the future')
  end
  if ~isnumeric(T), error('Invalid T (non-numeric)'), end
  if min(size(T))>1, error('T is a 2-D array'), end
  if isempty(synch)&~isempty(T), error('synch is empty, T is not'), end
  if ~exist('expi'), expi=[]; end, inp=[]; outp=[];
  %
  if isempty(fname) %not M-file
    rdsynch=rawdata.synchronization;
    if isempty(rdsynch)
      expno=get(rawdata,'expnumber');
      grps=get(rawdata,'groups');
      sgrp=grps.Groups_Synchronized;
      if (size(sgrp,1)==1)&(length(getexpnos(rawdata,sgrp(1,:)))==expno)
        rdsynch='on';
      end
      dgrp=grps.Groups_Delayed;
      if (size(dgrp,1)==1)&(length(getexpnos(rawdata,dgrp(1,:)))==expno)
        rdsynch='delayed';
      end
    end
    if isempty(rdsynch)&isempty(groupnames(rawdata)) %no info given
      if isempty(synch)|strncmpi(synch,'delayed',3)
        %Case analyzed in varanal, execute later
      elseif strncmpi(synch,'synchronized',10)|strncmpi(synch,'all',3)
        synch='';
        %Case analyzed in varanal, execute later
      elseif strncmpi(synch,'samepower',5)
        rawdata.synchronization='samepower';
        [avdata,avinfon]=varanal(rawdata,varargin{:});
        avinfo=[avinfo,avinfon];
        return
      end
    elseif strcmp(rdsynch,'on')
      %Case analyzed in varanal, execute later
    elseif strcmpi(rdsynch,'delayed')
      if isempty(synch'), synch='delayed'; end
      %Case analyzed in varanal, execute later
    elseif strcmp(rdsynch,'samepower')
      [avdata,avinfon]=nonlinvar(rawdata); %this is nonlinear analysis, filling in nonlin properties
      avinfo=[avinfo,avinfon];
      if strcmp(runmod,'novariance')
        set(avdata,'nonlinM',[],'nonlincovariancematrix',[],'M',[],'covariancematrix',[])
        %else
        %set(avdata,'covariancematrix',avdata.nonlincovariancematrix,...
        % 'M',avdata.nonlinM,'nonlinM',[],'nonlincovariancematrix',[])
      end
      return
      %
    elseif strcmp(rdsynch,'mimo')
      error('Varanal cannot determine variances if the data are full MIMO')
    elseif isempty(rdsynch)&~isempty(groupnames(rawdata))
      %This is the case when groups are defined: recursive calls are necessary
      %
      %Synchronized experiments
      if isempty(synch)|strncmpi(synch,'Synchronized',6)|strncmpi(synch,'All',3)|...
          strncmpi(synch,'Delayed',3)|strncmpi(synch,'SamePower',5)|strncmpi(synch,'MIMO',4)|...
          strncmpi(synch,'FullMIMO',5)
        grps=get(rawdata,'Groups_Synchronized');
        while ~isempty(grps)
          exps=getexpnos(rawdata,grps{1,1});
          rawdata1=rawdata{:,exps}; rawdata1.synchronization='on';
          [avi,avinfo]=varanal(rawdata1);
          rawdata{:,exps}=avi;
          grps=get(rawdata,'Groups_Synchronized');
        end
      end
      %Delayed experiments
      if isempty(synch)|strncmpi(synch,'All',3)|...
          strncmpi(synch,'Delayed',3)|strncmpi(synch,'SamePower',5)|strncmpi(synch,'MIMO',4)|...
          strncmpi(synch,'FullMIMO',5)
        grps=get(rawdata,'Groups_Delayed');
        while ~isempty(grps)
          exps=getexpnos(rawdata,grps{1,1});
          rawdata1=rawdata{:,exps}; rawdata1.synchronization='delayed';
          [avi,avinfo]=varanal(rawdata1,'delayed',T,runmod);
          rawdata{:,exps}=avi;
          grps=get(rawdata,'Groups_Delayed');
        end
      end
      %MIMO and SamePower
      if isempty(synch)|strncmpi(synch,'All',3)|...
          strncmpi(synch,'SamePower',5)|strncmpi(synch,'MIMO',4)|...
          strncmpi(synch,'FullMIMO',5)
        grps=get(rawdata,'Groups_FullMIMO');
        if size(grps,1)>0
          avdata=rawdata;
          for ii=1:size(grps,1)
            exps=getexpnos(rawdata,grps{ii,1});
            if ii==1
              avdata=decouple(rawdata{:,exps},'nonlin');
            else
              avdata=addtova(avdata,decouple(rawdata{:,exps}),'nonlin');
            end
          end
        else
          avdata=rawdata;
          grps=get(rawdata,'Groups_SamePower');
          for ii=1:size(grps,1)
            exps=getexpnos(rawdata,grps{ii,1});
            if ii==1
              avdata=applyref(rawdata{:,exps});
              avinfo.Na=1;
              avinfo.Np=1;
              avinfo.cfl=[NaN,NaN];
              avinfo.dv=[]; avinfo.stdelay=[];
              varargout(1)={avinfo};
            else
              [avdata,avinfo]=addtova(avdata,rawdata{:,exps},'nonlin');
            end
          end %for ii
        end %fullMIMO groups
      end %isempty(sync)...
      return
    end %groupnames are defined
  else
    %fname not empty: fullmimo with string
    for ii=expi(:)'
      objii=feval(fname,ii);
      if strcmp(synch,'delayed')|strcmpi(synch,'fullMIMO')|...
          strcmpi(synch,'MIMO')|strncmpi(synch,'SamePower',5)
        if get(objii,'expnumber')==1
          objii=applyref(objii);
        else 
          objii=decouple(objii);
        end
      end
      if ii==1, avdata=[]; end
      [avdata,avinfo]=addtova(avdata,objii);
    end %for ii
    return
  end %if fname
  %
  %And now here is preparation for the earlier varanal
  cht=get(rawdata,'chtype'); [ind,tmp]=sort(-cht); [ind,reshuffle]=sort(tmp);
  expno=rawdata.expn; pn=rawdata.chn; F=rawdata.freqn;
  U=rawdata.input; Y=rawdata.output; chtype=rawdata.chtype;
  Ref=rawdata.Ref;
  if iscell(Ref)&~isempty(Ref)
    Ref=Ref(:,1);
    %for ii=size(Ref,2):-1:2, if isequal(Ref(:,1),Ref(:,ii)), Ref(:,ii)=[]; end, end
    %if length(Ref)==1; Ref=Ref{1}; end
  end
  if iscell(U)
    Uc=U; U=zeros(F,1,expno);
    for ii=1:size(Uc,2)
      U(:,1,ii)=Uc{1,ii};
    end
    clear Uc
  end
  if iscell(Y)
    Yc=Y; Y=zeros(F,1,expno);
    for ii=1:size(Yc,2)
      Y(:,1,ii)=Yc{1,ii};
    end
    clear Yc
  end
  if expno>1
    UY=cat(2,U,Y);
  else
    UY=[U,Y];
  end
  Fu=F; expnou=expno;
  Fy=F; expnoy=expno;
  chtypes=rawdata.chtypes;
  pnu=sum(chtypes==('i'+0)); pny=sum(chtypes==('o'+0));
  dvd=rawdata.delay;
  if ~isempty(dvd)
    if iscell(dvd)
      dvdsav=dvd; dvd=zeros(size(dvdsav));
      for ii=1:prod(size(dvdsav)), dvd(ii)=dvdsav{ii}; end
    end
    if any(dvd(:)~=0)
      if isnumeric(rawdata.freqpoints)
      else
        error('This case is not ready')
      end
      dmod=[];
      chno=get(rawdata,'chnumber');
      for ii=1:chno
        dmod=[dmod,reshape(exp(-j*2*pi*(rawdata.freqpoints*dvd(ii,:))),F,1,expno)];
      end
      UY=dmod(:,ones(pn,1),:).*UY;
      if ~isempty(Ref), Ref{:,1}=Ref{:,1}.*dmod(:,1); end
    end
  end
  if (pnu<=1)&(pny<=1) %SISO
    if pnu==1
      if iscell(UY), UYu=UY(:,1,:); UYu=cat(1,UYu{:}); else UYu=UY(:,1,:); end
      UYu=reshape(UYu,F*expno,1);
    else
      UYu=[];
    end
    if pny==1
      if iscell(UY), UYy=UY(:,pnu+1,:); UYy=cat(1,UYy{:}); else UYy=UY(:,pnu+1,:); end
      UYy=reshape(UYy,F*expno,1);
    else
      UYy=[];
    end
    Fdat=expfou(rawdata.freqpoints,UYu,UYy);
  else %more than one input or output ports
    if ~isempty(dvd)
      error('Correction for delays has still to be done for MIMO')
    end
    u=rawdata.input; y=rawdata.y;
    Ref=get(rawdata,'Reference');
    if ~strcmp(rdsynch,'on')&~strncmpi(synch,'delayed',3)&~isempty(Ref)
      if ~iscell(Ref), Ref={Ref}; end
      if iscell(u)
        for ii=size(u,2)
          for ic=1:size(u,1)
            u{ic,ii}=u{ic,ii}./Ref{min(ii,end)};  
          end
        end
      else %numeric
        u=u./Ref{1};
      end
      if iscell(y)
        for ii=size(y,2)
          for ic=1:size(y,1)
            y{ic,ii}=y{ic,ii}./Ref{min(ii,end)};  
          end
        end
      else %numeric
        y=y./Ref{1};
      end
    end
    v=version;
    if v(1)>='6' %Matlab 6 or later
      if iscell(u), uf=feval('cell2mat',u'); else uf=u; end
      if iscell(y), yf=feval('cell2mat',y'); else yf=y; end
    else %V5
      if iscell(u), 
        xmat=u'; xmat=cat(1,xmat{:});
        xmat=reshape(xmat,length(u{1})*size(u,2),size(u,1));
        uf=xmat; 
      else uf=u;
      end
      if iscell(y)
        xmat=y'; xmat=cat(1,xmat{:});
        xmat=reshape(xmat,length(y{1})*size(y,2),size(y,1));
        yf=xmat; 
      else yf=y;
      end
    end
    Fdat=expfou(rawdata.freqpoints,uf,yf);
    if iscell(Ref)&~isempty(Ref)
      Ref=Ref(:,1);
      for ii=1:size(Ref,1), Ref{ii,1}=ones(size(Ref{ii,1})); end
    elseif isnumeric(Ref)
      Ref=ones(size(Ref));
    end
  end
else %not fiddata: old call
  %[vx,vy,cxy,mx,my,Na,Np,cfl,dv,sd]=varanal(Fdat,expi,synch,T,inp,outp);
  if ~isempty(fname), Fdat=fname; else Fdat=rawdata; end
  if nargin>=2, expi=varargin{1}; else expi=[]; end
  if nargin>=3, synch=varargin{2}; else synch=''; end
  if nargin>=4, T=varargin{3}; else T=[]; end
  if nargin>=5, inp=varargin{4}; else inp=[]; end
  if nargin>=6, outp=varargin{5}; else outp=[]; end
  if nargin>6, error('Too many input arguments'), end
  %
end
%
if ~isempty(T), if T<0, error('T is negative'), end, end
dv=[];
phdlim=pi/2; %max. accepted value of phd; pi/2: SNR<-3dB
tau=0;
white=[];
%
c=computer; isPC=strcmp(c(1:2),'PC'); MatlV=version;
if isPC %Matlab5 under Win95 still greys out
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
if isstr(Fdat)
  [Fdat,Ffnam,ext]=fnamanal(Fdat);
  if ~isempty(ext) %Fourier file
    if strcmp(ext,'m'), error('Extension of Fdat is ''.m'''), end
    [freqv,xm,ym,expno]=impfou(Fdat,expi); F=length(freqv);
    if ~isempty(expi), expno=length(expi); end
  else %m-file
    if exist(Fdat)==0, error(['m-file ''',Fdat,''' does not exist']), end
    if isempty(expi)
      error(['Fdat=''',Fdat,''' is an m-file name: expi may not be empty'])
    end
    i=expi(1); expno=length(expi);
    %eval(['[freqv,xm,ym]=',Fdat,'(',int2str(i),');'])
    obji=feval(Fdat,i);
    if isa(obji,'fiddata')
      if obji.expn~=1
        error(['Object from ''',Fdat,''' does not contain just 1 experiment'])
      end
      freqv=obji.freqpoints; xm=obji.input; ym=obji.output;
    else
      [freqv,xm,ym]=feval(Fdat,i);
    end
    [Fx,inpx]=size(xm); [Fy,outpy]=size(ym);
    freqv0=freqv; F=length(freqv);
    if (Fx~=Fy)&~isempty(ym)
      error('Lengths of input and output amplitudes are different')
    end
    if (Fx~=F)&~isempty(xm)
      error('Length of input amplitudes differs from freqlength')
    end
  end
else %Vector or array
  if length(Fdat(1,:))==3 %array
    freqvl=Fdat(:,1); xm=Fdat(:,2); ym=Fdat(:,3);
    ind=find([freqvl;freqvl(1)]==freqvl(1));
    F=ind(2)-1; expno=length(freqvl)/F;
    freqv=freqvl(1:F);
    for i=1:expno-1
      if any(abs(freqv-freqvl(i*F+[1:F]))>100*eps)
        error(sprintf('freqvl is not periodic with length %.0f',F))
      end
    end
    if ~isempty(expi)
      if any(expi<1)|any(expi>expno), error('expi out of range'), end
      ind=zeros(F*length(expi),1);
      ii=0;
      for i=expi(:)'
        ind(ii*F+[1:F])=(i-1)*F+[1:F];
        ii=ii+1;
      end
      xm=xm(ind,:); ym=ym(ind,:);
      expno=length(expi);
    end
  elseif min(size(Fdat))>1
    error('Fdat is an illegal array')
  else %Fourier vector
    [freqv,xm,ym,expno]=impfou(Fdat,expi); F=length(freqv);
    if ~isempty(expi), expno=length(expi); end
  end
end
if isempty(expi), expi=1:expno; end
Na=0; %number of averaged experiments
Np=0; %number of processed experiments
%
[Fx,inpx]=size(xm); [Fy,outpy]=size(ym);
if isempty(outp), outp=1:outpy; end
if isempty(inp), inp=1:inpx; end
inpno=length(inp); outpno=length(outp);
freq0=freqv; F=length(freqv);
%
if inpx<max(inp)
  error(['Number of input ports insufficient in Fdat'])
end
if outpy<max(outp)
  error(['Number of output ports insufficient in Fdat'])
end
if ~isempty(inp), xm=xm(:,inp); end
if ~isempty(outp), ym=ym(:,outp); end
if strncmpi(synch,'delayed',3)
  if isempty(xm), error('cannot synchronize with empty input vector'), end
  ph0=angle(xm(1:F,:));
elseif strcmp(synch,'synchronized')
elseif isempty(synch)
else
  if isstr(synch)
    disp('The value ''synch'' of the argument synch must be relaced by ''delayed'' in the future')
    error(['Illegal value of synch: ''',synch,''', proper values: '''', ''delayed'''])
  else error('Illegal value of synch')
  end
end
fmax=max(freqv);
%
ei=0; itcdone=0;
mfileobj=-1; %M-file returns an fiddata object
for eiexp=expi(:)'
  if calldrawnow, drawnow, end
  ei=ei+1;
  if Np==0
    if isstr(Fdat)&isempty(ext), ei=1; end
    if ~isempty(xm), x1=xm((ei-1)*F+[1:F],:); else x1=[]; end
    if ~isempty(ym), y1=ym((ei-1)*F+[1:F],:); else y1=[]; end
    mx=x1; my=y1;
    [xl,xw]=size(x1); [yl,yw]=size(y1);
    vx=zeros(xl,xw); vy=zeros(yl,yw); 
    if (xw<=1)&(yw<=1) %SISO
      cxy=zeros(xl,inpno*outpno);
    else
      cxy=zeros(xw+yw,xw+yw,max([xl,yl]));
    end
    Na=1;
  else %Np>0
    if isstr(Fdat)&isempty(ext) %m-file
      %eval(['[freqv,xk,yk]=',Fdat,'(',int2str(ei),');'])
      if mfileobj
        Fobj=feval(Fdat,ei);
        if isa(Fobj,'fiddata')
          if mfileobj~=1
            cht=get(Fobj,'chtype'); [ind,tmp]=sort(-cht); [ind,reshuffle]=sort(tmp);
            mfileobj=1;
          end
          freqv=Fobj.freqpoints;
          xk=Fobj.u; yk=Fobj.y;
          pnu=get(Fobj,'inputchnumber'); pny=get(Fobj,'outputchnumber');
        else
          mfileobj=0;
          [freqv,xk,yk]=feval(Fdat,ei);
        end
      else
        [freqv,xk,yk]=feval(Fdat,ei);
      end
      if any(abs(freqv-freqv0)>100*eps)
        error('Frequency vectors differ in different experiments')
      end
      xk=xk(:,inp); yk=yk(:,outp);
    else %not m-file
      if ~isempty(xm), xk=xm((ei-1)*F+[1:F],:); else xk=[]; end
      if ~isempty(ym), yk=ym((ei-1)*F+[1:F],:); else yk=[]; end
    end
    minphd=0;
    if strncmpi(synch,'delayed',3) %make an attempt to synchronize
      if calldrawnow, drawnow, end
      if Np==1 %prepare first sychronization
        dfv=diff(sort([0;freqv]));
        ind=find(dfv==0); dfv(ind)=[]; %eliminate equal frequencies
        df=min(dfv);
        remfnegl=max(freqv)/df*eps*max(freqv);
        while any(dfv>remfnegl)
          df0=df; df=min([df0;dfv]);
          dfv=sort(rem([df0;dfv],df));
          remfnegl=max(freqv)/df*eps*max(freqv);
          ind=find(dfv<=remfnegl); dfv(ind)=[];
        end
        Tp=1/df;
        if isempty(T) %varanal has to find periodicity
          disp('WARNING! T is not given in varanal')
          Tgiven=0;
          if isfinite(Tp)
            fprintf('   varanal found: Tp = %.3g s, df = %.3g Hz,',Tp,df)
            fprintf(' harmonic numbers: %.0f...%.0f\n',...
                Tp*min(freqv),Tp*max(freqv))
            if (Tp*max(freqv)>=1e6)
              fprintf(['The elements of the frequency vector are probably'...
                ' inaccurate.\n',...
                'Give T, or correct freqv as   freqv = round(freqv*Tp)/Tp;\n'])
            end
            T=Tp; dfT=1/T; TeTp=1;
          else error('No reasonable value of T is found')
          end
        else %T is given
          Tgiven=1;
          if T>0, dfT=1/T; else dfT=inf; end
        end
        mpno=max(freqv)*T;
        mpno=max(ceil(mpno),1);
        if any(abs(rem(freqv/df+0.5,1)-0.5)-2*eps*freqv/df>...
                 1e-6*(freqv/df))
          disp(['WARNING! Not all frequency vector elements are integer',...
              ' multiples of 1/T'])
          disp('Maximum relative deviation is larger than 1e-6 in varanal')
        end
        if T*df<1-10*length(freqv)*eps
          fprintf(['WARNING! T does not cover full period length found by ',...
                'varanal:\n   T=%.4e s,  Tp=%.4e s\n'],T,Tp)
          fprintf('   The proper delay may not be found\n')
        elseif T*df>1+10*length(freqv)*eps
          fprintf(['WARNING! T is longer than period length found by ',...
                'varanal:\n   T=%.4e s,  Tp=%.4e s\n'],T,Tp)
          if T>1.2/df
            fprintf('   Search time may be unnecessarily long\n')
          end
        elseif Tgiven==1
          fprintf(['T given and Tp found by varanal: ',...
               'T=%.4e s,  Tp=%.4e s\n'],T,Tp)
        end
        freqvar=freqv*ones(1,inpno);
        fprintf('Synchronizations (%.0f experiments, %.0f delays):\n',...
                expno,expno-1)
      end %prepare first synchronization
      %
      anglerr=30; %+- angle error from grid in degrees
      phk=angle(xk); %to be compared with ph0
      if T==0, tauirv=0;
      else tauirv=-T/2+[0:T/mpno/(180/anglerr):T+10*mpno*eps];
      end
      if ~any([tauirv,1]==0), tauirv=sort([tauirv,0]); end
      %
      tauvect=zeros(length(tauirv),1);
      phdcostvect=zeros(length(tauirv),1); phdmaxvect=phdcostvect;
      tk=0;
      if calldrawnow, drawnow, end
      for tk=1:length(tauirv)
        tauir=tauirv(tk);
        %roughly scan possible delays
        %T/mpno: phase shift of 2*pi, error +-pi
        phd=phk-ph0+tauir*2*pi*freqv*ones(1,inpno);
        phd=phd-2*pi*round(phd/2/pi);
          %now phd should be around zero, it is reasonable to
          %try to fit it by a straight line through (0,0)
        maxaxk=max(max(abs(xk)));
        axk=abs(xk)/maxaxk; %normed to 1
        if calldrawnow, drawnow, end
        dtaui=-[2*pi*freqvar(:).*axk(:)]\[phd(:).*axk(:)];
        if (Tp<=T)&~isnan(Tp)
          while (tauir+dtaui<-Tp/2)&(tauir+dtaui<Tp/2) %set -Tp/2<=taui
            dtaui=dtaui+Tp;
          end
          while (tauir+dtaui>Tp/2)&(tauir+dtaui>-Tp/2) %set taui<=Tp/2
            dtaui=dtaui-Tp;
          end
        end
        phd=phd+dtaui*2*pi*freqv*ones(1,inpno);
        phd=phd-round(phd/(2*pi))*2*pi;
        phdcostvect(tk)=mean(mean((abs(phd).*axk).^2));
        phdmaxvect(tk)=max(max(abs(phd)));
        tauvect(tk)=tauir+dtaui;
      end %tauir=...
      [minphd,ind]=min(phdcostvect); tau=tauvect(ind(1));
      if phdmaxvect(ind(1))>=phdlim
        disp(sprintf(['Synchronization is not successful ',...
                 'for experiment %.0f'],eiexp))
        tau=NaN;
      else %successful
        %if T>0, taupT=tau/T; else taupT=inf; end
        if Tp>0, taupTp=tau/Tp; else taupTp=inf; end
        if isfinite(taupTp), inftau0=sprintf('tau = %+.3g*Tp',taupTp);
        else inftau0='tau = inf*Tp';
        end
        inftau=inftau0;
        while length(inftau)<17, inftau=[inftau,' ']; end
        if Np+1<10, adsp=' '; else adsp=''; end
        info0=sprintf(['exp. %.0f of %.0f, ',inftau0,' = %+.5g'],...
           eiexp,length(expi),tau);
        info=sprintf([adsp,'exp. %.0f of %.0f, ',inftau,' = %+.5g'],...
           eiexp,length(expi),tau);
        if isstr(Fdat)&~isempty(ext) %file name
          info=['File: ',Fdat,', ',info]; info0=['File: ',Fdat,', ',info0];
        else
          info=['Fourier data, ',info]; info0=['Fourier data, ',info0];
        end
        fprintf([info,'\n'])
      end
      dv=[dv;tau];
      if calldrawnow, drawnow, end
      %
      %plot axk and phase
      if ~isnan(tau)&any(diff(freqv)>eps)
        if isempty(white) %graph not yet initialized
          %Delete all axes objects in current figure
          %Use get because findobj may be missing (Matlab 4.1 or earlier)
          %delete(findobj(gcf,'Type','axes'));
          hax=get(gcf,'Children');
          if ~isempty(hax), for ih=1:length(hax)
            if strcmp(get(hax(ih),'Type'),'axes'), delete(hax(ih)), end
          end, end
          if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
          if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
          else blue='b'; red='r'; green='g';
          end
        end
        if itcdone==0 %try to put up iterctrl
          if isempty(findall(0,'type','uimenu','tag','iteration_menu'))&exist('iterctrl')
            iterctrl;
          end
          itcdone==1;
        end
        freqsh=freqvar'+fmax/200*[0:inpno-1]'*ones(1,F);
        freqsh=[0;freqsh(:);max(freqv)+df];
        axksh=maxaxk*axk'; axksh=[0;axksh(:);0];
        phd=(phk+tauvect(ind)*2*pi*freqv*ones(1,inpno)-ph0)/2/pi*360;
        phd=phd-360*round(phd/360);
        phdsh=[0;phd(:);0];
        freqsh=[freqsh(:)';freqsh(:)';freqsh(:)']; freqsh=freqsh(:);
        axksh=[0*axksh(:)';axksh(:)';0*axksh(:)']; axksh=axksh(:);
        phdsh=[0*phdsh(:)';phdsh(:)';0*phdsh(:)']; phdsh=phdsh(:);
        hold off
        subplot(2,1,1)
        plot(freqsh,axksh(:,1),['-',green]), grid off
        axv=axis;
        axv(1)=0; axv(4)=1.05*max(axksh); axis(axv);
        title('Input amplitudes')
        subplot(2,1,2)
        plot(freqsh,phdsh(:,1),['-',red]), grid off
        axv=axis; axv(1)=0;
        if isnan(tau), axl=180; else axl=max(45,1.1*max(abs(phdsh))); end
        axv(3)=min([axv(3),-axv(4),-axl]);
        axv(4)=max([axv(4),-axv(3),axl]);
        if isnan(tau)
          hold on
          plot(axv(1:2),phdlim/pi*180*[1,1],[':',white],...
              axv(1:2),phdlim/pi*180*[-1,-1],[':',white])
          hold off
        end
        axis(axv);
        title('Corrected phase differences'), ylabel('degrees')
        graphh=gca;
        txth=axes('Position',[0,0,1,1]); axis('off')
        text(0.5,0,info0,...
             'HorizontalAlignment','center','VerticalAlignment','bottom')
        axes(graphh), drawnow, figure(gcf)
      end
      %
      if calliterctrl
        if calldrawnow==1, drawnow, end
        itctrlchecked=iterctrl('checked');
        if strcmp(itctrlchecked,'Hold graph')
          disp('Last graph of varanal held by GUI')
          while strcmp(itctrlchecked,'Hold graph')
            drawnow
            itctrlchecked=iterctrl('checked');
          end %Wait
          disp('Continue...')
        end
        if strcmp(itctrlchecked,'Keyboard')
          disp('You may now enter commands within the workspace of varanal')
          disp('Modify GUI selection and type ''return'' to continue')
          keyboard
          itctrlchecked=iterctrl('checked');
        end
        if strcmp(itctrlchecked,'Abort')
          iterctrl('Continue'); error('Abort requested through GUI')
        end
      end
      %
      %phase correction:
      if ~isnan(tau)
        phcorr=exp(+sqrt(-1)*2*pi*freqv*tau);
        xk=(phcorr*ones(1,inpno)).*xk; yk=(phcorr*ones(1,outpno)).*yk;
      end
    end %synchronization
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
        disp('You may now enter commands within the workspace of varanal')
        disp('Modify GUI selection and type ''return'' to continue')
        keyboard
        itctrlchecked=iterctrl('checked');
      end
      if strcmp(itctrlchecked,'Finish')
        cycleend=1;
        itctrllastchecked='Finish'; iterctrl('Continue');
      elseif strcmp(itctrlchecked,'Cancel')
        iterctrl('Continue');
        disp('varanal run canceled through GUI')
        vx=[]; vy=[]; cxy=[]; mx=[]; my=[]; Na=[]; Np=[]; cfl=[]; dv=[]; sd=[]; %for old call
        avdata=[];
        return
      elseif strcmp(itctrlchecked,'Abort')
        iterctrl('Continue'); error('Abort requested through GUI')
      end
      isPlot=strcmp(itctrlchecked,'Plot');
    else
      isPlot=0;
    end
    %
    if ~isnan(tau) %amplitudes are synchronized
      Na=Na+1; k=Na;
      if (k==1)|any(abs(xk-mx)>abs(mx)*eps*100)
        mx=(k-1)/k*mx+(1/k)*xk;
      end
      if (k==1)|any(abs(yk-my)>abs(my)*eps*100)
        my=(k-1)/k*my+(1/k)*yk; 
      end
      vx=(k-2)/(k-1)*vx+k/(k-1)^2*(real(xk-mx).^2+imag(xk-mx).^2)/2;
      vy=(k-2)/(k-1)*vy+k/(k-1)^2*(real(yk-my).^2+imag(yk-my).^2)/2;
      if (inpno>1)|(outpno>1) %MIMO
        for in=1:inpno, cxy(in,in,:)=vx(:,in); end
        for on=1:outpno, cxy(inpno+on,inpno+on,:)=vy(:,on); end
        mxy=[mx,my]; xyk=[xk,yk];
      end
      for ii=1:inpno+outpno-1
        for iii=ii+1:inpno+outpno
          if (inpno<=1)&(outpno<=1) %SISO
            in=1; on=1;
            cxy(:,in+inpno*(on-1))=(k-2)/(k-1)*cxy(:,in+inpno*(on-1))+...
              k/(k-1)^2*conj(xk(:,in)-mx(:,in)).*(yk(:,on)-my(:,on))/2;
          else %MIMO
            cxy(ii,iii,:)=(k-2)/(k-1)*cxy(ii,iii,:)+...
              permute(k/(k-1)^2*conj(xyk(:,ii)-mxy(:,ii)).*(xyk(:,iii)-mxy(:,iii))/2,[2,3,1]);
            cxy(iii,ii,:)=conj(cxy(ii,iii,:));
          end
        end
      end
    end
  end %Np~=0
  Np=Np+1;
  if strcmp(itctrllastchecked,'Finish')
    disp('Finish of varanal requested through GUI')
    break
  end
end %for ei
%
if calldrawnow, drawnow, end
if Na>1
  if Na==2 %m=2*(Na-1)=2
    cfl(1)=2/(5/6*7.824+1/6*5.991);
    cfl(2)=2/(5/6*0.0404+1/6*0.103);
  else %approximation is acceptable
    cfl(1)=1/(1-2/(9*(2*(Na-1)))+1.96*sqrt(2/(9*(2*(Na-1)))))^3;
    cfl(2)=1/(1-2/(9*(2*(Na-1)))-1.96*sqrt(2/(9*(2*(Na-1)))))^3;
  end
else %variance cannot be calculated
  if strncmpi(synch,'delayed',3)
    disp('Warning! No averaging could be performed in varanal')
    disp('Synchronizations unsuccessful')
  else
    disp('Warning! No averaging could be performed in varanal')
    fprintf('  %.0f experiment given in Fdat',Na)
    if exist('xk')
      if size(xk,2)>1, fprintf(' for MIMO system, %.0f inputs',size(xk,2)), end
    end
    disp(' ')
  end
  vx=NaN; vy=NaN; cfl(1)=NaN; cfl(2)=NaN; cxy=NaN;
end
%
sd=NaN;
if (Na>1)&strncmpi(synch,'delayed',3)
  sd=sqrt(2/sum(sum(abs(mx.^2)./vx.*(2*pi*freqv(:,ones(1,inpno))).^2)));
  if T>0, Tmul=sd/T; else Tmul=inf; end
  fprintf([...
        'CR bound of standard deviation of delays, calculated',...
        ' from vx and mx:\n',...
        '   CRstdtau = %.3g*T = %.5g,  CRstdtau*2*max(freqv) = %.3g\n'],...
                Tmul,sd,sd*2*max(freqv))
  if Na>=2 %minimum 1 delay value
    stdtau=std(dv);
    if Na==2, cflvl=(Na-1)/(5/6*5.412+1/6*3.841);
    elseif Na==3, cflvl=(Na-1)/(5/6*7.824+1/6*5.991);
    elseif Na==4, cflvl=(Na-1)/(5/6*9.837+1/6*7.815);
    else
      cflvl=1/(1-2/(9*(Na-1))+1.96*sqrt(2/(9*(Na-1))))^3;
    end
    if (sqrt(cflvl)*stdtau<sd*sqrt(cfl(2)))&...
        (abs(mean(dv))<sqrt(cfl(2))*(3*sd+3*sd/sqrt(Na)))
        %The delay is measured with reference to a randomly chosed experiment
      fprintf(['The estimated delays are small. With this signal-to-noise ',...
        'ratio,\nthe statistical test shows no significant ',...
        'unsynchronization.\n'])
      if Na<10
        fprintf(['However, %.0f experiments are not sufficient for an ',...
                'effective test.\n'],Na)
      end
    end
  end
end
if calliterctrl&(length(findall(0,'tag','iteration_menu'))>0)
  iterctrl('Continue')
end
%
if isa(rawdata,'fiddata')|(mfileobj==1) %call with objects
  if nargout>2, error('Too many output arguments'), end
  if ~isempty(mx)&~isempty(my)
    if (Na<=2)&~strcmp(runmod,'noreduce')
      if (inpno>1)|(outpno>1) %MIMO
        warning(sprintf(['Only %.0f periods are measured.'],Na))
      else
        warning(sprintf(['Only %.0f periods are measured. ',...
            'Noise is reduced to output.'],Na))
        if isa(Fdat,'fiddata')
          excfreq=get(Fdat,'frequencies');
          freqpoints=get(Fdat,'freqpoints');
          if isempty(excfreq), indexc=[1:length(freqpoints)]'; indnonexc=[];
          else 
            indexc=ismember(freqpoints,excfreq);
            indnonexc=~ismember(freqpoints,excfreq);
          end
        else
          indexc=[1:length(mx)]'; indnonexc=[];
        end
        if all(isnan(vy))
          vy=0; vx=0; cxy=0;
        else
          vy(indexc)=(vy(indexc)+vx(indexc).*abs(my(indexc)./mx(indexc)).^2 ...
            -2*real(conj(my(indexc)./mx(indexc)).*cxy(indexc)))./abs(mx(indexc)).^2;
          if ~isempty(indnonexc)
            tfexc=my(indexc)./mx(indexc);
            tfnonexc=interp1([0;freqpoints(indexc);max(freqpoints)],[tfexc(1);tfexc;tfexc(end)],...
              freqpoints(indnonexc));
            mxexc=mx(indexc);
            mxnonexc=interp1([0;freqpoints(indexc);max(freqpoints)],[mxexc(1);mxexc;mxexc(end)],...
              freqpoints(indnonexc));
            vy(indnonexc)=(vy(indnonexc)+vx(indnonexc).*abs(tfnonoexc).^2 ...
              -2*real(conj(tfnonexc).*cxy(indexc)))./abs(mxnonexc).^2;          
          end
          vx=zeros(size(vx)); cxy=vx;
          my(indexc)=my(indexc)./mx(indexc); mx(indexc)=ones(size(mx(indexc)));
          if ~isempty(indnonexc)
            my(indnonexc)=my(indnonexc)-tfnonexc.*mx(indnonexc);
            mx(indnonexc)=zeros(size(mx(indnonexc)));
          end
        end
      end %reduce to output
    end
  end
  if (pnu<=1)&(pny<=1) %SISO
    avdata=fiddata(my,mx,freqv);
    if ~strcmp(runmod,'novariance')
      if ~any(isnan(vx))&~any(sqrt(2*vx/Na)>100*eps*abs(mx))
        vx=zeros(size(vx)); cxy=vx;
      end
      if ~isempty(vx)
        set(avdata,'outputvariance',2*vy/Na,'inputvariance',2*vx/Na,'covvect',2*cxy/Na,'noconsistency');
        if exist('Ref'), set(avdata,'Reference',Ref,'noconsistency'), end
      else
        set(avdata,'outputvariance',2*vy/Na,'noconsistency');
      end
    end
  else %MIMO
    avdata=fiddata(my,mx,freqv);
    if exist('Ref'), set(avdata,'Reference',Ref), end
    if ~strcmp(runmod,'novariance')
      set(avdata,'covariance',2*cxy([outp+in,inp],[outp+in,inp],:)/Na,'noconsistency');
    end
  end
  if ~strcmp(runmod,'novariance')
    if Np==1, set(avdata,'covariance',get(rawdata,'covariance'),'noconsistency'); end
  end
  if mfileobj==1, rawdata=Fobj; end
  set(avdata,'notes','Generated by varanal','fs',rawdata.fs,'noconsistency');
  set(avdata,'frequencies',get(rawdata,'frequencies'),'noconsistency');
  set(avdata,'periodlength',get(rawdata,'periodlength'),'noconsistency');
  set(avdata,'inputname',rawdata.inputname,'noconsistency');
  set(avdata,'outputname',rawdata.outputname,'noconsistency');
  set(avdata,'N',rawdata.N,'noconsistency');
  if get(rawdata,'inputchnumber')>0
    set(avdata,'inputcharacter',get(rawdata,'inputcharacter'),'noconsistency')
  end
  if get(rawdata,'outputchnumber')>0
    set(avdata,'outputcharacter',get(rawdata,'outputcharacter'),'noconsistency')
  end
  if ~strcmp(runmod,'novariance')
    set(avdata,'M',Na,'noconsistency')
    if (Na<4)&~strcmp(runmod,'noreduce')
      warning(sprintf(['Number of processed experiments (segments) is only %.0f, ',...
          'instead of at least 4'],Na))
    end
  end
  if exist('reshuffle')&~isequal(reshuffle,[1:length(reshuffle)]')
    %reshuffle to have the same order of channels
    avdata=avdata{reshuffle,:}; 
  end 
  if ~strcmp(runmod,'noreduce')
    get(avdata,'consistency');
  end
  %if ~isempty(dv), avdata.delay=[0;dv]; end
  if nargout>1
    avinfo.Na=Na;
    avinfo.Np=Np;
    avinfo.cfl=cfl;
    if isempty(dv), avinfo.dv=[]; avinfo.stddelay=[];
    else avinfo.dv=[0;dv]; avinfo.stddelay=sd;
    end
    varargout(1)={avinfo};
  end
else %old call
  %[vx,vy,cxy,mx,my,Na,Np,cfl,dv,sd]=VARANAL(Fdat,expi,synch,T,inp,outp)
  if nargout>=1, avdata = vx; end
  if nargout>=2, varargout(1) = {vy}; end
  if nargout>=3, varargout(2) = {cxy}; end
  if nargout>=4, varargout(3) = {mx}; end
  if nargout>=5, varargout(4) = {my}; end
  if nargout>=6, varargout(5) = {Na}; end
  if nargout>=7, varargout(6) = {Np}; end
  if nargout>=8, varargout(7) = {cfl}; end
  if nargout>=9, varargout(8) = {dv}; end
  if nargout>=10, varargout(9) = {sd}; end
  if nargout>10, error('Too many output arguments'), end
end
%%%%%%%%%%%%%%%%%%%%%%%% end of varanal %%%%%%%%%%%%%%%%%%%%%%%%
