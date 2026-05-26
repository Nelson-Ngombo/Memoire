function elisqa(rpf,defaults)
%ELISQA Question/answer procedure to generate run parameter file for elis.
%
%       ELISQA(rpf,defaults)
%
%       Input arguments:
%       rpf = name of the mat-file of the run parameters to be generated
%               default extension: .ebn
%       defaults = name of the mat-file of the default run parameters
%
%       Usage: elisqa(rpf,defaults);
%       Example: elisqa('elisqtst.ebn');
%
%       See also: ELIS, ELRPF2V, ELRPV2F.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 30-Apr-1999

neglvali=realmin;
if nargin==0, rpf=''; end %no run parameter file is given
if isempty(rpf), rpf='elisrpar.ebn'; end
lrpf=length(rpf);
[rpf,rparname]=fnamanal(rpf,'ebn');
if length(rpf)>lrpf
  disp(['Warning! Run parameter file name has been extended to ',rpf,...
        ' in elisqa'])
end
clear lrpf
%
%define "universal" default values
ffile=''; %name of Fourier file (maybe without extension)
vfile=''; %name of variance file (maybe without extension)
pfile=''; %parameter file to be generated (maybe empty)
cfile=''; %covariance file to be generated
rfile=''; %report file to be generated
initpfile=''; %name of parameter file, containing the initial
                 %values (maybe without extension)
algtype='NG'; %type of the iteration algorithm (NG,LM,LMsvd,NR,svd)
calcrnum='c'; %calculate roots of numerator (c,n)
calcrdenom='c'; %calculate roots of denominator (c,n)
delay=0; %(initial) value of the delay
delaytreat='f'; %delay fix (f) or variable (v)
denomord=2; %order of the denominator
denomfix=[]; %fix denominator coeffs (set later according to paramtreat)
denomfixind=[]; %fix denominator coeff indices (set later)
domain='s'; %domain of the model to be fitted (s,z)
expi=1; %number of the experiment to be used
fmin=0; %minimal displayed frequency
fmax=NaN; %maximal displayed frequency
fpfile='p.fix'; %file of fixed parameters (optional)
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
plotdens=1; %cycles of iteration to plot (1,2...inf, negative for no 0th plot)
plotmode='i'; %frequency axis, lin or log
pzfollown=1; %pole/zero sets to be plotted on same plot
pzlimit='y'; %limit p/z on plot to pzlimitv*2*pi*fmax (s) or 2 (z) (n,y)
pzlimitv=10;
rcostvar=1e-6; %minimal relative variation of the cost function
rparvar=0; %minimal relative variation of parameters
vardef='u'; %variance values: numbers or from file (u,f)
varx=1; %uniform variance value of the input coefficients
vary=1; %uniform variance value of the output coefficients
loadf=0;
freqtrue=[];
if nargin>=2 %defaults given
  defaults=fnamanal(defaults,'ebn');
  eval(['load ',defaults,' -mat']), loadf=1;
  loadfn=defaults;
  clear defaults
else %nargin<2, defaults not given
  if nargin==1
    if exist(rpf)==2
      eval(['load ',rpf,' -mat']), loadf=1;
    end
  loadfn=rpf;
  end
end
if ~exist('elisqadate'), elisqadate=''; end
if ~isempty(elisqadate)
  disp(['Date of loaded run parameter file ''',loadfn,''': ',elisqadate])
end
clear loadfn
if exist('lambdadlim')==1 %Correction for late change of notation
  lambdadecr=lambdadlim; clear lambdadlim
end
if length(plotmode)==3, plotmode=plotmode(2); end %Correction for old files
if exist('Ffile'), ffile=Ffile; clear Ffile, end %ffile remains
%
%clear eventually existing global variables:
if exist('expimpmessages')==1, clear expimpmessages, end
%
if exist(rpf)==2, rpfexist=1; eval(['delete ',rpf]), else rpfexist=0; end
if exist(rpf)==2, error(['Cannot delete old ',rpf,' file']), end
%restore old file for the case when error occurs in elisqa:
if rpfexist==1
  clear rpfexist; rpfsave=rpf; clear rpf; eval(['save ',rpfsave]), rpf=rpfsave;
end
clear rpfexist
%---------------------------------------------
%File of measurement data
ffile=yesinput(['Fourier file (- for no file)'],ffile);
if strcmp(ffile,'-')
  ffile='';
elseif ~isempty(ffile)
  [ffile,ffn]=fnamanal(ffile,'fbn');
  if exist(ffile)~=2
    disp('WARNING: Fourier file does not exist'), expi=1;
  else
    [freqtrue,x,y,n]=impfou(ffile,[]); clear x y
    if n>1
     expi=yesinput(sprintf('Which one of the %.0f experiments in file',n),...
         1,[1,n]);
    else
      expi=1;
    end
  end
end %ffile=='-'
%
clear n
%---------------------------------------------
fprintf('\n Give variances uniformly (u) or read from file (f)?')
vardef=yesinput(['Your choice'],vardef,['u|f']);
if vardef=='f',
  vfile=yesinput('variance file (- for no file)',vfile);
  if strcmp(vfile,'-')
    vfile='';
  else
    vfile=fnamanal(vfile,'vbn');
    if exist(vfile)~=2
      disp('WARNING: Variance file does not exist')
    else
      if exist(ffile)==2
        [varx,vary]=impvar(vfile);
        if length(varx)~=length(freqtrue),
          error('Variance file is inconsistent with Fourier file')
        end
        clear varx, clear vary
      end
    end
  end %vfile=='-'
else
  if exist('varx')==1, varx=varx(1); vary=vary(1); else varx=1; vary=1; end
  varx=yesinput(['Variance of the input values'],varx);
  vary=yesinput(['Variance of the output values'],vary);
end
%---------------------------------------------
%definition of the domain
domain=yesinput(['Domain'],domain,['z|s']);
if domain=='z'
  if ~isfinite(fs), fs=1; end
  if exist(ffile)==2
    fprintf('\n Maximum frequency in the Fourier data: %.5g Hz',max(freqtrue))
    fs=yesinput('Sampling frequency in Hz',max(fs,max(freqtrue)),...
         [max(freqtrue)*2*(1-eps),inf]);
  else
    fs=yesinput('Sampling frequency in Hz',fs,[neglvali,inf]);
  end
  if loadf==0 %no predefined value
    fmax=0.5*fs; %upper limit of displayed frequency range
  end
else %domain=='s'
  if isequal(exist(ffile),2)
    fprintf('\n Suggested scaling angular frequency: %.3g rad*Hz',...
                (max(freqtrue)+min(freqtrue))/2*2*pi);
  end
  fprintf('\n Scaling angular frequency for internal calculations in rad*Hz');
  fs=yesinput('Type  inf or nan  for automatic scaling',fs,[neglvali,inf]);
  if exist(ffile)&isfinite(fs)
    fprintf('   Maximum of scaled angular frequencies: %.3g\n',...
        max(freqtrue/fs)*2*pi)
    fmax=1.05*max(freqtrue);
  else %Fourier data not available
    fmax=NaN;
  end
end
%---------------------------------------------
%order of the numerator and denominator
numordo=numord;
denomordo=denomord;
numord=yesinput(['Order of the numerator'],numord);
if numord~=numordo, %numord has been changed
  numfixind=[]; numfix=[];
end
denomord=yesinput(['Order of the denominator'],denomord);
if denomord~=denomordo, %denomord has been changed
  denomfixind=[]; denomfix=[];
end
clear numordo, clear denomordo
if length([numfixind,denomfixind])==0,
  paramtreat='n'; %no fix parameter remained
end
%------------
%Read fix parameters
if strcmp(paramtreat,'f'), paramtreat='0'; end %new notation
chfixparam='r';
while chfixparam=='r'
 if paramtreat=='n',
  fprintf(['\n No fixed parameters chosen'])
  numfixind=[]; numfix=[];
  denomfixind=[]; denomfix=[];
 elseif paramtreat=='0'
  fprintf(['\n One parameter fixed:\n     coefficient of ',...
            domain,'^0 in the denominator is set to 1.0'])
  numfixind=[]; numfix=[];
  denomfixind=[0]; denomfix=[1.0];
  if domain=='s',
    denomfixind=denomord-denomfixind;
  end
 else %some parameters fixed
  fprintf('\nFixed parameters:')
  if domain=='z',
    fprintf(['\n (Coefficients from 0 to order, in ascending ',...
         'powers of z^-1)\n'])
  else %s-domain
    fprintf(['\n (Coefficients from 0 to order, in descending ',...
         'powers of s)\n'])
  end
  fprintf(['   Numerator (order=',int2str(numord),'):\n'])
  for k=1:length(numfixind)
    if domain=='s',
      k=length(numfixind)+1-k;
      fprintf('      s^%.0f:  b(%.0f)=%5.3e\n',...
               numord-numfixind(k),numord-numfixind(k),numfix(k))
    else %domain='z'
      fprintf('      z^(-%.0f):  b(%.0f)=%5.3e\n',...
               numfixind(k),numfixind(k),numfix(k))
    end
  end %for k
  fprintf(['   Denominator (order=',int2str(denomord),'):\n'])
  if strcmp(paramtreat,'d')|strcmp(paramtreat,'r')
    for k=1:length(denomfixind)
      if domain=='s',
        k=length(denomfixind)+1-k;
        fprintf('      s^%.0f:  a(%.0f)=%5.3e\n',...
               denomord-denomfixind(k),denomord-denomfixind(k),denomfix(k))
      else %domain='z'
        fprintf('      z^(-%.0f):  a(%.0f)=%5.3e\n',...
                 denomfixind(k),denomfixind(k),denomfix(k))
      end
    end %for k
  else %allpass
    fprintf('      Allpass: reverse of numerator\n')
  end
 end  %paramtreat
 fprintf('\n Let this untouched (u) or redefine set (r)?')
 chfixparam=yesinput('Your choice','u',['u|r']);
 if chfixparam=='r',
  fprintf(['\n Fix no parameters (n)',...
          '\n   or fix coefficient of ',domain,'^0 in denominator (0)',...
          '\n   or define fixed parameters (d)',...
          '\n   or read fixed parameters from file (r)',...
          '\n   or design an allpass filter (a)'])
  paramtreat=yesinput('Your choice',paramtreat,['n|0|d|r|a']);
  if (paramtreat=='d')|(paramtreat=='a'),
    if domain=='z', domainstr='z^-1'; else domainstr='s'; end
    numfixind=[]; numfix=[];
    fixparam='y';
    if paramtreat=='a' %allpass
      fprintf(['\n Allpass filter design:',...
               ' you may (but need not) fix now numerator coefficients'])
    end
    while (fixparam~='n')&(length(numfixind)<numord+1),
      fixparam=input(['Power of ',domainstr,' in the numerator',...
          ' (terminate with <cr>): '],'s');
      if isempty(fixparam) %no fixed numerator coefficient
        if (paramtreat=='a')&isempty(numfixind), numfixind=[]; numfix=[]; end
        break
      end
      eval(['sorder=',fixparam,';'])
      if (sorder>=0)&(sorder<=numord)&isempty(find(numfixind==sorder)),
        numfixind=[numfixind,sorder];
        while length(numfixind)~=length(numfix)
          numfix=[numfix,input(['The value of the coefficient: '])];
          if length(numfixind)~=length(numfix)
            fprintf('   Type once more!\n')
          end
        end
      else
        disp('Warning! Power not allowed')
      end
    end %while
    fprintf('\n')
    %
    denomfixind=[];
    denomfix=[];
    if paramtreat=='d'
      fixparam='y';
      while (fixparam~='n')&(length(denomfixind)<denomord+1),
        fixparam=input(['Power of ',domainstr,' in the denominator',...
             ' (terminate with <cr>): '],'s');
        if isempty(fixparam), break, end
        eval(['sorder=',fixparam,';'])
        if (sorder>=0)&(sorder<=denomord)&isempty(find(denomfixind==sorder)),
          denomfixind=[denomfixind,sorder];
          while length(denomfixind)~=length(denomfix)
            denomfix=[denomfix,input(['The value of the coefficient: '])];
            if length(denomfixind)~=length(denomfix)
              fprintf('   Type once more!\n')
            end
          end
        else
          disp('Warning! Power not allowed')
        end
      end %while
    end %paramtreat=='d'
  elseif strcmp(paramtreat,'0')
    if domain=='z', denomfixind=[0]; else denomfixind=[denomord]; end
    denomfix=[1.0];
    numfixind=[]; numfix=[];
  elseif strcmp(paramtreat,'n')
    denomfixind=[]; denomfix=[1.0];
    numfixind=[]; numfix=[];
  elseif strcmp(paramtreat,'r') %read from file
    fpfile=yesinput('File with fixed parameters',fpfile);
    fparr=loadasc(fpfile,'flat');
    if min(size(fparr))==1
      fparr=[fparr(1:2:length(fparr)),fparr(2:2:length(fparr))];
    end
    ind=find(fparr(:,1)<=numord+1);
    numfixind=fparr(ind,1)-1; numfix=fparr(ind,2);
    if ~isempty(ind), fparr(ind,:)=[]; end
    ind=find(fparr(:,1)<=numord+denomord+2);
    denomfixind=fparr(ind,1)-numord-2; denomfix=fparr(ind,2);
    if ~isempty(ind), fparr(ind,:)=[]; end
    if ~isempty(fparr), delaytreat='f'; delay=fparr(1,2); end
    clear fparr, clear ind
  end
  if strcmp(domain,'s')&~strcmp(paramtreat,'r'),
    numfixind=numord-numfixind;
    denomfixind=denomord-denomfixind;
  end
 end %chfixparam=='r'
end %while chfixparam=='r'
%
calcrnum=yesinput('Calculate roots of numerator: c=calculate, n=no',...
       calcrnum,['c|n']);
calcrdenom=yesinput('Calculate roots of denominator: c=calculate, n=no',...
       calcrdenom,['c|n']);
%---------------------------------------------
fprintf('\n Fix the delay (f) of let it be a variable (v)?')
delaytreat=yesinput('Your choice',delaytreat,['f|v']);
if domain=='s', dtxt='seconds'; else dtxt='terms of 1/fs'; end
if delaytreat=='f',
  delay=yesinput(['Fixed value of the delay, in ',dtxt],delay);
else
  delay=yesinput(['Starting value of the delay, in ',dtxt],delay);
  algtype='LM'; %Levenberg-Marquardt is suggested for variable delay
end
%---------------------------------------------
%algorithm selection
if paramtreat~='n'
  fprintf('\n Possible types of the iteration algorithm:\n')
  fprintf('   Newton-Gauss (NG or ng)\n')
  fprintf('   Newton-Raphson (NR or nr, not yet implemented)\n')
  fprintf('   Levenberg-Marquardt (LM or lm)\n')
end
fprintf('   Levenberg-Marquardt with svd (LMsvd or lmsvd)\n')
fprintf('   singular value decomposition (svd)')
if strcmp(algtype,'ng'), algtype='NG'; end
if strcmp(algtype,'nr'), algtype='NR'; end
if strcmp(algtype,'lm'), algtype='LM'; end
if strcmp(algtype,'lmsvd'), algtype='LMsvd'; end
%
if paramtreat=='n'
  if strcmp(algtype,'NG')|strcmp(algtype,'NR')|strcmp(algtype,'LM')
    algtype='svd';
  end
  algtype=yesinput(['Your choice'],algtype,...
        'LMsvd|lmsvd|svd');
else %fixed parameters
  algtype=yesinput(['Your choice'],algtype,...
        'NG|ng|NR|nr|LM|lm|LMsvd|lmsvd|svd');
end
if strcmp(algtype,'ng'), algtype='NG'; end
if strcmp(algtype,'nr'), algtype='NR'; end
if strcmp(algtype,'lm'), algtype='LM'; end
if strcmp(algtype,'lmsvd'), algtype='LMsvd'; end
%
if strcmp(algtype,'LM')|strcmp(algtype,'LMsvd')
  %initial value of Levenberg-Marquardt parameter
  lambda0=yesinput('Initial value of lambda',lambda0,[0,inf]);
  lambdadecr=yesinput('Try lambda=0 after consecutive decreases of number',...
        lambdadecr,[1,inf]);
end
%---------------------------------------------
%How to set the initial values?
fprintf('\n Way of setting the initial values:\n')
if paramtreat~='n'
  fprintf('   l=linear least squares,\n')
  fprintf('   w=weighted LS (by variance of ym),\n')
end
fprintf('   s=weighted LS, singular value decomposition\n')
fprintf('   f=file, e=equation error method)');
if paramtreat=='n'
  if (initset=='w')|(initset=='l'), initset='s'; end
  initset=yesinput(['Your choice'],initset,['s|f|e']);
else
  initset=yesinput(['Your choice'],initset,['l|w|s|f|e']);
end
%
%Parameter file name (and type, if applicable)
if initset=='f'
  initpfile=yesinput('Initial parameter file',initpfile);
  initpfile=fnamanal(initpfile,'pbn');
  if exist(initpfile)~=2
    disp('WARNING! Parameter file does not exist')
  else
    disp(['Parameters as initial values will be read from file ',initpfile])
    [domainf,num,denom,delayf,fsf]=imppar(initpfile);
    if domainf~=domain,
      disp(['WARNING! Domain of file is ''',domainf,''', not ''',domain,''''])
    end
    if (length(num)~=(numord+1))|(length(denom)~=(denomord+1)),
      disp('WARNING! Parameter file inconsistent with given orders')
    end
    if abs(delayf-delay)>1e-4*abs(delay)
      if domain=='z', dtxt=[num2str(delayf),' samples'];
      else dtxt=[num2str(delayf),' s'];
      end
      error(['WARNING! Delay in parameter file is ',dtxt])
    end
    if (domain=='z')&(fs~=fsf)
      disp(sprintf(['WARNING! Sampling frequency in file, %.5e, ',...
          'differs from %.5e'],fsf,fs))
    end
    clear domainf, clear num, clear denom, clear delayf, clear fsf
  end
end
%---------------------------------------------
%display informations
plotdens=yesinput('Density of plotted iterations',plotdens);
if isfinite(plotdens)
  %if domain=='s'
    if length(plotmode)==3, plotmode=plotmode(2); end
    plotmode=yesinput('Frequency axis lin or log, i/o',plotmode,'i|o');
    if ~isempty(freqtrue)
      fprintf(['\n freqmin = %.4g Hz in the frequency vector'],min(freqtrue))
    end
    if strcmp(plotmode,'i'), fminmin=0; else fminmin=neglvali; end
    fmin=yesinput(sprintf(['Lower limit of the displayed frequency band in',...
       ' Hz,\n   type  nan  for just the minimum of the frequency vector']),...
       fmin,[fminmin,inf]); clear fminmin
    if (min(freqtrue)<fmin)&isfinite(fmin)
      disp(['freqmin=',num2str(min(freqtrue)),...
          ' is smaller than the displayed minimal frequency: ',num2str(fmin)])
    end
    if ~isempty(freqtrue)
      fprintf(['\n freqmax = %.4g Hz in the frequency vector'],max(freqtrue))
    end
    if domain=='z'
      fprintf('   Half of the sampling frequency: %.4g Hz\n',fs)
    end
    fmax=yesinput(sprintf(['Upper limit of the displayed frequency band in',...
       ' Hz,\n   type  inf or nan  for just the maximum of the frequency ',...
        'vector']),...
       fmax,[fmin+eps,inf]);
    if (max(freqtrue)>fmax)&isfinite(fmax) %1>NaN in 386-Matlab V3.5
      disp(['freqmax=',num2str(max(freqtrue)),...
          ' exceeds the displayed maximal frequency: ',num2str(fmax)])
    end
  %end
  if (calcrnum=='c')|(calcrdenom=='c')
    pzlimit=yesinput('Limit maximum magnitude of displayed poles/zeros',...
         pzlimit,'y|n');
    if strcmp(domain,'s')&strcmp(pzlimit,'y')
      pzlimitv=yesinput('Value of pzlimitv in pzlimitv*2*pi*max(freqv)',...
                pzlimitv,[1,inf]);
    end
    pzfollown=yesinput(['Number of pole/zero sets to be',...
         ' displayed simultaneously'],pzfollown,[1,10]);
  end
end
%---------------------------------------------
%Stop criteria
fprintf('\n')
itmax=yesinput(['Max. no. of iteration cycles'],itmax);
if itmax>0
  rcostvar=yesinput(['Stop if relative change of cost function is',...
        ' smaller than'],rcostvar,[0,inf]);
  if isnan(rcostvar), rcostvar=0; end
  if (rcostvar<100*eps)&(rcostvar~=0),
    fprintf([' Warning! relvar=%.3e<%.3e=100*eps is close to ',...
                'roundoff errors\n'],rcostvar,100*eps)
    disp(' This stop criterion will probably be ineffective')
  elseif rcostvar==0
    disp(' This stop criterion will be ineffective')
  end
  rparvar=yesinput(['Stop if maximum relative change of parameters',...
        ' is smaller than'],rparvar,[0,inf]);
  if isnan(rparvar), rparvar=0; end
  if (rparvar<100*eps)&(rparvar~=0),
    fprintf(' Warning! rparvar<%.2e=100*eps is close to roundoff errors\n',...
        100*eps)
    disp(' This stop criterion will probably be ineffective')
  elseif rparvar==0
    disp(' This stop criterion will be ineffective')
  end
  if strcmp(algtype,'LM')|strcmp(algtype,'LMsvd')
    lambdalim=yesinput('Maximum value of lambda which allows stopping',...
        lambdalim,[neglvali,inf]);
  end
end
%---------------------------------------------
%Savings
%
fprintf('\n Parameter file name')
if ~isempty(pfile), fprintf(' (- for no saving to parameter file)'), end
if isempty(pfile), ytxt='No parameter file'; else ytxt=pfile; end
pfile=yesinput('  ',ytxt); clear ytxt
if strcmp(pfile,'No parameter file'), pfile=''; end
if strcmp(pfile,'-'), pfile=''; cfile='';
elseif ~isempty(pfile)
  [pfile,pnam]=fnamanal(pfile,'pbn');
  if ~isempty(cfile), cfile=fnamanal(pnam,'cbn'); end
  clear pnam
end
%
if itmax>0
  fprintf('\n Covariance file name')
  if ~isempty(cfile), fprintf(' (- for no saving to covariance file)'), end
  if isempty(cfile), ytxt='No covariance file'; else ytxt=cfile; end
  cfile=yesinput('  ',ytxt); clear ytxt
  if strcmp(cfile,'No covariance file'), cfile=''; end
  if strcmp(cfile,'-'), cfile='';
  elseif ~isempty(cfile), cfile=fnamanal(cfile,'cbn');
  end
else
  cfile='';
  fprintf('\n Covariances cannot be calculated if itmax=0\n')
end
%
rfiletmp=fnamanal(rparname,'rep'); %same as ebn file
fprintf(['\n Report file name, type  =  for ',rfiletmp])
if ~isempty(rfile)
  fprintf(',')
  rfile=yesinput(' -   for no saving to report file',rfile);
else
  rfile=yesinput('    ','No report file');
  if strcmp(rfile,'No report file'), rfile=''; end
end
if strcmp(rfile,'-'), rfile='';
elseif strcmp(rfile,'='), rfile=rfiletmp;
end
if ~isempty(rfile), rfile=fnamanal(rfile,'rep'); end
%---------------------------------------------
clear freqtrue, clear k, clear ffn, clear chfixparam
clear dtxt, clear rparname, clear rfiletmp
clear nargin, clear nargout, clear ans
clear loadf
fprintf(['\nelisqa is saving run parameters to file ',rpf,' ...\n'])
rpfsave=rpf; clear rpf
%
rpfversion=2.0; %version of run parameter file
elisqadate=date; elisqacomputer=computer;
if exist('yesinpacceptdef')==1
  yiadvaluetmpstore=yesinpacceptdef;
  clear yesinpacceptdef
  if exist('yesinpacceptdef')==1
    disp('WARNING! Global variable yesinpacceptdef could not be cleared.')
    disp(['This variable has been saved with value '''' to the file ',rpfsave])
  end
  if strcmp(yiadvaluetmpstore,'yes')
    clear yiadvaluetmpstore
    eval(['save ',rpfsave])
    yesinpacceptdef='yes';
  else
    clear yiadvaluetmpstore
    eval(['save ',rpfsave])
    yesinpacceptdef='';
  end
else
  eval(['save ',rpfsave])
end
%%%%%%%%%%%%%%%%%%%%%%%% end of elisqa %%%%%%%%%%%%%%%%%%%%%%%%
