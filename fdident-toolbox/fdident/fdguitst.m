function fdguitst(hno,fdtoolmode,savemode)
%FDGUITST Automatically run all fdident GUI demos and tests
%
%       Examples: fdguitst
%                 fdguitst c
%                 fdguitst c U
%           You may open the recorder beforehand in any style
%
%       function fdguitst(hno,fdtoolmode,savemode)
%       hno: this is the vector of histories to execute (optional)
%           If it is empty or missing, all histories will be executed
%         additional possibilities:
%           c continue interrupted run
%           j continue interrupted run from next demo
%           n display number of last started demo
%           l execute only the last history file
%       fdtoolmode:
%           'D' development mode
%           'M' measurement mode
%           'MD', 'DM' both
%           'U' none
%           NaN or 'NaN' or '' or [] decided by the GUI based on the governing files
%       savemode: if this is 'save', the demos will all be saved after execution
%           (automatic update)
%       The file fdguitst-<version>.mat will contain the most important messages.
%       Usage: fdguitst(hno,savemode,fdtoolmode)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Mar-2005

runmod=''; %run modifier: n, j, c, l
if nargin<1, hno=[]; end
if isstr(hno)&(length(hno)==1)&any(findstr(hno,'CJNLcjnl')), runmod=hno; hno=[]; end
%
if (nargin<2)
  fdtoolmode=NaN;
  if isstr(hno), try, eval([hno,';']), catch, fdtoolmode=upper(hno); hno=[]; end, end
elseif isempty(fdtoolmode)
  fdtoolmode=NaN;
elseif (nargin>=3)&isstr(fdtoolmode)&any(findstr(savemode,'cjnCJN'))
  tmp=savemode; savemode=fdtoolmode; fdtoolmode=tmp;
end
if isstr(fdtoolmode)&(length(fdtoolmode)==1)&any(findstr(fdtoolmode,'CJNLcjnl'))
  runmod=fdtoolmode; fdtoolmode=[]; 
end
if ~isempty(fdtoolmode)
  if isstr(fdtoolmode), fdtoolmode=upper(fdtoolmode); end
  if isstr(fdtoolmode)&~isempty(fdtoolmode)
    ind=findstr(fdtoolmode,'NAN');
    if ~isempty(ind), fdtoolmode(ind+[0:2])=''; runmod=fdtoolmode; fdtoolmode=NaN; end
    if ~isempty(fdtoolmode)
      ind=[findstr(fdtoolmode,''''''),findstr(fdtoolmode,'[]')];
      if ~isempty(ind), fdtoolmode(ind+[0:1])=''; end
    end
  end
  if isempty(fdtoolmode)
    fdtoolmode=NaN;
  end
end
if strcmpi(fdtoolmode,'U'), fdtoolmode=''; end %empty fdtoolmode codes NO development, NO M
if ( isstr(fdtoolmode)&~isempty(fdtoolmode)&~strcmp(fdtoolmode,'D')&...
    ~strcmp(fdtoolmode,'M')&~strcmp(fdtoolmode,'MD')&~strcmp(fdtoolmode,'DM') ) | ...
    ( isnumeric(fdtoolmode)&~all(isnan(fdtoolmode)) )
  error('fdtoolmode is illegal')
end
%
if nargin<3, savemode=''; end
if isstr(savemode)&(length(savemode)==1)&any(findstr(savemode,'CJNLcjnl'))
  runmod=savemode; savemode=[]; 
end
if ~isempty(savemode)&~strcmpi(savemode,'save')&~strcmpi(savemode,'''''')&~strcmpi(savemode,'[]')
  error('savemode is invalid')
end
%
clearf=0; dbs=dbstack;
for id=2:length(dbs)
  if ~isempty(dbs(id).name)&~any(findstr([filesep,'fdguitst','%'],[dbs(id).name,'%']))
    clearf=0;
    break
  end
end
if clearf
  clear functions %always run with latest function copies
end
%dbclear all
lasterr('')
%
%Initialize info storage
t0=clock;
v=version;
strarr={};
if ~isempty(fdtoolmode)
  if isstr(fdtoolmode)
    fdtmtxt=['-',fdtoolmode];
  else %NaN
    fdtmtxt='';
    if exist('fdguidev.mat'), fdtmtxt=[fdtmtxt,'D']; end
    if exist('fdguimeas.mat'), fdtmtxt=[fdtmtxt,'M']; end
    if ~isempty(fdtmtxt), fdtmtxt=['-',fdtmtxt]; end    
  end
else
  fdtmtxt='-user';
end
if fdtool('license')<=1, ltxt='-trial'; else ltxt=sprintf('-lic%.0f',fdtool('license')); end
dname=['fdguitst-',v(1:3),fdtmtxt,ltxt,'.diary'];
matname=['fdguitst-',v(1:3),fdtmtxt,ltxt,'.mat'];
if (isempty(hno)&isempty(runmod))|~exist(matname)
  save(matname,'strarr') %initialize
  diary off
  if exist(dname)
    %disp(['Deleting file ''',dname,''''])
    delete(dname)
    if exist(dname), dname=''; end
  end
elseif exist(matname)
  load(matname)
  if ~isempty(runmod)
    strarrstr=cat(2,strarr{:});
    indh=findstr('#',strarrstr);
    if ~isempty(indh)
      inde=findstr(')',strarrstr(indh(end):end));
      laststr=strarrstr(indh(end)+[1:inde(end)-2]);
    else laststr='';
    end
    if ~isempty(laststr)
      lastname=deblank(alldemos(str2num(laststr)+1,:));
      ind=findstr(lastname,'. '); if ~isempty(ind), lastname=lastname(ind(1)+2:end); end
    else
      lastname='';
    end
    if strncmpi(runmod,'jump',1), jn=1; runmod='cont'; else jn=0; end
    if strncmpi(runmod,'n',1)
      disp(['Last started file: #',laststr,'. ',lastname])
      return
    elseif strncmp(runmod,'cont',1)
      if ~isempty(laststr)
        disp(['Last started file: #',laststr,'. ',lastname])
        hno=[str2num(laststr)+jn:size(alldemos,1)-1];
      else
        disp('Cannot find last file')
        laststr='1';
        hno=[];
      end
    end
  end
end
if ~isempty(dname), diary(dname), end
fdpath=which('fdident.m');
save(matname,'fdpath','-append')
%
stri=['Fdident GUI test, ',datestr(now)];
strarr{size(strarr,1)+1,1}=stri;
disp(stri)
%
l=fdtool('license');
%
disp('Opening main GUI window...')
hf=findall(0,'type','figure');
while ~isempty(hf)
  set(hf(1),'CloseRequestFcn','')
  set(hf(1),'DeleteFcn','')
  delete(hf(1)), pause(1)
  hf=findall(0,'type','figure');
end
close all force
if exist('fddefses.mat')
  try
    disp('Testing default session file ''fddefses.mat''...')
    %fdtool exit force
    fdtool
    %try, close all, catch, pause(1), close all, end
    fdtool exit force
  catch
    answ=input('Something is wrong with the default session. May I delete it? ','s');
    if strncmp(answ,'y',1), delete('fddefses.mat'), end
  end
end
if ((isstr(fdtoolmode)&~any(findstr(fdtoolmode,'D'))) | any(isnan(fdtoolmode))) &0
  %
  %test nonlindemo1, nonlindemo2 and harvester in non-development mode:
  if exist('harvester.mat')
    fdtool basic
    runhist('harvester')
    hrec=[findall(allchild(0),'flat','tag','fdtool_recorder_fig');...
      findall(allchild(0),'flat','tag', 'gui_recorder_fdtool')];
    hcmd=[findobj(hrec,'tag', 'fdtool_recorder_statustext');...
      findobj(hrec,'tag', 'gui_recorder_fdtool_status_text')];
    while ~any([findstr(lower(get(hcmd,'string')),'finished'),...
        findstr(lower(get(hcmd,'string')),'end of')])
      pause(1)
      %Wait until previous run finishes, or recorder is deleted
      if isempty([findall(0,'tag','fdtool_recorder_fig');...
          findall(0,'tag', 'gui_recorder_fdtool')]) %recorder was deleted
        %dbclear all
        return
      end
    end
    close all
  end
  if ~strncmpi(runmod,'c',1)
    %Test nonlindemo files
    for hm={'1','2'}
      fdtool basic
      %hrec=[findall(allchild(0),'flat','tag','fdtool_recorder_fig');...
      %    findall(allchild(0),'flat','tag', 'gui_recorder_fdtool')];
      %if ~isempty(hrec), delete(hrec), end
      runhist(['nonlindemo',hm{1}])
      hrec=[findall(allchild(0),'flat','tag','fdtool_recorder_fig');...
        findall(allchild(0),'flat','tag', 'gui_recorder_fdtool')];
      hcmd=[findobj(hrec,'tag', 'fdtool_recorder_statustext');...
        findobj(hrec,'tag', 'gui_recorder_fdtool_status_text')];
      while ~any([findstr(lower(get(hcmd,'string')),'finished'),...
          findstr(lower(get(hcmd,'string')),'end of')])
        pause(1)
        %Wait until previous run finishes, or recorder is deleted
        if isempty([findall(0,'tag','fdtool_recorder_fig');...
            findall(0,'tag', 'gui_recorder_fdtool')]) %recorder was deleted
          %dbclear all
          return
        end
      end
      fdtool exit force
    end
  end
  %Open fdtool for the test of all demos:
  fdtool exit force
  fdtool quick %open GUI without default session
else
  fdtool basic %no development, no default session
end
if ~any(isnan(fdtoolmode)), fdtool('setguimodes',fdtoolmode), end
%
if (l<=1)&exist('rml.m'), rml, end
%
isdev=guiinfos('isdevelopment');
if isdev, stri='Development mode: on';
else stri='Development mode: off';
end
ismeas=guiinfos('ismeasurement');
if ismeas, stri=[stri,', measurement: on'];
else stri=[stri,', measurement: off'];
end
stri=[stri,', license code: ',num2str(fdtool('license'))];
strarr{size(strarr,1)+1,1}=stri;
disp(' ')
clc
disp(stri)
stri=['Matlab version: ',version];
strarr{size(strarr,1)+1,1}=stri;
disp(stri)
stri=['Diary file: ',dname];
strarr{size(strarr,1)+1,1}=stri;
disp(stri)
stri=['Saved information file: ',matname];
strarr{size(strarr,1)+1,1}=stri;
disp(stri)
%hm=findall(0,'tag','fdtool_menu_test');
%if isempty(hm) %Restart fdtool in development mode
%  %fdtool('ui_reset', 'fdtool_menu_reset')
%  fdtool('close_all_windows', 'fdtool_menu_closewindows')
%  delete(findall(0,'tag','fdtool_main'))
%  fdtool
%end
%
dbstop if error
%dbstop if warning
%
disp(' ')
unique=fdunique;
if ~unique, error('Repeated file on path'), end
if isempty(hno) %| ~isempty(hno)&(isequal(hno(1),1)|(isstr(hno(1))&isequal(str2mat(hno),1)))
  if exist('hloadmat.m')
    disp('Testing MAT-files...')
    hloadmat
    %hloadmat('nomesg')
  else
    warning('Test M-file hloadmat.m does not exist')
  end
else
  disp('Skipping test of MAT-files')
end
%
guirecrd('init','development'); %Initialize development recorder
guirecrd('delete', 'all_no_question'); %Delete contents
%guirecrd('init', 'demo'); %Initialize demo recorder
if strcmpi(computer,'SOL2')
  hr=findall(0,'type','figure','tag','fdtool_recorder_fig');
  pos=get(hr,'position');
  if pos(2)==50, pos(2)=pos(2)+20; set(hr,'position',pos), end
end
%
hdemoscb={};
%Set UserLevel to Advanced, to assure that all demos are included

try %if possible
  fdtool('userlevel_set','Advanced')
catch
  fdtool('userlevel_set','Intermediate')
end
for ii=1:4
  %set up demo window
  if ii==1, fddgui1('test')
  elseif ii==2, fddgui1 %complex
  elseif ii==3, fddgui1('intro_ident')
  elseif ii==4, fddgui1('intro_gui')
  end
  hdem=findall(allchild(0),'flat','tag','fdident_gui_demos');
  hdemos=findall(hdem,'tag','fdgui_demobutton');
  newdemos=get(hdemos,'callback');
  if ~isempty(newdemos)
    if ~iscell(newdemos), newdemos={newdemos}; end
    hdemoscb=[hdemoscb;newdemos];
  end
  if ii==1
    %add demos
    %frfcompose.mat:
    hdemoscb=[hdemoscb;{'fdtool(''callback'',''guirecrd'',''SetContinuous'',1),fdtool(''callback'',''guirecrd'',''SetDiscardPause'',0),fdtool(''callback'',''guirecrd'',''loadhist'',''composefrf.mat'');'}];
    %nonlindemo1.mat, nonlindemo2.mat:
    %hdemoscb=[hdemoscb;{'fdtool(''callback'',''guirecrd'',''SetContinuous'',1),fdtool(''callback'',''guirecrd'',''SetDiscardPause'',0),fdtool(''callback'',''guirecrd'',''loadhist'',''nonlindemo1.mat'');'}];
    %hdemoscb=[hdemoscb;{'fdtool(''callback'',''guirecrd'',''SetContinuous'',1),fdtool(''callback'',''guirecrd'',''SetDiscardPause'',0),fdtool(''callback'',''guirecrd'',''loadhist'',''nonlindemo2.mat'');'}];
  end
  %
end %for ii
if ismeas
  if exist('private/homework')
    %hf:
    if ~strncmp(version,'5.2',3)
      hdemoscb=[hdemoscb;{'fdtool(''callback'',''guirecrd'',''SetContinuous'',1),fdtool(''callback'',''guirecrd'',''SetDiscardPause'',0),fdtool(''callback'',''guirecrd'',''loadhist'',''h.mat'');'}];
    end
    %fdhwemul:
    ind=[];
    for iii=length(hdemoscb):-1:1
      if any(findstr('fdhwemul.mat',hdemoscb{iii}))|...
          any(findstr('tstfdsim.mat',hdemoscb{iii}))|...
          any(findstr('tsffdsim.mat',hdemoscb{iii}))
        ind=[ind;iii];
      end
    end %for iii
    if ~isempty(ind), hdemoscb(ind)=[]; end
  end
end
%
fdtool('ui_userlevel_set','Interactive','fdtool_menu_userlevel_intermediate')
delete(hdem) %remove demo window
%
%Test uniqueness
pd=which('aluplate.mat','-all');
if length(pd)==0, error('aluplate.mat not found')
elseif size(pd,1)>1
  disp('Something is not correct: more than one aluplate.mat found:')
  for ii=1:size(pd,1)
    disp(pd{ii})
  end
  error('Repeated file aluplate.mat')
else
  pd=pd{1};
end
%now pd is a string
%
%Scan test history files between demos (t*.mat)
if guiinfos('isdevelopment')
  pd=pd(1:length(pd)-13); %only the path from which('aluplate.mat')
  fs=dir(pd);
  for ii=length(fs):-1:1
    nameii=fs(ii).name;
    if ~strcmp(nameii(1),'t')|any(findstr([lower(nameii),'|'],'.m|'))
      %delete non-test MAT-files and M-files
      fs(ii)=[];
    else
      for iii=1:length(hdemoscb)
        %Delete tests that are already among the demos
        if any(findstr(lower(hdemoscb{iii}),lower(nameii)))
          fs(ii)=[];
          break
        end
      end
    end %for iii
  end %for ii
  %
  for ii=1:length(fs) %add each extra name to hdemoscb
    dcb=hdemoscb{1};
    ind=findstr(dcb,'.mat');
    indq=max(find(dcb(1:ind)=='''')); ind1=indq+1;
    ind2=ind+3;
    %name=dcb(ind1:ind2);
    if exist('siglab.dll')|~strncmp(fs(ii).name,'testvna',7)
      newcb=[dcb(1:ind1-1),fs(ii).name,dcb(ind2+1:length(dcb))];
      if ~strncmpi(runmod,'l',1), warning(['Test file ''',fs(ii).name,''' was manually taken']), end
      %
      %hdemoscb{length(hdemoscb)+1}=newcb; %Add test as first in execution
      hdemoscb=[{newcb};hdemoscb]; %Add test as last in execution
    end
  end %for ii
end
%
%Eliminate demos/tests which do not run in trial mode
for ii=length(hdemoscb):-1:1
  if fdtool('license')<=1 %trial mode, models not saved
    if any(findstr('inpchdem.mat',hdemoscb{ii}))|...
        any(findstr('testarr.mat',hdemoscb{ii}))|...
        any(findstr('tstessda.mat',hdemoscb{ii}))|...
        any(findstr('testecpm.mat',hdemoscb{ii}))|...
        any(findstr('testecpc.mat',hdemoscb{ii}))|...
        any(findstr('testnl1levels.mat',hdemoscb{ii}))|...
        any(findstr('testnl2levels.mat',hdemoscb{ii}))|...
        any(findstr('testcorrdem.mat',hdemoscb{ii}))
      hdemoscb(ii)=[]; %delete demo not executable in trial mode
    end
  end
  if ~exist('impulse.m') %control toolbox is not present
    if any(findstr('test_impulse.mat',hdemoscb{ii}))
      hdemoscb(ii)=[]; %delete demo not executable
    end
  end
end %for ii
%
%Eliminate demos which do not run in non-measurement mode
%  because simulation is included
for ii=length(hdemoscb):-1:1
  if ~guiinfos('ismeasurement')
    if any(findstr('ruidemo.mat',hdemoscb{ii}))|...
        any(findstr('ruidsim.mat',hdemoscb{ii}))|...
        any(findstr('tstfdsim.mat',hdemoscb{ii}))|...
        any(findstr('tsffdsim.mat',hdemoscb{ii}))|...
        any(findstr('tstcorrt.mat',hdemoscb{ii}))|...
        any(findstr('testoppz.mat',hdemoscb{ii}))|...
        any(findstr('testnl1levels.mat',hdemoscb{ii}))|...
        any(findstr('testnl2levels.mat',hdemoscb{ii}))|...
        any(findstr('testcorrdem.mat',hdemoscb{ii}))
      hdemoscb(ii)=[]; %delete demo not executable in trial mode
    end
  end
  %Remove tests which would change data
  if any(findstr('testnonlin1.mat',hdemoscb{ii}))|...
      any(findstr('testnonlin2.mat',hdemoscb{ii}))
    hdemoscb(ii)=[]; %delete demo not executable in trial mode
  end
  %eliminate starting and fddefpre
  if any(findstr('fddefpre.mat',hdemoscb{ii}))
    precomm=hdemoscb(ii);
    hdemoscb(ii)=[]; %delete demo not executable
  elseif any(findstr('starting.mat',hdemoscb{ii}))
    stcomm=hdemoscb(ii);
    hdemoscb(ii)=[]; %delete demo not executable
  elseif any(findstr('introfdd.mat',hdemoscb{ii}))
    fddcomm=hdemoscb(ii);
    hdemoscb(ii)=[]; %delete demo not executable
  elseif any(findstr('sim_for_polyanal.mat',hdemoscb{ii}))
    polycomm=hdemoscb(ii);
    hdemoscb(ii)=[]; %delete demo not executable
  end
end %for ii
hdemoscb=[stcomm;polycomm;hdemoscb]; %put starting and sim_for_polyanal to the end
hdemoscb=[hdemoscb;precomm]; %put fddefpre to the beginning
hdemoscb=[hdemoscb;fddcomm]; %put fddefpre to the beginning
%
hrec=[findall(allchild(0),'flat','tag','fdtool_recorder_fig');...
    findall(allchild(0),'flat','tag', 'gui_recorder_fdtool')];
if ishandle(hrec), figure(hrec), end %pop recorder to front
%
t0d=clock;
hnoall=[length(hdemoscb):-1:1]; maxh=max(hnoall);
aotest=0;
if isempty(hno)
  hno=hnoall; aotest=1; %if empty hno, do also aotest
else
  if isstr(hno), eval(['hno=',hno,';']); end
  hno=sort(hno(:)');
  if (length(hno)==1)&isequal(hno,maxh+1), hno=hno-1; end
  ind=find(hno>maxh);
  if ~isempty(ind), 
    if hno+1==maxh, aotest=1;
    else aotest=0;
    end
    hno(ind)=[];
  end
  hno=maxh-hno+1;
end
%
%MAIN CYCLE
if strncmpi(runmod,'l',1)
  endname=deblank(hdemoscb{1,:});
  ind=findstr(endname,'loadhist'); indend=findstr(endname,'.mat');
  if ~isempty(ind), endname=endname(ind(end)+11:indend(end)+3); end
  hno=1; %size(hdemoscb,1); %last history
  disp(['Last file, this will be executed now: #',num2str(hno),'. ',endname])
  aotest=0; %for last history, do not test autoorder
end
hnoii=0;
if ~isequal(hno,1)|~strcmpi(runmod,'c')
  for ii=hno
    hnoii=hnoii+1;
    cycno=maxh-ii+1;
    ok=1;
    if ii==0 %try to execute fddefpre
      name='fddefpre.mat';
      if exist(name)
        guirecrd('loadhist',name);
        guirecrd('addhistnumber',ii,maxh);
      else
        ok=0;
      end
    elseif isequal(fdtool('lic'),1)&...
        (any(findstr(hdemoscb{ii},'ruidemo.mat'))|any(findstr(hdemoscb{ii},'ruidsim.mat')))
      %cannot execute in trial mode
      ok=0;
    else
      dcb=hdemoscb{ii};
      ind=findstr(dcb,'.mat');
      indq=max(find(dcb(1:ind)=='''')); ind1=indq+1;
      ind2=ind+3;
      name=dcb(ind1:ind2);
      eval(dcb)
      guirecrd('addhistnumber',cycno,maxh);
    end
    if ok==1
      alldemos='All demo/test files:';
      if cycno==maxh-max(hno)+1
        for ic=length(hdemoscb):-1:1
          cl=hdemoscb{ic};
          ind=findstr('loadhist',cl); ind2=findstr('.mat',cl);
          if isempty(ind2), ind2=findstr('.MAT',cl); end
          %alldemos=str2mat(alldemos,['  ',cl(ind(end)+11:end-3)]);
          alldemos=str2mat(alldemos,...
            sprintf(['  %.0f. ',cl(ind(end)+11:ind2(end)+3)],...
            length(hdemoscb)-ic+1));
        end
        disp(alldemos)
        save(matname,'alldemos','-append')
      end
      ti0=clock;
      stri=sprintf(['Test with history file ''',name,''' (file #%.0f)'],...
        cycno);
      strarr{size(strarr,1)+1,1}=stri;
      save(matname,'strarr','-append')
      disp(stri)
      fprintf('History file: #%.0f, others still to execute: %.0f\n',...
        cycno,sum(hno<ii))
      nfno=min(3,length(hno(hnoii:end))-1);
      for il=hno(hnoii)-[1:nfno]
        if nfno==1, stxt=''; else stxt='s'; end
        if il==ii-1, fprintf(['  Next %.0f file',stxt,':\n'],nfno), end
        dcbl=hdemoscb{il};
        indl=findstr(dcbl,'.mat');
        indql=max(find(dcbl(1:indl)=='''')); ind1l=indql+1;
        ind2l=indl+3;
        namel=dcbl(ind1l:ind2l);
        fprintf(['    ',namel,'\n'])
      end
      guirecrd('SetContinuous',1);
      guirecrd('SetDiscardPause',1);
      guirecrd('SetTestMode',2);
      guirecrd('SetEmulatemouse',0);
      if cycno==1 %only in first cycle
        %guirecrd('SetTestPlotMode',1); %save test plots (psc)
        if exist('fdidgui.psc'), delete('fdidgui.psc'), end
      end
      %
      %Execute action record:
      errorcatch 
      fdtool('userlevel','Automatic')
      fdtool('ui_signaltype_set','All','fdtool_menu_signaltype_all')
      fdtool('ui_modeltype_set','Linear','fdtool_menu_modeltype_linear')
      fdtool('ui_forget_all')
      guirecrd('PlayHist');

      %Wait until previous demo finishes:
      hrec=[findall(allchild(0),'flat','tag','fdtool_recorder_fig');...
        findall(allchild(0),'flat','tag', 'gui_recorder_fdtool')];
      hcmd=[findobj(hrec,'tag', 'fdtool_recorder_statustext');...
        findobj(hrec,'tag', 'gui_recorder_fdtool_status_text')];
      while ~any([findstr(lower(get(hcmd,'string')),'finished'),...
          findstr(lower(get(hcmd,'string')),'end of')])
        pause(1), drawnow
        %Wait until previous run finishes, or recorder is deleted
        if isempty([findall(0,'tag','fdtool_recorder_fig');...
            findall(0,'tag', 'gui_recorder_fdtool')]) %recorder was deleted
          %dbclear all
          disp(' '), disp(strarr)
          dbclear all, diary off
          error('Recorder was closed by force')
          return
        end
      end
      %
      if strcmpi(savemode,'save')
        guirecrd('Save'); %save actual record: update history files
      end
      %
      stri=sprintf('   Run time: %.1f mins, total until now: %.1f mins',...
        etime(clock,ti0)/60,etime(clock,t0)/60);
      strarr{size(strarr,1)+1,1}=stri;
      save(matname,'strarr','-append')
      %
      %pause(20) %attempt to fix
      %guirecrd('save'); %save updated history - fails on a Sun
      %
      pause(1) %wait a little bit for properly finished run
      load(name) %test consistency of MAT-file
      disp(' '), disp(strarr)
      %
    end %ok
    if strcmp(get(0,'diary'),'on'), diary off, diary on, end
  end %main cycle, for ii=hno
  fdtool('exit','force') %close GUI
  fdtool('close_all_windows','fdtool_menu_closewindows') %close all windows
  disp(' ')
  stri=sprintf('Total run time of GUI histories: %.1f mins',etime(clock,t0)/60);
  strarr{size(strarr,1)+1,1}=stri;
  if ~isequal(hno,maxh)
    save(matname,'strarr','-append')
  end
  disp(stri), disp(' ')
  if isempty(lasterr), stat=1; else stat=0; end
  %
  if aotest %test of automatic order selection demos
    if exist('testaod.m'), feval('testaod'), end
  end
  %
  %test data objects for basic calls:
  if ~isequal(hno,maxh)
    save(matname,'t0','-append')
  end
  %
  dbclear all
  load(matname)
  %
  disp(' ')
  disp('*************************') %line before message
  stri=sprintf('fdguitst has finished the run successfully.');
  disp(stri)
  strarr{size(strarr,1)+1,1}=stri;
  stri=sprintf('Total run time of fdguitst: %.1f mins',etime(clock,t0)/60);
  disp(stri), disp(' ')
  strarr{size(strarr,1)+1,1}=stri;
  if ~isequal(hno,maxh)
    save(matname,'strarr','-append')
  end
  %
  if (length(hno)>3)|strncmpi(runmod,'l',1)
    pause off
    dbstop if error
    if exist('testfobj.m'), testfobj, end %test data and model objects
    pause on
    close all
    %
    disp('*************************') %line before message
    striend1=sprintf('fdguitst+testobj has finished the run successfully.');
    disp(striend1)
    strarr{size(strarr,1)+1,1}=striend1;
    striend2=sprintf('Total run time: %.1f mins',etime(clock,t0)/60);
    disp(striend2), disp(' ')
  end
  dbclear all
  %
end
%if exist('rml.m'), feval('rml','r'), end
hmhf=findall(0,'tag','MiniHelPFigurE'); if ~isempty(hmhf), delete(hmhf), end, clear hmhf
delete(findobj(0,'tag','fdtool_importfig')) %delete strange window
delete(findobj(0,'tag','fdtool_exportfig')) %delete strange window
close(findall(0,'tag','compare_main'))
close(findall(0,'tag','compare_main'))
%h=findall(0, 'tag', 'fdtool_menu_forget_all');
%if ishandle(h), eval(get(h,'callback')), end
close(findall(0,'tag','fdtool_main'),'force')
diary off
fdtool('callback','guirecrd','Close')
%
global yesinpacceptdef, yesinpacceptdef='yes'; pause off, fdiddemo, pause on
%
%End of fdguitst
