function Fdat=frf_power(inpval,window)
%FRF_POWER  Calculate FRF as Guy(k)/Guu(k)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2009
%       All rights reserved.
%       $Revision: $
%       Last modified: 28-Apr-2009

Fdat=windowing(inpval,window);
if strcmp(window,'rect') %nothing to do
else %if strcmp(window,'sine')|strcmp(window,'Hanning')
  Fdat=windowing(Fdat,window);
end
set(Fdat,'delay',[]);
U=get(Fdat,'inputdata'); if ~iscell(U), U={U}; end
Y=get(Fdat,'outputdata'); if ~iscell(Y), Y={Y}; end
for ie=1:get(Fdat,'expn')
  Yi=Y{ie}; Ui=U{ie};
  Y{ie}=Yi.*conj(Ui);
  U{ie}=Ui.*conj(Ui);
end %for ie
set(Fdat,'inputdata',U); set(Fdat,'outputdata',Y);
% end ../@fiddata/frf_power.m