function dat = iddat(strucv)
%IDDAT Creation function for the IDDAT data object.
%
%       This is a parent object for the objects tiddata and fiddata.
%       Please do not use it by itself.

%       To obtain a detailed list of properties and possibilities, 
%       type 'help(iddat)' or 'helpc(iddat)'

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-May-2002

dversion=1.3; %Current version of object
%
if nargin==1 %one input argument given 
  if isa(strucv,'fiddata'), dat=fiddata(strucv); return
  elseif isa(strucv,'tiddata'), dat=tiddata(strucv); return
  elseif isa(strucv,'iddat')
    if length(strucv)>1, error('iddat is an array'), end
    id=iddat;
    if strucv.Version==id.Version, dat=strucv; return, end %nothing to do
    strucv=struct(strucv); %Maybe old iddat? Handle as structure
  elseif isa(strucv,'iddata')
    dat = iddata2iddat(strucv);
    return
  end
  if isa(strucv,'struct')
    %Either result of load of old version, or structure to be converted
    %Here handle earlier versions loaded from MAT-files
    %
    if ~isfield(strucv,'PeriodLength')
      error('There is no field PeriodLength in the structure')
    elseif ~isfield(strucv,'ChTypes')
      error('There is no field ChTypes in the structure')
    end
    if any(strucv.Version==[1.1,1.2])
      %if strucv.Version<dversion
      %  warning(sprintf(['Earlier iddat object version %.1f is found, ',...
      %      'converted to current iddat'],strucv.Version))
      %end
      %
      strucv.Version=dversion;
      %Version 1.2 -> 1.3
      if ~isfield(strucv,'NewProperties'), strucv.NewProperties=[]; end
      dat=class(strucv,'iddat'); %set class
      set(dat,'Version',get(dat,'Version')); %consistency check
    elseif any(strucv.Version==1.3)
      %warning(sprintf(['Earlier iddat object version %.1f is found, ',...
      %    'converted to current iddat'],strucv.Version))
      dat=class(strucv,'iddat'); %set class
    else
      error(sprintf('iddat version %.3g cannot be converted',strucv.Version))
    end
    return
  elseif isa(strucv,'cell')
    for ii=1:prod(size(strucv))
      strucv{ii}=iddat(strucv{ii});
    end
    dat=strucv;
    return
  else
    error(['Class of strucv is ''',class(strucv),''''])
  end
end %nargin==1

% Define default property values in new object.
dat=struct(...
  'Name','',...
  'Version',dversion,...
  'Date','',...
  'Notes','',...
  'History','',...
  'Instrumentation',[],...
  'UserData',[],...
  'Data',[],...
  'ChTypes',[],...
  'Names','',...
  'Characters','',...
  'Units','',...
  'Scales',[],...
  'PeriodLength',[],...
  'Frequencies',[],...
  'State','',...
  'Synchronization',''...
  ,'NewProperties',[]);
dat.NewProperties.ExperimentName='';
%
dat.Date=datestr(now);
dat=class(dat,'iddat');
%if ~get(dat,'consistency'), error('Inconsistent data in iddat object'), end
%
%end of function ../@iddat/iddat.m

function obj = iddata2iddat(idobj);
%IDDATA2IDDAT  Transform iddata object to fiddata or tiddata object

ni = nargin;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
no = nargout;
if no>1, error('Only one output argument is allowed'), end

input=get(idobj,'inputdata');
output=get(idobj,'outputdata');
dom=get(idobj,'Domain');
%
if strcmpi(dom,'time')
  Ts=get(idobj,'Ts');
  if isempty(Ts), si=get(idobj,'SamplingInstants'); else si=[]; end
  tu=get(idobj,'timeunit');
  tsc=1;
  if strcmp(tu,'ms'), tsc=1e-3; 
  elseif strcmp(tu,'us'), tsc=1e-6; 
  elseif isempty(tu)|strcmp(tu,'s')|strcmpi(tu,'seconds')
  else error(['Unknown time unit: ',tu])
  end
  if ~isempty(Ts)
    if isnumeric(Ts), Ts=tsc*Ts;
    elseif iscell(Ts)
      for ii=1:prod(size(Ts)), Ts{ii}=Ts{ii}*tsc; end
    else error('Ts is unknown')
    end
  end
  if ~isempty(si)
    if isnumeric(si), si=si*tsc; 
    elseif iscell(si)
      for ii=1:prod(size(si)), si{ii}=si{ii}*tsc; end
    end
  end
elseif strcmpi(dom,'frequency')
  vm=version;
  if str2num(vm(1:3))>=6.5
    try, si=get(idobj,'Frequency');
      if isstr(si)|isempty(si)
        try, si=get(idobj,'SamplingFrequencies');
        catch, si=[];
        end
      end
    catch, si=[];
    end
  else %6.1 or earlier
    try, si=get(idobj,'SamplingFrequencies');
    catch, error('Cannot get property ''SamplingFrequencies''')
    end
  end
  fu=get(idobj,'frequencyunit');
  if isempty(fu), fu='';
  elseif isnumeric(fu)|(iscell(fu)&isnumeric(fu{1,1}))
    warning('FrequencyUnit is still wrong'), fu='';
  end
  fsc=1;
  if strcmp(fu,'mHz')|strcmp(fu,'mhz'), fsc=1e-3; 
  elseif strcmpi(fu,'kHz'), fsc=1e3;
  elseif strcmp(fu,'MHz'), fsc=1e6;
  elseif strcmp(fu,'GHz'), fsc=1e9;
  elseif isempty(fu)|strcmpi(fu,'Hz')
  elseif isempty(fu)|strcmpi(fu,'rad/s')
  elseif isempty(fu)|strcmpi(fu,'krad/s'), fsc=1e3;
  elseif isempty(fu)|strcmpi(fu,'Mrad/s'), fsc=1e6;
  else error(['Unknown frequency unit: ',fu])
  end
  if ~isempty(si)
    if isnumeric(si), si=si*fsc; 
    elseif iscell(si)
      for ii=1:prod(size(si)), si{ii}=si{ii}*fsc; end
    end
  end
else
  error('domain unknown')
end
if iscell(si)
  siempty=1; sieq=1; si1=si{1};
  for ii=1:length(si)
    if ~isempty(si{ii}), siempty=0; end
    if ~isequal(si1,si{ii}), sieq=0; end
  end %for ii
  if siempty, si=[];
  elseif length(si)==1, si=si{1};
  end
  if iscell(si)&sieq, si=si{1}; end
end
%
if strcmpi(dom,'frequency')
  obj=fiddata(output,input,si);
elseif strcmpi(dom,'time')
  obj=tiddata(output,input,Ts);
  if ~isempty(si), set(obj,'SamplingInstants',si); end
end    
if 0 %error in iddata
	vid=get(idobj,'version');
	if isstr(vid)&(strcmp(vid(1),'0')|all(vid(1:3)<='1.0'))
		%Conversion OK
	else
		disp('iddata properties may have been changed.')
		if isnumeric(vid), vid=num2str(vid); end
		disp(['  Recent iddata version: ',vid,', known version: 1.0'])
		%error('iddata conversion error possible')
	end
end
%
name=get(idobj,'name');
if ~isempty(name), set(obj,'name',name,'noconsistency'), end
iu=get(idobj,'inputunit');
if ~isempty(iu), set(obj,'inputunit',iu,'noconsistency'), end
ou=get(idobj,'outputunit');
if ~isempty(ou), set(obj,'outputunit',ou,'noconsistency'), end
in=get(idobj,'inputname');
if ~isempty(in), set(obj,'inputname',in,'noconsistency'), end
on=get(idobj,'outputname');
if ~isempty(on), set(obj,'outputname',on,'noconsistency'), end
en=get(idobj,'ExperimentName');
if ~isempty(en), set(obj,'experimentname',en,'noconsistency'), end
pl=get(idobj,'period');
if ~isempty(pl)
  if iscell(pl)
    pleq=1; pl1=pl{1};
    for ii=2:length(pl)
      if ~isequal(pl1,pl{ii}), pleq=0; end
    end
    if pleq, pl=pl1; end
  end
  if iscell(pl)|isfinite(pl), set(obj,'periodlength',pl,'noconsistency'), end
end
ic=get(idobj,'intersample');
if ~isempty(ic)
  if strcmpi(ic,'ZOH'), ic='ZOH'; oc='Samples';
  elseif strcmpi(ic,'FOH'), ic='FOH'; oc='Samples';
  elseif strcmpi(ic,'BL'), ic='BL'; oc='BL';
  elseif strcmpi(ic,'Samples'), ic='Samples'; oc=Samples';
  elseif strcmpi(ic,'AASamples'), ic='BL'; oc='BL';
  else error(['Unknown intersample value ''',ic,''''])
  end
  icn=get(obj,'inputchnumber'); ocn=get(obj,'outputchnumber');
  if icn==0, ic='';
  elseif icn>1, ic={ic}; for ii=2:icn, ic{ii,1}=ic{1}; end
  end
  if ocn==0, oc='';
  elseif ocn>1, oc={oc}; for ii=2:ocn, oc{ii,1}=oc{1}; end
  end
  set(obj,'inputcharacter',ic,'outputcharacter',oc,'noconsistency');
end
notes=get(idobj,'notes');
if ~isempty(notes)
  %if isstr(notes)&size(notes,1)>1
  %  tmp=notes; notes={};
  %  for ii=1:size(tmp,1), notes(ii,:)={deblank(tmp(ii,:))}; end
  %end
  set(obj,'notes',notes,'noconsistency')
end
ud=get(idobj,'userdata');
if ~isempty(ud), set(obj,'userdata',ud,'noconsistency'), end
if isa(obj,'tiddata')
  %try, tst=get(idobj,'tstart'); catch, tst=[]; end
  tst=get(idobj,'tstart');
  if ~isempty(tst), set(obj,'TStart',tst,'noconsistency'); end
  if ~isempty(si), set(obj,'SamplingInstants',si,'noconsistency'); end
end
try
  tim=timestamp(idobj);
  if ~isempty(tim)
    t=tim(1,:);
    sp=find(isspace(t));
    t(1:sp(1))='';
    t=fliplr(deblank(fliplr(deblank(t))));
    set(obj,'date',t);
  end
catch
end
try
  ename=get(idobj,'ExperimentName');
  if ~isempty(ename)&iscell(ename)
    ens=size(ename);
    if all(ens>0)&any(ens>1)
      if ~isequal(ens(2),get(obj,'expnumber'))&isequal(ens(1),get(obj,'expnumber'))
        %column instead of row
        ename=ename';
      end
    end
  end
catch
  ename='';
end
if ~isempty(ename), set(obj,'ExperimentName',ename,'noconsistency'); end
%
if get(obj,'consistency')~=1
  error('Generated object is inconsistent: see the warning message above for the reason')
end
addhist(obj,['Converted from iddata object, on ',date])
%
%End of iddata2iddat
%
%End of file ../@iddat/iddat.m
