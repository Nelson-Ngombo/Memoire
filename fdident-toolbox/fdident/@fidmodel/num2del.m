function out=num2del(model,tol)
%NUM2DEL  Move zero leading coefficients from numerator to delay

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-May-2005

if nargin<2, tol=[]; end, if isempty(tol), tol=0; end
var=get(model,'variable');
if ~any(findstr(var,'z')), error(['num2del may not be used for variable ''',var,'''']), end
out=model;
num=get(model,'num'); delay=get(model,'delay');
c=get(model,'covariance');
in=0;
while (length(num)>1)&(abs(num(1))<=tol)
  in=in+1;
  delay=delay+1;
  num(1)=[];
  if size(c,1)>1, c(1,:)=[]; c(:,1)=[]; end
end
if in>0
  set(out,'num',num,'covariance',c,'delay',delay);
end
%
%End of @fidmodel/num2del