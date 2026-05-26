function out=sisononlinvariance(dat)
%SISONONLINVARIANCE  Return [outputnonlinvar,inputnonlinvarvar,nonlincov]

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Mar-2005

vy=get(dat,'OutputNonlinVariance'); vx=get(dat,'InputNonlinVariance'); 
cxy=get(dat,'NonlinCovVect');

len=max([size(vy,1),size(vx,1),size(cxy,1)]);
if (length(vx)==1)&(len>1), vx=vx*ones(len,1); end
if (length(vy)==1)&(len>1), vy=vy*ones(len,1); end
if (length(cxy)==1)&(len>1), cxy=cxy*ones(len,1); end
if len>=1
  if isempty(vx), vx=zeros(len,1); end
  if isempty(vy), vy=zeros(len,1); end
  if isempty(cxy), cxy=zeros(len,1); end
end

out=[vy,vx,cxy];
%
%end @fiddata/sisononlinvariance.m