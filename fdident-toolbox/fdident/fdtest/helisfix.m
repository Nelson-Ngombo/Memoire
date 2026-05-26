%HELISFIX  Test the parameter fixing in the new syntax of elis.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
domainv='szw';
for domain=domainv
%for domain='z'
  disp(['Parameter fixing test for elis, ''',domain,'''-domain']), disp(' ')
  num=[20,10,5]; numord=length(num)-1;
  denom=[4,3,2,1,0.001]; denomord=length(denom)-1;
  if domain=='z', m=fidmodel('z^-1',num,denom,0,1);
  else m=fidmodel(domain,num,denom);
  end
  %save helisfix m -append, return
  u=msinclip(fiddata([],ones(12,1),[1:12]/50),...
    struct('itmax',0,'graphs','nograph','showmsgs','no'));
  u.output=u.input; vard=1e-8;
  u.SiSoVariance=[1,1]*vard;
  d=simfou(m,u,1); 
  if all(d.SiSoVariance==0), d.SiSoVariance=100*[eps,eps].^2; end
  %
  for ii=5:-1:0
  %for ii=3
    runmod='';
    runmod.itmax=1;
    if ii==0
      devrunmod.displaymessages='no';
    else
      devrunmod='';
    end
    if domain=='z', runmod.fs=1; end
    if ii==0
      mf=[];
    elseif ii==1
      mf=m; mf.num=NaN*num;
      runmod.fixedpars=mf;
    elseif ii==2
      mf=m; mf.num(1)=NaN*num(1);
      runmod.fixedpars=mf;
    elseif ii==3
      mf=m; mf.num=NaN*num;
      runmod.fixedpars=mf;
      runmod.initmodel=m;
    elseif ii==4
      runmod.fixedpars='a_n';
      if any(domain=='z'), runmod.itmax=10; end
    elseif ii==5
      runmod.fixedpars='a_0';
      if any(domain=='spw'), runmod.itmax=10; end
    else
      error('Programming error')
    end
    figure(gcf), drawnow
    p=elis(d,domain,numord,denomord,runmod,devrunmod);
    if isfield(runmod,'fixedpars')&...
        (isequal(runmod.fixedpars,'a_0')|isequal(runmod.fixedpars,'a_n'))
      %nothing to do
    elseif ~isempty(mf)
      %nothing to do
    else %mf empty: norm=1
      x=norm(denom)/norm(p.denom)*sign(p.denom(1));
      p.num=x*p.num; p.denom=x*p.denom;
    end
    num, denom
    get(p)
    %
    y=1; %factor for a_0~0
    if isfield(runmod,'fixedpars')&isequal(runmod.fixedpars,'a_0')
      if any(domain=='spw')
        if p.denom(5)~=1, error('a_0 is not 1'), end
        p.num=0.001*p.num; p.denom=0.001*p.denom;
        ind=[2:4];
      elseif any(domain=='z')
        p.num=4*p.num; p.denom=4*p.denom;
        if p.denom(1)~=4, error('a_0 is not 4'), end
        ind=[2:4];
      end
      if ~any(domain=='zw')
        if any(abs(num-p.num)./num>0.15), error('Numerator is not restored'), end
        if any(abs(denom(ind)-p.denom(ind))./denom(ind)>0.15)
          error('Denominator is not restored')
        end
      end
    elseif isfield(runmod,'fixedpars')&isequal(runmod.fixedpars,'a_n')
      if any(domain=='spw')
        p.num=4*p.num; p.denom=4*p.denom;
        if p.denom(1)~=4, error('a_n is not 4'), end
        ind=[2:4];
      elseif any(domain=='z')
        if p.denom(5)~=1, error('a_n is not 1'), end
        p.num=0.001*p.num; p.denom=0.001*p.denom;
        ind=[2:4];
      end
      if ~any(domain=='zw')
        if any(abs(num-p.num)./num>0.15), error('Numerator is not restored'), end
        if any(abs(denom(ind)-p.denom(ind))./denom(ind)>0.15)
          error('Denominator is not restored')
        end
      end
    elseif ~isempty(mf)
      ind=find(~isnan(mf.num));
      if ~isempty(ind)
        if any(num(ind)~=p.num(ind)), error('Numerator is not properly fixed'), end
        if any(abs(num-p.num)>20*sqrt(vard)), error('Numerator is not restored'), end
      end
      %
      ind=find(~isnan(mf.denom));
      if ~isempty(ind)
        if any(denom(ind)~=p.denom(ind)), error('Denominator is not properly fixed'), end
        if any(abs(denom-p.denom)>100*eps), error('Denominator is not restored'), end
      end
    end
    %
    if ii==0
      disp(['HELISFIX: reference elis fit was done for domain: ''',domain,'''.'])
      disp(' ')
    else
      fprintf(['HELISFIX: elis fix test passed for ii=%.0f, domain: ''',domain,'''\n\n'],ii)
    end
    fprintf('Press any key to continue...'), pause, disp(' ')
  end %for ii
  %
end
clear m u num denom p vard domain runmod devrunmod x u d ind indn indd
clear numord denomord ii ans domainv mf
