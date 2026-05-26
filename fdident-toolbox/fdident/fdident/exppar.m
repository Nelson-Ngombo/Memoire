function pvect=exppar(domain,num,denom,delay,fs,Znum,Zdenom,fname,cmts,fdate,ntr,Zntr,ptyp,tauR)
%EXPPAR Write parameters to a parameter vector or file (for use by ELIS).
%
%       pvect=EXPPAR(domain,num,denom,delay,fs,Znum,Zdenom,fname,cmts,fdate,ntr,Zntr,ptyp,tauR)
%
%       Output argument:
%       pvect = vector, containing the same data as the .pnt file
%
%       Input arguments:
%       domain = 's' or 'z', depending on the domain;
%       num = numerator vector, coefficients of 1/z in ascending order,
%           or coefficients of s in descending order
%           for domain=='p', Znum contains the weights to calculate
%               the numerator polynomial, but this is should be avoided
%               because it is usually very badly conditioned
%       denom = denominator vector, coefficients of 1/z in ascending order,
%           or coefficients of s in descending order
%           for domain=='p', Zdenom contains the weights to calculate
%               the numerator polynomial, but this is should be avoided
%               because it is usually very badly conditioned
%       delay = additional delay
%       fs = sampling frequency in the z-domain
%           In the s-domain fs is the scaling frequency between the internal
%           representation, and the parameter file, given in Hz.
%           In p-domain, this is the scaling frequency for the orthogonal
%               representation (the basis is stored as scaled).
%       Two arguments for orthogonal polynomial representation,
%         for regular polynomial coefficients, they are empty:
%       Znum = orthogonal polynomial weights for numerator (see orthopol)
%       Zdenom = orthogonal polynomial weights for denominator (see orthopol)
%       fname = the name of the file (string)
%           If the name has no extension, this function extends it by '.pbn'.
%           If the extension is .pbn, the result will be a binary file,
%           else an ASCII text file. If the extension is '.pnt', no comment
%           is sent to the ASCII file, only data.
%           If fname is empty, no file will be generated.
%       cmts = string with eventual comments (optional)
%       fdate = date (and time) string (optional). If fdate is missing or
%           empty, an actual date string will be generated.
%       ntr = numerator belonging to the transient response
%       Zntr = orthogonal polynomial weights for the transient numerator
%       ptyp = type of parameters: empty or 'real', or 'complex'
%       tauR = In r-domain, this is the tauR parameter.
%
%       If a file is generated, the most important values will be displayed on
%       the screen, unless a global variable 'expimpmessages' with value 'no'
%       is defined.
%       The file will be created in the active subdirectory or folder.
%
%       Special call:
%          pvect=exppar(idmod,fname); %convert fidmodel object to ASCII file or pvect
%
%       Usage: pvect=exppar(domain,num,denom,delay,fs,Zn,Zd,fname,cmts,fdate,ntr,Zntr,ptyp,tauR);
%       Examples:
%          pvect=exppar('s',[1,1],[1,2,3,4]);
%          exppar('z',[1,1],[4,3,2,1],0,1,[],[],'filter.pnt','Trial',date);
%
%       See also: IMPPAR.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-2001

ftype='parameter V1.0';
true=1;
false=0;
separateline=true; %if no text, each number in a separate line
global expimpmessages
maxvali=realmax; minvali=realmin;
if strncmp(version,'5.',2), isieeei=isieee; else isieeei=1; end
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
%
if nargin<13, ptyp=''; end
if isa(domain,'idmodel'), domain=fidmodel(domain); end
if isa(domain,'fidmodel')
  %conversion only from fidmodel object
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,2,ni)), %earlier
  end
  mod=domain;
  domain=mod.variable; if strcmp(domain,'z^-1'), domain='z'; end
  if nargin>1, fname=num; else fname=''; end
  num=mod.num; denom=mod.denom;
  ptyp=mod.coefficients;
  delay=mod.delay;
  if length(delay)~=1, error('delay is not scalar'), end
  if domain=='r', tauR=mod.tauR;
  else fs=mod.fs;
  end
  if isempty(fs), fs=1; end
  cmts=mod.notes; fdate=mod.date; ntr=mod.ntr;
  if strcmp(mod.representation,'orthopol')
    if strcmp(domain,'s'), domain='p'; end
    Zn=mod.Znum;
    Zd=mod.Zdenom;
    Zntr=mod.Zntr;
  end
elseif isa(domain,'iddat')
  error(['Class of domain is invalid: ',class(domain)])
else
  if ~any(domain=='zqswpr')
    error(['domain is illegal: ',domain])
  end
  if domain=='r'
    if nargin<14, error('For r-domain, tauR is not given'), end
    if length(tauR)~=1, error('tauR is not a scalar'), end
  end
  if nargin<12, Zntr=[]; end
  if nargin<11, ntr=[]; end
  if nargin<10, fdate=''; end
  if nargin<9, cmts=''; end
  if nargin<8, fname=''; end
  if nargin<7, Znum=[]; end
  if nargin<6, Zdenom=[]; end
  if nargin<5, fs=[]; end
  if isempty(fs)
    if any(domain=='zq'), error('fs is not given'), end
    fs=1;
  end
  if isstr(fs), error('fs is a string'), end
  if length(fs)~=1, error('fs is not a scalar'), end
  if nargin<4, delay=[]; end, if isempty(delay), delay=0; end
  if any(domain=='pq')
    if isempty(Znum)&~isempty(num), error(['Znum is empty for domain==''',domain,'''']), end
    if isempty(Zdenom)&~isempty(denom), error(['Zdenom is empty for domain==''',domain,'''']), end
    if length(Znum)~=length(num)
      error('Znum and num are incompatible')
    end
    if length(Zdenom)~=length(denom)
      error('Zdenom and denom are incompatible')
    end
    if ~isempty(ntr)
      if isempty(Zntr), error(['Zntr is empty for domain==''',domain,'''']), end
      if length(Zntr)~=length(ntr)
        error('Zntr and ntr are incompatible')
      end
    end
  end
end
if isempty(delay), delay=0; end
%
cmts=setstr(cmts); fdate=setstr(fdate);
if isempty(fdate), %generate actual date
  dat=clock;
  fdate=[date,sprintf(', %.0f:%.0f:%.0f',dat(4),dat(5),dat(6))];
end
inpno=1; outpno=1; %SISO
if ~isempty(fname)
  if ~isstr(fname), error('fname is not a string'), end
  [fname,dummy,ext]=fnamanal(fname,'pbn'); lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'pnt') %No comment will be sent
    notext=true;
    ntx='flat '; %ASCII file type
  else
    notext=false;
    ntx='';
  end
  if ~isempty(fname)&(exist(fname)~=0)
    delete(fname)
    if exist(fname)~=0, error(['Cannot delete existing file ''',...
         fname,'''']), end
  end
else %fname is empty
  lcext='';
end
%
if iscell(num)&(length(num)==1), num=num{1}; end
if iscell(denom)&(length(denom)==1), denom=denom{1}; end
nsize=size(num);
dsize=size(denom);
if (min(nsize)>1)|(min(dsize)>1)
  error('''num'' and ''denom'' must be vectors')
end
if ~strcmp(ptyp,'complex')&any([any(imag(num)),any(imag(denom))]'),
  error('There are complex coefficient(s) in the parameter vectors')
end
if ~all([all(isfinite(num)),all(isfinite(denom))]'),
  disp('There are infinite or NaN coefficient(s) in the parameter vectors')
end
%
if strcmp(lcext,'pbn') %binary file
  fty='binary'; ntx='';
else
  fty='ASCII';
end
if ~strcmp(eim,'no')&~isempty(fname)
  disp(['exppar sending data to ',ntx,fty,' file ''',fname,''''])
end
if ~isempty(fname)
  if ~(strcmp(lcext,'par')|strcmp(lcext,'pnt')|strcmp(lcext,'pbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''par'' or ''pnt'' or ''pbn'''])
    lcext='par'; %ASCII file with nonstandard extension
  end
end
%
if any(domain=='sw')
  fscale=fs; %actual scaling frequency
  if any(domain=='s')
    if ~isempty(num), num=num./(fs.^[length(num)-1:-1:0]); end
    if ~isempty(denom), denom=denom./(fs.^[length(denom)-1:-1:0]); end
    if ~isempty(ntr), ntr=ntr./(fs.^[length(ntr)-1:-1:0]); end
  elseif strcmp(domain,'w')
    num=num./(sqrt(fs).^[length(num)-1:-1:0]);
    denom=denom./(sqrt(fs).^[length(denom)-1:-1:0]);
    if ~isempty(ntr), ntr=ntr./(sqrt(fs).^[length(ntr)-1:-1:0]); end
  end
  delay=delay/fs;
  nums=num([length(num):-1:1]);
  denoms=denom([length(denom):-1:1]);
  if ~isempty(ntr), ntrs=ntr(length(ntr):-1:1); else ntrs=[]; end
  %
  normbyp='pn'; %'p0' or 'pn', normalize polynomials by this coefficient
  if strcmp(normbyp,'pn')
    cnav=0; weightnum=0;
    numnlz=num; %no leading zero in numnlz
    if length(numnlz)>=2
      while numnlz(1)==0, numnlz(1)=[]; if length(numnlz)<2, break, end, end
      lnum=length(numnlz);
      if lnum>=2,
        numsc=max(abs(numnlz(1)),2*max(abs(numnlz))*minvali);
        cnav=mean(abs(numnlz(2:lnum)/numsc).^((1.0)./[1:lnum-1]));
        weightnum=lnum-1;
      end
    end
  else %normalize by p0
    cnav=0; weightnum=0;
    lnum=length(num);
    if lnum>=2,
      numsc=max(abs(num(lnum)),2*max(abs(num))*minvali);
      cnav=mean(abs(num(1:lnum-1)/numsc).^((1.0)./[lnum-1:-1:1]));
      weightnum=lnum-1;
    end
  end
  if cnav==0, weightnum=0; end
  %
  if strcmp(normbyp,'pn')
    cdav=0; weightdenom=0;
    denomnlz=denom; %no leading zero in denomnlz
    if length(denomnlz)>2
      while denomnlz(1)==0, denomnlz(1)=[]; if length(denomnlz)<2, break, end, end
      ldenom=length(denomnlz);
      if ldenom>=2,
        denomsc=max(abs(denomnlz(1)),2*max(abs(denomnlz))*minvali);
        cdav=mean(abs(denomnlz(2:ldenom)/denomsc).^((1.0)./[1:ldenom-1]));
        weightdenom=ldenom-1;
      end
    end
  else %normalize by p0
    cdav=0; weightdenom=0;
    ldenom=length(denom);
    if ldenom>=2,
      denomsc=max(abs(denom(ldenom)),2*max(abs(denom))*minvali);
      cdav=mean(abs(denom(1:ldenom-1)/denomsc).^((1.0)./[ldenom-1:-1:1]));
      weightdenom=ldenom-1;
    end
  end
  if cdav==0, weightdenom=0; end
  %
  if (weightnum+weightdenom)==0, fs=1;
  else
    if strcmp(normbyp,'pn')
      fs=(2/3/(weightnum+weightdenom)*(weightnum*cnav+weightdenom*cdav));
    else %normalize by p0
      fs=1/(1.5/(weightnum+weightdenom)*(weightnum*cnav+weightdenom*cdav));
    end
    %fs=mean(abs([roots(num);roots(denom)])); %alternative suggested fs
    if strcmp(domain,'w')&isfinite(fs^2), fs=fs^2; end
  end
  if isnan(fs)|(fs==0), fs=1; end
  if ~isfinite(fs), fs=maxvali; end
  if ~strcmp(eim,'no')&~isempty(fname)
    fprintf(['   Scaling frequency: %-0.3e Hz, suggested: %-0.3e Hz\n'],...
      fscale,fs);
  end
elseif any(domain=='zqpr')
  nums=num;
  denoms=denom;
  ntrs=ntr;
  if domain=='r', delay=delay/fs; end
end
%
if strcmp(lcext,'pnt')|strcmp(lcext,'par') %ASCII file
  fnid=fopen(fname,'w');
  nind=[0:length(nums)-1];
  dind=[0:length(denoms)-1];
  if notext==false
    %Prepare comment string for fprintf
    if ~isempty(cmts)
      cr=setstr(13); lf=setstr(10); %carriage return, line feed
      commf=cmts;
      %make vector from text array
      [vc,hc]=size(commf);
      if vc>1
        commf=[commf';setstr(cr*ones(1,vc))]; commf=commf(:)';
      end
      %double \ signs
      pcti=find(commf=='\');
      if ~isempty(pcti)
        for pctn=length(pcti):-1:1
          commf(pcti(pctn)+1:length(commf)+1)=commf(pcti(pctn):length(commf));
        end
      end
      %double percent signs
      pcti=find(commf=='%');
      if ~isempty(pcti)
        for pctn=length(pcti):-1:1
          commf(pcti(pctn)+1:length(commf)+1)=commf(pcti(pctn):length(commf));
        end
      end
      %delete line feed characters from cr/lf combinations
      cri=find(commf(1:length(commf)-1)==cr);
      crlfi=find([commf(cri+1),'0']==lf);
      if ~isempty(crlfi) commf(cri(crlfi)+1)=''; end
      crorlfi=find((commf==cr)|(commf==lf));
      commf(crorlfi)=setstr(lf*ones(1,length(crorlfi)));
      if max([crorlfi,0])<length(commf), commf=[commf,lf]; end
    else
      commf='';
    end
    %
    pct='%%\n';
    header=['%%fname: ',fname,', ftype: ',ftype,...
            ', date: ',fdate,'\n'];
    if strcmp(domain,'z')|strcmp(domain,'q')
      dot='1';
      fst='%8.6e %%Sampling frequency\n';
      dvar='z^-1';
    elseif any(domain=='sw')
      if domain=='s', dot='0';
      elseif domain=='w', dot='2';
      end
      fst='%8.6e %%Suggested frequency scaling factor\n';
      dvar=domain;
    elseif domain=='p', dot='3';
      fst='%8.6e %%Scaling frequency for orthogonal polynomials\n';
      dvar=domain;
    elseif domain=='r', dot='4';
      fst='%8.6e %%Tau-parameter\n';
      fs=tauR;
      dvar=domain;
    end
    dot=[dot,' %%',domain,'-domain\n'];
    ont=' %%Order of the numerator';
    odt=' %%Order of the denominator';
    cn='%%Coefficients of the numerator\n';
    if domain~='p', pc=['%%Powers of ',dvar,'    coefficients\n'];
    else pc='%%Orders of polynomials   coefficients\n';
    end
    cd='%%Coefficients of the denominator\n';
    nd='%17.15e %%Delay';
    if strcmp(domain,'z'), nd=[nd,', in samples']; end
    if (domain~='p')|(fs==1), nd=[nd,'\n'];
    else nd=[nd,sprintf(', unscaled: %17.15e',delay/fs),'\n'];
    end
    nfn='%%Number of the fixed parameters in the numerator';
    nfd='%%Number of the fixed parameters in the denominator';
    Znumt='%%Weights of the orthopol calculation of the numerator\n';
    Zdenomt='%%Weights of the orthopol calculation of the denominator\n';
    ctr='%%Coefficients of the transient numerator\n';
    ontrt=' %%Order of the transient numerator';
    Zntrt='%%Weights of the orthopol calculation of the transient numerator\n';
    eof='%%End of parameter file\n';
  else %no text
    commf='';
    pct='';
    header='';
    if any(domain=='s')
      dot='0\n';
    elseif strcmp(domain,'z')
      dot='1\n';
    elseif strcmp(domain,'w')
      dot='2\n';
    elseif strcmp(domain,'p')
      dot='3\n';
    elseif strcmp(domain,'r')
      dot='4\n';
    elseif strcmp(domain,'q')
      dot='5\n';
    end
    fst='%8.6e\n';
    ont='';
    odt='';
    cn='';
    cd='';
    pc='';
    nd='%17.15e\n';
    nfn='';
    nfd='';
    Znumt='';
    Zdenomt='';
    ctr='';
    ontrt='';
    Zntrt='';
    eof='';
  end
  fprintf(fnid,header);
  while ~isempty(commf)
    cri=min(find(commf==lf));
    if isempty(cri), error('comment cycle error'), end
    fprintf(fnid,['%%',commf(1:cri-1),'\n']);
    commf(1:cri)='';
  end
  fprintf(fnid,dot);
  fprintf(fnid,fst,fs);
  if (notext==true)&(separateline==true)
    separ='\n     '; %cr + 5 spaces
  else
    separ='    '; %4 spaces
  end
  pformat1=['%.0f',separ]; pformat2='% 17.15e\n';
  if ~isieeei %bug in VMS
    pformat2='%17.15e\n';
  end
  fprintf(fnid,['%.0f',ont,'\n'],length(nums)-1);
  fprintf(fnid,['%.0f',odt,'\n'],length(denoms)-1);
  fprintf(fnid,pct);
  fprintf(fnid,cn);
  fprintf(fnid,pc);
  for i=1:length(nums)
    sps='';
    if ~isieeei %bug in VMS
      if nums(i)>=0, sps=' '; end %space if positive
    end
    fprintf(fnid,[pformat1,sps,pformat2],nind(i),nums(i));
  end
  fprintf(fnid,pct);
  fprintf(fnid,cd);
  fprintf(fnid,pc);
  for i=1:length(denoms)
    sps='';
    if ~isieeei %bug in VMS
      if denoms(i)>=0, sps=' '; end %space if positive
    end
    fprintf(fnid,[pformat1,sps,pformat2],dind(i),denoms(i));
  end
  fprintf(fnid,pct);
  fprintf(fnid,nd,delay);
  if any(domain=='pq')
    fprintf(fnid,pct);
    fprintf(fnid,Znumt);
    for i=1:length(Znum(:));
      j1=1;
      if j1>1, fprintf(fnid,'  '); end
      fprintf(fnid,pformat2,Znum(i));
      j1=j1+1;
    end %for i
    fprintf(fnid,Zdenomt);
    for i=1:length(Zdenom(:));
      j1=1;
      if j1>1, fprintf(fnid,'  '); end
      fprintf(fnid,pformat2,Zdenom(i));
      j1=j1+1;
    end %for i
  end %domain=='p'
  fprintf(fnid,pct);
  %
  if ~isempty(ntr)
    ntrind=[0:length(ntrs)-1];
    fprintf(fnid,['%.0f',ontrt,'\n'],length(ntrs)-1);
    fprintf(fnid,ctr);
    fprintf(fnid,pc);
    for i=1:length(ntrs)
      sps='';
      if ~isieeei %bug in VMS
        if ntrs(i)>=0, sps=' '; end %space if positive
      end
      fprintf(fnid,[pformat1,sps,pformat2],ntrind(i),ntrs(i));
    end
    fprintf(fnid,Zntrt);
    for i=1:length(Zntr)
      j1=1;
      if j1>1, fprintf(fnid,'  '); end
      fprintf(fnid,pformat2,Zntr(i));
      j1=j1+1;
    end %for i
    fprintf(fnid,pct);
  end
  fprintf(fnid,eof); %end of file line
  fclose(fnid);
elseif strcmp(lcext,'pbn') %binary file
  comments=cmts;
  if any(domain=='pq'), pnames='Znum Zdenom '; else pnames=''; end
  if isempty(pnames)
    %Compiler:
    if domain~='r'
      feval('save',fname,'comments','ftype','fdate','domain','fs','num','denom','delay')
    else %r--domain
      feval('save',fname,'comments','ftype','fdate','domain','tauR','num','denom','delay')
    end
  else %orthopol
    %Compiler:
    feval('save',fname,'comments','ftype','fdate','domain','fs','num','denom',...
        'delay','Znum','Zdenom','ntr','Zntr')
  end
end
%
if (nargout>0)|isempty(fname) %output vector defined, or no output file
  if domain=='s', pvect=0;
  elseif strcmp(domain,'z'), pvect=1;
  elseif strcmp(domain,'w'), pvect=2;
  elseif strcmp(domain,'p'), pvect=3;
  elseif strcmp(domain,'r'), pvect=4;
  elseif strcmp(domain,'q'), pvect=5;
  else error('Unknown domain')
  end
  if domain=='r', fs=tauR; end
  pvect=[pvect;fs;length(nums)-1;length(denoms)-1];
  datn=[0:length(nums)-1,0:length(denoms)-1;nums(:).',denoms(:).'];
  pvect=[pvect;datn(:);delay];
  %
  if any(domain=='pq') %add orthonormal basis
    pvect=[pvect;Znum(:)];
    pvect=[pvect;Zdenom(:)];
  end %domain=='p'
  %
  if length(ntrs)>0
    datn=[0:length(ntrs)-1;ntrs(:)'];
    pvect=[pvect;length(ntrs)-1;datn(:)];
    if any(domain=='pq')
      pvect=[pvect;Zntr(:)];
    end
  end
end
%
if ~strcmp(eim,'no')&~isempty(fname)
  if any(domain=='sw')
    fprintf(['   Orders: %.0f/%.0f, delay: %-6.4e s, ',domain,'-domain\n'],...
       length(num)-1,length(denom)-1,delay)
  elseif any(domain=='pq')
    fprintf(['   Orders: %.0f/%.0f, delay: %-6.4e s, ',domain,'-domain'],...
       length(num)-1,length(denom)-1,delay/fs)
    fprintf(', fs=%.3e Hz\n',fs)
  else %z
    fprintf(['   Orders: %.0f/%.0f, delay: %-.3f samples, z-domain'],...
       length(num)-1,length(denom)-1,delay)
    fprintf(', fs=%.3e Hz\n',fs)
  end
  if ~isempty(ntr)
    fprintf('   With transients, order %.0f\n',length(ntr)-1)
  end
end
%
if (length(cmts)>0)&~strcmp(lcext,'pnt')&...
        ~strcmp(eim,'no')&~isempty(fname)
  disp(['   Comments: ',cmts])
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of exppar %%%%%%%%%%%%%%%%%%%%%%%%%
