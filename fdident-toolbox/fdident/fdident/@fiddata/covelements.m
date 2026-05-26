function cove=covelements(obj)
%COVELEMENTS  Array which shows the element numbers of the covariance vectors

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Dec-2003

nargchk(1,1,nargin);
if ~isa(obj,'fiddata'), error('class is not ''fiddata'''), end
%
chn=get(obj,'chn');
expn=get(obj,'expn');
cove=cell(1,expn);
fi=get(obj,'freqindices');
if ~iscell(fi), fi={fi}; end
if size(fi,1)==1
  for ic=2:chn, fi=[fi;fi(1,:)]; end
end
if size(fi,2)==1
  for ie=2:expn, fi=[fi,fi(:,1)]; end
end
for ie=1:expn
  c=NaN*ones(chn,chn);
  for ic1=1:chn
    for ic2=1:chn
      if ~isempty(fi{ic1,ie})&~isempty(fi{ic2,ie})
        c(ic1,ic2)=sum(ismember(fi{ic1,ie},fi{ic2,ie}));
      end
    end
  end
  cove{ie}=c;
end
if length(cove)==1, cove=cove{1}; end
%
% end @fiddata/covelements.m