function helpc(obj)
%HELP  Type out detailed Contents help for fiddata objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Jun-2001

c=which('@fiddata/Contents.m');
if ~isempty(c)
  type(c)
else
  warning('@fiddata/Contents.m not found, contents.m is typed')
  type('@fiddata/contents.m')
end
%
%end @fiddata/helpc.m
