function Out = getexp(obj,ind)
%GETEXP Select certain experiments

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Aug-2001

ni = nargin;
no = nargout;
if nargin==1, Out=obj; return, end
Struct.type='{}';
if iscell(ind)|isstr(ind), ind=findchnumber(obj,ind); end
Struct.subs={':' ind};
Out=subsref(obj,Struct);
%
%end @iddat/getexp.m
