%HMSCLTST Test msinclip and crestmin

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
echo on
%
fv=[16:4:60]'; fl=length(fv); ampv=1/sqrt(2*fl)*ones(fl,1);
echo off
disp('[ampv2,crestx]=msinclip(fv,ampv,[],'''',30);')
fprintf('Press a key to continue...'), pause, disp(' ')
%
[ampv2,crestx]=msinclip(fv,ampv,[],'',30);
graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
if exist('corrtest.m')
  [ampv2,crestx]=msinclip(fiddata([],ampv,fv),struct('itno',30));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [ampv2,crestx]=crestmin(fiddata([],ampv,fv),struct('itno',5,'pmax',32));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%
disp('[ampv2,crestx]=msinclip(fv,ampv,[],''ZOHd'',30);')
fprintf('Press a key to continue...'), pause, disp(' ')
[ampv2,crestx]=msinclip(fv,ampv,[],'ZOHd',30,1);
graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
if exist('corrtest.m')
  [ampv2,crestx]=msinclip(fiddata([],ampv,fv),struct('itno',30,'crestmode','discrete'));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [ampv2,crestx]=crestmin(fiddata([],ampv,fv),struct('itno',5,'crestmode','discrete','pmax',32));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%
disp('[ampv2,crestx]=msinclip(fv,ampv,[],''ZOHc'',30);')
fprintf('Press a key to continue...'), pause, disp(' ')
[ampv2,crestx]=msinclip(fv,ampv,[],'ZOHc',30,1);
graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
if exist('corrtest.m')
  [ampv2,crestx]=msinclip(fiddata([],ampv,fv),...
    struct('itno',30,'crestmode','ZOH','overs',1));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [ampv2,crestx]=crestmin(fiddata([],ampv,fv),....
    struct('itno',30,'crestmode','ZOH','pmax',32,'overs',1));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%
%dc
if exist('corrtest.m')
  fv2=[0;fv];
  [ampv2,crestx]=msinclip(fiddata([],[0.5;ampv],fv2),struct('itno',30));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [ampv2,crestx]=crestmin(fiddata([],[0.5;ampv],fv2),struct('itno',30,'pmax',32));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [ampv2,crestx]=msinclip(fiddata([],[NaN;ampv],fv2),struct('itno',30));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [ampv2,crestx]=crestmin(fiddata([],[NaN;ampv],fv2),struct('itno',30,'pmax',32));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%
echo on
%Input-output minimization
tf=100*ones(fl,1)./(sqrt(-1)*2*pi*fv);
echo off
disp('[cx,crestx]=msinclip(fv,ampv,tf,''graph'',4);')
fprintf('Press a key to continue...'), pause, disp(' ')
[cx,crestx]=msinclip(fv,ampv,tf,'graph',4);
graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
if exist('corrtest.m')
  [cx,crestx]=msinclip(fiddata(tf,ampv,fv),struct('itno',4));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [cx,crestx]=crestmin(fiddata(tf,ampv,fv),struct('itno',4,'pmax',32));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%ZOHd
disp('[cx,crestx]=msinclip(fv,ampv,tf,''graphZOHd'',4,3.3);')
fprintf('Press a key to continue...'), pause, disp(' ')
[cx,crestx]=msinclip(fv,ampv,tf,'graphZOHd',4,1,100);
graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
if exist('corrtest.m')
  [cx,crestx]=msinclip(fiddata(tf,ampv,fv),...
    struct('itno',4,'overs',1,'n',100,'graph','graph','crestmode','discrete'));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [cx,crestx]=crestmin(fiddata(tf,ampv,fv),...
    struct('itno',4,'pmax',32,'overs',1,'n',100,'graph','graph','crestmode','discrete'));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%ZOHc
disp('[cx,crestx]=msinclip(fv,ampv,tf,''graphZOHc'',4,3.3);')
fprintf('Press a key to continue...'), pause, disp(' ')
[cx,crestx]=msinclip(fv,ampv,tf,'graphZOHc',4,1,100);
graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
if exist('corrtest.m')
  [cx,crestx]=msinclip(fiddata(tf,ampv,fv),...
    struct('itno',4,'overs',1,'n',100,'graph','graph','crestmode','ZOH'));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
  [cx,crestx]=crestmin(fiddata(tf,ampv,fv),...
    struct('itno',4,'overs',1,'n',100,'pmax',32,'graph','graph','crestmode','ZOH'));
  graphnumber=grapause('hmscltst',graphnumber,testsavegraphst);
end
%
%snowing and slew rate...
msinclip(1:15,[ones(8,1);NaN*ones(7,1)],[],'graph',2,[],[],[],200);
if exist('corrtest.m')
  msinclip(fiddata([],[ones(8,1);NaN*ones(7,1)],1:15),...
    struct('itno',2,'graph','graph','slewr',200));
  crestmin(fiddata([],[ones(8,1);NaN*ones(7,1)],1:15),...
    struct('itno',2,'graph','graph','slewr',200));
end
%
%snowing
msinclip(1:15,[ones(6,1);NaN*ones(7,1);1;NaN],[],'graph',2);
if exist('corrtest.m')
  msinclip(fiddata([],[ones(6,1);NaN*ones(7,1);1;NaN],1:15),...
    struct('itno',2,'graph','graph'));
  crestmin(fiddata([],[ones(6,1);NaN*ones(7,1);1;NaN],1:15),...
    struct('itno',2,'graph','graph'));
end
tf=100*ones(15,1)./(sqrt(-1)*2*pi*[1:15]');
msinclip(1:15,[ones(6,1);NaN*ones(7,1);1;NaN],tf,'graph',2);
if exist('corrtest.m')
  msinclip(fiddata(tf,[ones(6,1);NaN*ones(7,1);1;NaN],1:15),...
    struct('itno',2,'graph','graph'));
  crestmin(fiddata(tf,[ones(6,1);NaN*ones(7,1);1;NaN],1:15),...
    struct('itno',2,'graph','graph'));
end
msinclip(1:15,[ones(7,1);NaN*ones(7,1);1],[],'nograph',2);
if exist('corrtest.m')
  msinclip(fiddata([],[ones(7,1);NaN*ones(7,1);1],1:15),...
    struct('itno',2,'graph','nograph'));
  crestmin(fiddata([],[ones(7,1);NaN*ones(7,1);1],1:15),...
    struct('itno',2,'graph','nograph'));
end
msinclip([1:22]/9,reshape([ones(1,11);1,1,1,NaN*ones(1,8)],22,1),...
  [],'graph10',8);
if exist('corrtest.m')
  msinclip(fiddata([],reshape([ones(1,11);1,1,1,NaN*ones(1,8)],22,1),[1:22]/9),...
    struct('itno',20,'graph','graph10'));
  crestmin(fiddata([],reshape([ones(1,11);1,1,1,NaN*ones(1,8)],22,1),[1:22]/9),...
    struct('itno',5,'graph','graph10'));
end
%
%slew rate
msinclip(1:15,[ones(8,1);NaN*ones(7,1)],[],'nograph',2,[],[],[],30);
msinclip(1:15,[ones(8,1);NaN*ones(7,1)],[],'nograph',8,[],[],[],200);
%
clear crestx cx tf ampv crestx fv fl graphnumber
%%%%% End of hmscltst %%%%%%%
