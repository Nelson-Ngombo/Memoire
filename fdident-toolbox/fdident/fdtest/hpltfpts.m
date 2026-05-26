%HPLTFPTS Test ploteltf, plotelpz, stdtf, stdpz, stdtfm

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
%Check ploteltf and plotelpz
%
echo off
%
disp(' '), disp('TEST OF S-DOMAIN PLOTS')
disp('First some calculations will be performed...')
rand('seed',0), randn('seed',0)
num=[5,5]; denom=[4,3,2,1];
no=length(num)-1; nd=length(denom)-1;
delay=1;
pdat=exppar('s',num,denom,delay);
pdat1=exppar('s',1.1*num,denom,delay);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-2*[1,1];
[x,y]=simfou(pdat,freqv,cx,vdat);
Fdat=[freqv,x,y];
[pvect,fit,Cp,CR,cfv]=elis(Fdat,vdat,['s',no,nd],'f',[NaN,NaN,2],[50],delay);
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
clf, hold off
disp(['Now the errors of the estimated transfer function will ',...
                'be calculated...'])
for msc='*='
  ploteltf(pvect,pdat1,Fdat,'lin',msc,Cp)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
  clf
end
cc=3;
fprintf('Plot %.0f-sigma bounds of the magnitudes only...\n',cc)
ploteltf(pvect,[],Fdat,'lin','+',Cp,cc)
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','Verticalalignment','bottom',...
                'HorizontalAlignment','center')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
disp('Plot phases only...')
ploteltf([],pdat,Fdat,'lin','-')
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
%
for msc='*='
  if any(msc=='*')
    cc=1;
    fprintf('Plot %.0f-sigma errors of tfm...\n',cc)
  else
    cc=2;
    fprintf('Plot %.0f-sigma bounds of tfm...\n',cc)
  end
  ploteltf(pvect,pdat,Fdat,'lin',msc,vdat,cc)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
end
%
clf, hold off
disp('Pole/zero plot with uncertainty bounds...')
axv=[-2.5,0.1,-0.8,0.8];
plotelpz(pvect,Cp,10,axv)
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
%
clear pdat pdat1 Fdat x y fit Cp CR cfv freqv cx vdat num denom no nd delay
clear pvect N fl axv
if strcmp(computer,setstr('pc'-32))|strcmp(computer,setstr('mac'-32))
  save hpltfpts.mat, clear, clear functions
  load hpltfpts.mat, delete hpltfpts.mat
end
%
disp(' '), disp('TEST OF W-DOMAIN PLOTS')
disp('First some calculations will be performed...')
rand('seed',0), randn('seed',0)
num=[5,5]; denom=[4,3,2,1];
no=length(num)-1; nd=length(denom)-1;
delay=1;
pdat=exppar('w',num,denom,delay);
N=64;
freqv=15*([0.2,0.5,1:N/2-1]'/N); fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-5*[1,1];
[x,y]=simfou(pdat,freqv,cx,vdat);
Fdat=[freqv,x,y];
if exist('corrtest.m')
  [pvect,fit,Cp,CR,cfv]=elis(Fdat,vdat,['w',no,nd],'f',[],[50],delay);
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
  %
  clf, hold off
  disp(['Now the estimation errors of the transfer function will ',...
                'be calculated...'])
  ploteltf(pvect,pdat,Fdat,'lin','',Cp)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
  %
  clf
  cc=3;
  fprintf('Plot %.0f-sigma bounds of the magnitudes only...\n',cc)
  ploteltf(pvect,[],Fdat,'lin','+',Cp,cc)
  xp=0.82; yp=0;
  txth=axes('Position',[0,0,1,1]); axis('off')
  text(xp,yp,'Press a key...','Verticalalignment','bottom',...
                'HorizontalAlignment','center')
  fprintf('Press any key to continue ...'), figure(gcf), pause
  delete(txth), disp(' ')
  disp('Plot phases only...')
  ploteltf([],pdat,Fdat,'lin','-')
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
  %
  cc=2;
  fprintf('Plot %.0f-sigma errors of tfm...\n',cc)
  ploteltf(pvect,pdat,Fdat,'lin','=',vdat,cc)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
  %
  clf, hold off
  disp('Pole/zero plot with uncertainty bounds...')
  axv=[-2.5,0.1,-0.8,0.8];
  plotelpz(pvect,Cp,10,axv)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
end
%
clear pdat Fdat x y fit Cp CR cfv freqv cx vdat num denom no nd delay pvect
clear N fl axv
if strcmp(computer,setstr('pc'-32))|strcmp(computer,setstr('mac'-32))
  save hpltfpts.mat, clear, clear functions
  load hpltfpts.mat, delete hpltfpts.mat
end
%
disp(' '), disp('TEST OF Z-DOMAIN PLOTS...')
disp('First some calculations will be performed...')
rand('seed',0), randn('seed',0)
num=[5,5]; denom=[4,3,2,1];
no=length(num)-1; nd=length(denom)-1;
delay=1;
pdat=exppar('z',num,denom,delay,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-2*[1,1];
[x,y]=simfou(pdat,freqv,cx,vdat);
Fdat=[freqv,x,y];
fixp=[3,4;7,0];
fixp(2,:)=[]; rppl=50;
[pvect,fit,Cp,CR,cfv]=elis(Fdat,vdat,['z',no,nd],fixp,'',rppl,delay);
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
%
clf, hold off
for msc='*='
  if msc=='='
    disp(['Now the confidence bounds of the transfer function will be ',...
                'calculated...'])
  else %*
    disp(['Now the estimation errors of the transfer function will be ',...
                'calculated...'])
  end
  ploteltf(pvect,pdat,Fdat,'lin','',Cp,1)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
end
%
clf
cc=3;
fprintf('Plot %.0f-sigma bounds of the magnitudes only...\n',cc)
ploteltf(pvect,[],Fdat,'lin','+',Cp,cc)
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','Verticalalignment','bottom',...
                'HorizontalAlignment','center')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
disp('Plot phases only...')
ploteltf([],pdat,Fdat,'lin','-')
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
%
cc=1;
for msc='*='
  if msc=='='
    fprintf('Plot %.0f-sigma bounds of tfm...\n',cc)
  else
    fprintf('Plot %.0f-sigma errors of tfm...\n',cc)
  end
  ploteltf(pvect,pdat,Fdat,'lin',msc,vdat,cc)
  graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
end
%
clear pdat Fdat x y fit cfv freqv cx vdat num denom no nd delay
clear N fl axv
%
clf, hold off
disp('Pole/zero plot with uncertainty bounds...')
plotelpz(pvect,Cp,10)
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
%
%Now do a series of plots
load rarmmods
%
plotelpz(m,'c'), xlabel('s-domain'), zoom on, pause
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
[zpkdata,rzp,dps]=stdpz(m);
%
plotelpz(mo,'c'), xlabel('orthopol'), zoom on, pause
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
[zpkdata,rzp,dps]=stdpz(mo);
%
plotelpz(z_domain,'c'), xlabel('z-domain'), zoom on, pause
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
[zpkdata,rzp,dps]=stdpz(z_domain);
%
plotelpz(moz,'c'), xlabel('z-orthopol'), zoom on, pause
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
[zpkdata,rzp,dps]=stdpz(moz);
%
plotelpz(w_domain,'c'), xlabel('w-domain'), zoom on, pause
graphnumber=grapause('hpltfpts',graphnumber,testsavegraphst);
[zpkdata,rzp,dps]=stdpz(w_domain);
%
clf
plotelpz(m)
for dalg={'anal','num'}
  plotelpz(m,struct('conf','on','dalg',dalg)), drawnow
  plotelpz(m,struct('cloud','on','dalg',dalg)), drawnow
  plotelpz(m,struct('conf','on','cloud','on','dalg',dalg)), drawnow
  plotelpz(m,struct('conf','on','cloud','on','Pc',.99,'dalg',dalg)), drawnow
  plotelpz(m,struct('conf','on','cloud','on','stdm',10,'dalg',dalg)), drawnow
end
%
clear m mo moz robotarm_3models robotarm_6models w_domain s_domain z_domain
clear zpkdata dps rzp
%
clear pvect Cp CR cc cn graphnumber msc xp yp fixp ans a rppl
rand('seed',0), randn('seed',0)
%%%%% End of hpltfpts %%%%%%%
