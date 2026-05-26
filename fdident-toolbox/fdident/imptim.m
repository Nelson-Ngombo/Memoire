function [timevect,xt,yt,expno,fv,vdat,comments,fdate]=imptim(tdat,expi)
%IMPTIM Read amplitudes from a time vector or file (used by ELIS).
%
%       [timevect,xt,yt,expno,fv,vdat,comments,fdate]=IMPTIM(tdat,expi)
%
%       Output arguments:
%       timevect = vector of time instants
%       xt = complex input amplitudes (column vector or array)
%       yt = complex output amplitudes (column vector or array)
%       expno = Number of experiments
%       fv = frequency vector (excited frequencies, optonal, in binary files only)
%       vdat = variance data (optional, for binary files only)
%       comments = optional, comment string in the input file (if any)
%       fdate = optional, comment string in the input file (if any)
%
%       Input arguments:
%       tdat = data vector or the name of the file, maybe an array
%           [timevect,xt,yt]; ; the data vector contains
%           the data in the same order as a .tnt file.
%       expi = number(s) of the experiment(s) to be read (integer vector)
%           optional; if omitted or empty, all the experiments will be read
%
%       The file may be an ASCII file with comments (usual extension: .tim),
%       an ASCII file without comments (.tnt), or a binary file (.tbn).
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given. Default extension: .tbn.
%       If a file is read, the most important values will be displayed on the
%       screen, unless a global variable 'expimpmessages' with value 'no' is
%       defined.
%
%       Usage: [timevect,xt,yt,expno,fv,vdat,comments,fdate]=imptim(tdat,expi);
%       Example: expvar(ones(20,1),0.1*ones(20,1),[],'data.vbn');
%                [varx,vary]=impvar('data.vbn');
%
%       See also: EXPTIM.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Mar-2001

global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
if nargin<2, expi=[]; end
comments=setstr([]); fdate=setstr([]);
fv=[]; vdat=[];
if isstr(tdat)
  [filename,dummy,ext]=fnamanal(tdat,'tbn'); lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'tbn') %binary file
    fty='binary'; ntx=[];
  else %ASCII file
    fty='ASCII';
    if strcmp(lcext,'tnt')
      ASCIItype='flat';
    else %ASCII with text
      ASCIItype='text';
    end
  end
  fty=[fty,' file ''',filename,''''];
elseif isa(tdat,'tiddata')
  fty='tiddata object'; lcext='';
else %vector in workspace
  [dl,dw]=size(tdat); if (dl==1)&(dw>3), tdat=tdat(:); end
  fty='vector in workspace';
  lcext='';
end %isstr(tdat)
if ~strcmp(eim,'no')&isstr(tdat)
  disp(['imptim loading data from ',fty])
end
if isstr(tdat)
  if ~(strcmp(lcext,'tim')|strcmp(lcext,'tnt')|strcmp(lcext,'tbn'))
    disp(['Warning! File name ext. in imptim is ''',ext,...
          ''', instead of ''tim'' or ''tnt'' or ''tbn'''])
    lcext='tim'; %ASCII file with nonstandard extension
  end
end
%
[dl,dw]=size(tdat);
if isa(tdat,'tiddata')
  timevect=tdat.samplinginstants;
  expno=tdat.expn;
  if isempty(timevect)
    timevect=[0:tdat.samplen-1]'*tdat.ts;
  end
  xt=tdat.input; yt=tdat.output;
  if tdat.expn>1
    if tdat.chn>2, error('Cannot import MIMO data from object'), end
    xtc=xt; xt=xtc{1}; ytc=yt; yt=ytc{1};
    for ii=2:tdat.expn
      xt=[xt;xtc{ii}]; yt=[yt;ytc{ii}];
    end
  end
  fv=tdat.frequencies;
  comments=tdat.notes;
  fdate=tdat.date;
  return
elseif ~strcmp(lcext,'tbn')&( isstr(tdat)|(dw==1) ) %vector or ASCII file
  if isstr(tdat)
    tdat=loadasc(filename,ASCIItype);
    if length(tdat)<11, error(['Not enough data in file ',filename]), end
  else
    if length(tdat)<11, error('Not enough data in time vector'), end
  end
  inputno=tdat(1); outputno=tdat(2);
  lno=inputno+outputno+1; %numbers in a line
  expno=tdat(3); %Number of experiments
  if (nargin<2)|(length(expi)==0), expi=[1:expno]; end
  if max(expi)>expno
    error(['Desired experiment does not exist in file ',filename])
  end
  timelen=tdat(4); %Number of time instants
  f1=tdat(5); %Start time
  fn=tdat(6); %Stop time
  if isstr(tdat), fnstr=[' (file ',filename,')']; else fnstr=''; end
  nodati=[sprintf(['Number of data is incorrect in tdat ',...
      fnstr,':\n%.0f'],length(tdat)),...
      sprintf(' instead of %.0f*(%.0f*%0.f+1)+6=',expno,timelen,lno),...
      sprintf('%.0f',expno*(timelen*lno+1)+6)];
  if length(tdat)~=6+expno*(lno*timelen+1),
    if expno==1
      disp(['Warning! ',nodati]), tdat=tdat(1:6+expno*(lno*timelen+1));
    else
      error(nodati)
    end
  end
  timeind=lno*[0:timelen-1]'; timevect=tdat(8+timeind);
  for fi=1:expno-1
    timei=tdat(8+fi*(lno*timelen+1)+timeind);
    if any(timei-timevect)
      error('Time instants differ in experiments')
    end
  end
  if f1~=min(timevect),
    disp('tmin is not equal to minimum of the time vector')
  end
  if fn~=max(timevect),
    disp('tmax is not equal to maximum of the time vector')
  end
  if any(tdat([7:(lno*timelen+1):length(tdat)])-[1:expno]')
    disp('Experiment numbers are not equal to [1:expno]')
  end
  rind1=9+[0:lno:lno*(timelen-1)]';
  rind=rind1;
  for ei=1:expno-1
    rind=[rind;rind1+ei*(lno*timelen+1)];
  end
  xt=[];
  for ii=0:inputno-1
    xt=[xt,tdat(rind+ii)];
  end
  rind=rind+inputno;
  yt=[];
  for ii=0:outputno-1
    yt=[yt,tdat(rind+ii)];
  end
elseif strcmp(lcext,'tbn') %binary file
  load(filename,'-mat'),
  if length(expi)==0, expi=[1:expno]; end
  if max(expi)>expno
    error(['Desired ',int2str(max(expi)),...
           '. experiment does not exist in file ',filename])
  end
  timelen=length(timevect);
  if exist('x')
    disp(['WARNING! Variable x instead of xt in file ',filename])
    if ~exist('xt'), xt=[]; end
    if isempty(xt), xt=x; end
  end
  if exist('y')
    disp(['WARNING! Variable y instead of yt in file ',filename])
    if ~exist('yt'), yt=[]; end
    if isempty(yt), yt=y; end
  end
  if exist('freqvect'), fv=freqvect; end
  if size(fv,2)>1, fv=fv'; end
  if size(fv,2)>1, error('freqvect is an array in the file'), end
  if ~isempty(vdat)
    try, [vx,vy,cxy]=impvar(vdat); vdatOK=1; catch, vdatOK=0; end
    if vdatOK==0
      vdat=[];
      disp('Warning! Invalid vdat found in imptim')
    end
  end
else %array
  expno=1;
  if length(expi)==0, expi=[1:expno]; end
  if max(expi)>expno
    error(['Desired ',int2str(max(expi)),...
           '. experiment cannot be taken from array'])
  end
  timevect=tdat(:,1); timelen=length(timevect);
  xt=tdat(:,2); if length(tdat(1,:))>2, yt=tdat(:,3); else yt=[]; end
end
if any(timevect<0)
  error('Negative value in time vector')
end
if any(any(imag([xt,yt])~=0)),
  error('Complex value among amplitudes')
end
if any(any(~isfinite([xt,yt]))),
  error('Infinite value among amplitudes')
end
%Select desired experiments
ind1=[1:timelen]'; indi=[];
for ii=expi
  indi=[indi;ind1+(ii-1)*timelen];
end
if ~isempty(xt), xt=xt(indi,:); end, if ~isempty(yt), yt=yt(indi,:); end
expt=int2str(expi(1));
if length(expi)==2, expt=[expt,sprintf(',%.0f',expi(2))]; end
if length(expi)>2, expt=[expt,'...',int2str(max(expi))]; end
if ~strcmp(eim,'no')&~isempty(lcext)
  fprintf(['   Experiment: ',expt,','])
  fprintf(' time instants: %.0f, from %.3e to %.3e s\n',...
          timelen,min(timevect),max(timevect))
end
%
if (length(comments)>0)&~strcmp(eim,'no')&~isempty(lcext)
  disp(['   Comments: ',comments])
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of imptim %%%%%%%%%%%%%%%%%%%%%%%%%
