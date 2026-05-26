function testfidm
%TESTFIDM  Check fidmodel objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Mar-2005

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clear ds n ind
disp(' '), disp('Test of fidmodel objects')
%dbstop if warning, dbstop if error
%
echo on
clear functions %Reset functions

load rarmmods
m=fidmodel(m);
if ~isa(m,'fidmodel'), error('Load error'), end
%
fidmodel_examples
%
ver=fdtool('version');
if str2num(ver(1:3))>=3.1
  exppar(m,'tmps.par');
  exppar(z_domain,'tmpz.par');
  delete tmps.par, delete tmpz.par
end
%
load inpchmod
inpchans=fidmodel(inpchans); inpchanz=fidmodel(inpchanz);
if ~isa(inpchans,'fidmodel')|~isa(inpchanz,'fidmodel'), error('Load error'), end
load bandpmod
bkref=fidmodel(bkref); bkfit=fidmodel(bkfit);
if ~isa(bkref,'fidmodel')|~isa(bkfit,'fidmodel'), error('Load error'), end

if ~m.consistency, error('Inconsistent m'), end
get(m), check(m)

m2=m;
m2.data.SiSoVariance=[];
if ~m2.consistency, error('Inconsistent m2'), end
diff(m,m2)

%Size
ic=0;
for ms={m,robotarm_6models',stack(1,m,m)}
  ic=ic+1;
  if ic==1, ord=6; elseif ic==2, ord=32; elseif ic==3, ord=6; end
  ms=ms{1};
  size(ms), s=size(ms);
  if length(s)~=3, error('Size of ms is not 3-element'), end
  if any(s~=[1,1,length(ms)]), error('Size of ms is not [1,1,length]'), end
  [s1,s2,s3]=size(ms);
  if any([s1,s2,s3]~=[1,1,length(ms)]), error('Size of ms is not [1,1,length]'), end
  if size(ms,1)~=1, error('outputchnumber error'), end
  if size(ms,2)~=1, error('inputchnumber error'), end
  if size(ms,3)~=length(ms), error('model number error'), end
  if ~strncmp(version,'5.2',3) %does not work in 5.2
    if size(ms,'order')~=ord, error('size(m,''order'') error'), end
  end
end

%Examples of Lennart
%
info=which('fidmodel.m','-all');
if length(info)>1, error('More than 1 fidmodels'), end
%
load rarmmods
m=fidmodel(m);
get(m)
%
ms=m;
%
get(ms), set(ms), plot(ms)
clf, bode(ms)
figure(gcf), drawnow
isstab=isstable(ms), polevect=pole(ms), zerovect=zero(ms)
%
clf
if exist('c2d')&exist('nyquist')
  clf, nyquist(ms)
  figure(gcf), drawnow
  mc=tf(m) %convert to control toolbox format
  %
  mcf=fidmodel(mc); %Convert back
  m2=m; m2.covariance=[]; %Covariance is not converted
  m2.freqvect=[]; m2.algorithm=[];
  m2.fitinfo=[]; m2.data=[];
  if m2~=mcf
    diff(m2,mcf), error('Models differ')
  end
  mcfc=tf(mcf);
  if ~isequal(mc,mcfc)
    mcs=struct(mc), mcfcs=struct(mcfc)
    error('CTB models differ')
  end
  %
  md=c2d(ms,0.1); %convert to discrete domain
else
  warning('Control System Toolbox is not installed')
end
%
if exist('theta')&exist('bodeplot')
  th=theta(md,0.1); %transform to theta-format
  bodeplot(trf(th))
  figure(gcf), drawnow
  present(th)
  mid=fidmodel(th); get(mid), diff(md,mid)
end
%
ms.B, ms.B=[1,2,3];
diff(m,ms)
mrec=1/ms; mrec.B, mrec.a
%
%Greg's examples
load rarmmods %models
plot(m), plot(robotarm_6models), bode(m)
%ss(m), tf(m), zpk(m)
if exist('@tf\tf.m'), fidmodel(tf(m)), end
%
help fidmodel %help on creator
help(fidmodel) %description of object
helpc(fidmodel) %contents of class directory
%
%First MIMO tests
mm=fidmodel('s',{[1,2];[3,4,5]},{[6,7,8];[9,10,11]});
disp('Type: ''TFS''') %set of SISO TF's
get(mm)
mm=fidmodel('s',{[1,2],[3,4,5]},{[9,10,11,12]});
disp('Type: ''CD''') %Common denominator
get(mm)
%
if exist('htestfidm.m'), htestfidm, end %test plots
%
%Test conversions from-to the SITB
if exist(['@idmodel',filesep,'idmodel.m'])
  load rarmmods
  ms=m;
  sc=ms.denom(1); ms.num=ms.num/sc; ms.denom=ms.denom/sc;
  zs=z_domain;
  sc=zs.denom(1); zs.num=zs.num/sc; zs.denom=zs.denom/sc;
  %
  disp('s-domain model, to/from idmodel')
  %im=idmodel(m)
  %mm=fidmodel(im)
  %if any(abs(mm.num-ms.num)>1e4*eps*abs(ms.num))|...
  %    any(abs(mm.denom-ms.denom)>1e4*eps*abs(ms.denom))
  %  error('Restored model differs')
  %end
  %
  disp('z-domain model, to/from idmodel')
  %imz=idmodel(z_domain)
  %mmz=fidmodel(imz)
  %if any(abs(zs.num-mmz.num)>1e4*eps*abs(zs.num))|...
  %    any(abs(zs.denom-mmz.denom)>1e4*eps*abs(zs.denom))|...
  %    any(abs(zs.fs-mmz.fs)>10*eps*abs(zs.fs))
  %  error('Restored model differs')
  %end
  %
  mi=idpoly([1,2,3],[2,3,4],[1,20,30],[1,22,33],[1,23,34],1)
  mim=fidmodel(mi)
  %
  disp('s-domain model, to/from idpoly')
  im=idpoly(m)
  mm=fidmodel(im)
  if any(abs(mm.num-ms.num)>1e4*eps*abs(ms.num))|...
      any(abs(mm.denom-ms.denom)>1e4*eps*abs(ms.denom))
    error('Restored model differs')
  end
  %
  disp('z-domain model, to/from idpoly')
  imz=idpoly(z_domain)
  mmz=fidmodel(imz)
  if any(abs(zs.num-mmz.num)>1e4*eps*abs(zs.num))|...
      any(abs(zs.denom-mmz.denom)>1e4*eps*abs(zs.denom))|...
      any(abs(zs.fs-mmz.fs)>10*eps*abs(zs.fs))
    error('Restored model differs')
  end
  %
  disp('s-domain model, to/from idarx')
  try
    im=idarx(m)
    OK=1;
  catch
    OK=0;
  end
  if OK==1
    error('New development: arx can accomodate now continuous-time models')
    mm=fidmodel(im)
    if any(abs(mm.num-ms.num)>1e4*eps*abs(ms.num))|...
        any(abs(mm.denom-ms.denom)>1e4*eps*abs(ms.denom))
      error('Restored model differs')
    end
  end
  %
  disp('z-domain model, to/from idarx')
  imz=idarx(z_domain)
  mmz=fidmodel(imz)
  if any(abs(zs.num-mmz.num)>1e4*eps*abs(zs.num))|...
      any(abs(zs.denom-mmz.denom)>1e4*eps*abs(zs.denom))|...
      any(abs(zs.fs-mmz.fs)>10*eps*abs(zs.fs))
    error('Restored model differs')
  end
end
%
load rarmmods
w=whos;
for ii=1:length(w)
  modeltoget=eval(w(ii).name); 
  if isa(modeltoget,'fidmodel'), get(modeltoget); set(modeltoget); end
end
s=export(m); ds=fidmodel(s);
testplots fidmodel
close
%
if exist('testc2d.m'), testc2d, end
%
%End of file testfidm
