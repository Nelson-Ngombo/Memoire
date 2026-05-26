function [freqvect,x,y,expno,vdat,comments,fdate]=impfou(Fdat,expi)
%IMPFOU Read complex amplitudes from a Fourier vector or file (used by ELIS).
%
%       [freqvect,x,y,expno,vdat,comments,fdate]=IMPFOU(Fdat,expi)
%
%       Output arguments:
%       freqvect = vector of frequency points
%       x = complex input amplitudes (column vector or array)
%       y = complex output amplitudes (column vector or array)
%       vdat = variance data (optional, for binary files only)
%       expno = Total number of experiments in Fdat
%       comments = optional, comment string in the input file (if any)
%       fdate = optional, comment string in the input file (if any)
%
%       Input arguments:
%       Fdat = data vector or the name of the file, maybe an array
%           [freqvect,x,y]; the data vector contains
%           the data in the same order as a .fnt file.
%       expi = number(s) of the experiment(s) to be read (integer vector)
%           optional; if omitted or empty, all the experiments will be read.
%
%       The file may be an ASCII file with comments (usual extension: .fou),
%       an ASCII file without comments (.fnt), or a binary file (.fbn).
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given. Default extension: .fbn.
%       If a file is read, the most important values will be displayed on the
%       screen, unless a global variable 'expimpmessages' with value 'no' is
%       defined.
%
%       Usage: [freqvect,x,y,expno,vdat,comments,fdate]=impfou(Fdat,expi);
%       Example: [freqvect,x,y,expno]=impfou('inpchan',[]);
%
%       See also: EXPFOU.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Jun-2001

global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
if nargin==1
  if length(Fdat)==1
    if (isa(Fdat,'double')&Fdat==-1)|(isstr(Fdat)&strcmp(Fdat,'preload'))
      return
    end
  end
end
if nargin<2, expi=[]; end
comments=''; fdate='';
vdat=[];
if ~isempty(expi)
  if any(diff([0,sort(expi(:))])==0)
    error('expi is not strictly monotonic')
  elseif any(expi<=0)
    error('Nonpositive element in expi')
  end
end
%
Fdat=getobjf(Fdat,'fiddata'); %get fiddata if possible
if isstr(Fdat)
  [filename,dummy,ext]=fnamanal(Fdat,'mat');
  if strcmpi(ext,'mat')&exist(filename)
    vnstr=whos('-file',filename);
    if ~isempty(vnstr)
      if length(vnstr)==1, vname=vnstr(1).name;
      else error('More than one object in file')
      end
      for ii=1:length(vnstr)
        nii=0;
        if strcmp(vnstr(ii).name,vname)
          nii=ii; break
        end
      end
      if nii==0, error(['Variable ''',vname,''' not found in file']), end
      objstruc=feval('load',filename,vname);
      [freqvect,x,y,expno,vdat,comments,fdate]=feval('impfou',['objstruc.',vname],expi);
      return
    else
      error('No object in file')
    end
  else
    [filename,dummy,ext]=fnamanal(Fdat,'fbn');
  end
  lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'fbn') %binary file
    fty='binary'; ntx=[];
  else %ASCII file
    fty='ASCII';
    if strcmp(lcext,'fnt')
      ASCIItype='flat';
    else %ASCII with text
      ASCIItype='text';
    end
  end
  fty=[fty,' file ''',filename,''''];
elseif isa(Fdat,'fiddata')
  fty='fiddata object';
  lcext='';
  if nargin>2, error('Variable name given for object input'), end
else %vector in workspace
  [dl,dw]=size(Fdat); if (dl==1)&(dw>3), Fdat=Fdat(:); end
  fty='vector in workspace';
  lcext='';
  if nargin>2, error('Variable name given for vector input'), end
end %isstr(Fdat)
if ~strcmp(eim,'no')&isstr(Fdat)
  disp(['impfou loading data from ',fty])
end
if isstr(Fdat)
  if ~(strcmp(lcext,'fou')|strcmp(lcext,'fnt')|strcmp(lcext,'fbn'))
    disp(['Warning! File name ext. in expfou is ''',ext,...
          ''', instead of ''fou'' or ''fnt'' or ''fbn'''])
    lcext='fou'; %ASCII file with nonstandard extension
  end
end
%
if isa(Fdat,'fiddata')
  if ~isempty(expi), Fdat=Fdat{:,expi}; expi=[]; end
  freqvect=Fdat.inputfreqpoints;
  x=Fdat.input;
  y=Fdat.output;
  vdat=Fdat.SisoVariance;
  if iscell(freqvect)
    expno=max(size(freqvect,2),size(y,2));
    if ~isempty(expi)
      if any(expi>expno)|any(expi<=0), error('expi is out of range'), end
      if length(expi)<expno
        Fdat=Fdat{:,expi(:)};
      end
      freqvect=Fdat.inputfreqpoints;
      x=Fdat.input;
      y=Fdat.output;
      vdat=Fdat.OldTBSisoVariance;
    end
    return
  end
  if iscell(x), x=cat(1,x{:}); end
  if iscell(y), y=cat(1,y{:}); end
  freqlen=length(freqvect);
  expno=length(x)/freqlen;
  if iscell(vdat), vdat=cat(1,vdat{:}); end
  %Correct for new definition:
  if isempty(expi), expi=[1:expno]; end
elseif ~strcmp(lcext,'fbn')&( isstr(Fdat)|(size(Fdat,2)==1) ) %vector or ASCII file
  if isstr(Fdat)
    Fdat=loadasc(filename,ASCIItype);
    if length(Fdat)<11, error(['Not enough data in file ',filename]), end
  else
    if length(Fdat)<11, error('Not enough data in Fourier vector'), end
  end
  inputno=Fdat(1); outputno=Fdat(2);
  lno=2*inputno+2*outputno+1; %numbers in a line
  expno=Fdat(3); %Number of experiments
  if (nargin<2)|(length(expi)==0), expi=[1:expno]; end
  if max(expi)>expno
    error(['Desired experiment does not exist in file ',filename])
  end
  freqlen=Fdat(4); %Number of frequencies
  f1=Fdat(5); %Start frequency
  fn=Fdat(6); %Stop frequency
  if isstr(Fdat), fnstr=[' (file ',filename,')']; else fnstr=''; end
  nodati=[sprintf(['Number of data is incorrect in Fdat ',...
      fnstr,':\n%.0f'],length(Fdat)),...
      sprintf(' instead of %.0f*(%.0f*%0.f+1)+6=',expno,freqlen,lno),...
      sprintf('%.0f',expno*(freqlen*lno+1)+6)];
  if length(Fdat)~=6+expno*(lno*freqlen+1),
    if expno==1
      disp(['Warning! ',nodati]), Fdat=Fdat(1:6+expno*(lno*freqlen+1));
    else
      error(nodati)
    end
  end
  freqind=lno*[0:freqlen-1]'; freqvect=Fdat(8+freqind);
  for fi=1:expno-1
    freqi=Fdat(8+fi*(lno*freqlen+1)+freqind);
    if any(freqi-freqvect)
      error('Frequencies differ in experiments')
    end
  end
  if f1~=min(freqvect),
    disp('fmin is not equal to minimum of the frequency vector')
  end
  if fn~=max(freqvect),
    disp('fmax is not equal to maximum of the frequency vector')
  end
  if any(Fdat([7:(lno*freqlen+1):length(Fdat)])-[1:expno]')
    disp('Experiment numbers are not equal to [1:expno]')
  end
  rind1=9+[0:lno:lno*(freqlen-1)]';
  rind=rind1;
  for ei=1:expno-1
    rind=[rind;rind1+ei*(lno*freqlen+1)];
  end
  x=[];
  for ii=0:inputno-1
    x=[x,Fdat(rind+2*ii)+j*Fdat(rind+2*ii+1)];
  end
  rind=rind+2*inputno;
  y=[];
  for ii=0:outputno-1
    y=[y,Fdat(rind+2*ii)+j*Fdat(rind+2*ii+1)];
  end
elseif strcmp(lcext,'fbn') %binary file
  load(filename,'-mat'),
  if length(expi)==0, expi=[1:expno]; end
  if max(expi)>expno
    error(['Desired ',int2str(max(expi)),...
           '. experiment does not exist in file ',filename])
  end
  freqlen=length(freqvect);
  if ~isempty(vdat)
    try, [vx,vy,cxy]=impvar(vdat); vdatOK=1; catch, vdatOK=0; end
    if vdatOK==0
      vdat=[];
      disp('Warning! Invalid vdat found in impfou')
    end
  end
else %array
  expno=1;
  if length(expi)==0, expi=[1:expno]; end
  if max(expi)>expno
    error(['Desired ',int2str(max(expi)),...
           '. experiment cannot be taken from array'])
  end
  freqvect=Fdat(:,1); freqlen=length(freqvect);
  x=Fdat(:,2); y=Fdat(:,3);
end
%if any(freqvect<0)
%  error('Negative value in frequency vector')
%end
%Select desired experiments
if ~isequal(sort(expi(:)'),[1:expno])
  ind1=[1:freqlen]'; indi=[];
  for ii=expi(:)'
    indi=[indi;ind1+(ii-1)*freqlen];
  end
  if ~isempty(x)
    if isnumeric(x) 
      if size(x,3)>1, x=x(:); end
      x=x(:,indi);
    elseif iscell(x)
      x=x(:,indi);
    end
  end
  if ~isempty(y)
    if isnumeric(y) 
      if size(y,3)>1, y=y(:); end
      y=y(:,indi);
    elseif iscell(y)
      y=y(:,indi);
    end
  end
end
expt=int2str(expi(1));
if length(expi)==2, expt=[expt,sprintf(',%.0f',expi(2))]; end
if length(expi)>2, expt=[expt,'...',int2str(max(expi))]; end
if ~strcmp(eim,'no')&~isempty(lcext)
  fprintf(['   Experiment: ',expt,','])
  fprintf(' frequencies: %.0f, from %.3e to %.3e Hz\n',...
          freqlen,min(freqvect),max(freqvect))
  sbno=length(find((x(:,1)==0)&(y(:,1)==0)))/length(expi);
  if sbno>0, fprintf('   Stopband (0/0): %.0f frequency point(s)\n',sbno), end
end
%
if (length(comments)>0)&~strcmp(eim,'no')&~isempty(lcext)
  disp(['   Comments: ',comments])
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of impfou %%%%%%%%%%%%%%%%%%%%%%%%%
