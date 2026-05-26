function out=var2nonlinvar(dat)
%VAR2NONLINVAR  Move variance properties to "nonlinear error"

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Mar-2005

covs=get(dat,'CovarianceMatrix');
M=get(dat,'M');
% *** For nonlinear analysis, errors do not average out ***
%if ~isempty(M)
%  if isnumeric(covs), covs=covs*M;
%  else for ii=1:prod(size(covs)), covs{ii}=covs{ii}*M; end
%  end
%end
%
set(dat,'CovarianceMatrix',[],'M',[],'NonlinCovarianceMatrix',covs,'NonlinM',M)
if nargout>=1, out=dat;
else assignin('caller',inputname(1),dat)
end
%
%end @fiddata/var2nonlinvar.m