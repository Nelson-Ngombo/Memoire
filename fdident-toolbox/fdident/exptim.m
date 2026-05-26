function tvect=exptim(timevect,xt,yt,i,expno,filename,comments,fdate,digitnum)
%EXPTIM Write time data to a vector or a (maybe existing) file (for ELIS).
%
%       tvect=EXPTIM(timevect,xt,yt,i,expno,filename,comments,fdate,digitnum)
%
%       Output argument:
%       tvect = vector, containing the same data as would be sent to
%           a .tnt file.
%
%       Input argument:
%       timevect = vector of time points
%       xt = input vector (or array for multiple inputs)
%       yt = output vector (or array for multiple outputs)
%           Each vector must be a column vector; xt or yt may be empty.
%           Results of different experiments must be given below each other,
%           as e.g. [xexp1;xexp2;xexp3]
%       i = Number(s) of the actual experiment(s). If several experiments are
%           given, they must be denoted by successive numbers. If i is empty or
%           missing, the default is  i=[1:length(xt(:,1))/length(timevect)].
%       expno = Total number of experiments, if empty, max(i) is assigned.
%       filename = name of the output file (string)
%           If the name has no extension, EXPTIM extends it by '.tbn'. If the
%           extension is .tbn, the result will be a binary file, else an ASCII
%           file. If the extension is '.tnt', no text is sent to the ASCII
%           file, only data.
%           If filename is empty, no file will be generated.
%       comments = string with eventual comments (optional)
%       fdate = date (and time) string (optional). If fdate is missing or
%           empty, an actual date string will be generated.
%       digitnum (optional) = number of digits sent to ASCII files,
%           default: 5.   1<=digitnum<=16
%
%       When exporting the data of the first experiment, any file with the
%       same name will be deleted.
%       The file will be created in the active subdirectory or folder.
%       If a file is generated, the most important values will be displayed
%       on the screen, unless a global variable 'expimpmessages' with value
%       'no' is defined. When exporting the data of the first experiment, any
%       file with the same name will be deleted.
%
%       Usage:
%            tvect=exptim(timevect,xt,yt,i,expno,filename,comments,fdate,dign);
%       Example: exptim([1:10],ones(50,1),0.1*ones(50,1),[1:5],5,'data.tbn');
%
%       See also: IMPTIM.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Dec-2000

ftype='time V1.0';
true=1;
false=0;
separateline=true; %without text, each number in a separate line
global expimpmessages
if strncmp(version,'5.',2), isieeei=isieee; else isieeei=1; end
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
%
if nargin<9, digitnum=[]; end
if isempty(digitnum), digitnum=5; end
if nargin<8, fdate=''; end
if nargin<7, comments=''; end
comments=setstr(comments); fdate=setstr(fdate);
if isempty(fdate), %generate actual date
  dat=clock;
  fdate=[date,sprintf(', %.0f:%.0f:%.0f',dat(4),dat(5),dat(6))];
end
if nargin<3, error('yt is not given'), end
if nargin<2, error('xt is not given'), end
if (size(xt,1)==1)&(size(xt,2)>1)&(size(xt,2)==size(yt,2))
  xt=xt'; yt=yt';
  disp('Warning! xt and yt are row vectors, they have been transposed')
end
sizxt=size(xt);
if sizxt(1)<sizxt(2)
  fprintf('Warning! xt is an %.0fx%.0f array. Do you really mean\n',...
        sizxt(1),sizxt(2))
  fprintf('  %.0f data points for a MIMO system with %.0f inputs?\n',...
        sizxt(1),sizxt(2))
end
if sizxt(1)<length(timevect)
  error('timevect is longer than vertical size of xt')
end
if rem(sizxt(1)/length(timevect),1)~=0
  error('Length of timevect is not integer multiple of vertical size of xt')
end
if nargin<4, i=[]; end
if isempty(i), i=1:length(xt(:,1))/length(timevect); end
if length(i)>1
  if any(diff(i)~=1)
    error('experiment numbers must be successive integers')
  end
end
if nargin<5, expno=max(i); end
if isempty(expno), expno=max(i); end
if length(expno)>1, error('expno is not scalar'), end
if any(expno<i), error('i exceeds expno'), end
if nargin<6, filename=''; end
if ~isempty(filename)&~isstr(filename), error('filename is not a string'), end
if ~isempty(filename)
  [filename,dummy,ext]=fnamanal(filename,'tbn'); lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'tnt') %No comment will be sent
    notext=true;
    ntx='flat '; %ASCII file type
  else
    notext=false;
    ntx='';
  end
else %filename is empty
  lcext='';
end
if strcmp(lcext,'tbn') %binary file
  fty='binary'; ntx='';
else
  fty='ASCII';
end
if ~strcmp(eim,'no')&~isempty(filename)
  if length(i)>1, itxt=['...',int2str(i(length(i)))]; else itxt=''; end
  if expno>1, exptxt=['of exp. ',int2str(i(1)),itxt,' ']; else exptxt=''; end
  disp(['exptim sending data ',exptxt,'to ',...
       ntx,fty,' file ''',filename,''''])
end
if ~isempty(filename)
  if ~(strcmp(lcext,'tim')|strcmp(lcext,'tnt')|strcmp(lcext,'tbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''tim'' or ''tnt'' or ''tbn'''])
    lcext='tim'; %ASCII file with nonstandard extension
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
if min(size(timevect))~=1
  error('''timevect'' must be a vector')
end
timevect=timevect(:); %column vector
timelen=length(timevect); [lx,inputno]=size(xt); [ly,outputno]=size(yt);
if ( ~isempty(xt) & (length(timevect)*length(i)~=lx) )|...
       ( ~isempty(yt) & (length(timevect)*length(i)~=ly) )
  error('Vector lengths of timevect, xt and yt are incompatible')
end
if any(any(imag(timevect))'),
  error('The time vector contains complex elements')
end
if any(any(timevect<0)'),
  error('The time vector contains negative elements')
end
if ~all(all(isfinite(timevect))'),
  error('Time vector contains infinite or NaN elements')
end
if ~all([all(isfinite(xt)),all(isfinite(yt))]'),
  disp('Vectors contain infinite or NaN elements')
end
if any(any(imag([xt,yt]))'),
  error('Amplitude vectors contain complex elements')
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
  fprintf('   Time values: %.0f, from %.3e to %.3e s\n',...
          timelen,min(timevect),max(timevect))
end
%
if (length(comments)>0)&~strcmp(lcext,'tnt')&~isempty(filename)
  disp(['   Comments: ',comments])
end
%
if strcmp(lcext,'tnt')|strcmp(lcext,'tim') %ASCII file
  fnid=fopen(filename,'a');
  if (notext==true)&(separateline==true)|...
        ((7+digitnum)*(inputno+outputno+1)>78)
    fill='\n'; %each number will be in a separate line
    spaces='     ';  %5 spaces
    spi=', '; spo=', ';
  else
    fill='  '; %two spaces
    spaces='';
    %Header separators (Time, input, output)
    spi=setstr(32*ones(1,10));
    spo=setstr(32*ones(1,inputno*(7+digitnum)-5));
  end
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
    nof=' %%Number of samples';
    sf=' %%Start time (s)';
    stpf=' %%Stop time (s)';
    if length(spi)>2
      mr='%%                   Measurement results\n';
    else
      mr='%%Measurement results\n';
    end
    hio=['%%Time',spi,'input',spo,'output\n'];
    eno=' %%Experiment no.';
    eof='%%End of time file\n';
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
    fprintf(fnid,['%.0f',noe,'\n','%.0f',nof,'\n'],expno,timelen);
    fprintf(fnid,[fspecf,sf,'\n'],timevect(1));
    fprintf(fnid,[fspecf,stpf,'\n'],timevect(timelen));
    fprintf(fnid,mr);
    fprintf(fnid,hio);
  end
  for ii=1:length(i) %cyclic export of experiments
    fprintf(fnid,['%.0f',eno,'\n'],i(ii)); %experiment no.
    tenlines='';
    for k=1:timelen,   %main cycle
      km=(ii-1)*timelen+k; %index in x and y
      oneline=sprintf(fspecf,timevect(k));
      for io=1:inputno,
        sr=''; si='';
        if length(fspecf)==length(fspec) %space omitted
          if xt(km,io)>=0, sr=' '; end %space if positive
        end
        oneline=[oneline,sprintf([fill,spaces,sr]),sprintf(fspec,xt(km,io))];
      end
      for io=1:outputno,
        sr=''; si='';
        if length(fspecf)==length(fspec) %space omitted
          if yt(km,io)>=0, sr=' '; end %space if positive
        end
        oneline=[oneline,sprintf([fill,spaces,sr]),...
                         sprintf(fspec,yt(km,io))];
      end
      oneline=[oneline,'\n'];
      tenlines=[tenlines,oneline];
      if (rem(km,10)==0)|(rem(km,timelen)==0),
        fprintf(fnid,tenlines); %send ten lines
        tenlines='';
        if ~strcmp(eim,'no')&~isempty(filename)
          fprintf('%4.0f rows of %.0f are ready\n',km,timelen*length(i))
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
elseif strcmp(lcext,'tbn') %binary file
  if i(1)>1, %not first experiment
    xtsav=xt; ytsav=yt; timevectsav=timevect;
    load(filename,'-mat')
    if any(timevect-timevectsav)
      error('Time vector differs from previous one')
    end
    ifile=length(xt(:,1))/length(timevectsav);
    if ifile~=i(1)-1
      error(sprintf(['Existing ',filename,...
         ' contains %.0f experiment(s) instead of %.0f'],ifile,i(1)-1))
    end
    xt=[xt;xtsav]; yt=[yt;ytsav];
  end
  %Matlab4.0 and later:
  save(filename,'comments','ftype','fdate','expno','timevect','xt','yt')
  %Compiler and Matlab4.2c and later:
  %feval('save',filename,'comments','ftype','fdate','expno','timevect','xt','yt')
  if i(1)>1, xt=xtsav; yt=ytsav; end %restore for later use (tvect)
end
%
if (nargout>0)|isempty(filename) %output vector defined, or no output file
  tvect=[];
  for ii=1:length(i)
    if i(ii)==1
      tvect0=[inputno;outputno;expno;timelen;...
             timevect(1);timevect(timelen);1];
    elseif i(ii)<=expno
      tvect0=i(ii);
    end
    tvecti=timevect;
    for io=1:inputno
      tvecti=[tvecti,xt((ii-1)*timelen+[1:timelen],io)];
    end
    for io=1:outputno
      tvecti=[tvecti,yt((ii-1)*timelen+[1:timelen],io)];
    end
    tvecti=tvecti'; tvect=[tvect;tvect0;tvecti(:)];
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of exptim %%%%%%%%%%%%%%%%%%%%%%%%%
