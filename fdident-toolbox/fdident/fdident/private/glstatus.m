function glstatus(hWin, hStatusBar, hStatusFrame, msg)
%function glstatus(hWin, hStatusBar, hStatusFrame, msg)
% FDTOOL global status fcn
% If the beginning of the message is Error or Warning then the
% statusbar is colored appropriately.
% The following commands can be send at the beginning of the string:
%   &c reset time info of the statusbar, previous settings (e.g. hold) are forgot
%      (warning: this mode overwrites error messages without any pause !)
%   #c hold message, do not clear automatically
%   $c auto clear enabled,
%      where c is a color descriptor character
%      c can be 'd' meaning 'default'
%      '$d' is considered if no command is sent
% e.g. '$r' means red message with autoclear enabled
%      '#g' means green message with hold


%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 22-Nov-2003, IK

msgorig=msg; msg=msg'; msg=msg(:)';
ErrorIx=findstr(lower(msg), 'error');
WarningIx=findstr(lower(msg), 'warning');
isHold=strncmp(msg, '#',1);
isClear=strncmp(msg, '$',1);
isReset=strncmp(msg, '&', 1);

if ~isempty(ErrorIx) & ErrorIx<3
   status_color=[1 0 0];
   hold=1;
   % notify recorder: Error captured
   guirecrd('error_msg_captured', 'Error'); %lecserélni
   %catch, guirecrd('callback', 'recorder_error_msg_captured', 'gui_recorder_fdtool', 'Error');
   %end
 elseif ~isempty(WarningIx) & WarningIx<3
   status_color='y';
   hold=1;
   % notify recorder: Warning captured
   guirecrd('error_msg_captured', 'Warning'); %lecserélni
   %catch, guirecrd('callback', 'recorder_error_msg_captured', 'gui_recorder_fdtool', 'Warning');		
   %end
elseif isHold
   hold=1;
   status_color=msg(2);
   msgorig(1,:)=[msgorig(1,3:end),'  '];
elseif isClear
   hold=0;
   status_color=msg(2);
   msgorig(1,:)=[msgorig(1,3:end),'  '];
elseif isReset
   hold=0;
   status_color=msg(2);
   msgorig(1,:)=[msgorig(1,3:end),'  '];
else
   status_color='d';
   hold=0;
end
if strcmp(status_color, 'd'), status_color='default'; end


% if previous message is hold, wait before overwriting it, or forget new msg
lastupdate=get(hWin,'userdata'); 
if ~isReset & isstr(lastupdate) & findstr(lastupdate, 'hold') % last message's status is hold
   lastupdate=str2num(lastupdate(5:end));
   dt=etime(clock, lastupdate);
   if dt<3  
      if hold
         MAXWAIT=3; % max time to wait (in sec)
         pause(MAXWAIT-dt)
      else
         return % forget message if not 'hold'
      end
   end
end


if ishandle(hStatusBar) & ishandle(hStatusFrame)
   set(hStatusBar,'string',msgorig)
   set([hStatusBar hStatusFrame], 'backgroundcolor', status_color);
   if hold % do not delete this message automatically
      set(hWin,'userdata', ['hold' num2str(clock)])
   else % message may be deleted automatically
      set(hWin,'userdata', clock)
   end
end

