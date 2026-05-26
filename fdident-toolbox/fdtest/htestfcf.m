%HTESTFCF Test fcoeffs
%randn('seed',0), rand('seed',0)
iivect=[1:7];
%iivect=[1:3,5:6,7];
%iivect=[5:7];
%iivect=[4];
ic=0;
for ii=iivect
  ic=ic+1;
  fprintf('fcoeffs cycle %.0f of %.0f\n',ic,length(iivect))
  clear N Nf t fs f T X x xm
  fprintf('Testing fcoeffs, cycle %.0f\n',ii)
  if ii==1
    N=1024; t=[1:2.5*N]; fs=1; Nf=8; 
    f=[1:Nf]/N*fs; T=N/fs; X=ones(size(f)).*exp(j*2*pi*rand(size(f)));
    stdn=0;
  elseif ii==2
    N=1024; t=[1:2.5*N]; fs=1; Nf=8; 
    f=[1:Nf]/N*fs; T=N/fs; X=ones(size(f)).*exp(j*2*pi*rand(size(f)));
    stdn=1;
  elseif ii==3
    N=2^14; t=[1:2.3*N]; fs=1; Nf=25; 
    f=[1:Nf]/N*fs; T=N/fs; X=ones(size(f)).*exp(j*2*pi*rand(size(f)));
    stdn=0;
  elseif ii==4
    N=2^8; t=[1:round(3.2*N)]; fs=1; Nf=8; 
    f=[1:Nf]/N*fs; T=N/fs; X=ones(size(f)).*exp(j*2*pi*rand(size(f)));
    stdn=0.5;
  elseif ii==5
    N=2^9; t=[1:round(2.3*N)]; fs=1; Nf=6; 
    f=[1:2:Nf]/N*fs; T=N/fs; X=ones(size(f)).*exp(j*2*pi*rand(size(f)));
    stdn=1;
  elseif ii==6
    N=2^12; t=[1:round(2.3*N)]; fs=1; Nf=35; 
    f=[1:Nf]/N*fs; T=N/fs; X=ones(size(f)).*exp(j*2*pi*rand(size(f)));
    stdn=0;
  elseif ii==7
    N=2^9; t=[1:round(2.3*N)]; fs=1; Nf=15; 
    f=[0,1:2:Nf]/N*fs; T=N/fs; 
    X=ones(size(f)).*exp(j*2*pi*rand(size(f))); 
    stdn=0;
  else
    error(sprintf('ii=%.0f is not allowed',ii))
  end
  if any(f==0), X(1)=abs(X(1)); end
  x=2*real(X)*cos(2*pi*f'*t)-2*imag(X)*sin(2*pi*f'*t);
  if any(f==0), x=x-X(1); end
  xm=x+stdn*randn(size(x));
  if max(f)>=fs/2, error('Too large frequency'), end
  %
  figure(1), clf
  [Xe,Xvar,fe,Te]=fcoeffs(xm,fs);
  %indf=find((fe>min(f)-fs/N/4)&(fe<max(f)+fs/N/4));
  indf=[];
  for iii=1:length(f)
    [dummy,fi]=min(abs(fe-f(iii)));
    indf=[indf;fi];
  end
  %disp('Complex amplitudes (original and estimated):'), complex_amplitudes=[X.',Xe(indf)]
  %
  %figure(81), plot(unwrap(angle(X))), figure(82), plot(unwrap(angle(Xe(indf)))), shg
  %
  figure(98)
  clf
  if min(f)>0, fm=[0;f(:)]; else fm=f(:); end
  f1=min(diff(fm)); Nm=fs/f1;
  Y=fft(x(1:Nm)); plot([0:max(f)/f1]*fs,abs(Y(1:max(f)/f1+1))), shg
  %
  figure(99)
  clf
  xlim=[0,max(f)+fs/N];
  subplot(1,2,1)
  set(cla,'xlim',xlim,'ylim',[min(abs(X))-1,max(abs(X))+1])
  hold on
  semilogy(f,abs(X));
  hold off
  title(sprintf('Original Fourier coefficients, ii=%.0f',ii))  
  %
  subplot(1,2,2)
  set(cla,'xlim',xlim,'ylim',[min(abs(X))-1,max(abs(X))+1])
  hold on
  semilogy(fe(indf),abs(Xe(indf)));
  hold off
  title('Estimated Fourier coefficients')  
  drawnow, shg
  %
  fprintf('Relative period deviation: %.3g\n',(Te-T)/T)
  if ~isequal(ii,iivect(end))
    fprintf('Press any key to continue...'), disp(' '), pause
  end
end %for ii
close(98), close(99)
%
%Johan's example
if exist('htestfcf.mat')
  disp('Johan''s example...')
  load htestfcf.mat
  v2=BKfcftestdata.output; v1=BKfcftestdata.input;
  M=9; P=2*1024;
  plot(v1); drawnow
  % Traditional processing
  y1=v1((1:P*M));   % input
  y1=reshape(y1,P,M);
  Y1=fft(y1);
  
  y2=v2((1:P*M));   % input
  y2=reshape(y2,P,M);
  Y2=fft(y2);
  
  G2=Y2(2:4:floor(0.4*P),:)./Y1(2:4:floor(0.4*P),:);
  G2m=mean(G2,2);G2s=std(G2,1,2)/sqrt(M);
  
  % Using the routine
  %[Zm,Zcov,F,T]=PeriodEstimate([v1 v2],1);
  [Zm,Zcov,F,T]=fcoeffs([v1 v2],1);
  lines=2:4:floor(0.4*P);       % select the lines in use
  
  G1m=Zm(lines,2)./(Zm(lines,1));  % measured FRF
  
  varG1m=abs(G1m).^2.*(Zcov(lines,1)./(abs(Zm(lines,1)).^2)+ ...
  Zcov(lines,2)./(abs(Zm(lines,2)).^2))- ... 
  2*(abs(G1m).^2).*real(Zcov(lines,3)./(Zm(lines,2).*conj(Zm(lines,1)))); % variance on G1m
  
  F=F(2:4:floor(0.4*P));
  clf, plot(F,20*log10(abs(G1m)),'+',F,20*log10(abs(G2s)),'+',...
    F,20*log10(abs(G2m-G1m)),'*',F,20*log10(abs(varG1m))/2)
  legend('G1m new routine','std old routine','error','std new routine')
  fprintf('Press any key to continue...'), pause, disp(' ')
end
%
disp('Test of fcoeffs for robotarm_rawdata')
t=NaN;
d=load('robotarm.mat'); d=d.robotarm_rawdata;
disp('Input only')
if exist('PeriodEstimate.m')
  tic
  PeriodEstimate(d.input,1/d.ts);
  t(1)=toc
end
tic
fcoeffs(d.input,1/d.ts);
disp('input/PeriodEstimate, input/fcoeffs, i/o/PeriodEstimate, i/o/fcoeffs, object/fcoeffs')
t(2)=toc
disp('Input and Output')
t(3)=NaN;
if exist('PeriodEstimate.m')
  tic
  PeriodEstimate([d.input,d.output],1/d.ts);
  disp('input/PeriodEstimate, input/fcoeffs, i/o/PeriodEstimate, i/o/fcoeffs, object/fcoeffs')
  t(3)=toc
end
tic
fcoeffs([d.input,d.output],1/d.ts);
disp('input/PeriodEstimate, input/fcoeffs, i/o/PeriodEstimate, i/o/fcoeffs, object/fcoeffs')
t(4)=toc
disp('fcoeffs')
tic
Fdat=fcoeffs(d);
disp('input/PeriodEstimate, input/fcoeffs, i/o/PeriodEstimate, i/o/fcoeffs, object/fcoeffs')
t(5)=toc
%
tic
Fdatfft=varanal(tim2fou(segment(d)));
tfft(1)=toc
dm=d; dm.frequencies=Fdatfft.freqpoints;
%
load robotarm, td=robotarm_rawdata;
tic
Fdat=fcoeffs(td);
tfft(2)=toc
plot(Fdat), pause
tic
Fdat2=fcoeffs(td(1:16000),td.periodlength);
tfft(3)=toc
plot(Fdat2), pause
tic
td.frequencies=[];
Fdat3=fcoeffs(td(1:16000),td.periodlength);
tfft(4)=toc
plot(Fdat3), pause
tic
Fdat4=fcoeffs(td(1:16000));
tfft(5)=toc
plot(Fdat4), pause
%
%tic
%Fdatfft=varanal(tim2fou(segment(dm),'leak'));
%tfft(2)=toc
disp('fft, leak, fcoeffs')
tfft(3)=t(5)
close, disp('htestfcf ready.')
%End of tstfcf
