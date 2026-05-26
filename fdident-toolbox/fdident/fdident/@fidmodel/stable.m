function stmodel=stable(imodel,mode)
%STABLE Stabilize model by reflecting poles
%
%       if mode is given as 'zeros' or 'with-zeros', then - if possible - one
%       near zero is reflected along with each reflected pole

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Apr-2000

if nargin<2, mode=''; end
if strncmpi(mode,'with-zeros',6)|strncmpi(mode,'zeros',5)
  mode='with-zeros';
elseif isempty(mode)
 %OK
else
 error(['mode is not valid with value ''',mode,''''])
end
warn=0;

if strcmp(imodel.variable,'w')
  error('Warburg-models cannot be stabilized yet')
end
if ~isempty(imodel.data)
  fv=imodel.data.allfreqpoints;
else
  fv=[];
end
%
if strcmp(imodel.representation,'orthopol')
  rdenom=pole(imodel); rnum=zero(imodel);
else
  denom=imodel.denom; rdenom=roots(denom);
  num=imodel.num; rnum=roots(num); 
end
rdenomst=rdenom; lr=length(rdenom); rnummod=rnum; ln=length(rnum);
if any(findstr(imodel.variable,'z'))
  ind=find(abs(rdenom)>1);  
  rdenomst(ind)=1./rdenom(ind);
  %
  if strcmp(mode,'with-zeros')
    %bring zero along
    for ii=1:length(ind)
      if angle(rdenom(ind(ii)))==0
        indz=find((abs(rnummod)>1) & (angle(rnummod)==0));
      elseif angle(rdenom(ind(ii)))==pi
        indz=find((abs(rnummod)>1) & (angle(rnummod)==pi));
      else
        ang=angle(rdenom(ind(ii)));
        if ang>0, angmax=max(ang+pi/4,pi); angmin=min(ang-pi/4,0);
        else angmin=min(ang-pi/4,-pi); angmax=max(ang+pi/4,0);
        end
        indz=find((abs(rnummod)>1) &...
          (angle(rnummod)>angmin) &...
          (angle(rnummod)<angmax));
      end
      if ~isempty(indz)
        [dummy,indm]=min(rnummod(indz)-rdenom(ii));
        indm=indm(1);
        rnummod(indz(indm))=1/rnummod(indz(indm));
      else
        warn=warn+1;
      end
    end %for ii
  end %if strcmp
  %
  if isempty(fv)
    if all(angle(rdenom)==0); fv=imodel.fs/4;
    else fv=[0:lr+1]'/(lr+2)*imodel.fs/2;
    end
  end
  omv=exp(j*2*pi*fv);
elseif strcmp(imodel.variable,'s')
  ind=find(real(rdenom)>0);
  rdenomst(ind)=conj(-rdenomst(ind));
  %
  if strcmp(mode,'with-zeros')
    %bring zero along
    for ii=1:length(ind)
      if angle(rdenom(ind(ii)))==0
        indz=find((real(rnummod)>0) & (angle(rnummod)==0));
      elseif angle(rdenom(ind(ii)))==pi
        indz=find((real(rnummod)>0) & (angle(rnummod)==pi));
      else
        ang=angle(rdenom(ind(ii)));
        if ang>0, angmax=max(ang+pi/4,pi); angmin=min(ang-pi/4,0);
        else angmin=min(ang-pi/4,-pi); angmax=max(ang+pi/4,0);
        end
        indz=find((real(rnummod)>0) &...
          (angle(rnummod)>angmin) &...
          (angle(rnummod)<angmax));
      end
      if ~isempty(indz)
        [dummy,indm]=min(rnummod(indz)-rdenom(ii));
        indm=indm(1);
        rnummod(indz(indm))=-conj(rnummod(indz(indm)));
      else
        warn=warn+1;
      end
    end %for ii
  end %if strcmp
  %
  if isempty(fv)
    if all(imag(rdenom)==0), fv=[lr+1:-1:0]'/(lr+1);
    else fv=[0:lr+2]'/(lr+1)*max(imag(rdenom))/2/pi;
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
  tfv_new=prod(omv(:,ones(1,lr)).'-rdenomst(:,ones(length(fv),1))).';
  pvalarr=fdident('private','orthopol',length(rdenom),'s',fv/fsc,[],imodel.Zdenom);
  denomnew=([real(pvalarr);imag(pvalarr)]\[real(tfv_new);imag(tfv_new)]).';
  denom=imodel.denom;  
  %tfv_old=prod(omv(:,ones(1,lr)).'-rdenom(:,ones(length(fv),1))).';
  %denomnew=denomnew*median(tfv_old./tfv_new);
  denomnew=denomnew/norm(denomnew)*norm(denom);
elseif strcmp(imodel.variable,'s')
  fscv=fsc.^[lr:-1:0]';
  denomnew=real(poly(rdenomst/fsc));
  tfv_new=max(abs(polyval(denomnew,omv/fsc)));
  tfv_old=max(abs(polyval(denom.*fscv',omv/fsc)));
  denomnew=(denomnew./fscv')*tfv_old/tfv_new;
else
  denomnew=real(poly(rdenomst));
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
stmodel=imodel;
stmodel.denom=denomnew;

if strcmp(mode,'with-zeros')
  if strcmp(imodel.representation,'orthopol')
    tfv_new=prod(omv(:,ones(1,ln)).'-rnummod(:,ones(length(fv),1))).';
    pvalarr=fdident('private','orthopol',length(rnum),'s',fv/fsc,[],imodel.Znum);
    numnew=([real(pvalarr);imag(pvalarr)]\[real(tfv_new);imag(tfv_new)]).';
    num=imodel.num;  
    %tfv_old=prod(omv(:,ones(1,ln)).'-rnum(:,ones(length(fv),1))).';
    %numnew=numnew*median(tfv_old./tfv_new);
    numnew=numnew/norm(numnew)*norm(num);
  elseif strcmp(imodel.variable,'s')
    fscv=fsc.^[ln:-1:0]';
    numnew=real(poly(rnummod/fsc));
    tfv_new=max(abs(polyval(numnew,omv/fsc)));
    tfv_old=max(abs(polyval(num.*fscv',omv/fsc)));
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
  stmodel.num=numnew;
end
if strcmp(imodel.representation,'orthopol')
  tfi=tfcalc(imodel,fv);
  tfst=tfcalc(stmodel,fv);
  stmodel.denom=stmodel.denom*(median(abs(tfst./tfi)));
  if sum(find(abs(tfi+tfst)<abs(tfi-tfst)))>length(fv)/2, stmodel.denom=-stmodel.denom; end
end
stmodel.covariance=[];
%
if warn
  warning(sprintf(['%.0f unstable pole(s) do not have their nonminimum phase ',...
    'zero pair'],warn))
end
%End of @fidmodel/stable
