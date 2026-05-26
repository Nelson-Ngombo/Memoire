function out=nonlinvar2var(mod)
%NONLINVAR2VAR  Move "nonlinear variance" properties to variance

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Apr-2005

out=mod;
set(out,'data',nonlinvar2var(get(out,'data')));

%
%end @fidmodel/nonlinvar2var.m