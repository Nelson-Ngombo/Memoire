function varargout=fcoeffs(varargin)
%FCOEFFS Estimation of the period length and the Fourier coefficients of a noisy signal
%
%       There are two calling forms: toolbox-embedded, using a tiddata object, 
%       and general, using data arrays.
%       Calling form 1:
%       [Fdat,msg,Np]=FCOEFFS(tdat,Tp,sol);
%       Calling form 2:
%       [Xe,Xvar,fvect,Np,M]=FCOEFFS(x,fs,Tp,mode);
%
%       Calling form 1: the first input argument is a tiddata object
%         Output arguments:
%           Fdat = fiddata object
%           msg = warning message (if any)
%           Np = Number of samples in a period
%         Input arguments:
%           tdat = tiddata object
%           Tp = known period length (usually not given)
%           sol = 'sign-of-life' command, executed periodically to show process
%             e.g. sol.command='gettime'; sol.string='Time: %.2f';
%           If both tdat.frequencies and Tp are given, only the amplitudes 
%             at the given frequencies will be returned.
%         Examples: load robotarm, t=robotarm_rawdata;
%                 Fdat=fcoeffs(t);
%                 Fdat2=fcoeffs(t(1:16000),t.periodlength);
%
%       Calling form 2: the first input argument is a numerical array
%         Output arguments:
%           Xe = estimated complex Fourier coefficients of the periodic part
%              (vector or NFx2 array):
%               x(t) = sum( 2*real(Xe(i))*cos(2*pi*fe(i)*t)
%                         + 2*imag(Xe(i))*sin(2*pi*fe(i)*t) )
%           Xvar = variances of Xe and covariances: 
%                  [var(Xe(:,1) var(Xe(:,2), E{conj(Xe(:,1))*Xe(:,2)}]
%           fvect = vector of the frequencies
%           Np = period length in samples
%           M = number of periods processed
%         Input arguments:
%           x = measured time series, or an Nx2 array with input and output signals
%               the first signal x(:,1) is used to estimate the period
%           fs = sampling frequency
%           Tp = known period length (usually not given)
%           mode = generate array Xvar (default), or covariance array (cxcxF),
%                  for 'cov'
%       Example: load robotarm, t=robotarm_rawdata;
%                 Fdat=fcoeffs(t);
%                 Fdat2=fcoeffs(t(1:16000),t.periodlength);
%
%       Conditions of proper working:
%         Preferably at least 4 periods + 288 samples need to be measured
%         Minimum length (without error message): 2 periods + 288 samples
%         The function returns reliable results in freq. band [df,0.4*fs]
%         Coherent sampling (integer number of periods) is not neccessary

%       Algorithm: J. Schoukens, Y. Rolain, G. Simon, and R. Pintelon, 
%       "Fully automated spectral analysis of periodic signals," 
%       IEEE Instrumentation and Measurement Technology Conference, Anchorage, 
%       AK, USA, May 21-23, 2002.
%
%       See also: TIM2FOU

%       Algorithm written by J. Schoukens

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Sep-2002

global johanplot %Plots for Johan
if ~exist('johanplot'), johanplot=''; end
if isempty(johanplot), johanplot=0; end
%
global phasefit %fit phases instead if looking for minimum sidelobes
if ~exist('phasefit'), phasefit=''; end
if isempty(phasefit), phasefit=0; end
%
persistent clock0
clock0=clock; cycle=0;
persistent sol
if ~exist('sol'), sol=''; end
%tic; %***
%
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,4); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,4,ni)), %earlier
end
tdat=varargin{1}; Tp=[]; mode='';
if ischar(tdat), tdat=fdident('private','getobjf',tdat,'tiddata'); end
if isa(tdat,'tiddata')
  newcall=1; msg='';
  if tdat.samplenumber<290
    error('At least 2*Np+288 samples should have been provided')
  end
  if nargin>=3, sol=varargin{3}; end
  if nargin>=2, Tp=varargin{2}; end
  if tdat.inputchnumber==0, error('There is no input channel'), end
  if ((tdat.inputchnumber==1)&(tdat.outputchnumber<=1)) %standard call, I1 or I1/O1
    x=[tdat.input,tdat.output];
    fs=1/tdat.ts;
    [Xe,Xvar,fvect,Np,M]=fcoeffs(x,fs,Tp);
    if ~isempty(tdat.frequencies)
      fvt=tdat.frequencies; ind=zeros(size(fvt));
      for ii=1:length(fvt)
        [dummy,iii]=min(abs(fvt(ii)-fvect));
        ind(ii)=iii;
      end
      ind=sort(ind); di=diff(ind);
      i0=find(di==0);
      if ~isempty(i0), ind(i0)=[]; end
      if length(ind)<length(fvect)
        fvect=fvect(ind);
        Xe=Xe(ind,:);
        Xvar=Xvar(ind,:);
      end
    end
    Nx=length(x);
    if Nx>=2*Np+288 %OK or almost OK
      Y=[]; vx=[]; vy=[]; cuy=[];
      if ~isempty(Xvar), vx=Xvar(:,1); end
      if size(Xe,2)==2
        Y=Xe(:,2);
        if size(Xvar,2)>=3, vy=Xvar(:,2); cuy=Xvar(:,3); end
      end
      if (M>=3)|(size(Xe,2)==1) %Y and U can be returned or input only case
        Fdat=fiddata(Y,Xe(:,1),fvect,vy,vx,cuy,tdat.outputname,...
          tdat.inputname,tdat.outputunit,tdat.inputunit);
        Fdat.M=M; %floor((Nx-288)/Np);
        Fdat.N=Np;
        if M==3
          msg=['Warning: only 3 periods can be extracted from signal - we need ',...
              '4 for proper identification']; 
        end
      else
        tf=Y./Xe(:,1);
        Fdat=fiddata(Y,Xe(:,1),fvect,vy+vx.*abs(tf).^2-2*real(cuy.*conj(tf)),...
          zeros(size(Y)),zeros(size(Y)),...
          tdat.outputname,tdat.inputname,tdat.outputunit,tdat.inputunit);
        Fdat.M=M;
        msg=sprintf(['Warning: only %.0f periods instead of 4 can be extracted from signal: noise ',...
            'is reduced to output'],M); 
      end
      Fdat.state=tdat.state;
    else
      error('Cannot extract at least two periods from signal')
    end
  else %MIMO
    u=tdat.input; if isempty(u), u=tdat.output; end
    fs=1/tdat.ts;
    if isnumeric(u), u={u}; end
    if isempty(Tp) %Determine Tp from input records
      Tpv=[];
      for ii=1:size(u,1)
        uii=u{ii,1};
        [Xe,Xvar,fvect,Np,M]=fcoeffs(uii,fs);
        Tpv(ii,1)=Np/fs;
      end %for ii
      if length(Tpv)>1
        w=round(max(Tpv)./Tpv);
        Tp=sum(Tpv)./sum(w)*max(w); %longest Tp
        Tptd=tdat.periodlength;
        if isempty(Tptd), tdatTpincomp=0;
        else tdatTpincomp=(abs(rem(Tp/Tptd+0.5,1)-0.5)>1e-2);
        end
        if any(abs(rem(Tpv/(Tp/max(w))+0.5,1)-0.5)>1e-2)|tdatTpincomp
          Tp_tdat=Tptd, Tpv
          error('Period lengths in different channels are not compatible')
        end
      end
    end %isempty(Tp)
    x=tdat.data;
    for ii=1:size(x,2) %by experiments
      v=version;
      if v(1)>='6'
        [Xe,Xvar,fvect,Np,M]=fcoeffs(feval('cell2mat',x(:,ii).'),fs,Tp,'cov');
      else
        xmat=x(:,ii); xmat=cat(1,xmat{:}); 
        xmat=reshape(xmat,length(x{1}),size(x,1));
        [Xe,Xvar,fvect,Np,M]=fcoeffs(xmat,fs,Tp,'cov');        
      end
      %if iscell(Xvar), Xvar=Xvar{1}; end
      if ~isempty(tdat.frequencies)
        fvt=tdat.frequencies; 
        if iscell(fvt), error('Cannot handle different frequencies in different channels as yet'), end
        ind=zeros(size(fvt));
        for ii=1:length(fvt)
          [dummy,iii]=min(abs(fvt(ii)-fvect));
          ind(ii)=iii;
        end
        ind=sort(ind); di=diff(ind);
        i0=find(di==0); if ~isempty(i0), ind(i0)=[]; end
        if length(ind)<length(fvect)
          fvect=fvect(ind); Xe=Xe(ind,:); Xvar=Xvar(:,:,ind);
        end
      end
    end
    Nx=tdat.samplenumber;
    if Nx>=2*Np+288 %OK or almost OK
      Fdat=fiddata(Xe,[],fvect);
      Fdat.chtypes=tdat.chtypes;
      set(Fdat,'covariance',Xvar,'M',M,'outputname',tdat.outputname,...
        'inputname',tdat.inputname,...
        'outputunit',tdat.outputunit,'inputunit',tdat.inputunit,'noconsistency');
      if M<=3
        msg=sprintf(['Warning: only %.0f periods can be extracted from signal - ',...
            'at least 4 periods are needed\n  for proper identification'],M); 
      end
    else
      error('Cannot extract at least two periods from signal')
    end
  end
  %
  if ~isempty(tdat.outputcharacter)
    set(Fdat,'outputcharacter',tdat.outputcharacter)
  end
  set(Fdat,'inputcharacter',tdat.inputcharacter)
  addhist(Fdat,'Processed by fcoeffs.')
  varargout{1}=Fdat;
  varargout{2}=msg;
  varargout{3}=Np;
  %toc/60 %***
  return %Done for objects
end
%
%old call admin
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,4); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,4,ni)), %earlier
end
newcall=0;
x=varargin{1};
if size(x,1)==1, x=x(:); 
elseif any(size(x,1)==[2,3]), x=x';
end
if any(imag(x)), error('x is complex'), end
if size(x,1)<290, error('At least 2*p+288 samples should have been provided'), end
fs=varargin{2};
if nargin>=3, Tp=varargin{3}; end
if nargin>=4, mode=varargin{4}; end

% FCOEFFS UNTOUCHED FROM HERE, EXCEPT FOR SETTING OF VARARGOUT
% New names:
%  PeriodEstimate -> fcoeffs
%  Zm -> Xe
%  Zcov -> Xvar
%  F -> fvect
%  T -> Np
%  z -> x
%  Fs -> fs
%  internal: x -> xi
%%%%%%%%%% END OF NEW HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% settings of the algorithm
Bmax=0.4;   % max allowed bandwidth with respect to fs
US=6;       % upsample factor, set to get errors below -100 dB

v=version;
if v(1)=='5'
  InterPolMethod='cubic';       % '*spline' or '*cubic'
else
  InterPolMethod='v5cubic';   % '*spline' or '*cubic'
end

xi=x(:,1);
L=size(xi,1);                   % length of the available data record

% find first rough estimate
if isempty(Tp)
  Nper=SearchInitVal(xi);         % initial estimate of the period
else %Tp given
  Nper=Tp*fs;
end

if johanplot
  display('Initial estimate of the period'),Nper
end

% upsampling the signal for the fine search
[xUS,tUS,Ntrans]=upsample(xi,US);        % upsampling the signal
								% scan width in the next step

if isempty(Tp)
  ConvergenceCheck=-1;
else %Tp given
  ConvergenceCheck=0; NperNew=Nper;
end

while ConvergenceCheck~=0
  % scan until minimum not on the border of search interval                              
  Scantype='coarse';
  [NperNew,ConvergenceCheck]=ScanSearch(xUS,tUS,Nper,Scantype,Bmax,US);
  Nper=round(NperNew+ConvergenceCheck*8.5);
  if ~isempty(sol)
    if isstruct(sol)&strcmp(sol.command,'gettime')
      cycle=cycle+1;
      tptxt=sprintf(', testpoint %.0f',cycle);
      tptxt=''; %no test point message
      fdtool('callback','gettime','status',sprintf([sol.string,tptxt],etime(clock,clock0)/60));
    end
    %try, eval(sol), catch, sol=''; warning('sol is erroneous'), end
  end
end

if isempty(Tp)
  Scantype='fine';
  [NperNew]=ScanSearch(xUS,tUS,round(NperNew),Scantype,Bmax,US);
  if ~isempty(sol)
    if isstruct(sol)&strcmp(sol.command,'gettime')
      cycle=cycle+1;
      tptxt=sprintf(', testpoint %.0f',cycle);
      tptxt=''; %no test point message
      fdtool('callback','gettime','status',sprintf([sol.string,tptxt],etime(clock,clock0)/60));
    end
  end
  M=floor((length(xUS)-3)/NperNew/US);
else %Tp given
  Npc=Tp*fs;
  M=floor(L/Npc*(1+1000*eps));
end

if isempty(Tp)
  % final search around min found value
  Tmin=[NperNew-1/M,NperNew,NperNew+1/M];  % one sample up and down in full record
  %[Tminmin,Sminmin]=FastSearchMin3(xUS,tUS,1,Tmin,[],Tmin(2)/1e11,M,'fine')
  % fine tuning on the full data set
  IntPolErr=1;
  while IntPolErr==1                                        
    % fine tuning on the full data set
    [Tminmin,Sminmin, IntPolErr]=...
      FastSearchMin3(xUS,tUS,US,M*Tmin,[],Tmin(2)/1e11,M,'fine');
    if IntPolErr==1         % interpolation failed
      if M>2
        M=M-1;          % reduce number of periods
        if johanplot
          fprintf('New trial with %.3g periods\n',M)
        end
      else
        error('Not enough periods in data record')
        return
      end
    end 
  end
else %Tp given
  IntPolErr=0;
  Tminmin=Tp*fs*M; %usable record length in samples
end
%Tminmin: record to be processed in samples

if ~isempty(sol)
  if isstruct(sol)&strcmp(sol.command,'gettime')
    cycle=cycle+1;
    tptxt=sprintf(', testpoint %.0f',cycle);
    tptxt=''; %no test point message
    fdtool('callback','gettime','status',sprintf([sol.string,tptxt],etime(clock,clock0)/60));
  end
end

Np=Tminmin/M;
if abs(rem(Np+0.5,1)-0.5)<1000*eps
  Np=round(Np); Tminmin=Np*M;
end
%
% show final spectrum  + noise std
%

% 1) calculate the final spectrum over the full record and plot it
Mfinal=floor((length(xi)-Ntrans/US)/Np);		% number of periods in the signal
Tall=Mfinal*Np;    % total length of the Mfinal periods
OverSampleFFT=6;   % in order to keep small disturbances in the interpolation step
NFFTFinal=2^(ceil(log2(Np*OverSampleFFT)));	% number of points in fft
NallFFTFinal=NFFTFinal*Mfinal;
tAllInterp=Tall*[0:NallFFTFinal-1]/NallFFTFinal;	% interpolation time vector

Y=[]; ismimo=0;
for k=1:size(x,2)            % loop over the signals, calculate the spectra 
  [xUS,tUS,Ntrans]=upsample(x(:,k),US);     
  xinterp=interp1(tUS,xUS,tAllInterp,InterPolMethod);
  xinterp=reshape(xinterp,NFFTFinal,Mfinal);	% break in single periods
  if k==1
    X=fft(xinterp)/NFFTFinal;	% spectra per period of the first signal
  else
    if ~isempty(Y), ismimo=1; end
    Y=[Y,fft(xinterp)/NFFTFinal];	% spectra per period of the second signal
  end
end

if ~isempty(sol)
  if isstruct(sol)&strcmp(sol.command,'gettime')
      cycle=cycle+1;
      tptxt=sprintf(', testpoint %.0f',cycle);
      tptxt=''; %no test point message
      fdtool('callback','gettime','status',sprintf([sol.string,tptxt],etime(clock,clock0)/60));
  end
end

if size(x,2)==1
  Xe=mean(X,2);					     % mean value
  Xvar(:,1)=std(X,0,2).^2/Mfinal;    % variance deviation
else %at least 2 channels
  chn=size(x,2);
  Xe(:,1)=mean(X,2);
  for ii=2:chn
    Xe(:,ii)=mean(Y(:,(ii-2)*Mfinal+[1:Mfinal]),2);  
  end %for ii
  for k=1:NFFTFinal/2-1;   % variance analysis
    C=cov([X(k,:).' reshape(Y(k,:).',Mfinal,chn-1)]);
    if ~isempty(sol)&(rem(k,2000)==1)
      if isstruct(sol)&strcmp(sol.command,'gettime')
        cycle=cycle+1;
        tptxt=sprintf(', testpoint %.0f',cycle);
        tptxt=''; %no test point message
        fdtool('callback','gettime','status',sprintf([sol.string,tptxt],etime(clock,clock0)/60));
      end
    end
    if ~ismimo&~strncmp(mode,'cov',3)
      Xvar(k,1)=real(C(1,1)/Mfinal); Xvar(k,2)=real(C(2,2)/Mfinal); % complex variances
      Xvar(k,3)=C(1,2)/Mfinal;   % covariances
    else %MIMO
      if k==1, Xvar=zeros(chn,chn,NFFTFinal/2-1); end
      for ii=1:chn, C(ii,ii)=real(C(ii,ii)); end %variances
      Xvar(:,:,k)=(C+permute(conj(C),[2,1,3]))/2/Mfinal; %make sure complex conjugates in C
    end
  end %for k
end

NinUse=floor(Bmax*Np); % part of the spectrum that can be used
Xe=Xe(1:NinUse,:); fvect=[0:NinUse-1]*fs/Np;
if ~ismimo&~strncmp(mode,'cov',3)
  Xvar=Xvar(1:NinUse,:); 
else
  Xvar=Xvar(:,:,1:NinUse);
end

if johanplot
  if min(size(x))==1
    hf=figure(1);
    plot(fvect,db(Xe),'+',fvect,db(Xvar)/2,'*')
    title('final estimated spectrum')
    zoom(hf,'on'), drawnow
    legend('mean value','std dev. of the noise on the mean value')
  else
    hf=figure(1);
    subplot(2,1,1)
    plot(fvect,db(Xe(:,1)),'+',fvect,db(Xvar(:,1))/2,'*')
    title('final estimated spectrum input'),zoom(hf,'on'), drawnow
    legend('mean value','std dev. of the noise on the mean value')
    subplot(2,1,2)
    plot(fvect,db(Xe(:,2)),'+',fvect,db(Xvar(:,2))/2,'*')
    title('final estimated spectrum output'),zoom(hf,'on'), drawnow
    legend('mean value','std dev. of the noise on the mean value')
  end
end

%%%%%%%%%%%%%% SETTING OF VARARGOUT %%%%%%%%%%%%%%%
varargout{1}=Xe;
varargout{2}=Xvar;
varargout{3}=fvect;
varargout{4}=Np;
varargout{5}=M;
%%%%%%%%%%%%%% END OF SETTING OF VARARGOUT %%%%%%%%%%%%%%%

%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%

function Nper=SearchInitVal(xi)
%SEARCHINITVAL search for an initial value of the period using correlation analysis

x=(xcorr(xi));						% correlation analysis

if abs(min(x))>0.9*max(x)			% strong odd behaviour of the signal
	Nper1=PeriodEst(x);
	Nper2=PeriodEst(abs(x));
	if Nper2>0.7*Nper1				% the odd behaviour fooled the search
		Nper=2*Nper1;
	else
		Nper=Nper1;
	end
else
	Nper=PeriodEst(x);
end

%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%

function Nper=PeriodEst(x)
% extract the periodicity in x by determing the peaks distance
L=length(x)/2-1;
Nper=[];scale=1;I=1;
while length(I)<3%isempty(Nper)
  if scale>100, Nper=(length(x)+1)/2; break, end %get out of infinite cycle
  scale=scale*1.05;
  crit=max(x)/scale;						% peak selection
  I1=x>=crit;I2=x<crit;
  z1(I1)=1;z1(I2)=0;					% normalize to 0 or 1
  
  G=min(L/50,64);gauss=exp(-([-G:1:G]/G*3).^2);	% smoothing filter
  z2=conv(z1,gauss);
  
  crit=max(z2)/2;						% peak selection
  I1=z2>=crit;I2=z2<crit;
  z2(I1)=1;z2(I2)=0;					% normalize to 0 or 1
  
  z2=diff(z2);I=(find(z2==1)+find(z2==-1))/2;				% find the peak positions
  Nper=(median(diff(I)));
end


%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%

function [Tper,ConvergenceCheck]=ScanSearch(xUS,tUS,Nper,Scantype,Bmax,US)
%
% xUS: upsampled signal
% Nper: number of data points per period (previous estimate)
% Scantype: 'coarse' scan or 'fine' scan
% Bmax: maximum allowed bandwidth (fraction of fs)
% US: upsampling factor

global johanplot
if isempty(johanplot), johanplot=0; end

% set the interpolation method
v=version;
if v(1)=='5'
    InterPolMethod='cubic';		% '*spline' or '*cubic'
else
    InterPolMethod='v5cubic';		% '*spline' or '*cubic'
end



NUS=length(xUS);						% number of datapoints available

% setup type of scan
switch lower(Scantype)
case 'coarse'
  B=35;       % scan width
  M=floor((NUS/US-1-B)/Nper);	% number of periods available for processing
  MBlock=2;
case 'fine'
  Minit=floor(NUS/Nper/US);
  B=2*(Minit);       % SCAN Width
  M=floor((NUS/US-1-B)/Nper);	% number of periods available for processing
  MBlock=M;	% 1 block containing all periods
otherwise, disp('illegal choice for the Scantype')
end

if M <2
	error('Could not find two periods plus 288 samples in the record')
end
			

LBlock=(Nper*MBlock+B);					% length of a block
NBlock=floor(NUS/LBlock/US);			% number of blocks
NBlockUsed=NBlock;
xUSBlock=reshape(xUS(1:NBlock*LBlock*US),LBlock*US,NBlock);
%xUSBlock=xUS; % FORCE
										% the broken upsampled record
tUSBlock=tUS(1:LBlock*US);				% the upsampled block time vector
%tUSBlock=tUS; % FORCE

Nscan=Nper*MBlock+[-B:2:B];Nscan(Nscan<=4)=[];

for l=1:length(Nscan)	% loop over the scan
  Lscan=Nscan(l);
  LscanUS=Lscan*US;
  Nfft=2^(ceil(log2(Lscan))); % Lfft=floor(Bmax*Lscan-1);  % calc. fft on slow sampl. rate
  tinterp=[0:Nfft-1]/Nfft*Lscan;    % interpolation points
  
  if max(tinterp)>max(tUSBlock)
    disp('Pay attention: extrapolation instead of interpolation')
  end
  
  xinterp=interp1(tUSBlock,xUSBlock(:,1:NBlockUsed),tinterp,InterPolMethod);
  Y=abs(fft(xinterp));if(min(size(Y)>1)),Y=sum(Y,2)';end;Y(1)=0;
  S(l)=scostfcn(Y, Bmax, MBlock); % cost function	
end

if johanplot
  %figure(1),clf,
  plot(Nscan,db(S(1:length(Nscan))),'+-'), drawnow
  %title('first scan of the cost function')
  %figure(3)
end

% Improved estimate of the local minima
dT=0.01;			% required resolution dT s
l=0;			% counter

for k=2:length(Nscan)-1
  if and(S(k)<S(k-1),S(k)<S(k+1))		% local minimum found
    l=l+1;
    Tinit=[Nscan(k-1) Nscan(k) Nscan(k+1)];		% search interval
    Sinit=[S(k-1) S(k) S(k+1)];					% local cost			
    [Tper,Sper]=FastSearchMin3(xUSBlock,tUSBlock,US,Tinit,Sinit,dT/Nscan(k),MBlock,'coarse');
    
    Smin(l,[1 2 3])=[S(k-1) Sper S(k+1)];
    
    Tmin(l,[1 2 3])=[Nscan(k-1) Tper Nscan(k+1)];
    if johanplot
      figure(2), clf
      plot(Nscan,db(S(1:length(Nscan))),'+-b',Tmin(:,2),db(Smin(:,2)),'+r')
      drawnow
    end
  end
end
  
[SmminminInit I]=min(Smin(:,2));	
Tper=Tmin(I,2)/MBlock;

if Tmin(I,2)<Nscan(1)+length(Nscan)/3
    ConvergenceCheck=-1;            % minimum on the leftside of the border
elseif Tmin(I,2)>Nscan(end)-length(Nscan)/3
    ConvergenceCheck=1;             % minimum on the right side of the border
else
    ConvergenceCheck=0;             % minimum in the interval
end

%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%

function [Tper,Sper,IntPolErr]=FastSearchMin3(xi,t,US,Tinit,Sinit,dT,M,Searchtype);
% 
% fast search of the local minimum in the cost
% to generate starting values for the final search
%
% xi: the upsampled input signal
%       dimension (L,M): M subrecords available
%		the maximum processed bandwidth is 0.4 of 
%		the original fs (before upsampling)
% t: the corresponding time vector
% US: undersampling factor to select the points used to calculate the fft
%		This compensates the upsampling used for the interpolation to create xi
% Tinit: 
%		Np(1): the left boundary of the search interval in seconds (=\ period)
%		Np(2): the local maximum (initial value) in seconds
%		Np(3): the right boundary of the search interval in seconds
% Sinit: the corresponding cost function values
%                   we advice to leave it empty
% dT: the required accuracy of the solution
% M: the estimated number of periods
% Searchtype: 'coarse': low sampling rate in FFT's
%               'fine': high sampling rate in FFT's
%
% Johan Schoukens, VUB, 19 March 2001

global johanplot
if isempty(johanplot), johanplot=0; end

IntPolErr=0;                   % check for interpolation errors
Bmax=0.4;						% max allowed bandwidth signal Bmax*fs
v=version;
if v(1)=='5'
    InterPolMethod='cubic';		% '*spline' or '*cubic'
else
    InterPolMethod='v5cubic';		% '*spline' or '*cubic'
end
L=length(xi);					% length of the available data record
fs=(t(end)-t(1))/(L-1);			% sampling frequency

[R C]=size(xi);if R<C;xi=xi';end					% put the subsignals in the colums 

initOK=1; % the init vector is OK. It's checked only if no Sinit is empty
MAX_EXTRAPOLATE_TRIALS=3;  % the number of bins enabled to diverge from the initial set
while isempty(Sinit)|~initOK
    for k=1:length(Tinit)
        switch lower(Searchtype)        % select the sampling rate (upsampled or not)
            case 'coarse'
                Nfft=2^(ceil(log2(Tinit(k)/fs/US))); %low sample rate fft
            case 'fine'
                Nfft=2^(ceil(log2(Tinit(k)/fs)));    %high sample rate fft
        otherwise, disp('illegal choice for the Searchtype')
        end

        Lfft=floor(Bmax*Nfft-1);  % number of test lines
        tinterp=[0:Nfft-1]'/Nfft*Tinit(k);    				% interpolation points	
        
        if max(tinterp)>t(end) 
            disp('interpolation problem')
            IntPolErr=1;
            return                      % force a return and retry with M-1 periods
        end	
        
        xinterp=interp1(t,xi,tinterp,InterPolMethod);	% interpolated signal
        Y=abs(fft(xinterp));if(min(size(Y)>1)),Y=sum(Y,2);end;Y=Y(:)';Y(1)=0;
        Sinit(k)=scostfcn(Y, Bmax,M);  % cost function
    end
    if johanplot
      MAX_EXTRAPOLATE_TRIALS
    end
    
    if MAX_EXTRAPOLATE_TRIALS
        [minSinit, IXminSinit]=min(Sinit);
        if IXminSinit==1 % minimum is to the left
            initOK=0;
            dTinit=(max(Tinit)-min(Tinit))/2;
            MAX_EXTRAPOLATE_TRIALS=MAX_EXTRAPOLATE_TRIALS-1;
            if Tinit(1)-dTinit<0
                Tinit=[0, dTinit, dTinit*2];
                MAX_EXTRAPOLATE_TRIALS=0; % no more trials make sense
            else
                Tinit=[Tinit(1)-dTinit, Tinit(1), Tinit(1)+dTinit];
            end
        elseif IXminSinit==3 % minimum is to the right
            initOK=0;
            dTinit=(max(Tinit)-min(Tinit))/2;
            MAX_EXTRAPOLATE_TRIALS=MAX_EXTRAPOLATE_TRIALS-1;
            if Tinit(3)+dTinit>t(end)
                Tinit=[t(end)-dTinit*2, t(end)-dTinit, t(end)];
                MAX_EXTRAPOLATE_TRIALS=0; % no more trials make sense
            else
                Tinit=[Tinit(3)-dTinit, Tinit(3), Tinit(3)+dTinit];
            end
        else
            initOK=1;
        end
    end
end

% parabolic interpolation step 1

Ttop=Tinit;mTtop=mean(Ttop);		% left/max/right
Stop=Sinit;		% corresponding cost function values

[p]=polyfit(Ttop-mTtop,Stop,2);		% fit parabol
Test=-p(2)/p(1)/2+mTtop;			% new estimated period

switch lower(Searchtype)        % select the sampling rate (upsampled or not)
    case 'coarse'
        Nfft=2^(ceil(log2(Test/fs/US))); %low sample rate fft
    case 'fine'
       Nfft=2^(ceil(log2(Test/fs)));    %high sample rate fft
    otherwise, disp('illegal choice for the Searchtype')
end
Lfft=floor(Bmax*Nfft-1);  
% select de test lijnen >>>>> moet aangepast worden in de subroutine

k=1;
% interpolation to 2^n for fast fft
tinterp=[0:Nfft-1]'/Nfft*Test;    				% interpolation points	

if max(tinterp)>t(end)
	disp('take care: extrapolation instead of interpolation')
	disp('maximum time > available time')
	[t(end) t(interp)]
    IntPolErr=1;
    return              % for a return to try with M-1 periods
end	
xinterp=interp1(t,xi,tinterp,InterPolMethod);	% interpolated signal
	
Y=abs(fft(xinterp));if(min(size(Y)>1)),Y=sum(Y,2);end;Y=Y(:)';Y(1)=0;
Snew=scostfcn(Y, Bmax,M); % cost function	
	
%
% parabolic interpolation, iteration process
%
deltaT=Ttop(3)-Ttop(1);	
[deltaT/Ttop(2) dT];
while deltaT/Ttop(2)>dT		% iterate till the interval is small enough
	TestOld=Test;
	k=k+1;						% lth iteration
	Ttop1=[Ttop Test];Stop1=[Stop Snew];
    
	[Ttop1 I]=sort(Ttop1);Stop1=Stop1(I);
	[Smin I]=min(Stop1);
    if (I==1)|(I==length(Ttop1)) % shouldn't happen: the best point is on the edge
        Snew=Smin;  % select the best and leave the iteration (the true minimum is outside the region)
        Test=Ttop1(I);
        break
    end
	Ttop=Ttop1([I-1 I I+1]);				% left/new max/right
	deltaT=Ttop(3)-Ttop(1);  
	if deltaT/Ttop(2)<=dT, break, end  % convergence reached, leave the loop !  2001.06.15.
	Stop=Stop1([I-1 I I+1]);
	deltaS=max(Stop)-min(Stop);
	%[Smax I]=max(Stop1);Ttop1(I)=[];Ttop=Ttop1;Stop1(I)=[];Stop=Stop1;
	mTtop=mean(Ttop);mStop=mean(Stop);
	[p]=polyfit((Ttop-mTtop)/deltaT,(Stop-mStop)/deltaS,2);	% fit parabol
		
	Test=-p(2)/p(1)/2*deltaT+mTtop	;						% new estimated from parabola
	
	[dTmin I]=min(abs(Ttop([1,2,3])-Test(1)));  % avoid that two base points completely collapse

    if abs(dTmin)<0.25*deltaT				% create a new point		
			Test(1)=0.1*Ttop(1)+0.9*Ttop(2);		% 10% of the distance between the points
			Test(2)=0.1*Ttop(3)+0.9*Ttop(2);		% 
	end
	
	clear Snew
	for k1=1:length(Test)
    switch lower(Searchtype)        % select the sampling rate (upsampled or not)
    case 'coarse'
      Nfft=2^(ceil(log2(Test(k1)/fs/US)));Lfft=floor(Bmax*Nfft-1); %low sample rate fft
    case 'fine'
      Nfft=2^(ceil(log2(Test(k1)/fs)));Lfft=floor(Bmax*Nfft-1);  %high sample rate fft
    otherwise, disp('illegal choice for the Searchtype')
    end
    
    % interpolation to 2^n for fast fft
    tinterp=[0:Nfft-1]'/Nfft*Test(k1);    % interpolation point
    
        
    if or(max(tinterp)>max(t(end)),min(tinterp)<t(1))
      disp('Pay attention: extrapolation instead of interpolation')
    end	
    xinterp=interp1(t,xi,tinterp,InterPolMethod);
        
    Y=abs(fft(xinterp));if(min(size(Y)>1)),Y=sum(Y,2);end;Y=Y(:)';Y(1)=0;
    Snew(k1)=scostfcn(Y, Bmax,M); % cost function			
  end
  %[k deltaT/Ttop(2)]
  
end	

[Sper I]=min(Snew);
Tper=Test(I);
if johanplot
  figure(3), plot(db(Y),'+')
end

%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%

function [xUS,tUS,Ntrans]=upsample(xi,US)
% upsampling a signal with a factor US
% xi: the original signal
% xUS: the upsampled signal
% tUS: the time vector for the upsampled signal
% Ntrans: the transient length of the upsampled signal

L=length(xi);			% length of the input signal
Norder=48*US;			% order upsampling filter
if US==6
  b=remezb;
else
  b=remez(Norder,[0 0.7/US 1.2/US 1],[1 1 0 0]); % design upsampling filter
end
Ntrans=Norder+1;	% transient length of the upsampling filter
xUS=reshape([xi(:) zeros(L,US-1)]',US*L,1);   % zero padding
xUS=filter(b,1,xUS);
if Ntrans+1>=length(xUS)
    warning('Problem in upsampling: record length too short for transient')
end

xUS=xUS(Ntrans+1:end)*US;      % eliminate the transient and scale for same amplitude
tUS=[0:length(xUS)-1]/US;


%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%


function cf=scostfcn(Y, Bmax, M)
%
% calculation of the cost function
%
% M: basic harmonic: power is calculated at multiples of M
% Lfft: maximum spectral line that is considered
Lfft=floor(length(Y)*Bmax+1);
Iplace=[M:M:Lfft-1]+1;  % the frequency lines to be considered in the cost
cf=sum(Y(Iplace-1).^2+Y(Iplace+1).^2)/sum(Y(Iplace).^2); % cost function


function dbX=db(X)
%DB decibel
dbX=20*log10(abs(X));

function b=remezb
b=[9.1132542535027592e-010
  2.0804666094462352e-009
  3.5776316645836668e-009
  4.5635638347836572e-009
  3.8124907245037083e-009
 -2.4847676012088759e-011
 -7.7548797890733432e-009
 -1.8775315325142678e-008
 -3.0327747301192403e-008
 -3.7313294231793278e-008
 -3.3124645186342745e-008
 -1.1703394329394368e-008
  2.9389419447098550e-008
  8.5703864317191281e-008
  1.4374366935267258e-007
  1.8144475176396524e-007
  1.7245433762071079e-007
  9.4371456812524036e-008
 -6.0434454788865570e-008
 -2.7449451359849763e-007
 -4.9966457223482356e-007
 -6.6061354502551304e-007
 -6.7006618723466328e-007
 -4.5517804481412199e-007
  1.0015421431451532e-008
  6.7542986368497854e-007
  1.4009115561004198e-006
  1.9683593311217784e-006
  2.1257989130964578e-006
  1.6600508803716409e-006
  4.8335488985163472e-007
 -1.2907854091790667e-006
 -3.3122377954930522e-006
 -5.0254244219073702e-006
 -5.7793285552411344e-006
 -5.0061056453596445e-006
 -2.4318037709065888e-006
  1.7396294615692060e-006
  6.7375257122907207e-006
  1.1289248479769311e-005
  1.3864590105458648e-005
  1.3075508484949102e-005
  8.1498190301587366e-006
 -6.4960613609346057e-007
 -1.1807572531777823e-005
 -2.2665797086544162e-005
 -2.9914531807946366e-005
 -3.0417775690356237e-005
 -2.2206410973089477e-005
 -5.3783609337272927e-006
  1.7393334289557506e-005
  4.0998636961198598e-005
  5.8794367473992452e-005
  6.4189287362226061e-005
  5.2598847841056693e-005
  2.3272420342655319e-005
 -1.9581949710589259e-005
 -6.6871883099523985e-005
 -1.0614504790657510e-004
 -1.2443890754283487e-004
 -1.1191055376749721e-004
 -6.5352475448987818e-005
  9.4573719442409870e-006
  9.7502001094339330e-005
  1.7687865934987870e-004
  2.2361296078550949e-004
  2.1804252069149990e-004
  1.5124616274883796e-004
  2.9682686722719754e-005
 -1.2363558040332908e-004
 -2.7243214971629749e-004
 -3.7482412777400709e-004
 -3.9398688717903453e-004
 -3.0935725399753900e-004
 -1.2530794442703648e-004
  1.2560271556753423e-004
  3.8667505227159299e-004
  5.8853997959257449e-004
  6.6612277772728958e-004
  5.7729257531197577e-004
  3.1828436296010458e-004
 -6.8925147519208459e-005
 -5.0064347341518438e-004
 -8.6760876658205539e-004
 -1.0607213653446789e-003
 -1.0007713790647643e-003
 -6.6460483230833104e-004
 -1.0000174082759139e-004
  5.7651458923724372e-004
  1.2008855471385732e-003
  1.5987602820374876e-003
  1.6309684177838899e-003
  1.2360479021370243e-003
  4.5787068059017686e-004
 -5.5121351011581195e-004
 -1.5559752818651679e-003
 -2.2897003852991363e-003
 -2.5210587661231268e-003
 -2.1205628030334434e-003
 -1.1087303395958569e-003
  3.2936437015553558e-004
  1.8714438776822218e-003
  3.1254256643092775e-003
  3.7240687320903307e-003
  3.4251885867876614e-003
  2.1915619179720671e-003
  2.2681923962287209e-004
 -2.0476377527476933e-003
 -4.0758994252294801e-003
 -5.2964756427236002e-003
 -5.2886121017484983e-003
 -3.8997771555329837e-003
 -1.3187258567918924e-003
  1.9314515313638354e-003
  5.0880718547306695e-003
  7.3172994808655854e-003
  7.9214959515240390e-003
  6.5366378615710138e-003
  3.2678851672976708e-003
 -1.2787580414367339e-003
 -6.0890965094712651e-003
 -9.9489312941244551e-003
 -1.1728868473601115e-002
 -1.0683216433242926e-002
 -6.6898784880956887e-003
 -3.6455140760631238e-004
  6.9940255131574315e-003
  1.3634676968820333e-002
  1.7725522927673983e-002
  1.7794733065899924e-002
  1.3144403706612776e-002
  4.1382191881507860e-003
 -7.7170526059247785e-003
 -1.9936713403006793e-002
 -2.9458513673198152e-002
 -3.3213527430414308e-002
 -2.8760122790409206e-002
 -1.4851888809224823e-002
  8.1843601217633840e-003
  3.8351867954955210e-002
  7.2205982047673950e-002
  1.0536805775703036e-001
  1.3324308390815098e-001
  1.5180814461608452e-001
  1.5832065272040921e-001
  1.5180814461608452e-001
  1.3324308390815098e-001
  1.0536805775703036e-001
  7.2205982047673950e-002
  3.8351867954955210e-002
  8.1843601217633840e-003
 -1.4851888809224823e-002
 -2.8760122790409206e-002
 -3.3213527430414308e-002
 -2.9458513673198152e-002
 -1.9936713403006793e-002
 -7.7170526059247785e-003
  4.1382191881507860e-003
  1.3144403706612776e-002
  1.7794733065899924e-002
  1.7725522927673983e-002
  1.3634676968820333e-002
  6.9940255131574315e-003
 -3.6455140760631238e-004
 -6.6898784880956887e-003
 -1.0683216433242926e-002
 -1.1728868473601115e-002
 -9.9489312941244551e-003
 -6.0890965094712651e-003
 -1.2787580414367339e-003
  3.2678851672976708e-003
  6.5366378615710138e-003
  7.9214959515240390e-003
  7.3172994808655854e-003
  5.0880718547306695e-003
  1.9314515313638354e-003
 -1.3187258567918924e-003
 -3.8997771555329837e-003
 -5.2886121017484983e-003
 -5.2964756427236002e-003
 -4.0758994252294801e-003
 -2.0476377527476933e-003
  2.2681923962287209e-004
  2.1915619179720671e-003
  3.4251885867876614e-003
  3.7240687320903307e-003
  3.1254256643092775e-003
  1.8714438776822218e-003
  3.2936437015553558e-004
 -1.1087303395958569e-003
 -2.1205628030334434e-003
 -2.5210587661231268e-003
 -2.2897003852991363e-003
 -1.5559752818651679e-003
 -5.5121351011581195e-004
  4.5787068059017686e-004
  1.2360479021370243e-003
  1.6309684177838899e-003
  1.5987602820374876e-003
  1.2008855471385732e-003
  5.7651458923724372e-004
 -1.0000174082759139e-004
 -6.6460483230833104e-004
 -1.0007713790647643e-003
 -1.0607213653446789e-003
 -8.6760876658205539e-004
 -5.0064347341518438e-004
 -6.8925147519208459e-005
  3.1828436296010458e-004
  5.7729257531197577e-004
  6.6612277772728958e-004
  5.8853997959257449e-004
  3.8667505227159299e-004
  1.2560271556753423e-004
 -1.2530794442703648e-004
 -3.0935725399753900e-004
 -3.9398688717903453e-004
 -3.7482412777400709e-004
 -2.7243214971629749e-004
 -1.2363558040332908e-004
  2.9682686722719754e-005
  1.5124616274883796e-004
  2.1804252069149990e-004
  2.2361296078550949e-004
  1.7687865934987870e-004
  9.7502001094339330e-005
  9.4573719442409870e-006
 -6.5352475448987818e-005
 -1.1191055376749721e-004
 -1.2443890754283487e-004
 -1.0614504790657510e-004
 -6.6871883099523985e-005
 -1.9581949710589259e-005
  2.3272420342655319e-005
  5.2598847841056693e-005
  6.4189287362226061e-005
  5.8794367473992452e-005
  4.0998636961198598e-005
  1.7393334289557506e-005
 -5.3783609337272927e-006
 -2.2206410973089477e-005
 -3.0417775690356237e-005
 -2.9914531807946366e-005
 -2.2665797086544162e-005
 -1.1807572531777823e-005
 -6.4960613609346057e-007
  8.1498190301587366e-006
  1.3075508484949102e-005
  1.3864590105458648e-005
  1.1289248479769311e-005
  6.7375257122907207e-006
  1.7396294615692060e-006
 -2.4318037709065888e-006
 -5.0061056453596445e-006
 -5.7793285552411344e-006
 -5.0254244219073702e-006
 -3.3122377954930522e-006
 -1.2907854091790667e-006
  4.8335488985163472e-007
  1.6600508803716409e-006
  2.1257989130964578e-006
  1.9683593311217784e-006
  1.4009115561004198e-006
  6.7542986368497854e-007
  1.0015421431451532e-008
 -4.5517804481412199e-007
 -6.7006618723466328e-007
 -6.6061354502551304e-007
 -4.9966457223482356e-007
 -2.7449451359849763e-007
 -6.0434454788865570e-008
  9.4371456812524036e-008
  1.7245433762071079e-007
  1.8144475176396524e-007
  1.4374366935267258e-007
  8.5703864317191281e-008
  2.9389419447098550e-008
 -1.1703394329394368e-008
 -3.3124645186342745e-008
 -3.7313294231793278e-008
 -3.0327747301192403e-008
 -1.8775315325142678e-008
 -7.7548797890733432e-009
 -2.4847676012088759e-011
  3.8124907245037083e-009
  4.5635638347836572e-009
  3.5776316645836668e-009
  2.0804666094462352e-009
  9.1132542535027592e-010]';

%%%%%%%%%%%%%%%%%%%%%%%% End of file fcoeffs %%%%%%%%%%%%%%%%%%%%%%%%
