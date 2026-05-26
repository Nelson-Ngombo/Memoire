fsc=1000;
poles=fsc*[[-.03+j,-.03-j],100*[-.003+j,-.003-j]];
m=fidmodel('s',1e6,real(poly(poles))/fsc^4)
fv=fsc*[.5:1:3,10:10:120]'/2/pi;
f=fiddata(fv,ones(size(fv)),fv,1e-11,0.0001)
d=simfou(m,f,1)
plot(m,d)
