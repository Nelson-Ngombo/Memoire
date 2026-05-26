%TFDEMO Demonstration of ploteltf

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
if ~exist('cc'), cc=''; end, if isempty(cc), cc=1; end
%c=yesinput('confidence bound coefficient',c); %cc=1000 for errorbar
ploteltf('inpchmod(inpchans)','','inpchan',['lin',0,2.1e4],'full',...
        NaN,cc)
%ploteltf('inpchmod(inpchanz)','','inpchan',['lin',0,2e4],'full',NaN,cc)
graphnumber=grapause('tfdemo',graphnumber,demosavegraphst);
%%%%%%%%%%%%%%%%%%%%%%%% end of tfdemo %%%%%%%%%%%%%%%%%%%%%%%%
