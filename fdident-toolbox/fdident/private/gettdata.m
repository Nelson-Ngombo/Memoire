function gettdata(p1,p2,p3,p4,p5,seltype);
%GETTDATA get time domain data
%Helper function of FDTOOL


%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 07-Dec-2002

Me='gettdatafig';
MyHand=findall(0, 'tag',Me);
myfcn='gettdata';  

if nargin >0 & ~strcmp(p1, 'init')        
   if nargin == 6
      sender=p5;                
   else                                                
      seltype=get(MyHand,'selectiontype');
      eval(['sender=p', num2str(nargin) ';']);
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if nargin == 0 | strcmp(p1, 'init')
   if ~isempty(MyHand), delete(MyHand), end
   f = figure('Units','pixels', ...
      'Position',windspos(Me), ...
      'color', get(0,'defaultuicontrolbackgroundcolor'),...
      'Numbertitle', 'off', ...
      'IntegerHandle', 'off',...
      'Handlevisibility', 'off',...
      'resize', 'off', ...
      'closerequestfcn',['fdtool(''callback'',''',myfcn ''',''ui_cancel'',''gettdata_cancel'')'],...
      'Name', 'Get Data', ...
      'visible','off',...
      'Tag', Me);
   if strncmp(version,'5',1), set(f,'Position',windspos(Me)), end %fix in 5.3
   MyHand=f;
   fdwindef(f);  % set default window properties
   
   h = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 185 140 25], ...
      'String','Import...', ...
      'Tooltipstring','Read tiddata object from workspace, or from file',...      
      'callback', 'fdtool(''callback'',''gettdata'',''ui_import'',''gettdata_import'')', ...
      'interruptible', 'off', ...
      'Tag','gettdata_import');
   
   gettdata_compose = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 150 140 25], ...
      'String','Compose...', ...
      'tooltipstring','Compose input',...
      'callback', 'fdtool(''callback'',''gettdata'',''ui_compose'',''gettdata_compose'')', ...
      'interruptible', 'off', ...
      'Tag','gettdata_compose',...
      'enable','on');   
   
   gettdata_measurement = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 80 140 25], ...
      'String','Measure...', ...
      'tooltipstring','Start measurement using hardware connected to computer',...
      'callback', 'fdtool(''callback'',''gettdata'',''ui_measurement'',''gettdata_measurement'')', ...
      'interruptible', 'off', ...
      'Tag','gettdata_measurement',...
      'enable','on');   
   
   gettdata_simulation = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 115 140 25], ...
      'String','Simulate...', ...
      'tooltipstring','Generate noisy simulated data for model, using designed excitation signal',...
      'callback', 'fdtool(''callback'',''gettdata'',''ui_simulation'',''gettdata_simulation'')', ...
      'interruptible', 'off', ...
      'Tag','gettdata_simulation');
   
   h = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[40 20 90 25], ...
      'String','Cancel', ...
      'Tooltipstring','Close window without saving data',...
      'callback', 'fdtool(''callback'',''gettdata'',''ui_cancel'',''gettdata_cancel'')', ...
      'interruptible', 'off', ...
      'Tag','gettdata_cancel');
   
   guimenus(Me,'gettdata','gettdata');
   helpmgr('init_help', '', myfcn, MyHand );
   
   if nargin >1 
      storewin('restore_all', Me, p2) % bring up window with settings in p2
   else
      storewin('recover', Me); % restore previous settings if any
   end
   
   intoscr({Me});
   
   % The above function, intoscr positions the windows given by their labels
   % into the actual screen. This might come handy when the session has been saved 
   % on a machine with different resolution than that of the present machine.
   
   ulevctrl('gettdatafig'); 
   
   if strcmp(guiinfos('userlevel'),'Automatic')&0 %bypass direct opening (allow compose)
      % in basic only one pb (import) is alive, hide window and call import
      % when replayed, no hide and no auto import call (it recorded !!)
      if ~guiinfos('isrecorderplayback')
        %hide window on computers NOT Macintosh
        %if ~strncmpi(computer,'MAC',3) %rarmdemo errors out
        if strcmpi(computer,'PCWIN')|strncmpi(computer,'SOL',3)
           set(MyHand,'visible','off') %This is tested
        end
        % automatically press import pb
        fdtool('callback', 'gettdata', 'ui_import', 'gettdata_import')
     else
        %during playback gettdata win is always alive
     end
   else
     set(f,'visible','on'); drawnow
   end
   
else % not init
   
   if strcmp(p1, 'ui_import')
      SetEnableAllPB(MyHand, 'off')
      guiimpv('init', myfcn, 'Time domain data', [], 'filter: tiddata Object')
      1;
      
   elseif strcmp(p1, 'ui_measurement')
      SetEnableAllPB(MyHand, 'off')
      gettime('status','Opening Measure... ')
      fdmeasw('init', 'TIME', 'gettdata')
      
   elseif strcmp(p1, 'ui_simulation')
      SetEnableAllPB(MyHand, 'off')
      gettime('status','Opening Simulate... ')
      fdsimul('init', 'TIME', 'gettdata')
      
   elseif strcmp(p1, 'ui_compose')
      SetEnableAllPB(MyHand, 'off')
      simple=strcmpi(guiinfos('signaltype'),'all');
      if simple
        compinp('init1', 'gettdata', 'simple');
      else
        compinp('init1', 'gettdata', '');
      end
   elseif strcmp(p1, 'ui_cancel')
      guiclose('gettdata'), drawnow
      gettime('finished_box','rect_gettdata','cancel');
      
   elseif strcmp(p1,'simulation_ready') | strcmp(p1,'measurement_ready')
      % p2: 'done' or 'cancel'
      % p3: returned data
      guiclose('gettdata'), drawnow
      switch p2
      case 'done'
         guidtawr('gettime_main','DATA_gotdata','direct',p3);
         gettime('zohcomp',p3); %set visibility of zohcomp 
         gettime('finished_box','rect_gettdata','done',Me)
      case 'cancel'
         gettime('finished_box','rect_gettdata','cancel');
      end      
      ulevctrl('gettime_main')

   elseif strcmp(p1, 'import_ready')
      switch  p2
      case 'cancel'
         guiclose('gettdata'), drawnow
         ulevctrl('gettime_main')
         gettime('finished_box','rect_gettdata','cancel');
      case 'done'
         data=guidtard('fdtool_importfig', 'IMPORTED_VAR'); 
         if strcmpi(guiinfos('signaltype'),'all')
           if data.expn>1
             gettime('status','#yMore than one experiments are included in time domain data')
             error('More than one experiments are included in time domain data')
           end
           data.inputfrequencies=[];
           data.outputfrequencies=[];
           data.frequencies=[];
           data.periodlength=[];
         end
         guiclose('gettdata'), drawnow
         guidtawr('gettime_main','DATA_gotdata','direct',data);
         gettime('zohcomp',data); %set visibility of zohcomp 
         if ~strcmp(guiinfos('userlevel'),'Automatic')
           %boxmgr('delete_arrow_2', 'gettime_main'); %error in auto mode
           %try, gettime('ui_autoconvert'), catch, end %fix coloring
         end
         ulevctrl('gettime_main')
         if strcmp(guiinfos('userlevel'),'Automatic')
           if strcmpi(guiinfos('signaltype'),'all')
             %gettime('setbox','rect_convert',guicolor('BOX_COLOR_UNSELECTABLE'));
             %gettime('finished_box','rect_gettdata','done',Me)
             gettime('finished_box','rect_gettdata','done',Me) %gettdata done arrow
             %gettime('autofinish','','with_freq_selection')
           else %periodic
             gettime('finished_box','rect_gettdata','done',Me)
             %
             %gettime('setbox','rect_convert',guicolor('BOX_COLOR_UNSELECTABLE'));
             %gettime('autofinish')
             %agv('init'), 
             %agv('suggest')
           end
         else
           gettime('finished_box','rect_gettdata','done',Me) %gettdata done arrow
         end
      end
      
   elseif findstr(p1, 'compose_ready') % test only
      action=p2; id=p3; data=p4;
      compinp('kill')
      switch action
      case 'cancel'
         guiclose('gettdata'), drawnow
         gettime('finished_box','rect_gettdata','cancel');
         ulevctrl('gettime_main')
         gettime('status', 'Data composition cancelled.')
       case 'done'
         guiclose('gettdata'), drawnow
         guidtawr('gettime_main','DATA_gotdata','direct',data);
         gettime('zohcomp',data); %set visibility of zohcomp 
         gettime('finished_box','rect_gettdata','done',Me)
         ulevctrl('gettime_main')
         gettime('status', 'Data composition done.')
      end
      if strcmpi(guiinfos('signaltype'),'all')
        gettime('setbox','rect_convert',guicolor('BOX_COLOR_UNSELECTABLE'));
      end

   elseif strcmp(p1,'status')
      gettime('status', p2)
      
   end % of last command
end % of commands


function SetEnableAllPB(myfig, enable)
ch=allchild(myfig);
h=[findobj(ch, 'flat', 'tag', 'gettdata_import'), ...
      findobj(ch, 'flat', 'tag', 'gettdata_compose'), ...
      findobj(ch, 'flat', 'tag', 'gettdata_measurement'), ...
      findobj(ch, 'flat', 'tag', 'gettdata_simulation')];

set(h, 'enable', enable);
