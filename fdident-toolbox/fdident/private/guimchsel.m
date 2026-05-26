function out=guimchsel(p1,p2,p3,p4,p5,seltype);
%GUIMCHSEL Input/output multiple selection 
%Helper function of FDTOOL

% calling conventions
% init: guimchsel('init', caller_fcn , caller_ID, initvar)

% popup window is modified after finishing the function

% initvar structure fields:
%   .tagpopup;   
%   .windowname;

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Written by Z.T. Bilau
%       Last modified: 13-Nov-2004

if (nargin==1)&isstr(p1)&strcmp(p1,'preload')
  return %loading only for one argument 'preload'
end

mainfig=findall(0,'tag','fdtool_main');
Me='fdtool_guimchsel';
myfig=findall(0, 'tag',Me);
myfcn='guimchsel';
if ~any(findstr(p1, 'init'))
   if isempty(myfig)
       if strcmpi(p1, 'GetSettings')
           out=[]; return
       else
           error('Input/output channel selection window does not exist.')
       end
   end
   if nargin == 6
      sender=p5;
      replay_mode='replay';
   else                                                
      seltype=get(myfig,'selectiontype');
      eval(['sender=p', num2str(nargin) ';']);
      replay_mode='normal';
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if findstr(p1, 'init')
   if ~isempty(myfig), delete(myfig), end
   scrs=get(0,'screensize');
   sy=scrs(4);
   Tag='fdtool_guimchsel'; 
   Me=Tag;

   c.tagpopup=p4.tagpopup; 
   strpopup=get(findall(0,'Tag',c.tagpopup),'String');
   if isempty(findstr(strpopup{get(findall(0,'Tag',c.tagpopup),'Value')},'More than one...'))
      if ~isempty(findstr(strpopup{end},'More than one...'))
         strpopup{end}=['More than one...          (',sprintf('%d',get(findall(0,'Tag',c.tagpopup),'Value')),')'];   
         set(findall(0,'Tag',c.tagpopup),'String',strpopup);
      end
      set(findall(0,'Tag',c.tagpopup),'Userdata',get(findall(0,'Tag',c.tagpopup),'Value'));
      return;
   end
      
   c.tagcallfigure=get(get(findall(0,'Tag',c.tagpopup),'parent'),'Tag');
   c.caller_name=p2;
   c.caller_ID=p3;
   if exist('p5','var')
       c.filter=p5;
   end
   strcell=get(findall(0,'Tag',c.tagpopup),'String');
   %selection=sscanf(strcell{end}(28:end-1),'%d,');
   if strcmp(p4.tagpopup,'import_ch_pop1'), tag='h_pop1_names';
   elseif strcmp(p4.tagpopup,'import_ch_pop2'), tag='h_pop2_names';
   end
   hpop=findobj(findall(0,'type','figure','tag','fdtool_importfig'),'tag','import_ch_pop1');
   selection=getappdata(hpop,tag);

   posfig=get(findall(0,'Tag',c.tagcallfigure),'Position');
   pospop=get(findall(0,'Tag',c.tagpopup),'Position');
   posnew=[posfig(1)+pospop(1)+pospop(3),posfig(2)+pospop(2)-140,180,140];

   myfig=figure(...
      'HandleVisibility','on', ...
      'windowstyle', 'modal', ...
      'IntegerHandle','off', ...
      'Handlevisibility', 'off',...
      'Name',p4.windowname, ...
      'NumberTitle','off', ...
      'units', 'pixels',...
      'visible', 'on',...
      'resize', 'off', ...
      'Position',posnew, ...
      'Tag',Tag);
   
   hLIST=uicontrol('Parent',myfig, ...
      'Position',[10 10 90 120], ...
      'CallBack',['fdtool(''callback'',''guimchsel'',''ui_list'',''list'');'],...
      'Style','listbox', ...
      'string', strcell(1:end-1),...
      'Userdata', 'MultiChannelObject', ...
      'Visible', 'on', ...
      'Tooltipstring', 'Select channels',...  
      'value',selection,...
      'Max',2,...
      'Tag','list');
   
   hOK = uicontrol('Parent',myfig, ...
      'Callback',['fdtool(''callback'',''guimchsel'',''ui_OK'',''OK_pb'');'], ...
      'Position',[110 10 60 20], ...
      'String','OK', ...
      'tooltipstring','OK',...
      'Visible', 'on',...
      'Tag','OK_pb');
   
   
   hCancel = uicontrol('Parent',myfig, ...
      'Callback',['fdtool(''callback'',''guimchsel'',''ui_cancel'',''Cancel_pb'');'],...
      'Position',[110 38 60 20], ...
      'String','Cancel', ...
      'tooltipstring','Close window without changing the selection',...
      'Tag','Cancel_pb');
   
   hHelp = uicontrol('Parent',myfig, ...
     'callback',        [ 'fdtool(''callback'',''helpmgr'',''ui_help_object'', ' ...
            '''' myfcn ''',', '''help_pb'' )'],...
      'Position',[110 66 60 20], ...
      'String','Help', ...
      'tooltipstring','Help on object',...
      'Tag','help_pb');
   
   helpmgr('init_help', '', myfcn, myfig );
   
   guidtawr(Me, 'CALLER_INFO', 'direct', c)

%    %end of init
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   %   GUIIMPV commands
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
elseif findstr(p1,'ui_list')
   hlist=findall(myfig,'Tag',p2);
   if isempty(get(hlist,'Value')) || length(get(hlist,'Value'))==length(get(hlist,'String'))
       set(findall(myfig,'Tag','OK_pb'),'Enable','off');
   else
       set(findall(myfig,'Tag','OK_pb'),'Enable','on');
   end

elseif findstr(p1,'ui_OK')
   hLIST=findall(myfig,'Tag','list');
   selection=get(hLIST,'Value');
   allnames=get(hLIST,'string');
   selnames=allnames(selection);
   if strcmp(get(myfig,'name'),'Select output channels')
     hpop=findobj(findall(0,'type','figure','tag','fdtool_importfig'),'tag','import_ch_pop1');
     setappdata(hpop,'h_pop1_names',selection(:))
   elseif strcmp(get(myfig,'name'),'Select input channels')
     hpop=findobj(findall(0,'type','figure','tag','fdtool_importfig'),'tag','import_ch_pop2');
     setappdata(hpop,'h_pop2_names',selection(:))
   else error('Cannot determine if input or output')
   end
   c=guidtard(Me, 'CALLER_INFO');
   strlist=get(findall(0,'Tag',c.tagpopup),'String');
   if length(selection)==1
      set(findall(0,'Tag',c.tagpopup),'Value',selection);
   end
   %strlist{end}=['More than one...          (',sprintf('%d,',selection),')'];
   strlist{end}(end-1)=[];
   set(findall(0,'Tag',c.tagpopup),'String',strlist);

   close(myfig);
   
elseif findstr(p1,'ui_cancel')
   c=guidtard(Me, 'CALLER_INFO');
   
   strcell=get(findall(0,'Tag',c.tagpopup),'String');
   selection=sscanf(strcell{end}(28:end-1),'%d,');

   if length(selection)==1
      set(findall(0,'Tag',c.tagpopup),'Value',selection);
   end
   close(myfig);
   
   
else
   error(['unknown command:' p1])
end


