function iss = issiso(data)
%ISSISO  True for SISO tiddata or fiddata objects (NOT for single channel).
%
%   ISSISO(DATA) returns 1 (true) if DATA is a single-input,
%   single-output (SISO) data or array of datas, and
%   0 (false) otherwise.
%
%   See also SIZE, STACK.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Aug-1999

iss=(get(data,'chnumber')==2)&~isempty(get(data,'input'))&~isempty(get(data,'output'));

