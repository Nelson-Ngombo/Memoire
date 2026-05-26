function modmodel=rmpz(imodel,poles,zeros)
%RMPZ  Remove poles/zeros from model

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Apr-2000

warnp=0; warnz=0;
if nargin<3, zeros=[]; end
if nargin<2, poles=[]; end
if strcmp(imodel.variable,'w')
  error('Warburg-models cannot be modified yet')
end
if ~isempty(imodel.data)
  fv=imodel.data.allfreqpoints;
else
  fv=[];
end
%
modmodel=imodel;
denom=imodel.denom; num=imodel.num; 
if strcmp(imodel.representation,'orthopol')
  rdenom=pole(imodel); rnum=zero(imodel);
else
  rdenom=roots(denom);
  rnum=roots(num); 
end
rdenommod=rdenom;  rnummod=rnum;
%
for ii=1:length(poles)
  r=poles(ii);
  if ~isnan(r)
    if imag(r)~=0
      ind=find( (abs(poles-conj(r))<100*eps*abs(r)) & ...
        (sign(imag(r))==-sign(imag(poles))) );
      if length(ind)>1
        [rc,ind]=min(abs(poles-conj(r)));
        ind=ind(1); rc=rc(1);
      end
      if ~isempty(ind)
        poles(ind)=NaN;
      end
      ind=find(abs(rdenommod-conj(r))<=100*eps*abs(r));
      if length(ind)>1
        [rc,ind]=min(abs(rdenommod-conj(r))); ind=ind(1); rc=rc(1);
      end
      if ~isempty(ind), rdenommod(ind)=NaN; end
    end
    ind=find(abs(rdenommod-r)<=100*eps*abs(r));
    if length(ind)>1
      [rc,ind]=min(abs(rdenommod-r)); ind=ind(1); rc=rc(1);
    end
    if ~isempty(ind), rdenommod(ind)=NaN; else warnp=warnp+1; end
  end %if ~isnan
end %for ii
ind=find(isnan(rdenommod)); if ~isempty(ind), rdenommod(ind)=[]; end
%
for ii=1:length(zeros)
  r=zeros(ii);
  if ~isnan(r)
    if imag(r)~=0
      ind=find( (abs(zeros-conj(r))<100*eps*abs(r)) & ...
        (sign(imag(r))==-sign(imag(zeros))) );
      if length(ind)>1
        [rc,ind]=min(abs(zeros-conj(r)));
        ind=ind(1); rc=rc(1);
      end
      if ~isempty(ind)
        zeros(ind)=NaN;
      end
      ind=find(abs(rnummod-conj(r))<=100*eps*abs(r));
      if length(ind)>1
        [rc,ind]=min(abs(rnummod-conj(r))); ind=ind(1); rc=rc(1);
      end
      if ~isempty(ind), rnummod(ind)=NaN; end
    end
    ind=find(abs(rnummod-r)<=100*eps*abs(r));
    if length(ind)>1
      [rc,ind]=min(abs(rnummod-r)); ind=ind(1); rc=rc(1);
    end
    if ~isempty(ind), rnummod(ind)=NaN; else warnz=warnz+1; end
  end %if ~isnan
end %for ii
ind=find(isnan(rnummod)); if ~isempty(ind), rnummod(ind)=[]; end
%
lrorig=length(denom)-1; lnorig=length(num)-1;
lr=length(rdenommod); ln=length(rnummod);
if any(findstr(imodel.variable,'z'))
  if isempty(fv)
    if all(angle(rdenom)==0); fv=imodel.fs/4;
    else fv=[0:lrorig+lnorig+1]'/(lrorig+lnorig+2)*imodel.fs/2;
    end
  end
  omv=exp(j*2*pi*fv);
elseif strcmp(imodel.variable,'s')
  if isempty(fv)
    if all(imag(rdenom)==0), fv=[lrorig+lnorig+1:-1:0]'/(lrorig+lnorig+1);
    else fv=[0:lrorig+lnorig+2]'/(lrorig+lnorig+1)*max([imag(rdenom);imag(rnum)])/2/pi;
    end
  end
  omv=j*2*pi*fv;
elseif strcmp(model.variable,'w')
  error('Not yet ready for variable ''w''')
else
  error(['Unknown variable ''',imodel.variable,''''])
end
%
fsc=get(imodel,'Fscale');
if strcmp(imodel.representation,'orthopol')
  tfv_new=prod(omv(:,ones(1,lr)).'-rdenommod(:,ones(length(fv),1))).';
  [pvalarr,Zdenom]=fdident('private','orthopol',length(rdenom),'s',fv/fsc,[],imodel.Zdenom);
  Zdenom=Zdenom(1:lr+1);
  set(modmodel,'Zdenom',Zdenom,'noconsistency')
  pvalarr=pvalarr(:,1:lr+1);
  denomnew=([real(pvalarr);imag(pvalarr)]\[real(tfv_new);imag(tfv_new)]).';
  denom=imodel.denom;  
  %tfv_old=prod(omv(:,ones(1,lr)).'-rdenom(:,ones(length(fv),1))).';
  %denomnew=denomnew*median(tfv_old./tfv_new);
  denomnew=denomnew/norm(denomnew)*norm(denom);
elseif strcmp(imodel.variable,'s')
  fscvorig=fsc.^[lrorig:-1:0]';
  fscv=fsc.^[lr:-1:0]';
  denomnew=real(poly(rdenommod/fsc));
  tfv_new=max(abs(polyval(denomnew,omv/fsc)));
  tfv_old=max(abs(polyval(denom.*fscvorig',omv/fsc)));
  denomnew=(denomnew./fscv')*tfv_old/tfv_new;
else
  denomnew=real(poly(rdenommod));
  tfv_new=max(abs(polyval(denomnew,omv)));
  tfv_old=max(abs(polyval(denom,omv)));
  denomnew=denomnew*tfv_old/tfv_new;
end  
%fix sign
s=1;
for ii=1:length(denom)
  if denom(ii)~=0, s=sign(denom(ii)); break, end
end
denomnew=s*denomnew;
set(modmodel,'denom',denomnew,'noconsistency');

if strcmp(imodel.representation,'orthopol')
  tfv_new=prod(omv(:,ones(1,ln)).'-rnummod(:,ones(length(fv),1))).';
  [pvalarr,Znum]=fdident('private','orthopol',length(rnum),'s',fv/fsc,[],imodel.Znum);
  Znum=Znum(1:ln+1);
  set(modmodel,'Znum',Znum,'noconsistency')
  pvalarr=pvalarr(:,1:ln+1);
  numnew=([real(pvalarr);imag(pvalarr)]\[real(tfv_new);imag(tfv_new)]).';
  num=imodel.num;  
  %tfv_old=prod(omv(:,ones(1,ln)).'-rnum(:,ones(length(fv),1))).';
  %numnew=numnew*median(tfv_old./tfv_new);
  numnew=numnew/norm(numnew)*norm(num);
elseif strcmp(imodel.variable,'s')
  fscv=fsc.^[ln:-1:0]';
  fscvorig=fsc.^[lnorig:-1:0]';
  numnew=real(poly(rnummod/fsc));
  tfv_new=max(abs(polyval(numnew,omv/fsc)));
  tfv_old=max(abs(polyval(num.*fscvorig',omv/fsc)));
  numnew=(numnew./fscv')*tfv_old/tfv_new;
else
  numnew=real(poly(rnummod));
  tfv_new=max(abs(polyval(numnew,omv)));
  tfv_old=max(abs(polyval(num,omv)));
  numnew=numnew*tfv_old/tfv_new;
end  
%fix sign
s=1;
for ii=1:length(num)
  if num(ii)~=0, s=sign(num(ii)); break, end
end
numnew=s*numnew;
modmodel.num=numnew;
%
if strcmp(imodel.representation,'orthopol')
  tfi=tfcalc(imodel,fv);
  tfst=tfcalc(modmodel,fv);
  modmodel.denom=modmodel.denom*(median(abs(tfst./tfi)));
  if sum(find(abs(tfi+tfst)<abs(tfi-tfst)))>length(fv)/2, modmodel.denom=-modmodel.denom; end
end
modmodel.covariance=[];
%
if warnp
  warning(sprintf('%.0f poles cannot be eliminated from model',warnp))
end
if warnz
  warning(sprintf('%.0f zeros cannot be eliminated from model',warnz))
end
%End of @fidmodel/rmpz
