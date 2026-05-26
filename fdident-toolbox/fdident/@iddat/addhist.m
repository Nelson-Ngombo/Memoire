function addhist(object,string)
%ADDHIST Adds string to history property of iddat object.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Sep-1998

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end

history=get(object,'history');
if isstr(history), history={history}; end
if isempty(history), history={}; end
ii=size(history,1);
if isstr(string)
  history{ii+1,1}=string;
elseif iscell(string)
  for iii=1:size(string,1)
    history{ii+1,1}=string{iii,1};
    ii=ii+1;
  end %for
else
  error(['Invalid class of string: ''',class(string),''''])
end
if isempty(history{1}), history(1)=''; end
set(object,'history',history,'noconsistency');

name=inputname(1);
assignin('caller',name,object)
%
%End of @iddat/addhist
