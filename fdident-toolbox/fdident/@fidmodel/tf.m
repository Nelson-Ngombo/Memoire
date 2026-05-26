function tfobj=tf(obj)
%TF  Transform fidmodel object to tf object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 25-May-2004

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if no>1
  error('Only one output argument is allowed');
end
if strcmp(obj.variable,'w')|strcmp(obj.variable,'r')
  error(['Variable ',obj.variable,' does not allow tf object representation'])
end

[domain,pnum,pdenom,delay,fs,Znum,Zdenom]=imppar(obj);
if strcmp(obj.representation,'orthopol')
  %prepare for export
  warning('Conversion from orthopol representation is potentially badly conditioned')
  freqv=obj.freqvect;
  [pvalnum,pcanum]=fdident('private','orthpval',pnum,Znum,freqv); num=pnum*pcanum;
  [pvaldenom,pcadenom]=fdident('private','orthpval',pdenom,Zdenom,freqv); denom=pdenom*pcadenom;
  if domain=='p'
    num=num./(fs.^[length(num)-1:-1:0]);
    denom=denom./(fs.^[length(denom)-1:-1:0]);
    domain='s';
  else %q
    domain='z^-1';
  end
else
  num=pnum; denom=pdenom;
end

if any(findstr(domain,'z'))
  if strcmp(domain,'z')
    if exist('@tf/tf.m')
      %if isreal(obj.num)&isreal(obj.denom)
        tfobj=tf(num,denom,1/fs,'variable',obj.variable);
      %else
      %  denom=cell(size(num));
      %  for ii=1:length(num(:)), denom{ii}=obj.denom; end
      %  tfobj=tf(num,denom,1/fs);
      %end
    else
      tfobj.num=num;
      tfobj.denom=denom;
      tfobj.Ts=1/fs;
      tfobj.variable=domain;
    end
  else %z^-1
    if ~iscell(num), num={num}; end
    for c=1:min(prod(size(num)),2)
      for ii=1:prod(size(num))
        if length(num{ii})<length(denom)
          num{ii}=[num{ii},zeros(1,length(denom)-length(num{ii}))];
        elseif length(num{ii})>length(denom)
          denom=[denom,zeros(1,length(num{ii})-length(denom))];
        end
      end %for ii
    end %for c
    if exist('@tf/tf.m')
      %if isreal(obj.num)&isreal(obj.denom)
        tfobj=tf(num,denom,1/fs);
      %else
      %  denom=cell(size(num));
      %  for ii=1:length(num(:)), denom{ii}=obj.denom; end
      %  tfobj=tf(num,denom,1/fs);
      %end
    else
      tfobj.num=num;
      tfobj.denom=denom;
      tfobj.Ts=1/fs;
    end
    tfobj.variable=domain;
  end %z or z^-1
elseif strcmp(obj.variable,'s')
  if exist('@tf/tf.m')
    %if isreal(obj.num)&isreal(obj.denom)
      tfobj=tf(num,denom);
    %else
    %  denom=cell(size(num));
    %  for ii=1:length(num(:)), denom{ii}=obj.denom; end
    %  tfobj=tf(num,denom);
    %end
  else
    tfobj.num=num;
    tfobj.denom=denom;
    tfobj.variable='s';
  end
else
  error(['Cannot convert fidmodel with variable ''',obj.variable,''' to tf'])
end
if ~isempty(obj.inputname), tfobj.inputname=obj.inputname; end
if ~isempty(obj.outputname), tfobj.outputname=obj.outputname; end
%s=struct(tfobj);
%if isa(tfobj,'tf')
%  sl=struct(s.lti); 
%  try, Version=sl.Version; catch, Version=[]; end
%  if isequal(Version,1)
%    if ~isempty(obj.delay)
%      if any(findstr('z',tfobj.variable))
%        tfobj=d2d(tfobj,[],round(obj.fs*obj.delay));
%      else
%        tfobj.Td=obj.delay;
%     end
%    end
%  else %later versions
    if ~isempty(obj.inputgroup), tfobj.inputgroup=obj.inputgroup; end
    if ~isempty(obj.outputgroup), tfobj.outputgroup=obj.outputgroup; end
    if ~isempty(obj.inputdelay), tfobj.inputgroup=obj.inputdelay; end
    if ~isempty(obj.outputdelay), tfobj.outputdelay=obj.outputdelay; end
    if ~isempty(obj.delay), tfobj.iodelaymatrix=obj.delay; end
%  end
%end
if ~isempty(obj.notes), tfobj.notes=obj.notes; end
if ~isempty(obj.userdata), tfobj.userdata=obj.userdata; end
if ~isa(tfobj,'tf')
  tfobj.class='tf'; %desired class
end
%
% end @fidmodel/tf.m
