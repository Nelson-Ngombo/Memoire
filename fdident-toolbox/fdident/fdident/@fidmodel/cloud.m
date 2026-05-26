function mobj = cloud(obj,cno,flim)
%Cloud  Generate scattered object set from covariance of parameters
%
%       mobj = CLOUD(obj,cno,flim);
%
%       Output argument:
%       mobj = structure of objects (if mobj is required, no plot is made)
%
%       Input arguments:
%       obj = fidmodel object with covariance
%       cno = number of calculated models in cloud
%       flim = borders of frequency band
%       Defaults: cno=10, flim=measured band (data), or covering all poles/zeros

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Apr-2002

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if nargin<2, cno=[]; end, if isempty(cno), cno=10; end
if length(cno)>1, error('cno is not a scalar'), end
if cno<1, error('cno is less than 1'), end
if nargin<3, flim=[]; end
if ~isempty(flim)
  if length(flim)~=2, error('flim is not a 2-element vector'), end
  if any(~isfinite(flim))|any(imag(flim))|any(flim<0)
    error('flim has illegal value')
  end
end
if length(obj)~=1, error('Object is not single'), end
cov=obj.covariance;
if isempty(cov), error('Covariance is empty'), end
%
num=obj.num; denom=obj.denom; delay=obj.delay;
pv=[num';denom';delay]; lp=length(pv);
cov=cov(1:lp,1:lp);
var=obj.variable;
if strcmp(var,'s')&strcmp(get(obj,'representation'),'polynomial')
  nn=length(num)-1; nd=length(denom)-1; fsc=get(obj,'fscale');
  if isempty(fsc)|~isfinite(fsc), fsc=1; end
  scv=[fsc.^[nn:-1:0],fsc.^[nd:-1:0],fsc];
  cov=cov.*(scv'*scv);  
else
  scv=ones(size(pv))';  
end
numind=1:length(num);
denomind=length(num)+[1:length(denom)];
delayind=length(num)+length(denom)+1;
%scov=sqrtm(cov);
[U,S,V]=svd(cov,0); scov=U*sqrt(S)*V';
%
if any(imag(scov(:))~=0)
  warning('Cannot calculate reliable matrix square root in @fidmodel/cloud')
  scov=real(scov);
end
mobji=obj;
for ii=1:cno-1
  n=randn(size(pv));
  pvi=pv+(scov(1:lp,1:lp)*n)./scv';
  numi=pvi(numind);
  denomi=pvi(denomind);
  delayi=pvi(delayind);
  obji=obj; obji.covariance=[]; obji.data=[]; obji.fitinfo=[];
  set(obji,'num',numi','denom',denomi','delay',delayi);
  mobji=stack(1,mobji,obji);
end

if nargout>0, mobj=mobji;
else plot(mobji,'m','flim',flim), title('Cloud of models')
end
% end ../@fidmodel/cloud.m
