%HSIMFTST
%Test simfou with new calls

disp('hsimftst running...')
randn('seed',1)
if ~exist('N'), N=[]; end, if isempty(N), N=10; end
fN=3/sqrt(N); %error limit which decreases with larger N
load bandpmod
Fdat=bkfit.data;
%
disp('Simulate 1 experiment...')
bksim=simfou(bkref,Fdat);
vd=Fdat.SiSoVariance;
vs=bksim.SiSoVariance;
if any(any(vs-vd)), error('Variances differ'), end
%
disp('Simulate noiseless experiment...')
Fnv=Fdat; Fnv.SiSoVariance=[0,0];
bksim0=simfou(bkref,Fnv);
%
fprintf('Simulate %.0f experiments...\n',N)
bksimN=simfou(bkref,Fdat,N);
vsN=bksimN.SiSoVariance;
if any(any(vsN-vd)), error('Variances differ'), end
sa=varanal(bksimN);
va=sa.SiSoVariance; %vd/N
if (abs(mean([va(:,1)./vd(:,1)])-1/N)>0.2*fN*1/N)|...
    (abs(mean([va(:,2)./vd(:,2)])-1/N)>0.2*fN*1/N)
  error('The measured variances significantly deviate from the theoretical one')
end
%
disp('Simulate 1 experiment from Fourier data...')
bksim=simfou(Fnv,Fdat);
vd=Fdat.SiSoVariance;
vs=bksim.SiSoVariance;
if any(any(vs-vd)), error('Variances differ'), end
%
disp('Simulate noiseless experiment from Fourier data...')
bksim0=simfou(Fnv);
bksim0=simfou(Fnv,Fnv);
%
fprintf('Simulate %.0f experiments from Fourier data...\n',N)
bksimN=simfou(Fnv,Fdat,N);
vsN=bksimN.SiSoVariance;
if any(any(vsN-vd)), error('Variances differ'), end
sa=varanal(bksimN);
va=sa.SiSoVariance; %approx. vd/N
if (abs(mean([va(:,1)./vd(:,1)])-1/N)>0.28*fN*1/N)|...
    (abs(mean([va(:,2)./vd(:,2)])-1/N)>0.28*fN*1/N)
  error('The measured variances significantly deviate from the theoretical one')
end
%
fprintf('Simulate %.0f experiments from noisy Fourier data...\n',N)
bksimN=simfou(Fdat,Fdat,N);
vsN=bksimN.SiSoVariance; %vd*2
if any(any( vsN(:,1:2)-2*vd(:,1:2) > (1-1e3*eps)*vd(:,1:2) ))
  error('Noisy simulation yields wrong theoretical variances')
end
sa=varanal(bksimN);
va=sa.SiSoVariance; %vd/N: the one-experiment variance does not count
if (abs(mean([va(:,1)./vd(:,1)])-1/N)>0.2*fN*1/N)|...
    (abs(mean([va(:,2)./vd(:,2)])-1/N)>0.2*fN*1/N)
  error('The measured variances significantly deviate from the theoretical one')
end
