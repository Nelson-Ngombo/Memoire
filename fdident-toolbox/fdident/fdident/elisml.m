function varargout=elisml(varargin)
%ELISML Maximum likelihood estimation of transfer function H(s)
%
%       pvect=ELISML(Fdat,numord,denomord,delay,dfx)
%
%       elisml calls elis with default run parameters, thus providing a
%       simple calling interface. If nonstandard run parameters are required,
%       elis can still be directly invoked.
%
%       Output arguments:
%       pvect = result in fidmodel object form
%
%       Input arguments:
%       Fdat = data in fiddata form, with variance
%       numord = order of numerator
%       denomord = order of denominator
%       delay = delay in seconds (optional, default: 0)
%           for dfx='v', delay is the starting value for the iterations
%       dfx = 'f' for fixed delay, 'v' for variable delay (default: 'f')
%
%       Usage: pvect=elisml(Fdat,numord,denomord,delay,dfx);
%       Example: pv=elisml('inpchan(inpchan)',11,12);
%       See also: ELIS.

%Old fdident help
%ELISML Maximum likelihood estimation of transfer function H(s)
%
%       [pvect,fit,Cp]=ELISML(Fdat,vdat,numord,denomord,delay,dfx)
%
%       elisml calls elis with default run parameters, thus providing a simple
%       calling interface. If nonstandard run parameters are required, elis
%       can still be directly invoked.
%
%       Output arguments:
%       pvect = parameters in vector form (for imppar)
%       fit = informative column vector about the fit (see elis for details)
%       Cp = approximate covariance matrix of the parameters
%
%       Input arguments:
%       Fdat = Fourier data ([freq,x,y], Fx3 array)
%       vdat = variance data: Fx2 variance array ([varx,vary]) or
%           Fx3 covariance array ([varx,vary,covxy]), or
%           1x2 row vector of variances ([vx0,vy0]), or
%           1x3 row vector of variances and covariance ([vx0,vy0,cxy0])
%       numord = order of numerator
%       denomord = order of denominator
%       delay = delay in seconds (optional, default: 0)
%           for dfx='v', delay is the starting value for the iterations
%       dfx = 'f' for fixed delay, 'v' for variable delay (default: 'f')
%
%       Usage: [pvect,fit,Cp]=elisml(Fdat,vdat,numord,denomord,delay,dfx);
%       Example: [freqv,x,y]=impfou('inpchan',1);
%                pv=elisml([freqv,x,y],[3.4e-4,3.4e-4],4,6);
%       See also: ELIS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jan-2000

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(3,6); %Matlab 2016a or later
else ni=nargin; error(nargchk(3,6,ni)), %earlier
end
Fdat=getobjf(varargin{1},'fiddata');
delay=[]; dfx='';
if isa(Fdat,'fiddata')
  if nargout>1, error('More than 1 output arguments'), end
  %new call
  vdat=[];
  numord=varargin{2};
  denomord=varargin{3};
  if nargin>=4, delay=varargin{4}; end
  if nargin>=5, dfx=varargin{5}; end
else
  %old call
  if nargin<4, error('Less than 4 input arguments'), end
  vdat=varargin{2};
  numord=varargin{3};
  denomord=varargin{4};
  if nargin>=5, delay=varargin{5}; end
  if nargin>=5, dfx=varargin{6}; end
end
domain='s'; fsm=NaN; %dummy scaling frequency in model estimation
if isempty(dfx), dfx='f'; end
if ~strcmp(dfx,'f')&~strcmp(dfx,'v')
  error(['dfx = ''',dfx,''' is not allowed'])
end
if isempty(delay), delay=0; end
if isnan(delay), delay=0; end
if isstr(delay), error('delay is a string'), end
if length(delay)>1, error('delay is not a scalar'), end
if ~isfinite(delay), error('Infinite delay'), end
%
if isnumeric(Fdat)
  [F,Fw]=size(Fdat);
  if (Fw~=3) & (Fw~=1)
    error('Fdat not allowed')
  end
end
if ~isempty(vdat)
  [vF,vw]=size(vdat);
  if ((Fw==3)&~((vF==F)|(vF==1)))
    error('Fdat and vdat are incompatible')
  end
  if vw>3, error('Width of vdat is larger than 3'), end
end
if length(numord)~=1, error('numord is not a scalar'), end
if isstr(numord), error('numord is a string'), end
if round(numord)~=numord, error('numord is not an integer'), end
if numord<0, error('numord is negative'), end
if length(denomord)~=1, error('denomord is not a scalar'), end
if round(denomord)~=denomord, error('denomord is not an integer'), end
if denomord<0, error('denomord is negative'), end
%
%Call elis
%Levenberg-Marquardt with svd, lambda=0; init approximate ML:
rpalg=['ma'+0,NaN,NaN,NaN,0];
rppl=-1e6; %only last plot
if nargout>=2
  [pvect,fit,Cp]=elis(Fdat,vdat,[domain+0,numord,denomord,fsm],dfx,rpalg,rppl,delay);
  varargout=cell(1,3);
  varargout{1}=pvect;
  varargout{2}=fit;
  varargout{3}=Cp;
else
  pvect=elis(Fdat,vdat,[domain+0,numord,denomord,fsm],dfx,rpalg,rppl,delay);
  varargout={pvect};
end
%
%%%%%%%%%%%%%%%%%%%%%%%% end of elisml %%%%%%%%%%%%%%%%%%%%%%%%
