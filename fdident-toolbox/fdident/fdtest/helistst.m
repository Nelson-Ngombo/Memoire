%HELISTST Test elis and simfou

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-2001

disp('File helistst')
clf, hold off
testno=0;
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
rand('seed',0), randn('seed',0)
echo on
%Check elis and simfou
echo off
disp('Loading elis...')
if exist('corrtest.m')
  elis('preload');
else
  elis(-1)
end
echo on
%
%First some very simple cases
freqv=[1:10]'; x=ones(size(freqv)); y=x+0.01*randn(size(x));
NaNv=NaN;
%elis with no messages, but final graph...
[pvect,fit]=elis([freqv,x,y],10e-5*[1,1],['s',0,1],[2,0;4,0],...
        [],[1000,NaNv(:,ones(1,12)),'n'+0]);
%elis with no messages finished
graphnumber=grapause('helistst',graphnumber,testsavegraphst);
clf, drawnow
%
%elis with no graphs
y=1./(1+j*freqv)+0.01*randn(size(x));
[pvect,fit]=elis([freqv,x,y],1e-3*[1,1],['z'+0,1,1,20],[2,0;5,0],[NaN,NaN,3],inf);
[pvect,fit]=elis([freqv,x,y],1e-5*[1,1],['s',1,1],[1,0;5,0],[],inf);
if exist('corrtest.m')
  [pvect,fit]=elis([freqv,x,y],1e-5*[1,1],['w',1,1],[1,0;5,0],[NaN,NaN,20],inf);
end
%
%Test of initset options...
fprintf('Press any key to continue ...'), pause
echo off
pvect0=pvect;
for fixpi=[1,2,3], for initset='lawyvsi'
  if fixpi==1, fixp=[3,1;5,0];
  elseif fixpi==2, fixp=[5,0];
  elseif fixpi==3, fixp=[1,0;5,0];
  end
  if initset=='i', initmod=pvect0; else initmod=[]; end
  if (initset~='i')|exist('corrtest.m')
    testno=testno+1;
    fprintf('helistst_no=%.0f\n',testno)
    [pvect,fit]=elis([freqv,x,y],[ones(size(x)),1./abs(y)],['s',1,1],...
        fixp,['g',initset,1]+0,'',initmod);
    graphnumber=grapause('helistst',graphnumber,testsavegraphst);
end
end, end
echo on
%elis with no graph finished
%
[pvect,fit]=elis([freqv,x,y],[0,1],['s',1,1],[2,0;4,0],[],...
        [inf,NaNv(:,ones(1,12)),'nr'+0]);
%
%Let us make now 'proper' fits in different domains.
%
for domain=['spwr']
  num=[1]; denom=[1e-3/2/pi,1];
  no=length(num)-1; nd=length(denom)-1;
  if domain~='p'
    if domain~='r', pdat=exppar(domain,num,denom,0,1);
    else pdat=exppar(domain,num,denom,0,1,[],[],[],[],[],[],[],[],0.01);
    end
  else pdat=exppar('s',num,denom,0);
  end
  freqv=1000*[0.1:0.5:10]'; fl=length(freqv);
  x0=ones(fl,1);
  if any(domain=='sp'), vdat=1e-5*[1,1];
  elseif domain=='w', vdat=1e-6*[1,1];
  end
  [x,y]=simfou(pdat,freqv,x0,vdat);
  Fdat=[freqv,x,y];
  echo off
  disp(['elis with fixed delay, ',domain,'-domain'])
  disp(['[pvect,fit,Cp,CR,cfv]=elis(Fdat,vdat,[domain,no,nd],',...
        '''f'',''rw'',[],[],''helistst.rep'');'])
  fprintf('Press a key to continue...'), pause, disp(' ')
  if exist('corrtest.m')&(domain~='r')
    [pvect,fit]=elis(Fdat,vdat,[domain,no,nd],'f','rw',[],[],'helistst.rep');
    type helistst.rep
    fprintf('Press a key to continue...'), pause, disp(' ')
    graphnumber=grapause('helistst',graphnumber,testsavegraphst);
    [d,nume,denome,delaye]=imppar(pvect);
    if (domain~='p')&(denome(2)~=1)
      nume=nume/denome(2); denome=denome/denome(2);
    end
    if (any(abs(nume-num)>1e-2)|any(abs((denome-denom)./denom)>3e-2))&...
          (domain~='p')
      echo off
      %fprintf(['Warning! \nThe results ',...
      %  'of the first fits unexpectedly differ from the ideal ones:\n'])
      fprintf('Numerator: estimated  ideal\n')
      for i=1:length(num)
        fprintf('    s^%.0f    %.4g    %.4g\n',length(num)-i,nume(i),num(i))
      end
      fprintf('Denominator: estimated  ideal\n')
      for i=1:length(denom)
        fprintf('    s^%.0f    %.4g    %.4g\n',length(denom)-i,denome(i),denom(i))
      end
      error(sprintf(['The results of the first fits unexpectedly differ from ',...
          'the ideal ones\nfor ',domain,'-domain.']))
      fprintf('Press a key to continue...'), pause, disp(' ')
    end
  end
  %
  vdat=[1e-5,1.1e-5,j*1e-5];
  if strcmp(domain,'w'), vdat=vdat/200; end
  [x,y]=simfou(pdat,freqv,x0,vdat);
  Fdat=[freqv,x,y];
  echo off
  %Variable delay...
  disp(['Variable delay for ',domain,'-domain'])
  if exist('corrtest.m')&(domain~='r')
    eliscall=['[pvect,fit,Cp,CR,cfv]=elis(Fdat,vdat,[domain,no,nd],',...
        '''v'',[],[],[],''helistst.rep'');']; disp(eliscall)
    fprintf('Press a key to continue...'), pause, disp(' ')
    eval(eliscall)
    type helistst.rep
    graphnumber=grapause('helistst',graphnumber,testsavegraphst);
    [d,nume,denome,delaye]=imppar(pvect);
    ndnorm=norm([num,denom]);
    ndnorme=norm([nume,denome]);
    num=num/ndnorm*ndnorme; denom=denom/ndnorm*ndnorme;
    difflim=1e-2/ndnorm*ndnorme;
    if (any(abs(nume-num)>difflim)|any(abs((denome-denom)./denom)>3e-2))&...
          (domain~='p')
      echo off
      %fprintf('Warning! The results unexpectedly differ from the ideal ones:\n')
      fprintf('Numerator: estimated  ideal\n')
      for i=1:length(num)
        fprintf('    s^%.0f    %.4g    %.4g\n',length(num)-i,nume(i),num(i))
      end
      fprintf('Denominator: estimated  ideal\n')
      for i=1:length(denom)
        fprintf('    s^%.0f    %.4g    %.4g\n',length(denom)-i,denome(i),denom(i))
      end
      fprintf('(num-nume)./num:\n')
      fprintf('%.4g  ',(num-nume)./num)
      disp(' ')
      fprintf('(denom-denome)./denom:\n')
      fprintf('%.4g  ',(denom-denome)./denom)
      disp(' ')
      error(['The results unexpectedly differ from the ideal ones ',...
          'for variable delay'])
      fprintf('Press a key to continue...'), pause, disp(' ')
    end
  end
end %for domain
delete helistst.rep
%
echo off
domain='s'; fixp='v'; stabm='n'; lines='n'; stl=0;
cyclecount=0;
for domain='szwr'
  for fixp='v0'
    for stabm='nrcl'
%      for lines='ln'
%        for stl=[0,-0.01]
          cyclecount=cyclecount+1;
          if strcmp(domain,'z')&(stl<0.5), stl=stl+1;
          elseif any(domain=='sw')&(stl>=0.5), stl=stl-1;
          end
          num=[1]; denom=real(poly([1,.1+j,.1-j,-2,-2-.1*j,-2+.1*j]));
          no=length(num)-1; nd=length(denom)-1;
          pdat=exppar(domain,num,denom,0,1,[],[],[],[],[],[],[],[],1);
          freqv=[0.1:0.2:10]'; fl=length(freqv);
          vdat=[1e-5,1e-5];
          if strcmp(domain,'z'), freqv=freqv/max(freqv)*.4;
          else freqv=freqv/40; %vdat=vdat/20;
          end
          x0=ones(fl,1);
          [x,y]=simfou(pdat,freqv,x0,vdat);
          Fdat=[freqv,x,y];
          echo off
          elisrf='';
          plotdens=-1000;
          if exist('corrtest.m')
            eliscall=['[pvect,fit]=elis(Fdat,vdat,',...
                  '[domain+0,no,nd,NaN,NaN,NaN,NaN,1,stabm+0,stl+0],fixp,',...
                  '[''gw''+0,2,NaN*ones(1,5),lines+0],',...
                  'plotdens,[],''',elisrf,''');'];
          else
            eliscall=['[pvect,fit]=elis(Fdat,vdat,',...
                  '[domain+0,no,nd],fixp,',...
                  '[''gw''+0,2],',...
                  'plotdens,[],''',elisrf,''');'];
          end
          fprintf(['\nCalling elis in cycle %.0f ...\n'],cyclecount)
          fprintf(['domain=''',domain,'''; fixp=''',fixp,'''; stabmode=''',...
                stabm,'''; lines=''',lines,'''; stl=%.4g;\n'],stl)
          disp(eliscall)
          fprintf('Press a key to continue...'), pause, disp(' ')
          if ~(strcmp(stabm,'c')&~strcmp(domain,'z')&strcmp(fixp,'0')&(stl==0))
            if exist('corrtest.m')&~any(domain=='wr')
              testno=testno+1;
              fprintf('helistst_no=%.0f\n',testno)
              eval(eliscall)
              type(elisrf)
              fprintf('Press a key to continue...'), pause, disp(' ')
              graphnumber=grapause('helistst',graphnumber,testsavegraphst);
              [d,nume,denome,delaye]=imppar(pvect);
              if ~isempty(elisrf), delete(elisrf), end
            end
          else
            disp('This call is skipped to avoid error message')
          end
%        end %for stl
%      end %for lines
    end %for stabm
  end %for fixp
end %for domain
clear eliscall stl fixp domain stabm elisrf
%
if exist('corrtest.m')
  load robotarm
  figure(gcf)
  elis(f,'s',8,12,struct('representation','orthopol','stabilization','r',...
    'forceminimumphase','r','algorithm','lm'));
  elis(f,'s',8,12,struct('representation','orthopol','stabilization','r',...
    'algorithm','lm','delaytreat','v'));
end
%
echo on, clc
%Now let us make a z-domain fit.
%
global elis_max_iteration_number
elis_max_iteration_number_save=elis_max_iteration_number;
elis_max_iteration_number=[];
%
num=[5,5]; denom=[4,3,2,1];
no=length(num)-1; nd=length(denom)-1;
pdat=exppar('z',num,denom,0,1);
freqv=[0.01:0.015:0.4]'; fl=length(freqv);
x0=ones(fl,1);
vdat=[1e-5,1e-5];
[x,y]=simfou(pdat,freqv,x0,vdat);
Fdat=[freqv,x,y];
echo off
rpalg='m'; rppl='';
rpfs=['helistst.par';'helistst.cbn';'helistst.rep'];
disp(['[pvect,fit,Cp]=elis(Fdat,vdat,[''z'',no,nd],[3,4;4,3;6,1]',...
        ',rpalg,rppl,0.9,rpfs);'])
fprintf('Press a key to continue...'), pause, disp(' ')
[pvect,fit,Cp]=elis(Fdat,vdat,['z',no,nd],[3,4;4,3;6,1],...
        rpalg,rppl,0.9,rpfs);
graphnumber=grapause('helistst',graphnumber,testsavegraphst);
type helistst.par
fprintf('Press a key to continue...'), pause, disp(' ')
type helistst.rep
fprintf('Press a key to continue...'), pause, disp(' ')
delete helistst.par, delete helistst.cbn, delete helistst.rep
[d,nume,denome,delaye]=imppar(pvect);
if any(abs((nume-num)./num)>0.05)|any(abs((denome-denom)./denom)>0.05)
  echo off
  fprintf(['Warning! The results unexpectedly differ from the ideal ones',...
        '\n for z-domain:\n'])
  fprintf('Numerator: estimated  ideal\n')
  for i=1:length(num)
    fprintf('    s^%.0f    %.4g    %.4g\n',length(num)-i,nume(i),num(i))
  end
  fprintf('Denominator: estimated  ideal\n')
  for i=1:length(denom)
    fprintf('    s^%.0f    %.4g    %.4g\n',length(denom)-i,denome(i),denom(i))
  end
  fprintf('Press a key to continue...'), pause, disp(' ')
  error('Fatal error in helistst')
end
elis_max_iteration_number=elis_max_iteration_number_save;
%
echo on
%Zero iteration
if ~exist('corrtest.m')
  Fdat='inpchan.fbn';
else
  Fdat='inpchan';
end
elis(Fdat,[],['s',12,12],[],['gl',0]);
%
%Zero iteration, report file
elis(Fdat,[],['s',12,12],[],['gl',0],inf,[],'helistst.rep');
type helistst.rep
fprintf('Press a key to continue...'), pause, disp(' ')
%
%Zero iteration, initial setting from parameter file
if exist('corrtest.m')
  initfile='inpchmod(inpchans)';
else
  initfile='inpchans.pbn';
end
elis(Fdat,[],['s',12,12],[],['gf',0],inf,initfile);
%
%Zero iteration, report file, initial setting from parameter file
if exist('corrtest.m')
  initfile='inpchmod(inpchanz)';
else
  initfile='inpchanz.pbn';
end
elis(Fdat,[],['z'+0,14,14,51200],[],['gf',0],inf,initfile,...
        'helistst.rep');
type helistst.rep
fprintf('Press a key to continue...'), pause, disp(' ')
%
%Equation error method, without iteration and with iteration
if exist('invfreqs')>=2
  elis(Fdat,[],['s',12,12],[],['ge',0],inf,[],'helistst.rep');
  type helistst.rep
  fprintf('Press a key to continue...'), pause, disp(' ')
  elis(Fdat,[],['s',12,12],[],['ge',1],inf,[],'helistst.rep');
  type helistst.rep
  fprintf('Press a key to continue...'), pause, disp(' ')
end
if exist('invfreqz')>=2
  elis(Fdat,[],['z'+0,14,14,51200],[],['ge',0],inf,[],'helistst.rep');
  type helistst.rep
  fprintf('Press a key to continue...'), pause, disp(' ')
  elis(Fdat,[],['z'+0,14,14,51200],[],['ge',1],inf,[],'helistst.rep');
  type helistst.rep
  fprintf('Press a key to continue...'), pause, disp(' ')
end
%
delete helistst.rep
%
%Allpass
load inpchan
mz=elis(tfres,'z',20,20,struct('fs',51200,'allpass','on','delay',-27));
mz=elis(tfres,'z',20,20,struct('fs',51200,'allpass','on','delay',-27,'delaytreat','v'));
ms=elis(tfres,'s',20,20,struct('allpass','on','delay',-27/51200));
%The following example diverges!
ms=elis(tfres,'s',20,20,struct('allpass','on','delay',-27/51200,'delaytreat','v'));%
ms=elis(tfres,'s',20,20,struct('allpass','on','delay',-27/51200,'delaytreat','v',...
  'algorithm','lm','itmax',200));%
clear ms mz inpchan tfres
%
d=load('robotarm.mat'); f=d.f; clear d
m1=elis(f,'s',3,6,struct('coefficients','real','algorithm','lm'));
m2=elis(f,'s',3,6,struct('coefficients','complex','algorithm','lm'));
%
echo off
clear pv0 fit0 Cp0 m1 m2 f
clear Cp CR nume denome pvect fit pdat freqv x y x0 vdat cfv Fdat d delaye
clear num denom fl i nd no ndnorm NaNv graphnumber texth
rand('seed',0), randn('seed',0)
%%%%% End of helistst %%%%%%%
