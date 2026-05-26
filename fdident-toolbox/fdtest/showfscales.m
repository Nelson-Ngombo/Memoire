function showfscales(Fdat,numord,denomord,runmod,devrunmod,fscrel)
%SHOWSCALES  Show conditioning as a function of fscale.
%
%       fscrel: relative deviation of the scaling frequency
%
%       Use: showfscales(Fdat,numord,denomord,runmod,devrunmod,fscrel)

if nargin<1, Fdat=[]; end
if isstr(Fdat), dname=Fdat; else dname=''; end
if isempty(Fdat), d=load('robotarm.mat'); Fdat=d.f; clear d, end
Fdat=fdident('private','getobjf',Fdat,'fiddata');
if nargin<2, numord=[]; end, if isempty(numord), numord=4; end
if nargin<3, denomord=[]; end, if isempty(denomord), denomord=6; end
if nargin<4, runmod=[]; end
if nargin<5, devrunmod=[]; end
if nargin<6, fscrel=[]; end
%
domain='s';
if ~isfield(runmod,'itmax'), runmod.itmax=0; end
if ~isfield(runmod,'plotdens'), runmod.plotdens=inf; end
if ~isfield(devrunmod,'displaymessages'), devrunmod.displaymessages='off'; end
Fdatstrm=Fdat.name; if ~isempty(Fdatstrm), dn=[', data: ',Fdatstrm]; 
elseif ~isempty(dname), dn=[', data: ',dname];
else dn='';
end
ind=find(dn=='_');
for ii=length(ind):-1:1
  dn=[dn(1:ind(ii)-1),'\',dn(ind(ii):end)];
end
%disp('Starting elis ...')
pv=elis(Fdat,domain,numord,denomord,runmod,devrunmod);
fscale=pv.fitinfo.fscale;
condn=pv.fitinfo.condnum;
%fvr=logspace(0,3,100);
%
figure(99), hold off, plot(Fdat), title(['Frequency domain',dn]),
hold on, ymm=get(gca,'ylim'); xmm=get(gca,'xlim'); fmm=1;
while xmm(2)<fscale/2/pi*fmm, fmm=fmm/1e3; end
while xmm(1)>fscale/2/pi*fmm, fmm=fmm*1e3; end
plot(fscale/2/pi*fmm*[1,1],ymm,':'), shg
hold off, figure(1)
%
if isempty(fscrel), fvr=logspace(0,1,10);
else fvr=fscrel;
end
fv=[fscale./fliplr(fvr(2:end)),fscale*fvr];
fp=Fdat.freqpoints; if iscell(fp), fp=cat(1,fp{:})'; end
fmed=2*pi*median(fp); fv=sort([fv,fmed]);
runmod.fscale=fmed;
pv=elis(Fdat,domain,numord,denomord,runmod,devrunmod);
cmed=pv.fitinfo.condnum;
cv=zeros(size(fv)); ii=0;
for fsc=fv
  ii=ii+1;
  runmod.fscale=fv(ii);
  pv=elis(Fdat,domain,numord,denomord,runmod,devrunmod);
  cv(ii)=pv.fitinfo.condnum;
  figure(1)
  loglog(fv(1:ii),cv(1:ii),':',fv(1:ii),cv(1:ii),'x',fscale,condn,'r*',fmed,cmed,'go')
  title(['Condition number',dn])
  xlabel('Scaling radian frequency')
  shg
end