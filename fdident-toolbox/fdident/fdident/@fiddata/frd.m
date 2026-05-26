function frdobj=frd(varargin)
%FRD  Transform fiddata object to frd object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Oct-1998

ni = nargin;
no = nargout;
if no>1
  error('Only one output argument is allowed')
end
obj=varargin{1};
if exist('@frd/frd.m') %frd found
  if get(obj,'chn')~=2
    error(sprintf('Cannot convert data with %.0f channels',get(obj,'chn')))
  end
  input=get(obj,'input');
  if iscell(input)|(min(size(input))~=1)
    error('Input data does not contain SISO measurements with one experiment')
  end
  ResponseData=get(obj,'output')./get(obj,'input');
  Frequency=get(obj,'freqpoints');
  frdobj=frd(ResponseData,Frequency,'Units','Hz');
  fs=obj.Fs;
  if ~isempty(fs)&~isnan(fs), frdobj.Ts=1/fs; end
  InputDelay=get(obj,'InputDelay');
  OutputDelay=get(obj,'OutputDelay');
  frdobj.InputDelay=InputDelay;
  frdobj.OutputDelay=OutputDelay;
  frdobj.ioDelayMatrix=...
    [InputDelay,OutputDelay-InputDelay;
    InputDelay-OutputDelay,OutputDelay];
  frdobj.InputName = get(obj,'InputName');
  frdobj.OutputName = get(obj,'OutputName');
  set(frdobj,'Notes',get(obj,'Notes'),'UserData',get(obj,'UserData'))
  for ii=2:2:length(varargin)-1
    set(frdobj,varargin{ii},varargin{ii+1})
  end
else %tf directory is missing, structure is generated
  warning('frd.m not found: structure is generated')
  error('Not yet ready')
end

% end ../@fiddata/frd.m