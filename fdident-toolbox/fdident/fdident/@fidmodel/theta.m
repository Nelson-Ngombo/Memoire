function thetavar=theta(mod,noisemod)
%THETA Convert fidmodel object to theta format (System Identification Toolbox)
%
%       thetavar=theta(mod,noisemod)
%
%       Output argument:
%       thetavar = theta matrix
%           Entries filled in with zeros:
%           thetavar(2,1) = Final Prediction Error
%           thetavar(3+nb+[1:nc+nd],nb+[1:nc+nd]) = 
%                      covariances of the coefficients of C and D
%
%       Input arguments:
%       mod = fidmodel object to be converted
%       noisemod = output noise shaping filter (fidmodel object)
%           If it is a scalar, time domain unit white noise is just
%           multiplied with this factor.
%           If the variance of the real and of the imaginary parts of the
%           complex amplitudes is vary everywhere in the N-point spectrum,
%           calculate the constant as follows:  varet=2/N*vary
%
%       Usage: thetavar=elis2tha(mod,noisemod);
%       Example: load inpchmod
%                thetavar=theta(inpchanz,2/256*1e-9);
%
%       See also: ELIS2THA, THA2ELIS; System Identification Toolbox.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jan-1999

if ~exist('poly2th')&~exist('mktheta')
  error(sprintf(['The function m-file ''poly2th'' or ''mktheta'' of the ',...
        'System Identification Toolbox\n      is required for the ',...
        'execution of this routine']))
end
%
numn=1; denomn=1;
if nargin<2, noisemod=[]; end
if isa(mod,'fidmodel')
  cdat=mod.covariance;
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,2,ni)), %earlier
  end
  if isa(noisemod,'fidmodel')
    numn=noisemod.num; denomn=noisemod.denom; varet=1;
  elseif (length(noisemod)==1)&isnumeric(noisemod)&(noisemod>=0)
    varet=noisemod;
  else
    error('noisemod is invalid')
  end
  noisemod=[];
else
  error('mod is not an fidmodel object')
end
thetavar=elis2tha(mod,cdat,varet,numn,denomn);
%%%%%%%%%%%%%%%%%%%%%%%% end of theta %%%%%%%%%%%%%%%%%%%%%%%%