%ILLRARM  Illustrate flexible robotarm in plot

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 21-Mar-1999

lw=2.5; xl=25; xf=1/6; N=100; rl=16;
figure
set(gcf,'tag','illrarm')
clf, ha=gca;
angvect=[0:N]'/N*2*pi;
set(gca,'defaultlinelinewidth',lw), hold on
hc=plot(sin(angvect),cos(angvect),'b');
fr=2/5; af=[-angvect(N*fr/2:-1:1);angvect(2:N*fr/2)];
hc2=plot(-1.8*cos(af),1.8*sin(af),'b','linewidth',lw*2/3);
x=get(hc2,'xdata'); y=get(hc2,'ydata');
p1=[x(end);y(end)];
p2=[x(end-1);y(end-1)];
arr=[p1+5*(p2-p1)+[0;0.08],p1,p1+3.2*(p2-p1)-[0;0.2]];
harr=plot(arr(1,:),arr(2,:),'linewidth',lw*2/3);
plot([0,rl,rl,0],[1,1,-1,-1],'b')
plot(rl+[0,rl/10,rl/10,0,0,rl/10,rl/10,0],...
  [1,0.75,0.3,0.3,-0.3,-0.3,-0.75,-1],'b')
plot(0.6+[1,1,3,3,5,5,7,7,9,9,11,11,13,13,15,15],...
  [-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1],'b','linewidth',lw*2/3)
plot(rl*1.15*[1,1],1.8*[-1,1],'b','linewidth',lw*2/3)
plot(rl*1.15+[-0.15,0,.15],[1.2,1.8,1.2],'linewidth',lw*2/3)
text(x(1),-2.8,'u(t)','horizontalal','center')
text(rl*1.15,-2.8,'y(t)','horizontalal','center')

title('Sketch of robot arm')
if ~strncmp(version,'5.2',3), set(gcf,'toolbar','none'), end
axis('square')

set(gca,'xlim',[-xf*xl,(1-xf)*xl],'ylim',[-xl/2,xl/2])
figure(gcf)
