function [uniqueflag,msg]=fdunique(palso)
%FDUNIQUE  Check all fdident M-files and MAT-files for uniqueness
%
%       fdunique(palso) makes modified check:
%       If palso==1, then the M-files are matched also to P-files
%       If palso==2, then only warnings will be shown.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jun-2003, IK

%Preparations
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(0,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(0,1,ni)), %earlier
end
if nargin<1, palso=[]; end, if isempty(palso), palso=0; end
if strcmp(palso,'2'), palso=2;
elseif strcmp(palso,'1'), palso=1;
end
if palso==1
  %disp('')
  %disp('fdunique spec: error out also if concurring P-file and M-file found')
elseif palso==2
  %disp('')
  %disp('fdunique spec: send warning if concurring P-file and M-file found')
elseif palso==0;
else 
  error('palso is improper')
end
%
unf=1; %internal initial value of first output
msg=''; %initial value of second output

%First check uniqueness of object creators and class directories
crs={'tiddata','fiddata','iddat','fidmodel'};
%First look for class directories
p=path;
if p(1)==pathsep, p(1)=''; end, if p(end)==pathsep, p(end)=''; end
p=[pathsep,p,pathsep];
ind=find(p==pathsep);
clmarker='@'; %class directory marker
if strncmp(version,'5.',2), if isvms, clmarker='#'; end, end
for cn=crs %scan all creators
  dno=0; %number of class directories with the same name
  dlist={}; %list of same name class directories
  for ii=2:length(ind)
    dn=p(ind(ii-1)+1:ind(ii)-1); %individual directories
    dc=dir([dn,filesep,clmarker,cn{1}]); %contents of class directory on path
    if length(dc)>0
      dlist=[dlist;{[dn,filesep,clmarker,cn{1}]}];
      dno=dno+1; %a class directory found
      for iii=1:length(dc)
        if dc(iii).bytes>10 %nonempty file
          %Here check if the file is only once on the path
          %The problem is that we do not know if the current directory
          %is on the path or not.
          if strcmpi(dc(iii).name(end-[1,0]),'.m') %M-file
            wdci=which([clmarker,cn{1},filesep,dc(iii).name(1:end-2)],'-all');
            if length(wdci)==2
              %Maybe M-P pair?
              if strcmpi(wdci{1}(1:end-1),wdci{2}(1:end-1))&...
                  any(wdci{1}(end)=='mMpP')&any(wdci{2}(end)=='mMpP')&...
                  ~strcmpi(wdci{1}(end),wdci{2}(end))
                %yes, pair
                if palso==2
                  disp(wdci)
                  warning('P-file and M-file creators in the same directory')
                  wdci=[];
                elseif palso==1 %error, let us leave as it is
                else %don't care
                  wdci=[];
                end
              end
            end %2 found
            if length(wdci)>1
              disp(wdci)
              unf=0;
              msg='Class function is repeated on the path';
              break
            end
          end
        end
      end %for iii
    end
    if unf==0, break, end
  end %for ii
  if dno>1 %more than one class directories with the same name
    disp(dlist)
    msg=['Class directory ''',clmarker,cn{1},''' is repeated on path'];
    unf=0;
    break
  end
  if unf==0, break, end
end %for cn
%
if exist('corrtest')
  %Toolbox version 3.0 or later
  for ii=1:length(crs)
    crn=crs{ii};
    w=which([filesep,crn]); %Creator must be found
    if isempty(w), error(['Creator ''',crn,''' is not found']), end
    cm='@'; %class marker
    if strncmp(version,'5.',2), if isvms, cm='#'; end, end
    wokend=[cm,crn,filesep,crn,'.m']; l=length(wokend);
    ind=findstr(wokend(1:end-1),lower(w(1:end-1)));
    if isempty(ind)
      error(['Class creator name end was incorrectly generated: ',wokend])
    end
    ind=ind(end);
    if ind~=length(w)-l+1
      disp(w)
      error('This is not an object creator:')
    end
    wa=which(crn,'-all');
    if length(wa)==2
      if strcmp(wa{1}(1:end-1),wa{2}(1:end-1))
        %P and M-files with the same name in the same directory
        if palso==2
          disp(wa)
          warning('P and M-files in the same directory')
        elseif palso==1
          disp(wa)
          msg='P and M-files in the same directory';
          unf=0;
          break
        end
      else
        %something more strange
        for iii=2:length(wa)
          if any(findstr(lower(wa{iii}),[filesep,cm,crn,filesep,crn,'.m']))
            %it is a problem if the same class directory name repeats,
            disp(['Shadowed creator file'])
            disp(['  Used: ',wa{1}])
            disp(['  Shadowed: ',wa{iii}])
            msg='Redefinition of creator file';
            unf=0;
            break
          elseif ~any(findstr(lower(wa{iii}),[filesep,cm]))
            %but it is no problem if a creator name repeats in other class directories
            disp(['Warning: Shadowed executable file:'])
            disp(['  ',wa{iii}])
          end
        end %for iii
      end
    end
    if unf==0, break, end
  end
end %for ii
%Classes and creators OK
%
%Scan fdident directories
fdtpathall={};
mainnameall={'elis.m','fdiddemo.m'};
if exist('testfd.m'), mainnameall=[mainnameall,{'testfd.m'}]; end 
if exist('corrtest.m')
  mainnameall=[mainnameall,{'fdtool.m','aluplate.mat'}]; %files from all possible dirs
  elp=which('elis.m');
  elqp=which('elisqa.m');
  if strcmp(elp(1:end-6),elqp(1:end-8))
    mainnameall=[mainnameall,{'orthopol.m','fddgui1.m','fdtlogo.mat'}];
  end
  e=which('elis');
  p=which('ploteltf');
  if ~ischar(e)|isempty(e)|~ischar(p)|isempty(p)
    error('Something is wrong with elis or with ploteltf')
  end
  if ~strcmp(e(1:end-6),p(1:end-10))
    %elis is in a separate directory, its private does not need to be checked
    mainnameall(end)=[]; %eliminate orthopol ???
  end
end
for mainname=mainnameall
  if unf==0, break, end %Return immediately, earlier error
  mainname=mainname{1}; %make string from cell
  %
  indmnd=find(mainname=='.');
  ext=mainname(indmnd+1:end);
  if strcmp(ext,'mat')
    fdt=which(mainname,'-all');
  else
    fdt=which(mainname(1:indmnd-1),'-all');
  end
  if isempty(fdt) %main file not found, something fishy
    unf=0; break
  else %something found
    fdt1=fdt{1}; %first file found
    ind=findstr(lower(fdt1),mainname(1:indmnd));
    newpath=fdt1(1:ind(end)-2);
    %Now eliminate repeated files in the same folder (*.m and *.p etc)
    for ii=length(fdt):-1:2
      ind=find(fdt1=='.');
      fdtii=fdt{ii};
      indii=find(fdtii=='.');
      if strcmpi(fdt1(1:ind(end)),fdtii(1:indii(end)))
        fdt(ii)='';
      end
    end
    if length(fdt)>1
      if length(newpath)>35, msg2line=1; else msg2line=0; end
      if msg2line==1
        disp(['Testing path ''',newpath,''''])
        disp(['   for uniqueness of ',upper(ext),'-files'])
      else
        disp(['Testing path ''',newpath,''' for uniqueness of ',...
            upper(ext),'-files'])
      end
      %disp(fdt)
      %disp(' ')
      msg=[{['''',mainname,''' is repeated on the path']};fdt];
      unf=0;
      break
    end
    done=0;
    for ii=1:size(fdtpathall,1)
      if strcmpi(fdtpathall{ii,1},newpath)&strcmpi(fdtpathall{ii,2},ext)
        done=1; break
      end
    end
  end
  if done==0
    %Not examined yet
    fdtpathall=[fdtpathall;{newpath,ext}];
    fdtpath=newpath;
    if length(newpath)>35, msg2line=1; else msg2line=0; end
    if msg2line==1
      disp(['Testing path ''',newpath,''''])
      disp(['   for uniqueness of ',upper(ext),'-files'])
    else
      disp(['Testing path ''',newpath,''' for uniqueness of ',...
          upper(ext),'-files'])
    end
    %Now make a list of the whole directory
    fdir=dir([fdtpath,filesep,'*.',ext]);
    for ii=1:length(fdir) %all files in directory
      name=fdir(ii).name; 
      dothisfile=1;
      if strcmpi(name,'demos.m')|strcmpi(name,'contents.m')...
          |strcmpi(name,'readme.m')
        dothisfile=0; %These are unimportant repetitions
      elseif strcmpi(name,'robotarm.mat')
        alupl=which('aluplate.mat');
        rarm=which('robotarm.mat');
        if strcmpi(alupl(1:end-12),rarm(1:end-12))
          %dothisfile=0; %robotarm.mat together with aluplate.mat
        end
      end
      if dothisfile
        ind=findstr(lower(name),'.m'); name0=name(1:ind(1)-1);
        nex0=exist(name0);
        if nex0==1 %variable, unfortunately
          nm0=which(name0,'-all');
          for iii=1:length(nm0)
            exc=exist(nm0{iii});
            if exc>nex0, nex0=exc; end %artificial exist
          end
        elseif strcmp(lower(ext),'mat')&(nex0>2)
          nex0=exist([name0,'.mat']); %for MAT-files, only coincidence with MAT-files is important
        end
        %
        nm0=which(name0,'-all');
        exf=0; %number of files with this name
        if nex0==7 %directory, unfortunately
          namept=[filesep,name0,'.'];
          for inm0=length(nm0):-1:1
            if any(findstr(nm0{inm0},namept))
              exf=exf+1;
            else
              nm0(inm0)=[];
            end
          end
        end
        if (3<=nex0)&(nex0<=5)&~strcmp(name0,'siglab')
          %MEX, MDL, built-in
          msg=sprintf(['exist returns %.0f for which(''',name0,''')'],nex0);
          unf=0;
          break
        elseif ((nex0==6)|(exf>1)) %P-file
          for fi=2:length(nm0)
            %now check if two files with the same extension appear
            if strcmpi(nm0{1}(end-[1,0]),nm0{fi}(end-[1,0]))&...
                ~any(findstr(nm0{1},clmarker))&~any(findstr(nm0{1},clmarker))
              %last two characters are equal
              disp(nm0)
              msg='Two files of the same extension';
              unf=0;
              break
            end
          end
          if palso>=2
            disp(['Warning:  Executable file exists before M-file for ''',name0,''''])
            disp(nm0)
          elseif palso==1
            disp(nm0)
            msg=['Executable file shadows M-file ''',name,''''];
            unf=0;
            break
          end
        end
        %
        nm=which(name,'-all');
        for inm=length(nm):-1:1
          %eliminate current directory:
          if ~any(findstr(nm{inm},filesep)), nm(inm)=[]; end
          %eliminate class directories:
          clmarker='@';
          if strncmp(version,'5.',2), if isvms, clmarker='#'; end, end
          if (length(nm)>=inm)&any(findstr(nm{inm},[filesep,clmarker]))
            nm(inm)=[]; %file in class directory
          end
          %eliminate private directories:
          if (length(nm)>=inm)&...
              any(findstr([nm{inm},pathsep],[filesep,'private',filesep,name,pathsep]))
            nm(inm)=[];
          end
        end %for inm
        if length(nm)>1
          fwh1=[newpath,filesep,name];
          fwh2=[newpath,filesep,'private',filesep,name];
          ifd=0;
          for ic=1:length(nm)
            if strcmpi(nm{ic},fwh1), ifd=ifd+1; end
            if strcmpi(nm{ic},fwh2), ifd=ifd+1; end
          end
          if ifd<=1
            warning(['File ''',name,''' shadows another file:'])
            if iscell(nm)
              for ic=1:length(nm), disp(['  ',nm{ic}]), end
            else
              disp(['  ',nm])
            end
            unf=0;
          else
            msg=[{['Shadowed file ''',name,''' ']};nm];
            unf=0;
            break
          end
        end
      end %dothisfile
      %
      %Special test for private directories
      %if any(findstr('sme.',name)), keyboard, end %test
      %if exist([fdtpath,filesep,'private',filesep,name])
      %  msg={['File in private directory shadows file ''',name,''':'];...
      %      ['  ',fdtpath,filesep,'private',filesep,name];...
      %      ['  ',fdtpath,filesep,name]};
      %  unf=0;
      %  break
      %end
    end %for ii
  end
end
%
if unf==0
  %Error found
  if ~iscell(msg), msg={msg}; end
  fdpathfr=[filesep,'fdident',filesep];
  otherp=0;
  for ii=2:length(msg)
    if any(findstr(fdpathfr,lower(msg{ii}))), otherp=otherp+1; end
  end %for ii
  if otherp>0 %Repetition of unknown origin
    msg=[msg;{'';'Repetition of unknown origin:';...
          '  are you sure that another version of the toolbox is not there?';...
          '  In trouble contact the developers by email at fdident@vub.ac.be'}];
    if (length(msg)>1)|~isempty(msg{1})
      if ~any(findstr([filesep,'private',filesep],cat(2,msg{:})))
        msg=[msg;{'Delete older fdident file or ';...
              '  remove its directory from the path'}];
      else %private
        msg=[msg;{'';'Delete shadowed (non-private) fdident file'}];
      end
    else
      if nargout==0
        disp(msg)
      end
    end
  end
end
%
if unf==1
  disp('Good news: no name clashes found')
end
%
if ~exist('fdguitst.m')
  unf=0;
  dmsg='Error: Directory fddemos with demonstration files not found.';
  disp(dmsg)
  msg=[msg;{dmsg}];
end
if nargout>0, uniqueflag=unf; end
%
%End of fdunique
