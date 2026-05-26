function tdatm=times(tdat,term)
%MTIMES Multiplication of all data in tiddata object
%
%       Term must be a scalar or a cell vector, and it multiplies the output.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jun-1999

if isa(tdat,'double')|isa(tdat,'cell')
  tmp=tdat; tdat=term; term=tmp;
end

if isa(term,'numeric')
  if length(term)~=1, error('term must be a double scalar'), end
  termc=cell(get(tdat,'ChNumber'),1);
  for ii=1:length(termc)
    termc{ii}=term;
  end
  tdatm=mtimes(tdat,termc);
elseif iscell(term)
  tdatm=mtimes(tdat,term);
else
  error('.* may only be used between tiddata and a double scalar or a cell vector')
end
%
%End of @tiddata/times