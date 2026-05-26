function rmodel=mrdivide(arg1,arg2)
%MRDIVIDE Realize scalar divided by fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Mar-1999

if isa(arg1,'double')
  scalar=arg1; model=arg2; rec=1;
elseif isa(arg2,'fidmodel')
  rmodel=mtimes(arg1,1/arg2);
  return
elseif ~isnumeric(arg2)
  error(['Function ''*'' not defined between variables of class ''',...
    class(arg1),''',''',class(arg2),''''])
else
  scalar=arg2; model=arg1; rec=0;
end
if any(size(scalar)~=1), error('Number in mrdivide must be a scalar'), end
if ~isfinite(scalar), error('Scalar is not finite'), end
if scalar==0, error('Scalar is zero'), end
if imag(scalar)~=0, error('Scalar is complex'), end
%
if rec==1 %reciprocal
  num=get(model,'num');
  denom=get(model,'denom');
  lnum=length(num); ldenom=length(denom);
  set(model,'num',denom,'noconsistency')
  set(model,'denom',num,'noconsistency')
  ntr=get(model,'ntr');
  if ~isempty(ntr), error('ntr cannot be inverted'), end
  fixedpar=get(model,'fixedpar');
  if ~isempty(fixedpar)
    if size(fixedpar,2)==2
      indn=find(fixedpar(:,1)<=lnum);
      indd=find((fixedpar(:,1)>lnum)&(fixedpar(:,1)<=lnum+ldenom));
      if ~isempty(indn), fixedpar(indn,1)=fixedpar(indn,1)+lnum; end
      if ~isempty(indd), fixedpar(indd,1)=fixedpar(indd,1)-lnum; end
      set(model,'fixedpar',fixedpar,'noconsistency')
    end
  end
  set(model,'fitinfo',[],'noconsistency')
  Znum=get(model,'Znum');
  Zdenom=get(model,'Zdenom');
  if ~isempty(Znum)
    set(model,'Znum',Zdenom,'noconsistency')
    set(model,'Zdenom',Znum,'noconsistency')
  end
  delay=get(model,'delay');
  set(model,'delay',-delay,'noconsistency');
  cov=get(model,'covariance');
  if ~isempty(cov)
    cov2=cov;
    cov2(ldenom+[1:lnum],ldenom+[1:lnum])=cov([1:lnum],[1:lnum]);
    cov2([1:ldenom],ldenom+[1:lnum])=cov(lnum+[1:ldenom],[1:lnum]);
    cov2(ldenom+[1:lnum],[1:ldenom])=cov([1:lnum],lnum+[1:ldenom]);
    cov2([1:ldenom],[1:ldenom])=cov(lnum+[1:ldenom],lnum+[1:ldenom]);
    set(model,'covariance',cov2,'noconsistency')
  end
  addhist(model,'Reciprocal operation')  
else
  scalar=1/scalar;
end
%
%Finally, let us multiply by the value of the scalar
if scalar~=1
  lnum=length(model.num); ldenom=length(model.denom);
  set(model,'num',scalar*model.num,'noconsistency')
  cov=get(model,'covariance');
  if ~isempty(cov)
     scv=[ones(lnum,1);scalar*ones(ldenom,1);1];
     set(model,'covariance',cov.*(scv*scv'),'noconsistency')
  end
end
rmodel=model;
%
%End of @fidmodel/mrdivide