%HELISNEW Test elis with new input arguments

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Nov-2001

echo on, close, iterctrl
testno=0;
disp('File helisnew')
tmp=load('bandpass.mat');
Fdat=tmp.bandpass_agv; clear tmp
%
%if 1==2
%
[pv,dev]=elis(Fdat,'s',4,6); pause
elis(Fdat,'s',4,6,struct('representation','orthopol')); pause
elis(Fdat,'z',6,6,struct('representation','orthopol','fs',3000)); pause
elis(Fdat,'s',4,6,struct('fscale',1)); pause
elis(Fdat,'z',4,6,struct('fs',2000)); pause
elis(Fdat,'s',6,6,struct('allpass','on')); pause
elis(Fdat,'s',4,6,struct('transients','on','trnumord',5)); pause
elis(Fdat,'s',4,6,struct('delaytreat','v','delayscale',1000,'itmax',2)); pause
elis(Fdat,'s',4,16,struct('stabilization','r','itmax',2)); pause
elis(Fdat,'s',4,16,struct('stabilization','c','itmax',2,'stablimit',-0.1)); pause
%
%end %1==2
%
elis(Fdat,'s',4,16,struct('stabilization','r','forceminimumphase','r',...
  'itmax',2)); pause
elis(Fdat,'s',4,16,struct('stabilization','c','forceminimumphase','c',...
  'itmax',2,'stablimit',-0.1)); pause
num=[nan,nan,nan,0,0]; denom=nan*ones(1,7); p=fidmodel('s',num,denom);
elis(Fdat,'s',4,6,struct('fixedpars',p)); pause
denom(1)=1; p=fidmodel('s',num,denom);
for alg={'Newton-Gauss','NG','Levenberg-Marquardt','LM','LM with svd','LMsvd',...
   'singular value decomposition','svd','Newton-Raphson','NR'}
  elis(Fdat,'s',4,6,struct('fixedpars',p,'algorithm',alg,'itmax',1)); pause
end
   for initset={'least squares','LS','l',...
         'output-weighted least squares','vary-WLS','w',...
         'output-weighted singular value decomposition','vary-WLS with svd','y',...
         'y-weighted svd','ysvd','v',...
         'u-weighted svd','usvd','u',...
         'singular value decomposition','svd','s',...
         'frequency-weighted svd','approximate maximum likelihood','AML','freq-w svd','a',...
         'equation-error variance WLS','eevWLS','r',...
         'scan different algorithms','scan','try different algorithms','trials','t'}
  testno=testno+1;
  fprintf('helisnew_no=%.0f\n',testno)
  elis(Fdat,'s',4,6,struct('fixedpars',p,'initset',initset,'itmax',1)); pause
end
for initset={'equation error method','eem'}
  pv=elis(Fdat,'s',4,6,struct('initset',initset,'itmax',1)); pause
end
for initset={'IQML','i'}
  elis(Fdat,'s',4,6,struct('initset',initset,'itmax',1,'initmodel',pv)); pause
end
elis(Fdat,'s',4,6,struct('dcfmax',1e-2)); pause
elis(Fdat,'s',4,6,struct('dprelmax',1e-2)); pause
elis(Fdat,'s',4,6,struct('algorithm','lm','lambdadecrease',2)); pause
elis(Fdat,'s',4,6,struct('algorithm','lm','lambdamin',1.11)); pause
elis(Fdat,'s',4,6,struct('algorithm','lm','lambda0',2.71)); pause
elis(Fdat,'s',4,6,struct('algorithm','lm','lambdalim',1e-2)); pause
%
elis(Fdat,'s',4,6,struct('plotdens',3)); pause
elis(Fdat,'s',4,6,struct('plot0','off')); pause
elis(Fdat,'s',4,6,struct('plotdens',3,'plotoffset',1)); pause
elis(Fdat,'s',4,6,struct('plotdenstime',2)); pause
elis(Fdat,'s',4,6,struct('plotlevel','basic')); pause
elis(Fdat,'s',4,6,struct('plotlevel','advanced')); pause
elis(Fdat,'s',4,6,struct('plotfreq','log')); pause
elis(Fdat,'s',4,6,struct('freqdim','radhz')); pause
elis(Fdat,'s',4,6,struct('magnitudeaxis',[0,100,0,100])); pause
elis(Fdat,'s',4,6,struct('pzaxis',[-1,1,-1,1])); pause
elis(Fdat,'s',4,6,struct('pzaxis','prop')); pause
elis(Fdat,'s',4,6,struct('pzaxis','all')); pause
elis(Fdat,'s',4,6,struct('pzaxis',0.1)); pause
%
elis(Fdat,'s',4,6,struct('initset','file','itmax',1,...
  'initmodel',fidmodel('s',ones(1,5),ones(1,7)))); pause
elis(Fdat,'s',4,6,struct('reportfile','rfile'));
if ~exist('rfile.rep'), error('Report file is missing'), else delete rfile.rep, end

%Development parameters
elis(Fdat,'s',4,6,'',struct('displaymessages','off')); pause
elis(Fdat,'s',4,6,'',struct('displaymessages','short')); pause
elis(Fdat,'s',4,6,'',struct('displaymessages','burst')); pause
for initset={'external weight','eW'}
  elis(Fdat,'s',4,6,struct('fixedpars',p,'initset',initset,'itmax',1,...
    'initweight',ones(size(Fdat.freqpoints)))); pause
end
elis(Fdat,'s',4,6,struct('representation','orthopol'),struct('newbasis','on')); pause
elis(Fdat,'z',4,6,struct('representation','orthopol','fs',3000),struct('newbasis','on')); pause
elis(Fdat,'s',4,6,'',struct('linesearch','on')); pause
elis(Fdat,'s',4,6,'',struct('calculatezeros','off')); pause
elis(Fdat,'s',4,6,'',struct('calculatepoles','off')); pause
elis(Fdat,'s',4,6,'',struct('followroots',3)); pause
elis(Fdat,'s',4,6,'',struct('checkiterctrl','off')); pause
elis(Fdat,'s',4,6,'',struct('calldrawnow','off')); pause
%
elis date
d=elis('date');
%%%%%%%%%%%%%%%%% End of helisnew %%%%%%%%%%%%%%%%%%%
