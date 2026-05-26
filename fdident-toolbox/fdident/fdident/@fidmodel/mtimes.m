function rmodel=mtimes(arg1,arg2)
%MTIMES Realize multiplication of fidmodel object with scalar
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-May-2001
if isa(arg1,'double'), scalar=arg1; model=arg2;
elseif  isa(arg2,'double'), scalar=arg2; model=arg1;
elseif isa(arg1,'fidmodel')&isa(arg2,'fidmodel')
  if ~strcmp(get(arg1,'variable'),get(arg2,'variable'))
    error('Variables differ')
  elseif any(findstr(get(arg1,'variable'),'z'))
    if ~isequal(get(arg1,'fs'),get(arg2,'fs'))
      error('Sampling frequencies differ')
    end
  elseif strcmp(get(arg1,'representation'),'orthopol')|...
      strcmp(get(arg2,'representation'),'orthopol')
    error('Cannot combine orthopol-based model representations')
  end
  if any(findstr(get(arg2,'variable'),'z'))
    if strcmp(get(arg2,'InterSample'),'ZOH')
      warning('Cascading ZOH-type z-domain models is dubious')
    end
  end
  rmodel=arg1;
  if strcmp(get(arg2,'Coefficients'),'complex'), set(rmodel,'Coefficients','complex'), end
  set(rmodel,'covariance',[]);
  set(rmodel,'num',conv(get(arg1,'num'),get(arg2,'num')),...
    'denom',conv(get(arg1,'denom'),get(arg2,'denom')),...
    'delay',get(arg1,'delay')+get(arg2,'delay'));
  if ~isempty(get(arg1,'covariance'))|~isempty(get(arg2,'covariance'))
    warning('Handling of covariances is not yet implemented')
  end
  return
else
  error(['Function '*' not defined between variables of class ''',...
    class(arg1),''',''',class(arg2),''''])
end
if any(size(scalar)~=1), error('Number in @fidmodel/mtimes must be a scalar'), end
if ~isfinite(scalar), error('Scalar is not finite'), end
if scalar==0, warning('Scalar is zero in @fidmodel/mtimes'), end
if imag(scalar)~=0, error('Scalar is complex'), end
%
if scalar~=1
  set(model,'num',scalar*get(model,'num'),'noconsistency')
  model.outputunit='';
  cov=get(model,'covariance');
  if ~isempty(cov)
     lnum=length(model.num); ldenom=length(model.denom);
     scv=[ones(lnum,1);scalar*ones(ldenom,1);1];
     set(model,'covariance',cov.*(scv*scv'),'noconsistency')
  end
end
rmodel=model;
%
%End of @fidmodel/mtimes