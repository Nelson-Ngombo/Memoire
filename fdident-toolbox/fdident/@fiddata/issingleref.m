function Out=issingleref(Fdat)
%ISSINGLEREF  Check if fullMIMO experiments are decoupled using the Reference property

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

Out=((0<abs([ref_channels(Fdat),0])));
Out(end)=[];
%End of @fiddata/issingleref
