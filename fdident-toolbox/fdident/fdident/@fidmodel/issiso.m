function iss = issiso(model)
%ISSISO  True for SISO fidmodel objects.
%
%   ISSISO(SYS) returns 1 (true) if SYS is a single-input,
%   single-output (SISO) model or array of models, and
%   0 (false) otherwise.
%
%   See also SIZE, ISEMPTY.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Aug-1999

sizes = size(model);
iss = all(sizes(1:2)==1);

