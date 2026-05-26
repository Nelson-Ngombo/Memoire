function helpc(obj)
%HELP  Type out detailed Contents help for fidmodel objects

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Oct-1998

c=which('@fidmodel/Contents.m');
if ~isempty(c)
  type(c)
else
  warning('@fidmodel/Contents.m not found, contents.m is typed')
  type('@fidmodel/contents.m')
end
%
%end @fidmodel/helpc.m
