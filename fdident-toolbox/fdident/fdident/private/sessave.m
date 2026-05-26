function out=sessave(fullname, p2);
% session save to file
% helper file of FDTool

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 17-Aug-2003

%LatestVersion='4.0002';  % 4.0001 before 23-Aug-2001
LatestVersion='5.0';  % 5.0 from 13-Aug-2003
DefaultName='fddefses.mat';
if nargin==2
   if findstr(p2, 'version')
      out=LatestVersion;
      return
   elseif findstr(p2, 'filename')
      out=DefaultName;
      return
   else
      error(['Bad question:' p2])
      return
   end
end

% save objects
   fdtool('status', 'Wait...'); % to prevent annoying status during load
   session_data=savewindow('fdtool_main');
   session_data.version=LatestVersion;
   session_data.UserLevel=guiinfos('userlevel');
   session_data.SignalType=guiinfos('signaltype');
   session_data.ModelType=guiinfos('modeltype');
   fdtool('status', ['Saving session to file ' fullname ' ...']);
   save(fullname, 'session_data');
   
   fdtool('status',['Session saved to file ' fullname '.'])


function out=savewindow(tWin)
session_data=storewin('store_all', tWin);
ch=guiinfos('children', tWin);
active_ch_count=0;
children_data={};
for ii=1:length(ch)
   h=findobj(allchild(0), 'flat', 'tag', ch{ii}, 'visible', 'on');
   masterfcn=guiinfos('masterfcn', tWin);
   if any(findstr(masterfcn, '*'))
      masterfcn=''; % * shows that window is not to be stored
   end
   if ~isempty(h) & ~isempty(masterfcn)
      active_ch_count=active_ch_count+1;
      children_data{active_ch_count}=savewindow(ch{ii});
   end
end
session_data.children=children_data;
out=session_data;
