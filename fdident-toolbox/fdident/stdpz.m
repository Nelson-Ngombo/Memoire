function varargout=stdpz(varargin)
%STDPZ  Calculate standard deviations and covariances of poles and zeros of tf.
%
%       [zpkdata,rzp,dps]=STDPZ(pdat,zpstruc,calcmode)
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
%       zpstruc = structure of initial pole/zero vectors or empty
%           optional fields:
%           zv0 - vector of zeros (this vector determines the order in
%                  the vector zv)
%           pv0 - vector of poles (this vector determines the order in
%                  the vector pv)
%       calcmode = structure of calculation mode descriptors
%           optional fields:
%           da - mode of derivative calculation.
%              For 'anal' (the default value), root/coefficient
%              sensitivities are calculated by analytical differentiation
%              of the polynomials.
%              For 'num', small perturbations and numerical differentiation
%              are used. The perturbations are introduced in the directions
%              of the eigenvectors of the covariance matrix, the amount is
%              the corresponding eigenvector. The perturbations can be
%              multiplied by a constant factor dp.
%              Default value: 'anal'
%           dp - amount of perturbation of parameter vector in the directions
%              of the eigenvectors of the covariance matrix (multiplier
%              of the eigenvalues)
%           plm - plotmode: if plm is given with value 'mc', the perturbed
%              sets and the pairing will be shown on the screen, one after
%              other; when with value 'mp', a statement pause will be
%              executed after each pairing.
%           axv - axis vector to influence plotted range in movie
%
%       Usage:
%           [zpkdata,rzp,dps]=stdpz(pdat,zpstruc,calcmode);
%       Example:
%           pdat=elis('inpchan','s',11,12);
%           zpkdata=stdpz(pdat);
%
%       See also: PLOTELPZ, FDCOVPZP.

%Old fdident help
%STDPZ  Calculate standard deviations and covariances of poles and zeros of tf.
%
%       [zv,stdz,pv,stdp,g,stdg,rzp,dps]=...
%                       STDPZ(pdat,cdat,zv0,pv0,da,dp,plm,axv,freqv)
%
%       Output arguments:
%       zv = column vector of zeros
%       stdz = array of standard deviations of the zeros; the three columns
%           contain the std-s of the real parts, std-s of the imaginary
%           parts, and their correlation coefficients, respectively.
%           For multiple zeros NaN-s are returned if da is 'anal'.
%       pv = column vector of poles
%       stdp = array of standard deviations of the poles; the three columns
%           contain the std-s of the real parts, std-s of the imaginary
%           parts, and their correlation coefficients, respectively
%           For multiple poles NaN-s are returned if da is 'anal'.
%       g = gain, the leading coefficients in the Matlab representation
%           of the numerator and the denominator.
%       stdg = 3x1 vector of standard deviations of g and their correlation
%           coefficient
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
%       pdat = parameter vector (see EXPPAR) or the name of parameter file
%       cdat = covariance matrix of parameters or covariance vector
%           (see EXPCOV) or name of covariance file
%       zv0  = vector of zeros (this vector determines the order in the
%           vector zv), optional, may be empty
%       pv0  = vector of poles (this vector determines the order in the
%           vector pv), optional, may be empty
%       da = mode of derivative calculation.
%           For 'anal' (the default value), root/coefficient
%           sensitivities are calculated by analytical differentiation
%           of the polynomials.
%           For 'num', small perturbations and numerical differentiation
%           are used. The perturbations are introduced in the directions
%           of the eigenvectors of the covariance matrix, the amount is
%           the corresponding eigenvector. The perturbations can be
%           multiplied by a constant factor dp.
%           Default value: 'anal'
%       dp = amount of perturbation of parameter vector in the directions
%           of the eigenvectors of the covariance matrix (multiplier
%           of the eigenvalues)
%       plm = plotmode: if plm is given with value 'mc', the perturbed
%           sets and the pairing will be shown on the screen, one after
%           other; when with value 'mp', a statement pause will be
%           executed after each pairing.
%       axv = axis vector (optional) to influence plotted range in movie
%       freqv = non-scaled frequency grid for the evaluation of the
%       orthonormal bases
%
%       Usage:
%           [zv,stdz,pv,stdp,g,stdg,rzp,dps]=...
%                                stdpz(pdat,cdat,zv0,pv0,da,dp,plm,axv,freqv);
%       Example:
%           [pvect,fit,Cp]=elis('inpchan',[],['s',11,12]);
%           [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pvect,Cp);
%
%       See also: PLOTELPZ, FDCOVPZP.

%       The kernel of the analytical derivation algorithm was written by
%         Patrick Guillaume (VUB).
%       Reference: P. Guillaume, J. Schoukens and R. Pintelon, "Sensitivity of
%         roots to errors in the coefficients of polynomials obtained by
%         frequency-domain estimation methods," IEEE Trans. Instrumentation and
%         Measurement, Vol. 38, No. 6, pp. 1050-1056, Dec. 1989.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Aug-2002

if (nargin==1)&isstr(varargin{1})&strcmp(varargin{1},'preload')
  return %loading only for one argument 'preload'
end
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,9); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,9,ni)), %earlier
end
pdat=getobjf(varargin{1},'fidmodel');
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
zv0=[]; pv0=[]; da=[]; dp=[]; plm=''; axv=[]; freqv=[];
if isa(pdat,'fidmodel')
  %new call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,3,ni)), %earlier
  end
  if nargout>=1, rzpreq=1; else rzpreq=0; end
  if strcmp(pdat.representation,'orthopol')
    freqv=pdat.data.freqpoints; %unscaled frequencies
  end
  cdat=pdat.covariance;
  if nargin>=2
    zpstruc=varargin{2};
    if isnan(zpstruc), zpstruc=[]; end
    if ~isstruct(zpstruc)&~isempty(zpstruc), error('zpstruc is not allowed'), end
    if isfield(zpstruc,'zv0'), zv0=zpstruc.zv0; end
    if isfield(zpstruc,'pv0'), pv0=zpstruc.pv0; end
  end
  if nargin>=3
    calcmode=varargin{3};
    if ~isstruct(calcmode)&~isempty(calcmode)
      error('calcmode is not allowed')
    end
    if isfield(calcmode,'da'), da=calcmode.da; end
    if isfield(calcmode,'dp'), dp=calcmode.dp; end
    if isfield(calcmode,'plm'), plm=calcmode.plm; end
    if isfield(calcmode,'axv'), axv=calcmode.axv; end
  end
else
  %old call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,9); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,9,ni)), %earlier
  end
  if nargin>=9, freqv=varargin{9}; end
  if nargin>=8, axv=varargin{8}; end
  if nargin>=7, plm=varargin{7}; end
  if nargin>=6, dp=varargin{6}; end
  if nargin>=5, da=varargin{5}; end
  if nargin>=4, pv0=varargin{4}; end
  if nargin>=3, zv0=varargin{3}; end
  cdat=varargin{2};
  if nargout>=7, rzpreq=1; else rzpreq=0; end
end
%
%Prepare run
if isempty(dp), dp=1; end
if isempty(da), da='anal'; end
if ~strcmp(da,'num')&~strcmp(da,'anal')
  error(['da = ''',da,''' is not allowed'])
end
if ~isempty(plm)&~strcmp(plm,'mc')&~strcmp(plm,'mp')
  error(['plm = ''',plm,''' is not allowed'])
end
%
if isnan(cdat)
  if isa(pdat,'fidmodel'), cdat=pdat.covariance;
  else error('cdat is NaN, but pdat is not fidmodel')
  end
end
[domain,num,denom,delay,fsc,Znum,Zdenom,comment,fdata,ntr,Zntr]=imppar(pdat);
if ~isempty(freqv), freqv=freqv/fsc; fv=freqv; %scale freqs for orthopol
elseif any(domain=='pq')
  if isa(pdat,'fidmodel')
    fv=pdat.freqvect/fsc;
    [vnum,pcoeffnum]=orthpval(num,Znum,fv);
    [vdenom,pcoeffdenom]=orthpval(denom,Zdenom,fv);
  else
    error('Cannot evaluate pole/zero errors for orthopol without frequency vector')
  end
end
fscset=[];
%fscset=1; %Test value of fsc=1
if any(domain=='sw')
  pdati=exppar(domain,num,denom,delay);
  [domain,num,denom,delay,fsc]=imppar(pdati,fscset); %get fsc
elseif any(domain=='zq')
  fsc=1;
end
%fprintf('fsc = %.2g in stdpz\n',fsc)
numord=length(num)-1; denomord=length(denom)-1;
if any(domain=='sz')
  rnumi=fsc*roots(num); rdenomi=fsc*roots(denom); %true (not scaled) values
elseif any(domain=='pq')
  rnumi=fsc*ortroots(num,Znum); rdenomi=fsc*ortroots(denom,Zdenom);
  tfval=orthpval(num,Znum,fv,[],domain)./orthpval(denom,Zdenom,fv,[],domain);
elseif domain=='w'
  rnumi=sqrt(fsc)*roots(num); rdenomi=sqrt(fsc)*roots(denom);
elseif domain=='r'
  rnumi=roots(num); rdenomi=roots(denom);
end
%
lambda=1e4;
if ~isempty(zv0)
  if length(zv0)~=length(rnumi), error('Orders of zv0 and pdat differ'), end
  [pointv,cycle]=pairs(zv0,rnumi,1);
  if any(abs(zv0-rnumi(pointv))>eps*lambda*abs(zv0))
    error('Zeros defined by zv0 and pdat differ significantly')
  end
  rnumi=rnumi(pointv);
end
zv=rnumi;
%
if ~isempty(pv0)
  if length(pv0)~=length(rdenomi), error('Orders of pv0 and pdat differ'), end
  [pointv,cycle]=pairs(pv0,rdenomi,1);
  if any(abs(pv0-rdenomi(pointv))>eps*lambda*abs(pv0))
    error('Poles defined by pv0 and pdat differ significantly')
  end
  rdenomi=rdenomi(pointv);
end
pv=rdenomi;
%
if ~any(domain=='pq')
  g=[num(1)/fsc^numord,denom(1)/fsc^denomord]; %gain
else
  if isempty(fv), error('for orthopol, freqv must be given'), end
  nord=length(num)-1; dord=length(denom)-1;
  if length(num)>1, vnum=orthopol(nord,domain,freqv,[],Znum); else vnum=ones(size(num)); end
  if length(denom)>1, vdenom=orthopol(dord,domain,freqv,[],Zdenom); else vdenom=ones(size(denom)); end
  [dummy,ind1]=max(abs(num*vnum.'));
  [dummy,ind2]=max(abs(denom*vdenom.'));
  if domain=='p'
    g=[(num*vnum(ind1,:).')/prod(j*2*pi*fv(ind1)-rnumi/fsc),...
      (denom*vdenom(ind2,:).')/prod(j*2*pi*fv(ind2)-rdenomi/fsc)];
  else %domain='q'
    g=[(num*vnum(ind1,:).')/prod(exp(-j*2*pi*fv(ind1))-1./rnumi),...
        (denom*vdenom(ind2,:).')/prod(exp(-j*2*pi*fv(ind2))-1./rdenomi)];
  end
  if ~any(imag(num))&~any(imag(denom)), g=real(g); end
  [dummy,pcoeffnum]=orthpval(num,Znum,fv);
  [dummy,pcoeffdenom]=orthpval(denom,Zdenom,fv);
end
%
pcovar=impcov(cdat); %covariance matrix of parameters (not scaled except for p and q)
ltr=length(ntr);
if length(pcovar)~=numord+denomord+3+ltr
  error('pdat and cdat are incompatible')
end
if ltr>0
  nc=size(pcovar,1);
  pcovar=pcovar(1:nc-ltr,1:nc-ltr);
end
%
if strcmp(da,'num'), dps=dp; else dps=[]; end
sugdp=dp;
%
if ~isempty(plm)&strcmp(da,'num')
  %plots are required
  if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
  if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
  else blue='b'; red='r'; green='g';
  end
  if (mean(get(gcf,'Color'))>=0.5), yellow=blue; %white bg
  elseif (get(0,'ScreenDepth')>=8), yellow='y';
  else yellow=green;
  end
  tp=0;
  pzs=[rnumi(:);rdenomi(:)];
  if isempty(axv)
    if strcmp(domain,'zq')
      sc=max([abs(real(pzs));abs(imag(pzs));1.2]);
      sc=2;
      axv=[-sc,sc,-sc,sc];
    elseif any(domain=='swp')
      axv=[min(real(pzs)),max(real(pzs)),min(imag(pzs)),max(imag(pzs))];
      if isempty(axv), axv=zeros(1,4); end
      dax=diff(axv);
      if dax(1)==0, dax(1)=0.1*abs(axv(1)); end
      if dax(3)==0, dax(3)=0.1*abs(axv(3)); end
      inca=0.15*[-dax(1),dax(1),-dax(3),dax(3)];
      axv=axv+inca; %increase borders
      %if axv(1)>0, axv(1)==inca(1); end
      %if axv(2)<0, axv(2)==inca(2); end
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
  %
  axvrat=abs(diff(axv(1:2))/diff(axv(3:4)));
  %bypass bug in Sun-Matlab 4.0: badly conditioned matrix in plot
  if axvrat>1e13, axv(3:4)=axv(3:4)*axvrat/1e13;
  elseif axvrat<1e-13, axv(1:2)=axv(1:2)/(axvrat/1e-13);
  end
  axis('off')
  plot(axv(1:2),axv(3:4),'.k','visible','off','markersize',1), axis(axv);
  axis('square'), axis('on'), hold on
  if any(domain=='zq')
    t=[0:2*pi/215:2*pi*(1+eps)];
    plot(cos(t),sin(t),['-',white])
  elseif any(domain=='swp')
    plot(axv(1:2),[0,0],['-',white],[0,0],axv(3:4),['-',white]) %coordinate ax
  end
  hold on
  %
  if length(rnumi)>0,
    plot(real(rnumi),imag(rnumi),['o',yellow])
  end
  if length(rdenomi)>0,
    plot(real(rdenomi),imag(rdenomi),['x',yellow])
  end
  %Texts onto plot
  titlpz=sprintf('Zeros/poles: %.0f/%.0f',...
                length(rnumi),length(rdenomi));
  if abs(log10(axv(4)-axv(3)))>=4, titlpz=['   ',titlpz]; end
  title(titlpz)
  ploth=gca; axis(axv); grid off, drawnow
  txth=axes('Position',[0,0,1,1]); axis('off') %axes for texts
  axes(ploth); %restore axes for plots
  pointpos=0.5; %starting position of movie indicator points
else
  txth=[];
end %~isempty(plm)
%
%CALCULATE STANDARD DEVIATIONS
%
%ZEROS
%covariance matrix of scaled numerator:
nzc=pcovar(1:numord+1,1:numord+1);
if any(domain=='pqz')
else
  if domain=='w'
    fscvz=sqrt(fsc).^[numord:-1:0];
  else %s
    fscvz=fsc.^[numord:-1:0];
  end
  nzc=(fscvz'*fscvz).*nzc;
end
%
numalg='eig';
%numalg='svd';
%calculate sensitivity of real/imaginary parts of zeros
Nz=length(rnumi);
if strcmp(da,'anal')&(Nz>0)
  %The algorithm determines the sensitivity matrix of roots to coefficients
  %The basic idea is:  dr(i,j) = df/dp / df/dro = ro(i)^j / f'(ro(i))
  %where ro(i) is a root, and f is the s-polynomial at ro(i).
  %For orthopol, dr(i,j) = df/dp / df/dro = q_j(ro(i)) / f'(ro(i))
  if domain=='w', s=rnumi/sqrt(fsc);
  else s=rnumi/fsc;
  end
  co=num; cocov=nzc;
  stot=length(rnumi);
  %
  ro=[]; %collect new root vector
  nco=length(co);
  %
  %eliminate one from each complex conjugate pair
  i=0; idel=[];
  while i<length(s), i=i+1;
    if imag(s(i))~=0
      [dummy,ind]=min(abs(conj(s(i))-s(i+1:length(s))));
      s(i+ind(1))=[];
    end
  end
  ns=length(s);
  %derivatives:
  if ~any(domain=='pq')
    coderiv=co(1:nco-1).*[nco-1:-1:1]; %derivative by s or z
    deriv=polyval(coderiv,s); %f'(ri)
  else %domain=='pq'
    %pcoeffnum
    deriv=zeros(size(s));
    if 0 %wrong: use polynomial representation of orthopol model
      for ii=1:size(pcoeffnum,1)
        coo=pcoeffnum(ii,:)*co(ii);
        coderiv=coo(1:nco-1).*[nco-1:-1:1]; %derivative by s or z
        deriv=deriv+polyval(coderiv,s); %f'(ri)
      end
    else %follow Yves Rolain's paper
      for ii=1:length(s)  
        sm=rnumi/fsc; [dummy,ind]=min(abs(sm-s(ii))); smii=sm(ind); sm(ind)=[];
        deriv(ii)=g(1)*prod(smii-sm);
      end
    end
  end
  k=[nco-1:-1:0]; A=zeros(size(k)); Ac=A;
  ir=1; drdv=zeros(stot,nco);
  for i=1:ns
    if imag(s(i))~=0 %complex root
      if deriv(i)==0 %multiple root
        ro=[ro;s(i);conj(s(i))];
        NaNv=NaN; %bypass Vax problem with NaN*
        drdv([ir,ir+1],:)=NaNv(ones(2,1),ones(1,nco));
      else %multiplicity one
        if ~any(domain=='pq')
          %calculation of the complex row vector A(k) = si^k/f'(si)
          Ac=(s(i).^k)/deriv(i);
        else
          for ki=k
            Ac(ki+1)=polyval(pcoeffnum(ki+1,:),s(i))/deriv(i);
          end
        end
        ro=[ro;s(i);conj(s(i))];
        drdv([ir,ir+1],:)=[Ac;conj(Ac)];
      end
      ir=ir+2;
    else %real root
      if deriv(i)==0 %multiple root
        %results
        ro=[ro;s(i)];
        NaNv=NaN; %bypass Vax problem with NaN*
        drdv(ir,:)=NaNv(1,ones(1,nco));
      else %multiplicity one
        if ~any(domain=='pq')
          %calculation of the row vector A(k) = si^k/f'(si)
          A=real((s(i).^k)/deriv(i));
        else
          for ki=k
            A(ki+1)=polyval(pcoeffnum(ki+1,:),s(i))/deriv(i);
          end
        end
        ro=[ro;s(i)];
        drdv(ir,:)=A;
      end
      ir=ir+1;
    end %if statement: complex or real
  end %for i=1 to number of roots
  %The last problem is that the order of roots has been changed.
  if domain=='w'
    [iperm,cycle]=pairs(rnumi/sqrt(fsc),ro,1);
    dzdn=sqrt(fsc)*drdv(iperm,:); %Sensitivity of true zeros
  else
    [iperm,cycle]=pairs(rnumi/fsc,ro,1);
    dzdn=fsc*drdv(iperm,:); %Sensitivity of true zeros
  end
elseif strcmp(da,'num')&(Nz>0) %numerical approximation follows
  if strcmp(numalg,'eig')
    [Vz,Dzv]=eig(nzc); %nzc*Vz=Vz*Dzv
    ind=find(Dzv<0); if ~isempty(ind), Dzv(ind)=zeros(size(ind)); end
    [Dzabs,indz]=sort(-abs(diag(Dzv))); maxD=-Dzabs(1);
    minDr=sqrt(10*eps*maxD);
    Vz=Vz(:,indz); Dzv=diag(Dzv(indz,indz));
  else
    %SVD rather
    [Vz,Dzv,dummy]=svd(nzc);
    Dzv=diag(Dzv); maxD=Dzv(1);
    minDr=sqrt(10*eps*maxD);
  end
  %
  %Eigenvalues ordered by descending absolute values
  %Index of last significant eigenvalue:
  lvz=min([find( sqrt(abs(Dzv))<minDr );length(Dzv)+1])-1;
  lvzn=sum(diag(nzc)~=0);
  if lvz<lvzn
    disp('WARNING! Low rank of the covariance matrix of zeros in stdpz')
    fprintf('Free parameters: %.0f, usable eigenvalues: %.0f\n',lvzn,lvz)
    %lvz=lvzn;
  end
  %
  dzdv=zeros(numord,lvz);
  if numord>0
    dist=min(abs(ones(numord,1)*rnumi.'-rnumi*ones(1,numord))+...
         10*max(abs(rnumi))*eye(numord,numord))'; %distance to closest zero
    for kp=1:lvz %a cycle for each important direction
      stepl=dp*max(sqrt(abs(Dzv(kp))),minDr);
      dpk=stepl*Vz(:,kp)';
      numk=num+dpk;
      if any(domain=='pq')
        rnumk=fsc*ortroots(numk,Znum);
      elseif domain=='w'
        rnumk=sqrt(fsc)*roots(numk);
      else %sr
        rnumk=fsc*roots(numk);
      end
      [pointv,cycle,digits]=pairs(rnumi,rnumk,2,10);
      if cycle>0, sugdp=dp/2; end
      if ~isempty(plm)
        hold on
        for k=1:Nz
          zin=rnumi(k); zk=rnumk(pointv(k));
          plot(real([zk]),imag([zk]),['o',red])
          plot(real([zin,zk]),imag([zin,zk]),['-',white])
        end
        %plot(real(rnumi),imag(rnumi),['o',yellow])
      end
      rd=abs(rnumi-rnumk(pointv)); inde=find(rd>dist/2);
      if ~isempty(inde)
        sugdp=min([sugdp;dp*(dist(inde)/4)./rd(inde)]);
      end
      if ~isempty(plm)
        if kp==1
          axes(txth); %axes for texts
          dtxt=sprintf('deltap=%.3g*sigmapeig in numerical derivations',dp);
          text(0,0.04,dtxt,'VerticalAlignment','bottom')
          disp(dtxt)
          axes(ploth)
          disp('A dot will be displayed for each perturbation:')
        end
        if rem(kp,5)==0, fprintf(':'), else fprintf('.'), end
        if kp==lvz, disp(' '), end
        grid off
        if strcmp(plm,'mp'), pause, else drawnow, end
      end
      dzdv(:,kp)=(rnumk(pointv)-rnumi)/stepl;
    end %for kp
    dzdn=dzdv*Vz(:,1:lvz)'; %Sensitivity of true zeros
  end %numord>0
else %no zeros or testing
  dzdn=zeros(length(rnumi),length(num));
end %strcmp(da,...
%
%Standard deviations of zeros
%if domain=='p', nzc=pcoeffnum'*nzc*pcoeffnum; end
stdz=zeros(Nz,3);
for k=1:Nz
  covzk=[real(dzdn(k,:));imag(dzdn(k,:))]*nzc*...
        [real(dzdn(k,:));imag(dzdn(k,:))]';
  stdz(k,1)=sqrt(covzk(1,1));
  stdz(k,2)=sqrt(covzk(2,2));
  if covzk(1,2)~=0, stdz(k,3)=covzk(1,2)/sqrt(covzk(1,1)*covzk(2,2));
  else stdz(k,3)=0;
  end
end
if Nz>0
  ind=find(abs(stdz(:,3))>1+1000*(numord+denomord)*eps);
  if ~isempty(ind)
    disp('WARNING! A correlation coefficient in stdz is larger than 1 in stdpz')
  end
  ind=find((abs(stdz(:,3))>1)&(abs(stdz(:,3))<=1+1000*(numord+denomord)*eps));
  if ~isempty(ind), stdz(ind,3)=sign(stdz(ind,3)); end
end
%
%POLES
%covariance matrix of scaled denominator
npc=pcovar(numord+2:numord+denomord+2,numord+2:numord+denomord+2);
if any(domain=='pqz')
else
  if domain=='w'
    fscvp=sqrt(fsc).^[denomord:-1:0];
  else %s
    fscvp=fsc.^[denomord:-1:0];
  end
  npc=(fscvp'*fscvp).*npc;
end
%
%calculate sensitivity of real/imaginary parts
Np=length(rdenomi);
%
if strcmp(da,'anal')&(Np>0)
  %The algorithm determines the sensitivity matrix of roots to coefficients
  %The basic idea is:  dr(i,j) = ro(i)^j / f'(ro(i))
  %where ro(i) is a root, and f is the polynomial.
  if domain=='w', s=rdenomi/sqrt(fsc);
  else s=rdenomi/fsc;
  end
  co=denom; cocov=npc;
  stot=length(s);
  %
  ro=[]; %collect new root vector
  nco=length(co);
  %
  %eliminate one from each complex conjugate pair
  i=0; idel=[];
  if ~isa(pdat,'fidmodel')|~strcmp(get(pdat,'coefficients'),'complex')
    while i<length(s)
      i=i+1;
      if imag(s(i))~=0
        [dummy,ind]=min(abs(conj(s(i))-s(i+1:length(s))));
        if ~isempty(ind), s(i+ind(1))=[]; end
      end
    end
  end
  %
  ns=length(s);
  %derivatives:
  coderiv=co(1:nco-1).*[nco-1:-1:1];
  if ~any(domain=='pq')
    deriv=polyval(coderiv,s); %f'(si)
  else %domain=='pq'
    if 1 %wrong: use polynomial representation of orthopol model
      %pcoeffdenom
      deriv=zeros(size(s));
      for ii=1:size(pcoeffdenom,1)
        coo=pcoeffdenom(ii,:)*co(ii);
        coderiv=coo(1:nco-1).*[nco-1:-1:1]; %derivative by s or z
        deriv=deriv+polyval(coderiv,s); %f'(ri)
      end
    else %follow Yves Rolain's paper
      for ii=1:length(s)  
        sm=rdenomi/fsc; [dummy,ind]=min(abs(sm-s(ii))); smii=sm(ind);
        sm(ind)=[];
        deriv(ii)=g(2)*prod(smii-sm);
      end
    end
  end
  k=[nco-1:-1:0]; A=zeros(size(k)); Ac=A;
  ir=1; drdv=zeros(stot,nco);
  for i=1:ns
    if imag(s(i))~=0 %complex root
      if deriv(i)==0 %multiple root
        ro=[ro;s(i);conj(s(i))];
        NaNv=NaN; %bypass Vax problem with NaN*
        drdv([ir,ir+1],:)=NaNv(ones(2,1),ones(1,nco));
      else %multiplicity one
        if ~any(domain=='pq')
          %calculation of the complex row vector A(k) = si^k/f'(si)
          Ac=(s(i).^k)/deriv(i);
        else %domain=='pq'
          for ki=k
            Ac(ki+1)=polyval(pcoeffdenom(ki+1,:),s(i))/deriv(i);
          end
        end
        ro=[ro;s(i);conj(s(i))];
        drdv([ir,ir+1],:)=[Ac;conj(Ac)];
      end
      ir=ir+2;
    else %real root
      if deriv(i)==0 %multiple root
        %results
        ro=[ro;s(i)];
        NaNv=NaN; %bypass Vax problem with NaN*
        drdv(ir,:)=NaNv(1,ones(1,nco));
      else %multiplicity one
        if ~any(domain=='pq')
          %calculation of the row vector A(k) = si^k/f'(si)
          A=real((s(i).^k)/deriv(i));
        else %domain=='pq'
          for ki=k
            A(ki+1)=polyval(pcoeffdenom(ki+1,:),s(i))/deriv(i);
          end
        end
        ro=[ro;s(i)];
        drdv(ir,:)=A;
      end
      ir=ir+1;
    end %if statement: complex or real
  end %for i=1 to number of roots
  %The last problem is that the order of roots has been changed.
  if domain=='w'
    [iperm,cycle]=pairs(rdenomi/sqrt(fsc),ro,1);
    dpdd=sqrt(fsc)*drdv(iperm,:); %Sensitivity of true poles
  else
    [iperm,cycle]=pairs(rdenomi/fsc,ro,1);
    dpdd=fsc*drdv(iperm,:); %Sensitivity of true poles
  end
elseif strcmp(da,'num')&(Np>0)
  if strcmp(numalg,'eig')
    [Vp,Dpv]=eig(npc); %npc*Vp=Vp*Dpv
    [mDpvabs,indp]=sort(-abs(diag(Dpv)));
    ind=find(Dpv<0); if ~isempty(ind), Dpv(ind)=zeros(size(ind)); end
    maxD=-mDpvabs(1); minDr=sqrt(10*eps*maxD);
    Vp=Vp(:,indp); Dpv=diag(Dpv(indp,indp));
  else
    %SVD rather
    [Vp,Dp,dummy]=svd(npc);
    Dpv=diag(Dp); maxD=Dp(1);
    minDr=sqrt(10*eps*maxD);
  end
  %
  %Eigenvalues ordered by descending absolute values
  %Index of last significant eigenvalue:
  lvp=min([find( sqrt(abs(Dpv))<minDr );length(Dpv)+1])-1;
  lvpn=sum(diag(npc)~=0);
  if lvp<lvpn
    disp('WARNING! Low rank of the covariance matrix of poles in stdpz')
    fprintf('Free parameters: %.0f, usable eigenvalues: %.0f\n',lvpn,lvp)
    %lvp=lvpn;
  end
  %
  dpdv=zeros(denomord,lvp);
  if denomord>0
    dist=min(abs(ones(denomord,1)*rdenomi.'-rdenomi*ones(1,denomord))+...
       10*max(abs(rdenomi))*eye(denomord,denomord))'; %distance to closest pole
    for kp=1:lvp %a cycle for each important direction
      stepl=dp*max(sqrt(abs(Dpv(kp))),minDr);
      dpk=stepl*Vp(:,kp)';
      denomk=denom+dpk;
      if any(domain=='pq')
        rdenomk=fsc*ortroots(denomk,Zdenom);
      elseif domain=='w'
        rdenomk=sqrt(fsc)*roots(denomk);
      else %sr
        rdenomk=fsc*roots(denomk);
      end
      [pointv,cycle,digits]=pairs(rdenomi,rdenomk,2,10);
      if cycle>0, sugdp=dp/2; end
      if ~isempty(plm)
        hold on
        for k=1:Np
          pin=rdenomi(k); pk=rdenomk(pointv(k));
          plot(real([pk]),imag([pk]),['x',red])
          plot(real([pin,pk]),imag([pin,pk]),['-',white])
        end
        %plot(real(rdenomi),imag(rdenomi),['x',yellow])
      end
      rd=abs(rdenomi-rdenomk(pointv)); inde=find(rd>dist/2);
      if ~isempty(inde)
        sugdp=min([sugdp;dp*(dist(inde)/4)./rd(inde)]);
      end
      if ~isempty(plm)
        if rem(kp,5)==0, fprintf(':'), else fprintf('.'), end
        if kp==lvp, disp(' '), end
        grid off
        if strcmp(plm,'mp'), pause, else drawnow, end
        %if rem(kp,5)==0, text(pointpos,0.045,'.'), end
        %text(pointpos,0.04,'.'), pointpos=pointpos+0.01;
        %if strcmp(plm,'mp')
        %  text(0,0.8,'Press any key to continue ...',...
        %     'VerticalAlignment','bottom'), pause
        %end
        %axes(ploth)
      end
      dpdv(:,kp)=(rdenomk(pointv)-rdenomi)/stepl;
    end %for kp
    dpdd=dpdv*Vp(:,1:lvp)'; %Sensitivity of true poles
  end %denomord>0
else %no poles or testing
  dpdd=zeros(length(rdenomi),length(denom));
end %strcmp(da,...
%
%Standard deviations of poles
%if domain=='p', npc=pcoeffdenom'*npc*pcoeffdenom; end
stdp=zeros(Np,3);
for k=1:Np
  covpk=[real(dpdd(k,:));imag(dpdd(k,:))]*npc*...
        [real(dpdd(k,:));imag(dpdd(k,:))]';
  stdp(k,1)=sqrt(covpk(1,1));
  stdp(k,2)=sqrt(covpk(2,2));
  if covpk(1,2)~=0, stdp(k,3)=covpk(1,2)/sqrt(covpk(1,1)*covpk(2,2));
  else stdp(k,3)=0;
  end
end
if Np>0
  ind=find(abs(stdp(:,3))>1+1000*(numord+denomord)*eps);
  if ~isempty(ind)
    disp('WARNING! A correlation coefficient in stdp is larger than 1 in stdpz')
  end
  ind=find((abs(stdp(:,3))>1)&(abs(stdp(:,3))<=1+1000*(numord+denomord)*eps));
  if ~isempty(ind), stdp(ind,3)=sign(stdp(ind,3)); end
end
%
%FINAL ADMINISTRATION
if strcmp(da,'num')&(sugdp~=dp)
  dps=sugdp;
  if ~isempty(plm)&strcmp(da,'num')
    wtx=sprintf('WARNING: dp=%.2g too large, suggested: %.2g  ',dp,sugdp);
    axes(txth);
    text(0,0,wtx,'VerticalAlignment','bottom'), tp=0.04;
    axes(ploth);
    if strcmp(plm,'mp'), pause, end
  end
end
%
if rzpreq
  if Nz>0
    dzdntot=zeros(2*Nz,length(num));
    dzdntot(1:2:2*Nz,:)=real(dzdn); dzdntot(2:2:2*Nz,:)=imag(dzdn);
  else
    dzdntot = zeros(0,length(num));
  end
  if Np>0
    dpddtot=zeros(2*Np,length(denom));
    dpddtot(1:2:2*Np,:)=real(dpdd); dpddtot(2:2:2*Np,:)=imag(dpdd);
  else
    dpddtot = zeros(0,length(denom));
  end
  drdp=[dzdntot,[zeros(2*Nz,length(denom))];...
        [zeros(2*Np,length(num))],dpddtot];
  %gain: [numtrue(1);denomtrue(1)]=[num(1)/fsc^numord;denom(1)/fsc^denomord]
  drdpext=zeros(2,length(num)+length(denom));
  drdpext(1,1)=1/fsc^numord; drdpext(2,numord+2)=1/fsc^denomord;
  drdp=[drdp;drdpext];
  %
  %covariance matrix of scaled parameter vector
  pcovsc=pcovar(1:numord+denomord+2,1:numord+denomord+2);
  if ~any(domain=='pqz')
    pcovsc=([fscvz,fscvp]'*[fscvz,fscvp]).*pcovsc;
  end
  rzp=drdp*pcovsc*drdp';
  rzpl=length(rzp);
  %Treat fixed leading coefficients
  if pcovar(1,1)==0
    rzp(:,rzpl-1)=zeros(rzpl,1); rzp(rzpl-1,:)=zeros(1,rzpl);
  end
  if pcovar(numord+2,numord+2)==0
    rzp(:,rzpl)=zeros(rzpl,1); rzp(rzpl,:)=zeros(1,rzpl);
  end
  stdg=rzp(rzpl-1:rzpl,rzpl-1:rzpl); %std of gain
  stdg=[sqrt(stdg(1));sqrt(stdg(4));stdg(2)];
  if stdg(1)*stdg(2)~=0, stdg(3)=stdg(3)/(stdg(1)*stdg(2)); end
  diagrzp=diag(rzp);
  ind=find(diagrzp==0);
  diagrzp(ind)=ones(length(ind),1);
  rzp=rzp./sqrt(diagrzp(:,ones(1,length(rzp(:,1)))))./...
           sqrt(diagrzp(:,ones(1,length(rzp(:,1)))))';
  for i=ind(:)', rzp(i,i)=1; end
  ind=find(abs(rzp(:))>1+1000*(numord+denomord)*eps);
  if ~isempty(ind)
    warning('A correlation coefficient in rzp is larger than 1 in stdpz')
  end
  ind=find( (abs(rzp(:))>1) & (abs(rzp(:))>1+1000*(numord+denomord)*eps) );
  if ~isempty(ind), rzp(ind)=sign(rzp(ind)); end
else %not required
  rzp=[]; stdg=[];
end
%
if ~isempty(txth), hold off, delete(txth), end
if isa(pdat,'fidmodel')
  zpkdata.zv=zv;
  zpkdata.stdz=stdz;
  zpkdata.pv=pv;
  zpkdata.stdp=stdp;
  zpkdata.g=g;
  zpkdata.stdg=stdg;
  varargout={zpkdata};
  if exist('dps'), varargout{3}=dps; else varargout{2}=[]; end
  if rzpreq, varargout{2}=rzp; end
else
  varargout={zv,stdz,pv,stdp};
  if nargout>=5, varargout=[varargout,{g,stdg,rzp,dps}]; end
end
%%%%%%%%%%%%%%%%%%%%%%%% end of stdpz %%%%%%%%%%%%%%%%%%%%%%%%
