function [out,fig_modal]=guirecrd(p1, p2, p3, p4, p5)
%       GUIRECRD   fdident GUI universal recorder tool
%
%       init: guirecrd('init', mode), where mode can be:
%            'demo', 'recorder', or 'development'
%       recorder command line options (commands are NOT case sensitive):
%            guirecrd('LoadHist', filename, [varname])  load history file, do not start
%            guirecrd('New')                            clear history file
%            guirecrd('AddHistNumber',N)                add history number to name
%            guirecrd('PlayHist')                       start history from current line
%            guirecrd('PlayHist', filename, [varname])  load and start history from line 1
%            guirecrd('GotoAction', index)              go to specified action
%            guirecrd('GotoEnd')                        jump to the end of record (after the last instruction)
%            guirecrd('SetContinuous', 0|1)             set Continuous cb 
%            guirecrd('SetEmulatemouse', 0|1)           set Emulate Mouse cb
%            guirecrd('SetLectureMode', 0|1)            set Lecture Mode cb
%            guirecrd('SetDiscardErrorChk', 0|1)        set Discard Error Check cb
%            guirecrd('SetTestPlotMode', 0|1)           disable/enable test plots (in test mode only)
%            guirecrd('SetTestMode', 0|1|2)             set test mode (0:off, 1:normal, 2:quick)
%            guirecrd('SetMouseSpeed', 1|2|3)           set mouse emulation speed (fast|slower|slow)
%            guirecrd('RecordOn')                       switch to recording mode
%            guirecrd('Stop')                           stop playback or recording
%            guirecrd('Save')                           save actual record

%      Other commands (for demo purposes):
%            guirecrd('SetInfoField', cellstr)          set text in info field

%      Other commands (for internal use):
%            guirecrd('GetHistData')                    return actual record
%            guirecrd('GetLectureMode')                 return lecture mode flag
%            guirecrd('GetTestPlotMode')                return testplot mode flag
%            guirecrd('GetTestMode')                    return test mode flag (0,1,2)
%            guirecrd('GetSourceName')                  return history file name
%            guirecrd('GetActionIndex')                 return action index
%            guirecrd('GetContinuous')                  return Continuous state
%            guirecrd('GetDiscardPause')                return DiscardPause state

%      Accepted commands (Yellow Cmd):
%            MATLAB Cmd + Param                         matlab command
%            Jump       + Param                         abs. jump (e.g. Param=2) or rel. jump (+2)
%            PrivateCB  [+ Param]                       private callback, used to animate 'foreign' windows
%            Other GUI commands                         FDTool GUI action, Cmd field is used only in special cases


%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Dec-2003, IK

if exist('gui_recorder.m')
  argin={};
  if nargin>=1, argin=[{p1},{'fdtool'}]; end
  if nargin>=2, argin=[argin,{p2}]; end 
  if nargin>=3, argin=[argin,{p3}]; end 
  if nargin>=4, argin=[argin,{p4}]; end 
  if nargin>=5, argin=[argin,{p5}]; end 
  %
  if nargout==0, gui_recorder(argin{:});
  elseif nargout==1, out=gui_recorder(argin{:});
  elseif nargout==2, [out,fig_modal]=feval('gui_recorder',argin{:});
  else error('Something wrong in guirecrd')
  end
  %warning('Recorder call redirected from inside fdident to separate recorder')
  return
end

LatestVersion='1.106';

%Construct list of history files used
persistent hfiles
if ~exist('hfiles')|isempty(hfiles), hfiles=cell(0,0); end
%mlock

if nargout>=1, out=[]; end, if nargout>=2, fig_modal=[]; end % Modified, D.T.
Me='fdtool_recorder_fig';
myfig=findall(0, 'tag', Me);
myfcn='guirecrd';
if nargin==0, p1='init'; end

if strcmp(p1, 'init')
   if nargin<2, p2='demo'; end
   
   if ~(strcmp(p2, 'development')|strcmp(p2, 'recorder')|strcmp(p2, 'demo'))
      error(['Recorder init failed: bad mode ' p2])
   end
   
   set(0, 'units', 'pixels')
   scr=get(0, 'screensize');
   h=findall(0, 'tag', Me);
   %   delete(h), h='';
   if ~isempty(h)
      if strcmp(RecorderMode(h), p2) % same mode
         figure(h)
         return
      else % different mode, delete previous
         guirecrd('close');
      end
   end
   figpos=windspos('recorder');
   wid=figpos(3);
   develcolor='m';
   
   f=figure('units', 'pixels',...
      'position', figpos,...
      'integerhandle', 'off',...
      'handlevisibility','off', ...
      'numbertitle', 'off',...
      'nextplot','replacechildren',...  
      'color', get(0, 'defaultuicontrolbackgroundcolor'),...
      'menubar', 'none',...
      'resize', 'off', ...
      'visible', 'off', ...
      'closerequestfcn', 'fdtool(''callback'',''guirecrd'',''close'')',...
      'tag', Me);
   if strncmp(version,'5',1), set(f,'position',figpos), end %fix in 5.3
   myfig=f;
   fdwindef(myfig); % set default Comment window props
   
   guidtawr(Me, 'recordermode', 'direct', p2)  % set recordermode
   
   switch RecorderMode(myfig)
   case 'development'
      title='Recorder for FDTool - Development Mode';
   case 'recorder'
      title='Recorder for FDTool';
   case 'demo'
      title='FDTool Demo Playback'; 
   end
   set(myfig, 'name', title)
   
   frame1=uicontrol('parent', f,...
      'style', 'frame',...
      'position', [5 5 wid-10 70],...
      'tag', 'fdtool_recorder_frame1');
   
   pbwid1=30; pbwid2=50; pbh=30;
   
   beginpb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', '<<', ...
      'tooltipstring', 'Rewind', ...
      'position', [15, 10, pbwid1, pbh],...
      'callback', 'fdtool(''callback'',''guirecrd'',''begin'')',...
      'tag', 'fdtool_recorder_beginpb');
   backpb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', '<', ...
      'tooltipstring', 'Rewind one step', ...
      'position', [50, 10, pbwid1, pbh],...
      'callback', 'fdtool(''callback'',''guirecrd'',''back'')',...
      'tag', 'fdtool_recorder_backpb');
   playpb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', 'PLAY', ...
      'tooltipstring', 'Play history', ...
      'position', [90, 10, pbwid2, pbh],...
      'callback', 'fdtool(''callback'',''guirecrd'',''play'')',...
      'tag', 'fdtool_recorder_playpb');
   stoppb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', 'STOP', ...
      'tooltipstring', 'Stop play or record', ...
      'position', [145, 10, pbwid2, pbh],...
      'callback', 'fdtool(''callback'',''guirecrd'',''userstop'')',...
      'tag', 'fdtool_recorder_stoppb');
   forwardpb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', '>', ...
      'tooltipstring', 'Step forward', ...
      'position', [205, 10, pbwid1, pbh],...
      'callback', 'fdtool(''callback'',''guirecrd'',''forward'')',...
      'tag', 'fdtool_recorder_forwardpb');
   endpb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', '>>', ...
      'tooltipstring', 'Go to end of recording', ...
      'position', [240, 10, pbwid1, pbh],...
      'callback', 'fdtool(''callback'',''guirecrd'',''end'')',...
      'tag', 'fdtool_recorder_endpb');
   recpos=[wid-pbwid2-25, 10, pbwid2+10, pbh];
   recordpb=uicontrol('parent', f,...
      'style', 'pushbutton',...
      'string', 'RECORD', ...
      'tooltipstring', 'Start recording', ...
      'position', recpos,...
      'callback', 'fdtool(''callback'',''guirecrd'',''record'')',...
      'userdata', 0,...
      'tag', 'fdtool_recorder_recordpb');
   statpos=[240+pbwid1+10, 10, wid-pbwid2-25-240-pbwid1-20, pbh];
   statusfr=uicontrol('parent', f,...
      'style', 'frame',...
      'string', '', ...
      'position', statpos,...
      'callback', '',...
      'tag', 'fdtool_recorder_statusframe');
   statustext=uicontrol('parent', f,...
      'style', 'text',...
      'string', '', ...
      'horizontalalignment', 'center', ...
      'tooltipstring', 'Status', ...
      'position', statpos+[1 1 -2 -2],...
      'callback', '',...
      'tag', 'fdtool_recorder_statustext');
   
   
   edwid=150; edhig=20;
   edit2=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Selection type (normal/open/alt)', ...   
      'string', '', ...
      'position', [60 85 edwid-80 edhig],...
      'max', 2,... %by Zoltan
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  2)',...
      'tag', 'fdtool_recorder_edit2');
   edit1=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Parameter (if required)', ...   
      'string', '', ...
      'max', 2,... % by zoltan
      'position', [60 110 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  1)',...
      'tag', 'fdtool_recorder_edit1');
   
   edit12=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Command', ...   
      'string', '', ...
      'position', [60 135 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  12)',...
      'enable', 'inactive', ...
      'tag', 'fdtool_recorder_edit12');
   edit13=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Name of the action window', ...   
      'string', '', ...
      'position', [60 160 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  13)',...
      'enable', 'inactive', ...
      'tag', 'fdtool_recorder_edit13');
   
   
   edit3=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Target object''s tag', ...   
      'string', '', ...
      'position', [60 185 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  3)',...
      'tag', 'fdtool_recorder_edit3');
   edit4=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Target window''s tag', ...   
      'string', '', ...
      'position', [60 210 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  4)',...
      'tag', 'fdtool_recorder_edit4');
   edit5=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Target function''s name', ...   
      'string', '', ...
      'position', [60 235 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'', 5)',...
      'tag', 'fdtool_recorder_edit5');
   edit6=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Command (internal)', ...   
      'string', '', ...
      'position', [60 260 edwid edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'', 6)',...
      'tag', 'fdtool_recorder_edit6');
   
   edit7=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'string', '', ...
      'tooltipstring', 'Record position (Action # in history)', ...   
      'position', [60 285 40 edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'', 7)',...
      'tag', 'fdtool_recorder_edit7');
   
   txwid=50; txhig=edhig;
   text2=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'SelType', ...
      'position', [5 85 txwid txhig],...
      'tag', 'text2');
   text1=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Param', ...
      'position', [5 110 txwid txhig],...
      'tag', 'text1');
   
   
   text21=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Cmd', ...
      'position', [5 135 txwid txhig],...
      'tag', 'text21');
   text22=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Window', ...
      'position', [5 160 txwid txhig],...
      'tag', 'text22');
   
   text3=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'CurObj', ...
      'position', [5 185 txwid txhig],...
      'foregroundcolor', develcolor, ...
      'tag', 'text3');
   text4=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Win', ...
      'position', [5 210 txwid txhig],...
      'foregroundcolor', develcolor, ...
      'tag', 'text4');
   text5=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Fcn', ...
      'position', [5 235 txwid txhig],...
      'foregroundcolor', develcolor, ...
      'tag', 'text5');   
   text6=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Cmd', ...
      'position', [5 260 txwid txhig],...
      'foregroundcolor', develcolor, ...
      'tag', 'text6');  
   text7=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'right',...
      'string', 'Index', ...
      'tooltipstring', 'Record position (Action # in history)', ...   
      'position', [5 285 txwid txhig],...
      'tag', 'text7');  
   
   contcb=uicontrol('parent', f,...
      'style', 'checkbox',...
      'string', 'Continuous', ...
      'tooltipstring', 'Continuous or step-by-step execution', ...
      'value', 1,...
      'position', [15 50 75 txhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''cont/step'')',...
      'tag', 'fdtool_recorder_contcb');
   
   emulatecb=uicontrol('parent', f,...
      'style', 'checkbox',...
      'string', 'Emulate mouse motion', ...
      'tooltipstring', 'Mouse emulation on/off', ...
      'value', 0,...
      'position', [100 50 130 txhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''emulatecb'')',...
      'tag', 'fdtool_recorder_emulcb');
   
   speedpop=uicontrol('parent', f,...
      'style', 'popup',...
      'string', {'Fast mouse', 'Slower mouse', 'Slow mouse'}, ...
      'tooltipstring', 'Speed of mouse emulation', ...
      'value', 1,...
      'position', [240 50 100 txhig],...
      'callback', '',...
      'tag', 'fdtool_recorder_speedpop');
   
   discardcb=uicontrol('parent', f,...
      'style', 'checkbox',...
      'string', 'Discard pause', ...
      'tooltipstring', 'Discard pause flag', ...
      'value', 0,...
      'position', [350 50 100 txhig],...
      'callback', '',...
      'tag', 'fdtool_recorder_discardcb');
   
   lecturecb=uicontrol('parent', f,...
      'style', 'checkbox',...
      'string', 'Lecture Mode', ...
      'tooltipstring', 'In Lecture Mode the Recorder does not jump forward when stopped', ...
      'value', 0,...
      'position', [450 50 100 txhig],...
      'callback', '',...
      'tag', 'fdtool_recorder_lecturecb');
   
   discardcb2=uicontrol('parent', f,...
      'style', 'checkbox',...
      'string', 'Discard ErrChk', ...
      'tooltipstring', 'Discard error checking', ...
      'value', 0,...
      'position', [240 285 100 txhig],...
      'callback', '',...
      'foregroundcolor', develcolor, ...
      'tag', 'fdtool_recorder_discardcb2');
   
   plotcb=uicontrol('parent', f,...
      'style', 'checkbox',...
      'string', 'Test plot', ...
      'tooltipstring', 'Test print enable/disable (only in test mode)', ...
      'value', 0,...
      'position', [350 285 100 txhig],...
      'callback', '',...
      'foregroundcolor', develcolor, ...
      'tag', 'fdtool_recorder_plotcb');
   
   testmodepop=uicontrol('parent', f,...
      'style', 'popupmenu',...
      'string', {'Test off', 'Normal Test', 'Quick Test'}, ...
      'tooltipstring', 'Test mode', ...
      'value', 1,...
      'position', [450 285 130 txhig],...
      'callback', '',...
      'foregroundcolor', develcolor, ...
      'tag', 'fdtool_recorder_testmodepop');
   
   infoedit=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'tooltipstring', 'Textual information', ...   
      'string', '', ...
      'position', [240 85 350 220-85],...
      'Min', 0, 'Max',2,...   
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  8)',...
      'tag', 'fdtool_recorder_edit8');
   
   noteedit=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'string', '', ...
      'tooltipstring', 'Note (only in development mode)', ...
      'position', [240 230 350 edhig],...
      'Min', 0, 'Max',1,...   
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  14)',...
      'backgroundcolor', 'y', ...
      'tag', 'fdtool_recorder_edit14');
   
   debugstoptxt=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'left',...
      'string', 'ErrStatus:', ...
      'position', [240 260 60 txhig],...
      'foregroundcolor', develcolor, ...
      'tag', 'text9');
   debugstop=uicontrol('parent', f,...
      'style', 'popup',...
      'horizontalalignment', 'left',...
      'string', {'OK','Warning','Error', 'Disabled'}, ...
      'tooltipstring', 'Required error status after executing command', ...
      'position', [290 260 70 edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  9)',...
      'tag', 'fdtool_recorder_edit9');
   debugfcntxt=uicontrol('parent', f,...
      'style', 'text',...
      'horizontalalignment', 'left',...
      'string', 'CheckFcn:', ...
      'position', [370 260 50 txhig],...
      'foregroundcolor', develcolor, ...
      'tag', 'text10');
   debugstoped=uicontrol('parent', f,...
      'style', 'edit',...
      'horizontalalignment', 'left',...
      'string', '', ...
      'tooltipstring', 'Check Function entry sting, empty means no ChkFcn', ...
      'position', [430 260 70 edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  10)',...
      'tag', 'fdtool_recorder_edit10');
   
   pausecb=uicontrol('parent', f,...
      'style', 'check',...
      'horizontalalignment', 'left',...
      'string', 'Pause', ...
      'tooltipstring', 'Pause before executing command', ...
      'position', [140 85 70 edhig],...
      'callback', 'fdtool(''callback'',''guirecrd'',''edit'',  11)',...
      'tag', 'fdtool_recorder_edit11');
   
   playled=uicontrol('parent', f,...
      'style', 'frame',...
      'tooltipstring', 'Play LED', ...   
      'position', [90+5 44 pbwid2-10 7],...
      'backgroundcolor', 'default',...
      'tag', 'fdtool_recorder_playled');
   recordled=uicontrol('parent', f,...
      'style', 'frame',...
      'tooltipstring', 'Record LED', ...   
      'position', [recpos(1)+5 44 recpos(3)-10 7],...
      'backgroundcolor', 'default',...
      'tag', 'fdtool_recorder_recordled');
   
   win_name='fdtool_recorder';
   
   menu_file=uimenu(myfig, 'label','&File ','posit',1);
   tag=[win_name '_menu_file_new'];
   menu_file_new=uimenu(menu_file,...
      'label',        '&New',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''delete'', ''all'',''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   tag=[win_name '_menu_file_load'];
   menu_file_load=uimenu(menu_file,...
      'label',        '&Load history...',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''load'',''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   tag=[win_name '_menu_file_save'];
   menu_file_save=uimenu(menu_file,...
      'label',        '&Save history',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''save'',''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   tag=[win_name '_menu_file_saveas'];
   menu_file_saveas=uimenu(menu_file,...
      'label',        'Save history &as...',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''saveas'',''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
    
   tag=[win_name '_menu_file_startrep'];
   menu_file_startrep=uimenu(menu_file,...
      'label',        'Start report',...
      'tag', tag,...
      'enable',   'on'); 
   %tag=[win_name '_menu_file_startrep_simple'];
   %menu_file_startrep_auto=uimenu(menu_file_startrep,...
   %   'label',        'with UserLevel Simple',...
   %   'callback',        ['fdtool(''callback'',''guirecrd'',''startrep'',''' tag ''')'],...
   %   'tag', tag,...
   %   'enable',   'on'); 
   tag=[win_name '_menu_file_startrep_auto'];
   menu_file_startrep_auto=uimenu(menu_file_startrep,...
      'label',        'with UserLevel Automatic (default)',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''startrep'',''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   tag=[win_name '_menu_file_startrep_inter'];
   menu_file_startrep_inter=uimenu(menu_file_startrep,...
      'label',        'with UserLevel Interactive',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''startrep'',''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   if guiinfos('isdevelopment')
     tag=[win_name '_menu_file_startrep_adv'];
     menu_file_startrep_adv=uimenu(menu_file_startrep,...
       'label',        'with UserLevel Advanced',...
       'callback',        ['fdtool(''callback'',''guirecrd'',''startrep'',''' tag ''')'],...
       'tag', tag,...
       'enable',   'on'); 
    end
   
    tag=[win_name '_menu_file_recstyle'];
    menu_file_recstyle=uimenu(menu_file,...
      'label','Change recorder style',...
      'tag', tag,...
      'enable','on',...
      'separator','on'); 
    tag=[win_name '_menu_file_recstyle_demo'];
    menu_file_recstyle_auto=uimenu(menu_file_recstyle,...
      'label','to demo mode',...
      'callback',['fdtool(''callback'',''guirecrd'',''recstyle'',''' tag ''')'],...
      'tag', tag,...
      'enable','on'); 
    tag=[win_name '_menu_file_recstyle_standard'];
    menu_file_recstyle_inter=uimenu(menu_file_recstyle,...
      'label','to standard mode',...
      'callback',['fdtool(''callback'',''guirecrd'',''recstyle'',''' tag ''')'],...
      'tag', tag,...
      'enable','on'); 
    if guiinfos('isdevelopment')
      tag=[win_name '_menu_file_recstyle_dev'];
      menu_file_recstyle_adv=uimenu(menu_file_recstyle,...
        'label','to development mode',...
        'callback',['fdtool(''callback'',''guirecrd'',''recstyle'',''' tag ''')'],...
        'tag', tag,...
        'enable','on'); 
   end
   
   tag=[win_name '_menu_file_print'];
   menu_file_print_recorder=uimenu(menu_file,...
      'label','Print Recorder',...
      'tag', tag,...
      'separator','on');
   tag=[win_name '_menu_file_print'];
   menu_file_print=uimenu(menu_file_print_recorder,...
      'label','To printer',...
      'callback', ['fdtool(''callback'',''guirecrd'',''recorder_print'',''' tag ''');'],...
      'tag', tag,...
      'separator','on');
   tag=[win_name '_menu_file_print_ps'];
   menu_file_print_ps=uimenu(menu_file_print_recorder,...
      'label','To PS file',...
      'callback', ['fdtool(''callback'',''guirecrd'',''recorder_print_ps'',''' tag ''');'],...
      'tag', tag,...
      'separator','off');
   tag=[win_name '_menu_file_print_dialog'];
   menu_file_print_dialog=uimenu(menu_file_print_recorder,...
      'label','Through dialog window',...
      'callback', ['fdtool(''callback'',''guirecrd'',''recorder_print_dialog'',''' tag ''');'],...
      'tag', tag,...
      'separator','off');
   
   tag=[win_name '_menu_file_print_last'];
   menu_file_print_last=uimenu(menu_file,...
      'label','Print last figure',...
      'tag', tag,...
      'separator','off');
   tag=[win_name '_menu_file_print_last_pr'];
   menu_file_print_last_pr=uimenu(menu_file_print_last,...
      'label','To printer',...
      'callback', ['fdtool(''callback'',''guirecrd'',''recorder_print_last_pr'',''' tag ''');'],...
      'tag', tag,...
      'separator','off');
   tag=[win_name '_menu_file_print_last_ps'];
   menu_file_print_last_ps=uimenu(menu_file_print_last,...
      'label','To PS file',...
      'callback', ['fdtool(''callback'',''guirecrd'',''recorder_print_last_ps'',''' tag ''');'],...
      'tag', tag,...
      'separator','off');
   tag=[win_name '_menu_file_print_last_ps'];
   menu_file_print_last_dialog=uimenu(menu_file_print_last,...
      'label','Through dialog window',...
      'callback', ['fdtool(''callback'',''guirecrd'',''recorder_print_last_dialog'',''' tag ''');'],...
      'tag', tag,...
      'separator','off');
   
   tag='fdtool_recorder_menu_close';
   menu_file_close=uimenu(menu_file,...
      'label',        '&Close',...
      'callback',[        'fdtool(''callback'',''guirecrd'',''close'', ''' tag ''')'],...
      'tag', tag, ...
      'enable',   'on',...
      'separator','on'); 
   tag='fdtool_recorder_menu_destroy';
   menu_file_destroy=uimenu(menu_file,...
      'label',        '&Destroy',...
      'callback','delete(findall(0,''tag'',''fdtool_recorder_fig''))',...
      'tag', tag, ...
      'enable',   'on',...
      'separator','off'); 
   
   tag='fdtool_recorder_menu_recent';
   menu_file_recent=uimenu(menu_file,...
      'label',        '&Recent records',...
      'tag', tag, ...
      'enable',   'on',...
      'visible','off',...
      'separator','on'); 
   
   menu_edit=uimenu(myfig, 'label','&Edit ','posit',2);
   tag='fdtool_recorder_menu_edit_copy';
   menu_edit_copy=uimenu(menu_edit,...
      'label',        '&Copy',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''copy'', ''' tag ''')'],...
      'tag', tag,...
      'enable',   'on');
   tag='fdtool_recorder_menu_edit_cut';
   menu_edit_cut=uimenu(menu_edit,...
      'label',        'Cu&t',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''delete'', ''this, toclipboard'' , ''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   tag='fdtool_recorder_menu_edit_cutandadd';
   menu_edit_cut=uimenu(menu_edit,...
      'label',        'Cut and &Add',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''delete'', ''this, addtoclipboard'' , ''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   tag='fdtool_recorder_menu_edit_paste';
   menu_edit_paste=uimenu(menu_edit,...
      'label',        '&Paste',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''paste'', ''' tag ''')'],...
      'tag', tag,...
      'enable',   'on');
   tag='fdtool_recorder_menu_edit_delete_actual';
   menu_edit_delete=uimenu(menu_edit,...
      'label',        '&Delete',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''delete'', ''this'', ''' tag ''')'],...
      'tag', tag,...
      'enable',   'on'); 
   
   if guiinfos('isdevelopment')
     tag='fdtool_recorder_menu_edit_copy_to_history';
     menu_edit_move=uimenu(menu_edit,...
       'label',        '&Copy to ''history''',...
       'callback',        ['fdtool(''callback'',''guirecrd'',''copy'', ''this_action_to_history'',''' tag ''')'],...
       'tag', tag,...
       'separator','on',...
       'enable',   'on');
     tag='fdtool_recorder_menu_edit_move';
     menu_edit_move=uimenu(menu_edit,...
       'label',        '&Move to ''history''',...
       'callback',        ['fdtool(''callback'',''guirecrd'',''move'', ''this_action_to_history'',''' tag ''')'],...
       'tag', tag,...
       'separator','off',...
       'enable',   'on');
     tag='fdtool_recorder_menu_edit_clear';
     menu_edit_clear=uimenu(menu_edit,...
       'label',        'Clear ''&history''',...
       'callback',        ['fdtool(''callback'',''guirecrd'',''clear'', ''' tag ''')'],...
       'tag', tag,...
       'enable',   'on');
     tag='fdtool_recorder_menu_edit_insert';
     menu_edit_insert=uimenu(menu_edit,...
       'label',        '&Insert ''history''',...
       'callback',        ['fdtool(''callback'',''guirecrd'',''insert'', ''' tag ''')'],...
       'tag', tag,...
       'enable',   'on');
   end

   tag='fdtool_recorder_menu_edit_insert_cmd';
   menu_edit_insertnop=uimenu(menu_edit,...
      'label',        '&Insert MATLAB Command',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''insertNOP'', ''' tag ''')'],...
      'tag', tag,...
      'separator', 'on',...
      'enable',   'on');    
   tag='fdtool_recorder_menu_edit_insert_jmp';
   menu_edit_insertjump=uimenu(menu_edit,...
      'label',        'Insert &Jump',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''insertJUMP'', ''' tag ''')'],...
      'tag', tag,...
      'separator', 'off',...
      'enable',   'on');    
   
   if guiinfos('isdevelopment')
      menu_editbox=uimenu(myfig, 'label','Comment&box ');
      tag=[win_name '_menu_commentbox_copyall'];
      menu_editbox_copyall=uimenu(menu_editbox,...
         'label',        '&Copy all',...
         'callback',        ['fdtool(''callback'',''guirecrd'',''editbox'', ''copyall'', ''' tag ''')'],...
         'tag', tag,...
         'enable',   'on'); 
      tag=[win_name '_menu_commentbox_cutall'];
      menu_editbox_cutall=uimenu(menu_editbox,...
         'label',        'C&ut all',...
         'callback',        ['fdtool(''callback'',''guirecrd'',''editbox'', ''cutall'', ''' tag ''')'],...
         'tag', tag,...
         'enable',   'on'); 
      tag=[win_name '_menu_commentbox_replaceall'];
      menu_editbox_replaceall=uimenu(menu_editbox,...
         'label',        '&Replace all',...
         'callback',        ['fdtool(''callback'',''guirecrd'',''editbox'', ''replaceall'', ''' tag ''')'],...
         'tag', tag,...
         'userdata','',...
         'enable',   'on'); 
      tag=[win_name '_menu_commentbox_export'];
      menu_editbox_export=uimenu(menu_editbox,...
         'label','&Export text',...
         'callback',['fdtool(''callback'',''guirecrd'',''editbox'', ''export'', ''' tag ''')'],...
         'tag', tag,...
         'separator','on',...
         'enable',   'on'); 
      tag=[win_name '_menu_commentbox_import'];
      menu_editbox_import=uimenu(menu_editbox,...
         'label',        '&Import text',...
         'callback',['fdtool(''callback'',''guirecrd'',''editbox'', ''import'', ''' tag ''')'],...
         'tag', tag,...
         'enable',   'on'); 
      guirecrd('SetEmulatemouse', 0);
   end
   
   menu_window=uimenu(f,...
      'label','&Window ',...
      'Callback', ['winmenu(findall(0, ''tag'', ''' Me '''))'],...
      'tag','winmenu');   
   
   menu_help=uimenu(myfig, 'label','&Help');
   menu_help_fdid=uimenu(menu_help,...
      'label',        '&Fdident GUI',...
      'callback',        ['fdtool(''callback'',''helpmgr'',''ui_help_fdid'',''guirecrd'', ' ...
         '''fdtool_recorder_menu_help_fdid'')'],...
      'tag',                ['fdtool_recorder' '_menu_help_fdid']);
   
   menu_help_this=uimenu(menu_help,...
      'label',        '&This window',...
      'callback',        ['fdtool(''callback'',''helpmgr'',''ui_help_this'',''guirecrd'', ' ...
         '''fdtool_recorder' '_menu_help_this'')'],...
      'tag',                ['fdtool_recorder' '_menu_help_this']);
   
   menu_help_object=uimenu(menu_help,...
      'label',        'On &Object',...
      'callback',        ['fdtool(''callback'',''guirecrd'',''ui_help_object'',''guirecrd'', ' ...
         '''fdtool_recorder_menu_help_object'')'],...
      'tag',                ['fdtool_recorder' '_menu_help_object'],...
      'separator','on');   
   
   
   
   history={}; index=1; % init empty histdata
   histdata.history=history; histdata.index=index;
   guidtawr(Me, 'RECORDERDATA', 'direct', histdata)  
   guirecrd('cont/step'); % init pb srings
   [out,fig_modal]=guirecrd('stop'); % init leds		% Modified, D.T.
   %guirecrd('close'); % close window
   history=updatefig(history, index, myfig);
   
   % init help
   helpmgr('init_help', '', myfcn, myfig );
   
   switch p2
   case 'demo'
      % hide unnecessary objs   
      
      %discardcb: discard pause
      set([text1, text2, text3, text4, text5, text6, text7, ...
            edit1, edit2, edit3, edit4, edit4, edit5, edit6, edit7, ...
            debugstoptxt, debugstop, debugfcntxt, debugstoped, pausecb, ...
            discardcb2, plotcb, testmodepop, edit12, edit13, text21, text22, noteedit], ...
         'visible', 'off')
      
      pos=get(frame1, 'position');
      edpos=[pos(1), pos(2)+pos(4)+5, pos(3), 200];
      set(infoedit, 'position', edpos, 'enable', 'inactive')
      set([menu_file_new, menu_file_load, menu_file_saveas, menu_file_save,...
          menu_file_startrep,...
          menu_edit_copy, menu_edit_cut, menu_edit_paste, menu_edit_delete,...
          menu_edit_insertnop, menu_edit_insertjump], 'enable', 'off')
      set([backpb, forwardpb, endpb, recordpb], 'enable', 'off')
      set(contcb, 'enable', 'off')
      set(discardcb2, 'value', 1); % no error check enabled
      set(speedpop, 'value', 2); % set slower mode
   case 'development'
      % slightly bigger figure
      pos=get(myfig, 'position');
      pos(4)=320;
      set(myfig, 'position', pos);
      
   case 'recorder'
      set(...
         [ text3, text4, text5, text6,  ...
            edit3, edit4, edit4, edit5, edit6, noteedit, ...
            debugstoptxt, debugstop, debugfcntxt, debugstoped, ...
            discardcb2, plotcb, testmodepop], ...
         'visible', 'off')
      set(discardcb2, 'value', 1); % no error check enabled
      pos=get(edit13, 'position'); set(edit7, 'position', pos+[0 35 -100 0 ])
      pos=get(text22, 'position'); set(text7, 'position', pos+[0 35 0 0 ])
      
      % slightly smaller figure
      pos=get(myfig, 'position');
      pos(4)=240;
      set(myfig, 'position', pos);
   end
   DisplayName(myfig);
   set(myfig, 'visible', 'on')
   winmenu(myfig)
   fdtool('status', 'Action recorder ready.')
else % not init commands
   
   % ------------------------- COMMANDS NOT UPDATING HISTORY
   
   if strcmp(p1, 'status')
      stattxt=findobj(allchild(myfig), 'flat', 'tag', 'fdtool_recorder_statustext');
      statfr=findobj(allchild(myfig), 'flat', 'tag', 'fdtool_recorder_statusframe');
      glstatus(myfig, stattxt, statfr, p2)
      set(stattxt, 'horizontalalignment', 'center')
      return
      
   elseif strcmp(p1,'sethistname')
     if nargin>=2
       ind=strmatch(p2,hfiles);
       if ~isempty(ind), hfiles(ind)=[]; end
       hfiles=[{p2};hfiles];
     else
       ind=length(hfiles);
     end
     hr=findobj(myfig,'type','uimenu','tag','fdtool_recorder_menu_recent');
     hrc=get(hr,'children');
     delete(hrc);
     if ~isempty(hfiles)
       if length(hfiles)>10, hfiles=hfiles(1:10); end
       for ii=1:length(hfiles)
         if ii==1, set(hr,'visible','on'), end
         ind=findstr(' (',hfiles{ii});
         if isempty(ind)
           %ind=findstr('(',hfiles{ii});
           ind=0;
           indv=ind+1;
         else
           indv=ind+2;
         end
         if isempty(hfiles{ii}(1:ind-1))
           cbstr=['fdtool(''callback'',''guirecrd'',''loadhist_recorder'',''',...
               hfiles{ii}(indv:end),''');'];
         else
           cbstr=['fdtool(''callback'',''guirecrd'',''loadhist_recorder'',''',...
               hfiles{ii}(1:ind-1),''',''',hfiles{ii}(indv:end-1),''');'];
         end
         uimenu(hr,...
           'label',hfiles{ii},...
           'callback',cbstr,...
           'separator','off');
       end
       if ii>=1
         cbstr=['fdtool(''callback'',''guirecrd'',''clearhistfiles'');'];
         uimenu(hr,...
           'label','Clear list of records',...
           'callback',cbstr,...
           'separator','on');
       end
     end
     
   elseif strcmp(p1,'clearhistfiles')
     hr=findobj(myfig,'type','uimenu','tag','fdtool_recorder_menu_recent');
     hrc=get(hr,'children');
     delete(hrc);
     set(hr,'visible','off')
     hfiles=cell(0,0);
     
   elseif strcmp(p1, 'insertNOP')   
      nop=struct('Cmd', 'MATLAB Cmd', 'Fcn', '', 'Win', '', ...
         'CurObj', 'MATLAB Command', 'SelType', '', 'XParam', '');
      guirecrd('addhist', nop, 'nostep');
			if (nargin==2)&isstr(p2)&~strcmp(p2,'fdtool_recorder_menu_edit_insert_cmd')
				he=findobj(allchild(myfig),'tag','fdtool_recorder_edit1');
				set(he,'string',p2)
			else
				guirecrd('status', ['$yFill in the Parameter field with a MATLAB command.']);
			end
			return
      
   elseif strcmp(p1, 'insertJUMP')
     %vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
      nop=struct('Cmd', 'Jump', 'Fcn', '', 'Win', '', ...
        'CurObj', 'Jump', 'SelType', '', 'XParam', '+2');
      %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      guirecrd('addhist', nop, 'nostep');
      guirecrd('status', ['$yFill in the Parameter field with absolute or relative jump index.']);
      return
            
   elseif strcmp(p1, 'paste')
      comm=guidtard(Me, 'RECORDER_CLIPBOARD');
      if ~isempty(comm)
         % guirecrd('addhist', comm, 'paste, nostep');  % index is not increased
         guirecrd('addhist', comm, 'paste');
      end
      return
      
   elseif strcmp(p1, 'insert')
      evalin('base',['if ~exist(''history''), history={}; end,',sprintf('\n'),...
          'fdtool(''callback'',''guidtawr'',''fdtool_recorder_fig'',',...
          '''history_tmp'',''direct'',history)'])
      comm=guidtard(Me,'history_tmp');
      if ~isempty(comm)
        % guirecrd('addhist', comm, 'paste, nostep');  % index is not increased
        for ii=1:length(comm)
          fn=fieldnames(comm{ii});
          if ~isequal(sort(fn),sort({'Cmd';
              'Fcn';
              'Win';
              'CurObj';
              'SelType';
              'XParam';
              'Info';
              'DebugInfo';
              'Stop';
              'ObjName';
              'WinName';
              'Note'}))
            error('history field names are wrong')
          end
          guirecrd('addhist', comm{ii}, 'paste');
        end
      end
      return

   elseif strcmpi(p1, 'close')
      histdata=guidtard(Me, 'RECORDERDATA');
      if isstruct(histdata), history=histdata.history;
      else history=[];
      end
      if length(history)>0
         figure(myfig)
         answ=SaveIfNeeded(myfig, history);
         if strcmp(answ,'Cancel'), return, end
      end
      try
         guiclose(Me)
      catch
         1;
      end
      fdtool('status', 'Recorder closed')
      return
      
      
   elseif strcmp(p1, 'record')|strcmp(p1, 'RecordOn')
      guirecrd('status', 'Record of FDTool Actions is on...');
      fdtool('status', '$yRecord of FDTool Actions is on...')
      c=allchild(myfig);
      hstop=findobj(c,'tag', 'fdtool_recorder_stoppb');
      set(hstop, 'enable', 'on');
      
      hrec=findobj(c, 'tag', 'fdtool_recorder_recordpb');
      hplay=findobj(c, 'tag', 'fdtool_recorder_playpb');
      hled=findobj(c, 'flat', 'tag', 'fdtool_recorder_recordled');
      hs(1)=findobj(c,'tag', 'fdtool_recorder_beginpb');
      hs(2)=findobj(c,'tag', 'fdtool_recorder_backpb');
      hs(3)=findobj(c,'tag', 'fdtool_recorder_forwardpb');
      hs(4)=findobj(c,'tag', 'fdtool_recorder_endpb');
      if get(hrec, 'userdata') % already in record mode
         
      else
         set(hrec, 'userdata', 1)
         set(hled, 'backgroundcolor', 'r')
         set([hs, hplay, hrec], 'enable', 'off')
      end
      
   elseif strcmp(p1, 'emulatecb')
      h=findobj(myfig, 'tag', 'fdtool_recorder_emulcb');
      h2=findobj(myfig, 'tag', 'fdtool_recorder_speedpop');
      if get(h, 'value')
         set(h2, 'enable', 'on')
      else
         set(h2, 'enable', 'off')
      end
      
   elseif strcmp(p1, 'cont/step')
      c=allchild(myfig);
      hcont=findobj(c, 'flat','tag', 'fdtool_recorder_contcb');
      cont=get(hcont, 'value');
      hplay=findobj(c, 'flat','tag', 'fdtool_recorder_playpb');  
      hrec=findobj(c, 'flat','tag', 'fdtool_recorder_recordpb');
      if cont
         set(hplay, 'string', 'PLAY', 'tooltipstring', 'Play history')
         set(hrec, 'string', 'RECORD', 'tooltipstring', 'Start recording')
      else
         set(hplay, 'string', 'PLAY', 'tooltipstring', 'Replay next command')
         set(hrec, 'string', 'RECORD', 'tooltipstring', 'Record next action')
      end
      
      %------------------COMMAND LINE OPTIONS-------------------    
   elseif strcmpi(p1, 'loadhist')|strcmpi(p1, 'loadhist_recorder')
      % load history, do not start
      if nargin<2
        error('filename or history missing')
      end
      if isstr(p2)&(~strcmpi(p1, 'loadhist_recorder')|(nargin>=3)) %load history from file
         if ~guiinfos('isrecorderopen')
            guirecrd('init', 'demo');
         end
         if nargin < 3
           ind1=findstr(p2,'('); ind2=findstr(')',p2);
           if ~isempty(ind1), p3=p2(ind1+1:ind2-1); p2=p2(1:ind1-1); 
           else p3='history_data'; % default variable name
           end
         end
         guirecrd('loadfile_recorder', p2, p3);
         
       else %history as cell
         if ~guiinfos('isrecorderopen')
            guirecrd('init', 'demo');
         end
         if isstr(p2)
           try,
             filecont=evalin('base',[p2,';']);
           catch
             guirecrd('status',['Error: variable ''',p2,''' cannot be loaded from base workspace'])
             error(['Error: variable ''',p2,''' cannot be loaded from base workspace'])
           end
           varname=p2;
         else
           filecont=p2;
           if strcmpi(p1, 'loadhist_recorder'), varname=p3; else varname='Untitled'; end
         end
         history=eval(['filecont.history'], '''''');
         if isempty(history)
            guirecrd('status',['Error: History file not proper']);
            error(['Error: History file not proper'])
         end
         % convert old history
         history=ConcvertOldHistory(history);
         %
         index=1;
         answ=SaveIfNeeded(myfig, history);
         if strcmp(answ,'Cancel'), return, end
         history=updatefig(history, index, myfig);
         if isstr(p2)|strcmpi(p1, 'loadhist_recorder')
           guirecrd('sethistname',varname);  
         end
         s=struct('CurrentSource', 'WP', ...
            'CurrentPath', '',...
            'CurrentFileName', '',...
            'CurrentVarName', varname);
         guidtawr(Me, 'HistorySourceInfo', 'direct', s);
         DisplayName(myfig);
         SetDirtyFlag(Me, 0)
       end
      
   elseif strcmpi(p1, 'playhist')   
      if nargin > 1
         if nargin < 3
            p3='history_data'; % default variable name
         end
         guirecrd('loadhist', p2, p3);
      end
      figure(myfig)
      [out,fig_modal]=guirecrd('play');		% Modified, D.T.
      %   start history from current line or
      %   load and start history from the beginning
      
      
   elseif strcmpi(p1, 'addhistnumber')   
      name=get(myfig,'name');
      if nargin>=3, Nstr=sprintf('%.0f/%.0f, ',p2,p3);
      elseif nargin>=2, Nstr=sprintf('%.0f. ',p2);
      else Nstr='?. ';
      end
      ind=findstr(name,':')+2;
      indp=[findstr(name(ind:end),'.'),findstr(name(ind:end),',')];
      if ~isempty(indp)
        name=[name(1:ind-1),Nstr,name(ind:end)];
        set(myfig,'name',name)
      end
      
      
   elseif strcmpi(p1, 'setcontinuous') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_contcb');
      set(h, 'value', ~~p2)
      
   elseif strcmpi(p1, 'setemulatemouse') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_emulcb');
      set(h, 'value', ~~p2)
      guirecrd('emulatecb'); % set speed enable
      
   elseif strcmpi(p1, 'setdiscardpause') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_discardcb');
      set(h, 'value', ~~p2)
      
   elseif strcmpi(p1, 'setlecturemode') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_lecturecb');
      set(h, 'value', ~~p2)
      
   elseif strcmpi(p1, 'getlecturemode') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_lecturecb');
      out=get(h, 'value');
      return
      
   elseif strcmpi(p1, 'getcontinuous') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_contcb');
      out=get(h, 'value');
      return
      
   elseif strcmpi(p1, 'getdiscardpause') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_discardcb');
      out=get(h, 'value');
      return
      
   elseif strcmpi(p1, 'getactionindex') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_edit7');
      str=get(h, 'string');
      if ~isempty(str), out=str2num(str); else out=[]; end
      return
      
   elseif strcmpi(p1, 'gethistdata') 
      out=guidtard(Me, 'RECORDERDATA');
      return
      
   elseif strcmpi(p1, 'getsourcename') 
      s=guidtard(get(myfig, 'tag'), 'HistorySourceInfo');
      if isempty(s)
         out='Untitled';
      else
         if strcmp(s.CurrentSource, 'FILE')
            out=[s.CurrentFileName ' (' s.CurrentVarName ')'];
         else
            out='Untitled';
         end
      end
      return
      
   elseif strcmpi(p1, 'setdiscarderrorchk') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_discardcb2');
      set(h, 'value', ~~p2)
      
   elseif strcmpi(p1, 'settestplotmode') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_plotcb');
      set(h, 'value', ~~p2)
      
   elseif strcmpi(p1, 'gettestplotmode') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_plotcb');
      out=get(h, 'value');
      
   elseif strcmpi(p1, 'settestmode') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_testmodepop');
      set(h, 'value', p2+1)
      
   elseif strcmpi(p1, 'gettestmode') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_testmodepop');
      if isempty(h)
         out=0;
      else
         out=get(h, 'value')-1;
      end
      
   elseif strcmpi(p1, 'setmousespeed') 
      h=findobj(myfig, 'tag', 'fdtool_recorder_speedpop');
      set(h, 'value', p2)
      
   elseif strcmpi(p1, 'setinfofield')
      h=findobj(myfig, 'tag', 'fdtool_recorder_edit8');
      if ischar(p2), p2=cellstr(p2); end
      set(h, 'string', p2)
      
   %------------------ERROR HANDLING COMMANDS-------------------    
   
   elseif strcmp(p1, 'command_execution_finished')
       % check if error status is still OK
       % if not, update ErrStatus info in record
       SetRecordedActionIsActive(0, Me);
       err_status=GetErrorStatus(Me);
   elseif strcmp(p1, 'error_msg_captured')
       if guiinfos('isrecorderplayback')
           SetErrorStatus(p2, Me);
       elseif guiinfos('isrecorderrecord')
           %SetErrorStatus(p2, Me);
           if GetRecordedActionIsActive(Me)
               guirecrd('AddErrorStatusToLastHistory', p2)
               SetRecordedActionIsActive(0, Me); % inactivate, no other error messages will go through
           end
       end
      
      
      %------------------EDITBOX HANDLING COMMANDS-------------------    
      
   elseif strcmpi(p1,'editbox')
      ebh=findobj(myfig,'tag', 'fdtool_recorder_edit8');
      str=get(ebh,'string');
      reh=findobj(myfig,'tag', 'fdtool_recorder_replaceallmenu');
      if strcmpi(p2,'copyall')|strcmpi(p2,'cutall')
         set(reh,'UserData',str)
         if strcmpi(p2,'cutall'), set(ebh,'string',''), end
      elseif strcmpi(p2,'replaceall')
         set(ebh,'string',get(reh,'UserData'))
      elseif strcmpi(p2,'export')
         assignin('base','ebtext',...
            get(findall(0,'tag', 'fdtool_recorder_edit8'),'string'))
         set(findall(0, 'tag', 'fdtool_recorder_statustext'),'string',...
            'Text exported to base workspace, to variable ''ebtext''')
      elseif strcmpi(p2, 'import')
         ebtext=evalin('base', 'ebtext', 'error');
         if ~evalin('base', 'exist(''ebtext'')')
            set(findall(0, 'tag', 'fdtool_recorder_statustext'),'string',...
               'Warning: ebtext not found')
         elseif ~(iscell(ebtext)|isstr(ebtext))
            set(findall(0, 'tag', 'fdtool_recorder_statustext'),'string',...
               ['Warning: class of ebtext is ''',class(ebtext),''''])
         else %import
            set(findall(0, 'tag', 'fdtool_recorder_statustext'),'string',...
               'Variable ''ebtext'' imported')
            set(myfig, 'currentobject', myfig)
            set(ebh,'string',ebtext)
            SetDirtyFlag(Me, 1)
         end
      else
         error(['Unknown second argument: ',p2])
      end
      
      
      
      %------------------PRINTING COMMANDS-------------------    
   elseif any(findstr(p1, 'recorder_print'))
      
      he=findobj(myfig,'tag','fdtool_recorder_edit14');
      strsave=get(he,'string');
      name=get(myfig,'name');
      ind=findstr('fdtool:',lower(name));
      if ~isempty(name), name=['   ',name(ind(1)+8:length(name))]; end
      set(he,'string',name)
      hedit= findall(0, 'tag', 'fdtool_recorder_edit8');
      set([hedit;he],'backgroundcolor',[1,1,1])
      
      ststr=get(findall(0,'tag','fdtool_recorder_statustext'),'string');
      if size(ststr,1)>1, ststr=ststr(1,:); end
      
      if strcmpi(p1, 'recorder_print')
         fdgprint(Me)
         ststr=str2mat(ststr,'Print recorder done.');
         
      elseif strcmpi(p1, 'recorder_print_ps')
         fdgprint(Me,'ps')
         ststr=str2mat(ststr,'Print recorder to file done.');
         
      elseif strcmpi(p1, 'recorder_print_dialog')
         hpp=printdlg(myfig); %set(hpp,'visible','off')
         hps=pagesetupdlg(myfig);
         %wait for windows appearing:
         while ~(ishandle(hpp)|ishandle(hps)), pause(1), end
         %wait for both disappearing:
         while ishandle(hpp)|ishandle(hps), pause(1), end
         %
         ststr=str2mat(ststr,'Print recorder to file done.');
         
      elseif any(findstr(p1,'recorder_print_last'))
         hfigs=findall(0,'type','figure');
         ih=[]; hr=[]; h=[];
         for ii=1:length(hfigs)
            if any(findstr(lower(get(hfigs(ii),'name')),'recorder')) %recorder
               hr=hfigs(ii);
            elseif any(findstr(lower(get(hfigs(ii),'name')),'gui')) %gui
            elseif isempty(ih), ih=ii; h=hfigs(ii);
            end
         end %for ii
         if isempty(h)
            ststr=str2mat(ststr,'No special figure found.');
         else
            guirecrd('status',['Printing figure ',get(h,'name'),' ...']);
            %get(h,'name')
            if strcmpi(p1, 'recorder_print_last_ps')
               fdgprint(get(h,'tag'),'ps')
            elseif strcmpi(p1, 'recorder_print_last_dialog')
               hpp=printdlg(h);
               hps=pagesetupdlg(h);
               %wait for windows appear:
               while ~(ishandle(hpp)|ishandle(hps)), pause(1), end
               %wait for windows disappear:
               while ishandle(hpp)|ishandle(hps), pause(1), end
            else
               fdgprint(get(h,'tag'))
            end
            ststr=str2mat(ststr,'Print last figure done.');
         end
         if ~isempty(hr), figure(hr), end %pop recorder to front
         
      end
      guirecrd('status',ststr);
      %Restore note
      set(he,'string',strsave) 
      
   elseif strcmp(p1, 'preload')
      % preload, nothing to do
      if exist('gui_recorder.m')
        try, gui_recorder('preload'), catch, warning('Cannot preload gui_recorder'), end
      end
    
   else  % end of non-updating commands
      % ----------------------   COMMANDS UPDATING/USING HISTORY
      histdata=guidtard(Me, 'RECORDERDATA');
      history=histdata.history;
      index=histdata.index; %actual command to play, insertion BEFORE this element
      
      if strcmp(p1, 'addhist')
         if nargin > 2
            step=~any(findstr(p3, 'nostep'));
            paste=any(findstr(p3, 'paste'));
         else
            step=1;
            paste=0;
            % Execution of the recorded action is currently going on
            SetRecordedActionIsActive(1, Me); 
            % This flag is cleared when 'command_execution_finished' msg arrives from fdtool's command wrapper
         end
         if ~paste % normal operation; paste doesn't need param  update
            p2.time=datestr(now);
            p2.Info={''};
            DebugInfo=struct('ErrorStatus', 0, 'CheckFcn', '');
            p2.DebugInfo=DebugInfo;
            p2.Stop=0;
            [ObjName, WinName]=GetFieldNames(p2); % find WinName and ObjName
            p2.ObjName=ObjName;
            p2.WinName=WinName;
            p2.Note='';
            SetErrorStatus('OK', Me); % init error capture (error & warning in status)
         end
         %index=min(index, length(history));

         if isempty(history)
            if iscell(p2), history=p2; else history={p2}; end
         else
           if ~iscell(p2), p2={p2}; end
           history=[history(1:index-1) p2 history(index:end)];
         end
         if step
            index=index+1;
         end
         SetDirtyFlag(Me, 1)
         history=updatefig(history, index, myfig);
         hcont=findobj(allchild(myfig), 'flat', 'tag', 'fdtool_recorder_contcb');
         if ~get(hcont, 'value')
            [out,fig_modal]=guirecrd('stop');		% Modified, D.T.
         end
      elseif strcmpi(p1, 'AddErrorStatusToLastHistory')
          switch p2
          case 'Warning'
              history{end}.DebugInfo.ErrorStatus=1;
          case 'Error'
              history{end}.DebugInfo.ErrorStatus=2;
          end
              
      elseif strcmpi(p1, 'userstop')
         c=allchild(myfig);
         h=findobj(c, 'tag', 'fdtool_recorder_playpb');
         hstop=findobj(c,'tag', 'fdtool_recorder_stoppb');
         set(h, 'userdata', 0)
         % set(hstop, 'enable', 'off');
         
         if guiinfos('isrecorderrecord')
            [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
         else
            a=dbstack;
            % test if recorder is relly running or stopped by CTRL-C or error
            flag=0;
            for ii=2:length(a) % skip #1, which is the present call
               if findstr(a(ii).name, mfilename)
                  flag=1; break
               end
            end
            if flag % recorder is running
               hled=findobj(c, 'flat', 'tag', 'fdtool_recorder_playled');
               set(hled, 'backgroundcolor' , 'y')
               guirecrd('status', '$yRecorder will be stopped after the completion of this command. ');
               %break %this is wrong here, changed to return
               return
            else % force stop
               [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
            end
         end
         
      elseif strcmpi(p1, 'stop')
         c=allchild(myfig);
         h(1)=findobj(c, 'tag', 'fdtool_recorder_recordpb');
         h(2)=findobj(c, 'tag', 'fdtool_recorder_playpb');
         h(3)=findobj(c,'tag', 'fdtool_recorder_beginpb');
         h(4)=findobj(c,'tag', 'fdtool_recorder_backpb');
         h(5)=findobj(c,'tag', 'fdtool_recorder_forwardpb');
         h(6)=findobj(c,'tag', 'fdtool_recorder_endpb');
         if strcmp(RecorderMode(myfig), 'demo')
           h=h(2:3); % do not enable but play and <<
           %h=h(2:6); %also enable < and >
         end % do not enable but play and <<
         set(h, 'userdata', 0, 'enable', 'on')
         hled(1)=findobj(c, 'flat', 'tag', 'fdtool_recorder_recordled');
         hled(2)=findobj(c, 'flat', 'tag', 'fdtool_recorder_playled');
         set(hled, 'backgroundcolor' , 'default')
         LectureMode=get(findobj(c, 'flat', 'tag', 'fdtool_recorder_lecturecb'), 'value');
         if ~LectureMode
            figure(myfig) %jump recorder into foreground
         end
         % take index from editbox, index here may not be updated when stop called
         hstep=findobj(c,'tag', 'fdtool_recorder_edit7');
         ixstr=get(hstep, 'string'); 
         history=updatefig(history, index, myfig); % call update to make fields accessible
         if isempty(str2num(ixstr))
            guirecrd('status', ...
               ['Recorder stopped after last command. ' , ...
                  '(record length = ' num2str(length(history)) ')', ...
               ]);
         else            
            guirecrd('status', ...
               ['Recorder stopped before command #' , ...
                  ixstr, ' of ', num2str(length(history)), ...
               ]);
         end
         fdtool('status', 'Recorder stopped')
         hstop=findobj(c,'tag', 'fdtool_recorder_stoppb');
         set(hstop, 'enable', 'off');
         
         % check for modal (gui) windows (e.g. import window)
         % make them normal when recorder stops, otherwise recorder cannot be reached
         
         fig_modal=findobj(allchild(0), 'flat', 'windowstyle', 'modal');
         set(fig_modal, 'windowstyle', 'normal')
         
         return
         
      elseif strcmp(p1, 'copy')
         if index>0 & index <= length(history)
            current=history(index);
            if any(findstr(p2, 'to_history'))
               evalin('base',['if ~exist(''history''), history={}; end,',sprintf('\n'),...
                   'fdtool(''callback'',''guidtawr'',''fdtool_recorder_fig'',',...
                   '''history_tmp'',''direct'',history)'])
               historyvar=[guidtard(Me,'history_tmp'),current];
               assignin('base','history',historyvar)
            else
               %guidtawr(Me, 'RECORDER_CLIPBOARD', 'direct', [historyvar,current])
               guidtawr(Me, 'RECORDER_CLIPBOARD', 'direct', current)
             end
           end   

      elseif strcmpi(p1, 'clear')
        evalin('base','clear history')
        
      elseif strcmp(p1, 'delete')|strcmpi(p1, 'new')|strcmp(p1, 'move')        
         guirecrd('stop')
         if strcmpi(p1, 'new')&(nargin==1), p2='all_no_question'; end
         if isstr(p2) 
           if strcmp(p2, 'all') | strcmp(p2, 'all_no_question')% delete all
             if ~any(findstr('no_question', p2))
               answ=SaveIfNeeded(myfig, history);
               if strcmp(answ,'Cancel'), error('delete cancelled'), end
             end
             history={}; index=1; % empty histdata
             history=updatefig(history, index, myfig);
             guidtawr(Me, 'HistorySourceInfo', 'direct', '');
             DisplayName(myfig);
             SetDirtyFlag(Me, 0)
           elseif any(findstr(p2, 'this')) & index>0 & index <= length(history)
             ix=index; % delete this element
             current=history(ix);
             if any(findstr(p2, 'addtoclipboard'))
               historyvar=guidtard(Me, 'RECORDER_CLIPBOARD');
               if ~isempty(historyvar)&~iscell(historyvar), historyvar={historyvar}; end
               guidtawr(Me, 'RECORDER_CLIPBOARD', 'direct', [historyvar,current])
             elseif any(findstr(p2, 'toclipboard'))
               guidtawr(Me, 'RECORDER_CLIPBOARD', 'direct', current)
               %Tamás! itt javítottam! vvvvvvvvvvvvvvvvv
             elseif any(findstr([p2,'|'],'this_action_to_history'))
               %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
               evalin('base',['if ~exist(''history''), history={}; end,',sprintf('\n'),...
                   'fdtool(''callback'',''guidtawr'',''fdtool_recorder_fig'',',...
                   '''history_tmp'',''direct'',history)'])
               historyvar=[guidtard(Me,'history_tmp'),current];
               assignin('base','history',historyvar)
             end
             history={history{1:ix-1} history{ix+1:end}};
             if length(history)==0, index=1; end
             history=updatefig(history, index, myfig);
             SetDirtyFlag(Me, 1)
           end
         else 
            %
         end
         
      elseif strcmp(p1, 'load')|strcmp(p1, 'loaddemo')
         guirecrd('stop')
         answ=SaveIfNeeded(myfig, history);
         if strcmp(answ,'Cancel'), return, end
         if strcmp(p1, 'loaddemo')
            pd=pwd; pd0=pwd;
            p=which('glassfib.mat','-all');
            if length(p) > 1
               warning('More than one fddemo directory ?!')
            elseif length(p) <1
               msg='Import: Demo directory not found';
               guirecrd('status', ['Error: ' msg]);
               warning(msg)
               return
            end
            p=p{1};
            pd=p(1:length(p)-12);
         else
            pd='';
         end
         call_ID='History';
         initvar=struct(...
            'CurrentSource', 'FILE', ...
            'CurrentPath', [pd],...
            'CurrentFileName', '',...
            'CurrentVarName', '', ...
            'ExportData', '');
         filter='filter: FDTool Action History';
         guiimpv('init', myfcn, call_ID, initvar, filter);
         
         return
         
      elseif strcmp(p1, 'import_ready')
         
         switch  p2
         case 'cancel'
            msgstr='Load cancelled.';
         case 'done'
            h=findall(0, 'tag', 'fdtool_importfig');
            histdata=guidtard('fdtool_importfig', 'IMPORTED_VAR');
            history=histdata.history;
            index=1;
            hversion=histdata.version;
            if (str2num(hversion) >= str2num(LatestVersion));
               msgstr=['History successfully loaded.'];
            else
               % convert old history
               history=ConcvertOldHistory(history);
               warning(['File contains old history data. Some functions may not work properly.'])
               msgstr=['Warning: File contains old history data. Some functions may not work properly.'];
            end
            Settings=guiimpv('GetSettings'); % get filename, varname, ... etc.
            guidtawr(Me, 'HistorySourceInfo', 'direct', Settings);
            DisplayName(myfig);
            SetDirtyFlag(Me, 0)
         end
         history=updatefig(history, index, myfig);
         if ~isempty(msgstr), guirecrd('status', msgstr); end
         
      elseif strcmp(p1, 'loadfile')|strcmp(p1, 'loadfile_recorder') 
         if exist(p2, 'file')
            try
              filecont=load('-mat',p2);
            catch
              filecont=load(p2);
            end
          else 
            guirecrd('status',['Error: File ''',p2,''' does not exist']);
            error(['File ''' p2 ''' does not exist'])
            return
         end
         varname=p3;
         history=eval(['filecont.' varname '.history'], '''''');
         if isempty(history)
            guirecrd('status',['Error: Variable ''',varname,''' does not exist']);
            error(['Variable ''',varname,''' does not exist'])
         end
         % convert old history
         history=ConcvertOldHistory(history);
         index=1;
         answ=SaveIfNeeded(myfig, history);
         if strcmp(answ,'Cancel'), return, end
         history=updatefig(history, index, myfig);
         [p, n, e]=fileparts(p2);
         s=struct('CurrentSource', 'FILE', ...
            'CurrentPath', p,...
            'CurrentFileName', [n e],...
            'CurrentVarName', varname);
         guidtawr(Me, 'HistorySourceInfo', 'direct', s);
         DisplayName(myfig);
         guirecrd('sethistname',[p2,' (',p3,')'])  
         SetDirtyFlag(Me, 0)
         
			elseif strcmpi(p1, 'save')
         guirecrd('stop')
         if isempty(history), 
            guirecrd('status', 'Warning: Empty history cannot be saved');
            return
         end
         histdata=rmfield(histdata, 'index');
         histdata.version=LatestVersion;
         histdata.history=history;
         histdata.time=datestr(now);
         if ~isfield(histdata, 'version')
            histdata.version=LatestVersion;
         end
         si=guidtard(Me, 'HistorySourceInfo');
         if ~isempty(si)&strcmp(si.CurrentSource, 'FILE')
            fullfilename1234567890=fullfile(si.CurrentPath, si.CurrentFileName);
            %
            %bypass bug between Matlab 5.3 - Matlab 5.2: load and save
            %RecoverFile(fullfilename1234567890)
            %
            eval([si.CurrentVarName '=histdata; save(''' , ...
                  fullfilename1234567890,''', ''', si.CurrentVarName,...
                  ''',  ''-APPEND''); OK=1;'], 'OK=0;');
            if OK
               guirecrd('status', ['History save completed']);
               SetDirtyFlag(Me, 0)
            else
               guirecrd('status', ['Error: History save failed. See command window for details']);
               disp(lasterr)
            end
         else % WP
            guirecrd('saveas');
         end
         
         
      elseif strcmpi(p1, 'saveas')
         guirecrd('stop')
         if isempty(history), 
            guirecrd('status', 'Warning: Empty history cannot be saved');
            return
         end
         histdata=rmfield(histdata, 'index');
         histdata.version=LatestVersion;
         histdata.history=history;
         histdata.time=datestr(now);
         si=guidtard(Me, 'HistorySourceInfo');
         if ~isempty(si) & strcmp(si.CurrentSource, 'FILE')
            cfilename=si.CurrentFileName;
            cpath=si.CurrentPath;
            cvarname='history_data';
         else
            cfilename='history';
            cpath='';
            cvarname='history_data';
         end
         
         initvar=struct(...
            'CurrentSource', 'FILE', ...
            'CurrentPath', cpath,...
            'CurrentFileName', cfilename,...
            'CurrentVarName', cvarname);
         initvar.ExportData=histdata; % bypass bug: it does not work with struct !!!!
         filter='filter: FDTool Action History';
         guiimpv('init_export', myfcn, '', initvar, filter)
         guirecrd('status', ['Saving history. See Export Window...']);
         return
         
      elseif strcmp(p1, 'startrep')
        if guiinfos('isdevelopment')
          guirecrd('init','development');
        else
          guirecrd('init','recorder');
        end
        guirecrd('delete','all_no_question')
        guirecrd('RecordOn')
        fdtool('callback','fdtool','ui_forget_all', 'fdtool_menu_forget_all')
        guirecrd('RecordOn')
        if any(findstr(p2,'_auto'))|any(findstr(p2,'_default'))
          fdtool('callback', 'fdtool', 'ui_userlevel_set', 'Automatic', 'fdtool_menu_userlevel_basic')
        %elseif any(findstr(p2,'_simple'))
        %  fdtool('callback', 'fdtool', 'ui_userlevel_set', 'Simple', 'fdtool_menu_userlevel_simple')
        elseif any(findstr(p2,'_inter'))
          fdtool('callback', 'fdtool', 'ui_userlevel_set', 'Interactive', 'fdtool_menu_userlevel_intermediate')
        elseif any(findstr(p2,'_adv'))
          fdtool('callback', 'fdtool', 'ui_userlevel_set', 'Advanced', 'fdtool_menu_userlevel_advanced')
        else
          error('Cannot set userlevel')
        end
        hmt=[findall(0,'tag','fdtool_menu_modeltype_linear');
          findall(0,'tag','fdtool_menu_modeltype')];
        if ~isempty(hmt)&any(strmatch(get(hmt,'visible'),'on'));
          %vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
          %Not necessary, clear GUI does it
          %guirecrd('RecordOn')
          %fdtool('callback', 'fdtool', 'ui_modeltype_set', 'Linear', 'fdtool_menu_modeltype_linear')
          %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        end
        guirecrd('Stop')
        %vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        %Tamás! Ez az új rész!
        %add notes for reports to document settings
        try, note=fdtool('reportnote'); catch, note={''}; end, if ~iscell(note), note={note}; end
        vers=feval('version'); %vers=vers(1:min(5,end));
        if ~isempty(note{1}), note{1}=[note{1},', ']; end
        note{1}=[note{1},computer,', ML',vers];
        histdata=guidtard(Me, 'RECORDERDATA');
        for ii=1:min(length(note),length(histdata.history))
          histdata.history{ii}.Note=note{ii};
        end
        guidtawr(Me, 'RECORDERDATA','direct',histdata);
				%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        %
        guirecrd('insertNOP', 'clear %clear workspace')
        fdtool('callback','guirecrd','edit',  1)
				fdtool('callback','guirecrd','forward')
        guirecrd('insertNOP', '%load mydata.mat')
				guirecrd('SetInfoField', {'If necessary, insert your load command into the Param field,';...
						'and then press button ">" before Recording is started.'})
        fdtool('callback','guirecrd','edit',  1)
	      %***
        guirecrd('status', 'Warning: Report has been started; record actions and save history to file.');
        return
         
      elseif strcmp(p1, 'recstyle')
        hrec=findall(0, 'tag', Me);
        if strcmp(RecorderMode(hrec), p2) % same mode, nothing to do
        else
          hist=guirecrd('GetHistData');
          index=guirecrd('GetActionIndex');
          cont=guirecrd('GetContinuous');
          discardpause=guirecrd('GetDiscardPause');
          s=guidtard(Me, 'HistorySourceInfo'); %file info
          
          if any(findstr(p2,'_demo'))
            guirecrd('init','demo');
          elseif any(findstr(p2,'_dev'))
            guirecrd('init','development');
            guirecrd('SetContinuous', cont);
          elseif any(findstr(p2,'_standard'))
            guirecrd('init','recorder');
            guirecrd('SetContinuous', cont);
          else
            error('Cannot change style of recorder')
          end
          myfig=findall(0, 'tag', Me);

          if ~isempty(hist.history)
            guirecrd('LoadHist', hist);
            guirecrd('GotoAction', index);
            %s=struct('CurrentSource', 'FILE', ...
            %  'CurrentPath', p,...
            %  'CurrentFileName', [n e],...
            %  'CurrentVarName', varname);
            guidtawr(Me, 'HistorySourceInfo', 'direct', s);
            DisplayName(myfig);
            SetDirtyFlag(Me, 0)
          end
          guirecrd('SetDiscardPause',discardpause)
          guirecrd('sethistname') %restore recent files
          guirecrd('status', 'Recorder style has been changed.');
        end
        return
         
      elseif strcmp(p1, 'export_ready')
         switch  p2
         case 'cancel'
            guirecrd('status', 'History save cancelled');
         case 'done'
            Settings=guiimpv('GetSettings'); % get filename, varname, ... etc.
            guidtawr(Me, 'HistorySourceInfo', 'direct', Settings);
            DisplayName(myfig);
            guirecrd('status',['History save completed.']);
            SetDirtyFlag(Me, 0)
         end      
         h= findobj(allchild(0), 'flat', 'tag', 'fdtool_exportfig');
         % delete export window to allow 'close' to proceed (waitfor))
         delete(h) % necessary for 'close' !!!!!!
         return
         
         
      elseif strcmp(p1, 'play')
         fdtool('status', '$gReplay is on...')
         c=allchild(myfig);
         hstop=findobj(c,'tag', 'fdtool_recorder_stoppb');
         set(hstop, 'enable', 'on');
         
         hrec=findobj(c, 'tag', 'fdtool_recorder_recordpb');
         hplay=findobj(c, 'tag', 'fdtool_recorder_playpb');
         hled=findobj(c, 'flat', 'tag', 'fdtool_recorder_playled');
         hcont=findobj(c, 'flat', 'tag', 'fdtool_recorder_contcb');
         hpause=findobj(c, 'flat', 'tag', 'fdtool_recorder_edit11');
         hcheckfcn=findobj(c, 'flat', 'tag', 'fdtool_recorder_edit10');
         herrstat=findobj(c, 'flat', 'tag', 'fdtool_recorder_edit9');
         hdiscard= findobj(c, 'flat', 'tag', 'fdtool_recorder_discardcb');
         hdiscarderr= findobj(c, 'flat', 'tag', 'fdtool_recorder_discardcb2');
         hspeed= findobj(c, 'flat', 'tag', 'fdtool_recorder_speedpop');
         
         hs(1)=findobj(c,'tag', 'fdtool_recorder_beginpb');
         hs(2)=findobj(c,'tag', 'fdtool_recorder_backpb');
         hs(3)=findobj(c,'tag', 'fdtool_recorder_forwardpb');
         hs(4)=findobj(c,'tag', 'fdtool_recorder_endpb');
         
         ispause=get(hpause, 'value')& ~get(hdiscard, 'value');
         IsFirstAction=1;
         if get(hplay, 'userdata') % already in play mode
            %
         else
            set(hplay, 'userdata', 1)
            set(hled, 'backgroundcolor', 'g')
            set([hplay, hs, hrec,], 'enable', 'off')
            drawnow
         end
         if index==0
            index=min(1, length(history)); 
         end
         history=updatefig(history, index, myfig);
         LastForcedMousePos=GetMousePos;
         while (get(hplay, 'userdata') & (index>0) & (index<=length(history)))
            % check if mouse is moving, if so, pause
            emul=get(findobj(allchild(myfig), 'flat', 'tag', 'fdtool_recorder_emulcb'), 'value');
            fastemul=get(findobj(allchild(myfig), 'flat', 'tag', 'fdtool_recorder_speedpop'), 'value');
            if emul & any(abs(LastForcedMousePos-GetMousePos)>10)  % if mouse moved
               LastForcedMousePos=GetMousePos;
               pause(1)
            else  % mouse was not moved, execution enabled
               a=history{index};
               ispause=get(hpause, 'value')& ~get(hdiscard, 'value');
               if ispause & ~IsFirstAction
                  [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                  break
               end
               IsFirstAction=0;
               if strcmp(a.Cmd, 'MATLAB Cmd')
                  cmdstr=a.XParam;
               elseif strcmp(a.Cmd, 'NOP')
                  cmdstr='';
               elseif strcmp(a.Cmd, 'Jump')
                  cmdstr='';
                  jp=a.XParam;
                  if any(findstr(jp, '+'))| any(findstr(jp, '-'))
                     % relative jump
                     indexn=index+str2num(jp)-1; % auto increment later !
                  else
                     % absolute jump
                     indexn=str2num(jp)-1; % auto increment later !
                  end
                  if indexn>=0 & indexn<length(history)
                     % OK
                     index=indexn;
                     guirecrd('status', ['Jump performed']); pause(0)
                  else
                     [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                     guirecrd('status', ['Error: Incorrect Jump statement (command #' num2str(index) ').']);
                     return
                  end
               else  % GUI action or strcmp(a.Cmd, 'PrivateAction')
                  hWin=findobj(allchild(0), 'flat', 'Tag', a.Win);
                  %
                  %modify userlevel actions between 5.2 and other versions
                  if any(findstr([a.CurObj],'fdtool_menu_modeltype'))
                    %model type setting is different in 5.2 and later
                    hm=[findobj(hWin, 'tag','fdtool_menu_modeltype_linear');
                      findobj(hWin, 'tag','fdtool_menu_modeltype')];
                    if isempty(hm)
                      fdtool('modeltype_set','Linear')
                      hm=[findobj(hWin, 'tag','fdtool_menu_modeltype_linear');
                        findobj(hWin, 'tag','fdtool_menu_modeltype')];
                    end
                    if strcmp(a.CurObj,'fdtool_menu_modeltype')&...
                        strcmp(get(hm(1),'type'),'uitoggletool')
                      %5.2 record in newer Matlab 
                      a.CurObj=['fdtool_menu_modeltype_',lower(a.XParam)];
                      ind=find(a.CurObj==' '); if ~isempty(ind), a.CurObj(ind)='_'; end
                      a.XParam=[];
                    elseif any(findstr(a.CurObj,'fdtool_menu_modeltype_'))&...
                        strcmp(get(hm(1),'type'),'uicontrol')&isempty(a.XParam)
                      %new record in Matlab 5.2
                      a.XParam=[upper(a.CurObj(23)),a.CurObj(24:end)];
                      ind=find(a.XParam=='_');
                      if ~isempty(ind), a.XParam(ind)=' '; end
                      a.CurObj='fdtool_menu_modeltype';
                    end
                  elseif strcmp(a.CurObj,'fdtool_menu_userlevel_advanced')
                    fdtool('userlevel_set','Advanced')
                  end
                  %
                  hObj=findobj(hWin, 'Tag', a.CurObj);
                  if length(hWin)>1
                     hWin=getpwin(hObj);
                  end
                  if isempty(hWin)
                     [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                     msg=['''' a.WinName '''' ...
                           ' window is missing during playback (command #' num2str(index) ').'];
                     guirecrd('status', ['Error: ' msg]);
                     error(msg)
                  elseif isempty(hObj)   
                     [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                     msg=['''' a.ObjName '''' ...
                           ' object is missing during playback (command #' num2str(index) ').'];
                     guirecrd('status', ['Error: ' msg]);
                     error(msg)
                  else
                     figure(hWin); drawnow
                     % show active item
                     if emul
                        mouseto(a.Win,a.CurObj);
                        LastForcedMousePos=GetMousePos;
                        if fastemul == 1 % fast
                           pause(0)
                        elseif fastemul == 2  % medium
                           pause(1)
                        else
                           pause(2)
                        end
                     end
                  end
                  
                  % make sure that the enable property of the current object is set properly
                  % certain menus' enable is set when their parent is activated
                  % (which does not occur during replay: do it NOW)
                  if strcmp(get(hObj, 'type'), 'uimenu')
                     par=get(hObj, 'parent');
                     if strcmp(get(par, 'type'), 'uimenu')
                        cb_par=get(par, 'callback');
                        eval(cb_par, '1;');
                     end
                  end
                  
                  if strcmp(get(hObj,'type'),'uicontrol'), Ost=get(hObj,'style'); else Ost='not uicontrol'; end
                  try
                    if ~strcmp(get(hObj,'type'),'patch')&~strcmp(get(hObj,'type'),'axes')
                      Oen=get(hObj,'enable'); 
                    else Oen='on';
                    end, 
                  catch
                    Oen='on';
                  end
                  try, Ovi=get(hObj,'visible'); catch, Ovi='on'; end
                  if isstr(Oen)& (~strcmp(Oen, 'on')|~strcmp(Ovi, 'on')) & ~strcmpi(Ost, 'text') 
                     % for text object playback is enabled! (buttondownfcn is active)
                     % check if help mode
                     if guiinfos('ishelpmode', hWin)
                        % OK, help on object can be replayed
                     else
                       if strcmpi(popupstr(herrstat), 'disabled') & ...
                           ~get(hdiscarderr, 'value')
                         % everything is OK: uicontrol is disabled but it is required so
                       elseif strcmp(get(hObj,'userdata'),'fdtool_menu_userlevel')|...
                           strcmp(get(hObj,'userdata'),'fdtool_menu_modeltype')
                         %modeltype or userlevel: special handling...
                         if strcmp(get(hObj,'userdata'),'fdtool_menu_modeltype')
                           if strcmp(get(hObj,'type'),'uicontrol')
                             mtype=popupstr(hObj);
                           else
                             tobj=get(hObj,'tag'); ind=findstr(tobj,'_modeltype_');
                             mtype=tobj(ind+11:end);
                             ind=find(mtype=='_'); if ~isempty(ind), mtype(ind)=' '; end
                           end
                           fdtool('modeltype',mtype);
                         elseif strcmp(get(hObj,'tag'),'fdtool_menu_userlevel_advanced')
                           fdtool('userlevel','advanced')
                         end
                         %nothing else to do: the following branches only
                         %check visibility and enables status
                       elseif ~strcmp(Oen, 'on')
                         if strcmp(get(hObj,'tag'),'fdtool_menu_modeltype_linear')|...
                             (strcmp(get(hObj,'tag'),'fdtool_menu_modeltype')&isequal(get(hObj,'value'),1))
                           %linear model set, when selection not enabled.
                         elseif strcmp(get(hObj,'tag'),'agv_uic_evalpb')
                           %Not a problem when recorder tries to execute agv
                         else
                           msg='Current Object is not enabled';
                           [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                           guirecrd('status', ['Error: ' msg]);
                           error(msg)
                         end
                       elseif ~strcmp(Ovi, 'on')
                         if strcmp(get(hObj,'tag'),'fdtool_menu_modeltype_linear')|...
                             (strcmp(get(hObj,'tag'),'fdtool_menu_modeltype')&isequal(get(hObj,'value'),1))
                           %linear model set, when selection not enabled.
                         else
                           msg='Current Object is not visible';
                           [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                           guirecrd('status', ['Error: ' msg]);
                           error(msg)
                         end
                       end
                     end   
                  end
                  % this was the old version (v1.xxx):
                  %cmdstr=(['fdtool(''callback'',''',a.Fcn,''',''' a.Cmd ''', ''' a.XParam ''', ' ...
                  %      '[], [], ''' a.CurObj ''', ''' a.SelType ''');']);
                  
                  % find special call types (callback can not be used to replay)
                  SPECIAL_CALL=0;
                  % axes with mouse selection (eg. freqsel)
                  if (strcmp(get(hObj, 'type'), 'axes') & ~isempty(a.XParam )) | ...
                        (strcmp(get(hObj, 'type'), 'uimenu') & ~isempty(a.XParam ))
                     SPECIAL_CALL=1; 
                  end
                  
                  if SPECIAL_CALL
                     cmdstr=(['fdtool(''callback'',''',a.Fcn,''',''' a.Cmd ''', ''' a.XParam ''', ' ...
                           '[], [], ''' a.CurObj ''', ''' a.SelType ''');']);
                  else
                     
                     % now create cmdstr using the callback string of the current object:
                     switch get(hObj, 'type')
                     case {'uicontrol', 'uimenu'}
                        cb_property='callback';
                      case 'uitoggletool'
                        cb_property='clickedcallback';
                      otherwise
                        cb_property='buttondownfcn';
                     end
                     cbstr=get(hObj, cb_property);
                     if any(findstr(a.CurObj,'fdtool_menu_modeltype_'))&...
                         strcmp(get(hm(1),'type'),'uicontrol')
                       %fix for new record in 5.2 matlab
                       ind=findstr('''Linear''',cbstr);
                       if ~isempty(ind)
                         cbstr=[cbstr(1:ind),a.XParam,cbstr(ind+7:end)]; %exchange 'Linear'
                       end
                     end
                     if strcmp(a.Cmd, 'PrivateCB')
                        cmdstr=cbstr;
                     else
                        % check if callback is correct
                        ix1=findstr(cbstr,'fdtool(');
                        ix2=findstr(cbstr,')'); if length(ix2)>1, ix2=ix2(end);end
                        ix3=findstr(cbstr,'''callback''');
                        if (isempty(ix1) | length(ix1)>1)
                           % if not PrivateCB and no fdtool call, probably bad or old callback
                           msg='Error: Current control object has bad callback string (1)';
                           if guiinfos('isdevelopment')
                              msg=[msg ': ' cbstr];
                           end
                           [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                           guirecrd('status', ['Error: ' msg]);
                           error(msg)
                        else % cbstr probably OK
                           parstr=cbstr; parstr(ix2)='}';
                           parstr=[parstr(1:ix2), ')', parstr(ix2+1:end)];
                           parstr=strrep(parstr, 'fdtool(', 'parnum=length({');
                           eval([parstr ';']);
                           pause(0) %Try to plot everything
                           
                           if isempty(ix3) % fdtool's own OLD callback, no wrapping
                              % cbstr has the form:
                              % fdtool(cmd, CurObj) or 
                              % fdtool(cmd) or 
                              % fdtool(cmd, XtraParam, CurObj), where parnum gives
                              % the current number of params in the bracket
                              
                              % now create cmdstr in the form:
                              % fdtool(cmd, XParam, x, [], CurObj, SelType)
                              % where x is don't-care ([] or CurObj)
                              % Xparam may also be empty
                              if guiinfos('isdevelopment')
                                 % It works, but shouldn't happen any more
                                 error('Callback found without wrapping !!!')
                              end
                              EmptyParamNum=4-parnum;
                           else % callback wrapped by fdtool
                              % cbstr has the form:
                              % fdtool('callback', cmd, CurObj) or 
                              % fdtool('callback', cmd) or 
                              % fdtool('callback', cmd, XtraParam, CurObj) or
                              % fdtool('callback', cmd, XtraParam), where parnum gives
                              % the current number of params in the bracket
                              
                              % now create cmdstr in the form:
                              % fdtool('callback', fcn, cmd, XParam, x, [], CurObj, SelType)
                              % where x is don't-care ([] or CurObj)
                              % Xparam may also be empty
                              EmptyParamNum=6-parnum;
                           end
                           % NOTE: XParam forwarded ONLY if callback provides
                           %       Usually it is not necessary any more, playback sets necessary
                           %       uicontrol properties
                           if EmptyParamNum<0
                              msg='Error: Current control object has bad callback string (2)';
                              if guiinfos('isdevelopment')
                                 msg=[msg ': ' cbstr];
                              end
                              [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                              guirecrd('status', ['Error: ' msg]);
                              error(msg)
                           end
                           cmdstr=cbstr(1:ix2-1);
                           %if ~any(findstr(cmdstr,'menu_help')) %re-activate helps? 
                           for emptyix=1:EmptyParamNum;
                             cmdstr=[cmdstr, ' , []'];
                           end
                           if isempty(a.SelType)
                             a.SelType='normal';
                           end
                           cmdstr=[cmdstr, ' , ''' a.CurObj, ''', ''' a.SelType, ''');'];
                           %else
                           %cmdstr=[cmdstr, ');'];
                           %end
                         end
                     end % - PrivateCB or GUI action
                     
                     % settings for editboxes, checkboxes
                     if strcmp(get(hObj, 'type'), 'uicontrol')
                        switch get(hObj, 'style')
                        case 'edit'
                           set(hObj, 'string', a.XParam)
                        case 'checkbox'
                           set(hObj, 'value', str2num(a.XParam))
                        case {'listbox', 'popupmenu'}
                           % find XParam in the list
                           FullList=get(hObj, 'string');
                           Err=0;
                           if ~iscell(FullList) % shouldn't happen anyway
                              if strcmpi(FullList, a.XParam)
                                 ListIx=1;
                              else
                                 Err=1; msg=[ a.XParam ' is not found in the list. Cannot replay (1).'];
                              end   
                           else   
                              if ~iscell(a.XParam)
                                 L=length(FullList);
                                 try
                                   ix=strmatch(a.XParam,FullList,'exact'); %new and elegant
                                   if ~isequal(length(ix),1), error('Not found'), end
                                 catch
                                   ix=1;
                                   while ix<=L & ~strcmpi(FullList{ix}, a.XParam)
                                     ix=ix+1;
                                   end
                                 end
                                 if isempty(ix)|(ix>L)
                                   Err=1; msg=[ a.XParam ' is not found in the list. Cannot replay.'];
                                 else
                                   ListIx=ix;
                                 end
                              else     % extension of Zoltan 13/11/2004 multiple selection for listboxes
                                 L=length(FullList); ix=1;
                                 ListIx=[];
                                 for ipar=1:size(a.XParam,1)
                                    for ix=1:L
                                       if strcmpi(FullList{ix}, a.XParam{ipar,1}), ListIx=[ListIx;ix]; end
                                    end
                                 end
                                 if isempty(ListIx)
                                    Err=1; msg=[ a.XParam ' is not found in the list. Cannot replay.'];
                                 end
                              end
                           end
                           if Err
                              [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                              guirecrd('status', ['Error: ' msg]);
                              error(msg)
                           else
                              set(hObj, 'value', ListIx)
                           end
                        end
                     end
                  end %if SPECIAL_CALL, else                  
               end  % if-then-else
               
               % eval command with or without error handling
               if ~get(hdiscarderr, 'value')  
                  fdtstplt('before', a); % test plot if necessary
                  % 'soft' error check required (test mode)
                  RequiredErrorStat=popupstr(herrstat);
                  if strcmpi(RequiredErrorStat, 'disabled') 
                     % required state: disabled
                     if isequal(Oen, 'off')
                        ErrorStat=RequiredErrorStat;
                     else
                        ErrorStat='Enabled';
                     end
                     % no execution required!!
                  else % not disabled, execute
                     SetErrorStatus('OK', Me); % init error capture (error & warning in status)
                     if guiinfos('isdevelopment') & ~strcmp(a.Cmd, 'MATLAB Cmd')& exist('fdcbcall.m','file')
                        fdcbcall(cmdstr, 'nocatch');
                     else
                        evalin('base', cmdstr)  % NO catch !! stop if error
                     end
                     % required result
                     ErrorStat=GetErrorStatus(Me);
                     
                  end
                  if strcmpi(ErrorStat, RequiredErrorStat)
                     CheckOK=1;
                     msg='';
                  else
                     CheckOK=0;
                     msg=sprintf([...
                           'TEST ERROR: Required status: %s\n' ...
                           '            Current status : %s\n'], ...
                        RequiredErrorStat, ErrorStat);
                     [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                  end
                  checkID=get(hcheckfcn, 'string');
                  if ~isempty(checkID) % eval debugfcn if required
                     [errmsg, chkstatus]=feval('guidbfcn', checkID);
                     TestOK=(chkstatus==0);
                     if ~TestOK
                        msg=sprintf(...
                           [msg, ...
                              'TEST ERROR: DebugFcn returned with message: \n  %s'],...
                           errmsg);
                        [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                     end
                  else
                     TestOK=1;
                  end
                  fdtstplt('after', a); % test plot if necessary
               else   % no 'soft' error checking (demo or user recorder)
                  lasterr(''); lastwarn(''); err=0;
                  errorcatch
                  if guiinfos('isdevelopment') & ~strcmp(a.Cmd, 'MATLAB Cmd')& exist('fdcbcall.m','file')
                     % err=fdcbcall(cmdstr, 'errorcatch');
                    % modified because DT's checker
                     err=fdcbcall(cmdstr, 'nocatch');
                  else
                    % modified because DT's checker
                    % evalin('base', cmdstr, 'err=1;')
                     evalin('base', cmdstr)
                  end
                  errorcatch
                  if err
                     disp(['Error: ' lasterr])
                  end
                  TestOK=1; CheckOK=1;
               end
               if ~CheckOK | ~TestOK
                  guirecrd('status', ['$rTEST ERROR in command #' num2str(index) '. See Command Window for details']);
                  error(msg)
               else % everything is OK
                  index=index+1;
                  if index>length(history)+1
                     index=length(history)+1;
                     history=updatefig(history, index, myfig);
                     [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
                  else
                    history=updatefig(history, index, myfig);
                  end
               end
               
               if ~get(hcont, 'value')
                  [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
               end
            end % of exec of current action
         end % while
         if guiinfos('isrecorderplayback') % last command executed, play is still on
            [out,fig_modal]=guirecrd('stop');	% Modified, D.T.
            histlen=length(history);
            guirecrd('status', ['$gPlayback finished (record length = ' num2str(histlen) ')']);
         else
            % user stop or pause
            [out,fig_modal]=guirecrd('stop'); % call stop again to update status	% Modified, D.T.
            %break %this is wrong here, changed to return
            return
         end
         
         
      elseif strcmp(p1, 'back')
         index=max(index-1,1);
         history=updatefig(history, index, myfig);
      elseif strcmp(p1, 'forward')
         index=min(index+1, length(history)+1);
         history=updatefig(history, index, myfig);
      elseif strcmp(p1, 'begin')
         index=1;
         history=updatefig(history, index, myfig);
      elseif strcmp(p1, 'end')|strcmp(p1, 'GotoEnd')
         index=length(history)+1;
         history=updatefig(history, index, myfig);
         
         
      elseif strcmp(p1, 'edit')
         c=allchild(myfig);
         edit=findobj(c, 'flat', 'tag', ['fdtool_recorder_edit' num2str(p2)]);
         switch p2
         case 7 % index change
            ix=str2num(get(edit, 'string'));
            if ix<1 | ix>length(history)|(ix~=floor(ix))
               % bad value, write back old
               history=updatefig(history, index, myfig);
            else
               index=ix; history=updatefig(history, index, myfig);
            end
         otherwise % no check implemented
            history{index}=currentitem(myfig);
            SetDirtyFlag(Me, 1)
         end
         
         
      elseif strcmpi(p1, 'gotoaction')   
         % go to specified action
         if p2<1 | p2 > length(history)| floor(p2)~=p2
            error('Bad action index')
         end
         index=p2;
         history=updatefig(history, index, myfig);
         
      %end of commands updating history
			else %not a valid command
				 error(['Command ''',p1,''' is not recognized'])
      end
            
       % update history now
       updatefig(history, index, myfig);
       
   end   % not init
end % of all commands      


% local functions

function act_com=currentitem(myfig)
% return current figure data

c=allchild(myfig);
for ix=1:14
   edit(ix)=findobj(c, 'flat', 'tag', ['fdtool_recorder_edit' num2str(ix)]);
end
DebugInfo=struct('ErrorStatus', get(edit(9), 'value')-1,...
   'CheckFcn', get(edit(10), 'string'));
act_com.XParam    = get(edit(1), 'string');
act_com.SelType   = get(edit(2), 'string');
act_com.CurObj    = get(edit(3), 'string');
act_com.Win       = get(edit(4), 'string');
act_com.Fcn       = get(edit(5), 'string');
act_com.Cmd       = get(edit(6), 'string');
act_com.Info      = get(edit(8), 'string');
% the next line is needed while old demos are not completely converted:
act_com.Info      = cellstr(act_com.Info);
act_com.DebugInfo = DebugInfo;
act_com.Stop      = get(edit(11), 'value');
act_com.ObjName   = get(edit(12), 'string');
act_com.WinName   = get(edit(13), 'string');
act_com.Note      = get(edit(14), 'string');

function history=updatefig(history, index, myfig)
% updates figure data
% returns history (change if old history is updated)
% writes back history !!!!

c=allchild(myfig);
for ix=1:14
   edit(ix)=findobj(c, 'flat', 'tag', ['fdtool_recorder_edit' num2str(ix)]);
end
runstatus=[guiinfos('isrecorderplayback'),guiinfos('isrecorderrecord')];
if index <1 | index > length(history)
   set(edit, 'enable', 'inactive')
   % set(edit(7), 'string', '')
   for ix=[1:8, 10, 12:14]
      set(edit(ix), 'string', '')
   end   
   if isempty(history)
      if strcmp(RecorderMode(myfig), 'demo')
         msgstr='$yRecord is empty. Load history.';
      else
         msgstr='$yRecord is empty. Load history or record actions after pressing RECORD button.';
      end
   else
      msgstr=['$yEnd of Record. Record length = ' num2str(length(history))];
   end
   guirecrd('status', msgstr);
   set(edit(9), 'value', 1)
   set(edit(11), 'value', 0)
   
else
   if any(runstatus)  %  playback or record
      set(edit, 'enable', 'inactive')
   else % stopped
      switch RecorderMode(myfig)
      case 'demo'
         set(edit, 'enable', 'inactive')
      case 'recorder'
         set(edit(1:11), 'enable', 'on') 
         set(edit(12:14), 'enable', 'inactive')  
      otherwise  % development mode
         set(edit, 'enable', 'on')
      end
   end
   set(edit(7), 'string', num2str(index))
   act_com=history{index};
   set(edit(1), 'string', act_com.XParam)
   set(edit(2), 'string', act_com.SelType)
   set(edit(3), 'string', act_com.CurObj)
   set(edit(4), 'string', act_com.Win)
   set(edit(5), 'string', act_com.Fcn)
   set(edit(6), 'string', act_com.Cmd)
   % if guiinfos('isrecorderplayback') & ...
   if ~isempty(act_com.Info) & any(findstr(act_com.Info{1}, '#HOLD PREVIOUS#'))
     % do not update info field, hold previous for demonstration purposes
     1;
   else
     set(edit(8), 'string', act_com.Info) %new string
   end
   % help for Pisti: red, if still char, and not cell array
   if ischar(act_com.Info)
      set(edit(8), 'backgroundcolor', 'r'), 
   else 
      set(edit(8), 'backgroundcolor', get(edit(7), 'backgroundcolor'))
   end
   set(edit(9), 'value', act_com.DebugInfo.ErrorStatus+1)
   set(edit(10), 'string', act_com.DebugInfo.CheckFcn)
   set(edit(11), 'value', act_com.Stop)
   guirecrd('status', ['Command #' num2str(index) ' of ' num2str(length(history)) '.']);
   errorcatch
   if isfield(act_com, 'WinName')  
      % history before version 1.100 does not contain WinName and ObjName
      set(edit(12), 'string', act_com.ObjName)
      set(edit(13), 'string', act_com.WinName)
   else
      act_com.WinName='';
      act_com.ObjName='';
      set(edit(12), 'string', ['*' act_com.CurObj '*'])
      set(edit(13), 'string', ['*' act_com.Win '*'])
   end
   errorcatch

   % on-line conversion of old demos: update of WinName and ObjName fields
   UPDATE_REQUIRED=1; % true if update of old recordings required. Active only in development mode !
   if UPDATE_REQUIRED & guiinfos('isdevelopment') & guiinfos('isrecorderplayback')
      [ObjName, WinName]=GetFieldNames(act_com); % find WinName and ObjName
      act_com.ObjName=ObjName;
      act_com.WinName=WinName;
      history{index}=act_com;
      if any(findstr(act_com.WinName, '*')) | any(findstr(act_com.ObjName, '*'))
         disp(['Record update failed in win: ''' act_com.Win ''', obj: ''' act_com.CurObj '''.'])
      end
   end
   
   set(edit(14), 'string', act_com.Note)
   
end
% write back history
histdata.history=history; histdata.index=index;
guidtawr(get(myfig, 'tag'), 'RECORDERDATA', 'direct', histdata)
% end of function updatefig


function mouseto(tFig, tObj)
% positions the mouse over the object with tag tObj in figure tFig

hFig=findall(0, 'tag', tFig);
if isempty(hFig)
   disp(['Mouse Positioning Error: fig ''',tFig,''' is missing.' ])
   return
end
hObj=findobj(allchild(hFig), 'tag', tObj);
if isempty(hObj)
   disp(['Mouse Positioning Error: object ''' tObj ''' is missing.' ])
   return
end

RootUnit=get(0,'units');
set(0,'units', 'pixels');
ScreenSize=get(0,'screensize');

FigPos=get(hFig, 'position');
ObjType=get(hObj, 'type');
switch lower(ObjType)
case 'uicontrol'
   set(hObj, 'units', 'pixels');
   ObjPos=get(hObj, 'position');
   style=get(hObj, 'style');
   if any(findstr(style, 'radio'))|any(findstr(style, 'check'))  % go to left part of obj
      ScrCord=FigPos(1:2)+[ObjPos(1)+7 ObjPos(2)+ObjPos(4)/2];
   else % go to middle of obj
      ScrCord=FigPos(1:2)+[ObjPos(1)+ObjPos(3)/2 ObjPos(2)+ObjPos(4)/2];
   end
case 'uitoggletool'
   %set(hObj, 'units', 'pixels');
   %ObjPos=get(hObj, 'position');
   % go to middle of obj
   ScrCord=[FigPos(1)+20,FigPos(2)+FigPos(4)+10]; uttsize=25;
   if strcmp(get(hObj,'tag'),'fdtool_menu_userlevel_basic')
   elseif strcmp(get(hObj,'tag'),'fdtool_menu_userlevel_intermediate'), ScrCord(1)=ScrCord(1)+1*uttsize;
   elseif strcmp(get(hObj,'tag'),'fdtool_menu_userlevel_advanced'), ScrCord(1)=ScrCord(1)+2*uttsize;
   elseif strcmp(get(hObj,'tag'),'fdtool_menu_modeltype_linear'), ScrCord(1)=ScrCord(1)+3*uttsize+5;
   elseif strcmp(get(hObj,'tag'),'fdtool_menu_modeltype_nonlinear_errors'), ScrCord(1)=ScrCord(1)+4*uttsize+5;
   end
case 'uimenu'
   ScrCord=FigPos(1:2)+[5 FigPos(4)+5];
case 'patch'
   Ax=get(hObj,'parent');
   AxUnit=get(Ax, 'units');
   set(Ax, 'units', 'pixels');
   AxPos=get(Ax,'position');
   AxX =get(Ax, 'xlim'); 
   AxY =get(Ax, 'ylim'); 
   ObjX=get(hObj, 'xdata'); ObjY=get(hObj, 'ydata');
   CentX=(max(max((ObjX)))+min(min(ObjX)))/2;
   CentY=(max(max((ObjY)))+min(min(ObjY)))/2;
   XPix=(CentX-AxX(1))/diff(AxX)*AxPos(3);
   YPix=(CentY-AxY(1))/diff(AxY)*AxPos(4);
   ScrCord=AxPos(1:2)+FigPos(1:2)+[XPix YPix];
   set(Ax, 'units', AxUnit);
case 'surface' % bar 3d plot figures
   Ax=get(hObj,'parent');
   AxUnit=get(Ax, 'units');
   set(Ax, 'units', 'pixels');
   AxPos=get(Ax,'position');
   AxX =get(Ax, 'xlim'); x1=AxX(1); x2=AxX(2);
   AxY =get(Ax, 'ylim'); y1=AxY(1); y2=AxY(2);
   AxZ =get(Ax, 'zlim'); z1=AxZ(1); z2=AxZ(2);
   if 0
      
      v=get(Ax, 'view');
      az=v(1); el=v(2);
      %m=viewmtx(az,el);m=m(1:2, 1:3);
      m=(get(Ax, 'xform')) ;m=m(1:2, 1:4);
      
      MinMaxMat=[...
            x1 x1 x1 x1 x2 x2 x2 x2;...
            y1 y1 y2 y2 y1 y1 y2 y2;...
            z1 z2 z1 z2 z1 z2 z1 z2;...
            zeros(1, 8)];
      MinMaxXY=m*MinMaxMat
      MinAxX=min(MinMaxXY(1,:));
      MaxAxX=max(MinMaxXY(1,:));
      MinAxY=min(MinMaxXY(2,:));
      MaxAxY=max(MinMaxXY(2,:)); % these are the axes limits in the reference koord system
      
      
      
      ObjX=get(hObj, 'xdata'); ObjY=get(hObj, 'ydata'); ObjZ=get(hObj, 'zdata');
      ObjX=ObjX(find(~isnan(ObjX(:))));
      ObjY=ObjY(find(~isnan(ObjY(:))));
      ObjZ=ObjZ(find(~isnan(ObjZ(:))));
      CoordMat=[ObjX'; ObjY'; ObjZ'; ones(size(ObjX'))];
      XYCoords=m*CoordMat;
      
      
      CentX=(max((XYCoords(1,:)))+min(XYCoords(1,:)))/2;
      CentY=(max((XYCoords(2,:)))+min(XYCoords(2,:)))/2;
      
      CentY=max(XYCoords(2,:));
      
      XPix=(CentX-MinAxX)/(MaxAxX-MinAxX)*AxPos(3);
      YPix=(CentY-MinAxY)/(MaxAxY-MinAxY)*AxPos(4);
   end   
   % nem mukodik a kereses !
   XPix=0;
   YPix=0;
   
   ScrCord=AxPos(1:2)+FigPos(1:2)+[XPix YPix];
   set(Ax, 'units', AxUnit);
   
   
case 'axes'
   Ax=hObj;
   AxUnit=get(Ax, 'units');
   set(Ax, 'units', 'pixels');
   AxPos=get(Ax,'position');
   AxX =get(Ax, 'xlim'); 
   AxY =get(Ax, 'ylim'); 
   ScrCord=AxPos(1:2)+FigPos(1:2)+AxPos(3:4)/2;
   set(Ax, 'units', AxUnit);
otherwise
   disp(['Mouse Positioning Error: object ''' tObj ''' has wrong type.' ])
   set(0,'units', RootUnit);
   return
end
set(0, 'pointerlocation', ScrCord);
set(0,'units', RootUnit);



function mode=RecorderMode(myfig)
% RecorderMode can be development, recorder, or demo
mode=guidtard(get(myfig, 'tag'), 'recordermode');


function  pos=GetMousePos;
pos=get(0, 'pointerlocation');

function out=ConcvertOldHistory(history);
% convert old history format 
for ii=1:length(history)
   % 1. Convert str array to cell array in Info field
   history{ii}.Info=cellstr(history{ii}.Info);
   % 2. Make Note field if necessary
   if ~isfield(history{ii}, 'Note')
      history{ii}.Note={''};
   end
   % 3. Try to fill Window and Command fields
   % this is done during runtime
   
   % 4. modify old dismiss button tags
   % fdtool_dismiss_pb ->  [wintag, '_dismiss_pb'] 
   if strcmp(history{ii}.CurObj, 'fdtool_dismiss_pb')
      history{ii}.CurObj=[history{ii}.Win, '_dismiss_pb'];
   end
   
   % 5. modify old _mod_ tags
   % xxx_mod_yyy -> xxx_uic_yyy
   if findstr(history{ii}.CurObj, '_mod_')
      history{ii}.CurObj=strrep(history{ii}.CurObj,'_mod_', '_uic_');
   end
   
   % 6. modify old arrowdlg wintag
   % arrwdlg -> fdtool_arrowdlg
   if findstr(history{ii}.Win, 'arrowdlg')
      history{ii}.Win='fdtool_arrowdlg';
   end
   % end of ver 1.104
   
   % 7. modify old importfig wintag
   % importfig -> fdtool_importfig
   if findstr(history{ii}.Win, 'importfig')
      history{ii}.Win='fdtool_importfig';
   end
   
   % 8. modify old exportfig wintag
   % exportfig -> fdtool_exportfig
   if findstr(history{ii}.Win, 'exportfig')
      history{ii}.Win='fdtool_exportfig';
   end
   
   % end of ver 1.105
   
   % 9. modify old userlevel names 
   %if strcmp(history{ii}.Cmd, 'ui_userlevel_set')
   %   if strcmp(history{ii}.ObjName,'UserLevel Intermediate')
   %      history{ii}.ObjName='UserLevel Interactive';
   %   elseif strcmp(history{ii}.ObjName,'UserLevel Basic')
   %      history{ii}.ObjName='UserLevel Automatic';
   %   end
   %   history{ii}.XParam='';
   %end
   % end of ver 1.106
   
end
out=history;

function SetRecordedActionIsActive(mode, Me)
% Set 'RecordedActionIsActive' flag. 
% It's true if the execution of the recorded command has not finished yet
guidtawr(Me, 'RecordedActionIsActive', 'direct', mode);

function out=GetRecordedActionIsActive(Me)
% Get 'RecordedActionIsActive' flag
out=guidtard(Me, 'RecordedActionIsActive');


function SetErrorStatus(mode, Me)
% Set OK or Error or Warning status
guidtawr(Me, 'errorstatusflag', 'direct', mode);

function out=GetErrorStatus(Me)
% Get (last) OK or Error or Warning status since last clearing errorstatus flag
out=guidtard(Me, 'errorstatusflag');


function  DisplayName(myfig);
% display history source on window title
s=guidtard(get(myfig, 'tag'), 'HistorySourceInfo');
if isempty(s)
   str='Untitled';
else
   if strcmp(s.CurrentSource, 'FILE')
      if ~isempty(s.CurrentFileName), str=[s.CurrentFileName ' (' s.CurrentVarName ')'];
      else str=[s.CurrentVarName];
      end
    else
      if ~isempty(s.CurrentVarName)
        str=[s.CurrentVarName];
      else
        str='Untitled';
      end
    end
end
set(myfig, 'name', ['Recorder for FDTool: ' str])

function [ObjName, WinName]=GetFieldNames(histelem)
% Find WinName and ObjName for history item 'histelem'

if ~isempty(histelem.CurObj) & ~isempty(histelem.Win)
   [LongHelp, ShortHelp, ObjName]=fdhlpstr(histelem.Win, histelem.CurObj);
   [LongHelp, ShortHelp, WinName]=fdhlpstr(histelem.Win, histelem.Win);
   hWin=findobj(allchild(0), 'flat', 'tag', histelem.Win);
   if length(hWin)>1
      % we're in trouble: more window with the same tag
      % try to find the right one
      ix=[];
      for ii=1:length(hWin)
         if ~isempty(findobj(hWin(ii), 'tag', histelem.CurObj))
            ix=[ix,ii];
         end
      end
      if length(ix)>1
         error('Internal error: Unresolvable name clash (3)')
      else
         hWin=hWin(ix);
      end
   end
   hObj=findobj(allchild(hWin), 'tag', histelem.CurObj); % not flat (uimenus)!!
   if length(hObj)>1, error(['This window contains two objects with the same tag: ' histelem.CurObj]), end
   if length(ObjName)<3
      if strcmpi(get(hObj, 'type'), 'uimenu')
         % build name from menu label
         ObjName=get(hObj, 'label');
         hCurobj=hObj; parent=get(hCurobj, 'parent');
         while strcmp(get(get(parent, 'parent'), 'type'), 'uimenu') % add parent's name, but not the highest level
            ObjName=[get(parent, 'label') ' ' ObjName];
            hCurobj=parent; parent=get(hCurobj, 'parent');
         end
         ObjNames=ObjName;
         ObjName=strrep(ObjName, '&', ''); % remove shortcut characters
         if length(ObjName)==length(ObjNames)-2, ObjName=strrep(ObjNames, '&&', '&'); end
      elseif strcmpi(get(hObj, 'type'), 'uicontrol')
         if strcmpi(get(hObj, 'style'), 'popupmenu')
            ObjName='*popupmenu*';
         elseif strcmpi(get(hObj, 'style'), 'edit')
            ObjName='*edit*';
         elseif strcmpi(get(hObj, 'style'), 'listbox')
            ObjName='*listbox*';
         else
            ObjName=get(hObj, 'string');
         end
      else
         ObjName='**';
      end
   end
   if length(WinName)<3
      WinName=get(hWin, 'name');
   end
else
   ObjName=[histelem.CurObj];
   WinName=[histelem.Win];
end


function RecoverFile(fullfilename1234567890)
% load and save file, attempt to bypass MATLAB's save -append bug 
% RecoverFile makes save possible when files move between different platforms
try
  a1234567890=load('-mat',fullfilename1234567890);
catch
  a1234567890=load(fullfilename1234567890);
end
VarNames1234567890=fieldnames(a1234567890);
%delete(fullfilename1234567890) % not necessary, save replaces
eval([VarNames1234567890{1} '= getfield(a1234567890, VarNames1234567890{1});' ]);
wffn=which(fullfilename1234567890,'-all');
dffn=dir(fullfilename1234567890);
if ~isempty(wffn)
   if length(wffn)==1, fullfilename1234567890=wffn{1};
   else error(['More than 1 file ''',fullfilename1234567890,''' on the path'])
   end
else %file not on path
   if isempty(dffn), error(['File ''',fullfilename1234567890,''' not found'])
   end
end
save(fullfilename1234567890, VarNames1234567890{1})
for ii=2:length(VarNames1234567890)
   eval([VarNames1234567890{ii} '= getfield(a1234567890, VarNames1234567890{ii});' ]);
   save(fullfilename1234567890, VarNames1234567890{ii}, '-append')
end
%


function answ=SaveIfNeeded(myfig, history) 
answ='';
Me=get(myfig, 'tag');
if ~isempty(history) & ~strcmp(RecorderMode(myfig), 'demo') & ...
      GetDirtyFlag(Me)
   answ=questdlg('Do you want to save the current record?',  ...
     'Recorder', 'Yes', 'No', 'Cancel', 'Cancel');
   if strcmp(answ, 'Cancel')
     return %(with answer)
   elseif strcmp(answ, 'Yes')
     guirecrd('saveas');
     h_export= findobj(allchild(0), 'flat', 'tag', 'fdtool_exportfig');
     if ishandle(h_export)
       waitfor(h_export) % delete of fig is necessary in export_ready !!!
     end
   end
end


function flag=GetDirtyFlag(Me)
flag=isequal(guidtard(Me, 'dirtyFLAG'), 1);


function SetDirtyFlag(Me, dirtyflag)
oldflag=guidtard(Me, 'dirtyFLAG');
guidtawr(Me, 'dirtyFLAG', 'direct', dirtyflag);
if ~isequal(oldflag, dirtyflag)
   hFig=findobj(allchild(0), 'flat', 'tag', Me);
   namestr=get(hFig, 'name');
   if dirtyflag
      if ~isequal(namestr(end), '*')
         set(hFig, 'name', [namestr '*']);
      end
   else
      if isequal(namestr(end), '*')
         set(hFig, 'name', namestr(1:end-1));
      end
   end
end

% End of file

