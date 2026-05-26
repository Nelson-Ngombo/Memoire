function fsc=optfscale(varargin)
%OPTFSCALE  Calculate optimal scaling frequency for s- and w-domain parameters
%
%       Examples: optfscale(pobj)
%                 optfscale(pobj,'coeffs')
%                 optfscale(pobj,'roots')

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision
%       Last modified: 18-Jul-1999

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
fsc=fdident('private','optfscale',varargin{:});
%End