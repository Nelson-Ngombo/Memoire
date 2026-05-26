function helpc(obj)
%HELP  Type out detailed Contents help for iddat objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Oct-1998

c=which('@iddat/Contents.m');
if ~isempty(c)
  type(c)
else
  warning('@iddat/Contents.m not found, contents.m is typed')
  type('@iddat/contents.m')
end
%
%end @iddat/helpc.m
