%HRDUETST Test rdueelis

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
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
rand('seed',0), randn('seed',0)
echo on
%Check rdueelis
%
num=[1]; denom=[.5e-1/2/pi,1];
no=length(num)-1; nd=length(denom)-1;
pdat=exppar('s',num,denom,0);
freqv=[1:4,5:5:100]'; fl=length(freqv);
x0=ones(fl,1);
vdat=[2.5e-3,2.5e-3];
%
vdat3=[2.5e-3,2.5e-3,j*2e-3];
[x,y]=simfou(pdat,freqv,x0,vdat3,3);
Fdat=expfou(freqv,x,y);
[rx,ry,ryx,vryx,xe,ye]=rdueelis(pdat,'',Fdat,vdat3);
%
[x,y]=simfou(pdat,freqv,x0,vdat);
[dummy,tf]=simfou(pdat,freqv,x0,[0,0]);
Fdat=[freqv,x,y];
[rx,ry,ryx,vryx,xe,ye]=rdueelis(pdat,'',Fdat,vdat);
echo off
fprintf('Press a key to continue...'), pause, disp(' ')
clf, subplot(2,2,4), hold off
plot(freqv,abs(tf),['-',white],freqv,abs(y./x),['+',green])
title('Transfer function')
%
subplot(2,2,1)
pv=[real(rx);imag(rx);real(ry);imag(ry);real(ryx);imag(ryx)];
pv=[pv;abs([rx;ry;ryx])];
ax4=1.1*max(abs(pv));
plot(freqv,real(rx),['-.',red],freqv,imag(rx),[':',red],...
        freqv,abs(rx),['-',white],[0,0],[-ax4,ax4],['.',white])
axv=axis;
title('real,imag,abs rx')
%title('real(rx), imag(rx)')
%
subplot(2,2,2)
plot(freqv,real(ry),['-.',red],freqv,imag(ry),[':',red],...
        freqv,abs(ry),['-',white])
axis(axv);
title('real,imag,abs ry')
%title('real(ry), imag(ry)')
%
subplot(2,2,3)
plot(freqv,real(ryx),['-.',red],freqv,imag(ryx),[':',red],...
        freqv,abs(ryx),['-',white])
%plot(freqv,real(ryx),['-',white],freqv,imag(ryx),[':',white])
axis(axv);
title('real,imag,abs ryx')
axes('Position',[0,0,1,1]), axis('off')
text(0.5,0,sprintf('sigmax=sigmay=%.4f',sqrt(vdat(1))),...
        'Horizontalalignment','center','Verticalalignment','bottom')
graphnumber=grapause('hrduetst',graphnumber,testsavegraphst);
%
clear ryx rx ry pv x0 x y pdat Fdat vdat freqv tf dummy
clear ax4 axv num denom fl nd no graphnumber
rand('seed',0), randn('seed',0)
%%%%% End of hrduetst %%%%%%%
