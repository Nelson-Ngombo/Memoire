function [bestmodel,index]=best(models,Fdat)
%BEST  Return best model from model set

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999
%       All rights reserved.
%       $Revision: $
%       Last modified: 17-Jul-1999

if nargin<2, Fdat=[]; end
if isempty(Fdat), models(1).data; mdat=1; else mdat=0; end
cf=inf; icf=0;
for ii=1:prod(size(models))
  if (mdat==1)&~isempty(models(ii).fitinfo);
    cfi=models(ii).fitinfo.cf;
  else
    cfi=eliscost(models(ii),Fdat);
  end
  if cfi<cf
    cf=cfi; icf=ii;
  end
end %for ii
%
bestmodel=models(icf);
if nargout>1
  [v,h,d]=size(models);
  if sum([v,h,d]>1)==1, index=icf;
  else
    index=icf;
    index=[0,0,0];
    if d==1, index(3)=[];
    else index(3)=rem(icf,v*h); icf=(icf-index(3))/h;
    end
    index(2)=rem(icf,v); icf=icf-index(2);
    index(1)=icf/v;
  end
end
%
%End of @fidmodel/best
