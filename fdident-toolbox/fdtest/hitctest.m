%HITCTEST Test iterctrl

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, hold off
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
%
MatlV=version; NaNv=NaN;
lasterrsave=lasterr;
stat=dbstatus; stopiferror=0;
for ii=1:length(stat);
  if strcmp(stat(ii).cond,'error'), stopiferror=1; end
end %for ii
dbclear if error
try, tpnone=strcmp(get(0,'TerminalProtocol'),'none');
catch, tpnone=0;
end
if stopiferror, dbstop if error, end
lasterr(lasterrsave), clear lasterrsave
if strcmp(MatlV(1:3),'4.0')|tpnone
  %iterctrl does not work for versions below Matlab 4.1, it will not be tested
  %It does not work either if no graphics terminal is used.
  testiterctrl=0;
else %regular case, e.g. Matlab5 or Matlab4.2
  testiterctrl=1;
end
%
if testiterctrl %test of iterctrl
  freqv=[1:10]'; x=ones(size(freqv)); %y=x+0.01*randn(size(x));
  y=1./(1+j*freqv)+0.01*randn(size(x));
  %
  iterctrl('initialize')
  iterctrl('Finish'), pause(0)
  [pvect,fit]=elis([freqv,x,y],[1,0],['s',5,5],[1,0;3,0],[NaN,'a'+0],...
        [50,NaNv(:,ones(1,9)),3.14+[-0.02,0.02]]);
  graphnumber=grapause('hitctest',graphnumber,testsavegraphst,0.82,0.04);
  if fit(17)~=4, error('Iteration 1 did not stop because of GUI'), end
  if fit(6)~=0
    error(sprintf('Performed iterations: %.0f, instead of 0',fit(6)))
  end
  %
  iterctrl
  iterctrl('Finish'), drawnow
  [pvect,fit]=elis([freqv,x,y],[1,0],['s',1,1],[1,0;3,0],[NaN,'l'+0],...
        [50,NaNv(:,ones(1,9)),3.14+[-0.02,0.02]]);
  iterctrl('delete'), clear testiterctrl
  graphnumber=grapause('hitctest',graphnumber,testsavegraphst,0.82,0.04);
  if fit(17)~=4, error('Iteration2 did not stop because of GUI'), end
  clear x y freqv fit pvect
end %if testiterctrl
%
clear MatlV NaNv graphnumber stat ii stopiferror
%
%End of hitctest
