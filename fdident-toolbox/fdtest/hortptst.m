%HORTPTST Test elis with orthopol

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
echo on
NaNv=NaN;
%
%First step: test generation of orthopol and orthogonality
ord=4;
for domain='sz';
  freqv=[1:5]'/10;
  w=([11:15]');
  %w=ones(5,1);
  [pvalarr,Z]=fdident('private','orthopol',ord,domain,freqv,w);
  pvalarrm=pvalarr.*kron(ones(1,size(pvalarr,2)),w);
  scp=2*real(pvalarrm'*pvalarrm); %This should be identity
  if any(any(abs(scp-eye(ord+1))>ord*100*eps)),
    error(['Orthopol base generation error in ',domain,'-domain'])
  end
end%
echo on
%Now orthopol solutions for a very simple system for testing purposes
for domain='qp'
  i=0;
  for cycno=[0,1,10]
    for startv='Lpb' %LS, parameter vector, basis in vector
      i=i+1;
      %global saveorthopoldata
      %saveorthopoldata='yes'; %save internal data to file orthpdat.mat
      num=real(poly(-0.3)); denom=real(poly(-0.2+0.5*[-j,j]));
      if i==1, numsave=num; denomsave=denom; end
      %simulate noise-free data
      if domain=='p'
        freq=[0.1:0.8:5]'; F=length(freq);
        [x,y]=simfou(exppar('s',num,denom),freq,[],[0,0]);
      else
        freq=[0.1:0.2:1]'; F=length(freq); fs=4;
        [x,y]=simfou(exppar('z',num,denom,0,fs),freq,[],[0,0]);
      end
      fsi=NaN;
      cycno=yesinput('Iterations to perform before save, [0,n]',cycno,[0,100]);
      startv=yesinput('Start from LS equation or params or basis, L/b/p',...
        startv,'l|L|p|P|b|B');
      if lower(startv)=='l',     initv='';  initobj='';    initset='s'; basistreat='n';
      elseif lower(startv)=='p', initv=pvl; initobj=pvobj; initset='f'; basistreat='f';
      elseif lower(startv)=='b', initv=pvl; initobj=pvobj; initset='s'; basistreat='f';
      end
      if cycno==0, fname='orthpd0.mat'; else fname='orthpdn.mat'; end
      if exist(fname), delete(fname), end
      if exist(fname), error(['File ',fname,' exist, and cannot be deleted']), end
      NaNv=NaN; NaNv6=NaNv(:,ones(1,6)); NaNv13=NaNv(:,ones(1,13));
      vdat=[0,eps];
      if domain=='p'
        [pvect,fit]=elis([freq,x,y],vdat/2,['p'+0,1,2,fsi],...
          'f',['s'+0,initset+0,cycno,NaNv6,basistreat+0],[NaNv13,'n'+0],initv);
        if lower(startv)=='l', pvl=pvect; end
        pvectobj=fidmodel(pvect); Fdat=fiddata(y,x,freq); Fdat.SiSoVariance=vdat;
        if basistreat=='f', newbasis='off'; else newbasis='on'; end
        if initset=='f', initsetn='o'; else initsetn=initset; end
        [pvectnew,fitnew]=elis(Fdat,'s',1,2,...
          struct('representation','orthopol','delaytreat','fixed',...
          'algorithm','svd','initset',initsetn,'itmax',cycno,'initmodel',initobj),...
          struct('newbasis',newbasis));
        if lower(startv)=='l', pvobj=pvectobj; end
      else %'q'
        [pvect,fit]=elis([freq,x,y],vdat/2,['q'+0,1,2,fs],...
          'f',['s'+0,initset+0,cycno,NaNv6,basistreat+0],[NaNv13,'n'+0],initv);
        if lower(startv)=='l', pvl=pvect; end
        pvectobj=fidmodel(pvect); Fdat=fiddata(y,x,freq); Fdat.SiSoVariance=vdat;
        if basistreat=='f', newbasis='off'; else newbasis='on'; end
        if initset=='f', initsetn='o'; else initsetn=initset; end
        [pvectnew,fitnew]=elis(Fdat,'z',1,2,...
          struct('fs',fs,'representation','orthopol','delaytreat','fixed',...
          'algorithm','svd','initset',initsetn,'itmax',cycno,'initmodel',initobj),...
          struct('newbasis',newbasis));
        if lower(startv)=='l', pvobj=pvectnew; end
      end
      %
      convfit=fdident('private','elisnewfit',fit);
      convfit.runtime=[]; pvectnew.fitinfo.runtime=[];
      pvectnew.fitinfo=rmfield(pvectnew.fitinfo,'cf05'); %quick fix
      if ~isequal(pvectobj.num,pvectnew.num)|...
          ~isequal(pvectobj.Znum,pvectnew.Znum)|...
          ~isequal(pvectobj.denom,pvectnew.denom)|...
          ~isequal(pvectobj.Zdenom,pvectnew.Zdenom)
        error('Different old and new results')
      elseif ~isempty(fitinfodiff(convfit,pvectnew.fitinfo))
        fitinfodiff(convfit,pvectnew.fitinfo);
        error('fitinfo is different')
      end
      %Check basis
      disp('Check pcoeffvar ...')
      [domainc,numc,denomc,delayc,fsc,Znumc,Zdenomc]=imppar(pvect);
      %numerator
      [v,Znum]=fdident('private','orthopol',1,domain,freq/fsc,ones(size(freq)));
      if ~isequal(Znum,Znumc), error('orthogonal basis is not reproduced'), end
      [Nf,pcoeffvarn,numval]=fdident('private','orthpval',numc,Znum,freq/fsc,fsc,domainc);
      %denominator
      [v,Zdenom]=fdident('private','orthopol',2,domain,freq/fsc,y);
      if ~isequal(Zdenom,Zdenomc), error('orthogonal basis is not reproduced'), end
      [Df,pcoeffvard,denomval]=fdident('private','orthpval',denomc,Zdenom,freq/fsc,fsc,domainc);
      if any(abs(y./x-Nf./Df>1e3*eps))
        error('value of tf is wrong')
      end
      %
      numnew=numc*pcoeffvarn; 
      if domain=='p'
        fsv=fsc.^[length(num)-1:-1:0]; numnew=numnew./fsv;
      end
      denomnew=denomc*pcoeffvard;
      if domain=='p'
        fsv=fsc.^[length(denom)-1:-1:0]; denomnew=denomnew./fsv;
      end
      if ~isequal(numval,numnew)|~isequal(denomval,denomnew)
        error('orthpval error?')
      end
      if domain=='p', nnorm=numnew(1); else nnorm=numnew(1); end
      denomnew=denomnew/nnorm; numnew=numnew/nnorm;
      if cycno>=0
        if isempty(pcoeffvarn)|any(abs(numnew-numsave)>1000*eps)
          numnew, numsave
          denomnew, denomsave
          plot(freq,abs(tfcalc(exppar('s',numnew,denomnew),freq)),freq,abs(y./x),'+'), shg
          error(['num is not restored for ',domain,'-domain'])
        end
        if isempty(pcoeffvard)|...
            any(abs(denomnew-denomsave)>1000*eps)
          denomnew, denomsave
          plot(freq,abs(tfcalc(exppar('s',numnew,denomnew),freq)),freq,abs(y./x),'+'), shg
          error(['denom is not restored for ',domain,'-domain'])
        end
      end
      disp(' ')
      %
      fprintf(['\nFile name: ',fname,', cycle: %.0f\n'],cycno), clear fname
      fprintf(['startv = ''',startv,''', '])
      condJ=fit(14);
      if ~isnan(condJ), fprintf('condJ = %.8g, ',condJ)
      else fprintf('condJ = NaN, ')
      end
      fs=fit(16);
      fprintf('fsint = %.4g, costf = %.3g\n',fs,fit(1))
      if ~isempty(initv)&(initset=='f')
        disp('Starting values read from previous data')
      end
      if basistreat=='n'
        disp('Orthonormal basis generated for LS equation')
      elseif basistreat=='f'
        disp('Orthonormal basis generated from previous data')
      else
        error('Illegal basistreat')
      end
      if (cycno==0)&(initset~='f'), disp('LS equation solved'), end
      disp(' ')
      fprintf('Press a key to continue, or Ctrl/c to stop ...'), pause, disp(' ')
    end %for startv
  end %for cycno 
end %for domain
clear Nf pcoeffvarn Df pcoeffvard numsave denomsave
clear initv cycno startv pvect fit pvl initset vdat i
%clear global saveorthopoldata
%
echo on
rppl=[inf,NaNv(:,ones(1,12)),'n'+0];
%Classical elis fit, zero iteration:
[pv0s,fit0s]=elis('inpchan','',['s',12,12],'',['ss'+0,0],rppl);
fprintf('Condition number: %.3g\n',fit0s(13)), shg, pause
[pv0z,fit0z]=elis('inpchan','',['z'+0,14,14,51200],'',['ss'+0,0],rppl);
fprintf('Condition number: %.3g\n',fit0z(13)), shg, pause
%
%Orthopol with zero iteration, LS setting
[pv0p,fit0p]=elis('inpchan',[],['p',11,12],[],['ss'+0,0],rppl);
fprintf('Condition number: %.3g\n',fit0p(13)), shg, pause
[pv0q,fit0q]=elis('inpchan',[],['q'+0,14,14,51200],[],['ss'+0,0],rppl);
fprintf('Condition number: %.3g\n',fit0q(13)), shg, pause
%
%Orthopol with one iteration, LS setting
[pv1p,fit1p]=elis('inpchan',[],['p',11,12],[],['ss'+0,1],rppl);
fprintf('Condition number: %.3g\n',fit1p(13)), shg, pause
[pv1q,fit1q]=elis('inpchan',[],['q'+0,14,14,51200],[],['ss'+0,1],rppl);
fprintf('Condition number: %.3g\n',fit1q(13)), shg, pause
%
%Classical elis fit:
[pvs,fits]=elis('inpchan','',['s',12,12],'','ss',rppl);
fprintf('Condition number: %.3g\n',fits(13)), shg, pause
[pvz,fitz]=elis('inpchan','',['z'+0,14,14,51200],'','ss',rppl);
fprintf('Condition number: %.3g\n',fitz(13)), shg, pause
%
%Orthopol with all the iterations, LS setting
[pvp,fitp]=elis('inpchan',[],['p',11,12],[],'ss',rppl);
fprintf('Condition number: %.3g\n',fitp(13)), shg, pause
[pvq,fitp]=elis('inpchan',[],['q'+0,14,14,51200],[],'ss',rppl);
fprintf('Condition number: %.3g\n',fitp(13)), shg, pause
%
%Orthopol with starting values from earlier elis
[pvso,fitso]=elis('inpchan',[],['p',11,12],[],['s'+0,NaNv(ones(1,8)),'n'+0],rppl,pvs);
fprintf('Condition number: %.3g\n',fitso(13)), shg, pause
[pvzo,fitzo]=elis('inpchan',[],['q'+0,14,14,51200],[],['s'+0,NaNv(ones(1,8)),'n'+0],rppl,pvz);
fprintf('Condition number: %.3g\n',fitzo(13)), shg, pause
%
%Orthopol with starting values and basis from earlier orthopol
[pvrs,fitrs]=elis('inpchan',[],['p',11,12],[],'s',rppl,pvp);
fprintf('Condition number: %.3g\n',fitrs(13)), shg, pause
[pvrz,fitrz]=elis('inpchan',[],['q'+0,14,14,51200],[],'s',rppl,pvq);
fprintf('Condition number: %.3g\n',fitrz(13)), shg, pause
%
%Orthopol with previous basis (take over basis only, LS setting)
NaNv8=NaNv(:,ones(1,8));
[pvpf,fitf]=elis('inpchan',[],['p',11,12],'',['s'+0,NaNv8,'f'+0],rppl,pvrs);
fprintf('Condition number: %.3g\n',fitf(13)), shg, pause
[pvqf,fitf]=elis('inpchan',[],['q'+0,14,14,51200],'',['s'+0,NaNv8,'f'+0],rppl,pvrz);
fprintf('Condition number: %.3g\n',fitf(13)), shg, pause
%
echo off
fprintf('Cost functions and condition numbers:\n')
fprintf('   s-domain:            cf = %.4f,  condn = %.2e\n',fits(1),fits(14))
fprintf('   p-domain, 0th cycle: cf = %.4f,  condn = %.2e\n',fit0s(1),fit0s(14))
fprintf('   iterated p:          cf = %.4f,  condn = %.2e\n',fitrs(1),fitrs(14))
disp(' ')
fprintf('   z-domain:            cf = %.4f,  condn = %.2e\n',fitz(1),fitz(14))
fprintf('   q-domain, 0th cycle: cf = %.4f,  condn = %.2e\n',fit0z(1),fit0z(14))
fprintf('   iterated q:          cf = %.4f,  condn = %.2e\n',fitrz(1),fitrz(14))
disp(' ')
%
%IQML with orthopol
s=load('rarmmods'); m=s.m; op=s.mo; z=s.z_domain;
s=load('robotarm'); f=s.f;
pv=elis(f,'s',4,6,struct('itmax',1,'initset','IQML','initmodel',m));
shg, pause
pv=elis(f,'p',4,6,struct('itmax',1,'initset','IQML','initmodel',m));
shg, pause
pv=elis(f,'s',4,6,struct('itmax',1,'initset','IQML','initmodel',op));
shg, pause
pv=elis(f,'p',4,6,struct('itmax',1,'initset','IQML','initmodel',op));
shg, pause
pv=elis(f,'z',4,6,struct('fs',500,'itmax',1,'initset','IQML','initmodel',z));
shg, pause
pv=elis(f,'q',4,6,struct('fs',500,'itmax',1,'initset','IQML','initmodel',z));
%
%delete orthpd0.mat, delete orthpdn.mat
clear NaNv NaNv6 NaNv8 NaNv13 s m op
clear z x y v w pvf pvps pvpz pvrs pvrz pvs pvso pvsoz pvz pvpf pvqf
clear F Z Zdenom Znum basistreat condJ
clear denom domain f fit0s fit0z fit1s fit1z fitf fitp
clear fitrs fitrz fits fitso fitsoz fitz freq freqv fs fsi num ord pv pv0p pv0q  
clear pv1p pv1q pvalarr pvalarrm rppl scp pv0s fit0s pv0z fit0z
%
%End of hortptst
