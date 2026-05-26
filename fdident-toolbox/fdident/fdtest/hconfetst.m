function hconfetst
%HCONFETST Test confidence ellipses of polynomial/orthopol representations

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-2005

echo off
V=version;
if str2num(V(1:3))>=7, ds=dbstack('-completenames'); 
else ds=dbstack; 
end
n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name

global elis_max_iteration_number
elis_max_iteration_number_save=elis_max_iteration_number;
elis_max_iteration_number=[];

if ~exist('lastcyc'), lastcyc=0; cyc=1; else cyc=lastcyc; end
%cyc=5; %first cycle to run
for ii=cyc:100
  if ii==1
    tmp=load('testoppz'); d=tmp.Fdat;
    domain='s';
    fprintf(['ii = %.0f, domain = ',domain,'\n'],ii)
    figure(1), clf, figure(2), clf, figure(3), clf, figure(4), clf, figure(5), clf, figure(6), clf
    drawnow
    if ~isequal(lastcyc,ii)
      ms=elis(d,domain,14,14);
      mo=elis(d,domain,14,14,struct('representation','orthopol'));
    end
    axv=[2e3*[-1,1],1e4*[-1,1]];
  elseif ii==2
    tmp=load('testoppz'); d=tmp.testdata;
    domain='s';
    fprintf(['ii = %.0f, domain = ',domain,'\n'],ii)
    figure(1), figure(2), figure(3), figure(4)
    if ~isequal(lastcyc,ii)
      ms=elis(d,domain,0,4);
      mo=elis(d,domain,0,4,struct('representation','orthopol'));
    end
    axv=[];
  elseif ii==3
    tmp=load('robotarm'); d=tmp.robotarm_freqdata_agv;
    domain='s';
    fprintf(['ii = %.0f, domain = ',domain,'\n'],ii)
    figure(1), figure(2), figure(3), figure(4)
    if ~isequal(lastcyc,ii)
      ms=elis(d,domain,4,6);
      mo=elis(d,domain,4,6,struct('representation','orthopol'));
    end
    axv=[];
  elseif ii==4
    tmp=load('robotarm'); d=tmp.robotarm_freqdata_agv;
    domain='z';
    fprintf(['ii = %.0f, domain = ',domain,'\n'],ii)
    figure(1), figure(2), figure(3), figure(4)
    if ~isequal(lastcyc,ii)
      ms=elis(d,domain,4,6);
      mo=elis(d,domain,4,6,struct('representation','orthopol'));
    end
    axv=[];
  elseif ii==5
    tmp=load('robotarm'); d=tmp.robotarm_freqdata_agv;
    domain='w';
    fprintf(['ii = %.0f, domain = ',domain,'\n'],ii)
    figure(1), figure(2), figure(3), figure(4)
    if ~isequal(lastcyc,ii)
      ms=elis(d,domain,4,6); clear mo
    end
    axv=[];
  elseif ii==6
    tmp=load('robotarm'); d=tmp.robotarm_freqdata_agv;
    domain='r';
    fprintf(['ii = %.0f, domain = ',domain,'\n'],ii)
    figure(1), figure(2), figure(3), figure(4)
    if ~isequal(lastcyc,ii)
      ms=elis(d,domain,4,6,struct('tauR',1e-3)); clear mo
    end
    axv=[];
  else 
    break
  end
  lastcyc=ii;
  if any(ii==[1:100])
    zs=stdpz(ms);
    if exist('mo')
      zo=stdpz(mo);
      if ~isempty(zs.zv), indab=pairs(zs.zv,zo.zv); zo.zv=zo.zv(indab); zo.sdtz=zo.stdz(indab,:); end
      if ~isempty(zs.pv), indab=pairs(zs.pv,zo.pv); zo.pv=zo.pv(indab); zo.sdtp=zo.stdp(indab,:); end
    end
    %
    indz=[1:length(zs.zv)]';
    if ii==1, indz=[find((zs.stdz(:,2)==0)==(zo.stdz(:,2)==0))]; end
    indp=[1:length(zs.pv)]';
    if ii==1, indp=[find((zs.stdp(:,2)==0)==(zo.stdp(:,2)==0))]; end
    if ~isempty(zs.zv)
      fac=10;
      if ii==1, indz(1)=[];
      elseif ii==6, fac=0.2;
      end
      if any(abs(zs.zv(indz))<fac*zs.stdz(indz,1))
        error('difference between zero standard deviations')
      end
      if exist('mo')
        if any(abs(zo.zv(indz))<10*zo.stdz(indz,1))
          error('difference between orthopol zero standard deviations')
        end
        if any(abs((zs.zv-zo.zv)./zo.zv)>2e-2)
          error('Too large deviation between zeros')
        end
        ind2=indz;
        if ii==1, ind2([0,-2,-3]+end)=[]; end
        fact=1e-4; if ii==4, fact=1e-2; end
        if any(any(abs(zs.stdz(ind2,1:2)-zo.stdz(ind2,1:2))>fact*abs(zs.stdz(ind2,1:2))))
          error('zero standard deviations differ too much')
        end
      end
    end
    if ~isempty(zs.pv)
      fac=1;
      if ii==6, fac=0.02; end
      if any(abs(zs.pv)<fac*zs.stdp(:,1))
        error('difference between pole standard deviations')
      end
      if exist('mo')
        if any(abs(zo.pv)<zo.stdp(:,1))
          error('difference between orthopol pole standard deviations')
        end
        if any(abs((zs.pv-zo.pv)./zo.pv)>1e-4)
          error('Too large deviation between poles')
        end
        ind2=indp;
        if ii==1, ind2([-4,-5]+end)=[]; 
        elseif any(ii==[3,4]), ind2([-2,-3]+end)=[];
        end
        if any(any(abs(zs.stdp(ind2,1:2)-zo.stdp(ind2,1:2))>abs(zs.stdp(ind2,1:2))))
          error('pole standard deviations differ too much')
        end
      end
    end
    %
    Pc=10;
    if ii==1, Pc=30;
    elseif ii==4, Pc=100;
    end
    figure(1), clf
    h11=subplot(1,2,1);
    plotelpz(ms,ms.covar,Pc,axv,'','','','','','','','',h11), shg
    xlabel([domain,'-domain'])
    %
    figure(2), clf
    h21=subplot(1,2,1);
    plotelpz(ms,ms.covar,Pc,axv,'','','','','','','','',h21), shg
    xlabel([domain,'-domain, alg: anal'])
    h22=subplot(1,2,2);
    dp=[];
    plotelpz(ms,ms.covar,Pc,axv,'','','','','num',dp,'','',h22), shg
    xlabel([domain,'-domain',', alg: num'])
    if i==1
      hold on, axes('position',[0,0,1,1],'visible','off');
      ht=text(0.5,0.01,'WARNING: Numerical calculation is somewhat unreliable for these data','sc');
      set(ht,'horizontalalignment','center','verticalalignment','bottom')
      hold off
    end
    %
    figure(4), clf
    h41=subplot(1,2,1);
    plotelpz(ms,ms.covar,Pc,axv,'','','','','','','','',h41), shg
    xlabel([domain,'-domain, alg: anal'])
    h42=subplot(1,2,2);
    dp=[];
    %plotelpz(ms,Pc^2*ms.covar,-200,axv,'','','','','',dp,'','',h42), shg
    %Pc=1-exp(-stdm^2/2);
    %stdm=sqrt(-2*log(1-Pc));
    stdm=Pc;
    cloudm=stdm/sqrt(-2*log(1-sqrt(0.95)));
    plotelpz(ms,struct('conf','on','cloud','on','stdm',stdm,'cloudm',cloudm,'axv',axv,'hax',h42)), shg
    set(h42,'xlim',get(h41,'xlim'),'ylim',get(h41,'ylim'))
    xlabel([domain,'-domain',', cloud (95%)'])
    figure(4), zoom on
    %
    if exist('mo')
      figure(1)
      h12=subplot(1,2,2);
      plotelpz(mo,mo.covar,Pc,axv,'','','','','','','','',h12), shg
      xlabel('orthopol')
      %
      figure(5), clf
      h51=subplot(1,2,1);
      plotelpz(mo,mo.covar,Pc,axv,'','','','','','','','',h51), shg
      xlabel([domain,'-domain, orthopol, alg: anal'])
      h52=subplot(1,2,2);
      dp=[];
      %plotelpz(mo,Pc^2*mo.covar,-200,axv,'','','','','',dp,'','',h52), shg
      stdm=Pc;
      cloudm=stdm/sqrt(-2*log(1-sqrt(0.95)));
      plotelpz(mo,struct('conf','on','cloud','on','stdm',stdm,'cloudm',cloudm,'axv',axv,'hax',h52)), shg
      xlabel([domain,'-domain, orthopol, cloud (95%)'])
      set(h52,'xlim',get(h51,'xlim'),'ylim',get(h51,'ylim'))
      figure(5), zoom on
      figure(4), zoom on
      %
      figure(3), clf
      h31=subplot(1,2,1);
      plotelpz(mo,mo.covar,Pc,axv,'','','','','','','','',h31), shg
      xlabel([domain,'-domain, orthopol, alg: anal'])
      h32=subplot(1,2,2);
      dp=[];
      plotelpz(mo,mo.covar,Pc,axv,'','','','','num',dp,'','',h32), shg
      xlabel([domain,'-domain, orthopol, alg: num'])
      %
      figure(3), shg, zoom on
    else
      figure(3), clf, close
      figure(5), clf, close
    end
  end
  figure(2), shg, zoom on
  figure(1), shg, zoom on
  fprintf('Press any key to continue...'), pause, disp(' ')
end %for
clear tmp
close all
elis_max_iteration_number=elis_max_iteration_number_save;
%
%End of hconfetst