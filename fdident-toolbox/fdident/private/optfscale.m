function fsc=optfscale(varargin)
%OPTFSCALE Calculate optimal scaling frequency for s- and w-domain parameters
%
%       Examples: optscale(num,denom)
%                 optscale(num,denom,'w')
%                 optscale(pobj)
%                 optscale(Fobj)
%                 optscale(pobj,'coeffs'), optscale(pobj,'roots')

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision
%       Last modified: 18-Jul-1999

fs=1; fsc=1; domain='s'; ni=nargin;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,4); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,4,ni)), %earlier
end
type='roots';
if isstr(varargin{end})&strncmp(varargin{end},'roots',4)
  type='roots'; ni=ni-1;
elseif isstr(varargin{end})&strncmp(varargin{end},'coeffs',5)
  type='coeffs'; ni=ni-1;
end
if isnumeric(varargin{1})&(size(varargin{1},1)>1)
  [domain,num,denom]=imppar(varargin{1},fsc); %result of exppar
elseif isnumeric(varargin{1})|iscell(varargin{1})
  num=varargin{1};
  if ni>=2, denom=varargin{2}; end
  if ni>=3, domain=varargin{3}; end
elseif isa(varargin{1},'fidmodel')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,2,ni)), %earlier
  end
  pdat=varargin{1};
  if strcmp(pdat.representation,'orthopol')
    fsc=pdat.fscale;
  elseif strcmp(pdat.variable,'z')
    fsc=pdat.fs;
  else
    if ~isempty(pdat.data), fsc=optfscale(pdat.data); end
    [domain,num,denom]=imppar(pdat,fsc);
  end
elseif isa(varargin{1},'fiddata')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
  else ni=nargin; error(nargchk(1,1,ni)), %earlier
  end
  Fdat=varargin{1};
  fv=Fdat.freqpoints;
  if iscell(fv), fv=cat(1,fv{:}); end
  fsc=pi*(min(fv)+max(fv));
  return
end
%
if strcmp(type,'roots')
  if isnumeric(num), num={num}; end
  if isnumeric(denom), denom={denom}; end
  pz=[];
  for ii=1:prod(size(num))
     if all(isfinite(num{ii}))
        pz=[pz;roots(num{ii})];
     end
  end
  for ii=1:prod(size(denom))
     if all(isfinite(denom{ii}))     
        pz=[pz;roots(denom{ii})];
     end
  end
  ind=find(imag([pz;0])~=0);
  if length(ind)>0, fs=median(abs(imag(pz(ind)))); end
elseif strcmp(type,'coeffs')
  numnlz=num; %no leading zero in numnlz
  while numnlz(1)==0, numnlz(1)=[]; end
  lnum=length(numnlz);
  if lnum>=2,
    numsc=max(abs(numnlz(1)),2*max(abs(numnlz))*realmin);
    cnav=median(abs(numnlz(2:lnum)/numsc).^((1.0)./[1:lnum-1]));
    weightnum=sum(num~=0)-1;
  else
    cnav=0; weightnum=0;
  end
  if cnav==0, weightnum=0; end
  %
  denomnlz=denom; %no leading zero in denomnlz
  while denomnlz(1)==0, denomnlz(1)=[]; end
  ldenom=length(denomnlz);
  if ldenom>=2,
    denomsc=max(abs(denomnlz(1)),2*max(abs(denomnlz))*realmin);
    cdav=median(abs(denomnlz(2:ldenom)/denomsc).^((1.0)./[1:ldenom-1]));
    weightdenom=sum(denom~=0)-1;
  else
    cdav=0; weightdenom=0;
  end
  if cdav==0, weightdenom=0; end
  %
  if (weightnum+weightdenom)==0, fs=1;
  else
    fs=2/3*(weightnum*cnav+weightdenom*cdav)/(weightnum+weightdenom);
    %fs=mean(abs([roots(num);roots(denom)])); %alternative suggested fs
    if strcmp(domain,'w')&isfinite(fs^2), fs=fs^2; end
  end
  if isnan(fs)|(fs==0), fs=1; end
  if ~isfinite(fs), fs=realmax; end
  %
else
  error('type is invalid')
end
%
fsc=fsc*fs;
%
%End