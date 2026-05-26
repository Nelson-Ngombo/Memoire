function out=guifreez(tFig, mode, ID)
% function out=guifreez(tFig, mode, ID)
%
% freeze or unfreeze FDTool figure with tag tFig
% tFig is the tag of window or can be 'all_fdtool'  passing command
% to all existing FDTool windows
% mode: 'freeze', 'unfreeze', or 'freeze_strong'
% ID: Identifier should be the same on freeze and unfreeze
%     unfreeze will be active only if freeze info contains
%     the same ID thus providing correct handle of nested calls
%     unfreeze ID can be 'force' causing defreeze unconditionally
%     freeze_strong disables watchdog
%         USE ONLY IN CASES when
%         other window opens and no continuously running process is present
%         (e.g. import), and correct unfreeze is provided in all case, 
%         even if error occures
% ------------ Note on usage ----------
% The caller should not modify any of the objects' 
% enable, hittest, callback properties while the window is frozen.
% Returns 0 if call is freeze and window already frozen or
% if call is unfreeze but window cannot be unfrozen (missing freeze 
% info, non-matching ID, or nonexisting window)

if strcmp(tFig, 'all_fdtool')
   h_vect=guiinfos('allchild', 'fdtool_main'); h_vect{end+1}='fdtool_main';
   for win_ix=1:length(h_vect)
      out(win_ix)=guifreez(h_vect{win_ix}, mode, ID);
   end
   return
end
hFig=findobj(allchild(0), 'flat', 'tag', tFig);
out=1;
switch mode
case {'freeze', 'freeze_strong'}
   if isempty(hFig)
      return
   end
   % test if figure is already frozen
   s_obj=guidtard(tFig, 'DATA_FRIDGE');
   if ~isempty(s_obj)
      % warning(['Window ' tFig ' is already frozen!'])
      out=0;
      return
   end
   ch=get(hFig, 'children');
   
   Menus=findobj(ch, 'flat', 'type', 'uimenu', 'visible', 'on');
   Menu.Tags=get(Menus, 'tag');
   Menu.Enable=get(Menus, 'enable');
   
   Uis=findobj(ch, 'flat', 'type', 'uicontrol', 'visible', 'on');
   Ui.Tags=get(Uis, 'tag');
   Ui.CallBack=get(Uis, 'callback');
   Ui.HitTest=get(Uis, 'hittest');
   Ui.Enable=get(Uis, 'enable');
   
   AllAxs=findobj(ch, 'flat', 'type', 'axes');
   Axs=findobj(AllAxs, 'flat', 'hittest', 'on'); % store only those with hittest on
   tags=get(Axs, 'tag'); 
   if ~iscell(tags); tags={tags}; end
   Axes.Tags=tags;
   
   Pas=findobj(AllAxs, 'type', 'patch', 'visible', 'on', 'hittest', 'on'); % -"-
   tags=get(Pas, 'tag'); 
   if ~iscell(tags); tags={tags}; end
   Patch.Tags=tags;
   
   Surf=findobj(AllAxs, 'type', 'surface', 'visible', 'on', 'hittest', 'on'); % -"-
   tags=get(Surf, 'tag'); 
   if ~iscell(tags); tags={tags}; end
   Surface.Tags=tags;
   
   Win.WindowButtonMotionFcn=get(hFig, 'WindowButtonMotionFcn');
   Win.WindowButtonDownFcn=get(hFig, 'WindowButtonDownFcn');
   Win.WindowButtonUpFcn=get(hFig, 'WindowButtonUpFcn');
   Win.KeyPressFcn=get(hFig, 'KeyPressFcn');
   Win.Pointer=get(hFig, 'Pointer');
   
   save_obj=struct('Menu', Menu, 'Ui', Ui, 'Axes', Axes, 'Patch', Patch, 'Surface', Surface, 'Win', Win, 'ID', ID);
   guidtawr(tFig, 'DATA_FRIDGE', 'direct', save_obj)
   
   set(Menus, 'enable', 'off')
   set([Uis; Axs; Pas; Surf], 'hittest', 'off')
   set([Uis], 'Callback', '')
   % in order to keep the same look set only uis with enable 'on' to 'inactive'
   UisEn=findobj(Uis, 'enable', 'on');  
   set(UisEn, 'Enable', 'inactive');
   set(hFig,...
      'WindowButtonMotionFcn', ['fdtool(''callback'',''guifreez'',''' tFig ''', ''watchdog'', ''dummy'');'],...
      'WindowButtonDownFcn', '',...
      'WindowButtonUpFcn','',...
      'KeyPressFcn','',...
      'pointer', 'watch')
   if findstr(mode, 'strong')
      set(hFig, 'WindowButtonMotionFcn', '')  % no watchdog
   end
case 'unfreeze'
   if isempty(hFig)
      out=0; return
   end
   save_obj=guidtard(tFig, 'DATA_FRIDGE');
   if isempty(save_obj)
      out=0; return
   end
   if ~strcmp(save_obj.ID, ID) & ~strcmp(ID, 'force')
      out=0; return
   end
   ch=get(hFig, 'children');
   
   Menus=save_obj.Menu;
   h=-1*ones(length(Menus.Tags),1);
   for ii=1:length(Menus.Tags)
      hand=findobj(ch, 'flat', 'tag', Menus.Tags{ii});
      if length(hand)==1, h(ii)=hand; else h(ii)=inf; end
   end
   StillAround=ishandle(h);
   set(h(StillAround), ...
      {'Enable'}, Menus.Enable(StillAround))
   

   Uis=save_obj.Ui;
   h=-1*ones(length(Uis.Tags),1);
   for ii=1:length(Uis.Tags)
      hand=findobj(ch, 'flat', 'tag', Uis.Tags{ii});
      if length(hand)==1, h(ii)=hand; 
      else h(ii)=inf;
      end
   end
   StillAround=ishandle(h);
   set(h(StillAround), ...
     {'CallBack'}, Uis.CallBack(StillAround), ...
     {'HitTest'}, Uis.HitTest(StillAround), ...
     {'Enable'}, Uis.Enable(StillAround))
      
   Axs=save_obj.Axes;
   h=-1*ones(length(Axs.Tags),1);
   h_axes=findobj(ch, 'flat', 'type', 'axes');
   for ii=1:length(Axs.Tags)
      hand=findobj(h_axes, 'flat', 'tag', Axs.Tags{ii});
      if length(hand)==1, h(ii)=hand; else h(ii)=inf; end
   end
   StillAround=ishandle(h);
   set(h(StillAround), 'hittest', 'on')
   
   Pas=save_obj.Patch;
   h=-1*ones(length(Pas.Tags),1);
   h_patch=[];
   for ii=1:length(h_axes);
      h_patch=[h_patch; findobj(allchild(h_axes(ii)), 'flat', 'type', 'patch')];
   end
   for ii=1:length(Pas.Tags)
      hand=findobj(h_patch, 'flat', 'tag', Pas.Tags{ii});
      if length(hand)==1, h(ii)=hand; else h(ii)=inf; end
   end
   StillAround=ishandle(h);
   set(h(StillAround), 'hittest', 'on')
      
   Surf=save_obj.Surface;
   h=-1*ones(length(Surf.Tags),1);
   h_surf=[];
   for ii=1:length(h_axes);
      h_surf=[h_surf; findobj(allchild(h_axes(ii)), 'flat', 'type', 'surface')];
   end
   for ii=1:length(Surf.Tags)
      hand=findobj(h_surf, 'flat', 'tag', Surf.Tags{ii});
      if length(hand)==1, h(ii)=hand; else h(ii)=inf; end
   end
   StillAround=ishandle(h);
   set(h(StillAround), 'hittest', 'on')
   
   Win=save_obj.Win;
   set(hFig,...
      'WindowButtonMotionFcn', Win.WindowButtonMotionFcn,...
      'WindowButtonDownFcn', Win.WindowButtonDownFcn,...
      'WindowButtonUpFcn',Win.WindowButtonUpFcn,...
      'KeyPressFcn',Win.KeyPressFcn,...
      'pointer', Win.Pointer)
   guidtawr(tFig, 'DATA_FRIDGE', 'direct', '')

   %Bypass paralyzing of popups in Matlab 7.0.4
   fixpopups(hFig)

case 'watchdog'
   % check if GUI is in frozen state
   % if no program running in the background performs unfreeze
   LastCheckTime=guidtard('fdtool_main', 'watchdog');
   if isempty(LastCheckTime)
      CheckRequired=1;
   elseif eval('etime(clock, LastCheckTime) > 3', 'inf')  % check in every 3 secs
      CheckRequired=1;
   else
      CheckRequired=0;
   end
   % CheckRequired
   if CheckRequired
      calldepth=length(dbstack);
      if calldepth<3  
         % callback only, no running program in the background
         % process 1: guifreez
         % process 2: fdtool (wrapper)
         guifreez('all_fdtool', 'unfreeze', 'force');
         fdtool('status', 'Automatic unfreeze process performed.')
      end
      guidtawr('fdtool_main', 'watchdog', 'direct', clock);
   end
end