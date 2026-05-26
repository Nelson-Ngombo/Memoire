function out=nonlinvar2var(dat)
%NONLINVAR2VAR  Move "nonlinear variance" properties to variance

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Aug-2003

covs=get(dat,'NonlinCovarianceMatrix');
M=get(dat,'NonlinM');
% *** For nonlinear analysis, errors do not average out ***
%if ~isempty(M)
%  if isnumeric(covs), covs=covs/M;
%  else for ii=1:prod(size(covs)), covs{ii}=covs{ii}/M; end
%  end
%end
%
if ~isempty(get(dat,'OddNonexcFrequencies'))
  vdat=sisononlinvariance(dat);
  set(dat,'outputvariance',vdat(:,1),'inputvariance',vdat(:,2),'covvect',vdat(:,3),'M',M)
else
  set(dat,'NonlinCovarianceMatrix',[],'NonlinM',[],'CovarianceMatrix',covs,'M',M)
end
%if nargout>=1
out=dat;
%else
%assignin('caller',inputname(1),dat)
%end
%
%end @fiddata/nonlinvar2var.m