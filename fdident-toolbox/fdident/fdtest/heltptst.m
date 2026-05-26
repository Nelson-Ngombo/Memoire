%HELTPTST Test elistper

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Jun-2001

disp('File heltptst')
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
rand('seed',0), randn('seed',0)
%
echo on
%Simplest case
num=[1,1]; denom=[4,3,2,1];
pdat=exppar('s',num,denom);
df=0.05; f0=df;
freqv=[f0:df:1.0]'; F=length(freqv);
lp=1024; fs=lp*min(f0,df);
cx=msinclip(freqv,ones(size(freqv)),[],'nograph',0);
pno=10;
xt0=msinprep(freqv,cx,lp*pno,fs,'screen')*pno; %rescale by pno to assure mx~1.0
vmx=2e-5; vmy=1e-6; %Variance of mx and my
if exist('corrtest.m')
  [xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,'',fs);
else
  [xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,fs);
end
[pv,fit,Cp,Fdat,vdat]=elistper(xt,yt,fs,freqv,1,3);
graphnumber=grapause('heltptst',graphnumber,testsavegraphst);
%
echo off
[domain,nume,denome]=imppar(pv);
nume=nume/denome(1)*4; denome=denome/denome(1)*4;
%
%nume,denome
%[vmx,vmy], mean(vdat)
echo off
if any(abs(num-nume)>0.15), error('nume differs from num'), end
if any(abs(denom-denome)>0.3), error('denome differs from denom'), end
if any(abs([vmy,vmx]-mean(vdat(:,1:2)))>0.2*[vmy,vmx])
  error('Estimated variances are incorrect in simple case')
end
%
echo on
%Now strange freqv-df combination
num=[1,1]; denom=[4,3,2,1];
pdat=exppar('s',num,denom);
df=0.05; f0=1.5*df;
freqv=[f0:df:1.0]'; F=length(freqv);
lp=1024; fs=lp*min(f0,df);
cx=msinclip(freqv,ones(size(freqv)),[],'nograph',0);
pno=10;
xt0=msinprep(freqv,cx,lp*pno,fs,'screen')*pno; %rescale by pno to assure mx~1.0
vmx=2e-5; vmy=1e-6; %Variance of mx and my
if exist('corrtest.m')
  [xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,'',fs);
else
  [xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,fs);
end
[pv,fit,Cp,Fdat,vdat]=elistper(xt,yt,fs,freqv,1,3);
graphnumber=grapause('heltptst',graphnumber,testsavegraphst);
echo off
[domain,nume,denome]=imppar(pv);
nume=nume/denome(1)*4; denome=denome/denome(1)*4;
%
%nume,denome
%[vmx,vmy], mean(vdat)
echo off
if any(abs(num-nume)>0.1), error('nume differs from num'), end
if any(abs(denom-denome)>0.2), error('denome differs from denom'), end
if any(abs([vmx,vmy]*4-mean(vdat(:,1:2)))>0.2*[vmx,vmy])
  %skip test here
  disp('Warning! Variance values are not compared here')
  %error('Estimated variances are incorrect in 1.5*df case')
end
%
echo on, clc
%Now just a run with leakage compensation without test of results
%Test of elistper output still necessary
num=[1,1]; denom=[4,3,2,1];
pdat=exppar('s',num,denom);
df=0.05; f0=df;
freqv=[f0:df:1.0]'; F=length(freqv);
freqvs=freqv;
freqv(2)=1.05*freqv(2);
lp=1024; fs=lp*min(f0,df);
cx=ones(size(freqv));
pno=10;
xt0=msinprep(freqvs,cx,lp*pno,fs,'screen')*pno; %rescale by pno to assure mx~1.0
vmx=2e-5/10; vmy=1e-6/10; %Variance of mx and my
if exist('corrtest.m')
  [xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,'',fs);
else
  [xt,yt]=simtime(pdat,xt0,sqrt(2*vmx/lp*pno),1,sqrt(2*vmy/lp*pno),1,fs);
end
%
[pv,fit,Cp,Fdat,vdat]=elistper(xt,yt,fs,freqv,1,3,0,'f','leak');
graphnumber=grapause('heltptst',graphnumber,testsavegraphst);
echo off
[domain,nume,denome]=imppar(pv);
nume=nume/denome(1)*4; denome=denome/denome(1)*4;
%
%nume,denome
%[vmx,vmy], mean(vdat)
echo off
%
clear pdat df f0 fs freqv lp cx xt0 pno xt yt pv fit Cp Fdat vdat
clear domain num nume denom denome vmx vmy F tvect tvectl freqvs graphnumber
%
rand('seed',0), randn('seed',0)
%%%%% End of heltptst %%%%%%%
