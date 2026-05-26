function errmess=plotdelays(models,index,varargin)
%PLOTDELAYS Plot cost functions and delays of models
%
%       models is a vector of fidmodel objects, index points to the
%       selected model (usually models with the same orders are treated),
%       if the index is empty, all models are plotted.
%       In the place of varargin, the string 'parents' and the handle of
%       an axes may be given. If these are missing, gca is used.
%
%       Usage:
%         errmess=plotdelays(models,index,'parent',axeshandle)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Jan-2000

if nargout>0, errmess=''; end
if nargin<=2, varargin=[]; end
ha=[];
for ii=1:length(varargin)
  if strcmpi(varargin(ii),'parent')
    ha=varargin{ii+1};
    break
  end
end %for ii

if nargin<2, index=[]; end

arr=[];
if ~isempty(index)
  numord=length(models(index).num)-1; %models(:,:,index outside class directory
  denomord=length(models(index).denom)-1;  
else
  numord=[]; denomord=[];
end
for ii=1:prod(size(models))
  numordii=length(models(ii).num)-1;
  denomordii=length(models(ii).denom)-1;
  if isempty(numord)|(isequal(numord,numordii)&isequal(denomord,denomordii))
    cfii=models(ii).fitinfo.cf;
    del=models(ii).delay;
    if isfield(models(ii).algorithm,'initdelay')
      initdel=models(ii).algorithm.initdelay;
    else
      initdel=NaN;
      warning('initial delay was not yet stored in this model')  
    end
    arr=[arr,[cfii;initdel;del]];
    if size(arr,2)==1, no=numordii; do=denomordii; end
  elseif ~isempty(index)&(index>size(arr,2)) 
    index=index-1;
  end
end %for ii
%
if size(arr,2)==0
  errmess='No appropriate model is found'; return
%elseif (size(arr,2)>1)&all(diff(arr(3,:))==0)
%  errmess='All delays are exactly equal'; break
end
%
if isempty(ha), ha=gca; end
if ishandle(ha)
  set(ha,'nextplot','replace')
  delete(allchild(ha))
  set(ha,'xlimmode','auto','ylimmode','auto')
else
  error('Handle is invalid')
end
%
h=[];
%Check xlim
dd=max(arr(3,:))-min(arr(3,:));
dm=max(abs(arr(3,:)));
if (dd==0)&(dm==0), dd=2; end
dd=max(dd,4e-3*dm);
dc=(max(arr(3,:))+min(arr(3,:)))/2;
dmm=dc+1.05*[-0.5,0.5]*dd;
%
dd2=max(max(arr(2:3,:)))-min(min(arr(2:3,:)));
dd2=max(dd2,dd);
dc2=(max(max(arr(2:3,:)))+min(min(arr(2:3,:))))/2;
dmm2=dc2+1.05*[-0.5,0.5]*dd2;
%
%Check ylim
ddy=max(arr(1,:))/min(arr(1,:));
maxa=10^ceil(log10(1.05*max(arr(1,:))));
mina=10^floor(log10(min(arr(1,:))/1.05));
%
[xa,ind]=sort(arr(3,:));
ya=arr(1,:); ya=ya(ind);
%Plot cost function values
semilogy(xa,ya,'*b',xa,ya,':b','parent',ha)
if all(~isnan([mina,maxa])), set(ha,'ylim',[mina,maxa]), end
set(ha,'yscale','log')
set(ha,'xlim',dmm)
%
fdident('private','fixlgtck',ha)
set(ha,'nextplot','add')
if ~isempty(index)
  semilogy(arr(3,index),arr(1,index),'*r','parent',ha)
end
%set(ha,'xlimmode','manual')
if ~isempty(index), sostr=sprintf(', %.0f/%.0f systems',no,do);
else sostr='';
end
set(get(ha,'title'),'string',['Cost function for different delays',sostr])
set(get(ha,'xlabel'),'string','Delays (the triangles mark the starting delay values)')

if any(arr(2,:)-arr(3,:)~=0)
  %Any delay differs from initial one
  axv2=get(ha,'ylim');
  daxv2=log10(axv2(2)/axv2(1));
  maxv2=10^(floor(daxv2/5)+1);
  axv2(1)=axv2(1)/maxv2;
  set(ha,'ylim',axv2)
end
if ishandle(h), delete(h), end
%
%Now plot half circles
t=[0:60]'/60*pi;
x=-cos(t);
y=sin(t);
axv2=get(ha,'ylim');
%
set(ha,'xlim',dmm2)
for ii=1:length(arr(1,:))
  c=mean(arr(2:3,ii));
  r=abs(arr(3,ii)-arr(2,ii))/2;
  ym=max((2*r)/diff(dmm2),0.05)*2*y;
  semilogy(x*r+c,axv2(1)*10.^(ym),'-b','parent',ha,'tag','delay-evolution');
  semilogy(arr(2,:),axv2(1),'^b','MarkerSize',4,'parent',ha,'tag','delay-evolution')  
end
%
set(ha,'nextplot','replace')
