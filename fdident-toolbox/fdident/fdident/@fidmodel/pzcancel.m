function out=pzcancel(model,tol)
%PZCANCEL Cancel poles/zeros in model (if possible)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Nov-2000

if nargin<2, tol=[]; end, if isempty(tol), tol=100*eps; end
%name = inputname(1);
%if isempty(name),
%   error('First argument to set must be a named variable.')
%end
if length(model)>1, error('This is not a SISO model'), end
if strcmp(get(model,'representation'),'orthopol')
  error('Orthogonal represenation cannot be added')
end
v=get(model,'variable');
if any(strmatch(v,{'s','r','w'}))
  fscale=get(model,'fscale');
  [domain,num,denom]=imppar(model,fscale);
elseif any(strmatch(v,{'z^-1'}))
  num=get(model,'num'); denom=get(model,'denom');
else
  error(['Variable ''',v,''' is not allowed'])
end
numsave=num; denomsave=denom;
%First eliminate leading zeros
if any(strmatch(v,{'s','r','w'}))
  %eliminate leading zero coefficients (of s^n)
  while (length(num)>1)&(num(1)==0), num(1)=[]; end
  while (length(denom)>1)&(denom(1)==0), denom(1)=[]; end
  %eliminate trailing zero coefficents present both in num and denom
  while (length(num)>1)&(num(end)==0)&(length(denom)>1)&(denom(end)==0)
    num(end)=[]; denom(end)=[];
  end
elseif any(strmatch(v,{'z^-1'}))
  %eliminate trailing zero coefficients (of z^(-n))
  while (length(num)>1)&(num(end)==0), num(end)=[]; end
  while (length(denom)>1)&(denom(end)==0), denom(end)=[]; end
  %eliminate leading zero coefficents present both in num and denom
  while (length(num)>1)&(num(1)==0)&(length(denom)>1)&(denom(1)==0)
    num(1)=[]; denom(1)=[];
  end
end
%count remaining trailing zero coefficients
num0=0;
for ii=length(num):-1:1
  if num(ii)==0, num0=num0+1; else break, end
end
denom0=0;
for ii=length(denom):-1:1
  if denom(ii)==0, denom0=denom0+1; else break, end
end
%
z=roots(num);
%Fix exactly zero roots:
if num0>0
  [zs,ind]=sort(abs(z)); z=z(ind);
  indi=1:num0;
  z(indi)=zeros(size(indi));
end
%
p=roots(denom);
%Fix exactly zero roots:
if denom0>0
  [ps,ind]=sort(abs(p)); p=p(ind);
  indi=1:denom0;
  p(indi)=zeros(size(indi));
end
%
if isempty(z)|isempty(p), ended=1; else ended=0; end
indz=1:length(z); indp=1:length(p);
indz0=[]; indp0=[];
while ended==0
  dist=abs(z(indz,ones(1,length(indp)))-p(indp,ones(1,length(indz))).');
  if ~isempty(dist)
    dist=dist(:); [m,ind]=min(dist);
    indz0i=rem(ind-1,length(indz))+1; indp0i=(ind-indz0i)/length(indz)+1;
    indz0i=indz(indz0i); indp0i=indp(indp0i);
    z0=z(indz0i); p0=p(indp0i);
  else %there is nothing to explore
    m=inf; p0=0; z0=0;
  end
  if m<=tol*max(abs(p0),abs(z0)) %eliminate
    if isreal(z0)&isreal(p0)
      indz0=[indz0;indz0i]; ind=find(indz==indz0i); indz(ind)=[];
      indp0=[indp0;indp0i]; ind=find(indp==indp0i); indp(ind)=[];
      if z0==0, num0=num0-1; end  
      if p0==0, denom0=denom0-1; end  
    elseif ~isreal(z0)&~isreal(p0)
      indz0=[indz0;indz0i]; ind=find(indz==indz0i); indz(ind)=[];
      indz0i=find(z==conj(z0)); indz0=[indz0;indz0i(1)];
      ind=find(indz==indz0i(1)); indz(ind)=[];
      indp0=[indp0;indp0i]; ind=find(indp==indp0i); indp(ind)=[];
      indp0i=find(p==conj(p0)); indp0=[indp0;indp0i(1)];
      ind=find(indp==indp0i(1)); indp(ind)=[];
      %no zero pole/zero can be involved
    elseif ~isreal(z0)&isreal(p0)
      indr=find(imag(p)==0); pr=p(indr);
      ind=find(pr==p0); pr(ind(1))=[]; indr(ind(1))=[];
      if length(pr)>0
        [m,i1]=min(abs(conj(z0)-pr));
        if m<tol*abs(z0) %found
          indz0=[indz0;indz0i]; ind=find(indz==indz0i); indz(ind)=[];
          indz0i=find(z==conj(z0)); indz0=[indz0;indz0i(1)];
          ind=find(indz==indz0i(1)); indz(ind)=[];
          indp0=[indp0;indp0i]; ind=find(indp==indp0i); indp(ind)=[];
          indp0i=indr(i1);
          indp0=[indp0;indp0i]; p1=p(indp0i); ind=find(indp==indp0i); indp(ind)=[];
          if p0==0, denom0=denom0-1; end  
          if p1==0, denom0=denom0-1; end  
        else %this is not good
          ind=find(indp==indp0i); indp(ind)=[];
        end
      else
        ind=find(indp==indp0i); indp(ind)=[];
      end
    elseif isreal(z0)&~isreal(p0)
      indr=find(imag(z)==0); zr=z(indr);
      ind=find(zr==z0); zr(ind(1))=[]; indr(ind(1))=[];
      if length(zr)>0
        [m,i1]=min(abs(conj(p0)-zr));
        if m<tol*abs(p0) %found
          indp0=[indp0;indp0i]; ind=find(indp==indp0i); indp(ind)=[];
          indp0i=find(p==conj(p0)); indp0=[indp0;indp0i(1)];
          ind=find(indp==indp0i(1)); indp(ind)=[];
          indz0=[indz0;indz0i]; ind=find(indz==indz0i); indz(ind)=[];
          indz0i=indr(i1);
          indz0=[indz0;indz0i]; z1=z(indz0i); ind=find(indz==indz0i); indz(ind)=[];
          if z0==0, num0=num0-1; end  
          if z1==0, num0=num0-1; end  
        else
          ind=find(indz==indz0i); indz(ind)=[];
        end
      else
        ind=find(indz==indz0i); indz(ind)=[];
      end
    end
  else
    ended=1;
  end
  if (length(indz0)==length(z))|(length(indp0)==length(p))
    ended=1;
  end
end %while
%
if ~isempty(indz0)
  z0poly=real(poly(z(indz0))); num=deconv(num,z0poly);
  p0poly=real(poly(p(indp0))); denom=deconv(denom,p0poly);
end
%
if ~isempty(num0), num(end+1-[1:num0])=zeros(1,num0); end
if ~isempty(denom0), denom(end+1-[1:denom0])=zeros(1,denom0); end
%
if ~isequal(denomsave,denom)|~isequal(numsave,num)
  if any(strmatch(v,{'s','r','w'}))
    m=fidmodel(v,num,denom,0,fscale);
    set(model,'num',get(m,'num'),'denom',get(m,'denom'))
  else
    set(model,'num',num,'denom',denom)
  end
end
%if nargout>0
  out=model;
%end
%assignin('caller',name,model)
%
%End of @fidmodel/pzcancel