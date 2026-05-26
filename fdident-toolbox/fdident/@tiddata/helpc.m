function helpc(obj)
%HELP  Type out detailed Contents help for tiddata objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Oct-1998

c=which('@tiddata/Contents.m');
if ~isempty(c)
  type(c)
else
  warning('@tiddata/Contents.m not found, contents.m is typed')
  type('@tiddata/contents.m')
end
%
%end @tiddata/helpc.m
