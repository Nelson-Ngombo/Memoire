%HVARANTS Test varanal

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
disp('HVARANTS')
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, hold off
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
rand('seed',0), randn('seed',0)
echo on
%Check varanal
%
%Simplest cases
freqv=1;
x=(1+j)*[1;1;-1;-1]+1;
y=0.1*j*x;
Fdat=expfou(freqv,x,y);
[vx,vy,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat);
echo off
disp(' ')
if abs(vx-4/3)>10*eps, error('Wrong value of vx'), end
if abs(vy-0.01*4/3)>10*eps, error('Wrong value of vy'), end
if abs(cxy-0.1*j*4/3)>10*eps, error('Wrong value of cxy'), end
if abs(mx-1)>10*eps, error('Wrong value of mx'), end
if abs(my-0.1*j)>10*eps, error('Wrong value of my'), end
if Na~=4, error('Na is not 4'), end
if Np~=4, error('Np is not 4'), end
fprintf('Press a key to continue ...'), pause, disp(' ')
%
clf
echo on
%T set to zero
[vx,vy,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',0);
echo off
disp(' ')
if Na~=4, error('Na is not 4'), end
if Np~=4, error('Np is not 4'), end
fprintf('Press a key to continue ...'), pause, disp(' ')
%
echo on
freqv=[1;1];
x=[0.9;0.9;j;j;-1.1;-1.1;1;-1];
y=0.1*(-j)*x;
Fdat=expfou(freqv,x,y);
[vx,vy,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',1);
echo off
disp(' ')
if abs(vx-0.005)>10*eps, error('Wrong value of vx'), end
if abs(vy-0.01*0.005)>10*eps, error('Wrong value of vy'), end
if abs(cxy+0.1*j*0.005)>10*eps, error('Wrong value of cxy'), end
if abs(mx-1)>10*eps, error('Wrong value of mx'), end
if abs(my+0.1*j)>10*eps, error('Wrong value of my'), end
if Na~=3, error('Na is not 3'), end
if Np~=4, error('Np is not 4'), end
fprintf('Press a key to continue ...'), pause, disp(' ')
%
echo on
%MIMO test
num=[5,5]; denom=[4,3,2,1];
pdat=exppar('z',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-4*[1,1];
expno=10;
x=[]; y=[];
tauv=N*(rand(expno-1,1)-0.5);
echo off
disp('Simulations ...')
for i=0:expno-1
  if i==0, tau=0; else tau=tauv(i); end
  [xi,yi]=simfou(pdat,freqv,cx.*exp(-sqrt(-1)*2*pi*freqv*tau),vdat);
  x=[x;[xi,(1+j)*xi]]; y=[y;yi,-yi];
end
Fdat=expfou(freqv,x,y);
disp(['[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=',...
        'varanal(Fdat,[],''delayed'',N);'])
fprintf('Press a key to continue...'), pause, disp(' ')
[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',N);
graphnumber=grapause('hvarants',graphnumber,testsavegraphst);
%
disp('Estimated and true delays:')
delays=[dv,tauv]
if any(abs(diff(delays'))>0.01), error('delays differ'), end
mvx=mean(varx);
fprintf('mean(varx)=[%.3e,%.3e]  true value = %.3e\n',mvx(:,1),mvx(:,2),vdat(1))
if (mvx(:,1)*cfl(1)>vdat(1))|(mvx(:,1)*cfl(2)<vdat(1))
  fprintf('Warning! varx strongly deviates from true value\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
Fdat=[freqv,mx(:,1),my(:,1)];
ploteltf(pdat,'',Fdat);
graphnumber=grapause('hvarants',graphnumber,testsavegraphst);
%
%SISO test 1
num=[5,5]; denom=[4,3,2,1];
pdat=exppar('z',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-4*[1,1,-j];
expno=5;
x=[]; y=[]; freqvlong=[];
tauv=N*(rand(expno-1,1)-0.5);
for i=0:expno-1
  if i==0, tau=0; else tau=tauv(i); end
  [xi,yi]=simfou(pdat,freqv,cx.*exp(-sqrt(-1)*2*pi*freqv*tau),vdat);
  x=[x;xi]; y=[y;yi];
  freqvlong=[freqvlong;freqv];
end
echo off
disp(['[varx,vary,covxy,mx,my,Na,Np,cfl,dv,sd]=',...
        'varanal([freqvlong,x,y],[],''delayed'',N);'])
fprintf('Press a key to continue...'), pause, disp(' ')
[varx,vary,covxy,mx,my,Na,Np,cfl,dv,sd]=varanal([freqvlong,x,y],[],'delayed',N);
graphnumber=grapause('hvarants',graphnumber,testsavegraphst);
%
disp('Estimated and true delays:')
delays=[dv,tauv]
fprintf('mean(varx)=%.3e,  true value = %.3e\n',mean(varx),vdat(1))
if (mean(varx)*cfl(1)>vdat(1))|(mean(varx)*cfl(2)<vdat(1))
  fprintf('Warning! varx strongly deviates from true value\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
%
%SISO test 2
num=[5,5]; denom=[4,3,2,1];
pdat=exppar('z',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
vdat=1e-4*[1,1,-j];
expno=5;
x=[]; y=[]; freqvlong=[];
tauv=N*(rand(expno-1,1)-0.5);
echo off
disp(['[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=',...
        'varanal(''hgetftst'',[1:expno],''delayed'');'])
fprintf('Press a key to continue...'), pause, disp(' ')
[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=varanal('hgetftst',[1:expno],'delayed');
xp=0.82; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','Verticalalignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
%
fprintf('mean(varx)=%.3e,  true value = %.3e\n',mean(varx),vdat(1))
if (mean(varx)*cfl(1)>vdat(1))|(mean(varx)*cfl(2)<vdat(1))
  fprintf('Warning! varx strongly deviates from true value\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
Fdat=[freqv,mx,my];
ploteltf(pdat,'',Fdat);
graphnumber=grapause('hvarants',graphnumber,testsavegraphst);
%
clear Fdat pdat num denom N freqv cx vdat expno x y xi yi varx vary n cfl mx my
clear dv delays tauv fl freqvlong vx vy cxy Na Np sd graphnumber
rand('seed',0), randn('seed',0)
%
%%%%% End of hvarants %%%%%%%
