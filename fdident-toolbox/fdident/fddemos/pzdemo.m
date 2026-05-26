%PZDEMO Demonstration of plotelpz

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
graphnumber=0;
if ~exist('graphnumber_demo'), graphnumber_demo=[]; end
if isempty(graphnumber_demo), graphnumber_demo=0; end
if graphnumber_demo>0, graphnumber=graphnumber_demo; end
clf, hold off, echo off, clc
if exist('domain')~=1, domain='z'; end
if ~exist('axishandle'), axishandle=[]; end
if ~ishandle(axishandle), axishandle=[]; end
domainold=domain;
domain=yesinput('domain',domain,'s|z');
if ~exist('Pc'), Pc=[]; end
if (domainold~=domain)|isempty(Pc)
  if domain=='z', Pc=30; else Pc=10; end
end
if ~exist('dp'), dp=[]; end
if (domainold~=domain)|isempty(dp)
  if domain=='z', dp=1; else dp=0.1; end
end
if ~exist('algt'), algt='anal'; end
algt=yesinput('Derivation method (num or anal)',algt,'num|anal');
Pc=yesinput('Pc',Pc);
if strcmp(algt,'num')
  dp=yesinput('dp',dp);
  if ~exist('shm'), shm=''; end
  if isempty(shm), shm='n'; end
  shm=yesinput('Show ''movie'', y/n',shm,'y|n');
  if strcmp(shm,'y'), plm='mc'; else plm=''; end
else
  plm='';
end
disp(' ')
if domain=='z'
  plotelpz('inpchmod(inpchanz)',NaN,Pc,'z','',[],[],[],algt,dp,plm,[],axishandle)
else
  plotelpz('inpchmod(inpchans)',NaN,Pc,[-6,2,-4,4]*1e5,...
        '',[],[],[],algt,dp,plm,[],axishandle)
end
graphnumber=grapause('pzdemo',graphnumber,demosavegraphst);
%
if 1==2
  print(['pzdemo',domain,'.ps']), delete(['pzdemo',domain,'.ps'])
end %1==2
%%%%%%%%%%%%%%%%%%%%%%%% end of pzdemo %%%%%%%%%%%%%%%%%%%%%%%%