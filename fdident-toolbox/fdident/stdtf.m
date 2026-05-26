function [tf,stda,stdph,stdri,rtf]=stdtf(varargin)
%STDTF  Calculate standard deviations of amplitude and phase values of tf.
%
%       [tf,stda,stdph,stdri,rtf]=STDTF(pdat,freqv)
%
%       Output arguments:
%       tf = complex transfer function values at the given frequencies
%       stda  = standard deviations of amplitude values
%       stdph = standard deviations of phase values (in radians)
%       stdri = array of standard deviations of the transfer function
%           values; the three columns contain the std-s of the real
%           parts, std-s of the imaginary parts, and their correlation
%           coefficients, respectively
%       rtf = normalized covariance matrix (= correlation coefficients) of
%           the vector which contains real and imaginary parts of each
%           transfer function point, like: [Re(tf1);Im(tf1);Re(tf2);...]
%
%       Input arguments:
%       pdat = fidmodel object or file name with variable
%       freqv = frequency vector (optional)
%
%       Usage:
%           [tf,stda,stdph,stdri,rtf]=stdtf(pdat,freqv);
%       Example:
%           pvect=elis('inpchan(inpchan)',[],['s',11,12]);
%           [tf,stda,stdph,stdri,rtf]=stdtf(pvect);
%
%       See also: PLOTELTF, STDTFM.

%Old fdident help
%STDTF  Calculate standard deviations of amplitude and phase values of tf.
%
%       [tf,stda,stdph,stdri,rtf]=STDTF(freqv,pdat,cdat)
%
%       Output arguments:
%       tf = complex transfer function values at the given frequencies
%       stda  = standard deviations of amplitude values
%       stdph = standard deviations of phase values (in radians)
%       stdri = array of standard deviations of the transfer function
%           values; the three columns contain the std-s of the real
%           parts, std-s of the imaginary parts, and their correlation
%           coefficients, respectively
%       rtf = normalized covariance matrix (= correlation coefficients) of
%           the vector which contains real and imaginary parts of each
%           transfer function point, like: [Re(tf1);Im(tf1);Re(tf2);...]
%
%       Input arguments:
%       freqv = frequency vector
%       pdat = parameter vector (see EXPPAR) or the name of parameter file
%       cdat = covariance matrix of parameters or covariance vector
%           (see EXPCOV) or name of covariance file
%
%       Usage:
%           [tf,stda,stdph,stdri,rtf]=stdtf(freqv,pdat,cdat);
%       Example:
%           [pvect,fit,Cp]=elis('inpchan',[],['s',11,12]);
%           [tf,stda,stdph,stdri,rtf]=stdtf([400:400:19600],pvect,Cp);
%
%       See also: PLOTELTF, STDTFM.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
pdatn=getobjf(varargin{1},'fidmodel');
if isa(pdatn,'idmodel'), pdatn=fidmodel(pdatn); end
if isa(pdatn,'fidmodel')
  %new call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,2,ni)), %earlier
  end
  pdat=pdatn;
  freqv=[];
  if nargin>=2, freqv=varargin{2}; end
  if isempty(freqv), freqv=pdat.data.freqpoints; end
  cdat=pdat.covariance;
else
  %old call
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(3,3); %Matlab 2016a or later
  else ni=nargin; error(nargchk(3,3,ni)), %earlier
  end
  freqv=varargin{1};
  pdat=varargin{2};
  cdat=varargin{3};
end

%Expressions for the calculation of the total variance:
%vartf=stdri(:,1).^2+stdri(:,2).^2+2*stdri(:,3).*stdri(:,1).*stdri(:,2);
%vartf=stdri(:,1).^2+stdri(:,2).^2+2*prod(stdri')';
%
neglvali=realmin;
%
[freqv,ind]=sort(freqv(:));
fvl=length(freqv);
if ~isempty(pdat)
  [domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr]=imppar(pdat,[]);
  %if ~any(findstr(domain,'z')), fs=1; end
  %freqv=freqv/fs;
end
if any(domain=='pq')
  numord=length(num)-1;
  vnum=orthopol(numord,domain,freqv/fs,[],Znum);
  Nf=vnum*num';
  denomord=length(denom)-1;
  vdenom=orthopol(denomord,domain,freqv/fs,[],Zdenom);
  Df=vdenom*denom';
end
if strcmp(domain,'s')|strcmp(domain,'w')
  %set optimum scaling
  %fsc=(max(freqv)+min(freqv))*pi;
  %pv=exppar(domain,num,denom,delay);
  %[domain,num,denom,delay,fs]=imppar(pv,[]);
elseif domain=='p'
  %error('tf uncertainty calculation not yet implemented for orthopol')
end
%
coeffcovar=impcov(cdat);
zvind=find(diag(coeffcovar)==0); %fixed parameters
coeffcovar(:,zvind)=[];
coeffcovar(zvind,:)=[];
if ~isempty(ntr)
  ltr=length(ntr);
  lc=size(coeffcovar,1);
  coeffcovar=coeffcovar(1:lc-ltr,1:lc-ltr);
end
%
%calculate Jacobian
nn=length(num); nd=length(denom);
stda=zeros(fvl,1); stdph=zeros(fvl,1); tf=zeros(fvl,1);
if nargout>=4, stdri=zeros(fvl,3); end
trkl=[];
%
wi=0; %warnings issued
for k=1:fvl
  dN=1; dD=1;
  if strcmp(domain,'s')|strcmp(domain,'w')
    if strcmp(domain,'s')
      Om=sqrt(-1)*2*pi*freqv(k)/fs; fvs=[]; cfs=fs;
    elseif strcmp(domain,'w')
      Om=sqrt(sqrt(-1)*2*pi*freqv(k)/fs); fvs=[]; cfs=sqrt(fs);
    end
    vf=1; fvs=[1,fvs];
    for ip=1:nd-1, vf=vf*Om; dD=[vf,dD]; fvs=[cfs^ip,fvs]; end
    vf=1; fvs=[1,fvs];
    for ip=1:nn-1, vf=vf*Om; dN=[vf,dN]; fvs=[cfs^ip,fvs]; end
    fvs=[fvs,fs];
  elseif strcmp(domain,'z')
    Om=exp(-sqrt(-1)*2*pi*freqv(k)/fs);
    vf=1; for ip=1:nn-1, vf=vf*Om; dN=[dN,vf]; end
    vf=1; for ip=1:nd-1, vf=vf*Om; dD=[dD,vf]; end
    fvs=ones(1,nn+nd+1);
  elseif any(domain=='pq')
    dN=vnum(k,:);
    dD=vdenom(k,:);
    %Df=vdenom*denom';
    fvs=ones(1,nn+nd+1);
  end
  delterm=exp(-j*2*pi*freqv(k)/fs*delay);
  pev=ones(1,nn+nd+1); %vector to "expand" vectors to matrices
  N=dN*num'; D=dD*denom';
  if isnan(N)&(wi==0), warning('NaN element in N'), end
  dN=[dN,zeros(1,nd),zeros(1,1)];
  dD=[zeros(1,nn),dD,zeros(1,1)];
  ddelterm=[zeros(1,nn+nd),(-sqrt(-1)*2*pi*freqv(k)/fs).*delterm];
  %Jn=dtf/dp=ddelterm*N/D+delterm*(dN*D-dD*N)/(D^2)]
  Jn=(ddelterm*N/D)+delterm*(dN.*D(:,pev)-dD.*N(:,pev))./(D*D*pev);
  Jn(:,zvind)=[]; fvs(zvind)=[]; pev(zvind)=[]; %delete fixed parameters
  Jnsc=Jn.*fvs; %compensate for scaling
  tfk=delterm*N/D; tf(k)=tfk;
  if isnan(tfk)&(wi==0), warning('NaN element in tf'), wi=wi+1; end
  Re=real(tfk); Im=imag(tfk);
  trk=[real(Jnsc);imag(Jnsc)];
  Ck=trk*coeffcovar*trk'; %2x2 covariance matrix
  %
  if nargout>=4
    if Ck(1,1)<0
      %Ck(1,1)=abs(Ck(1,1));
      warning(sprintf('A variance value (of real part) is negative for k=%.0f',k))
    end
    if Ck(2,2)<0
      %Ck(2,2)=abs(Ck(2,2));
      warning(sprintf('A variance value (for imaginary part) is negative for k=%.0f',k))
    end
    stdri(k,1)=sqrt(Ck(1,1)); stdri(k,2)=sqrt(Ck(2,2));
    if Ck(1,2)~=0, stdri(k,3)=Ck(1,2)/abs(stdri(k,1)*stdri(k,2));
    else stdri(k,3)=0; %avoid possible division by zero
    end
    if abs(stdri(k,3))>1+100*fvl*eps
      fprintf('  For k=%.0f, Ck(1,1)=%.4g, Ck(2,2)=%.4g, Ck(1,2)=%.4g\n',...
        k,Ck(1,1),Ck(2,2),Ck(1,2))
      fprintf('     stdri(k,3)=%.4g\n',stdri(k,3))
      warning('A correlation coefficient in stdri is larger than 1')
      %stdri(k,3)=.99999*sign(stdri(k,3));
    end
  end
  if nargout>=5, trkl=[trkl;trk]; end
  %
  %dA/d[Re,Im]=1/sqrt(Re^2+Im^2)*[Re;Im]
  dAdRI=[Re;Im]/sqrt(Re^2+Im^2+neglvali);
  stda(k)=sqrt(dAdRI'*Ck*dAdRI);
  %
  %dph/d[Re,Im]=darctan(Im/Re)/d[Re,Im]=1/(1+(Im/Re)^2)*[-Im/Re^2;1/Re]
  if Re==0, Re=sqrt(neglvali)*10; end
  dphdRI=[-Im/Re^2;1/Re]/(1+(Im/Re)^2);
  stdph(k)=sqrt(dphdRI'*Ck*dphdRI);
end %for k
if nargout>=4
  ind=find(abs(stdri(:,3))>1);
  if ~isempty(ind), stdri(ind,3)=sign(stdri(ind,3)); end
end
%
if nargout>=5
  rtf=trkl*coeffcovar*trkl';
  stdv=sqrt(diag(rtf)); ind=find(stdv==0);
  if ~isempty(ind), stdv(ind)=ones(length(ind),1); end
  rtf=rtf./(stdv*stdv'); %Normalize to corr. coefficients
  ind=find(abs(rtf(:))>1+100*fvl*eps);
  if ~isempty(ind), error('A correlation coefficient in rtf is larger than 1')
  end
  ind=find(abs(rtf(:))>1);
  if ~isempty(ind), rtf(ind)=sign(rtf(ind)); end
end
%if isa(pdatn,'fidmodel')
%  varargout={tf,stda,stdph,stdri,rtf};
%else
%  varargout={tf,stda,stdph,stdri,rtf};
%end
%%%%%%%%%%%%%%%%%%%%%%%% end of stdtf %%%%%%%%%%%%%%%%%%%%%%%%
