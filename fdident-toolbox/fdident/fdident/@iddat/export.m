function Outstruct = export(obj,mode)
%EXPORT  Export object as structure or variables in the base workspace
%
%       Examples: 
%         s=export(dataobj);
%         export(dataobj,'vars') %clear base workspace, then creates variables

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Sep-2003

no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
if nargin<2, mode=''; end
if isempty(mode)|strcmp(mode,'vars')
else error(['mode is invalid> ''',mode,''''])
end

date=obj.Date; obj.Date='';
f=fiddata; f.Date='';
if isequal(obj,f)
  plist=1;
  Out=set(obj);
  fns=fieldnames(Out);
  for ii=1:length(fns)
    if strcmp(fns{ii},'Version')
      Out.Version=get(fiddata,'Version');
    else
      if ischar(get(obj,fns{ii})), Out=setfield(Out,fns{ii},'');
      elseif iscell(get(obj,fns{ii})), Out=setfield(Out,fns{ii},{});
      else Out=setfield(Out,fns{ii},[]);
      end
    end
  end
else %list of true properties
  plist=0;
  obj.Date=date; %restore
  Out=get(obj);
  if isfield(Out,'Data')
    if isa(Out.Data,'fiddata'), Out.Data=export(Out.Data); end
  end
end

if isfield(Out,'Frequencies')&isfield(Out,'OutputFrequencies')&isfield(Out,'InputFrequencies')&...
      ~isempty(Out.Frequencies)
  if (isequal(Out.Frequencies,Out.InputFrequencies)|isempty(Out.InputFrequencies)) & ...
      (isequal(Out.Frequencies,Out.OutputFrequencies)|isempty(Out.OutputFrequencies))
    Out=rmfield(Out,'InputFrequencies');
    Out=rmfield(Out,'OutputFrequencies');
  end
end
fns={'u','y','CovarianceMatrix','AllFreqPoints','FreqIndices','Instrumentation',...
    'NonlinError','InputNonlinError','OutputNonlinError','NonlinM','NonlinCovarianceMatrix',...
    'NonlinCovVector','Variance','Speciality','Type','Coherence',...
    'Groups_Synchronized','Groups_Delayed','Groups_SamePower','Groups_FullMIMO','CohVector','FreqNumber',...
    'N','ChNumber','InputChNumber','OutputChNumber','ExpNumber','SampleNumber'};
if plist, fns=[fns,{'Information'}]; end
for fn=fns
  if isfield(Out,fn{1}), 
    Out=rmfield(Out,fn{1});  
  else
    %warning(['Property ''',fn{1},''' does not exist'])
  end  
end

if no>=1
  Outstruct=Out;
end
if strcmp(mode,'vars')
  evalin('base','clear')
  struct2vars(Out)
end
%End of export


function struct2vars(s)
%STRUCT2VARS  Generate variables from structure fields

if ~isstruct(s), error('s is not a structure'), end
fns=fieldnames(s);
for ii=1:length(fns)
  assignin('base',fns{ii},getfield(s,fns{ii}))
end

% end of file @fidmodel/export.m
