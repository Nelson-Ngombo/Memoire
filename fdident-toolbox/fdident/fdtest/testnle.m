%TESTNLE  Test robust nonlinear analysis

Np=2^8; M=100; A=10/(Np/2); %20dB
y=A*cos(2*pi*1*[1:M*Np]/Np)';
stdn=0.001*sqrt(M)/sqrt(Np); %std for average -60 dB
y=y+stdn*randn(size(y));
u=cos(2*pi*1*[1:M*Np]/Np)'/(Np/2); %0dB
d=tiddata(y,u,1/Np);
set(d,'periodsa',Np,'frequencies',1)
f=varanal(tim2fou(segment(d)));
plot(f,'#'), shg
%plot(f), shg
Ne=10; fn=[];
for ii=1:Ne
  ff=f; 
  %ff.y=ff.y+0.1*sqrt(1/2)*(randn(1,1)+j*randn(1,1));
  ff.y=ff.y+0.1*sqrt((Ne-1)/Ne)*exp(j*2*pi*ii/Ne); %- 20 dB
  fn=merge(fn,ff);
end
fn.groups_samepower=[1:Ne];
fav=nonlinvar(fn);
plot(fav,'@'), zoom on
disp(' ')
outputnonlinerror=db(fav.outputnonlinerr)/2 %-20 dB
outputnonlinvar=db(fav.outputnonlinvar)/2 %-30 dB
outputvar=db(fav.outputvar)/2 %-70 dB -> plot -60
if (abs(outputnonlinerror+20)>0.001)|...
    (abs(outputnonlinvar+30)>0.001)|...
    (abs(outputvar+70)>1)
  error('Something is wrong in robust nonlinear analysis')
end
h1=findobj(gca,'marker','+');
h2=findobj(gca,'marker','x');
dat1=get(h1,'ydata');
dat2=get(h2,'ydata');
if iscell(dat2)
  dat2=sort([dat2{1};dat2{2};dat2{3}]);
  if (abs(dat1-20)>0.001)|any(abs(dat2-[-60;-30;-20])>1)
    error('Something wrong in robust nonlinear analysis plots')
  end
end