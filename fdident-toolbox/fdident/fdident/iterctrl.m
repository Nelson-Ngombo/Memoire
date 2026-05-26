function checked=iterctrl(action,parent,items,visibility)
%ITERCTRL Iteration control function using pull-down menu.
%
%       checked=ITERCTRL(action,parent,items,visibility)
%
%       ITERCTRL provides means to influence the iteration of functions
%       like elis, using a pull-down menu. The control is only effective
%       if the iterative function is programmed to obey.
%       ITERCTRL allows to pause iteration, keep the last graph, modify the
%       graph from the command line, print it, and to request finishing
%       of the iteration after the currect cycle, with proper output arguments,
%       even if the iteration termination criteria are otherwise not met.
%       Activate menu by iterctrl('initialize') or simply iterctrl;
%       select item from program by iterctrl(item-label);
%       look for selected item from program by iterctrl('checked').
%       Calling iterctrl('initialize',parent,'Abort|Finish','off') creates
%       an invisible menu in figure with handle given in parent, with
%       selectable options Abort and Finish. items may be empty or 'all' in
%       order to have all menu options.
%
%       Output argument:
%       checked = checked menu item (string)
%           If action='Iteration', checked is the status of the Iteration
%               menu item: 'selected' or 'not selected'
%               Warning! This latter information depends on handling of the
%               event que, and may become valid with a significant delay only.
%           checked is empty if the uimenu is not defined.
%           For 'initialize', iterctrl returns the uimenu handle of checked
%               item.
%
%       Input argument:
%       action = type of action to be performed:
%           'initialize': create and initialize menu (this is the default)
%           'checked': return label of checked menu item
%           'Iteration': get info if menu item is selected
%           'Abort','Cancel','Continue','Finish','Hold graph','Keyboard',
%               'Matlab prompt','Pause','Plot','Print','Zoom':
%               select corresponding item
%           'delete': delete menu
%           'datapage': go to data page on web
%           'devpage': go to developers' page on web
%       The following arguments are only used with action='initialize':
%       parent = handle of parent figure (default: gcf)
%       items = list of submenu items to be displayed. 'all' creates all
%           possible menu items
%       visibility = 'on' or 'off', used with action set to 'initialize';
%           set visibility of Iteration menu. Default: 'on'
%
%       Usage: checked=iterctrl(action,parent,items,visibility);
%       Examples: iterctrl; iterctrl('Pause'); iterctrl('checked')

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Apr-2016

if (nargin==1)&isstr(action)&strcmp(action,'preload')
  return %loading only for one argument 'preload'
end
%One-line substitute to eliminate problems
%checked='Continue'; return

c=computer;
ispc=strncmpi(c,'PC',2);
ismac=strncmpi(c,'MAC',3);
%
if nargin<1, action=''; end, if isempty(action), action='initialize'; end
if strcmp(action,'Initialize'), action='initialize'; end
if nargin<4, visibility=''; end
if (strcmp(action,'Iteration')|strcmp(action,'Iteratio&n'))&(nargin==2)
  %For Iteration, visibility is used to set the UserData
  %If it is empty, UserData is will not be set
  visibility=parent; parent=gcf;
elseif strcmp(action,'initialize')
  if nargin<3, items=''; end, if isempty(items), items='all'; end
  if nargin<2, parent=[]; end, if isempty(parent), parent=gcf; end
  if ~strcmp(get(parent,'Type'),'figure')
    error('Object defined by ''parent'' is not a figure')
  end
  if ~strcmp(visibility,'on')&~strcmp(visibility,'off')&~isempty(visibility)
    error(['visibility = ''',visibility,''' is not valid'])
  end
elseif nargin<2
  if ~isempty(get(0,'children')), parent=gcf; end
elseif nargin>2
  error('Multiple input arguments are only used with action=''initialize''')
end
if ~exist('findobj') %Early version of Matlab
  if strcmp(action,'initialize')
    disp('Warning! Command ''findobj'' not found')
    disp('iterctrl only works under Matlab 4.2 or later')
  end
  if nargout>0, checked='Continue'; end
  return
end
%
MatlV=version;
if strcmp(action,'initialize')&strcmp(MatlV(1),'4')
  disp(['WARNING! In Matlab V',MatlV,' or earlier some mouse clicks may ',...
          'not be noticed'])
  %disp('Upgrade asap to Matlab 5')
end
%
%No control if graphics not defined
lasterrsave=lasterr;
eval('tp=~strcmp(get(0,''TerminalProtocol''),''none'');','tp=1;')
lasterr(lasterrsave)
if (tp==0) %no terminal protocol
  if strcmp(action,'initialize')
    if nargout>0, checked=[]; end
    disp('Warning! No terminal protocol defined, uimenu is not created')
  elseif nargout>0, checked='Continue';
  end
  return %Nothing to do if terminalprotocol is undefined
end
%
if strcmp(action,'Checked'), action='checked'; end
if strcmp(action,'Delete'), action='delete'; end
%
if strcmp(action,'initialize')|strcmp(action,'checked')
elseif strcmp(action,'Iteration')|strcmp(action,'Iteratio&n')
elseif strcmp(action,'Abort')|strcmp(action,'Cancel')
elseif strcmp(action,'Continue')|strcmp(action,'Finish')
elseif strcmp(action,'Hold graph')|strcmp(action,'Keyboard')
elseif strcmp(action,'Matlab prompt')|strcmp(action,'Evaluate command')
elseif strcmp(action,'Pause')|strcmp(action,'Print')
elseif strcmp(action,'Plot')
elseif strcmp(action,'Zoom')
elseif strcmp(action,'delete')
elseif strcmpi(action,'datapage')|strcmpi(action,'devpage')
  h=findall(0,'tag','iteration_menu');
  if ~isempty(h), iterctrl; end
  h=findall(0,'tag','iteration_menu');
  if strcmpi(action,'datapage'), tag='iteration_menu_data';
  elseif strcmpi(action,'devpage'), tag='iteration_menu_dev';
  end
  eval(get(findobj(h,'tag',tag),'callback'))
  return
elseif isempty(action)
else %Unknown option
  error(['Illegal action ''',action,''''])
end
%
PCIteration='Iteratio&n';
if ispc|isunix, ItLabel=PCIteration;
else ItLabel='Iteration';
end
%
%htop=findobj('Type','uimenu','Label',ItLabel);
%Avoid error message in Matlab 4.0:
eval(['htop=findobj(''Type'',''uimenu'',''Tag'',''iteration_menu'');'])
if ~isempty(htop)&strcmp(action,'initialize')
  if length(htop)>1, error('Multiple iteration control menus in workspace'), end
  if parent==get(htop,'parent')
    %Delete old menu; new definition is requested, probably with new menu items
    delete(htop), htop=[];
  elseif parent==get(htop,'parent')
  %  error('It makes no sense to redefine the same iteration control menu')
  else
     delete(htop), htop=[];
     %error('Cannot define multiple iteration control menus')
  end
end
htopparent=htop;
if isempty(htop) %Look for menu elsewhere
  %figs=findobj(get(0,'Children'),'flat','Type','figure');
  eval('figs=findobj(get(0,''Children''),''flat'',''Type'',''figure'');')
  %look for invisible menu only
  if ~isempty(figs)
    %figs=findobj(figs,'flat','visible','off');
    eval('figs=findobj(figs,''flat'',''visible'',''off'');')
  end
  %find menus
  if ~isempty(figs)
    figsCh=get(figs(1),'Children');
    for i=2:length(figs), figsCh=[figsCh;get(figs(i),'Children')]; end
    %htop=findobj(figsCh,'flat','Type','uimenu','Label',ItLabel);
    eval(['htop=findobj(figsCh,''flat'',''Type'',''uimenu''',...
        ',''Tag'',''iteration_menu'');'])
  end
  if length(htop)>1
    error('Multiple Iteration menus found in object space')
  end
elseif length(htop)>1 %multiple menus defined, probably during testing
  htop=htop(length(htop));
end
%
PCPrint='&Print'; %not used in the end
PCMatlab_prompt='&Matlab prompt';
PCZoom='&Zoom';
if ispc
  PCAbort='&Abort';
  PCCancel='&Cancel';
  PCContinue='C&ontinue';
  PCFinish='&Finish';
  PCHold_graph='&Hold graph';
  PCKeyboard='&Keyboard';
  PCPause='Pa&use';
  PCPlot='&Plot';
  PCData='Fdident Data &Sheet';
  PCDev='Fdident &Developers'' Page';
  if strcmp(action,'Iteration'), action=PCIteration;
  elseif strcmp(action,'Abort'), action=PCAbort;
  elseif strcmp(action,'Cancel'), action=PCCancel;
  elseif strcmp(action,'Continue'), action=PCContinue;
  elseif strcmp(action,'Finish'), action=PCFinish;
  elseif strcmp(action,'Hold graph'), action=PCHold_graph;
  elseif strcmp(action,'Keyboard'), action=PCKeyboard;
  elseif strcmp(action,'Matlab prompt'), action=PCMatlab_prompt;
  elseif strcmp(action,'Pause'), action=PCPause;
  elseif strcmp(action,'Plot'), action=PCPlot;
  elseif strcmp(action,'Print'), action=PCPrint;
  elseif strcmp(action,'Zoom'), action=PCZoom;
  end
end
%
if isempty(htopparent)
  if strcmp(action,'initialize')
    if strcmp(items,'all')|isempty(items)
      items=['|Abort|Cancel|Continue|Finish|Hold graph|Keyboard',...
                '|Matlab prompt|Pause|Plot|Print|Zoom|'];
      if strcmp(c,'PCWIN')|strcmp(c(1:3),'MAC') %Print item not necessary
        ind=findstr(items,'Print|'); items(ind+[0:5])=[];
      end
    end
    %
    %Accelerators taken on Mac:
    %  Open-O, Close-W, Save-S, Print-P, Quit-Q
    %  Undo-Z, Cut-X, Copy-C, Paste-V, Select All-A,
    %  Window-1...9
    %
    if ispc, Acc='Label'; else Acc='Accelerator'; end
    if ispc, Acck=PCIteration; else Acck='I'; end
    if strcmp(c(1:3),'MAC'), Acck=''; end %Top-line item, no acc on Mac
    htop=uimenu(parent,'Label',ItLabel,Acc,Acck,...
        'UserData','not selected',...
        'Callback','iterctrl(''Iteration'',''on'');',...
        'tag','iteration_menu');
    if strcmp(visibility,'off'), set(htop,'visible','off'), end
    %
    if ~isempty(findstr(items,'Abort'))
      if ispc, Acck=PCAbort; else Acck='A'; end
      if strcmp(c(1:3),'MAC'), Acck='B'; end %A is taken on the Mac
      hab=uimenu(htop,'Label','Abort',Acc,Acck,...
        'CallBack','iterctrl(''Abort'');');
    end
    %
    if ~isempty(findstr(items,'Cancel'))
      if ispc, Acck=PCCancel; else Acck='C'; end
      if strcmp(c(1:3),'MAC'), Acck='I'; end %C is taken on the Mac
      hterm=uimenu(htop,'Label','Cancel',Acc,Acck,...
        'CallBack','iterctrl(''Cancel'');');
    end
    %
    if ispc, Acck=PCContinue; else Acck='U'; end %Ctrl/c is taken
    if strcmp(c(1:3),'MAC'), Acck='U'; end %C is taken on the Mac
    hcont=uimenu(htop,'Label','Continue',Acc,Acck,...
        'CallBack','iterctrl(''Continue'');');
    set(hcont,'Checked','on') %initial setting
    %
    if ~isempty(findstr(items,'Finish'))
      if ispc, Acck=PCFinish; else Acck='F'; end
      hterm=uimenu(htop,'Label','Finish',Acc,Acck,...
        'CallBack','iterctrl(''Finish'');');
    end
    %
    if ~isempty(findstr(items,'Hold graph'))
      if ispc, Acck=PCHold_graph; else Acck='H'; end
      hhold=uimenu(htop,'Label','Hold graph',Acc,Acck,...
        'CallBack','iterctrl(''Hold graph'');');
    end
    %
    if ~isempty(findstr(items,'Keyboard'))
      if ispc, Acck=PCKeyboard; else Acck='K'; end
      hkeyb=uimenu(htop,'Label','Keyboard',Acc,Acck,...
        'CallBack','iterctrl(''Keyboard'');');
    end
    %
    if ~isempty(findstr(items,'Matlab prompt'))
      if ispc, Acck=PCMatlab_prompt; else Acck='M'; end
      hprompt=uimenu(htop,'Label','Matlab prompt',Acc,Acck,...
        'CallBack','iterctrl(''Matlab prompt'');');
    end
    %
    if ~isempty(findstr(items,'Pause'))
      if ispc, Acck=PCPause; else Acck='S'; end %P is taken
      if strcmp(c(1:3),'MAC'), Acck='E'; end %S is taken on the Mac
      hpause=uimenu(htop,'Label','Pause',Acc,Acck,...
        'CallBack','iterctrl(''Pause'');');
    end
    %
    if ~isempty(findstr(items,'Print'))
      if ispc, Acck=PCPrint; else Acck='P'; end
      if strcmp(c(1:3),'MAC'), Acck=''; end
      %P is taken on Mac, for the same purpose, to print
      hprint=uimenu(htop,'Label','Print',Acc,Acck,...
        'CallBack','iterctrl(''Print'');');
    end
    %
    if ~isempty(findstr(items,'Plot'))
      if ispc, Acck=PCPlot; else Acck='T'; end
      hplot=uimenu(htop,'Label','Plot',Acc,Acck,...
        'CallBack','iterctrl(''Plot'');');
    end
    %
    if ~isempty(findstr(items,'Zoom'))
      if ispc, Acck=PCZoom; else Acck='Y'; end
      hzoom=uimenu(htop,'Label','Zoom',Acc,Acck,...
        'CallBack','iterctrl(''Zoom'');');
    end
    %
    if ispc, Acck=PCDev; else Acck='E'; end
    hwebd=uimenu(htop,...
        'label','Fdident Developers'' Page',Acc,Acck,...
        'callback','web(''http://elecwww.vub.ac.be/fdident/'');',...
        'tag','iteration_menu_dev','separator','on');

    if ispc, Acck=PCData; else Acck='D'; end
    hweb=uimenu(htop,...
        'label','Fdident Data Sheet',Acc,Acck,...
        'callback','web(''http://www.mathworks.com/products/fdident/'');',...
        'tag','iteration_menu_data','separator','off');

    if nargout>0, checked=htop; end %return handle
    return
  end %initialize
end %htopparent
%
if isempty(htop)&~strcmp(action,'initialize')
  %error('Menu does not exist')
  if nargout>0, checked='Continue'; end
  %figure(gcf)
elseif strcmp(action,'checked')
  %Menu exists, and checked item is sought
  %hchkd=findobj(htop,'Checked','on');
  eval('hchkd=findobj(htop,''Checked'',''on'');')
  checked=get(hchkd,'Label');
else
  %Action is 'initialize', or Iteration menu exists and action is not 'checked'
  Mpcmdtag='Matlab prompt';
  if ~strcmp(action,'Evaluate command')&~strcmp(action,ItLabel)
    hempw=findobj('Tag',Mpcmdtag);
    delete(hempw)
    if ~isempty(hempw), fprintf('Back from Matlab prompt menu item...\n'), end
  end
  if strcmp(action,'initialize')
    if ~isempty(visibility)
      set(htop,'visible',visibility)
    end
    if nargin<2, disp('Warning! Iteration menu already exists'), end
    iterctrl('Continue')
    if nargout>0, checked=htop; end
  elseif strcmp(action,'delete')
    delete(htop)
  elseif strcmp(action,ItLabel)|strcmp(action,'Iteration')
    if strcmp(visibility,'on')
      set(htop,'UserData','selected')
    elseif strcmp(visibility,'off')
      set(htop,'UserData','not selected')
    else %check status
      checked=get(htop,'UserData');
    end
  else %all the others
    %hchkd=findobj(htop,'Checked','on');
    eval('hchkd=findobj(htop,''Checked'',''on'');')
    set(htop,'UserData','not selected');
    %Special actions:
    if strcmp(action,'Print')|strcmp(action,PCPrint)
      print;
    elseif strcmp(action,'Zoom')|strcmp(action,PCZoom)
      feval('zoom',gcf,'on');
    elseif ~strcmp(action,'Evaluate command')
      %hchkdnew=findobj(htop,'Label',action);
      eval('hchkdnew=findobj(htop,''Label'',action);')
      if ~isempty(hchkdnew)
        set(hchkd,'Checked','off')
        set(hchkdnew,'Checked','on')
        hchkd=hchkdnew;
      else
        warning(['Nonexistent menu item ''',action,''''])
      end
    end
    if nargout>0
      checked=get(hchkd,'Label');
    end
    %
    if strcmp(action,'Matlab prompt')|strcmp(action,PCMatlab_prompt)
      cmdstr0=Mpcmdtag;
      cmdstr1='>> '; cmdstr2='M>> ';
      pos0=[20,60,520,20]; dpos=25; p1w=25;
      pos1=pos0; pos1(2)=pos1(2)-dpos; pos1(3)=p1w; pos1(4)=dpos;
      pos2=pos1; pos2(1)=pos1(1)+p1w; pos2(3)=pos0(3)-p1w;
      pos3=pos2; pos3(2)=pos2(2)-dpos; pos3(3)=pos2(3);
      fprintf('\nMatlab prompt menu item activated...\n\n')
      uicontrol('Style','text',...
        'Position',pos0,'Tag',Mpcmdtag,...
        'String',cmdstr0,'UserData',pos3);
      uicontrol('Style','text',...
        'Position',pos1,'Tag',Mpcmdtag,...
        'String',cmdstr1);
      afterevalOK=['iterctrl(''',Mpcmdtag,');'];
      afterevalOK=[...
        'set(findobj(''Tag'',''',Mpcmdtag,''',''Style'',''edit''),',...
        '''String'','''')'];
      afterevalnotOK=['fprintf([''??? '',lasterr,''\n\n''])'];
      %
      afterevalnotOK=[afterevalnotOK,';'...
        'uicontrol(''Style'',''text'',''Position'',',...
        'get(findobj(''Tag'',''',Mpcmdtag,'''',...
                ',''Style'',''text'',''String'',''',cmdstr0,'''),',...
                '''UserData''),',...
                '''String'',[''??? '',lasterr],',...
                '''UserData'',''Error!'',''Tag'',''',Mpcmdtag,''');',...
        'set(findobj(gcf,''UserData'',''Error!''),',...
                '''HorizontalAlignment'',''left'')'];
      hedit=uicontrol('Style','edit',...
        'HorizontalAlignment','left',...
        'Position',pos2,'Tag',Mpcmdtag,...
        'Callback',...
        ['delete(findobj(gcf,''UserData'',''Error!''));',...
                'disp([''',cmdstr2,''',get(findobj(''Tag'',''',Mpcmdtag,...
                ''',''Style'',''edit''),''String'')]);',...
                'eval([get(findobj(''Tag'',''',Mpcmdtag,...
                ''',''Style'',''edit''),''String''),',...
                    ''',MATLAB_COMMAND_EOK=1;''],',...
                    '''MATLAB_COMMAND_EOK=0;'');',...
                'if MATLAB_COMMAND_EOK==1, ',afterevalOK,';',...
                'else ',afterevalnotOK,'; end,',...
                'clear MATLAB_COMMAND_EOK']);
        %'Callback','iterctrl(''Evaluate command'')');
      set(hedit,'String','')
    elseif strcmp(action,'Evaluate command')
      %This would be a good solution, but would use the workspace  of iterctrl
      %hempw=findobj('Tag',Mpcmdtag,'Style','edit');
      eval('hempw=findobj(''Tag'',Mpcmdtag,''Style'',''edit'');')
      cstr=get(hempw,'String');
      delcmd=1; disp([cmdstr2,cstr]), eval([cstr,',delcmd=1;'],'delcmd=0;');
      if delcmd==1
        set(hempw,'String','')
        %iterctrl('Matlab prompt')
        %%hempw=findobj('Tag',Mpcmdtag,'Style','edit');
        %eval(['hempw=findobj(''Tag'',''',Mpcmdtag,''',''Style'',''edit'');')
      else set(hempw,'String',[cstr,'  <-Error!'])
      end
    end %Matlab prompt
  end %all other menu items
end %menu exists
%
if exist('checked')
  if ~isempty(checked)
    ind=find(checked=='&');
    if ~isempty(ind), checked(ind)=''; end
  end
end
%End of iterctrl
