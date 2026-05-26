function dismispb(p1, p2, p3, p4, p5, seltype)
% DISMISPB Helper function of FDTool
% Close button on figure

%       dismispb(windowtag) makes Close button.
%       dismispb('remove','windowtag') removes it.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon 1997-1999
%       Last modified: 15-Mar-1999, GYS

if nargin<1
   error('tag is not given')
elseif nargin==1  % init
   wintag=p1;
   h=findobj(allchild(0), 'flat', 'tag', wintag);
   if isempty(h)
      error(['Bad window tag: ' wintag])
   elseif length(h)>1
      warning(['More than one windows have been found with tag ''', wintag]')
      delete(h(2:length(h)))
   end
   
   fdwindef(h(1)); % set default window props, necessary for the pb
   
   % init callback
   callb=   ['fdtool(''callback'',''dismispb'',''ui_push_dismiss_pb_on_' wintag ''', ''' wintag '_dismiss_pb'');'];
   % warning: close with the windows's close fcn (e.g. x or Alt-F4) is not recorded
   % This is because the figure's closefcn is called from guiclose to perform automatic
   % test plot.
   closefcn=['fdtool(''callback'',''dismispb'',''cl_push_dismiss_pb_on_' wintag ''', ''' wintag '_dismiss_pb'');'];
   
   % init resizefcn
   set(h(1),...
      'resizefcn', ['fdtool(''callback'',''dismispb'',''resize'', ''' wintag ''',''' wintag '_dismiss_pb'')'] , ...
      'closerequestfcn', closefcn, ...
      'units', 'pixels');
   
   winpos=get(h(1), 'position');
   
   % the figure may be old, another dismispb may be present: delete it
   h_pb=findobj(allchild(h(1)), 'flat', 'tag', [wintag '_dismiss_pb']);
   %
   %Delete also original multisine pb
   h_pb=[h_pb;findobj(allchild(h(1)), 'flat', 'tag', 'fdident_dismiss')];
   %
   if ~isempty(h_pb)
      delete(h_pb)
   end
   
   % make pb
   h_pb=uicontrol('parent', h(1), ...
      'units', 'pixel',...   
      'position', [winpos(3)-60, 1, 60 20],...
      'string', 'Close',...
      'Tooltipstring','Close this window',...
      'callback', callb,...
      'userdata', now, ...
      'tag', [wintag '_dismiss_pb']);
   
elseif any(findstr(p1, 'ui_push_dismiss_pb'))|any(findstr(p1, 'cl_push_dismiss_pb'))
   % callback syntax: dismispb('ui_push_dismiss_pb_on_WINTAG', wintag)
   wintag=p1(23:end);
   hwin=findobj(allchild(0), 'flat', 'tag', wintag);
   fdtstplt('in', wintag) % test plot if necessary
   if ~isempty(hwin)
      delete(hwin)
   end
   
   
elseif findstr(p1, 'resize')
   winh=findobj(allchild(0), 'flat', 'tag', p2);
   if length(winh)>1, winh=gco; end
   set(winh, 'units', 'pixels');
   winpos=get(winh, 'position');
   hpb=findobj(allchild(winh), 'flat', 'tag', p3);
   set(hpb, 'position', [winpos(3)-60, 1, 60 20])
   
elseif strcmp(p1, 'remove')   
   if strcmp(p2, 'last')
      % removes dismispb created last time
      h=findall(0, 'tag', 'fdtool_dismiss_pb');
      if isempty(h)
         return
      elseif length(h)>1
         times=get(h, 'userdata');
         times=cat(length(h), times{:});
         ix=find(times==max(times));
         delete(h(ix));
      else
         delete(h)
      end
   else
      winh=findobj(allchild(0), 'flat', 'tag', p2);
      hpb=findobj(allchild(winh), 'flat', 'tag', 'fdtool_dismiss_pb');
      delete(hpb)
   end  
end
%
%End of file
