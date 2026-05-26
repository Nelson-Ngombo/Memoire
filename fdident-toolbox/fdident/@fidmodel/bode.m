function [mag,phase,w] = bode(varargin)
%BODE  Plot fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Oct-1998

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
obj=varargin{1};

if ~exist('@zpk/zpk.m')%|strcmp(obj.variable,'w')
  warning('Control toolbox is not installed, calling ploteltf')
  if no>0, error('Cannot generate mag/phase vectors as requested'), end
  li=length(varargin);
  w=varargin{length(varargin)}; mods=varargin;
  if isa(w,'double')
    freqs=[min(varargin{li}),max(varargin{li})];
    mods(li)=[];
  else
    freqs=[];
  end
  if iscell(mods)
    mod1=mods{1};
    if length(mods)>1, mod2=mods{2}; else mod2=[]; end
  else
    mod1=mods; mod2=[];
  end
  if isa(mod2,'fiddata'), mod3=mod2; mod2=[]; else mod3=[]; end
  ploteltf(mod1,mod2,mod3,['log'+0,freqs/2/pi])
  if isa(mod1,'fiddata')
    if isa(mod3,'fiddata'), mod3=[mod3,mod1]; mod1=[];
    elseif isempty(mod3), mod3=mod1; mod1=[]; 
    end
  end
else %control toolbox exists
  instr='zpk(obj)';
  for ii=2:length(varargin)
    if isa(varargin{ii},'double') %frequency vector
      instr=[instr,',varargin{',int2str(ii),'}'];      
    else %model
      instr=[instr,',zpk(varargin{',int2str(ii),'})'];
    end
  end
      
  if no>0,
    eval(['[mag,phase,w]=bode(',instr,');'])
  else
    eval(['bode(',instr,');'])
    %bode(zpk(obj));  
  end
end

% end ../@fidmodel/bode.m