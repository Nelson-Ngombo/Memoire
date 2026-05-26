function Out=storewin(mode, tWin, in);
%STOREWIN stores tWin window's states to variable Out (mode='store' or 'store_all')
% 'store' collects the figure position and uicontrol settings
% 'store_all' collects the userprops as well
% 'restore' restores tWin's properties from variable 'in'
% 'restore_settings' restores only rb, popupmenu, editbox, checkbox, listbox objects
% 'remember' stores xxxxx_main or xxxxxfig windows props to STATUS_xxxxx values 
% 'recover' restores windows from STATUS_xxxxx values 
%           if window is in 'done' status, everything is restored and 0 is returned
%           if window is not in 'done' status, only setting are restored and 1 is returned
% 'recover_settings' forces the latter case
% 'recover_more' returns 1 but recovers everything if possible

% !!! NOTE !!! xxx_settings does not update texts; consistency must be maintained
%              by the caller if necessary
%              storewin does not update plots; consistency must be maintained
%              by the caller if necessary

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon 
%       Last modified: 21-Jan-2000, GYS

hWin=findall(0, 'tag', tWin);
if isempty(hWin)
   error('The specified window is missing.')
end
if any(findstr(mode, 'remember'))|any(findstr(mode, 'recover'))
   MotherWin=guiinfos('mother', tWin);
end
if any(findstr(tWin, '_main'))
   ix=findstr(tWin, '_main');
else
   ix=findstr(tWin, 'fig');
end   
nameWin=tWin(1:ix-1);

if strncmp(mode, 'store',5)
   c=get(hWin,'children');
   
   % save pathes
   %h=findobj(c, 'type', 'patch');
   %Out.patch.tag=get(h,'tag');
   
   % save user properties
   h_up=findobj(c, 'type', 'uicontrol', 'style', 'text', 'visible', 'off');
   
   % earlier version use different user properties !!!
   old_uprops = ~exist('setappdata', 'builtin');
   
   if old_uprops   % this for version before 5.3.0.24664 (R11) Beta 3
      tags=get(h_up,'tag');
      data=get(h_up, 'userdata');
      if ~iscell(tags); tags={tags}; end; if length(tags)<2; data={data}; end
   else   % this for version 5.3.0.24664 (R11) Beta 3 and later
      uprop_struct=getappdata(hWin);
      tags=fieldnames(uprop_struct);
      data=struct2cell(uprop_struct);
   end
   
   
   % further checking based upon names: uprops' names begin with 2 capital letters
   ix=zeros(size(tags));
   len=length(tags);
   for ii=1:len
      if strncmp(tags{ii}, upper(tags{ii}),2)
         ix(ii)=1;
      end
   end
   ix=find(ix~=0);
   if any(findstr(mode, 'all')) % store_all
      Out.uprop.tag=tags(ix);
      Out.uprop.data=data(ix);
   else % store
      Out.uprop.tag=[];
      Out.uprop.data=[];
   end
   % save uicontrols (which are NOT uprops)
   h=setdiff(findobj(c, 'type', 'uicontrol'), h_up);
   
   % no text save is required except in gettime_main (infos)
   if ~strcmp(tWin, 'gettime_main')
      h_txt=findobj(h, 'flat', 'style', 'text');
      h=setdiff(h, h_txt);
   end
   Out.uic=get(h, {'tag', 'string', 'value', 'userdata', 'enable', 'visible', 'style'});
   
   % save position
   Out.position=get(hWin,'position');
   Out.figuretag=tWin;
   % menu setting may be necessary to save (later...)
   
   
elseif strncmp(mode, 'restore',7)
   c=get(hWin,'children');
   if ~isempty(in) & isstruct(in)       
      
      % if 'settings' is called uprops are NOT restored, except the tag is called STATUS_XXXX
      for i=1:length(in.uprop.tag)
         tag=in.uprop.tag{i};
         need_to_restore_this=~any(findstr(mode, 'settings'))|any(findstr(tag, 'STATUS_'));
         if need_to_restore_this
            % restore user properties
            data=in.uprop.data{i};
            guidtawr(tWin, tag, 'direct', data);
         end
      end
      % restore position
      if ~isempty(in.position)
         set(hWin, 'position', in.position) % ellenorzes kell !!!
      end
      % restore uicontrols
      l=size(in.uic,1);
      h_ui=zeros(l,1); isedit=zeros(l,1); ispopup=zeros(l,1);
      settingsstr={'radiobutton', 'checkbox', 'edit', 'listbox', 'popupmenu'};
      for ii=1:l
         tag=in.uic{ii,1};
         h=findobj(c, 'flat', 'type', 'uicontrol', 'tag', tag);
         if ~isempty(h) & ~isempty(tag);
            h_ui(ii)=h;
         end
         % if restore_settings, no text update needed
         if any(findstr(mode, 'settings')) & ~any(strcmp(settingsstr, in.uic(ii,7)))
            h_ui(ii)=0;
         end
         
         % do not restore text except in gettime_main
         if strcmp(in.uic(ii,7), 'text') & ~strcmp(tWin, 'gettime_main')
            h_ui(ii)=0;
         end
         
         if strcmp(in.uic(ii,7), 'edit')
            isedit(ii)=1;
         end
         
         if strcmp(in.uic(ii,7), 'popupmenu')
            ispopup(ii)=1;
         end
         
      end
      % all strings were recovered, new features in popups didn't show up in sessions
      %ix=find(h_ui~=0);
      %ixedit=find(isedit~=0);
      %if ~isempty(h_ui)
      %   set(h_ui(ix), ...
      %      {'tag', 'string', 'value', 'userdata', 'enable', 'visible'}, in.uic(ix,1:6));
      %end
      
      
      % strategy:
      % 1. restore only those popups which don't contain letters (e.g. caem's model orders)
      % 2. check selected elements in popups, do not use stored 'value' properties
      
      ix=find(ispopup==0 & h_ui~=0);
      ixpop=find(ispopup~=0 & h_ui~=0);
      if ~isempty(h_ui)
         set(h_ui(ix), ...
            {'tag', 'string', 'value', 'userdata', 'enable', 'visible'}, in.uic(ix,1:6));
      end
      for ii=1:length(ixpop)
         ixp=ixpop(ii);
         str=in.uic{ixp,2}; if ~iscell(str), str={str}; end
         val=in.uic{ixp,3};
         sel_str=str{val};
            
         if strcmp(lower(str), upper(str))  % no letters, update necessary
            set(h_ui(ixp), ...
               {'tag', 'string', 'value', 'userdata', 'enable', 'visible'}, in.uic(ixp,1:6));
         else % update not enabled, index checking necessary (new elements may be added to str)
            current_str=get(h_ui(ixp),'string');
            act_value=strmatch(sel_str, deblank(current_str));
            if isempty(act_value)
              if guiinfos('isdevelopment')
                if strcmp(get(h_ui(ixp),'tag'),'fdmeas_uic_hwpop')&strcmp(current_str,'Hardware?')
                elseif strcmp(get(h_ui(ixp),'tag'),'fdmeas_uic_vipop')&strcmp(current_str,'Instrument?')
                else
                  warning('Session data inconsistent - code #1 (may also be because of dynamic popups!)')
                end
              end
              act_value=val;
            end
            if length(act_value)>1
               if guiinfos('isdevelopment')
                  warning('Session data inconsistent - code #2')
               end
               act_value=val;
            end
            in.uic{ixp,3}=act_value;
            set(h_ui(ixp), ...
               {'tag', 'value', 'userdata', 'enable', 'visible'}, in.uic(ixp,[1, 3:6]));
         end
      end

      if isfield(in,'UserLevel'), fdtool('userlevel_set',in.UserLevel); end
      if isfield(in,'SignalType'), fdtool('signaltype_set',in.SignalType); end
      if isfield(in,'ModelType'), fdtool('modeltype_set',in.ModelType); end
      
      %set(h_ui(ix), ...
      %   {'tag', 'value', 'userdata', 'enable', 'visible'}, in.uic(ix,[1, 3:6]));
      %set(h_ui(ixedit), {'string'}, in.uic(ixedit,2)); % restore strings for edit only
      % Wrong !!!!! popup needs string recovery (e.g. model orders) Text also needed (info)
      
      % menu setting may be necessary to save (?)
      
      
      % update patch colors if main win or gettime win
      if strcmp(tWin, 'fdtool_main')|strcmp(tWin, 'gettime_main')
         boxmgr('updatecolors', tWin)
      end
   end
elseif strcmp(mode, 'remember')
   % stores tWin's properties to STATUS_xxxx
   guifreez(tWin, 'unfreeze', 'force');
   status=storewin('store_all', tWin);
   guidtawr(MotherWin, ['STATUS_' nameWin], 'direct', status)
   
elseif strncmp(mode, 'recover', 7)
   % restores tWin's properties from STATUS_xxxx
   status=guidtard(MotherWin, ['STATUS_' nameWin]);
   if ~isempty(status)
      % full recovery if box is 'done' and not in 'recover_settings' mode
      full_recover=~any(findstr(mode, 'settings')) &...
         any(findstr(boxmgr('enquirebox', MotherWin, nameWin), 'd')) ;
      if full_recover
         Out=0; % load of input arrow is not necessary
         storewin('restore', tWin, status);
      else
         Out=1; % load of input arrow is necessary
         if any(findstr(mode, 'more')) % settings and uprops as well
            storewin('restore', tWin, status);
         else % only settings
            storewin('restore_settings', tWin, status);
         end
      end
   else
      Out=1; % load of input arrow is necessary
   end
   
end
