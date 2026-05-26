%HFDFLYER - figures for the toolbox flyer (script file)
%       To be set: fdflyern, serial number of figure; use 2.5 for 2b
%       Currently implemented: fdflyern=1,2,2.5,3,4
%       If fdflyern is not defined or fdflyern=0: all figures are plotted

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
disp('HFDFLYER - figures for the flyer of the FDIDENT Toolbox')
disp('File hfdflyer')
if ~exist('fdflyern'), fdflyern=0; end
if isempty(fdflyern), fdflyern=0; end
%
clf
invhcopy=get(gcf,'InvertHardCopy');
disp(' ')
disp('Plots look better on printouts with black background.')
disp('For this effect, InvertHardCopy is to be set to ''off''.')
invhcopy2=yesinput('InvertHardCopy, on or off',invhcopy,'on|off');
if ~strcmp(invhcopy,invhcopy2), set(gcf,'InvertHardCopy',invhcopy2); end
clear invhcopy invhcopy2
%
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
graphnumber=0;
%
if (fdflyern==1)|(fdflyern==0)
  disp(' ')
  disp('Fig. 1  Plot of a parameter estimation result, obtained by elis')
  elis('inpchan',[],['s',12,12]);
  if fdflyern==0
    graphnumber=grapause('hfdflyer',graphnumber,testsavegraphst);
  end
  %print -dgif8 newslett.gif
end
%
global halffiginmsinclip %secret halving feature in msinclip
if (fdflyern==2)|(fdflyern==0)
  halffiginmsinclip='y';
  disp(' ')
  disp('Fig. 2a  Multisine design, optimized for a minimum crest factor')
  msinclip(0.2:0.01:0.4,ones(1,21)/sqrt(2*21),[],'',300);
  if fdflyern==0
    graphnumber=grapause('hfdflyer',graphnumber,testsavegraphst);
  end
end
%
if (fdflyern==2.5)|(fdflyern==0)
  halffiginmsinclip='y';
  disp(' ')
  disp(['Fig. 2b  Zero-order hold multisine design,',...
        ' optimized for a minimum crest factor'])
  msinclip(0.2:0.01:0.4,ones(1,21)/sqrt(2*21),[],'graph10ZOH',300,1.24);
  if fdflyern==0
    graphnumber=grapause('hfdflyer',graphnumber,testsavegraphst);
  end
end
clear global halffiginmsinclip
%
if (fdflyern==3)|(fdflyern==0)
  disp(' ')
  disp('Fig. 3  Design of a discrete interval binary sequence')
  demosavegraphstsave=demosavegraphst; demosavegraphst='';
  dibsno=3; dibsi='n';
  graphnumbersave=graphnumber;
  dibsdemo
  graphnumber=graphnumbersave;
  clear dibsno dibsi
  demosavegraphst=demosavegraphstsave;
  if fdflyern==0
    graphnumber=grapause('hfdflyer',graphnumber,testsavegraphst);
  end
end
%
if (fdflyern==4)|(fdflyern==0)
  disp(' ')
  disp('Fig. 4  Pole/zero plot with uncertainty ellipses (z-domain)')
  demosavegraphstsave=demosavegraphst; demosavegraphst='';
  domain='z'; algt='anal'; Pc=[];
  graphnumbersave=graphnumber;
  pzdemo
  graphnumber=graphnumbersave;
  demosavegraphst=demosavegraphstsave;
  if fdflyern==0
    graphnumber=grapause('hfdflyer',graphnumber,testsavegraphst);
  end
end
%
clear graphnumber graphnumbersave fdflyern domain algt Pc dibsno dibsi invhcopy
%
%End of hfdflyer.m
