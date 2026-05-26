%PLOTCABL Plot cable measurement data

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Oct-1998

if ~exist('cablei'), cablei=[]; end
if isempty(cablei), cablei=1; end
cablei=yesinput('Experiment (1-6)',cablei,[1,6]);
tname=['cable',int2str(cablei)];
%
obj=loadvar('cable',tname);
timevect=[0:obj.samplen-1]*obj.ts;
data=obj.output;
clf, hold off
plot(1e9*timevect,data,'-')
title('TDR data')
xlabel(sprintf('Time (ns),  dt=%.3g ns,  N=%.0f',...
         1e9*(timevect(2)-timevect(1)),length(timevect)))
xp=0; yp=0;
txth=axes('Position',[0,0,1,1]); axis('off')
text(xp,yp,tname,'VerticalAlignment','bottom')
%
cablei=rem(cablei,6); cablei=cablei+1;
%
%eval(['print -deps ',tname,'.eps'])
%
%%%%%%%%%%%%%%%%%%%%%%%% end of plotcabl %%%%%%%%%%%%%%%%%%%%%%%%
