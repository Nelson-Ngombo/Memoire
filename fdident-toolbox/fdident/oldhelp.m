function message = oldhelp(mfile,opt)
%OLDHELP MFILE  displays the help on the old call form of fdident functions

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1996-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Dec-2000

if nargin==0, mfile=''; end
if nargin<2, opt=''; end
if isempty(mfile)
  help oldhelp
  return
elseif isempty(opt)&any(strmatch(mfile,...
    {'crestmin'}))
  %Just <funcname> oldhelp
  feval(mfile,'oldhelp')
  return
end
if isstr(mfile)&(length(mfile)>0)&isstr(opt)&(length(opt)>0)&~strcmpi(opt,'date')
  %help with option
  eval([mfile,' ',opt])
  return
end
mfilein=mfile;
perpos=find(mfile=='.');
if isempty(perpos), mfile=[mfile,'.m']; end
perpos=find(mfile=='.');
mfname=mfile(1:perpos(1)-1);
clear perpos
%
mfline=which(mfile);
if isempty(mfline)&isdir(mfilein)
  if strcmp(mfilein(end),filesep)|strcmp(mfilein(end),'\')|...
      strcmp(mfilein(end),'/')
    %mfilein(end)='';
  else
    mfilein=[mfilein,filsesep];
  end
  type([mfilein,'Contents.m'])
  return
end
if isempty(findstr(['fdident',filesep,'fdident',filesep,lower(mfile)],lower(mfline))) &...
    isempty(findstr(['fdident',filesep,'fddemos',filesep,lower(mfile)],lower(mfline))) &...
    isempty(findstr([filesep,'fd',filesep,lower(mfile)],lower(mfline))) &...
    isempty(findstr([filesep,'fdd',filesep,lower(mfile)],lower(mfline))) & ...
    ~strcmpi(opt,'date')
  if isempty(mfline), error(['Not fdident M-file: ',mfile]), end
  error(['Not fdident M-file: ',mfline])
end
%
[fid,errmess]=fopen(mfile,'r');
if fid==-1
  if exist(mfname)==5
    messagei=[mfname,' is a built-in function, no M-file available'];
    disp(messagei)
    if nargout>0, message=messagei; end
    help(mfile)
    return
  elseif exist(mfname)==1
    if strcmp(mfname,'mfile')|strcmp(mfname,'mfname')|...
        strcmp(mfname,'nargin')|strcmp(mfname,'nargout')|...
        strcmp(mfname,'fid')|strcmp(mfname,'errmess')
      messagei=['File ',mfile,': ',errmess];
    else
      messagei=[mfname,' is a built-in variable, no help M-file available'];
    end
    disp(messagei)
    if nargout>0, message=messagei; end
    return
  elseif exist(mfname)==0
    c=computer;
    pathsep = ':'; %Unixpath separator character
    dirsep = '/'; %Unix directory separator character
    if strcmp(c(1:2),'PC')
      pathsep = ';'; dirsep = '\';
    elseif strcmp(c(1:2),'MA')
      pathsep = ';'; dirsep = ':';
    elseif strncmp(version,'5.',2)
      if isvms pathsep = ','; dirsep='.'; end
    end
    ps=[pathsep,path,pathsep];
    ind=find(ps==pathsep);
    dirfound=0;
    for i=2:length(ind)
      if ind(i)>length(mfname)
        if strcmp(ps(ind(i)-[length(mfname):-1:1]),mfname)
          dirfound=1;
          break
        end
      end
    end %for i
    if dirfound==1
      messagei=[mfname,' is not an M-file, it is a directory:',sprintf('\n'),...
          ps(ind(i-1)+1:ind(i)-1)];
    else
      messagei=[mfname,' does not exist in workspace of function OLDHELP'];
    end
    disp(messagei)
    if nargout>0, message=messagei; end
    return
  end
  disp(errmess)
  if nargout>0, message=str2mat(message,errmess); end
  return
end
%
filestr=fread(fid); fclose(fid);
filestr=setstr(filestr');
lfstr=length(filestr);
if lfstr==0, error(['File ',mfile,' is empty']), end
if strcmpi(mfname,'elis'), scanlen=14000;
else scanlen=7000;
end
filestrsh=filestr(1:min(scanlen,length(filestr)));
indcr=[find((filestrsh==13)|(filestrsh==10)),length(filestrsh)+1]; %cr or lf
helpbegind=1; %index of first character of help to scan for call forms
helpendind=0; %index of last character of help to scan for call forms
if strcmpi(opt,'date')
  %Look for the file 'Last modified:'
  ind=findstr('last modified:',lower(filestrsh)); fmod=15;
  if length(ind)>1, ind=ind(1); end
  if isempty(ind), ind=findstr('modified:',lower(filestrsh)); fmod=10; end
  if length(ind)>1, ind=ind(1); end
  if isempty(ind), ind=findstr('date:',lower(filestrsh)); fmod=6; end
  if length(ind)>1, ind=ind(1); end
  if ~isempty(ind)
    %ind=ind+fmod;
    indind=min(find(indcr>ind));
    inde=indcr(indind)-1;
    dstr=filestrsh(ind:inde);
    indd=find(dstr=='$'); if ~isempty(indd), dstr(indd)=''; end
    disp(dstr);
  end
  return
end
%
%We will look for the word '%' and 'function' or 'Old fdident help' as string
%We will also explore here the beginning and end of the help text
firstchar=findstr(filestrsh,['%','function']); %Different old version definition
if isempty(firstchar), firstchar=findstr(filestrsh,['%','Old fdident help']); end
nfdstr=['%','Old fdident help: same as now'];
if ~isempty(firstchar)&strcmp(filestrsh(firstchar(1)+[0:length(nfdstr)-1]),nfdstr)
  help(mfile), return
elseif ~isempty(firstchar)
  firstchar=firstchar(1);
else
  %disp(' ')
  %disp('Warning: Modified fdident help not found, regular help is invoked')
  help(mfile), return
end
%
fhc=min(find(filestrsh(firstchar+2:length(filestrsh))=='%'));
nextchi=firstchar+1+fhc; %first 'hidden' help character: % sign
fhc=nextchi;
%
nch=filestrsh(nextchi); cri=1; stopsig=0; inhelp=1; funfound=-1;
commentline=1;
while stopsig==0
  if ( (nch==' ') | ((nch>=9)&(nch<=13)) ) %blank character
    commentline=commentline-1;
    if (inhelp==1)&(commentline<=0), inhelp=0; helpendind=nextchi-1; end
    nextchi=nextchi+1;
    if nextchi<=lfstr
      if (nch==13)&(filestrsh(nextchi)==10) %cr-lf on PC
        nextchi=nextchi+1;
      end
    end
  elseif nch=='%'
    if helpbegind==1, helpbegind=nextchi+1; inhelp=1; end
    nextchi=indcr(min(find(indcr>nextchi)));
    commentline=2;
  else %general character, cycle has to stop
    stopsig=1;
  end
  %Prepare next cycle
  if (nextchi>length(filestrsh)-400)&(length(filestrsh)<length(filestr))
    filestrsh=filestr;
    indcr=[find((filestrsh==13)|(filestrsh==10)),length(filestrsh)+1]; %cr or lf
  end
  if nextchi<=lfstr
    nch=filestrsh(nextchi);
  else
    stopsig=1;
  end
end %while
if inhelp==1, helpendind=nextchi-1; end
%
helptext=filestrsh(fhc+1:helpendind);
if length(helptext)>1;
  ind=findstr(helptext,setstr([13,10]));
  for ii=length(ind):-1:1, helptext(ind(ii))=''; end
end
ind=[findstr(helptext,[setstr(13),'%']),findstr(helptext,[setstr(10),'%'])];
for ii=length(ind):-1:1, helptext(ind(ii)+[0,1])='\n'; end
ind=findstr(helptext,'%');
for ii=length(ind):-1:1
  helptext=[helptext(1:ind(ii)),helptext(ind(ii):length(helptext))];
end
fprintf(['\n',helptext,'\n'])
%
ci=findstr('Copyright',filestrsh);
bci=max(find(filestrsh(1:ci(1))=='%')); %begin index of copyright string
yi=min(findstr('odified',filestrsh(bci+1:length(filestrsh))))+bci;
if isempty(bci), return, end
eci=min([find(filestrsh(yi+[0:min(length(filestrsh)-yi,80)])==setstr(13)),...
    find(filestrsh(yi+[0:min(length(filestrsh)-yi,80)])==setstr(10))])+yi-2;
ctext=filestrsh(bci:eci);
%
ctextm=ctext;
%Fix strange bug
eol=find((ctext==setstr(13))|(ctext==setstr(10)));
for ii=1:length(eol)
  if ii==1, ctextm=ctext(1:eol(1)-1); cti=eol(1)+1;
  else
    if eol(ii)>eol(ii-1)+1
      ctextm=[ctextm,sprintf('\n'),ctext(cti:eol(ii)-1)]; cti=eol(ii)+1;
    else
      cti=cti+1;
    end
  end
end %for
if cti<=length(ctext), ctextm=[ctextm,sprintf('\n'),ctext(cti:length(ctext))]; end
ind=find(ctextm=='%');
ctextm(ind)='';
%disp(ctextm) %display copyright info
%
%End of oldhelp
