function vvect=expvar(varx,vary,covxy,filename,comments,fdate,Ffile)
%EXPVAR Write variance data to a 'variance' vector or file (for ELIS).
%
%       vvect=EXPVAR(varx,vary,covxy,filename,comments,fdate,Ffile)
%
%       Output argument:
%       vvect = vector, containing the same data as the .pnt file
%
%       Input arguments:
%       varx = column, vector containing the variances of the real part (that
%           is, also of the imaginary part) of the input Fourier coefficients;
%           varx may be an array for multiple inputs
%       vary = column vector, containing the variances of the real part (that
%           is, also of the imaginary part) of the output Fourier coefficients;
%           vary may be an array for multiple outputs.
%       covxy = column vector of the complex input-output covariances
%           (0.5*E{conj(Nx)*Ny}). covxy may be empty. In the MIMO case covxy
%           contains either the covariances between input1 and output1, or
%           all the covariances beside each other, as [ci1o1,ci1o2,...ci2o1...]
%       filename = name of the output file
%           If the name has no extension, this function extends it by '.vbn'.
%           If the extension is .vbn, the result will be a binary file, else an
%           ASCII file. If the extension is '.vnt', no text is sent to the
%           ASCII file, but data. If filename is empty, no file will be
%           generated. The number of digits in ASCII files: digitnum=4
%       comments = string with eventual comments (optional)
%       fdate = date (and time) string (optional). If fdate is missing or
%           empty, an actual date string will be generated.
%       Ffile = associated Fourier file, readable for impfou (optional,
%             for cross-checking)
%
%       If a file is generated, the most important values will be displayed on
%       the screen, unless a global variable 'expimpmessages' with value 'no'
%       is defined.
%       The file will be created in the active subdirectory or folder.
%
%       Usage: vvect=expvar(varx,vary,covxy,filename,comments,fdate,Ffile)
%       Example: expvar(ones(20,1),0.1*ones(20,1),[],'data.vbn');
%
%       See also: IMPVAR.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 04-Oct-1996

ftype='variance V1.0';
true=1;
false=0;
separateline=true; %without text, each number in a separate line
global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
digitnum=4; %number of digits
%
if nargin<6, fdate=''; end
if nargin<5, comments=''; end
if nargin<4, filename=''; end
if nargin<3, covxy=[]; end
comments=setstr(comments); fdate=setstr(fdate);
if isempty(fdate), %generate actual date
  dat=clock;
  fdate=[date,sprintf(', %.0f:%.0f:%.0f',dat(4),dat(5),dat(6))];
end
if ~isempty(filename)
  if ~isstr(filename), error('filename is not a string'), end
  [filename,dummy,ext]=fnamanal(filename,'vbn'); lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'vnt') %No comment will be sent
    notext=true;
    ntx='flat '; %ASCII file type
  else
    notext=false;
    ntx='';
  end
else %filename is empty
  lcext='';
end
if strcmp(lcext,'vbn') %binary file
  fty='binary'; ntx='';
else
  fty='ASCII';
end
if ~strcmp(eim,'no')&~isempty(filename)
  disp(['expvar sending data to ',ntx,fty,' file ''',filename,''''])
end
if ~isempty(filename)
  if ~(strcmp(lcext,'var')|strcmp(lcext,'vnt')|strcmp(lcext,'vbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''var'' or ''vnt'' or ''vbn'''])
    lcext='var'; %ASCII file with nonstandard extension
  end
end
%
[lx,inputno]=size(varx); [ly,outputno]=size(vary);
if lx~=ly
  error('Input and output vectors must be of the same length')
end
[lc,wc]=size(covxy);
if ~isempty(covxy)
  if lc~=lx, error('Length of varx and covxy are different'), end
  if (wc~=1)&(wc~=inputno*outputno), error('Width of covxy is illegal'), end
end
if nargin==7, %Ffile given
  if isstr(Ffile)&(exist(Ffile)~=2),
    disp(['Warning (expvar): ',Ffile,' file does not exist'])
  else
    if ~strcmp(eim,'no')&isstr(Ffile)
      fprintf('In expvar: ')
    end
    [freqvect,x,y]=impfou(Ffile); fl=length(freqvect);
    xs=size(x); ys=size(y);
    vxs=size(varx); vys=size(vary);
    if (vxs(1)~=fl)|(vys(1)~=fl)|(vxs(2)~=xs(2))|(vys(2)~=ys(2))
      error('Data incompatible with Fourier file')
    end
  end
end
%
if ~isempty(filename)&(exist(filename)~=0)
  delete(filename)
  if exist(filename)~=0, error(['Cannot delete existing file ''',...
         filename,'''']), end
end
%
if any([any(imag(varx)),any(imag(vary))]'),
  error('Vectors contain complex elements')
end
if any(isnan([varx(:);vary(:);covxy(:)])),
  error('Vectors contain NaN elements')
end
%
if ~strcmp(eim,'no')&~isempty(filename)
  fprintf('   Number of frequencies: %.0f, inputs: %.0f, outputs: %.0f\n',...
     length(varx(:,1)),length(varx(1,:)),length(vary(1,:)))
  if ~isempty(covxy), fprintf('   Covariances given: %.0f\n',wc), end
end
%
if (length(comments)>0)&~strcmp(lcext,'vnt')&...
         ~strcmp(eim,'no')&~isempty(filename)
  disp(['   Comments: ',comments])
end
%
infno=sum(~isfinite([varx(:);vary(:);covxy(:)]));
if infno>0
  if strcmp(lcext,'vbn')|isempty(lcext)
    fprintf(['   WARNING: variance vectors contain %.0f ',...
            'infinite element(s)\n'],infno)
  else
    error('Vectors contain infinite elements')
  end
end
%
if strcmp(lcext,'vnt')|strcmp(lcext,'var') %ASCII file
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
    spi=setstr(32*ones(1,inputno*13-5));
    firstline=['%%Input and output variances'];
    if wc>0
      spo=setstr(32*ones(1,outputno*13-5));
      firstline=[firstline,', covariances\n'];
    else firstline=[firstline,'\n'];
    end
    if length(firstline)>78, firstline='Variances and covariances\n'; end
    noi=' %%Number of inputs';
    noo=' %%Number of outputs';
    cno=' %%Number of covariances (0, 1, or inputno*outputno)';
    eof='%%End of variance file\n';
  else
    commf='';
    pct='';
    header='';
    firstline='';
    noi='';
    noo='';
    cno='';
    eof='';
  end
  if ((notext==true)&(separateline==true))|...
     ((notext==false)&((inputno+outputno+2*wc)*(digitnum+5+3)>75))
    separ='\n     '; %cr + 5 spaces
  else
    separ='   '; %3 spaces
  end
  fprintf(fnid,header);
  while ~isempty(commf)
    cri=min(find(commf==lf));
    if isempty(cri), error('comment cycle error'), end
    fprintf(fnid,['%%',commf(1:cri-1),'\n']);
    commf(1:cri)='';
  end
  fprintf(fnid,['%.0f',noi,'\n%.0f',noo,'\n%.0f',cno,'\n',firstline],...
           inputno,outputno,wc);
  nform=['%',int2str(digitnum+1),'.',int2str(digitnum-1),'e'];
  tenlines='';
  freqlen=length(varx(:,1));
  for kc=1:freqlen
    tenlines=[tenlines,sprintf(nform,varx(kc,1))];
    for kio=2:inputno
      tenlines=[tenlines,sprintf([separ,nform],varx(kc,kio))];
    end
    for kio=1:outputno
      tenlines=[tenlines,sprintf([separ,nform],vary(kc,kio))];
    end
    for kio=1:wc
      tenlines=[tenlines,sprintf([separ,nform],real(covxy(kc,kio)))];
      tenlines=[tenlines,sprintf([separ,nform],imag(covxy(kc,kio)))];
    end
    tenlines=[tenlines,sprintf('\n')];
    if (rem(kc,10)==0)|(kc==freqlen),
      fprintf(fnid,tenlines); %send ten lines
      tenlines='';
      if ~strcmp(eim,'no')
        fprintf('%4.0f rows of %.0f are ready\n',kc,freqlen)
        %information message
      end
    end
  end
  fprintf(fnid,pct);
  fprintf(fnid,eof); %end of file line
  fclose(fnid);
elseif strcmp(lcext,'vbn') %binary file
  feval('save',filename,'comments','ftype','fdate','varx','vary','covxy')
end
%
if (nargout>0)|isempty(filename) %output vector defined, or no output file
  vvect=[varx,vary];
  for i=1:wc
    vvect=[vvect,real(covxy(:,i)),imag(covxy(:,i))];
  end
  vvect=vvect';
  vvect=[inputno;outputno;wc;vvect(:)];
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of expvar %%%%%%%%%%%%%%%%%%%%%%%%%
