%HE2THTST Test for elis2tha and tha2elis

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Feb-2000

disp('File he2thtst')
%clf, hold off
c=computer; if length(c)<3, c=[c,'  ']; end
echo on
%Check elis2tha and tha2elis
%
echo off
if ~exist('poly2th')&~exist('mktheta')
  fprintf(['\nWarning! Cannot find the function m-files ''poly2th'' or',...
        ' ''mktheta'' of the',...
        '\nSystem Identification Toolbox - is this toolbox installed?\n',...
        'The test of elis2tha will be skipped.\n\n'])
        fprintf('Press a key to continue...'), pause, disp(' ')
  ident_license=0; %The identification toolbox is not licensed
else %Identification toolbox exists
  cv=[1:3];
  ident_license=0; %Maybe the identification toolbox is not licensed
  if strcmp(c(1:3),'MAC')
    ident_license=2; %no licensing
  end
  for cyc=cv
    fprintf('\nTest of elis2tha, case %.0f\n',cyc)
    nume=[20,21]; denome=[10,11]; delaye=3; fse=1e3; varete=0.01;
    on=length(nume)-1; od=length(denome)-1;
    numn=[2]; denomn=[2];
    Cpe=diag([1,2,0,4,5]);
    if cyc==2, Cpe=diag([1,2,1,4,5]); end
    if cyc==3,
      Cpe=0.01*diag([1,1,1,1,0]); Cpe(1,3)=-0.01; Cpe(3,1)=-0.01;
      nume=[1,1.1]; denome=[1,1];
    end
    pdat=exppar('z',nume,denome,delaye,fse);
    if ident_license==0
      %if not licensed, the variable remains 0
      %use error catch facility of eval
      try, poly2th(1,1,1,1,1,0.1,0.001); ident_license=1;
      catch, ident_license=0;
      end
    end
    echo off
    if ident_license==0
      warning('The Identification Toolbox is present but not licensed')
      break
    else
      theta=elis2tha(pdat,Cpe,varete,numn,denomn);
    end
    %
    if exist('present')
      disp('Present(theta)'), disp(' ')
      present(theta)
      %pause
      disp(' ')
    end
    [dummyA,num,C,D,denom]=feval('polyform',theta);
    if (length(C)~=1)|(length(D)~=1)
      C, D, error('C or D not equal to 1')
    end
    if isnumeric(theta)
      delay=theta(1,9); num(1:delay)=[];
      fs=1/theta(1,2);
      varet=theta(1,1);
      Cpt=theta(4:length(theta(:,1)),1:length(theta(:,1))-3);
    else
      delay=theta.InputDelay+theta.nk; num(1:delay)=[];
      fs=1/theta.ts;
      varet=theta.NoiseVariance;
      Cpt=theta.CovarianceMatrix;
    end
    vt=[1:on+1,on+1+[2:od+1]];
    Cper=Cpe(vt,vt)/denome(1)/denome(1);
    if any(abs(nume-denome(1)*num)>1e-3)|any(abs(denome-denome(1)*denom)>1e-3)
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('Numerator: elis    from theta\n')
      for i=1:length(num)
        fprintf('    z^-%.0f    %.4g    %.4g\n',i-1,nume(i),num(i))
      end
      fprintf('Denominator: elis    from theta\n')
      for i=1:length(denom)
       fprintf('    z^-%.0f    %.4g    %.4g\n',i-1,denome(i),denom(i))
      end
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if abs(delaye-delay)>1e-3
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('elis delay=%.2f, theta delay=%.2f\n',delaye,delay)
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if abs(fse-fs)>1e-3
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('elis fs=%.2f, theta fs=%.2f\n',fse,fs)
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if abs(varet-varete*numn(1)^2/denomn(1)^2)>1e-3
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('elis varet=%.2f, theta varet=%.2f\n',varete,varet)
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if (Cpe(on+2,on+2)==0)&any(any(abs(Cper-Cpt)>1e-3))
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('The covariance matrices are not the same:\n')
      Cper, Cpt
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    elseif Cpe(on+2,on+2)~=0
      %Cper, Cpt, fprintf('Press a key..'), pause, disp(' ')
    end
    %
    disp('Read back data via tha2elis...')
    N=128;
    [num,denom,delay,fs,vary,Cpt2]=tha2elis(theta,N,[1:15]'/32);
    if any(abs(nume-denome(1)*num)>1e-3)|any(abs(denome-denome(1)*denom)>1e-3)
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('Numerator: elis    from theta\n')
      for i=1:length(num)
        fprintf('    z^-%.0f    %.4g    %.4g\n',i-1,nume(i),num(i))
      end
      fprintf('Denominator: elis    from theta\n')
      for i=1:length(denom)
       fprintf('    z^-%.0f    %.4g    %.4g\n',i-1,denome(i),denom(i))
      end
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if abs(delaye-delay)>1e-3
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('elis delay=%.2f, theta delay=%.2f\n',delaye,delay)
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if abs(fse-fs)>1e-3
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('elis fs=%.2f, theta fs=%.2f\n',fse,fs)
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    if abs(vary(1)-N/2*varet)>1e-3
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('vary=%.2f, expected: %.2f\n',vary(1),N/2*varet)
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    end
    pv=1:(on+od+2);
    if (Cpe(on+2,on+2)==0)&...
                any(any(abs(Cpe(pv,pv)/denome(1)^2-Cpt2(pv,pv))>1e-3))
      echo off
      fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
      fprintf('The covariance matrices are not the same:\n')
      Cpe, Cpt2
      fprintf('Press a key to continue...'), pause, disp(' ')
      error('Fatal error in he2thtst')
    elseif Cpe(on+2,on+2)~=0
      %Cper, Cpt, fprintf('Press a key..'), pause, disp(' ')
    end
  end %for cyc
  clear cyc cv nume denome delaye fse varete on od numn denomn Cpe pdat
  clear theta dummyA num C D denom fs varet Cpt vt Cper N vary Cpt2 i pv
end %exist
%
if ident_license>0
  if ~exist('th2poly')&~exist('polyform')
    fprintf(['\nWarning! Cannot find the function m-files ''th2poly'' ',...
        'or ''polyform'' of the',...
        '\nSystem Identification Toolbox - is this toolbox installed?\n',...
        'The test of tha2elis will be skipped.\n\n'])
        fprintf('Press a key to continue...'), pause, disp(' ')
  else
    cv=[1:4];
    for cyc=cv
      fprintf('\nTest of tha2elis, case %.0f\n',cyc)
      varet=0.01; fs=1e3;
      A=[1,2];
      B=[0,0,0,5,1,1];
      C=1; D=1; F=1;
      if cyc==3
        F=A; A=1;
      elseif cyc==4
        C=[1,1]; D=[1,1,1]; F=[1,1];
      end
      %
      na=length(A)-1; nb=length(B); nc=length(C)-1; nd=length(D)-1;
      nf=length(F)-1; np=na+nb+nc+nd+nf;
      Cp=[]; Cpe=[];
      if cyc>1
        ca=0.1*[1:na]; cb=0.01*[1:nb-3]; cc=0.001*[1:nc]; cd=1e-4*[1:nd];
        cf=1e-5*[1:nf];
        Cp=diag([ca,cb,cc,cd,cf]);
        if cyc==2
          Cpe=diag([cb,0,ca,0]);
        elseif cyc==3
          Cpe=diag([cb,0,cf,0]);
        elseif cyc==4
          NaNv=NaN; %bypass Vax problem with NaN*
          Cpe=diag([NaNv(1,ones(1,na+nf+1)),cb,0]);
          clear NaNv
        end %if cyc==2
      end %if cyc>1
      if exist('poly2th')
        thetap=feval('poly2th',A,B,C,D,F,varet,1/fs); %H=B/(A*F)
      elseif exist('mktheta')
        thetap=feval('mktheta',A,B,C,D,F,varet,1/fs); %H=B/(A*F)
      end
      if isa(thetap,'idpoly')
        theta=thetap; theta.covariancematrix=Cp;
      else
        [tv,th]=size(thetap); lCp=length(Cp);
        theta=zeros(3+lCp,max(th,lCp));
        theta(1:tv,1:th)=thetap;
        if lCp>0, theta(4:3+lCp,1:lCp)=Cp; end
      end
      %
      nume=B(4:6);
      denome=conv(A,F);
      delaye=3;
      [num,denom,delay,fs,vary,ccovar]=tha2elis(theta,256,[1:5:100]);
      if any(abs(nume-num)>1e-3)|any(abs(denome-denom)>1e-3)
        echo off
        fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
        fprintf('Numerator: elis    from theta\n')
        for i=1:length(num)
          fprintf('    z^-%.0f    %.4g    %.4g\n',i-1,nume(i),num(i))
        end
        fprintf('Denominator: elis    from theta\n')
        for i=1:length(denom)
          fprintf('    z^-%.0f    %.4g    %.4g\n',i-1,denome(i),denom(i))
        end
        fprintf('Press a key to continue...'), pause, disp(' ')
        error('Fatal error in he2thtst')
      end
      if abs(delaye-delay)>1e-3
        echo off
        fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
        fprintf('elis delay=%.2f, theta delay=%.2f\n',delaye,delay)
        fprintf('Press a key to continue...'), pause, disp(' ')
        error('Fatal error in he2thtst')
      end
      if (na>1)&(nf>1)&any(any(abs(ccovar-Cpe)>1e-3))
        fprintf('Warning! Results unexpectedly differ from the ideal ones:\n')
        fprintf('The covariance matrices are not the same:\n')
        ccovar,Cpe
        fprintf('Press a key to continue...'), pause, disp(' ')
        error('Fatal error in he2thtst')
      end
    end %cyc
    clear cv cyc varet fs A B C D F na nb nc nd nf np Cp Cpe ca cb cc cd cf
    clear ccovar delaye delay nume num denome denom theta thetap lCp tv th vary
  end %exist
end %ident_license
clear ident_license c
%%%%% End of he2thtst %%%%%%%
