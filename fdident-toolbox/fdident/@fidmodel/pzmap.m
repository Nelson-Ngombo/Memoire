function [P,Z] = pzmap(model)
%PZMAP  Plot poles/zeros of fidmodel object through @lti/pzmap

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Oct-1998

ni = nargin;
no = nargout;

if ~exist('@lti/pzmap.m')%|strcmp(obj.variable,'w')
  error('Control toolbox is not installed, calling ploteltf')
  if no>0, error('Cannot generate poles/zeros as requested'), end
else %control toolbox exists
  zpkobj=zpk(model);
  if no>0, [P,Z]=pzmap(zpkobj);
  else pzmap(zpkobj)
  end
end

% end ../@fidmodel/pzmap.m