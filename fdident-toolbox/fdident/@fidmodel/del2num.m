function out=del2num(model)
%DEL2NUM  Move delay to zero leading coefficients of numerator

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-May-2005

var=get(model,'variable');
if ~any(findstr(var,'z')), error(['num2del may not be used for variable ''',var,'''']), end
out=model;
num=get(model,'num'); delay=get(model,'delay');
c=get(model,'covariance');
in=0;
while delay>=1
  in=in+1;
  delay=delay-1;
  num=[0,num];
  if size(c,1)>=1, c=[ones(size(c,1),1),c]; c=[ones(size(c,2),1);c]; end
end
if in>0
  set(out,'num',num,'covariance',c,'delay',delay);
end
%
%End of @fidmodel/del2num