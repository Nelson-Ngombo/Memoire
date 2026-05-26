%CABLEDEM Demonstration - processing of cable measurements

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
echo on, clc
%The location of the fault in a cable may be determined by injecting narrow
%pulses into the cable, and measuring the time to the pulse, reflected from
%the fault. This technique is called time domain reflectometry.
%The problem is that the pulses become distorted while travelling along
%the cable, because of the skin effect. Therefore, it is not easy to measure
%the time delay between them. In this application of EliS, the distortion
%will be modelled by a low-order linear system, and this system will be
%identified with variable delay. Though the distortion is in fact caused by a
%nonlinear effect, the linear approximation may help in more exact
%measurement of the delay.
%Further details: see the book of Schoukens and Pintelon, Section 8.4, p. 268.
%
%Available experiments:
%     1) Open ended cable, length: 101.8 m
%     2) Open ended cable, length: 506.14 m
%     3) Termination: 75 Ohm, length: 102.55 m
%     4) Termination: 28 Ohm, length: 102.64 m
%     5) Short ended cable, length: 102.55 m
%     6) Termination: 1.2 nF, length: 102.63 m
%
echo off
if exist('eno')~=1, eval('eno=1;'), end
if isempty(eno), eval('eno=1;'), end
eno=yesinput('Your choice',eno,[1,6]);
disp(' ')
if eno==1
  i1=7; i2=266; Nx=31; Ny=170; vart=0.25; f1=1.47e6; f2=26.5e6;
  F=17; ztrue=101.80; varx=1/12/2*Nx/Ny; vary=0.697^2/2;
  %varx=0.0002; vary=0.0002;
  numord=1; denomord=1;
elseif eno==2
  i1=1+2; i2=333+2; Nx=79-10; Ny=129; vart=0.34; f1=0.50e6; f2=8.005e6;
  F=16; ztrue=506.14; varx=1/12/2*Nx/Ny; vary=1/12/2;
  %varx=0.001; vary=0.001;
  numord=0; denomord=2;
elseif eno==3
  i1=6; i2=194+1; Nx=28; Ny=112; vart=0.6; f1=1.62e6; f2=22.73e6;
  F=14; ztrue=102.55; varx=1/12/2*Nx/Ny; vary=1.196^2/2;
  %varx=0.01; vary=0.01;
  numord=1; denomord=1;
elseif eno==4
  i1=9; i2=269; Nx=43; Ny=140; vart=0.57; f1=1.7857e6; f2=23.22e6;
  F=13; ztrue=102.64; varx=1/12/2*Nx/Ny; vary=0.734^2/2;
  %varx=0.001; vary=0.001;
  numord=2; denomord=2;
elseif eno==5
  i1=7; i2=211+5; Nx=73-2; Ny=100+50; vart=0.2; f1=2.00e6; f2=20.0e6;
  F=10; ztrue=102.55; varx=1/12/2*Nx/Ny; vary=1/12/2;
  %varx=0.0001; vary=0.0001;
  numord=1; denomord=2;
elseif eno==6
  i1=6; i2=215; Nx=35; Ny=141; vart=0.82; f1=1.418e6; f2=24.12e6;
  F=17; ztrue=102.63; varx=1/12/2*Nx/Ny; vary=0.899^2/2;
  %varx=0.001; vary=0.001;
  numord=2; denomord=2;
end
v=1.960e8;
%
echo on, clc
%First let us have a look at the measured data
%
echo off
%fprintf('Press any key to continue ...'), pause, disp(' ')
cable=loadvar('cable',['cable',int2str(eno)]);
%
data=cable.output; Ts=cable.Ts;
%
fs=1/Ts; timevect=[0:length(data)-1]'*Ts;
delay0=(i2-i1)*Ts;
%
clf, hold off
plot(1e9*timevect,data,['-',white])
title('TDR data')
xlabel(sprintf('Time (ns),  Ts=%.3g ns,  N=%.0f',...
         1e9*Ts,length(timevect)))
grid off
graphnumber=grapause('cabledem',graphnumber,demosavegraphst);
echo on, clc
%The two pulses are easy to recognise and to cut out
% (notice the displayed initial guess of the delay):
%
echo off
fprintf('First guess of location: %.5g\n',delay0*v/2)
fprintf('Error: %.3g m = %.3g ns = %.2f taps\n\n',...
     delay0*v/2-ztrue,1e9*(delay0*v/2-ztrue)/(v/2),(delay0*v/2-ztrue)/(v/2)/Ts)
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
axv=axis;
hold on
lep=[0*axv(4)+1*axv(3),0.95*axv(4)+0.05*axv(3)];
plot([1e9*timevect(i1)*[1,1],1e9*timevect(i1+Nx-1)*[1,1]],...
           [lep,lep(2:-1:1)],[':',red])
plot(1e9*[timevect(i2)*[1,1],timevect(i2+Ny-1)*[1,1]],...
        [lep,lep(2:-1:1)],[':',red])
txth=axes('Position',[0,0,1,1]); axis('off')
text(0.73,0.84,sprintf('z0 = %.5g m',delay0*v/2))
text(0.73,0.80,sprintf('zt = %.5g m',ztrue))
graphnumber=grapause('cabledem',graphnumber,demosavegraphst);
hold off
echo on, clc
%Now these pulses will be treated as input and output signals.
%The first pulse is shorter, the noisy "zero line" will be
%substituted by a constant value.
%
echo off
fdidpaus(textpause)
%fprintf('Press a key to continue ...'), pause, disp(' ')
tsh=timevect(1:Ny);
xt=median(data([1:10]-1+i1+Nx))*ones(Ny,1); xt(1:Nx)=data(i1:i1+Nx-1);
yt=data(i2:i2+Ny-1);
hold off
clf, subplot(1,2,1)
plot(tsh,xt,['-',white]), title('First pulse'), grid off
subplot(1,2,2)
plot(tsh,yt,['-',white]), title('Second pulse'), grid off
graphnumber=grapause('cabledem',graphnumber,demosavegraphst);
%
echo on, clc
%Now the transformation to the frequency domain is being performed...
%
echo off
%fdidpaus(textpause)
%fprintf('Press a key to continue ...'), pause, disp(' ')
Fdat=tim2fou(exptim(tsh,xt,yt),[]); [fv,x,y]=impfou(Fdat);
freqvect=fs*[1:Ny/2-1]'/Ny; x(1)=[]; y(1)=[];
%
hold off
clf, subplot(1,2,1)
plot(freqvect,abs(x),['+',white],freqvect,abs(x),['-',green])
%axis([0.95*f1,1.05*f2,0.95*min(abs(x)),1.05*max(abs(x))])
axis([0,1.05*max(freqvect),0,1.05*max(abs(x))])
title('Input amplitudes')
axv1=axis; hold off, grid off
subplot(1,2,2)
plot(freqvect,abs(y),['+',white],freqvect,abs(y),['-',green])
%axis([0.95*f1,1.05*f2,0.95*min(abs(y)),1.05*max(abs(y))])
axis([0,1.05*max(freqvect),0,1.05*max(abs(y))])
title('Output amplitudes')
axv2=axis; hold off, grid off
xp=0.82; yp=0.000;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,'Press a key...','VerticalAlignment','bottom')
fprintf('Press any key to continue ...'), figure(gcf), pause
delete(txth), disp(' ')
%
echo on, clc
%The spectra contain information in the lower frequency band only.
%These points can be used for identification.
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
hold on
lep1=[0*axv1(4)+1*axv1(3),0.95*axv1(4)+0.05*axv1(3)];
subplot(1,2,1), hold on
plot([f1*[1,1],f2*[1,1]],[lep1,lep1(2:-1:1)],[':',red])
axis(axv1)
lep2=[0*axv2(4)+1*axv2(3),0.95*axv2(4)+0.05*axv2(3)];
subplot(1,2,2), hold on
plot([f1*[1,1],f2*[1,1]],[lep2,lep2(2:-1:1)],[':',red])
axis(axv2)
hold off
graphnumber=grapause('cabledem',graphnumber,demosavegraphst);
clc
%
echo off
ind=find((freqvect>=f1)&(freqvect<=f2));
Fdat=[freqvect(ind),x(ind),y(ind)];
if strcmp(computer,setstr('pc'-32))|strcmp(computer,setstr('mac'-32))
  %save cabledem.mat, clear, load cabledem, delete cabledem.mat  %simulate pack
end
echo on, clc
%Now ELiS will be executed.
%A transfer function will be identified with variable delay.
%This will take some time...
%
echo off
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%
[pvect,fit,Cp]=elis(Fdat,[varx,vary],['s',numord,denomord],...
                [numord+2+denomord,1],['ll'+0,50,1e-6,0,15],10);
%
hold off
[domain,num,denom,ddelay]=imppar(pvect);
delay=delay0+ddelay;
stdp=sqrt(diag(Cp));
%
graphnumber=grapause('cabledem',graphnumber,demosavegraphst);
clc
%fprintf('The cost function is too small. The reason is that the noise was\n')
%fprintf('not modelled properly: the variances of the complex amplitudes\n')
%fprintf('are smaller than given in the run parameter file.\n\n')
fprintf('Time domain reflectometry, experiment %.0f\n\n',eno)
fprintf('First guess: %.5g m, %.0f taps/2, with Ts = %.1f ns\n',...
                v*delay0/2,i2-i1,Ts*1e9)
fprintf('Error of first guess: %+.3g m = %+.3g ns = %+.2f taps\n\n',...
     delay0*v/2-ztrue,1e9*(delay0*v/2-ztrue)/(v/2),(delay0*v/2-ztrue)/(v/2)/Ts)
fprintf('Identified transfer function coefficients:\n')
fprintf('Numerator:\n')
for i=1:length(num)
  fprintf('  a%.0f: %.5g, std: %.3g\n',i-1,num(length(num)-i+1),...
             stdp(length(num)-i+1))
end
stdp(1:length(num))=[];
fprintf('Denominator:\n')
for i=1:length(denom)
  fprintf('  b%.0f: %.5g, std: %.3g\n',i-1,...
             denom(length(denom)-i+1),stdp(length(denom)-i+1))
end
fprintf('Identified delay: %.5g ns   -->   dz = %+.3g m, %+.2f taps\n',...
                1e9*ddelay,ddelay*v/2,ddelay/Ts)
stdp(1:length(denom))=[];
fprintf('Total delay: %.6g s, std: %.3g s\n',delay,stdp)
fprintf('Location: %.5g%+.3g=%.5g m',v*delay0/2,v*ddelay/2,v*delay/2)
fprintf(', tol: %.3g m, ztrue: %.5g m\n',(v*2*stdp+0.001*v*delay)/2,ztrue)
eno=rem(eno,6)+1;
fdidpaus(textpause)
%fprintf('Press any key to continue ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of cabledem %%%%%%%%%%%%%%%%%%%%%%%%
