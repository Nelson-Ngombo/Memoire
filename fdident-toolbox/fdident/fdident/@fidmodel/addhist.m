function addhist(object,string)
%ADDHIST Adds string to history property of fidmodel object.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-Oct-1997

ni = nargin;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end

if length(object)==1
   history=get(object,'history');
   ii=size(history,1);
   history{ii+1,1}=string;
   set(object,'history',history);
else
   object1=object(1);
   history=get(object1,'history');
   ii=size(history,1);
   history{ii+1,1}=string;
   set(object1,'history',history);
   object(1)=object1;
end

name=inputname(1);
assignin('caller',name,object)
%
%End of addhist
