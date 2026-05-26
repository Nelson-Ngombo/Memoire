%HVATSOBJ Test varanal with objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 20-Jan-2004

echo off
disp('HVATSOBJ')
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
x=(1+j)*[1;1;-1;-1]'+1; y=0.1*j*x; expno=size(x,2);
%Fdat=expfou(freqv,x,y);
MatlV=version;
if str2num(MatlV(1:3))<6.5
  Fdat=fiddata(num2cell(y,1),num2cell(x,1),freqv);  
else
  Fdat=fiddata(mat2cell(y,1,ones(expno,1)),mat2cell(x,1,ones(expno,1)),freqv);
end
%[vx,vy,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat);
[vaFdat,avinfo]=varanal(Fdat);
Na=avinfo.Na; Np=avinfo.Np; cfl=avinfo.cfl; dv=avinfo.dv;
mx=vaFdat.u; my=vaFdat.y;
vx=vaFdat.inputvariance/(2/Na); vy=vaFdat.outputvariance/(2/Na); 
cxy=vaFdat.covvect/(2/Na);
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
%[vx,vy,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',0);
[vaFdat,avinfo]=varanal(Fdat,'delayed',0);
Na=avinfo.Na; Np=avinfo.Np; cfl=avinfo.cfl; dv=avinfo.dv;
mx=vaFdat.u; my=vaFdat.y;
vx=vaFdat.inputvariance/(2/Na); vy=vaFdat.outputvariance/(2/Na); 
cxy=vaFdat.covvect/(2/Na);
echo off
disp(' ')
if Na~=4, error('Na is not 4'), end
if Np~=4, error('Np is not 4'), end
fprintf('Press a key to continue ...'), pause, disp(' ')
%
echo on
freqv=[1;1]; F=length(freqv);
%x=[0.9;0.9;j;j;-1.1;-1.1;1;-1].'; y=0.1*(-j)*x;
%Fdat=expfou(freqv,x,y);
x=[[0.9;0.9],[j;j],[-1.1;-1.1],[1;-1]]; y=0.1*(-j)*x; expno=size(x,2);
if str2num(MatlV(1:3))<6.5
  Fdat=fiddata(num2cell(y,1),num2cell(x,1),freqv);
else
  Fdat=fiddata(mat2cell(y,F,ones(expno,1)),mat2cell(x,F,ones(expno,1)),freqv);
end
%[vx,vy,cxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',1);
[vaFdat,avinfo]=varanal(Fdat,'delayed',1);
Na=avinfo.Na; Np=avinfo.Np; cfl=avinfo.cfl; dv=avinfo.dv;
mx=vaFdat.u; my=vaFdat.y;
vx=vaFdat.inputvariance/(2/Na); vy=vaFdat.outputvariance/(2/Na); 
cxy=vaFdat.covvect/(2/Na);
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
%pdat=exppar('z',num,denom,0,1);
pdat=fidmodel('z^-1',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-4*[1,1];
expno=10;
x=[]; y=[];
tauv=N*(rand(expno-1,1)-0.5);
echo off
disp('Simulations ...')
Fdat=[];
for ii=0:expno-1
  if ii==0, tau=0; fprintf('MIMO simulation cycle: '), else tau=tauv(ii); end
  %[xi,yi]=simfou(pdat,freqv,cx.*exp(-sqrt(-1)*2*pi*freqv*tau),vdat);
  Fdati=simfou(pdat,fiddata(zeros(size(freqv)),...
    cx.*exp(-sqrt(-1)*2*pi*freqv*tau),freqv,2*vdat(2),2*vdat(1)));
  Fdati=addchannels(Fdati,simfou(pdat,fiddata(zeros(size(freqv)),...
    cx.*exp(-sqrt(-1)*2*pi*freqv*tau),freqv,2*vdat(2),2*vdat(1))));
  %x=[x;[xi,(1+j)*xi]]; y=[y;yi,-yi];
  Fdati.inputname={'I1';'I2'}; Fdati.outputname={'O1';'O2'};
  Fdat=merge(Fdat,Fdati);
  fprintf('%.0f ',ii+1)
end
fprintf('\n')
%Fdat=expfou(freqv,x,y);
%
%disp(['[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],''delayed'',N);'])
disp(['[avdata,avinfo]=varanal(Fdat,''delayed'',N);'])
fprintf('Press a key to continue...'), pause, disp(' ')
%[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=varanal(Fdat,[],'delayed',N);
[vaFdat,avinfo]=varanal(Fdat,'delayed',N);
Na=avinfo.Na; Np=avinfo.Np; cfl=avinfo.cfl; dv=avinfo.dv;
mx=vaFdat.u; my=vaFdat.y;
varx=vaFdat.inputvariance; varx=[varx{1},varx{2}]/(2/Na);
vary=vaFdat.outputvariance; vary=[vary{1},vary{2}]/(2/Na); 
covxy=vaFdat.covariancematrix/(2/Na);
graphnumber=grapause('hvatsobj',graphnumber,testsavegraphst);
%
disp('Estimated and true delays:')
delays=[dv(2:end),tauv]
if any(abs(diff(delays'))>0.01), error('delays differ'), end 
mvx=mean(varx);
fprintf('mean(varx)=[%.3e,%.3e]  true value = %.3e\n',mvx(:,1),mvx(:,2),vdat(1))
%warning('Not yet finished'), pause, return
if (mvx(:,1)*cfl(1)>vdat(1))|(mvx(:,1)*cfl(2)<vdat(1))
  fprintf('Warning! varx strongly deviates from true value\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
%Fdat=[freqv,mx(:,1),my(:,1)];
Fdat=fiddata(my{1},mx{1},freqv);
ploteltf(pdat,'',Fdat);
graphnumber=grapause('hvatsobj',graphnumber,testsavegraphst);
%
%SISO test 1
num=[5,5]; denom=[4,3,2,1];
%pdat=exppar('z',num,denom,0,1);
pdat=fidmodel('z^-1',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=exp(sqrt(-1)*2*pi*rand(fl,1));
vdat=1e-4*[1,1,-j*0.95];
expno=5;
x=[]; y=[]; freqvlong=[];
tauv=N*(rand(expno-1,1)-0.5);
Fdat=[];
for ii=0:expno-1
  if ii==0, tau=0; fprintf('SISO simulation cycle: '), else tau=tauv(ii); end
  %[xi,yi]=simfou(pdat,freqv,cx.*exp(-sqrt(-1)*2*pi*freqv*tau),vdat);
  %x=[x;xi]; y=[y;yi];
  Fdati=simfou(pdat,fiddata(zeros(size(cx)),cx.*exp(-sqrt(-1)*2*pi*freqv*tau),freqv,...
    2*vdat(2),2*vdat(1),2*vdat(3)*ones(size(cx))));
  Fdat=merge(Fdat,Fdati);
  fprintf('%.0f ',ii+1)
end
fprintf('\n')
echo off
%disp(['[varx,vary,covxy,mx,my,Na,Np,cfl,dv,sd]=',...
%        'varanal([freqvlong,x,y],[],''delayed'',N);'])
disp('[vaFdat,avinfo]=varanal(Fdat,''delayed'',N);')
fprintf('Press a key to continue...'), pause, disp(' ')
%[varx,vary,covxy,mx,my,Na,Np,cfl,dv,sd]=varanal([freqvlong,x,y],[],'delayed',N);
[vaFdat,avinfo]=varanal(Fdat,'delayed',N);
Na=avinfo.Na; Np=avinfo.Np; cfl=avinfo.cfl; dv=avinfo.dv;
mx=vaFdat.u; my=vaFdat.y;
varx=vaFdat.inputvariance/(2/Na);
vary=vaFdat.outputvariance/(2/Na); 
covxy=vaFdat.covariancematrix/(2/Na);
graphnumber=grapause('hvatsobj',graphnumber,testsavegraphst);
%
disp('Estimated and true delays:')
delays=[dv(2:end),tauv]
if any(abs(diff(delays'))>0.01), error('delays differ'), end 
fprintf('mean(varx)=%.3e,  true value = %.3e\n',mean(varx),vdat(1))
if (mean(varx)*cfl(1)>vdat(1))|(mean(varx)*cfl(2)<vdat(1))
  fprintf('Warning! varx strongly deviates from true value\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
%
%SISO test 2
num=[5,5]; denom=[4,3,2,1];
%pdat=exppar('z',num,denom,0,1);
pdat=fidmodel('z^-1',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
vdat=1e-4*[1,1,-j*0.95];
expno=5;
x=[]; y=[]; freqvlong=[];
tauv=N*(rand(expno-1,1)-0.5);
echo off
%disp(['[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=',...
%        'varanal(''hgetftst'',[1:expno],''delayed'');'])
disp('[vaFdat,avinfo]=varanal(''hgetftstobj'',[1:expno],''delayed'');')
fprintf('Press a key to continue...'), pause, disp(' ')
%[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=varanal('hgetftst',[1:expno],'delayed');
[vaFdat,avinfo]=varanal('hgetftstobj',[1:expno],'delayed');
%[varx,vary,covxy,mx,my,Na,Np,cfl,dv]=varanal('hgetftst',[1:expno],'delayed');
Na=avinfo.Na; Np=avinfo.Np; cfl=avinfo.cfl; dv=avinfo.dv;
mx=vaFdat.u; my=vaFdat.y;
varx=vaFdat.inputvariance/(2/Na);
vary=vaFdat.outputvariance/(2/Na); 
covxy=vaFdat.covariancematrix/(2/Na);
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
graphnumber=grapause('hvatsobj',graphnumber,testsavegraphst);
%
clear Fdat pdat num denom N freqv cx vdat expno x y xi yi varx vary n cfl mx my
clear dv delays tauv fl freqvlong vx vy cxy Na Np sd graphnumber
rand('seed',0), randn('seed',0)
%
testvanew
%%%%% End of hvatsobj %%%%%%%
