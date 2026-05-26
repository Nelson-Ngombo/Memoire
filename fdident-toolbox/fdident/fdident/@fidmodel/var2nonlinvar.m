function out=var2nonlinvar(mod)
%VAR2NONLINVAR  Move variance properties to "nonlinear variance"

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Apr-2005

out=mod;
set(out,'data',var2nonlinvar(get(out,'data')));
%
%end @fidmodel/var2nonlinvar.m