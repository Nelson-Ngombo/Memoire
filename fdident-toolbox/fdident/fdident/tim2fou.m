function [foudata,dt]=tim2fou(timdata,varargin)
%TIM2FOU Convert time domain data to frequency domain for elis.
%
%       Input arguments:
%       timdata = time domain data object
%       fmod = modifier for the handling of the frequencies.
%          default (fmod is empty or missing): the sampling instants and freqv
%               are precisely given, and freqv/(fs/N) consists of integers,
%               that is, fft may be used
%          'leak': the sampling instants and freqv are precisely given, but
%               freqv/(fs/N) has fractional parts; instead of fft, an LS fit
%               must be performed.
%          Warning! The option 'leak' may only be used if anti-alias filters
%          were used in both data acquisition channels.
%          'segment': segment time records and analyze among these exp by exp
%          'segment-noreduce': the same for nonlinear analysis, but without 
%            reduction of noise to the output
%       scaling = definition of the calculation of the Fourier amplitudes:
%          'fft': result of the straightforward FFT of periods (default)
%          'coeff': coefficients of the Fourier series (independent of N)
%
%       Output argument:
%       foudata = frequency domain data object
%
%       Algorithm: an LS fit is performed (possibly the DFT is evaluated, by
%       using FFT), for each input and output period, in each experiment.
%       If it is possible to determine the period length, also variance
%       analysis is performed.
%       If the period length is not precisely given, use fcoeffs instead, to
%       determine the best estimate of Tp.
%
%       Usage: foudata=tim2fou(timdata,fmod,scaling);
%       Examples: load robotarm, t=robotarm_rawdata;
%                 Fdat=tim2fou(t);
%                 Fdat2=tim2fou(t(1:16000));
%
%       See also: EXPTIM.

%Old fdident help
%TIM2FOU Convert time domain data to frequency domain for elis.
%
%       [Fdat,dt]=TIM2FOU(tdat,freqv,expi,fmod)
%
%       Output arguments:
%       Fdat = frequency domain data (see expfou)
%       dt = time distance between subsequent samples in tdat
%
%       Input arguments:
%       tdat = a time vector or an (N*n)x3 array [timevl,x,y], with the time
%          vector repeated N times in timevl, or the name of the elis time file
%          (see EXPTIM; an extension is obligatory, in order to distinguish it
%          from a function name), or a string with the name of the function
%          which produces for every call the data of an experiment.
%          The sampling instants must be equidistant in each experiment.
%       freqv = frequency vector; possibly each element of freqv should be a
%          divider of fs, but the algorithm works even if this is not true.
%          If freqv is empty, all possible frequencies will be used from 0 to
%          fs/2, in fs/N grid.
%       expi = vector of serial numbers of the experiments to be processed:
%          if i is an element of expi, and tdat is a function name 'gettim',
%               [timev,x,y]=gettim(i);
%          must produce the results of experiment i, where the vertical sizes
%          of all the the vectors (arrays) are all N
%       fmod = modifier for the handling of the frequencies.
%          default (fmod is empty or missing): the sampling instants and freqv
%               are precisely given, and freqv/(fs/N) consists of integers,
%               that is, fft may be used
%          'leak': the sampling instants and freqv are precisely given, but
%               freqv/(fs/N) has fractional parts; instead fft, an LS fit must be
%               performed.
%          Warning! The option 'leak' may only be used if anti-alias filters
%          were used in both data acquisition channels.
%
%       Algorithm: an LS fit is performed (possibly the DFT is evaluated, by
%       using FFT), for each input and output period, in each experiment.
%
%       Usage: [Fdat,dt]=tim2fou(tdat,freqv,expi,fmod);
%       Example: Fdat=tim2fou([[0:63]',cos([0:63]'/64*2*pi*3)]);
%
%       See also: EXPTIM.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Aug-2003

scaling=''; Ref=[];
if isa(timdata,'tiddata')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,3,ni)), %earlier
  end
  if nargout>1, error('More than 1 output arguments in object-based call'), end
  if nargin<2, fmod=''; else fmod=varargin{1}; end
  if isempty(fmod), fmod=''; end
  if ~isstr(fmod), error('fmod is not a string'), end
  if nargin<3, scaling=''; else scaling=varargin{2}; end
  if isempty(scaling), scaling=''; end
  if ~isstr(scaling), error('scaling is not a string'), end
  groups=get(timdata,'groups');
  freqvi=timdata.inputfrequencies;
  freqvo=timdata.outputfrequencies;
  if isequal(freqvi,freqvo)
    if iscell(freqvi), freqv=freqvi{1};
    elseif ~isempty(freqvi), freqv=freqvi;
    else freqv=freqvo;
    end
  elseif isempty(freqvi)|isempty(freqvo)
    if ~isempty(freqvi), freqv=freqvi;
    else freqv=freqvo;
    end
  else
    error('Cannot handle different input and output frequency vectors yet')
  end
  %
  %Special cases
  ts=timdata.ts;
  if ~isempty(freqv), df=dfcalc([freqv(:)]); else df=[]; end
  Tp=timdata.periodlength;
  if isempty(Tp)&~isempty(df), Tp=1/df; elseif ~isempty(Tp)&isempty(df) df=1/Tp; end
  if isempty(Tp)
    if timdata.samplenumber>=288+8
      try
        foudata=fcoeffs(timdata); 
        set(foudata,'fs',1/ts);
        return
      catch
      end
    end
  else %Tp given
    Np=Tp/ts; N=get(timdata,'samplenumber');
    while (abs(rem(Np+0.5,1)-0.5)>N*10*eps)&(Np<N)
      Np=Np+Tp/ts;
    end
    M=N/Np;
    if rem(Np,1)==0
      if M>=2
        if strncmp(fmod,'segment',7)|(timdata.expnumber==1)
          sp=get(timdata,'Groups_SamePower');
          disptime=clock;
          for ii=1:timdata.expnumber
            if any(findstr(fmod,'noreduce')), runmod='noreduce'; else runmod=''; end
            fdii=varanal(tim2fou(segment(timdata{:,ii})),'',[],runmod);
            if ii==1
              foudata=fdii;
            else
              if ~strcmp(runmod,'noreduce')
                foudata=merge(foudata,fdii);
              else
                M=get(foudata,'M');
                covii=fdii.covariancematrix; fdii.covariancematrix=[];
                cov=foudata.covariancematrix; foudata.covariancematrix=[];
                foudata=merge(foudata,fdii);
                if ~iscell(cov), cov={cov}; end, if ~iscell(covii), covii={covii}; end
                cov=[cov,covii];
                set(foudata,'covariancematrix',cov,'M',M,'noconsistency')
              end
            end
            if etime(clock,disptime)>1
              fprintf('Experiment %.0f of %.0f has been converted to frequency domain\n',ii,timdata.expnumber)
              ds=dbstack;
              if (length(ds)>3)&any(findstr('gettime',ds(3).name))
                try
                  fdtool('callback','gettime','status',...
                    sprintf('Experiment %.0f of %.0f has been converted ...',ii,timdata.expnumber))
                    drawnow
                catch, end
              end
              disptime=clock;
            end
          end %for ii
          if (size(sp,1)==1)&(length(getexpnos(timdata,sp))==get(timdata,'expnumber'))
            addgroup(foudata,'Groups_SamePower',sp{:})
          end
          return
        end
      end
    elseif (N>=2*Np+288)
      if strncmp(fmod,'segment',7)|(timdata.expnumber==1)
        for ii=1:timdata.expnumber
          fdii=fcoeffs(timdata{:,ii},Tp);
          if ii==1, foudata=fdii; else foudata=merge(foudata,fdii); end
        end %for ii
        return
      end
    end
  end
  %
  u=timdata.input; y=timdata.output; expno=timdata.expn; Ref=timdata.Reference;
  if ~isempty(y)
    if ~iscell(y), y={y}; end
    yl=size(y{1},1); pny=size(y,1);
  else
    yl=0; pny=0;
  end
  if ~isempty(u)
    if ~iscell(u), u={u}; end
    ul=size(u{1},1); pnu=size(u,1);
  else
    pnu=0;
  end
  if ~isempty(Ref)
    if ~iscell(Ref), Ref={Ref}; end
    Refl=size(Ref{1},1); pnRef=size(Ref,1);
  else
    pnRef=0;
  end
  %data=[y;u];
  if (pnu<=1)&(pny<=1) %SISO
    tdat=timdata;
  else %more than one input or output ports
    %warning('Not yet ready')
    ut=zeros(ul*expno,pnu);
    for ii=1:pnu
      for iii=1:expno
        ut((iii-1)*ul+[1:ul],ii)=u{ii,iii}; 
      end
    end
    yt=zeros(yl*expno,pny);
    for ii=1:pny
      for iii=1:expno
        yt((iii-1)*yl+[1:yl],ii)=y{ii,iii}; 
      end
    end
    places=timdata.samplinginstants;
    if isempty(places)
      dt=timdata.ts;
      places=[0:timdata.samplen-1]'*dt;
    end
    tdat=exptim(places,ut,yt);
  end
  if nargin>1, fmod=varargin{1}; end
  inputvar=timdata.inputvariance; %variance given in time domain object
  outputvar=timdata.outputvariance; %variance given in time domain object
  %I/O covariance may not be given
else %old call
  %[Fdat,dt]=tim2fou(tdat,freqv,expi,fmod);
  tdat=timdata;
  if nargin>=2, freqv=varargin{1}; else freqv=[]; end
  if nargin>=3, expi=varargin{2}; else expi=[]; end
  if nargin>=4, fmod=varargin{3}; else fmod=''; end
end
if isempty(scaling), scaling='fft';
elseif strncmp(scaling,'fft',3)|strncmp(scaling,'coeff',5)
else
  if ~isstr(scaling), error('scaling is not a string'), end
  error(['scaling is not allowed: ''',scaling,''''])
end
%
%Internal part follows
if ~isstr(fmod), error('fmod is not a string'), end
if ~isempty(fmod)&~strcmp(fmod,'leak')
  error(['fmod = ''',fmod,''' is not allowed'])
end
if strcmp(fmod,'leak')
  %error('Sorry, fmod = ''leak'' is not yet implemented')
end
if isstr(tdat)
  [tdat,tfnam,ext]=fnamanal(tdat);
  if ~isempty(ext) %elis time file
    if strcmp(ext,'m'), error('Extension of tdat is ''.m'''), end
    [timevect,xtim,ytim,expno]=imptim(tdat); N=length(timevect);
  else %m-file
    if exist(tdat)==0, error(['m-file ''',tdat,''' does not exist']), end
    if isempty(expi)
      error(['tdat=''',tdat,''' is an m-file, expi may not be empty'])
    end
    expno=length(expi);
    i=expi(1);
    [timevect,xtim,ytim]=feval(tdat,i);
    [nx,inpx]=size(xtim); [ny,outpy]=size(ytim);
    N=length(timevect);
    if (nx~=ny)&~isempty(ytim)
      error('Lengths of input and output vectors are different')
    end
    if (nx~=N)&~isempty(xtim)
      error('Length of input vectors differs from timelength')
    end
    if any(imag(xtim(:))~=0)|any(imag(ytim(:))~=0)
      error(sprintf(['Complex element(s) in output of ',tdat,'(%.0f)'],i))
    end
    expi(1)=[];
    for i=expi(:)'
      [tv,xt,yt]=feval(tdat,i);
      [nx2,inpx2]=size(xt); [ny2,outpy2]=size(yt);
      n2=length(timevect);
      if (nx2~=nx)|(inpx2~=inpx)|(ny2~=ny)|(outpy2~=outpy)|(n2~=N)
        error(sprintf([tdat,'(%.0f) and ',tdat,'(%.0f) produce different',...
                ' vector sizes'],i,1))
      end
      if any(imag(xt)~=0)|any(imag(yt)~=0)
        error(sprintf(['Complex element(s) in output of ',tdat,'(%.0f)'],i))
      end
      xtim=[xtim;xt]; ytim=[ytim;yt];
    end %for i
  end %m-file
else %tdat object, vector or array
  if isa(tdat,'tiddata')
    timevect=tdat.samplinginstants;
    if isempty(timevect)
       timevect=[1:tdat.samplen]'*tdat.ts;
    end
    xtim=tdat.input; ytim=tdat.output; Reftim=tdat.referencedata;
    if iscell(xtim)
       xtimsav=xtim;
       %xtim=kron(ones(size(xtimsav,2),1),xtimsav{1});
       xtim=xtimsav{1};
       for ii=2:size(xtimsav,2)
          xtim=[xtim;xtimsav{ii}];
       end
    end
    if iscell(ytim)
       ytimsav=ytim; ytim=ytimsav{1};
       for ii=2:size(ytimsav,2)
          ytim=[ytim;ytimsav{ii}];
       end
    end
    if iscell(Reftim)
      if ~isempty(Reftim)
        Reftimsav=Reftim; Reftim=Reftimsav{1};
        for ii=2:size(Reftimsav,2)
          Reftim=[Reftim;Reftimsav{ii}];
        end
      else
        Reftim=[];
      end
    end
  else %~iddat
    if (length(tdat(1,:))==3)|(length(tdat(1,:))==2) %array
      timevl=tdat(:,1); xtim=tdat(:,2);
      if length(tdat(1,:))==3, ytim=tdat(:,3); else ytim=[]; end
      ind=find([timevl;timevl(1)]==timevl(1));
      N=ind(2)-1; expno=length(timevl)/N;
      timevect=timevl(1:N);
      for i=1:expno-1
        if any(abs(timevect-timevl(i*N+[1:N]))>100*eps)
          error(sprintf('timevl is not periodic with length %.0f',N))
        end
      end %for i
     elseif min(size(tdat))>1
       error('tdat is an illegal array')
     else %time vector or object
        [timevect,xtim,ytim,expno]=imptim(tdat);
     end
  end
end
if any( max(abs(diff(diff(timevect)))) > max(timevect)*eps*length(timevect) )
  error('Samples are not equidistant')
end
N=length(timevect);
if N==1
  error('Length of time vector is 1, transformation makes no sense')
end
if strncmp(scaling,'coeff',5), sc=N; else sc=1; end
[xl,inp]=size(xtim); [yl,outp]=size(ytim);
if ~exist('Reftim'), Reftim=[]; end, [Rl,inp2]=size(Reftim);
dt=mean(diff(timevect)); fs=1/dt;
df=fs/N;
%
freqv=freqv(:); %column vector
fftgrid=[0:N/2-1]'/N*fs;
if isempty(freqv), freqv=fftgrid; end
F=length(freqv);
if strcmp(fmod,'leak') %LS fit to avoid leakage
  freqvn0=freqv; if freqv(1)==0, freqvn0(1)=[]; end
  Fn0=length(freqvn0);
  U=[cos(timevect*2*pi*freqvn0'),sin(timevect*2*pi*freqvn0')]/N; %regr matrix
  U=[U,ones(N,1)/N]; %add dc component
end
if any(diff([-1;freqv]))<=0
  error('freqv is not monotonously increasing')
end
fv=freqv;
if max(freqv)>(1+eps)*fs/2
  error('Maximum of freqv is larger than fs/2')
end
%
x=zeros(F*expno,inp)+j; y=zeros(F*expno,outp)+j;
freqdev=rem(freqv+df/2,df)-df/2;
if all(abs(freqdev)<N*eps*max(freqv)) %freqs on the fft grid
  if strcmp(fmod,'leak')
    disp(['Warning! fmod=''leak'', but frequencies are all on the fft grid '...
        'in tim2fou'])
  end
  freqi=round(freqv/df)+1;
  for i=1:inp
    for ie=0:expno-1
      if iscell(xtim), xe=1/sc*fft(xtim{:,i});
      else xe=1/sc*fft(xtim(ie*N+[1:N],i));
      end
      x(ie*F+[1:F],i)=xe(freqi);
    end %for ie
  end
  for i=1:outp
    for ie=0:expno-1
      if iscell(ytim), ye=1/sc*fft(ytim{:,i});
      else ye=1/sc*fft(ytim(ie*N+[1:N],i));
      end
      y(ie*F+[1:F],i)=ye(freqi);
    end %for ie
  end
  fRef=cell(size(Ref));
  if ~isempty(Ref)
    for ii=1:size(Ref,1)
      for ie=1:expno
        fRefie=1/sc*fft(Ref{:,min(ie,end)});
        fRef{ii,ie}=fRefie(freqi);
      end %for ie
    end %for ii
  end
else %not fft grid
  disp('Calculating least squares fit in tim2fou...')
  if isempty(fmod)
    [mfd,ind]=max(abs(freqdev));
    if freqv(ind(1))==0
      fprintf('Maximum deviation from fft grid is %.3g*df\n',mfd/df)
    else
      fprintf(['Maximum deviation from fft grid is %.3g*df, ',...
        'relative error: %.3g\n'],mfd/df,mfd/freqv(ind(1)))
    end
    error('Frequencies are not fft points, set fmod=''leak'' to avoid leakage')
  end %if isempty(fmod)
  %
  QR=0;
  for i=1:inp
    for ie=0:expno-1
      if ~QR
        xer=U\xtim(ie*N+[1:N],i);
      else
        %A*xx=b
        A=U; b=xtim(ie*N+[1:N],i);
        if ~exist('R'), R=qr(A,0); end
        xx = R\(R'\(A'*b))
        r = b - A*xx
        e = R\(R'\(A'*r))
        xx = xx + e;
        xer=xx;
      end
      xe=xer(1:Fn0)/2-j*xer(Fn0+1:2*Fn0)/2;
      if freqv(1)==0, xe=[xer(2*Fn0+1);xe]; end
      x(ie*F+[1:F],i)=xe;
    end
  end
  for i=1:outp
    for ie=0:expno-1
      if ~QR
        yer=U\ytim(ie*N+[1:N],i);
      else
        %A*xx=b
        A=U; b=ytim(ie*N+[1:N],i);
        if ~exist('R'), R=qr(A,0); end
        xx = R\(R'\(A'*b))
        r = b - A*xx
        e = R\(R'\(A'*r))
        xx = xx + e;
        yer=xx;
      end
      ye=yer(1:Fn0)/2-j*yer(Fn0+1:2*Fn0)/2;
      if freqv(1)==0, ye=[yer(2*Fn0+1);ye]; end
      y(ie*F+[1:F],i)=ye;
    end
  end
  %fRef=cell(size(Ref));
  fRef=[];
  if ~isempty(Ref)
    warning('Conversion of Reference not yet implemented for ''leak''')  
  end
end
%
if isa(timdata,'tiddata') %make fiddata
  if nargout>1, error('Too many output arguments'), end
  F=length(fv);
  if ~isempty(x), x=reshape(x,F,expno,pnu); end
  if ~isempty(y), y=reshape(y,F,expno,pny); end
  %if expno>1
  if ~isempty(x), x=permute(num2cell(x,[1]),[3,2,1]); end
  if ~isempty(y), y=permute(num2cell(y,[1]),[3,2,1]); end
  %else
  % if ~isempty(x), x=permute(num2cell(x,[1]),[2,3,1]); end
  %if ~isempty(y), y=permute(num2cell(y,[1]),[2,3,1]); end
  %end
  foudata=fiddata(y,x,fv);
  if get(timdata,'inputchnumber')>0
    set(foudata,'inputcharacter',get(timdata,'inputcharacter'),'noconsistency')
  end
  if get(timdata,'outputchnumber')>0
    set(foudata,'outputcharacter',get(timdata,'outputcharacter'),'noconsistency')
  end
  valall=timdata.tstart; chtypes=timdata.chtypes;
  if ~isempty(valall)
    %if isnumeric(valall), valall=-valall;
    %else for ii=1:length(valall(:)), valall{ii}=-valall{ii}; end
    %end
    if size(valall,1)>1, val=valall(find(chtypes==['o'+0]),:);
    else val=valall;
    end
  else val=[];
  end
  if ~isempty(val)&(get(timdata,'outputchnumber')>0)
    set(foudata,'outputdelay',val,'noconsistency')
  end
  if ~isempty(valall)
    if size(valall,1)>1, val=valall(find(chtypes==['i'+0]));
    else val=valall;
    end
  else val=[];
  end
  if ~isempty(val)&(get(timdata,'inputchnumber')>0)
    set(foudata,'inputdelay',val,'noconsistency')
  end
  val=timdata.outputname;
  if ~isempty(val), set(foudata,'outputname',val,'noconsistency'), end
  val=timdata.inputname;
  if ~isempty(val), set(foudata,'inputname',val,'noconsistency'), end
  if ~isempty(timdata.state), set(foudata,'state',timdata.state,'noconsistency'); end
  set(foudata,'synchroniz',timdata.synchroniz,'noconsistency');
  if ~isempty(timdata.ts), set(foudata,'fs',1/timdata.ts,'noconsistency'); end
  if ~isempty(outputvar)
    if ~iscell(outputvar), outputvar={outputvar}; end
    for ii=1:length(outputvar)
      outputvar{ii}=outputvar{ii}*N/sc^2*ones(F,1);
    end
    if length(outputvar)==1, outputvar=outputvar{1}; end
    set(foudata,'outputvar',outputvar,'noconsistency');
  end
  if ~isempty(inputvar)
    if ~iscell(inputvar), inputvar={inputvar}; end
    for ii=1:length(inputvar)
      inputvar{ii}=inputvar{ii}*N/sc^2*ones(F,1);
    end
    if length(inputvar)==1, inputvar=inputvar{1}; end
    set(foudata,'inputvar',inputvar,'noconsistency');
  end
  Ns=get(timdata,'samplenumber');
  set(foudata,'N',Ns);
  if length(fRef)==1, fRef=fRef{1}; end
  if ~isempty(fRef), set(foudata,'Reference',fRef,'noconsistency'), end
  set(foudata,'groups',groups,'noconsistency')
  get(foudata,'consistency');
else
  foudata=expfou(fv,x,y);
end
%
%%%%%%%%%%%%%%%%%%%%%%%% end of tim2fou %%%%%%%%%%%%%%%%%%%%%%%%
