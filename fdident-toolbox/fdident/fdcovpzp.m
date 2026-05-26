function [pvect,Cp]=fdcovpzp(zv,stdz,pv,stdp,rzp,g,stdg,domain,fs,da,dzp)
%FDCOVPZP Parameters and covariances of transfer function from poles/zeros.
%
%       pdat=FDCOVPZP(zpkdata,domain,fs,da,dzp)
%
%       The approximate "inverse" of STDPZ.
%
%       Output arguments:
%       pdat = model object
%
%       Input arguments:
%       zpkdata = structure with fields:
%         zv = column vector of zeros
%         stdz = array of standard deviations of the zeros; the three columns
%           contain the std-s of the real parts, std-s of the imaginary
%           parts, and their correlation coefficients, respectively.
%         pv = column vector of poles
%         stdp = array of standard deviations of the poles; the three columns
%           contain the std-s of the real parts, std-s of the imaginary
%           parts, and their correlation coefficients, respectively
%         rzp = correlation coefficient matrix (normalized covariance matrix)
%           of the vector which contains real and imaginary parts of each
%           zero and pole, and the leading coefficients of the numerator
%           and the denominator, like:
%           [z1r;z1i;z2r;...;p1r;p1i;p2r;...;n1,d1]
%           If rzp is empty or missing, the random variables will be assumed
%           to be independent, except for the complex conjugate pairs
%         g = gain, the leading coefficients in the Matlab
%           representation of the numerator and the denominator.
%           If g is a two-element vector, it contains the leading
%           coefficients of the numerator and the denominator, respectively
%         stdg = standard deviations of the gain; stdg has three elements:
%           the two std-s, and the correlation coefficient
%       domain = 's' or 'z'
%       fs = sampling frequency for z-domain parameter vector
%       da = derivation algorithm for sensitivity calculations:
%           'anal' or 'num'; at present, only 'anal' is implemented.
%       dzp = amount of perturbation of zeros and poles in the directions
%           of the eigenvectors of the covariance matrix (multiplier
%           of the eigenvalues)
%       Default values: zpkdata.g=[1;1]; zpkdata.stdg=[0;0;0];
%           domain='s'; fs=1; da='num'; dzp=1
%
%       Usage: [pvect,Cp]=fdcovpzp(zpkdata,domain,fs,da,dzp)
%       Example:
%           [zpkdata,rzp,dps]=stdpz('inpchmod(inpchans)');
%           pdat=fdcovpzp(zpkdata);
%           subplot(121)
%           plotelpz('inpchmod(inpchans)',NaN,10,[-6,2,-4,4]*1e5,'nomsg')
%           subplot(122),plotelpz(pdat,[],10,[-6,2,-4,4]*1e5,'nomsg')

%Old fdident help
%FDCOVPZP Parameters and covariances of transfer function from poles/zeros.
%
%       [pvect,Cp]=FDCOVPZP(zv,stdz,pv,stdp,rzp,g,stdg,domain,fs,da,dzp)
%
%       The approximate "inverse" of STDPZ.
%
%       Output arguments:
%       pvect = parameter vector (numerator, denominator, delay), see EXPPAR
%       Cp = covariance matrix of pvect
%
%       Input arguments:
%       zv = column vector of zeros
%       stdz = array of standard deviations of the zeros; the three columns
%           contain the std-s of the real parts, std-s of the imaginary
%           parts, and their correlation coefficients, respectively.
%       pv = column vector of poles
%       stdp = array of standard deviations of the poles; the three columns
%           contain the std-s of the real parts, std-s of the imaginary
%           parts, and their correlation coefficients, respectively
%       rzp = correlation coefficient matrix (normalized covariance matrix)
%           of the vector which contains real and imaginary parts of each
%           zero and pole, and the leading coefficients of the numerator
%           and the denominator, like:
%           [z1r;z1i;z2r;...;p1r;p1i;p2r;...;n1,d1]
%           If rzp is empty or missing, the random variables will be assumed
%           to be independent, except for the complex conjugate pairs
%       g = gain, the leading coefficients in the Matlab
%           representation of the numerator and the denominator.
%           If g is a two-element vector, it contains the leading
%           coefficients of the numerator and the denominator, respectively
%       stdg = standard deviations of the gain; stdg has three elements:
%           the two std-s, and the correlation coefficient
%       domain = 's' or 'z'
%       fs = sampling frequency for z-domain parameter vector
%       da = derivation algorithm for sensitivity calculations:
%           'anal' or 'num'; at present, only 'anal' is implemented.
%       dzp = amount of perturbation of zeros and poles in the directions
%           of the eigenvectors of the covariance matrix (multiplier
%           of the eigenvalues)
%       Default values: g=[1;1]; stdg=[0;0;0]; domain='s'; fs=1; da='num'; dzp=1
%
%       Usage: [pvect,Cp]=fdcovpzp(zv,stdz,pv,stdp,rzp,g,stdg,domain,fs,da,dzp)
%       Example:
%           [zpkdata,dps,rzp]=stdpz('inpchmod(inpchans)');
%           [pvectn,Cpn]=fdcovpzp(zpkdata.zv,zpkdata.stdz,zpkdata.pv,...
%                   zpkdata.stdp,rzp,zpkdata.g,zpkdata.stdg);
%           subplot(121)
%           plotelpz('inpchmod(inpchans)',NaN,10,[-6,2,-4,4]*1e5,'nomsg')
%           subplot(122),plotelpz(pvectn,Cpn,10,[-6,2,-4,4]*1e5,'nomsg')
%
%       See also: STDPZ.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000
%       The kernel of the analytical derivation algorithm was written by
%               Patrick Guillaume (VUB).

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,11); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,11,ni)), %earlier
end
if isa(zv,'struct') %new call
  calltype='new';
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,5); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,5,ni)), %earlier
  end
  if nargout>1, error('More than 1 output arguments'), end
  if nargin<2, domain=''; else domain=stdz; end; if isempty(domain), domain='s'; end
  if nargin<3, fs=[]; else fs=pv; end, if isempty(fs), fs=1; end
  if nargin<4, da=''; else da=stdp; end, if isempty(da), da='anal'; end
  if nargin<5, dzp=[]; else dzp=rzp; end, if isempty(dzp), dzp=1; end
  zpkdata=zv;
  zv=zpkdata.zv;
  stdz=zpkdata.stdz;
  pv=zpkdata.pv;
  stdp=zpkdata.stdp;
  if isfield(zpkdata,'rzp'), rzp=zpkdata.rzp; else rzp=[]; end
  if isfield(zpkdata,'g'), g=zpkdata.g;
  else g=[1;1];
  end
  if isfield(zpkdata,'stdg'), stdg=zpkdata.stdg;
  else stdg=[0;0;0];
  end
else
  calltype='old';
  if nargin<11, dzp=[]; end, if isempty(dzp), dzp=1; end
  if nargin<10, da=''; end, if isempty(da), da='anal'; end
  if nargin<9, fs=1; end
  if nargin<8, domain='s'; end
  if ~strcmp(domain,'s')&~strcmp(domain,'z'), error('Invalid domain'), end
  if nargin<7, stdg=[]; end
  if nargin<6, g=[]; end, if isempty(g), g=[1,1]; end
  if length(g)==1, g=[g;1]; else g=g(:); end
  if isempty(stdg), stdg=zeros(3,1); end
  if length(stdg)<=2, stdg(3)=0; end
  stdg=stdg(:);
  if nargin<5, rzp=[]; end
  if nargin<4, stdp=[]; end
  if nargin<3, pv=[]; end
  if nargin<2, error('Not enough input arguments'), end
end
%
if any(any(~isfinite([stdz;stdp]))), error('NaN or inf in stdz or stdp'), end
if any(any(imag([stdz;stdp;zeros(1,3)])~=0))
  error('Complex element in stdz or stdp')
end
if any(~isfinite(rzp(:))), error('NaN or inf in rzp'), end
if any(imag([rzp(:);0])~=0), error('Complex element in rzp'), end
zv=zv(:); pv=pv(:);
zpv=[zv;pv]; stdzp=[stdz;stdp];
if any(any(stdzp(:,1:2)<0)), error('Negative std in stdz or stdp'), end
if any(abs(stdzp(:,3))>1), error('r>1 in stdz or stdp'), end
Nz=length(zv); Np=length(pv);
if strcmp(domain,'s'), fsc=mean(abs(zpv));
elseif strcmp(domain,'z'), fsc=1;
else error('Invalid domain')
end
%fsc=1; fprintf('fsc = %.2g in fdcovpzp\n',fsc) %test value
%fprintf('fsc = %.2g in fdcovpzp\n',fsc)
%
rzpl=2*(Nz+Np)+2;
FDTOL=2*rzpl^2*500*eps;
if isempty(rzp)
  rf=0; %mark rzp as empty
  rzp=eye(rzpl);
  for i=1:2:rzpl-2
    rzp(i,i+1)=stdzp((i+1)/2,3);
    rzp(i+1,i)=stdzp((i+1)/2,3);
  end
else
  rf=1; %rzp given
end
%Test rzp or fill cross correlation coefficients if it was empty
%zeros
if Nz>0
  ind=pairs(zv,conj(zv));
  if any(abs(zv-conj(zv(ind)))>abs(zv)*10*eps)
    error('Zeros do not form complex conjugate pairs')
  end
end
rv=zv;
for i=1:length(rv)
  if ~isnan(rv(i)) %NaN marks roots already scanned
    if imag(rv(i))~=0 %complex root, correlated with pair
      varr=stdzp(i,1)*stdzp(i,2);
      if abs(varr*(stdzp(i,3)+stdzp(ind(i),3))) > varr*eps
        fprintf('Checking zeros zv(%.0f) and zv(%.0f) ... \n',i,ind(i))
        error('Different covariances of zero pair in stdz')
      end
      if (abs(stdzp(i,1)-stdzp(ind(i),1)) > 10*real(stdzp(i,1))*eps) | ...
         (abs(stdzp(i,2)-stdzp(ind(i),2)) > 10*imag(stdzp(i,2))*eps)
        fprintf('Checking zeros zv(%.0f) and zv(%.0f) ...\n',i,ind(i))
        error('Different variances of zero in stdz')
      end
      rri=rzp(2*i-1,2*i);
      if rf==0 %rzp to be filled out
        %real1 to real2, imag1 to imag2:
        rzp(2*i-1,2*ind(i)-1)=1; rzp(2*i,2*ind(i))=-1;
        rzp(2*ind(i)-1,2*i-1)=1; rzp(2*ind(i),2*i)=-1;
        %real1 to imag2, imag1 to real2:
        rzp(2*i-1,2*ind(i))=-rri; rzp(2*i,2*ind(i)-1)=rri;
        rzp(2*ind(i),2*i-1)=-rri; rzp(2*ind(i)-1,2*i)=rri;
      else
        %real1 to imag1, real2 to imag2:
        if (abs(stdzp(i,3)-rri)>FDTOL)|...
           (abs(rzp(2*i,2*i-1)-rri)>FDTOL)|...
           (abs(rzp(2*ind(i)-1,2*ind(i))+rri)>FDTOL)|...
           (abs(rzp(2*ind(i),2*ind(i)-1)+rri)>FDTOL)
          fprintf('Checking zeros zv(%.0f) and zv(%.0f) ... \n',i,ind(i))
          error('Invalid correlations between real-imag parts of zeros')
        end
        %real1 to real2, imag1 to imag2:
        if (abs(rzp(2*i-1,2*ind(i)-1)-1)>FDTOL)|...
           (abs(rzp(2*i,2*ind(i))+1)    >FDTOL)|...
           (abs(rzp(2*ind(i)-1,2*i-1)-1)>FDTOL)|...
           (abs(rzp(2*ind(i),2*i)+1)    >FDTOL)
             fprintf('Checking zeros zv(%.0f) and zv(%.0f) ... \n',i,ind(i))
          error('Invalid cross correlations between complex zeros')
        end
        %real1 to imag2, imag1 to real2:
        if (abs(rzp(2*i-1,2*ind(i))+rri)>FDTOL)|...
           (abs(rzp(2*i,2*ind(i)-1)-rri)>FDTOL)|...
           (abs(rzp(2*ind(i),2*i-1)+rri)>FDTOL)|...
           (abs(rzp(2*ind(i)-1,2*i)-rri)>FDTOL)
             fprintf('Checking zeros zv(%.0f) and zv(%.0f) ... \n',i,ind(i))
          error('Invalid real-imag cross correlations between complex zeros')
        end
      end
      rv(ind(i))=NaN;
    else %real root
      if stdzp(i,2)~=0
           fprintf('Checking zero zv(%.0f) ... \n',i)
        disp('WARNING! Random imaginary part of real zero')
      end
    end %Complex or real
  end %~isnan
end %for i
%
%poles
if Np>0
  ind=pairs(pv,conj(pv));
  if any(abs(pv-conj(pv(ind)))>abs(pv)*10*eps)
    error('Poles do not form complex conjugate pairs')
  end
end
rv=pv;
ind=ind+Nz; ind=[zeros(Nz,1);ind];
for i=Nz+[1:length(rv)]
  if ~isnan(rv(i-Nz)) %NaN marks roots already scanned
    if imag(rv(i-Nz))~=0 %complex root, correlated with pair
      varr=stdzp(i,1)*stdzp(i,2);
      if abs(varr*(stdzp(i,3)+stdzp(ind(i),3))) > varr*eps
        fprintf('Checking poles pv(%.0f) and pv(%.0f) ... \n',i,ind(i))
        error('Different covariances of pole pair in stdp')
      end
      if (abs(stdzp(i,1)-stdzp(ind(i),1)) > 10*real(stdzp(i,1))*eps) | ...
         (abs(stdzp(i,2)-stdzp(ind(i),2)) > 10*imag(stdzp(i,2))*eps)
        fprintf('Checking poles pv(%.0f) and pv(%.0f) ...\n',i,ind(i))
        error('Different variances of pole in stdp')
      end
      rri=rzp(2*i-1,2*i);
      if rf==0 %rzp to be filled out
        %real1 to real2, imag1 to imag2:
        rzp(2*i-1,2*ind(i)-1)=1; rzp(2*i,2*ind(i))=-1;
        rzp(2*ind(i)-1,2*i-1)=1; rzp(2*ind(i),2*i)=-1;
        %real1 to imag2, imag1 to real2:
        rzp(2*i-1,2*ind(i))=-rri; rzp(2*i,2*ind(i)-1)=rri;
        rzp(2*ind(i),2*i-1)=-rri; rzp(2*ind(i)-1,2*i)=rri;
      else
        %real1 to imag1, real2 to imag2:
        if (abs(stdzp(i,3)-rri)>FDTOL)|...
           (abs(rzp(2*i,2*i-1)-rri)>FDTOL)|...
           (abs(rzp(2*ind(i)-1,2*ind(i))+rri)>FDTOL)|...
           (abs(rzp(2*ind(i),2*ind(i)-1)+rri)>FDTOL)
          fprintf('Checking poles pv(%.0f) and pv(%.0f) ...\n',i,ind(i))
          error('Invalid correlations between real-imag parts of poles')
        end
        %real1 to real2, imag1 to imag2:
        if (abs(rzp(2*i-1,2*ind(i)-1)-1)>FDTOL)|...
           (abs(rzp(2*i,2*ind(i))+1)    >FDTOL)|...
           (abs(rzp(2*ind(i)-1,2*i-1)-1)>FDTOL)|...
           (abs(rzp(2*ind(i),2*i)+1)    >FDTOL)
          fprintf('Checking poles pv(%.0f) and pv(%.0f) ...\n',i,ind(i))
          error('Invalid cross correlations between complex poles')
        end
        %real1 to imag2, imag1 to real2:
        if (abs(rzp(2*i-1,2*ind(i))+rri)>FDTOL)|...
           (abs(rzp(2*i,2*ind(i)-1)-rri)>FDTOL)|...
           (abs(rzp(2*ind(i),2*i-1)+rri)>FDTOL)|...
           (abs(rzp(2*ind(i)-1,2*i)-rri)>FDTOL)
          fprintf('Checking poles pv(%.0f) and pv(%.0f) ...\n',i,ind(i))
          error('Invalid real-imag cross correlations between complex poles')
        end
      end
      rv(ind(i)-Nz)=NaN;
    else %real root
      if stdzp(i,2)~=0
           fprintf('Checking pole pv(%.0f) ... \n',i)
        disp('WARNING! Random imaginary part of real pole')
      end
    end %Complex or real
  end %~isnan
end %for i
%
if rf==0 %rzp to be filled out
  %gain values
  %rzp(rzpl-1,rzpl-1)=sign(stdg(1));
  %rzp(rzpl,rzpl)=sign(stdg(2));
  if stdg(1)*stdg(2)~=0
    rzp(rzpl,rzpl-1)=stdg(3);
    rzp(rzpl-1,rzpl)=stdg(3);
  end
else
  if any(abs([rzp(rzpl,rzpl-1),rzp(rzpl-1,rzpl)])>1)
    error('Invalid gain correlation coefficients in rzp')
  end
end
%
[rzph,rzpw]=size(rzp);
if (rzph~=rzpl)|(rzpw~=rzpl)
  error([sprintf('rzp is %.0fx%.0f, and not ',rzph,rzpw),...
                sprintf('%.0fx%.0f',rzpl,rzpl)])
end
%
%Scaling for good conditioning by fsc
pv=pv/fsc; zv=zv/fsc; zpv=zpv/fsc;
g(1)=g(1)*fsc^Nz; g(2)=g(2)*fsc^Np;
stdg(1)=stdg(1)*fsc^Nz; stdg(2)=stdg(2)*fsc^Np;
%
%rzp = covariance matrix of all scaled variables
sdtvsc=[stdzp(:,1)';stdzp(:,2)']/fsc; sdtvsc=[sdtvsc(:);stdg(1);stdg(2)];
rzp=(sdtvsc*sdtvsc').*rzp;
%
%SENSITIVITY CALCULATIONS
%For the analytical calculations first the sensitivities dr/dp
%will be calculated, then the pseudoinverse will be taken.
%
%ZEROS
%
num=real(poly(zv));
if strcmp(da,'anal')&(Nz>0)
  %The algorithm determines the sensitivity matrix of roots to coefficients
  %The basic idea is:  dr(i,j) = df/dp / df/dro = ro(i)^j / f'(ro(i))
  %where ro(i) is a root, and f is the polynomial.
  %The sensitivity is first calculated for the leading coefficient set to 1
  s=zv;
  co=num;
  stot=length(zv);
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
  coderiv=co(1:nco-1).*[nco-1:-1:1];
  deriv=polyval(coderiv,s); %f'(si)
  k=[nco-1:-1:0];
  ir=1; drdv=zeros(stot,nco);
  for i=1:ns
    if imag(s(i))~=0 %complex root
      if deriv(i)==0 %multiple root
        ro=[ro;s(i);conj(s(i))];
        NaNv=NaN; %bypass Vax problem with NaN*
        drdv([ir,ir+1],:)=NaNv(ones(2,1),ones(1,nco));
      else %multiplicity one
        %calculation of the complex row vector A(k) = si^k/f'(si)
        Ac=(s(i).^k)/deriv(i);
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
        %calculation of the row vector A(k) = si^k/f'(si)
        A=real((s(i).^k)/deriv(i));
        ro=[ro;s(i)];
        drdv(ir,:)=A;
      end
      ir=ir+1;
    end %if statement: complex or real
  end %for i=1 to number of roots
  %The last problem is that the order of roots has been changed.
  [iperm,cycle]=pairs(zv,ro,1);
  dzdn=drdv(iperm,:)/g(1); %Sensitivity of scaled zeros
  dzdnri=zeros(2*Nz,Nz+1);
  dzdnri(1:2:2*Nz,:)=real(dzdn); dzdnri(2:2:2*Nz,:)=imag(dzdn);
elseif strcmp(da,'num')&(Nz>0) %numerical approximation follows
  Cz=rzp(1:2*Nz,1:2*Nz);
  [Vz,Dz]=eig(Cz); [mDzabs,indz]=sort(-abs(diag(Dz)));
  maxD=-mDzabs(1);
  minDr=sqrt(10*eps*maxD);
  Vz=Vz(:,indz); Dz=diag(Dz(indz,indz));
  %Eigenvalues ordered by descending absolute values
  %Index of last significant eigenvalue:
  lvz=min([find( sqrt(abs(Dz))<minDr );length(Dz)+1])-1;
  diagCz=diag(Cz);
  lvzn=sum((diagCz(1:2:2*Nz)+diagCz(2:2:2*Nz))~=0);
  if lvz<lvzn
    disp('WARNING! Low rank of the covariance matrix of zeros in fdcovpzp')
    fprintf('Uncertain zeros: %.0f, usable eigenvalues: %.0f\n',lvzn,lvz)
  end
  %
  dndv=zeros(lvz,Nz+1);
  for kp=1:lvz %a cycle in each important direction
    stepl=dzp*max(sqrt(abs(Dz(kp))),minDr);
    dzk=stepl*Vz(:,kp);
    zvk=zv+dzk(1:2:2*Nz)+j*dzk(2:2:2*Nz);
    numk=real(poly(zvk));
    dndv(kp,:)=(numk-num)/stepl;
  end %for kp
  dndzri=g(1)*(dndv'*Vz(:,1:lvz)')'; %sensitivity matrix to zeros
else
  dzdnri = zeros(0,length(num));
  dndzri = zeros(0,length(Nz+1));
end %strcmp(da,...
%
%POLES
%
denom=real(poly(pv));
if strcmp(da,'anal')&(Np>0)
  %The algorithm determines the sensitivity matrix of roots to coefficients
  %The basic idea is:  dr(i,j) = df/dp / df/dro = ro(i)^j / f'(ro(i))
  %where ro(i) is a root, and f is the polynomial.
  %The sensitivity is first calculated for the leading coefficient set to 1
  s=pv;
  co=denom;
  stot=length(pv);
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
  coderiv=co(1:nco-1).*[nco-1:-1:1];
  deriv=polyval(coderiv,s); %f'(si)
  k=[nco-1:-1:0];
  ir=1; drdv=zeros(stot,nco);
  for i=1:ns
    if imag(s(i))~=0 %complex root
      if deriv(i)==0 %multiple root
        ro=[ro;s(i);conj(s(i))];
        NaNv=NaN; %bypass Vax problem with NaN*
        drdv([ir,ir+1],:)=NaNv(ones(2,1),ones(1,nco));
      else %multiplicity one
        %calculation of the complex row vector A(k) = si^k/f'(si)
        Ac=(s(i).^k)/deriv(i);
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
        %calculation of the row vector A(k) = si^k/f'(si)
        A=real((s(i).^k)/deriv(i));
        ro=[ro;s(i)];
        drdv(ir,:)=A;
      end
      ir=ir+1;
    end %if statement: complex or real
  end %for i=1 to number of roots
  %The last problem is that the order of roots has been changed.
  [iperm,cycle]=pairs(pv,ro,1);
  dpdd=drdv(iperm,:)/g(2); %Sensitivity of scaled poles
  dpddri=zeros(2*Np,Np+1);
  dpddri(1:2:2*Np,:)=real(dpdd); dpddri(2:2:2*Np,:)=imag(dpdd);
elseif strcmp(da,'num')&(Np>0) %numerical approximation follows
  Cp=rzp(2*Nz+[1:2*Np],2*Nz+[1:2*Np]);
  [Vp,Dpv]=eig(Cp); [mDpvabs,indp]=sort(-abs(diag(Dpv)));
  maxD=-mDpvabs(1);
  minDr=sqrt(10*eps*maxD);
  Vp=Vp(:,indp); Dpv=diag(Dpv(indp,indp));
  %Eigenvalues ordered by descending absolute values
  %Index of last significant eigenvalue:
  lvp=min([find( sqrt(abs(Dpv))<minDr );length(Dpv)+1])-1;
  diagCp=diag(Cp);
  lvpn=sum((diagCp(1:2:2*Np)+diagCp(2:2:2*Np))~=0);
  if lvp<lvpn
    disp('WARNING! Low rank of the covariance matrix of poles in fdcovpzp')
    fprintf('Uncertain poles: %.0f, usable eigenvalues: %.0f\n',lvpn,lvp)
  end
  %
  dddv=zeros(lvp,Np+1);
  for kp=1:lvp %a cycle in each important direction
    stepl=dzp*max(sqrt(abs(Dpv(kp))),minDr);
    dpk=stepl*Vp(:,kp);
    pvk=pv+dpk(1:2:2*Np)+j*dpk(2:2:2*Np);
    denomk=real(poly(pvk));
    dddv(kp,:)=(denomk-denom)/stepl;
  end %for kp
  dddpri=g(2)*(dddv'*Vp(:,1:lvp)')'; %sensitivity matrix to poles
else
  dpddri = zeros(0,length(denom));
  dddpri = zeros(0,Np+1);
end %strcmp(da,...
%
%construct full sensitivity matrix
if strcmp(da,'anal')
  drdp=[dzdnri,[zeros(2*Nz,length(denom))];
      [zeros(2*Np,length(num))],dpddri]; %The delay is not treated yet
  %gain: [g(1);g(2)]=[num(1)*fsc^numord;denom(1)*fsc^denomord]
  drdpext=zeros(2,Nz+Np+2);
  drdpext(1,1)=1; drdpext(2,Nz+2)=1;
  drdp=[drdp;drdpext];
  [U,S,V]=svd(drdp,0);
  diagS=diag(S);
  infvar=inf; %bypass Vax problem with inf*
  i=find(diagS<10*eps*max(diagS)); diagS(i)=infvar(ones(length(i),1),1);
  dpdr=V*diag(1.0./diagS)*U';
else %num
  dpdr=[dndzri,[zeros(2*Nz,Np+1)];
        [zeros(2*Np,Nz+1)],dddpri;
        num,[zeros(1,Np+1)];
        [zeros(1,Nz+1)],denom]';
  %gain: [g(1);g(2)]=[num(1)*fsc^numord;denom(1)*fsc^denomord]
end
%
Cp=dpdr*rzp*dpdr';
%Treat fixed gains
if rzp(rzpl-1,rzpl-1)==0
  Cp(:,1)=zeros(Nz+Np+2,1); Cp(1,:)=zeros(1,Nz+Np+2);
end
if rzp(rzpl,rzpl)==0
  Cp(:,Nz+2)=zeros(Nz+Np+2,1); Cp(Nz+2,:)=zeros(1,Nz+Np+2);
end
%
i=find(diag(Cp)<-sqrt(eps)*max(diag(Cp)));
if ~isempty(i)
  disp('WARNING! Negative variance in Cp')
end
i=find( (diag(Cp)>=-sqrt(eps)*max(diag(Cp))) & (diag(Cp)<=0) );
Cp(i,:)=zeros(length(i),length(Cp));
Cp(:,i)=zeros(length(Cp),length(i));
%
Cp=[Cp,zeros(length(Cp),1);zeros(1,length(Cp)+1)]; %extend by delay
%
%Scaled export
scv=[fsc.^[Nz:-1:0,Np:-1:0]';fsc];
Cp=Cp./(scv*scv');
if strcmp(domain,'z'), fsc=fs; end
if strcmp(calltype,'new')
  pvect=fidmodel(domain,g(1)*num,g(2)*denom,0,fsc);
  pvect.covariance=Cp;
elseif strcmp(calltype,'old')
  pvect=exppar(domain,g(1)*num,g(2)*denom,0,fsc);
end
%%%%%%%%%%%%%%%%%%%%%%%% end of fdcovpzp %%%%%%%%%%%%%%%%%%%%%%%%
