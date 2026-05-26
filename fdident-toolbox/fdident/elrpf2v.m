function [rppar,fixp,rpalg,rppl,initp,rpfs]=elrpf2v(rpfile)
%ELRPF2V Conversion of elis run parameter file into run parameter vectors.
%
%       [rppar,fixp,rpalg,rppl,initp,rpfs]=ELRPF2V(rpfile)
%
%       Input argument:
%       rpfile = name of run parameter file (*.ebn)
%
%       Output arguments (see ELIS for details):
%         When there are no output arguments, the run parameters will be listed
%         to the screen.
%       rppar = vector of the basic model descriptors
%       fixp = definition of fixed parameters.
%       rpalg = vector of basic algorithm descriptors
%       rppl = vector of plot modifiers
%       initp = initial parameter values
%       rpfs = names of files to be generated
%
%       Usage: [rppar,fixp,rpalg,rppl,initp,rpfs]=elrpf2v(rpfile);
%       Example: elisqa('elrpftst.ebn');
%                [rppar,fixp,rpalg,rppl,initp,prfs]=elrpf2v('elrpftst.ebn');
%                elrpf2v('elrpftst.ebn')
%
%       See also: ELIS, ELISQA, ELRPV2F.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

nargoutelrp=nargout;
[rpfile,fnsh,ext]=fnamanal(rpfile,'ebn');
if ~strcmp(ext,'ebn'), error('Extension is not ''.ebn'''), end
%
ffile=''; %name of Fourier file (maybe without extension)
vfile=''; %name of variance file (maybe without extension)
pfile=''; %parameter file to be generated (maybe empty)
cfile=''; %covariance file to be generated
rfile=''; %report file to be generated
initpfile=''; %name of parameter file, containing the initial
                 %values (maybe without extension)
algtype='NG'; %type of the iteration algorithm (NG,LM,LMsvd,NR,svd)
amin=NaN; %axisvect(3) for magnitude plot
amax=NaN; %axisvect(4) for magnitude plot
calcrnum='c'; %calculate roots of numerator (c,n)
calcrdenom='c'; %calculate roots of denominator (c,n)
covxy=[]; %covariance between input and output amplitudes
delay=0; %(initial) value of the delay
delaytreat='f'; %delay fix (f) or variable (v)
denomord=2; %order of the denominator
denomfix=[]; %fix denominator coefficients
denomfixind=[]; %fix denominator coefficient indices
domain='s'; %domain of the model to be fitted (s,z)
expi=1; %number of the experiment to be used
fmin=0; %lower bound of displayed frequencies
fmax=NaN; %maximal displayed frequency in the s-domain
fpfile=''; %file of fixed parameters (optional)
fs=NaN; %sampling (normalising) frequency
initset='l'; %way of setting the initial values (l,w,s,f,e)
itmax=50; %maximal number of iteration cycles
lambda0=.1; %starting value for the Levenberg-Marquardt iteration
lambdadecr=10; %after lambdadecr consecutive decreases of lambda, 0 is tried
lambdalim=1e-10; %above this value of lambda the iteration will continue
numord=1; %order of the numerator
numfix=[]; %fix numerator coefficients
numfixind=[]; %fix numerator coefficient indices
paramtreat='n'; %no param fixed (n) some predefined (0, d or r) allpass (a)
plotdens=1; %cycles of iteration to plot (1,2...inf)
plotmode='i'; %frequency axis, i (lin) or o (log)
pzaxis='a'; %ploe/zero axis: 'a' for all poles and zeros
pzfollown=1; %pole/zero sets to be plotted on same plot
pzlimit='y'; %limit p/z on plot to pzlimimitv*2*pi*fmax (s) or 2 (z) (n,y)
pzlimitv=10;
rcostvar=1e-6; %minimal relative variation of the cost function
rparvar=0; %minimal relative variation of parameters
vardef='u'; %variance values: numbers or from file (u,f)
varx=1; %uniform variance value of the input coefficients
vary=1; %uniform variance value of the output coefficients
%
eval(['load ',rpfile,' -mat']),
%
%Correction for old files
if strcmp(paramtreat,'f'), paramtreat='0'; end
if length(plotmode)==3, plotmode=plotmode(2); end
if exist('lambdadlim')==1, lambdadecr=lambdadlim; end %notation change
%
if nargoutelrp>0,
  rppar=['s'+0,1,2,1];
  rpalg=['gw'+0,50,1e-6,0,10,0.1,1e-10];
  rppl=[1,0,NaN,NaN,NaN,'icca   '+0,1];
  rpfs='';
  %
  rppar(1)=domain+0;
  rppar(2)=numord;
  rppar(3)=denomord;
  rppar(4)=fs;
  if strcmp(paramtreat,'a'), rppar(5)='a'+0; end
  %
  if strcmp(paramtreat,'0'), fixp='0'+0;
  else
    fixp=[numfixind(:)+1,numfix(:);denomfixind(:)+1+numord+1,denomfix(:)];
    if strcmp(delaytreat,'f'), fixp=[fixp;numord+denomord+3,delay]; end
  end
  %
  if strcmp(algtype,'NG')|strcmp(algtype,'ng'), rpalg(1)='g'+0;
  elseif strcmp(algtype,'LM')|strcmp(algtype,'lm'), rpalg(1)='l'+0;
  elseif strcmp(algtype,'LMsvd')|strcmp(algtype,'lmsvd'), rpalg(1)='m'+0;
  elseif strcmp(algtype,'svd'), rpalg(1)='s'+0;
  elseif strcmp(algtype,'NR')|strcmp(algtype,'nr'), rpalg(1)='r'+0;
  end
  rpalg(2)=initset+0;
  if strcmp(initset,'f'), initp=initpfile; else initp=delay; end
  rpalg(3)=itmax;
  rpalg(4)=rcostvar;
  rpalg(5)=rparvar;
  rpalg(6)=lambdadecr;
  rpalg(7)=lambda0;
  rpalg(8)=lambdalim;
  %
  rppl(1)=plotdens;
  rppl(2)=fmin;
  rppl(3)=fmax;
  rppl(4)=amin;
  rppl(5)=amax;
  rppl(6)=plotmode+0;
  rppl(7)=calcrnum+0;
  rppl(8)=calcrdenom+0;
  if strcmp(pzlimit,'n'), rppl(9:12)='a   '+0;
  else rppl(9:12)=pzlimitv*[-1,1,-1,1];
  end
  rppl(13)=pzfollown;
  %
  rpfsv=min(size(rfile))+min(size(pfile))+min(size(cfile));
  rpfsh=max([length(rfile),length(pfile),length(cfile)]);
  rpfs=setstr(' '*ones(rpfsv,rpfsh));
  i=1;
  if ~isempty(rfile), rpfs(i,1:length(rfile))=rfile; i=i+1; end
  if ~isempty(pfile), rpfs(i,1:length(pfile))=pfile; i=i+1; end
  if ~isempty(cfile), rpfs(i,1:length(cfile))=cfile; i=i+1; end
  if isstr(rppar)|isstr(rpalg)|isstr(rppl)
    vers=version;
    if strcmp(vers(1:2),'4.')
      disp('Warning! rppar, rpalg or rppl is a string in elrpf2v')
    else %Matlab5
      error('rppar, rpalg or rppl is a string in elrpf2v')
    end
  end
else %no output arguments given
  fprintf(['Contents of the run parameter file ''',rpfile,...
        '''\n(list made on ',date,')\n\n'])
  fprintf(['ffile=''',ffile,'''','\n']);
  if strcmp(vardef,'f'), fprintf(['vfile=''',vfile,'''','\n']); end
  fprintf(['pfile=''',pfile,'''','\n']);
  fprintf(['cfile=''',cfile,'''','\n']);
  fprintf(['rfile=''',rfile,'''','\n']);
  if strcmp(initset,'f')
    fprintf(['initpfile=''',initpfile,'''','\n']);
  end
  fprintf(['algtype=''',algtype,'''','\n'])
  if isnan(amin), fprintf('amin=NaN\n')
  else fprintf('amin=%.5g\n',amin)
  end
  if isnan(amax), fprintf('amax=NaN\n')
  else fprintf('amax=%.5g\n',amax)
  end
  fprintf(['calcrnum=''',calcrnum,'''\n'])
  fprintf(['calcrdenom=''',calcrdenom,'''\n'])
  if length(covxy)==1, fprintf('covxy=%.5g%+.5gj\n',real(covxy),imag(covxy))
  elseif length(covxy)==0, fprintf('covxy=[]\n')
  end
  fprintf('delay=%.5g\n',delay)
  fprintf(['delaytreat=''',delaytreat,'''\n'])
  fprintf('denomord=%.0f\n',denomord)
  fprintf('[denomfixind,denomfix]=\n')
  for i=1:length(denomfix)
    if domain=='s', k=denomord-denomfixind(i); else k=denomfixind(i); end
    fprintf('   %.0f   %.5g   %% a(%.0f)\n',denomfixind(i),denomfix(i),k)
  end
  if isempty(denomfix), fprintf('   []\n'), end
  fprintf(['domain=''',domain,'''\n'])
  fprintf('expi=\n')
  for i=1:length(expi)
    fprintf('   %.0f\n',expi(i))
  end
  if isempty(expi), fprintf('   []\n'), end
  fprintf('fmin=%.5g\n',fmin)
  if isnan(fmax), fprintf('fmax=NaN\n')
  else fprintf('fmax=%.5g\n',fmax)
  end
  if isnan(fs), fprintf('fs=NaN\n')
  else fprintf('fs=%.5g\n',fs)
  end
  fprintf(['initset=''',initset,'''\n'])
  fprintf('itmax=%.0f\n',itmax)
  fprintf('lambda0=%.5g\n',lambda0)
  fprintf('lambdadecr=%.5g\n',lambdadecr)
  fprintf('lambdalim=%.5g\n',lambdalim)
  fprintf('numord=%.0f\n',numord)
  fprintf('[numfixind,numfix]=\n')
  for i=1:length(numfix)
    if domain=='s', k=numord-numfixind(i); else k=numfixind(i); end
    fprintf('   %.0f   %.5g   %% b(%.0f)\n',numfixind(i),numfix(i),k)
  end
  if isempty(numfix), fprintf('   []\n'), end
  fprintfnumfixind=[];
  fprintf(['paramtreat=''',paramtreat,'''\n'])
  if isfinite(plotdens), fprintf('plotdens=%.0f\n',plotdens)
  else fprintf('plotdens=inf\n')
  end
  fprintf(['plotmode=''',plotmode,'''\n'])
  if isempty(pzaxis), fprintf('pzaxis=[]\n')
  elseif isstr(pzaxis), fprintf(['pzaxis=''',pzaxis,'''\n'])
  else fprintf('pzaxis=[%.5g %.5g %.5g',pzaxis(1),pzaxis(2),pzaxis(3))
    fprintf(' %.5g]\n',pzaxis(4))
  end
  fprintf('pzfollown=%.0f\n',pzfollown)
  fprintf(['pzlimit=''',pzlimit,'''\n'])
  fprintf('pzlimitv=%.5g\n',pzlimitv)
  fprintf('rcostvar=%.5g\n',rcostvar)
  fprintf('rparvar=%.5g\n',rparvar)
  fprintf(['vardef=''',vardef,'''\n'])
  if strcmp(vardef,'u')
    if length(varx)==1, fprintf('varx=%.5g, vary=%.5g\n',varx,vary), end
  end
  disp(' ')
end
%%%%%%%%%%%%%%%%%%%%%%%% end of elrpf2v %%%%%%%%%%%%%%%%%%%%%%%%
