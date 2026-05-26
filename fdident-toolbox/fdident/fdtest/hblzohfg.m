%function hblzohfg
%HBLZOHFG plot band-limited and zoh interpolation illustration

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
%
BLmark='-'; ZOHmark='-';
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
  BLmark='.'; ZOHmark='-';
else blue='b'; red='r'; green='g';
end
if (mean(get(gcf,'Color'))>=0.5), yellow=blue; %white bg
elseif (get(0,'ScreenDepth')>=8), yellow='y';
else yellow=green;
end
n=15; N=32;
rand('seed',0)
cx=exp(j*2*pi*rand(n,1))/2*sqrt(N);
y=msinprep([1:n]',cx,N,N,'screen');
t=[0:N-1]; t2=[t;t+1]; t2=t2(:);
y2=[y';y']; y2=y2(:);
%plot ZOH interpolation signal
h1=plot(t2,y2,[ZOHmark,green]); grid off
set(h1,'LineWidth',1)
%
dens=16;
yd=msinprep([1:n]',cx*dens,N*dens,N*dens,'screen');
td=([0:N*dens-1])/dens;
hold on
%plot BL interpolation signal
h2=plot(td,yd,[BLmark,red]);
set(h2,'LineWidth',1)
set(h2,'markersize',6.5)
hold off
%
hold on
h3=plot(t,y,['o',white]);
hold off
%
ax=axis; ax(2)=N; axis(ax)
graphnumber=grapause('hblzohfg',graphnumber,testsavegraphst);
%
clear graphnumber
%
%End of hblzohfg.m
