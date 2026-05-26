function Fdatm=times(Fdat,term)
%MTIMES Multiplication of all data in fiddata object
%
%       Term must be a scalar or a cell vector, and it multiplies the output.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jun-1999

if isa(Fdat,'double')|isa(Fdat,'cell')
  tmp=Fdat; Fdat=term; term=tmp;
end

if isa(term,'numeric')
  if length(term)~=1, error('term must be a double scalar'), end
  termc=cell(get(Fdat,'ChNumber'),1);
  for ii=1:length(termc)
    termc{ii}=term;
  end
  Fdatm=mtimes(Fdat,termc);
elseif iscell(term)
  Fdatm=mtimes(Fdat,term);
else
  error('.* may only be used between fiddata and a double scalar or a cell vector')
end
%
%End of @fiddata/times