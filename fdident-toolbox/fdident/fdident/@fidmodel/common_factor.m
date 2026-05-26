function [commonpol,commonroots]=common_factor(p1,p2,tol,dummy)
%COMMON_FACTOR Common factors in polynomials

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Nov-2000

if isa(p1,'fidmodel')|isa(p2,'fidmodel')|isa(tol,'fidmodel')
  error('An argument is of class fidmodel')
end
if nargin<3, tol=[]; end, if isempty(tol), tol=100*eps; end
if ~isnumeric(p1)|~isnumeric(p2)
  error('p1 or p2 is not a polynomial')
elseif isempty(p1)|isempty(p2)
  error('p1 or p2 is empty')
elseif (size(p1,1)~=1)|(size(p2,1)~=1)|(length(tol)~=1)
  error('Size of an argument is incorrect')
end

if isequal(p1,p2)
  %polynomials are equal
  commonpol=p1;
  commonroots=roots(p1);
else
  %Look for common roots
  r1=roots(p1); r2=roots(p2);
  r10s=0; r20s=0;
  commonroots=[];
  if isempty(r1)|isempty(r2), ended=1; else ended=0; end
  indr1=1:length(r1); indr2=1:length(r2);
  indr10=[]; indr20=[];
  while ended==0
    dist=abs(r1(indr1,ones(1,length(indr2)))-r2(indr2,ones(1,length(indr1))).');
    if ~isempty(dist)
      dist=dist(:); [m,ind]=min(dist);
      indr10i=rem(ind-1,length(indr1))+1; indr20i=(ind-indr10i)/length(indr1)+1;
      indr10i=indr1(indr10i); indr20i=indr2(indr20i);
      r10=r1(indr10i); r20=r2(indr20i);
    else %there is nothing to explore
      m=inf; r20=0; r10=0;
    end
    if m<=tol*max(abs(r20),abs(r10)) %eliminate
      if isreal(r10)&isreal(r20)
        indr10=[indr10;indr10i]; ind=find(indr1==indr10i); indr1(ind)=[];
        indr20=[indr20;indr20i]; ind=find(indr2==indr20i); indr2(ind)=[];
        if r10==0, r10s=r10s-1; end  
        if r20==0, r20s=r20s-1; end  
      elseif ~isreal(r10)&~isreal(r20)
        indr10=[indr10;indr10i]; ind=find(indr1==indr10i); indr1(ind)=[];
        indr10i=find(r1==conj(r10)); indr10=[indr10;indr10i(1)];
        ind=find(indr1==indr10i(1)); indr1(ind)=[];
        indr20=[indr20;indr20i]; ind=find(indr2==indr20i); indr2(ind)=[];
        indr20i=find(r2==conj(r20)); indr20=[indr20;indr20i(1)];
        ind=find(indr2==indr20i(1)); indr2(ind)=[];
        %no zero can be involved
      elseif ~isreal(r10)&isreal(r20)
        indr=find(imag(r2)==0); pr=r2(indr);
        ind=find(pr==r20); pr(ind(1))=[]; indr(ind(1))=[];
        if length(pr)>0
          [m,i1]=min(abs(conj(r10)-pr));
          if m<tol*abs(r10) %found
            indr10=[indr10;indr10i]; ind=find(indr1==indr10i); indr1(ind)=[];
            indr10i=find(r1==conj(r10)); indr10=[indr10;indr10i(1)];
            ind=find(indr1==indr10i(1)); indr1(ind)=[];
            %
            indr20=[indr20;indr20i]; ind=find(indr2==indr20i); indr2(ind)=[];
            indr20i=indr(i1);
            indr20=[indr20;indr20i]; r21=r2(indr10i);
            ind=find(indr2==indr10i); indr2(ind)=[];
            if r20==0, r20s=r20s-1; end  
            if r21==0, r20s=r20s-1; end  
          else %this is not good
            ind=find(indr2==indr20i); indr2(ind)=[];
          end
        else
          ind=find(indr2==indr20i); indr2(ind)=[];
        end
      elseif isreal(r10)&~isreal(r20)
        indr=find(imag(r1)==0); zr=r1(indr);
        ind=find(zr==r10); zr(ind(1))=[]; indr(ind(1))=[];
        if length(zr)>0
          [m,i1]=min(abs(conj(r20)-zr));
          if m<tol*abs(r20) %found
            indr20=[indr20;indr20i]; ind=find(indr2==indr20i); indr2(ind)=[];
            indr20i=find(r2==conj(r20)); indr20=[indr20;indr20i(1)];
            ind=find(indr2==indr20i(1)); indr2(ind)=[];
            %
            indr10=[indr10;indr10i]; ind=find(indr1==indr10i); indr1(ind)=[];
            indr10i=indr(i1);
            indr10=[indr10;indr10i]; r11=r1(indr10i); ind=find(indr1==indr10i); indr1(ind)=[];
            if r10==0, r10s=r10s-1; end  
            if r11==0, r10s=r10s-1; end  
          else
            ind=find(indr1==indr10i); indr1(ind)=[];
          end
        else
          ind=find(indr1==indr10i); indr1(ind)=[];
        end
      end
    else
      ended=1;
    end
    if (length(indr10)==length(r1))|(length(indr10)==length(r2))
      ended=1;
    end
  end %while
  %
  commonroots=r1(indr10);
  commonpol=real(poly(commonroots));  
end
%
%End of @fidmodel/common_factor