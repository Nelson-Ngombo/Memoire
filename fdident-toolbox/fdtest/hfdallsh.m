function hfdallsh
%HFDALLSH  Run all fdident shows to check if they are error-free

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
shem=which('emachsh.m');
if isempty(shem), display('No demo found'), return
elseif ~isstr(shem), error('More than one bandpsh.m files found')
else shp=shem(1:end-9);
end
shstr=dir([shp,'*sh*.m']);
shows={};
for ii=1:length(shstr)
  if ~strcmp(shstr(ii).name(1:end-2),'fdgetcsh') %this is NOT a show file
    shows=[shows;{shstr(ii).name(1:end-2)}];
  end
end
%fdcoursh, bandpsh, emachsh

for ii=1:length(shows)
   fprintf(['\nTesting show ''',shows{ii},'''...\n'])
   hexecshow(shows{ii},'cont')
end

hf=[findall(0,'tag','playhist');findall(0,'name','Your plots');findall(0,'name','ELiS Run')];
for ii=1:length(hf)
   if ishandle(hf(ii)), delete(hf(ii)), end
end

disp(' ')
disp('End of fdshall, all shows finished properly')

%
%End of file
