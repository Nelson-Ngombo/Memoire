function outmodel=recalculate(inmodel,mserror)
%RECALCULATE  Recalculate model with given errors or with residuals of model

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 2-Apr-2006

if nargin==2
  if ~isempty(mserror)
    if min(size(mserror))~=1, error('mserror is not a vector'), end
  end
end

_

%End of @fidmodel/recalculate