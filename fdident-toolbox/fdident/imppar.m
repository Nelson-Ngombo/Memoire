function [domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr,tauR]=...
  imppar(pdat,fsc)
%IMPPAR Read system parameters from a parameter vector or file (used by ELIS).
%
%       [domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr,tauR]=IMPPAR(pdat,fsc)
%
%       Output arguments:
%       domain = 's' or 'z', depending on the domain;
%       num = numerator vector,
%           coefficients of 1/z in ascending order
%           or coefficients of s in descending order
%           for domain=='p', Znum contains the weights to calculate
%               the numerator polynomial, but this is should be avoided
%               because it is usually very badly conditioned
%       denom = denominator vector,
%           coefficients of 1/z in ascending order
%           or coefficients of s in descending order
%           for domain=='p', Zdenom contains the weights to calculate
%               the numerator polynomial, but this is should be avoided
%               because it is usually very badly conditioned
%       delay = additional delay
%       fs = sampling frequency in the z-domain.
%           In p-domain, this is the scaling frequency for the orthogonal
%               representation.
%           In s- and w-domain fs is the scaling frequency between
%               the internal representation, and the parameter file, given in Hz.
%       Further arguments for orthogonal polynomial representation -
%          for regular polynomial coefficients, they are empty:
%       Znum = orthogonal polynomial weights for numerator (see orthopol)
%       Zdenom = orthogonal polynomial weights for denominator (see orthopol)
%       comments = optional, comment string in the input file
%       fdate = optional, comment string in the input file (if any)
%       ntr = transient numerator vector
%       Zntr = orthogonal polynomial weights for transient numerator
%       tauR = tau parameter for r-domain
%
%       Input arguments:
%       pdat = data vector or the name of the file; the data vector contains
%           the data in the same order as a .pnt file.
%       fsc = scaling frequency between the s-domain internal representation,
%           and the parameter file. fsc is optional.
%           If it is not given, for p-domain the scaling will be equal to the
%           one given in the file, otherwise no scaling will be done (fsc=1);
%           if it is empty (fsc=[]), the value in the file is used.
%           In the case of z-domain files, fsc is neglected.
%
%       The file may be an ASCII file with comments (usual extension: .par),
%       an ASCII file without comments (.pnt) or a binary file (.pbn).
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given. Default extension: .pbn.
%       If a file is read, the most important values will be displayed on the
%       screen, unless a global variable 'expimpmessages' with value 'no' is
%       defined.
%
%       Usage:
%       [domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr,tauR]=...
%                       imppar(pdat,fsc);
%       Example: [domain,num,denom,delay,fsc]=imppar('inpchan(inpchans)',[]);
%
%       See also: EXPPAR.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Oct-2001

%Avoid warnings in Matlab5
if nargout>=1, domain=''; end
if nargout>=2, num=[]; end
if nargout>=3, denom=[]; end
if nargout>=4, delay=[]; end
if nargout>=5, fs=[]; end
Znum=[]; Zdenom=[]; comments=''; fdate='';
ntr=[]; Zntr=[]; tauR=[];
%
pdat=getobjf(pdat,'fidmodel'); %Take object from file if necessary
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
if isa(pdat,'fidmodel')
  domain=pdat.variable; if strcmp(domain,'z^-1'), domain='z'; end
  if strcmp(pdat.representation,'orthopol')
    if strcmp(pdat.variable,'s')
      domain='p';
    elseif any(findstr(pdat.variable,'z'))
      domain='q';
    end
  end
  num=pdat.num;
  denom=pdat.denom;
  if any(domain=='zq'), fs=pdat.fs;
  else fs=pdat.fscale;
  end
  if isempty(fs), fs=1; end
  delay=pdat.delay; if isempty(delay), delay=0; end
  if any(domain=='pq'), delay=delay*fs; end %scaled delay in imppar
  Znum=pdat.Znum;
  Zdenom=pdat.Zdenom;
  ntr=pdat.ntr;
  Zntr=pdat.Zntr;
  if domain=='r', tauR=pdat.tauR; end
  cmts=pdat.notes;
  if isa(pdat,'fidmodel')
    fdate=pdat.date;
  end
  if nargin<2
    if domain=='s', fs=1; end
    return
  elseif isequal(fsc,1)
    if (domain=='p')&(fs~=1)
      error('Cannot rescale orthogonal representation')
    end
    %For z-domain, neglect fsc
    return
  elseif domain=='s'
    if ~isempty(fsc), fs=fsc; end
    %rescale according to fsc or fs
    for ii=1:2
      if ii==1, pol=num; elseif ii==2, pol=denom; else pol=ntr; end
      if isnumeric(pol), pol={pol}; end
      for ip=1:length(pol)
        pol{ip}=pol{ip}.*(fs.^[length(pol{ip})-1:-1:0]);
      end %for ip
      if length(pol)==1, pol=pol{1}; end
      if ii==1, num=pol; elseif ii==2, denom=pol; else ntr=pol; end
    end
    delay=delay*fs;
    return
  end
  %prepare for regular imppar:
  if any(domain=='pq'), fsp=fs; %scaling for the basis
  elseif domain=='z', fsp=fs; %sampling frequency
  else fsp=1; %s and w: no scaling for storage
  end
  if iscell(num), numels=cat(2,num{:}); else numels=num; end
  if any(imag([numels(:);denom(:)])~=0)
    ptyp='complex';
  else
    ptyp='';
  end
  pdat=exppar(domain,num,denom,delay,fsp,Znum,Zdenom,'',cmts,fdate,ntr,Zntr,ptyp,1);
elseif isa(pdat,'iddat')
  error(['Class of pdat is ',class(pdat)])
end
%
global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
comments=setstr([]); fdate=setstr([]);
if isstr(pdat)
  [filename,dummy,ext]=fnamanal(pdat,'mat'); lcext=lower(ext);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'pbn') %binary file
    fty='binary'; ntx=[];
  else %ASCII file
    fty='ASCII';
    if strcmp(lcext,'pnt')
      ASCIItype='flat';
    else %ASCII with text
      ASCIItype='text';
    end
  end
  fty=[fty,' file ''',filename,''''];
else %vector in workspace
  pdat=pdat(:);
  fty='vector in workspace';
  lcext='';
end %isstr(pdat)
if ~strcmp(eim,'no')&isstr(pdat)
  disp(['imppar loading data from ',fty])
end
if isstr(pdat)
  if ~(strcmp(lcext,'par')|strcmp(lcext,'pnt')|strcmp(lcext,'pbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''par'' or ''pnt'' or ''pbn'''])
    lcext='par'; %ASCII file with nonstandard extension
  end
end
%
if isnumeric(pdat)|(isstr(pdat)&~strcmp(lcext,'pbn')) %vector or ASCII file
  if isstr(pdat)
    pdat=loadasc(filename,ASCIItype);
    if length(pdat)<4, error(['Not enough data in file ',filename]), end
  end
  if length(pdat)<4, error('Not enough data in vector'), end
  if pdat(1)==0, domain='s';
  elseif pdat(1)==1, domain='z';
  elseif pdat(1)==2, domain='w';
  elseif pdat(1)==3, domain='p';
  elseif pdat(1)==4, domain='r';
  elseif pdat(1)==5, domain='q';
  else error(['Domain incorrectly given in file ',filename])
  end
  fs=pdat(2); if domain=='r', tauR=pdat(2); end
  if nargin<2, if ~any(domain=='pq'), fsc=1.0; else fsc=[]; end, end
  if isempty(fsc), fsc=fs; end
  if any(domain=='pq')&(fs~=fsc)
    error(sprintf('Prescribed scaling frequency is %.3g, in data %.3g',fsc,fs))
  end
  numord=pdat(3); denomord=pdat(4);
  plstd=4+2*(numord+1+denomord+1)+1;
  if ~isempty(lcext), fnstr=['file ',filename]; else fnstr='vector'; end
  if length(pdat)<plstd
    error(['Insufficient number of data in ',fnstr,...
        sprintf(', orders: %.0f/%.0f',numord,denomord),...
        sprintf(', lengths: %.0f < %.0f',length(pdat),plstd)])
  end
  lenp=plstd+numord+1+denomord+1;
  if (domain=='p')&(length(pdat)<lenp)
    error(['Insufficient number of data in p-domain ',fnstr,...
            sprintf(', orders: %.0f/%.0f',numord,denomord),...
            sprintf(', lengths: %.0f < %.0f',length(pdat),lenp)])
  end
  if any(pdat(5+[0:2:2*numord]')-[0:numord]')
    error('Numerator indices improperly given')
  end
  if any(pdat(5+[0:2:2*denomord]'+2*numord+2)-[0:denomord]')
    error('Denominator indices improperly given')
  end
  num=pdat([6:2:6+2*numord]).';
  denom=pdat([6:2:6+2*denomord]+2*numord+2).';
  delay=pdat(4+2*(numord+1+denomord+1)+1);
  pdat(1:4+2*(numord+1+denomord+1)+1)=[];
  if any(domain=='p')
    clen=length(num);
    Znum=pdat(1:clen);
    pdat(1:clen)=[];
    clen=length(denom);
    Zdenom=pdat(1:clen);
    pdat(1:clen)=[];
  elseif any(domain=='q')
    clen=length(num);
    Znum=reshape(pdat(1:clen^2),clen,clen);
    pdat(1:clen^2)=[];
    clen=length(denom);
    Zdenom=reshape(pdat(1:clen^2),clen,clen);
    pdat(1:clen^2)=[];
  end
  if ~isempty(pdat)
    if rem(pdat(1),1)==0 %transient response
      if length(pdat)<2*pdat(1)+3
        error('pdat contains too few data')
      end
      ntrord=pdat(1); pdat(1)=[];
      ntr=pdat(2:2:2*(ntrord+1))';
      pdat(1:2*(ntrord+1))=[];
      if any(domain=='p')
        clen=length(ntr);
        Zntr=pdat(1:clen);
        pdat(1:clen)=[];
        if ~isempty(pdat)
          error('pdat contains too many data')
        end
      elseif any(domain=='q')
        clen=length(ntr);
        Zntr=reshape(pdat(1:clen^2),clen,clen);
        pdat(1:clen^2)=[];
        if ~isempty(pdat)
          error('pdat contains too many data')
        end
      end %'p'
    end %transient
  end %isempty(pdat)
  if strcmp(domain,'s')|strcmp(domain,'w')
    num=num(length(num):-1:1);
    denom=denom(length(denom):-1:1);
    if ~isempty(ntr), ntr=ntr(length(ntr):-1:1); end
  end
else %binary file
  load(filename,'-mat');
  num=num(:).'; denom=denom(:).'; %make sure to have row vectors
  if nargin<2, if domain~='p', fsc=1.0; else fsc=[]; end, end
  if isempty(fsc), fsc=fs; end
  if (domain=='p')&(fsc~=fs)
    error(sprintf('Prescribed scaling frequency is %.3g, in file %.3g',fsc,fs))
  end
end
%in the s-domain and the w-domain, fs is the scaling frequency in the file
if any(domain=='swr')
  if isempty(fsc), fsc=fs; else fs=fsc; end
  if ~isfinite(fsc)|(fsc<=0)
    error(sprintf('The value of fsc = %.3g is illegal',fsc))
  end
  if fs~=1, fsct=sprintf(', fsc=%-6.4e Hz',fs); else fsct=''; end
  if ~strcmp(eim,'no')&~isempty(lcext)
    fprintf(['   Orders: %.0f/%.0f, delay: %-6.4e s, ',domain,'-domain',fsct,...
        '\n'],length(num)-1,length(denom)-1,delay)
    if ~isempty(ntr), disp('Transients incorporated'), end
  end
  if strcmp(domain,'s')
    num=num.*(fs.^[length(num)-1:-1:0]);
    denom=denom.*(fs.^[length(denom)-1:-1:0]);
    if ~isempty(ntr), ntr=ntr.*(fs.^[length(ntr)-1:-1:0]); end
  elseif strcmp(domain,'w')
    num=num.*(sqrt(fs).^[length(num)-1:-1:0]);
    denom=denom.*(sqrt(fs).^[length(denom)-1:-1:0]);
    if ~isempty(ntr), ntr=ntr.*(sqrt(fs).^[length(ntr)-1:-1:0]); end
  end
  delay=delay*fs;
else %z-domain
  if ~strcmp(eim,'no')&~isempty(lcext)
    fprintf(['   Orders: %.0f/%.0f, delay: %-.3f samples, z-domain'],...
       length(num)-1,length(denom)-1,delay)
    fprintf(', fs=%.3e Hz\n',fs)
    if ~isempty(ntr), disp('Transients incorporated'), end
  end
end
if ~strcmp(eim,'no')&~isempty(lcext)&(length(comments)>0)
  disp(['   Comments: ',comments])
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of imppar %%%%%%%%%%%%%%%%%%%%%%%%%
