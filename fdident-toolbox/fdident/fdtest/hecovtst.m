%HECOVTST  Test fdcovpzp and stdpz

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
rand('seed',0), randn('seed',0)
%
%Simple tests starting from Cp
disp('HECOVTST')
disp('Simple tests starting from Cp')
for i=1:2 %zeros only; poles only
  if i==1
    pvect=exppar('s',2*[1,5,1],10);
    Cp=0.01*eye(5); Cp(5,5)=0; %delay
    Cp(1:3,1:3)=-0.01*ones(3,3); Cp(1:3,1:3)=Cp(1:3,1:3)+3*0.01*eye(3);
    Cp(1,3)=0.01; Cp(3,1)=0.01;
  elseif i==2
    pvect=exppar('s',10,2*[1,5,1]);
    Cp=0.01*eye(5); Cp(5,5)=0; %delay
    Cp(2:4,2:4)=-0.01*ones(3,3); Cp(2:4,2:4)=Cp(2:4,2:4)+3*0.01*eye(3);
    Cp(2,4)=0.01; Cp(4,2)=0.01;
  end
  [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pvect,Cp);
  [pvect2,Cp2]=fdcovpzp(zv,stdz,pv,stdp,rzp,g,stdg);
  if any(abs(pvect-pvect2)>1000*eps), error('Wrong pvect2'), end
  if any(abs(Cp(:)-Cp2(:))>1000*eps), error('Wrong Cp2'), end
  clear pvect2 Cp2
  dzp=inf;
  [pvect3,Cp3]=fdcovpzp(zv,stdz,pv,stdp,rzp,g,stdg,'s',1,'num',dzp);
  if any(abs(pvect-pvect3)>1000*eps), error('Wrong pvect3'), end
  if any(abs(Cp(:)-Cp3(:))>1e-4*dzp*max(Cp(:))), error('Wrong Cp3'), end
  clear pvect3 Cp3
end %for i
%
%Simple tests starting from a zero-pole model
disp('Simple tests starting from a zero-pole model')
c=0.8;
dcount=0;
for dzp=[0.00001,0.01,1]
  dcount=dcount+1;
  if dcount==1, iv=[1:12]; else iv=[7:12]; end
  fprintf('dzp=%.2g\n',dzp)
  for i=iv
    %fprintf('i=%.0f\n',i)
    if rem(i,6)==1
      disp('One zero, no pole')
      zv0=[1]; stdz0=[0.01,0,0];
      pv0=[]; stdp0=[];
    elseif rem(i,6)==2
      disp('Two zeros, no pole')
      zv0=[-1-j;-1+j]; stdz0=[.01,0.04,c;0.01,0.04,-c];
      pv0=[]; stdp0=[];
    elseif rem(i,6)==3
      disp('Three zeros, no pole')
      zv0=[-1-j;-1+j;1]; stdz0=[.01,0.04,c;0.01,0.04,-c;.1,0,0];
      pv0=[]; stdp0=[];
    elseif rem(i,6)==4
      disp('One pole, no zero')
      pv0=[1]; stdp0=[0.01,0,0];
      zv0=[]; stdz0=[];
    elseif rem(i,6)==5
      disp('Two poles, no zero')
      pv0=[-1-j;-1+j]; stdp0=[.01,0.04,c;0.01,0.04,-c];
      zv0=[]; stdz0=[];
    elseif rem(i,6)==0
      disp('Three poles, no zero')
      pv0=[-1-j;-1+j;1]; stdp0=[.01,.04,c;0.01,0.04,-c;.1,0,0];
      zv0=[]; stdz0=[];
    end
    rzpl=2*length([zv0;pv0])+2;
    rzp0=eye(rzpl);
    if (rem(i,6)~=1)&(rem(i,6)~=4)
      rzp0(1,2)=c; rzp0(2,1)=c; rzp0(3,4)=-c; rzp0(4,3)=-c;
      rzp0(1,3)=1; rzp0(3,1)=1; rzp0(1,4)=-c; rzp0(4,1)=-c;
      rzp0(2,4)=-1; rzp0(4,2)=-1; rzp0(2,3)=c; rzp0(3,2)=c;
    end
    if i<=6
      disp('  Analytic derivation')
      da='anal';
      [pvect,Cp]=fdcovpzp(zv0,stdz0,pv0,stdp0);
    else
      disp('  Numerical derivation')
      da='num';
      [pvect,Cp]=fdcovpzp(zv0,stdz0,pv0,stdp0,[],[],[],'z',10,'num',dzp);
    end
    [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pvect,Cp,zv0,pv0);
    if strcmp(da,'anal'), dlim=1e4*eps; else dlim=1e-3*dzp; end
    if ~isempty(zv)
      if any(abs([zv]-[zv0])>100*eps), error('Wrong zv'), end
      if any(any(abs([stdz]-[stdz0])>dlim)), error('Wrong stdz'), end
    end
    if ~isempty(pv)
      if any(abs([pv]-[pv0])>100*eps), error('Wrong pv'), end
      if any(any(abs([stdp]-[stdp0])>dlim)), error('Wrong stdp'), end
    end
    if any(any(abs([rzp0]-[rzp])>dlim)), error('Wrong rzp'), end
  end %for i
end %for dzp
%
%Graphics tests with the input channel data
disp('Graphics tests with the input channel data')
for i=1:4
  if rem(i,2)==1, da='anal';
  elseif rem(i,2)==0
    da='num';
    if i==2, dzp=1; else dzp=0.2; end
  end
  if i<=2
    if exist('inpchmod.mat')
      vars=load('inpchmod.mat');
      pvect=vars.inpchanz; Cp=vars.inpchanz.covariance;
    else
     [dom,num,denom,delay,fs]=imppar('inpchanz.pbn');
     pvect=exppar(dom,num,denom,delay,fs);
     Cp=impcov('inpchanz.cbn');
    end
    axv='z'; dom='z'; sc=30;
  else
    if exist('inpchmod.mat')
      vars=load('inpchmod.mat');
      pvect=vars.inpchans; Cp=vars.inpchans.covariance;
    else
     [dom,num,denom,delay,fs]=imppar('inpchans.pbn');
     pvect=exppar(dom,num,denom,delay,fs);
     Cp=impcov('inpchans.cbn');
    end
    axv=[-6,2,-4,4]*1e5; dom='s';
    sc=10;
  end
  %
  if isnumeric(pvect)
    [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pvect);
    [pvectn,Cpn]=fdcovpzp(zv,stdz,pv,stdp,rzp,g,stdg,dom,51200,da,dzp);
    subplot(121),plotelpz(pvect,Cp,sc,axv,'nomsg')
    subplot(122),plotelpz(pvectn,Cpn,sc,axv,'nomsg')
    txth=axes('Position',[0,0,1,1]); axis('off')
    if strcmp(da,'anal')
      text(0.5,0,['Deralg: ',da],'VerticalAlignment','bottom')
    else
      text(0.5,0,sprintf('Deralg: num, dzp=%.2g',dzp),...
        'VerticalAlignment','bottom')
    end
    graphnumber=grapause('hecovtst',graphnumber,testsavegraphst);
  elseif isa(pvect,'fidmodel')
    [zpkdata,rzp,dps]=stdpz(pvect);
    [pvectn]=fdcovpzp(zpkdata,dom,51200,da,dzp);
    subplot(121),plotelpz(pvect,Cp,sc,axv,'nomsg')
    subplot(122),plotelpz(pvectn,pvectn.covariance,sc,axv,'nomsg')
    txth=axes('Position',[0,0,1,1]); axis('off')
    if strcmp(da,'anal')
      text(0.5,0,['Deralg: ',da],'VerticalAlignment','bottom')
    else
      text(0.5,0,sprintf('Deralg: num, dzp=%.2g',dzp),...
        'VerticalAlignment','bottom')
    end
    graphnumber=grapause('hecovtst',graphnumber,testsavegraphst);
  end
end
%
clear pvect Cp pvectn Cpn xp yp zv stdz pv stdp g stdg dom sc axv i txth
clear dzp pv0 zv0 stdp0 stdz0 dlim rzp rzp0 c dcount rzpl iv da graphnumber
rand('seed',0), randn('seed',0)
%%%%% End of hecovtst %%%%%%%
