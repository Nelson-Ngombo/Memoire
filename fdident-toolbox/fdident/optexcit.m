function [X,CR,fsv,vXwdev,Fiw]=optexcit(varargin)
%OPTEXCIT Iterate towards an excitation signal with optimal power spectrum.
%
%       [optdata,CR,iterinfo]=OPTEXCIT(pdat,fixpind,runmod);
%
%       The transfer function of the system is given in a parameter vector or
%       parameter file.
%
%       Output arguments:
%       optdata = fiddata object containing the generated amplitudes (absolute values
%           of complex Fourier coefficients) in the input
%       CR = Cramer-Rao lower bound of the covariance matrix of the
%           parameter estimates with the amplitude set, calculated in the
%           before last iteration cycle
%       iterinfo = information about the iteration
%         iterinfo.fsv = suggested scaling vector for the Cramer-Rao bound:
%           CRs=CR.*(fsv*fsv')
%         iterinfo.vXwdev = 2xN array of the maximum and minimum values of the
%           dispersion function minus np at the beginning of each cycle
%         iterinfo.Fiw = array for the next run for the same system, with the same fixed
%           parameters and same frequency vector, formed of scaled Fisher
%           information matrices for each frequency, assuming that all amplitudes
%           are equal 1.
%
%       Input arguments:
%       pdat = fidmodel object. The field 'data' must be an fiddata object.
%         pdat.data.freqpoints = vector of frequencies where the optimal amplitudes
%           will be determined
%         pdat.data.input = starting values of the amplitudes. If this is empty
%           or missing, the amplitudes will be uniform. The amplitude vector will be
%           scaled internally to set the total signal power to 1.
%         pdat.data.SisoVariances: the input and output variance vectors and maybe
%           the input-output covariance vector; in the case of an 1x2 or 1x3 vector,
%           these values mean the constant input and output variances and the
%           covariances.
%           The variance property can only be set if the corresponding input/output
%           amplitudes are also set. If there is no reasonable value for these, set
%           all amplitudes to NaN.
%           Default value (if empty): [1,1].
%       fixpind = indices of fixed parameters in the total parameter vector,
%           defined as: [num,denom,delay]', where the coefficients are in
%           descending order in the s-domain, and in ascending order in the
%           z-domain. If fixpind is given as fixpind=0, the
%           coefficient of the denominator which belongs to s^0 or z^0,
%           respectively, and the delay will be fixed (fixpind=[nn+nd,nn+nd+1]
%           in the s-domain, or fixpind=[nn+1,nn+nd+1] in the z-domain, with
%           nn and nd the number of parameters in the numerator or the
%           denominator, respectively). fixpind='n' or missing means that no fixed
%           parameters are given at all.
%       runmod = structure of run modifiers (any field may be missing)
%         runmod.Ncyc = number of iterations to be performed, default: Ncyc=1
%         runmod.Fiw = array determined in a previous run for the same system, with
%           the same fixed parameters and same frequency vector, formed of
%           scaled Fisher information matrices for each frequency, assuming
%           that all amplitudes are equal 1.
%         runmod.plotdens = plot density: plot results in every pd'th cycle
%         runmod.textdens = text displaying density: type out results in every td'th
%           cycle
%         runmod.fscale = scaling frequency for better conditioning (optional)
%
%       Usage:
%       [optdata,CR,iterinfo]=optexcit(pdat,fixpind,runmod);
%       Example: optdata=optexcit('inpchmod(inpchans)');
%
%       See also: DIBS, DIBSIMPR, MSINCLIP, OPTEXCIT.

%Old fdident help
%OPTEXCIT Iterate towards an excitation signal with optimal power spectrum.
%
%       [X,CR,fsv,vXwdev,Fiw]=...
%                   OPTEXCIT(pdat,freqv,vdat,fixpind,X0,Ncyc,Fiw,pd,td,fsc)
%
%       The transfer function of the system is given in a parameter vector or
%       parameter file.
%
%       Output arguments:
%       X = generated amplitudes (absolute values of complex Fourier
%           coefficients)
%       CR = Cramer-Rao lower bound of the covariance matrix of the
%           parameter estimates with the amplitude set, calculated in the
%           before last iteration cycle
%       fsv = suggested scaling vector for the Cramer-Rao bound:
%           CRs=CR.*(fsv*fsv')
%       vXwdev = 2xN array of the maximum and minimum values of the
%           dispersion function minus np at the beginning of each cycle
%       Fiw = array for the next run for the same system, with the same fixed
%           parameters and same frequency vector, formed of scaled Fisher
%           information matrices for each frequency, assuming X(k)=1.
%
%       Input arguments:
%       pdat = 'parameter' vector or name of the parameter file (see EXPPAR)
%       freqv = vector of frequencies where the optimal amplitudes will be
%               determined
%       vdat = variances: if this is a string or a column vector, the
%           variances will be obtained via IMPVAR; if this is an array
%           (Nx2 or N=3, N>1), this is supposed to consist of the input and
%           output variance vectors and maybe the input-output covariance
%           vector; in the case of an 1x2 or 1x3 vector, these values mean
%           the constant input and output variances and the covariances.
%           Default value: [1,1].
%       fixpind = indices of fixed parameters in the total parameter vector,
%           defined as: [num,denom,delay]', where the coefficients are in
%           descending order in the s-domain, and in ascending order in the
%           z-domain. If fixpind is given as fixpind=0, the
%           coefficient of the denominator which belongs to s^0 or z^0,
%           respectively, and the delay will be fixed (fixpind=[nn+nd,nn+nd+1]
%           in the s-domain, or fixpind=[nn+1,nn+nd+1] in the z-domain, with
%           nn and nd the number of parameters in the numerator or the
%           denominator, respectively). fixpind='n' or [] means that no fixed
%           parameters are given at all.
%       X0 = starting values of X. If X0 is empty or missing, the amplitudes
%           will be uniform. X0 will be scaled internally to set the total
%           signal power to 1.
%       Ncyc = number of iterations to be performed, default: Ncyc=1
%       Fiw = array determined in a previous run for the same system, with
%           the same fixed parameters and same frequency vector, formed of
%           scaled Fisher information matrices for each frequency, assuming
%           X(k)=1.
%       pd = plot density: plot results in every pd'th cycle
%       td = text displaying density: type out results in every td'th cycle
%       fsc = scaling frequency for better conditioning (optional)
%
%       Usage:
%       [X,CR,fsv,vXwdev,Fiw]=...
%              optexcit(pdat,fv,vdat,fixpind,X0,Ncyc,Fiw,pd,td,fsc);
%       Example: X=optexcit('inpchmod(inpchans)',[1:50]/50*3e4);
%
%       See also: DIBS, DIBSIMPR, MSINCLIP, OPTEXCIT.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,10); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,10,ni)), %earlier
end
pdat=varargin{1};

isPC=strncmpi(computer,'PC',2); MatlV=version;
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
if exist('getobjf')
  pdat=getobjf(pdat,'fidmodel'); %If possible, get fidmodel object
  if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
end
if isa(pdat,'fidmodel')
  if strcmp(pdat.representation,'orthopol')
    error('Optexcit cannot handle orthopol yet')
  elseif strcmp(pdat.variable,'w')
    error('optexcit cannot handle w-domain yet')
  end
  if ~isa(pdat.data,'fiddata')
    error('data field of the fidmodel object is not fiddata')
  end
  freqv=pdat.data.freqpoints;
else
  freqv=varargin{2};
end
if min(size(freqv))~=1, error('freqv is not a vector'), end
freqv=freqv(:); F=length(freqv);
%
if isa(pdat,'fidmodel') %New call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,3,ni)), %earlier
  end
  if nargout>3, error('Too many output arguments'), end
  if nargin<2, fixpind=[]; else fixpind=varargin{2}; end
  if nargin<3, runmod=[]; else runmod=varargin{3}; end
  vdat=pdat.data.SisoVariance; X0=pdat.data.input;
  if all(isnan(X0(:))), X0=[]; end
  if all(isnan(vdat(:))), vdat=[]; end
  if (size(vdat,2)==1)&(size(vdat,1)>0)
    error('Variance is a scalar, instead of an Fx2 or Fx3 (1x2 or 1x3) array')
  end
  Ncyc=[]; Fiw=[]; pd=[]; td=[]; fsc=[];
  if isfield(runmod,'Ncyc'), Ncyc=runmod.Ncyc; end
  if isfield(runmod,'Fiw'), Fiw=runmod.Fiw; end
  if isfield(runmod,'plotdens'), pd=runmod.plotdens; end
  if isfield(runmod,'textdens'), td=runmod.textdens; end
  if isfield(runmod,'fscale'), fsc=runmod.fscale; end
else %old call
  if nargin<10, fsc=[]; else fsc=varargin{10}; end
  if nargin<9, td=[]; else td=varargin{9}; end
  if nargin<8, pd=[]; else pd=varargin{8}; end
  if nargin<7, Fiw=[]; else Fiw=varargin{7}; end
  if nargin<6, Ncyc=[]; else Ncyc=varargin{6}; end
  if nargin<5, X0=[]; else X0=varargin{5}; end
  if nargin<4, fixpind=[]; else fixpind=varargin{4}; end
  if nargin<3, vdat=[]; else vdat=varargin{3}; end
end
if isempty(pd), pd=1; end
if isempty(td), td=pd; end
if isempty(Ncyc), Ncyc=1; end
if Ncyc<0, error('The number of cycles must not be negative'), end
%
if isempty(X0), X0=ones(F,1)/sqrt(F);
elseif length(X0)~=F, error('X0 has not the same size as freqv')
end
if isempty(fsc)
  fsc=2*pi*(max(freqv)+min(freqv))/2;
end
[domain,num,denom,delay,fs]=imppar(pdat,fsc); %Frequency-scaled import
if ~isa(pdat,'fidmodel')&any(domain=='wp')
  error(['optexcit cannot handle domain ''',domain,''' yet'])
end
if isempty(vdat), vdat=[1,1]; end
[f0,f0ind]=min(freqv);
if f0==0
  dc=abs(X0(f0ind(1))); if dc==0, Fm=0; else Fm=1; end
  %If zero dc given, Fm will be increased anyway
else
  dc=0; Fm=0;
end
Fm=Fm-2*sum(X0==0); %zero amplitudes do not count
X0=abs(X0(:));
EX0=2*X0'*X0-dc^2; EX0d=X0'*X0; %total signal power
X0=X0/sqrt(EX0d); %normalize input amplitudes to unity power
P=[num,denom,delay]';
nn=length(num); nd=length(denom);
if length(fixpind)==1
  if (fixpind==0)|strcmp(fixpind,'0')
    if domain=='z', fixpind=[nn+1,nn+nd+1];
    elseif domain=='s', fixpind=[nn+nd,nn+nd+1];
    end
    fprintf(['The denominator coefficient of ',domain,'^0 and the delay ',...
             'will be fixed in optexcit\n'])
  elseif strcmp(fixpind,'n'), fixpind=[];
  end
elseif isempty(fixpind)
  fixpind=[];
end
fixpindnd=fixpind; ind=find([fixpindnd(:);0]==nn+nd+1);
if ~isempty(ind), fixpindnd(ind)=[]; end %eliminate delay fixing information
if isempty(fixpindnd), nfixps=1; %no fixed parameter
elseif all(P(fixpindnd)==0), nfixps=1; %no fixed nonzero parameter
else nfixps=0;
end
np=nn+nd+1-length(fixpind); %number of estimated parameters
npf=np-nfixps; %number of free parameters
if nfixps==1
  disp('WARNING! No fixed nonzero parameter in numerator or denominator')
  disp('CR and det(CR) will depend on the scaling of the parameter vector')
end
if np>2*F-Fm
  disp('WARNING! Insufficient number of frequencies given')
end
if isstr(vdat)|(length(vdat(1,:))==1)
  [varx,vary,covxy]=impvar(vdat);
  varx=varx(:,1); vary=vary(:,1); if ~isempty(covxy), covxy=covxy(:,1); end
elseif (length(vdat(1,:))==2)|(length(vdat(1,:))==3)
  if any(any(imag(vdat(:,1:2))))
    error('Complex value in variance array')
  elseif any(isnan(vdat(:)))
    error('NaN value in variance array')
  elseif any(any(vdat(:,1:2)<0))
    error('Negative value in variance array')
  end
  if length(vdat(:,1))>1
    varx=vdat(:,1); vary=vdat(:,2);
    if length(vdat(1,:))==3, covxy=vdat(:,3); else covxy=[]; end
  else %constant variances
    varx=vdat(1)*ones(F,1); vary=vdat(2)*ones(F,1);
    if length(vdat)==3, covxy=vdat(3)*ones(F,1); else covxy=[]; end
  end
  if isempty(covxy), covxy=zeros(F,1); end
else
  error('vdat is not allowed')
end
if length(varx)~=F
  error(sprintf('The length of varx is %.0f instead of %.0f',length(varx),F))
end
%
if ~isempty(Fiw)
  sFiw=size(Fiw); if length(size(sFiw)==2), sFiw=[sFiw,1]; end
  if any(size(Fiw)~=[np,np,F])
    %dimensions of Fiw not OK
    error(sprintf('The dimensions of Fiw (%.0f,%.0f,%.0f) are incorrect',...
      sFiw(1),sFiw(2),sFiw(3)))
  end
end
invFiX=[];
%
if domain=='z'
  tf=exp(-j*freqv*2*pi*delay/fs)...
        .*polyval(num(length(num):-1:1),exp(-sqrt(-1)*freqv*2*pi/fs))...
        ./polyval(denom(length(denom):-1:1),exp(-sqrt(-1)*freqv*2*pi/fs));
  fsv=ones(np,1); detscale=1;
else %s-domain
  tf=exp(-j*freqv/fs*2*pi*delay).*polyval(num,sqrt(-1)*2*pi*freqv/fs)...
                        ./polyval(denom,sqrt(-1)*2*pi*freqv/fs);
  fsv=1; fsi=1; for ip=1:nn-1, fsi=fsi*fs; fsv=[fsi;fsv]; end
  fsvd=1; fsi=1; for ip=1:nd-1, fsi=fsi*fs; fsvd=[fsi;fsvd]; end
  fsv=[fsv;fsvd;fs]; fsv(fixpind)=[]; %vector of rescaling factors
  logdetscale=2*sum(log(fsv));
  if logdetscale<log(realmax), detscale=exp(logdetscale);
  else detscale=inf;
  end
  %detscale=prod(fsv)^2;
end
%
X=X0; vXwdev=[]; if isempty(Fiw), NaNv=NaN; Fiw=NaNv(ones(np,np,F)); end
itcdone=0;
for i2=1:max(2*Ncyc,1) %usually double cycle, unless only CR is neded (Ncyc=0)
  if calldrawnow, drawnow, end
  i=ceil(i2/2); %counter of main iteration cycles
  vXw=zeros(F,1); %dispersion function
  if rem(i2,2)==1, %in odd cycles, calculate FiX
    FiX=zeros(np,np); %initialize
  end
  for k=1:F %all frequencies
    %if (length(Fiw)<np*F)
    if all(all(isnan(Fiw(1:np,1:np,F)))) %Fiwk has to be calculated
      if domain=='s'
        Om=sqrt(-1)*2*pi*freqv(k)/fs;
        delterm=exp(-sqrt(-1)*pi*freqv(k)/fs*delay);
        dN=1; vf=1; for ip=1:nn-1, vf=vf*Om; dN=[vf,dN]; end
        dD=1; vf=1; for ip=1:nd-1, vf=vf*Om; dD=[vf,dD]; end
      elseif domain=='z'
        Om=exp(-sqrt(-1)*2*pi*freqv(k)/fs);
        delterm=exp(-sqrt(-1)*pi*freqv(k)/fs*delay);
        dN=1; vf=1; for ip=1:nn-1, vf=vf*Om; dN=[dN,vf]; end
        dD=1; vf=1; for ip=1:nd-1, vf=vf*Om; dD=[dD,vf]; end
      end
      dN=delterm*dN; dD=conj(delterm)*dD;
      N=dN*num'; D=dD*denom';
      dN=[dN,zeros(1,nd),-sqrt(-1)*pi*freqv(k)/fs*N];
      dD=[zeros(1,nn),dD,+sqrt(-1)*pi*freqv(k)/fs*D];
      dN(fixpind)=[]; dD(fixpind)=[];
      %
      %K=KN/KD=(NX-DY)*conj(NX-DY)/(2*vary*D*conj(D)+2*varx*N*conj(N))
      %(KN/KD)''=(KN''*KD-2KN'*KD'-KN*KD'')/KD^2 - 2KN*KD'*KD'/KD^3
      %KN and dKN are zeros, X=1;
      d2KN=2*real((dN-dD*tf(k))'*(dN-dD*tf(k)));
      KD=2*vary(k)*abs(D)^2+2*varx(k)*abs(N)^2-4*real(covxy(k)*conj(N)*D);
      Fiwk=d2KN/KD;
      [comp,maxsize]=computer;
      Fiw(1:np,1:np,k)=Fiwk;
    else %Fiw is ready for use
      %Fiwk=Fiw(1:np,(k-1)*np+[1:np]);
      Fiwk=Fiw(1:np,1:np,k);
    end
    if rem(i2,2)==1, %in odd cycles, calculate FiX
      if ~isempty(f0ind)&(f0ind(1)==k)
        FiX=FiX+X(k).^2*Fiwk; %dc
      else
        FiX=FiX+(X(k).^2)*Fiwk;
      end
    else %in even cycles, calculate the dispersion function
      vXw(k)=trace(invFiX*Fiwk);
    end
    if calldrawnow, drawnow, end
  end %k
  if any(vXw<0)
    warning('Negative element(s) in vXw')
    vXw=abs(vXw);
  end
  if any(vXw==0)
    %warning('Zero element(s) in vXw')
  end
  if rem(i2,2)==1, %in odd cycles, calculate invFiX
    %invFiX=inv(FiX);
    [U,S,V]=svd(FiX,0);
    maxsv=max(max(S)); ind=find(diag(S)<eps*maxsv);
    %Eliminate deficiency 1 by taking pseudoinverse if no parameter is fixed
    if nfixps>0
      for indi=ind([1:nfixps])', S(indi,indi)=inf; end
    end
    %
    %Eliminate all singular values that are equal to zero
    for indi=size(S,1)-[0:length(P)-npf], S(indi,indi)=inf; end
    invFiX=V*diag(1.0./diag(S))*U';
    indS=find(isfinite(diag(S))); %usable singular values
    detCRs=1/prod(diag(S(indS,indS)));
    if length(ind)>nfixps
      fprintf('WARNING! Rank of FiX is deficient by %.0f\n',length(ind))
      NaNv=NaN; %bypass Vax problem with NaN*
      CR=NaNv(ones(np,1),ones(1,np)); detCRs=NaN;
    else
      CR=(invFiX/EX0d)./(fsv*fsv'); %detCRs=det(invFiX/EX0);
      %CR=(invFiX)./(fsv*fsv');
      %EX0
    end
    if isnan(detCRs)|isnan(detscale)
      detCR=NaN;
    elseif ~isfinite(detCRs)
      if ~isfinite(detscale), detCR=NaN; else detCR=inf; end
    else %finite detCRs
      logdetCR=log(abs(detCRs))-logdetscale;
      if abs(logdetCR)<log(realmax)
        detCR=sign(detCRs)*exp(logdetCR);
      elseif logdetCR>0, detCR=inf;
      else detCR=0;
      end
    end
  else %in even cycles, calculate the new amplitudes
    X0=X;
    X=sqrt(vXw/npf).*X;
    if ~isempty(f0ind), dc=X(f0ind); else dc=0; end
    EX=2*X'*X-dc^2; EXd=X'*X;
    X=X/sqrt(EXd); %for safety
    vXwdev=[vXwdev,[max(vXw)-npf;min(vXw)-npf]];
  end
  if calldrawnow, drawnow, end
  %
  %Messages in even cycles:
  if (rem(i2,2)==0)&isfinite(td)&((i2==2)|(rem(i2,2*td)==0)|(i2==max(2*Ncyc,1)))
    fprintf('optexcit: cycle %.0f',i)
    if length(ind)==nfixps
      fprintf(', det(CRs)=%.3g, det(CR)=%.3g\n',detCRs,detCR)
    else
      disp(' ')
    end
    fprintf('   np=%.0f,   %.1f <= dispersion <= %.1f\n',npf,min(vXw),max(vXw))
  end
  fsh=[];
  %
  %PLOTS:
  if (rem(i2,2)==0)&isfinite(pd)&((i2==2)|(rem(i2,2*pd)==0)|(i2==max(2*Ncyc,1)))
    if isempty(fsh) %for first plot only
      if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
      if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
      else blue='b'; red='r'; green='g';
      end
      if (mean(get(gcf,'Color'))>=0.5), yellow=blue; %white bg
      elseif (get(0,'ScreenDepth')>=8), yellow='y';
      else yellow=green;
      end
      %Delete all axes objects in current figure
      %Use get because findobj may be missing (Matlab 4.1 or earlier)
      %delete(findobj(gcf,'Type','axes'));
      hax=get(gcf,'Children');
      if ~isempty(hax), for ih=1:length(hax)
        if strcmp(get(hax(ih),'Type'),'axes'), delete(hax(ih)), end
      end, end
      %
      fsh=[freqv';freqv';freqv']; fsh=fsh(:);
      tfm=max(abs(tf));
      dfv=diff(sort(freqv(:))); if isempty(dfv), dfv=freqv; end
      fp1=min(freqv)-dfv(1); fp2=max(freqv)+dfv(length(dfv));
    end
    %
    hold off
    if itcdone==0 %try to put up iterctrl
      if isempty(findall(0,'type','uimenu','tag','iteration_menu'))&exist('iterctrl')
        iterctrl;
      end
      itcdone==1;
    end
    subplot(2,2,1)
    plot(freqv,abs(tf),['-',green]), title('Transfer function'), grid off
    axis([fp1,fp2,0,1.1*tfm])
    %
    Xsh=zeros(3*F,1); Xsh(2:3:length(Xsh))=vXw;
    subplot(2,2,2)
    plot(fsh,Xsh,['-',yellow],[fp1,fp2],[npf,npf],[':',white]), grid off
    axis([fp1,fp2,0,1.1*max(vXw)])
    title('Previous dispersion function')
    %
    Xsh(2:3:length(Xsh))=X0;
    subplot(2,2,3)
    plot(fsh,Xsh,['-',yellow]), title('Previous amplitudes (scaled)')
    grid off
    axis([fp1,fp2,0,1.1*max(abs([X;X0]))])
    %
    Xsh(2:3:length(Xsh))=X;
    subplot(2,2,4)
    plot(fsh,Xsh,['-',red]), grid off
    axis([fp1,fp2,0,1.1*max([X;X0])])
    title('New amplitudes')
    if length(ind)==nfixps %No degeneration
      graphh=gca;
      txth=axes('Position',[0,0,1,1]); axis('off')
      text(0,0,sprintf('det(CR)=%.3g',detCR),'VerticalAlignment','bottom')
      text(0,0.038,sprintf('det(CRs)=%.3g',detCRs),...
                'VerticalAlignment','bottom')
      text(0.5,0,sprintf('cycle %.0f in this call,  np=%.0f',i,npf),...
                'VerticalAlignment','bottom')
      axes(graphh)
    end
    drawnow, figure(gcf)
    hold off
    if calliterctrl
      itctrlchecked=iterctrl('checked');
      if calldrawnow==1, drawnow, end
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
  end %plot
  %
  %handle GUI-based iteration control using iterctrl:
  if calliterctrl&~isempty(get(0,'Children'))
    %we need to check iterctrl
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
      itctrllastchecked='Finish'; iterctrl('Continue');
      disp('Finish of optexcit requested through GUI')
      break
    elseif strcmp(itctrlchecked,'Cancel')
      iterctrl('Continue');
      disp('optexcit run canceled through GUI')
      X=[]; CR=[]; fsv=[]; vXwdev=[]; Fiw=[];
      return
    elseif strcmp(itctrlchecked,'Abort')
      iterctrl('Continue'); error('Abort requested through GUI')
    end
    isPlot=strcmp(itctrlchecked,'Plot'); %iterctrl requests plotting
  else
    isPlot=0; %iterctrl does not request plotting
  end
  %
end %i2
%
%optexcit finished: set iterctrl to Continue
if calliterctrl, iterctrl('Continue'), end
if isa(pdat,'fidmodel')
  X=fiddata([],X,freqv);
  if nargout>=3
    iterinfo.fsv=fsv;
    iterinfo.vXwdev=vXwdev;
    iterinfo.Fiw=Fiw;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%% end of optexcit %%%%%%%%%%%%%%%%%%%%%%%%%%
