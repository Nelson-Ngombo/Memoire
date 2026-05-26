function frdobj=idfrd(varargin)
%FRD  Transform fiddata object to idfrd object
%
%       Usage: 
%         frobj=idfrd(fiddata_object);
%         frobj=idfrd(fiddata_object,propery1,value1,property2,value2);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Apr-2003

ni = nargin;
no = nargout;
if no>1
  error('Only one output argument is allowed')
end
obj=varargin{1};
if exist('@idfrd/idfrd.m') %frd found
  if get(obj,'chn')~=2
    error(sprintf('Cannot convert data with %.0f channels',get(obj,'chn')))
  end
  input=get(obj,'input');
  if iscell(input)|(min(size(input))~=1)
    error('Input data does not contain SISO measurements with one experiment')
  end
  U=get(obj,'input');
  Y=get(obj,'output');
  ResponseData=Y./U;
  Frequency=get(obj,'freqpoints'); F=length(Frequency);
  frdobj=idfrd(ResponseData,Frequency*2*pi,'Units','rad/s');
  fs=obj.Fs;
  if ~isempty(fs)&~isnan(fs), frdobj.Ts=1/fs; end
  InputDelay=get(obj,'InputDelay');
  OutputDelay=get(obj,'OutputDelay');
  frdobj.InputDelay=InputDelay-OutputDelay;
  vararr=get(obj,'SiSoVariance');
  covarr=zeros(1,1,F,2,2);
  covarr(1,1,:,1,1)=vararr(:,1)./abs(U).^2/2;
  if any(vararr(:,2))
    warning('Input variance is transformed to the output')
    covarr(1,1,:,1,1)=permute(covarr(1,1,:,1,1),[3,1,2,4,5])+(abs(Y./U).^2)./(abs(U).^2).*vararr(:,2)/2;
  end
  if size(vararr,2)==3
		covarr(1,1,:,1,1)=permute(covarr(1,1,:,1,1),[3,1,2,4,5])-real(vararr(:,3).*conj(Y./U)./abs(U).^2);
  end
  covarr(1,1,:,2,2)=covarr(1,1,:,1,1);
  frdobj.covariance=covarr;
  frdobj.InputName = get(obj,'InputName');
  frdobj.OutputName = get(obj,'OutputName');
  set(frdobj,'Notes',get(obj,'Notes'),'UserData',get(obj,'UserData'))
  for ii=2:2:length(varargin)-1
    set(frdobj,varargin{ii},varargin{ii+1})
  end
else %idfrd directory is missing, structure is generated
  warning('idfrd.m not found: structure is generated')
  error('Not yet ready')
end

% end ../@fiddata/frd.m