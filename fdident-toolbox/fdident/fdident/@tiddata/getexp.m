function Out = getexp(obj,ind)
%GETEXP Select certain experiments
%   D = GETEXP(DAT,ExpNumber) or D = GETEXP(DAT,ExpName) extracts specific
%   experiments from the multi-experiment TIDDATA object DAT.  You can refer
%   to particular experiments either by number (e.g., ExpNumber=2) or by name
%   (e.g., ExpName='Day 1').  GETEXP returns a TIDDATA object D containing the 
%   requested experiments.
%
%   Examples: 
%      D = getexp(Dat,2)               D = getexp(Dat,[3 1])
%      D = getexp(Dat,'Period1')       D = getexp(Dat,{'Day 1','Period 2'})
%
%   See also TIDDATA, TIDDATA/MERGE, TIDDATA/SUBSREF.

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
%end @tiddata/getexp.m
