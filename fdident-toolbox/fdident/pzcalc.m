function [poles,zeros]=pzcalc(pdat)
%PZCALC Calculate poles and zeros of transfer function values from parameters
%
%       [poles,zeros]=PZCALC(pdat)
%
%       Output arguments:
%       poles = column vector of poles
%       zeros = column vector of zeros
%
%       Input arguments:
%       pdat = fidmodel object or parameter vector (see exppar)
%
%       Usage: [poles,zeros]=pzcalc(pdat);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

pdat=getobjf(pdat,'fidmodel');
if isstr(pdat), pdat=loadasc(pdat); end
if isa(pdat,'idmodel'), pdat=fidmodel(pdat); end
if isnumeric(pdat), pdat=fidmodel(pdat); end
if ~isa(pdat,'fidmodel'), error(['Class of pdat is ''',class(pdat),'''']), end
poles=pole(pdat);
zeros=zero(pdat);
%%%%%%%%%%%%%%%%%%%%%%%% end of pzcalc %%%%%%%%%%%%%%%%%%%%%%%%
