function Out = eq(obj1,obj2)
%EQ  Returns 1 if all properties (beside some strings, etc) are equal.
%       Properties not considered: Name, Date, Notes, History, Instrumentation
%       See also  @IDDAT/GET, @IDDAT/SET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Sep-1998

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
no = nargout;

d=diff(obj1,obj2);
for ii=1:size(d,1)
   ind=find(d(ii,:)==':');
   if ~isempty(ind)
      str=d(ii,1:ind(1)-1);
      str=fliplr(deblank(fliplr(str)));
      if ~any(findstr(['|',str,'|'],'|obj1|obj2|Name|Date|Notes|History|'))
         Out=0; return
      end
   end
end %for ii
Out=1;
%
% end @iddat/eq.m
