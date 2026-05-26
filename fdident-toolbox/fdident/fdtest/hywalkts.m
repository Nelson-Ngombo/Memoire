%HYWALKTS Test ywalk

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
echo on
%Check ywalk
%Manual, Tutorial, Section 7.5
%
num=1; r=0.7; phi=pi/4;
den=real(poly(r*[exp(j*phi),exp(-j*phi)])); %denominator
F=50; fv=[0:F]'/F/2; %frequency points
%tf=freqz(num,den,fv*2*pi);
tf=polyval([0,0,num],exp(j*fv*2*pi))./polyval(den,exp(j*fv*2*pi));
N=20;
%simulated random variables:
tfn=abs(tf).*sum(randn(2*N-2,length(fv)).^2)'/(2*N-2);
%transfer function calculation by no windowing version of yulewalk:
echo off
disp('[num2,den2]=ywalk(2,2*fv,tfn);')
fprintf('Press a key to continue...'), pause, disp(' ')
[num2,den2]=ywalk(2,2*fv,tfn);
%tf2=freqz(num2,den2,fv*2*pi);
tf2=polyval(num2,exp(j*fv*2*pi))./polyval(den2,exp(j*fv*2*pi));
clf, hold off
%
if exist('yulewalk')==2
  compyulewalk=yesinput('Compare result with yulewalk''s','n','y|n');
else
  compyulewalk='n';
  disp('WARNING! yulewalk is not found, cannot compare results')
end
if strcmp(compyulewalk,'y')
  eval('[numstb,denstb]=yulewalk(2,2*fv,tfn);')
  %tfstb=freqz(numstb,denstb,fv*2*pi);
  tfstb=polyval(numstb,exp(j*fv*2*pi))./polyval(denstb,exp(j*fv*2*pi));
  subplot(1,2,1)
  plot(fv,abs(tf),':',fv,abs(tfstb),'-',fv,tfn,'+')
  title('Magnitude, with yulewalk')
  subplot(1,2,2)
  clear numstb denstb tfstb
end
%
plot(fv,abs(tf),':',fv,abs(tf2),'-',fv,tfn,'+')
if strcmp(compyulewalk,'n'), title('Magnitude, with ywalk')
else title('Magnitude')
end
graphnumber=grapause('hywalkts',graphnumber,testsavegraphst);
%
clear tf fv tf2 tfn num den r phi N num2 den2 F zv graphnumber
rand('seed',0), randn('seed',0)
%%%%% End of hywalkts %%%%%%%
