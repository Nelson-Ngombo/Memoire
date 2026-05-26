function idssmodel = idss(model)
%IDSS  Convert fidmodel to idss.
%

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Apr-2000

if strcmp(model.representation,'orthopol')
  error('Conversion from orthogonal representation is not yet implemented')
elseif strcmp(model.representation,'polynomial')
else error('unknown representation')
end
idssmodel=idss(idpoly(model));
