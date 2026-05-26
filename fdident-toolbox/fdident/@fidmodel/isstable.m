function Out=isstable(imodel)
%ISSTABLE  Determine if model is stable or not

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Dec-2003

polevect=pole(imodel);
if iscell(polevect), Out=zeros(size(polevect));
else Out=0; polevect={polevect};
end
sm=[size(imodel),1];
for ii=1:prod(sm(3:end))
  vari=imodel(ii).variable;
  if strcmp(vari,'z^-1')
    Out(ii)=all(abs(polevect{ii})<1);
  elseif strcmp(vari,'s')|strcmp(vari,'r')
    Out(ii)=all(real(polevect{ii})<0);
  elseif strcmp(vari,'w')
    Out(ii)=~any((real(polevect{ii}.^2)>=0)&(real(polevect{ii})>=0));
  else
    error(['Unknown variable ''',vari,''''])
  end
end

%End of @fidmodel/isstable
