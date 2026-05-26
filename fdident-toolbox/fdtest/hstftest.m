%HSTFTEST Test simtime and tim2fou

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
echo on
%Check simtime, tim2fou
%
rand('seed',0), randn('seed',0)
%
%1. S-DOMAIN PARAMETER FILE
num=[5,5]; denom=[4,3,2,1];
pdat=exppar('s',num,denom,0);
N=64; di=N/2/16;
fi=[1:di:16*di-1]'; freqv=fi/N; fl=length(freqv);
x0=ones(fl,1);
cx=x0.*exp(sqrt(-1)*2*pi*rand(fl,1));
sp=zeros(N,1);
sp(fi+1)=cx; sp(N+1-fi)=conj(cx);
u=real(ifft(sp));
%
fs=1;
if exist('corrtest.m')
  [xt,yt]=simtime(pdat,u,0,1,0,1,'',fs);
else
  [xt,yt]=simtime(pdat,u,0,1,0,1,fs);
end
tdat=exptim([0:N-1],xt,yt);
Fdat=tim2fou(tdat,freqv);
[freqv,x,y]=impfou(Fdat);
echo off
if any(abs(cx-x)>N*100*eps)
  error(['Simulation and conversion did not give back complex ',...
        'amplitudes, s-domain'])
end
echo on
Fdat=tim2fou(tdat,freqv,'','leak');
[freqv,xl,yl]=impfou(Fdat);
echo off
if any(abs(x-xl)>N*100*eps)|any(abs(y-yl)>N*100*eps)
  error(['tim2fou gives different results for fmod='''' and fmod=''leak''',...
        ', fft grid, s-domain'])
end
echo on
freqvm=freqv; freqvm(1)=(1+fl*150*eps)*freqvm(1);
Fdat=tim2fou(tdat,freqvm,'','leak');
[freqvm,xl,yl]=impfou(Fdat);
echo off
if any(abs(x-xl)>N*1e3*eps)|any(abs(y-yl)>N*1e3*eps)
  error(['tim2fou gives different results for fmod='''' and ',...
        'fmod=''leak'', s-domain'])
end
%
if exist('corrtest.m')
  [xt,yt]=simtime(pdat,u,1e-3,1,1e-3,1,'',fs);
else
  [xt,yt]=simtime(pdat,u,1e-3,1,1e-3,1,fs);
end
tdat=exptim([0:N-1],xt,yt);
Fdat=tim2fou(tdat,freqv);
disp('ploteltf(pdat,'''',Fdat)')
fprintf('Press any key to continue...'), pause, disp(' ')
ploteltf(pdat,'',Fdat)
graphnumber=grapause('simtftst',graphnumber,testsavegraphst);
%
echo on
%2. Z-DOMAIN PARAMETER FILE
num=[5,5]; denom=[4,3,2,1];
pdat=exppar('z',num,denom,0,1);
N=64; di=N/2/16;
fi=[1:di:16*di-1]'; freqv=fi/N; fl=length(freqv);
x0=ones(fl,1);
cx=x0.*exp(sqrt(-1)*2*pi*rand(fl,1));
sp=zeros(N,1);
sp(fi+1)=cx; sp(N+1-fi)=conj(cx);
u=real(ifft(sp));
%
sp(fi+1)=cx; sp(N+1-fi)=conj(cx);
u=real(ifft(sp));
%
[xt,yt]=simtime(pdat,u,0,1,0,1,'periodic');
tdat=exptim([0:N-1],xt,yt);
Fdat=tim2fou(tdat,freqv);
[freqv,x,y]=impfou(Fdat);
echo off
if any(abs(cx-x)>N*100*eps)
  error(['Simulation and conversion did not give back complex ',...
        'amplitudes, s-domain'])
end
%
echo on
[xt,yt]=simtime(pdat,u,1e-3,1,1e-3,1,'periodic');
tdat=exptim([0:N-1],xt,yt);
Fdat=tim2fou(tdat,freqv);
echo off
disp('ploteltf(pdat,'''',Fdat)')
fprintf('Press any key to continue...'), pause, disp(' ')
ploteltf(pdat,'',Fdat)
graphnumber=grapause('simtftst',graphnumber,testsavegraphst);
%
echo on
N=80;
u=[1;zeros(N-1,1)];
[xt,yt]=simtime(pdat,u,1e-3,1,1e-3,1,'transient');
tdat=[[0:N-1]',xt,yt];
Fdat=tim2fou(tdat,freqv,[],'leak');
[freqv,x,y]=impfou(Fdat);
echo off
clf, subplot(2,2,1)
plot(1:N,xt), title('Input signal')
subplot(2,2,2)
plot(1:N,yt), title('Output signal')
subplot(2,2,3)
plot(freqv,abs(x),'+',0,0,'.'), title('Input amplitudes')
subplot(2,2,4)
plot(freqv,abs(y),'+'), title('Output amplitudes')
echo off
graphnumber=grapause('simtftst',graphnumber,testsavegraphst);
%
echo on
%leakage
N=80; tv=[0:N-1]'/N;
fv=1.1; c=1;
xt=1/N*c(1)*2*cos(2*pi*fv(1)*tv); yt=xt+.2;
Fdat=tim2fou([tv,xt,yt],fv,[],'leak');
[fv,x,y]=impfou(Fdat);
echo off
if length(x)~=length(fv), error('Length of x is not 1'), end
if any(abs(x-y)>100*eps), error('x and y differ, F=1'), end
if any(abs(x-c)>N*eps*10), error('x is wrong, F=1'), end
%
echo on
fv=[1.1,1.4]; c=[1;1.7*exp(j*2*pi/8)];
xt=1/N*c(1)*2*cos(2*pi*fv(1)*tv)+1/N*abs(c(2)*2)*cos(2*pi*fv(2)*tv+angle(c(2)));
yt=xt;
Fdat=tim2fou([tv,xt,yt],fv,[],'leak');
[fv,x,y]=impfou(Fdat);
echo off
if length(x)~=length(fv), error('Length of x is not 2'), end
if any(abs(x-y)>100*eps), error('x and y differ, F=2'), end
if any(abs(x-c)>N*eps*10), error('x is wrong, F=2'), end
%
echo on
%two experiments
Fdat=tim2fou([tv,xt,-yt;tv,-xt,yt],fv,[],'leak');
[fv,x,y]=impfou(Fdat);
echo off
if length(x)~=2*length(fv), error('Length of x is not 4'), end
if any(abs(x+y)>100*eps), error('x and y differ, F=4'), end
if any(abs(x-[c;-c])>N*eps*10), error('x is wrong, F=4'), end
%
echo on
%Function call in tim2fou
Fdat=tim2fou('hgetttst',[],[1:2]);
[freqv,x,y]=impfou(Fdat);
echo off
if any(abs(freqv-[0:15]'/32)>10*eps)
  error('Bad freqv from tim2fou with function call, empty freqv')
end
Fdat=tim2fou('hgetttst',[0,3/32],[1:2]);
[freqv,x,y]=impfou(Fdat);
if any(abs(freqv-[0;3/32])>10*eps)
  error('Bad freqv from tim2fou with function call, freqv=[0,3/32]')
end
if any(any(abs(x-[32;0;64;0])>10*eps))
  error('Bad x from tim2fou with function call, freqv=[0,3/32]')
end
if any(any(abs(y-[3.2,320;0,0;6.4,640;0,0])>10*eps))
  error('Bad y from tim2fou with function call, freqv=[0,3/32]')
end
%
%Array input in tim2fou
Fdat=tim2fou([[1:32]',ones(32,1),0.1*ones(32,1);
                [1:32]',2*ones(32,1),0.2*ones(32,1)],[],[1:2]);
[freqv,x,y]=impfou(Fdat);
if any(abs(freqv-[0:15]'/32)>10*eps)
  error('Bad freqv from tim2fou with array, empty freqv')
end
Fdat=tim2fou([[1:32]',ones(32,1),0.1*ones(32,1);
                [1:32]',2*ones(32,1),0.2*ones(32,1)],[0,3/32],[1:2]);
[freqv,x,y]=impfou(Fdat);
if any(abs(freqv-[0;3/32])>10*eps)
  error('Bad freqv from tim2fou with array, freqv=[0,3/32]')
end
if any(any(abs(x-[32;0;64;0])>10*eps))
  error('Bad x from tim2fou with array, freqv=[0,3/32]')
end
if any(any(abs(y-[3.2;0;6.4;0])>10*eps))
  error('Bad y from tim2fou with array, freqv=[0,3/32]')
end
%
load robotarm, t=robotarm_rawdata;
Fdat=tim2fou(t);
Fdat=tim2fou(t(1:16000));
t2=t; t2.outputname='output';
tt=addchannels(t,t2);
tim2fou(tt);
tt.periodlength=[]; tim2fou(tt);
tt.frequencies=[]; tim2fou(tt);
%
clear Fdat t tt t2 tdat u x y xl yl sp xt yt cx x0 freqv pdat num denom di fi N fl fs
clear c fv tv graphnumber ans
rand('seed',0), randn('seed',0)
%%%%% End of simtftst %%%%%%%
