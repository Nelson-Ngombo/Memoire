function elrpv2f(rpfile,rppar,fixp,rpalg,rppl,initp,rpfs)
%ELRPV2F Conversion of elis run parameter vectors to run parameter file.
%
%       ELRPV2F(rpfile,rppar,fixp,rpalg,rppl,initp,rpfs)
%
%       Input arguments (see ELIS for details):
%       rpfile = name of the run parameter file to be generated
%           If rpfile is empty, the values of the internal run parameters will
%           be listed to the screen.
%       rppar = vector of the basic model descriptors
%       fixp = definition of fixed parameters.
%       rpalg = vector of basic algorithm descriptors
%       rppl = vector of plot modifiers
%       initp = initial parameter values
%       rpfs = names of files to be generated
%
%       Usage: elrpv2f(rpfile,rppar,fixp,rpalg,rppl,initp,rpfs)
%       Example: elrpv2f('newfile.ebn',['z',12,12],[0],'r');
%                elrpv2f('',['z',12,12],'0','r');
%
%       See also: ELIS, ELISQA, ELRPF2V.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Nov-1996

narginelrp=nargin;
%set default values
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
paramtreat='n'; %no params fixed (n) some predefined (0, d or r) allpass (a)
plotdens=1; %cycles of iteration to plot (1,2...inf)
plotmode='i'; %frequency axis, i (lin) or o (log)
pzfollown=1; %pole/zero sets to be plotted on same plot
pzlimit='y'; %limit p/z on plot to pzlimimitv*2*pi*fmax (s) or 2 (z) (n,y)
pzlimitv=10;
rcostvar=1e-6; %minimal relative variation of the cost function
rparvar=0; %minimal relative variation of parameters
vardef='u'; %variance values: numbers or from file (u,f)
varx=1; %uniform variance value of the input coefficients
vary=1; %uniform variance value of the output coefficients
%
if narginelrp<2, rppar=[]; end
if length(rppar)>0
  if (length(rppar)>3)&isstr(rppar)
    disp('Warning! rppar is a string: possible error in Matlab5')
  end
  rppari=['s',1,2,1,'f']; rppar=rppar(:)';
  rppari(1:length(rppar))=rppar;
  domainn=setstr(rppar(1));
  if ~strcmp(domain,domainn)
    domain=domainn;
    numfixind=[]; numfixind=[]; denomfix=[]; denomfixind=[];
  end
  if ~isnan(rppari(2)), numord=rppari(2)+0; end
  if (numord<0)|(rem(numord,1)~=0)
    error(sprintf('Illegal value of numord: %.15g',numord))
  end
  if ~isnan(rppari(3)), denomord=rppari(3)+0; end
  if (denomord<0)|(rem(denomord,1)~=0)
    error(sprintf('Illegal value of denomord: %.15g',denomord))
  end
  if ~isnan(rppari(4)), fs=rppari(4)+0; end
  if strcmp(domain,'z')&isnan(fs), fs=1; end
  if (length(rppar)>4)
    if strcmp(setstr(rppar(5)),'a')
      if ~strcmp(paramtreat,'a')
        numfixind=[]; numfixind=[]; denomfix=[]; denomfixind=[];
      end
      paramtreat='a';
    end
  end
end
%
if narginelrp>2 %fixp
  if ~isempty(fixp)
    if length(fixp)==1
      if strcmp(fixp,'f')|strcmp(fixp,'v')
        delaytreat=fixp;
      elseif strcmp(fixp,'n')
        numfix=[]; numfixind=[]; denomfix=[]; denomfixind=[]; paramtreat='n';
        delaytreat='v';
      elseif strcmp(fixp,'0')
        paramtreat='0';
        delaytreat='f'; numfix=[]; numfixind=[]; denomfix=1;
        if domain=='s', denomfixind=[denomord];
        else denomfixind=0;
        end
      end
    else %fixed parameters given in array
      numfix=[]; numfixind=[]; denomfix=[]; denomfixind=[]; paramtreat='d';
      if isstr(fixp)
        disp(['elis loads fixed parameters from file ',fixp])
        fixp=loadasc(fixp,'flat');
      end
      [h,s]=size(fixp);
      if s~=2, error('fixp is not an nx2 array'), end
      ind=find(fixp(:,1)<=numord+1);
      if ~isempty(ind)
        numfixind=fixp(ind,1)'-1; numfix=fixp(ind,2)'; fixp(ind,:)=[];
        if any(numfixind<0), error('Indices in fixp must be positive'), end
      end
      if ~isempty(fixp)
        ind=find(fixp(:,1)<=numord+1+denomord+1);
        if ~isempty(ind)
          denomfixind=fixp(ind,1)'-numord-2;
          denomfix=fixp(ind,2)'; fixp(ind,:)=[];
        end
      end
      if ~isempty(fixp)
        if fixp(1)~=numord+denomord+3, error('Invalid last index in fixp'), end
        delay=fixp(1,2); delaytreat='f';
      else
        delaytreat='v';
      end
      if isempty([numfix,denomfix])
        paramtreat='n';
      end
    end
  end %~isempty(fixp)
end
%
if narginelrp<4, rpalg=[]; end
if ~isempty(rpalg)
  rpalg2=[rpalg(:)+0;NaN];
  if ((length(rpalg)>3)|any(rpalg2(1:2)==0)) & isstr(rpalg)
    disp('Warning! rpalg is a string: possible error in Matlab5')
  end
  rpalgi=['gw'+0,50,1e-6,0,10,0.1,1e-10]; rpalg=rpalg(:)';
  rpalgi(1:length(rpalg))=rpalg;
  if ~isnan(rpalgi(1)), algtn=setstr(rpalgi(1));
    if strcmp(algtn,'g'), algtype='NG';
    elseif strcmp(algtn,'r'), algtype='NR';
    elseif strcmp(algtn,'l'), algtype='LM';
    elseif strcmp(algtn,'m'), algtype='LMsvd';
    elseif strcmp(algtn,'s'), algtype='svd';
    elseif algtn==0, error('Algorithm type is zoded by zero in rpalg')
    else error(['Invalid algorithm type ',algtn,' in rpalg'])
    end
  end
  if ~isnan(rpalgi(2)), initsn=setstr(rpalgi(2));
    if strcmp(initsn,'l')|strcmp(initsn,'w')|strcmp(initsn,'e')|...
                strcmp(initsn,'s'), initset=initsn;
    elseif strcmp(initsn,'f'), initset=initsn;
    else error(['Invalid initset ',initsn,' in rpalg'])
    end
  end
  if ~isnan(rpalgi(3)), itmax=rpalgi(3)+0; end
  if ~isnan(rpalgi(4)), rcostvar=rpalgi(4)+0; end
  if ~isnan(rpalgi(5)), rparvar=rpalgi(5)+0; end
  if ~isnan(rpalgi(6)), lambdadecr=rpalgi(6)+0; end
  if lambdadecr<0, error('lambdadecr<0'), end
  if ~isnan(rpalgi(7)), lambda0=rpalgi(7)+0; end
  if lambda0<0, error('lambda0 is negative'), end
  if ~isnan(rpalgi(8)), lambdalim=rpalgi(8)+0; end
end
%
if narginelrp<5, rppl=[]; end
if ~isempty(rppl)
  rppli=[1,0,NaN,NaN,NaN,'icca   '+0,1];
  rppl=rppl(:)'; rppli(1:length(rppl))=rppl;
  if ~isnan(rppli(1)), plotdens=rppli(1)+0; end
  if ~isnan(rppli(2)), fmin=rppli(2)+0; end
  if ~isnan(rppli(3)), fmax=rppli(3)+0; end
  if ~isnan(rppli(4)), amin=rppli(4)+0; end
  if ~isnan(rppli(5)), amax=rppli(5)+0; end
  if ~isnan(rppli(6)), plotmode=setstr(rppli(6)); end
  if length(plotmode)==3, plotmode=plotmode(2); end %earlier: lin or log
  if ~isnan(rppli(7))
    calcrnum=setstr(rppli(7));
    if ~strcmp(calcrnum,'c')&~strcmp(calcrnum,'n')
      error('Invalid rppli(7)')
    end
  end
  if ~isnan(rppli(8)), calcrdenom=setstr(rppli(8)); end
  if all(~isnan(rppli(9:12)))
    pzlimit='n';
    if all(rppli(9:12)==('p   '+0)), pzaxis='p';
    elseif all(rppli(9:12)==('a   '+0)), pzaxis='a';
    elseif ~any(diff(rppli(9:12)+0)), pzlimit='y'; pzlimitv=rppl(9)+0;
      pzaxis=[];
    else pzaxis=rppl(9:12)+0;
    end
  end
  if ~isnan(rppli(13)), pzfollown=rppli(13)+0; end
else pzaxis=[];
end
%
if narginelrp<6, initp=[]; end
if ~isempty(initp)
  if (length(initp)==1)&~isstr(initp) %delay value
    delay=initp;
  elseif all(~isnan(initp)) %parameter vector or file name
    initpfile=initp;
    initset='f';
  end
end
if strcmp(initset,'f')&isempty(initpfile)
  error('No starting values are given, though initset=''f'' is defined')
end
%
if narginelrp>=7 %rpfs
  if ~isstr(rpfs), error('rpfs is not a string array'), end
  while ~isempty(rpfs)
    fnam=rpfs(1,:); rpfs(1,:)=[];
    ind=find(fnam==' '); if ~isempty(ind), fnam(ind)=''; end
    [fnam,dummy,ext]=fnamanal(fnam);
    if isempty(ext), error(['No extension in the file name ',fnam,' in rpfs'])
    end
    if strcmp(ext,'rep'), rfile=fnam;
    elseif strcmp(ext,'par')|strcmp(ext,'pbn')|strcmp(ext,'pnt'), pfile=fnam;
    elseif strcmp(ext,'cov')|strcmp(ext,'cbn')|strcmp(ext,'cnt'), cfile=fnam;
    else error(['Invalid file name extension ',ext,' in rpfs'])
    end
  end %while
end
%
if ~isempty(rpfile)
  [rpfile,dummy,ext]=fnamanal(rpfile,'ebn'); clear dummy
  if ~strcmp(ext,'ebn'), error('Extension of rpfile is not .ebn'), end
  clear ext
  clear rppar rppari fixp rpalg rpalgi rppl rppli initp rpfs
  clear nargin nargout narginelrp ind domainn
  if exist(rpfile)==2, eval(['delete ',rpfile]), end
  if exist(rpfile)==2
    error(['Cannot delete existing file ''',rpfile,''''])
  end
  eval(['save ',rpfile])
else %no output file given, listing follows
  fprintf(['ffile=''',ffile,'''','\n']);
  if strcmp(vardef,'f'), fprintf(['vfile=''',vfile,'''','\n']); end
  fprintf(['pfile=''',pfile,'''','\n']);
  fprintf(['cfile=''',cfile,'''','\n']);
  fprintf(['rfile=''',rfile,'''','\n']);
  fprintf(['initpfile=''',initpfile,'''','\n']);
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
end
%%%%%%%%%%%%%%%%%%%%%%%% end of elrpv2f %%%%%%%%%%%%%%%%%%%%%%%%
