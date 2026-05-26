%TESTVANEW Test of new calls of varanal

echo off
disp('TESTVANEW')
rand('seed',0), randn('seed',0)
fv=[1:2:25]'; N=length(fv);
so1=0.1; si1=0.01; so2=0.001; si2=0.0001;
m=fidmodel('s',3,1);
%
g1=fiddata(ones(N,1),ones(N,1),fv,so1^2,si1^2);
g2=fiddata(ones(N,1),2*ones(N,1),fv,so2^2,si2^2);
fobj=[];
for ii=1:10
  if ii==1, fprintf('Cycle'), end
  fprintf(' %.0f',ii)
  f1=simfou(m,g1);
  f1.outputname='O1'; f1.inputname='I1';
  f2=simfou(m,g2);
  f2.outputname='O2'; f2.inputname='I2';
  fobj=merge(fobj,addchannels(f1,f2));
end
disp(' ')
[vaobj,avinfo]=varanal(fobj);
c=mean(vaobj.covariance,3); v=diag(c)*avinfo.Na;
[v,[so1;si1;so2;si2].^2]
if any(abs(v-[so1;si1;so2;si2].^2)>0.3*v), error('Varanal error'), end
