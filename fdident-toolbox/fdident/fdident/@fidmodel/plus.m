function rmodel=plus(arg1,arg2,tol)
%PLUS Add model tf's (connect models in parallel)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-May-2001

if isa(arg1,'fidmodel')&isa(arg2,'fidmodel')
  if length(arg1)>1
    error('First variable is not a SISO model')
  elseif length(arg2)>1
    error('Second variable is not a SISO model')
  elseif ~strcmp(get(arg1,'variable'),get(arg2,'variable'))
    error('Variables differ')
  end
  if any(findstr(get(arg1,'variable'),'z'))
    if ~isequal(get(arg1,'fs'),get(arg2,'fs'))
      error('Sampling frequencies differ')
    end
  end
  if strcmp(get(arg1,'representation'),'orthopol')|...
      strcmp(get(arg2,'representation'),'orthopol')
    error('Cannot combine orthopol-based model representations')
  end
  if ~isequal(get(arg1,'delay'),get(arg2,'delay'))
    error('Delays are different')
  end
  rmodel=arg1;
  if strcmp(get(arg2,'Coefficients'),'complex'), set(rmodel,'Coefficients','complex'), end
  set(rmodel,'covariance',[],'data',[],'fitinfo',[],'date',datestr(now),'noconsistency');
  if ~isequal(get(arg1,'freqvect'),get(arg2,'freqvect'))
    set(rmodel,'freqvect',[],'noconsistency')
  end
  %
  denom1=get(arg1,'denom'); denom2=get(arg2,'denom');
  if isequal(denom1,denom2)
    %denominators are equal
    set(rmodel,'num',get(arg1,'num')+get(arg2,'num'))
  else
    %First look for common roots
    [cp,cr]=common_factor(denom1,denom2,[],arg1);
    if length(cp)>1, denom2=deconv(denom2,cp); end
    %
    set(rmodel,'num',conv(get(arg1,'num'),denom2)+...
      conv(get(arg2,'num'),deconv(denom1,cp)),...
      'denom',conv(denom1,denom2));
  end
  if ~isempty(get(arg1,'covariance'))|~isempty(get(arg2,'covariance'))
    warning('Handling of covariances is not yet implemented')
  end
  return
else
  error(['Function '+' not defined between variables of class ''',...
    class(arg1),''',''',class(arg2),''''])
end
%
%End of @fidmodel/plus