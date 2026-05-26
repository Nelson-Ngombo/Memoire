function [RE,IM,W] = nyquist(varargin)
%NYQUIST  nyquist plot of fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 25-Oct-2000

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
obj=varargin{1};

if ~exist('@zpk/zpk.m')%|strcmp(obj.variable,'w')
  error('Control toolbox is not installed')
else %control toolbox exists
  ltiobj=zpk(obj);
  varargin{1}=ltiobj;
  if nargout==0
    nyquist(ltiobj);
  elseif nargout==1
    [RE]=nyquist(varargin{:});
  elseif nargout==2
    [RE,IM]=nyquist(varargin{:});
  elseif nargout==3
    [RE,IM,W]=nyquist(varargin{:});
  else
    error('Too many output arguments')
  end
end  % end ../@fidmodel/nyquist.m