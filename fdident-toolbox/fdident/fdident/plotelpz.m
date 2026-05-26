function varargout=plotelpz(varargin)
%PLOTELPZ Plot poles/zeros of a transfer function with confidence ellipses.
%
%       [zpkdata,rzp,dps]=plotelpz(pdat,calcmode,zind,pind)
%
%       Output arguments:
%       zpkdata = structure of results. Fields:
%          zv - column vector of zeros
%          stdz - array of standard deviations of the zeros; the three columns
%             contain the std-s of the real parts, std-s of the imaginary
%             parts, and their correlation coefficients, respectively.
%             For multiple zeros NaN-s are returned if da is 'anal'.
%          pv - column vector of poles
%          stdp - array of standard deviations of the poles; the three columns
%             contain the std-s of the real parts, std-s of the imaginary
%             parts, and their correlation coefficients, respectively
%             For multiple poles NaN-s are returned if da is 'anal'.
%          g - gain, 1x2 vector of numerator/denominator gains.
%          stdg - 1x3 vector, standard deviations and covariance coefficient of g
%       rzp = correlation coefficient matrix (normalized covariance matrix)
%           of the vector which contains real and imaginary parts of each
%           zero and pole, and the leading coefficients of the numerator
%           and the denominator, like:
%           [z1r;z1i;z2r;...;p1r;p1i;p2r;...;n1;d1]
%       dps = if during the numerical derivations the perturbations are too
%           large (nearest neighbors cannot pair pole/zero sets properly),
%           dps contains a suggested value for dp.
%           otherwise dps is empty.
%
%       Input arguments:
%       pdat = fidmodel object with covariance
%       calcmode = structure of calculation mode descriptors
%         optional fields:
%           conf - 'on' for confidence ellipses (default: off)
%           cloud - 'on' for cloud of poles/zeros (default: off)
%           stdm - multiplier of standard deviations for confidence ellipses
%                (default: 2.45, 95%)
%           Pc - probability to pole/zero fall into the confidence ellipse (default: 95%)
%           Ncloud - number of poles/zeros in could plot (default: 500)
%           dalg - mode of derivative calculation
%              For 'anal' (the default value), root/coefficient
%              sensitivities are calculated by analytical differentiation
%              of the polynomials.
%              For 'num', small perturbations and numerical differentiation
%              are used. The perturbations are introduced in the directions
%              of the eigenvectors of the covariance matrix, the amount is
%              the squatre root of the corresponding eigenvalue. The perturbations
%              can be multiplied by a constant factor dp.
%              Default value: 'anal'
%           dp - amount of perturbation of parameter vector in the directions
%              of the eigenvectors of the covariance matrix (multiplier
%              of the eigenvalues). Default: 1
%           plm - plotmode: if plm is given with value 'mc', the perturbed
%              sets and the pairing will be shown on the screen, one after
%              other; when with value 'mp', a statement pause will be
%              executed after each pairing. Default: ''
%           axv = optional 4-element vector to be passed through 'axis'
%              if axv is omitted, the plot will be scaled to just show all poles
%              and zeros, except if it is 'z', when the axis will be [-2,2,-2,2],
%              or if it is 'p', the plot will show all poles and zeros, and the
%              x and y axes have the same scaling. Default: []
%              A valid axv may be appended by a number, the stability margin for
%              counting the unstable poles / nonminimum phase zeros.
%           ntx = string which inhibits any texts from being written to the
%              screen if given as 'notext', and inhibits warning messages only
%              if given as 'nomsg'. If ntx is not empty, the previous
%              subplot or axes command remains in force. Default: ''
%           zarr = an array of zeros to be plotted too
%           parr = an array of poles to be plotted too
%           hax = handle of axes to plot in
%           tauR = tauR for r-domain
%
%       Usage: [zpkdata,dps,rzp]=plotelpz(pdat,calcmode);
%       Examples:
%           plotelpz('inpchmod(inpchanz)');
%           zpkdata=plotelpz('inpchmod(inpchans)',struct('conf','on'));
%           plotelpz('inpchmod(inpchans),'conf'); %simplified call
%           plotelpz('inpchmod(inpchans),'conf','cloud'); %simplified call
%
%       See also: STDPZ, ROOTS, PLOTELTF.

%       cloudm = scale factor of pole/zero perturbations for cloud plot
%       zind = indices of selected zeros to be plotted (all zeros: NaN)
%       pind = indices of selected poles to be plotted (all poles: NaN)

%Old fdident help
%PLOTELPZ Plot poles/zeros of a transfer function with confidence ellipses.
%
%       [rnum,rdenom]=PLOTELPZ(pdat,cdat,Pc,axv,ntx,zarr,parr,domain,da,dp,plm,fv,hax,tauR)
%
%       Output arguments:
%       rnum = roots of the numerator (in terms of s or z), column vector
%       rdenom = roots of the denominator (in terms of s or z), column vector
%
%       Input arguments:
%       pdat = the parameter vector (see EXPPAR) or the name of the file.
%           pdat may be empty; in this case parr, zarr and domain are used.
%       cdat = covariance matrix (array) or covariance vector (see EXPCOV) or
%           name of the covariance file of the parameters in pdat.
%           Value NaN means that covariances are taken from the object pdat.
%           If this is empty, the uncertainty ellipses will not be shown.
%       Pc = confidence level of pole/zero uncertainty ellipses. If Pc>=1,
%           this value becomes the multiplier of sigma on the contour. For
%           Pc=0, no ellipses will be drawn.
%       axv = optional 4-element vector to be passed through 'axis'
%           if axv is omitted, the plot will be scaled to just show all poles
%           and zeros, except if it is 'z', when the axis will be [-2,2,-2,2],
%           or if it is 'p', the plot will show all poles and zeros, and the
%           x and y axes have the same scaling.
%           A valid axv may be appended by a number, the stability margin for
%           counting the unstable poles / nonminimum phase zeros.
%       ntx = string which inhibits any texts from being written to the
%           screen if given as 'notext', and inhibits warning messages only
%           if given as 'nomsg'. If ntx is not empty, the previous
%           subplot or axes command remains in force.
%       zarr = an array of zeros to be plotted too
%       parr = an array of poles to be plotted too
%       domain = 's' or 'z', domain of the zeros/poles
%       da = algorithm of derivative calculation, 'anal' for analytical,
%           'num' for numerical. Default: 'anal'
%       dp = perturbation of parameter vector during numerical derivation in
%           the directions of the eigenvectors of the covariance matrix,
%           as a coefficient of the std. Default: 1.
%       plm = if its value is 'mc', in the case of numerical derivation the
%           'movie' will be shown, how the poles/zeros are paired to each
%           other. 'mp' is the same, but with pause after each plot.
%       fv = non-scaled frequency grid (for orthopol)
%       hax = handle of axes to plot in
%
%       Default values: axv=[]; cdat=''; ntx='';
%
%       Usage: [rnum,rdenom]=...
%                  plotelpz(pdat,cdat,Pc,axv,ntx,zarr,parr,domain,da,dp,plm,fv,hax,tauR);
%       Examples:
%           plotelpz('inpchmod(inpchanz)');
%           [rnum,rdenom]=plotelpz('inpchmod(inpchans)',NaN);
%
%       See also: STDPZ, ROOTS, PLOTELTF.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Aug-2002

if (nargin==1)&isstr(varargin{1})&strcmp(varargin{1},'preload')
  return %loading only for one argument 'preload'
end
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,14); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,14,ni)), %earlier
end
pdat=getobjf(varargin{1},'fidmodel');
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
hax=[]; plm=''; dp=[]; da=''; domain=''; parr=[]; zarr=[]; ntx=''; axv=[];
Pc=[]; cdat=[]; tauR=[]; cloudm=1;
confmode=''; cloudmode=''; stdm=[]; Ncloud=[]; zind=NaN; pind=NaN;
if nargin>=2, calcmode=varargin{2}; else calcmode=[]; end
%
if (nargin==2)&isa(pdat,'fidmodel')&isstr(calcmode)&(strcmp(calcmode,'conf')|strcmp(calcmode,'cloud'))
  eval(['calcmode=struct(''',calcmode,''',''on'');']);
elseif isa(pdat,'fidmodel')&(nargin==3)&isstr(varargin{2})&isstr(varargin{3})&...
    ( (strcmp(varargin{2},'conf')&strcmp(varargin{3},'cloud')) | ...
    (strcmp(varargin{3},'conf')&strcmp(varargin{2},'cloud')) )
  calcmode=struct('conf','on','cloud','on');
end
if isa(pdat,'fidmodel')&isstruct(calcmode)
  %new call
  newcall=1;
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,4); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,4,ni)), %earlier
  end
  if v(1)>='9', nargoutchk(1,4); %Matlab 2016a or later
  else error(nargchk(0,3,nargout)), %earlier
  end
  if ~isstruct(calcmode)&~isempty(calcmode)
    error('calcmode is not allowed')
  end
  if isfield(calcmode,'conf'), confmode=calcmode.conf; calcmode=rmfield(calcmode,'conf'); end
  if isfield(calcmode,'cloud'), cloudmode=calcmode.cloud; calcmode=rmfield(calcmode,'cloud'); end
  if isfield(calcmode,'stdm'), stdm=calcmode.stdm; calcmode=rmfield(calcmode,'stdm'); end
  if isfield(calcmode,'cloudm'), cloudm=calcmode.cloudm; calcmode=rmfield(calcmode,'cloudm'); end
  if isfield(calcmode,'Pc'), Pc=calcmode.Pc; calcmode=rmfield(calcmode,'Pc'); end
  if strcmp(confmode,'on')|strcmp(cloudmode,'on')
    cdat=pdat.covariance;
    if strcmp(cloudmode,'on')
      if isfield(calcmode,'Ncloud'), Ncloud=calcmode.Ncloud; calcmode=rmfield(calcmode,'Ncloud'); end
      if isempty(Ncloud), Ncloud=500; end
      if ~isnumeric(Ncloud)|isempty(Ncloud)|(Ncloud<1)
        error('Ncloud is illegal')
      end
    end
    if isempty(Pc)&isempty(stdm), Pc=0.95; end
    if ~isempty(stdm)
      Pc=1-exp(-stdm^2/2);
    elseif ~isempty(Pc)
      if (Pc<0)|(Pc>=1), error('Pc out of range')
      elseif Pc==1, Pc=1-eps; 
      end
      stdm=sqrt(-2*log(1-Pc));
    end
  elseif isempty(Pc)
    Pc=0;
  end
  if isfield(calcmode,'dalg'), da=calcmode.dalg; calcmode=rmfield(calcmode,'dalg'); end
  if isfield(calcmode,'dp'), dp=calcmode.dp; calcmode=rmfield(calcmode,'dp'); end
  if isfield(calcmode,'plm'), plm=calcmode.plm; calcmode=rmfield(calcmode,'plm'); end
  if isfield(calcmode,'axv'), axv=calcmode.axv; calcmode=rmfield(calcmode,'axv'); end
  if isfield(calcmode,'ntx'), ntx=calcmode.ntx; calcmode=rmfield(calcmode,'ntx'); end
  if isfield(calcmode,'zarr'), zarr=calcmode.zarr; calcmode=rmfield(calcmode,'zarr'); end
  if isfield(calcmode,'parr'), parr=calcmode.parr; calcmode=rmfield(calcmode,'parr'); end
  if strcmp(pdat.representation,'orthopol'), fv=pdat.freqvect; end
  if isfield(calcmode,'hax'), hax=calcmode.hax; calcmode=rmfield(calcmode,'hax'); end
  if isfield(calcmode,'tauR'), tauR=calcmode.tauR; calcmode=rmfield(calcmode,'tauR'); end
  if isstruct(calcmode)&~isempty(fieldnames(calcmode))
    calcmode, error('Unknown field name')
  end
  if (nargin>=3)&isnumeric(varargin{3}), zind=varargin{3}; end
  if (nargin>=4)&isnumeric(varargin{4}), pind=varargin{4}; end
  if ~any(isnan(zind))|~any(isnan(pind))
    zpkdata=stdpz(pdat);
    if ~any(isnan(zind))
      zpkdata.zv=zpkdata.zv(zind);
      if ~isempty(zpkdata.stdz), zpkdata.stdz=zpkdata.stdz(zind,:); end
    end
    if ~any(isnan(pind))
      zpkdata.pv=zpkdata.pv(pind);
      if ~isempty(zpkdata.stdp), zpkdata.stdp=zpkdata.stdp(pind,:); end
    end
    pdat=fdcovpzp(zpkdata);
    %if ~isempty(cdat), cdat=pdat.covariance; end
  end
else
  %old call
  newcall=0;
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', nargoutchk(0,2); %Matlab 2016a or later
  else error(nargchk(0,2,nargout)), %earlier
  end
  if nargin>=2, cdat=varargin{2}; end
  if isstr(cdat)
    if strcmp(cdat,'conf')|strcmp(cdat,'cloud')|strcmp(cdat,'stdm')|strcmp(cdat,'Pc')
      error(['cdat is not valid as ''',cdat,''''])
    end
  end
  if nargin>=3, Pc=varargin{3}; end
  if nargin>=4, axv=varargin{4}; else axv=[]; end
  if nargin>=5, ntx=varargin{5}; end
  if nargin>=6, zarr=varargin{6}; end, if isempty(zarr), zarr=[]; end
  if nargin>=7, parr=varargin{7}; end, if isempty(parr), parr=[]; end
  if nargin>=8, domain=varargin{8}; end
  if nargin>=9, da=varargin{9}; end
  if nargin>=10, dp=varargin{10}; end
  if nargin>=11, plm=varargin{11}; end
  if nargin>=12, fv=varargin{12}; end
  if nargin>=13, hax=varargin{13}; end
  if nargin>=14, tauR=varargin{14}; end
  if isempty(Pc)
    if ~isempty(cdat), Pc=0.95; 
    else Pc=0; stdm=0;
    end
  end
  if (Pc<0)&isempty(cdat)
    error('Negative value of Pc with empty cdat')
  elseif (Pc==0)&~isempty(cdat)
    cdat=''; confmode='';
    warning('Pc = 0 in plotelpz, confidence ellipses not plotted')
  elseif Pc<0
    cloudmode='on'; Ncloud=round(-Pc); stdm=1; Pc=1-exp(-stdm^2/2);
  elseif (Pc<1)&(Pc>0)
    confmode='on'; stdm=sqrt(-2*log(1-Pc));
  elseif Pc>1
    confmode='on'; stdm=Pc;
    Pc=1-exp(-stdm^2/2);
  end
  if Pc==1, Pc=1-eps; end
end
if isempty(da), da='anal'; end
if isempty(dp), dp=1; end
if isempty(hax), hgiven=0; plot(1), hax=gca; else hgiven=1; end
%End of input handling
%
%Now processing follows
if (Pc>0)&(Pc<1), Pdig=max(2,-round(log10(1-Pc)-0.8)); end
if ~strcmp(get(hax,'NextPlot'),'add') %delete children if hold is off
  hv=get(hax,'children'); delete(hv)
end
hf=get(hax,'parent');
if mean(get(hf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
if (mean(get(hf,'Color'))>=0.5), magenta=blue; %white bg
elseif (get(0,'ScreenDepth')>=8), magenta='m';
else magenta=green;
end
if nargin==1
  if (length(pdat)==1)&isa(class(pdat),'double'), if pdat==-1, return, end, end
end
if ~isempty(cdat)&isempty(pdat)
  error('cdat is not empty, pdat must be given for covariance ellipses')
end
tagstr=get(hf,'Tag');
if ~any(findstr([tagstr,' '],'_main'))&isempty(ntx)&isempty(hax)
  %Only if not GUI window or no text is required
  %Delete all axes objects in current figure
  %Use get because findobj may be missing (Matlab 4.1 or earlier)
  %delete(findobj(gcf,'Type','axes'));
  hax=get(hf,'Children');
  if ~isempty(hax), for i=1:length(hax)
    if strcmp(get(hax(i),'Type'),'axes'), delete(hax(i)), end
  end, end
  hax=gca;
end
set(hax,'xscale','linear','yscale','linear')
if ~isempty(ntx)
  if ~isstr(ntx), error('ntx is not a string'), end
  if ~strcmp(ntx,'notext')&~strcmp(ntx,'nomsg')&~strcmp(ntx,'text')
    disp(['Warning! Nonstandard ntx (''',ntx,''') in plotelpz'])
  end
end
covNaN=0;
%
if (length(axv)==1)&isnan(axv), axv=[]; end
if ~isempty(plm)&~strcmp(plm,'mc')&~strcmp(plm,'mp')
  error(['plm ''',plm,''' is not allowed'])
end
%
rnumi=[]; rdenomi=[]; pzs=[];
pdat=getobjf(pdat,'fidmodel');
if any(isnan(cdat))|(isstr(cdat)&(length(cdat)==1))
  if isa(pdat,'fidmodel'), cdat=pdat.covariance;
  else error('cdat is NaN, pdat is not fidmodel')
  end
end
if ~isempty(pdat)
  [domainp,num,denom,delay,fsc,Znum,Zdenom,cmts,fdate,ntr,Zntr,tauR]=imppar(pdat);
  if isa(pdat,'fidmodel')
    fv=get(pdat,'freqvect');
    ptyp=pdat.Coefficients;
  else
    ptyp='';
  end
  if ~isempty(domain)&~strcmp(domain,domainp)
    error('domain differs from the one defined by pdat')
  end
  domain=domainp;
  if any(domain=='pq'), fexp=fsc; else fexp=1; end
  pdati=exppar(domain,num,denom,delay,fexp,Znum,Zdenom,'','','',ntr,Zntr,ptyp,tauR);
  if any(domain=='sw') %attempt optimal scaling
    [domain,num,denom,delay,fsc]=imppar(pdati,[]); %get scaled data and fsc
    if ~isempty(cdat), cdat=impcov(cdat,fsc); end
  elseif any(domain=='p') %keep fsc
  else
    fsc=1;
  end
  numord=length(num)-1; denomord=length(denom)-1;
  if any(domain=='sz')
    rnumip=fsc*roots(num); rdenomip=fsc*roots(denom);
  elseif any(domain=='pq')
    rnumip=fsc*ortroots(num,Znum); rdenomip=fsc*ortroots(denom,Zdenom);
  elseif domain=='w'
    rnumip=sqrt(fsc)*roots(num); rdenomip=sqrt(fsc)*roots(denom);
  elseif domain=='r'
    rnumip=roots(num); rdenomip=roots(denom);
  end
  rnumi=rnumip; rdenomi=rdenomip;
else
  rnumip=[]; rdenomip=[];
end
%
if ~isempty([zarr(:);parr(:)])
  if (strcmp(domain,'z'))|isempty([zarr(:);parr(:)]), fsc=1;
  elseif strcmp(domain,'s'), fsc=mean(abs([zarr(:);parr(:)]));
  elseif strcmp(domain,'w'), fsc=mean(abs([zarr(:);parr(:)]))^2;
  end
  if ~any(isnan(zind)), zarr=zarr(zind,:); end
  if ~any(isnan(pind)), parr=parr(pind); end
  rnumi=[rnumi;zarr(:)]; rdenomi=[rdenomi;parr(:)]; %column vectors
end
pzs=[rnumi(:);rdenomi(:)];
%
propplot='n';
%extract stablimit
if length(axv)==5, stablimit=axv(5); axv(5)=[];
elseif length(axv)==2, stablimit=axv(2); axv(2)=[];
elseif length(axv)==1
  if axv(1)<=1, stablimit=axv(1); axv(1)=[];
  else
    if domain=='z', stablimit=1; else stablimit=0; end
  end
elseif any(domain=='zq'), stablimit=1;
else stablimit=0;
end
if strcmp(domain,'z')&((stablimit>1)|(stablimit<=0))
  error('Stability margin in axv is illegal')
elseif any(domain=='spwr')&(stablimit>0)
  error('Positive stability margin in axv is illegal')
end
%
if strcmp(axv,'z')|strcmp(axv,'q')
  if any(domain=='zq')
    axv=[-2,2,-2,2];
  else
    axv=[];
  end
elseif strcmp(axv,'p')
  propplot='y';
  axv=[];
elseif ~((length(axv)==4)|(length(axv)==0))
  error('axv is not allowed')
end
%
pp=fdident('private','fdcfs','lic')>1;
d=dbstack;
drn=~pp*.04*rand(size(rnumi)); drd=~pp*.04*rand(size(rdenomi));
if ~pp
  if length(d)==1, pp=1;
  elseif length(d)==2
    if ~any(findstr(d(2).name,'elis.m')), pp=1; end
  end
end
c=sprintf('\n');
tp=[80,111,108,101,115, 32, 97,110,100, 32,122,101,114,111,115, 32, 97,...
    114,101,32,112,108,111,116,116,101,100,c,104,101,114,101,32,105,110, 32,...
    108,105,99,101,110,115,101,100, 32,118,101,114,115,105,111,110,115];
tp=setstr(tp);
%
%Calculate uncertainties
warnmes='no';
stdz=[]; stdp=[];
rnumi=rnumi.*(1+drn); rdenomi=rdenomi.*(1+drd);
if strcmp(confmode,'on')
  if ~any(domain=='pq')
    if strcmp(da,'anal') %analytical derivation as default
      if isa(pdati,'fidmodel')
        %if ~isequal(pdati.covariance,cdat), pdati.covariance=impcov(cdat); end
        zpstruct.zv0=rnumip; zpstruct.pv0=rdenomip;
        zpkdata=stdpz(pdati,zpstruct);
        zv=zpkdata.zv;
        stdz=zpkdata.stdz;
        pv=zpkdata.pv;
        stdp=zpkdata.stdp;
        g=zpkdata.g;
        stdg=zpkdata.stdg;
      else %not fidmodel
        if nargout>=2, [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pdati,cdat,rnumip,rdenomip);
        else [zv,stdz,pv,stdp,g,stdg]=stdpz(pdati,cdat,rnumip,rdenomip);
        end
      end
      dps=1;
    else %numerical derivation
      if isa(pdati,'fidmodel')
        %if ~isequal(pdati.covariance,cdat), pdati.covariance=impcov(cdat); end
        zpstruct.zv0=rnumip; zpstruct.pv0=rdenomip;
        calcmode.da=da; calcmode.dp=dp;
        calcmode.plm=plm; calcmode.axv=axv;
        [zpkdata]=stdpz(pdati,zpstruct,calcmode);
        zv=zpkdata.zv;
        stdz=zpkdata.ztdz;
        pv=zpkdata.pv;
        stdp=zpkdata.stdp;
        g=zpkdata.g;
        stdg=zpkdata.stdg;
      else
        [zv,stdz,pv,stdp,g,stdg,rpz,dps]=...
          stdpz(pdati,cdat,rnumip,rdenomip,da,dp,plm,axv);
      end
    end
  else %orthopol
    if isempty(fv)
      error('Uncertainties can only be calculated for orthopol if fv is given')
    end
    if strcmp(da,'anal') %analytical derivation as default
      if isa(pdati,'fidmodel')
        %if ~isequal(pdati.covariance,cdat), pdati.covariance=impcov(cdat); end
        %calculate full covariance matrix
        zpstruct.zv0=rnumip; zpstruct.pv0=rdenomip;
        calcmode.da=da;
        zpkdata=stdpz(pdati,zpstruct,calcmode);
        zv=zpkdata.zv;
        stdz=zpkdata.ztdz;
        pv=zpkdata.pv;
        stdp=zpkdata.stdp;
        g=zpkdata.g;
        stdg=zpkdata.stdg;
      else
        [zv,stdz,pv,stdp,g,stdg]=stdpz(pdati,cdat,rnumip,rdenomip,'anal',[],'',[],fv);
      end
      dps=1;
    else %numerical derivation
      if isa(pdati,'fidmodel')
        %if ~isequal(pdati.covariance,cdat), pdati.covariance=impcov(cdat); end
        zpstruct.zv0=rnumip; zpstruct.pv0=rdenomip;
        calcmode.da=da; calcmode.dp=dp;
        calcmode.plm=plm; calcmode.axv=axv;
        [zkpdata]=stdpz(pdati,zpstruct,calcmode);
        zv=zpkdata.zv;
        stdz=zpkdata.ztdz;
        pv=zpkdata.pv;
        stdp=zpkdata.stdp;
        g=zpkdata.g;
        stdg=zpkdata.stdg;
      else
        [zv,stdz,pv,stdp,g,stdg,rpz,dps]=...
          stdpz(pdati,cdat,rnumip,rdenomip,da,dp,plm,axv,fv);
      end
    end
  end
  if strcmp(da,'num')&(dp~=dps), warnmes='yes'; else warnmes='no'; end
  if ~isempty(rnumip)
    pzs=[pzs;
      rnumip(:)+stdm*(stdz(:,1)+j*stdz(:,2));
      rnumip(:)-stdm*(stdz(:,1)+j*stdz(:,2))];
  end
  if ~isempty(rdenomi)
    pzs=[pzs;
      rdenomip(:)+stdm*(stdp(:,1)+j*stdp(:,2));
      rdenomip(:)-stdm*(stdp(:,1)+j*stdp(:,2))];
  end
end %calculate uncertainties
ind=find(isnan(pzs)); if ~isempty(ind), pzs(ind)=[]; end
if ~pp&all(size(rdenomip)==size(rdenomi)), rdenomip=rdenomi; end
%
if length(axv)==0
  if any(domain=='zq')
    sc=max([abs(real(pzs));abs(imag(pzs));1.2]);
    axv=[-sc,sc,-sc,sc];
  else %'s' or 'w' or 'p'
    axv=[min(real(pzs)),max(real(pzs)),min(imag(pzs)),max(imag(pzs))];
    if isempty(axv), axv=zeros(1,4); end
    dax=diff(axv);
    if dax(1)==0, dax(1)=0.1*abs(axv(1)); end
    if dax(3)==0, dax(3)=0.1*abs(axv(3)); end
    inca=0.15*[-dax(1),dax(1),-dax(3),dax(3)];
    axv=axv+inca; %increase borders
    if axv(1)>0, axv(1)=inca(1); end
    if axv(2)<0, axv(2)=inca(2); end
  end
end
if axv(1)>=axv(2),
  axv(1)=min(-10*eps,axv(1)*(1+eps));
  axv(2)=max(10*eps,axv(2)*(1+eps));
end
if axv(3)>=axv(4),
  axv(3)=min(-10*eps,axv(3)*(1+eps));
  axv(4)=max(10*eps,axv(4)*(1+eps));
end
if axv(2)-axv(1)>abs(axv(2))&(axv(2)<0) %reasonable to include origo
  axv(2)=0.1*(axv(2)-axv(1));
end
if propplot=='y'
  dax=diff(axv);
  if dax(1)<dax(3), dda=dax(3)-dax(1);
    inca=[-dda/2,dda/2,0,0];
  elseif dax(1)>=dax(3), dda=dax(1)-dax(3);
    inca=[0,0,-dda/2,dda/2];
  end
  axv=axv+inca;
  dax=diff(axv); axv=axv+0.01*[-dax(1),dax(1),-dax(3),dax(3)];
end
%
%Basic plot
%bypass bug in Sun-Matlab: badly conditioned matrix in plot
%Earlier 1e13 was enough. Now 1e-6 (?) may be necessary.
axvrat=abs(diff(axv(1:2))/diff(axv(3:4)));
axvratlim=1e13;
if axvrat>axvratlim, axv(3:4)=axv(3:4)*axvrat/axvratlim;
elseif axvrat<1/axvratlim, axv(1:2)=axv(1:2)/(axvrat*axvratlim);
end
%set(hax,'visible','off')
if ~strcmp(get(hax,'NextPlot'),'add'), delete(allchild(hax)), end
plot(axv(1:2),axv(3:4),'.w','visible','off','markersize',1,'parent',hax)
set(hax,'xlim',axv(1:2),'ylim',axv(3:4))
set(hax,'Plotboxaspectratiomode','manual') %axis('square')
%axis('on'), grid off, hold on
set(hax,'visible','on','xgrid','off','ygrid','off','nextplot','add')
%Plot axes and stability limit
if any(domain=='zq')
  t=[0:2*pi/215:2*pi*(1+eps)];
  plot(cos(t),sin(t),['-',white],'tag','axisz','parent',hax)
  if stablimit<1
    set(hax,'nextplot','add')
    plot(stablimit*cos(t),stablimit*sin(t),[':',red],'tag','stablimit','parent',hax)
  end
else %s-domain or r-domain or w-domain
  if strcmp(domain,'s')|strcmp(domain,'p'), axtyp='-';
  elseif strcmp(domain,'w'), axtyp='-';
  elseif strcmp(domain,'r'), axtyp='-';
  end
  daxv=diff(axv);
  axmul=1000; %large axes to allow rescaling
  %coordinate axes:
  plot(axv(1:2)+axmul*daxv(1)*[-1,1],[0,0],[axtyp,white],...
    [0,0],axv(3:4)+axmul*daxv(3)*[-1,1],[axtyp,white],'tag','axis','parent',hax)
  if stablimit<1
    set(hax,'nextplot','add')
    if strcmp(domain,'s')
      plot(stablimit*[1,1],axv(3:4)+axmul*daxv(3)*[-1,1],[':',red],...
        'tag','stablimit','parent',hax)
    elseif strcmp(domain,'r')
      sst=tanh((stablimit+[-20:0.01:20]*j)*tauR);
      plot(real(sst),imag(sst),[':',red],...
        'tag','stablimit','parent',hax)
    elseif strcmp(domain,'w')
      stlep=max(abs(axv+axmul*[daxv(1)*[-1,1],daxv(3)*[-1,1]]).^2);
      npa=20;
      p2imag=imag([rdenomi;rnumi;parr(:);zarr(:)]'.^2);
      stlv=sqrt(stablimit+j*sort([[-npa*axmul/2:npa*axmul/2]/npa*stlep,...
          ([-npa:npa]/npa*max(abs(daxv([1,3])))).^2,...
          [-eps,eps]*stablimit,p2imag,0.9*p2imag,1.1*p2imag]));
      plot(real(stlv),imag(stlv),[':',red],...
        'tag','stablimit','parent',hax)
      %,real(-stlv),imag(-stlv),[':',red]
    end
  end
end
%
if strncmp(version,'5.',2)
  if exist('isvms'), isvmsi=isvms;
  else isvmsi=strcmp(computer,'VAX_VMSD')|strcmp(computer,'VAX_VMSG');
  end
else
  isvmsi=0;
end
%
if strcmp(cloudmode,'on') %"cloud" plot
  CR=impcov(cdat);
  if any(size(CR)~=length(num)+length(denom)+1)
    error('pdat and cdat do not correspond to each other')
  end
  scvec=fsc.^[length(num)-1:-1:0,length(denom)-1:-1:0,1];
  ntf=length(scvec)-1;
  if domain=='s' %This is the case when scaling is necessary
  elseif domain=='w', scvec(1:ntf)=sqrt(scvec(1:ntf));
  elseif any(domain=='zpqr'), scvec=ones(size(scvec));
  end
  CR=CR.*(scvec'*scvec); %scaled covariance
  %
  [U,D]=eig(CR); %CR*U=U*D
  ind=find(D<0); if ~isempty(ind), D(ind)=zeros(size(ind)); end %eliminate negative eigenvalues
  R=sqrt(D)*U'; %row eigenvectors, scaled by square root of eigenvalues
  %RR1=R'*R; %=CR (scaled)
  %
  if any(any(~isfinite(R)))
    [pdat2,outpar]=elis(pdat.data,'s',length(pdat.num)-1,length(pdat.denom)-1,...
      struct('initset','o','itmax',0,'initmodel',pdat,'plotdens',inf,'fscale',fsc),...
      struct('displaymessages','off'));
    [U,S,V]=svd(outpar.J,0);
    dinvS=diag(S); ind2=find(eps*100*size(S,2)*max(dinvS)>dinvS);
    dinvS(ind2)=inf*ones(size(ind2)); dinvS=1./dinvS; invS=diag(dinvS); 
    R=(V*invS)';
  end
%
  for ii=1:Ncloud
    dnd=cloudm*randn(1,size(R,2))*R;
    pertnum=num+dnd(1:length(num));
    pertdenom=denom+dnd(length(num)+[1:length(denom)]);
    if any(domain=='szr')
      pertrnum=fsc*roots(pertnum); pertrdenom=fsc*roots(pertdenom);
    elseif any(domain=='w')
      pertrnum=sqrt(fsc)*roots(pertnum); pertrdenom=sqrt(fsc)*roots(pertdenom);
    elseif any(domain=='pq')
      pertrnum=fsc*ortroots(pertnum,Znum); pertrdenom=fsc*ortroots(pertdenom,Zdenom);
    end
    set(hax,'nextplot','add')
    plot(real(pertrnum),imag(pertrnum),'.g','MarkerSize',1,'parent',hax)
    plot(real(pertrdenom),imag(pertrdenom),'.c','MarkerSize',1,'parent',hax)
  end %for ii
end
%
set(hax,'nextplot','add')
if 1
  if length(rnumi)>0,
    if ~isvmsi
      plot(real(rnumi),imag(rnumi),['o',magenta],'tag','modelplot','parent',hax)
    else %fix for VMS
      for ii=1:length(rnumi)
        plot(real(rnumi(ii)),imag(rnumi(ii)),['o',magenta],'tag','modelplot','parent',hax)
      end
    end
  end
  if length(rdenomi)>0,
    if ~isvmsi
      plot(real(rdenomi),imag(rdenomi),['x',magenta],'tag','modelplot','parent',hax)
    else %fix for VMS
      for ii=1:length(rdenomi)
        plot(real(rdenomi(ii)),imag(rdenomi(ii)),['x',magenta],'tag','modelplot','parent',hax)
      end
    end
  end
else
  htp=text(mean(get(hax,'xlim')),mean(get(hax,'ylim')),tp,...
    'parent',hax,'horizontalalignment','center')
  set(htp,'Units','normalized')
end
%
if ~strcmp(ntx,'notext')
  %Texts onto plot
  titlpz=sprintf('Zeros/poles: %.0f/%.0f',length(rnumi),length(rdenomi));
  if abs(log10(axv(4)-axv(3)))>=4, titlpz=['   ',titlpz]; end
  if strcmp(domain,'w'), titlpz=['    ',titlpz,' (w)']; end
  title(titlpz,'parent',hax)
  if strcmp(domain,'s')|strcmp(domain,'p')
    unstab=find(real(rdenomi)>stablimit);
    nonmphase=find(real(rnumi)>stablimit);
  elseif strcmp(domain,'r')
    unstab=find(atanh(rdenomi)/tauR>stablimit);
    nonmphase=find(atanh(rnumi)/tauR>stablimit);
  elseif strcmp(domain,'w')
    unstab=find((real(rdenomi.^2)>stablimit)&(real(rdenomi)>0));
    nonmphase=find(real(rnumi.^2)>stablimit);
    %nonmphase=find((real(rnumi.^2)>stablimit)&(real(rnumi)>0));
  elseif any(domain=='zq')
    unstab=find(abs(rdenomi)>stablimit);
    nonmphase=find(abs(rnumi)>stablimit);
  end
  %Not shown:
  nsz=find((axv(1)>real(rnumi))|(axv(2)<real(rnumi))|...
       (axv(3)>imag(rnumi))|(axv(4)<imag(rnumi)) );
  nsp=find((axv(1)>real(rdenomi))|(axv(2)<real(rdenomi))|...
       (axv(3)>imag(rdenomi))|(axv(4)<imag(rdenomi)) );
  nmptxt=[sprintf('nmph/unst: %.0f/%.0f',length(nonmphase),length(unstab)),...
          sprintf(', nsh: %.0f/%.0f',length(nsz),length(nsp))];
  %nmpos=get(hax,'Position'); axes('Position',nmpos);
  %eval('set(gca,''Visible'',''off'')'), axis(axv), axis('square')
  htx=text(0.98*axv(1)+0.02*axv(2),axv(3),nmptxt,...
      'VerticalAlignment','bottom','parent',hax);
  set(htx,'Units','normalized')
end
if ~strcmp(ntx,'nomsg')&~strcmp(ntx,'notext')&(nargin<13)
  set(hax,'xlim',axv(1:2),'ylim',axv(3:4))
  nmpos=get(hax,'Position');
  if nmpos(1)<0.5, p1=0; else p1=0.5; end
  if nmpos(2)<0.5, p2=0; else p2=0.5; end
  if nmpos(3)<0.5, p3=0.5; else p3=1; end
  if nmpos(4)<0.5, p4=0.5; else p4=1; end
  txth=axes('Position',[p1,p2,p3,p4],'parent',hf,'visible','off'); %axes for texts
  %Hide texts from zoom:
  txthcov=axes('Position',[p1,p2,p3,p4],'parent',hf,'visible','off');
  axes(hax); %restore axes for plots
else
   txth=[]; warnmes='no';
   if ~strcmp(ntx,'nomsg')&~strcmp(ntx,'notext'), ntx='nomsg'; end
end
%grid off
%drawnow
%pop graphics window to front, but not if called from elis:
if ~strcmp(ntx,'nomsg')&~strcmp(ntx,'notext'), figure(hf), figure(gcf), end
if strcmp(warnmes,'yes')
  wtx=sprintf('WARNING: dp=%.2g too large, suggested: dp<%.2g  ',dp,dps);
  text(0,0.035,wtx,'VerticalAlignment','bottom','parent',txth)
else
  wtx='';
end
%
if ~strcmp(ntx,'notext')&~strcmp(ntx,'nomsg')&~isempty(cdat)
  if strcmp(da,'num')
    deratxt=sprintf(', derivative: numerical, dp=%.3g',dp);
  else deratxt='';
  end
  if strcmp(confmode,'on')
    if Pc<0.999
      pcontxt=sprintf(['Probability contours for %.3g*sigma',...
        ',  Pc = %.',int2str(Pdig),'f',deratxt],stdm,Pc);
    else
      pcontxt=sprintf(['Probability contours for %.3g*sigma',...
        ',  Pc ~ 1',deratxt],stdm);
    end
  elseif strcmp(cloudmode,'on')
    pcontxt=sprintf('Clouds for poles and zeros, %.0f additional sets',...
      Ncloud);
  else
    pcontxt='';
  end
  if ~isempty(pcontxt), text(0,0,pcontxt,'VerticalAlignment','bottom','parent',txth), end
  if covNaN==1
    text(0,.96,'Dotted square:','VerticalAlignment','bottom','parent',txth)
    text(0,.92,'multiple','VerticalAlignment','bottom','parent',txth)
    text(0,.88,'pole or zero','VerticalAlignment','bottom','parent',txth)
  end
end %not notext or nomsg
%
%Uncertainty ellipses of zeros
axvm=axv;
if strcmp(confmode,'on')
  striph=5.5e-4;
  striph=1.5e-3;
  set(hax,'nextplot','add')
  for k=1:length(rnumip)
    if isfinite(stdz(k,1))&isfinite(stdz(k,2))
      covzk=zeros(2,2);
      covzk(1,1)=stdz(k,1)^2; covzk(2,2)=stdz(k,2)^2;
      covzk(1,2)=stdz(k,1)*stdz(k,2)*stdz(k,3); covzk(2,1)=covzk(1,2);
      [U,D]=eig(covzk); %covzk*U=U*D
      zinf=sqrt(diag(D))'.*(U(1,:)+j*U(2,:)); %2 complex vect, length: eigval.
      if max(abs(diag(D)))*eps*10>min(abs(diag(D))) %degenerate case, strip
         lv=sum(zinf);
         %daxv=diff(axv); lvm=real(lv)/daxv(1)+j*imag(lv)/daxv(3);
         %dlvm=striph*j*lvm/abs(lvm); dlv=real(dlvm)*daxv(1)+j*imag(dlvm)*daxv(3);
         pno=2;
         %locv=rnumip(k)+stdm*([lv;lv;-lv;-lv;lv])+[dlv;-dlv;-dlv;dlv;dlv];
         locv=rnumip(k)+stdm*[-lv;lv];
         set(hax,'nextplot','add')
         plot(real(locv),imag(locv),[':',red],'parent',hax,...
           'tag','modelplotb','linewidth',1)
      else %nondegenerate
        rat=stdm*(abs(zinf(1))+abs(zinf(2)))/(axv(2)-axv(1)+axv(4)-axv(3));
        pno=max(40,min(4094,4*150*rat));
        t=[1:pno]/pno*2*pi;
        locv=rnumip(k)+stdm*(cos(t)*zinf(1)+sin(t)*zinf(2));
        set(hax,'nextplot','add')
        plot(real(locv),imag(locv),['.',red],'markersize',1,...
          'tag','modelplotb','parent',hax)
      end
      indin=find( (real(locv)>axv(1))&(real(locv)<axv(2))&...
                  (imag(locv)>axv(3))&(imag(locv)<axv(4)) );
      if (length(indin)<pno/2)&~strcmp(ntx,'notext')&~strcmp(ntx,'nomsg')
        text(0,0.035,[wtx,'WARNING: fully or partly not visible ellipse'],...
                  'VerticalAlignment','bottom','parent',txth)
      end
    else %infinite or NaN
      covNaN=1;
      rv=(axv-[mean(axv(1:2))*[1,1],mean(axv(3:4))*[1,1]])/20;
      set(hax,'nextplot','add')
      plot(rnumip(k)+[rv(1)+j*rv(3);rv(2)+j*rv(3);rv(2)+j*rv(4);...
          rv(1)+j*rv(4);rv(1)+j*rv(3)],[':',red],...
          'tag','modelplotb','parent',hax)
    end
 end %for k
  %
  %Uncertainty ellipses of poles
  for k=1:length(rdenomip)
    if isfinite(stdp(k,1))&isfinite(stdp(k,2))
      covpk=zeros(2,2);
      covpk(1,1)=stdp(k,1)^2; covpk(2,2)=stdp(k,2)^2;
      covpk(1,2)=stdp(k,1)*stdp(k,2)*stdp(k,3); covpk(2,1)=covpk(1,2);
      [U,D]=eig(covpk); %covzk*U=U*D
      pinf=sqrt(diag(D))'.*(U(1,:)+j*U(2,:)); %2 complex vect, length: eigval.
      if max(abs(diag(D)))*eps*10>min(abs(diag(D))) %degenerate case, strip
        lv=sum(pinf);
        %daxv=diff(axv); lvm=real(lv)/daxv(1)+j*imag(lv)/daxv(3);
        %dlvm=striph*j*lvm/abs(lvm); dlv=real(dlvm)*daxv(1)+j*imag(dlvm)*daxv(3);
        pno=2;
        %locv=rdenomip(k)+stdm*([lv;lv;-lv;-lv;lv])+[dlv;-dlv;-dlv;dlv;dlv];
        locv=rdenomip(k)+stdm*[-lv;lv];
        set(hax,'nextplot','add')
        plot(real(locv),imag(locv),[':',red],'parent',hax,...
          'tag','modelplotb','linewidth',1)
      else %nondegenerate
        rat=stdm*(abs(pinf(1))+abs(pinf(2)))/(axv(2)-axv(1)+axv(4)-axv(3));
        pno=max(40,min(4094,4*150*rat));
        t=[1:pno]/pno*2*pi;
        locv=rdenomip(k)+stdm*(cos(t)*pinf(1)+sin(t)*pinf(2));
        set(hax,'nextplot','add')
        plot(real(locv),imag(locv),['.',red],'markersize',1,...
          'tag','modelplotb','parent',hax)
      end
      indin=find( (real(locv)>axv(1))&(real(locv)<axv(2))&...
                  (imag(locv)>axv(3))&(imag(locv)<axv(4)) );
      if (length(indin)<pno/2)&~strcmp(ntx,'notext')&~strcmp(ntx,'nomsg')
        axes(txth); %axes for texts
        text(0,0.035,[wtx,'WARNING: fully or partly not visible ellipse'],...
                  'VerticalAlignment','bottom','parent',txth)
      end
    else %infinite or NaN
      covNaN=1;
      rv=(axv-[mean(axv(1:2))*[1,1],mean(axv(3:4))*[1,1]])/20;
      set(hax,'nextplot','add')
      plot(rdenomip(k)+[rv(1)+j*rv(3);rv(2)+j*rv(3);rv(2)+j*rv(4);...
        rv(1)+j*rv(4);rv(1)+j*rv(2)],[':',red],...
        'tag','modelplotb','parent',hax)
    end
  end %for k
end %of uncertainty ellipses
%
set(hax,'nextplot','replace')
if ~strcmp(ntx,'notext')
  if ~isempty(plm) %new pole/zero plot was necessary
    title(titlpz,'parent',hax)
    text(0.98*axv(1)+0.02*axv(2),axv(3),nmptxt,'VerticalAlignment','bottom','parent',hax)
  end
end
if ~hgiven&(strcmp(cloudmode,'on')|~isempty(cdat)), zoom(get(hax,'parent'),'on'), end
if nargout>0
  if isa(pdat,'fidmodel')&isstruct(calcmode)
    varargout{1}=struct('zv',rnumip,'pv',rdenomip,'stdz',stdz,'stdp',stdp,'g',g,'stdg',stdg);     
    if nargout>=2, 
      varargout{2}=rzp;
      varargout{3}=dps;
    end
  else
    %rnum=rnumip; rdenom=rdenomip; 
    varargout{1}=rnumip; varargout{2}=rdenomip; 
  end
end
%%%%%%%%%%%%%%%%%%%%%%%% end of plotelpz %%%%%%%%%%%%%%%%%%%%%%%%
