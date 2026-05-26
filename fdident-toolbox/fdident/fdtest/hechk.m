function pdat=hechk(option,rsh,command)
%HECHK   Simple but long-lasting calls for testing iterctrl
%
%       hechk(option,rsh,command)
%
%       Input arguments:
%       option=0 or missing: create menu 'Run command' (interruptible on) and
%                 execute command-line call
%       option=1: create menu 'Run command' (interruptible on) for callback,
%                 no run
%       option=2: execute command-line call
%       option=3: execute long command-line call without plots
%       option=4: execute command-line call without pole/zero plots
%       rsh=1: run with short setting (checked=Final) Default: 0
%       commmand: function name to call: dibs, dibsimpr, elis, msinclip,
%                 optexcit, varanal. Default: elis
%
%       The callback run makes no messages at all.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Mar-2005

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, drawnow
if nargin<1, option=[]; end, if isempty(option), option=0; end
if nargin<2, rsh=[]; end, if isempty(rsh), rsh=0; end
if nargin<3, command=''; end, if isempty(command), command='elis'; end
fprintf('File hechk, option: %.3g\n',option)
if option==0
  disp(['Create menu ''Run ',command,''' (interruptible on), run ',command])
elseif option==1
  disp(['Create menu ''Run ',command,...
          ''' (interruptible on), return to command line'])
elseif option==2
  disp(['Call ',command])
elseif option==3
  disp(['Call ',command,', no plots'])
elseif option==4
  disp(['Call ',command,', no pole/zero plots'])
end
MatlV=version;
if strcmp(MatlV(1:3),'4.0')
  %iterctrl does not work for versions below Matlab 4.1, it will not be tested
  testiterctrl=0;
else %regular case, e.g. Matlab5 or Matlab4.2
  testiterctrl=1; %Test iterctrl
  if strcmp(iterctrl('Iteration'),'Continue'), iterctrl; drawnow, end
end
%
if ((option==0)|(option==1))&(testiterctrl==1)
  c=computer;
  if strcmp(command,'dibs')
    commandcallcb='dibs(128,1,[1:10]/128,[],50);';
  elseif strcmp(command,'dibsimpr')
    commandcallcb='dibsimpr(sign(randn(1,128)),1,[1:10]/128,[],5);';
  elseif strcmp(command,'elis')
    commandcallcb=['[pv]=elis(''bandpass(bandpass)'',[],[''s'',10,10],',...
      '[3,0;4,0;17,1],[],[NaNv(ones(1,13)),''n''+0]);'];
  elseif strcmp(command,'msinclip')
    commandcallcb='msinclip([1:20],ones(1,20),[],[],1000);';
  elseif strcmp(command,'optexcit')
    commandcallcb=['optexcit(''inpchmod(inpchans)'',0:400:20000,',...
          '[9.61e-12,9.61e-10],[],[],200);'];
  elseif strcmp(command,'varanal')
    commandcallcb='varanal(''lowpass(lowpass)'',''delayed'');';
  else
    error(['Invalid command ''',command,''''])
  end
  if strcmp(c(1:2),'PC'), lab=['&Run ',command]; lab1='&Start'; lab2='Sto&p';
  else lab=['Run ',command]; lab1='Start'; lab2='Stop'; end
  if isempty(findobj('Label',lab))
    %h=uimenu(gcf,'label',lab);
    %if strcmp(MatlV(1:2),'4.'), itble='yes'; else itble='on'; end
    %uimenu(h,'Label',lab1,'Callback',['NaNv=NaN;',commandcallcb],...
    %    'interruptible',itble);
    %drawnow
    %uimenu(h,'Label',lab2,'Callback','iterctrl; iterctrl(''Abort'');')
    if strcmp(MatlV(1:2),'4.'), itble='yes'; else itble='on'; end
    h=uimenu(gcf,'label',lab,'Callback',['NaNv=NaN;',commandcallcb],...
        'interruptible',itble);
    drawnow
  end
  if rsh==1
    disp('Run hechk with ''Finish'' on')
    iterctrl('Finish')
  end
elseif (testiterctrl==0)&(option==1)
  disp(['WARNING! iterctrl cannot be used in ',MatlV])
end
%
if ((option==0)|(option==2))&(testiterctrl==1)
  disp(['Long iteration with ',command])
  if strcmp(command,'dibs')
    commandcall='dibs(128,1,[1:10]/128,[],50);';
  elseif strcmp(command,'dibsimpr')
    commandcall='dibsimpr(sign(randn(1,128)),1,[1:10]/128,[],5);';
  elseif strcmp(command,'elis')
    commandcall='[pv]=elis(''bandpass'',[],[''s''+0,10,10]);';
  elseif strcmp(command,'varanal')
    commandcall='varanal(''lowpass(lowpass)'',''delayed'');';
  elseif strcmp(command,'msinclip')
    commandcall='msinclip([1:20],ones(1,20),[],[],1000);';
  elseif strcmp(command,'optexcit')
    commandcall=['optexcit(''inpchmod(inpchans)'',0:400:20000,',...
          '[9.61e-12,9.61e-10],[],[],200);'];
  end
  disp(commandcall)
  eval(commandcall)
end
%
if (option==3)&(testiterctrl==1)
  %Without plots:
  disp(['%Long iteration with ',command,', with no plots'])
  if strcmp(command,'dibs')
    commandcall='dibs(128,1,[1:10]/128,[],50,''nograph'');';
  elseif strcmp(command,'dibsimpr')
    commandcall='dibsimpr(sign(randn(1,128)),1,[1:10]/128,[],5,''nograph'');';
  elseif strcmp(command,'elis')
    commandcall='[pv]=elis(''bandpass'',[],[''s''+0,10,10],[],[],inf);';
  elseif strcmp(command,'msinclip')
    commandcall='msinclip([1:20],ones(1,20),[],''nograph'',1000);';
  elseif strcmp(command,'optexcit')
    commandcall=['optexcit(''inpchmod(inpchans)'',0:400:20000,',...
          '[9.61e-12,9.61e-10],[],[],200,[],inf);'];
  elseif strcmp(command,'varanal')
    commandcall='varanal(''lowpass(lowpass)'',''delayed'');';
  end
  disp(commandcall)
  eval(commandcall)
end
%
if (option==4)&(testiterctrl==1)
  %Without pole/zero plot:
  disp(['%Long iteration with ',command,', without pole/zero plots'])
  if strcmp(command,'elis')
    commandcall=['[pv]=elis(''bandpass'',[],[''s''+0,10,10],[],[]',...
        ',[NaN*ones(1,6),''nn''+0]);'];
  else
    disp(['Warning! option is not meaningful with ''',command,''''])
  end
  %
  if strcmp(command,'dibs')
    commandcall='dibs(128,1,[1:10]/128,[],50);';
  elseif strcmp(command,'dibsimpr')
    commandcall='dibsimpr(sign(randn(1,128)),1,[1:10]/128,[],5);';
  elseif strcmp(command,'msinclip')
    commandcall='msinclip([1:20],ones(1,20),[],[],1000);';
  elseif strcmp(command,'optexcit')
    commandcall=['optexcit(''inpchmod(inpchans)'',0:400:20000,',...
          '[9.61e-12,9.61e-10],[],[],200);'];
  elseif strcmp(command,'varanal')
    commandcall='varanal(''lowpass(lowpass)'',''delayed'');';
  end
  disp(commandcall)
  eval(commandcall)
end
if nargout>0, pdat=pv; end
%
%End of hechk
