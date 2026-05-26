function out=helpmgr (varargin)
%function mode=helpmgr (command, sender, WinFcn, WinHand, seltype)
% HELPMGR Help manager
% Helper function of FDTool

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon 
%       Last modified: 21-Mar-2005, IK

% commands:init_help                   -- initialize help functions of a window
%          callback_action             -- call from wrapper: callback
%            special menu calls: 
%              ui_help_this              -- help on this window
%              ui_help_fdid              -- help on FDTool
%              ui_help_start             -- getting started
%              ui_help_this              -- help on this window
%              ui_help_object            -- help on object (switch to HOO mode)
%              ui_help_expimp            -- help on export/import
%            context sensitive help:
%              click_on_uicontrol_help   -- help on object (in HOO mode)

v=version;
switch varargin{1}
case 'callback_action'
   command=varargin{3}; 
   if length(varargin)==8
      sender=varargin{end-1}; 
   else
      sender=varargin{end}; 
   end
   if isstr(command)
     useraction=any([findstr('click_on', command), findstr('ui_', command),...
         findstr('uic_', command), findstr('buttondown', command)]);
     if ~useraction&isstr(sender)
       useraction=~any(strcmp(command, 'status'))&any(findstr('_menu_', sender));
     end
   else
     useraction=0;
   end
   if useraction
      [WinFcn, CurObj, WinHand, seltype, XParam]=extrtcal(varargin{2:end});
      if isempty(CurObj)&isequal(varargin{end},'essd_uic_fgrb(3)') 
        sender='essd_uic_fgrb(3)_randomized';
        varargin{end}=sender;
        [WinFcn, CurObj, WinHand, seltype, XParam]=extrtcal(varargin{2:end});
      end      
      if isempty(CurObj)   
         mode = 'normal';
         if guiinfos('isdevelopment')
            error(['Development error: missing or bad object: ' sender])
         end
         return         
      elseif strcmp(get(CurObj,'type'),'uitoggletool')
        %flip state for uitoggletools
        if strcmp(get(CurObj,'state'),'on'), set(CurObj,'state','off')
        elseif strcmp(get(CurObj,'state'),'off'), set(CurObj,'state','on')
        end
      end
      WinTag=get(WinHand, 'tag');
      if guiinfos('ishelpmode',WinHand)
         mode='help';
         % set non-help mode
         if str2num(v(1:3))<6.0
           ui_props_save=getuprop(WinHand, 'ui_props_save');
         else
           ui_props_save=getappdata(WinHand, 'ui_props_save');
         end
         %clruprop(WinHand, 'ui_props_save');
         rmappdata(WinHand, 'ui_props_save');
         if ~isempty(ui_props_save), l=length(ui_props_save.h); else l=0; end;
         for i=1:l
            if ishandle(ui_props_save.h(i))
               set(ui_props_save.h(i),'enable',ui_props_save.en{i});
            end
         end
         set(WinHand,'pointer','arrow')
         %clruprop(WinHand, 'ui_props_save');
         if isappdata(WinHand, 'ui_props_save'), rmappdata(WinHand, 'ui_props_save'); end
         % help action
         eval([ WinFcn '(''status'',''Generating help...'')']);
         if strcmp(WinTag,'freqsel3fig')|strcmp(WinTag,'freqsel2fig'), WinTag='freqselfig'; end
         WindowHelp(WinTag, sender)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'');']);
         if guiinfos('isdevelopment')
           disp(['h= findall(0, ''tag'', ''' sender '''), ' sender]) %test only
           evalin('base',['h= findall(0, ''tag'', ''' sender ''')'])
         end
         
      elseif findstr('click_on', command) 
         ObjType=get(CurObj, 'type');
         if strcmp(ObjType, 'patch')|strcmp(ObjType, 'axes') % boxes or plots
            if strcmp(seltype, 'normal')
               mode='help'; % short help
            else
               mode='normal';    %open window
            end
         else
            if any(findstr(sender, 'caem_uic_frame(')) & ~strcmp(seltype, 'normal')
               mode='normal';      % info on model in caem window
            else
               mode='help'; % click on object (buttondownfcn call)
            end
         end
         
         if strcmp(mode, 'help')
            % short help
            [LongHelp, ShortHelp, Name]=fdhlpstr(WinTag, sender);
            if length(ShortHelp)>2
               %ShortHelp='Use context sensitive help to get info on this object';
               feval(WinFcn ,'status' , ShortHelp);
            end
            if guiinfos('isdevelopment')
               disp(['SHORT Help on: ', ...
                     sender, '.   h=' num2str(sender)])  % test only
                     %sender, '.   h=' num2str(CurObj)])  % test only
            end
         end
         
      elseif strcmp(command,'ui_help_object')
         mode='help';
         setptr(WinHand,'help')
         % get uicontrol enable prop
         h_uic=findobj(allchild(WinHand), 'flat', 'type', 'uicontrol');
         en_uic=get(h_uic, 'enable');
         if isempty(en_uic), en_uic={}; end
         % save menu enable prop
         h_uim=findobj(allchild(WinHand), 'type', 'uimenu');
         en_uim=get(h_uim, 'enable');
         if isempty(en_uim), en_uim={}; end
         % save enable properties
         h=[h_uic; h_uim]; en=[en_uic; en_uim];
         ui_props_save.h=h;
         ui_props_save.en=en;
         if str2num(v(1:3))<6.0
           cond=getuprop(WinHand, 'ui_props_save');
         else
           cond=getappdata(WinHand, 'ui_props_save');
         end
         if isempty(cond)
           if str2num(v(1:3))<6.0
             setuprop(WinHand, 'ui_props_save', ui_props_save);
           else
             setappdata(WinHand, 'ui_props_save', ui_props_save);
           end
         else  
            if guiinfos('isdevelopment')
               warning('Help mode is already on, attempt to set again')
            end
         end
         set(h_uic,'enable','inactive');
         set(h_uim,'enable','on');
         %experiment
         feval(varargin{4},'status','$yClick on an object to get help.')
         eval([ WinFcn '(''status'',''Click on an object to get help. '' , sender)']);
         %yellow: $y
         
      elseif strcmp(command,'ui_help_this')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         WinTag=get(WinHand, 'tag');
         WindowHelp(WinTag, WinTag)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_export')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         WinTag=get(WinHand, 'tag');
         WindowHelp(WinTag, command)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_fdid')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']); 
         WinTag='fdtool_main';
         WindowHelp(WinTag, WinTag)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']); 
         
      elseif strcmp(command,'ui_help_start')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         WinTag='fdtool_main'; HelpObj='getting_started';
         WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_expimp')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         HelpObj='export-import';
         WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_nonlin')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         WinTag='fdtool_main'; HelpObj='nonlinearities';
         WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_runmod')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         HelpObj='sme_menu_help_runmod';
         WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_autoorder')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         HelpObj='sme_menu_help_autoorder';
         WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_autoorder_demo')
         mode='help';
         eval([ WinFcn '(''status'',''Executing demo...'')']);
         HelpObj='sme_menu_help_autoorder_demo';
         autoorder_demo('init','sme'); out='';
         %WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      elseif strcmp(command,'ui_help_save_object')
         mode='help';
         eval([ WinFcn '(''status'',''Generating help...'')']);
         HelpObj='sme_menu_help_save_object';
         WindowHelp(WinTag, HelpObj)
         eval([ WinFcn '(''status'',''Help ready, see MATLAB Help Window...'')']);
         
      else
         % normal operation
         mode = 'normal';
      end
   else
      % normal operation
      mode = 'normal';
   end
case 'init_help'
    % call: helpmgr('init_help', '', WinFcn, WinHand)
   WinHand=varargin{4}; WinFcn=varargin{3};
   h=findobj(allchild(WinHand), 'flat', 'type', 'uicontrol');
   tags=get(h,'tag');
   for ii=1:length(h)
      set(h(ii),'buttondownfcn',['fdtool(''callback'',''',WinFcn,''',''click_on_uicontrol_help'', ''' tags{ii}, ''')'])
   end
   
otherwise
   mode='normal';
end
if nargout>0,out=mode;end



function WindowHelp(Win, Obj)
% call helpwin with info on Obj in window Win (tags)

% exception handling:
% exception #1 caem_bar3d[x/x] - > call with caem_bar3d
if findstr(Obj, 'caem_bar3d'), Obj='caem_bar3d'; end
if strcmp(Obj,'gettime_zoh_compensate')
  inpch=guiinfos('gettime_datacharacter');
  if strncmp(inpch,'ZOH',3)
    Obj=[Obj,'ZOH'];
  elseif strcmp(inpch,'BL')|strcmp(inpch,'Samples')
    Obj=[Obj,'BL'];
  elseif strcmp(inpch,'FOH')
    Obj=[Obj,'FOH'];
  end
  Obj=lower(Obj);
%Special handling of certain tags:
elseif strcmp(Obj,'essd_uic_genpop')|strcmp(Obj,'essd_uic_gentypetext')
  if strcmpi(guiinfos('userlevel'),'advanced')
    %Add separate text "advanced" to tag
    Obj=[Obj,'/advanced'];
  end
elseif strcmp(Obj,'essd_uic_fgrb(6)')|strcmp(Obj,'essd_uic_fgrb(3)') 
  %Odd no third/Randomized linear, Odd quasilog/Randomized odd quasilog
  if any(findstr(get(findobj(findall(0,'type','figure','tag',Win),'tag',Obj),'string'),...
      'Randomized'))
    Obj=[Obj,'_randomized'];
  end
elseif strcmp(Obj,'agv_axes_uaxes')|strcmp(Obj,'agv_axes_laxes')|...
    strcmp(Obj,'sme_axes_uaxes')|strcmp(Obj,'sme_axes_laxes')
  if ~guiinfos('islinear')
    %For the nonlinear case, give special explanations
    Me='average_main';
    if israndomized(guidtard(Me,'DATA_Fdat'))&any(findstr('agv',Obj))
      Obj=[Obj,'_interp'];
    else
      Obj=[Obj,'_nonlin'];
    end
  else
    ha=findall(0,'tag','agv_axes_laxes');
    if ~isempty(findobj(h,'marker','x'))
      Obj=[Obj,'_variances'];
    end
  end
end

[LongHelp, ShortHelp, Name]=fdhlpstr(Win, Obj);
ix=findstr(LongHelp, '#');
if ~isempty(ix)
   if length(ix)==2 & ix(1)<3
      % warning('Possibly bad help string!')
      Obj=LongHelp(ix(1)+1:ix(2)-1);
      [LongHelp, ShortHelp, Name_tmp]=fdhlpstr(Win, Obj);
   end
end
%
%EXCEPTION!!! Temporary additional info for nonlinear processing
if ~guiinfos('islinear')&isstr(Obj)&...
    ( strcmp(Obj,'caem_uic_typepop')|strcmp(Obj,'caem_axes_axes(2)')|strcmp(Obj,'caem_axes_axes(3)') )
  ind=findstr(LongHelp,'in magenta.')+10;
  for ii=length(ind):-1:1
    LongHelp=[LongHelp(1:ind(ii)),...
        sprintf('\nThe bounds for the nonlinear analysis are shown in blue.'),...
        LongHelp(ind(ii)+1:end)];
  end
end
%
if length(Name)<2 |(length(Name)>0 & strcmp(Name(1), '*'))
   Name='FDTool Help'; 
end
if length(LongHelp)<3 | (length(LongHelp)>1 & strcmp(LongHelp(1), '*'))
   % try to create help from tooltipstring
   hWin=findobj(allchild(0), 'flat', 'tag', Win);
   if ~isempty(hWin)
      hObj=findobj(allchild(hWin), 'flat', 'tag', Obj);
   else
      hObj='';
   end
   LongHelp=eval('get(hObj, ''Tooltipstring'')', '''''');
   if isempty(LongHelp)
      LongHelp='Sorry, no help available yet.'; 
   end
   helpwin({Name, LongHelp})
else
   topic_index=findstr(LongHelp,'!@!');
   if ~isempty(topic_index)
      N=length(topic_index)/2;
      ixStart=topic_index(1:2:2*N-1); 
      ixStop=topic_index(2:2:2*N); 
      ixStart(end+1)=length(LongHelp+1); % extra index to ease collection of data
      HelpWithTopic={};
      for ii=1:N
         HelpWithTopic=[HelpWithTopic; ...
               {LongHelp(ixStart(ii)+3:ixStop(ii)-1)...
                  ['Help on ' Name ': ' LongHelp(ixStart(ii)+3:ixStop(ii)-1), sprintf('\n\n')...
                     LongHelp(ixStop(ii)+4:ixStart(ii+1)-1), ...
                     sprintf('\nOther topics are also available, use the Topics menu.')]}];
      end
      helpwin(HelpWithTopic)
   else
      % 'normal' help, but extras may be present, e.g. measure
      if guiinfos('ismeasurement') % only if measurement is enabled
         measuretags=...
            '|gettdatafig|essd_uic_genpop|rect_gettime|rect_getfreq|gettime_main|getfreq_main|';
         if findstr(measuretags, ['|' Obj '|'])
            [LongHelpMeasure, ShortHelp1, Name1]=fdhlpstr(Win, [Obj '_measurement']);
            LongHelp=sprintf('%s\n%s', LongHelp, LongHelpMeasure);
         end
      end
      helpwin({Name, LongHelp})
   end
end
if ~isempty(findall(0,'tag','MiniHelPFigurE'))
  intoscr('MiniHelPFigurE')
end
%