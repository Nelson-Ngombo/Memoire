function questarr(p1,p2,p3,p4,p5,seltype);
% asks what to do with an arrow
% helper file of FDTool

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 16-Feb-2000, GYS

% Init: questarr(initstr, arrnum, sender) , 
% where initstr ='init1' (activation pb passive) or 
%                'init2' (activation pb active)
%                'init3' (only load and info active)


Me='fdtool_arrowdlg';
MyHand=findall(0, 'tag',Me);
myfcn='questarr';  

if nargin >0,
   
   if nargin == 6
      sender=p5;
      replay_mode='replay';
   else
      seltype=get(MyHand,'selectiontype');
      eval(['sender=p', num2str(nargin) ';']);
      replay_mode='normal';
   end
   
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%               INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if findstr(p1, 'init')
   
   if ~isempty(MyHand), delete(MyHand), end
   if strcmp(sender, 'gettime_main')
      p2=p2+100;
   end
   f = figure('Units','pixels', ...
      'Position',windspos(Me, p2), ...
      'Menubar', 'none', ...
      'Numbertitle', 'off', ...
      'IntegerHandle', 'off',...
      'handlevisibility', 'off',...
      'resize', 'off', ...
      'windowstyle', 'modal', ...
      'closerequestfcn',['fdtool(''callback'',''',myfcn,''',''ui_cancel'',''' Me ''')'],...
      'Name', 'Arrow Action', ...
      'color', get(0,'defaultuicontrolbackground'), ...
      'userdata', p2, ...
      'visible', 'off', ...
      'Tag', Me);
   set(f,'Position',windspos(Me, p2))
   
   fdwindef(f) % set default window props
   intoscr(Me);
   pos=get(f, 'position');
   dy=pos(4); % if dy>330; IsExport=1; else IsExport=0; end
   
   y=dy-40;
   h_info = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Info on Arrow', ...
      'enable', 'on', ...
      'tooltipstring', 'Detailed textual information on the arrow data',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_info_arrow'',''info_arrow_pb'')', ...
      'interruptible', 'off',...
      'Tag','info_arrow_pb');
   
   y=y-40;
   h_load = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Load Arrow Data', ...
      'enable', 'off', ...
      'tooltipstring', 'Load arrow data from workspace or file',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_load_arrow'',''load_arrow_pb'')', ...
      'interruptible', 'off',...
      'Tag','load_arrow_pb');
   
   y=y-40;
   h_save = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Save Arrow Data', ...
      'enable', 'off', ...
      'tooltipstring', 'Save arrow data to workspace or file',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_save_arrow'', ''save_arrow_pb'')', ...
      'interruptible', 'off',...
      'Tag','save_arrow_pb');
   
 %  if IsExport
 %     y=y-40;
 %     h_export = uicontrol('Parent',f, ...
 %        'Units','pixels', ...
 %        'Position',[15 y 110 25], ...
 %        'String','Export Arrow Data', ...
 %        'enable', 'off', ...
 %        'tooltipstring', 'Export arrow model in Control Toolbox LTI format',...
 %        'callback', 'fdtool(''callback'',''questarr'',''ui_export_arrow'', ''export_arrow_pb'')', ...
 %        'interruptible', 'off',...
 %        'Tag','export_arrow_pb');
 %  else
 %     h_export=h_save;
 %  end
   y=y-40;
   h_del = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Clear Arrow Data', ...
      'enable', 'off', ...
      'tooltipstring', 'Clear arrow data (and data in the previous box as well)',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_delete_arrow'',''delete_arrow_pb'')', ...
      'interruptible', 'off',...
      'Tag','delete_arrow_pb');
   
   y=y-40;
   h_plot = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Plot Arrow Data', ...
      'enable', 'off', ...
      'tooltipstring', 'Plot the arrow data',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_view_plot'',''view_plot_pb'')', ...
      'interruptible', 'off',...
      'Tag','view_plot_pb');
   
   y=y-40;
   h_act = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Activate Arrow', ...
      'enable', 'off', ...
      'tooltipstring', 'Activate arrow if is in passive mode',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_activate_arrow'',''activate_arrow_pb'')', ...
      'interruptible', 'off',...
      'Tag','activate_arrow_pb');
   
   
   y=y-60;
   h = uicontrol('Parent',f, ...
      'Units','pixels', ...
      'Position',[15 y 110 25], ...
      'String','Cancel', ...
      'tooltipstring', 'Close window without action',...
      'callback', 'fdtool(''callback'',''questarr'',''ui_cancel'',''questarr_cancel'')', ...
      'interruptible', 'off',...
      'Tag','questarr_cancel');
   
   
   if strcmp(p1, 'init1')
%      set([h_plot, h_save, h_export, h_load, h_del], 'enable', 'on')
      set([h_plot, h_save, h_load, h_del], 'enable', 'on')
   elseif strcmp(p1, 'init2')
%      set([h_act, h_plot, h_save, h_export, h_load, h_del], 'enable', 'on')
      set([h_act, h_plot, h_save, h_load, h_del], 'enable', 'on')
   elseif strcmp(p1, 'init3')
      set([h_load], 'enable', 'on')
   end
   set(f, 'visible', 'on')
else % not init
   
   if strcmp(p1, 'ui_activate_arrow')  % only fdtool_main
      arrnum=get(MyHand, 'UserData');
      delete(MyHand)
      fdtool('activate_an_arrow', arrnum, Me);
      
   elseif strcmp(p1, 'ui_delete_arrow')  
      arrnum=get(MyHand, 'UserData');
      if arrnum < 100
         boxmgr(['delete_arrow_' num2str(arrnum)], 'fdtool_main');
      else    
         boxmgr(['delete_arrow_' num2str(arrnum-100)], 'gettime_main');
      end
      delete(MyHand)
      
   elseif strcmp(p1, 'ui_save_arrow') | strcmp(p1, 'ui_load_arrow')| strcmp(p1, 'ui_export_arrow')
      arrnum=get(MyHand, 'UserData');
      if arrnum<100 % fdtool main window
         switch  arrnum
         case {1,2,3}
            source='OUTPUT_excitation';
            dataname='arrowdata_essd';
         case 4
            source='OUTPUT_gettime';
            dataname='arrowdata_gtdd';
         case 5
            source='OUTPUT_getfreq';
            dataname='arrowdata_gfdd';
         case {6,7,8}
            source='OUTPUT_average';
            dataname='arrowdata_agv';
         case 9
            source='OUTPUT_select';
            dataname='arrowdata_sme';
         case 10
            source='OUTPUT_aided';
            dataname='arrowdata_cams';
         case 11
            source='OUTPUT_compare';
            dataname='arrowdata_caem';
         otherwise
            error('Internal error. QUESTARR: bad arrow index')
         end
         outdata=guidtard('fdtool_main', source);
         callfcn='fdtool'; 
      else % gettime main window
         switch  arrnum
         case 101
            dataname='arrowdata_time';
            source='DATA_gotdata';
         case 102
            dataname='arrowdata_segm';
            source='DATA_segmenteddata';
         case 103
            dataname='arrowdata_conv';
            source='DATA_converteddata';
         case 104
            dataname='arrowdata_sel';
            source='DATA_selecteddata';
         otherwise
            error('Internal error. QUESTARR: bad arrow index')
         end
         outdata=guidtard('gettime_main', source);
         callfcn='gettime'; 
      end
      
      switch arrnum
      case {1, 2, 3}
         filter='filter: tiddata Object (Single Channel)';
      case {101, 102}
         filter='filter: tiddata Object';
      case {4, 5, 103, 104} 
         filter='filter: fiddata Object'; % with or without variance
      case {4, 5, 6, 7, 8, 103, 104}
         filter='filter: fiddata Object with Variance'; % with variance 
      case {9, 11}
         filter='filter: fidmodel object with fitted data';
      case {10}
         filter='filter: fidmodel object(s) with fitted data';
      otherwise
         error('INTERNAL ERROR: bad arrow number.')
      end
      
      if findstr(p1, 'load_arrow')
         call_ID=struct('arrnum', arrnum, 'message', 'Arrow data');
         guiimpv('init', myfcn, call_ID, '', filter)
      elseif findstr(p1, 'save_arrow') 
         call_ID=struct('arrnum', arrnum, 'message', 'Arrow data');
         initvar=struct(...
            'CurrentSource', 'WP', ...
            'CurrentPath', [''],...
            'CurrentFileName', 'arrowdta',...
            'CurrentVarName', dataname);
         initvar.ExportData=outdata; % it does not work with struct !!!!
         guiimpv('init_export', myfcn, callfcn, initvar, filter)
      else % export arrow
         disp('not implemented yet...')
         
      end
      delete(MyHand)
      
   elseif strcmp(p1, 'ui_info_arrow')
      arrnum=get(MyHand, 'UserData');
      garrinfo(arrnum)
      delete(MyHand)
      
   elseif strcmp(p1, 'import_ready')
      switch  p2
      case 'cancel'
         
      case 'done'
         data=guidtard('fdtool_importfig', 'IMPORTED_VAR');
         arrnum=p3.arrnum;
         if arrnum < 100  % fdtool_main window
            fdtool('load_an_arrow', arrnum, data)
         else  % gettime window
            gettime('load_an_arrow', arrnum-100, data)
         end
      end
      
   elseif strcmp(p1, 'export_ready')
      switch  p2
      case 'cancel'
         
      case 'done'
         % arrnum=p3.arrnum;
         questarr('status', 'Arrow data exported')
      end      
      
   elseif strcmp(p1, 'ui_view_plot')
      arrnum=get(MyHand, 'UserData');
      if arrnum<100
         arrstr=['l' num2str(arrnum)];
      else
         arrstr=['arr' num2str(arrnum-100)];
      end
      arrplot(arrstr,'')
      delete(MyHand)
      
   elseif strcmp(p1, 'ui_cancel')
      delete(MyHand)
      
   elseif strcmp(p1,'status')
      arrnum=get(MyHand, 'userdata');
      
      if arrnum > 100
         gettime('status', p2)
      else
         fdtool('status', p2)
      end
   else
      error(['bad command called in questarr:' p1])
   end % of last command
end % of commands
%