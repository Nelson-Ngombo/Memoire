function [indab,cycle,digits]=pairs(a,b,p,maxcycle,digitsreq,D)
%PAIRS  Closest pairs between elements of complex vectors.
%
%       [indab,cycle,digits]=PAIRS(a,b,p,maxcycle,digitsreq,D)
%
%       Minimize sum(D(i,indab(i))) or sum(abs(a(i)-b(indab(i)))^p), using the
%       Hungarian method.
%
%       Output arguments:
%       indab = indices of the elements of b, belonging to the corresponding
%           elements of a: b(indab) is the corresponding vector.
%       cycle = number of performed iterative cycles; cycle is 0 if simple
%           nearest neighbors give optimum.
%       digits = number of digits used in the last step of iterative
%           minimization.
%
%       Input arguments:
%       a = first complex vector
%       b = second complex vector, length(b)>=length(a)
%       p = exponent of the distance (if D is not given), default=2.
%       maxcycle=maximum number of weight distribution cycles; if optimum is
%           not reached within the given number of cycles, indab contains at
%           least one zero index. default: maxcycle=inf.
%       digitsreq = digits to be used in the weighting iteration; if
%           digitsreq is not given and maxcycle is finite, digits will be
%           adjusted to provide convergence within specified number of cycles,
%           but digits will not be set smaller than 2.
%           default value: floor(log10(1/eps)).
%       D = matrix of edge weights; if not given, the pth power of distances
%           will be used.
%
%       Usage: [indab,cycle,digits]=pairs(a,b,p,maxcycle,digitsreq,D)
%       Examples: indab=pairs(roots([1,2,3,4]),roots([1.01,2,3,4]),2);
%                 pind=pairs([-0.1-1.5*j,-0.1+1.5*j],roots([1,2,3,4]));
%
%       See also: STDPZ, PLOTELPZ.

%       Algorithm:
%         Kuhn, H. W., The Hungarian Method for the Assignment Problem.
%           Naval Res. Logist. Quart., Vol. 2, 1955. pp. 83-97.
%         Andrasfai, B., Graph Theory: Flows, Matrices. Budapest, Akademiai
%           Kiado; Bristol, UK, Adam Hilger, 1991.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Jun-1999

global pairsmessages
if ~exist('pairsmessages'), pairsmessages=''; end
if nargin<6, D=[]; end
if nargin<5, digitsreq=[]; end
if nargin<4, maxcycle=[]; end
if nargin<3, p=[]; end
%
if isempty(p), p=2; end
if isempty(maxcycle), maxcycle=inf; end
digmax=floor(log10(1/eps));
if isempty(digitsreq), digitsreq=digmax; end
digits=min(digmax,digitsreq);
if min(size(a))>1, error('a is not a vector'), end
if min(size(b))>1, error('b is not a vector'), end
a=a(:); b=b(:);
N=length(a); Nb=length(b);
if N==0, error('a is empty'), end
if N>Nb, error('a is longer than b'), end
if any(~isfinite([a;b])), error('Infinite or NaN element in vectors'), end
if isempty(D)
  D=abs( a*ones(1,Nb)-ones(N,1)*b.' ); %distance matrix, size la*lb
  if max(D(:))>0, D=(D/max(D(:))).^p; end
else
  [Dv,Dh]=size(D);
  if (Dv~=N)|(Dh~=Nb)
    error('Size of weight matrix does not correspond to vector lengths')
  end
  if any(any(~isfinite(D))), error('Intinite or NaN element in D'), end
  D=D-min(D(:)); %non-negative weights
  D=(D/max(D(:))); %set max to 1
end
D=1-D; %maximum is sought instead of minimum in the Hungarian method
%integer values between 0 and 10^digits:
if max(D(:))>0, D=round(D/max(D(:))*10^digits); end
%
if maxcycle<=0, error('maxcycle is not positive'), end
if digitsreq<1, error('digitsreq is smaller than 1'), end
if p<=0, error('p is not positive'), end
%
iN=[1:N]'; iNb=[1:Nb]';
cycle=0;
%
%1st step: initial weights for points
fa=max(D')'; fb=zeros(1,Nb); %row vectors of weights
%
A1=iN; %Initially, put all points in A1
while (any(A1)&(cycle<maxcycle)) | (cycle==0)
  %continue until A1 (set of not related points) becomes empty
  %
  %2nd step: find maximum number of independent, exactly covered edges
  G0=fa*ones(1,Nb)+ones(N,1)*fb-D; %zeros indicate exactly covered edges
  ind0=find(G0(:)==0);
  inda=rem(ind0-1,N)+1; indb=floor((ind0-1)/N)+1; %ind0=indb*N+inda
  %inda, indb: column vectors, points of exactly covered edges
  %
  %find initial cover:
  A23=zeros(N,1); B23=zeros(Nb,1);
  indat=inda; indbt=indb; %points still to explore
  while length(indat)>0
    A23(indat(1))=indbt(1); B23(indbt(1))=indat(1);
    %exclude edges with common points with chosen edge:
    ie=[find(indat==indat(1));find(indbt==indbt(1))];
    if length(ie)>1
      ie=sort(ie); iei=find(diff(ie)==0); ie(iei)=[];
    end
    indat(ie)=[]; indbt(ie)=[];
  end %while
  A1=iN.*(1-sign(A23)); B1=iNb.*(1-sign(B23));
  %
  if ~any(A1)
    break %all points of 'a' are related to points in 'b'
  else
    cycle=cycle+1;
    if cycle==1
      disp('WARNING: nearest neighbors do not give optimum in PAIRS')
    end
    if strcmp(pairsmessages,'yes')
      fprintf('Cycle %.0f\n',cycle)
      fprintf('   %.0f covered edges\n',length(inda))
    end
    seekar=1; %seek alternating route
  end
  %
  while seekar==1
    %find A2 (reachable from A1 via alternating route)
    A2=zeros(N,1);
    i2=find(A1~=0); %set of new route points in A
    while length(i2)>0
      A2ic=[]; %cumulate increments to A2 in A2ic
      for i=1:length(i2)
        ir=find(inda==i2(i)); %edges from the point i2(i)
        %exclude heavy edges (none of them present in first cycle of 'while')
        ic=find(indb(ir)==A23(i2(i))); if ~isempty(ic), ir(ic)=[]; end
        A2ic=[A2ic;B23(indb(ir))]; %augment set of route points
      end %for i
      for i=length(A2ic):-1:1
        if A2ic(i)==0, A2ic(i)=[]; %delete zeros of A2ic
        elseif A2(A2ic(i))>0, A2ic(i)=[]; %exclude already explored points
        end
      end
      if ~isempty(A2ic)
        A2ic=sort(A2ic);
        if length(A2ic)>1
          ie=find(diff(A2ic)==0);
          if length(ie)>0, A2ic(ie)=[]; end
        end
        A2(A2ic)=A23(A2ic); %store new points
      end
      i2=A2ic; %prepare continuation of exploring alternating routes
    end %while length(i2)
    A2=A23.*sign(A2); A3=A23.*(1-sign(A2));
    B2=B23; if any(A3), iA3=find(A3>0); B2(A3(iA3))=zeros(length(iA3),1); end
    B3=B23.*(1-sign(B2));
    %
    %look for alternating route A1->B1, that is, for existence of edge A2->B1
    B1r=[]; %reachable points in B1
    iA2=find(A2>0);
    for i=1:length(iA2)
      ie=find(inda==iA2(i)); %edges from points in A2
      Bv=B1(indb(ie));
      i0=find(Bv==0); if ~isempty(i0), Bv(i0)=[]; end %throw away zeros
      if ~isempty(Bv)
        B1r=[B1r;Bv];
      end
    end %for i
    arb=[];
    while ~isempty(B1r) %alternating route exists
      if strcmp(pairsmessages,'yes')
        fprintf(['        %.0f edges in current cover',...
            ', alternating route found\n'],sum(sign(A23)) )
      end
      %explore alternating route B1->A1, from first point of B1r
      arb=B1r(1); %set initial value: starting point of alternating route in B
      %From now on, collect B-points of alternating route in variable arb
      ia0=find(indb==arb); %end points of related branches
      ara=min(inda(ia0)); %initial value: point of alternating route in A
      %From now on, collect A-points of alternating route in variable ara
      maxa=ara; %maximum starting element already explored in A
      ic=find(inda(ia0)==ara);
      ia0(ic)=[]; %eliminate this point everywhere
      %
      while A1(ara(end))==0 %A1 not reached yet
        if length(arb)==length(ara)
          %First selection of point in B follows
          arb=[arb;A23(ara(end))];
        end
        %Now selection of point in A follows:
        %First exclude points already explored in this attempt
        iexcl=sort(ara); %Already explored points
        if length(iexcl)>1, iee=find(diff(iexcl)==0); iexcl(iee)=[]; end
        vexcl=ones(length(inda),1);
        for i=1:length(iexcl)
          ic=find(inda==iexcl(i)); vexcl(ic)=zeros(length(ic),1);
        end
        ia=find( (indb.*vexcl)==arb(length(arb)) );
        %Now exclude already explored points
        if length(maxa)>=length(ara)+1
          ie=find(inda(ia)<=maxa(length(ara)+1));
          if ~isempty(ie), ia(ie)=[]; end
        end
        %
        if ~isempty(ia) %proceed along path
          ara=[ara;min(inda(ia))];
          maxa(length(ara))=ara(end);
        else %end of current path, step back
          if ~isempty(ara), maxa(length(ara))=ara(end); end
          ara(end)=[];
          maxa([length(ara)+2:end])=[];
          %Now store info about explored A point
          arb(end)=[];
          if isempty(arb), break, end
        end %if ~isempty
        %
        if isempty(ara)
          if ~isempty(ia0)
            ara=min(inda(ia0)); %try next possible point
            maxa=ara;
            ic=find(inda(ia0)==ara); ia0(ic)=[];
          else
            %save pairssav.mat
            error('Algorithmic error: alternating route not found')
          end
        end
      end %while A1
      %
      %Define new cover
      if ~isempty(arb)
        A23(ara)=arb; A1=iN.*(1-sign(A23)); clear A2 A3
        B23(arb)=ara; B1=iNb.*(1-sign(B23)); clear B2 B3
        seekar=1; %continue search for even longer alternating route
        B1r=[];
      else %arb empty
        %Search failed in this branch, try next one
        B1r(1)=[];
      end
    end %while ~isempty(B1r)
    %
    if isempty(arb)
      if strcmp(pairsmessages,'yes')
        fprintf('        %.0f edges in maximum cover\n',sum(sign(A23)) )
      end
      seekar=0; %maximum cover found
    end
  end %while seekar==1
  %
  %Step 3:adjust weights
  if any(A1)
    iA12=find(A1+A2>0); %Members of A1+A2
    iB13=find(B1+B3>0); %Members of B1+B3
    covedge=length(ind0);
    if strcmp(pairsmessages,'yes')
      fprintf('     Redistribute weights: ')
    end
    i0=find(G0(:)==0);
    while (covedge==length(i0))&all(G0(i0)==0) %no new covered edge found yet
      if strcmp(pairsmessages,'yes')
        fprintf('*')
      end
      fov=min(min(G0(iA12,iB13))); %minimal excess cover
      if fov==0, error('Algorithmic error: zero value in excess cover'), end
      if all(fa(iA12)>0)
        %3rd step
        fmod=min(fov,min(fa(iA12)));
        fa(iA12)=fa(iA12)-fmod;
        iB2=find(B2>0);
        fb(iB2)=fb(iB2)+fmod;
      elseif all(fb(iB13)>0)
        %4th step
        fmod=min(fov,min(fb(iB13)));
        fb(iB13)=fb(iB13)-fmod;
        iA3=find(A3>0);
        fa(iA3)=fa(iA3)+fmod;
      else %Algorithmic error, not probable!
        %save pairssav.mat
        error('Algorithmic error: minimum weight is 0')
      end %if all ..
      G0=fa*ones(1,Nb)+ones(N,1)*fb-D; %zeros indicate exactly covered edges
      edgedis=sum(G0(i0)~=0);
      if edgedis>0
        if strcmp(pairsmessages,'yes')
          fprintf('\n   %.0f covered edge(s) disappeared',edgedis)
        end
      end
      covedge=sum(G0(:)==0); %number of covered edges
    end %while covedge
    if any(fa<0)|any(fb<0)
      error('Algorithmic error: negative weight generated')
    end
    %new exactly covered edge was generated
    if strcmp(pairsmessages,'yes')
      fprintf('\n   %.0f new covered edge(s) found\n',...
                  covedge-length(ind0)+edgedis)
    end
  end %if any(A1)
  %
  %check convergence and adjust number of digits
  if (nargin<5)&isfinite(maxcycle) %number of digits may be adjusted
    exccover=sum(G0(:)); %Total excess cover
    mindec=min(N,Nb); %minimum decrease of excess cover in a cycle
    digmod=ceil(log10(exccover/mindec/(maxcycle-cycle+1)));
    if digmod>0
      ndigits=max(digits-digmod,2);
      if ndigits<digits
        digits=ndigits;
        fprintf('Number of digits is set to %.0f in PAIRS\n',digits)
        D=round(D/max(D(:))*10^digits);
        fa=max(D')'; fb=zeros(1,Nb);
      end
    end
  end %(nargin<5)
end %while any(A1)
%
if any(A23==0)
  disp('WARNING: PAIRS did not converge')
end
indab=A23;
%%%%%%%%%%%%%%%%%%%%%%%% end of pairs %%%%%%%%%%%%%%%%%%%%%%%%
