function rmexp(obj,expi)
%RMEXP  Remove experiment from object
%
%       rmexp(obj,expi)
%         expi is the name of the experiment, or number of the
%         experiment

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Dec-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if isempty(expi), return, end
if ~isnumeric(expi), expi=getexpnos(obj,expi); end
exps=[1:get(obj,'expnumber')]';
exps(expi)=[];
Struct.type='{}'; Struct.subs={':',expi};
obj=subsref(obj,Struct);
assignin('caller',inputname(1),obj)
%End of rmexp