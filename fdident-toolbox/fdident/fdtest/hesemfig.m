%HESEMFIG Illustrative plots for seminar

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

echo off
disp('File hesemfig')
graphnumber=0;
%
ic=0;
if ~exist('testsavegraphst'), testsavegraphst=''; end
global yesinpacceptdef
if ~strcmp(yesinpacceptdef,'yes')
  testsavegraphst=['disp(''Type in your commands, then type: return''), ',...
         'keyboard'];
end
fn='hesemfig.ps';
%Generate one postscript file:
%testsavegraphst=['print -append -dps ',fn,',']; if exist(fn), delete(fn), end
istr=',sprintf(''%02.0f'',ic),';
%Generate separate eps or gif files:
%testsavegraphst=['ic=ic+1;eval([''print -deps fdsemf''',istr,'''.eps''])'];
%testsavegraphst=['ic=ic+1;eval([''print -dgif8 fdsemf''',istr,'''.gif''])'];
%
invhcopy=get(gcf,'InvertHardCopy');
disp(' ')
disp('Plots look better on printouts with black background.')
disp('For this effect, InvertHardCopy is to be set to ''off''.')
invhcopy2=yesinput('InvertHardCopy, on or off',invhcopy,'on|off');
if ~strcmp(invhcopy,invhcopy2), set(gcf,'InvertHardCopy',invhcopy2); end
clear invhcopy invhcopy2
%hyiad
%

graphnumbersave=graphnumber;
testsavegraphstsave=testsavegraphst; testsavegraphst='';
hblzohfg
testsavegraphst=testsavegraphstsave;
graphnumber=graphnumbersave;
%
graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);

%Illustration of main toolbox functions
if ~strcmp(yesinpacceptdef,'yes'), cyc=300; else cyc=5; end
msinclip(0.2:0.01:0.4,ones(1,21)/sqrt(2*21),[],'',cyc);
graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);

if ~strcmp(yesinpacceptdef,'yes')
  testsavegraphstold=testsavegraphst; testsavegraphst='';
  dibsno=3; dibsi='n'; dibsdemo
  testsavegraphst=testsavegraphstold;
  graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);
end

[pvect,fit,Cp]=elis('inpchan',[],['s',12,12]);
graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);

if ~strcmp(yesinpacceptdef,'yes')
  testsavegraphstold=testsavegraphst; testsavegraphst='';
  domain='s'; tfdemo
  testsavegraphst=testsavegraphstold;
  graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);
end

if ~strcmp(yesinpacceptdef,'yes')
  testsavegraphstold=testsavegraphst; testsavegraphst='';
  domain='s'; algt='anal'; Pc=[]; pzdemo
  %plotelpz(pvect,Cp,3,[-6,2,-4,4]*1e5)
  testsavegraphst=testsavegraphstold;
  graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);
end

%Electrical machine
if ~strcmp(yesinpacceptdef,'yes')
  testsavegraphstold=testsavegraphst; testsavegraphst='';
  emachdem
  testsavegraphst=testsavegraphstold;
  graphnumber=grapause('hesemfig',graphnumber,testsavegraphst);
end
%
clear graphnumber testsavegraphstold
%
%End of hesemfig
