function Out=issingleexc(Fdat)
%ISSINGLEEXC  Check if experiments are excited in a single channel or not

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

Out=(0<[exc_channels(Fdat),0]);
Out(end)=[];
%End of @fiddata/issingleexc
