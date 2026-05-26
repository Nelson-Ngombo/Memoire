function Fdatm=mrdivide(Fdat,term)
%MRDIVIDE Realize division of fiddata object with scalar, fiddata or fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 28-Nov-2000

if isa(Fdat,'numeric')&isa(term,'fiddata')
  %2/Fdat
  tmp=Fdat; Fdat=term; term=tmp;
  %Reciprocal
  inp=get(Fdat,'input'); outp=get(Fdat,'output');
  iv=get(Fdat,'inputvar'); ov=get(Fdat,'outputvar'); c=get(Fdat,'covvect');
  in=get(Fdat,'inputname'); on=get(Fdat,'outputname');
  set(Fdat,'input',outp,'output',inp,'inputvar',ov,'outputvar',iv,...
    'outputname',in,'inputname',on);
  Fdatm=mtimes(Fdat,term);
end
if ~isa(Fdat,'fiddata'), error('Fdat is not ''fiddata'''), end

if isa(term,'numeric')
  if isequal(term,1), Fdatm=Fdat;
  else Fdatm=mtimes(Fdat,1/term);
  end
elseif isa(term,'fiddata')
  Fdatm=mtimes(Fdat,1/term);  
elseif isa(term,'fidmodel')
  if size(Fdat,2)==1
    Fdatm=modifyfv(Fdat,term,'noplot');  
  else
    Fdatm=Fdat;
    for ii=1:size(Fdat,2)
      Fdatm=subsasgn(Fdatm,struct('type','{}','subs',{{':',ii}}),...
        modifyfv(subsref(Fdatm,struct('type','{}','subs',{{':',ii}})),term,'noplot'));  
    end %for ii
  end
else
  error(['Class of ''term'' is ''',class(term),''''])
end
%Function '*' not defined for variables of class 'fiddata'.
%
%End of @fiddata/mrdivide
