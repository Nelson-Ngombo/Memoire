function Out = isequal(obj1,obj2)
%ISEQAL  Returns 1 if all properties (beside some strings, etc) are equal.
%       See also  @FIDMODEL/EQ.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Jul-2002

if ~strcmp(class(obj1),class(obj2)), Out=0; return, end
Out=eq(obj1,obj2);

% end @fidmodel/isequal.m
