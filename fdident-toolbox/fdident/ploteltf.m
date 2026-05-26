function [ha1,ha2,fsc]=ploteltf(pd1,pd2,Fdat,fscale,msc,cd1,cc,cn,rec,expi,ntx,h,fsm,objtype)
%PLOTELTF Plot transfer function(s), measured data and confidence intervals.
%
%       [ha1,ha2,fsc]=PLOTELTF(pd1,pd2,Fdat,fscale,msc,cd1,cc,cn,rec,expi,ntx,h)
%
%       The transfer function, defined by the model object or parameter
%       vector or file pd1 is plotted with mark '-',
%       the one defined by pd2 is plotted with ':',
%       and the measured data in Fdat with '+'. The magnitude is on the upper
%       half of the screen, in deciBels, the phase is on the lower one, in
%       degrees. Two of pd1, pd2, Fdat may be empty. If cd1 is also
%       given containing covariance data, the two-sigma confidence intervals of
%       tf1 will also be shown, at 32 points. These numbers can be changed
%       by cc and cn. If cd1 contains variance data, the confidence
%       intervals of the tf points defined by Fdat are plotted for all
%       frequencies, if not otherwise requested by cn.
%
%       Output arguments:
%       ha1 = handle of magnitude plot
%       ha2 = handle of phase plot
%       fsc = scaling frequency for plots
%
%       Input arguments:
%       pd1 = first model object or parameter vector (see exppar) or the
%            name of the first parameter file
%       pd2 = second model object or parameter vector (see exppar) or the
%            name of the second parameter file
%       Fdat = Fourier vector or the name of the Fourier file, or the array
%           [freqvect,x,y]
%       fscale = scaling of the frequency axis. Possible values:
%           'lin': linear, from 0 to either higher sampling frequency in
%           parameter sets (if any), or maximal frequency in Fourier file.
%           'linF': linear, from 0 to maximal frequency in Fourier file.
%           ['lin',f1,f2]: linear from f1 to f2, [f1,f2]: scale linearly
%           'log': logarithmic, between 1e-3*fs/2 to fs/2 (fs is the higher
%              sampling frequency in files, if any), or from 1e-3*maxf to maxf
%              (maximal frequency in Fourier file). For s-domain parameter
%              files with no Fourier file, plot from 1e-2*fscale to 10*fscale.
%           'logF': logarithmic, from minimal nonzero frequency to maximal
%              frequency in Fourier file.
%           ['log',f1,f2]: logarithmic from f1 to f2
%           default: 'lin'
%       msc = scaling of amplitude plot: 'full' to scale to all points,
%           'passb' to scale to passband only (defined by the minimum and
%           maximum of frequencies, for which y is not zero in Fdat).
%           If a '+' is appended to this parameter, only the amplitudes are
%           plotted, if a '-', only the phases, while '=' allows to
%           show both the amplitude and the phase.
%           For '&', an f-X, f-Y pair is plotted. If the variance is given in
%           cd1, this is also plotted. 
%           For the next options, the absolute value of the magnitude is plotted,
%           along with error indicators.
%           For '*', the indicator depends on the type of cd1: if it is the
%           covariance matrix of the parameters, then the standard deviations of
%           the magnitude are shown, if the variance, the std's of the residuals.
%           '@' lets the std's of the non-averaged FRF's plotted.
%           '2' shows the output/input and the var + nonlinear error (if any) for non-av data.
%           '1' shows the output and the var + nonlinear error (if any) for non-av data.
%           'w' shows the 'nonlinear variances', used in estimation
%           'r' allows to see the complex residuals.
%           'a' is the same as 'r', but also the 50% and 95% confidence limits
%               of the residuals are shown;
%           'b' is the same in adition with the nonlinearity levels in blue.
%           For 'S', the signal-to-noise ratio is plotted along with the magnitudes.
%           For 's', the signal-to-noise ratios are plotted along with the inputs and outputs.
%           For 'N', the noise-to-signal ratio is plotted along with the magnitudes.
%           For 'n', the noise-to-signal ratios are plotted along with the inputs and outputs.
%           For 'A' or 'B' numerator and denominator of model are plotted 
%       cd1 = covariance matrix or covariance vector or name of file
%           belonging to pd1 (cd1 may be empty). 
%           If cd1 contains variance data of complex amplitudes belonging
%           to Fdat ([vy,vu,cuy]), the confidence intervals of Ym./Xm will be plotted. 
%           Value NaN means that covariances are taken from the object pd1.
%       cc = coefficient for setting the confidence bound. It is the
%           multiplier of the standard deviation.
%       cn = number of plotted confidence intervals
%       rec = 'abc', where each letter refers to pd1, pd2, Fdat,
%           respectively: 's' means straight (no reciprocal building is
%           necessary), 'r' means reciprocal before plotting
%       expi = number of the experiment(s) to be plotted: if empty, all the
%           experiments in the file will be plotted
%       ntx = if this is 'nomesg', the file names etc. will not be shown.
%             for 'notext', even the labels are not shown.
%       h = handle of the axes to plot at; vector if two subplots are given
%       fsm = if 'n', automatic frequency scaling is not done
%       objtype = type of object to be plotted: linear, interpnonlin, nonlin
%       Most of the input parameters maybe omitted.
%       Default values:
%           pd2=''; Fdat=''; fscale='lin'; msc='full='; cd1='';
%           cc=2; (cc=1 for complex error), cn=32; rec='sss'; expi=[]; ntx='';
%           h=gca; fsm=[]; objtype = whichever corresponds to object,
%           preference from right
%
%       Usage:
%          [ha1,ha2,fsc]=...
%               ploteltf(pd1,pd2,Fdat,fscale,msc,cd1,cc,cn,rec,expi,ntx,h);
%       Examples:
%           ploteltf('inpchmod(inpchans)','','inpchan','linF','full+');
%           [ha1,ha2,fsc]=ploteltf(exppar('z',[1.1,1],[4,3,2,1],0));
%
%       See also: STDTF, STDTFM, PLOTELPZ.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-2005

fmin=NaN;
if (nargin==1)&isstr(pd1)&strcmp(pd1,'preload')
  return %loading only for one argument 'preload'
end
if nargout>0, ha1=[]; ha2=[]; fsc=1; end

c=computer; vers=version;
argerrorbar=5; %Number of allowed input arguments of errorbar
ptyp1=''; ptyp2='';
nonlinplot=0; vtype=''; %type of variance
%
if nargin<12, h=[]; end, if ~isempty(h), hgiven=1; else hgiven=0; end
if hgiven, hp=get(h(1),'parent'); else hp=gcf; end, %if iscell(hp), hp=hp{1}; end
neglvali=realmin; maxvali=realmax;
if mean(get(hp,'Color'))<=0.5, white='w'; invis='k';
else white='k'; invis='w';
end
if get(0,'ScreenDepth')<=4
  blue=white; red=white; green=white; green2=white; yellow=white;
  cyan=red; cyangreen=cyan; yellow=green;
  nonexyellow=white;
else
  blue='b'; red='r'; green=[0,0.9,0]; green2='g'; yellow=green; nonexyellow=[0.95,0.95,0];
  cyan='c'; cyangreen=[0,1,0.85]; yellow=[0.83,0.83,0];
end
%
errorblue=[0.4,0.4,1]; %blue
errorblue=[0,0,1]; %blue
%errorblue=[0,0.8,1]; %Johan
%errorblue=[0,0.6,1];
lighterrorblue=[0.8,0.8,1]; %lighter blue
lighterrorblue=[.8,0,1]; %Johan
lighterrorblue=[.9,0.5,1];
if (length(errorblue)==3)&(length(yellow)==3)
  lighterrorblue2=min([1,1,1],1.3*mean([errorblue;yellow],1));
else lighterrorblue2=min([1,1,1],1.3*errorblue);
end
lighterrorblue2=1-0.3*(1-errorblue);
%
if nargin<14, objtype=''; 
elseif strncmpi(objtype,'linear',3), objtype='linear';
elseif strncmpi(objtype,'nonlinear',4), objtype='nonlinear';
elseif strncmpi(objtype,'interpnonlinear',6), objtype='interpnonlin';
elseif isempty(objtype)
else error('objtype, is not allowed')
end
if nargin<13, fsm=''; end
if ~(isempty(fsm)|strcmp(fsm,'n')), error('fsm not allowed'), end
if nargin<11, ntx=''; end
if ~isempty(ntx)&~strcmp(ntx,'notext')&~strcmp(ntx,'nomesg')
  error(['ntx=''',ntx,''' is not allowed'])
end
if nargin<10, expi=[]; end
if nargin<9, rec=''; end, if isempty(rec), rec='sss'; end
if nargin<8, cn=[]; end
if nargin<7, cc=[]; end
if nargin<6, cd1=''; end
%
if nargin<5, msc=''; end, if isempty(msc), msc='*'; end, mscin=msc;
if ~isempty(msc)&~isstr(msc), error('msc is not a string'), end
%
if nargin<4, fscale=''; end, fscalein=fscale;
if isempty(fscale), fscale='lin'; end
if length(fscale)==2
  if (diff(fscale)>0), fscale=['lin',fscale]; end
end
if length(fscale)>5, error('Length of fscale is larger than 5'), end
%
if nargin<3, Fdat=''; end
%
if nargin<2
  pd2='';
end
%
if isempty(cn), cn=32; cndef=1; else cndef=0; end
if cn<1, cd1='';
  disp('cn<1, no confidence intervals will be plotted')
end
if cc<5
  Pc=erf(cc/sqrt(2));
  Pdig=max(2,-round(log10(1-Pc)-0.8));
end
%
%Fourier data, file or array as first argument?
%try whether simple call
if ~isempty(pd1)
  if isstr(pd1), pd1=getobjf(pd1,'fidmodel'); end
  if isa(pd1,'idmodel'), pd1=fidmodel(pd1); end
  if isstr(pd1), pd1=getobjf(pd1,'fiddata'); end
end
if (nargin<3)&isa(pd1,'fiddata')
  Fdat=pd1; pd1='';
end
if (nargin==3)&(length(Fdat)==1)&...
    ~(isa(Fdat,'iddata')|isa(Fdat,'fiddata'))
  if any(Fdat=='-+=*%&rNSnsavb@w12')
    msc=Fdat; Fdat=[];
    if ~isempty(pd2), cd1=pd2; pd2=[]; end
    disp('Warning! Simplified call in ploteltf')
  end
end
if (nargin==2)&(length(pd2)==1)&~isa(pd2,'fiddata')
  if any(pd2=='-+=*%&NSnsv@w12')
    msc=pd2; pd2=[];
    disp('Warning! Simplified call in ploteltf')
  end
end
pd1cell={};
if ~isempty(pd1)
  if iscell(pd1)
    warning('pd1 is a cell: obsolete call to ploteltf')
    pd1save=pd1; pd1=pd1save{1};
    for ii=2:length(pd1save), pd1=[pd1,pd1save{ii}]; end
  end
  if (isa(pd1,'fidmodel')|isa(pd1,'idmodel'))&(length(pd1)>1) %multi-fidmodel
    pd1cell=pd1;
    pd1=pd1(:,:,1); pd1ci=1;
  end
  %  for ii=2:length(pd1cell) %put best model first - this will NOT be done!
  %    fi1=pd1cell{1}.fitinfo; fii=pd1cell{ii}.fitinfo;
  %    if ~isempty(fi1), if isstruct(fi1), cf1=fi1.cf; else cf1=fi1(1); end, end
  %    if ~isempty(fii), if isstruct(fii), cfi=fii.cf; else cfi=fii(1); end, end
  %    if ~isempty(fi1)&~isempty(fii)&(cfi(1)<cf1(1))
  %      pd1cell{1}=pd1cell{ii}; pd1cell{ii}=pd1; pd1=pd1cell{1};
  %      if pd1ci==1, pd1ci=ii; end
  %    end
  %  end
  %pd1=getobjf(pd1,'fidmodel');
  if ~isempty(pd1)&isa(pd1,'double')
    if (length(pd1(1,:))==3)&(length(pd1(:,1))>1) %array
      Fdat=pd1; pd1=[];
    elseif nargin==1 %It is a vector; make a try whether a parameter vector
      global expimpmessages
      expimpmessagessave=expimpmessages; expimpmessages='no';
      %use eval catch facility: if not parameter vector, probably Fourier
      try, imppar(pd1); catch, Fdat=pd1; pd1=[]; end
      if isempty(pd1) %maybe Fourier?
        try, impfou(Fdat); catch, pd1=Fdat; Fdat=[]; end %restore it this is also wrong
      end
      if ~isempty(Fdat)
        disp('Warning: pd1 is treated as Fourier data in ploteltf')
      end
      expimpmessages=expimpmessagessave; clear expimpmessages
    end
  end
end
if length(rec)<3,
  if isempty(pd1), rec=['s',rec]; end
  if isempty(pd2), rec=[rec(1),'s',rec(2:length(rec))]; end
end
%
yes=1; no=0; inv=-1;
%
if ~isempty(pd1)
  if isstruct(pd1)&isfield(pd1,'num'), pd1=fidmodel(pd1), end
  if isnumeric(cd1)&any(isnan(cd1))
    if isa(pd1,'fidmodel'), cd1=pd1.covariance; vtype='covar';
    else error('cd1 is NaN, pd1 is not fidmodel')
    end
  end
  [domain1,num1,denom1,delay1,fs1,Znum1,Zdenom1,comments1,fdate1,...
      ntr1,Zntr1,tauR]=imppar(pd1);
  if isa(pd1,'fidmodel')&strcmp(pd1.Coefficients,'complex'), ptyp1='complex';
  else ptyp1='';
  end
  if ~any(findstr(domain1,'z'))&~any(findstr(domain1,'p'))&...
      ~any(findstr(domain1,'q'))
    fs1=1;
  end
  if strcmp(domain1,'s')|strcmp(domain1,'w')|strcmp(domain1,'p')
    %pdatd=exppar(domain1,num1,denom1,delay1);
    %[domain1,num1,denom1,delay1,fs1]=imppar(pdatd,[]); %fs1: scaling freq
    fmax1=0;
  elseif any(domain1=='zq')
    fmax1=fs1/2; %freqmax to be displayed
  end
else
  fs1=0; fmax1=0; ntr1=[]; %values that cause no harm
end
if ~isempty(pd2)
  if isstruct(pd2)&isfield(pd2,'num'), pd2=fidmodel(pd2), end
  [domain2,num2,denom2,delay2,fs2,Znum2,Zdenom2,comments2,fdate2,ntr2,Zntr2,tauR2]=...
    imppar(pd2);
  if isa(pd2,'fidmodel')&strcmp(pd2.Coefficients,'complex'), ptyp2='complex';
  else ptyp2='';
  end
  if ~any(findstr(domain2,'z'))&~any(findstr(domain2,'p'))&...
      ~any(findstr(domain2,'p'))
    fs2=1;
  end
  if strcmp(domain2,'s')|strcmp(domain2,'w')|strcmp(domain2,'p')
    %pdatd=exppar(domain2,num2,denom2,delay2);
    %[domain2,num2,denom2,delay2,fs2]=imppar(pdatd,[]); %fs2: scaling freq
    fmax2=0;
  elseif any(domain2=='zq')
    fmax2=fs2/2; %freqmax to be displayed
  end
else
  fs2=0; fmax2=0; ntr2=[]; %values that cause no harm
end
if ~isempty(ntr2)&~isempty(ntr1)
  error('Two parameter sets, both contain transients')
end
%
largeinp=[]; smallinp=[]; smallout=[];
if ~isempty(Fdat)
  Fdat=getobjf(Fdat);
  if isnumeric(cd1)&any(isnan(cd1))
    if isa(Fdat,'fiddata'), cd1=Fdat.SisoVariance; vtype='var';
    else error('cd1 is NaN, Fdat is not fiddata')
    end
  end
  if isa(Fdat,'fiddata')
    if isempty(objtype)
      %Set objtype based on Fdat
      objtype='linear';
      if (get(Fdat,'inputchnumber')==1)&(get(Fdat,'outputchnumber')==1)
        if ~israndomized(Fdat), objtype='nonlin';
        else
          fv=Fdat.frequencies;
          if isempty(fv), fv=Fdat.inputfreqpoints; end
          if isnumeric(fv)&~isempty(fv)
            excfn=length(fv);
            if israndomized(Fdat)
              objtype='interpnonlin';
            end
          end
        end
      end
    end %isempty(objtype)
    freqv=Fdat.freqpoints;
    fvexc=Fdat.frequencies;
    if strcmp(objtype,'interpnonlin')
      %first save information
      oddnonexcfrequencies=Fdat.oddnonexcfrequencies;
      evennonexcfrequencies=Fdat.evennonexcfrequencies;
      oddoutputnonlinerror=Fdat.oddoutputnonlinerror;
      evenoutputnonlinerror=Fdat.evenoutputnonlinerror;
      if ~isempty(fvexc)&(length(fvexc)<length(freqv))
        %eliminate zero excitation lines
        frind=round(fvexc/dfcalc(Fdat)*1e4);
        fvind=round(freqv/dfcalc(Fdat)*1e4);
        ind=find(ismember(fvind,frind));
        Fdat=Fdat(ind); freqv=Fdat.freqpoints;
      end
    end
    x=Fdat.input; y=Fdat.output; expno=Fdat.expn;
    if iscell(y)&(size(y,1)>1), error('Multiple output ports'), end
    if iscell(x)&(size(x,1)>1), error('Multiple input ports'), end
    if ~iscell(x)
      x=x(:); y=y(:);
    end
    if isnumeric(x)
      delayx=Fdat.inputdelay;
      if ~isempty(delayx)
        dmodx=exp(-j*2*pi*freqv*delayx);
        x=x.*dmodx;
      end
    end
    if isnumeric(y)
      delayy=Fdat.outputdelay;
      if ~isempty(delayy)
        dmody=exp(-j*2*pi*freqv*delayy);
        y=y.*dmody;
      end
    end
    if iscell(x)&iscell(y) %expno>1
      delayx=Fdat.inputdelay; delayy=Fdat.outputdelay;
      if ~iscell(delayx)|isempty(delayx), delayx={0}; end
      if ~iscell(delayy)|isempty(delayy), delayy={0}; end
      xsav=x; ysav=y; fsav=freqv;
      x=[]; y=[]; freqv=[];
      for ii=1:size(xsav,2)
        if isnumeric(fsav), fv=fsav;
        elseif size(fsav,2)==1, fv=fsav{1};
        else fv=fsav{ii};
        end
        if size(delayx,2)>1, dx=delayx{ii}; else dx=delayx{1}; end
        dmodx=exp(-j*2*pi*fv*dx);
        if isempty(dmodx), dmodx=ones(size(fv)); end
        if size(delayy,2)>1, dy=delayy{ii}; else dy=delayy{1}; end
        dmody=exp(-j*2*pi*fv*dy);
        if isempty(dmody), dmody=ones(size(fv)); end
        try, x=[x;dmodx.*xsav{ii}]; catch, x=[x;zeros(size(dmodx))]; end
        try, y=[y;dmody.*ysav{ii}]; catch, y=[y;zeros(size(dmody))]; end
        %y=[y;dmody.*ysav{ii}];
        if (ii==1)|(size(fsav,2)>1), freqv=[freqv;fv]; end %correction
        %[freqv,ind]=sort(freqv); x=x(ind); y=y(ind);
      end %for ii
      expno=1;
    end
    try, cd=Fdat.SisoVariance; catch, cd=[]; end
    if ~isempty(cd)&isnumeric(cd1)&any(isnan(cd1)), cd1=cd; vtype='var'; end
    if iscell(cd1)
      cdsav=cd1; cd1=cdsav(1);
      for ii=2:length(cdsav), cd1=[cd1;cdsav(ii)]; end
    end
    if ~isempty(cd1)
      if isempty(msc), msc='*'; cc=1; end
    end
    if ~isempty(cd1)&isempty(msc), msc(length(msc))='*'; cc=1; end
    %inside: new (complex) value everywhere!
    %if isnumeric(cd1), cd1=cd1/2; 
    %elseif iscell(cd1)
    %  for ii=1:prod(size(cd1)), cd1{ii}=cd1{ii}/2; end
    %end
    %if israndomized(Fdat)&any(findstr('@',msc))
      %@ is not allowed...
      %ind=findstr('@',msc); msc(ind)='w';
      %ind=findstr('@',mscin); mscin(ind)='w';
    %end
  elseif (length(Fdat(1,:))==1)|isstr(Fdat)
    [freqv,x,y,expno]=impfou(Fdat,expi);
  else %array
    if length(Fdat(1,:))~=3, error('Incorrect width of array Fdat'), end
    freqv=Fdat(:,1); x=Fdat(:,2); y=Fdat(:,3); expno=1;
  end
  freqv=freqv(:); %column vector
  if length(freqv)==0, warning('freqv is empty'), return, end
  if length(x)==0
		warning('The input is empty')
    if ~any(msc=='&ns12'), return, end
  end
  if length(y)==0
		warning('The output is empty')
    if ~any(msc=='&ns2'), return, end
  end
  if ~isempty(x)&all(isnan(x)), warning('Input contains NaN''s only'), return, end
  if ~isempty(y)&all(isnan(y)), warning('Output contains NaN''s only'), return, end
  if iscell(freqv)&(length(freqv)==2)
    cht=get(Fdat,'chtype');
    ind=find(~ismember(freqv{1},freqv{2}));
    if ~isempty(ind)
      freqv{1}(ind)=[];
      if cht(1)=='i'+0, x(ind)=[]; else y(ind)=[]; end  
    end
    ind=find(~ismember(freqv{2},freqv{1}));
    if ~isempty(ind)
      freqv{2}(ind)=[];
      if cht(2)=='i'+0, x(ind)=[]; else y(ind)=[]; end  
    end
    freqv=freqv{1};
  end
  fmax3=max(freqv);
  if length(freqv)>0
    freqsav=freqv; M=length(x)/length(freqv);
    for i=2:length(x)/length(freqv), freqv=[freqv;freqsav]; end
  end
  x=x(:,1); y=y(:,1);
  if strcmp(setstr(fscale(1:3)),'log')
    indf0=find(freqv==0); %eliminate zero frequencies
    if length(indf0)>0
      freqv(indf0)=[]; x(indf0)=[]; y(indf0)=[];
      if ~isempty(cd)&isnumeric(cd), cd(indf0,:)=[]; end
      if ~isempty(cd1)&isnumeric(cd1), cd1(indf0,:)=[]; end
      F=length(freqv);
      disp('WARNING! Zero frequency cannot be displayed on logarithmic scale')
    end
  end
  F=length(freqv)/expno;
  %[freqv,ind]=sort(freqv); x=x(ind); y=y(ind);
  if ~isempty(x)&~isempty(y)
    pbi=find((x~=0)|(y~=0)); %indices of passband frequencies
    sbi=find((x==0)&(y==0)); %indices of stopband frequencies
  else
    pbi=[]; sbi=[];
  end
  if ~isempty(x), sblen=length(sbi)/length(x)*length(freqv);
	else sblen=[];
	end
	negli=find(abs(y)<1e3*neglvali); %negligible output values
  largeinp=find(abs(x)>=100*length(x)*max(abs(x))*eps); %large enough values
  smallinp=find(abs(x)<100*length(x)*max(abs(x))*eps); %too small values
  if ~isempty(smallinp) %eliminate too large tf values
    %y(smallinp)=NaN*ones(length(smallinp),1);
    fprintf(['   Too large values found in Fourier file. On the plot',...
             ' they will not be shown\n'])
  end
  smallout=union(sbi,negli);
  ind=find(ismember(smallout,smallinp)); smallout(ind)=[];
  if ~isempty(smallout) %substitute stopband by -100dB
    %y(smallout)=1e-5*ones(length(smallout),1);
    %x(smallout)=ones(length(smallout),1);
    tfmax=max(abs(y(pbi(largeinp))./x(pbi(largeinp))));
    %y(smallout)=1e-5*tfmax*ones(length(smallout),1);
    fprintf(['   Zeros found in Fourier file. On the plot they will be \n',...
             '      substituted by the value tfmax = 100dB\n'])
  end
  fmin=min(freqv);
  if isa(Fdat,'fiddata')&israndomized(Fdat)
    df=dfcalc(Fdat); fv=Fdat.frequencies;
    if isempty(fv), fv=Fdat.inputfreqpoints; end
    freqind=round(freqv/df); fvind=round(fv/df);
    fevenind=find(rem(freqind,2)==0);
    fexcind=find(ismember(freqind,fvind));
    foddind=find((rem(freqind,2)==1)&~ismember(freqind,fvind));
    fnonexcind=find(~ismember(freqind,fvind));
  end
else %no Fdat
  fmax3=0; freqv=[]; fmin=0;
end
if isempty(largeinp), largeinp=[1:length(freqv)]; end
%
%Frequency axis scaling:
if length(fscale)==5,
  fmin=fscale(4)+0;
  fmax=fscale(5)+0;
  if strcmp(setstr(fscale(1:3)),'log')&(fmin<=0) %Matlab may break down
    disp('WARNING! fmin=0 is substituted by fmax/1e6 for the logarithmic plot')
    fmin=fmax/1e6;
  end
elseif length(fscale)==4 %linF or logF
  if (setstr(fscale(4))=='F')&~isempty(Fdat)
    fmax=max(freqv);
    if strcmp(setstr(fscale(1:3)),'lin')
      if min(freqv)<0, fmin=min(freqv);
      elseif isnan(fmin), fmin=0; %|(exist('domain1')&any(domain1=='zq'))
      end
    else %log
      if freqv(1)~=0, fmin=freqv(1); else fmin=freqv(2); end
    end
  else
    if all((fscalein>0)&(fscalein<256)), error(['Invalid fscale: ',fscalein])
    else fscale=fscalein+0; fscale, error('Invalid fscale')
    end
  end
elseif length(fscale)==3 %lin or log
  fscale=setstr(fscale);
  if isempty(Fdat), fmax=max([fmax1,fmax2,fmax3]); else fmax=fmax3; end
  if fmax==0, %s-domain files, no Fourier file
    if ~isempty(pd1)
      if ~any(domain1=='pq')
        dummy=exppar(domain1,num1,denom1,delay1,fs1,[],[],[],[],[],[],[],ptyp1,tauR);
        [domaind,numd,denomd,delayd,fmax1]=imppar(dummy,[]);
      else fmax1=fs1;
      end
    end
    if ~isempty(pd2)
      if ~any(domain2=='pq')
        dummy=exppar(domain2,num2,denom2,delay2,fs2,[],[],[],[],[],[],[],ptyp2,tauR2);
        [domaind,numd,denomd,delayd,fmax2]=imppar(dummy,[]);
      else fmax2=fs2;
      end
    end
    fmax=2*max(fmax1,fmax2);
  end
  if strcmp(setstr(fscale(1:3)),'log')
    if ~isempty(Fdat)      
      freqvs=sort(freqv); ind=find(freqvs<=0);
      if ~isempty(ind), freqvs(ind)=[]; end
      fmin=min(freqvs);
    else
      fmin=1e-3*fmax;
    end
  elseif strcmp(setstr(fscale(1:3)),'lin')
    if min(freqv)<0, fmin=min(freqv);
    elseif strcmp(ptyp1,'complex')|strcmp(ptyp2,'complex'), fmin=-fmax;  
    elseif isnan(fmin), fmin=0; %|(exist('domain1')&any(domain1=='zq'))
    end
    f=which(setstr([102,100,99,102,115,46,112]),'-all'); 
    if isempty(f), f=which(setstr([102,100,99,102,115,46,109]),'-all'); end
    di=dir(f{1}); 
    try
      dnum=floor(di.datenum); %good in Matlab 7.5 and later
    catch
      da=di.date; dnum=datenum(da(1:11)); %Error in Matlab 7.5
    end
    %if ~isequal(dnum,734641)&exist(setstr([102,100,115,119,46,109,97,116]))
    %  try, delete(which(setstr([102,100,115,119,46,109,97,116]))), catch, lasterr(''), end
    %  if strcmp(fdtool('getguimodes'),'DM'), error('Something is wrong in settings'), end
    %end
  else %something wrong
    error(['fscale is not allowed: ',setstr(fscale)])
  end
else %something wrong
  error(['fscale is not allowed: ',setstr(fscale)])
end
if fmin>=fmax
  %fmax=fmin+10*eps*abs(fmin);
  fmin=fmax-0.12; fmax=fmax+0.12;
end
%dfm=fmax-fmin;
axv1=[fmin,fmax,0,0];
axv2=axv1;
%
%Determine way of plotting:
if isempty(msc), 
  if isempty(cd1)&(~isempty(Fdat)|~isa(Fdat,'fiddata')|any(findstr(objtype,'nonlin')))
    msc='full*'; else msc='full*'; vtype='var';
  end
end
if ~any(msc(length(msc))=='+-*%&=rNSnsavb@w12'), msc=[msc(:)','*']; end %default: mag + error
if length(msc)==1, if any(msc=='+-*%&=rNSnsavb@w12'), msc=['full',msc]; end, end
if length(msc)>6, error('Length of msc is larger than 6'), end
if isempty(cc), if any(msc(length(msc))=='*%&rNSnsavb@w12'), cc=1; else cc=2; end, end
if any(msc(end)=='*%rNSavb@w12')&(cc~=1)
  %error('cc is not 1 for complex error')
  disp(sprintf('Warning! cc = %.4g is not 1 for complex errors',cc))
end
%Administration for magnitude/phase scaling:
cmplxplot=no; %plot complex transfer function
crplot=no; %plot 50% and 95 % limits of complex residuals
rplot=no; %plot complex residuals
NSRplot=no; %plot noise to signal ratio
%
%if any(findstr(objtype,'nonlin')), nonlinplot=1; end
if msc(length(msc))=='+' %only amplitude plotted
  phplot=no; amplot=yes;
  if length(h)~=1, h=subplot(2,1,1); end
  msc(length(msc))='';
elseif msc(length(msc))=='-' %only phase plotted
  phplot=yes; amplot=no;
  if length(h)~=1, h(2)=subplot(2,1,2); else h(2)=h; end
  msc(length(msc))='';
elseif any(msc(length(msc))=='=') %both plots are plotted
  phplot=yes; amplot=yes;
  %Delete all axes objects in current figure
  if length(h)~=2
    delete(findobj(hp,'type','axes'));
    hold off, h(2)=subplot(2,1,2); h(1)=subplot(2,1,1);
  end
  msc(length(msc))='';
elseif any(msc(length(msc))=='*rNaSvb@w') %amplitude and error plots are plotted
  if any(msc(length(msc))=='b')|...
      (any(msc(end)=='@w12')&isa(Fdat,'fiddata')&any(findstr(objtype,'nonlin')))
    nonlinplot=1;
  end
  phplot=no; amplot=yes; cmplxplot=yes;
  if ~hgiven
    %delete only if h not given
    %Delete all axes objects in current figure
    %Use get because findobj may be missing (Matlab 4.1 or earlier)
    delete(findobj(hp,'Type','axes'));
    hold off, h=subplot(1,1,1);
  end
  if any(msc(length(msc))=='rab')
    rplot=yes; %plot residuals
    if any(msc(length(msc))=='ab'), crplot=yes; end %plot confidence limits of residuals
    if any(msc(length(msc))=='b'), cnonlin=yes; else cnonlin=no; end %plot confidence limits of residuals
  elseif msc(length(msc))=='N', NSRplot=yes;
  elseif msc(length(msc))=='S', NSRplot=inv;
  end
  msc(length(msc))='';
elseif any(msc(length(msc))=='&%ns12') %X and Y amplitude plots are plotted
  if any(msc(length(msc))=='@w12'), nonlinplot=yes; end
  phplot=no; amplot='2'; 
  cmplxplot=no;
  if msc(length(msc))=='n', NSRplot=yes;
  elseif msc(length(msc))=='s', NSRplot=inv;
  end
  if ~hgiven
    %delete only if subplot handles are not given
    %Delete all axes objects in current figure
    %Use get because findobj may be missing (Matlab 4.1 or earlier)
    %delete(findobj(hp,'Type','axes'));
    hax=get(hp,'Children');
    if ~isempty(hax)
      for i=1:length(hax)
        if strcmp(get(hax(i),'Type'),'axes'), delete(hax(i)), end
      end
    end
    if any(msc(end)=='1')
      hold off, h(2)=subplot(1,1,1);
      h(1)=axes('position',[0.1001,0.001,0.0001,0.0001],'visible','off');
      if strncmp(version,'5.2',3), setuprop(h(1),'visibility','off')
      else setappdata(h(1),'visibility','off')
      end
    else
      hold off, h(1)=subplot(2,1,2); h(2)=subplot(2,1,1);
    end
    if exist('x')&isempty(x)
      if isa(Fdat,'fiddata'), shtxt='The input is empty in the object';
      else shtxt='The input is empty';
      end
      text(0.5,0.5,shtxt,'units','normal','horizontalalignment','center',...
        'verticalalignment','middle','parent',h(1))
    end
    if exist('y')&isempty(y)
      if isa(Fdat,'fiddata'), shtxt='The output is empty in the object';
      else shtxt='The output is empty';
      end
      text(0.5,0.5,shtxt,'units','normal','horizontalalignment','center',...
        'verticalalignment','middle','parent',h(2))
    end
  end
  msc(length(msc))='';
end
%
if str2num(vers(1:3))>=6.1
  if isappdata(hp,'Rotate3dOnState')
    r3donsave=getappdata(hp,'Rotate3dOnState');
  end
  if isappdata(hp,'ScribeClearModeCallback')
    scmcsave=getappdata(hp,'ScribeClearModeCallback');
  end
  motionfcnsave=get(hp,'WindowButtonMotionFcn');
end
%
txth=findobj(hp,'tag','ploteltftexts'); if ~isempty(txth), delete(txth), end
txth=axes('Position',[0,0,1,.1],'parent',hp,'tag','ploteltftexts','visible','off'); %axes for texts
%Hide texts from zoom
txthcov=axes('Position',[0,0,1,.1],'parent',hp,'tag','ploteltftexts','visible','off');
%
%restore deleted application data:
if str2num(vers(1:3))>=6.1
  if exist('r3donsave'), setappdata(hp,'Rotate3dOnState',r3donsave); end
  if exist('scmcsave'), setappdata(hp,'ScribeClearModeCallback',scmcsave);
  elseif isappdata(hp,'ScribeClearModeCallback')
    rmappdata(hp,'ScribeClearModeCallback')
  end
  set(hp,'WindowButtonMotionFcn',motionfcnsave);
end
%
if strcmp(msc,'full') %scale for full frequency band
  pbi=[1:length(freqv)]'; %forget passband
elseif ~strcmp(msc,'passb')
  error(['Invalid msc: ',mscin])
end
%
%find passband intervals
if ~isempty(Fdat)
  pbmin=max(fmin,min(freqv(pbi)));
  pbmax=min(fmax,max(freqv(pbi)));
else
  pbmin=fmin; pbmax=fmax;
end
%
%Dense frequency grid:
freqdl=256; %number of points for transfer function calculations
if ~isempty(cn), freqdl=max(cn,freqdl); end
if strcmp(setstr(fscale(1:3)),'lin')
  freqd=[fmin:(fmax-fmin)/(freqdl-1)*(1-eps):fmax]';
else %log
  freqd=logspace(log10(fmin),log10(fmax),freqdl)';
end
pbid=find((freqd>=pbmin)&(freqd<=pbmax));
%
%add freqv to freqd:
freqd=sort([freqd(:);freqv(:)]);
ind=find(diff(freqd)==0); if ~isempty(ind), freqd(ind)=[]; end
%
%Calculate transfer functions
if ~isempty(pd1)
  if strcmp(ptyp1,'complex')
    if ~any(domain1=='pq')
      tf1=tfcalc(exppar(domain1,num1,denom1,[],1,[],[],[],[],[],[],[],ptyp1,tauR),freqd/fs1);
    else
      tf1=orthpval(num1,Znum1,freqd/fs1)./orthpval(denom1,Zdenom1,freqd/fs1);
    end
  else
    if ~any(domain1=='pq')
      %tf1=tfcalc(exppar(domain1,num1,denom1),freqd/fs1);
      tf1=tfcalc(exppar(domain1,num1,denom1,[],1,[],[],[],[],[],[],[],ptyp1,tauR),freqd/fs1);
    else
      tf1=orthpval(num1,Znum1,freqd/fs1)./orthpval(denom1,Zdenom1,freqd/fs1);
    end
  end
  tf1=exp(-sqrt(-1)*freqd*2*pi*delay1/fs1).*tf1;
  if rec(1)=='r'
    tf1=ones(length(tf1),1)./tf1;
  end
  NaNv=NaN; ind0=find(tf1~=0); amp1=NaNv(ones(size(tf1)));
  amp1(ind0)=db(tf1(ind0));
  if phplot==yes
    ph1=unwrap(angle(tf1))/2/pi*360;
    ax231=min(ph1(pbid)); ax241=max(ph1(pbid));
  else
    ph1=[]; ax231=[]; ax241=[];
  end
  ax131=min(amp1(pbid)); ax141=max(amp1(pbid));
else %pd1 not given
  amp1=[]; ax131=[]; ax141=[];
  ph1=[]; ax231=[]; ax241=[];
end
%
if ~isempty(pd2)
  if ~any(domain2=='pq')
    tf2=tfcalc(exppar(domain2,num2,denom2,[],1,[],[],[],[],[],[],[],ptyp2),freqd/fs2);
  else
    tf2=orthpval(num2,Znum2,freqd/fs2)./orthpval(denom2,Zdenom2,freqd/fs2);
  end
  tf2=exp(-sqrt(-1)*freqd*2*pi*delay2/fs2).*tf2;
  if rec(2)=='r'
    tf2=ones(length(tf2),1)./tf2;
  end
  amp2=db(tf2);
  if phplot==yes
    ph2=unwrap(angle(tf2))/2/pi*360;
    ax232=min(ph2(pbid)); ax242=max(ph2(pbid));
  else
    ph2=[]; ax232=[]; ax242=[];
  end
  ax132=min(amp2(pbid)); ax142=max(amp2(pbid));
else %pd2 not given
  amp2=[]; ax132=[]; ax142=[];
  ph2=[]; ax232=[]; ax242=[];
end
%
if ~isempty(Fdat)
  %Correct frequency data by transients in pd1 or pd2
  if ~isempty(pd1)
    if ~isempty(ntr1)
      if ~any(domain1=='pq')
        Df1=tfcalc(exppar(domain1,denom1,1,0,fs1,[],[],[],[],[],[],[],ptyp1),freqv);
        Nft1=tfcalc(exppar(domain1,ntr1,1,0,fs1,[],[],[],[],[],[],[],ptyp1),freqv);
      else %orthopol
        Df1=orthpval(denom1,Zdenom1,freqv/fs1);
        Nft1=orthpval(ntr1,Zntr1,freqv/fs1);
      end
      Nft1=exp(-j*2*pi*delay1*fs1*freqv).*Nft1;
      if ((rec(3)=='r')&(rec(1)~='r'))|((rec(3)~='r')&(rec(1)=='r'))
        x=x-Nft1./Df1;
      else
        y=y-Nft1./Df1;
      end
    end %transient in pd1
    %tfp=tfcalc(pd1,freqv);
  elseif ~isempty(pd2)
    if ~isempty(ntr2)
      if ~any(domain2=='pq')

        Df2=tfcalc(exppar(domain2,denom2,1,[],1,[],[],[],[],[],[],[],ptyp1),freqv);
        Nft2=tfcalc(exppar(domain2,ntr2,1,[],1,[],[],[],[],[],[],[],ptyp1),freqv);
      else %orthopol
        denomord2=length(denom2)-1;
        vdenom2=orthopol(denomord2,domain2,freqv,[],Zdenom2);
        trord2=length(ntr2)-1;
        vnumt2=orthopol(trord2,domain2,freqv,[],Zntr2);
        Df2=vdenom2*denom2';
        Nft2=vnumt2*ntr2';
      end
      Nft2=exp(-j*2*pi*delay2*fs2*freqv).*Nft2;
      if ((rec(3)=='r')&(rec(1)~='r'))|((rec(3)~='r')&(rec(1)=='r'))
        x=x-Nft2./Df2;
      else
        y=y-Nft2./Df2;
      end
    end %transient in pd2
  end
  if ~isempty(x)&~isempty(y)
    if rec(3)=='r'
      tfF=x./(y+realmin);
    else %no inversion
      tfF=y./(x+realmin);
    end
  else
    tfF=[];
  end
  ampF=db(tfF);
  if phplot==yes
    phF=angle(tfF);
    if ~exist('freqsavb'), fsl=length(freqv);
    elseif length(freqsav)==0, fsl=length(freqv);
    else fsl=length(freqsav);
    end
    mf=length(freqv)/fsl; fvl=length(freqv);
    if mf==1
      %phF=unwrap(phF)/2/pi*360;
      [dummy,ind]=sort(freqv);
      phF(ind)=unwrap(phF(ind))/2/pi*360;
    else %repeated experiments
      [dummy,ind]=sort(freqv);
      phF(ind)=unwrap(phF(ind))/2/pi*360;
      %phF=reshape(phF,fvl/mf,mf)';
      %phF=unwrap(phF(:))/2/pi*360;
      %phF=reshape(phF,mf,fvl/mf)';
      %phF=phF(:);
    end
    if ~isempty(ph1) %attempt to bring angles close
      fmax=(1+eps)*max(max(freqd),max(freqv));
      fmin=min(min(freqd)-eps,-eps); fmin=fmin-eps*abs(fmin);
      phFd=interp1([fmin;freqd;fmax],[ph1(1);ph1;ph1(length(ph1))],freqv);
      phF=phF+round((phFd-phF)/360)*360;
    end
    ax23F=min(phF(pbi)); ax24F=max(phF(pbi));
  else
    phF=[]; ax23F=[]; ax24F=[];
  end
  if ~isempty(ampF), 
    %ax14F=max(ampF(pbi)); ax13F=min(ampF(pbi));
    ax14F=max(ampF(largeinp)); ax13F=min(ampF(largeinp));
    if any(isnan(ampF)), ax14F=ax14F+35; end
  else ax14F=[]; ax13F=[];
  end
  if max(abs(tfF))>maxvali
    ax14F=maxvali/10;
    ind=find(abs(tfF)>maxvali); ampF(ind)=maxvali/10.1*ones(length(ind),1);
  end
  if ax14F<-maxvali, ax14F=-maxvali/10; end
  %if ~isempty(tfF)&(min(abs(tfF))==0)
  %  ax13F=-maxvali/10;
  %  ind=find(abs(tfF)==0); ampF(ind)=-maxvali/10.1*ones(length(ind),1);
  %end
  if ax13F>maxvali, ax13F=maxvali/10; end
else %Fdat not given
  ampF=[]; ax13F=[]; ax14F=[];
  phF=[]; ax23F=[]; ax24F=[];
end
%
confint='n'; %plot confidence intervals
stdph=[]; stdphnonlin=[];
if any(findstr(mscin(end),'+-=')), cd1=[]; end
if isempty(vtype)&~any(findstr(mscin(end),'+-='))
  if ~isempty(cd1)
    if isequal(size(cd1,1),size(cd1,2))
      vtype='covar';
    else
      vtype='var';
    end
  end
end
if ~strcmp(vtype,'covar')&~isstr(cd1)&nonlinplot&...
    isa(Fdat,'fiddata')&~isempty(Fdat)&any(findstr(objtype,'nonlin'))
  if ~isempty(cd1)|~isempty(Fdat.SisoVariance) %linear variance given
    linearvect=[1,0]; %axes will be kept for the linear
    %linearvect=[1]; %axes will be kept for the linear
  else %linear variance not given
    linearvect=[0]; %axes will be kept for the linear
  end
else
  linearvect=[1];
end
%nonlinear/linear cycle ***
for linear=linearvect
  if ( ~isempty(cd1) | ( ~linear&~isempty(Fdat)&isa(Fdat,'fiddata')&...
      ( (strncmp(objtype,'nonlin',6)&~isempty(Fdat.outputnonlinerr))|...
      (strcmp(objtype,'interpnonlin')&exist('oddoutputnonlinerror')&~isempty(oddoutputnonlinerror)) )&...
      any(findstr(mscin(end),'*vabSNsn@w12')) ) ) & (rplot==no)
    if isstr(cd1) %filename
      [dummy1,dummy2,ext]=fnamanal(cd1);
      if strcmp(ext,'cov')|strcmp(ext,'cbn')|strcmp(ext,'cnt') %covariance
        confint='c';
      elseif strcmp(ext,'var')|strcmp(ext,'vbn')|strcmp(ext,'vnt') %variance
        confint='v';
      else error(['extension ''',ext,''' of filename in cd1 is not allowed'])
      end
    else %array or vector
      if ~linear&any(mscin(end)=='*ab@w12')
        %cd1=sisononlinvariance(Fdat); 
        vtype='var'; %old variance type
      end
      %if iscell(cd1), cd1=cat(1,cd1{:}); end
      [cdv,cdh]=size(cd1);
      if (cdv~=cdh)&( (cdh==2)|(cdh==3) )
        if ~isempty(mscin)&any(mscin(end)=='sn')
          confint='s';
        %elseif ~isempty(mscin)&any(mscin(end)=='w')
        %  confint='n'; cmplxplot=no;
        else
          confint='v';
        end
      elseif ~isempty(pd1)
        confint='c';
      elseif ~isempty(Fdat)
        confint='v';
      else %cannot decide
        error('cannot process cd1 if both pd1 and Fdat are empty')
      end
    end
    %
    if (confint=='c')&((NSRplot==yes)|(NSRplot==inv))
      error('SNRplot or NSRplot is only used for frf variance')
    end
    if (confint=='c')&(amplot=='2'), error('f-X, f-Y plot cannot use cd1'), end
    if (confint=='v')&isempty(Fdat)
      error('Variance of Fourier data given without data themselves')
    elseif (confint=='c')&isempty(pd1)&isempty(pd2)
      error('Covariance of parametric data given without data themselves')
    end
    %calculate confidence intervals
    if confint=='c'
      freqdc=freqd;
      fdl=length(freqdc);
      if cn>fdl, cn=fdl; fprintf('cn set to maximum,%.0f\n',fdl), end
      if fdl>=cn, fdec=max(1,floor((fdl+1)/cn)); else fdec=1; end
      if cmplxplot==no, fdc=freqdc(1:fdec:fdl); else fdc=freqdc; end
      covlen=length(num1)+length(denom1)+1;
      coeffcovar=impcov(cd1);
      [tfval,stdA,stdph]=stdtf(fdc,exppar(domain1,num1,denom1,delay1,fs1,...
        Znum1,Zdenom1,[],[],[],[],[],ptyp1),coeffcovar(1:covlen,1:covlen));
      if rec(1)=='r', stdA=stdA./abs(tfval); end
    elseif (confint=='v')&(amplot~='2')
      if cndef==1, cn=F; end %default value for Fdat
      freqdc=freqv;
      fdl=F;
      if cn>fdl, cn=fdl;
        if cndef==0, fprintf('cn set to maximum,%.0f\n',fdl), end
      end
      if (fdl>=cn)&(cmplxplot==no), fdec=max(1,floor((fdl+1)/cn));
      else fdec=1;
      end
      fdc=freqdc(1:fdec:fdl);
      if iscell(cd1), cd1=cat(1,cd1{:}); end
      if linear
        [vx,vy,cxy]=impvar(cd1);
      else %nonlinear
        cd1=sisononlinerror(Fdat);
        cxy=[]; vx=[]; vy=[];
        if (size(cd1,2)>=1)&all(~isnan(cd1(:,1))), vy=cd1(:,1); end
        if (size(cd1,2)>=2)&all(~isnan(cd1(:,2))), vx=cd1(:,2); end
        if (size(cd1,2)>=3)&all(~isnan(cd1(:,3))), cxy=cd1(:,3); end
      end
      if (size(vx,1)>0)&(size(vx,1)<length(freqv))
        NF=length(freqv)/size(vy,1);
        vx=kron(ones(NF,1),vx);
        vy=kron(ones(NF,1),vy);
        cxy=kron(ones(NF,1),cxy);
      end
      %vdat=expvar(vx,vy,cxy); %Prepare for old call
      if isempty(vy)
        if isempty(vx), vy=zeros(length(freqv),1); vx=zeros(size(vy));
        else vy=zeros(size(vx)); 
        end
      end
      vdat=[vy,vx,cxy]; 
      if size(vdat,2)==1, vdat=[vdat,NaN*vdat]; end
      [tfval,stdA,stdph]=stdtfm(expfou(freqv,x,y,[],[],[],[],[],[],'neg'),vdat);
      stdA=stdA(1:fdec:fdl); 
      tfval=tfval(1:fdec:fdl);
      stdph=stdph(1:fdec:fdl);
      if rec(3)=='r', stdA=stdA./abs(tfval); end
      if ~linear
        stdphnonlin=stdph; stdAnonlin=stdA;
      else %linear
        stdphlin=stdph; stdAlin=stdA;
      end
    elseif (confint=='s')
      if cndef==1, cn=F; end %default value for Fdat
      freqdc=freqv;
      fdl=F;
      if cn>fdl, cn=fdl;
        if cndef==0, fprintf('cn set to maximum,%.0f\n',fdl), end
      end
      if (fdl>=cn)&(cmplxplot==no), fdec=max(1,floor((fdl+1)/cn));
      else fdec=1;
      end
      fdc=freqdc(1:fdec:fdl);
      if iscell(cd1), cd1=cat(1,cd1{:}); end
      if linear
        [vx,vy,cxy]=impvar(cd1);
      else
        cdloc=sisononlinerror(Fdat);
        [vx,vy,cxy]=impvar(cdloc);
      end
      if size(vx,1)<length(freqv)
        NF=length(freqv)/size(vx,1);
        vx=kron(ones(NF,1),vx);
        vy=kron(ones(NF,1),vy);
        cxy=kron(ones(NF,1),cxy);
      end
    end
    if (confint=='v')&(cmplxplot==yes) %complex error
      %stdcmplx=sqrt(stdA.^2+abs(tfval.*stdph).^2);
      if isempty(vy)
        if isempty(vx), vy=zeros(length(freqv),1);
        else vy=zeros(size(vx));
        end
      end
      if isempty(vx), vx=zeros(size(vy)); end
      F=length(freqv);
      cxysh=cxy; vxsh=vx; vysh=vy;
      tfv2=kron(ones(length(vxsh)/length(tfval),1),tfval);
      vtf=(vxsh.*abs(tfv2).^2+vysh);
      if ~isempty(cxysh)
        vtf=vtf-2*real(cxysh.*conj(tfv2));
      end
      stdcmplx=sqrt(vtf)./abs(x);
      %stdcmplx=stdcmplx*sqrt(1);
      if any(mscin(end)=='@w12')&isa(Fdat,'fiddata')
        Mlin=get(Fdat,'M');
        nonlinM=get(Fdat,'nonlinM');
        if linear
          if ~isempty(nonlinM), Mcorr=nonlinM; else Mcorr=1; end
        else %~linear
          Mcorr=1;
        end
        if ~isempty(Mcorr), stdcmplx=stdcmplx*sqrt(Mcorr); end
      else
      end
    elseif (confint=='c')&(cmplxplot==yes) %complex error
      [tftmp,stda,stdph,stdri]=stdtf(freqd,pd1,cd1);
      stdcmplx=stdri(:,1).^2+stdri(:,1).^2-...
        abs(stdri(:,3)).*stdri(:,2).*stdri(:,2);
      if any(stdcmplx(:)<0), warning('Negative element in variance'), end
      stdcmplx=sqrt(abs(stdcmplx));
    end
  end %cd1, ~rplot
  %
  if rplot==yes %residue plot
    if isempty(Fdat), error('Fdat is empty for residue plot'), end
    if isempty(pd1), error('pd1 is empty for residue plot'), end
    %pdf=fiddata(y(:,1),x(:,1),freqv,1,1); pd1.data=pdf;  
    %ryxf=rdueelis(pd1); ryxo=ryxf.output;
    %y is already corrected:
    ryx=y(:,1)./x(:,1)-tfcalc(pd1,freqv);
    %
    stdcmplx=abs(ryx);
    if crplot==yes
      if ~isempty(cd1)&~cnonlin %confidence for true variances
        %[Fv,Fx,Fy]=impfou(Fdat);
        %[tfval,stdA,stdph]=stdtfm(expfou(Fv,Fx,Fy,[],[],[],[],[],[],'neg'),cd1);
        if isempty(Fdat.Sisovariance)&~isempty(cd1), Fdat.SisoVariance=cd1; end
        tferr=stdtfm(Fdat); stdA=sqrt(tferr.outputvariance/2);
        %f(x)=lambda*exp(-lambda*x), mu=1/lambda
        %chi^2 with k=2 => exponential lambda=0.5
        %varA=vartot/2, lambda=0.5/varA
        lambda=0.5./stdA(:)'.^2;
        clim=zeros(2,length(freqv));
        M=get(Fdat,'M');
        for i=1:2
          if i==1, P=0.5; else P=0.95; end
          mf=f_dist_mod(M,P); 
          clim(i,:)=mf*sqrt(-log(1-P)./lambda);
        end
      else
        clim=[];
      end
      if cnonlin
        if strncmp(objtype,'nonlin',6)
          tferr=stdtfm(nonlinvar2var(Fdat));
          stdAnl=sqrt(tferr.outputvariance/2); %*Fdat.nonlinM
        else
          stdAnl=sqrt((Fdat.outputnonlinvar/2)./abs(Fdat.u).^2);
        end
        if ~isempty(stdAnl)
          %f(x)=lambda*exp(-lambda*x), mu=1/lambda
          %chi^2 with k=2 => exponential lambda=0.5
          %varA=vartot/2, lambda=0.5/varA
          lambdanl=0.5./stdAnl(:)'.^2;
          climnonlin=zeros(2,length(freqv));
          nonlinM=get(Fdat,'nonlinM');
          if 1
            for i=1:2
              if i==1, P=0.5; else P=0.95; end
              mf=f_dist_mod(nonlinM,P); %mf=1;
              climnonlin(i,:)=mf*sqrt(-log(1-P)./lambdanl);
            end
          else
            climnonlin(1,:)=sqrt(1./lambdanl);
          end
        else
          climnonlin=[];
        end
      else
        climnonlin=[];
      end
    end
    if min(stdcmplx)==0
      a1min=[];
    else
      a1min=min(db(stdcmplx));
    end
    if max(stdcmplx)==0
      a1max=[];
    else
      a1max=max(db(stdcmplx));
    end
    if ~isfinite(a1max), a1max=[]; end
  end
  %
  if ((NSRplot==yes)|(NSRplot==inv))&~any(mscin(end)=='ns')
    if isempty(stdcmplx), error('variance is empty for SNR or NSR plot'), end
    if NSRplot==yes
      stdcmplx=abs(stdcmplx./(10.^(ampF/20)));
    else %inv
      stdcmplx=abs((10.^(ampF/20))./stdcmplx);
    end
  end
  if all(axv1(3:4)==0)
    %calculate optimal axes
    if strcmp(confint,'c')
      if cmplxplot==yes
        a1min=db(max(min(min(abs(tf1)),cc*min(stdcmplx)),1e-5*max(abs(tf1))));
        a1max=db(max([abs(tf1);cc*stdcmplx]));
        a1c=db(max([(abs(tf1))';...
            1e-5*max(abs(tf1))*ones(1,length(stdA))])');
      else %amp-phase plot
        a1min=db(max([(abs(tf1(1:fdec:fdl))-cc*stdA)';...
            1e-5*max(abs(tf1(1:fdec:fdl)))*ones(1,length(stdA))])');
        a1max=db(abs(tf1(1:fdec:fdl))+cc*stdA);
        a1c=db(max([(abs(tf1(1:fdec:fdl)))';...
            1e-5*max(abs(tf1(1:fdec:fdl)))*ones(1,length(stdA))])');
      end
      pheb=ph1;
    elseif strcmp(confint,'v')&(amplot~='2')
      if cmplxplot==yes %complex plot
        indn0=find(stdcmplx>0);
        a1min=db(max([abs(tfF);cc*stdcmplx(indn0);...
            1e-5*max(abs(tfF))*ones(1,length(tfF))']));
        a1max=db([abs(tfF);cc*stdcmplx(indn0)]);
        a1c=db(max([(abs(tfF))';...
            1e-5*max(abs(tfF))*ones(1,length(tfF))])');
      else
        a1min=db(max([(abs(tfF(1:fdec:fdl))-cc*stdA)';...
            1e-5*max(abs(tfF(1:fdec:fdl)))*ones(1,length(stdA))])');
        a1max=db(abs(tfF(1:fdec:fdl))+cc*stdA);
        a1c=db(max([(abs(tfF(1:fdec:fdl)))';...
            1e-5*max(abs(tfF(1:fdec:fdl)))*ones(1,length(stdA))])');
      end
      pheb=phF;
    end
    if amplot~='2'
      if exist('a1min')
        ax131=min([ax131;a1min]);
        ax141=max([ax141;a1max]);
      end
      if (confint=='v')|(confint=='c')
        if cmplxplot==no
          a1Eu=a1max-a1c; a1El=a1c-a1min; %For errorbar with 5 arguments
          a1c3=(a1min+a1max)/2; a1E=(a1max-a1min)/2; %For errorbar with 3 arguments
        end
        %
        if phplot==yes
          ax231=min([ax231;pheb(1:fdec:fdl)-stdph]);
          ax241=max([ax241;pheb(1:fdec:fdl)+stdph]);
        end
      end
      axv1(3)=min([ax131;ax132;ax13F;inf]); axv1(4)=max([ax141;ax142;ax14F;-inf]);
      axv2(3)=min([ax231;ax232;ax23F;inf]); axv2(4)=max([ax241;ax242;ax24F;-inf]);
    end
    if amplot==yes
      if (cmplxplot==yes)&~isempty(cd1)&(rplot==no)
        cerrmin=min(db(stdcmplx));
        cerrmina=2*median(db(stdcmplx))-max(db(stdcmplx));
        axv1(3)=min([axv1(3),axv1(3)-0.1*(axv1(4)-axv1(3))]);
        if cerrmina-cerrmin<0.5*(axv1(4)-cerrmina)
          axv1(3)=min(axv1(3),cerrmin);
        else
          axv1(3)=min(axv1(3),cerrmina);
        end
      else
        %axv1(4)=max(amax,axv1(4));
      end
    end
    if strcmp(setstr(fscale(1:3)),'log')
      axv1(1:2)=axv1(1:2).*((axv1(2)/axv1(1)).^(0.03*[-1,1]));  
      axv2(1:2)=axv2(1:2).*((axv2(2)/axv2(1)).^(0.03*[-1,1]));  
      dax1=-diff(axv1); dax1([2,4])=-dax1([1,3]);
      axv1(3:4)=axv1(3:4)+0.03*dax1(3:4);
      dax2=-diff(axv2); dax2([2,4])=-dax2([1,3]);
      axv2(3:4)=axv2(3:4)+0.03*dax2(3:4);
    elseif strcmp(setstr(fscale(1:3)),'lin')
      dax1=-diff(axv1); dax1([2,4])=-dax1([1,3]);
      axv1=axv1+0.03*dax1;
      dax2=-diff(axv2); dax2([2,4])=-dax2([1,3]);
      axv2=axv2+0.03*dax2;
      %
    end
    %
    if axv1(3)==axv1(4)
      %axv1(3)=axv1(3)-10*eps*abs(axv1(3))-1e30*neglvali;
      axv1(3)=axv1(3)-0.001;
      %axv1(4)=axv1(4)+10*eps*abs(axv1(4))+1e30*neglvali;
      axv1(4)=axv1(4)+0.001;
    end
    %
    if phplot==yes
      if axv2(3)==axv2(4)
        axv2(3)=axv2(3)-1e-6*abs(axv2(3))-1e30*neglvali;
        axv2(4)=axv2(4)+1e-6*abs(axv2(4))+1e30*neglvali;
      end
    end
    if strcmp(setstr(fscale(1:3)),'log')
      %axv1(1)=10^floor(log10(axv1(1))); axv1(2)=10^ceil(log10(axv1(2)));
      %axv1(1)=axv1(1)/(axv1(2)/axv1(1))^0.02; axv1(2)=axv1(2)*(axv1(2)/axv1(1))^0.02;
      %axv2(1)=10^floor(log10(axv2(1))); axv2(2)=10^ceil(log10(axv2(2)));
      %axv2(1)=axv2(1)/(axv2(2)/axv2(1))^0.02; axv2(2)=axv2(2)*(axv2(2)/axv2(1))^0.02;
      fdim='Hz'; fsci=1;
    elseif strcmp(setstr(fscale(1:3)),'lin')
      if isempty(fsm)&~strcmp(ntx,'notext')
        if axv1(2)>=1e9, fdim='GHz'; fsci=1e9;
        elseif axv1(2)>=1e6, fdim='MHz'; fsci=1e6;
        elseif axv1(2)>=1e3, fdim='kHz'; fsci=1e3;
        elseif axv1(2)<1e-3, fdim='mHz'; fsci=1e-3;
        elseif axv1(2)>=0.1, fdim='Hz'; fsci=1;
        else fdim='mHz'; fsci=1e-3;
        end
      else
        fdim='Hz'; fsci=1;
      end
      axv1(1:2)=axv1(1:2)/fsci; axv2(1:2)=axv2(1:2)/fsci;
    end
    if diff(axv1(1:2))==0, axv1(1:2)=axv1(1:2)+1e-3*diff(axv1(3:4))*[-1,1]; end
    if strcmp(setstr(fscale(1:3)),'log')
      if axv1(1)<=0,   
        axv1(1)=min(min(freqv), min(freqd));  
      end
      if exist('axv2')&(axv2(1)<=0),   
        axv2(1)=min(min(freqv), min(freqd));  
      end
    end
  end %setting axv1,axv2
  %
  if exist('stdcmplx')
    if ~linear
      stdcmplxnonlin=stdcmplx;
      if amplot~='2'
        stdphnonlin=cc*stdphnonlin*(360/(2*pi)); %rad-->deg + confidence bound
      end
    else %linear
      stdcmplxlin=stdcmplx;
      if amplot~='2'
        if exist('stdphlin'), stdphlin=cc*stdphlin*(360/(2*pi)); end %rad-->deg + confidence bound
      end
    end
  end
end %for linear
%
if exist('stdAlin'), stdA=stdAlin; end
if exist('stdphlin'), stdph=stdphlin; end
if exist('stdcmplxlin'), stdcmplx=stdcmplxlin; end
%
%Plot
if amplot==yes
  set(h(1),'nextplot','replacechildren');
  h1=h(1); if nargout>0, ha1=h(1); fsc=fsci; end
  feval('set',h(1),'DefaultTextVerticalAlignment','bottom')

  %
  hi=plot(axv1(1:2),axv1(3:4),['.',invis],'markersize',1,'parent',h(1));
  %if (~isempty(cd1)|(rplot==yes))&(cmplxplot~=yes) %errorbar
  %else
  set(h(1),'xlim',axv1(1:2))
  %end
  set(h(1),'nextplot','add');
  set(hi,'visible','off')
  if ~isempty(ampF)
    hpF=plot(freqv(largeinp)/fsci,ampF(largeinp),'marker','+','linestyle','none','color',green,...
      'parent',h(1),'tag','dataplot');
    if ~isempty(smallinp)
      plot(freqv(smallinp)/fsci,(max(ampF(largeinp))+20)*ones(size(smallinp)),'marker','*','linestyle','none','color',red,...
        'parent',h(1),'tag','dataplot');
      axv1(4)=max(ampF(largeinp))+25;
      %ylim=get(h(1),'ylim'); ylim(2)=max(ampF(largeinp))+25; set(h(1),'ylim',ylim)
    end
    if ~isempty(ntr1)|~isempty(ntr2), set(hpF,'color',cyangreen), end
    %if exist('fnonexcind')&~isempty(fnonexcind)
    %  hpF2=plot(freqv(fnonexcind)/fsci,ampF(fnonexcind),'+','color',[0.7,1,0.7],...
    %    'parent',h(1),'tag','dataplot');
    %end
  end
  if ~isempty(amp2)
    plot(freqd/fsci,amp2,[':',blue],'parent',h(1),'tag','modelplot')
  end
  mp='modelplot';
  sp=size(pd1cell);
  for ii=2:prod([sp(3:end),1])
    ampi=db(abs(tfcalc(pd1cell(:,:,ii),freqd)));
    pd1h=plot(freqd/fsci,ampi,...
      'color',[1,0,0],'parent',h(1),'tag','modelplot2');
    if ii==pd1ci, set(pd1h,'tag','modelplot'), mp='modelplot2'; end
    y=get(pd1h,'ydata');
    axv1(3)=min(axv1(3),min(y));
    axv1(4)=max(axv1(4),max(y));
  end %for ii
  if ~isempty(amp1)
    pd1h=plot(freqd/fsci,amp1,['-',red],'parent',h(1),'tag',mp);
  end
  set(h(1),'ylim',axv1(3:4))
  if strcmp(setstr(fscale(1:3)),'log'), set(h(1),'xscale','log')
  else set(h(1),'xscale','lin')
  end
  axv1(3:4)=get(h(1),'ylim');
  if strcmp(setstr(fscale(1:3)),'lin')
    hd1=text(axv1(2)+0.01*(axv1(2)-axv1(1)),axv1(3)-0.01*(axv1(4)-axv1(3)),...
      fdim,'VerticalAlignment','bottom','parent',h(1));
  else %log
    hd1=text(axv1(2)*(axv1(2)/axv1(1))^0.01,...
      axv1(3)/(axv1(4)/axv1(3))^0.01,fdim,'VerticalAlignment','bottom',...
      'parent',h(1));
  end
  set(hd1,'Units','normalized','tag','ploteltfdim')
  if strcmp(ntx,'notext')
    set(hd1,'visible','off')
  end
  %
  if (exist('stdcmplx')&~isempty(stdcmplx))|...
      (exist('stdcmplxnonlin')&~isempty(stdcmplxnonlin))|...
      (rplot==yes) %model or data uncertainty
    if cmplxplot==yes
      if confint=='v', ecodex='x'; ecodes=':'; %yellow
      elseif confint=='c', ecodex=[':',red]; ecodes=green2;
      elseif rplot==yes, ecodex=['x',cyan]; ecodes=[':',cyan];
      else error('Unknown option')
      end
      set(h(1),'nextplot','add')
      set(h(1),'xlim',axv1(1:2),'ylim',axv1(3:4))
      if rplot==yes, fv=freqv/fsci; else fv=fdc/fsci; end
      if exist('stdcmplx')&~isempty(stdcmplx)&~any(findstr(mscin(end),'w'))
        indn0=find(stdcmplx~=0);
        if ~isempty(indn0)
          if (length(fv)<length(stdcmplx)), fv=kron(ones(length(stdcmplx)/length(fv),1),fv); end
          [fvs,indf]=sort(fv(indn0));
          if any(findstr(ecodex,'x'))
            hpy=plot(fv(indn0),db(stdcmplx(indn0)),ecodex,...
              fv(indn0(indf)),db(stdcmplx(indn0(indf))),ecodes,...
              'parent',h(1),'tag','errorplot');
          else
            hpy=plot(fv(indn0(indf)),db(stdcmplx(indn0(indf))),ecodex,...
              'parent',h(1),'tag','errorplot');
          end
          if any(diff(indf)>1), set(hpy,'linestyle','none'), end
          if length(ecodex)==1, set(hpy,'color',yellow), end
        end
      end
      if exist('stdcmplxnonlin')&~isempty(stdcmplxnonlin)&~strcmp(confint,'n')
        indn0=find(stdcmplxnonlin~=0);
        if (length(fv)<length(stdcmplxnonlin)), fv=kron(ones(length(stdcmplxnonlin)/length(fv),1),fv); end
        [fvs,indf]=sort(fv(indn0));
        if strncmp(objtype,'nonlinear',6)... %&any(findstr(mscin(end),'w'))
            |(strncmp(objtype,'interp',6)&any(findstr(mscin(end),'@')))
          if ~isempty(indn0)
            if any(findstr(ecodex,'x'))
              hpy=plot(fv(indn0),db(stdcmplxnonlin(indn0)),ecodex,...
                fv(indn0(indf)),db(stdcmplxnonlin(indn0(indf))),ecodes,...
                'parent',h(1),'tag','errorplot');
            else
              hpy=plot(fv(indn0(indf)),db(stdcmplxnonlin(indn0(indf))),ecodex,...
                'parent',h(1),'tag','errorplot');
            end
            if length(ecodex)==1, set(hpy,'color',lighterrorblue), end %light blue
          end
          %
          if strncmp(objtype,'nonlinear',6)&~any(findstr(mscin(end),'w'))
            if exist('nonlinM')&~isempty(nonlinM) else nonlinM=1; end
            hpy=plot(fv(indn0),db(stdcmplxnonlin(indn0)/sqrt(nonlinM)),ecodex,...
              fv(indn0(indf)),db(stdcmplxnonlin(indn0(indf))/sqrt(nonlinM)),ecodes,...
              'parent',h(1),'tag','errorplot');
            set(hpy,'color',lighterrorblue2)
          end
        end
        %
        if exist('oddoutputnonlinerror')&~isempty(oddoutputnonlinerror)&...
            (length(ecodex)==1)&~any(findstr(mscin,'@'))%&0
          for ltype='oe'
            if strcmp(ltype,'o')
              evenvar=oddoutputnonlinerror;
              evenfreq=oddnonexcfrequencies;
              marker='^';  markersize=5.2; ls='none';
              color=errorblue;
            else
              evenvar=evenoutputnonlinerror;
              evenfreq=evennonexcfrequencies;
              marker='square'; markersize=4; ls='none';
              color=lighterrorblue;
            end
            xint2=interp1([0;fv;10*max(fv)],[abs(x(1));abs(x);abs(x(end))].^2,evenfreq/fsci);
            yint2=interp1([0;fv;10*max(fv)],[abs(y(1));abs(y);abs(y(end))].^2,evenfreq/fsci);
            indn0=find(evenvar>0);
            if ~isempty(indn0)
              lm=[1,0.6,1];
              evenvar=evenvar(indn0)./xint2(indn0);
              if strcmp(setstr(fscale(1:3)),'lin')
                plot(evenfreq(indn0)/fsci,0.5*db(evenvar),'marker',marker,'markersize',markersize,...
                  'linestyle',ls,'color',color,...
                  'parent',h(1),'tag','errorplot')
                %plot(evenfreq(indn0),0.5*db(evenvar),':','color',color,...
                %  'parent',h(1),'tag','errorplot')
              else %log
                semilogx(evenfreq(indn0)/fsci,0.5*db(evenvar),'marker',marker,'markersize',markersize,...
                  'linestyle',ls,'color',color,...
                  'parent',h(1),'tag','errorplot')
                %semilogx(evenfreq(indn0),0.5*db(evenvar),':','color',color,...
                %  'parent',h(1),'tag','errorplot')
              end
              axmod34=0.5*db(median(evenvar(indn0))); ylim=get(h(1),'ylim');
              set(h(1),'ylim',[min(ylim(1),axmod34-0.1*diff(ylim)),...
                max(ylim(2),axmod34+0.1*diff(ylim))]);
            end %~isempty(indn0)
          end %ltype
          if ~isempty(Fdat.userdata)
            tfdat=stdtfm(Fdat.userdata);
            nonexcfv=tfdat.freqpoints;
            nonexcvar=tfdat.outputvar;
            if strcmp(setstr(fscale(1:3)),'lin')
              plot(nonexcfv,0.5*db(nonexcvar),'marker','d','markersize',3,...
                'color',nonexyellow,...
                'linestyle',':','parent',h(1),'tag','errorplot')
            else %log
              semilogx(nonexcfv,0.5*db(nonexcvar),'marker','d','markersize',3,...
                'color',nonexyellow,...
                'linestyle',':','parent',h(1),'tag','errorplot')
            end
          end
        end %~isempty(oddoutputnonlinerror)
        %
      end %exist('stdcmplxnonlin')&~isempty(stdcmplxnonlin)
      if (confint=='v')&nonlinplot&isa(Fdat,'fiddata')&~isempty(pd1)
        %vdatnl=get(Fdat,'SisoNonlinError');
        %if ~isempty(vdatnl)
        %  nonlinvar2var(Fdat);
        %  tfdat=stdtfm(Fdat); tfvar=tfdat.outputvariance;
        %  indn0=find(tfvar>0);
        %
        if exist('oddoutputnonlinerror')&~isempty(oddoutputnonlinerror)&(length(ecodex)==1)%&0 %***
          for ltype='oe'
            if strcmp(ltype,'o')
              evenvar=oddoutputnonlinerror;
              evenfreq=oddnonexcfrequencies;
              marker='^'; 
              markersize=2.2; 
              ls='none';
              color=errorblue;
            else
              evenvar=evenoutputnonlinerror;
              evenfreq=evennonexcfrequencies;
              marker='square'; 
              markersize=2; 
              ls='none';
              color=lighterrorblue;
            end
            xint2=interp1([0;fv;10*max(fv)],[abs(x(1));abs(x);abs(x(end))].^2,evenfreq);
            yint2=interp1([0;fv;10*max(fv)],[abs(y(1));abs(y);abs(y(end))].^2,evenfreq);
            evenvar=evenvar./xint2; %Variance of the frf needed, not of the output
            indn0=find(evenvar>0);
            if ~isempty(indn0)
              if NSRplot==yes
                evenvar=abs(evenvar(indn0)./(yint2(indn0)./xint2(indn0)));
              elseif NSRplot==inv
                evenvar=abs((yint2(indn0)./xint2(indn0))./evenvar(indn0));
              else
                evenvar=evenvar(indn0);
              end
              if strcmp(setstr(fscale(1:3)),'lin')
                plot(evenfreq(indn0),0.5*db(evenvar),'marker',marker,'markersize',markersize,...
                  'linestyle',ls,'color',color,...
                  'parent',h(1),'tag','errorplot')
                %plot(evenfreq(indn0),0.5*db(evenvar),':','color',color,...
                %  'parent',h(1),'tag','errorplot')
              else %log
                semilogx(evenfreq(indn0),0.5*db(evenvar),'marker',marker,'markersize',markersize,...
                  'linestyle',ls,'color',color,...
                  'parent',h(1),'tag','errorplot')
                %semilogx(evenfreq(indn0),0.5*db(evenvar),':','color',color,...
                %  'parent',h(1),'tag','errorplot')
              end
              axmod34=0.5*db(median(evenvar(indn0))); ylim=get(h(1),'ylim');
              set(h(1),'ylim',[min(ylim(1),axmod34-0.1*diff(ylim)),...
                max(ylim(2),axmod34+0.1*diff(ylim))]);
            end %~isempty(indn0)
          end %ltype
          nevarobj=Fdat.userdata;
          if ~isempty(nevarobj)
            netfm=stdtfm(nevarobj);
              if NSRplot==yes
                evenvar=netfm.outputvariance./abs(netfm.y).^2;
              elseif NSRplot==inv
                evenvar=abs(netfm.y).^2./netfm.outputvariance;
              else
                evenvar=netfm.outputvariance;
              end
            plot(netfm.inputfreqpoints,0.5*db(evenvar),...
              'color',nonexyellow,'marker','v','markersize',2,...
              'linestyle','none','parent',h(1),'tag','errorplot')
          end
        end %~isempty(oddoutputnonlinerror)
      end
      if crplot==yes
        if exist('clim')&~isempty(clim) %plot confidence limits
          hcl1=plot(fv,db(clim(1,:)),':','parent',h(1),'tag','ploteltf bounds');
          hcl2=plot(fv,db(clim(2,:)),':','parent',h(1),'tag','ploteltf bounds');
          set([hcl1,hcl2],'color',[1,0.3,1]) %light magenta
        end
        if exist('climnonlin')&~isempty(climnonlin) %plot confidence limits
          hcl1=plot(fv,db(climnonlin(1,:)),':','parent',h(1),'tag','ploteltf bounds');
          hcl2=plot(fv,db(climnonlin(2,:)),':','parent',h(1),'tag','ploteltf bounds');
          color=[1,0,1]; %magenta
          color=errorblue; %light blue
          set([hcl1,hcl2],'color',color)
        end
      end
      set(h(1),'xscale',setstr(fscale(1:3)))
      axv1(3:4)=get(h(1),'ylim');
      hc=findobj(h(1),'tag','ploteltf bounds');
      if ~isempty(hc)
        clim=get(hc,'ydata');
        if isa(clim,'cell'), clim=cat(1,clim{:}); clim=clim(:); end
        axv1(3)=min(axv1(3),min(clim)-0.05*diff(axv1(3:4)));
        axv1(4)=max(axv1(4),max(clim)+0.05*diff(axv1(3:4)));
      end
      if length(findall(h(1),'tag','ploteltfdim'))>0
        if strcmp(setstr(fscale(1:3)),'lin')
          hd1=text(axv1(2)+0.01*(axv1(2)-axv1(1)),...
            axv1(3)-0.01*(axv1(4)-axv1(3)),...
            fdim,'VerticalAlignment','bottom','parent',h(1));
        else %log
          hd1=text(axv1(2)*(axv1(2)/axv1(1))^0.01,...
            axv1(3)/(axv1(4)/axv1(3))^0.01,fdim,'VerticalAlignment',...
            'bottom','parent',h(1));
        end
        set(hd1,'Units','normalized','tag','ploteltfdim')
        if strcmp(ntx,'notext')
          set(hd1,'visible','off')
        end
      end
      %
      if axv1(3)<axv1(4)-400, axv1(3)=axv1(4)-400; end
      set(h(1),'xlim',axv1(1:2),'ylim',axv1(3:4))
      if NSRplot==no
        if ~exist('vx'), titletext='Magnitude of tf and complex error';
        elseif any(find(mscin(end)=='@'))
          titletext='Magnitude of tf and error levels';
          if isa(Fdat,'fiddata')
            N=get(Fdat,'N'); M=get(Fdat,'M');
            if ~isempty(N)
              titletext=[titletext,sprintf(' for av. of periods, %.0f samples each',N)];
            end
          end
        else titletext='Magnitude of tf and Variance';
        end
      elseif NSRplot==yes, titletext='Magnitude of tf and NSR (dB)';
      elseif NSRplot==inv, titletext='Magnitude of tf and  SNR (dB)';
      end
      set(get(h(1),'title'),'string',titletext,'tag','ploteltftext')
      if strcmp(ntx,'notext')
        set(get(h(1),'title'),'visible','off')
      end
    else %errorbar plot
      axes(h(1))
      hpa=get(h(1),'parent');
      if argerrorbar>=5 %errorbar with 5 arguments
        %use error catch facility of errorbar
        %if attempt with 5 arguments fails, use 3 arguments
        %eval('heb=errorbar(fdc/fsci,a1c,a1El,a1Eu,''.'');',[...
        %    'disp(''This is rather a warning message.''),',...
        %    'disp(''Old version of errorbar found: it is time to ',...
        %    'upgrade it!''), argerrorbar=3; heb=errorbar(fdc/fsci,a1c3,a1E)'])
        heb=plot([fdc/fsci,fdc/fsci]',[a1c-a1El,a1c+a1Eu]','-b','parent',h(1));
      else
        heb=errorbar(fdc/fsci,a1c3,a1E); %old errorbar
      end
      mverrorbar(heb,hgiven,h(1))
    end %errorbar or cmplx
  end %cd1
  if isempty(get(get(h(1),'title'),'string'))
    if ~exist('vx')
      set(get(h(1),'title'),'string','Magnitude of tf','tag','ploteltftext')
    else
      set(get(h(1),'title'),'string','Magnitude of tf and Variance',...
        'tag','ploteltftext')
    end
  end
  set(get(h(1),'ylabel'),'string','dB','tag','ploteltftext')
  if strcmp(ntx,'notext')
    set(get(h(1),'title'),'visible','off')
    set(get(h(1),'ylabel'),'visible','off')
  end
  set(h(1),'xlim',axv1(1:2),'ylim',axv1(3:4))
  if strcmp(setstr(fscale(1:3)),'log')
     fixlgtck(h(1),axv1)
  end
end %amplot
%
if phplot==yes
  %subplot(h(2))
  %hold off, axis('normal')
  h2=h(2); if nargout>1, ha2=h(2); fsc=fsci; end
  feval('set',h(2),'DefaultTextVerticalAlignment','bottom')
  set(h(2),'xlim',axv2(1:2))
  if all(isfinite(axv2(3:4))), set(h(2),'ylim',axv2(3:4)), end
  plot(axv2(2),axv2(4),['.',invis],'markersize',1,'parent',h(2))
  set(h(2),'nextplot','add')
  if ~isempty(phF)
    hpF=plot(freqv/fsci,phF,'marker','+','linestyle','none','color',green,'parent',h(2),'tag','dataplot');
    if ~isempty(ntr1)|~isempty(ntr2), set(hpF,'color',cyangreen), end
    if exist('fnonexcind')
      hpF2=plot(freqv(fnonexcind)/fsci,phF(fnonexcind),'+','color',[0.7,1,0.7],...
        'parent',h(2),'tag','dataplot');
    end
  end
  if ~isempty(ph2)
    plot(freqd/fsci,ph2,[':',blue],'parent',h(2),'tag','modelplot')
  end
  mp='modelplot';
  sp=size(pd1cell);
  for ii=2:prod([sp(3:end),1])
    phi=angle(tfcalc(pd1cell(:,:,ii),freqd))/2/pi*360;
    phi=phi+round((ph1-phi)/360)*360;
    pd1h=plot(freqd/fsci,phi,['-',red],'parent',h(2),'tag','modelplot2');
    if ii==pd1ci, set(pd1h,'tag','modelplot'), mp='modelplot2'; end
  end %for ii
  if ~isempty(ph1)
    plot(freqd/fsci,ph1,['-',red],'parent',h(2),'tag',mp)
  end
  set(h(2),'xlim',axv2(1:2))
  if all(isfinite(axv2(3:4))), set(h(2),'ylim',axv2(3:4)), end
  set(h(2),'xscale',setstr(fscale(1:3)))
  axv2(3:4)=get(h(2),'ylim');
  if strcmp(setstr(fscale(1:3)),'lin')
    hd2=text(axv2(2)+0.01*(axv2(2)-axv2(1)),axv2(3)-0.01*(axv2(4)-axv2(3)),...
        fdim,'VerticalAlignment','bottom','parent',h(2));
  else %log
    hd2=text(axv2(2)*(axv2(2)/axv2(1))^0.01,...
    axv2(3)/(axv2(4)/axv2(3))^0.01,fdim,'VerticalAlignment',...
    'bottom','parent',h(2));
  end
  set(hd2,'Units','normalized','tag','ploteltfdim')
  if strcmp(ntx,'notext')
    set(hd2,'visible','off')
  end %ntx
  %
  if ~isempty(cd1) %confidence intervals
    hpa=get(h(2),'parent');
    axes(h(2))
    if argerrorbar>=5 %errorbar with 5 arguments
      %use error catch facility of errorbar
      %if attempt with 5 arguments fails, use 3 arguments
      %eval('heb=errorbar(fdc/fsci,pheb(1:fdec:fdl),stdph,stdph,''.'');',[...
      %       'argerrorbar=3; heb=errorbar(fdc/fsci,pheb(1:fdec:fdl),stdph);'])
      heb=plot([fdc/fsci,fdc/fsci]',...
        [pheb(1:fdec:fdl)-stdph,pheb(1:fdec:fdl)+stdph]','-b','parent',h(2));
    else
      heb=errorbar(fdc/fsci,pheb(1:fdec:fdl),stdph);
    end
    mverrorbar(heb,hgiven,h(2))
  end
  ht=get(h(2),'title'); set(ht,'string','Phase of tf','tag','ploteltftext');
  hy=get(h(2),'ylabel'); set(hy,'string','degrees','tag','ploteltftext')
  if strcmp(ntx,'notext')
    set(ht,'visible','off')
    set(hy,'visible','off')
  end
  set(h(2),'xlim',axv2(1:2),'ylim',axv2(3:4))
  set(h(2),'nextplot','replacechildren')
  if strcmp(setstr(fscale(1:3)),'log')
     fixlgtck(h(2),axv2)
  end
end %phplot
%
if strcmp(mscin,'1')
  if length(h)==1, h=[h,h]; end
end
if amplot=='2'
  if exist('x')&~isempty(x)&~strcmp(mscin,'1')
    Fl=length(x);
    delete(get(h(1),'children'))
    set(h(1),'xscale',setstr(fscale(1:3)))
    if strcmp(setstr(fscale(1:3)),'lin')
      hpF=plot(freqv/fsci,db(x),'+g','parent',h(1));
      set(h(1),'nextplot','add')
      if exist('fnonexcind')
        hpF2=plot(freqv(fnonexcind)/fsci,db(x(fnonexcind)),'+','color',[0.7,1,0.7],'parent',h(1),'tag','dataplot');
      end
      %if ~isempty(ntr1)|~isempty(ntr2), set(hpF,'color',cyangreen), end
      set(h(1),'xlim',axv1(1:2),'ylim',axv1(3:4))
      axv1(3:4)=get(h(1),'ylim');
      hd1=text(axv1(2)+0.01*(axv1(2)-axv1(1)),axv1(3)-0.01*(axv1(4)-axv1(3)),...
        fdim,'VerticalAlignment','bottom','parent',h(1));
      set(hd1,'Units','normalized','tag','ploteltfdim')
      if strcmp(ntx,'notext')
        set(hd1,'visible','off')
      end
    else %log
      semilogx(freqv/fsci,db(x),'+g','parent',h(1))
      set(h(1),'nextplot','add')
      if exist('fnonexcind')
        hpF2=semilogx(freqv(fnonexcind)/fsci,db(x(fnonexcind)),'+','color',[0.7,1,0.7],'parent',h(1),'tag','dataplot');
      end
      if strcmp(ntx,'notext')
        %  set(hd1,'visible','off')
      end
    end
    axv1(3:4)=[min(db(x)),max(db(x))];
    if diff(axv1(3:4))==0, axv1(3:4)=axv1(3:4)+sqrt(eps)*abs(axv1(3))*[-1,1]; end
    if diff(axv1(3:4))==0, axv1(3:4)=[-eps,eps]; end
    axv1(3)=max(axv1(3),axv1(4)-100); axv1(3:4)=axv1(3:4)+0.05*[-1,1]*diff(axv1(3:4));
    set(h(1),'ylim',axv1(3:4))
    %if exist('vx')&~isempty(vx)
    if strcmp(confint,'v')&~isempty(cd1)
      if strcmp(mscin(end),'2')
        set(get(h(1),'title'),'string','Input amplitudes + errors')
      else
        set(get(h(1),'title'),'string','Input amplitudes + standard deviations (dB)')
      end
    elseif strcmp(confint,'s')&~isempty(cd1)
      if NSRplot==yes
        set(get(h(1),'title'),'string','Input amplitudes + NSR''s (dB)')      
      else
        set(get(h(1),'title'),'string','Input amplitudes + SNR''s (dB)')      
      end
    else
      set(get(h(1),'title'),'string','Input amplitudes (dB)')
    end
    set(get(h(1),'ylabel'),'string','')
    if strcmp(ntx,'notext')
      set(get(h(1),'title'),'visible','off')
    end
    if M>1
      %Mean of several experiments
      Ref=get(Fdat,'Ref');
      if ~isempty(Ref)
        if iscell(Ref), Ref=cat(1,Ref{:}); end
        xm=mean(reshape(x./exp(j*angle(Ref)),Fl/M,M)')';        
      else
        xm=mean(reshape(x,Fl/M,M)')';
      end
      if strcmp(setstr(fscale(1:3)),'lin')
        plot(freqsav/fsci,db(xm),['*',cyan],...
          freqsav/fsci,db(xm),[':',cyan],'parent',h(1));
      else %log
        semilogx(freqsav/fsci,db(xm),['*',cyan],...
          freqsav/fsci,db(xm),[':',cyan],'parent',h(1));
      end
      maxxm=db(max(abs(xm)));
      minxm=db(min(abs(xm)));
      if isnan(minxm), minxm=maxxm+db(eps)-5; end
      medxm=db(median(abs(xm)));
      dxm=maxxm-medxm;
      axv1(3)=min([axv1(3),minxm,max(minxm-dxm/10,maxxm-10*dxm)]);
      set(h(1),'ylim',axv1(3:4))
      hc=get(h(1),'children'); set(h(1),'children',flipud(hc));
    end
  end
  if strcmp(confint,'v')
    set(h(1),'ylimmode','auto')
    for linear=linearvect
      if linear
        if iscell(cd1)
          cd1=cat(1,cd1{:});
          %vy=cd1(:,1:3:end);
          %vx=cd1(:,2:3:end);
        end
        if size(cd1,2)==2, vx=cd1(:,2); vy=cd1(:,1);
        else [vx,vy]=impvar(cd1);
        end
        vcolor=yellow;
      else %nonlinear
        vdatnl=sisononlinerror(Fdat);
        if ~isempty(vdatnl)
          vy=vdatnl(:,1); vx=vdatnl(:,2); 
        else
          vy=0; vx=0;
        end
        if all(isnan(vx)), vx=zeros(size(vx)); end
        vcolor=errorblue;
      end %nonlinear
      if size(vx,1)==1
        vx=vx(ones(length(freqsav),1));
        vy=vy(ones(length(freqsav),1));
      end
      if length(vx)==length(freqv), [fvs,indf]=sort(freqv);
      else [fvs,indf]=sort(freqsav);
      end
      if any(vx>0)
        if strcmp(setstr(fscale(1:3)),'lin')
          hv=plot(fvs/fsci,0.5*db(vx(indf)),'x',...
            freqv(indf)/fsci,0.5*db(vx(indf)),':','color',vcolor,'parent',h(1),...
            'tag','errorplot');
        else
          hv=semilogx(fvs/fsci,0.5*db(vx(indf)),'x',...
            freqv(indf)/fsci,0.5*db(vx(indf)),':','color',vcolor,'parent',h(1),...
            'tag','errorplot');
        end
        if any(diff(indf)>1), set(hv,'linestyle','none'), end
      end
      if ~linear
        if ~israndomized(Fdat)
          %simple nonlinear
          nonlinM=get(Fdat,'nonlinM');
          if any(vx>0)&(length(nonlinM)==1)&isfinite(nonlinM)
            if strcmp(setstr(fscale(1:3)),'lin')
              hv=plot(fvs/fsci,0.5*db(vx),'x',...
                fvs/fsci,0.5*db(vx(indf)/nonlinM),':','color',lighterrorblue2,'parent',h(1),...
                'tag','errorplot');
            else
              hv=semilogx(fvs/fsci,0.5*db(vx),'x',...
                fvs/fsci,0.5*db(vx(indf)/nonlinM),':','color',lighterrorblue2,'parent',h(1),...
                'tag','errorplot');
            end
            if any(diff(indf)>1), set(hv,'linestyle','none'), end
          end
        else
          nevarobj=Fdat.userdata;
          if ~isempty(nevarobj)
            if strcmp(setstr(fscale(1:3)),'lin')
              plot(nevarobj.freqpoints,0.5*db(nevarobj.inputvariance),'marker','d','markersize',3,...
                'color',nonexyellow,...
                'linestyle',':','parent',h(1),'tag','errorplot')
            else %log
              semilogx(nevarobj.freqpoints,0.5*db(nevarobj.inputvariance),'marker','d','markersize',3,...
                'color',nonexyellow,...
                'linestyle',':','parent',h(1),'tag','errorplot')
            end
            %netfm=stdtfm(nevarobj);
          end
        end %~israndomized
      end %~linear
    end
  elseif strcmp(confint,'s')
    set(h(1),'ylimmode','auto')
    for linear=linearvect
      if linear
        if size(cd1,2)==2, vx=cd1(:,2); vy=cd1(:,1);
        else [vx,vy]=impvar(cd1);
        end
        vcolor=yellow;
      else
        vdatnl=sisononlinerror(Fdat);
        [vx,vy]=impvar(vdatnl);
        vcolor=errorblue;
      end
      if size(vx,1)==1
        vx=vx(ones(length(freqsav),1));
        vy=vy(ones(length(freqsav),1));
      end
      %[fvs,indf]=sort(freqsav);
      if length(vx)==length(freqv), [fvs,indf]=sort(freqv);
      else [fvs,indf]=sort(freqsav);
      end
      if any(vx>0)
        if NSRplot==yes
          varv=0.5*db(vx)-db(x);
        else
          varv=-0.5*db(vx)+db(x);
        end
        if strcmp(setstr(fscale(1:3)),'lin')
          plot(freqsav/fsci,varv,'x',...
            freqsav(indf)/fsci,varv(indf),':','color',vcolor,'parent',h(1),...
            'tag','errorplot')
        else
          semilogx(freqsav/fsci,varv,'x',...
            freqsav(indf)/fsci,varv(indf),':','color',vcolor,'parent',h(1),...
            'tag','errorplot')
        end
      end %any(vx)
    end %for linear
  end 
  ax(3:4)=get(h(1),'ylim');
  axv1(3)=min(axv1(3),ax(3));
  axv1(4)=max(axv1(4),ax(4));
  axv1(3)=axv1(3)-0.05*(axv1(4)-axv1(3));
  axv1(4)=axv1(4)+0.05*(axv1(4)-axv1(3));
  set(h(1),'ylim',axv1(3:4))
  set(h(1),'xlim',axv1(1:2))
  set(h(1),'nextplot','replacechildren')
  %
  %axes(h(2)); cla, hold off
  if exist('y')&~isempty(y)
		delete(get(h(2),'children'))
    set(h(2),'xscale',setstr(fscale(1:3)))
    if strcmp(setstr(fscale(1:3)),'lin')
      hpF=plot(freqv/fsci,db(y),'+g','parent',h(2));
      set(h(2),'nextplot','add')
      if ~isempty(ntr1)|~isempty(ntr2), set(hpF,'color',cyangreen), end
      if exist('fnonexcind')
        hpF2=plot(freqv(fnonexcind)/fsci,db(y(fnonexcind)),'+','color',[0.7,1,0.7],'parent',h(2),'tag','dataplot');
      end
      axv2(3:4)=get(h(2),'ylim'); %axv2(1:2)=get(h(2),'xlim');
      set(h(2),'xlim',axv2(1:2),'ylimmode','auto')
      axv2(3:4)=get(h(2),'ylim');
      hd2=text(axv2(2)+0.01*(axv2(2)-axv2(1)),axv2(3)-0.01*(axv2(4)-axv2(3)),...
        fdim,'VerticalAlignment','bottom','parent',h(2));
      set(hd2,'Units','normalized','tag','ploteltfdim')
      if strcmp(ntx,'notext')
        set(hd2,'visible','off')
      end
    else %log
      semilogx(freqv/fsci,db(y),'+g','parent',h(2))
      set(h(2),'nextplot','add')
      if exist('fnonexcind')
        hpF2=semilogx(freqv(fnonexcind)/fsci,db(y(fnonexcind)),'+','color',[0.7,1,0.7],'parent',h(2),'tag','dataplot');
      end
      axv2(3:4)=get(h(2),'ylim'); %axv2(1:2)=get(h(2),'xlim');
      %hd2=text(axv2(2)*(axv2(2)/axv2(1))^0.01,...
      %  axv2(3)/(axv2(4)/axv2(3))^0.01,fdim,'VerticalAlignment',...
      %  'bottom','parent',h(2));
      %set(hd2,'Units','normalized')
      if strcmp(ntx,'notext')
        %  set(hd2,'visible','off')
      end
    end
    axv2(3:4)=[min(db(y)),max(db(y))];
    if diff(axv2(3:4))==0, axv2(3:4)=axv2(3:4)+sqrt(eps)*abs(axv2(3))*[-1,1]; end
    if diff(axv2(3:4))==0, axv2(3:4)=[-eps,eps]; end
    axv2(3)=max(axv2(3),axv2(4)-100); axv2(3:4)=axv2(3:4)+0.05*[-1,1]*diff(axv2(3:4));
    set(h(2),'ylim',axv2(3:4))
  end
  if strcmp(confint,'v')
    set(h(2),'ylimmode','auto')
    for linear=linearvect
      if linear
        if size(cd1,2)==2, vx=cd1(:,2); vy=cd1(:,1);
        else [vx,vy]=impvar(cd1);
        end
        vcolor=yellow;
      else %not linear
        if exist('oddoutputnonlinerror')&~isempty(oddoutputnonlinerror) %&0 %***
          for ltype='oe'
            if strcmp(ltype,'o')
              evenvar=oddoutputnonlinerror;
              evenfreq=oddnonexcfrequencies;
              marker='^'; 
              markersize=5.2; 
              ls='none';
              %color=[1,0.6,1]; %light magenta
              color=errorblue; %light blue
            else
              evenvar=evenoutputnonlinerror;
              evenfreq=evennonexcfrequencies;
              marker='square'; 
              markersize=4; 
              ls='none';
              %color=[1,0.6,1]; %light magenta
              color=lighterrorblue; %lighter blue
            end
            xint2=interp1([0;freqv;10*max(freqv)],[abs(x(1));abs(x);abs(x(end))].^2,evenfreq);
            yint2=interp1([0;freqv;10*max(freqv)],[abs(y(1));abs(y);abs(y(end))].^2,evenfreq);
            indn0=find(evenvar>0);
            if ~isempty(indn0)
              evenvar=evenvar(indn0);
              if strcmp(setstr(fscale(1:3)),'lin')
                plot(evenfreq(indn0),0.5*db(evenvar),'marker',marker,'markersize',markersize,...
                  'linestyle',ls,'color',color,...
                  'parent',h(2),'tag','errorplot')
                %plot(evenfreq(indn0),0.5*db(evenvar),':','color',color,...
                %  'parent',h(2),'tag','errorplot')
              else %log
                semilogx(evenfreq(indn0),0.5*db(evenvar),'marker',marker,'markersize',markersize,...
                  'linestyle',ls,'color',color,...
                  'parent',h(2),'tag','errorplot')
                %semilogx(evenfreq(indn0),0.5*db(evenvar),':','color',color,...
                %  'parent',h(2),'tag','errorplot')
              end
              axmod34=0.5*db(median(evenvar(indn0))); ylim=get(h(2),'ylim');
              set(h(2),'ylim',[min(ylim(1),axmod34-0.1*diff(ylim)),...
                max(ylim(2),axmod34+0.1*diff(ylim))]);
            end %~isempty(indn0)
          end %for ltype
        else %simple nonlinear
          vdatnl=sisononlinerror(Fdat);
          nonlinM=Fdat.nonlinM;
          [vx,vy]=impvar(vdatnl);
          vcolor=lighterrorblue;
          %
        end %~isempty(oddoutputnonlinerror)
      end %linear/nonlinear
      isodd=0;
      if exist('oddoutputnonlinerror')
        if ~isempty(oddoutputnonlinerror), isodd=1; end
      end
      if any(vy>0)&(linear|~isodd)
        if strcmp(mscin(end),'1')|strcmp(mscin(end),'2')
          nonlinM=get(Fdat,'nonlinM');
          if linear
            Mcorr=1;
            if ~isempty(nonlinM), Mcorr=nonlinM; else Mcorr=1; end
          else %~linear
            Mcorr=1;
          end
          if ~isempty(Mcorr), vy=vy*Mcorr; end
        end
        if length(vy)==length(freqv), fvplot=freqv; else fvplot=freqsav; end
        if length(vy)==length(freqv), [fvs,indf]=sort(freqv);
        else [fvs,indf]=sort(freqsav);
        end
        if strcmp(setstr(fscale(1:3)),'lin')
          if (length(vy)==1), vy=vy*ones(size(fvplot)); end
          hv=plot(fvplot(indf)/fsci,0.5*db(vy(indf)),'marker','x',...
            'linestyle',':','color',vcolor,'parent',h(2),...
            'tag','errorplot');
          if ~linear
            hv=plot(fvplot(indf)/fsci,0.5*db(vy(indf)/nonlinM),'marker','x',...
              'linestyle',':','color',lighterrorblue2,...
              'parent',h(2),'tag','errorplot');
          end
          if any(diff(indf)>1), set(hv,'linestyle','none'), end
        else %log
          semilogx(fvplot(indf)/fsci,0.5*db(vy(indf)),'marker','x',...
            'linestyle',':','color',vcolor,'parent',h(2),...
            'tag','errorplot')
          if ~linear
            if (length(vcolor)==3)&(length(yellow)==3), color=mean(vcolor,yellow);
            else color=vcolor;
            end
            color=1-0.3*(1-vcolor);
            semilogx(fvplot(indf)/fsci,0.5*db(vy(indf)/nonlinM),'marker','x',...
              'linestyle',':','color',lighterrorblue2,...
              'parent',h(2),'tag','errorplot')
          end
        end
      end %oddoutput...
    end %for linear
    nevarobj=Fdat.userdata;
    if ~isempty(nevarobj)
      if strcmp(setstr(fscale(1:3)),'lin')
        plot(nevarobj.freqpoints,0.5*db(nevarobj.outputvariance),'marker','d','markersize',3,...
          'color',nonexyellow,...
          'linestyle',':','parent',h(2),'tag','errorplot')
      else %log
        semilogx(nevarobj.freqpoints,0.5*db(nevarobj.outputvariance),'marker','d','markersize',3,...
          'color',nonexyellow,...
              'linestyle',':','parent',h(2),'tag','errorplot')
      end
      %netfm=stdtfm(nevarobj);
    end
    ax(3:4)=get(h(2),'ylim');
    ax(3)=ax(3)-0.05*(ax(4)-ax(3));
    set(h(2),'ylim',ax(3:4))
  elseif strcmp(confint,'s')
    for linear=linearvect
      if linear
        if size(cd1,2)==2, vx=cd1(:,2); vy=cd1(:,1);
        else [vx,vy]=impvar(cd1);
        end
        vcolor=yellow;
      else
        vdatnl=sisononlinerror(Fdat);
        nonlinM=Fdat.nonlinM;
        [vx,vy]=impvar(vdatnl);
        vcolor=errorblue;
      end
      set(h(2),'ylimmode','auto')
      if any(vy>0)
        if NSRplot==yes
          varv=0.5*db(vy)-db(y);
        else
          varv=-0.5*db(vy)+db(y);
        end
        if strcmp(setstr(fscale(1:3)),'lin')
          plot(freqsav/fsci,varv,'x',...
            freqsav(indf)/fsci,varv(indf),':','color',vcolor,'parent',h(2),...
            'tag','errorplot')
        else
          semilogx(freqsav/fsci,varv,'x',...
            freqsav(indf)/fsci,varv(indf),':','color',vcolor,'parent',h(2),...
            'tag','errorplot')
        end
      end
      ax(3:4)=get(h(2),'ylim'); ax(3)=ax(3)-0.05*(ax(4)-ax(3));
      set(h(2),'ylim',ax(3:4))
    end %for linear
  end
  ax(3:4)=get(h(2),'ylim');
  axv2(3)=min(axv2(3),ax(3));
  axv2(4)=max(axv2(4),ax(4));
  axv2(3)=axv2(3)-0.05*(axv2(4)-axv2(3));
  axv2(4)=axv2(4)+0.05*(axv2(4)-axv2(3));
  set(h(2),'ylim',axv2(3:4))
  set(h(2),'xlim',axv2(1:2))
  if exist('vy')&~isempty(vy)
    if NSRplot==yes
      set(get(h(2),'title'),'string','Output amplitudes + NSR''s (dB)')      
    elseif NSRplot==inv
      set(get(h(2),'title'),'string','Output amplitudes + SNR''s (dB)')      
    else
      if strcmp(mscin(end),'2')|strcmp(mscin(end),'1')
        set(get(h(2),'title'),'string','Output amplitudes + errors')
      else
        set(get(h(2),'title'),'string','Output amplitudes + standard deviations (dB)')
      end
    end
  else
    set(get(h(2),'title'),'string','Output amplitudes (dB)')
  end
  set(get(h(2),'ylabel'),'string','')
  %xlabel('Frequency')
  if strcmp(ntx,'notext')
    set(get(h(2),'title'),'visible','off')
  end
end
%
%texts onto plot
if isempty(pd1)
  titstr1='';
else
  if isstr(pd1), ptxt1=pd1; else ptxt1='pvect1'; end
  if rec(1)=='r', recstr='/r'; else recstr=''; end
  if strcmp(domain1,'z'), dim1='samples   '; dval1=delay1;
  else dim1='s   '; dval1=delay1/fs1;
  end
  titstr1=[ptxt1,sprintf([recstr,' (',domain1,',%.0f/%.0f), d = %.3g ',...
        dim1],length(num1)-1,length(denom1)-1,dval1)];
end
if isempty(pd2)
  titstr2='';
else
  if isstr(pd2), ptxt2=pd2; else ptxt2='pvect2'; end
  if rec(2)=='r', recstr='/r'; else recstr=''; end
  if strcmp(domain2,'z'), dim2='samples   '; dval2=delay2;
  else dim2='s   '; dval2=delay2/fs2;
  end
  titstr2=[ptxt2,sprintf([recstr,' (',domain2,',%.0f/%.0f), d=%.3g ',...
        dim2],length(num2)-1,length(denom2)-1,dval2)];
end
if isempty(Fdat)
  titstrF='';
else
  if isstr(Fdat), Ftxt=Fdat; else Ftxt='Fvect'; end
  if rec(3)=='r', recstr='/r'; else recstr=''; end
  if sblen>0, sbtxt=sprintf(', sb: %.0f',sblen); else sbtxt=''; end
  if length(x)>F, extxt=sprintf('exp: %.0f, ',length(x)/F);
  else extxt='';
  end
  titstrF=[Ftxt,recstr,' (',extxt,sprintf('freq: %.0f',F),sbtxt,')'];
end
if (amplot==yes)&~isempty(cd1) %confidence intervals
  if cmplxplot %complex error
    cbtxt=sprintf('%.0f*sigma error values',cc);
  else
    if exist('Pc')
      cbtxt=sprintf(['conf. bound = %.3g*sigma',...
                ',  Pc = %.',int2str(Pdig),'f'],cc,Pc);
    else
      cbtxt=sprintf('conf. bound = %.3g*sigma,  Pc ~ 1',cc);
    end
  end
  if strcmp(confint,'c'), cbtxt=['pdat1, ',cbtxt];
  elseif strcmp(confint,'v'), cbtxt=['Fdat, ',cbtxt];
  elseif confint=='n', cbtxt='';
  else error('invalid confint')
  end
  if ~(strcmp(ntx,'notext')|strcmp(ntx,'nomesg'))
    text(0,0.35,cbtxt,'VerticalAlignment','bottom','parent',txth)
  end
end
if ~(strcmp(ntx,'notext')|strcmp(ntx,'nomesg'))&((amplot==yes)|(amplot=='2'))
  text(0,0,[titstr1,titstr2,titstrF],'VerticalAlignment','bottom','parent',txth)
end
if h(1)~=0
  set(h(1),'nextplot','replacechildren')
  %set(hp,'nextplot','replacechildren')
end
if ~hgiven
  drawnow, figure(hp), hold off
else
  if (strncmp(version,'5.2',3)&strcmp(getuprop(h(1),'visibility'),'off'))|...
      (~strncmp(version,'5.2',3)&strcmp(getappdata(h(1),'visibility'),'off'))
    set([h(1);allchild(h(1))],'visible','off')
  elseif strcmp(get(get(h(1), 'parent'), 'visible'), 'on'), axes(h(1))
  end
  %axes(h(1))
end %refresh graph

%%%%%%%%%%%%%%%%%%%%%%%%% Subfunctions %%%%%%%%%%%%%%%%%%%%%%%
function mverrorbar(heb,hgiven,hax)
%MVERRORBAR Move errorbar plot to given axes, behind the others
if isempty(heb), return, end
haxused=get(heb(1),'parent');
if hgiven, set(heb,'parent',hax), end
h=get(hax,'children');
for ii=1:length(heb)
  ind=find(h==heb(ii));
  h(ind)=[]; h=[h;heb(ii)];
end
set(hax,'children',h);
if haxused~=hax
  delete(get(haxused,'parent'))
end

function y=db(x)
%DB  Value of the complex amplitude vector in decibels
y=NaN*zeros(size(x));
if ~isempty(x), ind=find(~isnan(abs(x))&(abs(x)~=0));
else ind=[]; 
end
if ~isempty(ind), y(ind)=20*log10(abs(x(ind))); end

%
%%%%%%%%%%%%%%%%%%%%%%%% end of ploteltf %%%%%%%%%%%%%%%%%%%%%%%%
