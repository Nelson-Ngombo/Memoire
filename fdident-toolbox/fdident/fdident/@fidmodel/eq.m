function out=eq(model1,model2)
%Eq Realize operation ==

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Nov-1998

if nargin<2, error('Not enough input argiments'), end
out=1; %equal
if ~isa(model1,'fidmodel'), out=0; return, end
if ~isa(model2,'fidmodel'), out=0; return, end
s1=size(model1); s2=size(model2);
if ~isequal(s1,s2), out=0; return, end
if prod(s1)>1
   for ii=1:prod(s1)
      outi=model1(ii)==model2(ii);
      if outi==0, out=0; return, end
   end
end
%One model only in each
if ~isequal(model1.version,model2.version), out=0; return, end
for ii=1:6
   if ii==1, p1=model1.num; p2=model2.num;
   elseif ii==2, p1=model1.denom; p2=model2.denom;
   elseif ii==3, p1=model1.C; p2=model2.C;
   elseif ii==4, p1=model1.D; p2=model2.D;
   elseif ii==5, p1=model1.F; p2=model2.F;
   elseif ii==6, p1=model1.ntr; p2=model2.ntr;
   end
   if isempty(p1)&~isempty(p2), out=0; return, end
   if ~isempty(p1)&isempty(p2), out=0; return, end
   if ~isempty(p1)&~isempty(p2)
      sp1=size(p1); sp2=size(p2);
      if any(sp1~=sp2), out=0; return, end
      if iscell(p1)&~iscell(p2), out=0; return, end
      if ~iscell(p1)&iscell(p2), out=0; return, end
      if isa(p1,'double')&isa(p2,'double')
         if any(size(p1)~=size(p2)), out=0; return, end
         if any(p1~=p2), out=0; return, end
      elseif iscell(p1)&iscell(p2)
         error('Not yet implemented')
      end
   end
end %for ii
%
%End of @fidmodel/eq