function dcobj=applyref(obj)
%APPLYREF  Apply reference for synchronization

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Jan-2004

dcobj=obj;
fullmimo_groups=get(obj,'Groups_FullMIMO');
if ~isempty(fullmimo_groups)
  error('Cannot apply reference to full MIMO experiments')
end
%
for ii=1:get(obj,'expnumber')
  Struc.type='{}'; Struc.subs={':',ii};
  objii=subsref(obj,Struc);
  Data=get(obj,'Data'); Ref=get(obj,'Ref'); if ~iscell(Ref), Ref={Ref}; end
  for ir=1:size(Ref,1)
    if any(Ref{ir}), Refi=Ref{ir}; break, end
  end
  ind=find(Refi);
  for id=1:size(Data,1), Data{id,ii}=Data{id,ii}./Refi; end
end
set(objii,'Data',Data);
%
%End of applyref