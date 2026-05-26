function message = usage(mfile)
%USAGE MFILE  displays the call form(s) of a function with all i/o arguments.
%
%MESSAGE = USAGE(MFILE)  also returns the information in the string MESSAGE.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Apr-2002

if nargin==0, mfile=''; end
if isempty(mfile)
  help usage
  return
end
perpos=find(mfile=='.');
if isempty(perpos), mfile=[mfile,'.m']; end
perpos=find(mfile=='.');
mfname=mfile(1:perpos(1)-1);
clear perpos
%
ffn=which(mfile,'-all');
if ~isempty(ffn), ffn=ffn{1}; else ffn=''; end
[fid,errmess]=fopen(ffn,'r');
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
    pathsep = ':'; %path separator character
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
      messagei=[mfname,' does not exist in workspace of function USAGE'];
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
callforms=' '; %string array of call forms
%
%It is not easy to recognize if an M-file is a function or a script.
%We have to look for the word 'function' as first word in the first
%nonempty noncomment line.
%We will also explore here the beginning and end of the help text
nextchi=1;
nch=filestrsh(nextchi); cri=1; stopsig=0; inhelp=0; funfound=-1;
commentline=0;
%This is the clue for the old fdident help
indofd=findstr(filestrsh,[setstr(10),'%','Old fdident help']);
if ~isempty(indofd)
   minnextchi=indofd(1);
else
  indofd=findstr(filestrsh,[setstr(13),'%','Old fdident help']);
  if ~isempty(indofd), minnextchi=indofd(1); else minnextchi=0; end
end
while stopsig==0
  if ( (nch==' ') | ((nch>=9)&(nch<=13)) ) %blank character
    commentline=commentline-1;
    if nextchi>minnextchi
      if (inhelp==1)&(commentline<=0), inhelp=0; helpendind=nextchi-1; end
    end
    nextchi=nextchi+1;
    if nextchi<=lfstr
      if (nch==13)&(filestrsh(nextchi)==10) %cr-lf on PC
        nextchi=nextchi+1;
      end
    end
  elseif nch=='%'
    %At start, skip the first line with %name
    if helpbegind==1, helpbegind=nextchi+2; inhelp=1; end
    nextchi=indcr(min(find(indcr>nextchi)));
    commentline=2;
  elseif (nch=='f')&(funfound==-1) %this could be the function definition
    commentline=0;
    if inhelp==1, helpendind=nextchi-1; end
    inhelp=0;
    if lfstr>nextchi+9
      if strcmp(filestrsh(nextchi+[0:7]),'function')
        funfound=1; funbeg=nextchi+9;
        %Look for end of function definition, first look for '...'
        beglin=funbeg; indcri=min(find(indcr>=beglin));
        funend=indcr(indcri)-1;
        if (indcri>=length(indcr)-10)&(length(filestrsh)<length(filestr))
          filestrsh=filestr;
          indcr=[find((filestrsh==13)|(filestrsh==10)),length(filestrsh)+1];
        end
        for i=1:5 %maximum 5 continuing lines
          indp=find(filestrsh(beglin:indcr(indcri)-1)=='.');
          for ii=indp
            if beglin+ii-1>lfstr-2, break, end
            if strcmp('...',filestrsh(beglin+ii-1+[0:2]))
              beglin=indcr(indcri)+1;
              indcri=indcri+1;
              if (filestrsh(indcr(indcri-1))==13)&(filestrsh(indcr(indcri))==10)
                %cr-lf pair (PC)
                indcri=indcri+1; beglin=beglin+1;
              end
              funend=indcr(indcri)-1;
            end
          end %for ii
        end %for i
        callforms=str2mat([filestrsh(funbeg:funend),';'],callforms);
        nextchi=funend+1;
        if helpbegind<=helpendind, stopsig=1; end
      else %not 'function': this is not a function definition
        funfound=0;
        indcri=min(find(indcr>=nextchi));
        nextchi=indcri;
      end
    else
      funfound=0;
    end
    if funfound==0, stopsig=1; end
  elseif nextchi>minnextchi %general character, cycle has to stop
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
%Temporary extension until % + function
ofi=min(findstr(['%','function'],filestrsh))+100;
if ~isempty(ofi), helpendind=ofi; end
%
if funfound<1 %Script M-file
  if exist(mfname)==5 %built-in function, go ahead to scan full help
  elseif exist(mfname)==1 %built-in variable, execute help
    messagei=[mfname,' is a built-in variable, help is invoked'];
    disp(messagei)
    if nargout>0, message=messagei; end
    help(mfname)
    return
  else %regular script M-file, execute help
    messagei1=[mfile,' is a script M-file'];
    messagei2=[sprintf('\n'),filestrsh(2:indcr(1)-1)];
    if nargout>0, message=[messagei1,messagei2]; end
    disp(messagei1)
    fprintf('Help text:'), help(mfile)
    return
  end
end
%
%Function (maybe built-in function with script help)
%Get help header from file
helpstr=filestrsh(helpbegind:helpendind); %This is the help part
%oldhelpind=helpbegind-minnextchi; %beginning of old help in help string
if funfound==1
  %Execute this if you don't want to scan help text
  %helpstr='';
end
%
lhs=lower(helpstr);
mfi=find(lower(mfname(1))==lhs(1:length(lhs)-length(mfname)+1));
%first letter coincides
%
if length(mfname)>1
  if ~isempty(mfi)
    mfii=find(lower(mfname(2))==lhs(mfi+1));
    mfi=mfi(mfii);
  end
  if ~isempty(mfi)
    nstrind=[0:length(mfname)-1]'; mfnamev=lower(mfname');
    namarr=reshape(lhs(mfi(ones(length(mfname),1),:)+...
        nstrind(:,ones(size(mfi)))),length(mfname),length(mfi));
    mfii=find(all(namarr==mfnamev(:,ones(size(mfi)))));
    mfi=mfi(mfii);
  end
end
%
%Now mfi points to all occurrences of the function name
%Explore inputs and outputs
notyetaddo=1;
for i=1:length(mfi)
  callibeg=mfi(i); calliend=mfi(i)+length(mfname)-1;
  %if i==1, callforms=str2mat(callforms,helpstr(callibeg:calliend)); end
  if callibeg>2 %possible output argument
    cbeg=callibeg;
    chb=helpstr(cbeg-1);
    while (cbeg>=3)&((chb==' ')|((chb>=9)&(chb<=13))) %blank
      cbeg=cbeg-1; chb=lower(helpstr(cbeg-1));
    end
    if chb=='=' %output argument(s)
      cbeg=cbeg-1; chb=helpstr(cbeg-1);
      while (cbeg>=2)&((chb==' ')|((chb>=9)&(chb<=13))) %blank
        cbeg=cbeg-1; chb=lower(helpstr(cbeg-1));
      end
      if chb==']' %multiple output arguments
        bri=find(helpstr=='[');
        brii=bri(max(find(bri<cbeg-1)));
        if isempty(brii),
          error(['Unmatched ] in help text of file ',mfile,...
                sprintf('\n'),helpstr])
        end
        callibeg=brii;
      else %one  output argument
        while (cbeg>=2)&( ...
                ((chb>='a')&(chb<='z')) | ((chb>='A')&(chb<='Z')) |...
                ((chb>='0')&(chb<='9')) | (chb=='_') )
          %Letter or underscore
          cbeg=cbeg-1; chb=lower(helpstr(cbeg-1));
        end
        callibeg=cbeg;
      end
    end
  end %callibeg>2
  %
  if calliend<=length(helpstr)-3 %possible input arguments
    cend=calliend;
    if helpstr(cend+1)=='('
      pai=find(helpstr==')');
      paii=pai(min(find(pai>cend+1)));
      if isempty(paii)
        error(['Unmatched ( in help text of file ',mfile,sprintf('\n'),helpstr])
      end
      calliend=paii;
    end
  end
  calli=helpstr(callibeg:calliend);
  ind=find([calli,'*']==':'); if ~isempty(ind), calli=''; end %improper call
  ind=find([calli,'*']==']'); if length(ind)>1, calli=''; end %improper call
  ind=find([calli,'*']=='('); if length(ind)>1, calli=''; end %improper call
  ind=find([calli,'*']=='='); if length(ind)>1, calli=''; end %improper call
  if ~any(findstr('varargin',calli))&~any((findstr('varargout',calli)))&...
      ~strcmp(calli,upper(mfname)) %exclude upper-case mentioning
    if ~isempty(indofd)
      if i==1
        callforms=str2mat(callforms,'*** New call forms: ***');
      end
      if (mfi(i)>indofd)&notyetaddo
        callforms=str2mat(callforms,'*** Old call forms: ***');
        notyetaddo=0;
      end
    end
    callforms=str2mat(callforms,calli);
  end
end %for i
%delete empty lines in callforms:
ind=find(all(callforms'==' ')); callforms(ind,:)='';
%
%Now repeated information will be eliminated
lcf=' '; %string array of all the call forms
for i=1:size(callforms,1)
  cfi=lower(deblank(callforms(i,:)));
  if cfi(length(cfi))==')', cfi(length(cfi))=''; end %allow continuation
  ieq=find(cfi=='=');
  if length(ieq)==1
    if cfi(ieq+1)==' ', cfi(ieq+1)=''; end
    if cfi(ieq-1)==' ', cfi(ieq-1)=''; end
  end
  lcf=str2mat(lcf,cfi);
end
lcf(1,:)='';
%
mfonly=0; %function name only
for i=size(lcf,1):-1:1
  try, findstr('a','a');
  catch, disp('findstr not found, time to upgrade your Matlab'), break
  end
  cfi=deblank(lcf(i,:));
  for ii=1:size(lcf,1)
    cfii=deblank(lcf(ii,:));
    ind=findstr(cfi,cfii);
    if ~isempty(ind)&(i~=ii)&(length(cfi)<=length(cfii))&~strcmpi(cfi,mfname)
      callforms(i,:)=''; lcf(i,:)=setstr(32*ones(1,size(lcf,2)));
      break
    end
    if strcmp(cfi,mfname)
      if mfonly>0
        callforms(i,:)=''; lcf(i,:)=setstr(32*ones(1,size(lcf,2)));
        break
      end
      mfonly=mfonly+1;
    end
  end %for ii
end %for i
%
mfonly=0; %mark if it is only the function name that is got in callforms
if size(callforms,1)==1
  if strcmp(lower(mfname),deblank(lower(callforms(1,:))))
    mfonly=1;
  end
end
if isempty(callforms)|mfonly
  if exist(mfname)==5
    disp([mfname,' is a built-in function'])
  end
  messagei='No clue found to function call, help is invoked';
  disp(messagei)
  help(mfname)
  return
else
  messagei=callforms;
  if strncmpi(computer,'PCWIN',5)&(length(sprintf('\n'))==1)
    %Delete CR's from PC strings
    for ii=1:size(messagei,1)
      ind=findstr(messagei(ii,:),setstr([13,10]));
      if ~isempty(ind)
        messagei(ii,ind)=setstr(ones(size(ind))*' ');
      end
    end
  end
  if (funfound==1)&(size(messagei,1)>1)&(1==2) %Add empty line after definition
    disp([messagei(1,:);setstr(32*ones(1,size(messagei,2)));...
        messagei(2:size(messagei,1),:)])
  else
    disp(messagei)
  end
  fs=which(mfname);
  if any(findstr(lower(fs),[filesep,'fdident',filesep,'fdident',filesep,...
        lower(mfname)]))
    if ~isempty(indofd), otxt=[', or maybe ''oldhelp ',mfname,'''']; else otxt=''; end
    disp(['  Type ''help ',mfname,'''',otxt,' for details'])
  end
end
if nargout>0, message=messagei; end
%
%End of usage
