function Fvect=expfou(freqvect,x,y,i,expno,filename,comments,fdate,digitnum,ctyp)
%EXPFOU Write data to a Fourier vector or a (maybe existing) file (for ELIS).
%
%       Fvect=EXPFOU(freqvect,x,y,i,expno,filename,comments,fdate,digitnum,ctyp)
%
%       Output argument:
%       Fvect = vector, containing the same data as a .fnt file
%
%       Input arguments:
%       freqvect = vector of frequency points
%       x = complex input amplitude vector (or array for multiple inputs)
%       y = complex output amplitude vector (or array for multiple outputs)
%           Each vector must be a column vector; x or y may be empty.
%           Results of different experiments must be given below each other,
%           as e.g. [xexp1;xexp2;xexp3]
%       i = Number(s) of the actual experiment(s). If several experiments are
%           given, they must be denoted by successive numbers. If i is empty or
%           missing, the default is  i=[1:length(x(:,1))/length(freqvect)].
%       expno = Total number of experiments: if missing, max(i) is assigned.
%       filename = name of the output file (string)
%           If the name has no extension, EXPFOU extends it by '.fbn'. If the
%           extension is .fbn, the result will be a binary file, else an ASCII
%           one. If the extension is '.fnt', no text is sent to the ASCII file,
%           only data. If filename is empty, no file will be generated.
%       comments = string with eventual comments (optional)
%       fdate = date (and time) string (optional). If fdate is missing or
%           empty, an actual date string will be generated.
%       digitnum (optional) = number of digits sent to ASCII files,
%           default: 5.   1<=digitnum<=16
%       ctyp = if 'neg', then the frequencies may be negative.
%
%       When exporting the data of the first experiment, any file with the same
%       name will be deleted.
%       The file will be created in the active subdirectory or folder.
%       If a file is generated, the most important values will be displayed on
%       the screen, unless a global variable 'expimpmessages' with value 'no'
%       is defined. When exporting the data of the first experiment, any file
%       with the same name will be deleted.
%
%       Special call:
%            Fvect=expfou(fiddat,fname) %conversion of object to old format
%
%       Usage: Fvect=expfou(freqvect,x,y,i,expno,filename,comments,fdate,dign,ctyp);
%       Example: expfou([1:20],ones(100,1),0.1*ones(100,1),[1:5],5,'data.fbn');
%
%       See also: IMPFOU.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Apr-2002

ftype='Fourier V1.0';
true=1;
false=0;
separateline=true; %without text, each number in a separate line
global expimpmessages
if strncmp(version,'5.',2), isieeei=isieee; else isieeei=1; end
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
%
if nargin==1
  if (length(freqvect)==1)&isequal(freqvect,-1), return, end
  if isstr(freqvect)&isequal(freqvect,'preload'), return, end
end
if isa(freqvect,'fiddata')
  %conversion only from fiddata object
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,2,ni)), %earlier
  end
  fid=freqvect;
  freqvect=fid.freqpoints;
  if iscell(freqvect), fid=collapse(fid); freqvect=fid.freqpoints; end
  if nargin>=2, filename=x; else filename=''; end
  x=fid.input;
  y=fid.output;
  expno=fid.expn;
  i=1:expno;
  comments=fid.notes; fdate=fid.date;
  digitnum=6;
elseif isa(freqvect,'fidmodel')|isa(freqvect,'iddat')|isa(freqvect,'idmodel')
  error(['Class of freqvect is invalid: ',class(freqvect)])
else
  if nargin<10, ctyp=''; end
  if nargin<9, digitnum=[]; end
  if isempty(digitnum), digitnum=5; end
  if nargin<8, fdate=''; end
  if nargin<7, comments=''; end
  comments=setstr(comments); fdate=setstr(fdate);
  if isempty(fdate), %generate actual date
    dat=clock;
    fdate=[date,sprintf(', %.0f:%.0f:%.0f',dat(4),dat(5),dat(6))];
  end
  if nargin<4, i=[]; end
  if isempty(i), i=1:max(size(x,1),size(y,1))/length(freqvect); end
  if length(i)>1
    if any(diff(i)~=1)
      error('experiment numbers must be successive integers')
    end
  end
  if nargin<5, expno=max(i); end
  if isempty(expno), expno=max(i); end
  if length(expno)>1, error('expno is not scalar'), end
  if any(expno<i), error('i exceeds expno'), end
  if nargin<3, error('y is not given'), end
  %
  if nargin<6, filename=''; end
  if ~isempty(filename)&~isstr(filename), error('filename is not a string'), end
end
if ~isempty(filename)
  [filename,dummy,ext]=fnamanal(filename,'fbn');
  lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'fnt') %No comment will be sent
    notext=true;
    ntx='flat '; %ASCII file type
  else
    notext=false;
    ntx='';
  end
else %filename is empty
  lcext='';
end
if strcmp(lcext,'fbn') %binary file
  fty='binary'; ntx='';
else
  fty='ASCII';
end
if ~strcmp(eim,'no')&~isempty(filename)
  if length(i)>1, itxt=['...',int2str(i(length(i)))]; else itxt=''; end
  if expno>1, exptxt=['of exp. ',int2str(i(1)),itxt,' ']; else exptxt=''; end
  disp(['expfou sending data ',exptxt,'to ',...
       ntx,fty,' file ''',filename,''''])
end
if ~isempty(filename)
  if ~(strcmp(lcext,'fou')|strcmp(lcext,'fnt')|strcmp(lcext,'fbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''fou'' or ''fnt'' or ''fbn'''])
    lcext='fou'; %ASCII file with nonstandard extension
  end
end
%
if i(1)==1, %first experiment
  if ~isempty(filename)&(exist(filename)==2)
    delete(filename) %delete existing file
    if exist(filename)==2
      error(['Cannot delete existing file ''',filename,''''])
    end
  end
else %not first experiment
  if ~isempty(filename)&(exist(filename)~=2)
    error(['File must exist already when exporting ',...
                int2str(i),'. experiment'])
  end
end
%
if min(size(freqvect))~=1
  error('''freqvect'' must be a vector')
end
freqvect=freqvect(:); %column vector
flen=length(freqvect); exl=length(i);
[lx,inputno]=size(x); [ly,outputno]=size(y);
if ( ~isempty(x) & (flen*exl~=lx) ) | ( ~isempty(y) & (flen*exl~=ly) )
  error(['Parameter array sizes are incompatible:',...
      sprintf('\n   Amplitudes required: %.0f*%.0f=%.0f',flen,exl,flen*exl),...
      sprintf(', size(x)=[%.0f,%.0f]',lx,inputno),...
      sprintf(', size(y)=[%.0f,%.0f]',ly,outputno)])
end
if isnumeric(freqvect), fvv=freqvect;
else fvv=cat(1,freqvect{:});
end
if any(any(imag(fvv))'),
  error('The frequency vector contains complex elements')
end
if any(any(fvv<0)')&~strncmp(ctyp,'negative',3),
  error('The frequency vector contains negative elements')
end
if ~all(all(isfinite(fvv))'),
  error('Frequency vector contains infinite or NaN elements')
end
if ~all([all(isfinite(x)),all(isfinite(y))]'),
  disp('Vectors contain infinite or NaN elements')
end
%
if ( (1<=digitnum)&(digitnum<=16) )
  fspec=['% ',sprintf('%.0f.%.0fe',digitnum+1,digitnum-1)];
  fspecf=['%',fspec(3:length(fspec))];
  if ~isieeei %bug in VMS
    fspec=fspecf; %no leading space
  end
else
  error('Number of digits incorrect')
end
if ~strcmp(eim,'no')&~isempty(filename)
  fprintf('   Frequencies: %.0f, from %.3e to %.3e Hz\n',...
          flen,min(freqvect),max(freqvect))
  sbno=length(find((x(:,1)==0)&(y(:,1)==0)));
  if sbno>0, fprintf('   Stopband (0/0): %.0f frequency point(s)\n',sbno), end
end
%
if (length(comments)>0)&~strcmp(lcext,'fnt')&~isempty(filename)
  disp(['   Comments: ',comments])
end
%
if strcmp(lcext,'fnt')|strcmp(lcext,'fou') %ASCII file
  fnid=fopen(filename,'a');
  if notext==false
    %Prepare comment string for fprintf
    if ~isempty(comments)
      cr=setstr(13); lf=setstr(10); %carriage return, line feed
      commf=comments;
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
    header=['%%filename: ',filename,', ftype: ',ftype,...
            ', date: ',fdate,'\n'];
    noi=' %%Number of inputs';
    noo=' %%Number of outputs';
    noe=' %%Number of experiments';
    nof=' %%Number of frequencies';
    sf=' %%Start frequency (Hz)';
    stpf=' %%Stop frequency (Hz)';
    mr='%%                                 Measurement results\n';
    spi=setstr(32*ones(1,7));
    spo=setstr(32*ones(1,2*inputno*(7+digitnum)-5));
    hio=['%%Frequency',spi,'input',spo,'output\n'];
    eno=' %%Experiment no.';
    eof='%%End of Fourier file\n';
  else
    commf='';
    pct='';
    header='';
    noi='';
    noo='';
    noe='';
    nof='';
    sf='';
    stpf='';
    mr='';
    hio='';
    eno='';
    eof='';
  end
  if i(1)==1
    fprintf(fnid,header);
    while ~isempty(commf)
      cri=min(find(commf==lf));
      if isempty(cri), error('comment cycle error'), end
      fprintf(fnid,['%%',commf(1:cri-1),'\n']);
      commf(1:cri)='';
    end
    fprintf(fnid,['%.0f',noi,'\n','%.0f',noo,'\n'],inputno,outputno);
    fprintf(fnid,['%.0f',noe,'\n','%.0f',nof,'\n'],expno,flen);
    fprintf(fnid,[fspecf,sf,'\n'],min(freqvect));
    fprintf(fnid,[fspecf,stpf,'\n'],max(freqvect));
    fprintf(fnid,mr);
    fprintf(fnid,hio);
  end
  for ii=1:length(i) %cyclic export of experiments
    fprintf(fnid,['%.0f',eno,'\n'],i(ii)); %experiment no.
    if (notext==true)&(separateline==true)|...
          ((7+digitnum)*(2*inputno+2*outputno+1)>79)
      fill='\n'; %each number will be in a separate line
      spaces='     ';  %5 spaces
    else
      fill='  '; %two spaces
      spaces='';
    end
    tenlines='';
    for k=1:flen,   %main cycle
      km=(ii-1)*flen+k; %index in x and y
      oneline=sprintf([fspecf,fill,spaces],freqvect(k));
      for io=1:inputno,
        sr=''; si='';
        if length(fspecf)==length(fspec) %space left out from format
          if real(x(km,io))>=0, sr=' '; end %space if positive
          if imag(x(km,io))>=0, si=' '; end %space if positive
        end
        oneline=[oneline,sr,sprintf([fspec,fill],real(x(km,io))),...
                spaces,si,sprintf(fspec,imag(x(km,io)))];
      end
      for io=1:outputno,
        sr=''; si='';
        if length(fspecf)==length(fspec) %space left out from format
          if real(y(km,io))>=0, sr=' '; end %space if positive
          if imag(y(km,io))>=0, si=' '; end %space if positive
        end
        oneline=[oneline,sprintf(fill),...
                spaces,sr,sprintf([fspec,fill],real(y(km,io))),...
                spaces,si,sprintf(fspec,imag(y(km,io)))];
      end
      oneline=[oneline,'\n'];
      tenlines=[tenlines,oneline];
      if (rem(km,10)==0)|(rem(km,flen)==0),
        fprintf(fnid,tenlines); %send ten lines
        tenlines='';
        if ~strcmp(eim,'no')&~isempty(filename)
          fprintf('%4.0f rows of %.0f are ready\n',km,flen*length(i))
          %information message
        end
      end
    end
  end %ii
  if ii==expno, %last experiment
    fprintf(fnid,pct);
    fprintf(fnid,eof); %end of file line
  end
  fclose(fnid);
elseif strcmp(lcext,'fbn') %binary file
  if i(1)>1 %not first experiment
    xsav=x; ysav=y; freqvectsav=freqvect;
    load(filename,'-mat')
    if any(freqvect-freqvectsav)
      error('Frequency vector differs from previous one')
    end
    ifile=length(x(:,1))/length(freqvectsav);
    if ifile~=i(1)-1
      error(sprintf(['Existing ',filename,...
         ' contains %.0f experiment(s) instead of %.0f'],ifile,i(1)-1))
    end
    x=[x;xsav]; y=[y;ysav];
  end
  %Matlab4.0 and later:
  save(filename,'comments','ftype','fdate','expno','freqvect','x','y')
  %Compiler and Matlab4.2c and later:
  %feval('save',filename,'comments','ftype','fdate','expno','freqvect','x','y')
  if i(1)>1, x=xsav; y=ysav; end %restore for later use (Fvect)
end
%
if (nargout>0)|isempty(filename) %output vector defined, or no output file
  Fvect=[];
  for ii=1:length(i)
    if i(ii)==1
      Fvect0=[inputno;outputno;expno;flen;...
             freqvect(1);freqvect(flen);1];
    elseif i(ii)<=expno
      Fvect0=i(ii);
    end
    Fvecti=freqvect;
    for io=1:inputno
      Fvecti=[Fvecti,real(x((ii-1)*flen+[1:flen],io)),...
                   imag(x((ii-1)*flen+[1:flen],io))];
    end
    for io=1:outputno
      Fvecti=[Fvecti,real(y((ii-1)*flen+[1:flen],io)),...
                   imag(y((ii-1)*flen+[1:flen],io))];

    end
    Fvecti=Fvecti'; Fvect=[Fvect;Fvect0;Fvecti(:)];
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of expfou %%%%%%%%%%%%%%%%%%%%%%%%%
